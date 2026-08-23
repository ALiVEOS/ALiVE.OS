#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileCombatHandler);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_profileCombatHandler

Description:
Main handler for simulated combat between profiles

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Any - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Examples:
(begin example)
// create a new handler
_logic = [nil, "create"] call ALiVE_fnc_profileCombatHandler;
(end)

See Also:

Author:
SpyderBlack

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALIVE_fnc_baseClassHash
#define MAINCLASS   ALiVE_fnc_profileCombatHandler

private ["_result"];

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false,createHashMap]]
];


switch (_operation) do {

    case "init": {

        [_logic,"super", QUOTE(SUPERCLASS)] call ALiVE_fnc_hashSet;     // select 2 select 0
        [_logic,"class", QUOTE(MAINCLASS)] call ALiVE_fnc_hashSet;      // select 2 select 1

        [_logic,"debug", false] call ALiVE_fnc_hashSet;                 // select 2 select 2
        [_logic,"combatRange", 225] call ALiVE_fnc_hashSet;             // select 2 select 3
        [_logic,"combatRate", 1] call ALiVE_fnc_hashSet;                // select 2 select 4

        private _profilesBySide = createHashMapFromArray [
            ["EAST", []],
            ["WEST", []],
            ["GUER", []]
        ];

        [_logic,"profilesInCombatBySide", _profilesBySide] call ALiVE_fnc_hashSet;  // select 2 select 5

        [_logic,"attackCount", 0] call ALiVE_fnc_hashSet;               // select 2 select 6

        private _attacksByID = createHashMap;
        [_logic,"attacksByID", _attacksByID] call ALiVE_fnc_hashSet;    // select 2 select 7

    };

    case "debug": {

        if (typename _args == "BOOL") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "combatRange": {

        if (typename _args == "SCALAR") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "combatRate": {

        if (typename _args == "SCALAR") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "profilesInCombatBySide": {

        if (typename _args == "HASHMAP") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "attackCount": {

        if (typename _args == "SCALAR") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "attacksByID": {

        if (typename _args == "HASHMAP") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "getNextAttackID": {

        private _attackCount = [_logic,"attackCount"] call ALiVE_fnc_hashGet;
        _result = format ["attack_%1", _attackCount];
        [_logic,"attackCount", _attackCount + 1] call ALiVE_fnc_hashSet;

    };

    case "addAttack": {

        private _attack = _args;

        // store attack in attacksByID

        ([_logic, ["attacksByID","profilesInCombatBySide"]] call ALiVE_fnc_hashGetMany) params [
            "_attacksByID",
            "_profilesInCombatBySide"
        ];
        private _attackID = [_logic,"getNextAttackID"] call MAINCLASS;

        _attack set ["attackID", _attackID];
        _attacksByID set [_attackID, _attack];

        // store attacker in combatBySide

        private _attackerID = _attack get "attacker";
        private _attackerSide = _attack get "attackerSide";

        private _sideProfiles = _profilesInCombatBySide getOrDefault [_attackerSide, [], true];
        _sideProfiles pushback _attackerID;

        // log event

        private _targets = _attack get "targets";
        private _attackPosition = _attack get "position";
        private _maxRange = _attack get "maxRange";
        private _cyclesLeft = _attack get "cyclesLeft";

        private _event = ['PROFILE_ATTACK_START', [_attackID,_attackerID,_targets,_attackPosition,_attackerSide,_maxRange,_cyclesLeft], "profileCombatHandler"] call ALiVE_fnc_event;
        [MOD(eventLog),"addEvent", _event] call ALiVE_fnc_eventLog;

        _result = _attackID;

    };

    case "removeAttacks": {

        private _attacks = _args;

        ([_logic, ["attacksByID","profilesInCombatBySide"]] call ALiVE_fnc_hashGetMany) params [
            "_attacksByID",
            "_profilesInCombatBySide"
        ];
        private _profilesById = [MOD(profileHandler),"profilesById"] call ALiVE_fnc_hashGet;

        {
            if (isnil "_x") then { continue }; // why the fuck can we be nil here

            private _attackID = _x;
            private _attack = _attacksByID get _attackID;

            if (!isnil "_attack") then {
                private _attackPosition = _attack get "position";
                private _attackerID = _attack get "attacker";
                private _targetsLeft = _attack get "targets";

                // remove from combatBySide
                private _attackerSide = _attack get "attackerSide";

                private _sideProfiles = _profilesInCombatBySide getOrDefault [_attackerSide, []];
                private _sideProfileIndex = _sideProfiles find _attackerID;
                if (_sideProfileIndex >= 0) then {
                    _sideProfiles deleteAt _sideProfileIndex;
                };

                _attacksByID deleteAt _attackID;

                private _attacker = _profilesById get _attackerID;
                if (!isnil "_attacker") then {
                    [_attacker,"attackID"] call ALiVE_fnc_hashRem;
                };

                // log event

                private _timeStarted = _attack get "timeStarted";
                private _maxRange = _attack get "maxRange";
                private _cyclesLeft = _attack get "cyclesLeft";
                private _targetsKilled = _attack get "targetsKilled";

                private _event = ['PROFILE_ATTACK_END', [_attackID,_attackerID,_targetsLeft,_targetsKilled,_attackPosition,_attackerSide,_timeStarted,_maxRange,_cyclesLeft], "profileCombatHandler"] call ALiVE_fnc_event;
                [MOD(eventLog),"addEvent", _event] call ALiVE_fnc_eventLog;
            };
        } foreach _attacks;

    };

    case "getAttack": {

        private _attackID = _args;

        private _attacksByID = [_logic,"attacksByID"] call ALiVE_fnc_hashGet;

        _result = _attacksByID get _attackID;

    };

    default {
        _result = _this call SUPERCLASS;
    };

};

if (!isnil "_result") then {_result} else {nil};
