#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
SCRIPT(taskVIPEscort);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskVIPEscort

Description:
Escort a civilian VIP to destination and safely return them.

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
            [_taskParams, "taskType", "VIPEscort"] call ALIVE_fnc_hashGet,
            [_taskParams, "cooldownDuration", 3600] call ALIVE_fnc_hashGet,
            "failure"
        ]
    ] call ALIVE_fnc_taskApplyPopulationEffect;
};


private _getVipEscortPlayers = {
    params ["_vip", "_taskPlayers"];

    private _escortPlayers = _vip getVariable ["ALIVE_Task_VIPEscortPlayers", []];
    private _resolvedEscortPlayers = _escortPlayers select {
        _x != "" && {!(isNull ([_x] call ALIVE_fnc_getPlayerByUID))}
    };

    if !(_resolvedEscortPlayers isEqualTo []) exitWith {_resolvedEscortPlayers};

    _taskPlayers
};

private _updateVipPanicState = {
    params ["_vip", "_taskPlayers"];

    if !(_vip getVariable ["ALIVE_Task_VIPPanicked", false]) exitWith {"ready"};


    private _escortPlayers = [_vip, _taskPlayers] call _getVipEscortPlayers;
    private _closestPlayer = [position _vip, _escortPlayers] call ALIVE_fnc_taskGetClosestPlayerToPosition;
    if !(isNull _closestPlayer) then {
        if (_closestPlayer distance2D _vip < 30) then {
            _vip setVariable ["ALIVE_Task_VIPPanicked", false, true];
            _vip setVariable ["ALIVE_Task_VIPPanicUntil", 0, true];
            [_vip, ""] call ALIVE_fnc_switchMove;
            _vip setBehaviour "AWARE";
            _vip setSpeedMode "FULL";

            if (vehicle _vip == _vip) then {
                [_vip, position _closestPlayer] call ALiVE_fnc_doMoveRemote;
            };
            "ready"
        } else {
            if (serverTime > (_vip getVariable ["ALIVE_Task_VIPPanicUntil", 0])) then {"failed"} else {"active"};
        };
    } else {
        if (serverTime > (_vip getVariable ["ALIVE_Task_VIPPanicUntil", 0])) then {"failed"} else {"active"};
    };
};

// Civilian agents do not reliably transition into player-following from a
// single join/move order, so re-assert the escort state while the task runs.
private _syncVipEscortState = {
    params ["_vip", "_taskPlayers"];

    if (isNull _vip || {!alive _vip}) exitWith {objNull};

    _vip enableAI "MOVE";
    _vip enableAI "FSM";
    _vip enableAI "PATH";
    _vip setUnitPos "AUTO";
    _vip setBehaviour "AWARE";
    _vip setSpeedMode "FULL";

    private _escortPlayers = [_vip, _taskPlayers] call _getVipEscortPlayers;
    private _closestPlayer = [position _vip, _escortPlayers] call ALIVE_fnc_taskGetClosestPlayerToPosition;
    if (isNull _closestPlayer) exitWith {objNull};

    private _closestPlayerGroup = group _closestPlayer;
    if !(isNull _closestPlayerGroup) then {
        if (group _vip != _closestPlayerGroup) then {
            private _previousLeader = leader _closestPlayerGroup;
            [_vip] joinSilent _closestPlayerGroup;
            [_closestPlayerGroup, _previousLeader] remoteExecCall ["selectLeader", groupOwner _closestPlayerGroup];
        };
    };

    private _escortVehicle = vehicle _closestPlayer;
    if (_escortVehicle != _closestPlayer && {alive _escortVehicle}) then {
        if (vehicle _vip == _vip) then {
            if (_vip distance2D _escortVehicle > 12) then {
                [_vip, getPosATL _escortVehicle] call ALiVE_fnc_doMoveRemote;
            } else {
                if (_escortVehicle emptyPositions "cargo" > 0) then {
                    _vip allowGetIn true;
                    _vip assignAsCargo _escortVehicle;
                    [_vip] orderGetIn true;
                };
            };
        };
    } else {
        if (vehicle _vip == _vip && {_vip distance2D _closestPlayer > 4}) then {
            [_vip, getPosATL _closestPlayer] call ALiVE_fnc_doMoveRemote;
        };
    };

    _closestPlayer
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

        if (_taskID == "") exitWith {["C2ISTAR - Task VIPEscort - Wrong input for _taskID!"] call ALiVE_fnc_Dump};
        if (_requestPlayerID == "") exitWith {["C2ISTAR - Task VIPEscort - Wrong input for _requestPlayerID!"] call ALiVE_fnc_Dump};
        if (_taskFaction == "") exitWith {["C2ISTAR - Task VIPEscort - Wrong input for _taskFaction!"] call ALiVE_fnc_Dump};
        if (_taskLocationType == "") exitWith {["C2ISTAR - Task VIPEscort - Wrong input for _taskLocationType!"] call ALiVE_fnc_Dump};
        if (count _taskLocation == 0) exitWith {["C2ISTAR - Task VIPEscort - Wrong input for _taskLocation!"] call ALiVE_fnc_Dump};
        if (count _taskPlayers == 0) exitWith {["C2ISTAR - Task VIPEscort - Wrong input for _taskPlayers!"] call ALiVE_fnc_Dump};
        if (_taskApplyType == "") exitWith {["C2ISTAR - Task VIPEscort - Wrong input for _taskApplyType!"] call ALiVE_fnc_Dump};

        private _sourceClusterData = [_taskLocation, _taskLocationType, _taskSide, 10, 100000, _taskFaction, _tasksCurrent] call ALIVE_fnc_taskGetCivilianCluster;
        if (_sourceClusterData isEqualTo []) exitWith {["C2ISTAR - Task VIPEscort - No source civilian settlement found!"] call ALiVE_fnc_Dump};

        private _sourceCluster = _sourceClusterData select 0;
        private _supportState = _sourceClusterData param [2, []];
        private _sourceCenter = [_sourceCluster, "center", []] call ALIVE_fnc_hashGet;
        private _sourceClusterID = [_sourceCluster, "clusterID", ""] call ALIVE_fnc_hashGet;
        private _supportPhase = "Stabilize";
        if !(_supportState isEqualTo []) then {
            _supportPhase = [_supportState, "phase", "Stabilize"] call ALIVE_fnc_hashGet;
        };

        if (_sourceCenter isEqualTo []) exitWith {["C2ISTAR - Task VIPEscort - Invalid source cluster center!"] call ALiVE_fnc_Dump};

        private _destinationClusterData = [_sourceCenter, "Long", _taskSide, 10, 100000, _taskFaction, _tasksCurrent] call ALIVE_fnc_taskGetCivilianCluster;
        if (_destinationClusterData isEqualTo []) then {
            _destinationClusterData = [_taskLocation, "Long", _taskSide, 10, 100000, _taskFaction, _tasksCurrent] call ALIVE_fnc_taskGetCivilianCluster;
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
            _minDistance = 4000;
        };
        if (_destinationCenter isEqualTo [] || {_destinationCenter distance2D _sourceCenter < (_minDistance max 1200)} || {_destinationClusterID == _sourceClusterID}) then {
            _destinationCenter = [_sourceCenter, (_minDistance max 2000), (_minDistance max 2000) + 5000, 2, 0, 0.25, 0, [], [_sourceCenter]] call BIS_fnc_findSafePos;
            if (_destinationCenter isEqualTo []) then {
                _destinationCenter = [_sourceCenter, (_minDistance max 3000), random 360] call BIS_fnc_relPos;
            };
        };
        _destinationCenter set [2, 0];

        private _vipPosition = [_sourceCenter, 5, 20, 2, 0, 0.25, 0] call BIS_fnc_findSafePos;
        if (_vipPosition isEqualTo []) then {
            _vipPosition = +_sourceCenter;
        };

        private _vipClass = selectRandom ([] call ALiVE_fnc_taskGetCivilianClasses);
        private _vipGroup = createGroup [civilian, true];
        private _vip = _vipGroup createUnit [_vipClass, _vipPosition, [], 0, "NONE"];
        removeAllWeapons _vip;
        _vip disableAI "AUTOTARGET";
        _vip disableAI "TARGET";
        _vip disableAI "FSM";
        _vip disableAI "MOVE";
        _vip setCaptive true;
        _vip setBehaviour "CARELESS";
        _vip setDir random 360;
        _vip setVariable ["ALiVE_advciv_blacklist", true, true];
        _vip setVariable ["ALiVE_advciv_active", false, true];

        _vip setVariable ["ALIVE_Task_VIPPicked", false, true];
        _vip setVariable ["ALIVE_Task_VIPPanicked", false, true];
        _vip setVariable ["ALIVE_Task_VIPPanicUntil", 0, true];
        _vip setVariable ["ALIVE_Task_VIPActivated", false, true];
        _vip setVariable ["ALIVE_Task_VIPEscortPlayers", [], true];
        private _panicTimeout = missionNamespace getVariable ["ALIVE_taskVipPanicTimeout", 180];
        _vip setVariable ["ALIVE_Task_VIPPanicTimeout", (_panicTimeout max 30), false];

        _vip addEventHandler ["FiredNear", {
            params ["_unit"];

            if !(_unit getVariable ["ALIVE_Task_VIPPicked", false]) exitWith {};

            _unit setVariable ["ALIVE_Task_VIPPanicked", true, true];
            _unit setVariable ["ALIVE_Task_VIPPanicUntil", serverTime + (_unit getVariable ["ALIVE_Task_VIPPanicTimeout", 180]), true];

            if (vehicle _unit == _unit) then {
                private _fleePos = [getPosATL _unit, 25, 80, 1, 0, 0.25, 0] call BIS_fnc_findSafePos;
                if !(_fleePos isEqualTo []) then {
                    _unit setUnitPos "MIDDLE";
                    [_unit, _fleePos] call ALiVE_fnc_doMoveRemote;
                };
            };
        }];

        private _sourceTown = [_sourceCenter] call ALIVE_fnc_taskGetNearestLocationName;
        if (_sourceTown == "") then {
            _sourceTown = "the origin settlement";
        };

        private _destinationTown = [_destinationCenter] call ALIVE_fnc_taskGetNearestLocationName;
        if (_destinationTown == "") then {
            _destinationTown = "the destination settlement";
        };

        _vip setVariable ["ALIVE_Task_VIPSourceTown", _sourceTown, false];
        _vip setVariable ["ALIVE_Task_VIPDestinationTown", _destinationTown, false];

        [
            _vip,
            "Secure VIP",
            "\a3\missions_f_oldman\data\img\holdactions\holdAction_follow_start_ca.paa",
            "\a3\missions_f_oldman\data\img\holdactions\holdAction_follow_start_ca.paa",
            "_this distance2D _target < 3 && !(_target getVariable ['ALIVE_Task_VIPPicked', false])",
            "_caller distance2D _target < 3",
            {},
            {},
            {
                params ["_target", "_caller"];

                _target setVariable ["ALIVE_Task_VIPPicked", true, true];
                _target setVariable ["ALIVE_Task_VIPPanicked", false, true];
                _target setVariable ["ALIVE_Task_VIPPanicUntil", 0, true];
                _target setVariable ["ALIVE_Task_VIPActivated", false, true];

                private _escortPlayers = [];
                if !(isNull _caller) then {
                    _escortPlayers = ([(getPlayerUID _caller)] call ALIVE_fnc_getPlayersInGroupDataSource) param [1, []];
                    if (_escortPlayers isEqualTo []) then {
                        private _callerUID = getPlayerUID _caller;
                        if !(_callerUID isEqualTo "") then {
                            _escortPlayers pushBack _callerUID;
                        };
                    };
                };
                _target setVariable ["ALIVE_Task_VIPEscortPlayers", _escortPlayers, true];

                ["Task Update", format ["%1 secured the VIP in %2.", name _caller, _target getVariable ["ALIVE_Task_VIPSourceTown", "the area"]]] remoteExec ["BIS_fnc_showSubtitle", side (group _caller)];
            },
            {},
            [],
            6
        ] remoteExec ["BIS_fnc_holdActionAdd", 0, _vip];

        private _dialogOptions = [ALIVE_generatedTasks, "VIPEscort"] call ALIVE_fnc_hashGet;
        _dialogOptions = _dialogOptions select 1;
        private _dialogOption = +(selectRandom _dialogOptions);

        private _dialog = [_dialogOption, "Parent"] call ALIVE_fnc_hashGet;
        private _taskTitle = format [[_dialog, "title"] call ALIVE_fnc_hashGet, _sourceTown, _destinationTown];
        private _taskDescription = format [[_dialog, "description"] call ALIVE_fnc_hashGet, _sourceTown, _destinationTown];

        private _state = if (_taskCurrent == "Y") then {"Assigned"} else {"Created"};
        private _tasks = [];
        private _taskIDs = [];

        private _taskSource = format ["%1-VIPEscort-Parent", _taskID];
        _tasks pushBack [_taskID, _requestPlayerID, _taskSide, _sourceCenter, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, _state, _taskApplyType, "N", "None", _taskSource, false];
        _taskIDs pushBack _taskID;

        _dialog = [_dialogOption, "Pickup"] call ALIVE_fnc_hashGet;
        _taskTitle = format [[_dialog, "title"] call ALIVE_fnc_hashGet, _sourceTown];
        _taskDescription = format [[_dialog, "description"] call ALIVE_fnc_hashGet, _sourceTown];
        private _pickupTaskID = format ["%1_c1", _taskID];
        _taskSource = format ["%1-VIPEscort-Pickup", _taskID];
        _tasks pushBack [_pickupTaskID, _requestPlayerID, _taskSide, _vipPosition, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, _state, _taskApplyType, _taskCurrent, _taskID, _taskSource, false];
        _taskIDs pushBack _pickupTaskID;

        _dialog = [_dialogOption, "Escort"] call ALIVE_fnc_hashGet;
        _taskTitle = format [[_dialog, "title"] call ALIVE_fnc_hashGet, _destinationTown];
        _taskDescription = format [[_dialog, "description"] call ALIVE_fnc_hashGet, _destinationTown];
        private _escortTaskID = format ["%1_c2", _taskID];
        _taskSource = format ["%1-VIPEscort-Escort", _taskID];
        _tasks pushBack [_escortTaskID, _requestPlayerID, _taskSide, _destinationCenter, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, "Created", _taskApplyType, "N", _taskID, _taskSource, false];
        _taskIDs pushBack _escortTaskID;

        _dialog = [_dialogOption, "Return"] call ALIVE_fnc_hashGet;
        _taskTitle = format [[_dialog, "title"] call ALIVE_fnc_hashGet, _sourceTown];
        _taskDescription = format [[_dialog, "description"] call ALIVE_fnc_hashGet, _sourceTown];
        private _returnTaskID = format ["%1_c3", _taskID];
        _taskSource = format ["%1-VIPEscort-Return", _taskID];
        _tasks pushBack [_returnTaskID, _requestPlayerID, _taskSide, _sourceCenter, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, "Created", _taskApplyType, "N", _taskID, _taskSource, true];
        _taskIDs pushBack _returnTaskID;

        _dialog = [_dialogOption, "Pickup"] call ALIVE_fnc_hashGet;
        private _pickupChat = +([_dialog, "chat_start"] call ALIVE_fnc_hashGet);
        private _pickupMessage = +(_pickupChat select 0);
        _pickupMessage set [1, format [_pickupMessage select 1, _sourceTown]];
        _pickupChat set [0, _pickupMessage];
        [_dialog, "chat_start", _pickupChat] call ALIVE_fnc_hashSet;

        private _pickupFailChat = +([_dialog, "chat_failed"] call ALIVE_fnc_hashGet);
        private _pickupFailMessage = +(_pickupFailChat select 0);
        _pickupFailMessage set [1, format [_pickupFailMessage select 1, _sourceTown]];
        _pickupFailChat set [0, _pickupFailMessage];
        [_dialog, "chat_failed", _pickupFailChat] call ALIVE_fnc_hashSet;

        _dialog = [_dialogOption, "Escort"] call ALIVE_fnc_hashGet;
        private _escortChat = +([_dialog, "chat_start"] call ALIVE_fnc_hashGet);
        private _escortMessage = +(_escortChat select 0);
        _escortMessage set [1, format [_escortMessage select 1, _destinationTown]];
        _escortChat set [0, _escortMessage];
        [_dialog, "chat_start", _escortChat] call ALIVE_fnc_hashSet;

        private _escortFailChat = +([_dialog, "chat_failed"] call ALIVE_fnc_hashGet);
        private _escortFailMessage = +(_escortFailChat select 0);
        _escortFailMessage set [1, format [_escortFailMessage select 1, _destinationTown]];
        _escortFailChat set [0, _escortFailMessage];
        [_dialog, "chat_failed", _escortFailChat] call ALIVE_fnc_hashSet;

        _dialog = [_dialogOption, "Return"] call ALIVE_fnc_hashGet;
        private _returnChat = +([_dialog, "chat_start"] call ALIVE_fnc_hashGet);
        private _returnMessage = +(_returnChat select 0);
        _returnMessage set [1, format [_returnMessage select 1, _sourceTown]];
        _returnChat set [0, _returnMessage];
        [_dialog, "chat_start", _returnChat] call ALIVE_fnc_hashSet;

        private _returnSuccessChat = +([_dialog, "chat_success"] call ALIVE_fnc_hashGet);
        private _returnSuccessMessage = +(_returnSuccessChat select 0);
        _returnSuccessMessage set [1, format [_returnSuccessMessage select 1, _sourceTown]];
        _returnSuccessChat set [0, _returnSuccessMessage];
        [_dialog, "chat_success", _returnSuccessChat] call ALIVE_fnc_hashSet;

        private _returnFailChat = +([_dialog, "chat_failed"] call ALIVE_fnc_hashGet);
        private _returnFailMessage = +(_returnFailChat select 0);
        _returnFailMessage set [1, format [_returnFailMessage select 1, _sourceTown]];
        _returnFailChat set [0, _returnFailMessage];
        [_dialog, "chat_failed", _returnFailChat] call ALIVE_fnc_hashSet;

        private _taskParams = [] call ALIVE_fnc_hashCreate;
        [_taskParams, "nextTask", _taskIDs select 1] call ALIVE_fnc_hashSet;
        [_taskParams, "taskIDs", _taskIDs] call ALIVE_fnc_hashSet;
        [_taskParams, "dialog", _dialogOption] call ALIVE_fnc_hashSet;
        [_taskParams, "enemyFaction", _taskEnemyFaction] call ALIVE_fnc_hashSet;
        [_taskParams, "targets", [_vip]] call ALIVE_fnc_hashSet;
        [_taskParams, "cleanup", [_vip]] call ALIVE_fnc_hashSet;
        [_taskParams, "supportValue", 12] call ALIVE_fnc_hashSet;
        [_taskParams, "clusterID", _sourceClusterID] call ALIVE_fnc_hashSet;
        [_taskParams, "destinationClusterID", _destinationClusterID] call ALIVE_fnc_hashSet;
        [_taskParams, "supportPhase", _supportPhase] call ALIVE_fnc_hashSet;
        [_taskParams, "taskType", "VIPEscort"] call ALIVE_fnc_hashSet;
        [_taskParams, "cooldownDuration", 3600] call ALIVE_fnc_hashSet;
        [_taskParams, "supportEffectPosition", _sourceCenter] call ALIVE_fnc_hashSet;
        [_taskParams, "panicTimeout", (_panicTimeout max 30)] call ALIVE_fnc_hashSet;
        [_taskParams, "lastState", ""] call ALIVE_fnc_hashSet;

        _result = [_tasks, _taskParams];
    };
    case "Parent": {

    };
    case "Pickup": {
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
        private _currentTaskDialog = [_taskDialog, "Pickup"] call ALIVE_fnc_hashGet;
        private _targets = [_params, "targets"] call ALIVE_fnc_hashGet;
        private _vip = _targets param [0, objNull, [objNull]];

        if (_lastState != "Pickup") then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "lastState", "Pickup"] call ALIVE_fnc_hashSet;
        };

        if (isNull _vip || {!alive _vip}) then {
            [_params, "nextTask", ""] call ALIVE_fnc_hashSet;
            _task set [8, "Failed"];
            _task set [10, "N"];
            _result = _task;

            [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
            ["chat_failed", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, _taskPosition, _taskSide] call _applyFailurePopulationEffect;
            [_params] call _cleanupObjects;
        } else {
            [_taskPosition, _taskSide, _taskPlayers, _taskID, "civilian", "VIP"] call ALIVE_fnc_taskCreateMarkersForPlayers;

            if (_vip getVariable ["ALIVE_Task_VIPPicked", false]) then {
                if !(_vip getVariable ["ALIVE_Task_VIPActivated", false]) then {
                    _vip setCaptive false;
                    [_vip, ""] call ALIVE_fnc_switchMove;
                    [_vip, _taskPlayers] call _syncVipEscortState;

                    _vip setVariable ["ALIVE_Task_VIPActivated", true, true];
                } else {
                    [_vip, _taskPlayers] call _syncVipEscortState;
                };

                [_params, "nextTask", ([_params, "taskIDs"] call ALIVE_fnc_hashGet) select 2] call ALIVE_fnc_hashSet;

                _task set [8, "Succeeded"];
                _task set [10, "N"];
                _result = _task;

                [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
            };
        };
    };
    case "Escort": {
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
        private _currentTaskDialog = [_taskDialog, "Escort"] call ALIVE_fnc_hashGet;
        private _targets = [_params, "targets"] call ALIVE_fnc_hashGet;
        private _vip = _targets param [0, objNull, [objNull]];

        if (_lastState != "Escort") then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "lastState", "Escort"] call ALIVE_fnc_hashSet;
        };

        if (isNull _vip || {!alive _vip}) then {
            [_params, "nextTask", ""] call ALIVE_fnc_hashSet;
            _task set [8, "Failed"];
            _task set [10, "N"];
            _result = _task;

            [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
            ["chat_failed", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, _taskPosition, _taskSide] call _applyFailurePopulationEffect;
            [_params] call _cleanupObjects;
        } else {
            [_taskPosition, _taskSide, _taskPlayers, _taskID, "building", "VIP destination"] call ALIVE_fnc_taskCreateMarkersForPlayers;

            private _panicState = [_vip, _taskPlayers] call _updateVipPanicState;
            if (_panicState == "failed") then {
                [_params, "nextTask", ""] call ALIVE_fnc_hashSet;
                _task set [8, "Failed"];
                _task set [10, "N"];
                _result = _task;

                [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
                ["chat_failed", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, _taskPosition, _taskSide] call _applyFailurePopulationEffect;
                [_params] call _cleanupObjects;
            } else {
                if (_panicState == "ready") then {
                    [_vip, _taskPlayers] call _syncVipEscortState;

                    if (_vip distance2D _taskPosition <= 30) then {
                    [_params, "nextTask", ([_params, "taskIDs"] call ALIVE_fnc_hashGet) select 3] call ALIVE_fnc_hashSet;

                    _task set [8, "Succeeded"];
                    _task set [10, "N"];
                    _result = _task;

                    [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
                    };
                };
            };
        };
    };
    case "Return": {
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
        private _currentTaskDialog = [_taskDialog, "Return"] call ALIVE_fnc_hashGet;
        private _targets = [_params, "targets"] call ALIVE_fnc_hashGet;
        private _vip = _targets param [0, objNull, [objNull]];

        if (_lastState != "Return") then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "lastState", "Return"] call ALIVE_fnc_hashSet;
        };

        if (isNull _vip || {!alive _vip}) then {
            [_params, "nextTask", ""] call ALIVE_fnc_hashSet;
            _task set [8, "Failed"];
            _task set [10, "N"];
            _result = _task;

            [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
            ["chat_failed", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, _taskPosition, _taskSide] call _applyFailurePopulationEffect;
            [_params] call _cleanupObjects;
        } else {
            [_taskPosition, _taskSide, _taskPlayers, _taskID, "building", "return point"] call ALIVE_fnc_taskCreateMarkersForPlayers;

            private _panicState = [_vip, _taskPlayers] call _updateVipPanicState;
            if (_panicState == "failed") then {
                [_params, "nextTask", ""] call ALIVE_fnc_hashSet;
                _task set [8, "Failed"];
                _task set [10, "N"];
                _result = _task;

                [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
                ["chat_failed", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, _taskPosition, _taskSide] call _applyFailurePopulationEffect;
                [_params] call _cleanupObjects;
            } else {
                if (_panicState == "ready") then {
                    [_vip, _taskPlayers] call _syncVipEscortState;

                    if (_vip distance2D _taskPosition <= 30) then {
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
                            [_params, "taskType", "VIPEscort"] call ALIVE_fnc_hashGet,
                            [_params, "cooldownDuration", 3600] call ALIVE_fnc_hashGet
                        ]
                    ] call ALIVE_fnc_taskApplyPopulationEffect;

                    [_params] call _cleanupObjects;
                };
            };
        };
        };
    };
};

_result
