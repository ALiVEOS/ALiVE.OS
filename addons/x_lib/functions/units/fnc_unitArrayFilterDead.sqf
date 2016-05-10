#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(unitArrayFilterDead);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_unitArrayFilterDead

Description:
Returns an array of all alive units found in the passed array.

Parameters:
Array - Array of units

Returns:
Array of alive units

Examples:
(begin example)
// get near units
_aliveUnits = [_units] call ALIVE_fnc_unitArrayFilterDead;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_units", "_aliveUnits","_err"];
	
_units = _this select 0;

_err = format["unit array filter dead requires an array of units - %1",_units];
ASSERT_TRUE(typeName _units == "ARRAY",_err);

_aliveUnits = [];

{
	if(alive _x) then {
		_aliveUnits pushback _x;
	};
	
} forEach _units;

_aliveUnits