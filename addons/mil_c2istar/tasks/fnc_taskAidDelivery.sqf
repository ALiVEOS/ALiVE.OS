#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
SCRIPT(taskAidDelivery);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskAidDelivery

Description:
Transport humanitarian supplies from a friendly source to a civilian settlement
and supervise final distribution.

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
        [_taskParams, "supportValue", 8] call ALIVE_fnc_hashGet,
        [
            [_taskParams, "clusterID", ""] call ALIVE_fnc_hashGet,
            [_taskParams, "taskType", "AidDelivery"] call ALIVE_fnc_hashGet,
            [_taskParams, "cooldownDuration", 1800] call ALIVE_fnc_hashGet,
            "failure"
        ]
    ] call ALIVE_fnc_taskApplyPopulationEffect;
};

private _updateAidVehicleAbandonment = {
    params ["_taskParams", "_vehicle", "_taskPlayers"];

    private _contactRadius = [_taskParams, "contactRadius", 250] call ALIVE_fnc_hashGet;
    private _closestPlayer = [position _vehicle, _taskPlayers] call ALIVE_fnc_taskGetClosestPlayerToPosition;

    if !(isNull _closestPlayer) then {
        if (_closestPlayer distance2D _vehicle <= _contactRadius) then {
            [_taskParams, "lastVehicleContact", serverTime] call ALIVE_fnc_hashSet;
        };
    };

    (serverTime - ([_taskParams, "lastVehicleContact", serverTime] call ALIVE_fnc_hashGet)) > ([_taskParams, "abandonTimeout", 300] call ALIVE_fnc_hashGet)
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
        private _supportState = _clusterData param [2, []];
        private _clusterCenter = [_cluster, "center", []] call ALIVE_fnc_hashGet;
        private _clusterID = [_cluster, "clusterID", ""] call ALIVE_fnc_hashGet;
        private _supportPhase = "Stabilize";
        if !(_supportState isEqualTo []) then {
            _supportPhase = [_supportState, "phase", "Stabilize"] call ALIVE_fnc_hashGet;
        };
        if (_clusterCenter isEqualTo []) exitWith {["C2ISTAR - Task AidDelivery - Invalid civilian cluster center!"] call ALiVE_fnc_Dump};

        private _sourceCenter = [_taskLocation, _taskLocationType, _taskSide, "MIL", true] call ALIVE_fnc_taskGetSideCluster;
        if (_sourceCenter isEqualTo [] || {(count _sourceCenter > 1) && {(_sourceCenter select 0) > 90000 || {(_sourceCenter select 1) > 90000}}}) then {
            _sourceCenter = [_taskLocation, 50, 1500, 1, 0, 0.25, 0, [], [_taskLocation]] call BIS_fnc_findSafePos;
            if (_sourceCenter isEqualTo []) then {
                _sourceCenter = +_taskLocation;
            };
        };
        _sourceCenter set [2, 0];

        private _sourceContactPosition = [_sourceCenter, 5, 25, 2, 0, 0.25, 0] call BIS_fnc_findSafePos;
        if (_sourceContactPosition isEqualTo []) then {
            _sourceContactPosition = +_sourceCenter;
        };

        private _destinationContactPosition = [_clusterCenter, 5, 25, 2, 0, 0.25, 0] call BIS_fnc_findSafePos;
        if (_destinationContactPosition isEqualTo []) then {
            _destinationContactPosition = +_clusterCenter;
        };

        // Aid van placement (#868 sub-report: vehicles spawning in woods).
        // Route through the unified vehicle spawn validator so the van lands
        // on a road verge with a bbox-aware footprint check, rather than
        // BIS_fnc_findSafePos which doesn't know about roads or vehicle
        // dimensions and routinely placed vans 8-20 m from the contact in
        // dense forest where the player couldn't drive away.
        private _aidVehicleClass = "C_Van_01_box_F";
        private _aidVehicleDir = random 360;
        private _aidVehiclePosition = +_sourceContactPosition;
        private _spawnResult = [_aidVehicleClass, _sourceContactPosition, 80, "road", _aidVehicleDir] call ALiVE_fnc_findVehicleSpawnPosition;
        if (count _spawnResult >= 2) then {
            _aidVehiclePosition = _spawnResult select 0;
            _aidVehicleDir = _spawnResult select 1;
        } else {
            // Validator failed (no road / no flat ground in radius). Fall back
            // to the original findSafePos path so the task still spawns.
            private _safePos = [_sourceContactPosition, 8, 20, 0, 0, 0.4, 0] call BIS_fnc_findSafePos;
            if !(_safePos isEqualTo []) then {
                _aidVehiclePosition = _safePos;
            } else {
                _aidVehiclePosition = [_sourceContactPosition, 10, random 360] call BIS_fnc_relPos;
            };
        };
        _aidVehiclePosition set [2, 0];

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

        private _aidVehicle = createVehicle [_aidVehicleClass, _aidVehiclePosition, [], 0, "NONE"];
        _aidVehicle setPosATL _aidVehiclePosition;
        _aidVehicle setDir _aidVehicleDir;
        _aidVehicle setFuel 1;
        _aidVehicle setDamage 0;
        _aidVehicle setVehicleLock "UNLOCKED";
        clearWeaponCargoGlobal _aidVehicle;
        clearMagazineCargoGlobal _aidVehicle;
        clearItemCargoGlobal _aidVehicle;
        clearBackpackCargoGlobal _aidVehicle;

        private _completionVar = format ["ALIVE_Task_%1_AidDelivered", _taskID];

        private _sourceTown = [_sourceCenter] call ALIVE_fnc_taskGetNearestLocationName;
        if (_sourceTown == "") then {
            _sourceTown = "the friendly depot";
        };

        private _destinationTown = [_clusterCenter] call ALIVE_fnc_taskGetNearestLocationName;
        if (_destinationTown == "") then {
            _destinationTown = "the settlement";
        };

        _aidVehicle setVariable [_completionVar, false, true];
        _aidVehicle setVariable ["ALIVE_Task_AidDeliveryEnabled", false, true];
        _aidVehicle setVariable ["ALIVE_Task_AidSourceTown", _sourceTown, true];
        _aidVehicle setVariable ["ALIVE_Task_AidTown", _destinationTown, true];
        _aidVehicle setVariable ["ALIVE_Task_AidDestination", _destinationContactPosition, true];

        [
            _aidVehicle,
            "Distribute Aid",
            "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unloadVehicle_ca.paa",
            "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unloadVehicle_ca.paa",
            format ["_this distance2D _target < 4 && (_target getVariable ['ALIVE_Task_AidDeliveryEnabled', false]) && !(_target getVariable ['%1', false]) && {_target distance2D (_target getVariable ['ALIVE_Task_AidDestination', [0,0,0]]) < 35}", _completionVar],
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
            10
        ] remoteExec ["BIS_fnc_holdActionAdd", 0, _aidVehicle];

        private _dialogOptions = [ALIVE_generatedTasks, "AidDelivery"] call ALIVE_fnc_hashGet;
        _dialogOptions = _dialogOptions select 1;
        private _dialogOption = +(selectRandom _dialogOptions);

        private _dialog = [_dialogOption, "Parent"] call ALIVE_fnc_hashGet;
        private _taskTitle = format [[_dialog, "title"] call ALIVE_fnc_hashGet, _sourceTown, _destinationTown];
        private _taskDescription = format [[_dialog, "description"] call ALIVE_fnc_hashGet, _sourceTown, _destinationTown];

        private _state = if (_taskCurrent == "Y") then {"Assigned"} else {"Created"};
        private _tasks = [];
        private _taskIDs = [];

        private _taskSource = format ["%1-AidDelivery-Parent", _taskID];
        _tasks pushBack [_taskID, _requestPlayerID, _taskSide, _clusterCenter, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, _state, _taskApplyType, "N", "None", _taskSource, false];
        _taskIDs pushBack _taskID;

        _dialog = [_dialogOption, "Rally"] call ALIVE_fnc_hashGet;
        _taskTitle = format [[_dialog, "title"] call ALIVE_fnc_hashGet, _sourceTown];
        _taskDescription = format [[_dialog, "description"] call ALIVE_fnc_hashGet, _sourceTown];
        private _rallyTaskID = format ["%1_c1", _taskID];
        _taskSource = format ["%1-AidDelivery-Rally", _taskID];
        _tasks pushBack [_rallyTaskID, _requestPlayerID, _taskSide, _sourceContactPosition, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, _state, _taskApplyType, _taskCurrent, _taskID, _taskSource, false];
        _taskIDs pushBack _rallyTaskID;

        _dialog = [_dialogOption, "Move"] call ALIVE_fnc_hashGet;
        _taskTitle = format [[_dialog, "title"] call ALIVE_fnc_hashGet, _destinationTown];
        _taskDescription = format [[_dialog, "description"] call ALIVE_fnc_hashGet, _sourceTown, _destinationTown];
        private _moveTaskID = format ["%1_c2", _taskID];
        _taskSource = format ["%1-AidDelivery-Move", _taskID];
        _tasks pushBack [_moveTaskID, _requestPlayerID, _taskSide, _clusterCenter, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, "Created", _taskApplyType, "N", _taskID, _taskSource, false];
        _taskIDs pushBack _moveTaskID;

        _dialog = [_dialogOption, "Deliver"] call ALIVE_fnc_hashGet;
        _taskTitle = format [[_dialog, "title"] call ALIVE_fnc_hashGet, _destinationTown];
        _taskDescription = format [[_dialog, "description"] call ALIVE_fnc_hashGet, _destinationTown];
        private _deliverTaskID = format ["%1_c3", _taskID];
        _taskSource = format ["%1-AidDelivery-Deliver", _taskID];
        _tasks pushBack [_deliverTaskID, _requestPlayerID, _taskSide, _destinationContactPosition, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, "Created", _taskApplyType, "N", _taskID, _taskSource, true];
        _taskIDs pushBack _deliverTaskID;

        _dialog = [_dialogOption, "Rally"] call ALIVE_fnc_hashGet;
        private _rallyChat = +([_dialog, "chat_start"] call ALIVE_fnc_hashGet);
        private _rallyMessage = +(_rallyChat select 0);
        _rallyMessage set [1, format [_rallyMessage select 1, _sourceTown]];
        _rallyChat set [0, _rallyMessage];
        [_dialog, "chat_start", _rallyChat] call ALIVE_fnc_hashSet;

        private _rallyFailedChat = +([_dialog, "chat_failed"] call ALIVE_fnc_hashGet);
        private _rallyFailedMessage = +(_rallyFailedChat select 0);
        _rallyFailedMessage set [1, format [_rallyFailedMessage select 1, _sourceTown]];
        _rallyFailedChat set [0, _rallyFailedMessage];
        [_dialog, "chat_failed", _rallyFailedChat] call ALIVE_fnc_hashSet;

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
        [_taskParams, "targets", [_aidVehicle]] call ALIVE_fnc_hashSet;
        [_taskParams, "cleanup", [_sourceContact, _destinationContact, _aidVehicle]] call ALIVE_fnc_hashSet;
        [_taskParams, "completionVar", _completionVar] call ALIVE_fnc_hashSet;
        [_taskParams, "supportValue", 8] call ALIVE_fnc_hashSet;
        [_taskParams, "clusterID", _clusterID] call ALIVE_fnc_hashSet;
        [_taskParams, "supportPhase", _supportPhase] call ALIVE_fnc_hashSet;
        [_taskParams, "taskType", "AidDelivery"] call ALIVE_fnc_hashSet;
        [_taskParams, "cooldownDuration", 1800] call ALIVE_fnc_hashSet;
        [_taskParams, "supportEffectPosition", _clusterCenter] call ALIVE_fnc_hashSet;
        [_taskParams, "lastState", ""] call ALIVE_fnc_hashSet;
        [_taskParams, "abandonTimeout", 300] call ALIVE_fnc_hashSet;
        [_taskParams, "contactRadius", 250] call ALIVE_fnc_hashSet;
        [_taskParams, "lastVehicleContact", serverTime] call ALIVE_fnc_hashSet;

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
        private _aidVehicle = _targets param [0, objNull, [objNull]];

        if (_lastState != "Rally") then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "lastState", "Rally"] call ALIVE_fnc_hashSet;
        };

        if (isNull _aidVehicle || {!alive _aidVehicle}) then {
            [_params, "nextTask", ""] call ALIVE_fnc_hashSet;
            _task set [8, "Failed"];
            _task set [10, "N"];
            _result = _task;

            [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
            ["chat_failed", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, _taskPosition, _taskSide] call _applyFailurePopulationEffect;
            [_params] call _cleanupObjects;
        } else {
            private _vehiclePosition = getPosATL _aidVehicle;
            [_vehiclePosition, _taskSide, _taskPlayers, _taskID, "vehicle", "aid vehicle"] call ALIVE_fnc_taskCreateMarkersForPlayers;

            private _closestPlayer = [position _aidVehicle, _taskPlayers] call ALIVE_fnc_taskGetClosestPlayerToPosition;
            private _vehicleSecured = false;
            if !(isNull _closestPlayer) then {
                _vehicleSecured = (vehicle _closestPlayer == _aidVehicle) || {_closestPlayer distance2D _aidVehicle <= 12};
            };

            if (_vehicleSecured) then {
                [_params, "lastVehicleContact", serverTime] call ALIVE_fnc_hashSet;
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
        private _aidVehicle = _targets param [0, objNull, [objNull]];

        if (_lastState != "Move") then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "lastState", "Move"] call ALIVE_fnc_hashSet;
        };

        if (isNull _aidVehicle || {!alive _aidVehicle}) then {
            [_params, "nextTask", ""] call ALIVE_fnc_hashSet;
            _task set [8, "Failed"];
            _task set [10, "N"];
            _result = _task;

            [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
            ["chat_failed", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, _taskPosition, _taskSide] call _applyFailurePopulationEffect;
            [_params] call _cleanupObjects;
        } else {
            [_taskPosition, _taskSide, _taskPlayers, _taskID, "vehicle", "aid destination"] call ALIVE_fnc_taskCreateMarkersForPlayers;

            if ([_params, _aidVehicle, _taskPlayers] call _updateAidVehicleAbandonment) then {
                [_params, "nextTask", ""] call ALIVE_fnc_hashSet;
                _task set [8, "Failed"];
                _task set [10, "N"];
                _result = _task;

                [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
                ["chat_failed", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
                [_params, _taskPosition, _taskSide] call _applyFailurePopulationEffect;
                [_params] call _cleanupObjects;
            } else {
                if (_aidVehicle distance2D _taskPosition <= 60) then {
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
        private _aidVehicle = _targets param [0, objNull, [objNull]];
        private _completionVar = [_params, "completionVar", ""] call ALIVE_fnc_hashGet;

        if (_lastState != "Deliver") then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "lastState", "Deliver"] call ALIVE_fnc_hashSet;
        };

        if (isNull _aidVehicle || {!alive _aidVehicle}) then {
            [_params, "nextTask", ""] call ALIVE_fnc_hashSet;
            _task set [8, "Failed"];
            _task set [10, "N"];
            _result = _task;

            [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
            ["chat_failed", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, _taskPosition, _taskSide] call _applyFailurePopulationEffect;
            [_params] call _cleanupObjects;
        } else {
            _aidVehicle setVariable ["ALIVE_Task_AidDeliveryEnabled", true, true];
            [_taskPosition, _taskSide, _taskPlayers, _taskID, "vehicle", "distribution point"] call ALIVE_fnc_taskCreateMarkersForPlayers;

            if ([_params, _aidVehicle, _taskPlayers] call _updateAidVehicleAbandonment) then {
                [_params, "nextTask", ""] call ALIVE_fnc_hashSet;
                _task set [8, "Failed"];
                _task set [10, "N"];
                _result = _task;

                [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
                ["chat_failed", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
                [_params, _taskPosition, _taskSide] call _applyFailurePopulationEffect;
                [_params] call _cleanupObjects;
            } else {
                if (_aidVehicle getVariable [_completionVar, false]) then {
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
                            [_taskParams, "clusterID", ""] call ALIVE_fnc_hashGet,
                            [_taskParams, "taskType", "AidDelivery"] call ALIVE_fnc_hashGet,
                            [_taskParams, "cooldownDuration", 1800] call ALIVE_fnc_hashGet,
                            "success"
                        ]
                    ] call ALIVE_fnc_taskApplyPopulationEffect;

                    [_params] call _cleanupObjects;
                };
            };
        };
    };
};

_result
