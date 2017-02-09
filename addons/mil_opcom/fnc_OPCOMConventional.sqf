//#define DEBUG_MODE_FULL
#include <\x\ALiVE\addons\mil_opcom\script_component.hpp>
SCRIPT(OPCOMConventional);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_OPCOMConventional
Description:
Virtual AI Controller

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:

Examples:

Author:
SpyderBlack / Highhead

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALiVE_fnc_OPCOM
#define MAINCLASS   ALiVE_fnc_OPCOMConventional

#define MTEMPLATE "ALiVE_OPCOM_%1"

TRACE_1("OPCOM Conventional - input", _this);

private "_result";

params [
    ["_logic", objNull, [objNull,[],""]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];


switch(_operation) do {

    case "postStart": {

        _logic setVariable ["super", QUOTE(SUPERCLASS)];
        _logic setVariable ["class", QUOTE(MAINCLASS)];

        private _listenerID = [_logic,"listen", []] call MAINCLASS;
        _logic setvariable ["listenerID", _listenerID];

    };

    case "listen": {

        private _filters = _args;

        private _listenerID = [MOD(eventLog),"addListener", [_logic, _filters]] call ALIVE_fnc_eventLog;

        _result = _listenerID;

    };

    case "handleEvent": {

        private _event = _args;

        private _type = [_event, "type"] call ALIVE_fnc_hashGet;
        private _data = [_event, "data"] call ALIVE_fnc_hashGet;

        switch (_type) do {



        };

    };

    case "cycle": {

        private _handler = [_logic,"handler"] call MAINCLASS;

        private _debug = [_handler,"debug"] call ALiVE_fnc_hashGet;

        // begin cycling

        while {!isnil "_logic" && {!(_logic getvariable ["stopped", false])}} do {

            private _paused = _logic getvariable ["paused", false];

            if (!_paused) then {

                private _cycleStartTime = time;

                // fire cycle start event here

                // scan battlefield and update info


                private _friendlyTroops = [_logic,"scanTroops"] call MAINCLASS;

                [_handler,"forces", _friendlyTroops] call ALiVE_fnc_hashSet;

                private _countFriendlyTroops = [_logic,"countSortedProfiles", _friendlyTroops] call MAINCLASS;
                [_handler,"currentForceStrength", _countFriendlyTroops] call ALiVE_fnc_HashSet;

                // update known units
                // opcom should only act upon enemies it knows exist

                private _visibleEnemies = [_logic,"getVisibleEnemies"] call MAINCLASS;

                [_handler,"knownEnemies", _visibleEnemies] call ALiVE_fnc_hashSet;

                // get cluster occupation

                _friendlyTroops = [_logic,"condenseSortedProfiles", _friendlyTroops] call MAINCLASS;
                _visibleEnemies = [_logic,"condenseSortedProfiles", _visibleEnemies] call MAINCLASS;

                private _objectives = [_handler,"objectives"] call ALIVE_fnc_hashGet;

                private _friendlyTroopEntities = [_logic,"sortProfilesEntities", _friendlyTroops] call MAINCLASS;
                private _enemyTroopEntities = [_logic,"sortProfilesEntities", _visibleEnemies] call MAINCLASS;

                private _objectiveOccupationData = [_logic,"getObjectiveOccupation", [_objectives, [_friendlyTroopEntities,_enemyTroopEntities]]] call MAINCLASS;

                // TODO: evaluate active tasks success and logic here

                // TODO: filter out objectives involved in existing tasks

                private _objectiveStateData = [_logic,"assignObjectiveStates", _objectiveOccupationData] call MAINCLASS;

                if (_debug) then {
                    ["ALiVE - OPCOM: Cycle completed in %1 seconds", time - _cycleStartTime] call ALiVE_fnc_Dump;
                };

            };

        };

    };

    case "assignObjectiveStates": {

        private _occupationData = _args;

        private _startTime = time;

        private _handler = [_logic,"handler"] call MAINCLASS;

        private _debug = [_handler,"debug"] call ALiVE_fnc_hashGet;

        // get average objective priority

        private _objectives = [_handler,"objectives"] call ALiVE_fnc_hashGet;
        private _averageObjectivePriority = 0;

        {
            _averageObjectivePriority = _averageObjectivePriority + ([_x,"priority"] call ALiVE_fnc_hashGet);
        } foreach _objectives;

        _averageObjectivePriority = _averageObjectivePriority / (count _objectives);

        private _maxActiveReconTasks = [_handler,"maxActiveReconTasks"] call ALiVE_fnc_hashGet;
        private _maxActiveStrikeTasks = [_handler,"maxActiveStrikeTasks"] call ALiVE_fnc_hashGet;
        private _maxActiveAttackTasks = [_handler,"maxActiveAttackTasks"] call ALiVE_fnc_hashGet;

        private _activeTasks = [_handler,"activeTasks"] call ALiVE_fnc_hashGet;
        (_activeTasks select 2) params ["_activeReconTasks","_activeStrikeTasks","_activeAttackTasks","_activeDefendTasks"];

        private _countForAttack = [_handler,"profileAmountAttack"] call ALiVE_fnc_hashGet;
        private _countForDefend = [_handler,"profileAmountDefend"] call ALiVE_fnc_hashGet;
        private _countForHold = [_handler,"profileAmountHold"] call ALiVE_fnc_hashGet;

        private _objectivesToRecon = [];
        private _objectivesToStrike = [];
        private _objectivesToAttack = [];
        private _objectivesToDefend = [];
        private _objectivesToHold = [];
        private _objectivesToReinforce = [];
        private _objectivesToIdle = [];

        {
            _x params ["_objective","_nearProfiles"];

            _nearProfiles params ["_nearFriendlies","_nearEnemies"];

            private _nearFriendlyCount = count _nearFriendlies;
            private _nearEnemyCount = count _nearEnemies;
            private _netEnemyCount = _nearEnemyCount - _nearFriendlyCount;

            private _previousState = [_objective,"opcomState", "idle"] call ALiVE_fnc_hashGet;
            private _timeLastRecon = [_objective,"timeLastRecon", 0] call ALiVE_fnc_hashGet;
            private _objectivePriority = [_objective,"priority"] call ALiVE_fnc_hashGet;

            private _newState = "idle";

            switch (_previousState) do {

                case "recon": {

                    if (_netEnemyCount > 2) then {
                        // TODO: check if there are appropriate groups available for a strike
                        // if not, revert to idle or attack

                        _newState = "strike";
                    } else {
                        // TODO: check if there are enough groups available for an attack
                        // if not, revert to idle

                        _newState = "attack";
                    };

                };

                case "strike": {

                    if (_netEnemyCount > 2) then {
                        private _consecutiveStrikeTasks = [_objective,"consecutiveStrikeTasks", 0] call ALiVE_fnc_hashGet;

                        if (_consecutiveStrikeTasks <= 2) then {
                            // TODO: check if there are appropriate groups available for a strike
                            // if not, revert to idle or attack

                            _newState = "strike";

                            [_objective,"consecutiveStrikeTasks", _consecutiveStrikeTasks + 1] call ALiVE_fnc_hashSet;
                        } else {
                            // TODO: check if there are enough groups available for an attack
                            // if not, revert to idle

                            _newState = "attack";
                        };
                    } else {
                        // TODO: check if there are enough groups available for an attack
                        // if not, revert to idle

                        _newState = "attack";
                    };

                };

                case "attack": {

                    if (_netEnemyCount < 0) then {

                    } else {

                    };

                };

                case "hold": {

                    if (_nearFriendlyCount == 0) then {
                        _newState = "idle";
                    } else {
                        if (_netEnemyCount >= 2) then {
                            _newState = "retreat";
                        } else {
                            if (_nearFriendlyCount - _nearEnemyCount < _countForHold) then {
                                if (_nearEnemyCount > 0) then {
                                    _newState = "defend";
                                } else {
                                    _newState = "reinforce";
                                };
                            } else {
                                _newState = "hold";
                            };

                        };
                    };

                };

                case "defend": {

                    if (_nearEnemyCount > 0) then {
                        if (_netEnemyCount >= 2) then {
                            _newState = "retreat";
                        } else {
                            private _objectivePriority = [_objective,"priority"] call ALiVE_fnc_hashGet;
                            private _consecutiveDefendTasks = [_objective,"consecutiveDefendTasks", 0] call ALiVE_fnc_hashGet;

                            if (_nearFriendlyCount - _nearEnemyCount < _countForHold && {_objectivePriority > _averageObjectivePriority} && {_consecutiveDefendTasks < 2}) then {
                                _newState = "defend";

                                [_objective,"consecutiveDefendTasks", _consecutiveDefendTasks + 1] call ALiVE_fnc_hashSet;
                            } else {
                                _newState = "hold";
                            };
                        };
                    } else {
                        if (_nearFriendlyCount < _countForHold) then {
                            _newState = "reinforce";
                        } else {
                            _newState = "hold";
                        };
                    };

                };

                case "reinforce": {

                    if (_nearFriendlyCount == 0) then {
                        _newState = "idle";
                    } else {
                        _newState = "hold";
                    };

                };

                case "retreat": {

                    _newState = "idle";

                };

                case "idle": {

                    if (_nearFriendlyCount == 0 && {_nearEnemyCount == 0} && {(count _objectivesToRecon) + (count _activeReconTasks) < _maxActiveReconTasks}) then {
                        _newState = "recon";
                    } else {
                        _newState = "idle";
                    };

                };

            };

            switch (_newState) do {
                case "recon": {_objectivesToRecon pushback _objective};
                case "strike": {_objectivesToStrike pushback _objective};
                case "attack": {_objectivesToAttack pushback _objective};
                case "defend": {_objectivesToDefend pushback _objective};
                case "hold": {_objectivesToHold pushback _objective};
                case "reinforce": {_objectivesToReinforce pushback _objective};
                case "idle": {_objectivesToIdle pushback _objective};
            };

            [_objective,"opcomState", _newState] call MAINCLASS;

            // set state
            // fire event if significant state change
            // etc fire event if objective goes from hold to defend
            // if objective goes from idle to attack
            // if objective goes from idle to recon
        } foreach _occupationData;

        private _objectivesByState = [
            [
                ["recon", _objectivesToRecon],
                ["strike", _objectivesToStrike],
                ["attack", _objectivesToAttack],
                ["defend", _objectivesToDefend],
                ["hold", _objectivesToHold],
                ["idle", _objectivesToIdle]
            ]
        ] call ALiVE_fnc_hashCreate;

        _result = _objectivesByState;

        if (_debug) then {
            ["ALiVE OPCOM - getObjectiveOccupation: time taken: %1 seconds", time - _startTime] call ALiVE_fnc_Dump;
        };

    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };

};

TRACE_1("OPCOM Conventional - output", _result);

if !(isnil "_result") then {_result} else {nil};