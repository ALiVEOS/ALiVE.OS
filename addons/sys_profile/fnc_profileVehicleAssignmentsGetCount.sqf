#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profileVehicleAssignmentsGetCount);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileVehicleAssignmentsGetCount

Description:
Takes vehicle assignments and counts the number of units assigned

Parameters:
Array - Vehicle assignments

Returns:

Examples:
(begin example)
// get count of units assigned in assignments
_result = _vehicleAssignments call ALIVE_fnc_profileVehicleAssignmentsGetCount;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_assignments","_result","_assignment"];

_assignments = _this;

_result = 0;

{
	_assignment = _x select 2;
	
	{
		if((count _x) > 0) then {
			_result = _result + count(_x);
		};
	} forEach _assignment;
} forEach (_assignments select 2);

_result