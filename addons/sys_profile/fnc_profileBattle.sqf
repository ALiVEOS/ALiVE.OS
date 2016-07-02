#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profileBattle);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_profileBattle

Description:
Main handler for simulated battles between profiles

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Examples:
(begin example)
// create a profile battle
_logic = [nil, "create"] call ALiVE_fnc_profileBattle;
(end)

See Also:

Author:
SpyderBlack

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALIVE_fnc_baseClassHash
#define MAINCLASS   ALiVE_fnc_profileBattle

private ["_result"];

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];


switch (_operation) do {

    case "init": {

        [_logic,"super", QUOTE(SUPERCLASS)] call ALiVE_fnc_hashSet;     // select 2 select 0
        [_logic,"class", QUOTE(MAINCLASS)] call ALiVE_fnc_hashSet;      // select 2 select 1

        [_logic,"battleID", ""] call ALiVE_fnc_hashSet;                 // select 2 select 2
        [_logic,"position", [0,0,0]] call ALiVE_fnc_hashSet;            // select 2 select 3
        [_logic,"timeStarted", time] call ALiVE_fnc_hashSet;            // select 2 select 4
        [_logic,"listenerID", ""] call ALiVE_fnc_hashSet;               // select 2 select 5

        [_logic,"attacks", []] call ALiVE_fnc_hashSet;                  // select 2 select 6

        private _profilesBySide = [] call ALiVE_fnc_hashCreate;         // select 2 select 7
        [_profilesBySide,"EAST", []] call ALiVE_fnc_hashSet;            // select 2 select 8
        [_profilesBySide,"WEST", []] call ALiVE_fnc_hashSet;            // select 2 select 9
        [_profilesBySide,"GUER", []] call ALiVE_fnc_hashSet;            // select 2 select 10

        [_logic,"profilesBySide", _profilesBySide] call ALiVE_fnc_hashSet;          // select 2 select 11
        [_logic,"profilesKilledBySide", +_profilesBySide] call ALiVE_fnc_hashSet;   // select 2 select 12

    };

    case "battleID": {

        if (typename _args == "STRING") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "position": {

        if (typename _args == "ARRAY") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "timeStarted": {

        if (typename _args == "SCALAR") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "attacks": {

        if (typename _args == "ARRAY") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "profilesKilledBySide": {

        if (typename _args == "ARRAY") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "listen": {

        private _listener = [_logic, ["PROFILE_ATTACK_START","PROFILE_ATTACK_END"]];
        private _listenerID = [MOD(eventLog), "addListener", _listener] call ALIVE_fnc_eventLog;
        [_logic,"listenerID", _listenerID] call ALiVE_fnc_hashSet;

    };

    case "handleEvent": {

        private _event = _args;

        private _eventType = [_event,"type"] call ALiVE_fnc_hashGet;
        private _eventData = [_event,"data"] call ALiVE_fnc_hashGet;

        switch (_eventType) do {

            case "PROFILE_ATTACK_START": {
                _eventData params ["_attackID","_attackPosition"];
                _battlePosition = [_logic,"position"] call ALiVE_fnc_hashGet;

                if (_attackPosition distance2D _battlePosition < 500) then {
                    [_logic,"addAttacks", [_attackID]] call MAINCLASS;
                };
            };

            case "PROFILE_ATTACK_END": {
                _eventData params ["_attackID","_attackPosition","_timeStarted","_attacker","_killedInAttackBySide"];
                _attacks = [_logic,"attacks"] call ALiVE_fnc_hashGet;

                if (_attackID in _attacks) then {
                    [_logic,"removeAttacks", [_attackID]] call MAINCLASS;

                    // keep track of profiles killed in battle

                    private _profilesKilledBySide = ([_logic,"profilesKilledBySide"] call ALiVE_fnc_hashGet) select 2;
                    _killedInAttackBySide = _killedInAttackBySide select 2;

                    {
                        private _profilesKilledForSide = _x;
                        private _killedInAttackForSide = _killedInAttackBySide select _forEachIndex;

                        {_profilesKilledForSide pushbackunique _x} foreach _killedInAttackForSide;
                    } foreach _profilesKilledBySide;
                };
            };

        };

    };

    case "addAttacks": {

        private ["_attacks","_attacks","_profilesBySide","_profilesToAdd","_attack","_attackID","_attacker","_targets","_profile"];

        _attacksToAdd = _args;

        _attacks = [_logic,"attacks"] call ALiVE_fnc_hashGet;
        _profilesBySide = ([_logic,"profilesBySide"] call ALiVE_fnc_hashGet) select 2;
        _profilesToAdd = [];

        {
            _attack = _x;
            _attackID = [_x,"attackID"] call ALiVE_fnc_hashGet;

            if (typename _attackID == "ARRAY") then {
                _attackID = [_x,"attackID"] call ALiVE_fnc_hashGet;
            };

            _attacker = [_x,"attacker"] call ALiVE_fnc_hashGet;
            _profilesToAdd pushback _attacker;

            _targets = [_x,"targets"] call ALiVE_fnc_hashGet;
            _profilesToAdd append _targets;

            _attacks pushback _attackID;
        } foreach _attacksToAdd;

        // add profiles to profilesBySide

        {
            _profile = [MOD(profileHandler),"getProfile", _x] call ALiVE_fnc_profileHandler;

            switch (_profile select 2 select 3) do { // side
                case "EAST": {(_profilesBySide select 0) pushback _x};
                case "WEST": {(_profilesBySide select 1) pushback _x};
                case "GUER": {(_profilesBySide select 2) pushback _x};
            };
        } foreach _profilesToAdd;

    };

    case "removeAttacks": {

        private _attacks = _args;

        private _attacks = [_logic,"attacks"] call ALiVE_fnc_hashGet;

        {
            private _attackID = _x;

            if (typename _attackID == "ARRAY") then {
                _attackID = [_x,"attackID"] call ALiVE_fnc_hashGet;
            };

            _attacks deleteAt (_attacks find _attackID);
        } foreach _attacks;

    };

    case "destroy": {

        private _listenerID = [_logic,"listenerID"] call ALiVE_fnc_hashGet;
        [MOD(eventLog),"removeListener", _listenerID] call ALIVE_fnc_eventLog;

        private _event = ['PROFILE_BATTLE_END', [], "ProfileBattle"] call ALIVE_fnc_event;  // execute in profileSimulator
        [MOD(eventLog), "addEvent", _event] call ALIVE_fnc_eventLog;

        _this call SUPERCLASS;

    };

    default {
        _result = _this call SUPERCLASS;
    };

};

if (!isnil "_result") then {_result} else {nil};