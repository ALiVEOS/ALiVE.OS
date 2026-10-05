#include "\x\alive\addons\mil_command\script_component.hpp"
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
Jman
---------------------------------------------------------------------------- */
private ["_profile","_params","_startPos","_type","_speed","_formation","_behaviour","_vehiclesInCommandOf","_radius","_debug","_objective","_isDiverTeam","_debugColor","_profileSide"];

_profile = _this select 0;
_params = _this select 1;

_debug = false;

if (isnil "_profile") exitWith {};

private _profileID = [_profile,"profileID"] call ALiVE_fnc_HashGet;
_startPos = [_profile,"position"] call ALiVE_fnc_HashGet;
_profileSide = [_profile,"side"] call ALIVE_fnc_hashGet;

if (_debug) then {
    ["SEA PATROL - Starting Sea Patrol for: %1 on water (%3) with params: %2",  _profileID, _params, surfaceIsWater _startPos] call ALiVE_fnc_dump;
};

//defaults
_type = "MOVE";
_speed = "LIMITED";
_formation = "COLUMN";

if (typename _params == "ARRAY") then {
    _radius = _params select 0;
    _behaviour = _params select 1;
    _objective = _params select 2;
} else {
    _radius = 1000;
    _behaviour = "AWARE";
    _objective = [_profile,"position"] call ALiVE_fnc_HashGet;
};


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

// Validate hull clearance as well as water presence for boat patrols.
_vehiclesInCommandOf = [_profile,"vehiclesInCommandOf",[]] call ALIVE_fnc_HashGet;
_isDiverTeam = count _vehiclesInCommandOf == 0;
private _navalSettings = [missionNamespace getVariable ["ALiVE_pathfinding_seaLevel",0],
    (missionNamespace getVariable ["ALiVE_pathfinding_navalDepth",1]) max 0.1,
    (missionNamespace getVariable ["ALiVE_pathfinding_navalClearance",2.5]) max 0];
private _pointCache = createHashMap;
private _isWaterPosition = {
    if (_isDiverTeam) then {surfaceIsWater _this} else {
        [_this,_this,_navalSettings,[],_pointCache] call ALiVE_fnc_pathfinderNavalSegment
    }
};
private _pathfindingEnabled = [ALiVE_profileSystem,"pathfinding",false] call ALiVE_fnc_hashGet;
private _plannedWaypoints = count ([_profile,"waypoints",[]] call ALiVE_fnc_hashGet)
    + count ([_profile,"pendingWaypointPaths",[]] call ALiVE_fnc_hashGet);

// Ensure first start-WP is in water
if !(_startPos call _isWaterPosition) then {

    _startPos = [_startPos, 10, 50, 10, 2, 5 , 0, [], [_startPos,_startPos]] call BIS_fnc_findSafePos;

    if (_debug) then {
        ["SEA PATROL - Start-WP of Sea Patrol has not been in water! Switched position to be in water: %1 on water (%3) with params: %2",  _profileID, _params, surfaceIsWater _startPos] call ALiVE_fnc_dump;
    };
};

// Safe-position search does not guarantee naval depth or hull clearance.
if !(_startPos call _isWaterPosition) exitWith {};

private _addPatrolWaypoint = {
    params ["_position","_waypointType","_completionRadius"];
    private _placementRadius = 15;
    private _name = "";
    if (!_isDiverTeam && {!_pathfindingEnabled}) then {
        // Direct legs need the same placement and arrival policy as routed legs.
        _placementRadius = 0;
        _completionRadius = (missionNamespace getVariable ["ALiVE_pathfinding_navalCompletionRadius",1.5]) max 0.5 min 5;
        _name = "pathfound:naval";
    };
    private _waypoint = [_position, _placementRadius, _waypointType, _speed, _completionRadius, [], _formation,
        "NO CHANGE", _behaviour, "", "", ["true","_disableSimulation = true;"], _name] call ALIVE_fnc_createProfileWaypoint;
    [_profile, "addWaypoint", _waypoint] call ALIVE_fnc_profileEntity;
    _plannedWaypoints = _plannedWaypoints + 1;
};

[_startPos, _type, 30] call _addPatrolWaypoint;

if (_debug) then {
    [str(random 1000), _startPos, "ICON",[1,1],"COLOR:","ColorGreen","TYPE:","mil_dot_noShadow","TEXT:",format ["Sea patrol %1: start",[_profile,"profileID"] call ALIVE_fnc_hashGet]] call CBA_fnc_createMarker;
};

// Adjust patrol radius based on vehicle availability
if (!_isDiverTeam) then {

     _radius = 1000;
     _isDiverTeam = false;
} else { // Diver Team - get them to visit the objective too.

    _radius = 500;
    _speed = "NORMAL";
    _isDiverTeam = true;

    // Add the objective location as one of the first waypoints
    [_objective, _type, 100] call _addPatrolWaypoint;

    if (_debug  && count ([_profile,"waypoints",[]] call ALiVE_fnc_HashGet) < 5) then {
        [str(random 1000), _objective, "ICON",[1,1],"COLOR:",_debugColor,"TYPE:","mil_dot_noShadow","TEXT:",format ["Sea patrol %1: waypoint %2",[_profile,"profileID"] call ALIVE_fnc_hashGet, count ([_profile,"waypoints",[]] call ALiVE_fnc_HashGet)]] call CBA_fnc_createMarker;
    };
};

// Count requested orders, since pathfinding applies their nodes asynchronously.
// Keep the last accepted destination across iterations and bound failed probes.
private _lastpos = if (_isDiverTeam) then {+_objective} else {+_startPos};
private _attempts = 0;
while {_plannedWaypoints < 5 && {_attempts < 64}} do {
    private _gpos = [];
    private _last = false;
    _attempts = _attempts + 1;

    // Find a new position in the sea (doesn't have to be closest)
    _gpos = [_startPos, false] call ALiVE_fnc_getClosestSea;

    if !(_gpos call _isWaterPosition) then {

        if (_debug) then {
            ["SEA PATROL - ALERT NON WATER INITIAL POSITION Pos: %1 - On Water: %2",  _gpos, surfaceIsWater _gpos] call ALiVE_fnc_dump;
        };

        // Find a position that is definitely in water
        _gpos = [_gpos, 15, _radius, 20, 2, 10, 0, [], [_startPos,_startPos]] call bis_fnc_findSafePos;

        // Add 3rd element because BIS_fnc_findSafePos returns an array of 2 elements...
        _gpos set [2, 0];
    };

    // if its still not water, then go back to start position.
    if !(_gpos call _isWaterPosition) then {
        _gpos = +_startPos;
    };

    //Loop last Waypoint
    if (_plannedWaypoints == 4 || {_attempts == 64}) then {
        _gpos = +_startPos;
        _type = "CYCLE";
        _last = true;
    };

    if ((_gpos call _isWaterPosition) || (_isDiverTeam && _last)) then {

        // River bends need a routed connection, which the queued naval job finds.
        // Without pathfinding, accept only a directly navigable boat connection.
        if (_isDiverTeam || {_pathfindingEnabled} || {[_lastpos,_gpos,_navalSettings,[],_pointCache] call ALiVE_fnc_pathfinderNavalSegment}) then {

            [_gpos, _type, 100] call _addPatrolWaypoint;
            _lastpos = +_gpos;

            if (_debug  && count ([_profile,"waypoints",[]] call ALiVE_fnc_HashGet) < 5) then {
                [str(random 1000), _gpos, "ICON",[1,1],"COLOR:",_debugColor,"TYPE:","mil_dot_noShadow","TEXT:",format ["Sea patrol %1: waypoint %2",[_profile,"profileID"] call ALIVE_fnc_hashGet, count ([_profile,"waypoints",[]] call ALiVE_fnc_HashGet)]] call CBA_fnc_createMarker;
            };
        } else {
            if (_debug) then {
                ["AMB SEA PATROL [WP] - ALERT WAYPOINT MUST CROSS LAND LastPos: %1 - New Pos: %2",  _lastpos, _gpos] call ALiVE_fnc_dump;
            };
        };

    } else {
        // start pos was not in water?
        if (_debug) then {
            ["AMB SEA PATROL [WP] - ALERT NON WATER FINAL POSITION Pos: %1 - On Water: %2",  _gpos, surfaceIsWater _gpos] call ALiVE_fnc_dump;
        };
        _radius = _radius * 1.1;

    };
};

if (_debug) then {
    ["%1 - Placing Sea Patrol: %2 at %3. On water: %4 with %5 waypoints",_profileSide, _profileID, _startPos, surfaceIsWater _startPos, count ([_profile,"waypoints",[]] call ALiVE_fnc_HashGet)] call ALiVE_fnc_dump;
};
