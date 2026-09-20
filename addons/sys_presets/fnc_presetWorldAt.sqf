#include "script_component.hpp"
SCRIPT(presetWorldAt);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_presetWorldAt

Description:
Where a point on the screen is, in the world, in either of the editor's views.

The editor shows the scenario two ways and they answer this question with two
different mechanisms. In the three dimensional view a point on the screen is a
ray into the world and screenToWorld answers it. In the map view that same
question is meaningless: screenToWorld still answers from the camera's forward
ray, which points wherever the camera was last left, and gives a position that
can be off the island entirely. Measured: a preset placed that way on Stratis
landed at 2500, 16650, on a map 8192 m square, so four modules existed and
nothing was visible anywhere.

So the map is asked directly when the map is what is being shown. The control is
found by what it is rather than by a number, because a control's id belongs to
the game and can be renumbered, while a map is always a map.

Parameters:
    _display - DISPLAY - the editor display the point was taken on
    _sx      - NUMBER  - screen x, as a display event reports it
    _sy      - NUMBER  - screen y

Returns:
    ARRAY - the position, or [] if it is not on this map

Examples:
    (begin example)
    private _pos = [findDisplay 313, 0.5, 0.5] call ALIVE_fnc_presetWorldAt;
    (end)

See Also:
    ALIVE_fnc_presetPlace, ALIVE_fnc_presetWindow

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_display", displayNull, [displayNull]], ["_sx", 0.5, [0]], ["_sy", 0.5, [0]]];

disableSerialization;

private _pos = [];

if (!isNull _display) then {
    // CT_MAP and CT_MAP_MAIN. Shown, because the editor keeps both views built
    // and only draws one of them.
    private _map = ((allControls _display) select {
        (ctrlType _x) in [100, 101] && {ctrlShown _x}
    }) param [0, controlNull];

    if (!isNull _map) then {
        _pos = _map ctrlMapScreenToWorld [_sx, _sy];
    };
};

if (count _pos < 2) then { _pos = screenToWorld [_sx, _sy] };

// On this map or nothing: a position that is merely a pair of numbers is how
// modules end up somewhere nobody can see them.
if (count _pos < 2
    || {!((_pos select 0) isEqualType 0)} || {!((_pos select 1) isEqualType 0)}
    || {(_pos select 0) <= 0} || {(_pos select 1) <= 0}
    || {(_pos select 0) >= worldSize} || {(_pos select 1) >= worldSize}) exitWith { [] };

[_pos select 0, _pos select 1, 0]
