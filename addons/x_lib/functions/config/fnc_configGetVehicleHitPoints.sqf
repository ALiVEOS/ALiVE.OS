#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(configGetVehicleHitPoints);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_configGetVehicleHitPoints

Description:
Get hit point data for a vehicle class

Parameters:
String - vehicle class name

Returns:
Array of hit point data

Examples:
(begin example)
// get vehicle hit point data
_result = "B_Heli_Light_01_armed_F" call ALIVE_fnc_configGetVehicleHitPoints;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_type","_result","_hitPoints","_hitPoint","_hitName"];

_type = _this;

_result = [];

_hitPoints = configFile >> "CfgVehicles" >> _type >> "HitPoints";

for "_i" from 0 to (count _hitPoints)-1 do
{
	_hitPoint = _hitPoints select _i;
		
	if(isClass _hitPoint) then
	{
		_hitName = configName _hitPoint;
		_result pushback _hitName;
	};
};

_result;