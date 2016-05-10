#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_getPos

Description:
	Gets the position of a thing.
	
Parameters:
	0 - thing [object:marker:array]

Returns:
	Position [array]

Attributes:
	N/A

Examples:
	N/A

See Also:

Author:
	Naught
---------------------------------------------------------------------------- */

private ["_thing"];
_thing = _this select 0;

switch (typeName _thing) do
{
	case "OBJECT": {getPos _thing};
	case "STRING": {getMarkerPos _thing};
	case "ARRAY": {getWPPos _thing};
	default {[0,0,0]};
};
