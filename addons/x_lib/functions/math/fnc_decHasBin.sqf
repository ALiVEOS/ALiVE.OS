#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_decHasBin

Description:
	Returns whether a decimal number contains a specific
	binary number (power of 2).
	
Parameters:
	0 - Decimal number [number]

Returns:
	Decimal has binary number [bool]

Attributes:
	N/A

Examples:
	N/A

See Also:

Author:
	Naught
---------------------------------------------------------------------------- */

private ["_decimal", "_binary", "_return"];
_decimal	= _this select 0;
_binary		= _this select 1;
_return		= false;

if (_binary != 0) then
{
	if (_decimal == _binary) then {_return = true};
	
	if (_decimal > _binary) then
	{
		if (((log(_binary) / log(2)) % 1) == 0) then
		{
			if (floor((_decimal / _binary) % 2) == 1) then
			{
				_return = true;
			};
		}
		else
		{
			if (((_binary % 1) == 0) && ((_decimal % 1) == 0)) then
			{
				private ["_i"];
				_i = 0;
				_return = true;
				
				while {_binary > 0} do
				{
					if (((_binary mod 2) == 1) && ((_decimal mod 2) != 1)) exitWith {_return = false};
					_binary = floor(_binary / 2);
					_decimal = floor(_decimal / 2);
					_i = _i + 1;
				};
			};
		};
	};
};

_return
