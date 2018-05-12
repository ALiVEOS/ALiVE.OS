#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profileAttack);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_profileAttack

Description:
Main handler for simulated attacks of one profile on others

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Examples:
(begin example)
// create a new attack
_logic = [nil, "create"] call ALiVE_fnc_profileAttack;
(end)

See Also:

Author:
SpyderBlack

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALIVE_fnc_baseClassHash
#define MAINCLASS   ALiVE_fnc_profileAttack

private ["_result"];

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];


switch (_operation) do {

    case "create": {

        private _position = _args select 0;
        private _attacker = _args select 1;
        private _targets = _args select 2;
        private _attackerSide = _args select 3;

        _result = [
            [
                ["super", QUOTE(SUPERCLASS)],       // select 2 select 0
                ["class", QUOTE(MAINCLASS)],        // select 2 select 1
                ["cyclesLeft", 9999],               // select 2 select 2
                ["attackID", ""],                   // select 2 select 3
                ["attackerSide", _attackerSide],    // select 2 select 4
                ["position", _position],            // select 2 select 5
                ["timeStarted", time],              // select 2 select 6
                ["attacker", _attacker],            // select 2 select 7
                ["targets", _targets],              // select 2 select 8
                ["maxRange", [MOD(profileCombatHandler),"combatRange"] call ALiVE_fnc_hashGet] // for arty set to max arty range, else leave default
            ]
        ] call ALiVE_fnc_hashCreate;

    };

    case "attackID": {

        if (typename _args == "STRING") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

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

    case "attacker": {

        if (typename _args == "STRING") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "targets": {

        if (typename _args == "ARRAY") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "maxRange": {

        if (typename _args == "SCALAR") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "cyclesLeft": {

        if (typename _args == "SCALAR") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "attackerSide": {

        if (typename _args == "SCALAR") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    default {
        _result = _this call SUPERCLASS;
    };

};

if (!isnil "_result") then {_result} else {nil};