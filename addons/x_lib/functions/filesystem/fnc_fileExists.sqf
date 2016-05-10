#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fileExists

Description:
	Returns whether a file exists

Parameters:
	0 - File path to check [string]

Returns:
	file exists [bool]

Attributes:
	N/A

Examples:
	N/A

See Also:

Author:
	Tupolov
---------------------------------------------------------------------------- */

private ["_ctrl", "_fileExists","_file"];

_file = _this select 0;

disableSerialization;

_ctrl = findDisplay 0 ctrlCreate ["RscHTML", -1];

_ctrl htmlLoad _file;

_fileExists = ctrlHTMLLoaded _ctrl;

ctrlDelete _ctrl;

_fileExists