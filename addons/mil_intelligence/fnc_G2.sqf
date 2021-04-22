//#define DEBUG_MODE_FULL
#include "\x\alive\addons\mil_intelligence\script_component.hpp"
SCRIPT(G2);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_G2
Description:

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Examples:

See Also:

Author:
SpyderBlack723
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_G2
#define MTEMPLATE "ALiVE_G2_%1"

private "_result";

params [
    ["_logic", objNull, [objNull]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

switch(_operation) do {
    case "destroy": {
        [_logic, "debug", false] call MAINCLASS;
        if (isServer) then {
            // if server
            _logic setVariable ["super", nil];
            _logic setVariable ["class", nil];

            [_logic, "destroy"] call SUPERCLASS;
        };

    };
    case "debug": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["debug", _args];
        } else {
            _args = _logic getVariable ["debug", false];
        };
        if (typeName _args == "STRING") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["debug", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "init": {
        if (isServer) then {
            _logic setVariable ["super", SUPERCLASS];
            _logic setVariable ["class", MAINCLASS];
            _logic setVariable ["moduleType", "ALIVE_PSD"];
            _logic setVariable ["startupComplete", false];

            TRACE_1("After module init",_logic);

            [_logic,"start"] call MAINCLASS;
        };
    };
    case "start": {
        if (isServer) then {

        };
    };
    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};

if (!isnil "_result") then { _result } else { nil };