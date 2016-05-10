#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(vehicleHasRoomForGroup);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_vehicleHasRoomForGroup

Description:
Does the vehicle have enough empty positions for the group

Parameters:
Group - The group
Vehicle - The vehicle

Returns:
Boolean has room for group

Examples:
(begin example)
// get empty positions array
_result = [_group, _vehicle] call ALIVE_fnc_vehicleHasRoomForGroup;
(end)

See Also:
ALIVE_fnc_vehicleCountEmptyPositions

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_group", "_vehicle", "_groupCount", "_positionCount", "_result"];
	
_group = _this select 0;
_vehicle = _this select 1;

_result = false;
_groupCount = count units _group;
_positionCount = [_vehicle] call ALIVE_vehicleCountEmptyPositions;

if(_groupCount <= _positionCount) then
{
	_result = true;
};

_result