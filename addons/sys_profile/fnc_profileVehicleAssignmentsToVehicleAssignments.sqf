#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profileVehicleAssignmentsToVehicleAssignments);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileVehicleAssignmentsToVehicleAssignments

Description:
Takes profile vehicle assignments and creates real vehicle assignments
Needs to be run in unscheduled with delay to avoid freezes as it may trigger
creation of multiple vehicles / groups in one frame.
TBD: Move to unscheduled and split creation to several frames.

Parameters:
Array - Profile vehicle assignments
Array - Profile

Returns:

Examples:
(begin example)
_result = [_vehicleAssignments,_profile] call ALIVE_fnc_profileVehicleAssignmentsToVehicleAssignments;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_vehicleAssignments","_profile"];

_vehicleAssignments = _this select 0;
_profile = _this select 1;

if(count (_vehicleAssignments select 1) > 0) then {
	{
		[_x, _profile] call ALIVE_fnc_profileVehicleAssignmentToVehicleAssignment;
        sleep 0.5;
	} forEach (_vehicleAssignments select 2);
};