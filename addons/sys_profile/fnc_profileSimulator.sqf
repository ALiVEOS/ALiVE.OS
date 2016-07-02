#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profileSimulator);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileSimulator

Description:
Simulates movement of profiles that have waypoints set

Parameters:

Returns:

Examples:
(begin example)
_result = [] call ALIVE_fnc_profileSimulator;
(end)

See Also:
nothing yet

Author:
ARJay
Highhead
---------------------------------------------------------------------------- */

//_id = floor(random(100000));
//_time = time;
//[true, "ALiVE Profile Simulation starting!", format["profileSimTotal_%1",_id]] call ALIVE_fnc_timer;

private [
    "_debug","_cycleTime","_profiles","_markers","_deleteMarkers","_deleteMarker","_createMarker","_profileIndex","_profileBlock","_profile",
	"_entityProfile","_profileType","_profileID","_active","_waypoints","_waypointsCompleted","_currentPosition","_vehiclesInCommandOf","_vehicleCommander",
    "_vehicleCargo","_vehiclesInCargoOf","_activeWaypoint","_type","_speed","_destination","_distance","_speedPerSecondArray","_speedPerSecond","_moveDistance",
    "_vehicleProfile","_vehicleClass","_vehicleAssignments","_speedArray","_direction","_newPosition","_leader","_handleWPcomplete","_statements","_isCycling",
    "_isPlayer","_group","_combatRange","_totalEntities"
];

_markers = _this select 0;
_cycleTime = _this select 1;
_debug = if(count _this > 2) then {_this select 2} else {false};

_profiles = [ALIVE_profileHandler, "profiles"] call ALIVE_fnc_hashGet;
//_profileBlock = [ALIVE_arrayBlockHandler,"getNextBlock", ["simulation",_profiles select 2,50]] call ALIVE_fnc_arrayBlockHandler;

_combatRange = [MOD(profileCombatHandler),"combatRange"] call ALiVE_fnc_hashGet;

_totalEntities = 0;

//[true, "ALiVE Profiles Movement starting", format["profileCheck_%1",_id]] call ALIVE_fnc_timer;
{
    //[true, "ALiVE Profile starts...", format["profileSim1_%1",_id]] call ALIVE_fnc_timer;

	_entityProfile = _x;

	_profileType = _entityProfile select 2 select 5; //[_profile,"type"] call ALIVE_fnc_hashGet;

	if(_profileType == "entity") then {

        _totalEntities = _totalEntities + 1;

        //[true, "ALiVE entity inits...", format["profileSim_%1",_id]] call ALIVE_fnc_timer;

		_profileID = _entityProfile select 2 select 4;              //[_profile,"profileID"] call ALIVE_fnc_hashGet;
		_active = _entityProfile select 2 select 1;                 //[_profile, "active"] call ALIVE_fnc_hashGet;
		_waypoints = _entityProfile select 2 select 16;             //[_entityProfile,"waypoints"] call ALIVE_fnc_hashGet;
		_waypointsCompleted = _entityProfile select 2 select 17;    //[_entityProfile,"waypointsCompleted",[]] call ALIVE_fnc_hashGet;
		_currentPosition = _entityProfile select 2 select 2;        //[_entityProfile,"position"] call ALIVE_fnc_hashGet;
		_vehiclesInCommandOf = _entityProfile select 2 select 8;    //[_entityProfile,"vehiclesInCommandOf"] call ALIVE_fnc_hashGet;
		_vehiclesInCargoOf = _entityProfile select 2 select 9;      //[_entityProfile,"vehiclesInCargoOf"] call ALIVE_fnc_hashGet;
		_speedPerSecondArray = _entityProfile select 2 select 22;   //[_entityProfile, "speedPerSecond"] call ALIVE_fnc_hashGet;
		_isCycling = _entityProfile select 2 select 25;             //[_entityProfile, "speedPerSecond"] call ALIVE_fnc_hashGet;
		_side = _entityProfile select 2 select 3;                   //[_entityProfile, "side"] call ALIVE_fnc_hashGet;
		_positions = _entityProfile select 2 select 18;             //[_entityProfile, "positions"] call ALIVE_fnc_hashGet;
		_isPlayer = _entityProfile select 2 select 30;              //[_entityProfile, "isPlayer"] call ALIVE_fnc_hashGet;
        _locked = [_entityProfile, "locked",false] call ALIVE_fnc_HashGet;
        _combat = [_entityProfile, "combat",false] call ALIVE_fnc_HashGet;

        if (!_locked && {!_combat}) then {

	        _vehicleCommander = false;
			_vehicleCargo = false;
	        _collected = false;
	        _isAir = false;

			// if entity is commanding a vehicle/s
			if(count _vehiclesInCommandOf > 0) then {
				_vehicleCommander = true;

	            // check if moving air unit
	            {
	                private ["_entry"];

	                _entry = [ALiVE_ProfileHandler,"getProfile",_x] call ALiVE_fnc_ProfileHandler;

	                if !(isNil "_entry") then {
						if (
							[_entry,"engineOn",false] call ALiVE_fnc_HashGet &&
							{([_entry,"vehicleClass",""] call ALiVE_fnc_HashGet) isKindOf "Air"}
                        ) then {
                            _isAir = true
                        };
					};
	            } foreach _vehiclesInCommandOf;
			};

			// if entity is cargo of vehicle/s
			if(count _vehiclesInCargoOf > 0) then {
				_vehicleCargo = true;
			};

	        //[false, "ALiVE entity init ended...", format["profileSim_%1",_id]] call ALIVE_fnc_timer;

            // Combat

			if (!_vehicleCargo && {!_isPlayer} && {!_isAir} && {!_combat}) then {

                // Find and attack enemy profiles in-range

                private _nearEnemies = [];

                {
                    private _posInt = _x select 2 select 2;
                    private _typeInt = _x select 2 select 5;
                    private _isPlayerInt = [_x,"isPlayer",false] call ALiVE_fnc_hashGet;

                    if (
                        (_typeInt == "entity") &&
                        {_posInt distance2D _currentPosition <= _combatRange} &&
                        {!_isPlayerInt}
                    ) then {

                        private _sideObj = [_side] call ALiVE_fnc_sideTextToObject;
                        private _sideInt = _x select 2 select 3;
                        private _enemySides = [];

                        if (_sideObj getfriend east < 0.6) then {_enemySides pushback "EAST"};
                        if (_sideObj getfriend west < 0.6) then {_enemySides pushback "WEST"};
                        if (_sideObj getfriend resistance < 0.6) then {_enemySides pushback "GUER"};

                        if (_sideInt in _enemySides) then {
                            _profileIDInt = _x select 2 select 4;
                            _nearEnemies pushback _profileIDInt;
                        };
                    };

                } foreach (_profiles select 2);

                if !(_nearEnemies isEqualTo []) then {

                    private _profileAttack = [nil,"create"] call ALiVE_fnc_profileAttack;
                    [_profileAttack,"init"] call ALiVE_fnc_profileAttack;
                    [_profileAttack,"position", _currentPosition] call ALiVE_fnc_hashSet;
                    [_profileAttack,"attacker", _profileID] call ALiVE_fnc_hashSet;
                    [_profileAttack,"targets", _nearEnemies] call ALiVE_fnc_hashSet;
                    [_profileAttack,"attackerSide", _side] call ALiVE_fnc_hashSet;

                    private _attackID = [MOD(profileCombatHandler),"addAttack", _profileAttack] call ALiVE_fnc_profileCombatHandler;

                    _combat = true;
                    [_entityProfile,"combat", _combat] call ALIVE_fnc_HashSet;
                    [_entityProfile,"attackID", _attackID] call ALIVE_fnc_HashSet;

                    _collected = true;

                    //["ALiVE Profile Simulation - Profile %1 begins attacking profiles %2!",_profileID,_nearEnemies] call ALIVE_fnc_dump;
                };
            };

			// entity has waypoints assigned and entity is not in cargo of a vehicle
			if (count _waypoints > 0 && {!_vehicleCargo} && {!_isPlayer}) then {

				// entity is not spawned, simulate
				if!(_active) then {

	                //[true, "ALiVE entity movement phase 1 start...", format["profileSim_%1",_id]] call ALIVE_fnc_timer;

					_activeWaypoint = _waypoints select 0;
					_type = [_activeWaypoint,"type"] call ALIVE_fnc_hashGet;
					_speed = [_activeWaypoint,"speed"] call ALIVE_fnc_hashGet;
					_speedModifier = [ALiVE_profileSystem,"speedModifier",1] call ALiVE_fnc_HashGet;
					_destination = [_activeWaypoint,"position"] call ALIVE_fnc_hashGet;
					_statements = [_activeWaypoint,"statements"] call ALIVE_fnc_hashGet;
					_distance = _currentPosition distance _destination;

					switch(_speed) do {
						case "LIMITED": {_speedPerSecond = _speedPerSecondArray select 0};
						case "NORMAL": {_speedPerSecond = _speedPerSecondArray select 1};
						case "FULL": {_speedPerSecond = _speedPerSecondArray select 2};
						case default {_speedPerSecond = _speedPerSecondArray select 1};
					};

					_moveDistance = floor(_speedPerSecond * _cycleTime * _speedModifier);
					_direction = 0;

					// DEBUG -------------------------------------------------------------------------------------
					if(_debug) then {
						//["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
						//["ALIVE Simulated profile movement Profile: [%1] WPType: [%2] WPSpeed: [%3] Distance: [%4] MoveSpeed: [%5] SpeedArray: %6",_profileID,_type,_speed,_distance,_speedPerSecond,_speedPerSecondArray] call ALIVE_fnc_dump;
						//[_entityProfile,_activeWaypoint] call _createMarker;
					};
					// DEBUG -------------------------------------------------------------------------------------

	                //[false, "ALiVE entity movement phase 1 end...", format["profileSim_%1",_id]] call ALIVE_fnc_timer;

					if (!_collected && {!(isnil "_currentPosition")} && {count _currentPosition > 0} && {!(isnil "_destination")} && {count _destination > 0}) then {

	                	//[true, "ALiVE entity movement phase 2 virtual start...", format["profileSim_%1",_id]] call ALIVE_fnc_timer;

						//else simulate them
						//Match 2D since some profiles dont have a _pos select 2 defined
						_currentPosition set [2,0];
						_destination set [2,0];
						_executeStatements = false;

						switch (_type) do {
							case "MOVE" : {
								_direction = _currentPosition getDir _destination;
								_newPosition = _currentPosition getPos [_moveDistance, _direction];
								_handleWPcomplete = {};
							};
							case "CYCLE" : {
								_direction = _currentPosition getDir _destination;
								_newPosition = _currentPosition getPos [_moveDistance, _direction];
								_handleWPcomplete = {
									_waypoints = _waypoints + _waypointsCompleted;
									_waypointsCompleted = [];
								};
							};
							default {
								_newPosition = _currentPosition;
								_handleWPcomplete = {};
							};
						};

						// distance to wp destination within completion radius
						if(_distance <= (_moveDistance * 2)) then {

							if(_isCycling) then {
								_waypointsCompleted pushback _activeWaypoint;
							};

							_waypoints set [0,objNull];
							_waypoints = _waypoints - [objNull];

							[] call _handleWPcomplete; _executeStatements = true;

							[_entityProfile,"waypoints",_waypoints] call ALIVE_fnc_hashSet;

							if(_isCycling) then {
								[_entityProfile,"waypointsCompleted",_waypointsCompleted] call ALIVE_fnc_hashSet;
							};
						};

						if(_vehicleCommander) then {
							// if entity is in command of a vehicle (not cargo)
							[_entityProfile,"hasSimulated",true] call ALIVE_fnc_hashSet;
							{
								_vehicleProfile = [ALiVE_ProfileHandler,"getProfile",_x] call ALiVE_fnc_ProfileHandler;

								if !(isnil "_vehicleProfile") then {

	                                // turn engineOn virtually
	                            	// move all entities within the vehicle
									// set the vehicle position and merge all assigned entities positions

									//["PROFILE SIM SIMMED ENTITY %1 IN COMMAND OF %2 SET VEHICLE POS: %3",_entityProfile select 2 select 4,_vehicleProfile select 2 select 4,_newPosition] call ALIVE_fnc_dump;

									[_vehicleProfile,"hasSimulated",true] call ALIVE_fnc_hashSet;
									[_vehicleProfile,"engineOn",true] call ALIVE_fnc_profileVehicle;
									[_vehicleProfile,"position",_newPosition] call ALIVE_fnc_profileVehicle;
									[_vehicleProfile,"direction",_direction] call ALIVE_fnc_profileVehicle;
									[_vehicleProfile,"mergePositions"] call ALIVE_fnc_profileVehicle;
								};
							} forEach _vehiclesInCommandOf;
						}else{

							//["PROFILE SIM SIMMED ENTITY %1 NOT IN COMMAND SET ENTITY POS: %2",_entityProfile select 2 select 4,_newPosition] call ALIVE_fnc_dump;

							// set the entity position and merge all unit positions to group position
							[_entityProfile,"hasSimulated",true] call ALIVE_fnc_hashSet;
							[_entityProfile,"position",_newPosition] call ALIVE_fnc_profileEntity;
							[_entityProfile,"mergePositions"] call ALIVE_fnc_profileEntity;
						};

	                    // Execute statements at the end, needs review of any variables in hashes
	                    if (_executeStatements) then {if ((typeName _statements == "ARRAY") && {call compile (_statements select 0)}) then {call compile (_statements select 1)}};

	                    //[false, "ALiVE entity movement phase 2 virtual end...", format["profileSim_%1",_id]] call ALIVE_fnc_timer;
					} else {
						//["Profile-Simulator corrupted profile detected %1: _currentPosition %2 _destination %3 _collected: %4",_profileID,_currentPosition,_destination,_collected] call ALIVE_fnc_dump;
					};

				// entity is spawned, update positions
				} else {

	                //[true, "ALiVE entity movement phase 2 live start...", format["profileSim_%1",_id]] call ALIVE_fnc_timer;

				    _group = _entityProfile select 2 select 13;

					_leader = leader _group; //_leader = [_profile,"leader"] call ALIVE_fnc_hashGet;
					_newPosition = getPosATL _leader;
					_position = _entityProfile select 2 select 2; //_leader = [_profile,"position"] call ALIVE_fnc_hashGet;

					if (!(isnil "_newPosition") && {count _newPosition > 0} && {!(isnil "_position")} && {count _position > 0}) then {

						_moveDistance = _newPosition distance _position;

						if(_moveDistance > 10) then {

							if(_vehicleCommander) then {
								// if in command of vehicle move all entities within the vehicle
								// set the vehicle position and merge all assigned entities positions

								//_leader = _entityProfile select 2 select 10; //_leader = [_profile,"leader"] call ALIVE_fnc_hashGet;

								_newPosition = getPosATL vehicle _leader;

								{
									_vehicleProfile = [ALiVE_ProfileHandler,"getProfile",_x] call ALiVE_fnc_ProfileHandler;

									//["PROFILE SIM SPAWNED ENTITY %1 IN COMMAND OF %2 SET VEHICLE POS: %3",_entityProfile select 2 select 4,_vehicleProfile select 2 select 4,_newPosition] call ALIVE_fnc_dump;

									if !(isnil "_vehicleProfile") then {
										[_vehicleProfile,"position",_newPosition] call ALIVE_fnc_profileVehicle;
										[_vehicleProfile,"mergePositions"] call ALIVE_fnc_profileVehicle;
									};
								} forEach _vehiclesInCommandOf;
							} else {
								//_leader = _entityProfile select 2 select 10; //_leader = [_profile,"leader"] call ALIVE_fnc_hashGet;
								_newPosition = getPosATL _leader;

								//["PROFILE SIM SPAWNED ENTITY %1 NOT IN COMMAND SET ENTITY POS: %2",_entityProfile select 2 select 4,_newPosition] call ALIVE_fnc_dump;

								// set the entity position and merge all unit positions to group position
								[_entityProfile,"position",_newPosition] call ALIVE_fnc_profileEntity;
								[_entityProfile,"mergePositions"] call ALIVE_fnc_profileEntity;
							};
						};
					} else {
						["Profile-Simulator corrupted spawned profile detected %1: _newPosition %2 _position %3",_profileID,_newPosition,_position] call ALIVE_fnc_dump;
					};

	                //[false, "ALiVE entity movement phase 2 live end...", format["profileSim_%1",_id]] call ALIVE_fnc_timer;
				};
			} else {

	            // the profile has no waypoints
			    if(!(_vehicleCargo) && !(_isPlayer)) then {

	                //[true, "ALiVE entity no-movement starts...", format["profileSim_%1",_id]] call ALIVE_fnc_timer;

	                _group = _entityProfile select 2 select 13; //_leader = [_profile,"leader"] call ALIVE_fnc_hashGet;
	                //_group = group _leader;

	                // but the profile has waypoints set, but not by ALiVE
	                // eg Zeus
	                if((!isNull _group) && {currentWaypoint _group < count waypoints _group && currentWaypoint _group > 0}) then {
	                    //["S1: %1 %2", currentWaypoint _group, count waypoints _group] call ALIVE_fnc_dump;

	                    _newPosition = getPosATL _leader;
	                    _position = _entityProfile select 2 select 2; //_leader = [_profile,"position"] call ALIVE_fnc_hashGet;

	                    if (!(isnil "_newPosition") && {count _newPosition > 0} && {!(isnil "_position")} && {count _position > 0}) then {

	                        _moveDistance = _newPosition distance _position;

	                        if(_moveDistance > 10) then {

	                            if(_vehicleCommander) then {
	                                // if in command of vehicle move all entities within the vehicle
	                                // set the vehicle position and merge all assigned entities positions

	                                //_leader = _entityProfile select 2 select 10; //_leader = [_profile,"leader"] call ALIVE_fnc_hashGet;

	                                _leader = leader _group;

	                                _newPosition = getPosATL vehicle _leader;

	                                {
	                                    _vehicleProfile = [ALiVE_ProfileHandler,"getProfile",_x] call ALiVE_fnc_ProfileHandler;

	                                    //["PROFILE SIM SPAWNED NO WAYPOINTS ENTITY %1 IN COMMAND OF %2 SET VEHICLE POS: %3",_entityProfile select 2 select 4,_vehicleProfile select 2 select 4,_newPosition] call ALIVE_fnc_dump;

	                                    if !(isnil "_vehicleProfile") then {
	                                        [_vehicleProfile,"position",_newPosition] call ALIVE_fnc_profileVehicle;
	                                        [_vehicleProfile,"mergePositions"] call ALIVE_fnc_profileVehicle;
	                                    };
	                                } forEach _vehiclesInCommandOf;
	                            } else {

	                                //_leader = _entityProfile select 2 select 10; //_leader = [_profile,"leader"] call ALIVE_fnc_hashGet;

	                                _leader = leader _group;

	                                _newPosition = getPosATL _leader;

	                                //["PROFILE SIM SPAWNED NO WAYPOINTS ENTITY %1 NOT IN COMMAND SET ENTITY POS: %2",_entityProfile select 2 select 4,_newPosition] call ALIVE_fnc_dump;

	                                // set the entity position and merge all unit positions to group position
	                                [_entityProfile,"position",_newPosition] call ALIVE_fnc_profileEntity;
	                                [_entityProfile,"mergePositions"] call ALIVE_fnc_profileEntity;
	                            };
	                        };
	                    } else {
	                    	["Profile-Simulator corrupted profile detected %1: _newPosition %2 _position %3",_profileID,_newPosition,_position] call ALIVE_fnc_dump;
	                    };
	                };

	                //[false, "ALiVE entity no-movement ends...", format["profileSim_%1",_id]] call ALIVE_fnc_timer;
			    };

			    // entity is player entity
	            if(_isPlayer) then {

	                //[true, "ALiVE entity player starts...", format["profileSim_%1",_id]] call ALIVE_fnc_timer;

	                _leader = _entityProfile select 2 select 10;    //_leader = [_profile,"leader"] call ALIVE_fnc_hashGet;
	                _newPosition = getPosATL _leader;
	                _position = _entityProfile select 2 select 2;   //_leader = [_profile,"position"] call ALIVE_fnc_hashGet;

					//Positions are valid
					if (!(isnil "_newPosition") && {str(_newPosition) != "[0,0,0]"} && {!(isnil "_position")} && {str(_position) != "[0,0,0]"}) then {

	                     _moveDistance = _newPosition distance _position;

	                     if(_moveDistance > 10) then {
	                         if(_vehicleCommander) then {
	                             // if in command of vehicle move all entities within the vehicle
	                             // set the vehicle position and merge all assigned entities positions

	                             _leader = _entityProfile select 2 select 10; //_leader = [_profile,"leader"] call ALIVE_fnc_hashGet;
	                             _newPosition = getPosATL vehicle _leader;

	                             {
	                                 _vehicleProfile = [ALiVE_ProfileHandler,"getProfile",_x] call ALiVE_fnc_ProfileHandler;

	                                 if !(isnil "_vehicleProfile") then {
	                                     [_vehicleProfile,"position",_newPosition] call ALIVE_fnc_profileVehicle;
	                                     [_vehicleProfile,"mergePositions"] call ALIVE_fnc_profileVehicle;
	                                 };
	                             } forEach _vehiclesInCommandOf;
	                         } else {
	                             _leader = _entityProfile select 2 select 10; //_leader = [_profile,"leader"] call ALIVE_fnc_hashGet;
	                             _newPosition = getPosATL _leader;

	                             // set the entity position and merge all unit positions to group position
	                             [_entityProfile,"position",_newPosition] call ALIVE_fnc_profileEntity;
	                             [_entityProfile,"mergePositions"] call ALIVE_fnc_profileEntity;
	                         };
	                     };

	                //Positions are invalid (due to missing player object or corrupted profile)
					} else {
	                     ["DISCONNECT"] call ALIVE_fnc_createProfilesFromPlayers;
					};

	                //[false, "ALiVE entity player ends...", format["profileSim_%1",_id]] call ALIVE_fnc_timer;
	            };
	        };

        };
	};

    //[false, "ALiVE Profile stops...", format["profileSim1_%1",_id]] call ALIVE_fnc_timer;

} foreach (_profiles select 2);
//[false, "ALiVE Profile Movement ending", format["profileCheck_%1",_id]] call ALIVE_fnc_timer;

//[true, "ALiVE Profile Battle Simulation starting", format["profileClash_%1",_id]] call ALIVE_fnc_timer;

// Simulate attacks

private [
    "_combatRate","_profileAttacks","_attacksToRemove","_toBeUnassigned","_toBeKilled","_attack",
    "_cyclesLeft","_active","_attacker","_targets","_attackerProfile","_targetIndex","_attackerID",
    "_targetNil","_targetCount","_attackerType","_attackerVehiclesInCommandOf","_targetIDs","_attackerPos",
    "_targetType","_targetVehiclesInCommandOf","_targetPos","_profilesToAttackWith","_targetsToAttack",
    "_ran","_nextTargetDamageModifier","_targetToAttack","_targetToAttackType","_profileToAttackHealth","_damageToInflict",
    "_unitCount","_dmgPerUnitEven","_randomIndex","_randomIndexDamage","_randomDamage","_nextTarget","_entityInCommandOf",
    "_assignedVehicles","_hitPointCount","_dmgPerHitPointEven","_randomHitPointDmg","_vehicleClass","_indexesToRemove",
    "_totalHitpoints","_victimType","_victimID","_victimPos","_victimFaction","_victimSide","_killerSide","_event","_eventID",
    "_targetToAttackID","_deadHitPoints","_randomHitPointNme"
];

_combatRate = [MOD(profileCombatHandler),"combatRate"] call ALiVE_fnc_hashGet;
_profileAttacks = [MOD(profileCombatHandler),"attacksByID"] call ALiVE_fnc_hashGet;
_attacksToRemove = [];
_toBeUnassigned = [];
_toBeKilled = [];

{
    _attack = _x;
    _cyclesLeft = [_attack,"cyclesLeft"] call ALiVE_fnc_hashGet;

    _active = false;

    if (_cyclesLeft > 0) then {
        [_attack,"cyclesLeft", _cyclesLeft - 1] call ALiVE_fnc_hashSet;

        _attackerID = [_attack,"attacker"] call ALiVE_fnc_hashGet;
        _targetIDs = [_attack,"targets"] call ALiVE_fnc_hashGet;

        _attacker = [MOD(profileHandler),"getProfile", _attackerID] call ALiVE_fnc_profileHandler;

        if (!isnil "_attacker") then {
            if !(_attacker select 2 select 1) then {                    // [_attacker,"active", false] call ALiVE_fnc_hashGet

                _targetCount = count _targetIDs;
                _targetIndex = 0;

                _target = [MOD(profileHandler),"getProfile", _targetIDs select _targetIndex] call ALiVE_fnc_profileHandler;
                _targetNil = isnil "_target";

                while {(_targetNil || {[_target,"active", false] call ALiVE_fnc_hashGet}) && {_targetIndex < _targetCount}} do {

                    if (_targetNil) then {
                        _targetIDs deleteAt _targetIndex;
                        _targetCount = _targetCount - 1;
                    } else {
                        _targetIndex = _targetIndex + 1;
                    };

                    _target = [MOD(profileHandler),"getProfile", _targetIDs select _targetIndex] call ALiVE_fnc_profileHandler;
                    _targetNil = isnil "_target";

                };

                if (!_targetNil) then {
                    if !(_target select 2 select 1) then {                              // [_target,"active", false] call ALiVE_fnc_hashGet
                        _attackerType = _attacker select 2 select 5;                    // [_attacker,"type"] call ALiVE_fnc_hashGet;
                        _attackerVehiclesInCommandOf = _attacker select 2 select 8;;    // [_attacker,"vehiclesInCommandOf"] call ALiVE_fnc_hashGet;
                        _attackerPos = _attacker select 2 select 2;                     // [_attacker,"position"] call ALiVE_fnc_hashGet;

                        _targetType = _target select 2 select 5;                        // [_target,"type"] call ALiVE_fnc_hashGet;
                        _targetVehiclesInCommandOf = _target select 2 select 8;         // [_target,"vehiclesInCommandOf"] call ALiVE_fnc_hashGet;
                        _targetPos = _target select 2 select 2;                         // [_target,"position"] call ALiVE_fnc_hashGet;

                        _maxEngagementRange = [_attack,"maxRange"] call ALiVE_fnc_hashGet;

                        if (_attackerPos distance2D _targetPos <= _maxEngagementRange) then {

                            // get profiles to attack with
                            // vehicles entity commands, or just the entity

                            _profilesToAttackWith = [];

                            {
                                _profilesToAttackWith pushback ([MOD(profileHandler),"getProfile", _x] call ALiVE_fnc_profileHandler);
                            } foreach _attackerVehiclesInCommandOf;

                            if (count _profilesToAttackWith == 0) then {
                                _profilesToAttackWith pushback _attacker; // entity shouldn't attack if it's inside vehicle(s)
                            };

                            // get targets to attack

                            _targetsToAttack = [];

                            {
                                _targetsToAttack pushback ([MOD(profileHandler),"getProfile", _x] call ALiVE_fnc_profileHandler);
                            } foreach _targetVehiclesInCommandOf;

                            if (count _targetsToAttack == 0) then {
                                _targetsToAttack pushback _target; // entity shouldn't be attacked separately if it's in a vehicle
                            };

                            // attack each target profile individually
                            // if vehicle is destroyed, unassigned it from it's entity

                            _nextTargetDamageModifier = 1;

                            while {count _targetsToAttack > 0 && {_nextTargetDamageModifier > 0}} do {

                                _targetToAttack = _targetsToAttack select 0;
                                _targetToAttackID = [_targetToAttack,"profileID"] call ALiVE_fnc_hashGet;
                                _targetToAttackType = _targetToAttack select 2 select 5;  // [_targetToAttack,"type"] call ALiVE_fnc_hashGet;

                                _profileToAttackHealth = 0;
                                _damageToInflict = 0;

                                if (_targetToAttackType == "entity") then {
                                    _profileToAttackHealth = [_targetToAttack,"damages"] call ALiVE_fnc_hashGet;
                                } else {
                                    _profileToAttackHealth = [_targetToAttack,"damage"] call ALiVE_fnc_hashGet;

                                    // if vehicle hasn't been spawned yet
                                    // init hitpoint values

                                    if (_profileToAttackHealth isEqualTo []) then {
                                        _vehicleClass = [_targetToAttack,"vehicleClass"] call ALiVE_fnc_hashGet;
                                        _totalHitpoints = _vehicleClass call ALiVE_fnc_configGetVehicleHitPoints;
                                        {_profileToAttackHealth pushback [_x,0]} foreach _totalHitpoints;
                                    };
                                };

                                // get total damage that can be dealt this turn
                                // damage is calculated from each vehicle the entity controls
                                // if entity controls no vehicles, the entity itself attacks

                                {
                                    _damageToInflict = _damageToInflict + (([_x,_targetToAttack] call ALiVE_fnc_profileGetDamageOutput) * _nextTargetDamageModifier * _cycleTime * _combatRate);
                                } foreach _profilesToAttackWith;

                                if (_damageToInflict > 0) then {
                                    _damageToInflictLeft = _damageToInflict;

                                    if (_targetToAttackType == "entity") then {
                                        // attacking entity
                                        // spread damage randomly over units

                                        _unitCount = count _profileToAttackHealth;

                                        if (_unitCount > 0) then {
                                            _indexesToRemove = [];
                                            _dmgPerUnitEven = _damageToInflict / _unitCount;

                                            while {_damageToInflictLeft > 0 && {_unitCount > 0}} do {
                                                _randomIndex = floor random _unitCount;
                                                _randomIndexDamage = _profileToAttackHealth select _randomIndex;

                                                // calc damage - ensure no overdamage
                                                _randomDamage = random [_dmgPerUnitEven / 2, _dmgPerUnitEven, _dmgPerUnitEven * 8];
                                                if (_randomDamage > _damageToInflictLeft) then {
                                                    _randomDamage = _damageToInflictLeft;
                                                };

                                                _randomIndexDamage = _randomIndexDamage + _randomDamage;
                                                _damageToInflictLeft = _damageToInflictLeft - _randomDamage;

                                                if (_randomIndexDamage >= 1) then {
                                                    _indexesToRemove pushback _randomIndex;
                                                    _profileToAttackHealth deleteAt _randomIndex;
                                                    _unitCount = _unitCount - 1;
                                                } else {
                                                    _profileToAttackHealth set [_randomIndex,_randomIndexDamage];
                                                };
                                            };
                                        };

                                        if (_unitCount > 0) then {
                                            _profileToAttackHealth = +_profileToAttackHealth; // must be copied so that "removeUnit" doesn't alter the new damage array

                                            {
                                                [_targetToAttack,"removeUnit", _x] call ALiVE_fnc_profileEntity;
                                            } foreach _indexesToRemove;

                                            [_targetToAttack,"damages", _profileToAttackHealth] call ALiVE_fnc_hashSet;
                                            _nextTargetDamageModifier = 0; // ensure main loop doesnt run again
                                        } else {
                                            _toBeKilled pushbackunique [_attacker,_targetToAttack];
                                            _targetsToAttack deleteAt 0;
                                        };

                                        _nextTargetDamageModifier = _damageToInflictLeft / _damageToInflict;
                                    } else {
                                        // attacking vehicle
                                        // spread damage randomly over hit points

                                        _vehStillAlive = false;
                                        _hitPointCount = count _profileToAttackHealth;
                                        _dmgPerHitPointEven = _damageToInflict / _hitPointCount;

                                        while {_damageToInflictLeft > 0} do {
                                            _randomIndex = floor random _hitPointCount;
                                            _randomHitPoint = _profileToAttackHealth select _randomIndex;
                                            _randomHitPointNme = _randomHitPoint select 0;
                                            _randomHitPointDmg = _randomHitPoint select 1;

                                            if (_randomHitPointNme != "HitFuel") then {
                                                _randomDamage = random [_dmgPerHitPointEven / 2, _dmgPerHitPointEven, _dmgPerHitPointEven * 8];

                                                _randomHitPointDmg = _randomHitPointDmg + _randomDamage;
                                                _damageToInflictLeft = _damageToInflictLeft - _randomDamage;

                                                if (_randomHitPointDmg >= 1) then {
                                                    _randomHitPoint set [1,1];
                                                } else {
                                                    _randomHitPoint set [1,_randomHitPointDmg];
                                                };

                                                _profileToAttackHealth set [_randomIndex,_randomHitPoint];
                                            };
                                        };

                                        // if all of the vehicles hitpoints are 0, vehicle is dead

                                        _deadHitPoints = 0;
                                        {if ((_x select 1) == 1) then {_deadHitPoints = _deadHitPoints + 1}} foreach _profileToAttackHealth;

                                        if (_deadHitPoints < floor ((count _profileToAttackHealth) * 0.90)) then {
                                            [_targetToAttack,"damage", _profileToAttackHealth] call ALiVE_fnc_hashSet;
                                        } else {
                                            _toBeUnassigned pushbackunique [_target,_targetToAttack];
                                            _toBeKilled pushbackunique [_attacker,_targetToAttack];
                                            _targetsToAttack deleteAt 0;

                                            // if this vehicle is the last vehicles it's commanding entity controls
                                            // kill the commanding entity as well

                                            {
                                                _entityInCommandOf = [MOD(profileHandler),"getProfile", _x] call ALiVE_fnc_profileHandler;
                                                _assignedVehicles = [_entityInCommandOf,"vehiclesInCommandOf"] call ALiVE_fnc_hashGet;

                                                if (_assignedVehicles isEqualTo [_targetToAttackID]) then {
                                                    _toBeKilled pushbackunique [_attacker, [MOD(profileHandler),"getProfile", _x] call ALiVE_fnc_profileHandler];
                                                };
                                            } foreach ([_targetToAttack,"entitiesInCommandOf"] call ALiVE_fnc_hashGet);
                                        };

                                        _nextTargetDamageModifier = _damageToInflictLeft / _damageToInflict;
                                    };
                                };
                            };

                            // combat simulation over

                            if (count _targetsToAttack > 0) then {
                                _active = true;
                            };
                        };
                    } else {
                        // all targets are spawned
                        // don't end attack
                        // but don't simulate it either
                        _active = true;
                    };
                };

            } else {
                // attacker is spawned
                // don't end attack
                // but don't simulate it either
                _active = true;
            };
        };
    };

    if (!_active) then {
        _attacksToRemove pushback _attack;

        _attackerID = [_attack,"attacker"] call ALiVE_fnc_hashGet;
        _attacker = [MOD(profileHandler),"getProfile", _attackerID] call ALiVE_fnc_profileHandler;

        if !(isnil "_attacker") then {
            [_attacker,"combat", false] call ALiVE_fnc_hashSet;
            [_attacker,"attackID", nil] call ALiVE_fnc_hashSet;
        };
    };
} foreach (_profileAttacks select 2);

//[false, "ALiVE Profile Attack Simulation ending", format["profileClash_%1",_id]] call ALIVE_fnc_timer;

{
    // remove crew from commanding entity

    // unassign vehicle from entity
    _x call ALIVE_fnc_removeProfileVehicleAssignment;
} foreach _toBeUnassigned;

//[true, "ALiVE Profile Battle Cleanup starting", format["profileClean_%1",_id]] call ALIVE_fnc_timer;
{
    _x params ["_killer","_victim"];

    _victimType = _victim select 2 select 5;

    if (_victimType == "entity") then {
        _victimPos = _victim select 2 select 2;
        _victimFaction = _victim select 2 select 29;
        _victimSide = _victim select 2 select 3;

        _killerSide = _killer select 2 select 3;

        // log event

        _event = ['PROFILE_KILLED', [_victimPos,_victimFaction,_victimSide,_killerSide],"Profile"] call ALIVE_fnc_event;
        _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
    };

    [MOD(profileHandler), "unregisterProfile", _victim] call ALiVE_fnc_profileHandler;

} foreach _toBekilled;
//[false, "ALiVE Profile Combat Cleanup ending", format["profileClean_%1",_id]] call ALIVE_fnc_timer;

// attacks must be removed killed profiles have been unregistered
[MOD(profileCombatHandler),"removeAttacks", _attacksToRemove] call ALiVE_fnc_profileCombatHandler;

/*
// scan remaining attacks
// create battle if 6+ exist in radius
private [
    "_battleSize","_battleMinAttacks","_profileBattles","_attackPos","_addedToBattle",
    "_battlePos","_nearAttacks","_testAttackPos","_profileBattle","_nearAttackPositions"
];

_battleSize = [MOD(profileCombatHandler),"battleSize"] call ALiVE_fnc_hashGet;
_battleMinAttacks = [MOD(profileCombatHandler),"battleMinAttacks"] call ALiVE_fnc_hashGet;

_profileAttacks = [MOD(profileCombatHandler),"attacksByID"] call ALiVE_fnc_hashGet;
_profileBattles = [MOD(profileCombatHandler),"battlesByID"] call ALiVE_fnc_hashGet;
{
    _attack = _x;
    _attackPos = [_x,"position"] call ALiVE_fnc_hashGet;
    _addedToBattle = false;

    {
        _battlePos = _x select 2 select 3;

        if (_battlePos distance2D _attackPos <= _battleSize) exitwith {
            [_x,"addAttack", _attack] call ALiVE_fnc_profileBattle;
        };

        _addedToBattle = true;
    } foreach (_profileBattles select 2);

    if (!_addedToBattle) then {
        _nearAttacks = [];
        _nearAttackPositions = [];

        {
            private _testAttackPos = _x select 2 select 4;
            private _testMaxRange = _x select 2 select 8;

            // ensure attack range is default combat range to exclude long range artillery
            if (_testAttackPos distance2D _attackPos <= _combatRange && {_testMaxRange == _combatRange}) then {
                _nearAttacks pushback _x;
                _nearAttackPositions pushback _testAttackPos;
            };
        } foreach (_profileAttacks select 2);

        if (count _nearAttacks >= _battleMinAttacks) then {
            _profileBattle = [nil,"create"] call ALiVE_fnc_profileBattle;
            [_profileBattle,"position", _nearAttackPositions call ALiVE_fnc_getCenterOfPositions] call ALiVE_fnc_hashSet;
            [_profileBattle,"addAttacks", _nearAttacks] call ALiVE_fnc_profileBattle;
        };
    };
} foreach (_profileAttacks select 2);
*/


//["ALiVE Profile Simulation - Time taken per profile %1 (%2)",(time - _time) / _totalEntities, _totalEntities] call ALiVE_fnc_DumpR;
//[false, "ALiVE Profile Simulation end!", format["profileSimTotal_%1",_id]] call ALIVE_fnc_timer;
