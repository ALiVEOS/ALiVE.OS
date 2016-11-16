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

params ["_sectors","_elevationMin","_elevationMax"];

private _err = format["sector filter elevation requires an array of sectors - %1",_sectors];
ASSERT_TRUE(_sectors isEqualType [], _err);
_err = format["sector filter elevation requires a min elevation scalar- %1",_elevationMin];
ASSERT_TRUE(_elevationMin isEqualType 0, _err);
_err = format["sector filter elevation requires a max elevation scalar- %1",_elevationMax];
ASSERT_TRUE(_elevationMax isEqualType 0, _err);

private _filteredSectors = [];

{
    private _sector = _x;
    private _sectorData = [_sector, "data"] call ALIVE_fnc_sector;

    if("elevation" in (_sectorData select 1)) then {
        private _elevationData = [_sectorData, "elevation"] call ALIVE_fnc_hashGet;

        if(_elevationData >= _elevationMin && _elevationData <= _elevationMax) then {
            _filteredSectors pushback _sector;
        };
    };
} forEach _sectors;

_filteredSectors