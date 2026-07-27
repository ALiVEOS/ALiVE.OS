#include "\x\alive\addons\sys_profile\script_component.hpp"
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
    private _waypointType = [_x,"type",""] call ALiVE_fnc_hashGet;

    if (_waypointType != "CYCLE") then {
        [_x,_group,_forEachIndex == 0] call ALIVE_fnc_profileWaypointToWaypoint;
    } else {
        _cycleWaypoints pushBack _x;
    };
} forEach _waypoints;

// add cycle waypoints at the end to avoid stuck groups
{
    [_x,_group,_forEachIndex == 0] call ALIVE_fnc_profileWaypointToWaypoint;
} forEach _cycleWaypoints;
