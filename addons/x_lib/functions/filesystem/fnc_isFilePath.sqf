#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_isFilePath

Description:
	Returns whether a string is a valid
	file path (doesn't verify path).
	
Parameters:
	0 - File path to check [string]

Returns:
	Is file path [bool]

Attributes:
	N/A

Examples:
	N/A

See Also:

Author:
	Naught
---------------------------------------------------------------------------- */

private ["_stringArray"];
_stringArray = toArray(_this select 0);

(46 in _stringArray) && {!(34 in _stringArray)} && {!(39 in _stringArray)} // 46='.', 34=("), 39=(') (ie: 'path\file.sqf')
