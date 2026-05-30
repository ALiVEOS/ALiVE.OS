#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
SCRIPT(taskLockProfiles);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskLockProfiles

Description:
    Sets `busy = true` on a list of target profile IDs and registers the
    lock against a taskID in the missionNamespace registry
    `ALIVE_taskProfileLocks`. mil_opcom's TACOM troop-selection at
    fnc_OPCOM.sqf:935 gates on `!_busy`, so locked profiles stop being
    reassigned to other objectives for the duration of the task. Pairs
    with ALIVE_fnc_taskReleaseTaskLocks which clears the flag on task
    success / fail / cancel.

    Profile-type handling:
      - "entity" profiles → set busy on the profile directly
      - "vehicle" profiles → set busy on each associated entity in the
        vehicle's entitiesInCommandOf + entitiesInCargoOf lists. OPCOM
        only checks busy on entity profiles (the vehicle profile itself
        isn't iterated in TACOM's troop selection), so locking the crew
        is what actually keeps the vehicle stationary.

    Idempotent: re-locking an already-locked profile is a no-op (the
    busy flag is already true). The registry overwrites prior entries
    for the same taskID — taskHandler treats one taskID = one lock set.

    Movement halt: `busy = true` only blocks OPCOM from issuing NEW
    orders — existing waypoints (from initial spawn, prior TACOM
    assignments) keep executing in the profile sim. Without also
    clearing them the locked unit "wanders significantly" along its
    pre-existing patrol path before stopping. So the utility also calls
    clearWaypoints + clearActiveCommands per locked entity. The unit
    stops at its current position when the lock fires (which is at task
    INIT, usually at or near the spawn position), and can still
    maneuver under engine combat AI if a player engages it.

Parameters:
    0: STRING - taskID to register the lock against
    1: ARRAY  - profile IDs (entity or vehicle) to lock

Returns:
    ARRAY - the entity profile IDs that were actually locked (caller
            can inspect this if needed; vehicle-type inputs are
            expanded into their crew entities)

Examples:
    (begin example)
    // Lock a single destroy-infantry target:
    [_taskID, [_entityID]] call ALIVE_fnc_taskLockProfiles;

    // Lock multiple HVT targets:
    [_taskID, [_hvt1ID, _hvt2ID]] call ALIVE_fnc_taskLockProfiles;

    // Lock destroy-vehicle target + its crew (utility auto-resolves):
    [_taskID, [_vehicleID]] call ALIVE_fnc_taskLockProfiles;
    (end)

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_taskID", "", [""]], ["_profileIDs", [], [[]]]];

if (_taskID == "" || {count _profileIDs == 0}) exitWith { [] };

if (isNil "ALIVE_taskProfileLocks") then {
    ALIVE_taskProfileLocks = createHashMap;
};

private _lockedEntities = [];

{
    private _profileID = _x;
    private _profile = [ALiVE_ProfileHandler, "getProfile", _profileID] call ALiVE_fnc_ProfileHandler;
    if (!isNil "_profile" && {count _profile >= 3}) then {
        private _profileType = "";
        private _data = _profile select 2;
        if (count _data >= 6) then { _profileType = _data select 5; };

        switch (_profileType) do {
            case "entity": {
                [_profile, "busy", true] call ALIVE_fnc_profileEntity;
                // Stop the entity in place — clear queued waypoints + any
                // active commands. Without this the busy flag prevents NEW
                // OPCOM orders but the profile keeps executing its
                // existing patrol / move-to-objective path, so the
                // "locked" target wanders along its pre-task route
                // before eventually stopping.
                [_profile, "clearWaypoints"] call ALIVE_fnc_profileEntity;
                [_profile, "clearActiveCommands"] call ALIVE_fnc_profileEntity;
                _lockedEntities pushBack _profileID;
            };
            case "vehicle": {
                // OPCOM iterates entity profiles in TACOM troop selection;
                // locking the vehicle profile directly wouldn't be checked.
                // Walk the vehicle's assigned entities and lock those.
                private _entitiesInCommand = [_profile, "entitiesInCommandOf", []] call ALiVE_fnc_hashGet;
                private _entitiesInCargo   = [_profile, "entitiesInCargoOf",   []] call ALiVE_fnc_hashGet;
                {
                    private _crewProfile = [ALiVE_ProfileHandler, "getProfile", _x] call ALiVE_fnc_ProfileHandler;
                    if (!isNil "_crewProfile") then {
                        [_crewProfile, "busy", true] call ALIVE_fnc_profileEntity;
                        [_crewProfile, "clearWaypoints"] call ALIVE_fnc_profileEntity;
                        [_crewProfile, "clearActiveCommands"] call ALIVE_fnc_profileEntity;
                        _lockedEntities pushBackUnique _x;
                    };
                } forEach (_entitiesInCommand + _entitiesInCargo);
            };
        };
    };
} forEach _profileIDs;

ALIVE_taskProfileLocks set [_taskID, _lockedEntities];

_lockedEntities
