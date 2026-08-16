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
    _this select 2: NUMBER  - composition envelope in metres, as returned
                              by ALiVE_fnc_getCompositionRadius. This is a
                              DIAMETER, not a radius - that function doubles
                              the furthest object distance and adds five.
                              The checks below halve it and add an overhang
                              allowance to get the distance the composition
                              actually reaches. Do not treat this value as a
                              clear-circle radius; doing so asks for roughly
                              twice the clearance needed and rejects almost
                              every position on wooded terrain. Default 30.
    _this select 3: STRING  - exclusion mode (see above). Default
                              "military".
    _this select 4: NUMBER  - preferred direction in degrees [0, 360].
                              -1 (default) = random. Used at Stage 1 only;
                              roadblock mode overrides with road heading.
    _this select 5: BOOL    - caller-side debug flag. OR'd with the global
                              `ALiVE_compSpawn_debug`. Lets a module pass
                              its own debug attribute through without
                              relying on init.sqf timing (which can fire
                              after module init in MP host). Default false.

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
    ["_preferredDir", -1,    [0]],
    ["_callerDebug", false, [false]],
    ["_runwayClearanceMul", 1.0, [0]]
];

// _runwayClearanceMul scales the runway/taxiway rejection radius. Default
// 1.0 = full envelope (strict "no composition object ever intersects a
// runway", correct for camps / FOBs / roadblocks). Tight airfields with
// large compositions (env > ~50m) can't satisfy the strict rule because
// the safe zone outside both runway and ocean is narrower than the
// envelope - in that case, the caller passes a smaller multiplier (e.g.
// mil_ato AA passes 0.6) to allow some outermost-object clipping risk
// in exchange for actually spawning the composition. Compositions whose
// purpose is to PROTECT the airfield (AA / SAM) are the natural use
// case for the relaxed mode.
if (_runwayClearanceMul <= 0) then { _runwayClearanceMul = 1.0 };

if (count _centerPos < 2) exitWith { [] };
if (count _centerPos < 3) then { _centerPos = _centerPos + [0] };

_mode = toLower _mode;
if (_mode == "fieldhq") then { _mode = "field" };
if !(_mode in ["field", "military", "civilian", "roadblock", "ato"]) then {
    _mode = "military";
};

// Verbose per-candidate trace is gated on the dedicated ALiVE_compSpawn_debug
// flag ONLY, not on the calling module's debug - a module with debug on was
// flooding the log with every rejected sample. Set ALiVE_compSpawn_debug at
// the console for the deep trace. The one-line placement result below prints
// regardless so successful placements are always visible.
private _debug = (!isNil "ALiVE_compSpawn_debug" && {ALiVE_compSpawn_debug});

if (_debug) then {
    ["[ALiVE CompSpawn] ENTER pos=%1 radius=%2 envelope=%3 mode=%4", _centerPos, _radius, _envelope, _mode] call ALiVE_fnc_dump;
};

// ------------------------------------------------------------------------
// Mode flags - distilled boolean policy from the named mode.
// ------------------------------------------------------------------------
private _excludeRoads      = (_mode == "field");       // field-strict avoids ALL roads
private _excludeRunways    = true;                     // always exclude
// "ato" mode skips the helipad check - AA / SAM compositions placed
// on an active airbase are EXPECTED to sit near helipads they defend.
// Treating helipad proximity as a rejection makes the validator
// over-reject in dense airfield environments (Stratis peninsula).
private _excludeHelipads   = (_mode != "ato");
// Roadblock + ato modes SKIP the envelope-wide building bbox check.
// Roadblock compositions sit on a road centreline by design; the road
// network already routes around buildings, and flanking buildings are
// part of the urban context the checkpoint is supposed to live in
// (towns, villages). Enforcing envelope-wide clearance rejects every
// realistic road point in built-up areas (RPT pattern: "N obstacle
// bbox(s) intersect envelope" with N=4..24 in town tests). Field /
// military / civilian modes keep the check - they spawn off-road and
// nearby buildings genuinely block their footprint.
// Roadblock mode skips for the road-network reason above. "ato" mode
// also skips - airbase-resident AA / SAM compositions are surrounded
// by airfield infrastructure (hangars, fences, lamps, taxiway markers)
// that the bbox volume check flags as obstacles, which would reject
// every candidate in dense airfield environments.
private _excludeBuildings  = !(_mode in ["roadblock", "ato"]);
private _excludeWater      = true;                     // always exclude
private _requireRoad       = (_mode == "roadblock");   // roadblock REQUIRES road
// Attempts scale with search radius. Original fixed 200 was right for
// 50-150m search areas but became extremely sparse coverage at 500m+.
// Linear scaling: 200 attempts at 150m baseline, doubles per 150m
// of additional radius. Capped at 1200 to bound init-time cost.
// Roadblock keeps its low fixed count - it's a road-network-constrained
// search, not an area sweep.
private _maxAttempts       = if (_mode == "roadblock") then { 12 } else {
    private _scaled = round (200 * (_radius / 150));
    (_scaled max 200) min 1200
};

// ------------------------------------------------------------------------
// Airfield geometry - runway / taxiway segments to reject. Cached per
// call (callers usually feed the same _centerPos for one camp/HQ pick).
// ------------------------------------------------------------------------
private _airfield = [_centerPos, _radius + 200] call ALiVE_fnc_getAirfieldGeometry;
_airfield params ["_runwaySegments", "_taxiwaySegments", ["_airfieldZones", []]];

// Airfield-area exclusion: reject candidates inside ANY of the
// nearestLocations "Airport" zones returned by getAirfieldGeometry's
// Tier 4. Skipped in ato mode where AA / SAM compositions are placed
// ON the airfield by design. The runway / taxiway segment check still
// runs - even in ato mode we don't want gun crews on the runway
// centerline.
private _excludeAirfieldArea = !(_mode in ["ato"]);

if (_debug && {count _runwaySegments + count _taxiwaySegments + count _airfieldZones > 0}) then {
    ["[ALiVE CompSpawn]   airfield: %1 runway seg, %2 taxiway seg, %3 airport zone(s)", count _runwaySegments, count _taxiwaySegments, count _airfieldZones] call ALiVE_fnc_dump;
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
    // Returns true when point _p is within `_clearance` metres of any
    // runway/taxiway segment edge. Caller passes the COMPOSITION'S full
    // envelope as the clearance so the segment-edge proximity check
    // accounts for objects extending all the way out from the anchor.
    params ["_p", "_clearance"];
    private _hit = false;
    // Build the segment list dynamically per call so the airfield-zone
    // tier can be skipped in ato mode (where AA / SAM placement on the
    // airfield is intentional). Runway + taxiway centerlines stay
    // excluded in all modes.
    private _segments = _runwaySegments + _taxiwaySegments;
    if (_excludeAirfieldArea) then { _segments = _segments + _airfieldZones };
    {
        _x params ["_a", "_b", "_hw"];
        // Distance from point _p to line segment _a..b
        private _ax = _a select 0; private _ay = _a select 1;
        private _bx = _b select 0; private _by = _b select 1;
        private _px = _p select 0; private _py = _p select 1;
        private _segDx = _bx - _ax; private _segDy = _by - _ay;
        private _segLen2 = _segDx * _segDx + _segDy * _segDy;
        // Point-segment (start==end) handling: Tier 3 substring matches
        // and Tier 4 airfield zones are degenerate. Without this fallback
        // they'd be silently skipped (segLen2 == 0 fails the >0.001 gate).
        private _cx = _ax;
        private _cy = _ay;
        if (_segLen2 > 0.001) then {
            private _t = (((_px - _ax) * _segDx) + ((_py - _ay) * _segDy)) / _segLen2;
            _t = (_t max 0) min 1;
            _cx = _ax + _t * _segDx;
            _cy = _ay + _t * _segDy;
        };
        private _dx = _px - _cx;
        private _dy = _py - _cy;
        private _dist = sqrt (_dx * _dx + _dy * _dy);
        if (_dist <= _hw + _clearance) exitWith { _hit = true };
    } forEach _segments;
    _hit
};

// ------------------------------------------------------------------------
// Helper: candidate position passes all envelope clearance checks?
// ------------------------------------------------------------------------
// DIAG-STRIP (camps): tally of which rule turned candidates away, counted
// rather than logged. When a search fails there is currently no way to tell
// whether every candidate was in water, on a road, or blocked by an object,
// and the per-candidate trace below cannot be left on to find out because it
// writes a line for every sample and a wide search takes over a thousand.
// One summary line at the end costs nothing and answers the question.
private _rejectCounts = [0,0,0,0,0,0,0,0,0,0,0,0];
private _rejectNames = ["bounds","runway","helipad","road","obstacle","water-centre","water-edge","slope-normal","slope-inner","slope-outer","surface","rock"];

// How far the composition's objects can actually reach from the anchor.
//
// The envelope handed in is a DIAMETER: getCompositionRadius doubles the
// furthest object distance and adds five. So the objects themselves only
// reach about half of it. The checks below used to treat the whole figure
// as a reach, which asked for roughly twice the clearance in every
// direction, four times the area. On a wooded map that is a clearing that
// does not exist, and every candidate was refused.
//
// Simply halving it would bring back the problem that caused the doubling
// in the first place: object positions are measured from their centres, so
// one sitting right on the edge still hangs past it, and camps were
// clipping runways. Half plus an allowance for that overhang is the honest
// figure. The allowance is a judgement, not a measurement: five metres for
// small compositions rising to ten for large ones.
//
// Worth knowing before changing it: at envelope 10 this comes to exactly
// 10, which is what the old code used, so the many callers that search in
// tight sweeps at that size behave identically to before. Only genuinely
// large compositions move.
//
// Kept in one place because the airfield containment test further down has to
// use the SAME reach as the per-candidate check. If the two ever disagreed, the
// test could rule out a search that would actually have found somewhere.
private _fnc_clearReach = {
    params ["_env"];
    private _envHalf = _env / 2;
    _envHalf + ((5 max (_envHalf * 0.5)) min 10)
};

private _candidateClear = {
    params ["_p", "_env"];
    private _envHalf = _env / 2;
    // Reach of the composition's objects from the anchor. Worked out by
    // _fnc_clearReach above, where the reasoning behind the figure is written
    // down, and shared with the airfield containment test so the two agree.
    private _clearReach = [_env] call _fnc_clearReach;

    // 0. World-bounds rejection. When the caller's centre is near the
    // map edge, getPos [random radius, random angle] can land outside
    // the playable area. surfaceIsWater / nearObjects / nearRoads all
    // return clear/empty off-map, so nothing else rejects these
    // candidates - compositions then spawn beyond the visible terrain.
    // worldSize bounds the playable square; any candidate with X or Y
    // outside [0, worldSize] is rejected first. (Issue #877: Random
    // camps spawning outside map bounds.)
    private _wsz = worldSize;
    if (
        ((_p select 0) < 0) || {(_p select 0) > _wsz} ||
        {(_p select 1) < 0} || {(_p select 1) > _wsz}
    ) exitWith {
        if (_debug) then { ["[ALiVE CompSpawn]   reject %1: outside world bounds (worldSize=%2)", _p, _wsz] call ALiVE_fnc_dump };
        _rejectCounts set [0, (_rejectCounts select 0) + 1];
        false
    };

    // External-feature exclusions (1-3 below) keep things like runways and
    // roads clear of the composition's outermost objects, so they measure
    // against `_clearReach` - how far those objects actually reach - rather
    // than the envelope, which is a diameter. See the note where _clearReach
    // is worked out for why the earlier full-envelope version rejected almost
    // everything. Internal samples (slope, water perimeter) keep using
    // _envHalf, because those test the inside of the footprint.
    //
    // 1. Runway / taxiway exclusion. Caller can scale the rejection
    // radius via `_runwayClearanceMul` - default 1.0 (strict);
    // mil_ato AA passes ~0.6 to allow placement on tight airfields where
    // the strict rule would skip the spawn entirely.
    if (_excludeRunways && {[_p, _clearReach * _runwayClearanceMul] call _onAirfieldSurface}) exitWith {
        if (_debug) then { ["[ALiVE CompSpawn]   reject %1: airfield surface (clearance=%2m, mul=%3)", _p, _clearReach * _runwayClearanceMul, _runwayClearanceMul] call ALiVE_fnc_dump };
        _rejectCounts set [1, (_rejectCounts select 1) + 1];
        false
    };

    // 2. Helipad exclusion (any HeliH within envelope)
    if (_excludeHelipads && {count (_p nearObjects ["HeliH", _clearReach + 10]) > 0}) exitWith {
        if (_debug) then { ["[ALiVE CompSpawn]   reject %1: helipad nearby", _p] call ALiVE_fnc_dump };
        _rejectCounts set [2, (_rejectCounts select 2) + 1];
        false
    };

    // 3. Road exclusion (field mode only)
    if (_excludeRoads && {count (_p nearRoads (_clearReach + 5)) > 0}) exitWith {
        if (_debug) then { ["[ALiVE CompSpawn]   reject %1: road nearby (field mode)", _p] call ALiVE_fnc_dump };
        _rejectCounts set [3, (_rejectCounts select 3) + 1];
        false
    };

    // 4. Solid obstacle inside envelope - bbox-aware on ALL nearby objects.
    //    Class-hierarchy matching (`nearestObjects` with type list) is
    //    unreliable for stock A3 buildings - Land_MilOffices_V1_F doesn't
    //    isKindOf "House" / "Building" / "Static" - and the terrain-type
    //    tag set doesn't reliably cover military structures either. Empty
    //    type filter mirrors the working pattern in
    //    ALiVE_fnc_findNearObjectsByType: get all objects, then filter by
    //    bbox volume (>30 m^3 keeps real blockers - buildings 100+ m^3,
    //    walls 30-200 m^3 - while letting small clutter through: signs,
    //    posts, lamps, ammo boxes, single fence segments 5-20 m^3,
    //    scrub 1-10 m^3). The original 8 m^3 threshold rejected so much
    //    clutter that obstacle-dense terrain like Stratis around Kamino
    //    couldn't fit any composition - 200-1000 attempts at 750m radius
    //    found zero clear positions despite visible open fields. Living
    //    things (Man) are excluded since they don't physically block
    //    spawn and get repositioned downstream anyway.
    //
    //    Note on flow: `exitWith` exits the IMMEDIATE enclosing scope, so
    //    `if (X) then { exitWith {false} }` only exits the then-block, not
    //    the function. We compute _buildingIntruders inside the then-block
    //    and check it at function-top-level so the exitWith-at-true-scope
    //    actually returns false from _candidateClear.
    private _buildingIntruders = [];
    // Roadblock mode normally skips this check (urban tolerance - see the
    // _excludeBuildings note above), but a road point sitting under a building
    // footprint spawns the checkpoint inside the building. So roadblock runs a
    // narrowed version: only actual buildings (House class), and only when their
    // footprint covers the composition core (a tight radius), so flanking
    // buildings lining the street are still tolerated.
    private _isRoadblock = (_mode == "roadblock");
    if (_excludeBuildings || _isRoadblock) then {
        // Same reasoning as the runway / helipad exclusions above: measure
        // against how far the composition's objects actually reach. The +15
        // padding on the search radius catches objects whose centres sit
        // outside that reach but whose bulk extends inside it.
        // Roadblock narrows the intrusion radius to the composition core but
        // searches a fixed 35m so large buildings whose footprint reaches the
        // road point are still caught.
        private _intrudeRadius       = if (_isRoadblock) then { 6 } else { _clearReach };
        private _buildingCheckRadius = if (_isRoadblock) then { 35 } else { (_clearReach + 15) max 25 };
        private _allHits = nearestObjects [_p, [], _buildingCheckRadius];

        // Trees and undergrowth do not block a composition, because the
        // spawner clears them: it hides the vegetation and scenery categories
        // across the footprint as it builds. Counting them as obstacles meant
        // refusing perfectly good ground on account of trees that were about
        // to be removed anyway, and on a jungle map that is nearly all ground.
        // Measured on Cam Lao Nam at a rejected site: of 280 objects within
        // range, every one cleared the size test below and 277 were vegetation.
        // Taking them out left three.
        //
        // The list is deliberately the same one the spawner hides, so the two
        // cannot drift apart: exempt exactly what will be cleared, nothing more.
        // Rocks are NOT exempted even though the spawner hides those too. That
        // asymmetry is on purpose. Hiding a boulder field reads far worse than
        // hiding trees, and AI pathing was found reaching into rock the spawner
        // had removed, so rocks keep rejecting the position outright further
        // down rather than being quietly deleted.
        private _vegExempt = nearestTerrainObjects [_p, ["TREE","SMALL TREE","BUSH","FOREST BORDER","FOREST SQUARE","FOREST TRIANGLE","FOREST"], _buildingCheckRadius, false];
        if (count _vegExempt > 0) then { _allHits = _allHits - _vegExempt };

        _buildingIntruders = _allHits select {
            // Avoid exitWith inside a select-predicate code block - in some
            // SQF versions exitWith aborts the entire select (returns Bool
            // instead of the filtered Array, causing `count` downstream to
            // throw "Type Bool, expected Array"). Use if-then-else instead.
            if (_x isKindOf "Man") then { false } else {
                private _bbox = boundingBoxReal _x;
                _bbox params ["_bMin", "_bMax"];
                private _w = (_bMax select 0) - (_bMin select 0);
                private _l = (_bMax select 1) - (_bMin select 1);
                private _h = (_bMax select 2) - (_bMin select 2);
                // Non-roadblock: any solid object over 30 m3. Roadblock: only
                // actual buildings (House), so street walls / fences / clutter
                // don't reject an otherwise-good urban checkpoint.
                private _qualifies = if (_isRoadblock) then { _x isKindOf "House" } else { (_w * _l * _h) > 30 };
                _qualifies && {
                    private _pLocal = _x worldToModel _p;
                    private _cx = ((_pLocal select 0) max (_bMin select 0)) min (_bMax select 0);
                    private _cy = ((_pLocal select 1) max (_bMin select 1)) min (_bMax select 1);
                    private _dx = (_pLocal select 0) - _cx;
                    private _dy = (_pLocal select 1) - _cy;
                    sqrt ((_dx * _dx) + (_dy * _dy)) < _intrudeRadius
                }
            }
        };
    };
    if (count _buildingIntruders > 0) exitWith {
        if (_debug) then { ["[ALiVE CompSpawn]   reject %1: %2 obstacle bbox(s) intersect envelope: first=%3", _p, count _buildingIntruders, typeOf (_buildingIntruders select 0)] call ALiVE_fnc_dump };
        _rejectCounts set [4, (_rejectCounts select 4) + 1];
        false
    };

    // 5. Water exclusion - any water within envelope.
    //    Same flow note as check 4: the inner exitWiths only abort the
    //    then-block, so we capture rejection state in a flag and exitWith
    //    at function-top-level.
    private _waterCentre = false;
    private _waterEdge   = false;
    if (_excludeWater) then {
        if (surfaceIsWater _p) then { _waterCentre = true };
        if (!_waterCentre) then {
            for "_a" from 0 to 315 step 45 do {
                private _ep = _p getPos [_envHalf, _a];
                if (surfaceIsWater _ep) exitWith { _waterEdge = true };
            };
        };
    };
    if (_waterCentre) exitWith {
        if (_debug) then { ["[ALiVE CompSpawn]   reject %1: water surface", _p] call ALiVE_fnc_dump };
        _rejectCounts set [5, (_rejectCounts select 5) + 1];
        false
    };
    if (_waterEdge) exitWith {
        if (_debug) then { ["[ALiVE CompSpawn]   reject %1: water within envelope perimeter", _p] call ALiVE_fnc_dump };
        _rejectCounts set [6, (_rejectCounts select 6) + 1];
        false
    };

    // 6. Slope check - per-mode strictness via three tests:
    //    (a) surfaceNormal Z component at centre - direct engine-measured
    //        ground tilt (1.0 = perfectly flat, 0.985 ~= 10 deg, 0.97 ~= 14 deg)
    //    (b) Inner elevation-delta - 8 samples at envelope perimeter + centre,
    //        catches slopes / steps within the composition's own footprint.
    //    (c) Outer elevation-delta - 4 samples at extended radius + centre,
    //        catches surrounding hillsides / cliffs that crowd the camp from
    //        beyond its footprint. Extended radius is `(envHalf * 3) max 25m`
    //        so small compositions still reach into the surrounding terrain.
    //    Field mode (Random Camps + Field HQ) is strictest. Civilian /
    //    roadblock get more lenient thresholds since they typically need
    //    to sit near roads / urban infrastructure where sub-degree slopes
    //    are unavoidable.
    private _slopeRules = switch (_mode) do {
        case "field":     {[0.07, 0.970]};   // ~4.0 deg delta + ~14 deg normal-Z
        case "military":  {[0.10, 0.950]};   // ~5.7 deg delta + ~18 deg
        case "civilian":  {[0.12, 0.930]};   // ~6.8 deg delta + ~22 deg
        case "roadblock": {[0.10, 0.950]};   // tightened from [0.12, 0.930]: a tilted checkpoint reads as broken even on a graded road
        default           {[0.10, 0.950]};
    };
    _slopeRules params ["_deltaRatio", "_normalZMin"];

    private _normal = surfaceNormal _p;
    private _normalZ = _normal select 2;
    if (_normalZ < _normalZMin) exitWith {
        if (_debug) then { ["[ALiVE CompSpawn]   reject %1: surfaceNormal Z %2 < %3 (mode %4)", _p, _normalZ, _normalZMin, _mode] call ALiVE_fnc_dump };
        _rejectCounts set [7, (_rejectCounts select 7) + 1];
        false
    };

    // Two complementary slope-delta checks with independent budgets:
    //
    //   Inner: 8 samples at envelope perimeter + centre, budget = _env * _deltaRatio.
    //          Catches slopes / steps within the composition's own footprint.
    //
    //   Outer: 4 samples at an extended radius + centre, budget scaled to the
    //          extended radius's wider span. Catches surrounding hillsides /
    //          cliffs that crowd the spawn from beyond its own footprint.
    //          Extended radius is `(envHalf * 1.5) max 25m` - the floor
    //          ensures small compositions still reach into surrounding
    //          terrain (a 15m comp's natural envHalf is only 7.5m), while
    //          the modest multiplier prevents large FieldHQ-scale envelopes
    //          from sampling so far out that natural rolling terrain trips
    //          the rejection (180m+ samples on Stratis catch gentle hillsides
    //          unrelated to the actual spawn footprint).
    // Inner slope sampling. Default is envHalf (catches slope across the
    // composition's footprint half-radius). Roadblock mode widens this to
    // the full envelope - composition objects extend up to that reach
    // into the verge / shoulder, and a checkpoint half-on a 5m embankment
    // looks broken even when the road centre itself is graded. Budget
    // scales with sampling diameter so the slope-ratio policy stays
    // consistent (same percent grade allowed regardless of width).
    private _innerRadius = if (_mode == "roadblock") then { _env } else { _envHalf };
    private _maxDelta = (_innerRadius * 2) * _deltaRatio;
    private _outerRadius = (_envHalf * 1.5) max 25;
    private _neighbourhoodMaxDelta = (_outerRadius * 2) * _deltaRatio;

    private _innerSamples = [_p select 2];
    { _innerSamples pushBack ((_p getPos [_innerRadius, _x]) select 2); } forEach [0, 45, 90, 135, 180, 225, 270, 315];
    private _innerHi = selectMax _innerSamples;
    private _innerLo = selectMin _innerSamples;
    if (_innerHi - _innerLo > _maxDelta) exitWith {
        if (_debug) then { ["[ALiVE CompSpawn]   reject %1: composition slope-delta %2m > %3m max at %4m radius (mode %5)", _p, _innerHi - _innerLo, _maxDelta, _innerRadius, _mode] call ALiVE_fnc_dump };
        _rejectCounts set [8, (_rejectCounts select 8) + 1];
        false
    };

    private _outerSamples = [_p select 2];
    { _outerSamples pushBack ((_p getPos [_outerRadius, _x]) select 2); } forEach [0, 90, 180, 270];
    private _outerHi = selectMax _outerSamples;
    private _outerLo = selectMin _outerSamples;
    if (_outerHi - _outerLo > _neighbourhoodMaxDelta) exitWith {
        if (_debug) then { ["[ALiVE CompSpawn]   reject %1: neighbourhood slope-delta %2m > %3m max at %4m radius (mode %5)", _p, _outerHi - _outerLo, _neighbourhoodMaxDelta, _outerRadius, _mode] call ALiVE_fnc_dump };
        _rejectCounts set [9, (_rejectCounts select 9) + 1];
        false
    };

    // 7. Surface-type filter - reject sand / mud / seabed.
    private _surface = surfaceType _p;
    if (_surface in ["#GdtBeach", "#GdtMud", "#GdtSeabed", "#GdtStratisBeach", "#GdtStratisMud", "#GdtStratisSeabed"]) exitWith {
        if (_debug) then { ["[ALiVE CompSpawn]   reject %1: surface %2", _p, _surface] call ALiVE_fnc_dump };
        _rejectCounts set [10, (_rejectCounts select 10) + 1];
        false
    };

    // 8. Rock terrain objects intruding the footprint. The solid-obstacle check
    //    (4) misses rocks (terrain objects, small bbox to its volume filter) and a
    //    rock on flat ground doesn't trip the slope check (6) either - so AI
    //    compositions sat in the rocks (#913). The first fix here used a flat
    //    _envHalf proximity radius, but a large boulder whose ORIGIN sits just
    //    outside _envHalf still reaches its body into the footprint and clips the
    //    composition. Test each nearby rock's real footprint (boundingBoxReal
    //    half-extent + 1.5m margin) against the composition envelope - the same
    //    technique already proven for infantry anchor placement in
    //    sys_profile/fnc_profileGetGoodSpawnPosition.sqf. Search radius is
    //    deliberately _envHalf+25 (tighter than that sibling's fixed 80m) to bound
    //    cost while still reaching any rock whose body can intrude the footprint.
    private _nearRocks = nearestTerrainObjects [_p, ["ROCK", "ROCKS"], _envHalf + 25, false];
    private _rockBlocked = _nearRocks findIf {
        private _bb = boundingBoxReal _x;
        private _p0 = _bb select 0;
        private _p1 = _bb select 1;
        private _reach = (((abs (_p0 select 0)) max (abs (_p1 select 0))) max ((abs (_p0 select 1)) max (abs (_p1 select 1)))) + 1.5;
        (_p distance2D _x) < (_reach + _envHalf)
    };
    if (_rockBlocked >= 0) exitWith {
        if (_debug) then { ["[ALiVE CompSpawn]   reject %1: rock footprint intrudes (rock %2)", _p, typeOf (_nearRocks select _rockBlocked)] call ALiVE_fnc_dump };
        _rejectCounts set [11, (_rejectCounts select 11) + 1];
        false
    };

    if (_debug) then { ["[ALiVE CompSpawn]   accept %1", _p] call ALiVE_fnc_dump };
    true
};

// ------------------------------------------------------------------------
// Roadblock mode: find nearest road, snap position to its centreline,
// orient along its heading. Used as the candidate position before
// running it through _candidateClear.
//
// `direction _roadPiece` returns 0 for A3 road segments (they're terrain
// features, not vehicles, and don't carry a meaningful direction). The
// correct tangent is the angle from this road point to its nearest
// connected neighbour, which `roadsConnectedTo` exposes. Falls back to
// `direction` only when the road is a true dead-end with no neighbours.
// ------------------------------------------------------------------------
private _findRoadCandidates = {
    params ["_p", "_searchRadius"];
    private _nearby = _p nearRoads _searchRadius;
    if (count _nearby == 0) exitWith { [] };
    // Sort by distance to centre - closest first
    _nearby = [_nearby, [], { _x distance _p }, "ASCEND"] call BIS_fnc_sortBy;
    // Return the nearest few pieces, each as [centreline pos, road tangent].
    // The anchor search walks them in order so a bad nearest piece (rock /
    // slope) falls through to the next instead of abandoning the road point.
    (_nearby select [0, 3]) apply {
        private _roadConnectedTo = roadsConnectedTo _x;
        private _roadDir = if (count _roadConnectedTo > 0) then {
            _x getDir (_roadConnectedTo select 0)
        } else {
            direction _x
        };
        [getPosATL _x, _roadDir]
    }
};

// ------------------------------------------------------------------------
// Give up before starting when the whole search area is inside an airfield.
//
// The airfield zones are circles, and so is the search area, so "can any candidate
// here pass?" is answerable by comparing two circles rather than by sampling a
// thousand points and watching every one of them fail. When the search circle sits
// wholly inside a zone, no position within it can ever clear, and the loop below
// cannot discover anything except that.
//
// This is not a theoretical saving. One cluster on a Cam Lao Nam dedicated run
// spent 667 tries at 500m with every single candidate turned away by the airfield
// check, to reach a conclusion available from one comparison per zone.
//
// It does NOT save the wider retry that follows. Growing the circle can push it
// back out of containment, and on that same cluster it did: the 800m pass logged
// five candidates getting past the airfield check, so that disc was not contained
// and the loop below had to run. Only the first pass is saved here.
//
// Only segments with no length are considered, which is a CONSERVATIVE restriction
// rather than a complete one. A real segment's exclusion is a capsule and a capsule
// can contain a disc, so a containment that exists is sometimes missed. Nothing is
// ever wrongly claimed, which is the property that matters, and the survey records
// its runways and taxiways from terrain objects as single points anyway, so most of
// them are caught by the same test.
// ------------------------------------------------------------------------
// _swallowed is declared out here, and the give-up below sits at the top level of
// the file rather than inside the test. `exitWith` leaves the NEAREST enclosing
// block, so an exit written inside the `then` below would only leave the `then`,
// discard its own return value and fall straight through to the search it was
// meant to prevent. The same rule is relied on deliberately elsewhere in this file.
private _swallowed = false;
if (_mode != "roadblock" && _excludeRunways) then {
    private _reach = ([_envelope] call _fnc_clearReach) * _runwayClearanceMul;
    // The same list the per-candidate check walks, and assembled on the same terms:
    // runways and taxiways always, the wider airfield areas only in the modes that
    // exclude them. Anything this list would reject everywhere is worth knowing now.
    private _testable = _runwaySegments + _taxiwaySegments;
    if (_excludeAirfieldArea) then { _testable = _testable + _airfieldZones };
    {
        _x params ["_zStart", "_zEnd", ["_zHalfWidth", 0]];
        // Length of zero, so the per-candidate rule measures to the point itself and
        // the exclusion really is a circle that can be compared with the search area.
        if ((_zStart distance2D _zEnd) < 0.1
            && {((_centerPos distance2D _zStart) + _radius) <= (_zHalfWidth + _reach)}) exitWith {
            _swallowed = true;
        };
    } forEach _testable;
};

if (_swallowed) exitWith {
    // Reported on the same terms as the failure it replaces, so a search that gives
    // up here is as visible in the log as one that ground through the whole loop to
    // arrive at the same answer.
    if (_radius >= 50 || _callerDebug || _debug) then {
        ["[ALiVE CompSpawn] FAIL centre=%1 mode=%2 radius=%3m envelope=%4m before trying - the whole search area is inside an airfield zone, no position in it could pass",
            _centerPos, _mode, _radius, _envelope] call ALiVE_fnc_dump;
    };
    []
};

// ------------------------------------------------------------------------
// Stage 1: try the centre position itself.
// ------------------------------------------------------------------------
if (_mode != "roadblock" && {[_centerPos, _envelope] call _candidateClear}) exitWith {
    private _dir = if (_preferredDir >= 0) then { _preferredDir } else { random 360 };
    if (_debug) then { ["[ALiVE CompSpawn] placed (mode %1) at %2", _mode, _centerPos] call ALiVE_fnc_dump };
    [_centerPos, _dir]
};

// Roadblock mode: handle separately (always road-snap).
if (_mode == "roadblock") exitWith {
    private _candidates = [_centerPos, _radius] call _findRoadCandidates;
    if (count _candidates == 0) exitWith {
        if (_debug) then { ["[ALiVE CompSpawn] EXIT FAIL: no road in radius (roadblock mode)"] call ALiVE_fnc_dump };
        []
    };

    // Per-position validator: footprint clearance + slope. Slope is read off the
    // underlying terrain heightmap (getTerrainHeightASL ignores the graded road
    // mesh and bridge decks, so elevated/bridge segments are correctly rejected)
    // along road-relative axes out to the composition's footprint radius (env/2 --
    // env is a diameter). Verge axes -- both perpendiculars plus the two diagonals,
    // which catch a switchback fall-line oblique to the road -- use a 12%-grade
    // budget; the along-road axes 14%. These are generous on purpose: the heightmap
    // reads the true hill (steeper than the graded road the checkpoint sits on), so
    // tight budgets starved roadblocks on hilly maps. The general _candidateClear
    // slope check still binds normal roads; this only backstops egregiously steep
    // spots.
    private _validateRoadPos = {
        params ["_rPos", "_rDir"];
        if !([_rPos, _envelope] call _candidateClear) exitWith { false };
        private _half = _envelope / 2;
        private _dists = [_half * 0.33, _half * 0.67, _half];
        private _baseZ = getTerrainHeightASL [_rPos select 0, _rPos select 1];
        private _vergeDeltas = [];
        {
            private _ang = _x;
            { private _sp = _rPos getPos [_x, _ang]; _vergeDeltas pushBack (abs ((getTerrainHeightASL [_sp select 0, _sp select 1]) - _baseZ)); } forEach _dists;
        } forEach [_rDir + 90, _rDir - 90, _rDir + 45, _rDir - 45, _rDir + 135, _rDir - 135];
        if ((selectMax _vergeDeltas) > (_half * 0.12)) exitWith { false };
        private _longDeltas = [];
        {
            private _ang = _x;
            { private _sp = _rPos getPos [_x, _ang]; _longDeltas pushBack (abs ((getTerrainHeightASL [_sp select 0, _sp select 1]) - _baseZ)); } forEach _dists;
        } forEach [_rDir, _rDir + 180];
        if ((selectMax _longDeltas) > (_half * 0.14)) exitWith { false };
        true
    };

    // Anchor search. Instead of abandoning the road point when the nearest
    // road-piece centreline fails (a boulder, a sloped cut), slide the anchor:
    //   Pass 1 - the nearest road-piece centreline that validates (keeps the
    //            checkpoint centred on the carriageway).
    //   Pass 2 - if none, nudge each piece a few metres laterally / along the
    //            road, staying within 8m of a road, onto nearby clear ground.
    private _accepted = [];
    private _idx = _candidates findIf { [_x select 0, _x select 1] call _validateRoadPos };
    if (_idx >= 0) then { _accepted = _candidates select _idx; };

    if (count _accepted == 0) then {
        // [distance, angle relative to the road tangent]: lateral shoulder steps
        // + short longitudinal steps. The +-8m laterals were dropped -- they
        // usually land off the carriageway and get rejected by the nearRoads guard.
        private _offsets = [[4, 90], [4, -90], [6, 0], [6, 180]];
        private _nudges = [];
        {
            private _pPos = _x select 0;
            private _pDir = _x select 1;
            { _nudges pushBack [_pPos getPos [(_x select 0), _pDir + (_x select 1)], _pDir]; } forEach _offsets;
        } forEach _candidates;
        private _nidx = _nudges findIf {
            private _cand = _x select 0;
            (count (_cand nearRoads 8) > 0) && {[_cand, _x select 1] call _validateRoadPos}
        };
        if (_nidx >= 0) then { _accepted = _nudges select _nidx; };
    };

    if (count _accepted == 0) exitWith {
        if (_debug) then { ["[ALiVE CompSpawn] EXIT FAIL: no clear roadblock anchor across %1 road pieces (slope / clearance)", count _candidates] call ALiVE_fnc_dump };
        []
    };
    _accepted params ["_fPos", "_fDir"];
    if (_debug) then { ["[ALiVE CompSpawn] placed (mode %1) at %2", _mode, _fPos] call ALiVE_fnc_dump };
    [_fPos, _fDir]
};

// ------------------------------------------------------------------------
// Stage 2: random sample within radius.
//
// Distance is sqrt-uniform so candidates spread by AREA, not by linear
// radius - `random _radius` (uniform-along-radius) clusters samples in
// the central disk: half the samples land in the inner 50% radius which
// is only 25% of the area. sqrt(random 1) * _radius is the textbook
// inverse-CDF transform for uniform-disk sampling. Uniform area coverage
// matters most when _radius is large (search-cap-expanded scenarios)
// where the outer annulus is where unobstructed terrain typically lives.
// ------------------------------------------------------------------------
private _result = [];
for "_i" from 1 to _maxAttempts do {
    private _angle = random 360;
    private _dist  = sqrt (random 1) * _radius;
    private _candidate = _centerPos getPos [_dist, _angle];
    if ([_candidate, _envelope] call _candidateClear) exitWith {
        private _dir = if (_preferredDir >= 0) then { _preferredDir } else { random 360 };
        _result = [_candidate, _dir];
        if (_debug) then { ["[ALiVE CompSpawn] placed (mode %1) at %2", _mode, _candidate] call ALiVE_fnc_dump };
    };
};

if (count _result == 0 && _debug) then {
    ["[ALiVE CompSpawn] EXIT FAIL: %1 attempts exhausted (envelope=%2 mode=%3 radius=%4 centre=%5)", _maxAttempts, _envelope, _mode, _radius, _centerPos] call ALiVE_fnc_dump;
};

// DIAG-STRIP (camps): when a search comes back with nothing, say which rule
// was doing the turning away. Without this a failed search reports only that
// it failed, and the per-candidate trace above cannot be left switched on to
// find out because a wide search writes over a thousand lines.
//
// Only for searches of 50m and wider, and that gate is doing real work rather
// than being cautious. Seven of the callers use this inside their own sweeps,
// trying position after position where failing is simply how the loop moves
// on, and every one of those asks for 20 to 25m. Every caller that asks once
// and means it asks for 60m or more. Printing on the narrow ones would add
// hundreds of lines to every mission start. On the wide ones it is at most a
// line per objective that could not be placed, which is the thing we want to
// know about anyway.
if (count _result == 0 && {_radius >= 50 || _callerDebug || _debug}) then {
    private _reasons = "";
    {
        if (_x > 0) then {
            _reasons = _reasons + format ["%1%2=%3", if (_reasons == "") then {""} else {", "}, _rejectNames select _forEachIndex, _x];
        };
    } forEach _rejectCounts;
    if (_reasons == "") then { _reasons = "none recorded" };
    ["[ALiVE CompSpawn] FAIL centre=%1 mode=%2 radius=%3m envelope=%4m after %5 tries - turned away by: %6",
        _centerPos, _mode, _radius, _envelope, _maxAttempts, _reasons] call ALiVE_fnc_dump;
};

_result
