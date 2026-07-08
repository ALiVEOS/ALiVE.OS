#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskReleaseTaskLocks);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskReleaseTaskLocks

Description:
    Clears `busy = false` on every profile that was locked under a taskID
    in the missionNamespace registry `ALIVE_taskProfileLocks`, then
    removes the taskID from the registry. mil_opcom's TACOM troop
    selection at fnc_OPCOM.sqf:935 gates on `!_busy`, so released
    profiles become available for reassignment again.

    Idempotent: calling on a taskID that was never locked, or calling
    twice (e.g. once from the task-type success branch + once from the
    central task-handler terminal-state hook) is a no-op the second
    time.

Parameters:
    0: STRING - taskID whose locks should be released

Returns:
    SCALAR - count of profiles released (for diagnostics)

Examples:
    (begin example)
    // From a task type's success branch:
    [_taskID] call ALIVE_fnc_taskReleaseTaskLocks;

    // From the central state-transition hook in fnc_taskHandler
    // when state goes Succeeded / Failed / Canceled:
    [_taskID] call ALIVE_fnc_taskReleaseTaskLocks;
    (end)

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_taskID", "", [""]]];

if (_taskID == "") exitWith { 0 };
if (isNil "ALIVE_taskProfileLocks") exitWith { 0 };

private _lockedProfileIDs = ALIVE_taskProfileLocks getOrDefault [_taskID, []];
if (count _lockedProfileIDs == 0) exitWith { 0 };

private _released = 0;
{
    private _profile = [ALiVE_ProfileHandler, "getProfile", _x] call ALiVE_fnc_ProfileHandler;
    if (!isNil "_profile") then {
        [_profile, "busy", false] call ALIVE_fnc_profileEntity;
        _released = _released + 1;
    };
} forEach _lockedProfileIDs;

ALIVE_taskProfileLocks deleteAt _taskID;

_released
