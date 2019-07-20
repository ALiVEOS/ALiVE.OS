//#define DEBUG_MODE_FULL
#include "\x\alive\addons\mil_opcom\script_component.hpp"
SCRIPT(OPCOM);

/* ----------------------------------------------------------------------------
We don't know shit yet
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALIVE_fnc_baseClassHash
#define MAINCLASS   ALIVE_fnc_TACOM

TRACE_1("OPCOM - input",_this);

private ["_result"];

params [
    ["_logic", objNull, [objNull,[],""]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

switch (_operation) do {

    case "init": {

        systemchat "TACOM Init";

    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };

};

TRACE_1("OPCOM - output",_result);

if !(isnil "_result") then {_result} else {nil};
