#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(vehicleAssignmentsGetLinkedProfiles);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_vehicleAssignmentsGetLinkedProfiles

Description:
Read real vehicle assignments of an entity or vehicle and return a list of profiles that are linked via assignments

Parameters:
Vehicle - The vehicle

Returns:
Array - Hash of profiles linked via vehicle assignments

Examples:
(begin example)
// get all spawned profiles linked via assignments
_profiles = [_vehicle] call ALIVE_fnc_vehicleAssignmentsGetLinkedProfiles;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_profile","_profileType","_profileID","_profileActive","_linkedProfiles","_vehicle","_groupsInVehicle","_group","_units","_vehiclesUnitsIn","_leader",
"_entityID","_entityProfile","_entityProfileActive","_assignment","_vehicleAssignments","_vehicleID","_vehicleProfile","_vehicleProfileActive"];

_profile = _this select 0;
_linkedProfiles = if(count _this > 1) then {_this select 1} else {[] call ALIVE_fnc_hashCreate};

_profileType = _profile select 2 select 5; //[_profile,"type"] call ALIVE_fnc_hashGet;
_profileID = _profile select 2 select 4; //[_profile,"profileID"] call ALIVE_fnc_hashGet;
_profileActive = _profile select 2 select 1; //[_profile,"active"] call ALIVE_fnc_hashGet;

if!(_profileID in (_linkedProfiles select 1)) then {

	[_linkedProfiles, _profileID, _profile] call ALIVE_fnc_hashSet;

	if(_profileType == "vehicle") then {

		_vehicle = _profile select 2 select 10; //[_profile,"vehicle"] call ALIVE_fnc_hashGet;	
		_groupsInVehicle = _vehicle call ALIVE_fnc_vehicleGetGroupsWithin;
		
		/*
		["VA TO PVA : %1",_profileID] call ALIVE_fnc_dump;	
		["GROUPS IN VEHICLE: %1",_groupsInVehicle] call ALIVE_fnc_dump;
		*/
		
		{
			_group = _x;
			_leader = leader _group;
			_entityID = _leader getVariable "profileID";
            
            if !(isnil "_entityID") then {
			
				//["E: %1 EID: %2",_leader,_entityID] call ALIVE_fnc_dump;
				
				_entityProfile = [ALIVE_profileHandler, "getProfile", _entityID] call ALIVE_fnc_profileHandler;
                
                if !(isnil "_entityProfile") then {
					_entityProfileActive = _entityProfile select 2 select 1; //[_entityProfile,"active"] call ALIVE_fnc_hashGet;			
							
					if(_entityProfileActive) then {
						_linkedProfiles = [_entityProfile, _linkedProfiles] call ALIVE_fnc_vehicleAssignmentsGetLinkedProfiles;				
					};
                };
            };
		} forEach _groupsInVehicle;
		
	} else {
		
		_units = _profile select 2 select 21; //[_profile,"units"] call ALIVE_fnc_hashGet;
		_group = group (_units select 0);
		_vehiclesUnitsIn = _units call ALIVE_fnc_unitArrayGetVehiclesWithin;
		
		/*
		["VA TO PVA : %1",_profileID] call ALIVE_fnc_dump;
		["UNITS : %1",_units] call ALIVE_fnc_dump;
		["GROUP : %1",_group] call ALIVE_fnc_dump;
		["VEHICLES UNITS IN: %1",_vehiclesUnitsIn] call ALIVE_fnc_dump;
		*/
		
		{
			_vehicle = _x;
            
            if !(isnil "_vehicle") then {
				_vehicleID = _vehicle getVariable ["profileID","none"];
						
				//["V: %1 VID: %2",_vehicle,_vehicleID] call ALIVE_fnc_dump;
				
				_vehicleProfile = [ALIVE_profileHandler, "getProfile", _vehicleID] call ALIVE_fnc_profileHandler;
                
                if !(isnil "_vehicleProfile") then {
					_vehicleProfileActive = _vehicleProfile select 2 select 1; //[_vehicleProfile,"active"] call ALIVE_fnc_hashGet;
					
					if(_vehicleProfileActive) then {
						_linkedProfiles = [_vehicleProfile, _linkedProfiles] call ALIVE_fnc_vehicleAssignmentsGetLinkedProfiles;	
					};
                };
            };			
		} forEach _vehiclesUnitsIn;
			
	};
	
};

_linkedProfiles