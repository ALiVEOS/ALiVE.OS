#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(getRunwayCentreline);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getRunwayCentreline

Description:
    Works out a usable runway centreline near a position, for terrains whose
    config carries no ILS data.

    Arma's engine airport entries (cfgWorlds >> ilsPosition / ilsTaxiIn /
    ilsTaxiOff, and the SecondaryAirports list) are what normally tell ALiVE
    where an aircraft should sit before takeoff and where it should be put
    down after landing. Plenty of terrains define no airport at all, or
    define one with those arrays empty. Callers then read straight off an
    empty array, which is where the launch and arrival script errors came
    from.

    ALiVE_fnc_getAirfieldGeometry already knows where runways are - it is
    used to keep compositions and parked aircraft off them - but it reports
    them in a form meant for exclusion tests rather than for flying:

      Tier 1 (mil_ato runway attributes) and tier 2 (ALiVE_runway tagged
      objects) give a genuine [start, end] segment.
      Tier 3 (runway_main / runway_beton / taxiway p3d matches on terrain
      objects) gives one degenerate entry per object, where start == end.
      A point tells you "the runway is here"; it does not tell you which
      way it points.

    So this function prefers a real segment when one exists, and otherwise
    fits a line through the tier-3 point cloud by taking its farthest pair.
    For a runway - a long thin cluster of surface objects - the farthest
    pair lies along the centreline, which is the axis we need.

Parameters:
    _position : ARRAY  - centre to search around [x,y,z]
    _radius   : NUMBER - search radius in metres (default 1500). Runways are
                         long; too small a radius clips the point cloud and
                         biases the fitted axis.

Returns:
    ARRAY [_start, _end, _halfWidth] in the same shape getAirfieldGeometry
    uses, or [] when no runway could be determined. Callers must handle [].

    _start and _end are the two ends of the centreline. Which one is
    "the threshold" is not determined - there is no wind model here and no
    config to say which way the runway is numbered, so callers should pick
    whichever end suits them (nearest to the aircraft, usually).

Examples:
    (begin example)
    private _cl = [getPosATL _plane, 1500] call ALiVE_fnc_getRunwayCentreline;
    if (count _cl > 0) then {
        _cl params ["_start", "_end"];
        private _heading = _start getDir _end;
    };
    (end)

See Also:
    ALiVE_fnc_getAirfieldGeometry, ALiVE_fnc_getNearestAirportID

Author:
    Jman
---------------------------------------------------------------------------- */

params [
    ["_position", [0,0,0], [[]], [2,3]],
    ["_radius", 1500, [0]]
];

private _geom = [_position, _radius] call ALiVE_fnc_getAirfieldGeometry;
if (isNil "_geom" || {!(_geom isEqualType [])} || {count _geom == 0}) exitWith { [] };

private _runways = _geom select 0;
if (isNil "_runways" || {count _runways == 0}) exitWith { [] };

// ------------------------------------------------------------------------
// Preferred: a segment that already has two distinct ends. Only tiers 1 and
// 2 produce these, and both are authored rather than inferred - a mission
// maker's runway attributes or a deliberately tagged object - so they beat
// anything fitted from scattered terrain objects.
// ------------------------------------------------------------------------
private _authored = _runways select {
    (_x select 0) distance2D (_x select 1) > 50
};

if (count _authored > 0) exitWith {
    // Nearest authored centreline to the search position.
    private _best = _authored select 0;
    private _bestDist = 1e10;
    {
        private _mid = [
            (((_x select 0) select 0) + ((_x select 1) select 0)) / 2,
            (((_x select 0) select 1) + ((_x select 1) select 1)) / 2,
            0
        ];
        private _d = _mid distance2D _position;
        if (_d < _bestDist) then { _bestDist = _d; _best = _x; };
    } forEach _authored;
    _best
};

// ------------------------------------------------------------------------
// Fallback: fit an axis through the degenerate tier-3 points. Farthest pair
// wins - on a long thin object cluster that pair lies along the centreline.
//
// This is O(n^2) over the runway points near one airfield, which is a few
// dozen at most on the maps checked. It runs when an aircraft launches or
// lands rather than every frame, so the cost is irrelevant; a smarter
// principal-axis fit would add failure modes for no practical gain.
// ------------------------------------------------------------------------
private _points = [];
{
    private _p = _x select 0;
    if (!isNil "_p" && {_p isEqualType []} && {count _p >= 2}) then {
        _points pushBack _p;
    };
} forEach _runways;

if (count _points < 2) exitWith { [] };

private _bestA = _points select 0;
private _bestB = _points select 1;
private _bestSpan = -1;

{
    private _a = _x;
    private _i = _forEachIndex;
    {
        if (_forEachIndex > _i) then {
            private _span = _a distance2D _x;
            if (_span > _bestSpan) then {
                _bestSpan = _span;
                _bestA = _a;
                _bestB = _x;
            };
        };
    } forEach _points;
} forEach _points;

// A cluster too short to be a runway is more likely a helipad apron or a
// couple of stray concrete tiles. Reporting that as a centreline would aim
// a departing aircraft at nothing useful, so say we found nothing instead
// and let the caller fall back to the aircraft's own parking position.
if (_bestSpan < 200) exitWith { [] };

// Half-width from the widest contributing segment, defaulting to the same
// 12 m getAirfieldGeometry uses for an untagged runway.
private _halfWidth = 12;
{
    private _hw = _x select 2;
    if (!isNil "_hw" && {_hw isEqualType 0} && {_hw > _halfWidth}) then { _halfWidth = _hw; };
} forEach _runways;

[_bestA, _bestB, _halfWidth]
