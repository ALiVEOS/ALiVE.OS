#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileAttack);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_profileAttack

Description:
Main handler for simulated attacks of one profile on others

Parameters:
Nil or HashMap - If Nil, return a new attack. If HashMap, reference an existing attack.
String - The selected function
Array - The selected parameters

Returns:
Any - The new attack HashMap or the result of the selected function and parameters

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
    ["_logic", objNull, [objNull,[],createHashMap]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];


switch (_operation) do {

    case "create": {

        private _position = _args select 0;
        private _attacker = _args select 1;
        private _targets = _args select 2;
        private _attackerSide = _args select 3;

        _result = createHashMapFromArray [
            ["super", QUOTE(SUPERCLASS)],
            ["class", QUOTE(MAINCLASS)],
            ["cyclesLeft", 9999],
            ["attackID", ""],
            ["attackerSide", _attackerSide],
            ["position", _position],
            ["timeStarted", time],
            ["attacker", _attacker],
            ["targets", _targets],
            ["targetsKilled", []],
            ["maxRange", [MOD(profileCombatHandler),"combatRange"] call ALiVE_fnc_hashGet]
        ];

    };

    case "attackID": {

        if (typename _args == "STRING") then {
            _logic set [_operation, _args];
            _result = _args;
        } else {
            _result = _logic get _operation;
        };

    };


    case "battleID": {

        if (typename _args == "STRING") then {
            _logic set [_operation, _args];
            _result = _args;
        } else {
            _result = _logic get _operation;
        };

    };

    case "position": {

        if (typename _args == "ARRAY") then {
            _logic set [_operation, _args];
            _result = _args;
        } else {
            _result = _logic get _operation;
        };

    };

    case "timeStarted": {

        if (typename _args == "SCALAR") then {
            _logic set [_operation, _args];
            _result = _args;
        } else {
            _result = _logic get _operation;
        };

    };

    case "attacker": {

        if (typename _args == "STRING") then {
            _logic set [_operation, _args];
            _result = _args;
        } else {
            _result = _logic get _operation;
        };

    };

    case "targets": {

        if (typename _args == "ARRAY") then {
            _logic set [_operation, _args];
            _result = _args;
        } else {
            _result = _logic get _operation;
        };

    };

    case "maxRange": {

        if (typename _args == "SCALAR") then {
            _logic set [_operation, _args];
            _result = _args;
        } else {
            _result = _logic get _operation;
        };

    };

    case "cyclesLeft": {

        if (typename _args == "SCALAR") then {
            _logic set [_operation, _args];
            _result = _args;
        } else {
            _result = _logic get _operation;
        };

    };

    case "attackerSide": {

        if (typename _args == "STRING") then {
            _logic set [_operation, _args];
            _result = _args;
        } else {
            _result = _logic get _operation;
        };

    };

    default {
        _result = _logic get _operation;
    };

};

if (!isnil "_result") then {_result} else {nil};
