#include "\x\alive\addons\x_lib\script_component.hpp"
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

private ["_vehicle","_maxSpeed","_speedPerSecond","_result"];

_vehicle = _this;

if (isNil "ALiVE_vehicleSpeedPerSecondCache") then {
    ALiVE_vehicleSpeedPerSecondCache = createHashMap;
};

if (_vehicle in ALiVE_vehicleSpeedPerSecondCache) exitWith {
    +(ALiVE_vehicleSpeedPerSecondCache get _vehicle)
};

_maxSpeed = call ALIVE_fnc_configGetVehicleMaxSpeed;
_speedPerSecond = (_maxSpeed * 1000) / 3600;

_result = [
    floor (_speedPerSecond * 0.33),
    floor (_speedPerSecond * 0.66),
    floor (_speedPerSecond)
];

ALiVE_vehicleSpeedPerSecondCache set [_vehicle, _result];

_result
