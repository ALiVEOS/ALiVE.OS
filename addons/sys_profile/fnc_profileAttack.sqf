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

    case "init": {

        [_logic,"super", QUOTE(SUPERCLASS)] call ALiVE_fnc_hashSet; // select 2 select 0
        [_logic,"class", QUOTE(MAINCLASS)] call ALiVE_fnc_hashSet;  // select 2 select 1

        [_logic,"attackID", ""] call ALiVE_fnc_hashSet;             // select 2 select 2
        [_logic,"battleID", ""] call ALiVE_fnc_hashSet;             // select 2 select 3
        [_logic,"position", [0,0,0]] call ALiVE_fnc_hashSet;        // select 2 select 4
        [_logic,"timeStarted", time] call ALiVE_fnc_hashSet;        // select 2 select 5

        [_logic,"attacker", []] call ALiVE_fnc_hashSet;             // select 2 select 6
        [_logic,"targets", []] call ALiVE_fnc_hashSet;              // select 2 select 7

        // for arty set to max arty range, else leave default

        [_logic,"maxRange", [MOD(profileCombatHandler),"combatRange"] call ALiVE_fnc_hashGet] call ALiVE_fnc_hashSet;            // select 2 select 8

        [_logic,"cyclesLeft", 9999] call ALiVE_fnc_hashSet;         // select 2 select 9
        [_logic,"attackerSide", "WEST"] call ALiVE_fnc_hashSet;     // select 2 select 10

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