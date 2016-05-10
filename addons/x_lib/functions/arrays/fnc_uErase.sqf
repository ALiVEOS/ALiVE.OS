#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_uErase

Description:
	Erases a value from an array (unordered).
	
Parameters:
	0 - Array [array]
	1 - Index to erase [number]

Returns:
	Array copy [array]

Attributes:
	N/A

Examples:
	N/A

See Also:
	- <ALiVE_fnc_erase>

Author:
	Naught
---------------------------------------------------------------------------- */

private ["_arr", "_last"];
_arr = _this select 0;
_last = (count _arr) - 1;

_arr set [(_this select 1), (_arr select _last)];
_arr resize _last;

_arr
