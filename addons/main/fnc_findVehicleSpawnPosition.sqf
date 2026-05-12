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
      2. ROAD (preference road / auto) - up to 20 sorted nearest road
         segments (nearRoads + distance-sort, no expanding-radius search
         and no recursive segment walk - both contained sleeps / bugs
         that hung scheduled-context callers). Lateral side-of-road
         offset, footprint check on both sides of the centreline.
         Vehicle faces along the road. Full obstacle table including
         IED-clutter classes.
      3. FIELD (preference field / auto-fallback) - 500-iteration
         heuristic, footprint sampling at random points in the search
         radius. Surface-type blocklist (reject sand / mud / seabed /
         beach / swamp; everything else accepted). Map-specific runway
         and concrete-pad surfaces pass the filter without being
         listed individually.
      4. FAIL - returns []. Caller decides fallback.

    Side-of-road placement: vehicles spawn on the verge, not the lane.
    Lateral offset = (road half-width) + (vehicle half-width) + 0.5 m
    kerb gap. Both sides tried per segment; first clear side wins.

Parameters:
    _this select 0: STRING - vehicle classname for bbox sizing.
    _this select 1: ARRAY  - centre position [x, y, z] for the search.
    _this select 2: NUMBER - search radius (default 100 m).
    _this select 3: STRING - "road" / "field" / "auto" (default "auto").
    _this select 4: NUMBER - preferred direction in degrees [0, 360].
                             Used at Stage 1 (centre) when the caller's
                             parking position is accepted. -1 (default)
                             = no preference, random direction at Stage 1.
                             Stages 2 (road) and 3 (field) override with
                             their own direction regardless.

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
    ["_preference", "auto", [""]],
    ["_preferredDir", -1, [0]]
];

if (_vehicleClass == "" || count _centerPos < 2) exitWith { [] };

// Normalise to a 3-element position. Callers pass 2-element [x, y] in
// some paths (e.g. amb_civ_population's stored agent position from
// getParkingPosition). The geometry sweep needs Z to compute sweep
// heights via (_pos select 2) + heightOffset, and missing Z propagates
// nil into AGLToASL -> lineIntersectsSurfaces and errors out with
// "0 elements provided, 3 expected".
if (count _centerPos < 3) then { _centerPos = _centerPos + [0] };

// Debug flag - enable in initServer.sqf or debug console:
//   ALiVE_vehicleSpawn_debug = true; publicVariable "ALiVE_vehicleSpawn_debug";
// Logs per-call summary + per-stage decisions to RPT. Off by default.
private _debug = !isNil "ALiVE_vehicleSpawn_debug" && {ALiVE_vehicleSpawn_debug};

// Vehicle dimensions (cached per class).
private _bbox = [_vehicleClass] call ALiVE_fnc_getVehicleBoundingBox;
_bbox params ["_vehLen", "_vehWid"];
private _hl = _vehLen / 2;
private _hw = _vehWid / 2;
private _sampleRadius = 0.4;
private _gap = 0.5;

if (_debug) then {
    diag_log format ["[ALiVE VehSpawn DEBUG] ENTER class=%1 pos=%2 radius=%3 pref=%4 bbox=[%5,%6]",
        _vehicleClass, _centerPos, _maxDistance, _preference, _vehLen, _vehWid];
};

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
// spawn on roadside IED-hide objects). Keep clutter classnames in sync
// with addons/mil_ied/fnc_IED.sqf:94 - update both lists together.
//
// Military fortification classes are listed explicitly because they
// don't share a common kindOf parent (HBarrier, Bagfence, Bagbunker
// etc. all descend straight from NonStrategic / Strategic). Without
// these entries, parked composition vehicles next to hesco walls
// passed the obstacle check and clipped the bbox into the barrier
// geometry. Reported in #850.
private _classObstacles = [
    "Wall", "House", "AllVehicles",
    "Land_JunkPile_F", "Land_GarbageContainer_closed_F",
    "Land_GarbageBags_F", "Land_Tyres_F", "Land_GarbagePallet_F",
    "Land_Basket_F", "Land_Sack_F", "Land_Sacks_goods_F",
    "Land_Sacks_heap_F", "Land_BarrelTrash_F",
    // Hesco-style barriers (vanilla Arma 3)
    "Land_HBarrier_1_F", "Land_HBarrier_3_F", "Land_HBarrier_5_F",
    "Land_HBarrier_Big_F", "Land_HBarrierWall4_F", "Land_HBarrierWall6_F",
    "Land_HBarrierWall_corner_F", "Land_HBarrierWall_corridor_F",
    "Land_HBarrierTower_F",
    // Sandbag walls / bunkers
    "Land_BagFence_Round_F", "Land_BagFence_Long_F",
    "Land_BagFence_Short_F", "Land_BagFence_End_F",
    "Land_BagFence_Corner_F",
    "Land_BagBunker_Small_F", "Land_BagBunker_Large_F",
    "Land_BagBunker_Tower_F",
    // Concrete jersey barriers
    "Land_CncBarrier_F", "Land_CncBarrierMedium_F",
    "Land_CncBarrierMedium4_F", "Land_CncShelter_F",
    "Land_CncWall1_F", "Land_CncWall4_F",
    // Razor wire / fortification fences
    "Land_Razorwire_F"
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
// Last-rejection reason for debug logging. Read by the cascade after each
// _fnc_footprintClear call when _debug is true. Stays nil on success.
private _lastRejectReason = "";

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

    if ({surfaceIsWater _x} count _samples > 0) exitWith { _lastRejectReason = "water"; false };

    private _terrainHit = _samples findIf {
        !((nearestTerrainObjects [_x, _staticTerrainTypes, _sampleRadius + _gap, false, true]) isEqualTo [])
    };
    if (_terrainHit >= 0) exitWith { _lastRejectReason = "terrain-blocker"; false };

    private _classHit = _samples findIf {
        !((nearestObjects [_x, _classObstacles, _sampleRadius + _gap]) isEqualTo [])
    };
    if (_classHit >= 0) exitWith {
        // Capture which class blocked - useful for diagnosing missing entries
        // in _classObstacles when bad spawns slip through.
        private _blockingClasses = (nearestObjects [_samples select _classHit, _classObstacles, _sampleRadius + _gap]) apply {typeOf _x};
        _lastRejectReason = format ["class-blocker:%1", _blockingClasses];
        false
    };

    // Geometry sweep across the bbox perimeter. nearestObjects /
    // nearestTerrainObjects return objects whose bounding-sphere centre
    // is within the radius - a long-thin wall whose centre is far from
    // any sample (e.g. a 30 m fence whose centre is 15 m from the end)
    // can slip past a 0.9 m radius check even when the wall geometry
    // passes right through the vehicle's footprint. Cast lines along
    // the bbox edges + diagonals to catch the geometry directly.
    //
    // Two heights: 0.3 m catches low obstacles (jersey concrete
    // barriers ~0.8 m tall, sandbag walls, hesco bases, low fences)
    // that a single 1 m sweep would pass over. 1.5 m catches walls,
    // tall fences, and most vehicle-height obstacles. 12 line tests
    // per candidate (6 edges x 2 heights), still well under the
    // perf budget for this stage.
    private _diag = sqrt (_hl * _hl + _hw * _hw);
    private _frBear = _dir + (_hw atan2 _hl);
    private _flBear = _dir - (_hw atan2 _hl);
    private _frPos = _pos getPos [_diag, _frBear];
    private _flPos = _pos getPos [_diag, _flBear];
    private _rrPos = _pos getPos [_diag, _frBear + 180];
    private _rlPos = _pos getPos [_diag, _flBear + 180];

    private _sweepHeights = [0.3, 1.5];
    private _heightBlocked = _sweepHeights findIf {
        private _heightOffset = _x;
        private _h = (_pos select 2) + _heightOffset;
        private _frASL = AGLToASL [_frPos select 0, _frPos select 1, _h];
        private _flASL = AGLToASL [_flPos select 0, _flPos select 1, _h];
        private _rrASL = AGLToASL [_rrPos select 0, _rrPos select 1, _h];
        private _rlASL = AGLToASL [_rlPos select 0, _rlPos select 1, _h];
        // 4 edges + 2 diagonals at this height
        private _edges = [
            ["front",     [_flASL, _frASL]],
            ["right",     [_frASL, _rrASL]],
            ["rear",      [_rrASL, _rlASL]],
            ["left",      [_rlASL, _flASL]],
            ["diagonal1", [_frASL, _rlASL]],
            ["diagonal2", [_flASL, _rrASL]]
        ];
        private _hitEdge = _edges findIf {
            _x params ["_label", "_pair"];
            _pair params ["_a", "_b"];
            !((lineIntersectsSurfaces [_a, _b, objNull, objNull, true, 1, "GEOM", "NONE"]) isEqualTo [])
        };
        if (_hitEdge >= 0) then {
            private _label = (_edges select _hitEdge) select 0;
            _lastRejectReason = format ["geometry-sweep:height=%1m,edge=%2", _heightOffset, _label];
            true
        } else {
            false
        }
    };
    if (_heightBlocked >= 0) exitWith { false };

    true
};

// ------------------------------------------------------------------------
// Cascade with explicit found-flag tracking.
// ------------------------------------------------------------------------
private _found = [];
// Stage 1 direction: prefer caller's intent (parking direction from
// getParkingPosition / road-alignment from createRoadblock / etc.). Only
// generate a random direction when the caller had no preference - that
// path is for "find any clear spot" calls where direction doesn't matter.
// Without this, ambient parked vehicles validated at their own parking
// position were getting random rotations and ended up angled across the
// road instead of parallel to it.
private _centerDir = if (_preferredDir >= 0) then { _preferredDir } else { random 360 };
private _acceptedStage = "";

// Stage 1: centre check.
if ([_centerPos, _centerDir] call _fnc_footprintClear) then {
    _found = [_centerPos, _centerDir];
    _acceptedStage = "centre";
    if (_debug) then { diag_log format ["[ALiVE VehSpawn DEBUG]   STAGE 1 centre - ACCEPT pos=%1", _centerPos]; };
} else {
    if (_debug) then { diag_log format ["[ALiVE VehSpawn DEBUG]   STAGE 1 centre - REJECT reason=%1", _lastRejectReason]; };
};

// Stage 2: road search (preference road / auto).
//
// Two-step inline search:
//   (a) `nearRoads _maxDistance` for the seed segments closest to the
//       caller's centre.
//   (b) walk roadsConnectedTo from each seed up to a hop budget so the
//       segment list extends ALONG the road network (curving off into
//       the distance), not just clusters of seeds near centre. Vehicles
//       parked further down the same road still feel "at the cluster".
//
// Replaces ALiVE_fnc_getClosestRoad (internal sleep 0.02 in expanding-
// radius while loop, fires from scheduled context like mil_placement
// INIT and snowballs to seconds per call) and
// ALiVE_fnc_getSortedSeriesRoadPositions (buggy recursion shadowing
// shared state, can iterate erratically). Both originals were designed
// for human-paced lookups, not loop-driven validation.
if (count _found == 0 && {_preference in ["road", "auto"]}) then {
    // Seed pool: roads physically near the centre.
    private _seedRoads = _centerPos nearRoads _maxDistance;

    // Extend along the road graph. Walk connections from each seed up
    // to a shared hop budget. Bounded so we stop at roughly the same
    // segment count as the legacy walker (30) but never spin.
    private _walked = +_seedRoads;
    private _walkBudget = 30 - (count _walked);
    if (_walkBudget < 0) then { _walkBudget = 0 };
    private _frontier = +_seedRoads;
    while {_walkBudget > 0 && {count _frontier > 0}} do {
        private _next = [];
        {
            if (_walkBudget <= 0) exitWith {};
            {
                if !(_x in _walked) then {
                    _walked pushBack _x;
                    _next pushBack _x;
                    _walkBudget = _walkBudget - 1;
                    if (_walkBudget <= 0) then { break };
                };
            } forEach (roadsConnectedTo _x);
        } forEach _frontier;
        _frontier = _next;
    };

    if (count _walked == 0) then {
        if (_debug) then { diag_log format ["[ALiVE VehSpawn DEBUG]   STAGE 2 road - SKIP (no road within %1m)", _maxDistance]; };
    } else {
        // Sort by distance to centre so closest segments are tried first.
        private _sortedRoads = [_walked, [], { _centerPos distance (getPos _x) }, "ASCEND"] call ALiVE_fnc_sortBy;

        private _segmentsTried = 0;
        private _sidesTried = 0;
        private _sidesRejected = 0;
        {
            if (count _found > 0) exitWith {};
            private _road = _x;
            private _segPos = getPos _road;
            // Skip bridge segments - vehicles spawning on a bridge with
            // any side offset fall off the edge.
            if ((getRoadInfo _road) select 8) then { continue };

            _segmentsTried = _segmentsTried + 1;

            // Compute road direction from the segment's adjacent connections.
            private _connected = roadsConnectedTo _road;
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
                _sidesTried = _sidesTried + 1;
                if ([_tryPos, _tryDir] call _fnc_footprintClear) then {
                    // Small jitter for visual variety.
                    _found = [_tryPos, _tryDir + (random 10 - 5)];
                    _acceptedStage = "road";
                    if (_debug) then { diag_log format ["[ALiVE VehSpawn DEBUG]   STAGE 2 road - ACCEPT segment=%1 pos=%2", _segmentsTried, _tryPos]; };
                } else {
                    _sidesRejected = _sidesRejected + 1;
                };
            } forEach [
                [_segPos getPos [_lateralOffset, _roadDir + 90], _roadDir],
                [_segPos getPos [_lateralOffset, _roadDir - 90], _roadDir]
            ];
        } forEach _sortedRoads;

        if (_debug && {count _found == 0}) then {
            diag_log format ["[ALiVE VehSpawn DEBUG]   STAGE 2 road - REJECT (segments=%1, sides=%2, all blocked) lastReason=%3",
                _segmentsTried, _sidesTried, _lastRejectReason];
        };
    };
};

// Stage 3: field heuristic (preference field / auto-fallback).
if (count _found == 0 && {_preference in ["field", "auto"]}) then {
    // Surface-type BLOCKLIST. Vehicles bog on sand / mud / seabed; reject
    // those plus a couple of less common bog-prone variants. Anything else
    // (concrete, grass, asphalt, dirt, plus map-specific runway / paving /
    // terminal surfaces like Stratis's GdtStratisConcrete) passes the
    // surface filter and progresses to the gradient + footprint checks.
    //
    // Substring match (case-insensitive) catches map-specific variants
    // without listing every map's bespoke surface name. surfaceIsWater
    // is checked separately inside _fnc_footprintClear and stays as an
    // independent guard.
    private _surfaceBlocked = ["beach", "sand", "mud", "seabed", "swamp"];

    private _candidatesTried = 0;
    private _surfaceRejects = 0;
    private _gradientRejects = 0;
    private _footprintRejects = 0;
    for "_i" from 1 to 500 do {
        if (count _found > 0) exitWith {};

        private _pos = _centerPos getPos [random _maxDistance, random 360];
        private _dir = random 360;
        _candidatesTried = _candidatesTried + 1;

        // Surface filter (cheap, runs first). Block bog-prone surfaces.
        private _surface = surfaceType _pos;
        if ((_surface select [0, 1]) == "#") then { _surface = _surface select [1] };
        private _surfaceLower = toLower _surface;
        if ({_surfaceLower find _x >= 0} count _surfaceBlocked > 0) then { _surfaceRejects = _surfaceRejects + 1; continue };

        // Gradient filter - skip steep slopes. The check radius is
        // the larger of half-length / half-width so it covers the
        // whole vehicle footprint.
        if ((_pos isFlatEmpty [-1, -1, 0.4, (_hl max _hw), 0, false, objNull]) isEqualTo []) then {
            _gradientRejects = _gradientRejects + 1;
            continue
        };

        if ([_pos, _dir] call _fnc_footprintClear) then {
            _found = [_pos, _dir];
            _acceptedStage = "field";
            if (_debug) then { diag_log format ["[ALiVE VehSpawn DEBUG]   STAGE 3 field - ACCEPT iteration=%1 pos=%2", _candidatesTried, _pos]; };
        } else {
            _footprintRejects = _footprintRejects + 1;
        };
    };

    if (_debug && {count _found == 0}) then {
        diag_log format ["[ALiVE VehSpawn DEBUG]   STAGE 3 field - REJECT (tried=%1 surfaceRejects=%2 gradientRejects=%3 footprintRejects=%4) lastReason=%5",
            _candidatesTried, _surfaceRejects, _gradientRejects, _footprintRejects, _lastRejectReason];
    };
};

if (_debug) then {
    if (count _found > 0) then {
        diag_log format ["[ALiVE VehSpawn DEBUG] EXIT class=%1 result=ACCEPT stage=%2 pos=%3 dir=%4",
            _vehicleClass, _acceptedStage, _found select 0, _found select 1];
    } else {
        diag_log format ["[ALiVE VehSpawn DEBUG] EXIT class=%1 result=FAIL (caller falls back to %2)",
            _vehicleClass, _centerPos];
    };
};

_found
