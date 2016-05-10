#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profileVehicleAssignmentGetEmptyPositions);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileVehicleAssignmentGetEmptyPositions

Description:
Get empty positions for the vehicle profile

Parameters:
Array - Vehicle profile

Returns:
Array of empty vehicle positions

Examples:
(begin example)
// get empty positions
_result = _profileVehicle call ALIVE_fnc_profileVehicleAssignmentGetEmptyPositions;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_profileVehicle","_vehicleClass","_vehicleAssignments","_emptyPositionData","_indexes","_countCurrentPosition","_emptyPositions","_emptyPositionData"];

_profileVehicle = _this;

_vehicleClass = _profileVehicle select 2 select 11; //[_profileVehicle, "vehicleClass"] call ALIVE_fnc_hashGet;
_vehicleAssignments = _profileVehicle select 2 select 7; //[_profileVehicle, "vehicleAssignments"] call ALIVE_fnc_hashGet;

// prepare data
_emptyPositionData = [_vehicleClass] call ALIVE_fnc_configGetVehicleEmptyPositions;

// if the vehicle already has assignments
if(count (_vehicleAssignments select 1) > 0) then {
	{
		_indexes = _x select 2;
		// subtract occupied positions from empty position data
		for "_i" from 0 to (count _indexes)-1 do {		
			_countCurrentPosition = count (_indexes select _i);
			_emptyPositions = _emptyPositionData select _i;
			_emptyPositionData set [_i, _emptyPositions - _countCurrentPosition];
		};
		
	} forEach (_vehicleAssignments select 2);
};

_emptyPositionData