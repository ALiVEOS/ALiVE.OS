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

private ["_assignments","_position","_entity","_entityProfile","_drivers","_commander","_inControlVehicle"];

_assignments = _this select 0;
_position = _this select 1;

{
    _entity = _x select 1;
    _entityProfile = [ALIVE_profileHandler, "getProfile", _entity] call ALIVE_fnc_profileHandler;

    //["ENTITY %1 setAllPositions: %2",_entityProfile select 2 select 4,_position] call ALIVE_fnc_dump;

    if !(isnil "_entityProfile") then {
        // A vehicle assignment's entity slot (select 1) must resolve to an ENTITY profile
        // (the crew), never a vehicle. A vehicle-typed profile here is a malformed /
        // self-referential assignment (e.g. an ATO airframe whose crewID was its own vehicle
        // id). Feeding such a profile to profileEntity "mergePositions" re-routes back into
        // profileVehicle "mergePositions" -> setAllPositions -> here again, an unbounded
        // recursion that hard-freezes the sim thread. Only merge genuine entity profiles; skip
        // anything else (log once, keyed on profile id, sharing the profileEntity dedup set).
        // Mirrors the slot-1-must-be-entity guard in fnc_profileVehicleAssignmentToVehicleAssignment.
        // Note: this sits inside forEach, so it must be if/else, not exitWith (which would abort
        // the whole loop and skip a legitimate crew entry queued after a bad one).
        if ((_entityProfile select 2 select 5) == "entity") then {
            [_entityProfile,"position",_position] call ALIVE_fnc_profileEntity;
            [_entityProfile,"mergePositions"] call ALIVE_fnc_profileEntity;
        } else {
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