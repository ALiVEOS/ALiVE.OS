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
    ["_needZones", true, [true]]
];

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
ALiVE_airfieldGeomCalls = ALiVE_airfieldGeomCalls + 1;
private _cacheKey = format ["%1|%2|%3|%4", _centerPos select 0, _centerPos select 1, _radius, _needZones];
private _cached = ALiVE_airfieldGeomCache get _cacheKey;
if (!isNil "_cached") exitWith {
    ALiVE_airfieldGeomHits = ALiVE_airfieldGeomHits + 1;
    _cached
};

// Bounded, because each entry holds every object the sweep found and a long mission
// would otherwise accumulate those references without limit. The repeats worth having
// all arrive close together during placement, so emptying a full cache costs at most
// one more survey each for whatever is still being asked about.
if (count ALiVE_airfieldGeomCache > 256) then { ALiVE_airfieldGeomCache = createHashMap };

private _runways       = [];
private _taxiways      = [];
private _airfieldZones = [];

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

// ------------------------------------------------------------------------
// Tier 2 - ALiVE_runway / ALiVE_taxiway setVariable tagged objects
// ------------------------------------------------------------------------
private _taggedObjs = nearestObjects [_centerPos, [], _radius];
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

// ------------------------------------------------------------------------
// Tier 3 - BI substring matches on indexed terrain objects.
// `nearestObjects [_centerPos, [], _radius]` returns terrain plus regular
// objects; we filter on `typeOf == ""` (terrain) AND substring match in
// `str _x` to catch runway / taxiway p3d names. Each terrain segment is
// a single object; we treat its position as both start and end of a
// short segment (buffer absorbs the imprecision).
// ------------------------------------------------------------------------
{
    if (typeOf _x == "") then {
        private _str = toLower (str _x);
        // The engine's own string search rather than a function call, because this
        // runs on every object the sweep found and there can be thousands of them
        // on a wooded map. Four scripted calls each were costing more than the
        // comparisons they performed. Tier 4b below has always done it this way.
        // _str is already lower case and every needle is lower case, so the answers
        // are the same ones. The braces make the alternatives lazy, so a runway
        // stops being tested as soon as it matches.
        private _isRunway  = ((_str find "runway_main") != -1)
                          || {(_str find "runway_secondary") != -1}
                          || {(_str find "runway_beton") != -1};
        private _isTaxiway = (_str find "taxiway") != -1;

        if (_isRunway) then {
            private _pos = position _x;
            _runways pushBack [_pos, _pos, 12];
        };
        if (_isTaxiway) then {
            private _pos = position _x;
            _taxiways pushBack [_pos, _pos, 4];
        };
    };
} forEach _taggedObjs;

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
private _airportLocs = if (_needZones) then {
    nearestLocations [_centerPos, ["Airport"], _radius + 500]
} else { [] };

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
private _airfieldInfraObjects = if (_needZones) then {
    // The widest sweep in this function, and it looks at the name of every single thing it
    // finds. Only the zones need it, so a caller that does not want them pays none of it.
    (nearestObjects [_centerPos, [], _radius + 200]) select {
        private _str = toLower (str _x);
        (_str find "papi") != -1
        || {(_str find "runwaylight")  != -1}
        || {(_str find "runway_edge")  != -1}
        || {(_str find "airport")      != -1}
        || {(_str find "hangar")       != -1}
        || {(_str find "tower_small")  != -1}
        || {(_str find "controltower") != -1}
    }
} else { [] };
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

// The list of everything found around the field is handed back as well. Sweeping a
// square kilometre and a half is the most expensive thing here, and a caller that needs
// to look at those same objects for its own purposes would otherwise sweep the identical
// area a second time. Appended last, so nothing reading the first three is affected.
private _result = [_runways, _taxiways, _airfieldZones, _taggedObjs];
ALiVE_airfieldGeomCache set [_cacheKey, _result];
_result
