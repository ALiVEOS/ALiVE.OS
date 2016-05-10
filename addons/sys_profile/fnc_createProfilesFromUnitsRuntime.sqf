#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(createProfilesFromUnitsRuntime);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_createProfilesFromUnitsRuntime

Description:
Create profiles for all units on the map that don't have profiles

Parameters:

Returns:

Examples:
(begin example)
// get profiles from all map placed units
[] call ALIVE_fnc_createProfilesFromUnitsRuntime;
(end)

See Also:

Author:
Highhead
---------------------------------------------------------------------------- */

private ["_entityCount","_vehicleCount",
"_group","_leader","_units","_ignore","_inVehicle","_unitClasses","_positions","_ranks","_damages",
"_vehicle","_entityID","_profileEntity","_profileWaypoint","_vehicleID","_profileVehicle","_profileVehicleAssignments",
"_assignments","_vehicleAssignments","_vehicleClass","_vehicleKind","_position","_waypoints","_playerVehicle","_unitBlackist",
"_vehicleBlacklist","_unitBlacklisted","_initCommand","_deleteEntityCount","_deleteVehicleCount"];

if (isnil "_this") then {_this = []};

params [
    ["_debug", false, [true]],
    ["_groups", allGroups, [[]]],
    ["_vehicles", vehicles, [[]]]
];

_entityCount = 0;
_vehicleCount = 0;

_unitBlackist = ["O_UAV_AI","B_UAV_AI"];
_vehicleBlacklist = ["O_UAV_02_F","O_UAV_02_CAS_F","O_UAV_01_F","O_UGV_01_F","O_UGV_01_rcws_F","B_UAV_01_F","B_UAV_02_F","B_UAV_02_CAS_F","B_UGV_01_F","B_UGV_01_rcws_F"];

// DEBUG -------------------------------------------------------------------------------------
if(_debug) then {
	["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
	["ALIVE Create profiles from map groups runtime"] call ALIVE_fnc_dump;
	[true] call ALIVE_fnc_timer;
};
// DEBUG -------------------------------------------------------------------------------------

{
	_group = _x;
	_leader = leader _group;
	_units = units _group;

	//["CPR profileID: %1 isPlayer: %2 isIgnored: %3", _leader getVariable ["profileID",""], !(isPlayer _leader), _group getVariable ["ALIVE_profileIgnore", false]] call ALIVE_fnc_dump;

	if(
	    (_leader getVariable ["profileID",""] == "")
	    && (_leader getVariable ["agentID",""] == "")
	    && !(isPlayer _leader)
	    && !(isNull _leader)
	    && !(str(side _leader) == "LOGIC")
	    && !(_group getVariable ["ALIVE_Convoy",false])
	    && !(_group getVariable ["ALIVE_profileIgnore", false])
	    ) then {
	
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

			_leader setVariable ["runtimeProfiled",true];

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

            //["CPR profiling group..."] call ALIVE_fnc_dump;
            //_profileEntity call ALIVE_fnc_inspectHash;

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
						_vehicle setVariable ["runtimeProfiled",true];

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

						//["CPR profiling group vehicle..."] call ALIVE_fnc_dump;
                        //_profileVehicle call ALIVE_fnc_inspectHash;
						
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
	
	} else {
        _profileEntity = [ALIVE_profileHandler, "getProfile",_leader getVariable "profileID"] call ALIVE_fnc_profileHandler;
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


_deleteEntityCount = 0;
_deleteVehicleCount = 0;

{
	_group = _x;
	_leader = leader _group;
	_units = units _group;
	_unitClasses = [];

	_unitBlacklisted = false;

	if!(_leader getVariable ["runtimeProfiled",false]) then {
        _unitBlacklisted = true;
    };

	{
		if((typeOf _x) in _unitBlackist) then {
			_unitBlacklisted = true;
		};

		if (!(vehicle _x == _x)) then {
            _vehicle = (vehicle _x);

            if(_vehicle getVariable ["ALIVE_CombatSupport",false]) then {
                _unitBlacklisted = true;
            };

            if(_vehicle getVariable ["ALIVE_profileIgnore",false]) then {
                _unitBlacklisted = true;
            };

            if!(_vehicle getVariable ["runtimeProfiled",false]) then {
                _unitBlacklisted = true;
            };

            //["CPR vehicle: %1 isIgnored: %2 runtimeProfiled: %3", _group, _vehicle getVariable ["ALIVE_profileIgnore",false], _vehicle getVariable ["runtimeProfiled",false]] call ALIVE_fnc_dump;

        };

	} foreach (_units);

	//["CPR group: %1 isRuntimeProfiled: %2", _group, _leader getVariable ["runtimeProfiled",false]] call ALIVE_fnc_dump;

	//["CPR checking deletion status: %1 isBlacklisted: %2",_group, _unitBlacklisted] call ALIVE_fnc_dump;

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
	["ALIVE Deleting existing groups Complete - units deleted: [%1] vehicles deleted: [%2]",_deleteEntityCount,_deleteVehicleCount] call ALIVE_fnc_dump;
	[] call ALIVE_fnc_timer;
	[true] call ALIVE_fnc_timer;
	["ALIVE Create profiles from map empty vehicles"] call ALIVE_fnc_dump;
};
// DEBUG -------------------------------------------------------------------------------------

_vehicleCount = 0;

{
	_vehicle = _x;
	_vehicleClass = typeOf _vehicle;
	_vehicleKind = _vehicleClass call ALIVE_fnc_vehicleGetKindOf;
	_playerVehicle = false;

	//["CPR empty vehicle class: %1 kind: %2 isIgnored: %4 isBlacklisted: %3 ", _vehicleClass, _vehicleKind, _vehicleClass in _vehicleBlacklist, _vehicle getVariable ["ALIVE_profileIgnore",false]] call ALIVE_fnc_dump;
	
	if (
	    !(_vehicleClass in _vehicleBlacklist)
	    && !(_vehicle getVariable ["ALIVE_CombatSupport",false])
	    && !(_vehicle getVariable ["ALIVE_profileIgnore",false])
	    && !(_vehicle getVariable ["ALIVE_Convoy",false])
	    ) then {
		if((_vehicle getVariable ["profileID",""]) == "" && (_vehicle getVariable ["agentID",""]) == "" && _vehicleKind !="Vehicle") then {
		
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

			//["CPR profiling empty vehicle..."] call ALIVE_fnc_dump;
            //_profileVehicle call ALIVE_fnc_inspectHash;
			
			[ALIVE_profileHandler, "registerProfile", _profileVehicle] call ALIVE_fnc_profileHandler;
			
			_vehicleCount = _vehicleCount + 1;	
		} else {
        	_profileVehicle = [ALIVE_profileHandler, "getProfile",_vehicle getVariable "profileID"] call ALIVE_fnc_profileHandler;
        };
	};
} forEach _vehicles;


// DEBUG -------------------------------------------------------------------------------------
if(_debug) then {
	["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
	["ALIVE Create profiles from map empty vehicles Complete - vehicles profiled: [%1]",_vehicleCount] call ALIVE_fnc_dump;
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