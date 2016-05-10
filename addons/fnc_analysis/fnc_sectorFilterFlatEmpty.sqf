#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorFilterFlatEmpty);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorFilterFlatEmpty

Description:
Returns an array of sectors with flat empty as defined by passed parameters

Parameters:
Array - Array of sectors

Returns:
Array of flat empty filtered sectors

Examples:
(begin example)
// get all sectors that contain flat empty positions
_flatEmptySectors = [_sectors] call ALIVE_fnc_sectorFilterFlatEmpty;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_sectors","_err","_filteredSectors","_sector","_sectorData","_flatEmpty"];
	
_sectors = _this select 0;

_err = format["sector filter best places requires an array of sectors - %1",_sectors];
ASSERT_TRUE(typeName _sectors == "ARRAY",_err);

_filteredSectors = [];

{
	_sector = _x;
	_sectorData = [_sector, "data"] call ALIVE_fnc_sector;
	
	if("flatEmpty" in (_sectorData select 1)) then {
		_flatEmpty = [_sectorData, "flatEmpty"] call ALIVE_fnc_hashGet;
		
		if(count _flatEmpty > 0) then {
			_filteredSectors set [count _filteredSectors, _sector];
		};
	};
	
} forEach _sectors;

_filteredSectors