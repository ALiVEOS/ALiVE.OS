#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileVehicleAssignmentsGetInCommand);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileVehicleAssignmentsGetInCommand

Description:
Takes a entity profile vehicle assignment and return an array of vehicle profile ids that the entity is in command of

Parameters:
Array - Vehicle assignments

Returns:

Examples:
(begin example)
// get vehicles the entity is in commmand of
_result = [_vehicleAssignments] call ALIVE_fnc_profileVehicleAssignmentsGetInCommand;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

params ["_assignments","_profile"];

private _result = [];

private _profileType = _profile select 2 select 5; //[_profile,"type"] call ALIVE_fnc_hashGet;
private _entityIndex = if (_profileType == "vehicle") then { 1 } else { 0 };

{
    private _assignment = _x select 2;
    private _drivers = _assignment select 0;
    private _commander = _assignment select 2;

    private _inControlOfVehicle = _drivers isnotequalto [] || _commander isnotequalto [];
    if (_inControlOfVehicle) then {
        _result pushback (_x select _entityIndex);
    };
} forEach (_assignments select 2);

_result
