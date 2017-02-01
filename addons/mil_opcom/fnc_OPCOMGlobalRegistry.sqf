#include <\x\ALiVE\addons\mil_opcom\script_component.hpp>
SCRIPT(OPCOMGlobalRegistry);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_OPCOMGlobalRegistry
Description:
Registry handling for OPCOM modules

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enable, disable or refresh
Boolean - state - Store or restore state of analysis

Examples:
(begin example)
// create the registry
_logic = [nil, "create"] call ALiVE_fnc_OPCOMGlobalRegistry;

(end)

See Also:

Author:
SpyderBlack

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALiVE_fnc_baseClassHash
#define MAINCLASS   ALiVE_fnc_OPCOMGlobalRegistry

private ["_result"];

TRACE_1("OPCOM Global Registry - input", _this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

switch(_operation) do {

    case "init": {

        if (isServer) then {

            [_logic,"super"] call ALiVE_fnc_hashRem;
            [_logic,"class"] call ALiVE_fnc_hashRem;

            [_logic,"debug",false] call ALiVE_fnc_hashSet;
            [_logic,"moduleCount",0] call ALiVE_fnc_hashSet;
            [_logic,"modules",[] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashSet;

        };

    };

    case "destroy": {

        [_logic, "debug", false] call MAINCLASS;

        if (isServer) then {
            [_logic,"super"] call ALiVE_fnc_hashRem;
            [_logic,"class"] call ALiVE_fnc_hashRem;

            [_logic, "destroy"] call SUPERCLASS;
        };

    };

    case "debug": {

        if(_args isEqualType true) then {
            [_logic,_operation, _args] call ALiVE_fnc_hashSet;
        } else {
            _result = [_logic,_operation, false] call ALiVE_fnc_hashGet;
        };

    };

    case "register": {

        private _module = _args;

        private _debug = [_logic, "debug"] call MAINCLASS;

        private _modules = [_logic, "modules"] call ALiVE_fnc_hashGet;
        private _moduleID = [_logic, "getNextInsertID"] call MAINCLASS;
        [_modules, _moduleID, _module] call ALiVE_fnc_hashSet;

        [_module, "registryID", _moduleID] call ALiVE_fnc_OPCOM;

        if(_debug) then {
            ["OPCOM Global register module: %1",_moduleID] call ALiVE_fnc_dump;
        };

        publicVariable QUOTE(ALiVE_OPCOMGlobalRegistry);

    };

    case "unregister":{

        private _registryID = _args;

        private _modules = [_logic,"modules"] call ALiVE_fnc_hashGet;

        [_modules,_registryID] call ALiVE_fnc_hashRem;

        publicVariable QUOTE(ALiVE_OPCOMGlobalRegistry);

    };

    case "getModule": {

        if (_args isEqualType "") then {

            private _moduleID = _args;

            private _modules = [_logic, "modules"] call ALiVE_fnc_hashGet;

            if(_moduleID in (_modules select 1)) then {
                _result = [_modules, _moduleID] call ALiVE_fnc_hashGet;
            }else{
                _result = nil;
            };

        };

    };

    case "getModules": {

        _result = [_logic, "modules"] call ALiVE_fnc_hashGet;

    };

    case "getModulesBySide": {

        private _side = _args;

        if (_side isEqualType west) then {
            [_side] call ALiVE_fnc_sideToSideText;
        };

        _result = [];

        private _modules = [_logic,"modules"] call ALiVE_fnc_hashGet;

        {
            private _moduleDataHandler = [_x,"handler"] call ALiVE_fnc_OPCOM;
            private _moduleSide = [_moduleDataHandler,"side"] call ALiVE_fnc_hashGet;

            if (_moduleSide == _side) then {
                _result pushback _x;
            };
        } foreach (_modules select 2);

    };

    case "getModuleByFaction": {

        private _faction = _args;

        private _modules = [_logic,"modules"] call ALiVE_fnc_hashGet;

        {
            private _moduleDataHandler = [_x,"handler"] call ALiVE_fnc_OPCOM;
            private _moduleFactions = [_moduleDataHandler,"factions"] call ALiVE_fnc_hashGet;

            if (_faction in _moduleFactions) exitwith {
                _result = _x;
            };
        } foreach (_modules select 2);

    };

    case "getNextInsertID": {

        private _moduleCount = [_logic, "moduleCount"] call ALiVE_fnc_hashGet;

        _result = format["module_%1",_moduleCount];

        [_logic, "moduleCount", _moduleCount + 1] call ALiVE_fnc_hashSet;

    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };

};

TRACE_1("OPCOM Global Registry - output", _result);

if (!isnil "_result") then {_result} else {nil};