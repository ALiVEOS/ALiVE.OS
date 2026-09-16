#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(isAirside);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_isAirside

Description:
    True when a position falls on airfield surface that ground movement should
    keep off: a runway, its approach and departure strips, a taxiway, or an
    aircraft parking area.

    THIS IS A HOT PATH. It is called from the pathfinder's node expansion, so it
    does no engine spatial queries or config reads. Every
    airfield is reduced once at mission start to a bounding circle and an array
    of capsule records, and this walks that cached arithmetic.

    The first thing it does is compare against an empty array. On a terrain with
    no airfield the cache stays empty and every caller costs exactly that one
    comparison, forever.

    Shape of the cache, both built by ALiVE_fnc_buildAirsideCache:

    ALiVE_airsideFields   one record per airfield:
                           [[cx, cy], radius, radius squared, capsules]
    capsules             array of capsule records:
                           ax, ay, bx, by, radius, radius squared,
                           inverse squared length (0 when degenerate), kind, rectangle
                           rectangle: [midpoint, halfLength, heading]

    Classification uses each capsule's enclosing rotated rectangle directly,
    within the airfield bounding circle. Rounded capsule ends are approximated
    by square corners; degenerate parking discs become squares. Other geometry
    consumers still retain the original capsule data.

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

if (ALiVE_airsideFields isEqualTo [] || { count _position < 2 }) exitWith { false };

private _hit = false;
private _allKinds = _kinds isEqualTo [1,2,3];

{
    private _field = _x;

    // Reject distant airfields before testing individual capsules
    private _insideBounds = (_position distance2D (_field select 0)) <= abs ((_field select 1) + _margin);

    if (_insideBounds) then {
        private _caps = _field select 3;

        {
            private _cap = _x;

            if (_allKinds || {(_cap select 7) in _kinds}) then {
                private _rectangle = _cap select 8;
                private _extent = abs ((_cap select 4) + _margin);
                _hit = _position inArea [
                    _rectangle select 0, _extent,
                    (_rectangle select 1) + _extent,
                    _rectangle select 2, true, -1
                ];
            };
            
            if (_hit) exitWith {};
        } forEach _caps;
    };

    if (_hit) exitWith {};
} forEach ALiVE_airsideFields;

_hit
