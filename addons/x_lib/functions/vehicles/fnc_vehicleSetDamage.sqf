#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(vehicleSetDamage);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_vehicleSetDamage

Description:
Sets a vehicles damage from a passed multi dimensional array from ALIVE_fnc_vehicleGetDamage

Parameters:
Vehicle - The vehicle

Returns:

Examples:
(begin example)
_result = [_vehicle, _ammo] call ALIVE_fnc_vehicleSetDamage;
(end)

See Also:
ALIVE_fnc_vehicleGetDamage

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_vehicle","_damage"];
	
_vehicle = _this select 0;
_damage = _this select 1;

{
	_vehicle setHitPointDamage _x;
} forEach _damage;