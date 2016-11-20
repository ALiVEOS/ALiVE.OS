#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorFilterBestPlaces);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorFilterBestPlaces

Description:
Returns an array of sectors with best places as defined by passed parameters

Parameters:
Array - Array of sectors
String - place type to filter (forest,exposedHills,meadow,exposedTrees,houses,sea)

Returns:
Array of best places filtered sectors

Examples:
(begin example)
// get all sectors containing forests
_forestedSectors = [_sectors, "forest"] call ALIVE_fnc_sectorFilterBestPlaces;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

params ["_sectors","_placeType"];

private _err = format ["sector filter best places requires an array of sectors - %1", _sectors];
ASSERT_TRUE(_sectors isEqualType [], _err);
_err = format ["sector filter best places requires a place type string- %1", _placeType];
ASSERT_TRUE(_placeType isEqualType "", _err);

private _filteredSectors = [];

{
    private _sector = _x;
    private _sectorData = [_sector, "data"] call ALIVE_fnc_sector;

    if("bestPlaces" in (_sectorData select 1)) then {
        private _bestPlaces = [_sectorData, "bestPlaces"] call ALIVE_fnc_hashGet;

        private _placesTypeData = [_bestPlaces,_placeType] call ALIVE_fnc_hashGet;

        if (!(isnil "_placesTypeData") && {count _placesTypeData > 0}) then {
            _filteredSectors pushback _sector;
        };
    };
} forEach _sectors;

_filteredSectors