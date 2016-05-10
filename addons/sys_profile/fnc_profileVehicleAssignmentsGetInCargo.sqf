#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profileVehicleAssignmentsGetInCargo);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileVehicleAssignmentsGetInCargo

Description:
Takes a vehicle profile vehicle assignment and return an array of entity profile ids that are in cargo positions of the vehicle

Parameters:
Array - Vehicle assignments

Returns:

Examples:
(begin example)
// get entities that are in the vehicle as cargo
_result = [_vehicleAssignments] call ALIVE_fnc_profileVehicleAssignmentsGetInCargo;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_assignments","_profile","_profileType","_result","_entity","_assignment","_drivers","_commander","_inCargoVehicle"];

_assignments = _this select 0;
_profile = _this select 1;

_profileType = _profile select 2 select 5; //[_profile,"type"] call ALIVE_fnc_hashGet;

_result = [];
			
{
	if(_profileType == "vehicle") then {
		_entity = _x select 1;
	}else{
		_entity = _x select 0;
	};
	
	_assignment = _x select 2;
	_drivers = count(_assignment select 0);
	_commander = count(_assignment select 2);
	
	_inCargoVehicle = true;
					
	if(_drivers > 0) then {
		_inCargoVehicle = false;
	};
	
	if(_commander > 0) then {
		_inCargoVehicle = false;
	};
	
	if(_inCargoVehicle) then {
		_result set [count _result, _entity]
	};				
	
} forEach (_assignments select 2);

_result