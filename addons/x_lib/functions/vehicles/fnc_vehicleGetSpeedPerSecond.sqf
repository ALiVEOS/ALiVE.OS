#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(vehicleGetSpeedPerSecond);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_vehicleGetSpeedPerSecond

Description:
Returns vehicle speed values per second for waypoint speed settings LIMITED, NORMAL, FULL

Parameters:
String - The vehicle classname

Returns:
Array of speeds per second [LIMITED, NORMAL, FULL]

Examples:
(begin example)
_result = "B_Truck_01_covered_F" call ALIVE_fnc_vehicleGetSpeedPerSecond;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_vehicle","_result","_maxSpeed","_speedPerSecond"];
	
_vehicle = _this;
_result = [];

_maxSpeed = call ALIVE_fnc_configGetVehicleMaxSpeed;
_speedPerSecond = (_maxSpeed * 1000) / 3600;

_result set [0, floor(_speedPerSecond * 0.33)];
_result set [1, floor(_speedPerSecond * 0.66)];
_result set [2, floor(_speedPerSecond)];

_result