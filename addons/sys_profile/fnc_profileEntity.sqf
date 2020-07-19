#include "\x\alive\addons\sys_profile\script_component.hpp"
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

TRACE_1("profileEntity - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

private _result = true;

#define MTEMPLATE "ALiVE_PROFILEENTITY_%1"

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
            [_logic,"type","entity"] call ALIVE_fnc_hashSet;            // select 2 select 5
            [_logic,"vehiclesInCommandOf",[]] call ALIVE_fnc_hashSet;   // select 2 select 8
            [_logic,"vehiclesInCargoOf",[]] call ALIVE_fnc_hashSet;     // select 2 select 9
            [_logic,"leader",objNull] call ALIVE_fnc_hashSet;           // select 2 select 10
            [_logic,"unitClasses",[]] call ALIVE_fnc_hashSet;           // select 2 select 11
            [_logic,"unitCount",0] call ALIVE_fnc_hashSet;              // select 2 select 12
            [_logic,"group",grpNull] call ALIVE_fnc_hashSet;            // select 2 select 13
            [_logic,"companyID",""] call ALIVE_fnc_hashSet;             // select 2 select 14
            [_logic,"groupID",""] call ALIVE_fnc_hashSet;               // select 2 select 15
            [_logic,"waypoints",[]] call ALIVE_fnc_hashSet;             // select 2 select 16
            [_logic,"waypointsCompleted",[]] call ALIVE_fnc_hashSet;    // select 2 select 17
            [_logic,"positions",[]] call ALIVE_fnc_hashSet;             // select 2 select 18
            [_logic,"damages",[]] call ALIVE_fnc_hashSet;               // select 2 select 19
            [_logic,"ranks",[]] call ALIVE_fnc_hashSet;                 // select 2 select 20
            [_logic,"units",[]] call ALIVE_fnc_hashSet;                 // select 2 select 21
            [_logic,"speedPerSecond","Man" call ALIVE_fnc_vehicleGetSpeedPerSecond] call ALIVE_fnc_hashSet; // select 2 select 22
            [_logic,"despawnPosition",[0,0]] call ALIVE_fnc_hashSet;    // select 2 select 23
            [_logic,"hasSimulated",false] call ALIVE_fnc_hashSet;       // select 2 select 24
            [_logic,"isCycling",false] call ALIVE_fnc_hashSet;          // select 2 select 25
            [_logic,"activeCommands",[]] call ALIVE_fnc_hashSet;        // select 2 select 26
            [_logic,"inactiveCommands",[]] call ALIVE_fnc_hashSet;      // select 2 select 27
            [_logic,"spawnType",[]] call ALIVE_fnc_hashSet;             // select 2 select 28
            [_logic,"faction",[]] call ALIVE_fnc_hashSet;               // select 2 select 29
            [_logic,"isPlayer",false] call ALIVE_fnc_hashSet;           // select 2 select 30
            [_logic,"_rev",""] call ALIVE_fnc_hashSet;                  // select 2 select 31
            [_logic,"_id",""] call ALIVE_fnc_hashSet;                   // select 2 select 32
            [_logic,"busy",false] call ALIVE_fnc_hashSet;               // select 2 select 33
            [_logic,"pendingWaypointPaths", []] call ALiVE_fnc_hashSet;; // select 2 select 34;
        };

        /*
        VIEW - purely visual
        */

        /*
        CONTROLLER  - coordination
        */
    };

    case "debug": {
        if (_args isEqualType true) then {
            [_logic,"debug", _args] call ALIVE_fnc_hashSet;
        } else {
            _result = [_logic,"debug"] call ALIVE_fnc_hashGet;
        };

        [_logic,"deleteMarkers"] call MAINCLASS;

        if (_args) then {
            [_logic,"createMarkers"] call MAINCLASS;
        };
    };

    case "active": {
        if (_args isEqualType true) then {
            [_logic,"active", _args] call ALIVE_fnc_hashSet;
        } else {
            _result = [_logic,"active"] call ALIVE_fnc_hashGet;
        };
    };

    case "profileID": {
        if (_args isEqualType "") then {
            [_logic,"profileID", _args] call ALIVE_fnc_hashSet;
        } else {
            _result = [_logic,"profileID"] call ALIVE_fnc_hashGet;
        };
    };

    case "side": {
        if (_args isEqualType "") then {
            [_logic,"side", _args] call ALIVE_fnc_hashSet;
        } else {
            _result = [_logic,"side"] call ALIVE_fnc_hashGet;
        };
    };

    case "faction": {
        if (_args isEqualType "") then {
            [_logic,"faction", _args] call ALIVE_fnc_hashSet;
        } else {
            _result = [_logic,"faction"] call ALIVE_fnc_hashGet;
        };
    };

    case "objectType": {
        if (_args isEqualType "") then {
            [_logic,"objectType", _args] call ALIVE_fnc_hashSet;
        } else {
            _result = [_logic,"objectType"] call ALIVE_fnc_hashGet;
        };
    };

    case "companyID": {
        if (_args isEqualType "") then {
            [_logic,"companyID", _args] call ALIVE_fnc_hashSet;
        } else {
            _result = [_logic,"companyID"] call ALIVE_fnc_hashGet;
        };
    };

    case "unitClasses": {
        if (_args isEqualType []) then {
            [_logic,"unitClasses", _args] call ALIVE_fnc_hashSet;
        } else {
            _result = [_logic,"unitClasses"] call ALIVE_fnc_hashGet;
        };
    };

    case "position": {
        if (_args isEqualType []) then {
            if (count _args == 2) then  {
                _args pushback 0;
            };

            if !(((_args select 0) + (_args select 1)) == 0) then {
                private _spacialGrid = [ALiVE_profileSystem,"spacialGridProfiles"] call ALiVE_fnc_hashGet;

                private _currPos = _logic select 2 select 2;
                [_spacialGrid,"move", [_currPos, _args, _logic]] call ALiVE_fnc_spacialGrid;

                [_logic,"position", _args] call ALIVE_fnc_hashSet;

                if([_logic,"debug"] call ALIVE_fnc_hashGet) then {
                    [_logic,"debug",true] call MAINCLASS;
                };

                //["ENTITY %1 position: %2",_logic select 2 select 4,_args] call ALIVE_fnc_dump;

                // store position on handler position index
                private _profileID = [_logic,"profileID"] call ALIVE_fnc_hashGet;
                [ALIVE_profileHandler,"setPosition", [_profileID, _args]] call ALIVE_fnc_profileHandler;
            };
        } else {
            _result = _logic select 2 select 2; //[_logic,"position"] call ALIVE_fnc_hashGet;
        };
    };

    case "despawnPosition": {
        if (_args isEqualType []) then {
            [_logic,"despawnPosition", _args] call ALIVE_fnc_hashSet;
        } else {
            _result = [_logic,"despawnPosition"] call ALIVE_fnc_hashGet;
        };
    };

    case "positions": {
        if (_args isEqualType []) then {
            [_logic,"positions", _args] call ALIVE_fnc_hashSet;
        } else {
            _result = _logic select 2 select 18; //[_logic,"positions"] call ALIVE_fnc_hashGet;
        };
    };

    case "damages": {
        if (_args isEqualType []) then {
            [_logic,"damages", _args] call ALIVE_fnc_hashSet;
        } else {
            _result = [_logic,"damages"] call ALIVE_fnc_hashGet;
        };
    };

    case "ranks": {
        if (_args isEqualType []) then {
            [_logic,"ranks", _args] call ALIVE_fnc_hashSet;
        } else {
            _result = [_logic,"ranks"] call ALIVE_fnc_hashGet;
        };
    };

    case "leader": {
        if (_args isEqualType objnull) then {
            [_logic,"leader", _args] call ALIVE_fnc_hashSet;
        } else {
            _result = [_logic,"leader"] call ALIVE_fnc_hashGet;
        };
    };

    case "group": {
        if (_args isEqualType objnull) then {
            [_logic,"group", _args] call ALIVE_fnc_hashSet;
        } else {
            _result = [_logic,"group"] call ALIVE_fnc_hashGet;
        };
    };

    case "units": {
        if (_args isEqualType []) then {
            [_logic,"units", _args] call ALIVE_fnc_hashSet;
        } else {
            _result = [_logic,"units"] call ALIVE_fnc_hashGet;
        };
    };

    case "spawnType": {
        if (_args isEqualType []) then {
            [_logic,"spawnType", _args] call ALIVE_fnc_hashSet;
        } else {
            _result = [_logic,"spawnType"] call ALIVE_fnc_hashGet;
        };
    };

    case "isPlayer": {
        if (_args isEqualType true) then {
            [_logic,"isPlayer", _args] call ALIVE_fnc_hashSet;
        } else {
            _result = [_logic,"isPlayer"] call ALIVE_fnc_hashGet;
        };
    };

    case "busy": {
        if (_args isEqualType true) then {
            [_logic,"busy", _args] call ALIVE_fnc_hashSet;
        } else {
            _result = [_logic,"busy"] call ALIVE_fnc_hashGet;
        };
    };

    case "ignore_HC": {
        if (_args isEqualType true) then {
            [_logic,"ignore_HC", _args] call ALIVE_fnc_hashSet;
        } else {
            _result = [_logic,"ignore_HC"] call ALIVE_fnc_hashGet;
        };
    };

    case "unitCount": {
        private _unitClasses = _logic select 2 select 11; //[_logic,"unitClasses"] call ALIVE_fnc_hashGet;
        private _unitCount = count _unitClasses;
        [_logic,"unitCount",_unitCount] call ALIVE_fnc_hashSet;

        _result = _unitCount;
    };

    case "unitIndexes": {
        private _unitCount = [_logic, "unitCount"] call MAINCLASS;
        private _unitIndexes = [];

        for "_i" from 0 to _unitCount - 1 do {
            _unitIndexes pushback _i;
        };

        _result = _unitIndexes;
    };

    case "speedPerSecond": {
        if (_args isEqualType []) then {
            [_logic,"speedPerSecond",_args] call ALIVE_fnc_hashSet;
        } else {
            _result = [_logic,"speedPerSecond"] call ALIVE_fnc_hashGet;
        };
    };

    case "addVehicleAssignment": {
        if (_args isEqualType []) then {
            private _assignment = _args;

            _assignment params ["_vehicleID","_entityID","_assignmentData"];

            private _assignments = [_logic,"vehicleAssignments"] call ALIVE_fnc_hashGet; //[_logic,"vehicleAssignments"] call ALIVE_fnc_hashGet;
            [_assignments, _vehicleID, _args] call ALIVE_fnc_hashSet;

            // take assignments and determine if this entity is in command of any of them
            private _vehiclesInCommandOf = [_assignments,_logic] call ALIVE_fnc_profileVehicleAssignmentsGetInCommand;
            [_logic,"vehiclesInCommandOf", _vehiclesInCommandOf] call ALIVE_fnc_hashSet;

            // take assignments and determine if this entity is in cargo of any of them
            private _vehiclesInCargoOf = [_assignments,_logic] call ALIVE_fnc_profileVehicleAssignmentsGetInCargo;
            [_logic,"vehiclesInCargoOf", _vehiclesInCargoOf] call ALIVE_fnc_hashSet;

            // take assignments and determine the max speed per second for the entire group
            private _newSpeedPerSecond = [_assignments,_logic] call ALIVE_fnc_profileVehicleAssignmentsGetSpeedPerSecond;
            [_logic,"speedPerSecond", _newSpeedPerSecond] call ALIVE_fnc_hashSet;

            // if spawned make the unit get in
            private _active = _logic select 2 select 1; //[_logic,"active"] call ALIVE_fnc_hashGet
            if (_active) then {
                [_args, _logic, true] call ALIVE_fnc_profileVehicleAssignmentToVehicleAssignment;
            };
        };
    };

    case "clearVehicleAssignments": {
        // remove this entity from referenced vehicles
        private _vehiclesInCommandOf = [_logic,"vehiclesInCommandOf",[]] call ALIVE_fnc_hashGet;
        private _vehiclesInCargoOf = [_logic,"vehiclesInCargoOf",[]] call ALIVE_fnc_hashGet;
        {
            private _vehicleProfile = [ALiVE_ProfileHandler,"getProfile",_x] call ALIVE_fnc_ProfileHandler;

            if (!isnil "_vehicleProfile") then {
                [_logic,_vehicleProfile] call ALIVE_fnc_removeProfileVehicleAssignment;
            };
        } foreach (_vehiclesInCommandOf + _vehiclesInCargoOf);

        // reset data
        [_logic,"vehicleAssignments",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
        [_logic,"vehiclesInCommandOf",[]] call ALIVE_fnc_hashSet;
        [_logic,"vehiclesInCargoOf",[]] call ALIVE_fnc_hashSet;
    };

    case "profileWaypointToWaypoint": {

        private _waypoint = _args;

        private _units = _logic select 2 select 21; //[_logic,"units"] call ALIVE_fnc_hashGet;
        private _unit = _units select 0;

        if !(isnil "_unit") then {
            [_waypoint, group _unit] call ALIVE_fnc_profileWaypointToWaypoint;
        };

    };

    case "insertWaypoint": {
        private _waypoint = _args;

        private _pathfindingEnabled = [MOD(profileSystem),"pathfinding"] call ALiVE_fnc_hashGet;
        if (!_pathfindingEnabled) then {
            [{ [_logic,"insertWaypointInternal", _waypoint] call MAINCLASS }, []] call CBA_fnc_directCall;
        } else {
            [{ [_logic,"addPendingWaypoint", ["insertWaypoint",_waypoint]] call MAINCLASS }, []] call CBA_fnc_directCall;
        };

        _result = _waypoint;
    };

    case "addWaypoint": {
        private _waypoint = _args;

        //private _compRad = [_waypoint,"completionRadius"] call ALiVE_fnc_hashGet;
        //systemchat format ["adding waypoint with radius: %1 ||| From - %2", _compRad,_fnc_scriptnameparent];

        private _pathfindingEnabled = [MOD(profileSystem),"pathfinding"] call ALiVE_fnc_hashGet;
        if (!_pathfindingEnabled) then {
            [{ [_logic,"addWaypointInternal", _waypoint] call MAINCLASS }, []] call CBA_fnc_directCall;
        } else {
            [{ [_logic,"addPendingWaypoint", ["addWaypoint",_waypoint]] call MAINCLASS }, []] call CBA_fnc_directCall;
        };

        _result = _waypoint;
    };

    case "addPendingWaypoint": {
        _args params ["_insertionMethod","_waypoint", ["_ready", false]];

        private _pendingWaypoints = [_logic,"pendingWaypointPaths"] call ALiVE_fnc_hashGet;

        private _pendingPath = [_ready,_insertionMethod,[],_waypoint];
        _pendingWaypoints pushback _pendingPath;

        private _countPendingWaypoints = count _pendingWaypoints;

        if (_ready) then {
            private _waypointPosition = [_waypoint,"position"] call ALiVE_fnc_hashGet;
            _pendingPath set [2, [_waypointPosition]];

            if (_countPendingWaypoints == 1) then {
                [_logic,"advancePendingWaypoints"] call MAINCLASS;
            };
        } else {
            private _previousWaypoint = if (_countPendingWaypoints == 1) then {nil} else {(_pendingWaypoints select (_countPendingWaypoints - 2)) select 3};
            private _startPosition = if (isnil "_previousWaypoint" || _insertionMethod == "insertWaypoint") then { [_logic,"position"] call ALiVE_fnc_hashGet } else { [_previousWaypoint,"position"] call ALiVE_fnc_hashGet };
            private _endPosition = [_waypoint,"position"] call ALiVE_fnc_hashGet;
            private _pathfindingProcedure = [_logic] call ALiVE_fnc_profileGetPathfindingProcedure;
            private _profileID = [_logic,"profileID"] call ALiVE_fnc_hashGet;

            [ALiVE_Pathfinder,"findPath",[_startPosition,_endPosition,_pathfindingProcedure,true,true,[_profileID,_pendingPath],{
                params ["_callbackArgs","_path"];

                _callbackArgs params ["_profileID","_pendingPath"];

                private _profile = [ALiVE_profileHandler,"getProfile", _profileID] call ALiVE_fnc_profileHandler;
                if (!isnil "_profile") then {
                    _pendingPath set [0,true];
                    _pendingPath set [2,_path];
                    [_profile,"advancePendingWaypoints"] call ALIVE_fnc_profileEntity;
                };
            }]] call ALiVE_fnc_pathfinder;

            // if we're inserting into the front
            // we need to generate new paths for the existing waypoints
            if (_insertionMethod == "insertWaypoint") then {
                private _newPendingWaypoins = [_pendingWaypoints select 0];

                private _existingWaypoints = [_logic,"waypoints"] call ALiVE_fnc_hashGet;
                private _existingWaypointJobs = _existingWaypoints apply { [false,"addWaypoint",[],_x] };

                private _existingPendingWaypoints = _pendingWaypoints select [1, _countPendingWaypoints - 1];

                _newPendingWaypoins append _existingWaypointJobs;
                _newPendingWaypoins append _existingPendingWaypoints;

                [_logic,"pendingWaypointPaths", _newPendingWaypoins] call ALiVE_fnc_hashSet;
            };
        };

        _result = _pendingPath;
    };

    case "advancePendingWaypoints": {
        private _pendingWaypoints = [_logic,"pendingWaypointPaths"] call ALiVE_fnc_hashGet;

        private _firstPending = _pendingWaypoints select 0;
        while {!isnil "_firstPending" && {_firstPending select 0}} do {
            private _insertionMethod = if ((_firstPending select 1) == "addWaypoint") then {"addWaypointInternal"} else {"insertWaypointInternal"};
            private _path = _firstPending select 2;
            private _waypoint = _firstPending select 3;
            [_waypoint,"name", "pathfound"] call ALiVE_fnc_hashSet;

            private _waypointTemplate = +_waypoint;
            //[_waypointTemplate,"timeout", []] call ALiVE_fnc_hashSet;
            [_waypointTemplate,"type", "MOVE"] call ALiVE_fnc_hashSet;
            [_waypointTemplate,"description", ""] call ALiVE_fnc_hashSet;
            [_waypointTemplate,"attachVehicle", ""] call ALiVE_fnc_hashSet;
            [_waypointTemplate,"statements", ""] call ALiVE_fnc_hashSet;

            _path = _path apply {
                private _tempWP = +_waypointTemplate;
                [_tempWP,"position", _x] call ALiVE_fnc_hashSet;

                _tempWP
            };
            _path set [count _path - 1, _waypoint];

            // if we are inserting into the front
            // need to reverse path so it's executed in the correct order
            if (_insertionMethod == "insertWaypointInternal") then { reverse _path };

            {
                [_logic,_insertionMethod, _x] call MAINCLASS;
            } foreach _path;

            _pendingWaypoints deleteat 0;

            // check next pending path

            if (count _firstPending > 0) then {
                _firstPending = _pendingWaypoints select 0;
            } else {
                _firstPending = nil;
            };
        };

    };

    case "insertWaypointInternal": {
        private _waypoint = _args;

        private _waypoints = _logic select 2 select 16; //[_logic,"waypoints"] call ALIVE_fnc_hashGet;
        _waypoints = [_waypoints, [_waypoint], 0] call BIS_fnc_arrayInsert;
        [_logic,"waypoints",_waypoints] call ALIVE_fnc_hashSet;

        private _active = _logic select 2 select 1; //[_logic,"active"] call ALIVE_fnc_hashGet
        if (_active) then {
            [_logic,"profileWaypointToWaypoint", _waypoint] call MAINCLASS;
        };
    };

    case "addWaypointInternal": {
        private _waypoint = _args;

        private _waypoints = _logic select 2 select 16; //[_logic,"waypoints"] call ALIVE_fnc_hashGet;
        _waypoints pushback _waypoint;

        if (([_waypoint,"type"] call ALIVE_fnc_hashGet) == 'CYCLE') then {
            [_logic,"isCycling",true] call ALIVE_fnc_hashSet;
        };

        private _active = _logic select 2 select 1; //[_logic,"active"] call ALIVE_fnc_hashGet
        if (_active) then {
            [_logic,"profileWaypointToWaypoint", _waypoint] call MAINCLASS;
        };
    };

    case "clearWaypoints": {
        [_logic,"waypoints",[]] call ALIVE_fnc_hashSet;
        [_logic,"waypointsCompleted",[]] call ALIVE_fnc_hashSet;

        private _active = _logic select 2 select 1; //[_logic,"active"] call ALIVE_fnc_hashGet
        if (_active) then {
            private _units = _logic select 2 select 21; //[_logic,"units"] call ALIVE_fnc_hashGet;

            if (count _units > 0) then {
                private _unit = _units select 0;
                private _group = group _unit;
                while { count (waypoints _group) > 0 } do
                {
                    deleteWaypoint ((waypoints _group) select 0);
                };
            };
        };
    };

    case "setActiveCommand": {
        if (_args isEqualType []) then {

            [_logic, "clearActiveCommands"] call MAINCLASS;

            [_logic, "addActiveCommand", _args] call MAINCLASS;

            private _active = _logic select 2 select 1; //[_profile, "active"] call ALIVE_fnc_hashGet;
            if (_active) then {
                private _activeCommands = _logic select 2 select 26; //[_logic,"commands"] call ALIVE_fnc_hashGet;
                [ALIVE_commandRouter, "activate", [_logic, _activeCommands]] call ALIVE_fnc_commandRouter;
            };
        };
    };

    case "addActiveCommand": {
        if (_args isEqualType []) then {
            private _type = _logic select 2 select 5;

            if (!(isnil "_type") && {_type == "entity"}) then {

                private _activeCommands = _logic select 2 select 26; //[_logic,"commands"] call ALIVE_fnc_hashGet;
                _activeCommands pushback _args;
            };
        };
    };

    case "clearActiveCommands": {
        private _type = _logic select 2 select 5;

        if (!(isnil "_type") && {_type == "entity"}) then {
            private _activeCommands = _logic select 2 select 26; //[_logic,"vehicleAssignments"] call ALIVE_fnc_hashGet;

            if(count _activeCommands > 0) then {
                [ALIVE_commandRouter, "deactivate", _logic] call ALIVE_fnc_commandRouter;
                [_logic,"activeCommands",[]] call ALIVE_fnc_hashSet;
            };
        };
    };

    case "addInactiveCommand": {
        private _type = _logic select 2 select 5;

        if (!(isnil "_type") && {_type == "entity"}) then {
            if (_args isEqualType []) then {
                private _inactiveCommands = _logic select 2 select 27; //[_logic,"commands"] call ALIVE_fnc_hashGet;
                _inactiveCommands pushback _args;
            };
        };
    };

    case "clearInactiveCommands": {
        private _type = _logic select 2 select 5;

        if (!(isnil "_type") && {_type == "entity"}) then {
            private _inactiveCommands = _logic select 2 select 27; //[_logic,"vehicleAssignments"] call ALIVE_fnc_hashGet;

            if (count _inactiveCommands > 0) then {
                [ALIVE_commandRouter, "deactivate", _logic] call ALIVE_fnc_commandRouter;
                [_logic,"inactiveCommands",[]] call ALIVE_fnc_hashSet;
            };
        };
    };

    case "mergePositions": {
        private _position = _logic select 2 select 2; //[_logic,"position"] call ALIVE_fnc_hashGet;
        private _unitCount = [_logic,"unitCount"] call MAINCLASS;
        private _positions = _logic select 2 select 18; //[_logic,"positions"] call ALIVE_fnc_hashGet;

        //["ENTITY %1 mergePosition: %2",_logic select 2 select 4,_position] call ALIVE_fnc_dump;

        for "_i" from 0 to _unitCount - 1 do {
            _positions set [_i, _position];
        };
    };

    case "addUnit": {
        if (_args isEqualType []) then {
            _args params [
                "_class",
                ["_position", [0,0,0], [[]]],
                ["_damage", 0, [0]],
                ["_rank", "PRIVATE", [""]]
            ];
            private _unitClasses = _logic select 2 select 11;   //[_logic,"unitClasses"] call ALIVE_fnc_hashGet;
            private _positions = _logic select 2 select 18;     //[_logic,"positions"] call ALIVE_fnc_hashGet;
            private _damages = _logic select 2 select 19;       //[_logic,"damages"] call ALIVE_fnc_hashGet;
            private _ranks = _logic select 2 select 20;         //[_logic,"ranks"] call ALIVE_fnc_hashGet;

            _unitClasses pushback _class;
            _positions pushback _position;
            _damages pushback _damage;
            _ranks pushback _rank;
        };
    };

    case "removeUnit": {
        if (_args isEqualType 0) then {
            private _unitIndex = _args;

            private _unitClasses = _logic select 2 select 11;   //[_logic,"unitClasses"] call ALIVE_fnc_hashGet;
            private _positions = _logic select 2 select 18;     //[_logic,"positions"] call ALIVE_fnc_hashGet;
            private _damages = _logic select 2 select 19;       //[_logic,"damages"] call ALIVE_fnc_hashGet;
            private _ranks = _logic select 2 select 20;         //[_logic,"ranks"] call ALIVE_fnc_hashGet;
            private _unitCount = _logic select 2 select 12;

            _unitClasses deleteAt _unitIndex;
            _positions deleteAt _unitIndex;
            _damages deleteAt _unitIndex;
            _ranks deleteAt _unitIndex;

            //[_logic,"unitClasses",_unitClasses] call ALIVE_fnc_hashSet;
            //[_logic,"positions",_positions] call ALIVE_fnc_hashSet;
            //[_logic,"damages",_damages] call ALIVE_fnc_hashSet;
            //[_logic,"ranks",_ranks] call ALIVE_fnc_hashSet;
            [_logic,"unitCount", count _unitClasses] call ALiVE_fnc_hashSet; // use count to ensure unitIndex is within range

            private  _active = _logic select 2 select 1; //[_logic,"active"] call ALIVE_fnc_hashGet
            if (_active) then {
                private _units = _logic select 2 select 21; //[_logic,"units"] call ALIVE_fnc_hashGet;
                _units deleteAt _unitIndex;
                //[_logic,"units",_units] call ALIVE_fnc_hashSet;

                // update unitIndex variables
                {_x setVariable ["profileIndex",_forEachIndex]} foreach _units;
            };

            _result = true;
            if (_unitClasses isEqualTo []) then {
                _result = false;
            };
        };
    };

    case "removeUnitByObject": {
        if (_args isEqualType objnull) then {
            private _units = _logic select 2 select 21; //[_logic,"units"] call ALIVE_fnc_hashGet;

            {
                if(_x == _args) then {
                    _result = [_logic, "removeUnit", _forEachIndex] call MAINCLASS;
                };
            } forEach _units;
        };
    };

    case "resize": {
        private ["_newGroup"];

        if (_args isEqualType 0) then {
            private _size = _args;

            private _unitClasses = _logic select 2 select 11;
            private _active = _logic select 2 select 1;     //[_logic,"active"] call ALIVE_fnc_hashGet
            private _units = _logic select 2 select 21;     //[_logic,"units"] call ALIVE_fnc_hashGet;
            private _side = _logic select 2 select 3;       //[_logic, "side"] call MAINCLASS;
            private _sideObject = [_side] call ALIVE_fnc_sideTextToObject;

            if(_active) then {
                _newGroup = createGroup _sideObject;
            };

            private _removeIndexes = [];

            {
                if((_forEachIndex + 1) > _size) then {

                    if(_active) then {
                        private _unit = _units select (_forEachIndex - 1);
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
        private _active = _logic select 2 select 1;
        private _profileID = _logic select 2 select 4;

        private _waypointCompleted = false;

        if (_active) then {
            private _group = _logic select 2 select 13;
            private _leader = leader _group;
            private _currentPosition = position _leader;
            private _currentWaypoint = currentWaypoint _group;
            private _waypoints = waypoints _group;
            private _currentWaypoint = _waypoints select ((count _waypoints)-1);

            if !(isNil "_currentWaypoint") then {

                private _destination = waypointPosition _currentWaypoint;
                private _completionRadius = waypointCompletionRadius _currentWaypoint;

                _completionRadius = (_completionRadius * 2) + 20;

                private _distance = _currentPosition distance _destination;

                if(_distance < _completionRadius) then {
                    _waypointCompleted = true;
                };

            }else{
                _waypointCompleted = true;
            }

        } else {
            private _waypoints = [_logic,"waypoints"] call ALIVE_fnc_hashGet;

            if (count _waypoints == 0) then {
                _waypointCompleted = true;
            };
        };

        _result = _waypointCompleted;
    };

    case "setPosition": {
        if (_args isEqualType []) then {
            private _spacialGrid = [ALiVE_profileSystem,"spacialGridProfiles"] call ALiVE_fnc_hashGet;

            private _currPos = _logic select 2 select 2;
            [_spacialGrid,"move", [_currPos, _args, _logic]] call ALiVE_fnc_spacialGrid;

            [_logic,"position",_args] call ALIVE_fnc_hashSet;

            //["ENTITY %1 setPosition: %2",_logic select 2 select 4,_args] call ALIVE_fnc_dump;

            private _active = _logic select 2 select 1; //[_profile, "active"] call ALIVE_fnc_hashGet;
            if(_active) then {

                private _group = _logic select 2 select 13;

                {
                    _x setPos _args;
                } forEach (units _group);

            };
        };
    };

    case "spawn": {
        private _debug = _logic select 2 select 0; //[_logic,"debug"] call ALIVE_fnc_hashGet;
        private _profileID = _logic select 2 select 4; //[_profile,"profileID"] call ALIVE_fnc_hashGet;
        private _side = _logic select 2 select 3; //[_logic, "side"] call MAINCLASS;
        private _sideObject = [_side] call ALIVE_fnc_sideTextToObject;
        private _unitClasses = _logic select 2 select 11; //[_logic,"unitClasses"] call ALIVE_fnc_hashGet;
        private _position = _logic select 2 select 2; //[_entityProfile,"position"] call ALIVE_fnc_hashGet;
        private _positions = _logic select 2 select 18; //[_entityProfile,"positions"] call ALIVE_fnc_hashGet;
        private _damages = _logic select 2 select 19; //[_logic,"damages"] call ALIVE_fnc_hashGet;
        private _ranks = _logic select 2 select 20; //[_logic,"ranks"] call ALIVE_fnc_hashGet;
        private _active = _logic select 2 select 1; //[_profile, "active"] call ALIVE_fnc_hashGet;
        private _waypoints = _logic select 2 select 16; //[_entityProfile,"waypoints"] call ALIVE_fnc_hashGet;
        private _waypointsCompleted = _logic select 2 select 17; //[_entityProfile,"waypointsCompleted"] call ALIVE_fnc_hashGet;
        private _vehicleAssignments = _logic select 2 select 7; //[_logic,"vehicleAssignments"] call ALIVE_fnc_hashGet;
        private _activeCommands = _logic select 2 select 26; //[_logic,"vehicleAssignments"] call ALIVE_fnc_hashGet;
        private _inactiveCommands = _logic select 2 select 27; //[_logic,"vehicleAssignments"] call ALIVE_fnc_hashGet;
        private _vehiclesInCommandOf = _logic select 2 select 8; //[_profile,"vehiclesInCommandOf",[]] call ALIVE_fnc_hashSet;
        private _vehiclesInCargoOf = _logic select 2 select 9; //[_profile,"vehiclesInCargoOf",[]] call ALIVE_fnc_hashSet;
        private _locked = [_logic, "locked",false] call ALIVE_fnc_hashGet;
        private _ignore_HC = [_logic, "ignore_HC",false] call ALIVE_fnc_hashGet;

        private _formation = selectRandom ["COLUMN","STAG COLUMN","WEDGE","ECH LEFT","ECH RIGHT","VEE","LINE"];
        private _unitCount = 0;
        private _units = [];
        private _paraDrop = false;
        private _spawnOnGround = false;

        // not already active and spawning has not yet been triggered
        if (!_active && {!_locked}) then {

            // Indicate profile has been despawned and unlock for asynchronous waits
            [_logic, "locked",true] call ALIVE_fnc_HashSet;

            private _group = createGroup _sideObject;

            // determine a suitable spawn position
            //["Profile [%1] Spawn - Get good spawn position",_profileID] call ALIVE_fnc_dump;
            //[true] call ALIVE_fnc_timer;
            [_logic] call ALIVE_fnc_profileGetGoodSpawnPosition;
            //[] call ALIVE_fnc_timer;

            _position = _logic select 2 select 2; //[_entityProfile,"position"] call ALIVE_fnc_hashGet;

            //["SPAWN ENTITY [%1] pos: %2 command: %3 cargo: %4",_profileID,_position,_vehiclesInCommandOf,_vehiclesInCargoOf] call ALIVE_fnc_dump;

            if (((count _vehiclesInCommandOf) == 0) && {(count _vehiclesInCargoOf) == 0}) then {

                // If entity is not in a vehicle but in air give it a parachute
                if ((_position select 2) > 300) then {
                    _paraDrop = true;
                };
            } else {

                // If entity is in a vehicle spawn the unit on groundlevel to avoid falling to death with slowspawn, altering pos array directly
                if (surfaceIsWater _position) then {
                    _position set [2,(ATLtoASL _position) select 2];
                } else {
                    _position set [2,0];
                };

                _spawnOnGround = true;
            };

            // ["Profile [%1] Spawn - Spawn Units",_profileID] call ALIVE_fnc_dump;
            //[true] call ALIVE_fnc_timer;
            {
                if !(isnil "_x") then {

                    private _unitPosition = _position;
                    if (count _positions > 0 && {_unitCount < count _positions} && {!_spawnOnGround}) then {
                        _unitPosition = _positions select _unitCount;
                    };
                    if (count _unitPosition == 2) then {_unitPosition set [2,0]};

                    private _damage = 0;
                    if (count _damages > 0 && {_unitCount < count _damages}) then {
                        _damage = _damages select _unitCount;
                    };

                    private _rank = "PRIVATE";
                    if (count _ranks > 0 && {_unitCount < count _ranks}) then {
                        _rank = _ranks select _unitCount;
                        if (_rank isEqualTo "") then {_rank = "PRIVATE"};
                    };

                    private "_unit";
                    if (_forEachIndex == 0) then {

                        _unit = _group createUnit [_x, _unitPosition, [], 0 , "NONE"];

                        // select a random formation, must be at least one unit in group for formation to stick
                        _group setFormation _formation;
                        _group selectLeader _unit;

                    } else {
                        _unit = _group createUnit [_x, _unitPosition, [], 0 , "FORM"];

                        // sadly still needed, even though "FORM" is used above :(
                        _unit setpos (formationPosition _unit);
                    };

                    _unit allowDamage false; // allow all units to spawn first so profile isn't corrupted

                    //Set name
                    //_unit setVehicleVarName format["%1_%2",_profileID, _unitCount];

                    // Set damages and rank on all units including leader and reset position
                    _unit setposATL _unitPosition;
                    _unit setDamage _damage;
                    _unit setRank _rank;

                    // set profile id on the unit
                    _unit setVariable ["ALiVE_ignore_HC", _ignore_HC];
                    _unit setVariable ["profileID", _profileID];
                    _unit setVariable ["profileIndex", _unitCount];

                    // killed event handler
                    private _eventID = _unit addMPEventHandler["MPKilled", ALIVE_fnc_profileKilledEventHandler];

                    _units pushback _unit;
                    _unitCount = _unitCount + 1;

                    if(_paraDrop) then {

                        //Creating parachute on original position
                        private _parachute = createvehicle ["Steerable_Parachute_F",_unitPosition,[],0,"none"];

                        //Resetting unit to original position
                        _unit setpos _unitPosition;
                        _unit moveindriver _parachute;

                        _parachute setdir direction _unit;
                        _parachute setvelocity [0,0,-1];

                        if (time - (missionnamespace getvariable ["bis_fnc_curatorobjectedited_paraSoundTime",0]) > 0) then {
                            private _soundFlyover = selectRandom ["BattlefieldJet1","BattlefieldJet2"];
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
                sleep ALiVE_smoothSpawn;
            } forEach _unitClasses;
            //[] call ALIVE_fnc_timer;

            // set group profile as active and store references to units on the profile
            [_logic,"leader", leader _group] call ALIVE_fnc_hashSet;
            [_logic,"group", _group] call ALIVE_fnc_hashSet;
            [_logic,"units", _units] call ALIVE_fnc_hashSet;
            [_logic,"active", true] call ALIVE_fnc_hashSet;

            //["Profile [%1] Spawn - Create Vehicle Assignments",_profileID] call ALIVE_fnc_dump;
            //[true] call ALIVE_fnc_timer;
            // create vehicle assignments from profile vehicle assignments
            [_vehicleAssignments, _logic] call ALIVE_fnc_profileVehicleAssignmentsToVehicleAssignments;
            //[] call ALIVE_fnc_timer;
			
			//["Profile [%1] Spawn - Create Waypoints",_profileID] call ALIVE_fnc_dump;
            //[true] call ALIVE_fnc_timer;
            // create waypoints from profile waypoints
            _waypoints append _waypointsCompleted;
            [_waypoints, _group] call ALIVE_fnc_profileWaypointsToWaypoints;
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

            // remove profiled attacks

            private _attackID = [_logic,"attackID"] call ALiVE_fnc_hashGet;
            if (!isnil "_attackID") then {
                private _attack = [MOD(profileCombatHandler),"getAttack", _attackID] call ALiVE_fnc_profileCombatHandler;
                [MOD(profileCombatHandler),"removeAttacks", [_attack]] call ALiVE_fnc_profileCombatHandler;
            };

            [_logic,"combat", false] call ALIVE_fnc_HashSet;


            // Indicate profile has been spawned and unlock for asynchronous waits
            [_logic,"locked", false] call ALIVE_fnc_HashSet;

            // profile is fully spawned and cannot be corrupted
            // allow damage again
            {_x allowDamage true} foreach _units;

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
        private _debug = _logic select 2 select 0;      //[_logic,"debug"] call ALIVE_fnc_hashGet;
        private _group = _logic select 2 select 13;     //[_logic,"group"] call ALIVE_fnc_hashGet;
        private _leader = _logic select 2 select 10;    //[_logic,"leader"] call ALIVE_fnc_hashGet;
        private _units = _logic select 2 select 21;     //[_logic,"units"] call ALIVE_fnc_hashGet;
        private _positions = _logic select 2 select 18; //[_logic,"positions"] call ALIVE_fnc_hashGet;
        private _damages = _logic select 2 select 19;   //[_logic,"damages"] call ALIVE_fnc_hashGet;
        private _ranks = _logic select 2 select 20;     //[_logic,"ranks"] call ALIVE_fnc_hashGet;
        private _active = _logic select 2 select 1;     //[_logic,"active"] call ALIVE_fnc_hashGet;
        private _profileID = _logic select 2 select 4;  //[_logic,"profileID"] call ALIVE_fnc_hashGet;
        private _side = _logic select 2 select 3;       //[_logic, "side"] call MAINCLASS;
        private _activeCommands = _logic select 2 select 26;    //[_logic,"vehicleAssignments"] call ALIVE_fnc_hashGet;
        private _inactiveCommands = _logic select 2 select 27;  //[_logic,"vehicleAssignments"] call ALIVE_fnc_hashGet;

        //Don't despawn player profiles
        if ([_logic, "isPlayer",false] call ALIVE_fnc_HashGet) exitwith {};

        private _unitCount = 0;

        // not already inactive
        if (_active) then {

            // if any linked profiles have despawn prevented
            private _despawnPrevented = false;
            private _linked = [_logic] call ALIVE_fnc_vehicleAssignmentsGetLinkedProfiles;
            //_linked call ALIVE_fnc_inspectHash;
            if (count (_linked select 1) > 1) then {
                {
                    private _spawnType = [_x,"spawnType"] call ALIVE_fnc_hashGet;
                    if (count _spawnType > 0) then {
                        if(_spawnType select 0 == "preventDespawn") then {
                            _despawnPrevented = true;
                        };
                    }
                } forEach (_linked select 2);
            };

            if !(_despawnPrevented) then {

                [_logic,"active", false] call ALIVE_fnc_hashSet;

                // update profile waypoints before despawn
                [_logic,"clearWaypoints"] call MAINCLASS;
                [_logic,_group] call ALIVE_fnc_waypointsToProfileWaypoints;

                [_logic] call ALIVE_fnc_vehicleAssignmentsToProfileVehicleAssignments;

                _position = getPosATL _leader;

                // update the profiles position
                //[_logic,"position", _position] call ALIVE_fnc_hashSet;
                [_logic,"position", _position] call MAINCLASS;
                [_logic,"despawnPosition", _position] call ALIVE_fnc_hashSet;

                // delete units
                {
                    private _unit = _x;
                    _positions set [_unitCount, getPosATL _unit];
                    _damages set [_unitCount, damage _unit];
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
        if (_args isEqualType objnull) then {
            _result = [_logic, "removeUnitByObject", _args] call MAINCLASS;

            if!(_result) then {
                [ALIVE_commandRouter, "deactivate", _logic] call ALIVE_fnc_commandRouter;
            };
        };
    };

    case "destroy": {
        private _debug = _logic select 2 select 0; //[_logic,"debug"] call ALIVE_fnc_hashGet;
        private _group = _logic select 2 select 13; //[_logic,"group"] call ALIVE_fnc_hashGet;
        private _units = _logic select 2 select 21; //[_logic,"units"] call ALIVE_fnc_hashGet;
        private _active = _logic select 2 select 1; //[_logic,"active"] call ALIVE_fnc_hashGet;
        private _profileID = _logic select 2 select 4; //[_logic,"profileID"] call ALIVE_fnc_hashGet;

        private _unitCount = 0;

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
                private _unit = _x;
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

    case "createMarkers": {
        private _markers = [];

        private _position = [_logic,"position"] call ALIVE_fnc_hashGet;
        private _profileID = [_logic,"profileID"] call ALIVE_fnc_hashGet;
        private _profileSide = [_logic,"side"] call ALIVE_fnc_hashGet;
        private _profileType = [_logic,"objectType"] call ALIVE_fnc_hashGet;
        private _profileActive = [_logic,"active"] call ALIVE_fnc_hashGet;
        private _profileWaypoints = [_logic,"waypoints"] call ALIVE_fnc_hashGet;

        private _debugColor = [_logic,"debugColor","ColorGreen"] call ALIVE_fnc_hashGet;
        private _typePrefix = "n";
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
        };

        private _debugIcon = format["%1_inf",_typePrefix];
        /*
        switch(_profileType) do {
            default {
                _debugIcon = format["%1_inf",_typePrefix];
            };
        };
        */

        private _label = [_profileID, "_"] call CBA_fnc_split;
        private _debugAlpha = 1;

        if (!_profileActive) then {
            _debugAlpha = 0.3;

            private _waypointCount = 0;
            {
                private _waypointPosition = [_x,"position"] call ALIVE_fnc_hashGet;

                private _m = createMarker [format["SIM_MARKER_%1_%2",_profileID,_waypointCount], _waypointPosition];
                _m setMarkerShape "ICON";
                _m setMarkerSize [.6, .6];
                _m setMarkerType "waypoint";
                _m setMarkerColor _debugColor;
                _m setMarkerAlpha 0.6;

                _m setMarkerText format["%1",_label select ((count _label) - 1),_waypointCount];

                _markers pushback _m;

                [_logic,"debugMarkers", _markers] call ALIVE_fnc_hashSet;

                _waypointCount = _waypointCount + 1;
            } forEach _profileWaypoints;
        };

        if (count _position > 0) then {
            private _m = createMarker [format[MTEMPLATE, format["%1_debug",_profileID]], _position];
            _m setMarkerShape "ICON";
            _m setMarkerSize [.4, .4];
            _m setMarkerType _debugIcon;
            _m setMarkerColor _debugColor;
            _m setMarkerAlpha _debugAlpha;

            _m setMarkerText format["e%1",_label select ((count _label) - 1)];

            _markers pushback _m;

            [_logic,"debugMarkers", _markers] call ALIVE_fnc_hashSet;
        };

        _result = _markers;
    };

    case "deleteMarkers": {
        {
            deleteMarker _x;
        } forEach ([_logic,"debugMarkers", []] call ALIVE_fnc_hashGet);
    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };

};

TRACE_1("profileEntity - output",_result);

_result;