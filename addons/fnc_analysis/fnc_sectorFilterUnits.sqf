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

params ["_sectors","_side","_unitCountMin","_unitCountMax"];

private _err = format["sector filter units requires an array of sectors - %1",_sectors];
ASSERT_TRUE(_sectors isEqualType [], _err);
_err = format["sector filter units requires a string side - %1",_side];
ASSERT_TRUE(_sectors isEqualType [], _err);
_err = format["sector filter units requires a min units scalar- %1",_unitCountMin];
ASSERT_TRUE(_unitCountMin isEqualType 0, _err);
_err = format["sector filter units requires a max units scalar- %1",_unitCountMax];
ASSERT_TRUE(_unitCountMax isEqualType 0, _err);

private _filteredSectors = [];

{
    private _sector = _x;
    private _sectorData = [_sector, "data"] call ALIVE_fnc_sector;
    private _unitData = [_sectorData, "units"] call ALIVE_fnc_hashGet;
    private _units = [_unitData, _side] call ALIVE_fnc_hashGet;

    if(count _units > 0 && count _units > _unitCountMin &&  count _units < _unitCountMax) then {
        _filteredSectors pushback _sector;
    };
} forEach _sectors;

_filteredSectors