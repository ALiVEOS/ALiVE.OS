#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(configGetVehicleClass);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_configGetVehicleClass

Description:
Get vehicle type of the vehicle class

Parameters:
String - vehicle class name

Returns:
String vehicle type

Examples:
(begin example)
// get vehicle type 
_result = "B_Heli_Light_01_armed_F" call ALIVE_fnc_configGetVehicleClass;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_type","_result"];

_type = _this;

_result = getText(configFile >> "CfgVehicles" >> _type >> "vehicleClass");

_result;