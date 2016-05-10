#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorFilterElevation);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorFilterElevation

Description:
Returns an array of sectors with elevations within the passed range

Parameters:
Array - Array of sectors

Returns:
Array of elevation filtered sectors

Examples:
(begin example)
// get sectors between 100 and 200 meters
_highSectors = [_sectors, 100, 200] call ALIVE_fnc_sectorFilterElevation;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_sectors","_elevationMin","_elevationMax","_err","_filteredSectors","_sector","_sectorData","_elevationData"];
	
_sectors = _this select 0;
_elevationMin = _this select 1;
_elevationMax = _this select 2;

_err = format["sector filter elevation requires an array of sectors - %1",_sectors];
ASSERT_TRUE(typeName _sectors == "ARRAY",_err);
_err = format["sector filter elevation requires a min elevation scalar- %1",_elevationMin];
ASSERT_TRUE(typeName _elevationMin == "SCALAR",_err);
_err = format["sector filter elevation requires a max elevation scalar- %1",_elevationMax];
ASSERT_TRUE(typeName _elevationMax == "SCALAR",_err);

_filteredSectors = [];

{
	_sector = _x;
	_sectorData = [_sector, "data"] call ALIVE_fnc_sector;
	
	if("elevation" in (_sectorData select 1)) then {
		_elevationData = [_sectorData, "elevation"] call ALIVE_fnc_hashGet;
		
		if(_elevationData >= _elevationMin && _elevationData <= _elevationMax) then {
			_filteredSectors set [count _filteredSectors, _sector];
		};
	};
	
} forEach _sectors;

_filteredSectors