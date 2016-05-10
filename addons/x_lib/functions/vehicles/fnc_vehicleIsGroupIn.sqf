#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(vehicleIsGroupIn);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_vehicleIsGroupIn

Description:
Check if a whole group is in a vehicle

Parameters:
Group - The group
Vehicle - The vehicle

Returns:
Boolean

Examples:
(begin example)
_result = [_group, _vehicle] call ALIVE_fnc_vehicleIsGroupIn;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_group", "_vehicle", "_result"];
	
_group = _this select 0;
_vehicle = _this select 1;

_result = true;

{
	if!(_x in _vehicle) then
	{
		_result = false;
	};
} forEach units _group;

_result