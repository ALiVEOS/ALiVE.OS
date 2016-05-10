#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(allSides);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_allSides

Description:
Returns all sides of given objects

Parameters:
String - class

Returns:
Array - Array of used sides;

Examples:
(begin example)
_sides = ([] call BIS_fnc_ListPlayers) call ALiVE_fnc_allSides;
(end)

See Also:
- nil

Author:
Highhead

Peer reviewed:
nil
---------------------------------------------------------------------------- */
private ["_sides","_objects"];

_objects = [_this] param [0, [], [[]]];
_sides = [];

{
    private ["_side"];
    
    _side = (typeOf _x) call ALiVE_fnc_classSide;
    if !(_side in _sides) then {_sides pushback _side};
} foreach _objects;

_sides;