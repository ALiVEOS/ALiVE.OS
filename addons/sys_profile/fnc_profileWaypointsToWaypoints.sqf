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

private ["_waypoints","_group","_cycleWaypoints"];
	
_waypoints = _this select 0;
_group = _this select 1;

_cycleWaypoints = [];

//Add all waypoints but cycle first
{
    if !(([_x,"type",""] call ALiVE_fnc_HashGet) == "CYCLE") then {
		if(_forEachIndex == 0) then {
			[_x, _group, true] call ALIVE_fnc_profileWaypointToWaypoint;
		} else {
			[_x, _group] call ALIVE_fnc_profileWaypointToWaypoint;
		};
    } else {
        _cycleWaypoints pushback _x;
    };
} forEach _waypoints;

//Add cycle waypoints at the end to avoid stuck groups
{
	if(_forEachIndex == 0) then {
		[_x, _group, true] call ALIVE_fnc_profileWaypointToWaypoint;
	} else {
		[_x, _group] call ALIVE_fnc_profileWaypointToWaypoint;
	};
} forEach _cycleWaypoints;
