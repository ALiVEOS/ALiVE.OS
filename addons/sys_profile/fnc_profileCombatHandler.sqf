#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileCombatHandler);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_profileCombatHandler

Description:
Main handler for simulated combat between profiles

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

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
    ["_args", objNull, [objNull,[],"",0,true,false]]
];


switch (_operation) do {

    case "init": {

        private _tmpHash = [] call ALiVE_fnc_hashCreate;

        [_logic,"super", QUOTE(SUPERCLASS)] call ALiVE_fnc_hashSet;     // select 2 select 0
        [_logic,"class", QUOTE(MAINCLASS)] call ALiVE_fnc_hashSet;      // select 2 select 1

        [_logic,"debug", false] call ALiVE_fnc_hashSet;                 // select 2 select 2
        [_logic,"combatRange", 225] call ALiVE_fnc_hashSet;             // select 2 select 3
        [_logic,"combatRate", 1] call ALiVE_fnc_hashSet;                // select 2 select 4

        private _profilesBySide = +_tmpHash;
        [_profilesBySide,"EAST", []] call ALiVE_fnc_hashSet;            // select 2 select 5
        [_profilesBySide,"WEST", []] call ALiVE_fnc_hashSet;            // select 2 select 6
        [_profilesBySide,"GUER", []] call ALiVE_fnc_hashSet;            // select 2 select 7

        [_logic,"profilesInCombatBySide", _profilesBySide] call ALiVE_fnc_hashSet;  // select 2 select 8

        [_logic,"attackCount", 0] call ALiVE_fnc_hashSet;               // select 2 select 9

        private _attacksByID = +_tmpHash;
        [_logic,"attacksByID", _attacksByID] call ALiVE_fnc_hashSet;    // select 2 select 10

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

            {
                [_x,"maxRange", _args] call ALiVE_fnc_hashSet;
            } foreach (_attacksByID select 2);
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

        if (typename _args == "ARRAY") then {
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

        if (typename _args == "ARRAY") then {
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

        private _attacksByID = [_logic,"attacksByID"] call ALiVE_fnc_hashGet;
        private _attackID = [_logic,"getNextAttackID"] call MAINCLASS;

        [_attack,"attackID", _attackID] call ALiVE_fnc_hashSet;
        [_attacksByID,_attackID, _attack] call ALiVE_fnc_hashSet;

        // store attacker in combatBySide

        private _profilesInCombatBySide = ([_logic,"profilesInCombatBySide"] call ALiVE_fnc_hashGet) select 2;

        private _attackerID = [_attack,"attacker"] call ALiVE_fnc_hashGet;
        private _attackerSide = [_attack,"attackerSide"] call ALiVE_fnc_hashGet;

        switch (_attackerSide) do {
            case "EAST": {(_profilesInCombatBySide select 0) pushback _attackerID};
            case "WEST": {(_profilesInCombatBySide select 1) pushback _attackerID};
            case "GUER": {(_profilesInCombatBySide select 2) pushback _attackerID};
        };

        // log event

        private _targets = [_attack,"targets"] call ALiVE_fnc_hashGet;
        private _attackPosition = [_attack,"position"] call ALiVE_fnc_hashGet;
        private _maxRange = [_attack,"maxRange"] call ALiVE_fnc_hashGet;
        private _cyclesLeft = [_attack,"cyclesLeft"] call ALiVE_fnc_hashGet;

        private _event = ['PROFILE_ATTACK_START', [_attackID,_attackerID,_targets,_attackPosition,_attackerSide,_maxRange,_cyclesLeft], "profileCombatHandler"] call ALiVE_fnc_event;
        [MOD(eventLog),"addEvent", _event] call ALiVE_fnc_eventLog;

        _result = _attackID;

    };

    case "removeAttacks": {

        private _attacks = _args;

        private _attacksByID = [_logic,"attacksByID"] call ALiVE_fnc_hashGet;
        private _profilesInCombatBySide = ([_logic,"profilesInCombatBySide"] call ALiVE_fnc_hashGet) select 2;
        private _debug = [_logic,"debug"] call ALiVE_fnc_hashGet;

        {
            private _attackID = _x;
            private _attack = [_attacksByID,_attackID] call ALiVE_fnc_hashGet;

            if (!isnil "_attack") then {
                if (_debug) then {
                    if (isnil "_attack") then {
                        ["Why is my fucking attack null - %1 --- %2", _attacks, _attacksByID] call ALiVE_fnc_Dump;
                    };
                };

                private _attackPosition = [_attack,"position"] call ALiVE_fnc_hashGet;
                private _attackerID = [_attack,"attacker"] call ALiVE_fnc_hashGet;
                private _targetsLeft = [_attack,"targets"] call ALiVE_fnc_hashGet;

                // remove from combatBySide
                private _attackerSide = [_attack,"attackerSide"] call ALiVE_fnc_hashGet;

                switch (_attackerSide) do {
                    case "EAST": {
                        private _array = (_profilesInCombatBySide select 0);
                        _array deleteAt (_array find _attackerID);
                    };
                    case "WEST": {
                        private _array = (_profilesInCombatBySide select 1);
                        _array deleteAt (_array find _attackerID);
                    };
                    case "GUER": {
                        private _array = (_profilesInCombatBySide select 2);
                        _array deleteAt (_array find _attackerID);
                    };
                };

                [_attacksByID,_attackID] call ALiVE_fnc_hashRem;

                // log event

                private _timeStarted = [_attack,"timeStarted"] call ALiVE_fnc_hashGet;
                private _maxRange = [_attack,"maxRange"] call ALiVE_fnc_hashGet;
                private _cyclesLeft = [_attack,"cyclesLeft"] call ALiVE_fnc_hashGet;

                private _event = ['PROFILE_ATTACK_END', [_attackID,_attackerID,_targetsLeft,_attackPosition,_attackerSide,_timeStarted,_maxRange,_cyclesLeft], "profileCombatHandler"] call ALiVE_fnc_event;
                [MOD(eventLog),"addEvent", _event] call ALiVE_fnc_eventLog;
            };
        } foreach _attacks;

    };

    case "getAttack": {

        private _attackID = _args;

        private _attacksByID = [_logic,"attacksByID"] call ALiVE_fnc_hashGet;

        _result = [_attacksByID,_attackID] call ALiVE_fnc_hashGet;

    };

    default {
        _result = _this call SUPERCLASS;
    };

};

if (!isnil "_result") then {_result} else {nil};