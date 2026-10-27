#include "\x\alive\addons\sup_player_resupply\script_component.hpp"
SCRIPT(hubRequest);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_hubRequest

Description:
The only way a player's machine asks the server to change a Logistics Hub, and only for what a player
may ask: an admin's change to who may collect. It finds who is asking from the connection, never from
the request, and passes them on as the caller. Collecting a requisition goes through Military
Logistics like any other tablet requisition.

Call it unscheduled:
    [_op, _args] remoteExecCall ["ALIVE_fnc_hubRequest", 2];
A mission that limits remoteExec through CfgRemoteExec must allow ALIVE_fnc_hubRequest.

Parameters:
String - The operation
Array - Its arguments

Returns:
Nothing

Examples:
(begin example)
// an admin: only group leaders may collect at the hub being looked at; "" for every hub
["permissions", ["LEADER", "", cursorObject call BIS_fnc_netId]] remoteExecCall ["ALIVE_fnc_hubRequest", 2];
(end)

Author:
Jman
---------------------------------------------------------------------------- */

if (!isServer) exitWith {};
if !(_this isEqualType [] && {count _this == 2} && {(_this select 0) isEqualType ""} && {(_this select 1) isEqualType []}) exitWith {};
params ["_op", "_args"];

if !(_op in ["permissions"]) exitWith {
    ["ALiVE Logistics Hub - refused a request for %1 from machine %2: not something a player can ask for", _op, remoteExecutedOwner] call ALiVE_fnc_dumpR;
};

// Who is asking. On a hosted server the host's own requests come from machine 0.
private _owner = remoteExecutedOwner;
private _caller = objNull;
if (_owner == 0 || {_owner == clientOwner}) then {
    if (hasInterface) then { _caller = player };
} else {
    private _i = allPlayers findIf { owner _x == _owner && {isPlayer _x} && {getPlayerUID _x != ""} };
    if (_i > -1) then { _caller = allPlayers select _i };
};
if (isNull _caller) exitWith {
    ["ALiVE Logistics Hub - refused a request (%1) from machine %2: not a player", _op, _owner] call ALiVE_fnc_dump;
};

// no faster than one every 2 s per player
if (isNil "ALiVE_hub_inflight") then { ALiVE_hub_inflight = createHashMap };
private _uid = getPlayerUID _caller;
if (time - (ALiVE_hub_inflight getOrDefault [_uid, -10]) < 2) exitWith {};
ALiVE_hub_inflight set [_uid, time];

// The server case only accepts a call that comes through here: this name is visible down the call
// chain and nowhere else.
private _ALiVE_hubCaller = _caller;
[_op, _args] call ALIVE_fnc_hub;
