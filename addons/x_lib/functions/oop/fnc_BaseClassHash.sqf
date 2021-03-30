#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(baseClassHash);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_baseClassHash
Description:
Base class

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Nil - create - Create instance
Nil - destroy - Destroy instance

Examples:
(begin example)
// Create instance
_logic = [nil, "create"] call ALIVE_fnc_baseClassHash;

// Destroy instance
[_logic, "destroy"] call ALIVE_fnc_baseClassHash;
(end)

See Also:
- nil

Author:
Wolffy.au

Peer reviewed:
nil
---------------------------------------------------------------------------- */
if(
    isNil "_this" ||
    {typeName _this != "ARRAY"} ||
    {count _this == 0} ||
    {typeName (_this select 0) != "ARRAY"} // changed to array
) then {
    _this = [[], "create"]; // changed to array
};

TRACE_1("baseClassHash - input",_this);

//logic: changed to array as the allowed not sure if this is right..
params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

private _result = true;

switch(_operation) do {

    case "create": {
        // Create a module object for settings and persistence
        _result = [
            [
                ["class", ALIVE_fnc_baseClassHash]
            ]
        ] call ALiVE_fnc_hashCreate;
    };

    case "destroy": {
        {
            [_logic, _x] call ALIVE_fnc_hashRem;
        } forEach +(_logic select 1);

        _logic = nil;
    };

    default {
        private _err = format["'%2' operation is not supported by %1", _logic, _operation];
        _err call ALiVE_fnc_logger;
    };

};

TRACE_1("baseClassHash - output",_result);

_result;
