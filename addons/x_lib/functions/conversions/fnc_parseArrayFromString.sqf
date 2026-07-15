#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(parseArrayFromString);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_parseArrayFromString

Description:
Returns array from valid stringified array

Parameters:
String - stringified array

Returns:
Array - parsed array

Examples:
(begin example)
//
private _string = "[BLU_F, IND_F]";
_array = [_string] call ALIVE_fnc_parseArrayFromString; // ["BLU_F", "IND_F"]
(end)

See Also:

Author:
SpyderBlack723
---------------------------------------------------------------------------- */

private _str = _this select 0;

if (!(_str isequaltype "") or {_str isequalto ""}) exitwith { [] };

// remove spaces
_str = [_str, " ", ""] call CBA_fnc_replace;

// remove quotations
_str = [_str, """", ""] call CBA_fnc_replace;
_str = [_str, "''", ""] call CBA_fnc_replace;

// remove brackets
_str = [_str, "[", ""] call CBA_fnc_replace;
_str = [_str, "]", ""] call CBA_fnc_replace;

// split array entries into strings
_str = [_str, ","] call CBA_fnc_split;

_str