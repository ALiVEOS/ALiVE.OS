#include <\x\alive\addons\sys_profile\script_component.hpp>
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

private ["_indexes","_units","_index","_assignments","_assignment"];

_indexes = (_this select 0) select 2;
_units = _this select 1;

//["indexes:%1",_indexes] call ALIVE_fnc_dump;
//["units:%1",_units] call ALIVE_fnc_dump;

_assignments = [[],[],[],[],[],[]];

for "_i" from 0 to (count _indexes)-1 do {
	_assignment = _assignments select _i;
	{
	    /*
	    ["units: %1 x: %2",count _units,_x] call ALIVE_fnc_dump;
	    ["units: %1",count _units] call ALIVE_fnc_dump;
	    */

	    if(count _units > _x) then {
            _assignment set [count _assignment, _units select _x];
	    };
	} forEach (_indexes select _i);
};

_assignments