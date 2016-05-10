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
	Naught
---------------------------------------------------------------------------- */

private ["_eval"];
_eval = _this select 0;

if (typeName(_eval) == "STRING") then
{
	_eval = if (_eval == "") then {false} else {compile _eval};
};

if (typeName(_eval) == "CODE") then
{
	_eval = (if ((count _this) > 1) then {_this select 1} else {[]}) call _eval;
};

if (typeName(_eval) == "SCALAR") then
{
	switch (_eval) do
	{
		case 0: {_eval = false;};
		case 1: {_eval = true;};
	};
};

if (typeName(_eval) != "BOOL") then
{
	_eval = false;
};

_eval
