#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(getAirfieldGeometry);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_getAirfieldGeometry
Description:
    Returns runway and taxiway segment lists in the area around _centerPos.
    Used by ALiVE_fnc_findAirSpawnPosition's apron tier to reject candidate
    parking spots that would block AI taxi/take-off paths.

    Three data sources unioned in priority order:
      1. mil_ato module attributes - runwaystartpos / runwayendpos /
         runwaywidth on any mil_ato logic in the mission. Highest precision.
      2. ALiVE_runway / ALiVE_taxiway setVariable tagged objects in radius.
         Convention for custom-runway addons.
      3. Indexed BI substring matches on object string - runway_main /
         runway_secondary / runway_beton / taxiway. Floor for vanilla maps.

    Each segment is a [startPos, endPos, halfWidth] tuple. halfWidth is
    used by the validator to compute the wing-clearance exclusion radius.
    BI runways default to 12 m half-width, taxiways to 4 m, when no
    explicit width is supplied.

    Result is cached per call site by the validator (caller passes the
    same _centerPos for a given air-spawn search; we recompute fresh
    each call - mission run-times rarely place hundreds of aircraft per
    minute, so cache complexity isn't justified yet).

Parameters:
    _this select 0: ARRAY  - centre [x, y, z] for the search.
    _this select 1: NUMBER - search radius in metres (default 500).
    _this select 2: BOOL   - work out the wide airfield no-go zones as well
                             (default true). This is the most expensive part of
                             the function: it sweeps a wider area and inspects the
                             name of every object it finds. A caller that reads only
                             runways and taxiways should pass false.
    _this select 3: BOOL   - retain static terrain matches and exact survey coverage
                             for reuse (default false; builder only, requires false
                             for parameter 2). Retained terrain is assumed static;
                             clear ALiVE_airfieldRetainedSurveys after terrain edits.

Returns:
    ARRAY [_runwaySegments, _taxiwaySegments, _airfieldZones, _sweptObjects] where each
    entry is an array of [_startPos, _endPos, _halfWidth] tuples.
    _airfieldZones are degenerate (start == end) segments centred on
    `nearestLocations` Airport / NameAirportArea entries, with the
    half-width set to the larger of the location's two extents. Use
    them to reject candidates anywhere within an airfield's footprint
    (apron + taxiways + runway + surrounding paved ground), in modes
    that shouldn't place ground compositions on airfields. Callers
    that only need runway / taxiway segments can keep params-
    destructuring two fields; the 3rd is additive.
    _sweptObjects is everything the search found in radius, handed back so a
    caller needing to inspect the same objects does not sweep the area twice.
    Empty when the zone work is skipped is NOT the case - it is always returned.

Examples:
    (begin example)
    private _geom = [getPosATL player, 600] call ALiVE_fnc_getAirfieldGeometry;
    _geom params ["_runways", "_taxiways"];
    // _runways = [[[3500,4500,0], [3700,4700,0], 15], ...]
    (end)

See Also:
    ALiVE_fnc_findAirSpawnPosition
Author:
    Jman
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params [
    ["_centerPos", [0,0,0], [[]], [2,3]],
    ["_radius", 500, [0]],
    // Whether to work out the broad no-go zones around the field as well as its runways
    // and taxiways. Finding those zones is the most expensive thing this does, because it
    // sweeps a wider area and inspects the name of every object it finds, so a caller that
    // only wants runways and taxiways can say so and skip it. Defaults to doing the work,
    // so every existing caller behaves exactly as before.
    ["_needZones", true, [true]],
    ["_retainSurvey", false, [true]]
];

// Retention is for the builder's narrow surveys and their actual scan radius.
// Other callers keep the existing three-argument API.
_retainSurvey = _retainSurvey && {!_needZones};

// ------------------------------------------------------------------------
// Answer from the last identical survey where there was one.
//
// What this reads is static for a whole mission: runways do not move, tagged objects
// are placed before it starts, and the module attributes are read as they were
// authored. Recomputing on every call is harmless at run time, where an aircraft is
// placed now and again, and very costly during placement, where every objective of
// every module asks again and the widest sweep below looks at the name of every object
// within a kilometre. That cost lands hardest on a dedicated server, where the mission
// clock is running throughout placement and engine spatial queries are far dearer than
// they are on a host sitting on the briefing map.
//
// Keyed on exactly what was asked for, so a caller can never be handed a survey of
// somewhere else or of a smaller area than it requested.
//
// The result is SHARED, not copied. Every caller today only reads it; anything that
// wants to modify it must take its own copy first.
// ------------------------------------------------------------------------
if (isNil "ALiVE_airfieldGeomCache") then {
    ALiVE_airfieldGeomCache = createHashMap;
    // Counted so the cache can be judged on evidence rather than on the assumption
    // that callers repeat themselves. Two additions per call, at the top of the
    // function and nowhere near the sweeps, and the totals are reported in one line
    // when ALiVE finishes starting up. Timing anything INSIDE the searches is off the
    // table: six operations added per iteration once took placement from 50 seconds
    // to never finishing.
    ALiVE_airfieldGeomCalls = 0;
    ALiVE_airfieldGeomHits  = 0;
};
// Initialized separately so file-patched missions with an existing cache can
// start counting actual object queries without discarding cached geometry.
if (isNil "ALiVE_airfieldGeomObjectScans") then { ALiVE_airfieldGeomObjectScans = 0 };
if (isNil "ALiVE_airfieldGeomScansAvoided") then { ALiVE_airfieldGeomScansAvoided = 0 };
ALiVE_airfieldGeomCalls = ALiVE_airfieldGeomCalls + 1;
private _cacheKey = format ["%1|%2|%3|%4", _centerPos select 0, _centerPos select 1, _radius, _needZones];
private _cached = ALiVE_airfieldGeomCache get _cacheKey;
if (!_retainSurvey && {!isNil "_cached"}) exitWith {
    ALiVE_airfieldGeomHits = ALiVE_airfieldGeomHits + 1;
    _cached
};

// Measure whole phases only: no timers inside object loops.
// Retained-survey counters are updated per query, never per examined object.
// Cache hits return above; narrow and full surveys are accumulated separately.
private _geomDiag = (missionNamespace getVariable ["ALiVE_MP_STARTUP_DIAG",false])
    || {missionNamespace getVariable ["ALiVE_SEARCH_STARTUP_DIAG",false]};
private _geomT0 = if (_geomDiag) then {diag_tickTime} else {0};
private _geomPhaseT0 = 0;
private _geomPhaseTimes = if (_geomDiag) then {[0,0,0,0,0,0,0,0]} else {[]};
PROFILE_SCOPE(AIRGEOMMISS, "ALiVE airfield geometry: cache miss")

// Bounded, because each entry holds every object the sweep found and a long mission
// would otherwise accumulate those references without limit. The repeats worth having
// all arrive close together during placement, so emptying a full cache costs at most
// one more survey each for whatever is still being asked about.
if (count ALiVE_airfieldGeomCache > 256) then { ALiVE_airfieldGeomCache = createHashMap };

if (isNil "ALiVE_airfieldRetainedSurveys") then { ALiVE_airfieldRetainedSurveys = [] };
if (isNil "ALiVE_airfieldRetainedStats") then { ALiVE_airfieldRetainedStats = [0,0,0] };
private _retainedTerrain = [];
private _retainedSurvey = [];
private _queryASL = AGLToASL [_centerPos select 0, _centerPos select 1, _centerPos param [2,0]];
// Only terrain classification is reused; the wider infrastructure query stays live.
private _queryRadius = _radius;
if (!_retainSurvey) then {
    // Full 3D containment, not overlap or the builder's coarse airside bounds.
    private _covered = ALiVE_airfieldRetainedSurveys findIf {
        (_queryASL vectorDistance (_x select 0)) + _queryRadius <= (_x select 1)
    };
    if (_covered >= 0) then {
        _retainedSurvey = ALiVE_airfieldRetainedSurveys select _covered;
    };
    private _stat = if (_covered >= 0) then {0} else {1};
    ALiVE_airfieldRetainedStats set [_stat, (ALiVE_airfieldRetainedStats select _stat) + 1];
};
private _runways       = [];
private _taxiways      = [];
private _airfieldZones = [];

PROFILE_SCOPE(AIRGEOMMODULES, "ALiVE airfield geometry: module attributes and segments")
if (_geomDiag) then { _geomPhaseT0 = diag_tickTime };
// ------------------------------------------------------------------------
// Tier 1 - mil_ato module logic attributes
// ------------------------------------------------------------------------
{
    private _logic = _x;
    private _start = _logic getVariable ["runwaystartpos", ""];
    private _end   = _logic getVariable ["runwayendpos",   ""];
    private _width = _logic getVariable ["runwaywidth",    ""];

    if (_start != "" && _end != "") then {
        // Attribute strings encode "[x, y, z]" arrays; parse defensively.
        private _startArr = parseSimpleArray _start;
        private _endArr   = parseSimpleArray _end;
        private _widthN   = parseNumber _width;

        if (count _startArr >= 2 && count _endArr >= 2) then {
            // Only include runways within the search radius.
            private _midPos = [
                ((_startArr select 0) + (_endArr select 0)) / 2,
                ((_startArr select 1) + (_endArr select 1)) / 2,
                0
            ];
            if (_midPos distance _centerPos <= _radius * 2) then {
                private _hw = if (_widthN > 0) then { _widthN / 2 } else { 12 };
                _runways pushBack [_startArr, _endArr, _hw];
            };
        };
    };
} forEach (entities "ALiVE_mil_ATO");

if (_geomDiag) then { _geomPhaseTimes set [0, diag_tickTime - _geomPhaseT0] };
PROFILE_SCOPE_END(AIRGEOMMODULES)

// ------------------------------------------------------------------------
// Tier 2 - ALiVE_runway / ALiVE_taxiway setVariable tagged objects
// ------------------------------------------------------------------------
// Survey once at the largest required radius. nearestObjects uses model
// centers and 3D distance by default. Convert both positions to ASL before
// filtering so terrain elevation and object origin offsets are respected.
private _surveyRadius = if (_needZones) then { _radius + 200 } else { _radius };
PROFILE_SCOPE(AIRGEOMSCAN, "ALiVE airfield geometry: nearestObjects")
if (_geomDiag) then { _geomPhaseT0 = diag_tickTime };
private _surveyObjs = nearestObjects [_centerPos, [], _surveyRadius];
if (_geomDiag) then { _geomPhaseTimes set [1, diag_tickTime - _geomPhaseT0] };
PROFILE_SCOPE_END(AIRGEOMSCAN)

ALiVE_airfieldGeomObjectScans = ALiVE_airfieldGeomObjectScans + 1;
PROFILE_SCOPE(AIRGEOMFILTER, "ALiVE airfield geometry: radius filtering")
if (_geomDiag) then { _geomPhaseT0 = diag_tickTime };
private _taggedObjs = _surveyObjs;
if (_needZones) then {
    private _centerAGL = [_centerPos select 0, _centerPos select 1, _centerPos param [2,0]];
    private _centerASL = AGLToASL _centerAGL;
    _taggedObjs = _surveyObjs select {
        (_centerASL vectorDistance (AGLToASL (_x modelToWorld [0,0,0]))) <= _radius
    };
    ALiVE_airfieldGeomScansAvoided = ALiVE_airfieldGeomScansAvoided + 1;
};
if (_geomDiag) then { _geomPhaseTimes set [2, diag_tickTime - _geomPhaseT0] };
PROFILE_SCOPE_END(AIRGEOMFILTER)

PROFILE_SCOPE(AIRGEOMTAGS, "ALiVE airfield geometry: tag classification and segments")
if (_geomDiag) then { _geomPhaseT0 = diag_tickTime };
{
    if (_x getVariable ["ALiVE_runway", false]) then {
        // Tagged objects are treated as point-segments at the object position
        // unless they carry explicit start/end tags. Width from tag or default.
        private _segStart = _x getVariable ["ALiVE_runwayStart", position _x];
        private _segEnd   = _x getVariable ["ALiVE_runwayEnd",   position _x];
        private _hw       = _x getVariable ["ALiVE_runwayHalfWidth", 12];
        _runways pushBack [_segStart, _segEnd, _hw];
    };
    if (_x getVariable ["ALiVE_taxiway", false]) then {
        private _segStart = _x getVariable ["ALiVE_taxiwayStart", position _x];
        private _segEnd   = _x getVariable ["ALiVE_taxiwayEnd",   position _x];
        private _hw       = _x getVariable ["ALiVE_taxiwayHalfWidth", 4];
        _taxiways pushBack [_segStart, _segEnd, _hw];
    };
} forEach _taggedObjs;

if (_geomDiag) then { _geomPhaseTimes set [3, diag_tickTime - _geomPhaseT0] };
PROFILE_SCOPE_END(AIRGEOMTAGS)

PROFILE_SCOPE(AIRGEOMTERRAIN, "ALiVE airfield geometry: terrain classification and segments")
if (_geomDiag) then { _geomPhaseT0 = diag_tickTime };
// ------------------------------------------------------------------------
// Tier 3 - BI substring matches on indexed terrain objects.
// `nearestObjects [_centerPos, [], _radius]` returns terrain plus regular
// objects; we filter on `typeOf == ""` (terrain) AND substring match in
// `str _x` to catch runway / taxiway p3d names. Each terrain segment is
// a single object; we treat its position as both start and end of a
// short segment (buffer absorbs the imprecision).
// ------------------------------------------------------------------------
if (count _retainedSurvey > 0) then {
    PROFILE_SCOPE(AIRGEOMRETAINED, "ALiVE airfield geometry: retained terrain query")
    private _orderedMatches = [];
    {
        _x params ["_object", "_isRunway", "_isTaxiway"];
        private _index = _taggedObjs find _object;
        if (_index >= 0 && {!isNull _object} && {typeOf _object == ""}) then {
            _orderedMatches pushBack [_index, _isRunway, _isTaxiway];
        };
    } forEach (_retainedSurvey select 2);
    _orderedMatches sort true;
    {
        private _pos = position (_taggedObjs select (_x select 0));
        if (_x select 1) then { _runways pushBack [_pos, _pos, 12] };
        if (_x select 2) then { _taxiways pushBack [_pos, _pos, 4] };
    } forEach _orderedMatches;
    PROFILE_SCOPE_END(AIRGEOMRETAINED)
} else {
    PROFILE_SCOPE(AIRGEOMCLASSIFY, "ALiVE airfield geometry: builder or fallback terrain scan")
    {
        if (typeOf _x == "") then {
            // One case-insensitive search. Global matches preserve objects whose
            // names contain both categories; repeated matches still emit one segment.
            // regexFind returns [[matched text, offset], ...] for each match.
            private _matches = (str _x) regexFind ["runway_(?:main|secondary|beton)|taxiway/gi"];
            private _isRunway = false;
            private _isTaxiway = false;
            {
                if (toLower ((_x select 0) select 0) == "taxiway") then {
                    _isTaxiway = true;
                } else {
                    _isRunway = true;
                };
            } forEach _matches;
            if (_isRunway) then {
                if (_retainSurvey) then { _retainedTerrain pushBack [_x, true, _isTaxiway] };
                private _pos = position _x;
                _runways pushBack [_pos, _pos, 12];
            };
            if (_isTaxiway) then {
                if (_retainSurvey && {!_isRunway}) then { _retainedTerrain pushBack [_x, false, true] };
                private _pos = position _x;
                _taxiways pushBack [_pos, _pos, 4];
            };
        };
    } forEach _taggedObjs;
    PROFILE_SCOPE_END(AIRGEOMCLASSIFY)
};

if (_geomDiag) then { _geomPhaseTimes set [4, diag_tickTime - _geomPhaseT0] };
PROFILE_SCOPE_END(AIRGEOMTERRAIN)

// ------------------------------------------------------------------------
// Tier 4 - nearestLocations airport-area detection.
//
// The BI engine registers airfields as named locations with type
// "Airport" or "NameAirportArea". `nearestLocations` returns each
// match with position + size half-axes. For ground-composition
// placement we want to treat the whole airfield footprint as a
// no-go zone (apron + taxiway network + runway + paved
// surroundings) - this is the only tier robust against airfields
// whose surface objects don't carry "runway" / "taxiway" substrings
// in their class names (most BI airfield aprons + surrounding
// concrete fall into this gap).
//
// Half-width = larger of the two location extents. Conservative
// over the rectangular footprint but cheap and reliable.
// ------------------------------------------------------------------------
PROFILE_SCOPE(AIRGEOMLOCS, "ALiVE airfield geometry: nearestLocations")
if (_geomDiag) then { _geomPhaseT0 = diag_tickTime };
private _airportLocs = if (_needZones) then {
    nearestLocations [_centerPos, ["Airport"], _radius + 500]
} else { [] };

if (_geomDiag) then { _geomPhaseTimes set [5, diag_tickTime - _geomPhaseT0] };
PROFILE_SCOPE_END(AIRGEOMLOCS)

// Tier 4b - object-class detection for airfield infrastructure. Some
// maps (vanilla Stratis Air Station included) don't tag their air
// stations as "Airport" CfgLocationTypes - only larger civilian
// airports get that type. To catch military airbases reliably, scan
// nearby objects for runway / taxiway / airport-specific p3d classes
// (PAPI lights, runway-edge lights, airport hangars). Each match
// emits a small airfield zone centred on the object's position; the
// zone half-width grows with the number of matches so a dense cluster
// of airfield infrastructure produces one larger no-go area rather
// than dozens of overlapping small ones.
PROFILE_SCOPE(AIRGEOMINFRA, "ALiVE airfield geometry: infrastructure classification")
if (_geomDiag) then { _geomPhaseT0 = diag_tickTime };
// Infrastructure stays live for all full queries. Builder/narrow queries skip it.
private _airfieldInfraObjects = if (_needZones) then {
    // Reuse the wider survey; runway/taxiway detection and the returned object
    // list above still use only the original narrower radius.
    _surveyObjs select {
        // A single case-insensitive substring search; only the first match is
        // needed for this boolean predicate, so deliberately omit the global flag.
        count ((str _x) regexFind ["papi|runwaylight|runway_edge|airport|hangar|tower_small|controltower/i"]) > 0
    }
} else { [] };
if (_geomDiag) then { _geomPhaseTimes set [6, diag_tickTime - _geomPhaseT0] };
PROFILE_SCOPE_END(AIRGEOMINFRA)

PROFILE_SCOPE(AIRGEOMZONES, "ALiVE airfield geometry: zone construction")
if (_geomDiag) then { _geomPhaseT0 = diag_tickTime };
if (count _airfieldInfraObjects > 0) then {
    // Find bbox of detected infrastructure to size the no-go zone
    private _xs = _airfieldInfraObjects apply { (getPosATL _x) select 0 };
    private _ys = _airfieldInfraObjects apply { (getPosATL _x) select 1 };
    private _xmin = _xs select 0; private _xmax = _xmin;
    private _ymin = _ys select 0; private _ymax = _ymin;
    { if (_x < _xmin) then {_xmin = _x}; if (_x > _xmax) then {_xmax = _x}; } forEach _xs;
    { if (_x < _ymin) then {_ymin = _x}; if (_x > _ymax) then {_ymax = _x}; } forEach _ys;
    private _infraCenter = [(_xmin + _xmax) / 2, (_ymin + _ymax) / 2, 0];
    // half-extent + 30m buffer to cover the apron/taxiway that sits
    // between infrastructure points
    private _infraRadius = (((_xmax - _xmin) max (_ymax - _ymin)) / 2) + 30;
    _airfieldZones pushBack [_infraCenter, _infraCenter, _infraRadius];
};

{
    private _lpos = locationPosition _x;
    private _lsize = size _x;
    if (count _lsize >= 2) then {
        private _lradius = (_lsize select 0) max (_lsize select 1);
        if (_lradius > 0) then {
            _airfieldZones pushBack [_lpos, _lpos, _lradius];
        };
    };
} forEach _airportLocs;

if (_geomDiag) then { _geomPhaseTimes set [7, diag_tickTime - _geomPhaseT0] };
PROFILE_SCOPE_END(AIRGEOMZONES)

// The list of everything found around the field is handed back as well. Sweeping a
// square kilometre and a half is the most expensive thing here, and a caller that needs
// to look at those same objects for its own purposes would otherwise sweep the identical
// area a second time. Appended last, so nothing reading the first three is affected.
if (_retainSurvey) then {
    // Publish only a completed survey, including a valid empty match list.
    ALiVE_airfieldRetainedSurveys pushBack [_queryASL, _radius, _retainedTerrain];
    ALiVE_airfieldRetainedStats set [2, (ALiVE_airfieldRetainedStats select 2) + count _retainedTerrain];
};
private _result = [_runways, _taxiways, _airfieldZones, _taggedObjs];
ALiVE_airfieldGeomCache set [_cacheKey, _result];
PROFILE_SCOPE_END(AIRGEOMMISS)
if (_geomDiag) then {
    private _geomElapsed = diag_tickTime - _geomT0;
    // One sample per survey, outside all object loops. Elapsed includes scheduling.
    // Rows: builder, covered, fallback. Columns: calls, terrain seconds, whole
    // geometry seconds, live objects in terrain radius, retained candidates visited.
    if (isNil "ALiVE_airfieldTerrainPathMetrics") then {
        ALiVE_airfieldTerrainPathMetrics = [[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]];
    };
    private _terrainPath = if (_retainSurvey) then {0} else {
        if (count _retainedSurvey > 0) then {1} else {2}
    };
    private _pathMetrics = ALiVE_airfieldTerrainPathMetrics select _terrainPath;
    _pathMetrics set [0, (_pathMetrics select 0) + 1];
    _pathMetrics set [1, (_pathMetrics select 1) + (_geomPhaseTimes select 4)];
    _pathMetrics set [2, (_pathMetrics select 2) + _geomElapsed];
    _pathMetrics set [3, (_pathMetrics select 3) + count _taggedObjs];
    if (_terrainPath == 1) then {
        _pathMetrics set [4, (_pathMetrics select 4) + count (_retainedSurvey select 2)];
    };

    // Observe fallback reuse opportunities without changing classification or scans.
    // Compare against completed earlier fallback surveys only. A survey finishing
    // during this call could not have supplied retained data when this call began.
    if (_terrainPath == 2 && {!(missionNamespace getVariable ["ALiVE_airfieldOverlapDone",false])}) then {
        PROFILE_SCOPE(AIRGEOMOVERLAP, "ALiVE airfield diagnostics: fallback survey overlap")
        private _overlapT0 = diag_tickTime;
        if (isNil "ALiVE_airfieldFallbackHistory") then { ALiVE_airfieldFallbackHistory = [] };
        if (isNil "ALiVE_airfieldOverlapMetrics") then {
            ALiVE_airfieldOverlapMetrics = [[0,0,0],[0,0,0],[0,0,0]];
            ALiVE_airfieldOverlapComparisons = 0;
            ALiVE_airfieldOverlapElapsed = 0;
        };
        // Mutually exclusive: fully contained in one prior fallback / overlap only / none.
        private _overlapKind = 2;
        private _overlapComparisons = 0;
        {
            if ((_x select 2) <= _geomT0) then {
                _overlapComparisons = _overlapComparisons + 1;
                private _distance = _queryASL vectorDistance (_x select 0);
                private _priorRadius = _x select 1;
                if (_distance + _queryRadius <= _priorRadius) exitWith { _overlapKind = 0 };
                if (_distance < _queryRadius + _priorRadius) then { _overlapKind = 1 };
            };
            if (_overlapKind == 0) exitWith {};
        } forEach ALiVE_airfieldFallbackHistory;
        private _overlapMetrics = ALiVE_airfieldOverlapMetrics select _overlapKind;
        _overlapMetrics set [0, (_overlapMetrics select 0) + 1];
        _overlapMetrics set [1, (_overlapMetrics select 1) + (_geomPhaseTimes select 4)];
        _overlapMetrics set [2, (_overlapMetrics select 2) + count _taggedObjs];
        ALiVE_airfieldFallbackHistory pushBack [+_queryASL, _queryRadius, diag_tickTime];
        ALiVE_airfieldOverlapComparisons = ALiVE_airfieldOverlapComparisons + _overlapComparisons;
        ALiVE_airfieldOverlapElapsed = ALiVE_airfieldOverlapElapsed + (diag_tickTime - _overlapT0);
        PROFILE_SCOPE_END(AIRGEOMOVERLAP)
    };

    if (isNil "ALiVE_airfieldGeomPhaseMetrics") then {
        // Each mode: calls, elapsed, phase times, surveyed/tagged/infrastructure counts.
        ALiVE_airfieldGeomPhaseMetrics = [
            [0,0,[0,0,0,0,0,0,0,0],0,0,0],
            [0,0,[0,0,0,0,0,0,0,0],0,0,0]
        ];
    };
    private _geomMetrics = ALiVE_airfieldGeomPhaseMetrics select (if (_needZones) then {1} else {0});
    _geomMetrics set [0, (_geomMetrics select 0) + 1];
    _geomMetrics set [1, (_geomMetrics select 1) + _geomElapsed];
    private _geomTotals = _geomMetrics select 2;
    { _geomTotals set [_forEachIndex, (_geomTotals select _forEachIndex) + _x] } forEach _geomPhaseTimes;
    _geomMetrics set [3, (_geomMetrics select 3) + count _surveyObjs];
    _geomMetrics set [4, (_geomMetrics select 4) + count _taggedObjs];
    _geomMetrics set [5, (_geomMetrics select 5) + count _airfieldInfraObjects];
};

_result
