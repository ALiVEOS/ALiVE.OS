#include "\x\alive\addons\sys_profile\script_component.hpp"
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

private _vehicleAssignments = _this;

private _usedIndexes = [];

if ((_vehicleAssignments select 1) isnotequalto []) then {
    {
        private _indexes = _x select 2;

        // record indexes of units that are already assigned to other vehicles
        {
            _usedIndexes append _x;
        } forEach _indexes;
    } forEach (_vehicleAssignments select 2);
};

_usedIndexes
