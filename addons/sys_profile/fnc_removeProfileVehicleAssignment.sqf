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

private _entityID = _profileEntity select 2 select 4;
private _vehicleID = _profileVehicle select 2 select 4;

private _entityAssignments = _profileEntity select 2 select 7;
private _vehicleAssignments = _profileVehicle select 2 select 7;

if (_entityID in (_vehicleAssignments select 1)) then {
    // if spawned make the units get out

    private _profileActive = _profileEntity select 2 select 1;
    if (_profileActive) then {
        // Entity-side and vehicle-side assignment records can drift out of
        // sync during profile destruction: The vehicle-side record may still
        // reference _entityID, but the matching entry on the entity-side may
        // already be gone. In that case hashGet returns nil and the downstream call into
        // fnc_profileVehicleAssignmentIndexesToUnits errors. Skip the dismount when
        // the entity-side record is missing; the cleanup block below still
        // runs and prunes the vehicle-side record to restore consistency.
        private _assignment = [_entityAssignments,_vehicleID] call ALIVE_fnc_hashGet;
        if (!isNil "_assignment") then {
            private _units = _profileEntity select 2 select 21;
            private _vehicle = _profileVehicle select 2 select 10;

            private _vehicleAssignment = [_assignment,_units] call ALIVE_fnc_profileVehicleAssignmentIndexesToUnits;
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
        [_entityAssignments,_vehicleID, nil] call ALIVE_fnc_hashSet;
        [_vehicleAssignments,_entityID, nil] call ALIVE_fnc_hashSet;
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