#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(vehicleGetKindOf);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_vehicleGetKindOf

Description:
Returns vehicle class type from passed vehicle object or classname

Parameters:
Vehicle - The vehicle object or classname

Returns:

Examples:
(begin example)
_result = _vehicle call ALIVE_fnc_vehicleGetKindOf;

_result = "B_Truck_01_covered_F" call ALIVE_fnc_vehicleGetKindOf;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_vehicle","_result"];
	
_vehicle = _this;
_result = "Vehicle";

if(_vehicle isKindOf "Car") then {
	_result = "Car";
};
if(_vehicle isKindOf "Tank") then {
	_result = "Tank";
};
if(_vehicle isKindOf "Armored") then {
	_result = "Armored";
};
if(_vehicle isKindOf "Truck") then {
	_result = "Truck";
};					
if(_vehicle isKindOf "Ship") then {
	_result = "Ship";
};
if(_vehicle isKindOf "Helicopter") then {
	_result = "Helicopter";
};
if(_vehicle isKindOf "Plane") then {
	_result = "Plane";
};
if(_vehicle isKindOf "StaticWeapon") then {
	_result = "StaticWeapon";
};

_result