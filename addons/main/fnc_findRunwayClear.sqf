#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(findRunwayClear);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_findRunwayClear

Description:
    Returns a position guaranteed to be at least `_clearance` metres clear
    of any runway / taxiway segment edge in the area. If the input position
    already meets the clearance, it's returned unchanged. If not, the
    function nudges the position perpendicular to the nearest segment so
    the result sits exactly at `(segment halfWidth + clearance + small
    margin)` from the segment centreline.

    Reuses ALiVE_fnc_getAirfieldGeometry to enumerate runway and taxiway
    segments. Same closed-form perpendicular-distance-to-segment maths
    that ALiVE_fnc_findCompositionSpawnPosition already uses for runway
    exclusion in mode="ato"; this helper exposes the nudge half so
    callers that aren't position-search loops (e.g. a one-shot waypoint
    set, an aircraft-launch unit sweep) can get a clear point in a
    single call.

    Multi-airfield maps work because getAirfieldGeometry already accepts
    a search radius and returns all segments within it. Maps with no
    Cfg-defined runways short-circuit to "input position unchanged".

Parameters:
    _this select 0: ARRAY  - candidate position [x, y, z?]
    _this select 1: NUMBER - required clearance in metres beyond the
                             segment's halfWidth. Default 5m.
    _this select 2: NUMBER - airfield-geometry search radius. Default
                             1500m. Increase for very large airfields
                             where segments may sit further from the
                             candidate than the default radius.
    _this select 3: ARRAY  - optional segment override. When supplied
                             non-empty, used instead of querying
                             getAirfieldGeometry. Each segment is a
                             [startPos, endPos, halfWidth] tuple.
                             Lets callers synthesise a corridor on
                             maps where the runway is terrain texture
                             rather than placed p3d objects (Stratis
                             main airfield, many community maps) so
                             the helper still has geometry to nudge
                             relative to. Default [].

Returns:
    ARRAY - clear position. Same shape as input (z preserved when
    supplied; defaults to 0 otherwise).

Examples:
    (begin example)
    // Clear a patrol waypoint of any runway/taxiway by 10m
    private _safe = [_proposedWP, 10] call ALiVE_fnc_findRunwayClear;
    private _wp = _grp addWaypoint [_safe, 0];

    // Sweep a unit off the runway by 15m before aircraft takeoff
    private _clear = [getPosATL _u, 15] call ALiVE_fnc_findRunwayClear;
    (group _u) move _clear;
    (end)

See Also:
    ALiVE_fnc_getAirfieldGeometry
    ALiVE_fnc_findCompositionSpawnPosition

Author:
    Jman
---------------------------------------------------------------------------- */

params [
    ["_pos", [0,0,0], [[]], [2,3]],
    ["_clearance", 5, [0]],
    ["_searchRadius", 1500, [0]],
    ["_segmentsOverride", [], [[]]]
];

if (count _pos < 2) exitWith { _pos };

private _z = if (count _pos > 2) then { _pos select 2 } else { 0 };

// Segment data in [start, end, halfWidth] form. Caller-supplied override
// takes priority - lets a launch sweep pass a synthesised corridor when
// the map's runway is terrain texture rather than placed p3d objects.
// Otherwise query getAirfieldGeometry; empty result short-circuits to
// input position unchanged.
private _segments = if (count _segmentsOverride > 0) then {
    _segmentsOverride
} else {
    private _geom = [_pos, _searchRadius] call ALiVE_fnc_getAirfieldGeometry;
    _geom params [["_runways", []], ["_taxiways", []]];
    _runways + _taxiways
};

if (count _segments == 0) exitWith { _pos };

// Walk segments, find the closest one (by perpendicular distance from
// _pos to the segment's clamped foot-point). Track which is closest +
// the violation amount so we can nudge once at the end.
private _closestSeg = [];
private _closestFoot = [];
private _closestDist = 1e10;
private _closestNeeded = 0;

{
    _x params ["_a", "_b", "_hw"];
    private _ax = _a select 0; private _ay = _a select 1;
    private _bx = _b select 0; private _by = _b select 1;
    private _px = _pos select 0; private _py = _pos select 1;
    private _segDx = _bx - _ax; private _segDy = _by - _ay;
    private _segLen2 = _segDx * _segDx + _segDy * _segDy;

    // Point-segment (start==end) handling: getAirfieldGeometry's Tier 3
    // substring match emits each terrain runway/taxiway p3d as a single
    // point with start==end. Treat the foot-point as the point itself;
    // the perpendicular-distance test still works because dist =
    // |_pos - point|. Without this the segLen2 > 0.001 gate skipped
    // every point-segment, leaving real runway data unconsulted.
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
    private _needed = _hw + _clearance;
    if (_dist < _needed && {_dist < _closestDist}) then {
        _closestSeg = _x;
        _closestFoot = [_cx, _cy];
        _closestDist = _dist;
        _closestNeeded = _needed;
    };
} forEach _segments;

// No segment violated clearance - the input position is already clear.
if (count _closestSeg == 0) exitWith { _pos };

// Nudge: move from foot-point in the direction away from the segment by
// (needed + 1m margin). When candidate sits ON the centreline (dist=0),
// pick the segment's perpendicular axis arbitrarily so we still produce
// a non-degenerate result rather than returning the foot-point itself.
private _nudgeMargin = 1;
private _ax = (_closestSeg select 0) select 0;
private _ay = (_closestSeg select 0) select 1;
private _bx = (_closestSeg select 1) select 0;
private _by = (_closestSeg select 1) select 1;
private _fx = _closestFoot select 0;
private _fy = _closestFoot select 1;
private _dirX = (_pos select 0) - _fx;
private _dirY = (_pos select 1) - _fy;
private _dirLen = sqrt (_dirX * _dirX + _dirY * _dirY);
if (_dirLen < 0.001) then {
    // Candidate is exactly on the centreline. Pick perpendicular to
    // segment direction (rotate 90 degrees: [dx, dy] -> [-dy, dx]).
    private _segDx = _bx - _ax;
    private _segDy = _by - _ay;
    private _segLen = sqrt (_segDx * _segDx + _segDy * _segDy);
    if (_segLen > 0.001) then {
        _dirX = -_segDy / _segLen;
        _dirY =  _segDx / _segLen;
    } else {
        _dirX = 1; _dirY = 0;
    };
    _dirLen = 1;
};

private _scale = (_closestNeeded + _nudgeMargin) / _dirLen;
[_fx + _dirX * _scale, _fy + _dirY * _scale, _z]
