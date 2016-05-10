#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(vehicleSetAmmo);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_vehicleSetAmmo

Description:
Sets a vehicles ammo from a passed multi dimensional array from ALIVE_fnc_vehicleGetAmmo

Parameters:
Vehicle - The vehicle

Returns:

Examples:
(begin example)
_result = [_vehicle, _ammo] call ALIVE_fnc_vehicleSetAmmo;
(end)

See Also:
ALIVE_fnc_vehicleGetAmmo

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_vehicle","_ammo","_magazineClass","_roundCount","_roundMax"];
	
_vehicle = _this select 0;
_ammo = _this select 1;

// remove current load
{_vehicle removeMagazine _x} forEach magazines _vehicle;

// load according to passed ammo array
{
	_magazineClass = _x select 0;
	_roundCount = _x select 1;
	_roundMax = _x select 2;
	_vehicle addMagazine [_magazineClass, _roundCount];
} forEach _ammo;