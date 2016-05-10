#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_push

Description:
	Adds a value to the last of an array.
	
Parameters:
	0 - Array [array]
	1 - Value to push [any]

Returns:
	Array copy [array]

Attributes:
	N/A

Examples:
	N/A

See Also:
	- <ALiVE_fnc_insert>

Author:
	Naught
---------------------------------------------------------------------------- */

private ["_arr"];
_arr = _this select 0;

_arr pushback (_this select 1);

_arr
