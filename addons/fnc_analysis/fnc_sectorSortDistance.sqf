#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorSortDistance);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorSortDistance

Description:
Returns an array of sectors sorted by distance to passed position
Uses RUBEs shell sort implemented into ALIVE

Parameters:
Array - Array of sectors

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

private ["_sectors","_position","_err","_getDistance","_sortedSectors","_sector"];
	
_sectors = _this select 0;
_position = _this select 1;

_err = format["sector sort distance requires an array of sectors - %1",_sectors];
ASSERT_TRUE(typeName _sectors == "ARRAY",_err);
_err = format["sector sort distance requires an array position - %1",_position];
ASSERT_TRUE(typeName _position == "ARRAY",_err);

_getDistance = {
	private ["_sector", "_centerPosition", "_distance"];	
	_sector = _this select 0;
	_centerPosition = [_sector, "center"] call ALIVE_fnc_sector;	
	_distance = _centerPosition distance _position;
	_distance	
};

_sortedSectors = [_sectors, {
	([_this] call _getDistance)
}] call ALIVE_fnc_shellSort;

_sortedSectors