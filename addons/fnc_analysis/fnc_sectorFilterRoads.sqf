#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorFilterRoads);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorFilterRoads

Description:
Returns an array of sectors with roads data as defined

Parameters:
Array - Array of sectors
String - road type to filter (road,crossroad,terminus)

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
    ["_roadType", "road"]
];

private _err = format["sector filter roads requires an array of sectors - %1",_sectors];
ASSERT_TRUE(_sectors isEqualType [], _err);

private _filteredSectors = [];

{
    private _sector = _x;
    private _sectorData = [_sector, "data"] call ALIVE_fnc_sector;

    if("roads" in (_sectorData select 1)) then {

        private _roads = [_sectorData, "roads"] call ALIVE_fnc_hashGet;
        private _roadData = [_roads, _roadType] call ALIVE_fnc_hashGet;

        if(count _roadData > 0) then {
            _filteredSectors pushback _sector;
        };
    };

} forEach _sectors;

_filteredSectors