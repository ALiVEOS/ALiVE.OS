#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profile);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
Description:
Base class for profile objects to inherit from

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
// create a profile
_logic = [nil, "create"] call ALIVE_fnc_profile;
(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALIVE_fnc_baseClassHash
#define MAINCLASS   ALIVE_fnc_profile

TRACE_1("profile - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
private _result = true;

#define MTEMPLATE "ALiVE_PROFILE_%1"

switch(_operation) do {

    case "create": {

        _result = [] call ALiVE_fnc_hashCreate;

    };

    case "init": {

        if (isServer) then {
            [_logic, [
                ["debug", false],       // select 2 select 0
                ["active", false],      // select 2 select 1
                ["position", [0,0]],    // select 2 select 2
                ["side", "EAST"],       // select 2 select 3
                ["profileID", ""],      // select 2 select 4
                ["type", "entity"],     // select 2 select 5
                ["objectType", "inf"],  // select 2 select 6
                ["vehicleAssignments", [] call ALiVE_fnc_hashCreate] // select 2 select 7
            ]] call ALiVE_fnc_hashSetMany;
        };

    };

    case "destroy": {

        if (isServer) then {
            [_logic,"destroy"] call SUPERCLASS;
        };

    };

    case "state": {

        if !(_args isEqualType []) then {
            // Save state

            private _state = [] call ALIVE_fnc_hashCreate;

            {
                if (!(_x == "super") && !(_x == "class")) then {
                    [_state,_x, [_logic,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
                };
            } forEach (_logic select 1);

            _result = _state;
        } else {
            // Restore state

            {
                [_logic,_x, [_args,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
            } forEach (_args select 1);
        };

    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };

};

TRACE_1("profile - output",_result);

_result;
