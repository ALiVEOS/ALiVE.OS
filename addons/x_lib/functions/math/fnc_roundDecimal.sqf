#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_roundDecimal

Description:
	Rounds a numerical value to a certain number of decimal places.
	
Parameters:
	0 - Decimal number [number]
	1 - Decimal places [number]

Returns:
	Rounded decimal [number]

Attributes:
	N/A

Examples:
	N/A

See Also:

Author:
	Naught
---------------------------------------------------------------------------- */

private ["_prec"];
_prec = 10^(_this select 1);

round((_this select 0) * _prec) / _prec
