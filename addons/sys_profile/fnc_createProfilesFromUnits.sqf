#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(createProfilesFromUnits);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_createProfilesFromUnits

Description:
Create profiles for all units on the map that don't have profiles

Parameters:

Returns:

Examples:
(begin example)
// get profiles from all map placed units
[] call ALIVE_fnc_createProfilesFromUnits;
(end)

See Also:

Author:
Highhead
---------------------------------------------------------------------------- */

private ["_entityCount","_vehicleCount","_createModeGroups","_createModeVehicles",
"_group","_leader","_units","_ignore","_inVehicle","_unitClasses","_positions","_ranks","_damages","_unitBlacklisted","_initCommand",
"_vehicle","_entityID","_profileEntity","_profileWaypoint","_vehicleID","_profileVehicle","_profileVehicleAssignments",
"_assignments","_vehicleAssignments","_vehicleClass","_vehicleKind","_position","_waypoints","_playerVehicle","_unitBlackist","_vehicleBlacklist","_object"];

if (isnil "_this") then {_this = []};

params [
    ["_createMode", "NONE", [""]],
    ["_createModeObjects", [], [[]]],
    ["_debug", false, [true]],
    ["_groups", allGroups, [[]]],
    ["_vehicles", vehicles, [[]]]
];

_entityCount = 0;
_vehicleCount = 0;

_createModeGroups = [];
_createModeVehicles = [];

_unitBlackist = ["O_UAV_AI","B_UAV_AI"];
_vehicleBlacklist = ["O_UAV_02_F","O_UAV_02_CAS_F","O_UAV_01_F","O_UGV_01_F","O_UGV_01_rcws_F","B_UAV_01_F","B_UAV_02_F","B_UAV_02_CAS_F","B_UGV_01_F","B_UGV_01_rcws_F"];

//["Create Mode: %1",_createMode] call ALIVE_fnc_dump;
//["Create Objects: %1",_createModeObjects] call ALIVE_fnc_dump;

// use the passed create mode objects array of to
// compile lists of vehicles and groups to use 
{
	_object = _x;
	if!(isNull group _object) then {
		if!(side _object == sideLogic) then {			
			_group  = group _object;

			if!(_group in _createModeGroups) then {
			    _createModeGroups pushback _group;
            };

			if(_createMode == "IGNORE") then {
			    _group setVariable ["ALIVE_profileIgnore", true];
			};
			
			{
				_vehicle = vehicle _x;
				if(!(_vehicle == _x)) then {
					if!(_vehicle in _createModeVehicles) then {

                        if(_createMode == "IGNORE") then {
                            _vehicle setVariable ["ALIVE_profileIgnore", true];
                        };

						_createModeVehicles pushback _vehicle;
					};
				};
			} forEach units _group;
		}
	}else{
		if!(side _object == sideLogic) then {
			_createModeVehicles pushback _object;

			if(_createMode == "IGNORE") then {
                _object setVariable ["ALIVE_profileIgnore", true];
            };
		};
	};
} forEach _createModeObjects;

if(_createMode == "ADD") then {
	_groups = _createModeGroups;
	_vehicles = _createModeVehicles;
};

if(_createMode == "IGNORE") then {
	_groups = _groups - _createModeGroups;
	_vehicles = _vehicles - _createModeVehicles;
};

//["Create Mode Groups: %1",_groups] call ALIVE_fnc_dump;
//["Create Mode Vehicles: %1",_vehicles] call ALIVE_fnc_dump;

// DEBUG -------------------------------------------------------------------------------------
if(_debug) then {
	["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
	["ALIVE Create profiles from map groups"] call ALIVE_fnc_dump;
	[true] call ALIVE_fnc_timer;
};
// DEBUG -------------------------------------------------------------------------------------

{
	_group = _x;
	_leader = leader _group;
	_units = units _group;

	if((_leader getVariable ["profileID",""] == "") && !(isPlayer _leader) && !(isNull _leader) && !(str(side _leader) == "LOGIC")) then {
	
		_unitClasses = [];
		_positions = [];
		_ranks = [];
		_damages = [];
			
		_unitBlacklisted = false;
		{
			if((typeOf _x) in _unitBlackist) then {
				_unitBlacklisted = true;
			};
			_unitClasses pushback (typeOf _x);
			_positions pushback (getPosATL _x);
			_ranks pushback (rank _x);
			_damages pushback (getDammage _x);
		} foreach (_units);

		if (!(vehicle _leader == _leader)) then {
            _vehicle = (vehicle _leader);

            if(_vehicle getVariable ["ALIVE_CombatSupport",false]) then {
                _unitBlacklisted = true;
            };
        };
		
		if(!_unitBlacklisted) then {
		
			_entityID = [ALIVE_profileHandler, "getNextInsertEntityID"] call ALIVE_fnc_profileHandler;
			
			_position = getPosATL _leader;

			_profileEntity = [nil, "create"] call ALIVE_fnc_profileEntity;
			[_profileEntity, "init"] call ALIVE_fnc_profileEntity;
			[_profileEntity, "profileID", _entityID] call ALIVE_fnc_profileEntity;
			[_profileEntity, "unitClasses", _unitClasses] call ALIVE_fnc_profileEntity;
			[_profileEntity, "position", _position] call ALIVE_fnc_profileEntity;
			[_profileEntity, "despawnPosition", _position] call ALIVE_fnc_profileEntity;
			[_profileEntity, "positions", _positions] call ALIVE_fnc_profileEntity;
			[_profileEntity, "damages", _damages] call ALIVE_fnc_profileEntity;
			[_profileEntity, "ranks", _ranks] call ALIVE_fnc_profileEntity;
			[_profileEntity, "side", str(side _leader)] call ALIVE_fnc_profileEntity;
			[_profileEntity, "faction", faction _leader] call ALIVE_fnc_profileEntity;
			[_profileEntity, "isPlayer", false] call ALIVE_fnc_profileEntity;

			_initCommand = _leader getVariable ["addCommand",[]];
            if(count _initCommand > 0) then {
                [_profileEntity, "addActiveCommand", _initCommand] call ALIVE_fnc_profileEntity;
            };

			[ALIVE_profileHandler, "registerProfile", _profileEntity] call ALIVE_fnc_profileHandler;
			
			_waypoints = waypoints _group;
			
			if(currentWaypoint _group < count _waypoints) then {
				for "_i" from (currentWaypoint _group) to (count _waypoints)-1 do
				{
					_profileWaypoint = [(_waypoints select _i)] call ALIVE_fnc_waypointToProfileWaypoint;
					[_profileEntity, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
				};
			};
			
			{
				if (!(vehicle _x == _x)) then {
			
					_vehicle = (vehicle _x);
					
					if((_vehicle getVariable ["profileID",""]) == "") then {
										
						_vehicleID = [ALIVE_profileHandler, "getNextInsertVehicleID"] call ALIVE_fnc_profileHandler;
						_vehicleClass = typeOf _vehicle;
						_vehicleKind = _vehicleClass call ALIVE_fnc_vehicleGetKindOf;
						
						//["V: %1 K: %2 S: %3 F: %4",_vehicleClass,_vehicleKind,side _vehicle,faction _vehicle] call ALIVE_fnc_dump;
						
						_position = getPosATL _vehicle;
						
						_vehicle setVariable ["profileID",format["vehicle_%1",_vehicleCount]];

						_profileVehicle = [nil, "create"] call ALIVE_fnc_profileVehicle;
						[_profileVehicle, "init"] call ALIVE_fnc_profileVehicle;
						[_profileVehicle, "profileID", _vehicleID] call ALIVE_fnc_profileVehicle;
						[_profileVehicle, "vehicleClass", _vehicleClass] call ALIVE_fnc_profileVehicle;
						[_profileVehicle, "position", _position] call ALIVE_fnc_profileVehicle;
						[_profileVehicle, "despawnPosition", _position] call ALIVE_fnc_profileVehicle;
						[_profileVehicle, "direction", getDir _vehicle] call ALIVE_fnc_profileVehicle;
						[_profileVehicle, "damage", _vehicle call ALIVE_fnc_vehicleGetDamage] call ALIVE_fnc_profileVehicle;
						[_profileVehicle, "fuel", fuel _vehicle] call ALIVE_fnc_profileVehicle;
						[_profileVehicle, "ammo", _vehicle call ALIVE_fnc_vehicleGetAmmo] call ALIVE_fnc_profileVehicle;
						[_profileVehicle, "engineOn", isEngineOn _vehicle] call ALIVE_fnc_profileVehicle;
						[_profileVehicle, "canFire", canFire _vehicle] call ALIVE_fnc_profileVehicle;
						[_profileVehicle, "canMove", canMove _vehicle] call ALIVE_fnc_profileVehicle;
						[_profileVehicle, "needReload", needReload _vehicle] call ALIVE_fnc_profileVehicle;
						[_profileVehicle, "side", str(side _vehicle)] call ALIVE_fnc_profileVehicle;
						[_profileVehicle, "faction", faction _vehicle] call ALIVE_fnc_profileVehicle;
						
						if(_vehicleKind == "Plane" || _vehicleKind == "Helicopter") then {
							[_profileVehicle, "spawnType", ["preventDespawn"]] call ALIVE_fnc_profileVehicle;
						};
						
						[ALIVE_profileHandler, "registerProfile", _profileVehicle] call ALIVE_fnc_profileHandler;
						
						_vehicleCount = _vehicleCount + 1;					
					}else{
						_vehicleID = _vehicle getVariable "profileID";
						_profileVehicle = [ALIVE_profileHandler, "getProfile", _vehicleID] call ALIVE_fnc_profileHandler;
					};
					
					_profileVehicleAssignments = [_profileVehicle, "vehicleAssignments"] call ALIVE_fnc_hashGet;
					
					if!(_entityID in (_profileVehicleAssignments select 1)) then {
						_assignments = [_vehicle,_group] call ALIVE_fnc_vehicleAssignmentToProfileVehicleAssignment;
						
						_vehicleAssignments = [_vehicleID,_entityID,_assignments];

						[_profileEntity, "addVehicleAssignment", _vehicleAssignments] call ALIVE_fnc_profileEntity;
						[_profileVehicle, "addVehicleAssignment", _vehicleAssignments] call ALIVE_fnc_profileVehicle;
					};
				};		
			} foreach (_units);
			
			_entityCount = _entityCount + 1;
			
		};
	
	};
	
} forEach _groups;

// DEBUG -------------------------------------------------------------------------------------
if(_debug) then {
	["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
	["ALIVE Create profiles from map groups Complete - entity profiles created: [%1] vehicle profiles created: [%2]",_entityCount,_vehicleCount] call ALIVE_fnc_dump;
	[] call ALIVE_fnc_timer;
	[true] call ALIVE_fnc_timer;
	["ALIVE Deleting existing groups"] call ALIVE_fnc_dump;
};
// DEBUG -------------------------------------------------------------------------------------

private ["_deleteEntityCount","_deleteVehicleCount"];

_deleteEntityCount = 0;
_deleteVehicleCount = 0;

{
	_group = _x;
	_leader = leader _group;
	_units = units _group;
	_unitClasses = [];
	
	_unitBlacklisted = false;
	{
		if((typeOf _x) in _unitBlackist) then {
			_unitBlacklisted = true;
		};

		if (!(vehicle _x == _x)) then {
            _vehicle = (vehicle _x);

            if(_vehicle getVariable ["ALIVE_CombatSupport",false]) then {
                _unitBlacklisted = true;
            };
        };

	} foreach (_units);
	
	if(!_unitBlacklisted) then {
		
		if!(isPlayer _leader) then {
			
			{
				_inVehicle = !(vehicle _x == _x);
				
				if(_inVehicle) then {
					_vehicle = (vehicle _x);			
					deleteVehicle _vehicle;
					_deleteVehicleCount = _deleteVehicleCount + 1;
				};
				deleteVehicle _x;
			} forEach (_units);

			_group call ALiVE_fnc_DeleteGroupRemote;
			
			_deleteEntityCount = _deleteEntityCount + 1;
		};
	};
} forEach _groups;


// DEBUG -------------------------------------------------------------------------------------
if(_debug) then {
	["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
	["ALIVE Deleting existing groups Complete - groups deleted: [%1] vehicles deleted: [%2]",_deleteEntityCount,_deleteVehicleCount] call ALIVE_fnc_dump;
	[] call ALIVE_fnc_timer;
	[true] call ALIVE_fnc_timer;
	["ALIVE Create profiles from map empty vehicles"] call ALIVE_fnc_dump;
};
// DEBUG -------------------------------------------------------------------------------------

{
	_vehicle = _x;
	_vehicleClass = typeOf _vehicle;
	_vehicleKind = _vehicleClass call ALIVE_fnc_vehicleGetKindOf;
	_playerVehicle = false;
	
	if(!(_vehicleClass in _vehicleBlacklist) && !(_vehicle getVariable ["ALIVE_CombatSupport",false]))then {

		if((_vehicle getVariable ["profileID",""]) == "" && _vehicleKind !="Vehicle") then {
		
			{
				if(isPlayer _x) then {
					_playerVehicle = true;
				};
			} forEach crew _vehicle;
			
			_position = getPosATL _vehicle;

			_vehicleID = [ALIVE_profileHandler, "getNextInsertVehicleID"] call ALIVE_fnc_profileHandler;
						
			_profileVehicle = [nil, "create"] call ALIVE_fnc_profileVehicle;
			[_profileVehicle, "init"] call ALIVE_fnc_profileVehicle;
			[_profileVehicle, "profileID", _vehicleID] call ALIVE_fnc_profileVehicle;
			[_profileVehicle, "vehicleClass", _vehicleClass] call ALIVE_fnc_profileVehicle;
			[_profileVehicle, "position", _position] call ALIVE_fnc_profileVehicle;
			[_profileVehicle, "despawnPosition", _position] call ALIVE_fnc_profileVehicle;
			[_profileVehicle, "direction", getDir _vehicle] call ALIVE_fnc_profileVehicle;
			[_profileVehicle, "damage", _vehicle call ALIVE_fnc_vehicleGetDamage] call ALIVE_fnc_profileVehicle;
			[_profileVehicle, "fuel", fuel _vehicle] call ALIVE_fnc_profileVehicle;
			[_profileVehicle, "ammo", _vehicle call ALIVE_fnc_vehicleGetAmmo] call ALIVE_fnc_profileVehicle;
			[_profileVehicle, "engineOn", isEngineOn _vehicle] call ALIVE_fnc_profileVehicle;
			[_profileVehicle, "canFire", canFire _vehicle] call ALIVE_fnc_profileVehicle;
			[_profileVehicle, "canMove", canMove _vehicle] call ALIVE_fnc_profileVehicle;
			[_profileVehicle, "needReload", needReload _vehicle] call ALIVE_fnc_profileVehicle;
			[_profileVehicle, "side", str(side _vehicle)] call ALIVE_fnc_profileVehicle;
			[_profileVehicle, "faction", faction _vehicle] call ALIVE_fnc_profileVehicle;
			
			if(_vehicleKind == "Plane" || _vehicleKind == "Helicopter") then {
				[_profileVehicle, "spawnType", ["preventDespawn"]] call ALIVE_fnc_profileVehicle;
			};
			
			if(_playerVehicle) then {
				[_profileVehicle, "active", true] call ALIVE_fnc_profileVehicle;
			} else {
				deleteVehicle _vehicle;
			};	
			
			[ALIVE_profileHandler, "registerProfile", _profileVehicle] call ALIVE_fnc_profileHandler;
			
			_vehicleCount = _vehicleCount + 1;	
		};
	};
	
} forEach _vehicles;

// DEBUG -------------------------------------------------------------------------------------
if(_debug) then {
	["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
	["ALIVE Create profiles from map empty vehicles Complete"] call ALIVE_fnc_dump;
	[] call ALIVE_fnc_timer;
};
// DEBUG -------------------------------------------------------------------------------------

if !(isnil "_profileEntity") then {
    _profileEntity;
} else {
    if !(isnil "_profileVehicle") then {
        _profileVehicle;
    };
};