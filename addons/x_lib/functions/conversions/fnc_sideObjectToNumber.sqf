#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(sideObjectToNumber);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sideObjectToNumber

Description:
Return side number

Parameters:
Side - side

Returns:
Scalar - side number

Examples:
(begin example)
//
_result = [WEST] call ALIVE_fnc_sideObjectToNumber;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_side","_sideNumber"];

_side = _this select 0;

switch (_side) do
{
	case EAST: {0};
	case WEST: {1};
	case RESISTANCE: {2};
	case CIVILIAN: {3};
    default {3};
};