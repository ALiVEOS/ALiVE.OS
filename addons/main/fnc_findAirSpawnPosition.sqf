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
// How much room a parked aircraft gets beyond its own extent, in metres.
// Named so it can be tuned from init.sqf without a rebuild. Raising it makes
// aircraft sit further from structures at the cost of finding fewer spots on a
// cramped field; the tier simply returns nothing when it cannot oblige.
if (isNil "ALiVE_airSpawn_clearanceMargin") then { ALiVE_airSpawn_clearanceMargin = 8 };

private _hazardRadius = if (_isHeli) then {
    (_vehLen max _vehWid) * 0.55
} else {
    (_vehLen max _vehWid) * 0.5 + 0.5
};

// Paved-surface allowlist + linear-strip discriminator, hoisted to function
// scope so BOTH the apron tier and the field tier can consult it.
//
// A taxiway or runway is a NARROW paved band; an apron is a BROAD paved area. On
// Stratis the apron, taxiway and runway are all one terrain surface
// (GdtStratisConcrete), so a surface allowlist cannot tell them apart, and the
// object/capsule model _fnc_clearOfRunwayTaxiway relies on has coverage gaps a
// wide airframe lands in (14 sparse taxiway capsules over a 1.3 km field). Ask
// the ground directly instead: probe the paved surface at the aircraft's own
// footprint half-extent along four opposing axes; if the centre is paved but
// some axis runs off the pavement at BOTH ends, the pavement is a band narrower
// than the airframe is wide on that axis - a taxiway/runway strip - so reject
// it. A broad apron, or an apron edge/corner (only the outward side runs off,
// the inward end of each through-axis stays paved), is accepted. It never
// consults the capsule cache, so a gap cannot defeat it, and it scales with the
// aircraft (a wide transport demands wide pavement, a small fighter is content
// with a narrower hardstand) at a cost of at most eight surfaceType reads.
private _pavedSurfaces = ["asphalt", "concrete", "road", "runway", "pave", "tarmac"];
private _fnc_pavedAt = {
    params ["_p"];
    private _s = toLower (surfaceType _p);
    if ((_s select [0, 1]) == "#") then { _s = _s select [1] };
    _pavedSurfaces findIf {_s find _x > -1} >= 0
};
private _fnc_onNarrowStrip = {
    params ["_pos"];
    // Self-guard: only a paved CENTRE can be a strip, so this is inert on the
    // field tier's open-ground (non-paved) samples and can never misfire there.
    if (!([_pos] call _fnc_pavedAt)) exitWith { false };
    private _probe = _hazardRadius;
    ([0, 45, 90, 135] findIf {
        private _a = _x;
        !([_pos getPos [_probe, _a]]        call _fnc_pavedAt) &&
        {!([_pos getPos [_probe, _a + 180]] call _fnc_pavedAt)}
    }) >= 0
};

// A "wide" airframe is a large VTOL / transport whose wing or rotor span fits no
// helipad and no hangar, so the cascade drops it to the apron and field tiers.
// On Stratis those tiers park it wrong: apron, taxiway and runway share one
// concrete paint so the paved-surface allowlist cannot tell an apron from a
// taxiway, and the taxiway capsules have coverage gaps a wide span lands in, so a
// 29 m Blackfish ends up with a wingtip over a live taxiway or its belly on a
// road. Helis are excluded (they take real pads at tier 1, and a pad-less heli
// must not be pushed to a distant field, b0675164); a normal fighter (~17 m span)
// stays below the threshold and keeps the apron. Dimension-based, so it is
// independent of VTOL config inheritance - a re-classed airframe (DAO_Gunship_B)
// that no longer isKindOf a VTOL base is still caught on its ~29 m span alone.
// Tunable from init.sqf without a rebuild.
if (isNil "ALiVE_airSpawn_wideAirframeSpan") then { ALiVE_airSpawn_wideAirframeSpan = 24 };
private _wideAirframe = _isPlane && {(_vehLen max _vehWid) >= ALiVE_airSpawn_wideAirframeSpan};

// Whole-footprint OFF-PAVEMENT + OFF-ROAD test for a wide airframe. The capsule
// taxiway model has coverage gaps, and the surface allowlist cannot separate an
// apron from a taxiway where they share one paint, so neither can keep a wing off
// a movement surface. The ground itself can: a movement surface is paved, open
// dispersal is not, and a road answers isOnRoad. Sample the footprint - centre, a
// 12-point perimeter ring at the hazard radius (~15 m for the Blackfish, i.e. the
// wingtip arc; the 30-degree spacing is a ~7.6 m chord, finer than any Stratis
// taxiway is wide, so a wing overhang cannot slip between probes) and a 6-point
// mid ring - and reject if ANY sample is paved OR on a road. What survives stands
// wholly on open, non-paved, non-road ground and by construction cannot overhang
// a concrete taxiway/runway nor sit on a road. Surface-based, so a capsule gap
// cannot defeat it. Reuses _fnc_pavedAt and _hazardRadius, both in scope here.
private _fnc_footprintOffPavement = {
    params ["_pos"];
    private _pts = [_pos];
    { _pts pushBack (_pos getPos [_hazardRadius, _x]) } forEach [0,30,60,90,120,150,180,210,240,270,300,330];
    { _pts pushBack (_pos getPos [_hazardRadius * 0.6, _x]) } forEach [0,60,120,180,240,300];
    (_pts findIf { isOnRoad _x || {[_x] call _fnc_pavedAt} }) < 0
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

    // Sweep the WHOLE footprint, not nine dots on its edge.
    //
    // This used to test a one metre circle around each of the nine samples
    // above, which for a transport with a forty metre span meant nine small
    // dots on a twenty metre ring and enormous unchecked gaps between them. A
    // hangar or an office block sitting in one of those gaps was missed
    // entirely, the aircraft spawned inside it, and the pair detonated. That
    // destroyed the air commander's own headquarters on one run and took the
    // whole air component offline with it.
    //
    // One query at the hazard radius covers the area the aircraft actually
    // occupies. It is also cheaper than nine, and it fails safe: if nothing
    // clear can be found the tier simply returns nothing and the caller falls
    // back, which is the correct outcome for "there is no room here".
    // Clearance, not merely non-overlap. The hazard radius is the aircraft's own
    // extent, so testing at exactly that distance accepts a wingtip a hand's
    // breadth from a hangar wall: legal, but it looks wrong and leaves nothing
    // for the settling the engine does on spawn. Add a margin so parked aircraft
    // sit with visible room around them.
    private _clearRadius = _hazardRadius + ALiVE_airSpawn_clearanceMargin;

    private _terrainHits = (nearestTerrainObjects [_pos, _staticTerrainTypes, _clearRadius, false, true]) - _ignore;
    if !(_terrainHits isEqualTo []) exitWith { false };

    private _classHits = (nearestObjects [_pos, _classObstacles, _clearRadius]) - _ignore;
    if !(_classHits isEqualTo []) exitWith { false };

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

    // Two-stage orient:
    //
    //   Stage 1 -- raycast 4 cardinals from bay centre, identify
    //   which AXIS (pair of cardinals 180 deg apart) is the
    //   "long" axis by comparing average clear distance. The long
    //   axis runs through the hangar's open end(s); the short
    //   axis runs perpendicular into the side walls.
    //
    //   Stage 2 -- between the 2 cardinals along the long axis,
    //   pick whichever is closest to the bearing from bay centre
    //   to the nearest road / taxiway / apron object within 80 m.
    //   For one-ended hangars the road is on the apron side -> picks
    //   the opening end. For two-ended tent hangars (Land_TentHangar_V1_F
    //   on Stratis) both ends are openings; road bearing picks
    //   whichever end faces the active taxiway.
    //
    // Earlier approaches that failed:
    //   - "Longest single cardinal" -- broke on SS hangars in tight
    //     rows where the opening direction was blocked by an
    //     adjacent hangar at 21 m and the back wall at 24 m won.
    //   - "Doesn't hit own GEOM" -- A2 hangar GEOM lods returned
    //     hits on the hangar in all 4 directions for middle hangars.
    //   - "Road bearing only" -- regressed Stratis tents because
    //     the road is perpendicular to the long axis, not along it.
    //
    // This hybrid uses raycasts for AXIS detection (robust against
    // adjacent-building contamination because both long-axis ends
    // get equal contamination, both still beat the side cardinals
    // which hit walls at ~5-15 m) and road bearing for END
    // selection (robust against ambiguous tied distances because
    // the road is an unambiguous external signal).
    private _baseDir = direction _hangar;
    private _rayLen = 60;

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

    // Sample all 4 cardinals.
    private _c0 = _baseDir;
    private _c1 = _baseDir + 90;
    private _c2 = _baseDir + 180;
    private _c3 = _baseDir + 270;
    private _d0 = [_c0] call _fnc_clearDist;
    private _d1 = [_c1] call _fnc_clearDist;
    private _d2 = [_c2] call _fnc_clearDist;
    private _d3 = [_c3] call _fnc_clearDist;

    // Identify long axis. Pair A = (baseDir, baseDir+180); pair B =
    // (baseDir+90, baseDir+270). Whichever pair has the higher
    // average clear distance is the long axis.
    private _avgA = (_d0 + _d2) / 2;
    private _avgB = (_d1 + _d3) / 2;
    private _longCardinals = if (_avgA >= _avgB) then {
        [[_c0, _d0], [_c2, _d2]]
    } else {
        [[_c1, _d1], [_c3, _d3]]
    };

    // End selection logic:
    //   - If both long-axis cardinals have similar clear distance
    //     (within 15 m -- e.g. two-ended tent hangars where both
    //     openings are unblocked, or hangars where the GEOM is
    //     ambiguous), use road bearing as tiebreaker.
    //   - Otherwise, the cardinal with the greater clear distance
    //     is the more sensible opening (unobstructed vs partially
    //     blocked). The 15 m tied tolerance is wide enough that the
    //     SS-hangar-in-tight-row case (23.9 vs 21.3, diff 2.6 m)
    //     falls into the "use road bearing" branch -- both ends are
    //     blocked by neighbours, road bearing picks the apron side.
    //   - For one-ended hangars with a clearly unblocked opening
    //     (e.g. ServiceHangars where one end is 60 m clear and the
    //     other is 15 m), the larger clear distance wins outright
    //     and road bearing is not consulted.
    private _d0Long = (_longCardinals select 0) select 1;
    private _d1Long = (_longCardinals select 1) select 1;
    private _clearDelta = abs (_d0Long - _d1Long);
    private _useRoadTiebreaker = _clearDelta < 15;

    // Default = longer-clear long-axis cardinal when we're in the
    // "clear delta is significant" branch (delta >= 15 m).
    // Otherwise default to baseDir + 180, the historical convention
    // for A2-era hangars where one-ended models open opposite their
    // setDir. Road tiebreaker (below) overrides if a road is found.
    private _result = if (!_useRoadTiebreaker) then {
        if (_d0Long >= _d1Long) then {
            (_longCardinals select 0) select 0
        } else {
            (_longCardinals select 1) select 0
        }
    } else {
        // Tied long axis: prefer the cardinal closest to
        // baseDir+180 (the A2 convention). Falls through to road
        // tiebreaker below if a road exists.
        private _convDir = _baseDir + 180;
        private _convDiff0 = [_convDir, (_longCardinals select 0) select 0] call _fnc_angDiff;
        private _convDiff1 = [_convDir, (_longCardinals select 1) select 0] call _fnc_angDiff;
        if (_convDiff0 <= _convDiff1) then {
            (_longCardinals select 0) select 0
        } else {
            (_longCardinals select 1) select 0
        }
    };

    // Wider road search than the usual 80 m -- airfields often have
    // RoadBase objects only along the perimeter / access road, not
    // along the taxiway itself (the taxiway is a terrain-surface
    // runway, not a road object). 200 m catches perimeter roads
    // and access tracks for typical airfields.
    private _nearRoads = _bayCentre nearRoads 200;
    private _roadDir = -1;
    if (_useRoadTiebreaker && {count _nearRoads > 0}) then {
        private _nearestRoad = _nearRoads select 0;
        {
            if ((_bayCentre distance2D _x) < (_bayCentre distance2D _nearestRoad)) then {
                _nearestRoad = _x;
            };
        } forEach _nearRoads;
        _roadDir = _bayCentre getDir (position _nearestRoad);

        private _diff0 = [_roadDir, (_longCardinals select 0) select 0] call _fnc_angDiff;
        private _diff1 = [_roadDir, (_longCardinals select 1) select 0] call _fnc_angDiff;
        _result = if (_diff0 <= _diff1) then {
            (_longCardinals select 0) select 0
        } else {
            (_longCardinals select 1) select 0
        };
    };

    // DIAG-STRIP orient result. Strip per
    // strategy_diag_strip_cleanup_pass.md.
    if (!isNil "ALiVE_airSpawn_debug" && {ALiVE_airSpawn_debug}) then {
        [
            "DIAG-STRIP orientHangar result: type=%1, model=%2, baseDir=%3, samples=[[%4,%5],[%6,%7],[%8,%9],[%10,%11]], longAxis=[%12,%13], clearDelta=%14, useRoad=%15, roadDir=%16, chosenDir=%17 (delta=%18)",
            typeOf _hangar,
            toLower(getText(configFile >> "CfgVehicles" >> (typeOf _hangar) >> "model")),
            _baseDir,
            _c0, _d0, _c1, _d1, _c2, _d2, _c3, _d3,
            _d0Long, _d1Long,
            _clearDelta,
            _useRoadTiebreaker,
            _roadDir,
            _result,
            ((_result - _baseDir) + 540) mod 360 - 180
        ] call ALiVE_fnc_dump;
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

// A public road passes every other test here: it is paved, dead flat, and kept
// clear of obstacles by design, which is precisely the profile the apron and
// field tiers go looking for. Aircraft parked across one block traffic and look
// wrong, so the road network has to be asked directly.
//
// Surface type cannot settle it. The apron tier accepts "road" as a paved
// surface, and to the flatness check a road is indistinguishable from an ideal
// parking spot.
//
// Airfield parking is exempt. Some terrains build aprons and hardstanding out of
// road pieces, and refusing those outright would empty the apron tier on exactly
// the maps where it earns its keep. Kind 3 is parking: somewhere aircraft are
// meant to sit rather than a thoroughfare.
private _fnc_clearOfRoad = {
    params ["_pos"];

    // Test the footprint, not only the centre. A wingtip overhanging the
    // carriageway is still parked on the road.
    private _onRoad = isOnRoad _pos
        || {[0, 90, 180, 270] findIf {isOnRoad (_pos getPos [_hazardRadius, _x])} > -1};
    if (!_onRoad) exitWith { true };

    !isNil "ALiVE_fnc_isAirside"
        && {!(ALiVE_airsideBounds isEqualTo [])}
        && {[_pos, 0, [3]] call ALiVE_fnc_isAirside}
};

private _fnc_clearOfRunwayTaxiway = {
    params ["_pos"];
    private _taxiBuffer   = _hw + 8;   // half-width + AI taxi clearance
    private _runwayBuffer = _hw + 12;  // half-width + active runway clearance

    // Ask the airfield model first, where one has been built.
    //
    // The segment lists below come from scanning for runway and taxiway OBJECTS,
    // and on a terrain whose runway is painted into the ground texture rather than
    // built from objects there is almost nothing to find. Stratis is exactly that
    // case: the segments are a few sparse fragments, the gaps between them are wide
    // open, and aircraft were being parked on the runway edge through one of them.
    //
    // The mission start airfield pass fits a proper centreline from whatever
    // evidence the terrain does offer and stores it with a sensible width, plus the
    // approach strips off each end. Runway and taxiway only: parking areas are
    // where aircraft are supposed to sit, so kind 3 is deliberately not consulted.
    // One condition, one exitWith, at the function's own level. Nesting the
    // exitWith inside a then-block would exit only that block and the function
    // would carry on and return true, silently ignoring the answer.
    if (!isNil "ALiVE_fnc_isAirside"
        && {!(ALiVE_airsideBounds isEqualTo [])}
        && {[_pos, _hw + 8, [1,2]] call ALiVE_fnc_isAirside}) exitWith { false };

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
        // Own-pad fast-path: this validator is also re-run when a heli that is ALREADY
        // parked on a pad is tasked (the spawn re-validates its position). If a candidate
        // pad is essentially where the airframe already sits, it is THIS aircraft's pad -
        // accept it outright, ahead of the registry and footprint rejections, so a sibling
        // heli reserved-on or parked-near an adjacent pad cannot evict this airframe from
        // the pad it already owns and dump it onto open ground (the pad then sitting empty).
        // GATED on a live Air vehicle actually at the point: only a genuine re-validation of a
        // parked airframe qualifies. A fresh placement request (mil_placement placeHelis passes
        // the pad itself as the target; sys_profile respawn) has no live airframe there yet, so
        // it must fall through to the registry + footprint + occupied-pad checks rather than
        // bypassing them (else a heli could be placed on a pad already holding a vehicle).
        if (_padPos distance2D _centerPos < 3 && {(nearestObjects [_centerPos, ["Air"], 5]) isNotEqualTo []}) exitWith { _found = [_padPos, _padDir]; };
        if !([_padPos, _minSeparation] call _fnc_registryClear) then { continue };
        // Filter the helipad object itself (and any host building it
        // sits on, picked up via 2 m proximity) out of the obstacle
        // returns, so the helipad doesn't count as the obstacle that
        // blocks its own check.
        // A helipad is a deliberate landing spot: whoever placed it accepted the
        // structures around it, and pads are very often tucked against a tower or a
        // hangar and ringed by camp set-dressing (HESCO, sandbags, sack piles). So
        // ignore static structures across the whole footprint, and also ignore the
        // class-table clutter (junk props, non-terrain-tagged barriers) - but that
        // clutter only out in the clearance MARGIN, beyond the aircraft's own hazard
        // radius, where nothing the aircraft physically occupies can reach it. Clutter
        // standing inside the rotor/fuselage disc still rejects the pad, and vehicles
        // (AllVehicles) are never ignored at any distance, so a pad with something
        // parked on it - or an obstacle actually in the rotor's way - is still refused.
        // Completes cb3776ae, which widened the sweep to the whole disc and excused
        // House/Building + terrain-tagged clutter to match, but left the class-query
        // clutter (runtime-spawned camp props) with no ignore term, so deliberate pads
        // were rejected and helis dropped onto open dirt beside the camp.
        private _ignore = [_x]
            + (nearestObjects [_padPos, ["House", "Building"], (_hazardRadius + ALiVE_airSpawn_clearanceMargin)])
            + (nearestTerrainObjects [_padPos, _staticTerrainTypes, (_hazardRadius + ALiVE_airSpawn_clearanceMargin), false, true])
            + ((nearestObjects [_padPos, (_classObstacles - ["AllVehicles"]), (_hazardRadius + ALiVE_airSpawn_clearanceMargin)]) select { (_padPos distance2D _x) > _hazardRadius });
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

// Tier 2.5: wide-airframe open dispersal (large plane / VTOL).
//
// A wide VTOL (Blackfish-class, ~29 m span) fits no helipad and no hangar, so it
// falls to the apron and field tiers where Stratis's uniform concrete paint and
// gap-riddled taxiway capsules park it half over a movement surface or on a road
// (RPT-proven: a wing over a taxiway from a grass dispersal, a belly on a dirt
// road, a straddle of the concrete taxiway). Ask the ground under the WHOLE
// footprint instead: an airframe standing entirely on open, non-paved, non-road
// ground cannot overhang a concrete taxiway/runway nor sit on a road, whatever
// the capsule coverage.
//
// GRACEFUL: a PREFERENCE pass, not a hard gate. It searches the SAME _maxDistance
// the apron/field tiers use (no radius relaxation - a distant field was
// explicitly rejected), so any spot it finds is in taxi range of the field. If no
// fully-off-pavement open spot exists nearby it finds nothing, count stays 0, and
// the tiers below run unchanged as the fallback. Scoped to wide PLANES only, so
// every heli taking a real pad at tier 1 and every normal plane on the apron are
// untouched.
if (count _found == 0 && _wideAirframe && {_preference in ["auto", "apron", "field"]}) then {
    private _openDir = if (count _runwaySegments > 0) then {
        private _seg = _runwaySegments select 0;
        (_seg select 0) getDir (_seg select 1)
    } else {
        random 360
    };
    for "_i" from 1 to 500 do {
        if (count _found > 0) exitWith {};
        private _pos = _centerPos getPos [random _maxDistance, random 360];
        // Whole footprint off pavement and off road - the decisive test.
        if !([_pos] call _fnc_footprintOffPavement) then { continue };
        // Slope / clear-around, identical to the field tier so behaviour matches.
        if ((_pos isFlatEmpty [-1, -1, 0.3, _hazardRadius, 0, false, objNull]) isEqualTo []) then { continue };
        // Belt-and-suspenders: object/capsule taxiway model too (a terrain whose
        // taxiway is built from objects on non-paved ground would pass the surface
        // test but not this), plus sibling deconfliction and the full
        // obstacle / water / building footprint sweep the other tiers apply.
        if !([_pos] call _fnc_clearOfRunwayTaxiway) then { continue };
        if !([_pos, _minSeparation] call _fnc_registryClear) then { continue };
        if !([_pos, _openDir] call _fnc_footprintClear) then { continue };
        _found = [_pos, _openDir];
    };
};

// Tier 3: apron (planes; helis as final fallback if no hangar fit).
if (count _found == 0 && {_preference in ["auto", "apron"]}) then {
    // Parking pre-pass. buildAirsideCache infers where aircraft are meant to
    // SIT - authored ALiVE_parking tags, the far ends of taxi routes, and the
    // hangar and helipad discs - and stores them as kind-3 capsules. Unlike the
    // random paved sample below, these sit OFF the runway and taxiway movement
    // surfaces by construction, which is what a wide VTOL needs when every real
    // pad is taken: a hardstand near the field rather than a broad concrete
    // sample that _fnc_onNarrowStrip (weak on Stratis's uniform concrete) and
    // the capsule-gapped taxiway exclusion can both wave through onto a live
    // taxiway. Prefer a real parking disc; the random loop stays as the fallback
    // when every disc is blocked.
    //
    // Trust the kind-3 classification and skip the narrow-strip test here (a
    // parking disc is meant to be broad), but still run footprint, registry and
    // runway/taxiway checks so a mis-inferred or occupied disc self-rejects: a
    // helipad disc already holding an aircraft, a hangar-centre disc (a BUILDING
    // terrain hit), or a taxi tail that is really a runway hold point on a
    // kind-2 taxiway. The registry check deconflicts sibling VTOLs, one airframe
    // per parking spot.
    if (!isNil "ALiVE_airsideCapsules" && {!(ALiVE_airsideCapsules isEqualTo [])}) then {
        private _parkDir = if (count _runwaySegments > 0) then {
            private _seg = _runwaySegments select 0;
            (_seg select 0) getDir (_seg select 1)
        } else {
            random 360
        };
        {
            if (count _found > 0) exitWith {};
            private _caps = _x;
            private _capCount = (count _caps) / 8;
            for "_j" from 0 to (_capCount - 1) do {
                if (count _found > 0) exitWith {};
                private _c = _j * 8;
                if ((_caps select (_c + 7)) == 3) then {
                    private _pCentre = [_caps select _c, _caps select (_c + 1), 0];
                    if ((_pCentre distance2D _centerPos) <= _maxDistance) then {
                        private _r = _caps select (_c + 4);
                        private _cands = [_pCentre];
                        if (_r > (_hazardRadius + 4)) then {
                            private _ring = (_r - _hazardRadius) min (_r * 0.6);
                            { _cands pushBack (_pCentre getPos [_ring, _x]) } forEach [0, 60, 120, 180, 240, 300];
                        };
                        {
                            if (count _found > 0) exitWith {};
                            private _pos = _x;
                            if ([_pos] call _fnc_clearOfRoad && {[_pos] call _fnc_clearOfRunwayTaxiway} && {[_pos, _minSeparation] call _fnc_registryClear} && {[_pos, _parkDir] call _fnc_footprintClear}) then {
                                _found = [_pos, _parkDir];
                            };
                        } forEach _cands;
                    };
                };
            };
        } forEach ALiVE_airsideCapsules;
    };

    // Paved-surface match by SUBSTRING, case-insensitive. An exact-name list
    // does not survive contact with real terrains: Stratis Air Station's apron
    // reports GdtStratisConcrete, so an exact list rejected all 300 samples and
    // this tier silently returned nothing on the map it is most needed on.
    // The sibling ground validator hit the same wall and solved it this way, and
    // it names GdtStratisConcrete in its own comment.
    private _surfaceAllowed = ["asphalt", "concrete", "road", "runway", "pave", "tarmac"];
    // Random-sample inside _maxDistance, reject anything outside paved
    // surface, anything inside runway/taxiway exclusion, anything that
    // fails footprint or registry checks.
    for "_i" from 1 to 300 do {
        if (count _found > 0) exitWith {};
        private _pos = _centerPos getPos [random _maxDistance, random 360];
        private _surface = toLower (surfaceType _pos);
        if ((_surface select [0, 1]) == "#") then { _surface = _surface select [1] };
        if (_surfaceAllowed findIf {_surface find _x > -1} < 0) then { continue };
        // Reject a narrow taxiway/runway strip the capsule model missed (planes
        // only -- a heli lifts vertically and does not taxi a departure path, so
        // a heli on a strip does not stall take-offs, and gating here keeps a
        // pad-less heli off the distant-field fallback b0675164 fixed).
        if (_isPlane && {[_pos] call _fnc_onNarrowStrip}) then { continue };
        if !([_pos] call _fnc_clearOfRoad) then { continue };
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
    // Blocklist rather than allowlist here, for the same reason as the apron
    // tier above: an allowlist cannot know every terrain's bespoke surface
    // names. Reject what an aircraft genuinely should not sit on and let the
    // slope and footprint checks below do the real work.
    private _surfaceBlocked = ["beach", "sand", "mud", "seabed", "swamp", "water"];
    for "_i" from 1 to 500 do {
        if (count _found > 0) exitWith {};
        private _pos = _centerPos getPos [random _maxDistance, random 360];
        private _surface = toLower (surfaceType _pos);
        if ((_surface select [0, 1]) == "#") then { _surface = _surface select [1] };
        if (_surfaceBlocked findIf {_surface find _x > -1} > -1) then { continue };
        // A flat concrete taxiway/runway strip in a capsule gap passes this
        // blocklist and the isFlatEmpty test below; reject it here too, because
        // the apron tier's apron->field retry and the auto-cascade both feed the
        // field tier (planes only, same reasoning as the apron tier).
        if (_isPlane && {[_pos] call _fnc_onNarrowStrip}) then { continue };
        // Slope / clear-around check.
        if ((_pos isFlatEmpty [-1, -1, 0.3, _hazardRadius, 0, false, objNull]) isEqualTo []) then { continue };
        // Roads clear this tier's blocklist and its flatness test effortlessly,
        // being neither sand nor sloped nor cluttered, so they need refusing by
        // name here as well as on the apron.
        if !([_pos] call _fnc_clearOfRoad) then { continue };
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
