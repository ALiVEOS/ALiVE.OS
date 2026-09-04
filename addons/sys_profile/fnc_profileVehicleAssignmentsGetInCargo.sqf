#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileVehicleAssignmentsGetInCargo);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileVehicleAssignmentsGetInCargo

Description:
Takes a vehicle profile vehicle assignment and return an array of entity profile ids that are in cargo positions of the vehicle

Parameters:
Array - Vehicle assignments

Returns:

Examples:
(begin example)
// get entities that are in the vehicle as cargo
_result = [_vehicleAssignments] call ALIVE_fnc_profileVehicleAssignmentsGetInCargo;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_entity"];

params ["_assignments","_profile"];

private _result = [];

private _profileType = _profile select 2 select 5; //[_profile,"type"] call ALIVE_fnc_hashGet;
private _entityIndex = if (_profileType == "vehicle") then { 1 } else { 0 };

{
    private _assignment = _x select 2;
    private _drivers = _assignment select 0;
    private _commander = _assignment select 2;

    private _inVehicleCargo = _drivers isequalto [] && _commander isequalto [];
    if (_inVehicleCargo) then {
        _result pushback (_x select _entityIndex);
    };
} forEach (_assignments select 2);

_result
