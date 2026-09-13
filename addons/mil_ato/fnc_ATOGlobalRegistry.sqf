#include "\x\alive\addons\mil_ato\script_component.hpp"
SCRIPT(registry);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ATOGlobalRegistry
Description:
Registry and task handling for ATO modules

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
_logic = [nil, "create"] call ALIVE_fnc_ATOGlobalRegistry;

(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_ATOGlobalRegistry

private ["_result"];

TRACE_1("ATO Global Registry - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
_result = true;

switch(_operation) do {
    case "init": {
        if (isServer) then {
            // if server, initialise module game logic
            [_logic,"super"] call ALIVE_fnc_hashRem;
            [_logic,"class"] call ALIVE_fnc_hashRem;

            // set defaults
            [_logic,"debug",false] call ALIVE_fnc_hashSet;
            [_logic,"moduleCount",0] call ALIVE_fnc_hashSet;
            [_logic,"modules",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_logic,"persistenceLoaded",false] call ALIVE_fnc_hashSet;

            // The argument is still accepted and still ignored on purpose: the
            // callers pass it and it costs nothing to keep the shape.
            private _persistent = _args;

            // set the global ATO
            if(isNil "ALIVE_globalATO") then {
                ALIVE_globalATO = [] call ALIVE_fnc_hashCreate;
            };

            // Loading belongs to each commander now, not here.
            //
            // This read one shared blob of every faction's aircraft and kept
            // it, and the register step below then published that blob INSTEAD
            // of what the commander registering actually had. With two
            // commanders of one faction, whichever registered second had its
            // own aircraft replaced by the first one's, and a commander that
            // was not persistent could have its aircraft replaced by a
            // neighbour that was. Each commander now reads its own records
            // under its own key as it starts up, so there is nothing for this
            // to do.
            [_logic,"persistenceLoaded",false] call ALIVE_fnc_hashSet;

        };
    };
    case "destroy": {

        [_logic, "debug", false] call MAINCLASS;
        if (isServer) then {
            // if server
            [_logic,"super"] call ALIVE_fnc_hashRem;
            [_logic,"class"] call ALIVE_fnc_hashRem;

            [_logic, "destroy"] call SUPERCLASS;
        };

    };
    case "debug": {
        if(typeName _args != "BOOL") then {
            _args = [_logic,"debug", false] call ALIVE_fnc_hashGet;
        } else {
            [_logic,"debug",_args] call ALIVE_fnc_hashSet;
        };
        _result = _args;
    };
    case "register": {
        private ["_module","_debug","_modules","_moduleID","_persistent","_assets","_data"];

        _module = _args;
        _debug = [_logic, "debug"] call MAINCLASS;
        _modules = [_logic, "modules"] call ALIVE_fnc_hashGet;
        _moduleID = [_logic, "getNextInsertID"] call MAINCLASS;
        [_modules, _moduleID, _module] call ALIVE_fnc_hashSet;

        [_module, "registryID", _moduleID] call ALIVE_fnc_ATO;

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["ATO Global register module: %1",_moduleID] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        _persistent = [_module, "persistent"] call ALIVE_fnc_ATO;
        _assets = [_module, "assets"] call ALIVE_fnc_ATO;

        // What this commander has, published under this commander's entry.
        //
        // There used to be a branch here that replaced the whole published
        // state with the shared store instead, for any persistent commander.
        // Its own note said it should only register its own aircraft; that is
        // now the only thing it does, which is what lets persistent and
        // non-persistent commanders stand side by side.
        [_logic,"updateGlobalATO",[_moduleID,_assets]] call MAINCLASS;
    };
    case "updateGlobalATO": {
        private["_moduleID","_state","_debug","_modules","_moduleIndex","_module","_moduleFactions","_factions"];

        _moduleID = _args select 0;
        _state = _args select 1;

        _debug = [_logic, "debug"] call MAINCLASS;

        if(_state isEqualType "") then {
            _state = parseSimpleArray _state;
        };

        _modules = [_logic, "modules"] call ALIVE_fnc_hashGet;
        _moduleIndex = _modules select 1;
        if(_moduleID in _moduleIndex) then {
            _module = [_modules, _moduleID] call ALIVE_fnc_hashGet;
        }else{
            _module = nil;
        };

        if!(isNil "_module") then {

            _moduleFactions = _module getVariable ["factions", []];

            {

                [ALIVE_globalATO,_x,_state] call ALIVE_fnc_hashSet;

            } forEach _moduleFactions;

        };


        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["ATO Global ATO updated:"] call ALIVE_fnc_dump;
            ALIVE_globalATO call ALIVE_fnc_inspectHash;
        };
        // DEBUG -------------------------------------------------------------------------------------

    };
    case "getModule": {
        private["_moduleID","_modules","_moduleIndex"];

        if(typeName _args == "STRING") then {
            _moduleID = _args;
            _modules = [_logic, "modules"] call ALIVE_fnc_hashGet;
            _moduleIndex = _modules select 1;
            if(_moduleID in _moduleIndex) then {
                _result = [_modules, _moduleID] call ALIVE_fnc_hashGet;
            }else{
                _result = nil;
            };
        };
    };
    case "getModules": {
        _result = [_logic, "modules"] call ALIVE_fnc_hashGet;
    };
    case "getNextInsertID": {
        private["_moduleCount"];
        _moduleCount = [_logic, "moduleCount"] call ALIVE_fnc_hashGet;
        _result = format["module_%1",_moduleCount];
        _moduleCount = _moduleCount + 1;
        [_logic, "moduleCount", _moduleCount] call ALIVE_fnc_hashSet;
    };
    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};
TRACE_1("ATO Global Registry - output",_result);
_result;
