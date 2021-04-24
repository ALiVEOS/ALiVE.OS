#include "\x\ALiVE\addons\sys_profile\script_component.hpp"
SCRIPT(profileSimulator);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_profileSimulator

Description:
Simulates profile movement and combat

Notes:
    - Simulate up to 4 profiles per frame
    - Once all profiles have been simulated once, simulation will shift to profile attacks
    - Simulate up to 3 attacks per frame
    - Once all profile attacks have been simulated once, simulation will shift back to profile movement

    - Each profile and attack will store it's time of last simulation
    - To simulate profiles regardless of time passed between simulations, subtract the time of last simulation from the current time
      Multiply the resulting value by any anything that relates to time, such as distance moved or damage dealt

Parameters:

Returns:

Examples:
(begin example)
[] call ALiVE_fnc_profileSimulator;
(end)

See Also:
profileHandler
profileCombatHandler
profileAttack

Author:
ARJay
Highhead
SpyderBlack723
---------------------------------------------------------------------------- */

if (ALiVE_gamePaused) exitwith {
    private _profiles = [MOD(profileHandler),"profiles"] call ALiVE_fnc_hashGet;
    {[_x,"timeLastSim", diag_tickTime] call ALiVE_fnc_hashSet} foreach (_profiles select 2);
};

// parse CBA perFrameHandler arguments
//_this = _this select 0;


private _debug = [MOD(profileSystem),"debug"] call ALiVE_fnc_hashGet;
private _profileSystemPaused = [MOD(profileSystem),"paused"] call ALiVE_fnc_hashGet;

private _combatRange = [MOD(profileCombatHandler),"combatRange"] call ALiVE_fnc_hashGet;
private _profilesToSim = [MOD(profileSystem),"profilesToSim"] call ALiVE_fnc_hashGet;
private _simAttacks = [MOD(profileSystem),"simulatingAttacks"] call ALiVE_fnc_hashGet;

if (_profilesToSim isEqualTo []) then {
    private _profilesByType = [MOD(profileHandler),"profilesByType"] call ALiVE_fnc_hashGet;
    private _entities = [_profilesByType,"entity"] call ALiVE_fnc_hashGet;
    _profilesToSim append _entities;

    _simAttacks = true;
    [MOD(profileSystem),"simulatingAttacks", true] call ALiVE_fnc_hashSet;

};

if (!_simAttacks) then {

    private _speedModifier = [MOD(profileSystem),"speedModifier", 1] call ALiVE_fnc_HashGet;
    private _boatsEnabled = [MOD(profileSystem),"seaTransport", false] call ALiVE_fnc_HashGet;

    // find profile to sim
    // sim up to 4 profiles per frame

    for "_i" from 0 to 3 do {

        if (_profilesToSim isEqualTo []) exitwith {};

        private "_profile";

        while {isnil "_profile" && !(_profilesToSim isEqualTo [])} do {
            _profile = [MOD(profileHandler),"getProfile", _profilesToSim select 0] call ALiVE_fnc_profileHandler;
            _profilesToSim deleteat 0;
        };

        if (!isnil "_profile") then {

            if (!_profileSystemPaused && !ALiVE_gamePaused) then {
                // begin sim

                private _locked = [_profile,"locked", false] call ALiVE_fnc_HashGet;
                private _combat = [_profile,"combat", false] call ALiVE_fnc_HashGet;

                // only sim if profile is not locked or in combat
                // locked entities could be spawning/despawning or other

                if (!_locked && !_combat) then {

                    private _timeLastSim = [_profile,"timeLastSim", diag_tickTime - 0.001] call ALiVE_fnc_hashGet;
                    private _simModifier = diag_tickTime - _timeLastSim;

                    // gather info on this profile

                    private _profilePosition = _profile select 2 select 2;
                    private _isPlayer = _profile select 2 select 30;

                    // determine if entity occupies a vehicle
                    private _vehiclesInCommandOf = _profile select 2 select 8;
                    private _vehiclesInCargoOf = _profile select 2 select 9;

                    private _vehicleCommander = false;
                    private _isAir = false;

                    if !(_vehiclesInCommandOf isEqualTo []) then {
                        _vehicleCommander = true;

                        // determine if vehicles is a moving air unit
                        {
                            private _vehicle = [MOD(ProfileHandler),"getProfile", _x] call ALiVE_fnc_ProfileHandler;

                            // if engineOn and vehicleClass is air vehicle
                            if (!isnil "_vehicle" && {(_vehicle select 2 select 15)} && {(_vehicle select 2 select 11) isKindOf "Air"}) then {
                                _isAir = true;
                            };
                        } foreach _vehiclesInCommandOf;
                    };

                    // determine if entity is cargo of vehicle

                    private _vehicleCargo = false;
                    if !(_vehiclesInCargoOf isEqualTo []) then {
                        _vehicleCargo = true;
                    };


                    // check for combat opportunities
                    if (!_vehicleCargo && !_isPlayer && !_isAir && !_combat) then {
                        // get enemy sides
                        private _side = _profile select 2 select 3;
                        private _sideObj = [_side] call ALiVE_fnc_sideTextToObject;
                        private _sidesEnemy = [];
                        if (_sideObj getfriend east < 0.6) then {_sidesEnemy pushback "EAST"};
                        if (_sideObj getfriend west < 0.6) then {_sidesEnemy pushback "WEST"};
                        if (_sideObj getfriend resistance < 0.6) then {_sidesEnemy pushback "GUER"};

                        // find and attack enemy profiles in-range
                        // only attack non-player, inactive entities

                        private _nearEnemies = [_profilePosition, _combatRange, [_sidesEnemy,"entity","none", {!(_x select 2 select 1) && !(_x select 2 select 30)}], true] call ALiVE_fnc_getNearProfiles;
                        _nearEnemies = _nearEnemies apply {_x select 2 select 4};

                        if !(_nearEnemies isEqualTo []) then {

                            private _profileID = _profile select 2 select 4;

                            private _profileAttack = [nil,"create", [_profilePosition,_profileID,_nearEnemies,_side]] call ALiVE_fnc_profileAttack;
                            private _attackID = [MOD(profileCombatHandler),"addAttack", _profileAttack] call ALiVE_fnc_profileCombatHandler;

                            if (!isnil "_attackID") then {
                                //["%1 begins attacking %2", _profileID, _nearEnemies] call ALiVE_fnc_Dump;
                                _combat = true;
                                [_profile,"combat", true] call ALiVE_fnc_HashSet;
                                [_profile,"attackID", _attackID] call ALiVE_fnc_HashSet;
                            };
                        };
                    };


                    private _waypoints = _profile select 2 select 16;

                    if (!_isPlayer && !_vehicleCargo && !_combat) then {
                        if (!(_waypoints isEqualTo [])) then {
                            // profile has waypoints

                            private _active = _profile select 2 select 1;
                            if (!_active) then {

                                // profile is not spawned, simulate movement

                                private _activeWaypoint = _waypoints select 0;
                                private _destination = [_activeWaypoint,"position"] call ALiVE_fnc_hashGet;
                                private _completionRadius = [_activeWaypoint,"completionRadius"] call ALiVE_fnc_hashGet;
                                private _statements = [_activeWaypoint,"statements"] call ALiVE_fnc_hashGet;
                                private _distanceToWaypoint = _profilePosition distance _destination;

                                private _speedPerSecondArray = _profile select 2 select 22;
                                private _speedPerSecond = _speedPerSecondArray select 1;

                                switch ([_activeWaypoint,"speed"] call ALiVE_fnc_hashGet) do {
                                    case "LIMITED": {_speedPerSecond = _speedPerSecondArray select 0};
                                    case "NORMAL":  {_speedPerSecond = _speedPerSecondArray select 1};
                                    case "FULL":    {_speedPerSecond = _speedPerSecondArray select 2};
                                };

                                private _direction = 0;
                                private _moveDistance = _speedPerSecond * _simModifier * _speedModifier * accTime;

                                // don't overshoot waypoint
                                if (_moveDistance > _distanceToWaypoint) then {
                                    _moveDistance = _distanceToWaypoint - (random (_completionRadius * 0.7));
                                };

                                if (!isnil "_profilePosition" && {!(_profilePosition isEqualTo [])} && {!isnil "_destination"}) then {

                                    // add z-index since some profiles dont one defined
                                    if ((count _profilePosition) == 2) then {
                                        _profilePosition pushBack 0;
                                    };

                                    if ((count _destination) == 2) then {
                                        _destination pushBack 0;
                                    };

                                    private _newPosition = _profilePosition;
                                    private _executeStatements = false;
                                    private _handleWPcomplete = {};

                                    switch ([_activeWaypoint,"type"] call ALiVE_fnc_hashGet) do {
                                        case "MOVE" : {
                                            _direction = _profilePosition getDir _destination;
                                            _newPosition = _profilePosition getPos [_moveDistance, _direction];
                                            _handleWPcomplete = {};
                                        };
                                        case "CYCLE" : {
                                            _direction = _profilePosition getDir _destination;
                                            _newPosition = _profilePosition getPos [_moveDistance, _direction];
                                            _handleWPcomplete = {
                                                _waypoints append _waypointsCompleted;
                                                _waypointsCompleted = [];
                                            };
                                        };
                                    };

                                    // getPos above returns AGL
                                    if (surfaceIsWater _newPosition) then {
                                        _newPosition = ASLtoATL _newPosition;
                                    };

                                    // if distance to wp destination is within completion radius
                                    // mark waypoint as complete
                                    if (_distanceToWaypoint <= (_moveDistance * 2)) then {
                                        private _waypointComplete = true;
                                        if (count _statements > 0) then {
                                            private _waypointCondition = _statements select 0;
                                            private _waypointConditionSatisfied = call compile _waypointCondition; // TODO; Fix after https://github.com/ALiVEOS/ALiVE.OS/issues/582

                                            if (!_waypointConditionSatisfied) then { _waypointComplete = false };
                                        };

                                        if (_waypointComplete) then {
                                            private _isCycling = _profile select 2 select 25;
                                            if (_isCycling) then {
                                                private _waypointsCompleted = _profile select 2 select 17;
                                                _waypointsCompleted pushback _activeWaypoint;
                                            };

                                            _waypoints deleteat 0;

                                            call _handleWPcomplete;
                                            _executeStatements = true;
                                        };
                                    };

                                    if (_vehicleCommander) then {
                                        // move vehicles that profile is in
                                        [_profile,"hasSimulated", true] call ALiVE_fnc_hashSet;

                                        {
                                            private _vehicleProfile = [MOD(profileHandler),"getProfile", _x] call ALiVE_fnc_ProfileHandler;

                                            if (!isnil "_vehicleProfile") then {
                                                // turn engineOn virtually
                                                // move all entities within the vehicle
                                                // set the vehicle position and merge all assigned entities positions

                                                //["PROFILE SIM SIMMED ENTITY %1 IN COMMAND OF %2 SET VEHICLE POS: %3",_profile select 2 select 4,_vehicleProfile select 2 select 4,_newPosition] call ALiVE_fnc_dump;

                                                [_vehicleProfile,"hasSimulated", true] call ALiVE_fnc_hashSet;
                                                [_vehicleProfile,"engineOn", true] call ALiVE_fnc_profileVehicle;
                                                [_vehicleProfile,"position", _newPosition] call ALiVE_fnc_profileVehicle;
                                                [_vehicleProfile,"direction", _direction] call ALiVE_fnc_profileVehicle;
                                                [_vehicleProfile,"mergePositions"] call ALiVE_fnc_profileVehicle;

                                                // if profile is in boat, and is no longer on water
                                                // remove boat

                                                private _boat = [_profile,"boat"] call ALiVE_fnc_hashGet;
                                                if (_boatsEnabled && {!isnil "_boat"} && {!surfaceIsWater _profilePosition}) then {
                                                    private _boatProfileID = _boat select 0;
                                                    private _boatProfile = [MOD(profileHandler),"getProfile", _boatProfileID] call ALiVE_fnc_ProfileHandler;

                                                    if (isnil "_boatProfile") then {
                                                        if (_debug) then {["Profile Simulator _boatProfile is nil _profile is %1",_profile] call ALiVE_fnc_dumpR};
                                                    } else {
                                                        private _profileID = [_profile,"profileID", "no-ID"] call ALiVE_fnc_hashGet;
                                                        private _boatID = [_boatProfile,"profileID", "no-ID"] call ALiVE_fnc_hashGet;

                                                        if (_debug) then {["Profile Simulator is removing boat %1 from entity profile %2", _boatID, _profileID] call ALiVE_fnc_dump};

                                                        if (count _waypoints > 1) then {_waypoints deleteAt 0};

                                                        [_profile,_boatProfile] call ALiVE_fnc_removeProfileVehicleAssignment;
                                                        [MOD(profileHandler),"unregisterProfile", _boatProfile] call ALiVE_fnc_profileHandler;
                                                    };

                                                    [_profile,"boat"] call ALiVE_fnc_hashRem;
                                                };
                                            };
                                        } forEach _vehiclesInCommandOf;
                                    } else {
                                        // assign a boat to entities if on water

                                        if (_boatsEnabled && {surfaceIsWater _profilePosition} && {surfaceIsWater _newPosition}) then {
                                            if (isnil {[_profile,"boat"] call ALiVE_fnc_hashGet}) then {
                                                if (_debug) then {["Profile Simulator is adding a boat to entity profile %1",_profileID] call ALiVE_fnc_dump};

                                                private _unitPositions = _profile select 2 select 18;
                                                private _faction = [_profile, "faction"] call ALiVE_fnc_hashGet;
                                                private _side = _profile select 2 select 3;

                                                private _boatTypes = [(count _unitPositions) - 1, [_faction],"SHIP"] call ALiVE_fnc_findVehicleType;
                                                private _boatType = if (count _boatTypes > 0) then {selectRandom _boatTypes} else {"C_Boat_Transport_02_F"};

                                                private _boatProfile = [_boatType,_side,_faction,_newPosition,0,false,_faction,[]] call ALiVE_fnc_createProfileVehicle;
                                                [_profile,_boatProfile] call ALiVE_fnc_createProfileVehicleAssignment;

                                                // create waypoint to nearest shore point
                                                private _shore = [_newPosition,_destination] call ALiVE_fnc_findNearestShore;
                                                if !(_shore isEqualTo [0,0,0]) then {
                                                    private _shoreWaypoint = [_shore, 10] call ALiVE_fnc_createProfileWaypoint;
                                                    [_profile,"insertWaypoint", _shoreWaypoint] call ALiVE_fnc_profileEntity;
                                                };

                                                [_profile, "boat", [[_boatProfile,"profileID"] call ALiVE_fnc_HashGet, _newPosition]] call ALiVE_fnc_hashSet;
                                            };
                                        } else {
                                            // Remove boat if not on water anymore
                                            // failsafe, will be handled by _vehicleCommander case above

                                            private _boat = [_profile,"boat"] call ALiVE_fnc_hashGet;
                                            if (_boatsEnabled && {!isnil "_boat"}) then {
                                                private _boatProfileID = _boat select 0;
                                                private _boatProfile = [MOD(profileHandler),"getProfile", _boatProfileID] call ALiVE_fnc_ProfileHandler;

                                                if (isnil "_boatProfile") then {
                                                    if (_debug) then {["Profile Simulator _boatProfile is nil _profile is %1",_profile] call ALiVE_fnc_dumpR};
                                                } else {
                                                    private _profileID = [_profile,"profileID","no-ID"] call ALiVE_fnc_hashGet;
                                                    private _boatID = [_boatProfile,"profileID","no-ID"] call ALiVE_fnc_hashGet;

                                                    if (_debug) then {["Profile Simulator is removing boat %1 from entity profile %2",_boatID,_profileID] call ALiVE_fnc_dump};

                                                    if (count _waypoints > 1) then {_waypoints deleteAt 0};

                                                    [_profile,_boatProfile] call ALiVE_fnc_removeProfileVehicleAssignment;
                                                    [MOD(profileHandler),"unregisterProfile", _boatProfile] call ALiVE_fnc_profileHandler;
                                                };

                                                [_profile,"boat"] call ALiVE_fnc_hashRem;
                                            };
                                        };

                                        // set the profile position and merge all unit positions to group position
                                        [_profile,"hasSimulated", true] call ALiVE_fnc_hashSet;
                                        [_profile,"position", _newPosition] call ALiVE_fnc_profileEntity;
                                        [_profile,"mergePositions"] call ALiVE_fnc_profileEntity;
                                    };

                                    // Execute statements at the end, needs review of any variables in hashes
                                    if (_executeStatements) then {
                                        if((_statements isEqualType []) && {count _statements >= 2}) then {
                                            private _onCompletion = _statements select 1;
                                            call compile _onCompletion;
                                        } else {
                                            ["FIXME: Possible empty string. Content: %1",_statements] call ALiVE_fnc_dump;
                                        };
                                    };
                                } else {
                                    if (_debug) then {["Profile-Simulator profile movement stopped for profile %1: currentPosition: %2 destination: %3", [_profile,"profileID","no-ID"] call ALiVE_fnc_hashGet, _profilePosition, _destination] call ALiVE_fnc_dump};
                                };

                            } else {

                                // profile is spawned, update positions

                                private _group = _profile select 2 select 13;
                                private _leader = leader _group;
                                private _newPosition = getPosATL _leader;

                                if (!isnil "_newPosition" && {!(_newPosition isEqualTo [])} && {!isnil "_profilePosition"} && {!(_profilePosition isEqualTo [])}) then {
                                    private _activeWaypoint = _waypoints select 0;
                                    private _type = [_activeWaypoint,"type"] call ALiVE_fnc_hashGet;
                                    private _speed = [_activeWaypoint,"speed"] call ALiVE_fnc_hashGet;
                                    private _destination = [_activeWaypoint,"position"] call ALiVE_fnc_hashGet;

                                    private _moveDistance = _newPosition distance _profilePosition;
                                    private _nearDestination = _newPosition distance _destination < 100;

                                    // handle waypoint completion

                                    if (_moveDistance > 10 || {_nearDestination}) then {
                                        if (_vehicleCommander) then {

                                            // move all entities within the vehicle
                                            // set the vehicle position and merge all assigned entities positions

                                            _newPosition = getPosATL vehicle _leader;

                                            {
                                                private _vehicleProfile = [MOD(profileHandler),"getProfile", _x] call ALiVE_fnc_ProfileHandler;

                                                if (!isnil "_vehicleProfile") then {
                                                    [_vehicleProfile,"position", _newPosition] call ALiVE_fnc_profileVehicle;
                                                    [_vehicleProfile,"mergePositions"] call ALiVE_fnc_profileVehicle;
                                                };
                                            } forEach _vehiclesInCommandOf;

                                            // remove any boat if not on water anymore
                                            // if (_boatsEnabled && {_shallow} && {!isnil {[_profile,"boat"] call ALiVE_fnc_hashGet}} && {!(([_newPosition,0,50,0,0,0.5,1,[],[[0,0,0]]] call BIS_fnc_findSafePos) isEqualto [0,0,0])}) then {...};

                                            private _boat = [_profile,"boat"] call ALiVE_fnc_hashGet;
                                            if (_boatsEnabled && {((_newPosition) select 2) < 4} && {_nearDestination} && {!isnil "_boat"}) then {
                                                private _boatProfileID = _boat select 0;
                                                private _creation = ([_profile,"boat"] call ALiVE_fnc_hashGet) select 1;
                                                private _boatProfile = [MOD(profileHandler),"getProfile", _boatProfileID] call ALiVE_fnc_ProfileHandler;

                                                if (isnil "_boatProfile") then {
                                                    if (_debug) then {["Profile Simulator _boatProfile is nil _profile is %1",_profile] call ALiVE_fnc_dumpR};
                                                } else {
                                                    if (_newPosition distance _creation > 100) then {
                                                        private _profileID = [_profile,"profileID", "no-ID"] call ALiVE_fnc_hashGet;

                                                        if (_debug) then {["Profile Simulator is removing boat %1 from entity profile %2 (LIVE)",_boatProfileID,_profileID] call ALiVE_fnc_dump};

                                                        [MOD(SYS_GC),"trashIt", vehicle _leader] call ALiVE_fnc_GC;

                                                        [_profile,_boatProfile] call ALiVE_fnc_removeProfileVehicleAssignment;
                                                        [MOD(profileHandler),"unregisterProfile", _boatProfile] call ALiVE_fnc_profileHandler;

                                                        if (count _waypoints > 1) then {
                                                            _waypoints deleteAt 0;
                                                            [_waypoints, _group] call ALiVE_fnc_profileWaypointsToWaypoints;
                                                        };
                                                    };
                                                };

                                                [_profile,"boat"] call ALiVE_fnc_hashRem;
                                            };

                                        } else {

                                            private _deepEnough = ((ATLtoASL _newPosition) select 2) < 1 && {(_newPosition select 2) > 4};

                                            // Assign a boat to entities if on water
                                            if (_boatsEnabled && {surfaceIsWater _profilePosition} && {surfaceIsWater _newPosition} && {_deepEnough} && {[_position,_destination] call ALiVE_fnc_crossesSea}) then {
                                                if (isnil {[_profile,"boat"] call ALiVE_fnc_hashGet}) then {

                                                    if (_debug) then {["Profile Simulator is adding a boat to entity profile (LIVE) %1",_profileID] call ALiVE_fnc_dump};

                                                    private _unitPositions = _profile select 2 select 18;
                                                    private _faction = [_profile, "faction"] call ALiVE_fnc_hashGet;
                                                    private _side = _profile select 2 select 3;

                                                    private _boatTypes = [(count _unitPositions) - 1, [_faction],"SHIP"] call ALiVE_fnc_findVehicleType;
                                                    private _boatType = if (count _boatTypes > 0) then {selectRandom _boatTypes} else {"C_Boat_Transport_02_F"};

                                                    private _boatProfile = [_boatType,_side,_faction,_newPosition,0,false,_faction,[]] call ALiVE_fnc_createProfileVehicle;
                                                    [_profile,_boatProfile] call ALiVE_fnc_createProfileVehicleAssignment;

                                                    private _vehicleAssignments = [_profile,"vehicleAssignments"] call ALiVE_fnc_hashGet;
                                                    [_vehicleAssignments,_profile, true] call ALiVE_fnc_profileVehicleAssignmentsToVehicleAssignments;

                                                    // create waypoint to nearest shore point
                                                    private _shore = [_newPosition,_destination] call ALiVE_fnc_findNearestShore;
                                                    if !(_shore isEqualTo [0,0,0]) then {
                                                        private _shoreWaypoint = [_shore, 10] call ALiVE_fnc_createProfileWaypoint;
                                                        [_profile,"insertWaypoint", _shoreWaypoint] call ALiVE_fnc_profileEntity;
                                                    };

                                                    [_profile,"boat", [[_boatProfile,"profileID"] call ALiVE_fnc_HashGet, _newPosition]] call ALiVE_fnc_hashSet;
                                                };
                                            };

                                            // set the entity position and merge all unit positions to group position
                                            [_profile,"position", _newPosition] call ALiVE_fnc_profileEntity;
                                            [_profile,"mergePositions"] call ALiVE_fnc_profileEntity;

                                        };
                                    };
                                } else {
                                    if (_debug) then {["Profile-Simulator corrupted spawned profile detected %1: _newPosition %2 _position %3",_profileID,_newPosition,_position] call ALiVE_fnc_dump};
                                };

                            };
                        } else {
                            // profile has no waypoints

                            private _active = _profile select 2 select 1;
                            if (_active) then {
                                private _group = _profile select 2 select 13;
                                private _leader = _profile select 2 select 10;
                                private _currentWaypoint = currentWaypoint _group;

                                if ((_currentWaypoint < count waypoints _group) && (_currentWaypoint > 0)) then {
                                    _leader = leader _group;
                                    private _newPosition = getPosATL _leader;

                                    if (!isnil "_newPosition" && {!(_newPosition isEqualTo [])} && {!isnil "_profilePosition"} && {!(_profilePosition isEqualTo [])}) then {
                                        private _moveDistance = _newPosition distance _profilePosition;

                                        if (_moveDistance > 10) then {
                                            if (_vehicleCommander) then {
                                                // if in command of vehicle move all entities within the vehicle
                                                // set the vehicle position and merge all assigned entities positions

                                                _newPosition = getPosATL vehicle _leader;

                                                {
                                                    private _vehicleProfile = [MOD(profileHandler),"getProfile", _x] call ALiVE_fnc_ProfileHandler;
                                                    if (!isnil "_vehicleProfile") then {
                                                        [_vehicleProfile,"position", _newPosition] call ALiVE_fnc_profileVehicle;
                                                        [_vehicleProfile,"mergePositions"] call ALiVE_fnc_profileVehicle;
                                                    };
                                                } forEach _vehiclesInCommandOf;
                                            } else {
                                                // set the entity position and merge all unit positions to group position
                                                [_profile,"position", _newPosition] call ALiVE_fnc_profileEntity;
                                                [_profile,"mergePositions"] call ALiVE_fnc_profileEntity;
                                            };
                                        };
                                    } else {
                                        if (_debug) then {["Profile-Simulator corrupted profile detected %1: _newPosition %2 _profilePosition %3",_profileID,_newPosition,_profilePosition] call ALiVE_fnc_dump};
                                    };
                                };
                            };

                            // remove any ambient sea transport if no waypoint is assigned (should not happen - failsafe)
                            if (_boatsEnabled && {_vehicleCommander} && {!isnil {[_profile,"boat"] call ALiVE_fnc_hashGet}}) then {
                                private _boatProfileID = ([_profile,"boat"] call ALiVE_fnc_hashGet) select 0;
                                private _boatProfile = [ALiVE_ProfileHandler,"getProfile",_boatProfileID] call ALiVE_fnc_ProfileHandler;

                                if (isnil "_boatProfile") then {
                                    ["Profile Simulator _boatProfile is nil _profile is %1",_profile] call ALiVE_fnc_dumpR;
                                } else {
                                    private _profileID = [_profile,"profileID","no-ID"] call ALiVE_fnc_hashGet;

                                    if (_debug) then {["Profile Simulator is removing boat %1 from entity profile %2",_boatProfileID,_profileID] call ALiVE_fnc_dump};

                                    [_profile,_boatProfile] call ALiVE_fnc_removeProfileVehicleAssignment;

                                    [MOD(profileHandler),"unregisterProfile", _boatProfile] call ALiVE_fnc_profileHandler;
                                };

                                [_profile,"boat"] call ALiVE_fnc_hashRem;
                            };
                        };
                    };

                    if (_isPlayer) then {
                        private _leader = _profile select 2 select 10;
                        private _newPosition = getPosATL _leader;

                        // verify that position is valid

                        if (!isnil "_newPosition" && {str _newPosition != "[0,0,0]"} && {!isnil "_profilePosition"} && {str _profilePosition != "[0,0,0]"}) then {
                            private _moveDistance = _newPosition distance _profilePosition;

                            if (_moveDistance > 10) then {
                                if (_vehicleCommander) then {
                                    // if in command of vehicle move all entities within the vehicle
                                    // set the vehicle position and merge all assigned entities positions

                                    //_leader = _profile select 2 select 10; //_leader = [_profile,"leader"] call ALiVE_fnc_hashGet;
                                    _newPosition = getPosATL vehicle _leader;

                                    {
                                        private _vehicleProfile = [MOD(profileHandler),"getProfile", _x] call ALiVE_fnc_ProfileHandler;
                                        if (!isnil "_vehicleProfile") then {
                                            [_vehicleProfile,"position", _newPosition] call ALiVE_fnc_profileVehicle;
                                            [_vehicleProfile,"mergePositions"] call ALiVE_fnc_profileVehicle;
                                        };
                                    } forEach _vehiclesInCommandOf;
                                } else {
                                    _newPosition = getPosATL _leader;

                                    // set the entity position and merge all unit positions to group position
                                    [_profile,"position", _newPosition] call ALiVE_fnc_profileEntity;
                                    [_profile,"mergePositions"] call ALiVE_fnc_profileEntity;
                                };
                            };
                        } else {
                            // position is invalid
                            // (due to missing player object or corrupted profile)

                            ["DISCONNECT"] call ALiVE_fnc_createProfilesFromPlayers;
                        };
                    };
                };

            };

            [_profile,"timeLastSim", diag_tickTime] call ALiVE_fnc_hashSet;
        };
    };

} else {

    // Simulate attacks

    private _combatRate = [MOD(profileCombatHandler),"combatRate"] call ALiVE_fnc_hashGet;
    private _attacksToSim = [MOD(profileSystem),"profileAttacksToSim"] call ALiVE_fnc_hashGet;

    if (_attacksToSim isEqualTo []) then {

        private _profileAttacks = [MOD(profileCombatHandler),"attacksByID"] call ALiVE_fnc_hashGet;
        _attacksToSim append (_profileAttacks select 1);

        [MOD(profileSystem),"simulatingAttacks", false] call ALiVE_fnc_hashSet;

    } else {

        private _attacksToRemove = [];
        private _toBeUnassigned = [];
        private _toBeKilled = [];

        // sim 3 attack per frame
        for "_i" from 0 to 2 do {
            if (_attacksToSim isEqualTo []) exitwith {};

            private ["_attacker"];

            private _attackID = _attacksToSim select 0;
            private _attack = [MOD(profileCombatHandler),"getAttack", _attackID] call ALiVE_fnc_profileCombatHandler;
            _attacksToSim deleteat 0;

            if (!isnil "_attack") then {

                if (!_profileSystemPaused && !ALiVE_gamePaused) then {

                    private _cyclesLeft = [_attack,"cyclesLeft"] call ALiVE_fnc_hashGet;
                    private _timeLastSim = [_attack,"timeLastSim", diag_tickTime - 0.001] call ALiVE_fnc_hashGet;
                    private _simModifier = (diag_tickTime - _timeLastSim) * accTime;

                    private _active = false;

                    if (_cyclesLeft > 0) then {
                        [_attack,"cyclesLeft", _cyclesLeft - 1] call ALiVE_fnc_hashSet;

                        private _attackerID = [_attack,"attacker"] call ALiVE_fnc_hashGet;
                        private _targetIDs = [_attack,"targets"] call ALiVE_fnc_hashGet;

                        _attacker = [MOD(profileHandler),"getProfile", _attackerID] call ALiVE_fnc_profileHandler;

                        if (!isnil "_attacker") then {
                            private "_target";
                            while {isnil "_target" && !(_targetIDs isEqualTo [])} do {
                                _target = [MOD(profileHandler),"getProfile", _targetIDs select 0] call ALiVE_fnc_profileHandler;

                                // if target is active, remove it
                                if (isnil "_target" || {_target select 2 select 1}) then {
                                    _targetIDs deleteat 0;
                                    _target = nil;
                                };
                            };

                            if (!isnil "_target") then {
                                private _attackerPos = _attacker select 2 select 2;                     // [_attacker,"position"] call ALiVE_fnc_hashGet;
                                private _targetPos = _target select 2 select 2;                         // [_target,"position"] call ALiVE_fnc_hashGet;

                                private _maxEngagementRange = [_attack,"maxRange"] call ALiVE_fnc_hashGet;

                                if (_attackerPos distance2D _targetPos <= _maxEngagementRange) then {
                                    // get profiles to attack with
                                    // vehicles entity commands, or just the entity

                                    private _profilesToAttackWith = [];
                                    private _attackerVehiclesInCommandOf = _attacker select 2 select 8;

                                    {
                                        private _vehicleUnderCommand = [MOD(profileHandler),"getProfile", _x] call ALiVE_fnc_profileHandler;

                                        if (!isnil "_vehicleUnderCommand") then {
                                            _profilesToAttackWith pushback _vehicleUnderCommand;
                                        };
                                    } foreach _attackerVehiclesInCommandOf;

                                    // entity shouldn't attack separately if it's inside vehicle(s)
                                    if (_profilesToAttackWith isEqualTo []) then {
                                        _profilesToAttackWith pushback _attacker;
                                    };

                                    // get targets to attack

                                    private _targetsToAttack = [];
                                    private _targetVehiclesInCommandOf = _target select 2 select 8;

                                    {
                                        private _targetToAttack = [MOD(profileHandler),"getProfile", _x] call ALiVE_fnc_profileHandler;

                                        if (!isnil "_targetToAttack") then {
                                            _targetsToAttack pushback _targetToAttack;
                                        };
                                    } foreach _targetVehiclesInCommandOf;

                                    // entity shouldn't be attacked separately if it's in a vehicle
                                    if (_targetsToAttack isEqualTo []) then {
                                        _targetsToAttack pushback _target;
                                    } else {
                                        reverse _targetsToAttack; // destroy vehicles in reverse order to avoid corrupting unit assignment indexes
                                    };

                                    if !(_targetsToAttack isEqualTo []) then {
                                        // attack each target profile individually
                                        // if vehicle is destroyed, unassigned it from it's entity

                                        private _targetToAttack = _targetsToAttack select 0;
                                        private _targetToAttackID = _targetToAttack select 2 select 4;
                                        private _targetToAttackType = _targetToAttack select 2 select 5;

                                        private _profileToAttackHealth = [];

                                        if (_targetToAttackType == "entity") then {
                                            // must be copied so that calling "removeUnit" doesn't alter the new damage array
                                            _profileToAttackHealth = +([_targetToAttack,"damages"] call ALiVE_fnc_hashGet);
                                        } else {
                                            _profileToAttackHealth = [_targetToAttack,"damage"] call ALiVE_fnc_hashGet;

                                            // if vehicle hasn't been spawned yet
                                            // init hitpoint values

                                            if (_profileToAttackHealth isEqualTo []) then {
                                                private _vehicleClass = _targetToAttack select 2 select 11;
                                                private _totalHitpoints = _vehicleClass call ALiVE_fnc_configGetVehicleHitPoints;

                                                if (_totalHitpoints isEqualTo []) then {
                                                    private _hp = [(configfile >> "CfgVehicles" >> _vehicleClass >> "HitPoints"),0] call BIS_fnc_returnChildren;
                                                    {_totalHitpoints pushBack (configName _x)} forEach _hp;
                                                };

                                                {_profileToAttackHealth pushback [_x,0]} foreach _totalHitpoints;
                                            };
                                        };

                                        // get total damage that can be dealt this turn
                                        // damage is calculated from each vehicle the entity controls
                                        // if entity controls no vehicles, the entity itself attacks

                                        private _damageToInflict = 0;
                                        {
                                            _damageToInflict = _damageToInflict + (([_x,_targetToAttack] call ALiVE_fnc_profileGetDamageOutput) * _combatRate * _simModifier);
                                        } foreach _profilesToAttackWith;

                                        if (_damageToInflict > 0) then {
                                            private _damageToInflictLeft = _damageToInflict;

                                            if (_targetToAttackType == "entity") then {
                                                // attacking entity
                                                // spread damage randomly over units

                                                private _unitCount = count _profileToAttackHealth;

                                                if (_unitCount > 0) then {
                                                    private _dmgPerUnitEven = _damageToInflict / _unitCount;

                                                    private _randomDamageMin = _dmgPerUnitEven / 2;
                                                    private _randomDamageMax = _dmgPerUnitEven * 8;

                                                    private _indexesToRemove = [];

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
                                                        _unitCount = _unitCount - 1;
                                                    } foreach _indexesToRemove;

                                                    [_targetToAttack,"damages", _profileToAttackHealth] call ALiVE_fnc_hashSet;

                                                    if (_unitCount == 0) then {
                                                        _toBeKilled pushbackunique [_attacker,_targetToAttack];
                                                        _targetsToAttack deleteAt 0;

                                                        private _attackTargetsKilled = _attack select 2 select 9;
                                                        _attackTargetsKilled pushback (_targetToAttack select 2 select 4);
                                                    };
                                                } else {
                                                    _toBeKilled pushbackunique [_attacker,_targetToAttack];
                                                    _targetsToAttack deleteAt 0;

                                                    private _attackTargetsKilled = _attack select 2 select 9;
                                                    _attackTargetsKilled pushback (_targetToAttack select 2 select 4);
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

                                                    private _randomHitPointNme = _randomHitPoint select 0;
                                                    private _randomHitPointDmg = _randomHitPoint select 1;

                                                    // HitFuel can lead to rapid explosions on spawn
                                                    // if damaged at all
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
                                                        // HitHull, HitFuel damage of > 0.90 causes most vehicles to explode upon spawn
                                                        if ((_x select 1) > 0.85) then {_vehCritical = true};
                                                    };
                                                } foreach _profileToAttackHealth;

                                                if (_deadHitPointCount < floor (_hitPointCount * 0.75) && !_vehCritical) then {
                                                    [_targetToAttack,"damage", _profileToAttackHealth] call ALiVE_fnc_hashSet;
                                                } else {
                                                    _toBeUnassigned pushbackunique [_target,_targetToAttack];
                                                    _toBeKilled pushbackunique [_attacker,_targetToAttack];
                                                    _targetsToAttack deleteAt 0;

                                                    private _attackTargetsKilled = _attack select 2 select 9;
                                                    _attackTargetsKilled pushback (_targetToAttack select 2 select 4);

                                                    // if this vehicle is the last vehicle it's commanding entity controls
                                                    // kill the commanding entity as well

                                                    {
                                                        private _entityInCommandOf = [MOD(profileHandler),"getProfile", _x] call ALiVE_fnc_profileHandler;
                                                        private _assignedVehicles = _entityInCommandOf select 2 select 8;

                                                        if (_assignedVehicles isEqualTo [_targetToAttackID]) then {
                                                            _toBeKilled pushbackunique [_attacker, [MOD(profileHandler),"getProfile", _x] call ALiVE_fnc_profileHandler];
                                                            
                                                            _attackTargetsKilled pushback _x;
                                                        };
                                                    } foreach ([_targetToAttack,"entitiesInCommandOf"] call ALiVE_fnc_hashGet);
                                                };
                                            };
                                        };

                                        // combat simulation over
                                        // end attack if no targets remain

                                        if !(_targetsToAttack isEqualTo []) then {
                                            _active = true;
                                        };
                                    };
                                };
                            };
                        };
                    };

                    if (!_active) then {
                        _attacksToRemove pushback _attackID;

                        if (!isnil "_attacker") then {
                            [_attacker,"combat", false] call ALiVE_fnc_hashSet;
                        };
                    };

                };

                [_attack,"timeLastSim", diag_tickTime] call ALiVE_fnc_hashSet;
            };
        };

        {
            private _commandingEntity = _x select 0;
            private _subordinateVehicle = _x select 1;

            // remove crew from commanding entity

            private _vehAssignments = _commandingEntity select 2 select 7;

            if (count (_vehAssignments select 1) > 0) then {
                private _vehicleID = _subordinateVehicle select 2 select 4;

                private _vehAssignment = [_vehAssignments,_vehicleID] call ALiVE_fnc_hashGet;
                private _unitAssignments = +(_vehAssignment param [2, [], [[]]]);

                reverse _unitAssignments; // must remove in reverse order

                {
                    {
                        [_commandingEntity,"removeUnit", _x] call ALiVE_fnc_profileEntity
                    } foreach _x;
                } foreach _unitAssignments;
            } else {
                diag_log "FIXME: _vehAssignments is empty while we expect it not to be?!";
            };

            // unassign vehicle from entity
            _x call ALiVE_fnc_removeProfileVehicleAssignment;
        } foreach _toBeUnassigned;

        {
            private _killer = _x select 0;
            private _victim = _x select 1;

            private _victimType = _victim select 2 select 5;

            if (_victimType == "entity") then {
                private _victimPos = _victim select 2 select 2;
                private _victimFaction = _victim select 2 select 29;
                private _victimSide = _victim select 2 select 3;

                private _killerSide = _killer select 2 select 3;

                // log event

                private _event = ['PROFILE_KILLED', [_victimPos,_victimFaction,_victimSide,_killerSide],"Profile"] call ALiVE_fnc_event;
               [MOD(eventLog),"addEvent",_event] call ALiVE_fnc_eventLog;
            };

            [MOD(profileHandler),"unregisterProfile", _victim] call ALiVE_fnc_profileHandler;
        } foreach _toBekilled;

        if !(_attacksToRemove isEqualTo []) then {
            [MOD(profileCombatHandler),"removeAttacks", _attacksToRemove] call ALiVE_fnc_profileCombatHandler;
        };

    };

};
