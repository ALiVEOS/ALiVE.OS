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

params ["_profile","_params"];

private _debug = false;

private _profileID = [_profile,"profileID"] call ALiVE_fnc_HashGet;
private _startPos = [_profile,"position"] call ALiVE_fnc_HashGet;
private _profileSide = [_profile,"side"] call ALIVE_fnc_hashGet;

if (_debug) then {
    ["ALIVE SEA PATROL - Starting Sea Patrol for: %1 on water (%3) with params: %2",  _profileID, _params, surfaceIsWater _startPos] call ALIVE_fnc_dump;
};

//defaults
private _type = "MOVE";
private _speed = "LIMITED";
private _formation = "COLUMN";

private ["_radius","_behaviour","_objective"];
if (_params isequaltype []) then {
    _radius = _params select 0;
    _behaviour = _params select 1;
    _objective = _params select 2;
} else {
    _radius = 1000;
    _behaviour = "AWARE";
    _objective = [_profile,"position"] call ALiVE_fnc_HashGet;
};


private _debugColor = switch(_profileSide) do {
    case "EAST":{
        "ColorRed";
    };
    case "WEST":{
        "ColorBlue";
    };
    case "CIV":{
        "ColorYellow";
    };
    case "GUER":{
        "ColorGreen";
    };
    default {
        "ColorRed";
    };
};

// Add startpoint as waypoint
private _profileWaypoint = [_startPos, 15, _type, _speed, 30, [], _formation, "NO CHANGE", _behaviour] call ALIVE_fnc_createProfileWaypoint;
[_profileWaypoint,"statements",["true","_disableSimulation = true;"]] call ALIVE_fnc_hashSet;
[_profile,"addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

if (_debug) then {
    [str(random 1000), _startPos, "ICON",[1,1],"COLOR:","ColorGreen","TYPE:","mil_dot","TEXT:",format ["Marine-%1-START",[_profile,"profileID"] call ALIVE_fnc_hashGet]] call CBA_fnc_createMarker;
};

// Adjust patrol radius based on vehicle availability
private _isDiverTeam = false;
private _vehiclesInCommandOf = [_profile,"vehiclesInCommandOf",[]] call ALIVE_fnc_HashGet;
if (count _vehiclesInCommandOf > 0) then {
     _radius = 1000;
     _isDiverTeam = false;
} else {
    // Diver Team - get them to visit the objective too
    _radius = 500;
    _speed = "NORMAL";
    _isDiverTeam = true;

    // Add the objective location as one of the first waypoints
    private _profileWaypoint = [_objective, 15, _type, _speed, 100, [], _formation, "NO CHANGE", _behaviour] call ALIVE_fnc_createProfileWaypoint;
    [_profileWaypoint,"statements",["true","_disableSimulation = true;"]] call ALIVE_fnc_hashSet;
    [_profile,"addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

    if (_debug  && { count ([_profile,"waypoints",[]] call ALiVE_fnc_HashGet) < 5 }) then {
        [str(random 1000), _objective, "ICON",[1,1],"COLOR:",_debugColor,"TYPE:","mil_dot","TEXT:",format ["Marine-%1-%2",[_profile,"profileID"] call ALIVE_fnc_hashGet, count ([_profile,"waypoints",[]] call ALiVE_fnc_HashGet)]] call CBA_fnc_createMarker;
    };
};

// Find other waypoints in the sea
private "_gpos";
private _profileWaypoints = [_profile,"waypoints",[]] call ALiVE_fnc_HashGet;
private _waypointsToGenerate = 4;
while {count _profileWaypoints <= _waypointsToGenerate + 1} do {

    private _last = false;

    private "_lastpos";
    if (isnil "_gpos") then {
        _lastpos = +_startPos;
    } else {
        _lastpos = +_gpos;
    };

    // Find a new position in the sea (doesn't have to be closest)
    _gpos = [_startPos, false] call ALiVE_fnc_getClosestSea;

    if !(surfaceIsWater _gpos) then {

        if (_debug) then {
            ["ALIVE SEA PATROL - ALERT NON WATER INITIAL POSITION Pos: %1 - On Water: %2",  _gpos, surfaceIsWater _gpos] call ALIVE_fnc_dump;
        };

        // Find a position that is definitely in water
        _gpos = [_gpos, 15, _radius, 20, 2, 10, 0, [], [_startPos,_startPos]] call bis_fnc_findSafePos;

        // Add 3rd element because BIS_fnc_findSafePos returns an array of 2 elements...
        _gpos set [2, 0];
    };

    // if its still not water, then go back to start position.
    if !(surfaceIsWater _gpos) then {
        _gpos = +_startPos;
    };

    // cycle last Waypoint
    if (count _profileWaypoints == _waypointsToGenerate + 1) then {
        _gpos = +_startPos;
        _type = "CYCLE";
        _last = true;
    };

    if (surfaceIsWater _gpos || (_isDiverTeam && _last) ) then {

        // Check you don't have to cross land to get there in a boat
        if (!terrainIntersectASL [_lastpos,_gpos] || _isDiverTeam) then {

            private _profileWaypoint = [_gpos, 15, _type, _speed, 100, [], _formation, "NO CHANGE", _behaviour] call ALIVE_fnc_createProfileWaypoint;
            [_profileWaypoint,"statements",["true","_disableSimulation = true;"]] call ALIVE_fnc_hashSet;
            [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

            if (_debug  && count ([_profile,"waypoints",[]] call ALiVE_fnc_HashGet) < 5) then {
                [str(random 1000), _gpos, "ICON",[1,1],"COLOR:",_debugColor,"TYPE:","mil_dot","TEXT:",format ["Marine-%1-%2",[_profile,"profileID"] call ALIVE_fnc_hashGet, count _profileWaypoints]] call CBA_fnc_createMarker;
            };

        } else {
            if (_debug) then {
                ["ALIVE AMB SEA PATROL [WP] - ALERT WAYPOINT MUST CROSS LAND LastPos: %1 - New Pos: %2",  _lastpos, _gpos] call ALIVE_fnc_dump;
            };
        };

    } else {

        // start pos was not in water?
        if (_debug) then {
            ["ALIVE AMB SEA PATROL [WP] - ALERT NON WATER FINAL POSITION Pos: %1 - On Water: %2",  _gpos, surfaceIsWater _gpos] call ALIVE_fnc_dump;
        };

        _radius = _radius * 1.1;

    };
};

if (_debug) then {
    ["ALIVE %1 - Placing Sea Patrol: %2 at %3. On water: %4 with %5 waypoints",_profileSide, _profileID, _startPos, surfaceIsWater _startPos, count ([_profile,"waypoints",[]] call ALiVE_fnc_HashGet)] call ALIVE_fnc_dump;
};
