#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(findNearObjectsByType);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_findNearObjectsByType

Description:
Returns all objects of certain types within radius of pos

Parameters:
Array - Partial P3D type names or config classes to search

Returns:
Array of Objects

Examples:
(begin example)
// get array of id's and positions from object data
_obj_array = [
	"vez.p3d",
	"barrack",
	"mil_",
	"lhd_",
	"ss_hangar",
	"runway",
	"heli_h_army",
	"dragonteeth"
] call ALIVE_fnc_getObjectsByType;
(end)

See Also:
- <ALIVE_fnc_getNearestObjectInArray>

Author:
Highhead
---------------------------------------------------------------------------- */

private ["_pos","_radius","_types","_result","_objects"];

PARAMS_3(_pos,_radius,_types);

_objects = nearestObjects [_pos, [], _radius];
_result = [];

{
    private ["_object","_model"];
    
    _object = _x;
	_model = getText(configfile >> "CfgVehicles" >> typeOf _object >> "model");

	if ({([toLower _model, toLower _x] call CBA_fnc_find) > -1} count _types > 0) then {_result pushback _x} else {
        if ({([toLower (typeOf _object), toLower _x] call CBA_fnc_find) > -1} count _types > 0) then {_result pushback _x};
    };
} foreach _objects;

_result;