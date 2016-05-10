#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profileEntity);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
Description:
Entity profile class

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enable, disable or refresh
Boolean - state - Store or restore state
String - profileID - Set the profile object id
String - companyID - Set the profile company id
Array - unitClasses - Set the profile class names
Array - position - Set the profile group position
Array - positions - Set the profile units positions
Array - damages - Set the profile units damages
Array - ranks - Set the profile units ranks
String - side - Set the profile side
String - leaderID - Set the profile group leader profile object id
String - vehicleIDs - Set the profile vehicle profile object id
Boolean - active - Flag for if the agents are spawned
Object - unit - Reference to the spawned units
None - unitCount - Returns the count of group units
None - unitIndexes - Returns the count of group units
Array - speedPerSecond - Returns the speed per second array
Hash - addVehicleAssignment - Add a profile vehicle assignment array to the profile waypoint array
None - clearVehicleAssignments - Clear the profile vehicle assignments array
Hash - addWaypoint - Add a profile waypoint object to the profile waypoint array
None - clearWaypoints - Clear the profile waypoint array
Array - mergePositions - Sets the position of all sub units to the passed position
Array - addUnit - Add a unit to the group [_class,_position,_damage]
Scalar - removeUnit - Remove a unit from the group
None - spawn - Spawn the group from the profile data
None - despawn - De-Spawn the group from the profile data

Examples:
(begin example)
// create a profile
_logic = [nil, "create"] call ALIVE_fnc_profileEntity;

// init the profile
_result = [_logic, "init"] call ALIVE_fnc_profileEntity;

// set the profile id
_result = [_logic, "profileID", "agent_01"] call ALIVE_fnc_profileEntity;

// set the profile company id
_result = [_logic, "companyID", "company_01"] call ALIVE_fnc_profileEntity;

// set the unit class of the profile
_result = [_logic, "unitClasses", ["B_Soldier_F","B_Soldier_F"]] call ALIVE_fnc_profileEntity;

// set the profile position
_result = [_logic, "position", getPos player] call ALIVE_fnc_profileEntity;

// set the profile units positions
_result = [_logic, "positions", [getPos player,getPos player]] call ALIVE_fnc_profileEntity;

// set the unit damage of the profile
_result = [_logic, "damages", [true,true]] call ALIVE_fnc_profileEntity;

// set the unit rank of the profile
_result = [_logic, "ranks", ["PRIVATE","CORPORAL"]] call ALIVE_fnc_profileEntity;

// set the profile side
_result = [_logic, "side", "WEST"] call ALIVE_fnc_profileEntity;

// set the vehicle object ids
_result = [_logic, "vehicleIDs", ["vehicle_01","vehicle_02"]] call ALIVE_fnc_profileEntity;

// set the profile is active
_result = [_logic, "active", true] call ALIVE_fnc_profileEntity;

// get the group leader
_result = [_logic, "leader"] call ALIVE_fnc_profileEntity;

// set the profile group
_result = [_logic, "group", _group] call ALIVE_fnc_profileEntity;

// set the profile units object references
_result = [_logic, "units", [_unit,_unit]] call ALIVE_fnc_profileEntity;

// get the profile units count
_result = [_logic, "unitCount"] call ALIVE_fnc_profileEntity;

// get the profile units indexes
_result = [_logic, "unitIndexes"] call ALIVE_fnc_profileEntity;

// get the profile speed per second
_result = [_logic, "speedPerSecond"] call ALIVE_fnc_profileEntity;

// add a vehicle assignment to the profile vehicle assignment array
_result = [_logic, "addVehicleAssignment", _profileVehicleAssignment] call ALIVE_fnc_profileEntity;

// clear all vehicle assignments in the profiles vehicle assignment array
_result = [_logic, "clearVehicleAssignments"] call ALIVE_fnc_profileEntity;

// add a waypoint to the profile waypoint array
_result = [_logic, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

// clear all waypoints in the profiles waypoint array
_result = [_logic, "clearWaypoints"] call ALIVE_fnc_profileEntity;

// set all unit positions to the current profile position
_result = [_logic, "mergePositions"] call ALIVE_fnc_profileEntity;

// add a unit to the group profile
_result = [_logic, "addUnit", ["B_Soldier_F",getPos player,0]] call ALIVE_fnc_profileEntity;

// remove a unit from the group profile by unit index
_result = [_logic, "removeUnit", 1] call ALIVE_fnc_profileEntity;

// spawn the group from the profile
_result = [_logic, "spawn"] call ALIVE_fnc_profileEntity;

// despawn the group from the profile
_result = [_logic, "despawn"] call ALIVE_fnc_profileEntity;

(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_profile
#define MAINCLASS ALIVE_fnc_profileEntity

private ["_result","_deleteMarkers","_createMarkers"];

TRACE_1("profileEntity - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
_result = true;

#define MTEMPLATE "ALiVE_PROFILEENTITY_%1"

_deleteMarkers = {
		private ["_logic"];
        _logic = _this;
        {
                deleteMarker _x;
		} forEach ([_logic,"debugMarkers", []] call ALIVE_fnc_hashGet);
};

_createMarkers = {
        private ["_logic","_markers","_m","_position","_dimensions","_debugColor","_debugIcon","_debugAlpha"
		,"_profileID","_profileSide","_profileType","_profileActive","_profileWaypoints","_typePrefix","_label",
		"_waypointCount","_waypointPosition","_waypointCount"];
        _logic = _this;
        _markers = [];

		_position = [_logic,"position"] call ALIVE_fnc_hashGet;
		_profileID = [_logic,"profileID"] call ALIVE_fnc_hashGet;
		_profileSide = [_logic,"side"] call ALIVE_fnc_hashGet;
		_profileType = [_logic,"objectType"] call ALIVE_fnc_hashGet;
		_profileActive = [_logic,"active"] call ALIVE_fnc_hashGet;
		_profileWaypoints = [_logic,"waypoints"] call ALIVE_fnc_hashGet;
		
		switch(_profileSide) do {
			case "EAST":{
				_debugColor = "ColorRed";
				_typePrefix = "o";
			};
			case "WEST":{
				_debugColor = "ColorBlue";
				_typePrefix = "b";
			};
			case "CIV":{
				_debugColor = "ColorYellow";
				_typePrefix = "n";
			};
			case "GUER":{
				_debugColor = "ColorGreen";
				_typePrefix = "n";
			};
			default {
				_debugColor = [_logic,"debugColor","ColorGreen"] call ALIVE_fnc_hashGet;
				_typePrefix = "n";
			};
		};
		
		switch(_profileType) do {
			default {
				_debugIcon = format["%1_inf",_typePrefix];
			};
		};

		_label = [_profileID, "_"] call CBA_fnc_split;
		
		_debugAlpha = 0.3;
		if(_profileActive) then {
			_debugAlpha = 1;
		}else{
		    _waypointCount = 0;
		    {
		        _waypointPosition = [_x,"position"] call ALIVE_fnc_hashGet;

		        _m = createMarker [format["SIM_MARKER_%1_%2",_profileID,_waypointCount], _waypointPosition];
                _m setMarkerShape "ICON";
                _m setMarkerSize [.6, .6];
                _m setMarkerType "waypoint";
                _m setMarkerColor _debugColor;
                _m setMarkerAlpha 0.6;

                _m setMarkerText format["%1",_label select ((count _label) - 1),_waypointCount];

                _markers pushback _m;

                [_logic,"debugMarkers",_markers] call ALIVE_fnc_hashSet;

                _waypointCount = _waypointCount + 1;
		    } forEach _profileWaypoints;
		};

        if(count _position > 0) then {
				_m = createMarker [format[MTEMPLATE, format["%1_debug",_profileID]], _position];
				_m setMarkerShape "ICON";
				_m setMarkerSize [.4, .4];
				_m setMarkerType _debugIcon;
				_m setMarkerColor _debugColor;
				_m setMarkerAlpha _debugAlpha;

                _m setMarkerText format["e%1",_label select ((count _label) - 1)];

				_markers pushback _m;

				[_logic,"debugMarkers",_markers] call ALIVE_fnc_hashSet;
        };
};

switch(_operation) do {
        case "init": {
                /*
                MODEL - no visual just reference data
                - nodes
                - center
                - size
                */

                if (isServer) then {
					// if server, initialise module game logic
					// nil these out they add a lot of code to the hash..
					[_logic,"super"] call ALIVE_fnc_hashRem;
					[_logic,"class"] call ALIVE_fnc_hashRem;
					//TRACE_1("After module init",_logic);
					
					// init the super class
					[_logic, "init"] call SUPERCLASS;
					
					// set defaults
					[_logic,"type","entity"] call ALIVE_fnc_hashSet; // select 2 select 5
					[_logic,"vehiclesInCommandOf",[]] call ALIVE_fnc_hashSet; // select 2 select 8
					[_logic,"vehiclesInCargoOf",[]] call ALIVE_fnc_hashSet; // select 2 select 9
					[_logic,"leader",objNull] call ALIVE_fnc_hashSet; // select 2 select 10						
					[_logic,"unitClasses",[]] call ALIVE_fnc_hashSet; // select 2 select 11
					[_logic,"unitCount",0] call ALIVE_fnc_hashSet; // select 2 select 12
					[_logic,"group",grpNull] call ALIVE_fnc_hashSet; // select 2 select 13
					[_logic,"companyID",""] call ALIVE_fnc_hashSet; // select 2 select 14			
					[_logic,"groupID",""] call ALIVE_fnc_hashSet; // select 2 select 15
					[_logic,"waypoints",[]] call ALIVE_fnc_hashSet; // select 2 select 16
					[_logic,"waypointsCompleted",[]] call ALIVE_fnc_hashSet; // select 2 select 17				
					[_logic,"positions",[]] call ALIVE_fnc_hashSet; // select 2 select 18
					[_logic,"damages",[]] call ALIVE_fnc_hashSet; // select 2 select 19
					[_logic,"ranks",[]] call ALIVE_fnc_hashSet; // select 2 select 20
					[_logic,"units",[]] call ALIVE_fnc_hashSet; // select 2 select 21
					[_logic,"speedPerSecond","Man" call ALIVE_fnc_vehicleGetSpeedPerSecond] call ALIVE_fnc_hashSet; // select 2 select 22
					[_logic,"despawnPosition",[0,0]] call ALIVE_fnc_hashSet; // select 2 select 23
					[_logic,"hasSimulated",false] call ALIVE_fnc_hashSet; // select 2 select 24
					[_logic,"isCycling",false] call ALIVE_fnc_hashSet; // select 2 select 25
					[_logic,"activeCommands",[]] call ALIVE_fnc_hashSet; // select 2 select 26
					[_logic,"inactiveCommands",[]] call ALIVE_fnc_hashSet; // select 2 select 27
					[_logic,"spawnType",[]] call ALIVE_fnc_hashSet; // select 2 select 28
					[_logic,"faction",[]] call ALIVE_fnc_hashSet; // select 2 select 29
					[_logic,"isPlayer",false] call ALIVE_fnc_hashSet; // select 2 select 30
					[_logic,"_rev",""] call ALIVE_fnc_hashSet; // select 2 select 31
					[_logic,"_id",""] call ALIVE_fnc_hashSet; // select 2 select 32
					[_logic,"busy",false] call ALIVE_fnc_hashSet; // select 2 select 33
                };

                /*
                VIEW - purely visual
                */

                /*
                CONTROLLER  - coordination
                */
        };
		case "debug": {
                if(typeName _args != "BOOL") then {
						_args = [_logic,"debug"] call ALIVE_fnc_hashGet;
                } else {
						[_logic,"debug",_args] call ALIVE_fnc_hashSet;
                };
                ASSERT_TRUE(typeName _args == "BOOL",str _args);

				 _logic call _deleteMarkers;

                if(_args) then {
                        _logic call _createMarkers;
                };

                _result = _args;
        };
		case "active": {
				if(typeName _args == "BOOL") then {
						[_logic,"active",_args] call ALIVE_fnc_hashSet;
                };
				_result = [_logic,"active"] call ALIVE_fnc_hashGet;
        };
		case "profileID": {
				if(typeName _args == "STRING") then {
						[_logic,"profileID",_args] call ALIVE_fnc_hashSet;
                };
				_result = [_logic,"profileID"] call ALIVE_fnc_hashGet;
        };
		case "side": {
				if(typeName _args == "STRING") then {
						[_logic,"side",_args] call ALIVE_fnc_hashSet;
                };
				_result = [_logic,"side"] call ALIVE_fnc_hashGet;
        };
		case "faction": {
				if(typeName _args == "STRING") then {
						[_logic,"faction",_args] call ALIVE_fnc_hashSet;
                };
				_result = [_logic,"faction"] call ALIVE_fnc_hashGet;
        };
		case "objectType": {
				if(typeName _args == "STRING") then {
						[_logic,"objectType",_args] call ALIVE_fnc_hashSet;
                };
				_result = [_logic,"objectType"] call ALIVE_fnc_hashGet;
        };
		case "companyID": {
				if(typeName _args == "STRING") then {
						[_logic,"companyID",_args] call ALIVE_fnc_hashSet;
                };
				_result = [_logic,"companyID"] call ALIVE_fnc_hashGet;
        };
		case "unitClasses": {
				if(typeName _args == "ARRAY") then {
						[_logic,"unitClasses",_args] call ALIVE_fnc_hashSet;
                };
				_result = [_logic,"unitClasses"] call ALIVE_fnc_hashGet;
        };
		case "position": {
				private ["_profileID"];
				
				if(typeName _args == "ARRAY") then {
						
						if(count _args == 2) then  {
							_args pushback 0;
						};

						if!(((_args select 0) + (_args select 1)) == 0) then {
						    [_logic,"position",_args] call ALIVE_fnc_hashSet;

                            if([_logic,"debug"] call ALIVE_fnc_hashGet) then {
                                [_logic,"debug",true] call MAINCLASS;
                            };

                            //["ENTITY %1 position: %2",_logic select 2 select 4,_args] call ALIVE_fnc_dump;

                            // store position on handler position index
                            _profileID = [_logic,"profileID"] call ALIVE_fnc_hashGet;
                            [ALIVE_profileHandler, "setPosition", [_profileID, _args]] call ALIVE_fnc_profileHandler;
						};

                };
				_result = _logic select 2 select 2; //[_logic,"position"] call ALIVE_fnc_hashGet;
        };
		case "despawnPosition": {
				if(typeName _args == "ARRAY") then {
						[_logic,"despawnPosition",_args] call ALIVE_fnc_hashSet;
                };
				_result = [_logic,"despawnPosition"] call ALIVE_fnc_hashGet;
        };
		case "positions": {
				if(typeName _args == "ARRAY") then {
						[_logic,"positions",_args] call ALIVE_fnc_hashSet;
                };
				_result = _logic select 2 select 18; //[_logic,"positions"] call ALIVE_fnc_hashGet;
        };
		case "damages": {
				if(typeName _args == "ARRAY") then {
						[_logic,"damages",_args] call ALIVE_fnc_hashSet;
                };
				_result = [_logic,"damages"] call ALIVE_fnc_hashGet;
        };
		case "ranks": {
				if(typeName _args == "ARRAY") then {
						[_logic,"ranks",_args] call ALIVE_fnc_hashSet;
                };
				_result = [_logic,"ranks"] call ALIVE_fnc_hashGet;
        };
		case "leader": {
				if(typeName _args == "OBJECT") then {
						[_logic,"leader",_args] call ALIVE_fnc_hashSet;
                };
				_result = [_logic,"leader"] call ALIVE_fnc_hashGet;
        };
		case "group": {
				if(typeName _args == "OBJECT") then {
						[_logic,"group",_args] call ALIVE_fnc_hashSet;
                };
				_result = [_logic,"group"] call ALIVE_fnc_hashGet;
        };
		case "units": {
				if(typeName _args == "ARRAY") then {
						[_logic,"units",_args] call ALIVE_fnc_hashSet;
                };
				_result = [_logic,"units"] call ALIVE_fnc_hashGet;
        };
		case "spawnType": {
				if(typeName _args == "ARRAY") then {
						[_logic,"spawnType",_args] call ALIVE_fnc_hashSet;
                };
				_result = [_logic,"spawnType"] call ALIVE_fnc_hashGet;
        };
        case "isPlayer": {
                if(typeName _args == "BOOL") then {
                        [_logic,"isPlayer",_args] call ALIVE_fnc_hashSet;
                };
                _result = [_logic,"isPlayer"] call ALIVE_fnc_hashGet;
        };
        case "busy": {
                if(typeName _args == "BOOL") then {
                        [_logic,"busy",_args] call ALIVE_fnc_hashSet;
                };
                _result = [_logic,"busy"] call ALIVE_fnc_hashGet;
        };
		case "unitCount": {
				private ["_unitClasses","_unitCount"];
				_unitClasses = _logic select 2 select 11; //[_logic,"unitClasses"] call ALIVE_fnc_hashGet;
				_unitCount = count _unitClasses;
				[_logic,"unitCount",_unitCount] call ALIVE_fnc_hashSet;

				_result = _unitCount;
        };
		case "unitIndexes": {
				private ["_unitIndexes","_unitCount"];
				_unitCount = [_logic, "unitCount"] call MAINCLASS;
				_unitIndexes = [];
				for "_i" from 0 to _unitCount-1 do {
					_unitIndexes set [_i, _i];
				};

				_result = _unitIndexes;
        };
		case "speedPerSecond": {				
				if(typeName _args == "ARRAY") then {
						[_logic,"speedPerSecond",_args] call ALIVE_fnc_hashSet;
                };
				_result = [_logic,"speedPerSecond"] call ALIVE_fnc_hashGet;
        };
		case "addVehicleAssignment": {
				private ["_assignments","_key","_active"];

				if(typeName _args == "ARRAY") then {
						_assignments = [_logic,"vehicleAssignments"] call ALIVE_fnc_hashGet;
						_key = _args select 0;
						[_assignments, _key, _args] call ALIVE_fnc_hashSet;
						
						// take assignments and determine if this entity is in command of any of them
						[_logic,"vehiclesInCommandOf",[_assignments,_logic] call ALIVE_fnc_profileVehicleAssignmentsGetInCommand] call ALIVE_fnc_hashSet;
						
						// take assignments and determine if this entity is in cargo of any of them
						[_logic,"vehiclesInCargoOf",[_assignments,_logic] call ALIVE_fnc_profileVehicleAssignmentsGetInCargo] call ALIVE_fnc_hashSet;
						
						// take assignments and determine the max speed per second for the entire group
						[_logic,"speedPerSecond",[_assignments,_logic] call ALIVE_fnc_profileVehicleAssignmentsGetSpeedPerSecond] call ALIVE_fnc_hashSet;

						// if spawned make the unit get in
						_active = _logic select 2 select 1; //[_logic,"active"] call ALIVE_fnc_hashGet
						if(_active) then {
							[_args, _logic, true] call ALIVE_fnc_profileVehicleAssignmentToVehicleAssignment;
						};
                };
		};
		case "clearVehicleAssignments": {
				[_logic,"vehicleAssignments",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
				[_logic,"vehiclesInCommandOf",[]] call ALIVE_fnc_hashSet;
				[_logic,"vehiclesInCargoOf",[]] call ALIVE_fnc_hashSet;
		};
        case "insertWaypoint": {
				private ["_waypoints","_units","_unit","_group","_active"];

				if(typeName _args == "ARRAY") then {
						_waypoints = _logic select 2 select 16; //[_logic,"waypoints"] call ALIVE_fnc_hashGet;
						_waypoints = [_waypoints, [_args], 0] call BIS_fnc_arrayInsert;
                        [_logic,"waypoints",_waypoints] call ALIVE_fnc_hashSet;

						_active = _logic select 2 select 1; //[_logic,"active"] call ALIVE_fnc_hashGet
						if(_active) then {
							_units = _logic select 2 select 21; //[_logic,"units"] call ALIVE_fnc_hashGet;
							_unit = _units select 0;
                            
                            if !(isnil "_unit") then {
								_group = group _unit;
								[_args, _group] call ALIVE_fnc_profileWaypointToWaypoint;
                            };
						};
						_result = _args;
                };
		};
		case "addWaypoint": {
				private ["_waypoints","_units","_unit","_group","_active"];

				if(typeName _args == "ARRAY") then {
						_waypoints = _logic select 2 select 16; //[_logic,"waypoints"] call ALIVE_fnc_hashGet;
						_waypoints pushback _args;
						
						if(([_args,"type"] call ALIVE_fnc_hashGet) == 'CYCLE') then {
							[_logic,"isCycling",true] call ALIVE_fnc_hashSet;
						};

						_active = _logic select 2 select 1; //[_logic,"active"] call ALIVE_fnc_hashGet
						if(_active) then {
							_units = _logic select 2 select 21; //[_logic,"units"] call ALIVE_fnc_hashGet;
							_unit = _units select 0;
                            
                            if !(isnil "_unit") then {
								_group = group _unit;
								[_args, _group] call ALIVE_fnc_profileWaypointToWaypoint;
                            };
						};
						_result = _args;
                };
		};
		case "clearWaypoints": {
				private ["_units","_unit","_group","_active"];

				[_logic,"waypoints",[]] call ALIVE_fnc_hashSet;
				[_logic,"waypointsCompleted",[]] call ALIVE_fnc_hashSet;

				_active = _logic select 2 select 1; //[_logic,"active"] call ALIVE_fnc_hashGet
				if(_active) then {
						_units = _logic select 2 select 21; //[_logic,"units"] call ALIVE_fnc_hashGet;
						_unit = _units select 0;
						_group = group _unit;
						while { count (waypoints _group) > 0 } do
						{
							deleteWaypoint ((waypoints _group) select 0);
						};
				}
		};
		case "setActiveCommand": {
                private ["_activeCommands","_type","_active"];

                if(typeName _args == "ARRAY") then {

                    [_logic, "clearActiveCommands"] call MAINCLASS;

                    [_logic, "addActiveCommand", _args] call MAINCLASS;

                    _active = _logic select 2 select 1; //[_profile, "active"] call ALIVE_fnc_hashGet;

                    if(_active) then {
                        _activeCommands = _logic select 2 select 26; //[_logic,"commands"] call ALIVE_fnc_hashGet;
                        [ALIVE_commandRouter, "activate", [_logic, _activeCommands]] call ALIVE_fnc_commandRouter;
                    };
                };
        };
		case "addActiveCommand": {
				private ["_activeCommands","_type"];

				if(typeName _args == "ARRAY") then {

                    _type = _logic select 2 select 5;

                    if (!(isnil "_type") && {_type == "entity"}) then {

                        _activeCommands = _logic select 2 select 26; //[_logic,"commands"] call ALIVE_fnc_hashGet;
                        _activeCommands pushback _args;
                    };
                };
		};
		case "clearActiveCommands": {
				private ["_activeCommands","_type"];
                
                _type = _logic select 2 select 5;
						
                if (!(isnil "_type") && {_type == "entity"}) then {
					_activeCommands = _logic select 2 select 26; //[_logic,"vehicleAssignments"] call ALIVE_fnc_hashGet;
					
					if(count _activeCommands > 0) then {
						[ALIVE_commandRouter, "deactivate", _logic] call ALIVE_fnc_commandRouter;
						[_logic,"activeCommands",[]] call ALIVE_fnc_hashSet;
					};
                };
		};
		case "addInactiveCommand": {
				private ["_inactiveCommands","_type"];
                
                _type = _logic select 2 select 5;
						
                if (!(isnil "_type") && {_type == "entity"}) then {
					if(typeName _args == "ARRAY") then {
							_inactiveCommands = _logic select 2 select 27; //[_logic,"commands"] call ALIVE_fnc_hashGet;
							_inactiveCommands pushback _args;
	                };
                };
		};
		case "clearInactiveCommands": {
				private ["_inactiveCommands","_type"];
                
                _type = _logic select 2 select 5;
						
                if (!(isnil "_type") && {_type == "entity"}) then {
					_inactiveCommands = _logic select 2 select 27; //[_logic,"vehicleAssignments"] call ALIVE_fnc_hashGet;
					
					if(count _inactiveCommands > 0) then {
						[ALIVE_commandRouter, "deactivate", _logic] call ALIVE_fnc_commandRouter;
						[_logic,"inactiveCommands",[]] call ALIVE_fnc_hashSet;
					};
                };
		};
		case "mergePositions": {
				private ["_position","_unitCount","_positions"];

				_position = _logic select 2 select 2; //[_logic,"position"] call ALIVE_fnc_hashGet;
				_unitCount = [_logic,"unitCount"] call MAINCLASS;
				_positions = _logic select 2 select 18; //[_logic,"positions"] call ALIVE_fnc_hashGet;

				//["ENTITY %1 mergePosition: %2",_logic select 2 select 4,_position] call ALIVE_fnc_dump;

				for "_i" from 0 to _unitCount-1 do
				{
						_positions set [_i, _position];
				};
		};
		case "addUnit": {
				private ["_class","_position","_damage","_rank","_unitIndex","_unitClasses","_positions","_damages","_ranks"];

				if(typeName _args == "ARRAY") then {
                        _args params [
                            "_class",
                            ["_position", [0,0,0], [[]]],
                            ["_damage", 0, [0]],
                            ["_rank", "PRIVATE", [""]]
                        ];
						_unitClasses = _logic select 2 select 11; //[_logic,"unitClasses"] call ALIVE_fnc_hashGet;
						_positions = _logic select 2 select 18; //[_logic,"positions"] call ALIVE_fnc_hashGet;
						_damages = _logic select 2 select 19; //[_logic,"damages"] call ALIVE_fnc_hashGet;
						_ranks = _logic select 2 select 20; //[_logic,"ranks"] call ALIVE_fnc_hashGet;

						_unitIndex = count _unitClasses;

						_unitClasses set [_unitIndex, _class];
						_positions set [_unitIndex, _position];
						_damages set [_unitIndex, _damage];
						_ranks set [_unitIndex, _rank];
                };
		};
		case "removeUnit": {
				private ["_unitIndex","_unitClass","_damages","_ranks","_units","_unitClasses","_positions","_active"];

				if(typeName _args == "SCALAR") then {

						_unitIndex = _args;
						_unitClasses = _logic select 2 select 11; //[_logic,"unitClasses"] call ALIVE_fnc_hashGet;
						_positions = _logic select 2 select 18; //[_logic,"positions"] call ALIVE_fnc_hashGet;
						_damages = _logic select 2 select 19; //[_logic,"damages"] call ALIVE_fnc_hashGet;
						_ranks = _logic select 2 select 20; //[_logic,"ranks"] call ALIVE_fnc_hashGet;

						_unitClasses set [_unitIndex, objNull];
						_unitClasses = _unitClasses - [objNull];
						_positions set [_unitIndex, objNull];
						_positions = _positions - [objNull];
						_damages set [_unitIndex, objNull];
						_damages = _damages - [objNull];
						_ranks set [_unitIndex, objNull];
						_ranks = _ranks - [objNull];

						[_logic,"unitClasses",_unitClasses] call ALIVE_fnc_hashSet;
						[_logic,"positions",_positions] call ALIVE_fnc_hashSet;
						[_logic,"damages",_damages] call ALIVE_fnc_hashSet;
						[_logic,"ranks",_ranks] call ALIVE_fnc_hashSet;

						_active = _logic select 2 select 1; //[_logic,"active"] call ALIVE_fnc_hashGet
						if(_active) then {
							_units = _logic select 2 select 21; //[_logic,"units"] call ALIVE_fnc_hashGet;
							_units set [_unitIndex, objNull];
							_units = _units - [objNull];
							[_logic,"units",_units] call ALIVE_fnc_hashSet;
						};
						
						_result = true;
						if(count(_unitClasses) == 0) then {
							_result = false;
						};
                };
		};
		case "removeUnitByObject": {
				private ["_units","_unitIndex"];
		
				if(typeName _args == "OBJECT") then {
					_units = _logic select 2 select 21; //[_logic,"units"] call ALIVE_fnc_hashGet;
					_unitIndex = 0;
					{
						if(_x == _args) then {
							_result = [_logic, "removeUnit", _unitIndex] call MAINCLASS;
						};
						_unitIndex = _unitIndex + 1;
					} forEach _units;
				};
		};
		case "resize": {
                private ["_size","_unitClasses","_active","_units","_side","_sideObject","_newGroup","_unit","_removeIndexes"];

                if(typeName _args == "SCALAR") then {
                        _size = _args;

                        _unitClasses = _logic select 2 select 11;
                        _active = _logic select 2 select 1; //[_logic,"active"] call ALIVE_fnc_hashGet
                        _units = _logic select 2 select 21; //[_logic,"units"] call ALIVE_fnc_hashGet;
                        _side = _logic select 2 select 3; //[_logic, "side"] call MAINCLASS;
                        _sideObject = [_side] call ALIVE_fnc_sideTextToObject;

                        if(_active) then {
                            _newGroup = createGroup _sideObject;
                        };

                        _removeIndexes = [];

                        {
                            if((_forEachIndex + 1) > _size) then {

                                if(_active) then {
                                    _unit = _units select (_forEachIndex - 1);
                                    [_unit] joinSilent _newGroup;
                                };

                                _removeIndexes pushback (_forEachIndex - 1);

                            };
                        } forEach _unitClasses;

                        reverse _removeIndexes;

                        {
                            [_logic, "removeUnit", _x] call MAINCLASS;
                        } forEach _removeIndexes;

                };
        };
        case "checkWaypointComplete": {

                private ["_debug","_active","_profileID","_waypointCompleted"];

                _debug = [_logic, "debug"] call MAINCLASS;

                _active = _logic select 2 select 1;
                _profileID = _logic select 2 select 4;

                _waypointCompleted = false;

                if(_active) then {
                    private ["_group","_leader","_currentPosition","_currentWaypoint","_waypoints","_waypointCount",
                    "_destination","_completionRadius","_distance"];

                    _group = _logic select 2 select 13;
                    _leader = leader _group;
                    _currentPosition = position _leader;
                    _currentWaypoint = currentWaypoint _group;
                    _waypoints = waypoints _group;
                    _currentWaypoint = _waypoints select ((count _waypoints)-1);

                    if!(isNil "_currentWaypoint") then {

                        _destination = waypointPosition _currentWaypoint;
                        _completionRadius = waypointCompletionRadius _currentWaypoint;

                        _completionRadius = (_completionRadius * 2) + 20;

                        _distance = _currentPosition distance _destination;

                        if(_distance < _completionRadius) then {
                            _waypointCompleted = true;
                        };

                    }else{
                        _waypointCompleted = true;
                    }

                } else {
                    private ["_waypoints"];

                    _waypoints = [_logic,"waypoints"] call ALIVE_fnc_hashGet;

                    if(count _waypoints == 0) then {
                        _waypointCompleted = true;
                    };
                };

                _result = _waypointCompleted;

        };
        case "setPosition": {

            private ["_active","_group"];

            if(typeName _args == "ARRAY") then {

                [_logic,"position",_args] call ALIVE_fnc_hashSet;

                //["ENTITY %1 setPosition: %2",_logic select 2 select 4,_args] call ALIVE_fnc_dump;

                _active = _logic select 2 select 1; //[_profile, "active"] call ALIVE_fnc_hashGet;

                if(_active) then {

                    _group = _logic select 2 select 13;

                    {
                        _x setPos _args;
                    } forEach (units _group);

                };
            };
        };
		case "spawn": {
				private ["_debug","_side","_sideObject","_unitClasses","_unitClass","_position","_positions","_damage","_damages","_ranks","_rank",
				"_profileID","_active","_waypoints","_waypointsCompleted","_vehicleAssignments","_activeCommands","_inactiveCommands","_group","_unitPosition","_eventID",
				"_waypointCount","_unitCount","_units","_unit","_vehiclesInCommandOf","_vehiclesInCargoOf","_paraDrop","_parachute","_soundFlyover","_formations","_formation","_locked"];
				
				_debug = _logic select 2 select 0; //[_logic,"debug"] call ALIVE_fnc_hashGet;
				_profileID = _logic select 2 select 4; //[_profile,"profileID"] call ALIVE_fnc_hashGet;
				_side = _logic select 2 select 3; //[_logic, "side"] call MAINCLASS;
				_sideObject = [_side] call ALIVE_fnc_sideTextToObject;
				_unitClasses = _logic select 2 select 11; //[_logic,"unitClasses"] call ALIVE_fnc_hashGet;
				_position = _logic select 2 select 2; //[_entityProfile,"position"] call ALIVE_fnc_hashGet;
				_positions = _logic select 2 select 18; //[_entityProfile,"positions"] call ALIVE_fnc_hashGet;
				_damages = _logic select 2 select 19; //[_logic,"damages"] call ALIVE_fnc_hashGet;
				_ranks = _logic select 2 select 20; //[_logic,"ranks"] call ALIVE_fnc_hashGet;
				_active = _logic select 2 select 1; //[_profile, "active"] call ALIVE_fnc_hashGet;	
				_waypoints = _logic select 2 select 16; //[_entityProfile,"waypoints"] call ALIVE_fnc_hashGet;
				_waypointsCompleted = _logic select 2 select 17; //[_entityProfile,"waypointsCompleted"] call ALIVE_fnc_hashGet;
				_vehicleAssignments = _logic select 2 select 7; //[_logic,"vehicleAssignments"] call ALIVE_fnc_hashGet;
				_activeCommands = _logic select 2 select 26; //[_logic,"vehicleAssignments"] call ALIVE_fnc_hashGet;
				_inactiveCommands = _logic select 2 select 27; //[_logic,"vehicleAssignments"] call ALIVE_fnc_hashGet;
				_vehiclesInCommandOf = _logic select 2 select 8; //[_profile,"vehiclesInCommandOf",[]] call ALIVE_fnc_hashSet;
                _vehiclesInCargoOf = _logic select 2 select 9; //[_profile,"vehiclesInCargoOf",[]] call ALIVE_fnc_hashSet;
                _locked = [_logic, "locked",false] call ALIVE_fnc_HashGet;
                
				_unitCount = 0;
				_units = [];

				// not already active and spawning has not yet been triggered
				if (!_active && !_locked) then {
                    
                	// Indicate profile has been despawned and unlock for asynchronous waits
                    [_logic, "locked",true] call ALIVE_fnc_HashSet;

				    _group = createGroup _sideObject;
                    
                    // select a random formation
					_formations = ["COLUMN","STAG COLUMN","WEDGE","ECH LEFT","ECH RIGHT","VEE","LINE"];
					_formation = selectRandom _formations;
					_group setFormation _formation; 

					// determine a suitable spawn position
					//["Profile [%1] Spawn - Get good spawn position",_profileID] call ALIVE_fnc_dump;
					//[true] call ALIVE_fnc_timer;
					[_logic] call ALIVE_fnc_profileGetGoodSpawnPosition;
					_position = _logic select 2 select 2; //[_entityProfile,"position"] call ALIVE_fnc_hashGet;
					//[] call ALIVE_fnc_timer;

					//["SPAWN ENTITY [%1] pos: %2 command: %3 cargo: %4",_profileID,_position,_vehiclesInCommandOf,_vehiclesInCargoOf] call ALIVE_fnc_dump;

                    _paraDrop = false;
                    if ((_position select 2) > 300) then {
                        if (((count _vehiclesInCommandOf) == 0) && {(count _vehiclesInCargoOf) == 0}) then {
                            _paraDrop = true;
                        };
                    } else {
                        if (((count _vehiclesInCommandOf) == 0) && {(count _vehiclesInCargoOf) == 0}) then {
                            _position set [2,0];
                        };
                    };

                    //["Profile [%1] Spawn - Spawn Units",_profileID] call ALIVE_fnc_dump;
                    //[true] call ALIVE_fnc_timer;
					{
                        if !(isnil "_x") then {
							_unitPosition = _positions select _unitCount;
							_damage = _damages select _unitCount;
							_rank = _ranks select _unitCount;
                            
                            //Creating unit on ground, or they will fall to death with slow-spawn
							_unit = _group createUnit [_x, [_unitPosition select 0, _unitPosition select 1, 0], [], 0 , "NONE"];
							
                            //Set name 
							//_unit setVehicleVarName format["%1_%2",_profileID, _unitCount];
                                                       
							_unit setPos formationPosition _unit;
							_unit setDamage _damage;
							_unit setRank _rank;
							
							// set profile id on the unit
							_unit setVariable ["profileID", _profileID];
							_unit setVariable ["profileIndex", _unitCount];
	
							// killed event handler
							_eventID = _unit addMPEventHandler["MPKilled", ALIVE_fnc_profileKilledEventHandler];
	
							_units set [_unitCount, _unit];
	
							_unitCount = _unitCount + 1;

							if(_paraDrop) then {
								
                                //Creating parachute on original position
                                _parachute = createvehicle ["Steerable_Parachute_F",_unitPosition,[],0,"none"];
                                
                                //Resetting unit to original position
                                _unit setpos _unitPosition;
                                _unit moveindriver _parachute;

                                _parachute setdir direction _unit;
                                _parachute setvelocity [0,0,-1];

                                if (time - (missionnamespace getvariable ["bis_fnc_curatorobjectedited_paraSoundTime",0]) > 0) then {
                                    _soundFlyover = selectRandom ["BattlefieldJet1","BattlefieldJet2"];
                                    [_parachute,_soundFlyover,"say3d"] remoteExec ["bis_fnc_sayMessage"];
                                    missionnamespace setvariable ["bis_fnc_curatorobjectedited_paraSoundTime",time + 10]
                                };

                                [_unit,_parachute] spawn {
                                    _unit = _this select 0;
                                    _parachute = _this select 1;

                                    waituntil {isnull _parachute || isnull _unit};
                                    _unit setdir direction _unit;
                                    deletevehicle _parachute;
                                };
                            };
                        };
                        sleep 0.5;
					} forEach _unitClasses;
					//[] call ALIVE_fnc_timer;


					// set group profile as active and store references to units on the profile
					[_logic,"leader", leader _group] call ALIVE_fnc_hashSet;
					[_logic,"group", _group] call ALIVE_fnc_hashSet;
					[_logic,"units", _units] call ALIVE_fnc_hashSet;
					[_logic,"active", true] call ALIVE_fnc_hashSet;

                    //["Profile [%1] Spawn - Create Waypoints",_profileID] call ALIVE_fnc_dump;
                    //[true] call ALIVE_fnc_timer;
					// create waypoints from profile waypoints					
					_waypoints = _waypoints + _waypointsCompleted;
					[_waypoints, _group] call ALIVE_fnc_profileWaypointsToWaypoints;
					//[] call ALIVE_fnc_timer;

                    //["Profile [%1] Spawn - Create Vehicle Assignments",_profileID] call ALIVE_fnc_dump;
                    //[true] call ALIVE_fnc_timer;
					// create vehicle assignments from profile vehicle assignments
					[_vehicleAssignments, _logic] call ALIVE_fnc_profileVehicleAssignmentsToVehicleAssignments;
					//[] call ALIVE_fnc_timer;

					//["Profile [%1] Spawn - Process Commands",_profileID] call ALIVE_fnc_dump;
                    //[true] call ALIVE_fnc_timer;
					// process commands
					if(count _inactiveCommands > 0) then {
						[ALIVE_commandRouter, "deactivate", _logic] call ALIVE_fnc_commandRouter;
					};
					if(count _activeCommands > 0) then {
						[ALIVE_commandRouter, "activate", [_logic, _activeCommands]] call ALIVE_fnc_commandRouter;
					};
					//[] call ALIVE_fnc_timer;

					//["Profile [%1] Spawn - Set Active",_profileID] call ALIVE_fnc_dump;
                    //[true] call ALIVE_fnc_timer;
					// store the profile id on the active profiles index
					[ALIVE_profileHandler,"setActive",[_profileID,_side,_logic]] call ALIVE_fnc_profileHandler;
					[ALIVE_profileHandler,"setEntityActive",_profileID] call ALIVE_fnc_profileHandler;
                    
                    //Remove combat flag
                    [_logic, "combat"] call ALIVE_fnc_HashRem;
                    
                    // Indicate profile has been spawned and unlock for asynchronous waits
                    [_logic, "locked",false] call ALIVE_fnc_HashSet;   

					//[] call ALIVE_fnc_timer;

                    //["Profile [%1] Spawn - Debug",_profileID] call ALIVE_fnc_dump;
                    //[true] call ALIVE_fnc_timer;

					// DEBUG -------------------------------------------------------------------------------------
					if(_debug) then {
						//["Profile [%1] Spawn - pos: %2",_profileID,_position] call ALIVE_fnc_dump;
						[_logic,"debug",true] call MAINCLASS;
					};
					// DEBUG -------------------------------------------------------------------------------------

					//[] call ALIVE_fnc_timer;

				};
		};
		case "despawn": {
				private ["_debug","_group","_leader","_units","_positions","_damages","_ranks","_active","_profileID","_side","_activeCommands","_inactiveCommands","_unitCount","_waypoints",
				"_profileWaypoint","_unit","_vehicle","_vehicleID","_profileVehicle","_profileVehicleAssignments","_assignments","_vehicleAssignments","_despawnPrevented","_linked","_spawnType"];

				_debug = _logic select 2 select 0; //[_logic,"debug"] call ALIVE_fnc_hashGet;
				_group = _logic select 2 select 13; //[_logic,"group"] call ALIVE_fnc_hashGet;
				_leader = _logic select 2 select 10; //[_logic,"leader"] call ALIVE_fnc_hashGet;
				_units = _logic select 2 select 21; //[_logic,"units"] call ALIVE_fnc_hashGet;
				_positions = _logic select 2 select 18; //[_logic,"positions"] call ALIVE_fnc_hashGet;
				_damages = _logic select 2 select 19; //[_logic,"damages"] call ALIVE_fnc_hashGet;
				_ranks = _logic select 2 select 20; //[_logic,"ranks"] call ALIVE_fnc_hashGet;
				_active = _logic select 2 select 1; //[_logic,"active"] call ALIVE_fnc_hashGet;
				_profileID = _logic select 2 select 4; //[_logic,"profileID"] call ALIVE_fnc_hashGet;
				_side = _logic select 2 select 3; //[_logic, "side"] call MAINCLASS;
				_activeCommands = _logic select 2 select 26; //[_logic,"vehicleAssignments"] call ALIVE_fnc_hashGet;
				_inactiveCommands = _logic select 2 select 27; //[_logic,"vehicleAssignments"] call ALIVE_fnc_hashGet;

                //Don't despawn player profiles
                if ([_logic, "isPlayer",false] call ALIVE_fnc_HashGet) exitwith {};
                
				_unitCount = 0;

				// not already inactive
				if(_active) then {
				
					// if any linked profiles have despawn prevented
					_despawnPrevented = false;
					_linked = [_logic] call ALIVE_fnc_vehicleAssignmentsGetLinkedProfiles;
					//_linked call ALIVE_fnc_inspectHash;
					if(count (_linked select 1) > 1) then {
						{
							_spawnType = [_x,"spawnType"] call ALIVE_fnc_hashGet;
							if(count _spawnType > 0) then {
								if(_spawnType select 0 == "preventDespawn") then {
									_despawnPrevented = true;
								};
							}
						} forEach (_linked select 2);
					};
					
					if!(_despawnPrevented) then {				

						[_logic,"active", false] call ALIVE_fnc_hashSet;

						// update profile waypoints before despawn
						[_logic,"clearWaypoints"] call MAINCLASS;
						[_logic,_group] call ALIVE_fnc_waypointsToProfileWaypoints;
						
						// update profile vehicle assignments before despawn
						[_logic,"clearVehicleAssignments"] call MAINCLASS;					
						[_logic] call ALIVE_fnc_vehicleAssignmentsToProfileVehicleAssignments;
						
						_position = getPosATL _leader;
						
						// update the profiles position
						[_logic,"position", _position] call ALIVE_fnc_hashSet;
						[_logic,"despawnPosition", _position] call ALIVE_fnc_hashSet;

						// delete units
						{
							_unit = _x;
							_positions set [_unitCount, getPosATL _unit];
							_damages set [_unitCount, getDammage _unit];
							_ranks set [_unitCount, rank _unit];
							deleteVehicle _unit;
							_unitCount = _unitCount + 1;
						} forEach _units;

						// delete group
                        // FIX YOUR FUCKING CODES BIS. FINALLY. AFTER 239475987 gazillion years
                        _group call ALiVE_fnc_DeleteGroupRemote;

						[_logic,"leader", objNull] call ALIVE_fnc_hashSet;
						[_logic,"positions", _positions] call ALIVE_fnc_hashSet;
						[_logic,"damages", _damages] call ALIVE_fnc_hashSet;
						[_logic,"group", objNull] call ALIVE_fnc_hashSet;
						[_logic,"units", []] call ALIVE_fnc_hashSet;
						
						// process commands
						if(count _activeCommands > 0) then {
							[ALIVE_commandRouter, "deactivate", _logic] call ALIVE_fnc_commandRouter;
						};
						if(count _inactiveCommands > 0) then {
							[ALIVE_commandRouter, "activate", [_logic, _inactiveCommands]] call ALIVE_fnc_commandRouter;
						};
						
						// store the profile id on the in active profiles index
						[ALIVE_profileHandler,"setInActive",[_profileID,_side,_logic]] call ALIVE_fnc_profileHandler;
						[ALIVE_profileHandler,"setEntityInActive",_profileID] call ALIVE_fnc_profileHandler;         
                                                						
						// DEBUG -------------------------------------------------------------------------------------
						if(_debug) then {
							//["Profile [%1] Despawn - pos: %2",_profileID,_position] call ALIVE_fnc_dump;
							[_logic,"debug",true] call MAINCLASS;
						};
						// DEBUG -------------------------------------------------------------------------------------
					};
				};
		};
		case "handleDeath": {
				if(typeName _args == "OBJECT") then {
					_result = [_logic, "removeUnitByObject", _args] call MAINCLASS;
					
					if!(_result) then {
						[ALIVE_commandRouter, "deactivate", _logic] call ALIVE_fnc_commandRouter;
					};
				};
		};
		case "destroy": {
            private ["_debug","_group","_units","_active","_profileID","_unitCount","_unit"];

            _debug = _logic select 2 select 0; //[_logic,"debug"] call ALIVE_fnc_hashGet;
            _group = _logic select 2 select 13; //[_logic,"group"] call ALIVE_fnc_hashGet;
            _units = _logic select 2 select 21; //[_logic,"units"] call ALIVE_fnc_hashGet;
            _active = _logic select 2 select 1; //[_logic,"active"] call ALIVE_fnc_hashGet;
            _profileID = _logic select 2 select 4; //[_logic,"profileID"] call ALIVE_fnc_hashGet;

            _unitCount = 0;

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["Profile [%1] Destroying",_profileID] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------

            // clear waypoints
            [_logic,"clearWaypoints"] call MAINCLASS;

            // clear assignments
            [_logic,"clearVehicleAssignments"] call MAINCLASS;

            // deactivate command
            [ALIVE_commandRouter, "deactivate", _logic] call ALIVE_fnc_commandRouter;

            // not already inactive
            if(_active) then {

                // delete units
                {
                    _unit = _x;
                    deleteVehicle _unit;
                    _unitCount = _unitCount + 1;
                } forEach _units;

                // delete group
                _group call ALiVE_fnc_DeleteGroupRemote;
            };

            // unregister
            [ALIVE_profileHandler, "unregisterProfile", _logic] call ALIVE_fnc_profileHandler;

            [_logic, "destroy"] call SUPERCLASS;
		};
		case "createMarker": {
				private ["_markers","_m","_position","_dimensions","_color","_icon","_alpha","_vehicleMarkers","_inCommand",
				"_profileID","_profileSide","_profileType","_profileActive","_vehiclesInCommandOf","_typePrefix","_label",
				"_vehicleProfile","_vehicleMarkers"];

				_alpha = _args param [0, 0.5, [1]];
				
				_markers = [];

				_position = _logic select 2 select 2; //[_entityProfile,"position"] call ALIVE_fnc_hashGet;
				_profileID = _logic select 2 select 4; //[_profile,"profileID"] call ALIVE_fnc_hashGet;
				_profileSide = _logic select 2 select 3; //[_logic, "side"] call MAINCLASS;
				_profileType  = _logic select 2 select 6; //[_logic,"objectType"] call ALIVE_fnc_hashGet;
				_profileActive = _logic select 2 select 1; //[_profile, "active"] call ALIVE_fnc_hashGet;				
				_vehiclesInCommandOf = _logic select 2 select 8; //[_profile,"vehiclesInCommandOf",[]] call ALIVE_fnc_hashSet;
					
				if(count _vehiclesInCommandOf > 0) then {
				
					_vehicleMarkers = [];
					_inCommand = true;
					{
						_vehicleProfile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
												
						if !(isnil "_vehicleProfile") then {
							_markers = [_vehicleProfile, "createMarker", _args] call ALIVE_fnc_profileVehicle;
						};
						
						_vehicleMarkers = _vehicleMarkers + _markers;
					} forEach _vehiclesInCommandOf;
					
					[_logic,"markers",_vehicleMarkers] call ALIVE_fnc_hashSet;
					
				}else{
				
					switch(_profileSide) do {
						case "EAST":{
							_color = "ColorRed";
							_typePrefix = "o";
						};
						case "WEST":{
							_color = "ColorBlue";
							_typePrefix = "b";
						};
						case "CIV":{
							_color = "ColorYellow";
							_typePrefix = "n";
						};
						case "GUER":{
							_color = "ColorGreen";
							_typePrefix = "n";
						};
						default {
							_color = [_logic,"debugColor","ColorGreen"] call ALIVE_fnc_hashGet;
							_typePrefix = "n";
						};
					};
					
					switch(_profileType) do {
						default {
							_icon = format["%1_inf",_typePrefix];
						};
					};

					if(count _position > 0) then {
						_m = createMarker [format[MTEMPLATE, _profileID], _position];
						_m setMarkerShape "ICON";
						_m setMarkerSize [0.4, 0.4];
						_m setMarkerType _icon;
						_m setMarkerColor _color;
						_m setMarkerAlpha _alpha;
						
						_markers pushback _m;

						[_logic,"markers",_markers] call ALIVE_fnc_hashSet;
					};
				};
				
				_result = _markers;
		};
		case "deleteMarker": {
				{
					deleteMarker _x;
				} forEach ([_logic,"markers", []] call ALIVE_fnc_hashGet);
		};
        default {
                _result = [_logic, _operation, _args] call SUPERCLASS;
        };
};
TRACE_1("profileEntity - output",_result);
_result;