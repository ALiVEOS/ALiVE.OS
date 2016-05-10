#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(getMaxBuildingPositions);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getMaxBuildingPositions

Description:
Returns number of building positions for a given object.

Parameters:
Object - Building object

Returns:
Number - Maximum building position number for the given object. If
the object has no positions, -1 is returned.

Examples:
(begin example)
// get number of building positions for an object
_maxpos = [_house] call ALIVE_fnc_getMaxBuildingPositions;
(end)

See Also:
- <ALIVE_fnc_getEnterableHouses>

Author:
Wolffy.au
---------------------------------------------------------------------------- */

private ["_house"];

PARAMS_1(_house);

count ([_house] call ALIVE_fnc_getBuildingPositions) - 1;
