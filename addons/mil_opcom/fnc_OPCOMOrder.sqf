//#define DEBUG_MODE_FULL
#include <\x\alive\addons\mil_opcom\script_component.hpp>
SCRIPT(OPCOMOrder);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_OPCOMOrder
Description:


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

See Also:


Author:
SpyderBlack723

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALIVE_fnc_baseClassHash
#define MAINCLASS   ALiVE_fnc_OPCOMOrder

#define DEFAULT_ID          ""
#define DEFAULT_BLOCKING    true

private "_result";
params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

switch(_operation) do {

    case "create": {

        if (_args isEqualTo []) then {
            _result = _this call SUPERCLASS;
        } else {
            _args params [["_id", DEFAULT_ID], ["_blocking", DEFAULT_BLOCKING]];

            _result = [["id", _id], ["blocking", _blocking]] call ALiVE_fnc_hashCreate;
        };

    };

    case "init": {

        [_logic,"super", QUOTE(SUPERCLASS)] call ALiVE_fnc_hashSet;
        [_logic,"class", QUOTE(MAINCLASS)] call ALiVE_fnc_hashSet;

        [_logic,"id", DEFAULT_ID] call ALiVE_fnc_hashSet;
        [_logic,"blocking", DEFAULT_BLOCKING] call ALiVE_fnc_hashSet;

    };

    case "id": {

        if (_args isEqualType "") then {
            [_logic,_operation, _args] call ALiVE_fnc_hashSet;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashSet;
        };

    };

    case "blocking": {

        if (_args isEqualType true) then {
            [_logic,_operation, _args] call ALiVE_fnc_hashSet;
        } else {
            _result = [_logic,_operation] call ALiVE_fnc_hashSet;
        };

    };

    default {
        _result = _this call SUPERCLASS;
    };

};

if (!isnil "_result") then {_result} else {nil};