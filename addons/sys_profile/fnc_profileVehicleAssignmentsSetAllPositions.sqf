#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileVehicleAssignmentsSetAllPositions);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileVehicleAssignmentsSetAllPositions

Description:
Takes a vehicle profile assignment and sets the positions of all assign entities to the passed position

Parameters:
Array - Vehicle assignments
Array - Position

Returns:

Examples:
(begin example)
// set all entities within vehicle to position
_result = [_vehicleAssignments, getPos player] call ALIVE_fnc_profileVehicleAssignmentsSetAllPositions;
(end)

See Also:

Author:
ARJay
Jman
---------------------------------------------------------------------------- */

params ["_assignments","_position"];

private _profilesByID = [ALIVE_profileHandler,"profilesById"] call ALiVE_fnc_hashGet;

{
    private _entity = _x select 1;
    private _entityProfile = _profilesByID get _entity;

    if !(isnil "_entityProfile") then {
        if ((_entityProfile select 2 select 5) == "entity") then {
            [_entityProfile,"position", _position] call ALIVE_fnc_profileEntity;
            [_entityProfile,"mergePositions"] call ALIVE_fnc_profileEntity;
        } else {
            // assignments must be entities
            // this branch handles bad data that has been seen in the past
            // log for investigation
            private _badID = _entityProfile select 2 select 4;
            private _logged = missionNamespace getVariable ["ALIVE_profileMergePositionsLoggedIDs", []];
            if !(_badID in _logged) then {
                _logged pushBack _badID;
                missionNamespace setVariable ["ALIVE_profileMergePositionsLoggedIDs", _logged];
                ["fnc_profileVehicleAssignmentsSetAllPositions: assignment entity slot %1 is a %2 profile, not an entity -- skipped to prevent mergePositions recursion", _badID, (_entityProfile select 2 select 5)] call ALiVE_fnc_dump;
            };
        };
    };
} forEach (_assignments select 2);