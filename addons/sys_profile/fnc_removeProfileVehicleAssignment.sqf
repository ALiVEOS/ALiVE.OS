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
        // Entity-side and vehicle-side assignment records can drift out of
        // sync during profile destruction: we are in this branch because
        // the vehicle-side record still references _entityID, but the
        // matching entry on the entity-side may already be gone. In that
        // case hashGet returns nil and the downstream call into
        // fnc_profileVehicleAssignmentIndexesToUnits crashes with
        // "Undefined variable _indexes" / "Undefined variable _assignment"
        // (pre-existing ALiVE core error chain). Skip the dismount when
        // the entity-side record is missing; the cleanup block below still
        // runs and prunes the vehicle-side record to restore consistency.
        private _assignment = [_entityAssignments,_vehicleID] call ALIVE_fnc_hashGet;
        if (!isNil "_assignment") then {
            private _units = [_profileEntity,"units"] call ALIVE_fnc_hashGet;
            private _vehicleAssignment = [_assignment,_units] call ALIVE_fnc_profileVehicleAssignmentIndexesToUnits;
            private _vehicle = [_profileVehicle,"vehicle"] call ALIVE_fnc_hashGet;

            [_vehicleAssignment, _vehicle] call ALIVE_fnc_vehicleDismount;
        } else {
            [
                "ALiVE fnc_removeProfileVehicleAssignment: skipping dismount, entity-side assignment missing (entity=%1 vehicle=%2). Cleanup continues.",
                _entityID, _vehicleID
            ] call ALiVE_fnc_dump;
        };
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