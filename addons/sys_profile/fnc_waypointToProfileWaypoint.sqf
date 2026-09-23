#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(waypointToProfileWaypoint);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_waypointToProfileWaypoint

Description:
Takes a real waypoint and creates a profile waypoint

Parameters:
Waypoint - The waypoint
Hash - optional existing profile waypoint, already matched by the caller using its ALiVE name tag.
Its metadata is reused while the other settings are read from the Arma waypoint.
Waypoints without metadata leave data absent (nil) without allocating a HashMap.

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

params ["_waypoint","_existingProfileWaypoint"];

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

private _isALiVEWaypoint = (_name select [0,9]) == "alive_wp:";
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
    _statements
] call ALiVE_fnc_createProfileWaypoint;

if (!isNil "_existingProfileWaypoint") then {
    private _data = [_existingProfileWaypoint,"data"] call ALiVE_fnc_hashGet;
    if (!isNil "_data") then {
        // Reuse the existing HashMap by reference.
        [_profileWaypoint,"data",_data] call ALiVE_fnc_hashSet;
    };
};

if (_isALiVEWaypoint) then {
    [_profileWaypoint,"name",_name] call ALiVE_fnc_hashSet;
};

//["wp to p wp"] call ALIVE_fnc_dump;
//_profileWaypoint call ALIVE_fnc_inspectHash;

_profileWaypoint