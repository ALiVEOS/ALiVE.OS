#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(unitArrayFilterInSector);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_unitArrayFilterInSector

Description:
Returns an array of all units found in the passed array that are within the passed sector

Parameters:
Object - Sector object
Array - Array of units

Returns:
Array of in sector units

Examples:
(begin example)
// get near units
_inSectorUnits = [_units] call ALIVE_fnc_unitArrayFilterInSector;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_units","_sector","_err","_inSectorUnits"];

_units = _this select 0;
_sector = _this select 1;

_err = format["unit array filter in sector requires an array of units - %1",_units];
ASSERT_TRUE(typeName _units == "ARRAY",_err);
_err = format["unit array filter in sector requires a sector - %1",_sector];
ASSERT_TRUE(typeName _sector == "ARRAY",_err);

_inSectorUnits = [];

{
	if([_sector, "within", getPos _x] call ALIVE_fnc_sector) then {
		_inSectorUnits set [count _inSectorUnits, _x];
	};		
} forEach _units;

_inSectorUnits