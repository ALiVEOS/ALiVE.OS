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

Returns:
    ARRAY [_runwaySegments, _taxiwaySegments] where each entry is an
    array of [_startPos, _endPos, _halfWidth] tuples.

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
    ["_radius", 500, [0]]
];

private _runways  = [];
private _taxiways = [];

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
        // CBA_fnc_find expects [haystack, needle]. _str is the
        // haystack (object string), the literals are needles.
        private _isRunway  = (([_str, "runway_main"] call CBA_fnc_find) != -1)
                          || (([_str, "runway_secondary"] call CBA_fnc_find) != -1)
                          || (([_str, "runway_beton"] call CBA_fnc_find) != -1);
        private _isTaxiway = ([_str, "taxiway"] call CBA_fnc_find) != -1;

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

[_runways, _taxiways]
