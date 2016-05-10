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

private ["_args","_debug","_waypoints","_unit","_profile","_vehiclesInCommandOf","_vehiclesInCargoOf","_obj",
"_leader","_pos","_radius","_positions","_assignments","_profileWaypoint","_savepos","_type","_speed","_formation",
"_behaviour","_type","_objs","_parkedAir","_locations","_vehicleProfile","_vehicleObjectType","_roads"];

_profile = _this select 0;
_params = _this select 1;

if (typename _params == "SCALAR") then {
    _radius = _params;
    _behaviour = "SAFE";
} else {
    _radius = _params select 0;
    _behaviour = _params select 1;
};

_pos = [_profile,"position"] call ALiVE_fnc_HashGet;
_waypoints = [_profile,"waypoints",[]] call ALiVE_fnc_HashGet;
_vehiclesInCommandOf = [_profile,"vehiclesInCommandOf",[]] call ALIVE_fnc_HashGet;

_debug = true;
_roads = false;

if (count _vehiclesInCommandOf > 0) then {
	{
		_vehicleProfile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
        
        if !(isnil "_vehicleProfile") then {
			_vehicleObjectType = _vehicleProfile select 2 select 6; //[_profile,"objectType"] call ALIVE_fnc_hashGet;

			switch (_vehicleObjectType) do {
                case ("Car") : {
                    _radius = 800;
                    _locations = true;
                    _roads = true;
                };
                case ("Tank") : {
                    _radius = 1000;
                    _locations = true;
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

//if static
if ((count _waypoints == 0) && {isnil "_parkedAir"}) then {
    //get locations in case
    if !(isnil "_locations") then {_locations = nearestLocations [_pos, ["NameCity","NameVillage","NameLocal"], _radius]} else {_locations = []};
    
    //defaults
    _startPos = _pos;
    _type = "MOVE";
    _speed = "LIMITED";
    _formation = "COLUMN";
    
	for "_i" from 0 to 4 do {
        if (count _locations > 0) then {
            private ["_location"];
            _location = _locations call BIS_fnc_SelectRandom;
            _locations = _locations - [_location];
            _pos = position _location;
        } else {
            _pos = [_startPos,_radius] call CBA_fnc_RandPos;
            if (surfaceIsWater _pos) then {
                _pos = [_pos] call ALiVE_fnc_getClosestLand;
            };
        };
        
        if (_roads) then {
        	_roadsArray = _pos nearRoads 200;
            
            if (count _roadsArray > 0) then {
                _pos = getposATL (_roadsArray call BIS_fnc_SelectRandom);
            };    
        };
        
        //Loop last Waypoint
        if (_i == 4) then {_pos = _startPos; _type = "CYCLE"};

        _profileWaypoint = [_pos, 20, _type, _speed, 50, [], _formation, "NO CHANGE", _behaviour] call ALIVE_fnc_createProfileWaypoint;
        [_profileWaypoint,"statements",["true","_disableSimulation = true;"]] call ALIVE_fnc_hashSet;
        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
	};
};
