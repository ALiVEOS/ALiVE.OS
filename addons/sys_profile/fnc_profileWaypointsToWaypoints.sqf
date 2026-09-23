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
private _timestamp = diag_tickTime toFixed 6;

// add all waypoints but cycle first
{
    private _waypointType = [_x,"type",""] call ALiVE_fnc_hashGet;

    if (_waypointType != "CYCLE") then {
        [
            _x,
            _group,
            _forEachIndex == 0,
            _forEachIndex,
            _timestamp
        ] call ALIVE_fnc_profileWaypointToWaypoint;
    } else {
        _cycleWaypoints pushBack [_x,_forEachIndex];
    };
} forEach _waypoints;

// add cycle waypoints at the end to avoid stuck groups
{
    [
        _x select 0,
        _group,
        _forEachIndex == 0,
        _x select 1,
        _timestamp
    ] call ALIVE_fnc_profileWaypointToWaypoint;
} forEach _cycleWaypoints;
