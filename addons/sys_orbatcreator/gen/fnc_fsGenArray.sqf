#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsGenArray);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsGenArray

Description:
A value to config text, recursively: an array to {a,b,...} ({} when empty),
strings through ALiVE_fnc_fsGenQuote, whole numbers with toFixed 0 and other
numbers with toFixed 2 (never str, which writes 1.23457e+06), true/false as 1/0.

Parameters:
    _value - ARRAY, STRING, NUMBER or BOOL

Returns:
    STRING

Examples:
    (begin example)
    [["arifle_MX_F", ["30Rnd_65x39_caseless_mag", 30]]] call ALiVE_fnc_fsGenArray;
    // {"arifle_MX_F",{"30Rnd_65x39_caseless_mag",30}}
    (end)

Author:
    Jman
---------------------------------------------------------------------------- */

params ["_value"];

if (isNil "_value") exitWith { """""" };
if (_value isEqualType "") exitWith { [_value] call ALiVE_fnc_fsGenQuote };
if (_value isEqualType 0) exitWith { if (_value == round _value) then { _value toFixed 0 } else { _value toFixed 2 } };
if (_value isEqualType true) exitWith { ["0", "1"] select _value };
if (_value isEqualType []) exitWith { "{" + ((_value apply { [_x] call ALiVE_fnc_fsGenArray }) joinString ",") + "}" };
""""""
