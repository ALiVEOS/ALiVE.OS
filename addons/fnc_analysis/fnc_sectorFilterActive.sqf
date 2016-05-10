#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorFilterActive);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorFilterActive

Description:
Returns an array of sectors that are active

Parameters:
Array - Array of sectors

Returns:
Array of road filtered sectors

Examples:
(begin example)
// get all sectors that contain road positions
_roadSectors = [_sectors] call ALIVE_fnc_sectorFilterRoads;

// get all sectors that contain crossroads positions
_roadSectors = [_sectors,"crossroad"] call ALIVE_fnc_sectorFilterRoads;

// get all sectors that contain terminus road positions
_roadSectors = [_sectors,"terminus"] call ALIVE_fnc_sectorFilterRoads;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_sectors","_isActive","_err","_filteredSectors","_sector","_sectorData","_active"];
	
_sectors = _this select 0;
_isActive = if(count _this > 1) then {_this select 1} else {true};

_err = format["sector filter active requires an array of sectors - %1",_sectors];
ASSERT_TRUE(typeName _sectors == "ARRAY",_err);

_filteredSectors = [];

{
	_sector = _x;
	_sectorData = [_sector, "data"] call ALIVE_fnc_sector;
	
	if("active" in (_sectorData select 1)) then {
		
		_active = [_sectorData, "active"] call ALIVE_fnc_hashGet;

		if(_isActive) then {
            if(count _active > 0) then {
                _filteredSectors set [count _filteredSectors, _sector];
            };
		}else{
            if(count _active == 0) then {
                _filteredSectors set [count _filteredSectors, _sector];
            };
		};

	}else{
        if!(_isActive) then {
            _filteredSectors set [count _filteredSectors, _sector];
        };
	};
	
} forEach _sectors;

_filteredSectors