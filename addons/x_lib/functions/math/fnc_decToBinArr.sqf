#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_decToBinArr

Description:
	Converts a decimal number to a binary array.
	
Parameters:
	0 - Decimal number [number]

Returns:
	Binary array [array]

Attributes:
	N/A

Examples:
	N/A

See Also:

Author:
	Naught
---------------------------------------------------------------------------- */

private ["_decimal", "_return"];
_decimal	= _this select 0;
_return		= [];

if ((_decimal % 1) == 0) then // Needs to be a whole number 
{
	private ["_i"];
	_i = 0;
	
	while {_decimal > 0} do
	{
		_return set [_i, (_decimal mod 2)];
		_decimal = floor(_decimal / 2); // (_decimal - _rem) / 2
		_i = _i + 1;
	};
};

_return
