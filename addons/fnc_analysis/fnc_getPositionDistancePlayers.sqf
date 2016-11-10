#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(getPositionDistancePlayers);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getPositionDistancePlayers

Description:
Get closest position with no players present

Parameters:
Array - Position center point for search
Scalar - Max Radius of search
Scalar - Count positions to find
Boolean - Only land positions

Returns:
Array - position

Examples:
(begin example)
// get closest position with no players present
_position = [getPos player, 1000] call ALIVE_fnc_getPositionDistancePlayers;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

params [
	["_position", [], [[]]],
	["_distance", 1000, [0]],
	["_countToFind", 1, [0]],
	["_onlyLand", false, [false]]
];

private _sectors = [ALIVE_sectorGrid, "sectors"] call ALIVE_fnc_sectorGrid;

if (_onlyLand) then {
    _sectors = [_sectors, "SEA"] call ALIVE_fnc_sectorFilterTerrain;
};

_sectors = [_sectors, _position] call ALIVE_fnc_sectorSortDistance;

private _found = [];

{
    private _centerPos = [_x, "center"] call ALIVE_fnc_sector;

    if (([_centerPos, _distance] call ALiVE_fnc_anyPlayersInRange) == 0) then {
        // Check if position is water (in case of shore sector)
        if (_onlyLand && surfaceIsWater _centerPos) then {
            // Go find nearest land
            private _pos = [_centerPos, _distance / 2] call ALiVE_fnc_getClosestLand;

            if (_pos distance _centerPos > 5) then {
				_found pushBack _pos;
            };
        } else {
			_found pushBack _centerPos;
        };
    };
	
	if (count _found == _countToFind) exitWith {};
	
	false;
} count _sectors;

[_found, _found select 0] select (_countToFind == 1 && count _found == 1)