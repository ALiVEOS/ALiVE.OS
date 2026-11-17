#include "\x\alive\addons\mil_logistics\script_component.hpp"
SCRIPT(registry);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_MLGlobalRegistry
Description:
Registry and force pool handling for ML modules

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
_logic = [nil, "create"] call ALIVE_fnc_MLGlobalRegistry;

(end)

See Also:

Author:
ARJay
Jman

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_MLGlobalRegistry

private ["_result"];

TRACE_1("ML Global Registry - input",_this);

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

            // set the global force pool
            if(isNil "ALIVE_globalForcePool") then {
                ALIVE_globalForcePool = [] call ALIVE_fnc_hashCreate;
            };

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
        private["_module","_debug","_modules","_moduleID","_persistent","_forcePool","_data"];

        _module = _args;
        _debug = [_logic, "debug"] call MAINCLASS;
        _modules = [_logic, "modules"] call ALIVE_fnc_hashGet;
        _moduleID = [_logic, "getNextInsertID"] call MAINCLASS;
        [_modules, _moduleID, _module] call ALIVE_fnc_hashSet;

        [_module, "registryID", _moduleID] call ALIVE_fnc_ML;


        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["ML Global register module: %1",_moduleID] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------


        _persistent = [_module, "persistent"] call ALIVE_fnc_ML;
        _forcePool = [_module, "forcePool"] call ALIVE_fnc_ML;

        // A module that starts after the saved pool was loaded seeds only the factions the save
        // doesn't hold: seeding them all put a faction shared with the first module back to its
        // starting pool on every load, so the pool never seemed to be saved (#1128)
        private _loadedFactions = [_logic, "persistenceLoadedFactions", []] call ALIVE_fnc_hashGet;
        if (_loadedFactions isEqualTo []) then {
            [_logic,"updateGlobalForcePool",[_moduleID,_forcePool]] call MAINCLASS;
        } else {
            private _seed = if (_forcePool isEqualType "") then { parseNumber _forcePool } else { _forcePool };
            private _kept = [];
            {
                {
                    if (_x in _loadedFactions) then { _kept pushBackUnique _x } else {
                        [ALIVE_globalForcePool, _x, _seed] call ALIVE_fnc_hashSet;
                        [ALiVE_eventLog, "addEvent", ['FORCEPOOL_UPDATED', [_x, _seed], "Logistics"] call ALiVE_fnc_event] call ALiVE_fnc_eventLog;
                    };
                } forEach (_x select 1);
            } forEach (_module getVariable ["factions", []]);
            if (_kept isNotEqualTo []) then {
                ["ML Global register module: %1 keeps the saved force pool for %2", _moduleID, _kept] call ALIVE_fnc_dump;
            };
        };

        if(_persistent) then {
            if!([_logic,"persistenceLoaded"] call ALIVE_fnc_hashGet) then {
                [_logic,"persistenceLoaded",true] call ALIVE_fnc_hashSet;


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["ML Global registry load persistent force pool."] call ALIVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------


                _data = call ALIVE_fnc_MLLoadData;

                if(typeName _data == "ARRAY") then {

                    // Folded into what is already there rather than put in its place. Each module seeds
                    // an allowance for its own faction a few lines above, and taking the saved pool
                    // wholesale threw those away, so any faction added to a module since the save had no
                    // allowance at all and every request for it was turned down, on that run and on every
                    // run after. Saved figures still win where the save knows the faction, which is the
                    // point of saving them; the seeds only survive where it does not.
                    if (count _data >= 3) then { [_logic, "persistenceLoadedFactions", +(_data select 1)] call ALIVE_fnc_hashSet };
                    if (isNil "ALIVE_globalForcePool" || {count _data < 3}) then {
                        ALIVE_globalForcePool = _data;
                    } else {
                        {
                            [ALIVE_globalForcePool, _x, (_data select 2) select _forEachIndex] call ALIVE_fnc_hashSet;
                        } forEach (_data select 1);
                    };
                    // a save written before the pool had a floor can hold a figure below nothing (#1128)
                    {
                        private _v = [ALIVE_globalForcePool, _x, 0] call ALIVE_fnc_hashGet;
                        if (_v isEqualType 0 && {_v < 0}) then { [ALIVE_globalForcePool, _x, 0] call ALIVE_fnc_hashSet };
                    } forEach (ALIVE_globalForcePool select 1);


                    // DEBUG -------------------------------------------------------------------------------------
                    if(_debug) then {
                        ["ML Global registry persistent force pool loaded:"] call ALIVE_fnc_dump;
                        ALIVE_globalForcePool call ALIVE_fnc_inspectHash;
                    };
                    // DEBUG -------------------------------------------------------------------------------------
                };
            };
        };
    };
    case "updateGlobalForcePool": {
        private["_moduleID","_forcePool","_debug","_modules","_moduleIndex","_module","_moduleFactions","_factions"];

        _moduleID = _args select 0;
        _forcePool = _args select 1;

        _debug = [_logic, "debug"] call MAINCLASS;

        if(typeName _forcePool == "STRING") then {
            _forcePool = parseNumber(_forcePool);
        };
        // The pool never goes below nothing (#1128). A request is let in while the pool has anything left and
        // then pays its full size, so the last request of a run could take it to -1 or lower, and with the pool
        // now saved that figure came back on every restart.
        if (_forcePool isEqualType 0) then { _forcePool = _forcePool max 0 };

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
                _factions = _x select 1;
                {
                    [ALIVE_globalForcePool,_x,_forcePool] call ALIVE_fnc_hashSet;

                    private _event = ['FORCEPOOL_UPDATED', [_x,_forcePool],"Logistics"] call ALiVE_fnc_event;
                    [ALiVE_eventLog,"addEvent", _event] call ALiVE_fnc_eventLog;
                } forEach _factions;
            } forEach _moduleFactions;

        };


        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["ML Global force pool updated:"] call ALIVE_fnc_dump;
            ALIVE_globalForcePool call ALIVE_fnc_inspectHash;
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
TRACE_1("ML Global Registry - output",_result);
_result;
