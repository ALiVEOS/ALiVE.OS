#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorFilterTerrain);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorFilterTerrain

Description:
Returns an array of sectors with a terrain type filtered out

Parameters:
Array - Array of sectors

Returns:
Array of terrain filtered sectors

Examples:
(begin example)
// get near units
_landSectors = [_sectors, "SEA"] call ALIVE_fnc_sectorFilterTerrain;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_sectors","_terrainType","_err","_filteredSectors","_sector","_sectorData","_terrainData"];
	
_sectors = _this select 0;
_terrainType = _this select 1;

_err = format["sector filter terrain requires an array of sectors - %1",_sectors];
ASSERT_TRUE(typeName _sectors == "ARRAY",_err);
_err = format["sector filter terrain requires a terrain type string - %1",_terrainType];
ASSERT_TRUE(typeName _terrainType == "STRING",_err);

_filteredSectors = [];

{
	_sector = _x;
	_sectorData = [_sector, "data"] call ALIVE_fnc_sector;
	
	if("terrain" in (_sectorData select 1)) then {
		_terrainData = [_sectorData, "terrain"] call ALIVE_fnc_hashGet;
		
		if!(_terrainData == _terrainType) then {
			_filteredSectors set [count _filteredSectors, _sector];
		};
	};
	
} forEach _sectors;

_filteredSectors