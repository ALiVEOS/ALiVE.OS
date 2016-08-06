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

        // CfgFactionClass

        [_logic,"configName", ""] call ALiVE_fnc_hashSet;
        [_logic,"displayName", ""] call ALiVE_fnc_hashSet;
        [_logic,"flag", ""] call ALiVE_fnc_hashSet;
        [_logic,"icon", ""] call ALiVE_fnc_hashSet;
        [_logic,"priority", 0] call ALiVE_fnc_hashSet;
        [_logic,"side", 0] call ALiVE_fnc_hashSet;

        // CfgGroups

        private _groupCategory = +_tmpHash;
        [_groupCategory,"name",""] call ALiVE_fnc_hashSet;
        [_groupCategory,"configName", ""] call ALiVE_fnc_hashSet;
        [_groupCategory,"groups", +_tmpHash] call ALiVE_fnc_hashSet;

        private _groupsByCategory = +_tmpHash;

        private _groupCategoryInfantry = +_groupCategory;
        [_groupCategoryInfantry,"name", "Infantry"] call ALiVE_fnc_hashSet;
        [_groupCategoryInfantry,"configName", "Infantry"] call ALiVE_fnc_hashSet;
        [_groupsByCategory,"Infantry", _groupCategoryInfantry] call ALiVE_fnc_hashSet;

        private _groupCategorySpecOps = +_groupCategory;
        [_groupCategorySpecOps,"name", "Special Forces"] call ALiVE_fnc_hashSet;
        [_groupCategorySpecOps,"configName", "SpecOps"] call ALiVE_fnc_hashSet;
        [_groupsByCategory,"SpecOps", +_groupCategorySpecOps] call ALiVE_fnc_hashSet;

        private _groupCategoryMotorized = +_groupCategory;
        [_groupCategoryMotorized,"name", "Motorized Infantry"] call ALiVE_fnc_hashSet;
        [_groupCategoryMotorized,"configName", "Motorized"] call ALiVE_fnc_hashSet;
        [_groupsByCategory,"Motorized", _groupCategoryMotorized] call ALiVE_fnc_hashSet;

        private _groupCategoryMotorizedMTP = +_groupCategory;
        [_groupCategoryMotorizedMTP,"name", "Motorized Infantry (MTP)"] call ALiVE_fnc_hashSet;
        [_groupCategoryMotorizedMTP,"configName","Motorized_MTP"] call ALiVE_fnc_hashSet;
        [_groupsByCategory,"Motorized_MTP", +_groupCategoryMotorizedMTP] call ALiVE_fnc_hashSet;

        private _groupCategorySupport = +_groupCategory;
        [_groupCategorySupport,"name", "Support Infantry"] call ALiVE_fnc_hashSet;
        [_groupCategorySupport,"configName", "Support"] call ALiVE_fnc_hashSet;
        [_groupsByCategory,"Support", _groupCategorySupport] call ALiVE_fnc_hashSet;

        private _groupCategoryMechanized = +_groupCategory;
        [_groupCategoryMechanized,"name", "Mechanized Infantry"] call ALiVE_fnc_hashSet;
        [_groupCategoryMechanized,"configName", "Mechanized"] call ALiVE_fnc_hashSet;
        [_groupsByCategory,"Mechanized", _groupCategoryMechanized] call ALiVE_fnc_hashSet;

        private _groupCategoryArmored = +_groupCategory;
        [_groupCategoryArmored,"name", "Armor"] call ALiVE_fnc_hashSet;
        [_groupCategoryArmored,"configName", "Armored"] call ALiVE_fnc_hashSet;
        [_groupsByCategory,"Armored", _groupCategoryArmored] call ALiVE_fnc_hashSet;

        private _groupCategoryArtillery = +_groupCategory;
        [_groupCategoryArtillery,"name", "Artillery"] call ALiVE_fnc_hashSet;
        [_groupCategoryArtillery,"configName", "Artillery"] call ALiVE_fnc_hashSet;
        [_groupsByCategory,"Artillery", _groupCategoryArtillery] call ALiVE_fnc_hashSet;

        private _groupCategoryNaval = +_groupCategory;
        [_groupCategoryNaval,"name", "Naval"] call ALiVE_fnc_hashSet;
        [_groupCategoryNaval,"configName", "Naval"] call ALiVE_fnc_hashSet;
        [_groupsByCategory,"Naval", _groupCategoryNaval] call ALiVE_fnc_hashSet;

        private _groupCategoryAir = +_groupCategory;
        [_groupCategoryAir,"name", "Air"] call ALiVE_fnc_hashSet;
        [_groupCategoryAir,"configName", "Air"] call ALiVE_fnc_hashSet;
        [_groupsByCategory,"Air", _groupCategoryAir] call ALiVE_fnc_hashSet;

        [_logic,"groupCategories", _groupsByCategory] call ALiVE_fnc_hashSet;

        // units / vehicles

        [_logic,"assetCategories",[]] call ALiVE_fnc_hashSet;
        [_logic,"assets", []] call ALiVE_fnc_hashSet;

        [_logic,"assetsImportedConfig", false] call ALiVE_fnc_hashSet;

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

    case "groupCategories": {

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

    case "assetCategories": {

        if (typename _args == "ARRAY") then {
            [_logic,_operation,_args] call ALiVE_fnc_hashSet;
            _result = _args;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashGet;
        };

    };


};

if (!isnil "_result") then {_result} else {nil};