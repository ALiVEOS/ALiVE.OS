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

    case "cycleStart": {

        // cycle start event

    };

    case "updateFriendlyForces": {

        private _handler = [_logic,"handler"] call MAINCLASS;

        private _debug = [_handler,"debug"] call ALiVE_fnc_hashGet;
        private _startTime = diag_tickTime;

        private _friendlyTroops = [_logic,"scanTroops"] call MAINCLASS;

        [_handler,"forces", _friendlyTroops] call ALiVE_fnc_hashSet;

        private _countFriendlyTroops = [_logic,"countSortedProfiles", _friendlyTroops] call MAINCLASS;
        [_handler,"currentForceStrength", _countFriendlyTroops] call ALiVE_fnc_HashSet;

        if (_debug) then {
            ["[ALiVE] OPCOM - %1 time taken: %2 ms", _operation, diag_tickTime - _startTime] call ALiVE_fnc_Dump;
        };

    };

    case "updateEnemyForces": {

        private _handler = [_logic,"handler"] call MAINCLASS;

        private _debug = [_handler,"debug"] call ALiVE_fnc_hashGet;
        private _startTime = diag_tickTime;

        private _visibleEnemies = [_logic,"getVisibleEnemies"] call MAINCLASS;

        [_handler,"knownEnemies", _visibleEnemies] call ALiVE_fnc_hashSet;

        if (_debug) then {
            ["[ALiVE] OPCOM - %1 time taken: %2 ms", _operation, diag_tickTime - _startTime] call ALiVE_fnc_Dump;
        };

    };

    case "updateObjectiveState": {

        // get next state for objective
        // no checking for available units
        // or assigning of tasks done in this step

        _args params ["_occupationData",["_statesCount", []]];

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
                        if (_countForHold - _nearFriendlyCount > 0) then {
                            _newState = "reinforce";
                        } else {
                            _newState = "hold";
                        };
                    } else {
                        private _timeLastRecon = [_objective,"timeLastRecon", -1] call ALiVE_fnc_hashGet;
                        private _recentRecon = _timeLastRecon != -1 && {time - _timeLastRecon < (60 * 5)};

                        if (!_recentRecon && {_assignedRecon + (count _activeReconTasks) < _maxActiveReconTasks}) then {
                            _newState = "recon";
                        } else {
                            if (_recentRecon) then {
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
                        _newState = "attack";
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
                    private _consecutiveAttackTasks = [_objective,"consecutiveAttackTasks", 0] call ALiVE_fnc_hashGet;

                    if (_consecutiveAttackTasks < 2) then {
                        _newState = "attack";

                        [_objective,"consecutiveAttackTasks", _consecutiveAttackTasks + 1] call ALiVE_fnc_hashSet;
                    } else {
                        _newState = "idle";
                    };
                } else {
                    if (_nearFriendlyCount > 0) then {
                        if (_countForHold -  _nearFriendlyCount > 0) then {
                            _newState = "reinforce";
                        } else {
                            _newState = "hold";
                        };
                    } else {
                        _newState = "attack";
                    };
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

        // TODO: Set later on after validation - [_objective,"opcomState", _newState] call ALiVE_fnc_hashSet;
        // TODO: Do we need this? - [_objective,"currentStateHandled", false] call ALiVE_fnc_hashSet;

        if (_previousState != _newState) then {
            // fire event if state changes
        };

        _result = [_objective,_nearProfiles,_previousState,_newState];

    };

    case "validateObjectiveState": {

        private _objectiveStateData = _args;

        private _handler = [_logic,"handler"] call MAINCLASS;

        _objectiveStateData params ["_objective","_nearProfiles","_previousState","_newState"];

        private _objectivePos = [_objective,"center"] call ALiVE_fnc_hashGet;

        // _previousState = state as of last opcom cycle
        // _newState = state as recommended by opcom for new cycle
        // _validatedState = state after checking if available units are available

        _nearProfiles params ["_nearFriendlies","_nearEnemies"];

        // copy forces array so we can modify it

        private _friendlyForces = +([_handler,"forces"] call ALiVE_fnc_hashGet);
        _friendlyForces = [_logic,"sortSortedProfilesByDistance", [_friendlyForces,_objectivePos]] call MAINCLASS;

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
        private _validatedState = _newState;

        switch (_newState) do {

            // always valid

            case "idle": {

                _troops = _nearFriendlies;

            };

            // check if at least one recon-capable group is available
            // fall back to idle if not

            case "recon": {

                private _validUnitTypes = [_specOps,_air];

                {
                    if (_troops isEqualTo []) then {
                        if !(_x isEqualTo []) then {
                            _troops pushback (_x select 0);
                        };
                    };
                } foreach _validUnitTypes;

                if !(_troops isEqualTo []) then {
                    _validatedState = "idle";
                };

            };

            // check if at least one strike-capable group is available
            // fall back to idle if not

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

                if (count _troops == 0) then {
                    _validatedState = "idle";
                };

            };

            case "attack": {

                // see file on desktop for assembling an "anti" composition

                private _weaknessesByType = [_handler,"profileWeaknessesByType"] call ALiVE_fnc_hashGet;

                private _nearEnemiesSorted = [_logic,"sortProfilesByType", _nearEnemies] call MAINCLASS;
                private _nearFriendliesSorted = [_logic,"sortProfilesByType", _nearFriendlies] call MAINCLASS;

                _nearEnemiesSorted = [_logic,"subtractSortedProfiles", [_nearEnemies,_nearFriendlies]] call MAINCLASS;

                private _countUnmatched = 0; // how many enemy profiles weren't matched with a friendly profile

                {
                    private _countToGet = count _x;

                    if (_countToGet > 0) then {
                        private _typeWeaknesses = (_weaknessesByType select 2) select _forEachIndex;

                        {
                            private _typeUnits = [_friendlyForces, _x] call ALiVE_fnc_hashGet;

                            while {_countToGet > 0 && {count _typeUnits > 0}} do {
                                _troops pushback (_typeUnits select 0);
                                _typeUnits deleteat 0;

                                _countToGet = _countToGet - 1;
                            };
                        } foreach _typeWeaknesses;

                        _countUnmatched = _countUnmatched + _countToGet;
                    };
                } foreach _nearEnemiesSorted;

                if (_countUnmatched >= 2) then {
                    private _countEnemies = 0;
                    {_countEnemies = _countEnemies + (count _x)} foreach _nearEnemies;

                    private _acceptableDifference = (_countEnemies / (_countUnmatched * 1.5)) >= 3;

                    if (!_acceptableDifference) then {
                        _newState = _previousState;
                    };
                };

            };

            // always valid

            case "hold": {

                _troops = _nearFriendlies;

                _validatedState = _newState;

            };

            case "defend": {

                private _countForDefend = (count _nearEnemies) - (count _nearFriendlies);
                private _troopCount = 0;

                if (_countForDefend > 0) then {

                    // All Types: inf, specops, mot, mech, arm, arty, aaa, air, air armed, sea
                    // Preferred: mot, mech, arm, inf

                    private _typesByPriority = [2,3,4,0];

                    {
                        if (_troopCount < _countForDefend) then {
                            private _typeUnits = (_friendlyForces select 2) select _x;

                            while {_troopCount < _countForDefend && {!(_typeUnits isEqualTo [])}} do {
                                _troops pushback (_typeUnits select 0);
                                _typeUnits deleteat 0;
                                _troopCount = _troopCount + 1;
                            };
                        };
                    } foreach _typesByPriority;
                } else {
                    _validatedState = "hold";
                };

                if (_troopCount == 0) then {
                    _validatedState = _previousState;
                };

            };

            // find enough groups to reach limit for holding objective
            // validate if at least one reinforcement group found

            case "reinforce": {

                private _countForHold = [_handler,"profileAmountHold"] call ALiVE_fnc_hashGet;
                private _troopCount = 0;

                // All Types: inf, specops, mot, mech, arm, arty, aaa, air, air armed, sea
                // Preferred: inf, mot, mech, arm

                private _typesByPriority = [0,2,3,4];

                {
                    if (_troopCount < _countForHold) then {
                        private _typeUnits = (_friendlyForces select 2) select _x;

                        while {_troopCount < _countForHold && {!(_typeUnits isEqualTo [])}} do {
                            _troops pushback (_typeUnits select 0);
                            _typeUnits deleteat 0;
                            _troopCount = _troopCount + 1;
                        };
                    };
                } foreach _typesByPriority;

                if (_troopCount == 0) then {
                    _validatedState = _previousState;
                };

            };

            // always valid

            case "withdraw": {

                _troops = _nearFriendlies;

            };

        };

        if (_validatedState != _newState && {_validatedState != _previousState}) then {
            // fire event?
        };

        _objectiveStateData pushback _validatedState;
        _objectiveStateData pushback _troops;

        [_objective,"opcomState", _validatedState] call ALiVE_fnc_hashSet; // TODO: Keep this here or migrate somewhere else?

        // TEMP
        private _activeTasks = [_handler,"activeTasks"] call ALiVE_fnc_hashGet;
        (_activeTasks select 2) params ["_activeReconTasks","_activeStrikeTasks","_activeAttackTasks","_activeDefendTasks"];
        switch (_validatedState) do {
            case "idle": {

            };
            case "recon": {
                _activeReconTasks pushback [];
            };
            case "strike": {
                _activeStrikeTasks pushback [];
            };
            case "attack": {
                _activeAttackTasks pushback [];
            };
            case "defend": {
                _activeDefendTasks pushback [];
            };
            case "hold": {

            };
            case "reinforce": {

            };
            case "withdraw": {

            };
        };
        // TEMP

        _result = _objectiveStateData;

    };

    case "cycleEnd": {

        private _handler = [_logic,"handler"] call MAINCLASS;
        private _debug = [_handler,"debug"] call ALiVE_fnc_hashGet;

        // refresh objective markers

        if (_debug) then {
            private _objectives = [_handler,"objectives"] call ALiVE_fnc_hashGet;

            [_logic,"enableObjectiveDebugMarkers", [_objectives,true]] call MAINCLASS;
        };

    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };

};

TRACE_1("OPCOM Conventional - output", _result);

if !(isnil "_result") then {_result} else {nil};