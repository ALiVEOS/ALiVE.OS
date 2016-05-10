#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(createLink);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_createLink

Description:
Used for debugging and drawing lines between two objects on the map

Parameters:
Array - Two objects to draw a line between

Examples:
(begin example)
[_x, _x getVariable "neighbour1"] call ALIVE_fnc_createLink;
(end)

See Also:
- <ALIVE_fnc_deleteLink>

Author:
Karel Moricky
Wolffy.au
---------------------------------------------------------------------------- */

private ["_obj1","_obj2","_marker","_pos1","_pos2","_difX","_difY","_lx","_ly","_dis","_dir"];
_obj1 = _this select 0;
_obj2 = _this select 1;

if(isNil "_obj2") exitWith{};

_marker = createMarker [format ["%1_%2",_obj1,_obj2],[0,0,0]];
_marker setMarkerShape "rectangle";
_marker setMarkerBrush "solid";
_marker setMarkerColor "colorblack";	
_marker setMarkerAlpha 0.5;

_pos1 = getPosATL _obj1;
_pos2 = getPosATL _obj2;

_difX = (_pos1 select 0) - (_pos2 select 0) +0.1;
_difY = (_pos1 select 1) - (_pos2 select 1) +0.1;
_lx = (_pos2 select 0) + _difX / 2;
_ly = (_pos2 select 1) + _difY / 2;
_dis = sqrt(_difX^2 + _difY^2);
_dir = atan (_difX / _difY);
_marker setMarkerPos [_lx,_ly];
_marker setMarkerSize [5,_dis/2];
_marker setMarkerDir _dir;
