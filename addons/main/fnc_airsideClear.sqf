#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(airsideClear);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_airsideClear

Description:
    Moves a position off airfield surface, by the shortest push that clears it.

    Used where a waypoint has landed somewhere ground units should not be sent:
    on a runway, a taxiway, or an aircraft parking area. It nudges rather than
    rejects, because a dropped waypoint is worse than a slightly moved one.
    OPCOM treats a group with no waypoints as a fault and runs a self heal, so
    handing back nothing would cause more trouble than the original problem.

    IF IT CANNOT CLEAR THE POSITION IT RETURNS THE ORIGINAL UNCHANGED. Sending a
    group somewhere imperfect beats sending it somewhere unvalidated, and beats
    dropping the order entirely. The caller cannot tell the difference and does
    not need to.

    Works entirely on the cached capsule arithmetic, so it makes no engine
    spatial query and reads no config. It is only ever reached for a position
    that already tested airside, which is rare by construction.

Parameters:
    _position : ARRAY - position to clear, [x,y] or [x,y,z]. Z is preserved.
    _kinds    : ARRAY - which surface kinds to clear of. 1 runway and
                        thresholds, 2 taxiways, 3 parking. Default all three.

Returns:
    ARRAY - a cleared position, or the original when it could not be cleared.

Examples:
    (begin example)
    _pos = [_pos] call ALiVE_fnc_airsideClear;
    _garrisonPos = [_garrisonPos, [1]] call ALiVE_fnc_airsideClear;
    (end)

See Also:
    ALiVE_fnc_isAirside, ALiVE_fnc_buildAirsideCache

Author:
    Jman
---------------------------------------------------------------------------- */

params [
    ["_position", [], [[]]],
    ["_kinds", [1,2,3], [[]]]
];

if (ALiVE_airsideBounds isEqualTo []) exitWith { _position };
if (count _position < 2) exitWith { _position };

private _z = if (count _position > 2) then { _position select 2 } else { 0 };
private _px = _position select 0;
private _py = _position select 1;

// Bounded on purpose. Pushing clear of one capsule can land inside a
// neighbouring one, so a few passes are worth taking, but an unbounded loop on
// an airfield whose capsules overlap awkwardly would never settle.
private _passes = 0;

while {_passes < 4 && {[[_px, _py], 0, _kinds] call ALiVE_fnc_isAirside}} do {
    _passes = _passes + 1;

    // Find the capsule this position is furthest inside. Clearing the worst
    // offender first converges faster than taking them in arbitrary order.
    private _bestDepth = -1;
    private _bestFx = 0;
    private _bestFy = 0;
    private _bestR  = 0;
    private _bestPerp = [];

    private _fieldCount = (count ALiVE_airsideBounds) / 4;

    for "_i" from 0 to (_fieldCount - 1) do {
        private _b = _i * 4;
        private _dx = _px - (ALiVE_airsideBounds select _b);
        private _dy = _py - (ALiVE_airsideBounds select (_b + 1));
        private _br = ALiVE_airsideBounds select (_b + 2);

        if (((_dx * _dx) + (_dy * _dy)) <= (_br * _br)) then {
            private _caps = ALiVE_airsideCapsules param [_i, []];
            private _capCount = (count _caps) / 8;

            for "_j" from 0 to (_capCount - 1) do {
                private _c = _j * 8;

                if ((_caps select (_c + 7)) in _kinds) then {
                    private _ax  = _caps select _c;
                    private _ay  = _caps select (_c + 1);
                    private _r   = _caps select (_c + 4);
                    private _inv = _caps select (_c + 6);

                    private _vx = (_caps select (_c + 2)) - _ax;
                    private _vy = (_caps select (_c + 3)) - _ay;
                    private _wx = _px - _ax;
                    private _wy = _py - _ay;

                    private _t = if (_inv <= 0) then { 0 } else {
                        ((((_wx * _vx) + (_wy * _vy)) * _inv) max 0) min 1
                    };

                    private _ex = _wx - (_t * _vx);
                    private _ey = _wy - (_t * _vy);
                    private _d2 = (_ex * _ex) + (_ey * _ey);

                    if (_d2 <= (_r * _r)) then {
                        private _depth = (_r * _r) - _d2;
                        if (_depth > _bestDepth) then {
                            _bestDepth = _depth;
                            _bestFx = _ax + (_t * _vx);
                            _bestFy = _ay + (_t * _vy);
                            _bestR  = _r;
                            // Perpendicular to the capsule axis, used when the
                            // position sits exactly on the centreline and there
                            // is no outward direction to be had from the point
                            // itself. A runway centreline is a real case, not a
                            // theoretical one: that is where things get parked.
                            _bestPerp = if (_inv <= 0) then { [1, 0] } else {
                                private _len = sqrt ((_vx * _vx) + (_vy * _vy));
                                [(0 - _vy) / _len, _vx / _len]
                            };
                        };
                    };
                };
            };
        };
    };

    if (_bestDepth < 0) exitWith {};

    private _ox = _px - _bestFx;
    private _oy = _py - _bestFy;
    private _olen = sqrt ((_ox * _ox) + (_oy * _oy));

    if (_olen < 0.01) then {
        _ox = _bestPerp select 0;
        _oy = _bestPerp select 1;
    } else {
        _ox = _ox / _olen;
        _oy = _oy / _olen;
    };

    // Overshoot the boundary by a few metres rather than landing exactly on it.
    // Sitting on the edge leaves the comparison here and the one in isAirside
    // disagreeing about the boundary case, and the loop then burns every pass
    // without ever converging.
    _px = _bestFx + (_ox * (_bestR + 3));
    _py = _bestFy + (_oy * (_bestR + 3));
};

// Could not clear it. Hand back what came in.
if ([[_px, _py], 0, _kinds] call ALiVE_fnc_isAirside) exitWith { _position };

[_px, _py, _z]
