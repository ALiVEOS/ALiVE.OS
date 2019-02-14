#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(setposAGLS);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_setposAGLS
Description:
Sets an object on the top surface

Parameters:
Object - object to place
Array - position to set
number - offset of height

Returns:
ARRAY - position

Examples:
(begin example)
_pos = [player,getpos player,0.5] call ALiVE_fnc_setposAGLS
(end)

Author:
ARJay
 
Peer reviewed:
nil
---------------------------------------------------------------------------- */

params ["_obj", "_pos", "_offset"];

_offset = _pos select 2; if (isNil "_offset") then {_offset = 0};

_pos set [2, worldSize]; 
_obj setPosASL _pos;
_pos set [2, vectorMagnitude (_pos vectorDiff getPosVisual _obj) + _offset];
_obj setPosASL _pos;

_pos;
