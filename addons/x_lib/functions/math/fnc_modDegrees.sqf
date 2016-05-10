#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_modDegrees

Description:
	Rounds a degree value to 0 <= X <= 360.
	
Parameters:
	0 - Degree number [number]

Returns:
	Modulated degree [number]

Attributes:
	N/A

Examples:
	N/A

See Also:

Author:
	Naught
---------------------------------------------------------------------------- */

(((_this select 0) % 360) + 360) % 360
