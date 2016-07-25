//#define DEBUG_MODE_FULL
#include <\x\alive\addons\sys_orbatcreator\script_component.hpp>
SCRIPT(orbatCreatorFaction);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_orbatCreatorFaction
Description:
Main handler for factions for the orbat creator

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Nil - init - Intiate instance
Nil - destroy - Destroy instance

Examples:
_faction = [nil, "create"] call ALiVE_fnc_orbatCreatorFaction;

See Also:
- <ALiVE_fnc_orbatCreator>

Author:
SpyderBlack723

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALIVE_fnc_baseClassHash
#define MAINCLASS   ALiVE_fnc_orbatCreatorFaction

private ["_result"];
params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

switch(_operation) do {

    default {
        _result = _this call SUPERCLASS;
    };

    case "init": {

        [_logic,"super", QUOTE(SUPERCLASS)] call ALiVE_fnc_hashSet;
        [_logic,"class", QUOTE(MAINCLASS)] call ALiVE_fnc_hashSet;

        private _tmpHash = [] call ALiVE_fnc_hashCreate;

        [_logic,"inheritsFrom", []] call MAINCLASS;

        // CfgFactionClass

        [_logic,"configName", ""] call MAINCLASS;
        [_logic,"displayName", ""] call MAINCLASS;
        [_logic,"flag", ""] call MAINCLASS;
        [_logic,"icon", ""] call MAINCLASS;
        [_logic,"priority", 0] call MAINCLASS;
        [_logic,"side", 0] call MAINCLASS;

        // CfgGroups

        /*
            _groupCategories = +_tmpHash;
            [_groupCategories,"Infantry", +_tmpHash] call ALiVE_fnc_hashSet;
            [_groupCategories,"Motorized", +_tmpHash] call ALiVE_fnc_hashSet;
            [_groupCategories,"Mechanized", +_tmpHash] call ALiVE_fnc_hashSet;
            [_groupCategories,"Armored", +_tmpHash] call ALiVE_fnc_hashSet;
            [_groupCategories,"SpecOps", +_tmpHash] call ALiVE_fnc_hashSet;
            [_groupCategories,"Support", +_tmpHash] call ALiVE_fnc_hashSet;
            [_groupCategories,"Air", +_tmpHash] call ALiVE_fnc_hashSet;
        */

        private _groupsByCategory = [] call ALiVE_fnc_hashCreate;
        [_groupsByCategory,"ALiVE_compatible", +_tmpHash] call ALiVE_fnc_hashSet;
        [_groupsByCategory,"ALiVE_incompatible", +_tmpHash] call ALiVE_fnc_hashSet;

        [_logic,"groupsByCategory", _groupsByCategory] call MAINCLASS;

        // units / vehicles
        private _assets = [] call ALiVE_fnc_hashCreate;
        [_logic,"assets", _assets] call MAINCLASS;

    };

    case "inheritsFrom": {

        if (typename _args == "ARRAY") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "configName": {

        if (typename _args == "STRING") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "displayName": {

        if (typename _args == "STRING") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "flag": {

        if (typename _args == "STRING") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "icon": {

        if (typename _args == "STRING") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "priority": {

        if (typename _args == "SCALAR") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "side": {

        if (typename _args == "SCALAR") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "groupsByCategory": {

        if (typename _args == "ARRAY") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "assets": {

        if (typename _args == "ARRAY") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };


};

if (!isnil "_result") then {_result} else {nil};