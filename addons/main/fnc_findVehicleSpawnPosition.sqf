#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(findVehicleSpawnPosition);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_findVehicleSpawnPosition
Description:
    Unified vehicle spawn-position validator. Replaces the per-spawn-site
    ad-hoc safety logic across sys_profile, mil_placement, civ_placement,
    and amb_civ_placement with a single canonical entry point.

    Cascade:
      1. CENTRE - if the supplied position is already clear (full
         obstacle table, bbox-aware footprint), use it as-is. Most
         callers pre-validate so this often wins.
      2. ROAD (preference road / auto) - 30 sorted nearest road segments,
         lateral side-of-road offset, footprint check on both sides of
         the centreline. Vehicle faces along the road. Full obstacle
         table including IED-clutter classes.
      3. FIELD (preference field / auto-fallback) - 500-iteration
         heuristic, footprint sampling at random points in the search
         radius. Surface-type whitelist (asphalt / concrete / dirt /
         grass; reject sand / mud).
      4. FAIL - returns []. Caller decides fallback.

    Side-of-road placement: vehicles spawn on the verge, not the lane.
    Lateral offset = (road half-width) + (vehicle half-width) + 0.5 m
    kerb gap. Both sides tried per segment; first clear side wins.

Parameters:
    _this select 0: STRING - vehicle classname for bbox sizing.
    _this select 1: ARRAY  - centre position [x, y, z] for the search.
    _this select 2: NUMBER - search radius (default 100 m).
    _this select 3: STRING - "road" / "field" / "auto" (default "auto").

Returns:
    ARRAY [_pos, _dir] on success, [] on failure.

Examples:
    (begin example)
    private _result = ["B_MRAP_01_F", [3500, 4500, 0], 100, "auto"]
        call ALiVE_fnc_findVehicleSpawnPosition;
    if (count _result == 0) exitWith {};
    _result params ["_safePos", "_safeDir"];
    private _veh = createVehicle ["B_MRAP_01_F", _safePos, [], 0, "CAN_COLLIDE"];
    _veh setDir _safeDir;
    (end)

See Also:
    ALiVE_fnc_getVehicleBoundingBox

Author:
    Jman
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params [
    ["_vehicleClass", "", [""]],
    ["_centerPos", [0,0,0], [[]], [2,3]],
    ["_maxDistance", 100, [0]],
    ["_preference", "auto", [""]]
];

if (_vehicleClass == "" || count _centerPos < 2) exitWith { [] };

// Vehicle dimensions (cached per class).
private _bbox = [_vehicleClass] call ALiVE_fnc_getVehicleBoundingBox;
_bbox params ["_vehLen", "_vehWid"];
private _hl = _vehLen / 2;
private _hw = _vehWid / 2;
private _sampleRadius = 0.4;
private _gap = 0.5;

// Static obstacle terrain types - the full list, not just BUSH/HIDE.
// Includes building outer walls, fences, signage, lighting, vegetation.
private _staticTerrainTypes = [
    "BUILDING", "BUNKER", "BUSH", "BUSSTOP", "CHAPEL", "CHURCH", "CROSS",
    "FENCE", "FOREST BORDER", "FOREST SQUARE", "FOREST TRIANGLE", "FOREST",
    "FORTRESS", "FOUNTAIN", "FUELSTATION", "HIDE", "HOSPITAL", "HOUSE",
    "LIGHTHOUSE", "POWER LINES", "POWERSOLAR", "POWERWAVE", "POWERWIND",
    "QUAY", "RAILWAY", "ROCK", "ROCKS", "RUIN", "SHIPWRECK", "SMALL TREE",
    "STACK", "TOURISM", "TRANSMITTER", "TREE", "VIEW-TOWER", "WALL",
    "WATERTOWER", "Wreck_Base"
];

// Class-based obstacles. Catches mod-spawned content that doesn't carry
// terrain-type tags + the mil_ied DEFAULT_CLUTTER set (vehicles must not
// spawn on roadside IED-hide objects). Keep classnames in sync with
// addons/mil_ied/fnc_IED.sqf:94 - update both lists together.
private _classObstacles = [
    "Wall", "House", "AllVehicles",
    "Land_JunkPile_F", "Land_GarbageContainer_closed_F",
    "Land_GarbageBags_F", "Land_Tyres_F", "Land_GarbagePallet_F",
    "Land_Basket_F", "Land_Sack_F", "Land_Sacks_goods_F",
    "Land_Sacks_heap_F", "Land_BarrelTrash_F"
];

// ------------------------------------------------------------------------
// Footprint clearance check. Tiles the rotated rectangle of the vehicle
// with samples spaced <= 2 m along each axis so the obstacle-detection
// radius (~1 m around each sample) covers the whole bbox without gaps.
// A 4 m x 2 m sedan ends up with 8 samples; a 12 m x 3 m fuel tanker
// gets 21 samples - the longer body needs more coverage along its
// flanks where a static 9-sample pattern would leave 6 m unsampled
// between the mid-side and the front/rear corner.
// ------------------------------------------------------------------------
private _fnc_footprintClear = {
    params ["_pos", "_dir"];

    private _samplesAlongLength = (ceil (_vehLen / 2)) max 2;
    private _samplesAlongWidth  = (ceil (_vehWid / 2)) max 2;
    private _samples = [];
    for "_i" from 0 to _samplesAlongLength do {
        private _localY = ((_i / _samplesAlongLength) - 0.5) * _vehLen;
        for "_j" from 0 to _samplesAlongWidth do {
            private _localX = ((_j / _samplesAlongWidth) - 0.5) * _vehWid;
            if (_localX == 0 && _localY == 0) then {
                _samples pushBack _pos;
            } else {
                private _dist = sqrt (_localX * _localX + _localY * _localY);
                private _bear = _dir + (_localX atan2 _localY);
                _samples pushBack (_pos getPos [_dist, _bear]);
            };
        };
    };

    if ({surfaceIsWater _x} count _samples > 0) exitWith { false };

    private _terrainHit = _samples findIf {
        !((nearestTerrainObjects [_x, _staticTerrainTypes, _sampleRadius + _gap, false, true]) isEqualTo [])
    };
    if (_terrainHit >= 0) exitWith { false };

    private _classHit = _samples findIf {
        !((nearestObjects [_x, _classObstacles, _sampleRadius + _gap]) isEqualTo [])
    };
    if (_classHit >= 0) exitWith { false };

    true
};

// ------------------------------------------------------------------------
// Cascade with explicit found-flag tracking.
// ------------------------------------------------------------------------
private _found = [];
private _centerDir = random 360;

// Stage 1: centre check.
if ([_centerPos, _centerDir] call _fnc_footprintClear) then {
    _found = [_centerPos, _centerDir];
};

// Stage 2: road search (preference road / auto).
if (count _found == 0 && {_preference in ["road", "auto"]}) then {
    private _closestRoad = [_centerPos] call ALIVE_fnc_getClosestRoad;
    if (!isNil "_closestRoad" && {_centerPos distance _closestRoad <= _maxDistance}) then {
        private _segments = [_closestRoad, _maxDistance, 30] call ALIVE_fnc_getSortedSeriesRoadPositions;
        {
            if (count _found > 0) exitWith {};
            private _segPos = _x;
            private _road = roadAt _segPos;
            // Skip bridge segments - vehicles spawning on a bridge with
            // any side offset fall off the edge.
            if (!isNil "_road" && {(getRoadInfo _road) select 8}) then { continue };

            // Compute road direction from the segment's adjacent connections.
            private _connected = if (!isNil "_road") then { roadsConnectedTo _road } else { [] };
            private _roadDir = if (count _connected > 0) then {
                _segPos getDir (getPos (_connected select 0))
            } else {
                random 360
            };

            // Lateral offset: half road width + half vehicle width + kerb gap.
            // 3 m road half-width is a sensible default; A3 roads vary 4-8 m
            // total. Could tighten via getRoadInfo select 0 but the segment-
            // direction inference is more reliable.
            private _lateralOffset = 3 + _hw + _gap;

            // Try both sides of the road; first clear side wins.
            {
                if (count _found > 0) exitWith {};
                _x params ["_tryPos", "_tryDir"];
                if ([_tryPos, _tryDir] call _fnc_footprintClear) then {
                    // Small jitter for visual variety.
                    _found = [_tryPos, _tryDir + (random 10 - 5)];
                };
            } forEach [
                [_segPos getPos [_lateralOffset, _roadDir + 90], _roadDir],
                [_segPos getPos [_lateralOffset, _roadDir - 90], _roadDir]
            ];
        } forEach _segments;
    };
};

// Stage 3: field heuristic (preference field / auto-fallback).
if (count _found == 0 && {_preference in ["field", "auto"]}) then {
    // Surface-type whitelist. Vehicles bog on sand / mud.
    private _surfaceAllowed = ["GdtAsphalt", "GdtConcrete", "GdtDirt", "GdtGrass", "GdtRoad", "GdtRubble", "GdtSoil"];

    for "_i" from 1 to 500 do {
        if (count _found > 0) exitWith {};

        private _pos = _centerPos getPos [random _maxDistance, random 360];
        private _dir = random 360;

        // Surface filter (cheap, runs first).
        private _surface = surfaceType _pos;
        if ((_surface select [0, 1]) == "#") then { _surface = _surface select [1] };
        if !(_surface in _surfaceAllowed) then { continue };

        // Gradient filter - skip steep slopes. The check radius is
        // the larger of half-length / half-width so it covers the
        // whole vehicle footprint.
        if ((_pos isFlatEmpty [-1, -1, 0.4, (_hl max _hw), 0, false, objNull]) isEqualTo []) then { continue };

        if ([_pos, _dir] call _fnc_footprintClear) then {
            _found = [_pos, _dir];
        };
    };
};

_found
