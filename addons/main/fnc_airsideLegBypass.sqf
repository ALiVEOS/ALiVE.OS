#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(airsideLegBypass);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_airsideLegBypass

Description:
    Given a straight leg between two positions, returns intermediate positions
    that route it around airfield surface. Returns an empty array when the leg is
    already clear, which is nearly always.

    KEEPING WAYPOINTS OFF A RUNWAY IS NOT THE SAME AS KEEPING TRAFFIC OFF ONE.
    Two waypoints either side of a runway are both perfectly legal and the route
    between them drives straight across. This is the part that addresses that,
    for the virtual layer, where ALiVE decides the route itself and a leg really
    is the straight line between two stored nodes.

    Bypass points all go on ONE side of the obstruction, chosen from the leg
    direction against the runway axis. That consistency is the whole trick.
    Nudging each node independently is what produces a zig-zag that crosses the
    runway more times than the original leg did.

    Taxiways are excluded by default. They are still kept clear of waypoint
    placement, but forbidding every taxiway crossing strands vehicles at a field
    they have a legitimate reason to drive through.

    Conservative by design. Where a bypass cannot be found that is itself clear
    and on land, it returns an empty array and leaves the leg alone. A route
    that crosses a runway beats a route that ends in the sea.

Parameters:
    _from  : ARRAY - leg start [x,y] or [x,y,z]
    _to    : ARRAY - leg end
    _kinds : ARRAY - surface kinds to route around. Default [1,3], runway with
                     its thresholds, and parking.

Returns:
    ARRAY - ordered bypass positions to insert between _from and _to, or [].

Examples:
    (begin example)
    private _via = [_a, _b] call ALiVE_fnc_airsideLegBypass;
    (end)

See Also:
    ALiVE_fnc_isAirside, ALiVE_fnc_airsideClear, ALiVE_fnc_buildAirsideCache

Author:
    Jman
---------------------------------------------------------------------------- */

params [
    ["_from", [], [[]]],
    ["_to", [], [[]]],
    ["_kinds", [1,3], [[]]]
];

if (ALiVE_airsideBounds isEqualTo []) exitWith { [] };
if (count _from < 2 || {count _to < 2}) exitWith { [] };

private _fx = _from select 0;  private _fy = _from select 1;
private _tx = _to select 0;    private _ty = _to select 1;

private _lx = _tx - _fx;
private _ly = _ty - _fy;
private _legLen2 = (_lx * _lx) + (_ly * _ly);
if (_legLen2 < 1) exitWith { [] };
private _legLen = sqrt _legLen2;

// Squared distance from a point to a segment, plus where along the segment the
// closest approach falls. Used for both the reject and the capsule test, so it
// is worth having once.
private _fnc_ptSeg = {
    params ["_px","_py","_ax","_ay","_bx","_by"];
    private _vx = _bx - _ax;  private _vy = _by - _ay;
    private _len2 = (_vx * _vx) + (_vy * _vy);
    private _t = if (_len2 <= 0) then { 0 } else {
        (((((_px - _ax) * _vx) + ((_py - _ay) * _vy)) / _len2) max 0) min 1
    };
    private _ex = _px - (_ax + (_t * _vx));
    private _ey = _py - (_ay + (_t * _vy));
    [((_ex * _ex) + (_ey * _ey)), _t]
};

// Minimum squared distance between two segments in plan view. Exact enough:
// when they cross it reports zero, otherwise the smallest of the four
// endpoint-to-segment distances, which is the true minimum for segments.
private _fnc_segSeg = {
    params ["_p1x","_p1y","_p2x","_p2y","_q1x","_q1y","_q2x","_q2y"];

    private _fnc_cross = {
        params ["_ox","_oy","_ax","_ay","_bx","_by"];
        ((_ax - _ox) * (_by - _oy)) - ((_ay - _oy) * (_bx - _ox))
    };

    private _d1 = [_q1x,_q1y,_q2x,_q2y,_p1x,_p1y] call _fnc_cross;
    private _d2 = [_q1x,_q1y,_q2x,_q2y,_p2x,_p2y] call _fnc_cross;
    private _d3 = [_p1x,_p1y,_p2x,_p2y,_q1x,_q1y] call _fnc_cross;
    private _d4 = [_p1x,_p1y,_p2x,_p2y,_q2x,_q2y] call _fnc_cross;

    if (((_d1 > 0 && {_d2 < 0}) || {_d1 < 0 && {_d2 > 0}})
        && {((_d3 > 0 && {_d4 < 0}) || {_d3 < 0 && {_d4 > 0}})}) exitWith { 0 };

    private _best = 1e12;
    {
        private _d = (_x call _fnc_ptSeg) select 0;
        if (_d < _best) then { _best = _d };
    } forEach [
        [_p1x,_p1y,_q1x,_q1y,_q2x,_q2y],
        [_p2x,_p2y,_q1x,_q1y,_q2x,_q2y],
        [_q1x,_q1y,_p1x,_p1y,_p2x,_p2y],
        [_q2x,_q2y,_p1x,_p1y,_p2x,_p2y]
    ];
    _best
};

// ------------------------------------------------------------------------
// Find the first obstruction along the leg.
// ------------------------------------------------------------------------
private _bestT = 2;
private _hit = [];

private _fieldCount = (count ALiVE_airsideBounds) / 4;

for "_i" from 0 to (_fieldCount - 1) do {
    private _b = _i * 4;
    private _cx = ALiVE_airsideBounds select _b;
    private _cy = ALiVE_airsideBounds select (_b + 1);
    private _br = ALiVE_airsideBounds select (_b + 2);

    // Reject the whole airfield against the leg first. This is what makes the
    // function affordable to call on every leg of every route in the mission.
    private _res = [_cx, _cy, _fx, _fy, _tx, _ty] call _fnc_ptSeg;
    if ((_res select 0) <= (_br * _br)) then {

        private _caps = ALiVE_airsideCapsules param [_i, []];
        private _capCount = (count _caps) / 8;

        for "_j" from 0 to (_capCount - 1) do {
            private _c = _j * 8;

            if ((_caps select (_c + 7)) in _kinds) then {
                private _ax = _caps select _c;
                private _ay = _caps select (_c + 1);
                private _bx = _caps select (_c + 2);
                private _by = _caps select (_c + 3);
                private _r  = _caps select (_c + 4);

                private _d2 = [_fx,_fy,_tx,_ty,_ax,_ay,_bx,_by] call _fnc_segSeg;

                if (_d2 <= (_r * _r)) then {
                    // How far along the leg this obstruction sits, so the
                    // earliest one is the one routed around.
                    private _mid = [((_ax + _bx) / 2), ((_ay + _by) / 2), _fx, _fy, _tx, _ty] call _fnc_ptSeg;
                    private _t = _mid select 1;
                    if (_t < _bestT) then {
                        _bestT = _t;
                        _hit = [_ax, _ay, _bx, _by, _r];
                    };
                };
            };
        };
    };
};

if (_hit isEqualTo []) exitWith { [] };

_hit params ["_ax","_ay","_bx","_by","_r"];

// ------------------------------------------------------------------------
// Route around it, on one side.
// ------------------------------------------------------------------------
private _axisX = _bx - _ax;
private _axisY = _by - _ay;
private _axisLen = sqrt ((_axisX * _axisX) + (_axisY * _axisY));

// A degenerate capsule (a parking disc) has no axis, so take the perpendicular
// of the leg itself and step around the side the leg is already favouring.
private _perpX = 0;
private _perpY = 0;
if (_axisLen < 0.01) then {
    _perpX = (0 - _ly) / _legLen;
    _perpY = _lx / _legLen;
} else {
    _perpX = (0 - _axisY) / _axisLen;
    _perpY = _axisX / _axisLen;
};

// Pick the side once, from the leg direction against the obstruction axis, and
// use it for every point emitted for this leg.
private _side = if (((_lx * _perpX) + (_ly * _perpY)) < 0) then { -1 } else { 1 };
private _off = _r + 30;

// Step around the nearer end first, then the far end, so the detour hugs the
// obstruction rather than swinging wide of it.
private _endA = [_ax, _ay];
private _endB = [_bx, _by];
if ((_endB distance2D [_fx,_fy]) < (_endA distance2D [_fx,_fy])) then {
    private _swap = _endA; _endA = _endB; _endB = _swap;
};

private _via = [];
{
    private _vx = (_x select 0) + (_perpX * _off * _side);
    private _vy = (_x select 1) + (_perpY * _off * _side);
    private _p = [_vx, _vy, 0];

    // Only accept a bypass that is itself clear and on land. An unusable
    // bypass is worse than the crossing it was meant to avoid.
    if (!([_p, 0, _kinds] call ALiVE_fnc_isAirside) && {!(surfaceIsWater _p)}) then {
        _via pushBack _p;
    };
} forEach [_endA, _endB];

if (count _via == 0) exitWith { [] };

// Refuse a detour that costs more than it is worth. A group taking three times
// the distance to avoid a runway is a more visible problem than the crossing.
private _detour = ([_fx,_fy,0] distance2D (_via select 0));
{
    if (_forEachIndex > 0) then { _detour = _detour + ((_via select (_forEachIndex - 1)) distance2D _x) };
} forEach _via;
_detour = _detour + ((_via select ((count _via) - 1)) distance2D [_tx,_ty,0]);

if (_detour > (_legLen * 3)) exitWith { [] };

_via
