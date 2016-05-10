#include <\x\alive\addons\mil_command\script_component.hpp>
SCRIPT(SeaPatrol);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_SeaPatrol

Description:
Ambient sea patrol movement command

Parameters:
Profile - profile
Args - array (SCALAR - radius, STRING - behaviour, ARRAY - objective pos)

Returns:

Examples:
(begin example)
[_profile, [1000, "SAFE", _objective]] call ALiVE_fnc_seaPatrol;
(end)

See Also:

Author:
Tupolov
---------------------------------------------------------------------------- */
private ["_profile","_params","_startPos","_type","_speed","_formation","_behaviour","_profileWaypoint","_vehiclesInCommandOf","_radius","_gpos","_debug","_objective","_isDiverTeam","_debugColor","_profileSide"];
_profile = _this select 0;
_params = _this select 1;

if (typename _params == "ARRAY") then {
    _radius = _params select 0;
    _behaviour = _params select 1;
    _objective = _params select 2;
} else {
    _radius = 1000;
    _behaviour = "AWARE";
    _objective = [_profile,"position"] call ALiVE_fnc_HashGet;
};

_debug = false;

//defaults
_startPos = [_profile,"position"] call ALiVE_fnc_HashGet;
_type = "MOVE";
_speed = "LIMITED";
_formation = "COLUMN";


_profileSide = [_profile,"side"] call ALIVE_fnc_hashGet;

switch(_profileSide) do {
	case "EAST":{
		_debugColor = "ColorRed";
	};
	case "WEST":{
		_debugColor = "ColorBlue";
	};
	case "CIV":{
		_debugColor = "ColorYellow";
	};
	case "GUER":{
		_debugColor = "ColorGreen";
	};
	default {
		_debugColor = "ColorRed";
	};
};

// Add startpoint as waypoint
_profileWaypoint = [_startPos, 15, _type, _speed, 30, [], _formation, "NO CHANGE", _behaviour] call ALIVE_fnc_createProfileWaypoint;
[_profileWaypoint,"statements",["true","_disableSimulation = true;"]] call ALIVE_fnc_hashSet;
[_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

if (_debug) then {
	[str(random 1000), _startPos, "ICON",[1,1],"COLOR:","ColorGreen","TYPE:","mil_dot","TEXT:",format ["Marine-%1-START",[_profile,"profileID"] call ALIVE_fnc_hashGet]] call CBA_fnc_createMarker;
};


// Adjust patrol radius based on vehicle availability
_vehiclesInCommandOf = [_profile,"vehiclesInCommandOf",[]] call ALIVE_fnc_HashGet;
if (count _vehiclesInCommandOf > 0) then {

     _radius = 1000;
     _isDiverTeam = false;

} else { // Diver Team - get them to visit the objective too.

    _radius = 500;
    _speed = "NORMAL";
    _isDiverTeam = true;

    // Add the objective location as one of the first waypoints
    _profileWaypoint = [_objective, 15, _type, _speed, 100, [], _formation, "NO CHANGE", _behaviour] call ALIVE_fnc_createProfileWaypoint;
    [_profileWaypoint,"statements",["true","_disableSimulation = true;"]] call ALIVE_fnc_hashSet;
    [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

	if (_debug  && count ([_profile,"waypoints",[]] call ALiVE_fnc_HashGet) < 5) then {
    	[str(random 1000), _objective, "ICON",[1,1],"COLOR:",_debugColor,"TYPE:","mil_dot","TEXT:",format ["Marine-%1-%2",[_profile,"profileID"] call ALIVE_fnc_hashGet, count ([_profile,"waypoints",[]] call ALiVE_fnc_HashGet)]] call CBA_fnc_createMarker;
    };
};

// Find other waypoints in the sea
while {count ([_profile,"waypoints",[]] call ALiVE_fnc_HashGet) < 5} do {
	private ["_lastpos","_profileWaypoint"];

	if (isNil "_gpos") then {
		_lastpos = _startPos;
	} else {
		_lastpos = _gpos;
	};

    // Find a new position in the sea (doesn't have to be closest)
    _gpos = [_startPos, false] call ALiVE_fnc_getClosestSea;

    if !(surfaceIsWater _gpos) then {

		if (_debug) then {
		    ["ALIVE SEA PATROL - ALERT NON WATER POSITION Pos: %1 - On Water: %2",  _gpos, surfaceIsWater _gpos] call ALIVE_fnc_dump;
		};
        // Find a position that is definitely in water
        _gpos = [_gpos, 15, _radius, 20, 2, 10, 0, [], [_startPos,_startPos]] call bis_fnc_findSafePos;
    };

    //Loop last Waypoint
    if (count ([_profile,"waypoints",[]] call ALiVE_fnc_HashGet) == 4) then {_gpos = _startPos; _type = "CYCLE"};

    if (surfaceIsWater _gpos) then {

        // Check you don't have to cross land to get there in a boat
        if (!terrainIntersectASL [_lastpos,_gpos] || _isDiverTeam) then {

            _profileWaypoint = [_gpos, 15, _type, _speed, 100, [], _formation, "NO CHANGE", _behaviour] call ALIVE_fnc_createProfileWaypoint;
            [_profileWaypoint,"statements",["true","_disableSimulation = true;"]] call ALIVE_fnc_hashSet;
            [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

			if (_debug  && count ([_profile,"waypoints",[]] call ALiVE_fnc_HashGet) < 5) then {
            	[str(random 1000), _gpos, "ICON",[1,1],"COLOR:",_debugColor,"TYPE:","mil_dot","TEXT:",format ["Marine-%1-%2",[_profile,"profileID"] call ALIVE_fnc_hashGet, count ([_profile,"waypoints",[]] call ALiVE_fnc_HashGet)]] call CBA_fnc_createMarker;
            };
		} else {
			if (_debug) then {
        		["ALIVE AMB SEA PATROL [WP] - ALERT WAYPOINT MUST CROSS LAND LastPos: %1 - New Pos: %2",  _lastpos, _gpos] call ALIVE_fnc_dump;
			};
		};

    } else {
		if (_debug) then {
        	["ALIVE AMB SEA PATROL [WP] - ALERT NON WATER POSITION Pos: %1 - On Water: %2",  _gpos, surfaceIsWater _gpos] call ALIVE_fnc_dump;
        };
    };
};

if (_debug) then {
	["ALIVE CP [%1] - Placing Sea Patrol: %2 at %3. On water: %4 with %5 waypoints",_faction, _seaPatrolGroup, _startPos, surfaceIsWater _startPos, count ([_profile,"waypoints",[]] call ALiVE_fnc_HashGet)] call ALIVE_fnc_dump;
};