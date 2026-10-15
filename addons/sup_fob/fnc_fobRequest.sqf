#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobRequest);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fobRequest

Description:
The only way a player's machine asks the server to change a FOB, and only for what a player may
do: deploy, dismantle, build, recycle, unload, upgrade, repair, rename, and the Field HQ requests. It finds who is asking from the connection, never from the request, and passes them on
as the caller; the side is always the caller's own and every cost is worked out on the server,
so a request can't name its own price or act for another side.

Call it unscheduled, so the check and the change can't be split:
    [_op, _args] remoteExecCall ["ALiVE_fnc_fobRequest", 2];
A mission that limits remoteExec through CfgRemoteExec must allow ALiVE_fnc_fobRequest.

Parameters:
String - The operation
Array - Its arguments

Returns:
Nothing

Author:
Jman
---------------------------------------------------------------------------- */

if (!isServer) exitWith {};
if !(_this isEqualType [] && {count _this == 2} && {(_this select 0) isEqualType ""} && {(_this select 1) isEqualType []}) exitWith {};
params ["_op", "_args"];

// Only what a player may ask for. Everything else in ALiVE_fnc_fobOps (cleanup, flip, salvage,
// spawning profiles, tagging, restoring) is the server's own and never reachable from here.
if !(_op in ["deploy", "dismantle", "build", "recycle", "unload", "upgrade", "repair", "fieldHQ", "rename"]) exitWith {
    ["ALiVE Player FOBs - refused a request for %1 from machine %2: not something a player can ask for", _op, remoteExecutedOwner] call ALiVE_fnc_dumpR;
};

// Who is asking. On a hosted server the host's own requests come from machine 0; on a dedicated
// server nothing legitimate does (a headless client doesn't build), so those are dropped.
private _owner = remoteExecutedOwner;
private _caller = objNull;
if (_owner == 0 || {_owner == clientOwner}) then {
    if (hasInterface) then { _caller = player };
} else {
    private _i = allPlayers findIf { owner _x == _owner && {isPlayer _x} && {getPlayerUID _x != ""} };
    if (_i > -1) then { _caller = allPlayers select _i };
};
if (isNull _caller) exitWith {
    ["ALiVE Player FOBs - refused a request (%1) from machine %2: not a player", _op, _owner] call ALiVE_fnc_dump;
};

// One request in flight per player, and no faster than one every 2 s
if (isNil "ALiVE_FOB_inflight") then { ALiVE_FOB_inflight = createHashMap };
private _uid = getPlayerUID _caller;
if (time - (ALiVE_FOB_inflight getOrDefault [_uid, -10]) < 2) exitWith {};
ALiVE_FOB_inflight set [_uid, time];

// The server functions only accept a call that comes through here, which is how they tell it
// from a direct remote call: this name is visible down the call chain and nowhere else.
private _ALiVE_fobCaller = _caller;
[_op, _args, _caller] call ALiVE_fnc_fobOps;
