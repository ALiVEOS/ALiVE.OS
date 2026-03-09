#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(taskRequest);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_taskRequest

Description:
Send a task request to C2ISTAR

Parameters:
string - requesting side
string - requesting faction
string - type of task
array - targets (can be objects or string representing profile ID)
string - module or playerID making request
boolean - integrate with C2ISTAR auto task generation

Returns:
Boolean - if request was sent

Examples:
(begin example)
["WEST","BLU_F","CaptureObjective",["OPF-entity_14"],"OPCOM",true] call ALiVE_fnc_taskRequest;
(end)

See Also:
- nil

Author:
Tupolov

Peer reviewed:
nil
---------------------------------------------------------------------------- */
private _args = _this;

private _side = _args select 0; // Calling side
private _faction = _args select 1; // Calling faction
private _type = _args select 2; // Type of task
private _targets = _args select 3; // array of objects or profile IDs
private _playerID = _args select 4; // module name or player ID
private _strategic = _args select 5; // If this should integrate with C2ISTAR auto task generation functionality

// Check faction has strategic tasks turned on
private _autoGenerateStrategicTasks = false;

if (isNil "ALIVE_MIL_C2ISTAR") exitwith {
    ["PLAYER TASK REQUEST FAILED! NO C2ISTAR MODULE AVAILABLE!"] call ALiVE_fnc_dump;

    _autoGenerateStrategicTasks
};

private _logic = ALIVE_MIL_C2ISTAR;

if (_strategic) then {
    // Check auto task generation is turned on for side and faction
    switch (_side) do {
        case "GUER": {
            private _autoGenerateINDFOR = [_logic, "autoGenerateIndfor"] call ALiVE_fnc_C2ISTAR;
            private _autoGenerateINDFORFaction = [_logic, "autoGenerateIndforFaction"] call ALiVE_fnc_C2ISTAR;
            if (_autoGenerateINDFOR == "Strategic" && {_faction == _autoGenerateINDFORFaction}) then {_autoGenerateStrategicTasks = true};
        };
        case "EAST": {
            private _autoGenerateOPFOR = [_logic, "autoGenerateOpfor"] call ALiVE_fnc_C2ISTAR;
            private _autoGenerateOPFORFaction = [_logic, "autoGenerateOpforFaction"] call ALiVE_fnc_C2ISTAR;
            if (_autoGenerateOPFOR == "Strategic" && {_faction == _autoGenerateOPFORFaction}) then {_autoGenerateStrategicTasks = true};
        };
        default {
            private _autoGenerateBLUFOR = [_logic, "autoGenerateBlufor"] call ALiVE_fnc_C2ISTAR;
            private _autoGenerateBLUFORFaction = [_logic, "autoGenerateBluforFaction"] call ALiVE_fnc_C2ISTAR;
            if (_autoGenerateBLUFOR == "Strategic" && {_faction == _autoGenerateBLUFORFaction}) then {_autoGenerateStrategicTasks = true};
        };
    };

} else {
    _autoGenerateStrategicTasks = true;
};

if (_autoGenerateStrategicTasks) then {

    if (isNil QGVAR(playerRequests)) then {
        GVAR(playerRequests) = [] call ALiVE_fnc_hashCreate;
    };

    private _getTargetData = {
        params ["_target"];

        private _destination = [];
        private _enemyFaction = "OPF_F";

        switch (typeName _target) do {
            case "STRING": {
                private _targetProfile = [ALiVE_profileHandler, "getProfile", _target] call ALiVE_fnc_ProfileHandler;

                if !(isNil "_targetProfile") then {
                    _destination = [_targetProfile, "position"] call ALiVE_fnc_hashGet;
                    _enemyFaction = [_targetProfile, "faction"] call ALiVE_fnc_hashGet;
                };
            };
            case "OBJECT": {
                _destination = position _target;
                _enemyFaction = faction _target;
            };
            case "ARRAY": {
                _destination = [_target, "position", []] call ALiVE_fnc_hashGet;
                if (_destination isEqualTo []) then {
                    _destination = [_target, "center", []] call ALiVE_fnc_hashGet;
                };
                _enemyFaction = [_target, "faction"] call ALiVE_fnc_hashGet;
            };
        };

        [_destination, _enemyFaction]
    };

    private _getObjectiveReservationKey = {
        params ["_objective", "_fallbackPos"];

        switch (typeName _objective) do {
            case "ARRAY": {
                private _objectiveID = [_objective, "objectiveID", ""] call ALiVE_fnc_hashGet;
                if !(_objectiveID isEqualTo "") exitWith {_objectiveID};

                private _clusterID = [_objective, "clusterID", ""] call ALiVE_fnc_hashGet;
                if !(_clusterID isEqualTo "") exitWith {_clusterID};

                [_objective, "center", _fallbackPos] call ALiVE_fnc_hashGet
            };
            case "OBJECT": {
                position _objective
            };
            default {
                _objective
            };
        };
    };

    private _getStrategicReservationKey = {
        params ["_taskType", "_taskFaction", "_destination", "_target"];

        private _reservationKey = [_target, _destination] call _getObjectiveReservationKey;

        if !(_taskType in ["CaptureObjective", "MilDefence"]) exitWith {_reservationKey};
        if (_destination isEqualTo []) exitWith {_reservationKey};

        private _objectiveState = switch (_taskType) do {
            case "MilDefence": {"defending"};
            default {"attacking"};
        };

        private _opcom = [];
        {
            if (_x isEqualType []) then {
                if (_taskFaction in ([_x, "factions", []] call ALiVE_fnc_hashGet)) exitWith {
                    _opcom = _x;
                };
            };
        } forEach (missionNamespace getVariable ["OPCOM_instances", []]);

        if (_opcom isEqualTo []) exitWith {_reservationKey};

        private _objectives = +([_opcom, "nearestObjectives", [_destination, _objectiveState]] call ALiVE_fnc_OPCOM);
        if (_objectives isEqualTo []) exitWith {_reservationKey};

        [(_objectives select 0), _destination] call _getObjectiveReservationKey
    };

    // Check to see if this target has already been handed to players
    private _target = nil;
    private _targetReservationKey = nil;
    private _targetData = [];
    private _selectedGroup = [];
    private _currentTargets = [GVAR(playerRequests),_type,[]] call ALiVE_fnc_hashGet;

    {
        private _candidateTarget = _x;
        private _candidateTargetData = [_candidateTarget] call _getTargetData;
        private _candidateDestination = _candidateTargetData select 0;
        private _candidateTaskFaction = _faction;
        private _candidateSelectedGroup = [];

        if (_playerID == "OPCOM") then {
            _candidateSelectedGroup = ["selectEligibleGroup", [_side, _faction, _candidateDestination]] call ALiVE_fnc_playerOrders;

            if !(_candidateSelectedGroup isEqualTo []) then {
                _candidateTaskFaction = _candidateSelectedGroup select 9;
            };
        };

        private _candidateReservationKey = [_type, _candidateTaskFaction, _candidateDestination, _candidateTarget] call _getStrategicReservationKey;

        if !(_candidateReservationKey in _currentTargets) exitWith {
            _target = _candidateTarget;
            _targetReservationKey = _candidateReservationKey;
            _targetData = _candidateTargetData;
            _selectedGroup = _candidateSelectedGroup;
        };
    } foreach _targets;

    if !(isNil "_target") then {

        _currentTargets pushBack _targetReservationKey;

        private _destination = _targetData param [0, []];
        private _enemyFaction = _targetData param [1, "OPF_F"];

        private _requestID = format["%1_%2",_faction,floor(time)];
        private _requestPlayerID = _playerID;
        private _taskFaction = _faction;

        // All players in side
        private _sidePlayers = [_side] call ALiVE_fnc_getPlayersDataSource;
        _sidePlayers = [_sidePlayers select 1, _sidePlayers select 0];

        private _taskPlayers = _sidePlayers;
        private _current = "Y";
        private _apply = "Side";

        // Prefer assigning a strategic task directly to an eligible player group.
        if (_playerID == "OPCOM") then {
            if !(_selectedGroup isEqualTo []) then {
                _selectedGroup params [
                    "",
                    "_groupID",
                    "",
                    "_groupPlayerIDs",
                    "_groupPlayerNames",
                    "",
                    "",
                    "",
                    "",
                    "_groupFaction"
                ];

                _requestID = format["OPORD_%1_%2", _groupID, floor (diag_tickTime * 10)];
                _taskFaction = _groupFaction;
                _taskPlayers = [_groupPlayerIDs, _groupPlayerNames];
                _apply = "Group";
            } else {
                private _autoOrderPlayers = ["getAutoOrderSidePlayers", [_side]] call ALiVE_fnc_playerOrders;

                if ((_autoOrderPlayers select 0) isEqualTo []) then {
                    _autoGenerateStrategicTasks = false;
                } else {
                    if (count (_autoOrderPlayers select 0) != count (_sidePlayers select 0)) then {
                        _taskPlayers = _autoOrderPlayers;
                        _apply = "Individual";
                    };
                };
            };
        };

        if (_autoGenerateStrategicTasks) then {
            if ([_logic,"debug"] call ALiVE_fnc_C2ISTAR) then {
                ["CREATING PLAYER TASK %1 %2", _args, [_requestID,_requestPlayerID,_side,_taskFaction,_type,"Map",_destination,_taskPlayers,_enemyFaction,_current,_apply,[_target]]] call ALIVE_fnc_dump;
            };

            private _targetArray = [_target];

            private _taskData = [_requestID,_requestPlayerID,_side,_taskFaction,_type,"Map",_destination,_taskPlayers,_enemyFaction,_current,_apply,_targetArray];

            [GVAR(playerRequests), _type, _currentTargets] call ALiVE_fnc_hashSet;

            private _event = ["TASK_GENERATE", _taskData, "C2ISTAR"] call ALIVE_fnc_event;
            [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
        };

    } else {
        _autoGenerateStrategicTasks = false;
    };
};

_autoGenerateStrategicTasks
