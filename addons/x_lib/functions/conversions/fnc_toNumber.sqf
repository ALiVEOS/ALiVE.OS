#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_toNumber

Description:
    Extracts a number value from an expression.

Parameters:
    0 - Expression [anything]

Returns:
    Value [number]

Attributes:
    N/A

Examples:
    N/A

See Also:

Notes:
    1. Not safe for user input.

Author:
    Naught, dixon13
---------------------------------------------------------------------------- */

params ["_val"];

if (_val isEqualType "") then {
    _val = compile _val;
};

if (_val isEqualType {}) then {
    _val = call _val;
};

if (_val isEqualType true) then {
    _val = [0, 1] select _val;
};

if (typeName _val != "SCALAR") then {
    _val = -1;
};

_val
