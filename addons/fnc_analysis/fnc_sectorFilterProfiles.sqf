#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorFilterProfiles);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorFilterProfiles

Description:
Returns an array of sectors with profiles as defined with the passed parameters

Parameters:
Array - Array of sectors

Returns:
Array of profile filtered sectors

Examples:
(begin example)
// get sectors between 100 and 200 meters
_eastEntitySectors = [_allSectors, "entity", "EAST"] call ALIVE_fnc_sectorFilterProfiles;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

params ["_sectors","_profileType","_profileSide"];

private _err = format["sector filter profiles requires an array of sectors - %1",_sectors];
ASSERT_TRUE(_sectors isEqualType [], _err);
_err = format["sector filter profiles requires a profile type string- %1",_profileType];
ASSERT_TRUE(_profileType isEqualType "", _err);
_err = format["sector filter profiles requires a profile side string- %1",_profileSide];
ASSERT_TRUE(_profileSide isEqualType "", _err);

private _filteredSectors = [];

{
    private _sector = _x;
    private _sectorData = [_sector, "data"] call ALIVE_fnc_sector;

    switch(_profileType) do {
        case "entity": {
            if("entitiesBySide" in (_sectorData select 1)) then {
                private _sideProfiles = [_sectorData, "entitiesBySide"] call ALIVE_fnc_hashGet;
                private _sideProfile = [_sideProfiles, _profileSide] call ALIVE_fnc_hashGet;

                if(count _sideProfile > 0) then {
                    _filteredSectors pushback _sector;
                };
            };
        };
        case "vehicle": {
            if("vehiclesBySide" in (_sectorData select 1)) then {
                private _sideProfiles = [_sectorData, "vehiclesBySide"] call ALIVE_fnc_hashGet;
                private _sideProfile = [_sideProfiles, _profileSide] call ALIVE_fnc_hashGet;

                if(count _sideProfile > 0) then {
                    _filteredSectors pushback _sector;
                };
            };
        };
    };
} forEach _sectors;

_filteredSectors