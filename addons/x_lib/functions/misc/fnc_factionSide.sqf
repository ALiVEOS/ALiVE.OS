#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(factionSide);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_factionSide

Description:
Returns side of given faction (default EAST)

Parameters:
String - faction

Returns:
Side - Side of given faction

Examples:
(begin example)
_side = "OPF_F" call ALiVE_fnc_factionSide;
(end)

See Also:
- nil

Author:
Highhead

Peer reviewed:
nil
---------------------------------------------------------------------------- */
private ["_side"];

switch (getnumber(configfile >> "CfgFactionClasses" >> _this >> "side")) do {
	case 0 : {_side = EAST};
	case 1 : {_side = WEST};
	case 2 : {_side = RESISTANCE};
	case 3 : {_side = CIVILIAN};
	default {_side = EAST};
};
_side;