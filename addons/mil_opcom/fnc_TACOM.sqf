//#define DEBUG_MODE_FULL
#include "\x\alive\addons\mil_opcom\script_component.hpp"
SCRIPT(OPCOM);

/* ----------------------------------------------------------------------------
We don't know shit yet
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALIVE_fnc_baseClass
#define MAINCLASS   ALIVE_fnc_tacom

TRACE_1("OPCOM - input",_this);

private ["_result"];

params [
    ["_logic", objNull, [objNull,[],""]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

switch (_operation) do {

    case "create": {

        private _commander = _args;

        _logic = [nil,"create"] call SUPERCLASS;
        SET_PROPERTY(_logic,"commander", _commander);

        _result = _logic;

    };

    case "init": {

        systemchat "TACOM Init";

    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };

};

TRACE_1("OPCOM - output",_result);

if !(isnil "_result") then {_result} else {nil};
