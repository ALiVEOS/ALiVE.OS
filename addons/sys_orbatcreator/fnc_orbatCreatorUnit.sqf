//#define DEBUG_MODE_FULL
#include <\x\alive\addons\sys_orbatcreator\script_component.hpp>
SCRIPT(orbatCreatorUnit);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_orbatCreatorUnit
Description:
Main handler for custom units for the orbat creator

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
_faction = [nil, "create"] call ALiVE_fnc_orbatCreatorUnit;

See Also:
- <ALiVE_fnc_orbatCreator>

Author:
SpyderBlack723

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALIVE_fnc_baseClassHash
#define MAINCLASS   ALiVE_fnc_orbatCreatorUnit

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

        [_logic,"inheritsFrom", ""] call ALiVE_fnc_hashSet;
        [_logic,"side", 0] call ALiVE_fnc_hashSet;
        [_logic,"faction", ""] call ALiVE_fnc_hashSet;

        [_logic,"configName", ""] call ALiVE_fnc_hashSet;
        [_logic,"displayName", ""] call ALiVE_fnc_hashSet;

        // man properties

        [_logic,"loadout", []] call ALiVE_fnc_hashSet;

        private _identityTypes = [] call ALiVE_fnc_hashCreate;
        [_identityTypes,"face", ""] call ALiVE_fnc_hashSet;
        [_identityTypes,"voice", ""] call ALiVE_fnc_hashSet;
        [_identityTypes,"insignia", ""] call ALiVE_fnc_hashSet;
        [_identityTypes,"misc", []] call ALiVE_fnc_hashSet;
        [_logic,"identityTypes", _identityTypes] call ALiVE_fnc_hashSet;

        // vehicle properties

        [_logic,"crew", ""] call ALiVE_fnc_hashSet;
        [_logic,"turrets", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashSet;
        [_logic,"texture", ""] call ALiVE_fnc_hashSet;

    };

    case "inheritsFrom": {

        if (typename _args == "STRING") then {
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

    case "faction": {

        if (typename _args == "STRING") then {
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

    case "loadout": {

        if (typename _args == "ARRAY") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "crew": {

        if (typename _args == "STRING") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "turrets": {

        if (typename _args == "ARRAY") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "texture": {

        if (typename _args == "STRING") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

    case "identityTypes": {

        if (typename _args == "ARRAY") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };

};

if (!isnil "_result") then {_result} else {nil};