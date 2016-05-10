#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_random

Description:
	Generates a pseudo-random number.
	
Parameters:
	0 - Seed [number] (optional)

Returns:
	Random number [number]

Attributes:
	N/A

Examples:
	N/A

See Also:

Author:
	Naught
---------------------------------------------------------------------------- */

(((2^8) + 1) * (if ((count _this) > 0) then {_this select 0} else {random(2^16)}) + ((2^11) + 1)) mod (2^16)
