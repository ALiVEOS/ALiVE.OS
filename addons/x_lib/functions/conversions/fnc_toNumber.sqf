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
	Naught
---------------------------------------------------------------------------- */

private ["_val"];
_val = _this select 0;

if (typeName(_val) == "STRING") then
{
	_val = compile _val;
};

if (typeName(_val) == "CODE") then
{
	_val = call _val;
};

if (typeName(_val) == "BOOL") then
{
	_val = if (_val) then {1} else {0};
};

if (typeName(_val) != "SCALAR") then
{
	_val = -1;
};

_val
