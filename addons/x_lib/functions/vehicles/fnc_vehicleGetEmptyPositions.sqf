#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(vehicleGetEmptyPositions);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_vehicleGetEmptyPositions

Description:
Get an array of empty positions for the vehicle

Parameters:
Vehicle - The vehicle

Returns:
Array of empty positions

Examples:
(begin example)
// get empty positions array
_result = [_vehicle] call ALIVE_fnc_vehicleGetEmptyPositions;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_vehicle","_count","_positions","_turrets","_turretEmptyCount","_playerTurretEmptyCount","_turretUnit"];
	
_vehicle = _this select 0;

_positions = [0,0,0,0,0,0];

// get turrets for this class ignoring gunner and commander turrets
_turrets = [typeOf _vehicle, true, true, true] call ALIVE_fnc_configGetVehicleTurretPositions;
_turretEmptyCount = 0;

{
	_turretUnit = _vehicle turretUnit _x;
	if(isNull _turretUnit) then {
		_turretEmptyCount = _turretEmptyCount + 1;
	};
} forEach _turrets;

_turrets = [typeOf _vehicle, true, true, false, true, true] call ALIVE_fnc_configGetVehicleTurretPositions;
_playerTurretEmptyCount = 0;

{
	_turretUnit = _vehicle turretUnit _x;
	if(isNull _turretUnit) then {
		_playerTurretEmptyCount = _playerTurretEmptyCount + 1;
	};
} forEach _turrets;


if (locked _vehicle != 2 && alive _vehicle) then
{	
	_positions set [0, _vehicle emptyPositions "Driver"];
	_positions set [1, _vehicle emptyPositions "Gunner"];
	_positions set [2, _vehicle emptyPositions "Commander"];
	_positions set [3, _turretEmptyCount];	
	_positions set [4, _vehicle emptyPositions "Cargo"];
	_positions set [5, _playerTurretEmptyCount];
};

/*
["VEHICLE GET EMPTY POSITIONS: %1 %2 %3",_vehicle,_positions] call ALIVE_fnc_dump;
_assignments call ALIVE_fnc_inspectArray;
*/

_positions