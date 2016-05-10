#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorFilterUnits);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorFilterUnits

Description:
Returns an array of sectors with unit counts and sides as passed

Parameters:
Array - Array of sectors

Returns:
Array of unit filtered sectors

Examples:
(begin example)
// get sectors with west presence and unit count between 1 and 10 units
_westSectors = [_sectors, "WEST", 0, 10] call ALIVE_fnc_sectorFilterUnits;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_sectors","_side","_unitCountMin","_unitCountMax","_err","_filteredSectors","_sector","_sectorData","_unitData","_units"];
	
_sectors = _this select 0;
_side = _this select 1;
_unitCountMin = _this select 2;
_unitCountMax = _this select 3;

_err = format["sector filter units requires an array of sectors - %1",_sectors];
ASSERT_TRUE(typeName _sectors == "ARRAY",_err);
_err = format["sector filter units requires a string side - %1",_side];
ASSERT_TRUE(typeName _sectors == "ARRAY",_err);
_err = format["sector filter units requires a min units scalar- %1",_unitCountMin];
ASSERT_TRUE(typeName _unitCountMin == "SCALAR",_err);
_err = format["sector filter units requires a max units scalar- %1",_unitCountMax];
ASSERT_TRUE(typeName _unitCountMax == "SCALAR",_err);

_filteredSectors = [];

{
	_sector = _x;
	_sectorData = [_sector, "data"] call ALIVE_fnc_sector;
	_unitData = [_sectorData, "units"] call ALIVE_fnc_hashGet;
	_units = [_unitData, _side] call ALIVE_fnc_hashGet;
	
	if(count _units > 0 && count _units > _unitCountMin &&  count _units < _unitCountMax) then {
		_filteredSectors set [count _filteredSectors, _sector];
	};
	
} forEach _sectors;

_filteredSectors