#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(findNearHousePositions);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_findNearHousePositions

Description:
Provide a list of house positions in the area

Parameters:
Array - Position
Number - Radius to search
Array - Array of Object types to search for (optional)

Returns:
Array - A list of building positions

Examples:
(begin example)
// find nearby houses
_bldgpos = [_pos,50] call ALIVE_fnc_findNearHousePositions;

// find nearby Buildings
_bldgpos = [_pos,150,["Building","House"]] call ALIVE_fnc_findNearHousePositions;
(end)

See Also:
- <ALIVE_fnc_getBuildingPositions>
- <ALIVE_fnc_findIndoorHousePositions>

Author:
Highhead
---------------------------------------------------------------------------- */

params [
    ["_pos", [0,0,0]],
    ["_radius", 50],
    ["_types", ["House","Building","Land_vn_cave_base"]]
];

private _nearbldgs = nearestObjects [_pos, _types, _radius];
// filter out SPE bocage objects 
_nearbldgs = _nearbldgs select {!(_x isKindOf "spe_bocage_base")};

private _positions = [];
{
    _positions = _positions + ([_x] call ALIVE_fnc_getBuildingPositions);
} forEach _nearbldgs;

_positions;