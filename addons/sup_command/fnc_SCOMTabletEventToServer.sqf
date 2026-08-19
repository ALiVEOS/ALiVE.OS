#include "\x\alive\addons\sup_command\script_component.hpp"
SCRIPT(SCOMTabletEventToServer);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_SCOMTabletEventToServer
Description:

Transfers event from client instance to server module

Parameters:
Array - event hash

Returns:

See Also:

Author:
ARJay
Jman

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

// Authenticate the sender before dispatch. remoteExecutedOwner is only valid in
// this synchronous context (a spawn resets it to 0), so the caller identity MUST
// be resolved here and never inside a downstream op. Every SCOM event carries the
// client player UID at _data select 0; overwrite it with the UID of the player
// actually seated on the sending machine so every op keys its cooldowns, replies
// and side checks on an authenticated identity. Fail closed: an unresolvable
// sender is dropped silently (there is no trustworthy reply route, and replying to
// a claimed UID would let an attacker ping arbitrary tablets).

if (isNil QMOD(commandHandler)) exitWith {};

if !(_this isEqualType [] && {count _this == 2} && {(_this select 1) isEqualType []} && {count (_this select 1) > 0}) exitWith {};

private _callerOwner = remoteExecutedOwner;
private _caller = objNull;

if (_callerOwner == 0) then {
    // originated on this machine - only the local host player is a trusted owner==0 sender
    // (on a dedicated server there is no local player, so the event is dropped below)
    if (hasInterface) then {_caller = player};
} else {
    private _index = allPlayers findIf {(owner _x == _callerOwner) && {isPlayer _x} && {getPlayerUID _x != ""}};
    if (_index > -1) then {_caller = allPlayers select _index};
};

if (isNull _caller) exitWith {};

(_this select 1) set [0, getPlayerUID _caller];

[MOD(commandHandler),"handleEvent", _this] call ALiVE_fnc_commandHandler;