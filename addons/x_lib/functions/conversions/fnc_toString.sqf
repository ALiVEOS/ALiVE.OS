#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_toString

Description:
    Converts a value to a string.

Parameters:
    0 - Value [any]

Returns:
    String conversion [string]

Attributes:
    N/A

Examples:
    N/A

See Also:

Author:
    Naught
---------------------------------------------------------------------------- */

params ["_val"];

_return = switch (typeName _val) do {
    case "STRING": {_val};
    case "ARRAY": {
        private ["_ret"];
        _ret = "";

        { // forEach
            if (_forEachIndex != 0) then {_ret = _ret + ", "};
            _ret = _ret + ([_x] call ALiVE_fnc_toString);
        } forEach _val;

        _ret
    };
    case "SIDE": {[_val] call ALiVE_fnc_sideToText};
    default {str(_val)};
};

_return