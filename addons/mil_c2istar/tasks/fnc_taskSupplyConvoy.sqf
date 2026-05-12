#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
SCRIPT(taskSupplyConvoy);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskSupplyConvoy

Description:
Escort a humanitarian supply convoy between distant civilian settlements.

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

private _applyFailurePopulationEffect = {
    params ["_taskParams", "_taskPosition", "_taskSide"];

    [
        [_taskParams, "supportEffectPosition", _taskPosition] call ALIVE_fnc_hashGet,
        _taskSide,
        [_taskParams, "supportValue", 12] call ALIVE_fnc_hashGet,
        [
            [_taskParams, "clusterID", ""] call ALIVE_fnc_hashGet,
            [_taskParams, "taskType", "SupplyConvoy"] call ALIVE_fnc_hashGet,
            [_taskParams, "cooldownDuration", 3000] call ALIVE_fnc_hashGet,
            "failure"
        ]
    ] call ALIVE_fnc_taskApplyPopulationEffect;
};


private _updateConvoyAbandonment = {
    params ["_taskParams", "_vehicle", "_taskPlayers"];

    private _contactRadius = [_taskParams, "contactRadius", 250] call ALIVE_fnc_hashGet;
    private _closestPlayer = [position _vehicle, _taskPlayers] call ALIVE_fnc_taskGetClosestPlayerToPosition;

    if !(isNull _closestPlayer) then {
        if (_closestPlayer distance2D _vehicle <= _contactRadius) then {
            [_taskParams, "lastConvoyContact", serverTime] call ALIVE_fnc_hashSet;
        };
    };

    (serverTime - ([_taskParams, "lastConvoyContact", serverTime] call ALIVE_fnc_hashGet)) > ([_taskParams, "abandonTimeout", 300] call ALIVE_fnc_hashGet)
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

        if (_taskID == "") exitWith {["C2ISTAR - Task SupplyConvoy - Wrong input for _taskID!"] call ALiVE_fnc_Dump};
        if (_requestPlayerID == "") exitWith {["C2ISTAR - Task SupplyConvoy - Wrong input for _requestPlayerID!"] call ALiVE_fnc_Dump};
        if (_taskFaction == "") exitWith {["C2ISTAR - Task SupplyConvoy - Wrong input for _taskFaction!"] call ALiVE_fnc_Dump};
        if (_taskLocationType == "") exitWith {["C2ISTAR - Task SupplyConvoy - Wrong input for _taskLocationType!"] call ALiVE_fnc_Dump};
        if (count _taskLocation == 0) exitWith {["C2ISTAR - Task SupplyConvoy - Wrong input for _taskLocation!"] call ALiVE_fnc_Dump};
        if (count _taskPlayers == 0) exitWith {["C2ISTAR - Task SupplyConvoy - Wrong input for _taskPlayers!"] call ALiVE_fnc_Dump};
        if (_taskApplyType == "") exitWith {["C2ISTAR - Task SupplyConvoy - Wrong input for _taskApplyType!"] call ALiVE_fnc_Dump};

        private _sourceClusterData = [_taskLocation, _taskLocationType, _taskSide, 20, 100000, _taskFaction, _tasksCurrent] call ALIVE_fnc_taskGetCivilianCluster;
        if (_sourceClusterData isEqualTo []) exitWith {["C2ISTAR - Task SupplyConvoy - No source civilian settlement found!"] call ALiVE_fnc_Dump};

        private _sourceCluster = _sourceClusterData select 0;
        private _sourceCenter = [_sourceCluster, "center", []] call ALIVE_fnc_hashGet;
        private _sourceClusterID = [_sourceCluster, "clusterID", ""] call ALIVE_fnc_hashGet;
        if (_sourceCenter isEqualTo []) exitWith {["C2ISTAR - Task SupplyConvoy - Invalid source cluster center!"] call ALiVE_fnc_Dump};

        private _destinationClusterData = [_sourceCenter, "Long", _taskSide, 20, 100000, _taskFaction, _tasksCurrent] call ALIVE_fnc_taskGetCivilianCluster;
        if (_destinationClusterData isEqualTo []) then {
            _destinationClusterData = [_taskLocation, "Long", _taskSide, 20, 100000, _taskFaction, _tasksCurrent] call ALIVE_fnc_taskGetCivilianCluster;
        };

        private _destinationCenter = [];
        private _destinationClusterID = "";
        if !(_destinationClusterData isEqualTo []) then {
            private _destinationCluster = _destinationClusterData select 0;
            _destinationCenter = [_destinationCluster, "center", []] call ALIVE_fnc_hashGet;
            _destinationClusterID = [_destinationCluster, "clusterID", ""] call ALIVE_fnc_hashGet;
        };

        private _minDistance = missionNamespace getVariable ["ALIVE_taskMinDistance", 0];
        if (_minDistance <= 0) then {
            _minDistance = 4000 + floor (random 2000);
        };

        if (_destinationCenter isEqualTo [] || {_destinationClusterID == _sourceClusterID} || {_destinationCenter distance2D _sourceCenter < _minDistance}) then {
            _destinationCenter = [_sourceCenter, _minDistance, _minDistance + 4000, 2, 0, 0.25, 0, [], [_sourceCenter]] call BIS_fnc_findSafePos;
            _destinationClusterID = "";
            if (_destinationCenter isEqualTo []) then {
                _destinationCenter = [_sourceCenter, _minDistance, random 360] call BIS_fnc_relPos;
            };
        };
        _destinationCenter set [2, 0];

        private _sourceContactPosition = [_sourceCenter, 5, 25, 2, 0, 0.25, 0] call BIS_fnc_findSafePos;
        if (_sourceContactPosition isEqualTo []) then {
            _sourceContactPosition = +_sourceCenter;
        };

        private _destinationContactPosition = [_destinationCenter, 5, 25, 2, 0, 0.25, 0] call BIS_fnc_findSafePos;
        if (_destinationContactPosition isEqualTo []) then {
            _destinationContactPosition = +_destinationCenter;
        };

        // Convoy van placement (#868 sub-report: vehicles spawning in woods).
        // Route through the unified vehicle spawn validator so the van lands
        // on a road verge with a bbox-aware footprint check, rather than
        // BIS_fnc_findSafePos which doesn't know about roads or vehicle
        // dimensions and routinely placed vans 8-20 m from the contact in
        // dense forest where the player couldn't drive away.
        private _convoyVehicleClass = "C_Van_01_box_F";
        private _convoyDir = random 360;
        private _convoyPosition = +_sourceContactPosition;
        private _spawnResult = [_convoyVehicleClass, _sourceContactPosition, 80, "road", _convoyDir] call ALiVE_fnc_findVehicleSpawnPosition;
        if (count _spawnResult >= 2) then {
            _convoyPosition = _spawnResult select 0;
            _convoyDir = _spawnResult select 1;
        } else {
            // Validator failed (no road / no flat ground in radius). Fall back
            // to the original findSafePos path so the task still spawns.
            private _safePos = [_sourceContactPosition, 8, 20, 0, 0, 0.4, 0] call BIS_fnc_findSafePos;
            if !(_safePos isEqualTo []) then {
                _convoyPosition = _safePos;
            } else {
                _convoyPosition = [_sourceContactPosition, 10, random 360] call BIS_fnc_relPos;
            };
        };
        _convoyPosition set [2, 0];

        private _sourceContactGroup = createGroup [civilian, true];
        private _sourceContact = _sourceContactGroup createUnit [selectRandom ([] call ALiVE_fnc_taskGetCivilianClasses), _sourceContactPosition, [], 0, "NONE"];
        removeAllWeapons _sourceContact;
        _sourceContact disableAI "AUTOTARGET";
        _sourceContact disableAI "TARGET";
        _sourceContact disableAI "FSM";
        _sourceContact disableAI "MOVE";
        _sourceContact allowDamage false;
        _sourceContact setCaptive true;
        _sourceContact setBehaviour "CARELESS";
        _sourceContact setDir random 360;
        _sourceContact setVariable ["ALiVE_advciv_blacklist", true, true];
        _sourceContact setVariable ["ALiVE_advciv_active", false, true];

        private _destinationContactGroup = createGroup [civilian, true];
        private _destinationContact = _destinationContactGroup createUnit [selectRandom ([] call ALiVE_fnc_taskGetCivilianClasses), _destinationContactPosition, [], 0, "NONE"];
        removeAllWeapons _destinationContact;
        _destinationContact disableAI "AUTOTARGET";
        _destinationContact disableAI "TARGET";
        _destinationContact disableAI "FSM";
        _destinationContact disableAI "MOVE";
        _destinationContact allowDamage false;
        _destinationContact setCaptive true;
        _destinationContact setBehaviour "CARELESS";
        _destinationContact setDir random 360;
        _destinationContact setVariable ["ALiVE_advciv_blacklist", true, true];
        _destinationContact setVariable ["ALiVE_advciv_active", false, true];

        private _convoyVehicle = createVehicle [_convoyVehicleClass, _convoyPosition, [], 0, "NONE"];
        _convoyVehicle setPosATL _convoyPosition;
        _convoyVehicle setDir _convoyDir;
        _convoyVehicle setFuel 1;
        _convoyVehicle setDamage 0;
        _convoyVehicle setVehicleLock "UNLOCKED";
        clearWeaponCargoGlobal _convoyVehicle;
        clearMagazineCargoGlobal _convoyVehicle;
        clearItemCargoGlobal _convoyVehicle;
        clearBackpackCargoGlobal _convoyVehicle;

        private _completionVar = format ["ALIVE_Task_%1_ConvoyDelivered", _taskID];

        private _sourceTown = [_sourceCenter] call ALIVE_fnc_taskGetNearestLocationName;
        if (_sourceTown == "") then {
            _sourceTown = "the departure settlement";
        };

        private _destinationTown = [_destinationCenter] call ALIVE_fnc_taskGetNearestLocationName;
        if (_destinationTown == "") then {
            _destinationTown = "the destination settlement";
        };

        _convoyVehicle setVariable [_completionVar, false, true];
        _convoyVehicle setVariable ["ALIVE_Task_ConvoyDeliveryEnabled", false, true];
        _convoyVehicle setVariable ["ALIVE_Task_ConvoySourceTown", _sourceTown, false];
        _convoyVehicle setVariable ["ALIVE_Task_ConvoyDestinationTown", _destinationTown, false];
        _convoyVehicle setVariable ["ALIVE_Task_ConvoyDestination", _destinationCenter, false];

        [
            _convoyVehicle,
            "Unload Supplies",
            "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unloadVehicle_ca.paa",
            "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unloadVehicle_ca.paa",
            format ["_this distance2D _target < 4 && (_target getVariable ['ALIVE_Task_ConvoyDeliveryEnabled', false]) && !(_target getVariable ['%1', false]) && {_target distance2D (_target getVariable ['ALIVE_Task_ConvoyDestination', [0,0,0]]) < 35}", _completionVar],
            "_caller distance2D _target < 4",
            {},
            {},
            {
                params ["_target", "_caller", "", "_arguments"];
                _arguments params ["_completionVar"];

                _target setVariable [_completionVar, true, true];
                ["Task Accomplished", format ["%1 completed the convoy handover in %2.", name _caller, _target getVariable ["ALIVE_Task_ConvoyDestinationTown", "the area"]]] remoteExec ["BIS_fnc_showSubtitle", side (group _caller)];
            },
            {},
            [_completionVar],
            10
        ] remoteExec ["BIS_fnc_holdActionAdd", 0, _convoyVehicle];

        private _dialogOptions = [ALIVE_generatedTasks, "SupplyConvoy"] call ALIVE_fnc_hashGet;
        _dialogOptions = _dialogOptions select 1;
        private _dialogOption = +(selectRandom _dialogOptions);

        private _dialog = [_dialogOption, "Parent"] call ALIVE_fnc_hashGet;
        private _taskTitle = format [[_dialog, "title"] call ALIVE_fnc_hashGet, _sourceTown, _destinationTown];
        private _taskDescription = format [[_dialog, "description"] call ALIVE_fnc_hashGet, _sourceTown, _destinationTown];

        private _state = if (_taskCurrent == "Y") then {"Assigned"} else {"Created"};
        private _tasks = [];
        private _taskIDs = [];

        private _taskSource = format ["%1-SupplyConvoy-Parent", _taskID];
        _tasks pushBack [_taskID, _requestPlayerID, _taskSide, _sourceCenter, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, _state, _taskApplyType, "N", "None", _taskSource, false];
        _taskIDs pushBack _taskID;

        _dialog = [_dialogOption, "Rally"] call ALIVE_fnc_hashGet;
        _taskTitle = format [[_dialog, "title"] call ALIVE_fnc_hashGet, _sourceTown];
        _taskDescription = format [[_dialog, "description"] call ALIVE_fnc_hashGet, _sourceTown];
        private _rallyTaskID = format ["%1_c1", _taskID];
        _taskSource = format ["%1-SupplyConvoy-Rally", _taskID];
        _tasks pushBack [_rallyTaskID, _requestPlayerID, _taskSide, _sourceContactPosition, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, _state, _taskApplyType, _taskCurrent, _taskID, _taskSource, false];
        _taskIDs pushBack _rallyTaskID;

        _dialog = [_dialogOption, "Move"] call ALIVE_fnc_hashGet;
        _taskTitle = format [[_dialog, "title"] call ALIVE_fnc_hashGet, _destinationTown];
        _taskDescription = format [[_dialog, "description"] call ALIVE_fnc_hashGet, _sourceTown, _destinationTown];
        private _moveTaskID = format ["%1_c2", _taskID];
        _taskSource = format ["%1-SupplyConvoy-Move", _taskID];
        _tasks pushBack [_moveTaskID, _requestPlayerID, _taskSide, _destinationCenter, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, "Created", _taskApplyType, "N", _taskID, _taskSource, false];
        _taskIDs pushBack _moveTaskID;

        _dialog = [_dialogOption, "Deliver"] call ALIVE_fnc_hashGet;
        _taskTitle = format [[_dialog, "title"] call ALIVE_fnc_hashGet, _destinationTown];
        _taskDescription = format [[_dialog, "description"] call ALIVE_fnc_hashGet, _destinationTown];
        private _deliverTaskID = format ["%1_c3", _taskID];
        _taskSource = format ["%1-SupplyConvoy-Deliver", _taskID];
        _tasks pushBack [_deliverTaskID, _requestPlayerID, _taskSide, _destinationContactPosition, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, "Created", _taskApplyType, "N", _taskID, _taskSource, true];
        _taskIDs pushBack _deliverTaskID;

        _dialog = [_dialogOption, "Rally"] call ALIVE_fnc_hashGet;
        private _rallyChat = +([_dialog, "chat_start"] call ALIVE_fnc_hashGet);
        private _rallyMessage = +(_rallyChat select 0);
        _rallyMessage set [1, format [_rallyMessage select 1, _sourceTown]];
        _rallyChat set [0, _rallyMessage];
        [_dialog, "chat_start", _rallyChat] call ALIVE_fnc_hashSet;

        _dialog = [_dialogOption, "Move"] call ALIVE_fnc_hashGet;
        private _moveChat = +([_dialog, "chat_start"] call ALIVE_fnc_hashGet);
        private _moveMessage = +(_moveChat select 0);
        _moveMessage set [1, format [_moveMessage select 1, _sourceTown, _destinationTown]];
        _moveChat set [0, _moveMessage];
        [_dialog, "chat_start", _moveChat] call ALIVE_fnc_hashSet;

        private _moveFailedChat = +([_dialog, "chat_failed"] call ALIVE_fnc_hashGet);
        private _moveFailedMessage = +(_moveFailedChat select 0);
        _moveFailedMessage set [1, format [_moveFailedMessage select 1, _destinationTown]];
        _moveFailedChat set [0, _moveFailedMessage];
        [_dialog, "chat_failed", _moveFailedChat] call ALIVE_fnc_hashSet;

        _dialog = [_dialogOption, "Deliver"] call ALIVE_fnc_hashGet;
        private _deliverChat = +([_dialog, "chat_start"] call ALIVE_fnc_hashGet);
        private _deliverMessage = +(_deliverChat select 0);
        _deliverMessage set [1, format [_deliverMessage select 1, _destinationTown]];
        _deliverChat set [0, _deliverMessage];
        [_dialog, "chat_start", _deliverChat] call ALIVE_fnc_hashSet;

        private _deliverSuccessChat = +([_dialog, "chat_success"] call ALIVE_fnc_hashGet);
        private _deliverSuccessMessage = +(_deliverSuccessChat select 0);
        _deliverSuccessMessage set [1, format [_deliverSuccessMessage select 1, _destinationTown]];
        _deliverSuccessChat set [0, _deliverSuccessMessage];
        [_dialog, "chat_success", _deliverSuccessChat] call ALIVE_fnc_hashSet;

        private _deliverFailedChat = +([_dialog, "chat_failed"] call ALIVE_fnc_hashGet);
        private _deliverFailedMessage = +(_deliverFailedChat select 0);
        _deliverFailedMessage set [1, format [_deliverFailedMessage select 1, _destinationTown]];
        _deliverFailedChat set [0, _deliverFailedMessage];
        [_dialog, "chat_failed", _deliverFailedChat] call ALIVE_fnc_hashSet;

        private _taskParams = [] call ALIVE_fnc_hashCreate;
        [_taskParams, "nextTask", _taskIDs select 1] call ALIVE_fnc_hashSet;
        [_taskParams, "taskIDs", _taskIDs] call ALIVE_fnc_hashSet;
        [_taskParams, "dialog", _dialogOption] call ALIVE_fnc_hashSet;
        [_taskParams, "enemyFaction", _taskEnemyFaction] call ALIVE_fnc_hashSet;
        [_taskParams, "targets", [_convoyVehicle]] call ALIVE_fnc_hashSet;
        [_taskParams, "cleanup", [_sourceContact, _destinationContact, _convoyVehicle]] call ALIVE_fnc_hashSet;
        [_taskParams, "completionVar", _completionVar] call ALIVE_fnc_hashSet;
        [_taskParams, "supportValue", 12] call ALIVE_fnc_hashSet;
        [_taskParams, "clusterID", _destinationClusterID] call ALIVE_fnc_hashSet;
        [_taskParams, "sourceClusterID", _sourceClusterID] call ALIVE_fnc_hashSet;
        [_taskParams, "taskType", "SupplyConvoy"] call ALIVE_fnc_hashSet;
        [_taskParams, "cooldownDuration", 3000] call ALIVE_fnc_hashSet;
        [_taskParams, "supportEffectPosition", _destinationCenter] call ALIVE_fnc_hashSet;
        [_taskParams, "lastState", ""] call ALIVE_fnc_hashSet;
        [_taskParams, "abandonTimeout", 300] call ALIVE_fnc_hashSet;
        [_taskParams, "contactRadius", 250] call ALIVE_fnc_hashSet;
        [_taskParams, "lastConvoyContact", serverTime] call ALIVE_fnc_hashSet;

        _result = [_tasks, _taskParams];
    };
    case "Parent": {

    };
    case "Rally": {
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
        private _currentTaskDialog = [_taskDialog, "Rally"] call ALIVE_fnc_hashGet;
        private _targets = [_params, "targets"] call ALIVE_fnc_hashGet;
        private _convoyVehicle = _targets param [0, objNull, [objNull]];

        if (_lastState != "Rally") then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "lastState", "Rally"] call ALIVE_fnc_hashSet;
        };

        if (isNull _convoyVehicle || {!alive _convoyVehicle}) then {
            [_params, "nextTask", ""] call ALIVE_fnc_hashSet;
            _task set [8, "Failed"];
            _task set [10, "N"];
            _result = _task;

            [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
            ["chat_failed", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, _taskPosition, _taskSide] call _applyFailurePopulationEffect;
            [_params] call _cleanupObjects;
        } else {
            [_taskPosition, _taskSide, _taskPlayers, _taskID, "building", "convoy departure"] call ALIVE_fnc_taskCreateMarkersForPlayers;

            if ([_taskPosition, _taskPlayers, 100] call ALIVE_fnc_taskHavePlayersReachedDestination) then {
                [_params, "lastConvoyContact", serverTime] call ALIVE_fnc_hashSet;
                [_params, "nextTask", ([_params, "taskIDs"] call ALIVE_fnc_hashGet) select 2] call ALIVE_fnc_hashSet;

                _task set [8, "Succeeded"];
                _task set [10, "N"];
                _result = _task;

                [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
            };
        };
    };
    case "Move": {
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
        private _currentTaskDialog = [_taskDialog, "Move"] call ALIVE_fnc_hashGet;
        private _targets = [_params, "targets"] call ALIVE_fnc_hashGet;
        private _convoyVehicle = _targets param [0, objNull, [objNull]];

        if (_lastState != "Move") then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "lastState", "Move"] call ALIVE_fnc_hashSet;
        };

        if (isNull _convoyVehicle || {!alive _convoyVehicle}) then {
            [_params, "nextTask", ""] call ALIVE_fnc_hashSet;
            _task set [8, "Failed"];
            _task set [10, "N"];
            _result = _task;

            [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
            ["chat_failed", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, _taskPosition, _taskSide] call _applyFailurePopulationEffect;
            [_params] call _cleanupObjects;
        } else {
            [_taskPosition, _taskSide, _taskPlayers, _taskID, "vehicle", "convoy destination"] call ALIVE_fnc_taskCreateMarkersForPlayers;

            if ([_params, _convoyVehicle, _taskPlayers] call _updateConvoyAbandonment) then {
                [_params, "nextTask", ""] call ALIVE_fnc_hashSet;
                _task set [8, "Failed"];
                _task set [10, "N"];
                _result = _task;

                [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
                ["chat_failed", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, _taskPosition, _taskSide] call _applyFailurePopulationEffect;
                [_params] call _cleanupObjects;
            } else {
                if (_convoyVehicle distance2D _taskPosition <= 60) then {
                    [_params, "nextTask", ([_params, "taskIDs"] call ALIVE_fnc_hashGet) select 3] call ALIVE_fnc_hashSet;

                    _task set [8, "Succeeded"];
                    _task set [10, "N"];
                    _result = _task;

                    [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
                };
            };
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
        private _convoyVehicle = _targets param [0, objNull, [objNull]];
        private _completionVar = [_params, "completionVar", ""] call ALIVE_fnc_hashGet;

        if (_lastState != "Deliver") then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "lastState", "Deliver"] call ALIVE_fnc_hashSet;
        };

        if (isNull _convoyVehicle || {!alive _convoyVehicle}) then {
            [_params, "nextTask", ""] call ALIVE_fnc_hashSet;
            _task set [8, "Failed"];
            _task set [10, "N"];
            _result = _task;

            [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
            ["chat_failed", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, _taskPosition, _taskSide] call _applyFailurePopulationEffect;
            [_params] call _cleanupObjects;
        } else {
            _convoyVehicle setVariable ["ALIVE_Task_ConvoyDeliveryEnabled", true, true];
            [_taskPosition, _taskSide, _taskPlayers, _taskID, "vehicle", "handover point"] call ALIVE_fnc_taskCreateMarkersForPlayers;

            if ([_params, _convoyVehicle, _taskPlayers] call _updateConvoyAbandonment) then {
                [_params, "nextTask", ""] call ALIVE_fnc_hashSet;
                _task set [8, "Failed"];
                _task set [10, "N"];
                _result = _task;

                [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
                ["chat_failed", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, _taskPosition, _taskSide] call _applyFailurePopulationEffect;
                [_params] call _cleanupObjects;
            } else {
                if (_convoyVehicle getVariable [_completionVar, false]) then {
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
                            [_params, "taskType", "SupplyConvoy"] call ALIVE_fnc_hashGet,
                            [_params, "cooldownDuration", 3000] call ALIVE_fnc_hashGet
                        ]
                    ] call ALIVE_fnc_taskApplyPopulationEffect;

                    [_params] call _cleanupObjects;
                };
            };
        };
    };
};

_result
