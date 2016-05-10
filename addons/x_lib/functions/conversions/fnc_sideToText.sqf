#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_sideToText

Description:
	Converts a side to human-readable text.
	
Parameters:
	0 - Side [side]

Returns:
	Side name [string]

Attributes:
	N/A

Examples:
	N/A

See Also:

Author:
	Naught
---------------------------------------------------------------------------- */

switch (_this select 0) do
{
	case WEST: {'Blufor'};
	case EAST: {'Opfor'};
	case RESISTANCE: {'Independent'};
	case CIVILIAN: {'Civilian'};
	case SIDEENEMY: {'Renegade'};
	case SIDEFRIENDLY: {'Friendlies'};
	case default {'NULL'};
};
