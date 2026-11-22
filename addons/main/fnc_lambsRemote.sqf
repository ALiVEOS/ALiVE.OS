#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(lambsRemote);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_lambsRemote

Description:
The network door of ALiVE_fnc_lambs. The machine that owns a group reports to the server through
it, and the server answers the same way. Only the operations listed here come in over the network,
and each is checked against the machine that sent it. ALiVE_fnc_lambs takes the two owner-to-server
operations from here alone and leaves every other operation open, so a call made on the server
inside a client's remote call (a Zeus module, a commander tablet order) is not turned away.

The engine does not say who sent a call from a headless client: remoteExecutedOwner is 0 for one by
design, and isRemoteExecuted has been seen false as well. So the sending machine adds its own clientOwner, and the
server takes that number only when the engine gave none and it is the owner of a headless client. A
machine could at worst say that a real headless client runs LAMBS; it cannot pass as a player's machine
or get a group moved to itself.

A mission that limits remoteExec through CfgRemoteExec must allow ALiVE_fnc_lambsRemote.

Parameters:
String - operation
Array - arguments
Number - the sending machine's clientOwner (optional, sent with the owner-to-server operations)

Returns:
Nothing

Examples:
(begin example)
["report", ["contact", _id, _sideText, _position, _payload], clientOwner] remoteExecCall ["ALiVE_fnc_lambsRemote", 2];
(end)

Author:
Goldwep
---------------------------------------------------------------------------- */

// owner to server
#define TO_SERVER ["report", "with"]
// server to owner
#define TO_OWNER  ["detachLocal", "share", "unassign", "nudge", "soldierBehaviour"]

params [["_operation", "", [""]], ["_args", [], [[]]], ["_claimed", -1, [0]]];

// seen by ALiVE_fnc_lambs, which takes a report from nowhere else
private _lambsDoor = true;
private _toServer = _operation in TO_SERVER;
if (!_toServer && {!(_operation in TO_OWNER)}) exitWith {};

// -1: not from the network (single player, or called on this machine)
private _sender = if (isRemoteExecuted && {isMultiplayer}) then { remoteExecutedOwner } else { -1 };

// the engine named no sender and the call says which machine it is from: this machine itself counts as
// not from the network, a headless client is taken at its word, and anything else is turned away
private _unknown = false;
if (_sender < 1 && {isMultiplayer} && {_claimed > -1}) then {
    if (_claimed == clientOwner) exitWith { _sender = -1 };
    if (isServer && {((entities "HeadlessClient_F") findIf { owner _x == _claimed }) > -1}) exitWith { _sender = _claimed };
    _unknown = true;
};
if (_unknown) exitWith {};

if (_toServer) exitWith {
    if (!isServer) exitWith {};
    // the server reads the sender from the network, never from the arguments
    if (_operation == "with") exitWith { ["with", [_sender]] call ALiVE_fnc_lambs };
    _args = +_args;
    _args resize 5;
    _args set [5, _sender];
    [_operation, _args] call ALiVE_fnc_lambs;
};

// an answer to a group's owner comes from the server alone
if (_sender > -1 && {_sender != 2}) exitWith {};
[_operation, _args] call ALiVE_fnc_lambs;
