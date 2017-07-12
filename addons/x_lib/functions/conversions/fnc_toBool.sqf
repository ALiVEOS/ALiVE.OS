#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_toBool

Description:
    Evaluates an expression to a boolean value.

Parameters:
    0 - Expression [any]

Returns:
    Conversion [bool]

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

params ["_eval"];

if (_eval isEqualType "") then {
    _eval = if (_eval isEqualTo "") then {false} else {compile _eval};
};

if (_eval isEqualType {}) then {
    _eval = (if ((count _this) > 1) then {_this select 1} else {[]}) call _eval;
};

if (_eval isEqualType 0) then {
    _eval = [false, true] select _eval;
};

if (typeName _eval != "BOOL") then {
    _eval = false;
};

_eval
