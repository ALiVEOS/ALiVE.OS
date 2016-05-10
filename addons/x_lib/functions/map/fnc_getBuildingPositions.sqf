#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(getBuildingPositions);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getBuildingPositions

Description:
Returns the building positions for a given object.

Parameters:
Object - Building object

Returns:
Array - All building positions for the given object. If
the object has no positions, an empty array is returned.

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

private ["_house","_buildingPos","_pos","_expected","_result","_err","_positions"];

PARAMS_1(_house);

_buildingPos = -1;
_positions = [];
_pos = _house buildingPos _buildingPos + 1;
while {str _pos != "[0,0,0]"} do {
	_buildingPos = _buildingPos + 1;
	_positions pushback _pos;
	_pos = _house buildingPos _buildingPos + 1;
};

if(_buildingPos != -1) then {
	_expected = "[0,0,0]";
	_result = str (_house buildingPos _buildingPos) ;
	_err = format["max positions (%1) invalid", _buildingPos];
	ASSERT_TRUE(_result != _expected,_err);
};

_positions;
