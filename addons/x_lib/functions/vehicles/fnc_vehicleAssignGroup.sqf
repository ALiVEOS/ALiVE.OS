#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(vehicleAssignGroup);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_vehicleAssignGroup

Description:
Assign a vehicle to a group, returns an assignment array

Parameters:
Group - The group
Vehicle - The vehicle
Boolean - order in vehicle

Returns:
assignments array

Examples:
(begin example)
// assign group to vehicle
_result = [_group, _vehicle] call ALIVE_fnc_vehicleAssignGroup;

// assign group to vehicle and order get in
_result = [_group, _vehicle, true] call ALIVE_fnc_vehicleAssignGroup;
(end)

See Also:
ALIVE_vehicleGetEmptyPositions

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_group","_vehicle","_orderIn","_positionCount","_units","_assignments","_leader","_gunners","_vehicleTurrets","_turrets","_cargos","_unit","_turretPath","_playerTurrets"];
	
_group = _this select 0;
_vehicle = _this select 1;
_orderIn = if(count _this > 2) then {_this select 2} else {true};

_positionCount = [_vehicle] call ALIVE_fnc_vehicleGetEmptyPositions;
_units = units _group;
_assignments = [[],[],[],[],[],[]];
_gunners = [];
_turrets = [];
_cargos = [];
_playerTurrets = [];

if(count _units > 1) then
{
	
	_leader = leader _group;
	_units = _units - [_leader];
	
	// assign the leader as commander or cargo or gunner
	if(_positionCount select 2 > 0) then 
	{
		_leader assignAsCommander _vehicle;
		if(_orderIn) then { [_leader] orderGetIn true; };
		_assignments set [2, [_leader]];
	} else
	{
		// if there are more than 2 people in the group
		if(count _units > 1) then
		{
			_leader assignAsCargo _vehicle;
			if(_orderIn) then { [_leader] orderGetIn true; };
			_cargos set [0, _leader];
		}
		else
		{
			// if there are gunner positions available
			if(_positionCount select 1 > 0) then
			{
				_leader assignAsGunner _vehicle;
				if(_orderIn) then { [_leader] orderGetIn true; };
				_gunners set [0, _leader];
			}
			else
			{
				_leader assignAsCargo _vehicle;
				if(_orderIn) then { [_leader] orderGetIn true; };
				_cargos set [0, _leader];
			};				
		};			
	};
	
	// assign a unit as the driver		
	if(_positionCount select 0 > 0) then
	{
		_unit = _units call BIS_fnc_arrayPop;
		_unit assignAsDriver _vehicle;
		if(_orderIn) then { [_unit] orderGetIn true; };
		_assignments set [0, [_unit]];
	};
	
	// assign gunners	
	for "_i" from 1 to (_positionCount select 1) do 
	{
		if(count _units > 0) then
		{				
			_unit = _units call BIS_fnc_arrayPop;
			_unit assignAsGunner _vehicle;
			if(_orderIn) then { [_unit] orderGetIn true; };
			_gunners pushback _unit;
		};			
	};
	_assignments set [1, _gunners];
	
	// assign turrets
	if((_positionCount select 3) > 0) then {
	
		_vehicleTurrets = [typeOf _vehicle, true, true, true] call ALIVE_fnc_configGetVehicleTurretPositions;

		for "_i" from 0 to (_positionCount select 3) do
		{
			if(count _units > 0) then
			{
				_turretPath = _vehicleTurrets select _i;

				if!(isNil "_turretPath") then {
				    _unit = _units call BIS_fnc_arrayPop;
                    _unit assignAsTurret [_vehicle, _turretPath];
                    if(_orderIn) then { [_unit] orderGetIn true; };
                    _turrets pushback _unit;
				};
			};			
		};
		_assignments set [3, _turrets];
	};
	
	// assign cargo
	{
		_x assignAsCargo _vehicle;			
		if(_orderIn) then { [_x] orderGetIn true; };	
		_cargos pushback _x;
	} forEach _units;		
	_assignments set [4, _cargos];

	// assign player turrets
	if((_positionCount select 5) > 0) then {

		_vehicleTurrets = [typeOf _vehicle, true, true, false, true, true] call ALIVE_fnc_configGetVehicleTurretPositions;

		for "_i" from 0 to (_positionCount select 3) do
		{
			if(count _units > 0) then
			{
				_turretPath = _vehicleTurrets select _i;

				if!(isNil "_turretPath") then {
					_unit = _units call BIS_fnc_arrayPop;
					_unit assignAsTurret [_vehicle, _turretPath];
					if(_orderIn) then { [_unit] orderGetIn true; };
					_turrets pushback _unit;
				};
			};
		};
		_assignments set [5, _turrets];
	};
}
else
{
	_unit = _units select 0;	
	_unit assignAsDriver _vehicle;	
	if(_orderIn) then { [_unit] orderGetIn true; };	
	_assignments set [0, [_unit]];
};

/*
["VEHICLE ASSIGN GROUP: %1 %2 %3",_group,_vehicle,_assignments] call ALIVE_fnc_dump;
_assignments call ALIVE_fnc_inspectArray;
*/

_assignments