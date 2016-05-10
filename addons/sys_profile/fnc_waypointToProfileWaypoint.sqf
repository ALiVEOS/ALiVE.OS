#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(waypointToProfileWaypoint);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_waypointToProfileWaypoint

Description:
Takes a real waypoint and creates a profile waypoint

Parameters:
Waypoint - The waypoint

Returns:
A profile waypoint

Examples:
(begin example)
_result = [_waypoint] call ALIVE_fnc_waypointToProfileWaypoint;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_waypoint","_currentWaypoint","_waypoint","_position","_radius","_type","_formation","_behaviour",
"_combatMode","_speed","_completionRadius","_timeout","_description","_statements","_profileWaypoint"];
	
_waypoint = _this select 0;

if (isnil "_waypoint") exitwith {};

_position = waypointPosition _waypoint;
_radius = 0;
_type = waypointType _waypoint;
_speed = waypointSpeed _waypoint;
_completionRadius = waypointCompletionRadius _waypoint;
_timeout = waypointTimeout _waypoint;
_formation = waypointFormation _waypoint;
_combatMode = waypointCombatMode _waypoint;
_behaviour = waypointBehaviour _waypoint;
_description = waypointDescription _waypoint;
_statements = waypointStatements _waypoint;

_profileWaypoint = [] call ALIVE_fnc_hashCreate;
[_profileWaypoint,"position",_position] call ALIVE_fnc_hashSet;
[_profileWaypoint,"radius",_radius] call ALIVE_fnc_hashSet;
[_profileWaypoint,"type",_type] call ALIVE_fnc_hashSet;
[_profileWaypoint,"speed",_speed] call ALIVE_fnc_hashSet;
[_profileWaypoint,"completionRadius",_completionRadius] call ALIVE_fnc_hashSet;
[_profileWaypoint,"timeout",_timeout] call ALIVE_fnc_hashSet;
[_profileWaypoint,"formation",_formation] call ALIVE_fnc_hashSet;
[_profileWaypoint,"combatMode",_combatMode] call ALIVE_fnc_hashSet;
[_profileWaypoint,"behaviour",_behaviour] call ALIVE_fnc_hashSet;
[_profileWaypoint,"description",_description] call ALIVE_fnc_hashSet;
[_profileWaypoint,"attachVehicle",""] call ALIVE_fnc_hashSet;
[_profileWaypoint,"statements",_statements] call ALIVE_fnc_hashSet;

//["wp to p wp"] call ALIVE_fnc_dump;
//_profileWaypoint call ALIVE_fnc_inspectHash;

_profileWaypoint