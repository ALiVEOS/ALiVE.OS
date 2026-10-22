#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskReconObjective);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskReconObjective

Description:
Reconnaissance task (Javen on Discord, 22 Oct): players move to an overwatch position near an objective, then watch it
for a minute from within 600 m. When they have, every enemy group within 500 m of the objective is reported to their
side (ALiVE_reconReports), which an AI Commander with Tasks Only Against Known Enemy counts as seen, so its next
preparation tasks can go after them.

Stages: Parent, Travel (reach the overwatch position), Observe (60 s with a player within 600 m of the objective).

Parameters:
The usual task parameters (see ALIVE_fnc_taskWiretap).

Returns:
The task set on init, the task on a stage change

Author:
Jman
---------------------------------------------------------------------------- */

#define RECON_WATCH_RANGE 600
#define RECON_WATCH_SECONDS 60
#define RECON_REPORT_RADIUS 500

private ["_taskState","_taskID","_task","_params","_debug","_result"];

_taskState = _this select 0;
_taskID = _this select 1;
_task = _this select 2;
_params = _this select 3;
_debug = _this select 4;
_result = [];

switch (_taskState) do {
    case "init": {
        private _taskData = _task;
        _taskID = _taskData select 0;
        private _requestPlayerID = _taskData select 1;
        private _taskSide = _taskData select 2;
        private _taskFaction = _taskData select 3;
        private _taskLocationType = _taskData select 5;
        private _taskLocation = _taskData select 6;
        private _taskPlayers = _taskData select 7;
        private _taskEnemyFaction = _taskData select 8;
        private _taskCurrent = _taskData select 9;
        private _taskApplyType = _taskData select 10;

        if (_taskID == "") exitWith {["C2ISTAR - Task ReconObjective - Wrong input for _taskID!"] call ALiVE_fnc_Dump};
        if (_taskFaction == "") exitWith {["C2ISTAR - Task ReconObjective - Wrong input for _taskFaction!"] call ALiVE_fnc_Dump};
        if (count _taskLocation < 2) exitWith {["C2ISTAR - Task ReconObjective - Wrong input for _taskLocation!"] call ALiVE_fnc_Dump};
        if (count _taskPlayers == 0) exitWith {["C2ISTAR - Task ReconObjective - Wrong input for _taskPlayers!"] call ALiVE_fnc_Dump};
        if (_taskApplyType == "") exitWith {["C2ISTAR - Task ReconObjective - Wrong input for _taskApplyType!"] call ALiVE_fnc_Dump};

        // the objective itself is the target; the overwatch position is on the players' side of it, as an assault's is
        private _targetPosition = +_taskLocation;
        private _playerPos = _taskLocation;
        if (count _taskPlayers > 0 && {count (_taskPlayers select 0) > 0}) then {
            private _uid = (_taskPlayers select 0) select 0;
            if (_uid isEqualType "" && {_uid != ""}) then {
                private _p = [_uid] call ALIVE_fnc_getPlayerByUID;
                if (!isNull _p) then { _playerPos = getPos _p };
            };
        };
        private _stagingPosition = [_targetPosition, "overwatch", _playerPos] call ALIVE_fnc_taskGetSectorPosition;
        if (isNil "_stagingPosition" || {!(_stagingPosition isEqualType [])} || {count _stagingPosition < 2}) then {
            _stagingPosition = _targetPosition getPos [RECON_WATCH_RANGE - 150, _targetPosition getDir _playerPos];
        };

        private _dialogOption = +(selectRandom (([ALIVE_generatedTasks, "ReconObjective"] call ALIVE_fnc_hashGet) select 1));
        private _nearestTown = [_targetPosition] call ALIVE_fnc_taskGetNearestLocationName;
        if (isNil "_nearestTown" || {!(_nearestTown isEqualType "")} || {_nearestTown == ""}) then { _nearestTown = "grid " + mapGridPosition _targetPosition };

        // the place name into each stage's text and its opening radio call
        {
            private _d = [_dialogOption, _x] call ALIVE_fnc_hashGet;
            [_d, "title", format [[_d, "title", ""] call ALIVE_fnc_hashGet, _nearestTown]] call ALIVE_fnc_hashSet;
            [_d, "description", format [[_d, "description", ""] call ALIVE_fnc_hashGet, _nearestTown]] call ALIVE_fnc_hashSet;
            private _chat = [_d, "chat_start", []] call ALIVE_fnc_hashGet;
            if (_chat isNotEqualTo []) then {
                private _m = _chat select 0;
                _m set [1, format [_m select 1, _nearestTown]];
                [_d, "chat_start", _chat] call ALIVE_fnc_hashSet;
            };
        } forEach ["Parent", "Travel", "Observe"];

        private _state = ["Created", "Assigned"] select (_taskCurrent == "Y");
        private _tasks = [];
        private _taskIDs = [];

        private _d = [_dialogOption, "Parent"] call ALIVE_fnc_hashGet;
        _tasks pushBack [_taskID, _requestPlayerID, _taskSide, _targetPosition, _taskFaction, [_d, "title"] call ALIVE_fnc_hashGet, [_d, "description"] call ALIVE_fnc_hashGet,
            _taskPlayers, _state, _taskApplyType, "N", "None", format ["%1-ReconObjective-Parent", _taskID], false];
        _taskIDs pushBack _taskID;

        _d = [_dialogOption, "Travel"] call ALIVE_fnc_hashGet;
        _tasks pushBack [format ["%1_c1", _taskID], _requestPlayerID, _taskSide, _stagingPosition, _taskFaction, [_d, "title"] call ALIVE_fnc_hashGet, [_d, "description"] call ALIVE_fnc_hashGet,
            _taskPlayers, _state, _taskApplyType, _taskCurrent, _taskID, format ["%1-ReconObjective-Travel", _taskID], false];
        _taskIDs pushBack format ["%1_c1", _taskID];

        _d = [_dialogOption, "Observe"] call ALIVE_fnc_hashGet;
        _tasks pushBack [format ["%1_c2", _taskID], _requestPlayerID, _taskSide, _targetPosition, _taskFaction, [_d, "title"] call ALIVE_fnc_hashGet, [_d, "description"] call ALIVE_fnc_hashGet,
            _taskPlayers, "Created", _taskApplyType, "N", _taskID, format ["%1-ReconObjective-Observe", _taskID], true];
        _taskIDs pushBack format ["%1_c2", _taskID];

        private _taskParams = [] call ALIVE_fnc_hashCreate;
        [_taskParams, "nextTask", _taskIDs select 1] call ALIVE_fnc_hashSet;
        [_taskParams, "taskIDs", _taskIDs] call ALIVE_fnc_hashSet;
        [_taskParams, "dialog", _dialogOption] call ALIVE_fnc_hashSet;
        [_taskParams, "enemyFaction", _taskEnemyFaction] call ALIVE_fnc_hashSet;
        [_taskParams, "target", _targetPosition] call ALIVE_fnc_hashSet;
        [_taskParams, "watched", 0] call ALIVE_fnc_hashSet;
        [_taskParams, "lastState", ""] call ALIVE_fnc_hashSet;

        _result = [_tasks, _taskParams];
    };

    case "Parent": {};

    // to the overwatch position
    case "Travel": {
        private _taskSide = _task select 2;
        private _taskPosition = _task select 3;
        private _taskPlayers = _task select 7 select 0;
        private _currentTaskDialog = [[_params, "dialog"] call ALIVE_fnc_hashGet, _taskState] call ALIVE_fnc_hashGet;
        // the opening call once (a shared lastState can't gate two stages, #931)
        if !([_params, "chatStartDone_Travel", false] call ALIVE_fnc_hashGet) then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "chatStartDone_Travel", true] call ALIVE_fnc_hashSet;
        };
        private _target = [_params, "target", _taskPosition] call ALIVE_fnc_hashGet;
        // there, or already close enough to the objective to watch it
        if ([_taskPosition, _taskPlayers, 300] call ALIVE_fnc_taskHavePlayersReachedDestination
            || {[_target, _taskPlayers, RECON_WATCH_RANGE] call ALIVE_fnc_taskHavePlayersReachedDestination}) then {
            [_params, "nextTask", ([_params, "taskIDs"] call ALIVE_fnc_hashGet) select 2] call ALIVE_fnc_hashSet;
            _task set [8, "Succeeded"];
            _task set [10, "N"];
            _result = _task;
        };
    };

    // watch the objective: a minute in all with a player within range of it, then report what is there
    case "Observe": {
        private _taskSide = _task select 2;
        private _taskPosition = _task select 3;
        private _taskFaction = _task select 4;
        private _taskPlayers = _task select 7 select 0;
        private _currentTaskDialog = [[_params, "dialog"] call ALIVE_fnc_hashGet, _taskState] call ALIVE_fnc_hashGet;
        if !([_params, "chatStartDone_Observe", false] call ALIVE_fnc_hashGet) then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "chatStartDone_Observe", true] call ALIVE_fnc_hashSet;
            [_params, "lastTick", time] call ALIVE_fnc_hashSet;
        };
        private _now = time;
        private _dt = (_now - ([_params, "lastTick", _now] call ALIVE_fnc_hashGet)) min 30;
        [_params, "lastTick", _now] call ALIVE_fnc_hashSet;
        if ([_taskPosition, _taskPlayers, RECON_WATCH_RANGE] call ALIVE_fnc_taskHavePlayersReachedDestination) then {
            [_params, "watched", ([_params, "watched", 0] call ALIVE_fnc_hashGet) + _dt] call ALIVE_fnc_hashSet;
        };
        if (([_params, "watched", 0] call ALIVE_fnc_hashGet) >= RECON_WATCH_SECONDS) then {
            // every enemy group round the objective, reported to the side: [side, position, time, group profile ids, group
            // positions, this task's id]. The id is how a commander that asked for the recon knows it has reported: the
            // task's own rows are deleted the moment it finishes
            private _sideObj = [_taskSide] call ALIVE_fnc_sideTextToObject;
            private _ids = [];
            private _pos = [];
            {
                private _theirs = [_x] call ALIVE_fnc_sideTextToObject;
                if ((_sideObj getFriend _theirs) < 0.6) then {
                    {
                        private _id = [_x, "profileID", ""] call ALIVE_fnc_hashGet;
                        if (_id != "") then { _ids pushBack _id; _pos pushBack ([_x, "position", _taskPosition] call ALIVE_fnc_hashGet) };
                    } forEach ([_taskPosition, RECON_REPORT_RADIUS, [_x, "entity"]] call ALIVE_fnc_getNearProfiles);
                };
            } forEach ["EAST", "WEST", "GUER"];
            private _reports = missionNamespace getVariable ["ALiVE_reconReports", []];
            _reports pushBack [_taskSide, +_taskPosition, time, _ids, _pos, _task select 11];
            ALiVE_reconReports = _reports select { time - (_x select 2) < 3600 };
            ["C2ISTAR - Task ReconObjective %1: %2 enemy groups reported round %3", _taskID, count _ids, mapGridPosition _taskPosition] call ALiVE_fnc_Dump;

            [_params, "nextTask", ""] call ALIVE_fnc_hashSet;
            _task set [8, "Succeeded"];
            _task set [10, "N"];
            _result = _task;
            ["chat_success", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_currentTaskDialog, _taskSide, _taskFaction] call ALIVE_fnc_taskCreateReward;
        };
    };
};

_result
