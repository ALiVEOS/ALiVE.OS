#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(removeProfileVehicleAssignments);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_removeProfileVehicleAssignments

Description:
Removes all assignments for the passed profile

Parameters:
Array - Entity or Vehicle profile

Returns:

Examples:
(begin example)
// remove vehicle assignments from vehicle perspective
_result = _vehicleProfile call ALIVE_fnc_removeProfileVehicleAssignments;

// remove vehicle assignments from entity perspective
_result = _entityProfile call ALIVE_fnc_removeProfileVehicleAssignments;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_profile","_profileType","_vehicleAssignments","_keys","_vehicleID","_profileVehicle","_entityID","_profileEntity"];

_profile = _this select 0;
_profileType = [_profile,"type"] call ALIVE_fnc_hashGet;
_vehicleAssignments = [_profile,"vehicleAssignments"] call ALIVE_fnc_hashGet;
_keys = [];

if(_profileType == "vehicle") then {

	{	
		_entityID = _x select 1;
		_keys set [count _keys,_entityID];		
	} forEach (_vehicleAssignments select 2);
	
	{
		_entityID = _x;
		_profileEntity = [ALIVE_profileHandler, "getProfile", _entityID] call ALIVE_fnc_profileHandler;
        
        if !(isnil "_profileEntity") then {
			[_profileEntity,_profile,true] call ALIVE_fnc_removeProfileVehicleAssignment;
        };
	} forEach _keys;
	
}else{

	{	
		_vehicleID = _x select 1;
		_keys set [count _keys,_entityID];		
	} forEach (_vehicleAssignments select 2);
	
	{
		_vehicleID = _x;
		_profileVehicle = [ALIVE_profileHandler, "getProfile", _vehicleID] call ALIVE_fnc_profileHandler;
        if !(isnil "_profileVehicle") then {
			[_profile,_profileVehicle,true] call ALIVE_fnc_removeProfileVehicleAssignment;
        };
	} forEach _keys;
	
};	