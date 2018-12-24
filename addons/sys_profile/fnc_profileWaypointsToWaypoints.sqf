#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profileWaypointsToWaypoints);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileWaypointsToWaypoints

Description:
Takes profile waypoints and creates a real waypoints

Parameters:
Array - profile waypoints
Group - The group

Returns:

Examples:
(begin example)
_result = [_profileWaypoints, _group] call ALIVE_fnc_profileWaypointsToWaypoints;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

params ["_profile","_waypoints","_group"];

private _waypointsCompleted = _profile select 2 select 17;
private _currentWaypointIndex = count _waypointsCompleted;

{
    private _waypoint = _x;
    private _current = _forEachIndex == _currentWaypointIndex;
    [_waypoint, _group, _current] call ALIVE_fnc_profileWaypointToWaypoint;
} forEach (_waypointsCompleted + _waypoints);

_waypointsCompleted resize 0;