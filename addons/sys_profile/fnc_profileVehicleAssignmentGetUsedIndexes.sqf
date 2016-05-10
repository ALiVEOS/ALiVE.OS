#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profileVehicleAssignmentGetUsedIndexes);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileVehicleAssignmentGetUsedIndexes

Description:
Get used unit indexes according to current entity profile vehicle assignments

Parameters:
Array - Array of vehicle assignments as returned from vehicleAssignments on the entity profile

Returns:
Array of unit indexes that are assigned to vehicles

Examples:
(begin example)
// vehicle assignment
_result = _vehicleAssignments call ALIVE_fnc_profileVehicleAssignmentGetUsedIndexes;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_vehicleAssignments","_usedIndexes","_indexes","_indexesCurrentPosition"];

_vehicleAssignments = _this;

_usedIndexes = [];

// if the group already has assignments
if(count (_vehicleAssignments select 1) > 0) then {
	{		
		_indexes = _x select 2;
		// record indexs of units that are already assigned to other vehicles
		for "_i" from 0 to (count _indexes)-1 do {		
			_indexesCurrentPosition = _indexes select _i;
			_usedIndexes = _usedIndexes + _indexesCurrentPosition;
		};
		
	} forEach (_vehicleAssignments select 2);
};

_usedIndexes