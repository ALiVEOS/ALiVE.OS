#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(findNearHousePositions);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_findNearHousePositions

Description:
Provide a list of house positions in the area

Parameters:
Array - Position
Number - Radius to search
String - Object type to search for (optional)

Returns:
Array - A list of building positions

Examples:
(begin example)
// find nearby houses
_bldgpos = [_pos,50] call ALIVE_fnc_findNearHousePositions;

// find nearby Buildings
_bldgpos = [_pos,150,"Building"] call ALIVE_fnc_findNearHousePositions;
(end)

See Also:
- <ALIVE_fnc_getBuildingPositions>
- <ALIVE_fnc_findIndoorHousePositions>

Author:
Highhead
---------------------------------------------------------------------------- */

private ["_pos","_radius","_positions","_nearbldgs"];

PARAMS_2(_pos,_radius);
DEFAULT_PARAM(2,_type,"House");

_positions = [];
//_nearbldgs = nearestObjects [_pos, [_type], _radius];
_nearbldgs = _pos nearObjects [_type, _radius];

{
	_positions = _positions + ([_x] call ALIVE_fnc_getBuildingPositions);
} forEach _nearbldgs;

_positions;
