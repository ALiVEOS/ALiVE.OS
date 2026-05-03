#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
SCRIPT(taskSecureCommunityEvent);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskSecureCommunityEvent

Description:
Protect a civilian gathering and its VIP attendees from hostile disruption.

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

private _activateAttendees = {
    params ["_taskParams"];

    {
        if !(isNull _x) then {
            _x setCaptive false;
            _x enableAI "FSM";
            _x setBehaviour "CARELESS";
        };
    } forEach (([_taskParams, "vipTargets", []] call ALIVE_fnc_hashGet) + ([_taskParams, "crowdTargets", []] call ALIVE_fnc_hashGet));
};

private _getEventLosses = {
    params ["_taskParams"];

    private _vipTargets = [_taskParams, "vipTargets", []] call ALIVE_fnc_hashGet;
    private _crowdTargets = [_taskParams, "crowdTargets", []] call ALIVE_fnc_hashGet;

    private _vipLosses = {isNull _x || {!alive _x}} count _vipTargets;
    private _crowdLosses = {isNull _x || {!alive _x}} count _crowdTargets;

    [_vipLosses, _crowdLosses]
};

private _spawnWaveProfiles = {
    params ["_taskPosition", "_enemyFaction", "_currentWave"];

    private _profileIDs = [];
    private _groups = [];
    private _groupCount = (_currentWave max 1) * (1 + floor (random 2));

    for "_i" from 0 to _groupCount - 1 do {
        private _group = ["Infantry", _enemyFaction] call ALIVE_fnc_configGetRandomGroup;
        if !(_group == "FALSE") then {
            _groups pushBack _group;
        };
    };

    _groups = _groups - ALiVE_PLACEMENT_GROUPBLACKLIST;

    private _remotePositions = [_taskPosition, 600, 5, true] call ALIVE_fnc_getPositionDistancePlayers;
    private _remotePosition = if (count _remotePositions > 0) then {
        selectRandom _remotePositions
    } else {
        [_taskPosition, 450, random 360] call BIS_fnc_relPos
    };

    {
        private _spawnPosition = (_remotePosition getPos [random 200, random 360]);
        private _profiles = [_x, _spawnPosition, random 360, true, _enemyFaction, true] call ALIVE_fnc_createProfilesFromGroupConfig;
        if (count _profiles > 0) then {
            private _profileID = _profiles select 0 select 2 select 4;
            private _waypointPosition = (_taskPosition getPos [random 40, random 360]);
            private _profileWaypoint = [_waypointPosition, 100, "MOVE", "FULL", 100, [], "LINE", "NO CHANGE", "SAFE"] call ALIVE_fnc_createProfileWaypoint;
            [(_profiles select 0), "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
            _profileIDs pushBack _profileID;
        };
    } forEach _groups;

    if (random 1 > 0.6) then {
        private _vehicleGroupTypes = ["Motorized", "Mechanized"];
        private _vehicleGroupType = selectRandom _vehicleGroupTypes;
        private _vehicleGroup = [_vehicleGroupType, _enemyFaction] call ALIVE_fnc_configGetRandomGroup;
        if !(_vehicleGroup == "FALSE") then {
            if !(_vehicleGroup in ALiVE_PLACEMENT_GROUPBLACKLIST) then {
                private _spawnPosition = (_remotePosition getPos [random 200, random 360]);
                private _profiles = [_vehicleGroup, _spawnPosition, random 360, true, _enemyFaction, true] call ALIVE_fnc_createProfilesFromGroupConfig;
                if (count _profiles > 0) then {
                    private _profileID = _profiles select 0 select 2 select 4;
                    private _waypointPosition = (_taskPosition getPos [random 40, random 360]);
                    private _profileWaypoint = [_waypointPosition, 100, "MOVE", "FULL", 100, [], "LINE", "NO CHANGE", "SAFE"] call ALIVE_fnc_createProfileWaypoint;
                    [(_profiles select 0), "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                    _profileIDs pushBack _profileID;
                };
            };
        };
    };

    _profileIDs
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

        if (_taskID == "") exitWith {["C2ISTAR - Task SecureCommunityEvent - Wrong input for _taskID!"] call ALiVE_fnc_Dump};
        if (_requestPlayerID == "") exitWith {["C2ISTAR - Task SecureCommunityEvent - Wrong input for _requestPlayerID!"] call ALiVE_fnc_Dump};
        if (_taskFaction == "") exitWith {["C2ISTAR - Task SecureCommunityEvent - Wrong input for _taskFaction!"] call ALiVE_fnc_Dump};
        if (_taskLocationType == "") exitWith {["C2ISTAR - Task SecureCommunityEvent - Wrong input for _taskLocationType!"] call ALiVE_fnc_Dump};
        if (count _taskLocation == 0) exitWith {["C2ISTAR - Task SecureCommunityEvent - Wrong input for _taskLocation!"] call ALiVE_fnc_Dump};
        if (count _taskPlayers == 0) exitWith {["C2ISTAR - Task SecureCommunityEvent - Wrong input for _taskPlayers!"] call ALiVE_fnc_Dump};
        if (_taskApplyType == "") exitWith {["C2ISTAR - Task SecureCommunityEvent - Wrong input for _taskApplyType!"] call ALiVE_fnc_Dump};
        if (_taskEnemyFaction == "") exitWith {["C2ISTAR - Task SecureCommunityEvent - Wrong input for _taskEnemyFaction!"] call ALiVE_fnc_Dump};

        private _clusterData = [_taskLocation, _taskLocationType, _taskSide, 15, 85, _taskFaction, _tasksCurrent] call ALIVE_fnc_taskGetCivilianCluster;
        if (_clusterData isEqualTo []) then {
            _clusterData = [_taskLocation, "Long", _taskSide, 15, 85, _taskFaction, _tasksCurrent] call ALIVE_fnc_taskGetCivilianCluster;
        };
        if (_clusterData isEqualTo []) exitWith {["C2ISTAR - Task SecureCommunityEvent - No civilian settlement found!"] call ALiVE_fnc_Dump};

        private _cluster = _clusterData select 0;
        private _supportState = _clusterData param [2, []];
        private _clusterCenter = [_cluster, "center", []] call ALIVE_fnc_hashGet;
        private _clusterID = [_cluster, "clusterID", ""] call ALIVE_fnc_hashGet;
        private _supportPhase = "Stabilize";
        if !(_supportState isEqualTo []) then {
            _supportPhase = [_supportState, "phase", "Stabilize"] call ALIVE_fnc_hashGet;
        };
        if (_clusterCenter isEqualTo []) exitWith {["C2ISTAR - Task SecureCommunityEvent - Invalid cluster center!"] call ALiVE_fnc_Dump};

        private _minDistance = missionNamespace getVariable ["ALIVE_taskMinDistance", 0];
        if (_minDistance <= 0) then {
            _minDistance = 4000 + floor (random 2000);
        };

        if (_taskLocationType in ["Short", "Medium", "Long"] && {_taskLocation distance2D _clusterCenter < _minDistance}) then {
            private _longClusterData = [_taskLocation, "Long", _taskSide, 15, 85, _taskFaction, _tasksCurrent] call ALIVE_fnc_taskGetCivilianCluster;
            if !(_longClusterData isEqualTo []) then {
                private _longCluster = _longClusterData select 0;
                private _longCenter = [_longCluster, "center", []] call ALIVE_fnc_hashGet;
                if !(_longCenter isEqualTo []) then {
                    _cluster = _longCluster;
                    _clusterCenter = _longCenter;
                    _clusterID = [_longCluster, "clusterID", ""] call ALIVE_fnc_hashGet;
                    _supportState = _longClusterData param [2, []];
                    if !(_supportState isEqualTo []) then {
                        _supportPhase = [_supportState, "phase", "Stabilize"] call ALIVE_fnc_hashGet;
                    };
                };
            };
        };

        private _eventPosition = [_clusterCenter, 10, 40, 2, 0, 0.25, 0] call BIS_fnc_findSafePos;
        if (_eventPosition isEqualTo []) then {
            _eventPosition = +_clusterCenter;
        };
        _eventPosition set [2, 0];

        private _nearestTown = [_clusterCenter] call ALIVE_fnc_taskGetNearestLocationName;
        if (_nearestTown == "") then {
            _nearestTown = "the settlement";
        };

        private _vipUnits = [];
        private _crowdUnits = [];
        private _cleanup = [];
        private _civGroup = createGroup [civilian, true];

        for "_i" from 0 to 1 do {
            private _vipPosition = [_eventPosition, 3 + (random 8), random 360] call BIS_fnc_relPos;
            _vipPosition set [2, 0];
            private _vip = _civGroup createUnit [selectRandom ([] call ALiVE_fnc_taskGetCivilianClasses), _vipPosition, [], 0, "NONE"];
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
            _vipUnits pushBack _vip;
            _cleanup pushBack _vip;
        };

        for "_i" from 0 to 3 do {
            private _crowdPosition = [_eventPosition, 5 + (random 12), random 360] call BIS_fnc_relPos;
            _crowdPosition set [2, 0];
            private _crowdUnit = _civGroup createUnit [selectRandom ([] call ALiVE_fnc_taskGetCivilianClasses), _crowdPosition, [], 0, "NONE"];
            removeAllWeapons _crowdUnit;
            _crowdUnit disableAI "AUTOTARGET";
            _crowdUnit disableAI "TARGET";
            _crowdUnit disableAI "FSM";
            _crowdUnit disableAI "MOVE";
            _crowdUnit setCaptive true;
            _crowdUnit setBehaviour "CARELESS";
            _crowdUnit setDir random 360;
            _crowdUnit setVariable ["ALiVE_advciv_blacklist", true, true];
            _crowdUnit setVariable ["ALiVE_advciv_active", false, true];
            _crowdUnits pushBack _crowdUnit;
            _cleanup pushBack _crowdUnit;
        };

        private _dialogOptions = [ALIVE_generatedTasks, "SecureCommunityEvent"] call ALIVE_fnc_hashGet;
        _dialogOptions = _dialogOptions select 1;
        private _dialogOption = +(selectRandom _dialogOptions);

        private _dialog = [_dialogOption, "Parent"] call ALIVE_fnc_hashGet;
        private _taskTitle = format [[_dialog, "title"] call ALIVE_fnc_hashGet, _nearestTown];
        private _taskDescription = format [[_dialog, "description"] call ALIVE_fnc_hashGet, _nearestTown];

        private _state = if (_taskCurrent == "Y") then {"Assigned"} else {"Created"};
        private _tasks = [];
        private _taskIDs = [];

        private _taskSource = format ["%1-SecureCommunityEvent-Parent", _taskID];
        _tasks pushBack [_taskID, _requestPlayerID, _taskSide, _eventPosition, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, _state, _taskApplyType, "N", "None", _taskSource, false];
        _taskIDs pushBack _taskID;

        _dialog = [_dialogOption, "Setup"] call ALIVE_fnc_hashGet;
        _taskTitle = format [[_dialog, "title"] call ALIVE_fnc_hashGet, _nearestTown];
        _taskDescription = format [[_dialog, "description"] call ALIVE_fnc_hashGet, _nearestTown];
        private _setupTaskID = format ["%1_c1", _taskID];
        _taskSource = format ["%1-SecureCommunityEvent-Setup", _taskID];
        _tasks pushBack [_setupTaskID, _requestPlayerID, _taskSide, _eventPosition, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, _state, _taskApplyType, _taskCurrent, _taskID, _taskSource, false];
        _taskIDs pushBack _setupTaskID;

        _dialog = [_dialogOption, "Secure"] call ALIVE_fnc_hashGet;
        _taskTitle = format [[_dialog, "title"] call ALIVE_fnc_hashGet, _nearestTown];
        _taskDescription = format [[_dialog, "description"] call ALIVE_fnc_hashGet, _nearestTown];
        private _secureTaskID = format ["%1_c2", _taskID];
        _taskSource = format ["%1-SecureCommunityEvent-Secure", _taskID];
        _tasks pushBack [_secureTaskID, _requestPlayerID, _taskSide, _eventPosition, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, "Created", _taskApplyType, "N", _taskID, _taskSource, true];
        _taskIDs pushBack _secureTaskID;

        _dialog = [_dialogOption, "Setup"] call ALIVE_fnc_hashGet;
        private _setupChat = +([_dialog, "chat_start"] call ALIVE_fnc_hashGet);
        private _setupMessage = +(_setupChat select 0);
        _setupMessage set [1, format [_setupMessage select 1, _nearestTown]];
        _setupChat set [0, _setupMessage];
        [_dialog, "chat_start", _setupChat] call ALIVE_fnc_hashSet;

        _dialog = [_dialogOption, "Secure"] call ALIVE_fnc_hashGet;
        private _secureChat = +([_dialog, "chat_start"] call ALIVE_fnc_hashGet);
        private _secureMessage = +(_secureChat select 0);
        _secureMessage set [1, format [_secureMessage select 1, _nearestTown]];
        _secureChat set [0, _secureMessage];
        [_dialog, "chat_start", _secureChat] call ALIVE_fnc_hashSet;

        private _secureSuccessChat = +([_dialog, "chat_success"] call ALIVE_fnc_hashGet);
        private _secureSuccessMessage = +(_secureSuccessChat select 0);
        _secureSuccessMessage set [1, format [_secureSuccessMessage select 1, _nearestTown]];
        _secureSuccessChat set [0, _secureSuccessMessage];
        [_dialog, "chat_success", _secureSuccessChat] call ALIVE_fnc_hashSet;

        private _secureFailedChat = +([_dialog, "chat_failed"] call ALIVE_fnc_hashGet);
        private _secureFailedMessage = +(_secureFailedChat select 0);
        _secureFailedMessage set [1, format [_secureFailedMessage select 1, _nearestTown]];
        _secureFailedChat set [0, _secureFailedMessage];
        [_dialog, "chat_failed", _secureFailedChat] call ALIVE_fnc_hashSet;

        private _taskParams = [] call ALIVE_fnc_hashCreate;
        [_taskParams, "nextTask", _taskIDs select 1] call ALIVE_fnc_hashSet;
        [_taskParams, "taskIDs", _taskIDs] call ALIVE_fnc_hashSet;
        [_taskParams, "dialog", _dialogOption] call ALIVE_fnc_hashSet;
        [_taskParams, "enemyFaction", _taskEnemyFaction] call ALIVE_fnc_hashSet;
        [_taskParams, "cleanup", _cleanup] call ALIVE_fnc_hashSet;
        [_taskParams, "vipTargets", _vipUnits] call ALIVE_fnc_hashSet;
        [_taskParams, "crowdTargets", _crowdUnits] call ALIVE_fnc_hashSet;
        [_taskParams, "supportValue", 14] call ALIVE_fnc_hashSet;
        [_taskParams, "failureSupportValue", -8] call ALIVE_fnc_hashSet;
        [_taskParams, "clusterID", _clusterID] call ALIVE_fnc_hashSet;
        [_taskParams, "supportPhase", _supportPhase] call ALIVE_fnc_hashSet;
        [_taskParams, "taskType", "SecureCommunityEvent"] call ALIVE_fnc_hashSet;
        [_taskParams, "cooldownDuration", 3600] call ALIVE_fnc_hashSet;
        [_taskParams, "lastState", ""] call ALIVE_fnc_hashSet;
        [_taskParams, "siteActive", false] call ALIVE_fnc_hashSet;
        [_taskParams, "holdUntil", 0] call ALIVE_fnc_hashSet;
        [_taskParams, "forceCompleteAt", 0] call ALIVE_fnc_hashSet;
        [_taskParams, "currentWave", 1] call ALIVE_fnc_hashSet;
        [_taskParams, "lastWave", 0] call ALIVE_fnc_hashSet;
        [_taskParams, "totalWaves", 2 + floor (random 2)] call ALIVE_fnc_hashSet;
        [_taskParams, "nextWaveAt", 0] call ALIVE_fnc_hashSet;
        [_taskParams, "entityProfileIDs", []] call ALIVE_fnc_hashSet;
        [_taskParams, "maxCivilianLosses", 1] call ALIVE_fnc_hashSet;

        _result = [_tasks, _taskParams];
    };
    case "Parent": {

    };
    case "Setup": {
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
        private _currentTaskDialog = [_taskDialog, "Setup"] call ALIVE_fnc_hashGet;
        private _losses = [_params] call _getEventLosses;

        if (_lastState != "Setup") then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "lastState", "Setup"] call ALIVE_fnc_hashSet;
        };

        if ((_losses select 0) > 0) then {
            [_params, "nextTask", ""] call ALIVE_fnc_hashSet;
            _task set [8, "Failed"];
            _task set [10, "N"];
            _result = _task;

            [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
            ["chat_failed", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

            [
                _taskPosition,
                _taskSide,
                [_params, "failureSupportValue", -8] call ALIVE_fnc_hashGet,
                [
                    [_params, "clusterID", ""] call ALIVE_fnc_hashGet,
                    [_params, "taskType", "SecureCommunityEvent"] call ALIVE_fnc_hashGet,
                    [_params, "cooldownDuration", 3600] call ALIVE_fnc_hashGet
                ]
            ] call ALIVE_fnc_taskApplyPopulationEffect;

            [_params] call _cleanupObjects;
        } else {
            [_taskPosition, _taskSide, _taskPlayers, _taskID, "building", "event location"] call ALIVE_fnc_taskCreateMarkersForPlayers;

            if ([_taskPosition, _taskPlayers, 120] call ALIVE_fnc_taskHavePlayersReachedDestination) then {
                [_params] call _activateAttendees;
                [_params, "siteActive", true] call ALIVE_fnc_hashSet;
                [_params, "holdUntil", serverTime + 540] call ALIVE_fnc_hashSet;
                [_params, "forceCompleteAt", serverTime + 1140] call ALIVE_fnc_hashSet;
                [_params, "nextWaveAt", serverTime + 30] call ALIVE_fnc_hashSet;
                [_params, "nextTask", ([_params, "taskIDs"] call ALIVE_fnc_hashGet) select 2] call ALIVE_fnc_hashSet;

                _task set [8, "Succeeded"];
                _task set [10, "N"];
                _result = _task;

                [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
            };
        };
    };
    case "Secure": {
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
        private _currentTaskDialog = [_taskDialog, "Secure"] call ALIVE_fnc_hashGet;
        private _holdUntil = [_params, "holdUntil", 0] call ALIVE_fnc_hashGet;
        private _forceCompleteAt = [_params, "forceCompleteAt", 0] call ALIVE_fnc_hashGet;
        private _currentWave = [_params, "currentWave", 1] call ALIVE_fnc_hashGet;
        private _lastWave = [_params, "lastWave", 0] call ALIVE_fnc_hashGet;
        private _totalWaves = [_params, "totalWaves", 2] call ALIVE_fnc_hashGet;
        private _nextWaveAt = [_params, "nextWaveAt", 0] call ALIVE_fnc_hashGet;
        private _enemyFaction = [_params, "enemyFaction", ""] call ALIVE_fnc_hashGet;
        private _entityProfileIDs = [_params, "entityProfileIDs", []] call ALIVE_fnc_hashGet;
        private _losses = [_params] call _getEventLosses;
        private _vipLosses = _losses select 0;
        private _crowdLosses = _losses select 1;

        if (_lastState != "Secure") then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "lastState", "Secure"] call ALIVE_fnc_hashSet;
        };

        [_taskPosition, _taskSide, _taskPlayers, _taskID, "building", "community event"] call ALIVE_fnc_taskCreateMarkersForPlayers;

        if (_vipLosses > 0 || {_crowdLosses > ([_params, "maxCivilianLosses", 1] call ALIVE_fnc_hashGet)}) then {
            [_params, "nextTask", ""] call ALIVE_fnc_hashSet;
            _task set [8, "Failed"];
            _task set [10, "N"];
            _result = _task;

            [_taskPlayers, _taskID] call ALIVE_fnc_taskDeleteMarkersForPlayers;
            ["chat_failed", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;

            [
                _taskPosition,
                _taskSide,
                [_params, "failureSupportValue", -8] call ALIVE_fnc_hashGet,
                [
                    [_params, "clusterID", ""] call ALIVE_fnc_hashGet,
                    [_params, "taskType", "SecureCommunityEvent"] call ALIVE_fnc_hashGet,
                    [_params, "cooldownDuration", 3600] call ALIVE_fnc_hashGet
                ]
            ] call ALIVE_fnc_taskApplyPopulationEffect;

            [_params] call _cleanupObjects;
        } else {
            if (_currentWave <= _totalWaves && {serverTime >= _nextWaveAt} && {_entityProfileIDs isEqualTo []}) then {
                private _waveProfileIDs = [_taskPosition, _enemyFaction, _currentWave] call _spawnWaveProfiles;
                if (_waveProfileIDs isEqualTo []) then {
                    if (_currentWave < _totalWaves) then {
                        [_params, "currentWave", _currentWave + 1] call ALIVE_fnc_hashSet;
                        [_params, "nextWaveAt", serverTime + 1] call ALIVE_fnc_hashSet;
                    } else {
                        [_params, "currentWave", _totalWaves + 1] call ALIVE_fnc_hashSet;
                        [_params, "nextWaveAt", 0] call ALIVE_fnc_hashSet;
                    };
                } else {
                    [_params, "entityProfileIDs", _waveProfileIDs] call ALIVE_fnc_hashSet;
                    [_params, "lastWave", _currentWave] call ALIVE_fnc_hashSet;
                    _entityProfileIDs = _waveProfileIDs;
                    _lastWave = _currentWave;
                };
            };

            if !(_entityProfileIDs isEqualTo []) then {
                private _entitiesState = [_entityProfileIDs] call ALIVE_fnc_taskGetStateOfEntityProfiles;
                private _allDestroyed = [_entitiesState, "allDestroyed"] call ALIVE_fnc_hashGet;

                if (_allDestroyed) then {
                    [_params, "entityProfileIDs", []] call ALIVE_fnc_hashSet;
                    if (_currentWave < _totalWaves) then {
                        [_params, "currentWave", _currentWave + 1] call ALIVE_fnc_hashSet;
                        [_params, "nextWaveAt", serverTime + 75] call ALIVE_fnc_hashSet;
                    } else {
                        [_params, "currentWave", _totalWaves + 1] call ALIVE_fnc_hashSet;
                        [_params, "nextWaveAt", 0] call ALIVE_fnc_hashSet;
                    };
                };
            };

            _currentWave = [_params, "currentWave", _currentWave] call ALIVE_fnc_hashGet;
            _entityProfileIDs = [_params, "entityProfileIDs", []] call ALIVE_fnc_hashGet;

            if (_forceCompleteAt <= 0 && {_holdUntil > 0}) then {
                _forceCompleteAt = _holdUntil + 600;
                [_params, "forceCompleteAt", _forceCompleteAt] call ALIVE_fnc_hashSet;
            };

            private _areaClear = [_taskPosition, _taskPlayers, _taskSide, 250] call ALIVE_fnc_taskIsAreaClearOfEnemies;
            private _staleWave = !(_entityProfileIDs isEqualTo []) && {serverTime >= _holdUntil} && {_forceCompleteAt > 0} && {serverTime >= _forceCompleteAt};

            if (_staleWave) then {
                private _playersNear = [_taskPosition, _taskPlayers, 1000] call ALIVE_fnc_taskHavePlayersReachedDestination;
                private _realAreaClear = _playersNear && {!([_taskPosition, _taskSide, 250, false] call ALIVE_fnc_isEnemyNear)};

                if (_areaClear || {_realAreaClear}) then {
                    [_entityProfileIDs] call ALIVE_fnc_taskDestroyEntityProfiles;
                    [_params, "entityProfileIDs", []] call ALIVE_fnc_hashSet;
                    [_params, "currentWave", _totalWaves + 1] call ALIVE_fnc_hashSet;
                    [_params, "nextWaveAt", 0] call ALIVE_fnc_hashSet;
                    _currentWave = _totalWaves + 1;
                    _entityProfileIDs = [];
                    _areaClear = [_taskPosition, _taskPlayers, _taskSide, 250] call ALIVE_fnc_taskIsAreaClearOfEnemies;
                };
            };

            if (_currentWave > _totalWaves && {_entityProfileIDs isEqualTo []} && {serverTime >= _holdUntil} && {_areaClear}) then {
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
                    [_params, "supportValue", 14] call ALIVE_fnc_hashGet,
                    [
                        [_params, "clusterID", ""] call ALIVE_fnc_hashGet,
                        [_params, "taskType", "SecureCommunityEvent"] call ALIVE_fnc_hashGet,
                        [_params, "cooldownDuration", 3600] call ALIVE_fnc_hashGet
                    ]
                ] call ALIVE_fnc_taskApplyPopulationEffect;

                [_params] call _cleanupObjects;
            };
        };
    };
};

_result

