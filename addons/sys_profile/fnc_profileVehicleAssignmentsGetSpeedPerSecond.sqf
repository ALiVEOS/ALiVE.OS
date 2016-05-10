#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profileVehicleAssignmentsGetSpeedPerSecond);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileVehicleAssignmentsGetSpeedPerSecond

Description:
Takes vehicle assignments and calculates the max speed for the controlling group

Parameters:
Array - Vehicle assignments
Hash - Entity profile

Returns:

Examples:
(begin example)
// set all entities within vehicle to position
_result = [_vehicleAssignments, _entityProfile] call ALIVE_fnc_profileVehicleAssignmentsGetSpeedPerSecond;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_assignments","_profile","_result","_vehiclesInCommandOf","_manSpeedArray","_countAssignedUnits","_unitCount","_speeds","_vehicleProfile","_vehicleClass","_speedArray","_getAverageSpeed","_sortedSpeeds"];

_assignments = _this select 0;
_profile = _this select 1;

_vehiclesInCommandOf = _profile select 2 select 8; //[_profile,"vehiclesInCommandOf"] call ALIVE_fnc_hashGet;
_manSpeedArray = "Man" call ALIVE_fnc_vehicleGetSpeedPerSecond;
_countAssignedUnits = _assignments call ALIVE_fnc_profileVehicleAssignmentsGetCount;
_unitCount = [_profile,"unitCount"] call ALIVE_fnc_profileEntity;

/*
["MAN SPEED: %1",_manSpeedArray] call ALIVE_fnc_dump;
["COUNT ASSIGNED: %1",_countAssignedUnits] call ALIVE_fnc_dump;
["UNIT COUNT: %1",_unitCount] call ALIVE_fnc_dump;
*/


// if there are some non mounted units return walking speed
if(_countAssignedUnits < _unitCount || count(_vehiclesInCommandOf) == 0) then {
	_result = _manSpeedArray;
}else{
	// get the lowest speed from all assigned vehicles
	_speeds = [];
	{
		_vehicleProfile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
        
        if !(isnil "_vehicleProfile") then {
			_vehicleClass = _vehicleProfile select 2 select 11; //[_vehicleProfile,"vehicleClass"] call ALIVE_fnc_hashGet;
			_speedArray = _vehicleClass call ALIVE_fnc_vehicleGetSpeedPerSecond;
			_speeds set [count _speeds, _speedArray];
        };
	} forEach _vehiclesInCommandOf;
	
	//["SPEEDS: %1",_speeds] call ALIVE_fnc_dump;	
	
	_getAverageSpeed = {
		private ["_speeds","_speed"];	
		_speeds = _this select 0;
		_speed = _speeds select 0;
		_speed
	};
	
	_sortedSpeeds = [_speeds, {
		([_this] call _getAverageSpeed)
	}] call ALIVE_fnc_shellSort;
	
	//["SORTED SPEEDS: %1",_sortedSpeeds] call ALIVE_fnc_dump;	
	
	_result = _sortedSpeeds select 0;
};

_result