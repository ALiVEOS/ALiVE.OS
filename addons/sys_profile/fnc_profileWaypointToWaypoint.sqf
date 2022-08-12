#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileWaypointToWaypoint);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileWaypointToWaypoint

Description:
Takes a profile waypoint and creates a real waypoint

Parameters:
Hash - profile waypoint
Group - The group

Returns:
A waypoint

Examples:
(begin example)
_result = [_profileWaypoint, _group] call ALIVE_fnc_profileWaypointToWaypoint;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

params ["_profileWaypoint","_group",["_setCurrent", false]];

if (isnil "_profileWaypoint" || {!(_profileWaypoint isequaltype [])}) exitwith {
    ["- ALiVE_fnc_ProfileWaypointToWaypoint retrieved wrong input: %1!",_this] call ALiVE_fnc_dump;
};

private _position = [_profileWaypoint,"position"] call ALIVE_fnc_hashGet;
private _radius = [_profileWaypoint,"radius"] call ALIVE_fnc_hashGet;
private _type = [_profileWaypoint,"type"] call ALIVE_fnc_hashGet;
private _speed = [_profileWaypoint,"speed"] call ALIVE_fnc_hashGet;
private _completionRadius = [_profileWaypoint,"completionRadius"] call ALIVE_fnc_hashGet;
private _timeout = [_profileWaypoint,"timeout"] call ALIVE_fnc_hashGet;
private _formation = [_profileWaypoint,"formation"] call ALIVE_fnc_hashGet;
private _combatMode = [_profileWaypoint,"combatMode"] call ALIVE_fnc_hashGet;
private _behaviour = [_profileWaypoint,"behaviour"] call ALIVE_fnc_hashGet;
private _description = [_profileWaypoint,"description"] call ALIVE_fnc_hashGet;
private _attachVehicle = [_profileWaypoint,"attachVehicle"] call ALIVE_fnc_hashGet;
private _waypointStatements = [_profileWaypoint,"statements"] call ALIVE_fnc_hashGet;
private _waypointName = [_profileWaypoint,"name"] call ALiVE_fnc_hashGet;

// If the leader is in a land vehicle, snap waypoints to nearest road within 200m
if (
    !isNull (assignedVehicle leader _group) &&
    (assignedVehicle leader _group) isKindOf "LandVehicle"
) then {
    private _road = [_position, 200] call BIS_fnc_nearestRoad;
    if !(isNull _road) then {
        _position = (getPos _road) select [0, 2];
	_radius = -1;
    };
};

_position set [2,0];

private _waypoint = _group addWaypoint [_position, _radius];
_waypoint setWaypointDescription _description;
_waypoint setWaypointType _type;
_waypoint setWaypointFormation _formation;
_waypoint setWaypointBehaviour _behaviour;
_waypoint setWaypointCombatMode _combatMode;
_waypoint setWaypointSpeed _speed;
_waypoint setWaypointName _waypointName;

if (_completionRadius >= 0) then {
    _waypoint setWaypointCompletionRadius _completionRadius;
};

if ((count _timeout) == 3) then {
    _waypoint setWaypointTimeout _timeout;
};

if !(_attachVehicle == "") then {
    _waypoint waypointAttachVehicle _attachVehicle;
};

if (typeName _waypointStatements == "ARRAY") then {
    _waypoint setWaypointStatements _waypointStatements;
};

if (_setCurrent) then {
    _group setCurrentWaypoint _waypoint;
};

//["p wp to wp"] call ALIVE_fnc_dump;
//_profileWaypoint call ALIVE_fnc_inspectHash;

_waypoint
