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

params ["_waypoints","_group"];

private _cycleWaypoints = [];

// add all waypoints but cycle first
{
    private _waypoint = _x;
    private _waypointType = [_waypoint,"type",""] call ALiVE_fnc_HashGet;

    if (_waypointType != "CYCLE") then {
        if (_forEachIndex == 0) then {
            // set first waypoint as current
            [_waypoint, _group, true] call ALIVE_fnc_profileWaypointToWaypoint;
        } else {
            [_waypoint, _group] call ALIVE_fnc_profileWaypointToWaypoint;
        };
    } else {
        _cycleWaypoints pushback _waypoint;
    };
} forEach _waypoints;

// add cycle waypoints at the end to avoid stuck groups
{
    private _cycleWaypoint = _x;

    if (_forEachIndex == 0) then {
        // set first waypoint as current
        [_cycleWaypoint, _group, true] call ALIVE_fnc_profileWaypointToWaypoint;
    } else {
        [_cycleWaypoint, _group] call ALIVE_fnc_profileWaypointToWaypoint;
    };
} forEach _cycleWaypoints;