#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
SCRIPT(taskAidDelivery);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskAidDelivery

Description:
Hearts and Minds aid delivery task.

Author:
OpenAI
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

        if (_taskID == "") exitWith {["C2ISTAR - Task AidDelivery - Wrong input for _taskID!"] call ALiVE_fnc_Dump};
        if (_requestPlayerID == "") exitWith {["C2ISTAR - Task AidDelivery - Wrong input for _requestPlayerID!"] call ALiVE_fnc_Dump};
        if (_taskFaction == "") exitWith {["C2ISTAR - Task AidDelivery - Wrong input for _taskFaction!"] call ALiVE_fnc_Dump};
        if (_taskLocationType == "") exitWith {["C2ISTAR - Task AidDelivery - Wrong input for _taskLocationType!"] call ALiVE_fnc_Dump};
        if (count _taskLocation == 0) exitWith {["C2ISTAR - Task AidDelivery - Wrong input for _taskLocation!"] call ALiVE_fnc_Dump};
        if (count _taskPlayers == 0) exitWith {["C2ISTAR - Task AidDelivery - Wrong input for _taskPlayers!"] call ALiVE_fnc_Dump};
        if (_taskApplyType == "") exitWith {["C2ISTAR - Task AidDelivery - Wrong input for _taskApplyType!"] call ALiVE_fnc_Dump};

        private _clusterData = [_taskLocation, _taskLocationType, _taskSide, 35, 100000, _taskFaction, _tasksCurrent, false] call ALIVE_fnc_taskGetCivilianCluster;
        if (_clusterData isEqualTo []) exitWith {["C2ISTAR - Task AidDelivery - No civilian settlement found!"] call ALiVE_fnc_Dump};

        private _cluster = _clusterData select 0;
        private _supportState = [_clusterData, 2, []] call BIS_fnc_param;
        private _clusterCenter = [_cluster, "center", []] call ALIVE_fnc_hashGet;
        private _clusterID = [_cluster, "clusterID", ""] call ALIVE_fnc_hashGet;
        private _supportPhase = "Stabilize";
        if !(_supportState isEqualTo []) then {
            _supportPhase = [_supportState, "phase", "Stabilize"] call ALIVE_fnc_hashGet;
        };
        if (_clusterCenter isEqualTo []) exitWith {["C2ISTAR - Task AidDelivery - Invalid civilian cluster center!"] call ALiVE_fnc_Dump};

        private _contactPosition = [_clusterCenter, 5, 30, 3, 0, 0.25, 0] call BIS_fnc_findSafePos;
        if (_contactPosition isEqualTo []) then {
            _contactPosition = +_clusterCenter;
        };

        private _cratePosition = [_contactPosition, 4 + random 2, random 360] call BIS_fnc_relPos;
        _cratePosition set [2, 0];

        private _contact = createAgent [selectRandom ["C_man_1", "C_man_polo_1_F", "C_man_polo_2_F", "C_man_shorts_1_F"], _contactPosition, [], 0, "NONE"];
        removeAllWeapons _contact;
        _contact disableAI "AUTOTARGET";
        _contact disableAI "TARGET";
        _contact disableAI "FSM";
        _contact disableAI "MOVE";
        _contact allowDamage false;
        _contact setCaptive true;
        _contact setBehaviour "CARELESS";
        _contact setDir random 360;

        private _aidCrate = createVehicle ["Land_WoodenCrate_01_F", _cratePosition, [], 0, "NONE"];
        _aidCrate setPosATL _cratePosition;
        private _completionVar = format ["ALIVE_Task_%1_AidDelivered", _taskID];

        private _nearestTown = [_clusterCenter] call ALIVE_fnc_taskGetNearestLocationName;
        if (_nearestTown == "") then {
            _nearestTown = "the settlement";
        };

        _aidCrate setVariable ["ALIVE_Task_AidTown", _nearestTown, false];
        _aidCrate setVariable [_completionVar, false, true];

        [
            _aidCrate,
            "Distribute Aid",
            "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa",
            "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa",
            format ["_this distance2D _target < 4 && !(_target getVariable ['%1', false])", _completionVar],
            "_caller distance2D _target < 4",
            {},
            {},
            {
                params ["_target", "_caller", "", "_arguments"];
                _arguments params ["_completionVar"];

                _target setVariable [_completionVar, true, true];

                ["Task Accomplished", format ["%1 distributed relief supplies in %2.", name _caller, _target getVariable ["ALIVE_Task_AidTown", "the area"]]] remoteExec ["BIS_fnc_showSubtitle", side (group _caller)];
            },
            {},
            [_completionVar],
            8
        ] remoteExec ["BIS_fnc_holdActionAdd", 0, _aidCrate];

        private _dialogOptions = [ALIVE_generatedTasks, "AidDelivery"] call ALIVE_fnc_hashGet;
        _dialogOptions = _dialogOptions select 1;
        private _dialogOption = +(selectRandom _dialogOptions);

        private _dialog = [_dialogOption, "Parent"] call ALIVE_fnc_hashGet;
        private _taskTitle = format [[_dialog, "title"] call ALIVE_fnc_hashGet, _nearestTown];
        private _taskDescription = format [[_dialog, "description"] call ALIVE_fnc_hashGet, _nearestTown];

        private _state = if (_taskCurrent == "Y") then {"Assigned"} else {"Created"};
        private _tasks = [];
        private _taskIDs = [];

        private _taskSource = format ["%1-AidDelivery-Parent", _taskID];
        _tasks pushBack [_taskID, _requestPlayerID, _taskSide, _clusterCenter, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, _state, _taskApplyType, "N", "None", _taskSource, false];
        _taskIDs pushBack _taskID;

        _dialog = [_dialogOption, "Travel"] call ALIVE_fnc_hashGet;
        _taskTitle = format [[_dialog, "title"] call ALIVE_fnc_hashGet, _nearestTown];
        _taskDescription = format [[_dialog, "description"] call ALIVE_fnc_hashGet, _nearestTown];
        private _travelTaskID = format ["%1_c1", _taskID];
        _taskSource = format ["%1-AidDelivery-Travel", _taskID];
        _tasks pushBack [_travelTaskID, _requestPlayerID, _taskSide, _contactPosition, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, _state, _taskApplyType, _taskCurrent, _taskID, _taskSource, false];
        _taskIDs pushBack _travelTaskID;

        _dialog = [_dialogOption, "Deliver"] call ALIVE_fnc_hashGet;
        _taskTitle = [_dialog, "title"] call ALIVE_fnc_hashGet;
        _taskDescription = format [[_dialog, "description"] call ALIVE_fnc_hashGet, _nearestTown];
        private _deliverTaskID = format ["%1_c2", _taskID];
        _taskSource = format ["%1-AidDelivery-Deliver", _taskID];
        _tasks pushBack [_deliverTaskID, _requestPlayerID, _taskSide, _cratePosition, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, "Created", _taskApplyType, "N", _taskID, _taskSource, true];
        _taskIDs pushBack _deliverTaskID;

        _dialog = [_dialogOption, "Travel"] call ALIVE_fnc_hashGet;
        private _travelChat = +([_dialog, "chat_start"] call ALIVE_fnc_hashGet);
        private _travelMessage = +(_travelChat select 0);
        _travelMessage set [1, format [_travelMessage select 1, _nearestTown]];
        _travelChat set [0, _travelMessage];
        [_dialog, "chat_start", _travelChat] call ALIVE_fnc_hashSet;

        _dialog = [_dialogOption, "Deliver"] call ALIVE_fnc_hashGet;
        private _deliverChat = +([_dialog, "chat_start"] call ALIVE_fnc_hashGet);
        private _deliverMessage = +(_deliverChat select 0);
        _deliverMessage set [1, format [_deliverMessage select 1, _nearestTown]];
        _deliverChat set [0, _deliverMessage];
        [_dialog, "chat_start", _deliverChat] call ALIVE_fnc_hashSet;

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
        [_taskParams, "targets", [_aidCrate]] call ALIVE_fnc_hashSet;
        [_taskParams, "cleanup", [_contact, _aidCrate]] call ALIVE_fnc_hashSet;
        [_taskParams, "completionVar", _completionVar] call ALIVE_fnc_hashSet;
        [_taskParams, "supportValue", 8] call ALIVE_fnc_hashSet;
        [_taskParams, "clusterID", _clusterID] call ALIVE_fnc_hashSet;
        [_taskParams, "supportPhase", _supportPhase] call ALIVE_fnc_hashSet;
        [_taskParams, "taskType", "AidDelivery"] call ALIVE_fnc_hashSet;
        [_taskParams, "cooldownDuration", 1800] call ALIVE_fnc_hashSet;
        [_taskParams, "lastState", ""] call ALIVE_fnc_hashSet;

        _result = [_tasks, _taskParams];
    };
    case "Parent": {

    };
    case "Travel": {
        _task params [
            "_taskID",
            "",
            "_taskSide",
            "_taskPosition",
            "",
            "",
            "",
            "_taskPlayers"
        ];

        _taskPlayers = _taskPlayers select 0;

        private _lastState = [_params, "lastState"] call ALIVE_fnc_hashGet;
        private _taskDialog = [_params, "dialog"] call ALIVE_fnc_hashGet;
        private _currentTaskDialog = [_taskDialog, "Travel"] call ALIVE_fnc_hashGet;

        if (_lastState != "Travel") then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "lastState", "Travel"] call ALIVE_fnc_hashSet;
        };

        [_taskPosition, _taskSide, _taskPlayers, _taskID, "building", "aid distribution point"] call ALIVE_fnc_taskCreateMarkersForPlayers;

        if ([_taskPosition, _taskPlayers, 150] call ALIVE_fnc_taskHavePlayersReachedDestination) then {
            [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;

            [_params, "nextTask", ([_params, "taskIDs"] call ALIVE_fnc_hashGet) select 2] call ALIVE_fnc_hashSet;

            _task set [8, "Succeeded"];
            _task set [10, "N"];
            _result = _task;
        };
    };
    case "Deliver": {
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
        private _currentTaskDialog = [_taskDialog, "Deliver"] call ALIVE_fnc_hashGet;
        private _targets = [_params, "targets"] call ALIVE_fnc_hashGet;
        private _target = [_targets, 0, objNull, [objNull]] call BIS_fnc_param;

        if (_lastState != "Deliver") then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "lastState", "Deliver"] call ALIVE_fnc_hashSet;
        };

        if (isNull _target || {!alive _target}) then {
            [_params, "nextTask", ""] call ALIVE_fnc_hashSet;
            _task set [8, "Failed"];
            _task set [10, "N"];
            _result = _task;

            [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
            ["chat_failed", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

            [
                _taskPosition,
                _taskSide,
                [_params, "supportValue", 8] call ALIVE_fnc_hashGet,
                [
                    [_params, "clusterID", ""] call ALIVE_fnc_hashGet,
                    [_params, "taskType", "AidDelivery"] call ALIVE_fnc_hashGet,
                    [_params, "cooldownDuration", 1800] call ALIVE_fnc_hashGet,
                    "failure"
                ]
            ] call ALIVE_fnc_taskApplyPopulationEffect;

            [_params] call _cleanupObjects;
        } else {
            [_taskPosition, _taskSide, _taskPlayers, _taskID, "building", "aid supplies"] call ALIVE_fnc_taskCreateMarkersForPlayers;

            if (_target getVariable [([_params, "completionVar", ""] call ALIVE_fnc_hashGet), false]) then {
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
                    [_params, "supportValue", 8] call ALIVE_fnc_hashGet,
                    [
                        [_params, "clusterID", ""] call ALIVE_fnc_hashGet,
                        [_params, "taskType", "AidDelivery"] call ALIVE_fnc_hashGet,
                        [_params, "cooldownDuration", 1800] call ALIVE_fnc_hashGet,
                        "success"
                    ]
                ] call ALIVE_fnc_taskApplyPopulationEffect;

                [_params] call _cleanupObjects;
            };
        };
    };
};

_result
