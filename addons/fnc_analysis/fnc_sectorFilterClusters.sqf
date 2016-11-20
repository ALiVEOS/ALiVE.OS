#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorFilterClusters);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorFilterClusters

Description:
Returns an array of sectors with a cluster type filtered out

Parameters:
Array - Array of sectors

Returns:
Array of cluster filtered sectors

Examples:
(begin example)

// get consolidated mil sectors
_milSectors = [_sectors] call ALIVE_fnc_sectorFilterClusters;

// get civ marine sectors
_marineSectors = [_sectors, "clustersCiv", "marine"] call ALIVE_fnc_sectorFilterClusters;

// get mil heli sectors
_milHeliSectors = [_sectors, "clustersMil", "heli"] call ALIVE_fnc_sectorFilterClusters;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

params [
    "_sectors",
    ["_clusterCategory", "clustersMil"],
    ["_clusterType", "consolidated"]
];

private _err = format["sector filter clusters requires an array of sectors - %1",_sectors];
ASSERT_TRUE(_sectors isEqualType [], _err);

private _filteredSectors = [];

{
    private _sector = _x;
    private _sectorData = [_sector, "data"] call ALIVE_fnc_sector;

    if(_clusterCategory in (_sectorData select 1)) then {

        private _clusterData = [_sectorData, _clusterCategory] call ALIVE_fnc_hashGet;
        private _clusterTypeData = [_clusterData, _clusterType] call ALIVE_fnc_hashGet;

        if(count _clusterTypeData > 0) then {
            _filteredSectors pushback _sector;
        };
    };
} forEach _sectors;

_filteredSectors