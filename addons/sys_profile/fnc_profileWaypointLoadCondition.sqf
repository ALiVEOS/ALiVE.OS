#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileWaypointLoadCondition);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileWaypointLoadCondition

Description:
Native LOAD waypoint condition. Resolves the crew profile and tagged profile
waypoint, then processes loading on the group owner's machine. The native waypoint
stays pending until all passengers have boarded. Profile waypoints remain stored
while the group is active, so the tag identifies the correct LOAD along the route.

Parameters:
Object - Group leader (this in the native waypoint condition)
String - ALiVE waypoint name

Returns:
Boolean - Whether loading has completed. Missing profiles or waypoints return false.
---------------------------------------------------------------------------- */

params ["_leader", "_waypointName"];

if (isNil "ALIVE_profileHandler") exitWith {false};
private _profilesById = [ALIVE_profileHandler, "profilesById"] call ALIVE_fnc_hashGet;
private _crewProfile = _profilesById get (_leader getVariable ["profileID", ""]);
if (isNil "_crewProfile" || {!(_crewProfile select 2 select 1)}
    || {(_crewProfile select 2 select 13) != group _leader}
) exitWith {false};

private _waypoints = _crewProfile select 2 select 16;
private _index = _waypoints findIf {
    ([_x, "name"] call ALIVE_fnc_hashGet) == _waypointName
};
if (_index == -1) exitWith {false};

[_crewProfile, _waypoints select _index] call ALIVE_fnc_profileWaypointLoad
