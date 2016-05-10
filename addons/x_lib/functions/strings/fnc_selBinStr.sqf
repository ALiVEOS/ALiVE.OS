#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_selBinStr

Description:
	Selects an index value from a binary string.
	
Parameters:
	0 - Binary string [string]
	1 - Binary string index [number]

Returns:
	Index result [bool]

Attributes:
	N/A

Examples:
	N/A

See Also:

Author:
	Naught
---------------------------------------------------------------------------- */

private ["_binStrArr", "_index"];
_binStrArr = toArray(_this select 0);
_index = _this select 1;

((count _binStrArr) > _index) && {(_binStrArr select _index) == 49} // 49 = Digit One
