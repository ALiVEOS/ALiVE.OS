#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(configGetVehicleCrew);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_configGetVehicleCrew

Description:
Get vehicle type of the vehicle class

Parameters:
String - vehicle class name

Returns:
String vehicle crew type

Examples:
(begin example)
// get vehicle type 
_result = "B_Heli_Light_01_armed_F" call ALIVE_fnc_configGetVehicleCrew;
(end)

See Also:

Author:
ARJay, dixon13
---------------------------------------------------------------------------- */

getText(configFile >> "CfgVehicles" >> _this >> "crew")