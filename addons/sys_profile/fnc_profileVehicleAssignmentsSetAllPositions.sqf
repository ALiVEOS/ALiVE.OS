#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profileVehicleAssignmentsSetAllPositions);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileVehicleAssignmentsSetAllPositions

Description:
Takes a vehicle profile assignment and sets the positions of all assign entities to the passed position

Parameters:
Array - Vehicle assignments
Array - Position

Returns:

Examples:
(begin example)
// set all entities within vehicle to position
_result = [_vehicleAssignments, getPos player] call ALIVE_fnc_profileVehicleAssignmentsSetAllPositions;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_assignments","_position","_entity","_entityProfile","_drivers","_commander","_inControlVehicle"];

_assignments = _this select 0;
_position = _this select 1;

{
	_entity = _x select 1;
	_entityProfile = [ALIVE_profileHandler, "getProfile", _entity] call ALIVE_fnc_profileHandler;

	//["ENTITY %1 setAllPositions: %2",_entityProfile select 2 select 4,_position] call ALIVE_fnc_dump;

    if !(isnil "_entityProfile") then {
		[_entityProfile,"position",_position] call ALIVE_fnc_profileEntity;
		[_entityProfile,"mergePositions"] call ALIVE_fnc_profileEntity;
    };
} forEach (_assignments select 2);