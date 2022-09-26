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
            };
        };
    } forEach _vehiclesInCommandOf;
};

if (_debug) then {
    ["ALIVE_fnc_ambientMovement prepared data for %1: _radius %2 | _useLocations %3 | _parkedAir %4 | _roads %5 | _vehicleObjectType %6",
        _profileID,
        _radius,
        _useLocations,
        _parkedAir,
        _roads,
        _vehicleObjectType
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
    private _type = "MOVE";
    private _speed = "LIMITED";
    private _formation = "COLUMN";

    for "_i" from 0 to 4 do {
        if (count _locations > 0) then {
            private _location = selectRandom _locations;
            
            _locations deleteAt (_locations find _location);
            _pos = position _location;

            if (_debug) then {
                ["ALIVE_fnc_ambientMovement selected the location %1 at %2 as waypoint-index %3 for profileID %4!",_location,_pos,_i,_profileID] call ALiVE_fnc_Dump;
            };
        } else {
            //to be done: min distance to avoid waypoints too close together
            _pos = [_startPos,_radius] call CBA_fnc_RandPos;

            if (surfaceIsWater _pos) then {
                _pos = [_pos] call ALiVE_fnc_getClosestLand;
            };

            if (_debug) then {
                ["ALIVE_fnc_ambientMovement didn't find have locations available on waypoint-index %2 for profileID %3! Selecting random position %1!",_pos,_i,_profileID] call ALiVE_fnc_Dump;
            };
        };

        if (_roads) then {
            private _roadsArray = _pos nearRoads 200;

            if (count _roadsArray > 0) then {
                _pos = getposATL (selectRandom _roadsArray);

                if (_debug) then {
                    ["ALIVE_fnc_ambientMovement selected a road at %1 as waypoint-index %2 for profileID %3!",_pos,_i, _profileID] call ALiVE_fnc_Dump;
                };
            } else {
                //For ambientmovement keep motorized, mechanized or armored groups on road or default to startposition (which is likely near a road) 
                _pos = _startPos;

                if (_debug) then {
                    ["ALIVE_fnc_ambientMovement has no roads on waypoint-index %2 for profileID %3! Defaulting to startposition %1!",_pos,_i, _profileID] call ALiVE_fnc_Dump;
                };
            };
        };

        //Loop last Waypoint
        if (_i == 4) then {_pos = _startPos; _type = "CYCLE"};

        _profileWaypoint = [_pos, 20, _type, _speed, 50, [], _formation, "NO CHANGE", _behaviour] call ALIVE_fnc_createProfileWaypoint;
        [_profileWaypoint,"statements",["true","_disableSimulation = true;"]] call ALIVE_fnc_hashSet;
        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
    };
};