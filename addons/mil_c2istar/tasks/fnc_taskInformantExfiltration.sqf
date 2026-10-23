#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskInformantExfiltration);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskInformantExfiltration

Description:
Recover a cooperating informant and move them to a protected debrief site.

Three kinds (Will501 on Discord, 23 Oct), picked by the C2ISTAR module's Informant Extraction setting
(ALiVE_c2istar_informantExtractKind: classic by default, or random, hot, timed or cold):
  hot     enemy infantry are already in the town when the task starts
  timed   once a task player is within 2 km of his town, a hunter group sets out to kill him: if it reaches him, or
          the clock (Informant Hunt Time) runs out, before he is secured, he is killed and the task fails; once
          secured, it keeps coming. Hunters wiped out: the clock stops
  cold    no threat; at the hand-over he is debriefed: what he knows goes on the map and can raise a task, as a
          prisoner questioned at a prison does (ALiVE_c2istar_fnc_debriefInformant)
  classic as before any of these

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

// enemy infantry for the hot and timed kinds: [where round, how far out, how many groups, where they go, faction],
// left out of simulated combat for 15 minutes as Secure Community Event's waves are. Returns their profile IDs
private _spawnInfantry = {
    params ["_near", "_dist", "_count", "_goal", "_enemyFaction"];
    private _ids = [];
    for "_i" from 1 to _count do {
        private _group = ["Infantry", _enemyFaction] call ALIVE_fnc_configGetRandomGroup;
        if (_group != "FALSE" && {!(_group in ALiVE_PLACEMENT_GROUPBLACKLIST)}) then {
            private _at = _near getPos [_dist + random 100, random 360];
            private _profiles = [_group, _at, random 360, true, _enemyFaction, true] call ALIVE_fnc_createProfilesFromGroupConfig;
            if (_profiles isNotEqualTo []) then {
                [_profiles select 0, "simProtectUntil", time + 900] call ALIVE_fnc_hashSet;
                private _wp = [_goal getPos [random 30, random 360], 50, "MOVE", "FULL", 50, [], "LINE", "NO CHANGE", "AWARE"] call ALIVE_fnc_createProfileWaypoint;
                [_profiles select 0, "addWaypoint", _wp] call ALIVE_fnc_profileEntity;
                _ids pushBack (_profiles select 0 select 2 select 4);
            };
        };
    };
    _ids
};

// the hunters (timed kind) go where the informant is now: re-aimed only when he has moved more than 150 m from where
// they were last sent, and not while a route is still being worked out for them (clearing would cancel it)
private _retargetHunters = {
    params ["_taskParams", "_vip"];
    if (([_taskParams, "kind", "classic"] call ALIVE_fnc_hashGet) != "timed" || {isNull _vip}) exitWith {};
    if (serverTime < ([_taskParams, "huntersRetargetAt", 0] call ALIVE_fnc_hashGet)) exitWith {};
    [_taskParams, "huntersRetargetAt", serverTime + 30] call ALIVE_fnc_hashSet;
    private _last = [_taskParams, "huntersTarget", []] call ALIVE_fnc_hashGet;
    if (_last isNotEqualTo [] && {(_last distance2D _vip) < 150}) exitWith {};
    [_taskParams, "huntersTarget", getPosATL _vip] call ALIVE_fnc_hashSet;
    {
        private _prof = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
        if (!isNil "_prof" && {([_prof, "pendingWaypointPaths", []] call ALIVE_fnc_hashGet) isEqualTo []}) then {
            [_prof, "clearWaypoints"] call ALIVE_fnc_profileEntity;
            [_prof, "addWaypoint", [getPosATL _vip, 20, "MOVE", "FULL", 20, [], "LINE", "NO CHANGE", "AWARE"] call ALIVE_fnc_createProfileWaypoint] call ALIVE_fnc_profileEntity;
        };
    } forEach ([_taskParams, "hunterIDs", []] call ALIVE_fnc_hashGet);
};

private _cleanupObjects = {
    params ["_taskParams"];
    // the enemy the hot and timed kinds brought in: those still out of sight (virtual) go; a group players can see
    // stays and fights on as any other, rather than vanishing in front of them
    private _spawned = [_taskParams, "entityProfileIDs", []] call ALIVE_fnc_hashGet;
    if (_spawned isNotEqualTo []) then {
        private _virtual = _spawned select {
            private _pr = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
            !isNil "_pr" && {!(_pr select 2 select 1)}
        };
        if (_virtual isNotEqualTo []) then { [_virtual] call ALIVE_fnc_taskDestroyEntityProfiles };
        [_taskParams, "entityProfileIDs", []] call ALIVE_fnc_hashSet;
    };
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
        [_taskParams, "supportValue", 14] call ALIVE_fnc_hashGet,
        [
            [_taskParams, "clusterID", ""] call ALIVE_fnc_hashGet,
            [_taskParams, "taskType", "InformantExfiltration"] call ALIVE_fnc_hashGet,
            [_taskParams, "cooldownDuration", 4200] call ALIVE_fnc_hashGet,
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
                    // allowGetIn takes a list of units: given one unit it threw, which stopped the task's
                    // check every time a player waited in a vehicle with room, so the arrival was never seen.
                    [_vip] allowGetIn true;
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

        if (_taskID == "") exitWith {["C2ISTAR - Task InformantExfiltration - Wrong input for _taskID!"] call ALiVE_fnc_Dump};
        if (_requestPlayerID == "") exitWith {["C2ISTAR - Task InformantExfiltration - Wrong input for _requestPlayerID!"] call ALiVE_fnc_Dump};
        if (_taskFaction == "") exitWith {["C2ISTAR - Task InformantExfiltration - Wrong input for _taskFaction!"] call ALiVE_fnc_Dump};
        if (_taskLocationType == "") exitWith {["C2ISTAR - Task InformantExfiltration - Wrong input for _taskLocationType!"] call ALiVE_fnc_Dump};
        if (count _taskLocation == 0) exitWith {["C2ISTAR - Task InformantExfiltration - Wrong input for _taskLocation!"] call ALiVE_fnc_Dump};
        if (count _taskPlayers == 0) exitWith {["C2ISTAR - Task InformantExfiltration - Wrong input for _taskPlayers!"] call ALiVE_fnc_Dump};
        if (_taskApplyType == "") exitWith {["C2ISTAR - Task InformantExfiltration - Wrong input for _taskApplyType!"] call ALiVE_fnc_Dump};

        private _sourceClusterData = [_taskLocation, _taskLocationType, _taskSide, 10, 100000, _taskFaction, _tasksCurrent] call ALIVE_fnc_taskGetCivilianCluster;
        if (_sourceClusterData isEqualTo []) exitWith {["C2ISTAR - Task InformantExfiltration - No source civilian settlement found!"] call ALiVE_fnc_Dump};

        private _sourceCluster = _sourceClusterData select 0;
        private _supportState = _sourceClusterData param [2, []];
        private _sourceCenter = [_sourceCluster, "center", []] call ALIVE_fnc_hashGet;
        private _sourceClusterID = [_sourceCluster, "clusterID", ""] call ALIVE_fnc_hashGet;
        private _supportPhase = "Stabilize";
        if !(_supportState isEqualTo []) then {
            _supportPhase = [_supportState, "phase", "Stabilize"] call ALIVE_fnc_hashGet;
        };

        if (_sourceCenter isEqualTo []) exitWith {["C2ISTAR - Task InformantExfiltration - Invalid source cluster center!"] call ALiVE_fnc_Dump};

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
        // Maximum Task Distance (TheLogatron on Discord, 23 Oct): with no minimum set, a route of half the cap at least
        // rather than the 4 to 6 km default, and no floor or search ring past the cap
        private _capR = missionNamespace getVariable ["ALIVE_taskMaxDistance", 0];
        if (_capR > 0 && {(missionNamespace getVariable ["ALIVE_taskMinDistance", 0]) <= 0}) then { _minDistance = _capR * 0.5 };
        if (_capR <= 0) then { _capR = 1e9 };
        if (_destinationCenter isEqualTo [] || {_destinationCenter distance2D _sourceCenter < ((_minDistance max 1200) min _capR)} || {_destinationClusterID == _sourceClusterID}) then {
            _destinationCenter = [_sourceCenter, ((_minDistance max 2000) min _capR), (((_minDistance max 2000) + 5000) min _capR), 2, 0, 0.25, 0, [], [_sourceCenter]] call BIS_fnc_findSafePos;
            if (_destinationCenter isEqualTo []) then {
                _destinationCenter = [_sourceCenter, ((_minDistance max 3000) min _capR), random 360] call BIS_fnc_relPos;
            };
        };
        // Maximum Task Distance (TheLogatron on Discord, 23 Oct): the route no longer than it
        private _maxDistance = missionNamespace getVariable ["ALIVE_taskMaxDistance", 0];
        if (_maxDistance > 0 && {_destinationCenter isNotEqualTo []} && {(_destinationCenter distance2D _sourceCenter) > _maxDistance}) then {
            private _capped = [_sourceCenter, _maxDistance * 0.5, _maxDistance, 2, 0, 0.25, 0, [], [_sourceCenter]] call BIS_fnc_findSafePos;
            // a failed search gives back its default (the pickup itself): only a spot 0.4 to 1 times the cap out counts
            if (_capped isEqualTo [] || {(_capped distance2D _sourceCenter) > _maxDistance} || {(_capped distance2D _sourceCenter) < _maxDistance * 0.4}) then {
                _capped = [_sourceCenter, _maxDistance * 0.75, random 360] call BIS_fnc_relPos;
            };
            _destinationCenter = _capped;
            _destinationClusterID = "";
        };
        _destinationCenter set [2, 0];

        // A Player FOB, a friendly base or a point the OP lead picked on the tablet map can be the debrief site
        // instead of a settlement, which can be full of hostiles. The pickup stays where it is, and a FOB or
        // base too close to it is passed over (NeisAEL and A. Ares on Discord, 23 Oct)
        private _fixedEnd = [_taskSide, _task param [13, []], _sourceCenter, true, _sourceCenter,
            ((missionNamespace getVariable ["ALIVE_taskMinDistance", 0]) max 1200), false] call ALIVE_fnc_taskGetReturnPosition;
        _fixedEnd params ["_fixedPosition", "_fixedName"];
        if (count _fixedPosition >= 2) then {
            _destinationCenter = +_fixedPosition;
            _destinationCenter set [2, 0];
            _destinationClusterID = "";
        };

        private _vipPosition = [_sourceCenter, 5, 20, 2, 0, 0.25, 0] call BIS_fnc_findSafePos;
        if (_vipPosition isEqualTo []) then {
            _vipPosition = +_sourceCenter;
        };

        private _vipClass = selectRandom ([] call ALiVE_fnc_taskGetCivilianClasses);
        private _vipGroup = createGroup [civilian, true];
        private _vip = _vipGroup createUnit [_vipClass, _vipPosition, [], 0, "NONE"];
        removeAllWeapons _vip;
        // papers that say who he is, so he can be told from the townsfolk
        [_vip, "STR_ALIVE_TARGETID_INFORMANT"] call ALiVE_fnc_giveTargetPapers;
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

        private _destinationTown = _fixedName;
        if (_destinationTown == "") then {
            _destinationTown = [_destinationCenter] call ALIVE_fnc_taskGetNearestLocationName;
        };
        if (_destinationTown == "") then {
            _destinationTown = "the destination settlement";
        };

        _vip setVariable ["ALIVE_Task_VIPSourceTown", _sourceTown, false];
        _vip setVariable ["ALIVE_Task_VIPDestinationTown", _destinationTown, false];

        [
            _vip,
            "Secure Informant",
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

                ["Task Update", format ["%1 secured the informant in %2.", name _caller, _target getVariable ["ALIVE_Task_VIPSourceTown", "the area"]]] remoteExec ["ALIVE_fnc_taskSubtitle", side (group _caller)];
            },
            {},
            [],
            6
        ] remoteExec ["BIS_fnc_holdActionAdd", [0, -2] select isDedicated, _vip];

        private _dialogOptions = [ALIVE_generatedTasks, "InformantExfiltration"] call ALIVE_fnc_hashGet;
        _dialogOptions = _dialogOptions select 1;
        private _dialogOption = +(selectRandom _dialogOptions);

        private _dialog = [_dialogOption, "Parent"] call ALIVE_fnc_hashGet;
        private _taskTitle = format [[_dialog, "title"] call ALIVE_fnc_hashGet, _sourceTown, _destinationTown];
        private _taskDescription = format [[_dialog, "description"] call ALIVE_fnc_hashGet, _sourceTown, _destinationTown];

        private _state = if (_taskCurrent == "Y") then {"Assigned"} else {"Created"};
        private _tasks = [];
        private _taskIDs = [];

        private _taskSource = format ["%1-InformantExfiltration-Parent", _taskID];
        _tasks pushBack [_taskID, _requestPlayerID, _taskSide, _sourceCenter, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, _state, _taskApplyType, "N", "None", _taskSource, false];
        _taskIDs pushBack _taskID;

        _dialog = [_dialogOption, "Pickup"] call ALIVE_fnc_hashGet;
        _taskTitle = format [[_dialog, "title"] call ALIVE_fnc_hashGet, _sourceTown];
        _taskDescription = format [[_dialog, "description"] call ALIVE_fnc_hashGet, _sourceTown];
        private _pickupTaskID = format ["%1_c1", _taskID];
        _taskSource = format ["%1-InformantExfiltration-Pickup", _taskID];
        _tasks pushBack [_pickupTaskID, _requestPlayerID, _taskSide, _vipPosition, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, _state, _taskApplyType, _taskCurrent, _taskID, _taskSource, false];
        _taskIDs pushBack _pickupTaskID;

        _dialog = [_dialogOption, "Escort"] call ALIVE_fnc_hashGet;
        _taskTitle = format [[_dialog, "title"] call ALIVE_fnc_hashGet, _destinationTown];
        _taskDescription = format [[_dialog, "description"] call ALIVE_fnc_hashGet, _destinationTown];
        private _escortTaskID = format ["%1_c2", _taskID];
        _taskSource = format ["%1-InformantExfiltration-Escort", _taskID];
        _tasks pushBack [_escortTaskID, _requestPlayerID, _taskSide, _destinationCenter, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, "Created", _taskApplyType, "N", _taskID, _taskSource, false];
        _taskIDs pushBack _escortTaskID;

        _dialog = [_dialogOption, "Return"] call ALIVE_fnc_hashGet;
        _taskTitle = format [[_dialog, "title"] call ALIVE_fnc_hashGet, _destinationTown];
        _taskDescription = format [[_dialog, "description"] call ALIVE_fnc_hashGet, _destinationTown];
        private _returnTaskID = format ["%1_c3", _taskID];
        _taskSource = format ["%1-InformantExfiltration-Return", _taskID];
        _tasks pushBack [_returnTaskID, _requestPlayerID, _taskSide, _destinationCenter, _taskFaction, _taskTitle, _taskDescription, _taskPlayers, "Created", _taskApplyType, "N", _taskID, _taskSource, true];
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
        _returnMessage set [1, format [_returnMessage select 1, _destinationTown]];
        _returnChat set [0, _returnMessage];
        [_dialog, "chat_start", _returnChat] call ALIVE_fnc_hashSet;

        private _returnSuccessChat = +([_dialog, "chat_success"] call ALIVE_fnc_hashGet);
        private _returnSuccessMessage = +(_returnSuccessChat select 0);
        _returnSuccessMessage set [1, format [_returnSuccessMessage select 1, _destinationTown]];
        _returnSuccessChat set [0, _returnSuccessMessage];
        [_dialog, "chat_success", _returnSuccessChat] call ALIVE_fnc_hashSet;

        private _returnFailChat = +([_dialog, "chat_failed"] call ALIVE_fnc_hashGet);
        private _returnFailMessage = +(_returnFailChat select 0);
        _returnFailMessage set [1, format [_returnFailMessage select 1, _destinationTown]];
        _returnFailChat set [0, _returnFailMessage];
        [_dialog, "chat_failed", _returnFailChat] call ALIVE_fnc_hashSet;

        private _taskParams = [] call ALIVE_fnc_hashCreate;
        [_taskParams, "nextTask", _taskIDs select 1] call ALIVE_fnc_hashSet;
        [_taskParams, "taskIDs", _taskIDs] call ALIVE_fnc_hashSet;
        [_taskParams, "dialog", _dialogOption] call ALIVE_fnc_hashSet;
        [_taskParams, "enemyFaction", _taskEnemyFaction] call ALIVE_fnc_hashSet;
        [_taskParams, "targets", [_vip]] call ALIVE_fnc_hashSet;
        [_taskParams, "cleanup", [_vip]] call ALIVE_fnc_hashSet;
        [_taskParams, "supportValue", 14] call ALIVE_fnc_hashSet;
        [_taskParams, "clusterID", _sourceClusterID] call ALIVE_fnc_hashSet;
        [_taskParams, "destinationClusterID", _destinationClusterID] call ALIVE_fnc_hashSet;
        [_taskParams, "supportPhase", _supportPhase] call ALIVE_fnc_hashSet;
        [_taskParams, "taskType", "InformantExfiltration"] call ALIVE_fnc_hashSet;
        [_taskParams, "cooldownDuration", 4200] call ALIVE_fnc_hashSet;
        [_taskParams, "supportEffectPosition", _sourceCenter] call ALIVE_fnc_hashSet;
        [_taskParams, "panicTimeout", (_panicTimeout max 30)] call ALIVE_fnc_hashSet;
        [_taskParams, "lastState", ""] call ALIVE_fnc_hashSet;

        // the kind of extraction (header): random picks hot, timed or cold each time
        private _kind = toLower (missionNamespace getVariable ["ALiVE_c2istar_informantExtractKind", "classic"]);
        if (_kind == "random") then { _kind = selectRandom ["hot", "timed", "cold"] };
        if !(_kind in ["hot", "timed", "cold", "classic"]) then { _kind = "classic" };
        private _suffix = switch (_kind) do {
            case "hot": { " (hot area)" };
            case "timed": { " (against the clock)" };
            case "cold": { " (debrief)" };
            default { "" };
        };
        (_tasks select 0) set [5, ((_tasks select 0) select 5) + _suffix];
        [_taskParams, "kind", _kind] call ALIVE_fnc_hashSet;
        private _enemyFaction = if (_taskEnemyFaction isEqualType "" && {_taskEnemyFaction != ""}) then { _taskEnemyFaction } else { "OPF_F" };
        switch (_kind) do {
            case "hot": {
                [_taskParams, "entityProfileIDs", [_sourceCenter, 150, 1 + floor random 2, _sourceCenter, _enemyFaction] call _spawnInfantry] call ALIVE_fnc_hashSet;
            };
            case "timed": {
                // the hunters set out, and the clock starts, once a task player is near the town (Pickup)
                [_taskParams, "enemyFactionUsed", _enemyFaction] call ALIVE_fnc_hashSet;
            };
        };
        [_taskParams, "sourceTown", _sourceTown] call ALIVE_fnc_hashSet;
        ["C2ISTAR - Task InformantExfiltration %1: %2 extraction from %3", _taskID, _kind, _sourceTown] call ALiVE_fnc_Dump;

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

        if !([_params, "chatStartDone_Pickup", false] call ALIVE_fnc_hashGet) then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "chatStartDone_Pickup", true] call ALIVE_fnc_hashSet;
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
            // against the clock: the hunters head for him, and kill him if they reach him or the time runs out
            // before he is secured (the dead-informant fail above then ends the task on the next pass)
            if (([_params, "kind", "classic"] call ALIVE_fnc_hashGet) == "timed" && {!(_vip getVariable ["ALIVE_Task_VIPPicked", false])}) then {
                private _players = (_taskPlayers apply { [_x] call ALIVE_fnc_getPlayerByUID }) select { !isNull _x };
                private _town = [_params, "sourceTown", "the town"] call ALIVE_fnc_hashGet;
                private _arrive = [_params, "huntersArriveAt", -1] call ALIVE_fnc_hashGet;
                // not started: the hunters set out, and the clock starts, once a task player is within 2 km of the
                // town, so a player busy elsewhere doesn't lose him before he could have got there
                if (_arrive < 0) then {
                    if ((_players findIf { (_x distance2D _vip) < 2000 }) >= 0) then {
                        private _hunters = [getPosATL _vip, 1500 + random 900, 1, getPosATL _vip, [_params, "enemyFactionUsed", "OPF_F"] call ALIVE_fnc_hashGet] call _spawnInfantry;
                        [_params, "hunterIDs", _hunters] call ALIVE_fnc_hashSet;
                        [_params, "huntersTarget", getPosATL _vip] call ALIVE_fnc_hashSet;
                        [_params, "entityProfileIDs", ([_params, "entityProfileIDs", []] call ALIVE_fnc_hashGet) + _hunters] call ALIVE_fnc_hashSet;
                        _arrive = serverTime + ((missionNamespace getVariable ["ALiVE_c2istar_informantHuntTime", 900]) max 120);
                        [_params, "huntersArriveAt", _arrive] call ALIVE_fnc_hashSet;
                        ["Task Update", format ["HQ: A hunter team is moving on the informant in %1. Secure him within about %2 minutes.", _town, ceil ((_arrive - serverTime) / 60)]] remoteExec ["ALIVE_fnc_taskSubtitle", _players];
                    };
                } else {
                    [_params, _vip] call _retargetHunters;
                    private _hunters = ([_params, "hunterIDs", []] call ALIVE_fnc_hashGet) apply { [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler };
                    _hunters = _hunters select { !isNil "_x" };
                    // none ever came (no group for that faction): nothing to watch, so it plays as classic
                    if (([_params, "hunterIDs", []] call ALIVE_fnc_hashGet) isEqualTo []) then {} else {
                    if (_hunters isEqualTo []) then {
                        // the hunters are down: the clock stops
                        if (([_params, "huntersArriveAt", -1] call ALIVE_fnc_hashGet) < 1e9) then {
                            [_params, "huntersArriveAt", 1e10] call ALIVE_fnc_hashSet;
                            ["Task Update", "HQ: The hunter team is down. The informant is safe for now."] remoteExec ["ALIVE_fnc_taskSubtitle", _players];
                        };
                    } else {
                        private _near = _hunters findIf { (([_x, "position", [0, 0, 0]] call ALIVE_fnc_hashGet) distance2D _vip) < 50 };
                        if (serverTime > _arrive || {_near >= 0}) then {
                            _vip setDamage 1;
                            ["Task Update", ["HQ: Time's up. We've lost the informant.", "HQ: The hunters got to the informant first."] select (_near >= 0)] remoteExec ["ALIVE_fnc_taskSubtitle", _players];
                        };
                    };
                    };
                };
            };
            // the pin follows the informant, who may run or be moved before he is secured
            [getPosATL _vip, _taskSide, _taskPlayers, _taskID, "civilian", "Informant"] call ALIVE_fnc_taskCreateMarkersForPlayers;
            [ALiVE_TaskHandler, "followTaskPosition", [_task, _params, getPosATL _vip]] call ALiVE_fnc_TaskHandler;

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

        if !([_params, "chatStartDone_Escort", false] call ALIVE_fnc_hashGet) then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "chatStartDone_Escort", true] call ALIVE_fnc_hashSet;
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
            [_taskPosition, _taskSide, _taskPlayers, _taskID, "building", "safe site"] call ALIVE_fnc_taskCreateMarkersForPlayers;
            // against the clock: secured or not, the hunters keep coming after him. Secured before they ever set out
            // (a helicopter in and out within one check): they set out now, with no clock, as he is already in hand
            if (([_params, "kind", "classic"] call ALIVE_fnc_hashGet) == "timed" && {([_params, "huntersArriveAt", -1] call ALIVE_fnc_hashGet) < 0}) then {
                private _hunters = [getPosATL _vip, 1500 + random 900, 1, getPosATL _vip, [_params, "enemyFactionUsed", "OPF_F"] call ALIVE_fnc_hashGet] call _spawnInfantry;
                [_params, "hunterIDs", _hunters] call ALIVE_fnc_hashSet;
                [_params, "huntersTarget", getPosATL _vip] call ALIVE_fnc_hashSet;
                [_params, "entityProfileIDs", ([_params, "entityProfileIDs", []] call ALIVE_fnc_hashGet) + _hunters] call ALIVE_fnc_hashSet;
                [_params, "huntersArriveAt", 1e10] call ALIVE_fnc_hashSet;
                if (_hunters isNotEqualTo []) then {
                    ["Task Update", "HQ: A hunter team is coming after the informant. Get him out quickly."] remoteExec ["ALIVE_fnc_taskSubtitle", (_taskPlayers apply { [_x] call ALIVE_fnc_getPlayerByUID }) select { !isNull _x }];
                };
            };
            [_params, _vip] call _retargetHunters;

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

        if !([_params, "chatStartDone_Return", false] call ALIVE_fnc_hashGet) then {
            ["chat_start", _currentTaskDialog, _taskSide, _taskPlayers] call ALIVE_fnc_taskCreateRadioBroadcastForPlayers;
            [_params, "chatStartDone_Return", true] call ALIVE_fnc_hashSet;
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
            [_taskPosition, _taskSide, _taskPlayers, _taskID, "building", "handover point"] call ALIVE_fnc_taskCreateMarkersForPlayers;

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

                    // cold: he is debriefed at the hand-over, as a prisoner questioned at a prison is: what he knows
                    // of the ground round his town goes on the map and can raise a task (ALiVE_c2istar_fnc_debriefInformant)
                    if (([_params, "kind", "classic"] call ALIVE_fnc_hashGet) == "cold" && {!isNil "ALiVE_c2istar_fnc_debriefInformant"}) then {
                        [[_params, "supportEffectPosition", _taskPosition] call ALIVE_fnc_hashGet, _taskSide, _taskFaction,
                            [_params, "enemyFaction", ""] call ALIVE_fnc_hashGet, name _vip, _taskPlayers] call ALiVE_c2istar_fnc_debriefInformant;
                    };

                    [
                        ([_params, "supportEffectPosition", _taskPosition] call ALIVE_fnc_hashGet),
                        _taskSide,
                        [_params, "supportValue", 14] call ALIVE_fnc_hashGet,
                        [
                            [_params, "clusterID", ""] call ALIVE_fnc_hashGet,
                            [_params, "taskType", "InformantExfiltration"] call ALIVE_fnc_hashGet,
                            [_params, "cooldownDuration", 4200] call ALIVE_fnc_hashGet
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


