#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskRemoveIED);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskRemoveIED

Description:
EOD auto-task. Sends players to dispose of an IED placed by the mil_ied module.
Targets the nearest known IED to the task location (read from the public mil_ied
store, which holds positions even while the device is virtualised/despawned).
Completes when the device is resolved at that spot - either disarmed by a player
(mil_ied flags the object ALiVE_IED_Disarmed) or destroyed/detonated (object
deleted). A player must be near the target for completion to register, so the
task isn't falsely cleared when the IED merely despawns as players move away.

Parameters:
0: STRING - task state ("init" / "Parent" / "Dispose")
1: STRING - task ID
2: ARRAY  - task data (init) or main task array (monitor)
3: ARRAY  - task params hash (monitor)
4: BOOL   - debug

Returns:
ARRAY - init: [tasks, params]; monitor: updated task array

Author:
Jman
---------------------------------------------------------------------------- */

private ["_taskState","_taskID","_task","_params","_debug","_result"];

_taskState = _this select 0;
_taskID = _this select 1;
_task = _this select 2;
_params = _this select 3;
_debug = _this select 4;
_result = [];

// Completion radius around the stored IED position.
#define IED_TASK_RADIUS 60

switch (_taskState) do {
    case "init": {

        private["_requestPlayerID","_taskSide","_taskFaction","_taskLocationType","_taskLocation","_taskPlayers",
        "_taskEnemyFaction","_taskCurrent","_taskApplyType"];

        _taskID            = _task select 0;
        _requestPlayerID   = _task select 1;
        _taskSide          = _task select 2;
        _taskFaction       = _task select 3;
        _taskLocationType  = _task select 5;
        _taskLocation      = _task select 6;
        _taskPlayers       = _task select 7;
        _taskEnemyFaction  = _task select 8;
        _taskCurrent       = _task select 9;
        _taskApplyType     = _task select 10;

        if (_taskID == "") exitWith {["C2ISTAR - Task RemoveIED - Wrong input for _taskID!"] call ALiVE_fnc_Dump};
        if (count _taskLocation == 0) exitWith {["C2ISTAR - Task RemoveIED - Wrong input for _taskLocation!"] call ALiVE_fnc_Dump};
        if (count _taskPlayers == 0) exitWith {["C2ISTAR - Task RemoveIED - Wrong input for _taskPlayers!"] call ALiVE_fnc_Dump};

        // Find the nearest known IED to the task location. The mil_ied store
        // keeps positions even while the device is virtualised, so this works
        // whether or not the IED is currently spawned.
        private _store = missionNamespace getVariable ["ALiVE_MIL_IED_STORE", []];
        if (!(_store isEqualType []) || {count _store < 3}) exitWith {
            ["C2ISTAR - Task RemoveIED - mil_ied store empty / unavailable, no target"] call ALiVE_fnc_Dump;
        };

        private _iedsHash = [_store, "IEDs", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashGet;
        private _townHashes = if (_iedsHash isEqualType [] && {count _iedsHash > 2}) then { _iedsHash select 2 } else { [] };

        private _bestPos = [];
        private _bestDist = 1e10;
        {
            private _townHash = _x;
            if (_townHash isEqualType [] && {count _townHash > 2}) then {
                private _datas = _townHash select 2;
                {
                    private _pos = [_x, "IEDpos", []] call ALiVE_fnc_hashGet;
                    if (_pos isEqualType [] && {count _pos >= 2}) then {
                        private _d = _pos distance2D _taskLocation;
                        if (_d < _bestDist) then {
                            _bestDist = _d;
                            _bestPos = _pos;
                        };
                    };
                } forEach _datas;
            };
        } forEach _townHashes;

        if (_bestPos isEqualTo []) exitWith {
            ["C2ISTAR - Task RemoveIED - no IED positions in store, no target"] call ALiVE_fnc_Dump;
        };

        private _nearestTown = [_bestPos] call ALIVE_fnc_taskGetNearestLocationName;

        // Pull dialog text from the registry (lazy-loaded by staticData).
        private _dialogOptions = [ALIVE_generatedTasks, "RemoveIED"] call ALIVE_fnc_hashGet;
        if (isNil "_dialogOptions") exitWith {
            ["C2ISTAR - Task RemoveIED - dialog registry missing"] call ALiVE_fnc_Dump;
        };
        _dialogOptions = _dialogOptions select 1;
        private _dialogOption = +(selectRandom _dialogOptions);

        // Format placeholders (%1 = nearest location name).
        private _dialog = [_dialogOption, "Parent"] call ALIVE_fnc_hashGet;
        private _formatTitle = [_dialog, "title"] call ALIVE_fnc_hashGet;
        [_dialog, "title", format [_formatTitle, _nearestTown]] call ALIVE_fnc_hashSet;
        private _formatDesc = [_dialog, "description"] call ALIVE_fnc_hashGet;
        [_dialog, "description", format [_formatDesc, _nearestTown]] call ALIVE_fnc_hashSet;

        _dialog = [_dialogOption, "Dispose"] call ALIVE_fnc_hashGet;
        _formatTitle = [_dialog, "title"] call ALIVE_fnc_hashGet;
        [_dialog, "title", format [_formatTitle, _nearestTown]] call ALIVE_fnc_hashSet;
        _formatDesc = [_dialog, "description"] call ALIVE_fnc_hashGet;
        [_dialog, "description", format [_formatDesc, _nearestTown]] call ALIVE_fnc_hashSet;

        // Build the tasks.
        private _state = if (_taskCurrent == "Y") then { "Assigned" } else { "Created" };
        private _tasks = [];
        private _taskIDs = [];

        // Parent
        _dialog = [_dialogOption, "Parent"] call ALIVE_fnc_hashGet;
        private _parentTitle = [_dialog, "title"] call ALIVE_fnc_hashGet;
        private _parentDesc = [_dialog, "description"] call ALIVE_fnc_hashGet;
        private _parentSource = format ["%1-RemoveIED-Parent", _taskID];
        private _parentTask = [_taskID,_requestPlayerID,_taskSide,_bestPos,_taskFaction,_parentTitle,_parentDesc,_taskPlayers,_state,_taskApplyType,"N","None",_parentSource,false];
        _tasks pushBack _parentTask;
        _taskIDs pushBack _taskID;

        // Dispose (child)
        _dialog = [_dialogOption, "Dispose"] call ALIVE_fnc_hashGet;
        private _disposeTitle = [_dialog, "title"] call ALIVE_fnc_hashGet;
        private _disposeDesc = [_dialog, "description"] call ALIVE_fnc_hashGet;
        private _disposeID = format ["%1_c2", _taskID];
        private _disposeSource = format ["%1-RemoveIED-Dispose", _taskID];
        private _disposeTask = [_disposeID,_requestPlayerID,_taskSide,_bestPos,_taskFaction,_disposeTitle,_disposeDesc,_taskPlayers,"Created",_taskApplyType,_taskCurrent,_taskID,_disposeSource,true];
        _tasks pushBack _disposeTask;
        _taskIDs pushBack _disposeID;

        // Params for the monitor.
        private _taskParams = [] call ALIVE_fnc_hashCreate;
        [_taskParams, "nextTask", _taskIDs select 1] call ALIVE_fnc_hashSet;
        [_taskParams, "taskIDs", _taskIDs] call ALIVE_fnc_hashSet;
        [_taskParams, "dialog", _dialogOption] call ALIVE_fnc_hashSet;
        [_taskParams, "targetPos", _bestPos] call ALIVE_fnc_hashSet;
        [_taskParams, "seenArmed", false] call ALIVE_fnc_hashSet;
        [_taskParams, "lastState", ""] call ALIVE_fnc_hashSet;

        _result = [_tasks, _taskParams];
    };

    case "Parent": {
    };

    case "Dispose": {

        private["_requestPlayerID","_taskSide","_taskPosition","_taskFaction","_taskPlayers","_lastState",
        "_taskDialog","_currentTaskDialog","_targetPos","_seenArmed"];

        _taskID          = _task select 0;
        _requestPlayerID = _task select 1;
        _taskSide        = _task select 2;
        _taskPosition    = _task select 3;
        _taskFaction     = _task select 4;
        _taskPlayers     = _task select 7 select 0;

        _lastState         = [_params, "lastState"] call ALIVE_fnc_hashGet;
        _taskDialog        = [_params, "dialog"] call ALIVE_fnc_hashGet;
        _currentTaskDialog = [_taskDialog, _taskState] call ALIVE_fnc_hashGet;
        _targetPos         = [_params, "targetPos", _taskPosition] call ALIVE_fnc_hashGet;
        _seenArmed         = [_params, "seenArmed", false] call ALIVE_fnc_hashGet;

        // Opening radio call, once.
        if (_lastState != "Dispose") then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "lastState", "Dispose"] call ALIVE_fnc_hashSet;
        };

        // Count alive, not-yet-disarmed IED objects near the target. mil_ied
        // tags every placed device with a "town" object variable, and a
        // successful disarm sets ALiVE_IED_Disarmed on it; a detonation deletes
        // the object outright. So "armed" = an ALiVE IED object that is alive
        // and not flagged disarmed.
        private _nearObjects = nearestObjects [_targetPos, [], IED_TASK_RADIUS];
        private _armedNear = _nearObjects select {
            (alive _x)
            && {!isNil {_x getVariable "town"}}
            && {!(_x getVariable ["ALiVE_IED_Disarmed", false])}
        };
        private _armedCount = count _armedNear;

        // Latch once we've actually seen the device spawned at the target, so
        // virtualisation despawn (player walks away -> IED removed) can't be
        // mistaken for resolution.
        if (_armedCount > 0 && {!_seenArmed}) then {
            _seenArmed = true;
            [_params, "seenArmed", true] call ALIVE_fnc_hashSet;
        };

        // A player has to be near the target for completion to count.
        private _playerNear = ({(getPosATL _x) distance2D _targetPos < (IED_TASK_RADIUS + 150)} count allPlayers) > 0;

        if (_seenArmed && _playerNear && {_armedCount == 0}) then {

            [_params, "nextTask", ""] call ALIVE_fnc_hashSet;

            _task set [8, "Succeeded"];
            _task set [10, "N"];
            _result = _task;

            [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
            ["chat_success", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_currentTaskDialog, _taskSide, _taskFaction] call ALIVE_fnc_taskCreateReward;
        };
    };
};

_result
