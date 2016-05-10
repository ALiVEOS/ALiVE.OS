#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profileVehicleAssignmentToVehicleAssignment);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileVehicleAssignmentToVehicleAssignment

Description:
Takes a profile vehicle assignment and creates real vehicle assignment

Parameters:
Array - Profile vehicle assignment
Array - Profile

Returns:

Examples:
(begin example)
// create real vehicle assignment (move in instantly)
_result = [_vehicleAssignment, _profile] call ALIVE_fnc_profileVehicleAssignmentToVehicleAssignment;

// create real vehicle assignment (order get in)
_result = [_vehicleAssignment, _profile, true] call ALIVE_fnc_profileVehicleAssignmentToVehicleAssignment;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_vehicleAssignment","_profile","_orderGetIn","_profileType","_vehicle","_entityProfileID","_entityProfile",
"_entityProfileActive","_units","_vehicleProfileID","_vehicleProfile","_indexes","_vehicleProfileActive"];

_vehicleAssignment = _this select 0;
_profile = _this select 1;
_orderGetIn = if(count _this > 2) then {_this select 2} else {false};

_profileType = _profile select 2 select 5; //[_profile,"type"] call ALIVE_fnc_hashGet;

if(_profileType == "vehicle") then {

	_vehicle = _profile select 2 select 10; //[_profile,"vehicle"] call ALIVE_fnc_hashGet;	
	_entityProfileID = _vehicleAssignment select 1;
	_entityProfile = [ALIVE_profileHandler, "getProfile", _entityProfileID] call ALIVE_fnc_profileHandler;
    
    if !(isnil "_entityProfile") then {
		_entityProfileActive = _entityProfile select 2 select 1; //[_entityProfile,"active"] call ALIVE_fnc_hashGet;
		
		if!(_entityProfileActive) then {
			[_entityProfile,"spawn"] call ALIVE_fnc_profileEntity;
		} else {
			_units = _entityProfile select 2 select 21; //[_entityProfile,"units"] call ALIVE_fnc_hashGet;		
			_indexes = _vehicleAssignment;		
			_vehicleAssignment = [_indexes,_units] call ALIVE_fnc_profileVehicleAssignmentIndexesToUnits;		
			if(_orderGetIn) then {
				[_vehicleAssignment, _vehicle] call ALIVE_fnc_vehicleMount;
			}else{
				[_vehicleAssignment, _vehicle] call ALIVE_fnc_vehicleMoveIn;
			};
		};
    };
	
} else {
	_units = _profile select 2 select 21; //[_profile,"units"] call ALIVE_fnc_hashGet;
	_vehicleProfileID = _vehicleAssignment select 0;
	_vehicleProfile = [ALIVE_profileHandler, "getProfile", _vehicleProfileID] call ALIVE_fnc_profileHandler;
	
    if !(isnil "_vehicleProfile") then {
	    _vehicleProfileActive =  _vehicleProfile select 2 select 1; //[_vehicleProfile,"active"] call ALIVE_fnc_hashGet;
		
		if!(_vehicleProfileActive) then {
			[_vehicleProfile,"spawn"] call ALIVE_fnc_profileVehicle;
		} else {
			_vehicle = _vehicleProfile select 2 select 10; //[_vehicleProfile,"vehicle"] call ALIVE_fnc_hashGet;
			_indexes = _vehicleAssignment;		
			_vehicleAssignment = [_indexes,_units] call ALIVE_fnc_profileVehicleAssignmentIndexesToUnits;
			if(_orderGetIn) then {
				[_vehicleAssignment, _vehicle] call ALIVE_fnc_vehicleMount;
			}else{
				[_vehicleAssignment, _vehicle] call ALIVE_fnc_vehicleMoveIn;
			};		
		};
    };
};