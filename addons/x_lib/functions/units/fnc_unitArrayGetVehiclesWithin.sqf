#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(unitArrayGetVehiclesWithin);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_unitArrayGetVehiclesWithin

Description:
Get all vehicles that units are within

Parameters:
Array - units

Returns:
Array

Examples:
(begin example)
// get all vehicles that units are within
_result = _units call ALIVE_fnc_unitArrayGetVehiclesWithin;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_units","_result","_vehicle"];
	
_units = _this;

_result = [];

{
	if (!(vehicle _x == _x)) then {
	
		_vehicle = (vehicle _x);
		
		if!(_vehicle in _result) then {
			_result pushback _vehicle;
		};	
	};
} forEach _units;

_result