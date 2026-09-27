#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileWaypointLoadReset);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileWaypointLoadReset

Description:
Invalidates a LOAD visit on completion or route replacement. Native activation
statements run globally; only the group owner consumes a named visit. The server
also clears its dispatch state and releases any helicopter waiting for this visit.

Parameters:
Group - Crew group
String - Completed waypoint tag, or empty for route cleanup (optional)
Boolean - Invalidate the visit; false only clears server results/orders (optional)
---------------------------------------------------------------------------- */

params ["_group", ["_waypointName", ""], ["_resetVisit", true]];
if (isNull _group || {!isServer && {!local _group}}) exitWith {};
private _visit = _group getVariable ["ALIVE_profileLoadVisit", ["", 0]];
if (_waypointName != "" && {!local _group || {(_visit select 0) != _waypointName}}) exitWith {};

if (_resetVisit && {!isNil {_group getVariable "ALIVE_profileLoadVisit"}}) then {
    _group setVariable ["ALIVE_profileLoadVisit", ["", (_visit select 1) + 1], true];
};
if (!isServer) exitWith {};

private _orders = _group getVariable ["ALIVE_profileLoadOrders", []];
if (_orders isNotEqualTo [] && {(_orders select 5) == "GET IN"}) then {
    [_orders select 3, "NONE", _group, _orders select 0] call ALIVE_fnc_profileWaypointLoadLand;
};
// NONE retries are retained by profileWaypointLoadLand after this state is cleared.
_group setVariable ["ALIVE_profileLoadOrders", nil];
if (!isNil {_group getVariable "ALIVE_profileLoadResult"}) then {
    _group setVariable ["ALIVE_profileLoadResult", nil, true];
};
