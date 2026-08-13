#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(playerOrders);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_playerOrders
Description:
Player-group level helpers for requesting, rerolling, and opting in/out of
OPCOM-directed orders that are surfaced through C2ISTAR.

Parameters:
String - operation
Array - operation arguments

Returns:
Any

Author:
Javen
Jman
---------------------------------------------------------------------------- */

#define MAINCLASS ALiVE_fnc_playerOrders

private _result = false;

params [
    ["_operation", "", [""]],
    ["_args", [], [[]]]
];

switch (_operation) do {
    case "notify": {
        _args params [
            ["_player", objNull, [objNull]],
            ["_message", "", [""]]
        ];

        if (!isNull _player && {_message != ""}) then {
            [_message] remoteExec ["hint", owner _player];
        };
    };
    case "getGroupData": {
        _args params [
            ["_player", objNull, [objNull]]
        ];

        if (isNull _player) exitWith {[]};

        private _group = group _player;
        private _groupPlayers = (units _group) select {isPlayer _x};

        if (_groupPlayers isEqualTo []) exitWith {[]};

        private _requestPlayer = leader _group;
        if !(isPlayer _requestPlayer) then {
            _requestPlayer = _groupPlayers select 0;
        };

        private _playerIDs = _groupPlayers apply {getPlayerUID _x};
        private _playerNames = _groupPlayers apply {name _x};
        private _groupID = [format ["%1", _group], " ", "_"] call CBA_fnc_replace;
        private _groupPos = getPosATL _requestPlayer;
        private _side = [side _group] call ALIVE_fnc_sideObjectToNumber;
        _side = [_side] call ALIVE_fnc_sideNumberToText;

        _result = [
            _group,
            _groupID,
            _groupPlayers,
            _playerIDs,
            _playerNames,
            _requestPlayer,
            getPlayerUID _requestPlayer,
            _groupPos,
            _side,
            faction _requestPlayer
        ];
    };
    case "getGroupCurrentParentTask": {
        _args params [
            ["_groupID", "", [""]]
        ];

        if (_groupID == "" || {isNil "ALIVE_taskHandler"}) exitWith {[]};

        private _groupTasks = [ALIVE_taskHandler, "getTasksByGroup", _groupID] call ALiVE_fnc_taskHandler;
        private _currentTask = [];

        // The "current" marker never sits on the top of a task. Every task is built
        // with its top marked not current and carrying no parent, and the marker
        // handed to a step underneath it that names the top as its parent. Asking a
        // single record to be both could never match anything, so a group always
        // read as having nothing on, and asking the commander for a different order
        // added one alongside the old one instead of replacing it (#992). Confirmed
        // by a reporter trace on both a dedicated server and singleplayer: thirteen
        // lookups, none of which matched, against task lists growing to nine.
        //
        // Match the marker, then walk back up to the top of the task, because the
        // caller deletes whatever comes back and only the top takes the whole thing
        // with it. Handing back a step would strand the top and its siblings.
        //
        // Only a task given to this group speaks for this group. The commander's own
        // generated tasks are handed to every player on a side, so reading one of
        // those as "this group is busy" would mark every group busy at once and stop
        // anyone being given an order at all.
        //
        // No early exit here on purpose. A group should only ever have one task on the
        // go, but if it somehow has two, the later one is the one the player just asked
        // for, so that is the one to answer with. Deliberate, not a missing exit.
        {
            if (_x isEqualType [] && {count _x > 12}) then {
                private _taskState = _x param [8, "", [""]];
                private _applyType = _x param [9, "", [""]];
                private _taskCurrent = _x param [10, "", [""]];
                private _parent = _x param [11, "", [""]];

                if (_taskCurrent == "Y"
                    && {_applyType == "Group"}
                    && {!(_taskState in ["Succeeded", "Failed", "Canceled"])}) then {

                    if (_parent == "None") then {
                        // A task built by hand on the tablet has no steps beneath it,
                        // so it carries the marker itself. That is the one shape the
                        // old test did match, and it goes on matching.
                        _currentTask = _x;
                    } else {
                        private _parentTask = [ALIVE_taskHandler, "getTask", _parent] call ALiVE_fnc_taskHandler;

                        // Only accept a top that the task list still holds and that is
                        // itself parentless. Anything else leaves the group reading as
                        // free, which is how this behaved before, rather than handing
                        // the caller something it would then delete.
                        if (!isNil "_parentTask"
                            && {_parentTask isEqualType []}
                            && {count _parentTask > 12}
                            && {(_parentTask param [11, "", [""]]) == "None"}) then {
                            _currentTask = _parentTask;
                        };
                    };
                };
            };
        } forEach _groupTasks;

        // DIAG-STRIP (#992): says what this group was holding and which of it the test above
        // picked, so a log tells apart "found the one on the go" from "found nothing", and
        // if it found nothing, whether that is because the group genuinely had nothing on or
        // because the records are there and are being turned away. Carries the assignment
        // type, since that is what now separates a task given to this group from one the
        // commander handed to the whole side.
        // Gate: ALiVE_c2istar_taskDiag = true.
        if (!isNil "ALiVE_c2istar_taskDiag" && {ALiVE_c2istar_taskDiag}) then {
            ["[C2ISTAR #992 DIAG] lookup group=%1 groupTasks=%2 matched=%3",
                _groupID, count _groupTasks, _currentTask param [0, "<none>"]] call ALiVE_fnc_dump;
            {
                ["[C2ISTAR #992 DIAG]   record id=%1 state=%2 apply=%3 current=%4 parent=%5 source=%6",
                    _x param [0, ""], _x param [8, ""], _x param [9, ""], _x param [10, ""],
                    _x param [11, ""], _x param [12, ""]] call ALiVE_fnc_dump;
            } forEach _groupTasks;
        };

        _result = _currentTask;
    };
    case "getTaskManagedParams": {
        _args params [
            ["_taskID", "", [""]]
        ];

        if (_taskID == "" || {isNil "ALIVE_taskHandler"}) exitWith {[]};

        private _managedTaskParams = [ALIVE_taskHandler, "managedTaskParams"] call ALiVE_fnc_hashGet;
        if (!isNil "_managedTaskParams" && {_taskID in (_managedTaskParams select 1)}) then {
            _result = [_managedTaskParams, _taskID] call ALiVE_fnc_hashGet;
        } else {
            _result = [];
        };
    };
    case "getSideSettings": {
        _args params [
            ["_side", "", [""]]
        ];

        private _logic = missionNamespace getVariable ["ALIVE_MIL_C2ISTAR", objNull];
        if (isNull _logic) exitWith {["None", "OPF_F"]};

        _result = switch (_side) do {
            case "EAST": {
                [[_logic, "autoGenerateOpfor"] call ALiVE_fnc_C2ISTAR, [_logic, "autoGenerateOpforEnemyFaction"] call ALiVE_fnc_C2ISTAR]
            };
            case "GUER": {
                [[_logic, "autoGenerateIndfor"] call ALiVE_fnc_C2ISTAR, [_logic, "autoGenerateIndforEnemyFaction"] call ALiVE_fnc_C2ISTAR]
            };
            default {
                [[_logic, "autoGenerateBlufor"] call ALiVE_fnc_C2ISTAR, [_logic, "autoGenerateBluforEnemyFaction"] call ALiVE_fnc_C2ISTAR]
            };
        };
    };
    case "getAutoOrderSidePlayers": {
        _args params [
            ["_side", "", [""]]
        ];

        if !(isServer) exitWith {[[], []]};

        private _playerIDs = [];
        private _playerNames = [];

        {
            if !(isNull _x) then {
                private _playerSide = (faction _x) call ALiVE_fnc_FactionSide;
                _playerSide = [_playerSide] call ALIVE_fnc_sideObjectToNumber;
                _playerSide = [_playerSide] call ALIVE_fnc_sideNumberToText;

                if (_playerSide == _side && {!(group _x getVariable [QGVAR(playerOrdersOptOut), false])}) then {
                    private _playerID = getPlayerUID _x;

                    if !(_playerID in _playerIDs) then {
                        _playerIDs pushBack _playerID;
                        _playerNames pushBack (format["%1 - %2", name _x, group _x]);
                    };
                };
            };
        } forEach (allPlayers - entities "HeadlessClient_F");

        _result = [_playerIDs, _playerNames];
    };
    case "selectEligibleGroup": {
        _args params [
            ["_side", "", [""]],
            ["_faction", "", [""]],
            ["_destination", [], [[]]]
        ];

        if !(isServer) exitWith {[]};

        private _groupsByID = [] call ALiVE_fnc_hashCreate;
        private _candidates = [];

        {
            if (alive _x) then {
                private _playerSide = [side group _x] call ALIVE_fnc_sideObjectToNumber;
                _playerSide = [_playerSide] call ALIVE_fnc_sideNumberToText;

                if (_playerSide == _side) then {
                    private _groupData = ["getGroupData", [_x]] call MAINCLASS;

                    if !(_groupData isEqualTo []) then {
                        _groupData params [
                            "_group",
                            "_groupID",
                            "",
                            "",
                            "",
                            "",
                            "",
                            "_groupPos",
                            "",
                            "_groupFaction"
                        ];

                        if !(_groupID in (_groupsByID select 1)) then {
                            if !(_group getVariable [QGVAR(playerOrdersOptOut), false]) then {
                                if ((["getGroupCurrentParentTask", [_groupID]] call MAINCLASS) isEqualTo []) then {
                                    private _exactFactionMatch = _faction == "" || {_groupFaction == _faction};
                                    private _distance = if (_destination isEqualTo []) then {0} else {_groupPos distance2D _destination};

                                    [_groupsByID, _groupID, true] call ALiVE_fnc_hashSet;
                                    _candidates pushBack [_exactFactionMatch, _distance, _groupData];
                                };
                            };
                        };
                    };
                };
            };
        } forEach (allPlayers - entities "HeadlessClient_F");

        if (_candidates isEqualTo []) exitWith {[]};

        _candidates = [_candidates, [], {
            private _factionSort = if (_x select 0) then {0} else {1};
            [_factionSort, _x select 1]
        }, "ASCEND"] call ALiVE_fnc_SortBy;

        _result = (_candidates select 0) select 2;
    };
    case "createStrategicTaskForGroup": {
        _args params [
            ["_groupData", [], [[]]],
            ["_enemyFaction", "OPF_F", [""]],
            ["_excludedPosition", [], [[]]],
            ["_excludedReservationKey", []]
        ];

        if !(isServer) exitWith {false};
        if (_groupData isEqualTo []) exitWith {false};
        if (isNil "ALIVE_taskHandler") exitWith {false};

        _groupData params [
            "",
            "_groupID",
            "",
            "_playerIDs",
            "_playerNames",
            "",
            "_requestPlayerID",
            "_groupPos",
            "_side",
            "_faction"
        ];

        private _opcom = [];
        {
            if (_x isEqualType []) then {
                if (_faction in ([_x, "factions", []] call ALiVE_fnc_hashGet)) exitWith {
                    _opcom = _x;
                };
            };
        } forEach (missionNamespace getVariable ["OPCOM_instances", []]);

        if (_opcom isEqualTo []) exitWith {false};

        if (isNil QGVAR(playerRequests)) then {
            GVAR(playerRequests) = [] call ALiVE_fnc_hashCreate;
        };

        private _getObjectiveReservationKey = {
            params ["_objective", "_fallbackPos"];

            private _objectiveID = [_objective, "objectiveID", ""] call ALiVE_fnc_hashGet;
            if !(_objectiveID isEqualTo "") exitWith {_objectiveID};

            private _clusterID = [_objective, "clusterID", ""] call ALiVE_fnc_hashGet;
            if !(_clusterID isEqualTo "") exitWith {_clusterID};

            [_objective, "center", _fallbackPos] call ALiVE_fnc_hashGet;
        };

        private _getUnreservedObjective = {
            params ["_objectives", "_taskType", "_fallbackPos", "_excludedReservationKey"];

            private _currentTargets = [GVAR(playerRequests), _taskType, []] call ALiVE_fnc_hashGet;
            private _selectedObjective = [];
            private _selectedReservationKey = [];

            {
                private _reservationKey = [_x, _fallbackPos] call _getObjectiveReservationKey;
                private _isExcludedReservation = !(_excludedReservationKey isEqualTo []) && {_reservationKey isEqualTo _excludedReservationKey};

                if !(_reservationKey in _currentTargets) then {
                    if !(_isExcludedReservation) exitWith {
                        _selectedObjective = _x;
                        _selectedReservationKey = _reservationKey;
                    };
                };
            } forEach _objectives;

            [_selectedObjective, _selectedReservationKey]
        };

        private _filterObjectives = {
            params ["_objectives", "_fallbackPos", "_excludedPosition"];

            if (_excludedPosition isEqualTo []) exitWith {_objectives};

            _objectives select {
                private _objectiveCenter = [_x, "center", _fallbackPos] call ALiVE_fnc_hashGet;
                _objectiveCenter isEqualTo [] || {_objectiveCenter distance2D _excludedPosition > 10}
            }
        };

        private _taskType = "";
        private _taskLocation = [];
        private _reservationKey = [];
        private _objectives = +([_opcom, "nearestObjectives", [_groupPos, "attacking"]] call ALiVE_fnc_OPCOM);
        _objectives = [_objectives, _groupPos, _excludedPosition] call _filterObjectives;

        if !(_objectives isEqualTo []) then {
            private _objectiveSelection = [_objectives, "CaptureObjective", _groupPos, _excludedReservationKey] call _getUnreservedObjective;
            private _objective = _objectiveSelection select 0;

            if !(_objective isEqualTo []) then {
                _taskType = "CaptureObjective";
                _taskLocation = [_objective, "center", _groupPos] call ALiVE_fnc_hashGet;
                _reservationKey = _objectiveSelection select 1;
            };
        };

        if (_taskType == "") then {
            _objectives = +([_opcom, "nearestObjectives", [_groupPos, "defending"]] call ALiVE_fnc_OPCOM);
            _objectives = [_objectives, _groupPos, _excludedPosition] call _filterObjectives;
            if !(_objectives isEqualTo []) then {
                private _objectiveSelection = [_objectives, "MilDefence", _groupPos, _excludedReservationKey] call _getUnreservedObjective;
                private _objective = _objectiveSelection select 0;

                if !(_objective isEqualTo []) then {
                    _taskType = "MilDefence";
                    _taskLocation = [_objective, "center", _groupPos] call ALiVE_fnc_hashGet;
                    _reservationKey = _objectiveSelection select 1;
                };
            };
        };

        if (_taskType == "" || {_taskLocation isEqualTo []}) exitWith {false};

        private _currentTargets = [GVAR(playerRequests), _taskType, []] call ALiVE_fnc_hashGet;
        if !(_reservationKey in _currentTargets) then {
            _currentTargets pushBack _reservationKey;
            [GVAR(playerRequests), _taskType, _currentTargets] call ALiVE_fnc_hashSet;
        };

        private _taskID = format ["OPORD_%1_%2", _groupID, floor (diag_tickTime * 10)];

        // DIAG-STRIP (#992): this site and the one in the task request handler mint the same
        // ID shape, so an ID alone cannot say whether an order came from someone pressing the
        // menu or from the commander raising it unprompted. The tag can. Orders appearing
        // between a player's clicks mean a second source is running.
        // Gate: ALiVE_c2istar_taskDiag = true.
        if (!isNil "ALiVE_c2istar_taskDiag" && {ALiVE_c2istar_taskDiag}) then {
            ["[C2ISTAR #992 DIAG] minted by=TABLET id=%1 group=%2", _taskID, _groupID] call ALiVE_fnc_dump;
        };
        private _taskPlayers = [_playerIDs, _playerNames];
        private _task = [_taskID, _requestPlayerID, _side, _faction, _taskType, "Map", _taskLocation, _taskPlayers, _enemyFaction, "Y", "Group"];

        [ALIVE_taskHandler, "generateTask", _task] call ALiVE_fnc_taskHandler;

        private _createdTask = [ALIVE_taskHandler, "getTask", _taskID] call ALiVE_fnc_taskHandler;
        if (isNil "_createdTask") then {
            private _currentTargets = [GVAR(playerRequests), _taskType, []] call ALiVE_fnc_hashGet;
            private _reservationIndex = _currentTargets find _reservationKey;

            if (_reservationIndex > -1) then {
                _currentTargets deleteAt _reservationIndex;
                [GVAR(playerRequests), _taskType, _currentTargets] call ALiVE_fnc_hashSet;
            };
        } else {
            private _managedTaskParams = [ALIVE_taskHandler, "managedTaskParams"] call ALiVE_fnc_hashGet;
            if (!isNil "_managedTaskParams" && {_taskID in (_managedTaskParams select 1)}) then {
                private _taskParams = [_managedTaskParams, _taskID] call ALiVE_fnc_hashGet;
                [_taskParams, "strategicObjectivePosition", _taskLocation] call ALiVE_fnc_hashSet;
                [_taskParams, "strategicReservationKey", _reservationKey] call ALiVE_fnc_hashSet;
                [_managedTaskParams, _taskID, _taskParams] call ALiVE_fnc_hashSet;
            };

            _result = true;
        };
    };
    case "createGeneratedTaskForGroup": {
        _args params [
            ["_groupData", [], [[]]],
            ["_enemyFaction", "OPF_F", [""]],
            ["_excludedTaskTypes", [], [[]]],
            ["_excludedRootTaskID", "", [""]]
        ];

        if !(isServer) exitWith {false};
        if (_groupData isEqualTo []) exitWith {false};
        if (isNil "ALIVE_autoGeneratedTasks" || {ALIVE_autoGeneratedTasks isEqualTo []}) exitWith {false};
        if (isNil "ALIVE_taskHandler") exitWith {false};

        _groupData params [
            "",
            "_groupID",
            "",
            "_playerIDs",
            "_playerNames",
            "",
            "_requestPlayerID",
            "_groupPos",
            "_side",
            "_faction"
        ];

        private _excludedGeneratedTaskTypes = +_excludedTaskTypes;
        private _taskPlayers = [_playerIDs, _playerNames];
        private _attempt = 0;
        private _created = false;

        while {!_created} do {
            private _tasksCurrent = ([ALIVE_taskHandler, "getTasks"] call ALiVE_fnc_taskHandler) select 2;
            if (_excludedRootTaskID != "") then {
                private _filteredTasksCurrent = [];

                {
                    private _taskSource = _x param [12, "", [""]];
                    private _includeTask = true;

                    if (_taskSource != "") then {
                        private _parsedTaskSource = [ALIVE_taskHandler, "parseTaskSource", _taskSource] call ALiVE_fnc_taskHandler;
                        _includeTask = (_parsedTaskSource param [0, "", [""]]) != _excludedRootTaskID;
                    };

                    if (_includeTask) then {
                        _filteredTasksCurrent pushBack _x;
                    };
                } forEach _tasksCurrent;

                _tasksCurrent = _filteredTasksCurrent;
            };
            private _taskType = [ALIVE_autoGeneratedTasks, _groupPos, "Short", _side, _faction, _tasksCurrent, _excludedGeneratedTaskTypes, _enemyFaction] call ALiVE_fnc_taskSelectAutoGeneratedType;

            if (_taskType == "") exitWith {};

            _attempt = _attempt + 1;

            private _taskID = format ["OPORD_AUTO_%1_%2_%3", _groupID, floor (diag_tickTime * 10), _attempt];
            private _task = [_taskID, _requestPlayerID, _side, _faction, _taskType, "Short", _groupPos, _taskPlayers, _enemyFaction, "Y", "Group"];

            [ALIVE_taskHandler, "generateTask", _task] call ALiVE_fnc_taskHandler;

            private _createdTask = [ALIVE_taskHandler, "getTask", _taskID] call ALiVE_fnc_taskHandler;
            if (isNil "_createdTask") then {
                if !(_taskType in _excludedGeneratedTaskTypes) then {
                    _excludedGeneratedTaskTypes pushBack _taskType;
                };
            } else {
                _created = true;
            };
        };

        _result = _created;
    };
    case "requestOrder": {
        if !(isServer) exitWith {
            [_operation, _args] remoteExec ["ALiVE_fnc_playerOrders", 2];
        };

        _args params [
            ["_player", objNull, [objNull]],
            ["_replaceCurrent", false, [true]]
        ];

        if (isNull _player) exitWith {};

        private _groupData = ["getGroupData", [_player]] call MAINCLASS;
        if (_groupData isEqualTo []) exitWith {
            ["notify", [_player, "OPCOM cannot identify your player group."]] call MAINCLASS;
        };

        _groupData params [
            "",
            "_groupID",
            "",
            "",
            "",
            "",
            "_requestPlayerID",
            "",
            "_side"
        ];

        private _currentTask = ["getGroupCurrentParentTask", [_groupID]] call MAINCLASS;

        // DIAG-STRIP (#992): says whether the replace branch below was entered at all. The
        // only delete in this flow sits inside it, so a log showing found=false on every
        // request is the whole of the reported fault. Gate: ALiVE_c2istar_taskDiag = true.
        if (!isNil "ALiVE_c2istar_taskDiag" && {ALiVE_c2istar_taskDiag}) then {
            ["[C2ISTAR #992 DIAG] requestOrder group=%1 replaceRequested=%2 foundCurrent=%3",
                _groupID, _replaceCurrent, !(_currentTask isEqualTo [])] call ALiVE_fnc_dump;
        };

        private _excludedPosition = [];
        private _excludedReservationKey = [];
        private _excludedGeneratedTaskTypes = [];
        private _excludedTaskRootID = "";

        if !(_currentTask isEqualTo []) then {
            private _taskID = _currentTask select 0;
            private _isPlayerOrderTask = _taskID find "OPORD_" == 0;
            private _currentTaskParams = ["getTaskManagedParams", [_taskID]] call MAINCLASS;
            private _taskSource = _currentTask param [12, "", [""]];

            if (_taskSource != "" && {!isNil "ALIVE_taskHandler"}) then {
                private _parsedTaskSource = [ALIVE_taskHandler, "parseTaskSource", _taskSource] call ALiVE_fnc_taskHandler;
                _parsedTaskSource params ["_rootTaskID", "_currentTaskType", ""];
                _excludedTaskRootID = _rootTaskID;

                if (_rootTaskID find "OPORD_AUTO_" == 0 && {_currentTaskType != ""}) then {
                    _excludedGeneratedTaskTypes pushBack _currentTaskType;
                };
            } else {
                _excludedTaskRootID = _taskID;
            };

            if !(_currentTaskParams isEqualTo []) then {
                _excludedPosition = [_currentTaskParams, "strategicObjectivePosition", []] call ALiVE_fnc_hashGet;
                _excludedReservationKey = [_currentTaskParams, "strategicReservationKey", []] call ALiVE_fnc_hashGet;
            };

            if (_excludedPosition isEqualTo []) then {
                _excludedPosition = _currentTask param [3, [], [[]]];
            };

            if !(_replaceCurrent) exitWith {
                ["notify", [_player, "Your group already has an active task."]] call MAINCLASS;
            };

            if !(_isPlayerOrderTask) exitWith {
                ["notify", [_player, "Your group already has a non-OPCOM task and cannot reroll it here."]] call MAINCLASS;
            };

            private _event = ["TASK_DELETE", [_taskID, _requestPlayerID, _side], "C2ISTAR"] call ALiVE_fnc_event;
            [ALIVE_eventLog, "addEvent", _event] call ALiVE_fnc_eventLog;
        };

        private _sideSettings = ["getSideSettings", [_side]] call MAINCLASS;
        private _enemyFaction = _sideSettings param [1, "OPF_F"];

        // The strategic path picks CaptureObjective / MilDefence from nearby OPCOM
        // objectives and never consults the C2ISTAR auto-task whitelist. Only try it when
        // one of those types is actually permitted (or the whitelist is empty/unset =
        // allow-all); otherwise go straight to the whitelist-respecting generator so an
        // OPCOM Order honours the module's selected tasks (#942). NB CaptureObjective is
        // strategic-only (not a selectable auto-task), so in practice this keys on whether
        // MilDefence is whitelisted.
        private _strategicAllowed = (isNil "ALIVE_autoGeneratedTasks")
            || {ALIVE_autoGeneratedTasks isEqualTo []}
            || {((ALIVE_autoGeneratedTasks apply {toUpper _x}) arrayIntersect ["CAPTUREOBJECTIVE","MILDEFENCE"]) isNotEqualTo []};

        private _created = false;
        if (_strategicAllowed) then {
            _created = ["createStrategicTaskForGroup", [_groupData, _enemyFaction, _excludedPosition, _excludedReservationKey]] call MAINCLASS;
        };

        if !(_created) then {
            _created = ["createGeneratedTaskForGroup", [_groupData, _enemyFaction, _excludedGeneratedTaskTypes, _excludedTaskRootID]] call MAINCLASS;
        };

        if (_created) then {
            ["notify", [_player, "OPCOM has assigned a new order to your group."]] call MAINCLASS;
        } else {
            ["notify", [_player, "OPCOM has no suitable order for your group right now."]] call MAINCLASS;
        };
    };
    case "toggleOptOut": {
        if !(isServer) exitWith {
            [_operation, _args] remoteExec ["ALiVE_fnc_playerOrders", 2];
        };

        _args params [
            ["_player", objNull, [objNull]]
        ];

        if (isNull _player) exitWith {};

        private _group = group _player;
        private _optedOut = !(_group getVariable [QGVAR(playerOrdersOptOut), false]);
        _group setVariable [QGVAR(playerOrdersOptOut), _optedOut, true];

        private _message = if (_optedOut) then {
            "Your group is now opted out of automatic OPCOM orders."
        } else {
            "Your group is now opted in to automatic OPCOM orders."
        };

        ["notify", [_player, _message]] call MAINCLASS;

        if (!_optedOut && {!isNil "ALIVE_taskHandler"}) then {
            private _groupData = ["getGroupData", [_player]] call MAINCLASS;

            if !(_groupData isEqualTo []) then {
                _groupData params [
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "_requestPlayerID",
                    "",
                    "_side",
                    "_faction"
                ];

                private _sideSettings = ["getSideSettings", [_side]] call MAINCLASS;
                private _autoGenerate = _sideSettings param [0, "None"];

                if (_autoGenerate == "Constant") then {
                    private _enemyFaction = _sideSettings param [1, "OPF_F"];
                    private _generate = [format ["%1_%2", _side, time], _requestPlayerID, _side, _faction, _enemyFaction, _autoGenerate];
                    [ALIVE_taskHandler, "autoGenerateTasks", _generate] call ALiVE_fnc_taskHandler;
                };
            };
        };
    };
    case "changeStance": {
        if !(isServer) exitWith {
            [_operation, _args] remoteExec ["ALiVE_fnc_playerOrders", 2];
        };

        _args params [
            ["_player", objNull, [objNull]],
            ["_newControlType", "", [""]]
        ];

        if (isNull _player) exitWith {};

        if !(_newControlType in ["invasion","occupation","asymmetric"]) exitWith {
            ["notify", [_player, "Invalid OPCOM stance."]] call MAINCLASS;
        };

        private _groupData = ["getGroupData", [_player]] call MAINCLASS;
        if (_groupData isEqualTo []) exitWith {
            ["notify", [_player, "OPCOM cannot identify your player group."]] call MAINCLASS;
        };

        _groupData params [
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "_side"
        ];

        if (isNil "OPCOM_instances") exitWith {
            ["notify", [_player, "No OPCOM is active in this mission."]] call MAINCLASS;
        };

        private _opcom = [nil, "findOPCOMByAllegiance", _side] call ALiVE_fnc_OPCOM;
        if (isNil "_opcom") exitWith {
            ["notify", [_player, "No OPCOM found for your side."]] call MAINCLASS;
        };

        private _currentStance = [_opcom, "controltype", ""] call ALiVE_fnc_hashGet;
        if (_newControlType == _currentStance) exitWith {
            ["notify", [_player, format ["OPCOM is already in %1 stance.", _newControlType]]] call MAINCLASS;
        };

        if !([_opcom, "startupComplete", false] call ALiVE_fnc_hashGet) exitWith {
            ["notify", [_player, "OPCOM is still starting up - try again shortly."]] call MAINCLASS;
        };

        // Latch against overlapping swaps: during the FSM teardown
        // startupComplete stays true and controltype stays old, so a second
        // request would pass every check above and interleave a second
        // teardown/rebuild against dying FSM handles.
        if ([_opcom, "stanceChangeInProgress", false] call ALiVE_fnc_hashGet) exitWith {
            ["notify", [_player, "OPCOM is already changing stance - please wait."]] call MAINCLASS;
        };
        [_opcom, "stanceChangeInProgress", true] call ALiVE_fnc_hashSet;

        ["notify", [_player, format ["OPCOM is changing stance to %1 - this may take a minute.", _newControlType]]] call MAINCLASS;

        // changeControlType suspends (waitUntil + sleep during FSM teardown),
        // so it must run scheduled - both the remoteExec arrival path and the
        // hosted-server menu path (buttonSetAction UI context) are unscheduled.
        [_opcom, _newControlType, _player] spawn {
            params ["_opcom", "_newControlType", "_player"];

            [_opcom, "changeControlType", [_newControlType]] call ALiVE_fnc_OPCOM;

            [_opcom, "stanceChangeInProgress", false] call ALiVE_fnc_hashSet;

            private _stance = [_opcom, "controltype", ""] call ALiVE_fnc_hashGet;
            private _message = if (_stance == _newControlType) then {
                format ["OPCOM stance is now %1.", _newControlType]
            } else {
                "OPCOM could not change stance - see the server log."
            };
            ["notify", [_player, _message]] call MAINCLASS;
        };
    };
};

_result
