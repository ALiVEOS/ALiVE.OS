#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskRepairCriticalService);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskRepairCriticalService

Description:
Hearts and Minds repair task.

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

        if (_taskID == "") exitWith {["C2ISTAR - Task RepairCriticalService - Wrong input for _taskID!"] call ALiVE_fnc_Dump};
        if (_requestPlayerID == "") exitWith {["C2ISTAR - Task RepairCriticalService - Wrong input for _requestPlayerID!"] call ALiVE_fnc_Dump};
        if (_taskFaction == "") exitWith {["C2ISTAR - Task RepairCriticalService - Wrong input for _taskFaction!"] call ALiVE_fnc_Dump};
        if (_taskLocationType == "") exitWith {["C2ISTAR - Task RepairCriticalService - Wrong input for _taskLocationType!"] call ALiVE_fnc_Dump};
        if (count _taskLocation == 0) exitWith {["C2ISTAR - Task RepairCriticalService - Wrong input for _taskLocation!"] call ALiVE_fnc_Dump};
        if (count _taskPlayers == 0) exitWith {["C2ISTAR - Task RepairCriticalService - Wrong input for _taskPlayers!"] call ALiVE_fnc_Dump};
        if (_taskApplyType == "") exitWith {["C2ISTAR - Task RepairCriticalService - Wrong input for _taskApplyType!"] call ALiVE_fnc_Dump};

        private _clusterData = [_taskLocation, _taskLocationType, _taskSide, -100000, 25, _taskFaction, _tasksCurrent, false] call ALIVE_fnc_taskGetCivilianCluster;
        if (_clusterData isEqualTo []) exitWith {["C2ISTAR - Task RepairCriticalService - No civilian settlement found!"] call ALiVE_fnc_Dump};

        private _cluster = _clusterData select 0;
        private _supportState = _clusterData param [2, []];
        private _clusterCenter = [_cluster, "center", []] call ALIVE_fnc_hashGet;
        private _clusterID = [_cluster, "clusterID", ""] call ALIVE_fnc_hashGet;
        private _supportPhase = "Stabilize";
        if !(_supportState isEqualTo []) then {
            _supportPhase = [_supportState, "phase", "Stabilize"] call ALIVE_fnc_hashGet;
        };
        if (_clusterCenter isEqualTo []) exitWith {["C2ISTAR - Task RepairCriticalService - Invalid civilian cluster center!"] call ALiVE_fnc_Dump};

        private _nodes = [_cluster, "nodes", []] call ALIVE_fnc_hashGet;
        private _serviceOptions = [
            [missionNamespace getVariable ["ALIVE_civilianPowerBuildingTypes", []], "power node"],
            [missionNamespace getVariable ["ALIVE_civilianFuelBuildingTypes", []], "fuel point"],
            [missionNamespace getVariable ["ALIVE_civilianConstructionBuildingTypes", []], "public works site"],
            [missionNamespace getVariable ["ALIVE_civilianCommsBuildingTypes", []], "communications site"],
            [missionNamespace getVariable ["ALIVE_civilianHQBuildingTypes", []], "municipal building"],
            [missionNamespace getVariable ["ALIVE_civilianPopulationBuildingTypes", []], "public facility"],
            [missionNamespace getVariable ["ALIVE_civilianSettlementBuildingTypes", []], "service point"]
        ];

        private _targetBuilding = objNull;
        private _serviceType = "service point";

        {
            private _types = _x select 0;
            if (count _types > 0) then {
                private _buildings = [_nodes, _types] call ALIVE_fnc_findBuildingsInClusterNodes;
                _buildings = _buildings select {alive _x};

                if (count _buildings > 0) exitWith {
                    _targetBuilding = _buildings select 0;
                    _serviceType = _x select 1;
                };
            };
        } forEach _serviceOptions;

        if (isNull _targetBuilding) then {
            private _fallbackBuildings = nearestObjects [_clusterCenter, ["House", "Building"], 250];
            _fallbackBuildings = _fallbackBuildings select {alive _x};

            if (count _fallbackBuildings > 0) then {
                _targetBuilding = _fallbackBuildings select 0;
            };
        };

        if (isNull _targetBuilding) exitWith {["C2ISTAR - Task RepairCriticalService - No repair target found!"] call ALiVE_fnc_Dump};

        private _targetPosition = getPosATL _targetBuilding;
        private _targetDisplayType = getText (configFile >> "CfgVehicles" >> typeOf _targetBuilding >> "displayName");
        private _nearestTown = [_clusterCenter] call ALIVE_fnc_taskGetNearestLocationName;
        private _completionVar = format ["ALIVE_Task_%1_ServiceRepaired", _taskID];
        if (_nearestTown == "") then {
            _nearestTown = "the settlement";
        };

        _targetBuilding setVariable ["ALIVE_Task_ServiceTown", _nearestTown, false];
        _targetBuilding setVariable [_completionVar, false, true];

        [
            _targetBuilding,
            "Repair Service",
            "\a3\ui_f_oldman\data\IGUI\Cfg\holdactions\repair_ca.paa",
            "\a3\ui_f_oldman\data\IGUI\Cfg\holdactions\repair_ca.paa",
            format ["_this distance2D _target < 4 && !(_target getVariable ['%1', false]) && ('Item_Toolkit' in (items _this + assignedItems _this + backpackItems _this) || 'SPE_ToolKit' in (items _this + assignedItems _this + backpackItems _this) || 'ToolKit' in (items _this + assignedItems _this + backpackItems _this))", _completionVar],
            "_caller distance2D _target < 4",
            {},
            {},
            {
                params ["_target", "_caller", "", "_arguments"];
                _arguments params ["_completionVar"];

                _target setDamage 0;
                _target setVariable [_completionVar, true, true];

                ["Task Accomplished", format ["%1 restored a key service in %2.", name _caller, _target getVariable ["ALIVE_Task_ServiceTown", "the area"]]] remoteExec ["BIS_fnc_showSubtitle", side (group _caller)];
            },
            {},
            [_completionVar],
            ((sizeOf (typeOf _targetBuilding)) max 12) min 25
        ] remoteExec ["BIS_fnc_holdActionAdd", 0, _targetBuilding];

        private _dialogOptions = [ALIVE_generatedTasks, "RepairCriticalService"] call ALIVE_fnc_hashGet;
        _dialogOptions = _dialogOptions select 1;
        private _dialogOption = +(selectRandom _dialogOptions);

        private _dialog = [_dialogOption, "Parent"] call ALIVE_fnc_hashGet;
        private _taskTitle = format [[_dialog, "title"] call ALIVE_fnc_hashGet, _nearestTown];
        private _taskDescription = format [[_dialog, "description"] call ALIVE_fnc_hashGet, _nearestTown, _serviceType];

        private _state = if (_taskCurrent == "Y") then {"Assigned"} else {"Created"};
        private _tasks = [];
        private _taskIDs = [];

        private _taskSource = format ["%1-RepairCriticalService-Parent", _taskID];
        _tasks pushBack [_taskID, _requestPlayerID, _taskSide, _targetPosition, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, _state, _taskApplyType, "N", "None", _taskSource, false];
        _taskIDs pushBack _taskID;

        _dialog = [_dialogOption, "Repair"] call ALIVE_fnc_hashGet;
        _taskTitle = format [[_dialog, "title"] call ALIVE_fnc_hashGet, _serviceType];
        _taskDescription = format [[_dialog, "description"] call ALIVE_fnc_hashGet, _nearestTown, _targetDisplayType, _serviceType];
        private _repairTaskID = format ["%1_c1", _taskID];
        _taskSource = format ["%1-RepairCriticalService-Repair", _taskID];
        _tasks pushBack [_repairTaskID, _requestPlayerID, _taskSide, _targetPosition, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, _state, _taskApplyType, _taskCurrent, _taskID, _taskSource, true];
        _taskIDs pushBack _repairTaskID;

        private _repairChat = +([_dialog, "chat_start"] call ALIVE_fnc_hashGet);
        private _repairMessage = +(_repairChat select 0);
        _repairMessage set [1, format [_repairMessage select 1, _nearestTown, _serviceType]];
        _repairChat set [0, _repairMessage];
        [_dialog, "chat_start", _repairChat] call ALIVE_fnc_hashSet;

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
        [_taskParams, "targets", [_targetBuilding]] call ALIVE_fnc_hashSet;
        [_taskParams, "completionVar", _completionVar] call ALIVE_fnc_hashSet;
        [_taskParams, "supportValue", 12] call ALIVE_fnc_hashSet;
        [_taskParams, "clusterID", _clusterID] call ALIVE_fnc_hashSet;
        [_taskParams, "supportPhase", _supportPhase] call ALIVE_fnc_hashSet;
        [_taskParams, "taskType", "RepairCriticalService"] call ALIVE_fnc_hashSet;
        [_taskParams, "cooldownDuration", 3600] call ALIVE_fnc_hashSet;
        [_taskParams, "lastState", ""] call ALIVE_fnc_hashSet;

        _result = [_tasks, _taskParams];
    };
    case "Parent": {

    };
    case "Repair": {
        _task params [
            "_taskID",
            "",
            "_taskSide",
            "_taskPosition",
            "_taskFaction",
            "_taskTitle",
            "",
            "_taskPlayers"
        ];

        _taskPlayers = _taskPlayers select 0;

        private _lastState = [_params, "lastState"] call ALIVE_fnc_hashGet;
        private _taskDialog = [_params, "dialog"] call ALIVE_fnc_hashGet;
        private _currentTaskDialog = [_taskDialog, "Repair"] call ALIVE_fnc_hashGet;
        private _targets = [_params, "targets"] call ALIVE_fnc_hashGet;
        private _target = _targets param [0, objNull, [objNull]];

        if (_lastState != "Repair") then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "lastState", "Repair"] call ALIVE_fnc_hashSet;
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
                [_params, "supportValue", 12] call ALIVE_fnc_hashGet,
                [
                    [_params, "clusterID", ""] call ALIVE_fnc_hashGet,
                    [_params, "taskType", "RepairCriticalService"] call ALIVE_fnc_hashGet,
                    [_params, "cooldownDuration", 3600] call ALIVE_fnc_hashGet,
                    "failure"
                ]
            ] call ALIVE_fnc_taskApplyPopulationEffect;
        } else {
            [_taskPosition, _taskSide, _taskPlayers, _taskID, "building", "critical service", _taskTitle] call ALIVE_fnc_taskCreateMarkersForPlayers;

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
                    [_params, "supportValue", 12] call ALIVE_fnc_hashGet,
                    [
                        [_params, "clusterID", ""] call ALIVE_fnc_hashGet,
                        [_params, "taskType", "RepairCriticalService"] call ALIVE_fnc_hashGet,
                        [_params, "cooldownDuration", 3600] call ALIVE_fnc_hashGet,
                        "success"
                    ]
                ] call ALIVE_fnc_taskApplyPopulationEffect;
            };
        };
    };
};

_result
