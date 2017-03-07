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

                // TODO: attack known entities closest to friendly objectives
                // if vehicle -- attack with vehicle : vice versa for infantry

                if (_debug) then {
                    ["ALiVE - OPCOM: Cycle completed in %1 seconds", time - _cycleStartTime] call ALiVE_fnc_Dump;
                };

            };

        };

    };

    case "cycleStart": {

        // cycle start event

    };

    case "updateFriendlyForces": {

        private _handler = [_logic,"handler"] call MAINCLASS;

        private _friendlyTroops = [_logic,"scanTroops"] call MAINCLASS;

        [_handler,"forces", _friendlyTroops] call ALiVE_fnc_hashSet;

        private _countFriendlyTroops = [_logic,"countSortedProfiles", _friendlyTroops] call MAINCLASS;
        [_handler,"currentForceStrength", _countFriendlyTroops] call ALiVE_fnc_HashSet;

    };

    case "updateEnemyForces": {

        private _handler = [_logic,"handler"] call MAINCLASS;

        private _visibleEnemies = [_logic,"getVisibleEnemies"] call MAINCLASS;

        [_handler,"knownEnemies", _visibleEnemies] call ALiVE_fnc_hashSet;

    };

    case "updateObjectiveState": {

        // get next state for objective
        // no checking for available units
        // or assigning of tasks done in this step

        _args params ["_occupationData",["_statesCount", []]];

        private _startTime = time;

        private _handler = [_logic,"handler"] call MAINCLASS;

        if (_statesCount isEqualTo []) then {
            _statesCount = [_handler,"objectiveStatesCount"] call ALiVE_fnc_hashGet;
        };

        private _debug = [_handler,"debug"] call ALiVE_fnc_hashGet;
        private _averageObjectivePriority = [_handler,"averageObjectivePriority"] call ALiVE_fnc_hashGet;

        private _countForAttack = [_handler,"profileAmountAttack"] call ALiVE_fnc_hashGet;
        private _countForDefend = [_handler,"profileAmountDefend"] call ALiVE_fnc_hashGet;
        private _countForHold = [_handler,"profileAmountHold"] call ALiVE_fnc_hashGet;

        private _maxActiveReconTasks = [_handler,"maxActiveReconTasks"] call ALiVE_fnc_hashGet;
        private _maxActiveStrikeTasks = [_handler,"maxActiveStrikeTasks"] call ALiVE_fnc_hashGet;
        private _maxActiveAttackTasks = [_handler,"maxActiveAttackTasks"] call ALiVE_fnc_hashGet;

        private _activeTasks = [_handler,"activeTasks"] call ALiVE_fnc_hashGet;
        (_activeTasks select 2) params ["_activeReconTasks","_activeStrikeTasks","_activeAttackTasks","_activeDefendTasks"];

        _statesCount params ["_assignedIdle","_assignedRecon","_assignedStrike","_assignedAttack","_assignedHold","_assignedDefend","_assignedReinforce"];

        _occupationData params ["_objective","_nearProfiles"];

        _nearProfiles params ["_nearFriendlies","_nearEnemies"];

        private _nearFriendlyCount = count _nearFriendlies;
        private _nearEnemyCount = count _nearEnemies;
        private _netEnemyCount = _nearEnemyCount - _nearFriendlyCount;

        private _previousState = [_objective,"opcomState", "idle"] call ALiVE_fnc_hashGet;
        private _objectivePriority = [_objective,"priority"] call ALiVE_fnc_hashGet;

        private _newState = "idle";

        switch (_previousState) do {

            // DONE

            case "idle": {

                if (_nearEnemyCount > 0) then {
                    if (_netEnemyCount > 0) then {
                        if (_assignedAttack + (count _activeAttackTasks) < _maxActiveAttackTasks) then {
                            _newState = "attack";
                        } else {
                            _newState = "idle";
                        };
                    } else {
                        _newState = "reinforce";
                    };
                } else {
                    if (_nearFriendlyCount > 0) then {
                        if ((_countForHold - _nearFriendlyCount) > 0) then {
                            _newState = "reinforce";
                        };
                    } else {
                        private _timeLastRecon = [_objective,"timeLastRecon", 0] call ALiVE_fnc_hashGet;
                        private _recentlyRecon = time - _timeLastRecon < (60 * 5);

                        if (!_recentlyRecon && {_assignedRecon + (count _activeReconTasks) < _maxActiveReconTasks}) then {
                            _newState = "recon";
                        } else {
                            if (_recentlyRecon) then {
                                _newState = "reinforce";
                            } else {
                                _newState = "idle";
                            };
                        };
                    };
                };

            };

            // DONE

            case "recon": {

                if (_netEnemyCount > 2) then {
                    private _consecutiveStrikeTasks = [_objective,"consecutiveStrikeTasks", 0] call ALiVE_fnc_hashGet;

                    if (_consecutiveStrikeTasks < 2) then {
                        _newState = "strike";
                    } else {
                        _newState = "idle";
                    };
                } else {
                    _newState = "attack";
                };

            };

            case "strike": {

                if (_netEnemyCount > 2) then {
                    private _consecutiveStrikeTasks = [_objective,"consecutiveStrikeTasks", 0] call ALiVE_fnc_hashGet;

                    if (_consecutiveStrikeTasks < 2) then {
                        _newState = "strike";

                        [_objective,"consecutiveStrikeTasks", _consecutiveStrikeTasks + 1] call ALiVE_fnc_hashSet;
                    } else {
                        _newState = "attack";
                    };
                } else {
                    if (_nearEnemyCount > 0) then {
                        _newState = "attack";
                    } else {
                        _newState = "reinforce";
                    };
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
                        _newState = "withdraw";
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
                        _newState = "withdraw";
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

            case "withdraw": {

                _newState = "idle";

            };

        };

        [_objective,"opcomState", _newState] call ALiVE_fnc_hashSet;
        [_objective,"currentStateHandled", false] call ALiVE_fnc_hashSet;

        if (_previousState != _newState) then {
            // fire event if state changes
        };

        _result = [_objective,_previousState,_newState,_nearProfiles];

        if (_debug) then {
            ["ALiVE OPCOM - updateObjectiveState: time taken: %1 seconds", time - _startTime] call ALiVE_fnc_Dump;
        };

    };

    case "validateObjectiveState": {

        private _objectiveStateData = _args;

        private _handler = [_logic,"handler"] call MAINCLASS;

        _objectiveStateData params ["_objective","_previousState","_newState","_nearProfiles"];

        _nearProfiles params ["_nearFriendlies","_nearEnemies"];

        // copy forces array so we can modify it

        private _friendlyForces = +([_handler,"forces"] call ALiVE_fnc_hashGet);
        (_friendlyForces select 2) params [
            "_infantry",
            "_specOps",
            "_motorized",
            "_mechanized",
            "_armored",
            "_artillery",
            "_AAA",
            "_air",
            "_airArmed",
            "_sea"
        ];

        // ensure there are enough troops of the appropriate state available
        // grab recommended units if possible

        private _troops = [];

        switch (_newState) do {

            case "idle": {

                _troops = _nearFriendlies;

            };

            case "recon": {

                private _validUnitTypes = [_specOps,_air];

                {
                    if (_troops isEqualTo []) then {
                        if !(_x isEqualTo []) then {
                            _troops pushback (_x select 0);
                        };
                    };
                } foreach _validUnitTypes;

            };

            case "strike": {

                private _objectivePriority = [_objective,"priority"] call ALiVE_fnc_hashGet;
                private _maxTroopCount = 1;

                if (_objectivePriority >= 100) then {
                    _maxTroopCount = 2;
                };

                private _validUnitTypes = [_airArmed]; // artillery units cannot attack from ranged yet

                {
                    if (count _troops <= _maxTroopCount) then {
                        if !(_x isEqualTo []) then {
                            _troops pushback (_x select 0);
                        };
                    };
                } foreach _validUnitTypes;

            };

            case "attack": {

                // see file on desktop for assembling an "anti" composition

            };

            case "hold": {

                _troops = _nearFriendlies;

            };

            case "defend": {

                private _countForDefend = (count _nearEnemies) - (count _nearFriendlies);

                if (_countForDefend > 0) then {

                    // All Types: inf, specops, mot, mech, arm, arty, aaa, air, air armed, sea
                    // Preferred: mot, mech, arm, inf

                    private _typesByPriority = [2,3,4,0];

                    {
                        private _troopCount = count _troops;

                        if (_troopCount < _countForHold) then {
                            private _typeUnits = (_friendlyForces select 2) select _x;

                            while {_troopCount < _countForHold && {!(_typeUnits isEqualTo [])}} do {
                                _troops pushback (_typeUnits select 0);
                                _typeUnits deleteat 0;
                                _troopCount = _troopCount + 1;
                            };
                        };
                    } foreach _typesByPriority;
                } else {
                    _newState = "hold";
                };

            };

            case "reinforce": {

                private _countForHold = [_handler,"profileAmountHold"] call ALiVE_fnc_hashGet;

                // All Types: inf, specops, mot, mech, arm, arty, aaa, air, air armed, sea
                // Preferred: inf, mot, mech, arm

                private _typesByPriority = [0,2,3,4];

                {
                    private _troopCount = count _troops;

                    if (_troopCount < _countForHold) then {
                        private _typeUnits = (_friendlyForces select 2) select _x;

                        while {_troopCount < _countForHold && {!(_typeUnits isEqualTo [])}} do {
                            _troops pushback (_typeUnits select 0);
                            _typeUnits deleteat 0;
                            _troopCount = _troopCount + 1;
                        };
                    };
                } foreach _typesByPriority;

            };

            case "withdraw": {

                _troops = _nearFriendlies;

            };

        };

        if (_newState != _newState) then {
            _objectiveStateData set [2,_newState];
        };

        _objectiveStateData pushback _troops;

    };

    case "cycleEnd": {

        _logic setvariable ['lastCycleEndTime', time];

    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };

};

TRACE_1("OPCOM Conventional - output", _result);

if !(isnil "_result") then {_result} else {nil};