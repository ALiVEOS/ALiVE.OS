#include <\x\alive\addons\mil_command\script_component.hpp>
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

private ["_radius","_behaviour"];
if (_params isequaltype 0) then {
    _radius = _params;
    _behaviour = "SAFE";
} else {
    _radius = _params select 0;
    _behaviour = _params select 1;
};

private _profilePosition = [_profile,"position"] call ALiVE_fnc_HashGet;
private _waypoints = [_profile,"waypoints",[]] call ALiVE_fnc_HashGet;
private _vehiclesInCommandOf = [_profile,"vehiclesInCommandOf",[]] call ALIVE_fnc_HashGet;

private _debug = true;
private _useRoads = false;
private _useLocations = false;

{
    private _vehicleProfile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;

    if !(isnil "_vehicleProfile") then {
        private _vehicleObjectType = _vehicleProfile select 2 select 6; //[_profile,"objectType"] call ALIVE_fnc_hashGet;

        switch (_vehicleObjectType) do {
            case ("Car") : {
                _radius = 800;
                _useLocations = true;
                _useRoads = true;
            };
            case ("Tank") : {
                _radius = 1000;
                _useLocations = true;
                _useRoads = true;
            };
            case ("Helicopter") : {
                if (_profilePosition select 2 < 5) then {
                    _parkedAir = true;
                } else {
                    _radius = 1500;
                };
            };
            case ("Plane") : {
                if (_profilePosition select 2 < 5) then {
                    _parkedAir = true;
                } else {
                    _radius = 2000;
                };
            };
        };
    };
} forEach _vehiclesInCommandOf;

// if not moving

if ((count _waypoints == 0) && { isnil "_parkedAir" }) then {
    //get locations in case
    private _locations = if (_useLocations) then {
        nearestLocations [_profilePosition, ["NameCity","NameVillage","NameLocal"], _radius];
    } else {
        []
    };

    //defaults
    private _startPos = _profilePosition;
    private _type = "MOVE";
    private _speed = "LIMITED";
    private _formation = "COLUMN";

    // generates _waypointsToGenerate waypoints
    // and one cycle waypoint
    private _waypointsToGenerate = 5;
    for "_i" from 0 to _waypointsToGenerate do {
        private _waypointPos = _startPos;

        if (_i == _waypointsToGenerate) then {
            _type = "CYCLE";
        } else {
            if (count _locations > 0) then {
                private _location = selectRandom _locations;
                _locations = _locations - [_location];

                _waypointPos = position _location;
            } else {
                _waypointPos = [_startPos,_radius] call CBA_fnc_RandPos;
                if (surfaceIsWater _waypointPos) then {
                    _waypointPos = [_waypointPos] call ALiVE_fnc_getClosestLand;
                };
            };

            if (_useRoads) then {
                private _roadsArray = _waypointPos nearRoads 200;

                if !(_roadsArray isequalto []) then {
                    private _road = selectrandom _roadsArray;
                    _waypointPos = getposATL _road;
                };
            };
        };

        private _profileWaypoint = [_waypointPos, 20, _type, _speed, 50, [], _formation, "NO CHANGE", _behaviour] call ALIVE_fnc_createProfileWaypoint;
        [_profileWaypoint,"statements",["true","_disableSimulation = true;"]] call ALIVE_fnc_hashSet;
        [_profile,"addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
    };
};
