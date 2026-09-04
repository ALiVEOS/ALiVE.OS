#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileVehicleAssignmentIndexesToUnits);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileVehicleAssignmentIndexesToUnits

Description:
Takes a profile vehicle assignment unit index array and returns the array as units

Parameters:
Array - Vehicle assignment indexes
Array - Unit array

Returns:

Examples:
(begin example)
// convert assignment indexes to units
_result = [_vehicleAssignmentIndexes,_unitArray] call ALIVE_fnc_profileVehicleAssignmentIndexesToUnits;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private _indexes = (_this select 0) select 2;
private _units = _this select 1;

private _unitCount = count _units;
private _assignments = [[],[],[],[],[],[]];

{
    private _assignment = _assignments select _forEachIndex;

    {
        if (_unitCount > _x) then {
            _assignment pushback (_units select _x);
        };
    } forEach _x;
} forEach _indexes;

_assignments
