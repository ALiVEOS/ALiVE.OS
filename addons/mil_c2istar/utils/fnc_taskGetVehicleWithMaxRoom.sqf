#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskGetVehicleWithMaxRoom);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskGetVehicleWithMaxRoom

Description:
From an array of vehicles return the vehicle with the most room for passengers

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_taskVehicles","_vehicleWithMaxRoom","_vehicleMaxRoom","_emptyCount"];

_taskVehicles = _this select 0;

_vehicleWithMaxRoom = objNull;
_vehicleMaxRoom = 0;

{
    _emptyCount = [_x] call ALIVE_fnc_vehicleCountEmptyPositions;

    if(_emptyCount > _vehicleMaxRoom) then {
        _vehicleWithMaxRoom = _x;
        _vehicleMaxRoom = _emptyCount
    };

} forEach _taskVehicles;

[_vehicleWithMaxRoom,_vehicleMaxRoom]