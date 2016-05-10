#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(removeProfileVehicleAssignment);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_removeProfileVehicleAssignment

Description:
Removes a vehicle assignment from both entity and vehicle profiles

Parameters:
Array - Entity profile
Array - Vehicle profile

Returns:

Examples:
(begin example)
// remove vehicle assignment
_result = [_vehicleProfile,_entityProfile] call ALIVE_fnc_removeProfileVehicleAssignment;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_profileEntity","_profileVehicle","_deleteAssignment","_entityID","_vehicleID","_assignments","_units","_entityAssignments","_vehicleAssignments","_assignment",
"_vehicle","_vehicleAssignment","_entityInCommandOf","_entityInCargoOf","_vehicleInCommandOf","_vehicleInCargoOf"];

_profileEntity = _this select 0;
_profileVehicle = _this select 1;
_deleteAssignment = if(count _this > 2) then {_this select 2} else {true};

_entityID = [_profileEntity, "profileID"] call ALIVE_fnc_hashGet;
_vehicleID = [_profileVehicle, "profileID"] call ALIVE_fnc_hashGet;
						
_entityAssignments = [_profileEntity,"vehicleAssignments"] call ALIVE_fnc_hashGet;
_vehicleAssignments = [_profileVehicle,"vehicleAssignments"] call ALIVE_fnc_hashGet;

if(_entityID in (_vehicleAssignments select 1)) then {

	// if spawned make the units get out
	if([_profileEntity,"active"] call ALIVE_fnc_hashGet) then {
		_units = [_profileEntity,"units"] call ALIVE_fnc_hashGet;
		_assignment = [_entityAssignments,_vehicleID] call ALIVE_fnc_hashGet;
		_vehicle = [_profileVehicle,"vehicle"] call ALIVE_fnc_hashGet;
		_vehicleAssignment = [_assignment,_units] call ALIVE_fnc_profileVehicleAssignmentIndexesToUnits;
		[_vehicleAssignment, _vehicle] call ALIVE_fnc_vehicleDismount;
	};		

	// remove the assignments from the entity and vehicle profile
	if(_deleteAssignment) then {
		[_entityAssignments, _vehicleID] call ALIVE_fnc_hashRem;
		[_vehicleAssignments, _entityID] call ALIVE_fnc_hashRem;
	};

	// remove keys from in cargo arrays
	_entityInCommandOf = [_profileEntity,"vehiclesInCommandOf"] call ALIVE_fnc_hashGet;
	_entityInCargoOf = [_profileEntity,"vehiclesInCargoOf"] call ALIVE_fnc_hashGet;

	_entityInCommandOf = _entityInCommandOf - [_vehicleID];
	_entityInCargoOf = _entityInCargoOf - [_vehicleID];

	[_profileEntity,"vehiclesInCommandOf",_entityInCommandOf] call ALIVE_fnc_hashSet;
	[_profileEntity,"vehiclesInCargoOf",_entityInCargoOf] call ALIVE_fnc_hashSet;

	// remove keys from in command arrays
	_vehicleInCommandOf = [_profileVehicle,"entitiesInCommandOf"] call ALIVE_fnc_hashGet;
	_vehicleInCargoOf = [_profileVehicle,"entitiesInCargoOf"] call ALIVE_fnc_hashGet;

	_vehicleInCommandOf = _vehicleInCommandOf - [_entityID];
	_vehicleInCargoOf = _vehicleInCargoOf - [_entityID];

	[_profileVehicle,"entitiesInCommandOf",_vehicleInCommandOf] call ALIVE_fnc_hashSet;
	[_profileVehicle,"entitiesInCargoOf",_vehicleInCargoOf] call ALIVE_fnc_hashSet;
};