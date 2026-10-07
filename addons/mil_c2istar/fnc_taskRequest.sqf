#include "\x\alive\addons\mil_c2istar\script_component.hpp"
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
string - OPTIONAL objectiveID the caller has already decided to act on

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
Jman

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
// The objective the caller has already committed to, when it knows one. Optional seventh
// argument, so existing six argument calls are unaffected.
private _callerObjectiveID = _args param [6, "", [""]];

// Check faction has strategic tasks turned on
private _autoGenerateStrategicTasks = false;

if (isNil "ALIVE_MIL_C2ISTAR") exitwith {
    ["PLAYER TASK REQUEST FAILED! NO C2ISTAR MODULE AVAILABLE!"] call ALiVE_fnc_dump;

    _autoGenerateStrategicTasks
};

private _logic = ALIVE_MIL_C2ISTAR;

if (_strategic) then {
    // A commander with several factions sends one of them at random, so a request counts when its
    // faction and the Friendly faction chosen for the side belong to the same commander, not only
    // when the two match. Before, most of such a commander's tasks were dropped.
    private _fnc_sameCommander = {
        params ["_requestFaction", "_chosenFaction"];
        if (_requestFaction == _chosenFaction) exitWith { true };
        ((missionNamespace getVariable ["OPCOM_instances", []]) findIf {
            _x isEqualType [] && {
                private _opcomFactions = [_x, "factions", []] call ALiVE_fnc_hashGet;
                (_requestFaction in _opcomFactions) && {_chosenFaction in _opcomFactions}
            }
        }) > -1
    };

    // The side's mode comes through getSideSettings, which reads the task handler's copy first:
    // that's the one the C2ISTAR tablet's auto-generate button changes. The module's setting only
    // ever holds what was set in the editor, so reading it here meant the tablet could neither
    // start nor stop Strategic tasks.
    private _sideMode = (["getSideSettings", [_side]] call ALiVE_fnc_playerOrders) param [0, "None"];

    // Check auto task generation is turned on for side and faction
    switch (_side) do {
        case "GUER": {
            private _autoGenerateINDFORFaction = [_logic, "autoGenerateIndforFaction"] call ALiVE_fnc_C2ISTAR;
            if (_sideMode == "Strategic" && {[_faction, _autoGenerateINDFORFaction] call _fnc_sameCommander}) then {_autoGenerateStrategicTasks = true};
        };
        case "EAST": {
            private _autoGenerateOPFORFaction = [_logic, "autoGenerateOpforFaction"] call ALiVE_fnc_C2ISTAR;
            if (_sideMode == "Strategic" && {[_faction, _autoGenerateOPFORFaction] call _fnc_sameCommander}) then {_autoGenerateStrategicTasks = true};
        };
        default {
            private _autoGenerateBLUFORFaction = [_logic, "autoGenerateBluforFaction"] call ALiVE_fnc_C2ISTAR;
            if (_sideMode == "Strategic" && {[_faction, _autoGenerateBLUFORFaction] call _fnc_sameCommander}) then {_autoGenerateStrategicTasks = true};
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

        // Use the objective the caller actually chose, rather than working it back out from
        // where the enemy happens to be standing. The derivation below asks which attacking
        // objective is nearest the target, which ties the claim to the search radius the
        // caller used: widen that radius and a target can be nearest a DIFFERENT attacking
        // objective, claiming the wrong one and sending players to the edge of somewhere
        // else. Callers that do not know their objective pass nothing and keep the old path.
        if !(_callerObjectiveID isEqualTo "") exitWith {_callerObjectiveID};

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

                // DIAG-STRIP (#992): pairs with the tag at the tablet's own mint site. Both
                // produce the same ID shape, so only the tag says which raised a given order.
                // Gate: ALiVE_c2istar_taskDiag = true.
                if (!isNil "ALiVE_c2istar_taskDiag" && {ALiVE_c2istar_taskDiag}) then {
                    ["[C2ISTAR #992 DIAG] minted by=COMMANDER id=%1 group=%2", _requestID, _groupID] call ALiVE_fnc_dump;
                };
                _taskFaction = _groupFaction;
                _taskPlayers = [_groupPlayerIDs, _groupPlayerNames];
                _apply = "Group";
            } else {
                private _autoOrderPlayers = ["getAutoOrderSidePlayers", [_side]] call ALiVE_fnc_playerOrders;

                if ((_autoOrderPlayers select 0) isEqualTo []) then {
                    _autoGenerateStrategicTasks = false;
                } else {
                    _taskPlayers = _autoOrderPlayers;
                    _apply = "Individual";
                };
            };
        };

        if (_autoGenerateStrategicTasks) then {
            if ([_logic,"debug"] call ALiVE_fnc_C2ISTAR) then {
                ["CREATING PLAYER TASK %1 %2", _args, [_requestID,_requestPlayerID,_side,_taskFaction,_type,"Map",_destination,_taskPlayers,_enemyFaction,_current,_apply,[_target]]] call ALIVE_fnc_dump;
            };

            private _targetArray = [_target];

            private _taskData = [_requestID,_requestPlayerID,_side,_taskFaction,_type,"Map",_destination,_taskPlayers,_enemyFaction,_current,_apply,_targetArray];

            // Carry the key this request actually reserved inside the payload, so generation
            // stores the same value rather than working it out again. generateTask re-derives
            // from the raw target, and on the commander route that target is a PROFILE, not an
            // objective. A profile carries no objectiveID, so the re-derivation falls through to
            // a bare position while this store holds the objectiveID resolved through OPCOM just
            // above. Release then looks for a position among ID strings and never matches, which
            // would leave that objective claimed for the rest of the mission.
            //
            // The mismatch is provable from source. The stranded claim it implies has NOT been
            // observed in play: on every session measured the store was empty when checked,
            // because the routes that deliver most tasks never reserve anything in the first
            // place. Treat this as closing a hole rather than as repairing a reported fault.
            //
            // Appended only for the two types that reserve anything. Index 12 already means
            // something else to other tasks: CAS reads friendly units there. CSAR carries its
            // pilots at index 11 instead ([pilot netIds, hull netId]) and never comes this way.
            if (_type in ["CaptureObjective", "MilDefence"] && {!isNil "_targetReservationKey"}) then {
                _taskData pushBack _targetReservationKey;
            };

            // Claimed here, once the order is certain to go out, rather than when the target was
            // picked. The list read above can be the store's own list rather than a copy, so adding
            // to it there claimed the objective on the spot, and when nobody turned out to be
            // taking orders (just above) no task was raised and nothing ever handed it back. Read
            // again rather than reusing that list, since another route may have written it since.
            private _heldTargets = [GVAR(playerRequests), _type, []] call ALiVE_fnc_hashGet;
            _heldTargets pushBack _targetReservationKey;
            [GVAR(playerRequests), _type, _heldTargets] call ALiVE_fnc_hashSet;

            private _event = ["TASK_GENERATE", _taskData, "C2ISTAR"] call ALIVE_fnc_event;
            [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
        };

    } else {
        _autoGenerateStrategicTasks = false;
    };
};

_autoGenerateStrategicTasks
