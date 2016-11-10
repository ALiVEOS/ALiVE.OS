#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorSortDistance);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorSortDistance

Description:
Returns an array of sectors sorted by distance to passed position

Parameters:
Array - Array of sectors
Array - Position for distances

Returns:
Array of distance sorted sectors

Examples:
(begin example)
// get sectors with west presence and unit count between 1 and 10 units
_sortedSectors = [_sectors, getPos player] call ALIVE_fnc_sectorSortDistance;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

params [
	["_sectors", [], [[]]],
	["_position", [], [[]]]
];

// Create a new array with a subarray contains [distance, sector], than sort this array and convert it back
private _sortedSectors = _sectors apply {[([_x, "center"] call ALIVE_fnc_sector) distance _position, _x]};
_sortedSectors sort true;
_sortedSectors = _sortedSectors apply {_x select 1};

_sortedSectors