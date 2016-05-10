#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_pop

Description:
	Removes a value from the end of the array.
	
Parameters:
	0 - Array [array]

Returns:
	Array copy [array]

Attributes:
	N/A

Examples:
	N/A

See Also:

Author:
	Naught
---------------------------------------------------------------------------- */

private ["_arr", "_arrCount"];
_arr = _this select 0;
_arrCount = count _arr;

if (_arrCount > 0) then
{
	_arr resize (_arrCount - 1);
};

_arr
