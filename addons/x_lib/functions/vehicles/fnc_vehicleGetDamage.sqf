#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(vehicleGetDamage);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_vehicleGetDamage

Description:
Returns an array of damage hit points

Parameters:
Vehicle - The vehicle

Returns:
Array of damage hit points

Examples:
(begin example)
_result = _vehicle call ALIVE_fnc_vehicleGetDamage;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_vehicle","_type","_result","_hitPoints","_hitDamage"];
	
_vehicle = _this;

_result = [];
_type = typeof _vehicle;

_hitPoints = _type call ALIVE_fnc_configGetVehicleHitPoints;

{
	_hitDamage = _vehicle getHitPointDamage _x;
	_result pushback [_x,_hitDamage];
} forEach _hitPoints;

_result