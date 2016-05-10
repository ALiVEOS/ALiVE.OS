#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(canSee);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_canSee

Description:
Checks if a given unit can see another object/unit

Parameters:
ARRAY [OBJECT,OBJECT]
Returns:
BOOL

Examples:
(begin example)
[player,testunit] call ALIVE_fnc_canSee;
(end)

See Also:

Author:
Highhead
---------------------------------------------------------------------------- */

params [
    ["_unit", objNull, [objNull]],
    ["_target", objNull, [objNull]]
];

if !(alive _target) exitwith {false};

_dir = (_unit getRelDir _target) - (getDir _unit);

(_dir > -50 && {_dir < 50}) && {!(lineIntersects [eyePos _unit, eyePos _target , _unit, _target])};