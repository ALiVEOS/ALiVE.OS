#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_stringListToArray

Description:
    Converts a string list to an actual array.

	- Removes spaces, brackets, and quotes

Parameters:
    0 - Array String [string]

Returns:
    result [array]

Attributes:
    N/A

Examples:
    N/A

See Also:

Author:
    SpyderBlack723
---------------------------------------------------------------------------- */

private _stringList = _this;
private _arrayResult = [];

if (_stringList isequaltype "") then {
	if (_stringList != "") then {
		_stringList = [_stringList, " ", ""] call CBA_fnc_replace;
		_stringList = [_stringList, "[", ""] call CBA_fnc_replace;
		_stringList = [_stringList, "]", ""] call CBA_fnc_replace;
		_stringList = [_stringList, """", ""] call CBA_fnc_replace;

		_arrayResult = [_stringList, ","] call CBA_fnc_split;
	};
};

_arrayResult