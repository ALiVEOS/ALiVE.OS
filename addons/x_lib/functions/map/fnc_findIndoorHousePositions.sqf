#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(findIndoorHousePositions);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_findIndoorHousePositions

Description:
Provide a list of house positions in the area excluding rooftops

Parameters:
Array - Position
Number - Radius to search

Returns:
Array - A list of building positions

Examples:
(begin example)
// find nearby houses
_bldgpos = [_pos,50] call ALIVE_fnc_findIndoorHousePositions;
(end)

See Also:
- <ALIVE_fnc_getBuildingPositions>
- <ALIVE_fnc_findNearHousePositions>

Author:
Highhead
---------------------------------------------------------------------------- */

private ["_pos","_radius","_positions","_nearbldgs","_tmppositions","_house"];

PARAMS_2(_pos,_radius);
_positions = [];
_nearbldgs = nearestObjects [_pos, ["House"], _radius];
{
        _house = _x;
        _tmpPositions = [_house] call ALIVE_fnc_getBuildingPositions;
        {
                if((_x select 2) < (((boundingBox _house) select 1) select 2) - 0.5) then {
                        _positions pushback _x;
                };
        } forEach _tmppositions;
} forEach _nearbldgs;

_positions;
