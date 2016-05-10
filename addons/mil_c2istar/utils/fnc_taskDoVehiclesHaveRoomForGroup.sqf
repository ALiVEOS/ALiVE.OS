#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskDoVehiclesHaveRoomForGroup);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskDoVehiclesHaveRoomForGroup

Description:
Return any vehicles that have enough room for passengers to accommodate the group

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_taskVehicles","_taskGroup","_groupCount","_vehiclesWithRoom","_emptyCount"];

_taskVehicles = _this select 0;
_taskGroup = _this select 1;

_groupCount = count units _taskGroup;

["GROUP COUNT: %1",_groupCount] call ALIVE_fnc_dump;

_vehiclesWithRoom = [];

{
    _emptyCount = [_x] call ALIVE_fnc_vehicleCountEmptyPositions;

    ["EMPTY COUNT: %1",_emptyCount] call ALIVE_fnc_dump;

    if(_groupCount <= _emptyCount) then {
        _vehiclesWithRoom set [count _vehiclesWithRoom, _x];
    };

} forEach _taskVehicles;

_vehiclesWithRoom