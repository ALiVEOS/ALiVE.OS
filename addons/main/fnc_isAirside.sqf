#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(isAirside);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_isAirside

Description:
    True when a position falls on airfield surface that ground movement should
    keep off: a runway, its approach and departure strips, a taxiway, or an
    aircraft parking area.

    THIS IS A HOT PATH. It is called from the pathfinder's node expansion, so it
    does no engine spatial queries, no config reads and no square roots. Every
    airfield is reduced once at mission start to a bounding circle and a flat
    list of capsules, and this walks that cached arithmetic.

    The first thing it does is compare against an empty array. On a terrain with
    no airfield the cache stays empty and every caller costs exactly that one
    comparison, forever.

    Shape of the cache, both built by ALiVE_fnc_buildAirsideCache:

    ALiVE_airsideBounds    flat, stride 4 per airfield:
                           cx, cy, radius, radius squared
    ALiVE_airsideCapsules  element i is a flat stride 8 array for airfield i:
                           ax, ay, bx, by, radius, radius squared,
                           inverse squared length (0 when degenerate), kind

    A capsule is a line segment with a thickness, which suits every shape here.
    A runway is a long thin one, a parking area is a degenerate one that
    collapses to a disc. Testing a point means clamping its projection onto the
    segment and comparing squared distances, so no square root is needed.

Parameters:
    _position : ARRAY  - position to test, [x,y] or [x,y,z]. Z is ignored.
    _margin   : NUMBER - extra clearance in metres added to every radius.
                         Callers working in grid cells pass half a cell so that
                         a cell centre just outside a runway still counts when
                         the cell itself straddles it. Default 0.
    _kinds    : ARRAY  - which surface kinds count. 1 runway and thresholds,
                         2 taxiways, 3 parking. Default all three.

Returns:
    BOOL - true when the position is on excluded airfield surface.

Examples:
    (begin example)
    if ([_pos] call ALiVE_fnc_isAirside) then { ... };
    if ([_cellCentre, _cellSize / 2, [1]] call ALiVE_fnc_isAirside) then { ... };
    (end)

See Also:
    ALiVE_fnc_buildAirsideCache, ALiVE_fnc_airsideClear,
    ALiVE_fnc_airsideLegBypass, ALiVE_fnc_getAirfieldGeometry

Author:
    Jman
---------------------------------------------------------------------------- */

params [
    ["_position", [], [[]]],
    ["_margin", 0, [0]],
    ["_kinds", [1,2,3], [[]]]
];

// No airfield anywhere on this terrain, or the build has not run yet. This is
// the common case on most maps and it must stay a single comparison.
if (ALiVE_airsideBounds isEqualTo []) exitWith { false };
if (count _position < 2) exitWith { false };

private _px = _position select 0;
private _py = _position select 1;
private _hit = false;

private _fieldCount = (count ALiVE_airsideBounds) / 4;

for "_i" from 0 to (_fieldCount - 1) do {
    private _b = _i * 4;

    // Bounding circle first. Nearly every position in a mission is nowhere near
    // an airfield, and this rejects those in five arithmetic operations.
    private _dx = _px - (ALiVE_airsideBounds select _b);
    private _dy = _py - (ALiVE_airsideBounds select (_b + 1));
    private _br = (ALiVE_airsideBounds select (_b + 2)) + _margin;

    if (((_dx * _dx) + (_dy * _dy)) <= (_br * _br)) then {

        private _caps = ALiVE_airsideCapsules param [_i, []];
        private _capCount = (count _caps) / 8;

        for "_j" from 0 to (_capCount - 1) do {
            private _c = _j * 8;

            if ((_caps select (_c + 7)) in _kinds) then {
                private _ax  = _caps select _c;
                private _ay  = _caps select (_c + 1);
                private _r   = (_caps select (_c + 4)) + _margin;
                private _inv = _caps select (_c + 6);

                private _vx = (_caps select (_c + 2)) - _ax;
                private _vy = (_caps select (_c + 3)) - _ay;
                private _wx = _px - _ax;
                private _wy = _py - _ay;

                // Clamped projection onto the segment. A degenerate capsule has
                // inv 0 and collapses to a disc around its start point, which is
                // exactly what a parking area is.
                private _t = if (_inv <= 0) then { 0 } else {
                    ((((_wx * _vx) + (_wy * _vy)) * _inv) max 0) min 1
                };

                private _ex = _wx - (_t * _vx);
                private _ey = _wy - (_t * _vy);

                if (((_ex * _ex) + (_ey * _ey)) <= (_r * _r)) exitWith { _hit = true };
            };
        };
    };

    if (_hit) exitWith {};
};

_hit
