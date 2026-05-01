#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(findAirSpawnPosition);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_findAirSpawnPosition
Description:
    Unified air-unit spawn-position validator. Mirrors the role of
    ALiVE_fnc_findVehicleSpawnPosition for ground vehicles, but with
    aircraft-specific tiers and obstacle rules.

    Cascade (highest preference first):
      1. HELIPAD - HeliH or map-helipad classes within the search radius.
         Rotor-disc footprint check. Helis + VTOLs.
      2. HANGAR  - ALIVE_airBuildingTypes matches. Bbox fits internal
         dimensions (per-axis); openable doors verified via animateSource;
         auto-orient nose-out via raycast clear-distance comparison;
         ALIVE_problematicHangarBuildings retained as final-fallback
         override when raycast is uncertain.
      3. APRON   - paved area near hangars / airport tower. Excluded
         within (taxiwayHalfWidth + bboxHalf + 8) from any taxiway
         centreline and (runwayHalfWidth + bboxHalf + 12) from any
         runway centreline (mil_ato AI taxi/take-off paths must remain
         clear).
      4. FIELD   - open ground inside _maxDistance. Surface whitelist +
         slope filter. Last resort.

    Every tier runs the obstacle-table footprint sweep (rotor disc for
    helis, bbox rectangle for planes) so map-maker-placed HeliH markers
    in cluttered camps don't spawn aircraft on top of fences/walls/signs.

    A session registry (ALiVE_airSpawnRegistry) memoises chosen positions
    with a 60-second TTL; subsequent calls reject candidates within
    bbox-aware separation distance to prevent same-cluster spawn races.

Parameters:
    _this select 0: STRING - aircraft classname.
    _this select 1: ARRAY  - centre position [x, y, z] for the search.
    _this select 2: NUMBER - search radius (default 500 m).
    _this select 3: STRING - "auto" / "helipad" / "hangar" / "apron" /
                             "field" (default "auto").

Returns:
    ARRAY [_pos, _dir] on success, [] on failure.

Examples:
    (begin example)
    private _result = ["B_Heli_Light_01_F", getPosATL player, 600, "auto"]
        call ALiVE_fnc_findAirSpawnPosition;
    if (count _result == 0) exitWith {};
    _result params ["_safePos", "_safeDir"];
    private _veh = createVehicle ["B_Heli_Light_01_F", _safePos, [], 0, "CAN_COLLIDE"];
    _veh setDir _safeDir;
    (end)

See Also:
    ALiVE_fnc_getAirfieldGeometry, ALiVE_fnc_getVehicleBoundingBox,
    ALiVE_fnc_findVehicleSpawnPosition

Author:
    Jman
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params [
    ["_vehicleClass", "", [""]],
    ["_centerPos", [0,0,0], [[]], [2,3]],
    ["_maxDistance", 500, [0]],
    ["_preference", "auto", [""]]
];

if (_vehicleClass == "" || count _centerPos < 2) exitWith { [] };

// ------------------------------------------------------------------------
// Aircraft classification + dimensions.
// ------------------------------------------------------------------------
private _isHeli = _vehicleClass isKindOf "Helicopter";
private _isPlane = _vehicleClass isKindOf "Plane";
private _isVTOL = _isPlane && {(_vehicleClass isKindOf "VTOL_01_base_F") || (_vehicleClass isKindOf "VTOL_02_base_F")};
private _isUAV  = getNumber (configFile >> "CfgVehicles" >> _vehicleClass >> "isUav") > 0;

if !(_isHeli || _isPlane) exitWith { [] };

private _bbox = [_vehicleClass] call ALiVE_fnc_getVehicleBoundingBox;
_bbox params ["_vehLen", "_vehWid", "_vehHt"];
private _hl = _vehLen / 2;
private _hw = _vehWid / 2;
// Effective hazard radius. For helis the rotor disc is the dominant
// hazard; estimate from longest bbox axis with a 0.55 factor (rotors
// extend slightly beyond fuselage). For planes the wingspan IS the
// width axis so use the longer axis directly with a small margin.
private _hazardRadius = if (_isHeli) then {
    (_vehLen max _vehWid) * 0.55
} else {
    (_vehLen max _vehWid) * 0.5 + 0.5
};

// ------------------------------------------------------------------------
// Obstacle tables. Same shape as the ground validator's lists - keep in
// sync with addons/main/fnc_findVehicleSpawnPosition.sqf when adding
// classes.
// ------------------------------------------------------------------------
private _staticTerrainTypes = [
    "BUILDING", "BUNKER", "BUSH", "BUSSTOP", "CHAPEL", "CHURCH", "CROSS",
    "FENCE", "FOREST BORDER", "FOREST SQUARE", "FOREST TRIANGLE", "FOREST",
    "FORTRESS", "FOUNTAIN", "FUELSTATION", "HIDE", "HOSPITAL", "HOUSE",
    "LIGHTHOUSE", "POWER LINES", "POWERSOLAR", "POWERWAVE", "POWERWIND",
    "QUAY", "RAILWAY", "ROCK", "ROCKS", "RUIN", "SHIPWRECK", "SMALL TREE",
    "STACK", "TOURISM", "TRANSMITTER", "TREE", "VIEW-TOWER", "WALL",
    "WATERTOWER", "Wreck_Base"
];
private _classObstacles = [
    "Wall", "House", "AllVehicles",
    "Land_JunkPile_F", "Land_GarbageContainer_closed_F",
    "Land_GarbageBags_F", "Land_Tyres_F", "Land_GarbagePallet_F",
    "Land_Basket_F", "Land_Sack_F", "Land_Sacks_goods_F",
    "Land_Sacks_heap_F", "Land_BarrelTrash_F"
];

// ------------------------------------------------------------------------
// Session registry. Mission-scope, prevents same-cluster races by
// memoising recently-chosen positions for ~60 s.
// ------------------------------------------------------------------------
if (isNil "ALiVE_airSpawnRegistry") then { ALiVE_airSpawnRegistry = []; };
// Prune entries older than 60 s.
private _now = diag_tickTime;
ALiVE_airSpawnRegistry = ALiVE_airSpawnRegistry select { (_x select 2) + 60 > _now };

private _fnc_registryClear = {
    params ["_pos", "_minSeparation"];
    private _occupied = ALiVE_airSpawnRegistry findIf {
        (_pos distance2D (_x select 0)) < _minSeparation
    };
    _occupied < 0
};

// ------------------------------------------------------------------------
// Footprint clearance check. Disc-style for both helis and planes - the
// disc covers all asymmetric overhang at the cost of a slight over-
// rejection on long-fuselage planes (acceptable for spawn safety).
//
// _ignore: an array of objects (the helipad or hangar we're spawning
// at) that should not count as obstacles. Without this, helipads of
// class Land_HelipadEmpty_F (which is `isKindOf "House"`) reject
// themselves on every check, and helipads on or beside terrain-tagged
// BUILDING objects reject on the building hosting them.
// ------------------------------------------------------------------------
private _fnc_footprintClear = {
    params ["_pos", "_dir", ["_ignore", []]];

    // 9-sample sweep at the hazard radius.
    private _samples = [
        _pos,
        _pos getPos [_hazardRadius, 0],
        _pos getPos [_hazardRadius, 90],
        _pos getPos [_hazardRadius, 180],
        _pos getPos [_hazardRadius, 270],
        _pos getPos [_hazardRadius, 45],
        _pos getPos [_hazardRadius, 135],
        _pos getPos [_hazardRadius, 225],
        _pos getPos [_hazardRadius, 315]
    ];

    // Water rejection for non-amphibious craft. Helicopters operate over
    // water, but parking on it is a different proposition - reject
    // unconditionally. Mission-makers wanting carrier spawns should
    // route via the ship-deck path upstream.
    if ({surfaceIsWater _x} count _samples > 0) exitWith { false };

    private _sampleR = 0.5;
    private _terrainHit = _samples findIf {
        private _hits = nearestTerrainObjects [_x, _staticTerrainTypes, _sampleR + 0.5, false, true];
        _hits = _hits - _ignore;
        !(_hits isEqualTo [])
    };
    if (_terrainHit >= 0) exitWith { false };

    private _classHit = _samples findIf {
        private _hits = nearestObjects [_x, _classObstacles, _sampleR + 0.5];
        _hits = _hits - _ignore;
        !(_hits isEqualTo [])
    };
    if (_classHit >= 0) exitWith { false };

    true
};

// ------------------------------------------------------------------------
// Hangar door verification. Returns true if the hangar has at least one
// recognisable door animation source AND all such sources reach phase
// >= 0.95 after an instant open.
//
// Source names come from CfgVehicles >> typeOf veh >> AnimationSources;
// SQF has no run-time command that lists them, so we enumerate the
// config sub-class and filter by name substring.
// ------------------------------------------------------------------------
private _fnc_doorsOpenable = {
    params ["_hangar"];
    private _hangarType = typeOf _hangar;
    private _numDoors = getNumber (configFile >> "CfgVehicles" >> _hangarType >> "numberOfDoors");
    // Doorless hangars (tent hangars, open-fronted shelters) are
    // accessible by design - accept without further checks.
    if (_numDoors <= 0) exitWith { true };

    private _animSrcsConfig = configFile >> "CfgVehicles" >> _hangarType >> "AnimationSources";
    private _doorSources = [];
    if (isClass _animSrcsConfig) then {
        for "_i" from 0 to (count _animSrcsConfig - 1) do {
            private _entry = _animSrcsConfig select _i;
            if (isClass _entry) then {
                private _name = configName _entry;
                private _l = toLower _name;
                // CBA_fnc_find expects [haystack, needle].
                if (([_l, "door"] call CBA_fnc_find != -1) || ([_l, "hangar"] call CBA_fnc_find != -1)) then {
                    _doorSources pushBack _name;
                };
            };
        };
    };
    // numberOfDoors > 0 but no recognisable source - treat as
    // accessible (the doors are conceptual, no animation gate).
    if (count _doorSources == 0) exitWith { true };

    private _allOpen = true;
    {
        _hangar animateSource [_x, 1, true];
        if ((_hangar animationSourcePhase _x) < 0.95) exitWith { _allOpen = false };
    } forEach _doorSources;
    _allOpen
};

// ------------------------------------------------------------------------
// Hangar bbox-centre helper - returns the world-space centre of the
// hangar's bounding box. Many hangar models have their origin at a
// corner or front edge rather than the bay centre, so position _hangar
// is unreliable for both the orientation raycast and the spawn point.
// modelToWorld converts a local-space bbox-centre back to world coords
// using the hangar's actual rotation and origin.
// ------------------------------------------------------------------------
private _fnc_hangarBayCentre = {
    params ["_hangar"];
    private _bbox = boundingBoxReal _hangar;
    _bbox params ["_min", "_max"];
    private _localCentre = [
        ((_min select 0) + (_max select 0)) / 2,
        ((_min select 1) + (_max select 1)) / 2,
        0
    ];
    private _world = _hangar modelToWorld _localCentre;
    _world set [2, getTerrainHeightASL _world];
    _world
};

// ------------------------------------------------------------------------
// Hangar auto-orient.
//
// Casts 4 rays from the bay centre at the building's cardinal axes
// (baseDir, baseDir+90, baseDir+180, baseDir+270). Whichever model
// axis is along the long axis of the bay, the door is at one of
// those four cardinals - never at a diagonal, so testing diagonals
// would only produce off-axis aircraft orientations.
//
// The rays do NOT ignore the hangar; walls block them, the open
// door is a hole in the GEOM lod (animateSource phase 1 ran in the
// door-precondition check earlier in the tier), and the longest
// clear distance identifies the door direction.
//
// For both-ends-open tent hangars (Land_TentHangar_V1_F is the
// canonical case), two cardinals end up with similar clear
// distances because either opening leads to clear airfield. A
// road-bearing tiebreaker picks whichever opening faces the
// nearest taxiway / apron, biasing parked aircraft to face out
// toward the active surface where they'd naturally taxi from.
//
// Final fallback: the ALIVE_problematicHangarBuildings override
// list, applied when the raycast couldn't find any clear path
// (bay centre outside the bay, or GEOM lod missing).
// ------------------------------------------------------------------------
private _fnc_orientHangar = {
    params ["_hangar", "_bayCentre"];
    private _baseDir = direction _hangar;

    private _rayLen = 30;
    private _fnc_clearDist = {
        params ["_dir"];
        private _start = _bayCentre vectorAdd [0, 0, 1.5];
        private _end = _start vectorAdd [_rayLen * sin _dir, _rayLen * cos _dir, 0];
        private _hits = lineIntersectsSurfaces [_start, _end, objNull, objNull, true, 1, "GEOM", "NONE"];
        if (count _hits == 0) exitWith { _rayLen };
        (_hits select 0 select 0) distance _start
    };

    private _fnc_angDiff = {
        params ["_a", "_b"];
        abs (((_a - _b) + 540) mod 360 - 180)
    };

    // 4 cardinals at the building's local axes.
    private _angles = [_baseDir, _baseDir + 90, _baseDir + 180, _baseDir + 270];
    private _samples = [];
    private _bestClear = -1;
    {
        private _clear = [_x] call _fnc_clearDist;
        _samples pushBack [_x, _clear];
        if (_clear > _bestClear) then { _bestClear = _clear; };
    } forEach _angles;

    // Identify the tied set: cardinals whose clear distance is
    // within 5 m of the longest. For one-ended hangars there's
    // only one entry; for both-ends-open tent hangars there are
    // two; for fully-open pavilions there are up to four.
    private _tied = _samples select { (_x select 1) >= (_bestClear - 5) };

    private _result = -1;
    if (count _tied == 1) then {
        _result = (_tied select 0) select 0;
    };

    // Multiple cardinals tied - apron-facing tiebreaker via road
    // bearing. Pick the tied cardinal closest to the bearing from
    // bay centre to the nearest road object (taxiway / apron).
    if (_result < 0 && count _tied > 1) then {
        private _nearRoads = _bayCentre nearRoads 80;
        if (count _nearRoads > 0) then {
            private _nearestRoad = _nearRoads select 0;
            {
                if ((_bayCentre distance2D _x) < (_bayCentre distance2D _nearestRoad)) then {
                    _nearestRoad = _x;
                };
            } forEach _nearRoads;
            private _roadDir = _bayCentre getDir (position _nearestRoad);
            private _bestDiff = 360;
            {
                private _diff = [_roadDir, _x select 0] call _fnc_angDiff;
                if (_diff < _bestDiff) then {
                    _bestDiff = _diff;
                    _result = _x select 0;
                };
            } forEach _tied;
        };
    };

    // No road in range to break the tie - pick the first tied
    // cardinal deterministically.
    if (_result < 0 && count _tied > 0) then {
        _result = (_tied select 0) select 0;
    };

    // Last-resort override list fallback for total raycast failure.
    if (_bestClear < 5) then {
        if (!isNil "ALIVE_problematicHangarBuildings") then {
            if (typeOf _hangar in ALIVE_problematicHangarBuildings || str(position _hangar) in ALIVE_problematicHangarBuildings) then {
                _result = _baseDir + 180;
            };
        };
        if (_result < 0) then { _result = _baseDir };
    };

    _result
};

// ------------------------------------------------------------------------
// Runway / taxiway exclusion check for the apron tier.
// ------------------------------------------------------------------------
private _airfieldGeom = [_centerPos, _maxDistance max 500] call ALiVE_fnc_getAirfieldGeometry;
_airfieldGeom params ["_runwaySegments", "_taxiwaySegments"];

private _fnc_pointToSegmentDist2D = {
    params ["_p", "_a", "_b"];
    private _ax = _a select 0; private _ay = _a select 1;
    private _bx = _b select 0; private _by = _b select 1;
    private _px = _p select 0; private _py = _p select 1;
    private _dx = _bx - _ax; private _dy = _by - _ay;
    private _lenSq = _dx*_dx + _dy*_dy;
    if (_lenSq < 0.01) exitWith { sqrt ((_px-_ax)^2 + (_py-_ay)^2) };
    private _t = (((_px-_ax)*_dx) + ((_py-_ay)*_dy)) / _lenSq;
    _t = 0 max (_t min 1);
    private _qx = _ax + _t*_dx;
    private _qy = _ay + _t*_dy;
    sqrt ((_px-_qx)^2 + (_py-_qy)^2)
};

private _fnc_clearOfRunwayTaxiway = {
    params ["_pos"];
    private _taxiBuffer   = _hw + 8;   // half-width + AI taxi clearance
    private _runwayBuffer = _hw + 12;  // half-width + active runway clearance
    if (_taxiwaySegments findIf {
        _x params ["_segStart", "_segEnd", "_segHW"];
        ([_pos, _segStart, _segEnd] call _fnc_pointToSegmentDist2D) < (_segHW + _taxiBuffer)
    } >= 0) exitWith { false };
    if (_runwaySegments findIf {
        _x params ["_segStart", "_segEnd", "_segHW"];
        ([_pos, _segStart, _segEnd] call _fnc_pointToSegmentDist2D) < (_segHW + _runwayBuffer)
    } >= 0) exitWith { false };
    true
};

// ------------------------------------------------------------------------
// Cascade.
// ------------------------------------------------------------------------
private _found = [];
private _minSeparation = (_vehLen max _vehWid) + 6;

// Tier 1: helipad (helis + VTOLs, never UAVs - per design rule).
if (count _found == 0 && {_preference in ["auto", "helipad"]} && {_isHeli || _isVTOL} && !_isUAV) then {
    private _heliClasses = ["HeliH", "HelipadCircle_F", "HelipadSquare_F", "Land_HelipadEmpty_F", "Land_HelipadSquare_F", "Land_HelipadCircle_F"];
    private _candidates = nearestObjects [_centerPos, _heliClasses, _maxDistance];
    {
        if (count _found > 0) exitWith {};
        private _padPos = position _x;
        private _padDir = direction _x;
        if !([_padPos, _minSeparation] call _fnc_registryClear) then { continue };
        // Filter the helipad object itself (and any host building it
        // sits on, picked up via 2 m proximity) out of the obstacle
        // returns, so the helipad doesn't count as the obstacle that
        // blocks its own check.
        private _ignore = [_x] + (nearestObjects [_padPos, ["House", "Building"], 2]);
        if !([_padPos, _padDir, _ignore] call _fnc_footprintClear) then { continue };
        _found = [_padPos, _padDir];
    } forEach _candidates;
};

// Tier 2: hangar (manned planes only - helis and UAVs of any class
// must use helipads / aprons / field per design rule).
if (count _found == 0 && {_preference in ["auto", "hangar"]} && _isPlane && !_isUAV) then {
    if (!isNil "ALIVE_airBuildingTypes") then {
        private _candidates = nearestObjects [_centerPos, [], _maxDistance];
        // Filter to hangar-type buildings via substring match.
        // CBA_fnc_find takes [haystack, needle] - haystack is the
        // building's typeOf, needle is each entry from the building-
        // types list (e.g. "hangar", "tenthangar").
        private _hangars = _candidates select {
            private _t = toLower (typeOf _x);
            ALIVE_airBuildingTypes findIf { [_t, _x] call CBA_fnc_find != -1 } >= 0
        };
        {
            if (count _found > 0) exitWith {};
            private _hangar = _x;
            private _hPos = [_hangar] call _fnc_hangarBayCentre;

            // Bbox fit. BIS_fnc_boundingBoxDimensions returns
            // [width, length, height] in the building's local axes,
            // which don't necessarily map to the aircraft's local
            // axes - sort dimensions and compare longest-to-longest,
            // shortest-to-shortest so the orientation mismatch
            // doesn't produce false rejections.
            private _hangarSize = _hangar call BIS_fnc_boundingBoxDimensions;
            private _hLong  = (_hangarSize select 0) max (_hangarSize select 1);
            private _hShort = (_hangarSize select 0) min (_hangarSize select 1);
            private _vLong  = _vehLen max _vehWid;
            private _vShort = _vehLen min _vehWid;
            if (_hLong < _vLong) then { continue };
            if (_hShort < _vShort) then { continue };
            // Vertical clearance for rotor / tail.
            if ((count _hangarSize >= 3) && {(_hangarSize select 2) > 0 && (_hangarSize select 2) < _vehHt}) then { continue };

            // Door precondition.
            if !([_hangar] call _fnc_doorsOpenable) then { continue };

            // Auto-orient. Pass the bay centre we already computed
            // so the orient raycast starts from the same point the
            // aircraft will spawn at.
            private _hDir = [_hangar, _hPos] call _fnc_orientHangar;

            // Registry check only. The bbox-fit test above already
            // verified the aircraft physically fits the hangar
            // interior; the open-door test verified accessibility.
            // The obstacle-table footprint sweep can NOT be applied
            // at the hangar centre because the hangar itself is a
            // BUILDING-type terrain object - the check would always
            // return the hangar as a hit and reject every candidate.
            if !([_hPos, _minSeparation] call _fnc_registryClear) then { continue };

            _found = [_hPos, _hDir];
        } forEach _hangars;
    };
};

// Tier 3: apron (planes; helis as final fallback if no hangar fit).
if (count _found == 0 && {_preference in ["auto", "apron"]}) then {
    private _surfaceAllowed = ["GdtAsphalt", "GdtConcrete", "GdtRoad"];
    // Random-sample inside _maxDistance, reject anything outside paved
    // surface, anything inside runway/taxiway exclusion, anything that
    // fails footprint or registry checks.
    for "_i" from 1 to 300 do {
        if (count _found > 0) exitWith {};
        private _pos = _centerPos getPos [random _maxDistance, random 360];
        private _surface = surfaceType _pos;
        if ((_surface select [0, 1]) == "#") then { _surface = _surface select [1] };
        if !(_surface in _surfaceAllowed) then { continue };
        if !([_pos] call _fnc_clearOfRunwayTaxiway) then { continue };
        if !([_pos, _minSeparation] call _fnc_registryClear) then { continue };
        // Aircraft on apron: orient roughly toward the runway if we
        // know one, otherwise random. Aircraft will be repositioned
        // by AI taxi when it engages.
        private _dir = if (count _runwaySegments > 0) then {
            private _seg = _runwaySegments select 0;
            (_seg select 0) getDir (_seg select 1)
        } else {
            random 360
        };
        if !([_pos, _dir] call _fnc_footprintClear) then { continue };
        _found = [_pos, _dir];
    };
};

// Tier 4: field fallback. Same heuristic as the ground validator's
// stage 3 with relaxed surface set (helis can land on more surfaces
// than ground vehicles can drive on, but slope still matters).
if (count _found == 0 && {_preference in ["auto", "field"]}) then {
    private _surfaceAllowed = ["GdtAsphalt", "GdtConcrete", "GdtDirt", "GdtGrass", "GdtRoad", "GdtRubble", "GdtSoil"];
    for "_i" from 1 to 500 do {
        if (count _found > 0) exitWith {};
        private _pos = _centerPos getPos [random _maxDistance, random 360];
        private _surface = surfaceType _pos;
        if ((_surface select [0, 1]) == "#") then { _surface = _surface select [1] };
        if !(_surface in _surfaceAllowed) then { continue };
        // Slope / clear-around check.
        if ((_pos isFlatEmpty [-1, -1, 0.3, _hazardRadius, 0, false, objNull]) isEqualTo []) then { continue };
        // Runway / taxiway exclusion still applies in field tier - we
        // never want to drop an aircraft on an active path even by
        // random luck.
        if !([_pos] call _fnc_clearOfRunwayTaxiway) then { continue };
        if !([_pos, _minSeparation] call _fnc_registryClear) then { continue };
        private _dir = random 360;
        if !([_pos, _dir] call _fnc_footprintClear) then { continue };
        _found = [_pos, _dir];
    };
};

// Reserve the chosen position in the session registry.
if (count _found > 0) then {
    ALiVE_airSpawnRegistry pushBack [_found select 0, _vehicleClass, _now];
};

_found
