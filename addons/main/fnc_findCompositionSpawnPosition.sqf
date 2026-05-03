#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(findCompositionSpawnPosition);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_findCompositionSpawnPosition
Description:
    Unified composition spawn-position validator. Replaces the per-spawn-
    site `findFlatArea` cascade across mil_placement Random Camps + Create
    Field HQ, mil_placement_custom Spawn Composition, civ_placement
    Roadblocks, and supply / heli placement sites with a single canonical
    entry point.

    Cascade:
      1. CENTRE - if the supplied position is already clear (envelope-aware
         footprint, exclusion zones for the requested mode), use it as-is.
         Most callers pre-pick a cluster centre so this often wins.
      2. SAMPLE - random toss within radius (up to 200 attempts), each
         candidate validated against envelope clearance + exclusion zones.
      3. ROAD ALIGN (mode=="roadblock" only) - additionally require a road
         within envelope-half + 5 m and snap orientation to road heading.
      4. FAIL - returns []. Caller decides fallback.

    Exclusion modes (preset bundles):
      "field"     - field HQ / camps far from infrastructure. Excludes:
                    runways, taxiways, helipads, all roads, all
                    static buildings, walls, fences, water within
                    envelope. Slope <= 0.1.
      "military"  - same as field but tolerates being near roads (camp
                    at roadside is OK). Still excludes runways and
                    helipads. Default mode.
      "civilian"  - near civilian objectives. Allows close-to-roads,
                    urban-edge, but still excludes runways / helipads /
                    buildings inside footprint.
      "roadblock" - opposite of field: REQUIRES a road within
                    envelope-half + 5 m, snaps to road centreline,
                    excludes runways / helipads. Caller iterates with
                    different _centerPos values along the road if
                    multiple roadblocks needed (this fn places ONE).
      "fieldhq"   - alias of "field" (kept for caller-side clarity in
                    Create Field HQ wiring).

    Lessons translated from findVehicleSpawnPosition:
      - Envelope-aware footprint check (composition radius substituted
        for vehicle bbox).
      - getAirfieldGeometry for runway / taxiway segment exclusion -
        runway/taxiway camps were the visible pain point.
      - Static obstacle terrain blacklist + class-based fallback for
        mod content that doesn't carry terrain tags.
      - Surface-type filter (sand / sea / mud rejection).
      - Up-front debug flag + structured per-stage logging.

Parameters:
    _this select 0: ARRAY   - centre position [x, y, z]. Required.
    _this select 1: NUMBER  - search radius in metres. Default 200.
    _this select 2: NUMBER  - composition envelope radius in metres
                              (clear-circle requirement around the
                              picked position). Default 30.
                              Pass a larger value for big compositions
                              (Field HQ ~50m, large camps ~60m). Smaller
                              for outposts (~20m) and roadblocks (~15m).
    _this select 3: STRING  - exclusion mode (see above). Default
                              "military".
    _this select 4: NUMBER  - preferred direction in degrees [0, 360].
                              -1 (default) = random. Used at Stage 1 only;
                              roadblock mode overrides with road heading.

Returns:
    ARRAY [_pos, _dir] on success, [] on failure.

Examples:
    (begin example)
    // Random Camp - search around cluster centre, 30m envelope, military mode
    private _result = [_pos, 500, 30, "military"] call ALiVE_fnc_findCompositionSpawnPosition;
    if (count _result == 0) exitWith {};
    _result params ["_safePos", "_safeDir"];
    [_composition, _safePos, _safeDir, _faction] call ALiVE_fnc_spawnComposition;

    // Field HQ - bigger envelope, field-strict mode
    private _result = [_pos, 500, 50, "fieldhq"] call ALiVE_fnc_findCompositionSpawnPosition;

    // Roadblock - small envelope, roadblock mode (auto-aligns to road)
    private _result = [_pos, 200, 15, "roadblock"] call ALiVE_fnc_findCompositionSpawnPosition;
    (end)

See Also:
    ALiVE_fnc_findVehicleSpawnPosition
    ALiVE_fnc_findAirSpawnPosition
    ALiVE_fnc_getAirfieldGeometry

Author:
    Jman
---------------------------------------------------------------------------- */

params [
    ["_centerPos",  [0,0,0], [[]],   [2,3]],
    ["_radius",     200,     [0]],
    ["_envelope",   30,      [0]],
    ["_mode",       "military", [""]],
    ["_preferredDir", -1,    [0]]
];

if (count _centerPos < 2) exitWith { [] };
if (count _centerPos < 3) then { _centerPos = _centerPos + [0] };

_mode = toLower _mode;
if (_mode == "fieldhq") then { _mode = "field" };
if !(_mode in ["field", "military", "civilian", "roadblock"]) then {
    _mode = "military";
};

private _debug = !isNil "ALiVE_compSpawn_debug" && {ALiVE_compSpawn_debug};

if (_debug) then {
    diag_log format ["[ALiVE CompSpawn] ENTER pos=%1 radius=%2 envelope=%3 mode=%4", _centerPos, _radius, _envelope, _mode];
};

// ------------------------------------------------------------------------
// Mode flags - distilled boolean policy from the named mode.
// ------------------------------------------------------------------------
private _excludeRoads      = (_mode == "field");       // field-strict avoids ALL roads
private _excludeRunways    = true;                     // always exclude
private _excludeHelipads   = true;                     // always exclude
private _excludeBuildings  = true;                     // always exclude inside footprint
private _excludeWater      = true;                     // always exclude
private _requireRoad       = (_mode == "roadblock");   // roadblock REQUIRES road
private _maxAttempts       = if (_mode == "roadblock") then { 12 } else { 200 };

// ------------------------------------------------------------------------
// Airfield geometry - runway / taxiway segments to reject. Cached per
// call (callers usually feed the same _centerPos for one camp/HQ pick).
// ------------------------------------------------------------------------
private _airfield = [_centerPos, _radius + 200] call ALiVE_fnc_getAirfieldGeometry;
_airfield params ["_runwaySegments", "_taxiwaySegments"];

if (_debug && {count _runwaySegments + count _taxiwaySegments > 0}) then {
    diag_log format ["[ALiVE CompSpawn]   airfield: %1 runway seg, %2 taxiway seg", count _runwaySegments, count _taxiwaySegments];
};

// ------------------------------------------------------------------------
// Static obstacle terrain types + class fallbacks (subset of the vehicle
// validator's set, tuned for compositions which can tolerate proximity
// to some object kinds vehicles can't).
// ------------------------------------------------------------------------
private _staticTerrainTypes = [
    "BUILDING", "BUNKER", "CHAPEL", "CHURCH", "FENCE", "FOREST",
    "FORTRESS", "FUELSTATION", "HOSPITAL", "HOUSE", "LIGHTHOUSE",
    "POWER LINES", "QUAY", "RAILWAY", "RUIN", "SHIPWRECK", "STACK",
    "TRANSMITTER", "VIEW-TOWER", "WALL", "WATERTOWER"
];

// ------------------------------------------------------------------------
// Helper: position falls inside any runway / taxiway segment exclusion?
// Each segment is [startPos, endPos, halfWidth]. We compute perpendicular
// distance from candidate to the segment line and reject if <= halfWidth +
// envelope-half.
// ------------------------------------------------------------------------
private _onAirfieldSurface = {
    params ["_p", "_envHalf"];
    private _hit = false;
    {
        _x params ["_a", "_b", "_hw"];
        // Distance from point _p to line segment _a..b
        private _ax = _a select 0; private _ay = _a select 1;
        private _bx = _b select 0; private _by = _b select 1;
        private _px = _p select 0; private _py = _p select 1;
        private _segDx = _bx - _ax; private _segDy = _by - _ay;
        private _segLen2 = _segDx * _segDx + _segDy * _segDy;
        if (_segLen2 > 0.001) then {
            private _t = (((_px - _ax) * _segDx) + ((_py - _ay) * _segDy)) / _segLen2;
            _t = (_t max 0) min 1;
            private _cx = _ax + _t * _segDx;
            private _cy = _ay + _t * _segDy;
            private _dx = _px - _cx;
            private _dy = _py - _cy;
            private _dist = sqrt (_dx * _dx + _dy * _dy);
            if (_dist <= _hw + _envHalf) exitWith { _hit = true };
        };
    } forEach (_runwaySegments + _taxiwaySegments);
    _hit
};

// ------------------------------------------------------------------------
// Helper: candidate position passes all envelope clearance checks?
// ------------------------------------------------------------------------
private _candidateClear = {
    params ["_p", "_env"];
    private _envHalf = _env / 2;

    // 1. Runway / taxiway exclusion
    if (_excludeRunways && {[_p, _envHalf] call _onAirfieldSurface}) exitWith {
        if (_debug) then { diag_log format ["[ALiVE CompSpawn]   reject %1: airfield surface", _p] };
        false
    };

    // 2. Helipad exclusion (any HeliH within envelope)
    if (_excludeHelipads && {count (_p nearObjects ["HeliH", _envHalf + 10]) > 0}) exitWith {
        if (_debug) then { diag_log format ["[ALiVE CompSpawn]   reject %1: helipad nearby", _p] };
        false
    };

    // 3. Road exclusion (field mode only)
    if (_excludeRoads && {count (_p nearRoads (_envHalf + 5)) > 0}) exitWith {
        if (_debug) then { diag_log format ["[ALiVE CompSpawn]   reject %1: road nearby (field mode)", _p] };
        false
    };

    // 4. Building / wall / fence inside envelope - terrain-type sweep
    if (_excludeBuildings) then {
        private _terrainHits = nearestTerrainObjects [_p, _staticTerrainTypes, _envHalf, false, true];
        if (count _terrainHits > 0) exitWith {
            if (_debug) then { diag_log format ["[ALiVE CompSpawn]   reject %1: %2 static obstacles in envelope", _p, count _terrainHits] };
            false
        };
        // Also reject if a class-based building-derived object is inside
        // (catches mod content that doesn't carry terrain-type tags).
        private _objHits = nearestObjects [_p, ["House", "Building", "Wall", "Fence", "Static"], _envHalf];
        // Filter out tiny clutter (signs, posts) - we want REAL footprint
        // obstacles. Heuristic: bbox volume > 8 m^3.
        _objHits = _objHits select {
            private _bbox = boundingBoxReal _x;
            _bbox params ["_min", "_max"];
            private _w = (_max select 0) - (_min select 0);
            private _l = (_max select 1) - (_min select 1);
            private _h = (_max select 2) - (_min select 2);
            (_w * _l * _h) > 8
        };
        if (count _objHits > 0) exitWith {
            if (_debug) then { diag_log format ["[ALiVE CompSpawn]   reject %1: %2 class-based building obstacles in envelope", _p, count _objHits] };
            false
        };
    };

    // 5. Water exclusion - any water within envelope
    if (_excludeWater) then {
        if (surfaceIsWater _p) exitWith {
            if (_debug) then { diag_log format ["[ALiVE CompSpawn]   reject %1: water surface", _p] };
            false
        };
        // Sample envelope perimeter for shore intrusion
        private _waterEdge = false;
        for "_a" from 0 to 315 step 45 do {
            private _ep = _p getPos [_envHalf, _a];
            if (surfaceIsWater _ep) exitWith { _waterEdge = true };
        };
        if (_waterEdge) exitWith {
            if (_debug) then { diag_log format ["[ALiVE CompSpawn]   reject %1: water within envelope perimeter", _p] };
            false
        };
    };

    // 6. Slope check - sample envelope corners, reject if any pair
    // exceeds 5m elevation difference (~ 0.1 gradient over envelope).
    private _maxDelta = _env * 0.1;
    private _samples = [];
    {
        _samples pushBack ((_p getPos [_envHalf, _x]) select 2);
    } forEach [0, 90, 180, 270];
    private _hi = selectMax _samples;
    private _lo = selectMin _samples;
    if (_hi - _lo > _maxDelta) exitWith {
        if (_debug) then { diag_log format ["[ALiVE CompSpawn]   reject %1: slope %2m > %3m max", _p, _hi - _lo, _maxDelta] };
        false
    };

    // 7. Surface-type filter - reject sand / mud / seabed.
    private _surface = surfaceType _p;
    if (_surface in ["#GdtBeach", "#GdtMud", "#GdtSeabed", "#GdtStratisBeach", "#GdtStratisMud", "#GdtStratisSeabed"]) exitWith {
        if (_debug) then { diag_log format ["[ALiVE CompSpawn]   reject %1: surface %2", _p, _surface] };
        false
    };

    if (_debug) then { diag_log format ["[ALiVE CompSpawn]   accept %1", _p] };
    true
};

// ------------------------------------------------------------------------
// Roadblock mode: find nearest road, snap position to its centreline,
// orient along its heading. Used as the candidate position before
// running it through _candidateClear.
// ------------------------------------------------------------------------
private _findRoadCandidate = {
    params ["_p", "_searchRadius"];
    private _nearby = _p nearRoads _searchRadius;
    if (count _nearby == 0) exitWith { [] };
    // Sort by distance to centre - closest first
    _nearby = [_nearby, [], { _x distance _p }, "ASCEND"] call BIS_fnc_sortBy;
    private _picked = _nearby select 0;
    private _roadDir = direction _picked;
    private _roadPos = getPosATL _picked;
    [_roadPos, _roadDir]
};

// ------------------------------------------------------------------------
// Stage 1: try the centre position itself.
// ------------------------------------------------------------------------
if (_mode != "roadblock" && {[_centerPos, _envelope] call _candidateClear}) exitWith {
    private _dir = if (_preferredDir >= 0) then { _preferredDir } else { random 360 };
    if (_debug) then { diag_log format ["[ALiVE CompSpawn] EXIT centre dir=%1", _dir] };
    [_centerPos, _dir]
};

// Roadblock mode: handle separately (always road-snap).
if (_mode == "roadblock") exitWith {
    private _result = [_centerPos, _radius] call _findRoadCandidate;
    if (count _result == 0) exitWith {
        if (_debug) then { diag_log "[ALiVE CompSpawn] EXIT FAIL: no road in radius (roadblock mode)" };
        []
    };
    _result params ["_rPos", "_rDir"];
    if !([_rPos, _envelope] call _candidateClear) exitWith {
        if (_debug) then { diag_log format ["[ALiVE CompSpawn] EXIT FAIL: road candidate %1 fails clearance", _rPos] };
        []
    };
    if (_debug) then { diag_log format ["[ALiVE CompSpawn] EXIT roadblock pos=%1 dir=%2", _rPos, _rDir] };
    [_rPos, _rDir]
};

// ------------------------------------------------------------------------
// Stage 2: random sample within radius.
// ------------------------------------------------------------------------
private _result = [];
for "_i" from 1 to _maxAttempts do {
    private _angle = random 360;
    private _dist  = random _radius;
    private _candidate = _centerPos getPos [_dist, _angle];
    if ([_candidate, _envelope] call _candidateClear) exitWith {
        private _dir = if (_preferredDir >= 0) then { _preferredDir } else { random 360 };
        _result = [_candidate, _dir];
        if (_debug) then { diag_log format ["[ALiVE CompSpawn] EXIT sample[%1] pos=%2 dir=%3", _i, _candidate, _dir] };
    };
};

if (count _result == 0 && {_debug}) then {
    diag_log format ["[ALiVE CompSpawn] EXIT FAIL: %1 attempts exhausted", _maxAttempts];
};

_result
