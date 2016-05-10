#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(vehicleDismount);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_vehicleDismount

Description:
Dismount from vehicle by passed vehicle assignment array

Parameters:
Array - assignments array
Vehicle - The vehicle
Boolean - gunners dismount

Returns:

Examples:
(begin example)
// dismount all assignments
_result = [[[_unit],[_unit,_unit],[],[]], _vehicle] call ALIVE_fnc_vehicleDismount;

// dismount all assignments except gunners
_result = [[[_unit],[_unit,_unit],[],[]], _vehicle, false] call ALIVE_fnc_vehicleDismount;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_assignments", "_vehicle", "_gunnersDismount", "_driver", "_gunners", "_commander", "_cargo","_turret","_turrets","_unit"];
	
_assignments = _this select 0;
_vehicle = _this select 1;
_gunnersDismount = if(count _this > 2) then {_this select 2} else {true};

/*
["VEHICLE DISMOUNT : %1",_vehicle] call ALIVE_fnc_dump;
["VEHICLE DISMOUNT ASSIGNMENTS %1",_vehicle] call ALIVE_fnc_dump;
_assignments call ALIVE_fnc_inspectArray;
*/

// driver
_driver = _assignments select 0;	
{
	unassignVehicle _x;
	[_x] orderGetIn false;
} forEach _driver;

// gunner
if(_gunnersDismount) then
{
	_gunners = _assignments select 1;
	{
		unassignVehicle _x;
		[_x] orderGetIn false;
	} forEach _gunners;
};

// commander
_commander = _assignments select 2;
{
	unassignVehicle _x;
	[_x] orderGetIn false;
} forEach _commander;

// turrets
_turret = _assignments select 3;

/*
["VEHICLE DISMOUNT ASSIGNED TURRETS %1",_vehicle] call ALIVE_fnc_dump;
_turret call ALIVE_fnc_inspectArray;
*/

if(count _turret > 0) then {
	// get turrets for this class ignoring gunner and commander turrets
	_turrets = [typeOf _vehicle, true, true, true] call ALIVE_fnc_configGetVehicleTurretPositions;

	/*
	["VEHICLE DISMOUNT TURRET POSITIONS %1",_vehicle] call ALIVE_fnc_dump;
	_turrets call ALIVE_fnc_inspectArray;
	*/
	
	for "_i" from 0 to (count _turret)-1 do {
		_unit = _turret select _i;
		unassignVehicle _unit;	
		[_unit] orderGetIn false;
	};
};

// cargo
_cargo = _assignments select 4;
{
	unassignVehicle _x;
	[_x] orderGetIn false;
} forEach _cargo;

// player turrets
_turret = _assignments select 5;

/*
["VEHICLE DISMOUNT ASSIGNED PLAYER TURRETS %1",_vehicle] call ALIVE_fnc_dump;
_turret call ALIVE_fnc_inspectArray;
*/

if(count _turret > 0) then {
	// get turrets for this class ignoring gunner and commander turrets
	_turrets = [typeOf _vehicle, true, true, false, true, true] call ALIVE_fnc_configGetVehicleTurretPositions;

	/*
	["VEHICLE DISMOUNT PLAYER TURRET POSITIONS %1",_vehicle] call ALIVE_fnc_dump;
	_turrets call ALIVE_fnc_inspectArray;
	*/

	for "_i" from 0 to (count _turret)-1 do {
		_unit = _turret select _i;
		unassignVehicle _unit;
		[_unit] orderGetIn false;
	};
};