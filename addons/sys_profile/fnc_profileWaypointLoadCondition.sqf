#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileWaypointLoadCondition);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileWaypointLoadCondition

Description:
Native LOAD condition on the crew group's owner. Announces each visit once, then
reads the server's matching completion result. No profile registry is needed on
this machine. Repeated condition evaluations do not repeat assignments or orders.

Parameters:
Object - Group leader (this in the native waypoint condition)
String - ALiVE waypoint name

Returns:
Boolean - Whether the server has completed this LOAD visit.
---------------------------------------------------------------------------- */

params ["_leader", "_waypointName"];
private _group = group _leader;
if (isNull _group || {!local _group}
    || {waypointName [_group, currentWaypoint _group] != _waypointName}
) exitWith {false};

private _visit = _group getVariable ["ALIVE_profileLoadVisit", ["", 0]];
if ((_visit select 0) != _waypointName) then {
    _visit = [_waypointName, (_visit select 1) + 1];
    _group setVariable ["ALIVE_profileLoadVisit", _visit, true];
};
(_group getVariable ["ALIVE_profileLoadResult", []]) isEqualTo [_visit, true]
