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

params [
    "_sectors",
    ["_isActive", true]
]

private _err = format["sector filter active requires an array of sectors - %1",_sectors];
ASSERT_TRUE(_sectors isEqualto [], _err);

private _filteredSectors = [];

{
    private _sector = _x;
    private _sectorData = [_sector, "data"] call ALIVE_fnc_sector;

    if("active" in (_sectorData select 1)) then {

        private _active = [_sectorData, "active"] call ALIVE_fnc_hashGet;

        if(_isActive) then {
            if(count _active > 0) then {
                _filteredSectors pushback _sector;
            };
        }else{
            if(count _active == 0) then {
                _filteredSectors pushback _sector;
            };
        };

    }else{
        if!(_isActive) then {
            _filteredSectors pushback _sector;
        };
    };
} forEach _sectors;

_filteredSectors