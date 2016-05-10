#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_dirTo

Description:
	Calculates the direction to a position from a position.
	
Parameters:
	0 - From object or position [any]
	1 - To object or position [any]

Returns:
	Direction in degrees [number]

Attributes:
	N/A

Examples:
	N/A

See Also:

Author:
	Naught
---------------------------------------------------------------------------- */

private ["_from", "_to"];
_from = [_this select 0] call ALiVE_fnc_getPos;
_to = [_this select 1] call ALiVE_fnc_getPos;

[((_to select 0) - (_from select 0)) atan2 ((_to select 1) - (_from select 1))] call ALiVE_fnc_modDegrees
