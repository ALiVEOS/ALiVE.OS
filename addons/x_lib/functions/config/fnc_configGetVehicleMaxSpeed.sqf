#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(configGetVehicleMaxSpeed);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_configGetVehicleMaxSpeed

Description:
Get max speed of vehicle from config

Parameters:
String - vehicle class name

Returns:
Scalar max speed kilometers per hour

Examples:
(begin example)
// get vehicle max speed data
_result = "B_Heli_Light_01_armed_F" call ALIVE_fnc_configGetVehicleMaxSpeed;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_type","_result"];

_type = _this;

_result = getNumber(configFile >> "CfgVehicles" >> _type >> "maxSpeed");

_result;