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

private _waypoint = _this select 0;

if (isnil "_waypoint") exitwith {};

private _position = waypointPosition _waypoint;
private _radius = 0;
private _type = waypointType _waypoint;
private _speed = waypointSpeed _waypoint;
private _completionRadius = waypointCompletionRadius _waypoint;
private _timeout = waypointTimeout _waypoint;
private _formation = waypointFormation _waypoint;
private _combatMode = waypointCombatMode _waypoint;
private _behaviour = waypointBehaviour _waypoint;
private _description = waypointDescription _waypoint;
private _statements = waypointStatements _waypoint;
private _name = waypointName _waypoint;

private _profileWaypoint = [
    _position,
    _radius,
    _type,
    _speed,
    _completionRadius,
    _timeout,
    _formation,
    _combatMode,
    _behaviour,
    _description,
    "",
    _statements,
    _name
] call ALiVE_fnc_createProfileWaypoint;

//["wp to p wp"] call ALIVE_fnc_dump;
//_profileWaypoint call ALIVE_fnc_inspectHash;

_profileWaypoint