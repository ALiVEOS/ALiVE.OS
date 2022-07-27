#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(removeProfileVehicleAssignment);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_removeProfileVehicleAssignment

Description:
Removes a vehicle assignment from both entity and vehicle profiles

Parameters:
Array - Entity profile
Array - Vehicle profile

Returns:

Examples:
(begin example)
// remove vehicle assignment
_result = [_entityProfile,_vehicleProfile] call ALIVE_fnc_removeProfileVehicleAssignment;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

params ["_profileEntity","_profileVehicle",["_deleteAssignment", true]];

private _entityID = [_profileEntity, "profileID"] call ALIVE_fnc_hashGet;
private _vehicleID = [_profileVehicle, "profileID"] call ALIVE_fnc_hashGet;

private _entityAssignments = [_profileEntity,"vehicleAssignments", ["",[],[],""]] call ALIVE_fnc_hashGet;
private _vehicleAssignments = [_profileVehicle,"vehicleAssignments", ["",[],[],""]] call ALIVE_fnc_hashGet;

if(_entityID in (_vehicleAssignments select 1)) then {
    // if spawned make the units get out

    private _profileActive = [_profileEntity,"active"] call ALIVE_fnc_hashGet;
    if (_profileActive) then {
        private _units = [_profileEntity,"units"] call ALIVE_fnc_hashGet;
        private _assignment = [_entityAssignments,_vehicleID] call ALIVE_fnc_hashGet;
        private _vehicleAssignment = [_assignment,_units] call ALIVE_fnc_profileVehicleAssignmentIndexesToUnits;
        private _vehicle = [_profileVehicle,"vehicle"] call ALIVE_fnc_hashGet;

        [_vehicleAssignment, _vehicle] call ALIVE_fnc_vehicleDismount;
    };

    // remove the assignments from the entity and vehicle profile

    if (_deleteAssignment) then {
        [_entityAssignments, _vehicleID] call ALIVE_fnc_hashRem;
        [_vehicleAssignments, _entityID] call ALIVE_fnc_hashRem;
    };

    // remove keys from in cargo arrays

    private _entityInCommandOf = [_profileEntity,"vehiclesInCommandOf"] call ALIVE_fnc_hashGet;
    private _entityInCargoOf = [_profileEntity,"vehiclesInCargoOf"] call ALIVE_fnc_hashGet;

    _entityInCommandOf deleteat (_entityInCommandOf find _vehicleID);
    _entityInCargoOf deleteat (_entityInCargoOf find _vehicleID);

    // remove keys from in command arrays

    private _vehicleInCommandOf = [_profileVehicle,"entitiesInCommandOf"] call ALIVE_fnc_hashGet;
    private _vehicleInCargoOf = [_profileVehicle,"entitiesInCargoOf"] call ALIVE_fnc_hashGet;

    _vehicleInCommandOf deleteat (_vehicleInCommandOf find _entityID);
    _vehicleInCargoOf deleteat (_vehicleInCargoOf find _entityID);
};