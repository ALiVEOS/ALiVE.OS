#include "\x\alive\addons\mil_c2istar\script_component.hpp"
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
Jman
---------------------------------------------------------------------------- */

private ["_taskVehicles","_taskGroup","_groupCount","_vehiclesWithRoom","_emptyCount"];

_taskVehicles = _this select 0;
_taskGroup = _this select 1;

_groupCount = count units _taskGroup;

// Behind the debug flag: these ran every few seconds while players waited at a pickup.
private _debug = !isNil "ALiVE_mil_c2istar_debug" && {ALiVE_mil_c2istar_debug};
if (_debug) then { ["GROUP COUNT: %1",_groupCount] call ALIVE_fnc_dump; };

_vehiclesWithRoom = [];

{
    _emptyCount = [_x] call ALIVE_fnc_vehicleCountEmptyPositions;

    if (_debug) then { ["EMPTY COUNT: %1",_emptyCount] call ALIVE_fnc_dump; };

    if(_groupCount <= _emptyCount) then {
        _vehiclesWithRoom pushback _x;
    };

} forEach _taskVehicles;

_vehiclesWithRoom
