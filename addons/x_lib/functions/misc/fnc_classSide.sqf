#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(classSide);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_classSide

Description:
Returns side of given class (default EAST)

Parameters:
String - class

Returns:
Side - Side of given class

Examples:
(begin example)
_side = "B_Heli_Transport_01_F" call ALiVE_fnc_classSide;
(end)

See Also:
- nil

Author:
Highhead

Peer reviewed:
nil
---------------------------------------------------------------------------- */
private ["_side"];

switch (getNumber(configfile >> "CfgVehicles" >> _this >> "side")) do {
	case 0 : {_side = EAST};
	case 1 : {_side = WEST};
	case 2 : {_side = RESISTANCE};
	case 3 : {_side = CIVILIAN};
	default {_side = EAST};
};
_side;