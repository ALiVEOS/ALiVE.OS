#include "\x\alive\addons\mil_command\script_component.hpp"
SCRIPT(ambientMovement);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ambientMovement

Description:
Ambient movement command for active profiles

Parameters:
Profile - profile
Args - array

Returns:

Examples:
(begin example)
[_profile, "setActiveCommand", ["ALIVE_fnc_ambientMovement","spawn",200]] call ALIVE_fnc_profileEntity;
(end)

See Also:

Author:
Highhead
Jman
---------------------------------------------------------------------------- */

params ["_profile","_params"];

if (isnil "_profile") exitWith {
    ["ALIVE_fnc_ambientMovement retrieved a an empty nil-profile from %1!",_fnc_scriptNameParent] call ALiVE_fnc_Dump;
};

// Get profile data 
if (isnil "_profile") exitWith {};
private _pos = [_profile,"position"] call ALiVE_fnc_HashGet;
private _waypoints = [_profile,"waypoints",[]] call ALiVE_fnc_HashGet;
private _vehiclesInCommandOf = [_profile,"vehiclesInCommandOf",[]] call ALIVE_fnc_HashGet;
private _profileID = [_profile,"profileID"] call ALiVE_fnc_HashGet;
private _group = [_profile,"group"] call ALiVE_fnc_HashGet;

// Handle inputs types
private ["_radius","_behaviour"];

switch (typename _params) do {
    case "ARRAY" : {
        _radius = _params select 0;
        _behaviour = _params select 1;
    };
    default {
        _radius = _params;
        _behaviour = "SAFE";
    };
};

// defaults
private _debug = false;
private _roads = false;
private _parkedAir = false;
private _useLocations = false;
private _locations = [];
private _vehicleObjectType = "none";

if (_debug) then {
 ["ALIVE_fnc_ambientMovement - _radius: %1", _radius] call ALiVE_fnc_Dump;
};

// change radius and primary waypoints if not an infantry group
if (count _vehiclesInCommandOf > 0) then {
    {
        private _vehicleProfile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;

        if !(isnil "_vehicleProfile") then {
            _vehicleObjectType = _vehicleProfile select 2 select 6; //[_profile,"objectType"] call ALIVE_fnc_hashGet;

            switch (_vehicleObjectType) do {
                case ("Car") : {
                    _radius = 800;
                    _useLocations = true;
                    _roads = true;
                };
                case ("Tank") : {
                    _radius = 1000;
                    _useLocations = true;
                    _roads = true;
                };
                case ("Helicopter") : {
                    if (_pos select 2 < 5) then {
                        _parkedAir = true;
                    } else {
                        _radius = 1500;
                    };
                };
                case ("Plane") : {
                    if (_pos select 2 < 5) then {
                        _parkedAir = true;
                    } else {
                        _radius = 2000;
                    };
                };
                case ("Ship") : {
                    _radius = 800;
                };
            };
        };
    } forEach _vehiclesInCommandOf;
};

if (_debug) then {
    ["ALIVE_fnc_ambientMovement prepared data for %1: _group: %7, _radius %2 | _useLocations %3 | _parkedAir %4 | _roads %5 | _vehicleObjectType %6",
        _profileID,
        _radius,
        _useLocations,
        _parkedAir,
        _roads,
        _vehicleObjectType,
        _group
    ] call ALiVE_fnc_Dump;
};

//if static
if (count _waypoints == 0 && {!_parkedAir}) then {
    
    //get locations in case
    if (_useLocations) then {
        _locations = nearestLocations [_pos, ["NameCity","NameVillage","NameLocal"], _radius];
    };

    //defaults
    private _startPos = _pos;
    private _speed = "LIMITED";
    private _formation = "COLUMN";
    private _routePositions = [];
    private _minimumWaypointSeparation = (10 min ((_radius max 0) * 0.1)) max 3;

    // Generate distinct patrol nodes before adding the CYCLE return. A bounded
    // retry avoids duplicate/near-duplicate nodes from random, road, shoreline,
    // or location snapping without risking an unbounded scheduler loop.
    for "_i" from 0 to 3 do {
        private _accepted = false;
        private _candidate = [];
        private _attempt = 0;

        while {_attempt < 20 && {!_accepted}} do {
            _attempt = _attempt + 1;

            if (count _locations > 0) then {
                private _location = selectRandom _locations;
                _locations deleteAt (_locations find _location);
                _candidate = position _location;

                if (_debug) then {
                    ["ALIVE_fnc_ambientMovement selected the location %1 at %2 as waypoint-index %3 for profileID %4!",_location,_candidate,_i,_profileID] call ALiVE_fnc_Dump;
                };
            } else {
                _candidate = [_startPos,_radius] call CBA_fnc_RandPos;

                if (_vehicleObjectType == "Ship") then {
                    // #943 - boats keep their ambient waypoints ON water. The land
                    // relocation below hands a spawned boat shoreline waypoints its
                    // engine AI can never reach, halting it against the beach.
                    if !(surfaceIsWater _candidate) then {
                        _candidate = [_candidate] call ALiVE_fnc_getClosestSea;
                    };
                    if !(surfaceIsWater _candidate) then {_candidate = _startPos};
                } else {
                    if (surfaceIsWater _candidate) then {
                        _candidate = [_candidate] call ALiVE_fnc_getClosestLand;
                    };
                };

                if (_debug) then {
                    ["ALIVE_fnc_ambientMovement didn't find have locations available on waypoint-index %2 for profileID %3! Selecting random position %1!",_candidate,_i,_profileID] call ALiVE_fnc_Dump;
                };
            };

            if (_roads) then {
                private _roadsArray = _candidate nearRoads 200;

                if (count _roadsArray > 0) then {
                    _candidate = getPosATL (selectRandom _roadsArray);

                    if (_debug) then {
                        ["ALIVE_fnc_ambientMovement selected a road at %1 as waypoint-index %2 for profileID %3!",_candidate,_i,_profileID] call ALiVE_fnc_Dump;
                    };
                } else {
                    // Keep motorized, mechanized, and armored groups on a road or
                    // reject this candidate and retry from another random position.
                    _candidate = _startPos;

                    if (_debug) then {
                        ["ALIVE_fnc_ambientMovement has no roads on waypoint-index %2 for profileID %3! Rejecting candidate at startposition %1!",_candidate,_i,_profileID] call ALiVE_fnc_Dump;
                    };
                };
            };

            if (count _candidate >= 2) then {
                private _tooClose = (_candidate distance2D _startPos) < _minimumWaypointSeparation;
                if (!_tooClose) then {
                    _tooClose = (_routePositions findIf {(_candidate distance2D _x) < _minimumWaypointSeparation}) >= 0;
                };
                if (!_tooClose) then {
                    _accepted = true;
                    _routePositions pushBack _candidate;
                };
            };
        };
    };

    if !(_routePositions isEqualTo []) then {
        _routePositions pushBack _startPos;
        private _routeCount = count _routePositions;

        {
            private _previousIndex = if (_forEachIndex == 0) then {_routeCount - 1} else {_forEachIndex - 1};
            private _nextIndex = if (_forEachIndex == (_routeCount - 1)) then {0} else {_forEachIndex + 1};
            private _shortestLeg = ((_x distance2D (_routePositions select _previousIndex)) min (_x distance2D (_routePositions select _nextIndex)));
            // Adjacent radii total at most 90% of their leg, leaving a gap that
            // prevents a CYCLE route from completing two waypoints at once.
            private _completionRadius = 50 min (_shortestLeg * 0.45);
            private _type = if (_forEachIndex == (_routeCount - 1)) then {"CYCLE"} else {"MOVE"};
            private _profileWaypoint = [_x,20,_type,_speed,_completionRadius,[],_formation,"NO CHANGE",_behaviour] call ALIVE_fnc_createProfileWaypoint;
            [_profileWaypoint,"statements",["true","_disableSimulation = true;"]] call ALIVE_fnc_hashSet;
            [_profile,"addWaypoint",_profileWaypoint] call ALIVE_fnc_profileEntity;
        } forEach _routePositions;
    };
};
