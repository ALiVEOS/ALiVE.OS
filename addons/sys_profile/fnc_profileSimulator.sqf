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

// private _id = floor(random(100000));
// private _time = time;
// [true, "ALiVE Profile Simulation starting!", format["profileSimTotal_%1",_id]] call ALIVE_fnc_timer;

private ["_leader"]; // TODO

params ["_markers","_cycleTime",["_debug", false]];

private _speedModifier = [ALiVE_profileSystem,"speedModifier",1] call ALiVE_fnc_HashGet;
private _combatRange = [MOD(profileCombatHandler),"combatRange"] call ALiVE_fnc_hashGet;

private _moveDistModifier = _cycleTime * _speedModifier;

private _profiles = [ALIVE_profileHandler, "profiles"] call ALIVE_fnc_hashGet;
// private _profileBlock = [ALIVE_arrayBlockHandler,"getNextBlock", ["simulation",_profiles select 2,50]] call ALIVE_fnc_arrayBlockHandler;

private _totalEntities = 0;

//[true, "ALiVE Profiles Movement starting", format["profileCheck_%1",_id]] call ALIVE_fnc_timer;
{
    //[true, "ALiVE Profile starts...", format["profileSim1_%1",_id]] call ALIVE_fnc_timer;

    private _entityProfile = _x;
    private _profileType = _entityProfile select 2 select 5; //[_profile,"type"] call ALIVE_fnc_hashGet;

    if(_profileType == "entity") then {

        _totalEntities = _totalEntities + 1;

        //[true, "ALiVE entity inits...", format["profileSim_%1",_id]] call ALIVE_fnc_timer;

        private _profileID = _entityProfile select 2 select 4;              // [_profile,"profileID"] call ALIVE_fnc_hashGet;
        private _active = _entityProfile select 2 select 1;                 // [_profile, "active"] call ALIVE_fnc_hashGet;
        private _waypoints = _entityProfile select 2 select 16;             // [_entityProfile,"waypoints"] call ALIVE_fnc_hashGet;
        private _waypointsCompleted = _entityProfile select 2 select 17;    // [_entityProfile,"waypointsCompleted",[]] call ALIVE_fnc_hashGet;
        private _currentPosition = _entityProfile select 2 select 2;        // [_entityProfile,"position"] call ALIVE_fnc_hashGet;
        private _vehiclesInCommandOf = _entityProfile select 2 select 8;    // [_entityProfile,"vehiclesInCommandOf"] call ALIVE_fnc_hashGet;
        private _vehiclesInCargoOf = _entityProfile select 2 select 9;      // [_entityProfile,"vehiclesInCargoOf"] call ALIVE_fnc_hashGet;
        private _speedPerSecondArray = _entityProfile select 2 select 22;   // [_entityProfile, "speedPerSecond"] call ALIVE_fnc_hashGet;
        private _isCycling = _entityProfile select 2 select 25;             // [_entityProfile, "speedPerSecond"] call ALIVE_fnc_hashGet;
        private _side = _entityProfile select 2 select 3;                   // [_entityProfile, "side"] call ALIVE_fnc_hashGet;
        private _positions = _entityProfile select 2 select 18;             // [_entityProfile, "positions"] call ALIVE_fnc_hashGet;
        private _isPlayer = _entityProfile select 2 select 30;              // [_entityProfile, "isPlayer"] call ALIVE_fnc_hashGet;
        private _locked = [_entityProfile, "locked",false] call ALIVE_fnc_HashGet;
        private _combat = [_entityProfile, "combat",false] call ALIVE_fnc_HashGet;

        if (!_locked && {!_combat}) then {

            private _vehicleCommander = false;
            private _vehicleCargo = false;
            private _collected = false;
            private _isAir = false;

            // if entity is commanding a vehicle/s
            if(count _vehiclesInCommandOf > 0) then {
                _vehicleCommander = true;

                // check if moving air unit
                {
                    private _entry = [ALiVE_ProfileHandler,"getProfile",_x] call ALiVE_fnc_ProfileHandler;

                    if !(isNil "_entry") then {
                        if (
                            [_entry,"engineOn",false] call ALiVE_fnc_HashGet &&
                            {([_entry,"vehicleClass",""] call ALiVE_fnc_HashGet) isKindOf "Air"}
                        ) then {
                            _isAir = true;
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
                            private _profileIDInt = _x select 2 select 4;
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

                    private _activeWaypoint = _waypoints select 0;
                    private _type = [_activeWaypoint,"type"] call ALIVE_fnc_hashGet;
                    private _speed = [_activeWaypoint,"speed"] call ALIVE_fnc_hashGet;
                    private _destination = [_activeWaypoint,"position"] call ALIVE_fnc_hashGet;
                    private _statements = [_activeWaypoint,"statements"] call ALIVE_fnc_hashGet;
                    private _distance = _currentPosition distance _destination;

                    private ["_speedPerSecond"];

                    switch(_speed) do {
                        case "LIMITED": {_speedPerSecond = _speedPerSecondArray select 0};
                        case "NORMAL": {_speedPerSecond = _speedPerSecondArray select 1};
                        case "FULL": {_speedPerSecond = _speedPerSecondArray select 2};
                        case default {_speedPerSecond = _speedPerSecondArray select 1};
                    };

                    private _moveDistance = floor(_speedPerSecond * _moveDistModifier);
                    private _direction = 0;

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
                        private _executeStatements = false;

                        private ["_newPosition","_handleWPcomplete"];

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
                                private _vehicleProfile = [ALiVE_ProfileHandler,"getProfile",_x] call ALiVE_fnc_ProfileHandler;

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

                    private _group = _entityProfile select 2 select 13;

                    _leader = leader _group; //_leader = [_profile,"leader"] call ALIVE_fnc_hashGet;
                    private _newPosition = getPosATL _leader;
                    private _position = _entityProfile select 2 select 2; //_leader = [_profile,"position"] call ALIVE_fnc_hashGet;

                    if (!(isnil "_newPosition") && {count _newPosition > 0} && {!(isnil "_position")} && {count _position > 0}) then {

                        private _moveDistance = _newPosition distance _position;

                        if(_moveDistance > 10) then {

                            if(_vehicleCommander) then {
                                // if in command of vehicle move all entities within the vehicle
                                // set the vehicle position and merge all assigned entities positions

                                //_leader = _entityProfile select 2 select 10; //_leader = [_profile,"leader"] call ALIVE_fnc_hashGet;

                                _newPosition = getPosATL vehicle _leader;

                                {
                                    private _vehicleProfile = [ALiVE_ProfileHandler,"getProfile",_x] call ALiVE_fnc_ProfileHandler;

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

                    private _group = _entityProfile select 2 select 13; //_leader = [_profile,"leader"] call ALIVE_fnc_hashGet;
                    //_group = group _leader;

                    // but the profile has waypoints set, but not by ALiVE
                    // eg Zeus
                    if((!isNull _group) && {currentWaypoint _group < count waypoints _group && currentWaypoint _group > 0}) then {
                        //["S1: %1 %2", currentWaypoint _group, count waypoints _group] call ALIVE_fnc_dump;

                        private _newPosition = getPosATL _leader;
                        private _position = _entityProfile select 2 select 2; //_leader = [_profile,"position"] call ALIVE_fnc_hashGet;

                        if (!(isnil "_newPosition") && {count _newPosition > 0} && {!(isnil "_position")} && {count _position > 0}) then {

                            private _moveDistance = _newPosition distance _position;

                            if(_moveDistance > 10) then {

                                if(_vehicleCommander) then {
                                    // if in command of vehicle move all entities within the vehicle
                                    // set the vehicle position and merge all assigned entities positions

                                    //_leader = _entityProfile select 2 select 10; //_leader = [_profile,"leader"] call ALIVE_fnc_hashGet;

                                    _leader = leader _group;

                                    _newPosition = getPosATL vehicle _leader;

                                    {
                                        private _vehicleProfile = [ALiVE_ProfileHandler,"getProfile",_x] call ALiVE_fnc_ProfileHandler;

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

                    private _leader = _entityProfile select 2 select 10;    //_leader = [_profile,"leader"] call ALIVE_fnc_hashGet;
                    private _newPosition = getPosATL _leader;
                    private _position = _entityProfile select 2 select 2;   //_leader = [_profile,"position"] call ALIVE_fnc_hashGet;

                    //Positions are valid
                    if (!(isnil "_newPosition") && {str(_newPosition) != "[0,0,0]"} && {!(isnil "_position")} && {str(_position) != "[0,0,0]"}) then {

                        private _moveDistance = _newPosition distance _position;

                        if(_moveDistance > 10) then {
                            if(_vehicleCommander) then {
                                // if in command of vehicle move all entities within the vehicle
                                // set the vehicle position and merge all assigned entities positions

                                //_leader = _entityProfile select 2 select 10; //_leader = [_profile,"leader"] call ALIVE_fnc_hashGet;
                                _newPosition = getPosATL vehicle _leader;

                                {
                                    private _vehicleProfile = [ALiVE_ProfileHandler,"getProfile",_x] call ALiVE_fnc_ProfileHandler;

                                    if !(isnil "_vehicleProfile") then {
                                        [_vehicleProfile,"position",_newPosition] call ALIVE_fnc_profileVehicle;
                                        [_vehicleProfile,"mergePositions"] call ALIVE_fnc_profileVehicle;
                                    };
                                } forEach _vehiclesInCommandOf;
                            } else {
                                //_leader = _entityProfile select 2 select 10; //_leader = [_profile,"leader"] call ALIVE_fnc_hashGet;
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

private _combatRate = [MOD(profileCombatHandler),"combatRate"] call ALiVE_fnc_hashGet;
private _profileAttacks = [MOD(profileCombatHandler),"attacksByID"] call ALiVE_fnc_hashGet;
private _attacksToRemove = [];
private _toBeUnassigned = [];
private _toBeKilled = [];

private _damageModifier = _cycleTime * _combatRate;

{
    private ["_attacker"];

    private _attack = _x;
    private _cyclesLeft = [_attack,"cyclesLeft"] call ALiVE_fnc_hashGet;

    private _active = false;

    if (_cyclesLeft > 0) then {
        [_attack,"cyclesLeft", _cyclesLeft - 1] call ALiVE_fnc_hashSet;

        private _attackerID = [_attack,"attacker"] call ALiVE_fnc_hashGet;
        private _targetIDs = [_attack,"targets"] call ALiVE_fnc_hashGet;

        _attacker = [MOD(profileHandler),"getProfile", _attackerID] call ALiVE_fnc_profileHandler;

        if (!isnil "_attacker") then {
            if !(_attacker select 2 select 1) then {                    // [_attacker,"active", false] call ALiVE_fnc_hashGet

                private _targetCount = count _targetIDs;
                private _targetIndex = 0;

                private _target = [MOD(profileHandler),"getProfile", _targetIDs select _targetIndex] call ALiVE_fnc_profileHandler;
                private _targetNil = isnil "_target";

                while {(_targetNil || {_target select 2 select 1}) && {_targetIndex < _targetCount}} do {
                    if (_targetNil) then {
                        _targetIDs deleteAt _targetIndex;
                        _targetCount = _targetCount - 1;
                    } else {
                        _targetIndex = _targetIndex + 1;
                    };

                    _target = [MOD(profileHandler),"getProfile", _targetIDs select _targetIndex] call ALiVE_fnc_profileHandler;
                    _targetNil = isnil "_target";

                };

                if (!_targetNil && {_targetIndex != _targetCount}) then {
                    if !(_target select 2 select 1) then {                                      // [_target,"active", false] call ALiVE_fnc_hashGet
                        private _attackerType = _attacker select 2 select 5;                    // [_attacker,"type"] call ALiVE_fnc_hashGet;
                        private _attackerVehiclesInCommandOf = _attacker select 2 select 8;;    // [_attacker,"vehiclesInCommandOf"] call ALiVE_fnc_hashGet;
                        private _attackerPos = _attacker select 2 select 2;                     // [_attacker,"position"] call ALiVE_fnc_hashGet;

                        private _targetType = _target select 2 select 5;                        // [_target,"type"] call ALiVE_fnc_hashGet;
                        private _targetVehiclesInCommandOf = _target select 2 select 8;         // [_target,"vehiclesInCommandOf"] call ALiVE_fnc_hashGet;
                        private _targetPos = _target select 2 select 2;                         // [_target,"position"] call ALiVE_fnc_hashGet;

                        private _maxEngagementRange = [_attack,"maxRange"] call ALiVE_fnc_hashGet;

                        if (_attackerPos distance2D _targetPos <= _maxEngagementRange) then {

                            // get profiles to attack with
                            // vehicles entity commands, or just the entity

                            private _profilesToAttackWith = [];

                            {
                                private _profileUnderCommand = [MOD(profileHandler),"getProfile", _x] call ALiVE_fnc_profileHandler;

                                if (!isnil "_profileUnderCommand") then {
                                    _profilesToAttackWith pushback _profileUnderCommand;
                                };
                            } foreach _attackerVehiclesInCommandOf;

                            if (_profilesToAttackWith isEqualTo []) then {
                                _profilesToAttackWith pushback _attacker; // entity shouldn't attack if it's inside vehicle(s)
                            };

                            // get targets to attack

                            private _targetsToAttack = [];

                            {
                                private _targetToAttack = [MOD(profileHandler),"getProfile", _x] call ALiVE_fnc_profileHandler;

                                if (!isnil "_targetToAttack") then {
                                    _targetsToAttack pushback _targetToAttack;
                                };
                            } foreach _targetVehiclesInCommandOf;

                            if (_targetsToAttack isEqualTo []) then {
                                _targetsToAttack pushback _target; // entity shouldn't be attacked separately if it's in a vehicle
                            } else {
                                reverse _targetsToAttack; // destroy vehicles in reverse order to avoid corrupting unit assignment indexes
                            };

                            if !(_targetsToAttack isEqualTo []) then {
                                // attack each target profile individually
                                // if vehicle is destroyed, unassigned it from it's entity

                                private _targetToAttack = _targetsToAttack select 0;
                                private _targetToAttackID = [_targetToAttack,"profileID"] call ALiVE_fnc_hashGet;
                                private _targetToAttackType = _targetToAttack select 2 select 5;  // [_targetToAttack,"type"] call ALiVE_fnc_hashGet;

                                private _profileToAttackHealth = [];
                                private _damageToInflict = 0;

                                if (_targetToAttackType == "entity") then {
                                    _profileToAttackHealth = +([_targetToAttack,"damages"] call ALiVE_fnc_hashGet); // must be copied so that calling "removeUnit" doesn't alter the new damage array
                                } else {
                                    _profileToAttackHealth = [_targetToAttack,"damage"] call ALiVE_fnc_hashGet;

                                    // if vehicle hasn't been spawned yet
                                    // init hitpoint values

                                    if (_profileToAttackHealth isEqualTo []) then {
                                        private _vehicleClass = [_targetToAttack,"vehicleClass"] call ALiVE_fnc_hashGet;
                                        private _totalHitpoints = _vehicleClass call ALiVE_fnc_configGetVehicleHitPoints;
                                        {_profileToAttackHealth pushback [_x,0]} foreach _totalHitpoints;
                                    };
                                };

                                // get total damage that can be dealt this turn
                                // damage is calculated from each vehicle the entity controls
                                // if entity controls no vehicles, the entity itself attacks

                                {
                                    _damageToInflict = _damageToInflict + (([_x,_targetToAttack] call ALiVE_fnc_profileGetDamageOutput) * _damageModifier);
                                } foreach _profilesToAttackWith;

                                if (_damageToInflict > 0) then {
                                    private _damageToInflictLeft = _damageToInflict;

                                    if (_targetToAttackType == "entity") then {
                                        // attacking entity
                                        // spread damage randomly over units

                                        private _unitCount = count _profileToAttackHealth;

                                        if (_unitCount > 0) then {
                                            private _indexesToRemove = [];
                                            private _dmgPerUnitEven = _damageToInflict / _unitCount;

                                            private _randomDamageMin = _dmgPerUnitEven / 2;
                                            private _randomDamageMax = _dmgPerUnitEven * 8;

                                            while {_damageToInflictLeft > 0 && {_unitCount > 0}} do {
                                                private _randomIndex = floor random _unitCount;
                                                private _randomIndexDamage = _profileToAttackHealth select _randomIndex;

                                                // calc damage - ensure no overdamage

                                                private _randomDamage = random [_randomDamageMin, _dmgPerUnitEven, _randomDamageMax];
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

                                            {
                                                [_targetToAttack,"removeUnit", _x] call ALiVE_fnc_profileEntity;
                                            } foreach _indexesToRemove;

                                            [_targetToAttack,"damages", _profileToAttackHealth] call ALiVE_fnc_hashSet;

                                            if (_unitCount == 0) then {
                                                _toBeKilled pushbackunique [_attacker,_targetToAttack];
                                                _targetsToAttack deleteAt 0;
                                            };
                                        } else {
                                            _toBeKilled pushbackunique [_attacker,_targetToAttack];
                                            _targetsToAttack deleteAt 0;
                                        };
                                    } else {
                                        // attacking vehicle
                                        // spread damage randomly over hit points

                                        private _hitPointCount = count _profileToAttackHealth;
                                        private _dmgPerHitPointEven = _damageToInflict / _hitPointCount;

                                        private _randomDamageMin = _dmgPerHitPointEven / 2;
                                        private _randomDamageMax = _dmgPerHitPointEven * 8;

                                        while {_damageToInflictLeft > 0} do {
                                            private _randomIndex = floor random _hitPointCount;
                                            private _randomHitPoint = _profileToAttackHealth select _randomIndex;

                                            _randomHitPoint params ["_randomHitPointNme","_randomHitPointDmg"];

                                            if (_randomHitPointNme != "HitFuel") then {
                                                private _randomDamage = random [_randomDamageMin, _dmgPerHitPointEven, _randomDamageMax];

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

                                        private _vehCritical = false;
                                        private _deadHitPointCount = 0;

                                        {
                                            if ((_x select 0) != "HitHull" && {(_x select 0) != "HitFuel"}) then {
                                                if ((_x select 1) == 1) then {_deadHitPointCount = _deadHitPointCount + 1};
                                            } else {
                                                if ((_x select 1) > 0.85) then {_vehCritical = true}; // HitHull, HitFuel damage of > 0.90 causes most vehicles to explode upon spawn
                                            };
                                        } foreach _profileToAttackHealth;

                                        if (
                                            _deadHitPointCount < floor (_hitPointCount * 0.85)
                                            &&
                                            {_deadHitPointCount < floor (_hitPointCount * 0.75) && {!_vehCritical}}
                                        ) then {
                                            [_targetToAttack,"damage", _profileToAttackHealth] call ALiVE_fnc_hashSet;
                                        } else {
                                            _toBeUnassigned pushbackunique [_target,_targetToAttack];
                                            _toBeKilled pushbackunique [_attacker,_targetToAttack];
                                            _targetsToAttack deleteAt 0;

                                            // if this vehicle is the last vehicles it's commanding entity controls
                                            // kill the commanding entity as well

                                            {
                                                private _entityInCommandOf = [MOD(profileHandler),"getProfile", _x] call ALiVE_fnc_profileHandler;
                                                private _assignedVehicles = [_entityInCommandOf,"vehiclesInCommandOf"] call ALiVE_fnc_hashGet;

                                                if (_assignedVehicles isEqualTo [_targetToAttackID]) then {
                                                    _toBeKilled pushbackunique [_attacker, [MOD(profileHandler),"getProfile", _x] call ALiVE_fnc_profileHandler];
                                                };
                                            } foreach ([_targetToAttack,"entitiesInCommandOf"] call ALiVE_fnc_hashGet);
                                        };
                                    };
                                };

                                // combat simulation over

                                if !(_targetsToAttack isEqualTo []) then {
                                    _active = true;
                                };
                            };
                        };
                    } else {
                        // all targets are spawned
                        // don't end attack
                        // but don't simulate it either
                        //_active = true;
                    };
                };

            } else {
                // attacker is spawned
                // don't end attack
                // but don't simulate it either
                //_active = true;
            };
        };
    };

    if (!_active) then {
        _attacksToRemove pushback _attack;

        if !(isnil "_attacker") then {
            [_attacker,"combat", false] call ALiVE_fnc_hashSet;
            [_attacker,"attackID", nil] call ALiVE_fnc_hashSet;
        };
    };
} foreach (_profileAttacks select 2);

//[false, "ALiVE Profile Attack Simulation ending", format["profileClash_%1",_id]] call ALIVE_fnc_timer;

{
     _x params ["_commandingEntity","_subordinateVehicle"];

    // remove crew from commanding entity

    private _vehAssignments = [_commandingEntity,"vehicleAssignments"] call ALiVE_fnc_hashGet;
    private _vehicleID = _subordinateVehicle select 2 select 4;

    private _vehAssignment = [_vehAssignments,_vehicleID] call ALiVE_fnc_hashGet;
    private _unitAssignments = + (_vehAssignment select 2);

    reverse _unitAssignments; // must remove in reverse order

    {
        {
            [_commandingEntity,"removeUnit", _x] call ALiVE_fnc_profileEntity
        } foreach _x;
    } foreach _unitAssignments;

    // unassign vehicle from entity

    _x call ALIVE_fnc_removeProfileVehicleAssignment;
} foreach _toBeUnassigned;

//[true, "ALiVE Profile Battle Cleanup starting", format["profileClean_%1",_id]] call ALIVE_fnc_timer;
{
    _x params ["_killer","_victim"];

    private _victimType = _victim select 2 select 5;

    if (_victimType == "entity") then {
        private _victimPos = _victim select 2 select 2;
        private _victimFaction = _victim select 2 select 29;
        private _victimSide = _victim select 2 select 3;

        private _killerSide = _killer select 2 select 3;

        // log event

        private _event = ['PROFILE_KILLED', [_victimPos,_victimFaction,_victimSide,_killerSide],"Profile"] call ALIVE_fnc_event;
       [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
    };

    [MOD(profileHandler), "unregisterProfile", _victim] call ALiVE_fnc_profileHandler;

} foreach _toBekilled;
//[false, "ALiVE Profile Combat Cleanup ending", format["profileClean_%1",_id]] call ALIVE_fnc_timer;

// attacks must be removed killed profiles have been unregistered

[MOD(profileCombatHandler),"removeAttacks", _attacksToRemove] call ALiVE_fnc_profileCombatHandler;


//["ALiVE Profile Simulation - Time taken per profile %1 (%2)",(time - _time) / _totalEntities, _totalEntities] call ALiVE_fnc_DumpR;
//[false, "ALiVE Profile Simulation end!", format["profileSimTotal_%1",_id]] call ALIVE_fnc_timer;
