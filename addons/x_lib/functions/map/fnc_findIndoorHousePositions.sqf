#include "\x\alive\addons\x_lib\script_component.hpp"
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

params ["_pos","_radius"];

private _positions = [];
private _nearbldgs = _pos nearObjects ["Static", _radius];

{
        private _house = _x;
        private _tmpPositions = [_house] call ALIVE_fnc_getBuildingPositions;
        {
                /*
                // Still there if we need it.
                if((_x select 2) < (((boundingBox _house) select 1) select 2) - 0.5) then {
                        _positions pushback _x;
                };
                */

                // Better results with a roof check
                private _position = ATLtoASL _x;

                if (lineIntersects [
                        [_position select 0, _position select 1, (_position select 2) + 0.5],
                        [_position select 0, _position select 1, (_position select 2) + 2.5]
                ]) then {
                        _positions pushback _x;
                };

        } forEach _tmppositions;
} forEach _nearbldgs;

_positions;