#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(unitArraySortSide);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_unitArraySortSide

Description:
Returns a hash of units sorted into side sub arrays keyed by side to string

Parameters:
Array - Array of units

Returns:
Hash of units by side

Examples:
(begin example)
// get near units
_unitsBySide = [_units] call ALIVE_fnc_unitArraySortSide;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_units","_err","_sideUnits","_side","_sideUnitsArray"];
	
_units = _this select 0;

_err = format["unit array sort side requires an array of units - %1",_units];
ASSERT_TRUE(typeName _units == "ARRAY",_err);

_sideUnits = [] call ALIVE_fnc_hashCreate;

[_sideUnits, "EAST", []] call ALIVE_fnc_hashSet;
[_sideUnits, "WEST", []] call ALIVE_fnc_hashSet;
[_sideUnits, "CIV", []] call ALIVE_fnc_hashSet;
[_sideUnits, "GUER", []] call ALIVE_fnc_hashSet;

{
	if!(isNull group _x) then {
		_side = side group _x;
	} else {
		_side = side _x;
	};
	
	_sideUnitsArray = [_sideUnits, format["%1",_side]] call ALIVE_fnc_hashGet;
	_sideUnitsArray pushback _x;
	
} forEach _units;

_sideUnits