#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
SCRIPT(taskMeetLocalLeader);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskMeetLocalLeader

Description:
Hearts and Minds leader engagement task.

Author:
Javen
Jman
---------------------------------------------------------------------------- */

params [
    "_taskState",
    "_taskID",
    "_task",
    "_params",
    "_debug"
];

private _result = [];
private _cleanupObjects = {
    params ["_taskParams"];
    {
        if !(isNull _x) then {
            deleteVehicle _x;
        };
    } forEach ([_taskParams, "cleanup", []] call ALIVE_fnc_hashGet);

    [_taskParams, "cleanup", []] call ALIVE_fnc_hashSet;
};

switch (_taskState) do {
    case "init": {
        _task params [
            "_taskID",
            "_requestPlayerID",
            "_taskSide",
            "_taskFaction",
            "",
            "_taskLocationType",
            "_taskLocation",
            "_taskPlayers",
            "_taskEnemyFaction",
            "_taskCurrent",
            "_taskApplyType"
        ];

        private _tasksCurrent = ([ALiVE_TaskHandler, "tasks", ["", [], [], nil]] call ALiVE_fnc_HashGet) select 2;

        if (_taskID == "") exitWith {["C2ISTAR - Task MeetLocalLeader - Wrong input for _taskID!"] call ALiVE_fnc_Dump};
        if (_requestPlayerID == "") exitWith {["C2ISTAR - Task MeetLocalLeader - Wrong input for _requestPlayerID!"] call ALiVE_fnc_Dump};
        if (_taskFaction == "") exitWith {["C2ISTAR - Task MeetLocalLeader - Wrong input for _taskFaction!"] call ALiVE_fnc_Dump};
        if (_taskLocationType == "") exitWith {["C2ISTAR - Task MeetLocalLeader - Wrong input for _taskLocationType!"] call ALiVE_fnc_Dump};
        if (count _taskLocation == 0) exitWith {["C2ISTAR - Task MeetLocalLeader - Wrong input for _taskLocation!"] call ALiVE_fnc_Dump};
        if (count _taskPlayers == 0) exitWith {["C2ISTAR - Task MeetLocalLeader - Wrong input for _taskPlayers!"] call ALiVE_fnc_Dump};
        if (_taskApplyType == "") exitWith {["C2ISTAR - Task MeetLocalLeader - Wrong input for _taskApplyType!"] call ALiVE_fnc_Dump};

        private _clusterData = [_taskLocation, _taskLocationType, _taskSide, 5, 65, _taskFaction, _tasksCurrent, false] call ALIVE_fnc_taskGetCivilianCluster;
        if (_clusterData isEqualTo []) exitWith {["C2ISTAR - Task MeetLocalLeader - No civilian settlement found!"] call ALiVE_fnc_Dump};

        private _cluster = _clusterData select 0;
        private _supportState = _clusterData param [2, []];
        private _clusterCenter = [_cluster, "center", []] call ALIVE_fnc_hashGet;
        private _clusterID = [_cluster, "clusterID", ""] call ALIVE_fnc_hashGet;
        private _supportPhase = "Stabilize";
        if !(_supportState isEqualTo []) then {
            _supportPhase = [_supportState, "phase", "Stabilize"] call ALIVE_fnc_hashGet;
        };
        if (_clusterCenter isEqualTo []) exitWith {["C2ISTAR - Task MeetLocalLeader - Invalid civilian cluster center!"] call ALiVE_fnc_Dump};

        private _leaderPosition = [_clusterCenter, 5, 25, 2, 0, 0.25, 0] call BIS_fnc_findSafePos;
        if (_leaderPosition isEqualTo []) then {
            _leaderPosition = +_clusterCenter;
        };

        private _leaderGroup = createGroup [civilian, true];
        private _leader = _leaderGroup createUnit [selectRandom ([] call ALiVE_fnc_taskGetCivilianClasses), _leaderPosition, [], 0, "NONE"];
        removeAllWeapons _leader;
        _leader disableAI "AUTOTARGET";
        _leader disableAI "TARGET";
        _leader disableAI "FSM";
        _leader disableAI "MOVE";
        _leader allowDamage false;
        _leader setCaptive true;
        _leader setBehaviour "CARELESS";
        _leader setDir random 360;
        _leader setVariable ["ALiVE_advciv_blacklist", true, true];
        _leader setVariable ["ALiVE_advciv_active", false, true];
        private _completionVar = format ["ALIVE_Task_%1_LeaderMet", _taskID];
        _leader setVariable [_completionVar, false, true];

        private _nearestTown = [_clusterCenter] call ALIVE_fnc_taskGetNearestLocationName;
        if (_nearestTown == "") then {
            _nearestTown = "the settlement";
        };

        _leader setVariable ["ALIVE_Task_LeaderTown", _nearestTown, false];

        [
            _leader,
            "Hold Shura",
            "\a3\missions_f_oldman\data\img\holdactions\holdAction_talk_ca.paa",
            "\a3\missions_f_oldman\data\img\holdactions\holdAction_talk_ca.paa",
            format ["_this distance2D _target < 3 && !(_target getVariable ['%1', false])", _completionVar],
            "_caller distance2D _target < 3",
            {},
            {},
            {
                params ["_target", "_caller", "", "_arguments"];
                _arguments params ["_completionVar"];

                _target setVariable [_completionVar, true, true];

                ["Task Accomplished", format ["%1 completed the local leader engagement in %2.", name _caller, _target getVariable ["ALIVE_Task_LeaderTown", "the area"]]] remoteExec ["BIS_fnc_showSubtitle", side (group _caller)];
            },
            {},
            [_completionVar],
            6
        ] remoteExec ["BIS_fnc_holdActionAdd", 0, _leader];

        private _dialogOptions = [ALIVE_generatedTasks, "MeetLocalLeader"] call ALIVE_fnc_hashGet;
        _dialogOptions = _dialogOptions select 1;
        private _dialogOption = +(selectRandom _dialogOptions);

        private _dialog = [_dialogOption, "Parent"] call ALIVE_fnc_hashGet;
        private _taskTitle = format [[_dialog, "title"] call ALIVE_fnc_hashGet, _nearestTown];
        private _taskDescription = format [[_dialog, "description"] call ALIVE_fnc_hashGet, _nearestTown];

        private _state = if (_taskCurrent == "Y") then {"Assigned"} else {"Created"};
        private _tasks = [];
        private _taskIDs = [];

        private _taskSource = format ["%1-MeetLocalLeader-Parent", _taskID];
        _tasks pushBack [_taskID, _requestPlayerID, _taskSide, _leaderPosition, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, _state, _taskApplyType, "N", "None", _taskSource, false];
        _taskIDs pushBack _taskID;

        _dialog = [_dialogOption, "Meet"] call ALIVE_fnc_hashGet;
        _taskTitle = [_dialog, "title"] call ALIVE_fnc_hashGet;
        _taskDescription = format [[_dialog, "description"] call ALIVE_fnc_hashGet, _nearestTown];
        private _meetTaskID = format ["%1_c1", _taskID];
        _taskSource = format ["%1-MeetLocalLeader-Meet", _taskID];
        _tasks pushBack [_meetTaskID, _requestPlayerID, _taskSide, _leaderPosition, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, _state, _taskApplyType, _taskCurrent, _taskID, _taskSource, true];
        _taskIDs pushBack _meetTaskID;

        private _meetChat = +([_dialog, "chat_start"] call ALIVE_fnc_hashGet);
        private _meetMessage = +(_meetChat select 0);
        _meetMessage set [1, format [_meetMessage select 1, _nearestTown]];
        _meetChat set [0, _meetMessage];
        [_dialog, "chat_start", _meetChat] call ALIVE_fnc_hashSet;

        private _successChat = +([_dialog, "chat_success"] call ALIVE_fnc_hashGet);
        private _successMessage = +(_successChat select 0);
        _successMessage set [1, format [_successMessage select 1, _nearestTown]];
        _successChat set [0, _successMessage];
        [_dialog, "chat_success", _successChat] call ALIVE_fnc_hashSet;

        private _failedChat = +([_dialog, "chat_failed"] call ALIVE_fnc_hashGet);
        private _failedMessage = +(_failedChat select 0);
        _failedMessage set [1, format [_failedMessage select 1, _nearestTown]];
        _failedChat set [0, _failedMessage];
        [_dialog, "chat_failed", _failedChat] call ALIVE_fnc_hashSet;

        private _taskParams = [] call ALIVE_fnc_hashCreate;
        [_taskParams, "nextTask", _taskIDs select 1] call ALIVE_fnc_hashSet;
        [_taskParams, "taskIDs", _taskIDs] call ALIVE_fnc_hashSet;
        [_taskParams, "dialog", _dialogOption] call ALIVE_fnc_hashSet;
        [_taskParams, "enemyFaction", _taskEnemyFaction] call ALIVE_fnc_hashSet;
        [_taskParams, "targets", [_leader]] call ALIVE_fnc_hashSet;
        [_taskParams, "cleanup", [_leader]] call ALIVE_fnc_hashSet;
        [_taskParams, "completionVar", _completionVar] call ALIVE_fnc_hashSet;
        [_taskParams, "supportValue", 10] call ALIVE_fnc_hashSet;
        [_taskParams, "clusterID", _clusterID] call ALIVE_fnc_hashSet;
        [_taskParams, "supportPhase", _supportPhase] call ALIVE_fnc_hashSet;
        [_taskParams, "taskType", "MeetLocalLeader"] call ALIVE_fnc_hashSet;
        [_taskParams, "cooldownDuration", 2700] call ALIVE_fnc_hashSet;
        [_taskParams, "lastState", ""] call ALIVE_fnc_hashSet;

        _result = [_tasks, _taskParams];
    };
    case "Parent": {

    };
    case "Meet": {
        _task params [
            "_taskID",
            "",
            "_taskSide",
            "_taskPosition",
            "_taskFaction",
            "",
            "",
            "_taskPlayers"
        ];

        _taskPlayers = _taskPlayers select 0;

        private _lastState = [_params, "lastState"] call ALIVE_fnc_hashGet;
        private _taskDialog = [_params, "dialog"] call ALIVE_fnc_hashGet;
        private _currentTaskDialog = [_taskDialog, "Meet"] call ALIVE_fnc_hashGet;
        private _targets = [_params, "targets"] call ALIVE_fnc_hashGet;
        private _leader = _targets param [0, objNull, [objNull]];

        if (_lastState != "Meet") then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "lastState", "Meet"] call ALIVE_fnc_hashSet;
        };

        if (isNull _leader || {!alive _leader}) then {
            [_params, "nextTask", ""] call ALIVE_fnc_hashSet;
            _task set [8, "Failed"];
            _task set [10, "N"];
            _result = _task;

            [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
            ["chat_failed", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

            [
                _taskPosition,
                _taskSide,
                [_params, "supportValue", 10] call ALIVE_fnc_hashGet,
                [
                    [_params, "clusterID", ""] call ALIVE_fnc_hashGet,
                    [_params, "taskType", "MeetLocalLeader"] call ALIVE_fnc_hashGet,
                    [_params, "cooldownDuration", 2700] call ALIVE_fnc_hashGet,
                    "failure"
                ]
            ] call ALIVE_fnc_taskApplyPopulationEffect;

            [_params] call _cleanupObjects;
        } else {
            [_taskPosition, _taskSide, _taskPlayers, _taskID, "civilian", "Local Leader"] call ALIVE_fnc_taskCreateMarkersForPlayers;

            if (_leader getVariable [([_params, "completionVar", ""] call ALIVE_fnc_hashGet), false]) then {
                [_params, "nextTask", ""] call ALIVE_fnc_hashSet;

                _task set [8, "Succeeded"];
                _task set [10, "N"];
                _result = _task;

                [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;

                ["chat_success", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
                [_currentTaskDialog, _taskSide, _taskFaction] call ALIVE_fnc_taskCreateReward;

                [
                    _taskPosition,
                    _taskSide,
                    [_params, "supportValue", 10] call ALIVE_fnc_hashGet,
                    [
                        [_params, "clusterID", ""] call ALIVE_fnc_hashGet,
                        [_params, "taskType", "MeetLocalLeader"] call ALIVE_fnc_hashGet,
                        [_params, "cooldownDuration", 2700] call ALIVE_fnc_hashGet,
                        "success"
                    ]
                ] call ALIVE_fnc_taskApplyPopulationEffect;

                [_params] call _cleanupObjects;
            };
        };
    };
};

_result
