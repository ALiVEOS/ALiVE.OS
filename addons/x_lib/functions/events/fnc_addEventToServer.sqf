#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(addEventToServer);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_addEventToServer

Description:
Sends an event to the server event log

Parameters:
Array - event

Returns:

Examples:
(begin example)
// create a new event
[_event] call ALIVE_fnc_addEventToServer;
(end)

Author:
ARJay
Jman

Peer reviewed:
nil
---------------------------------------------------------------------------- */

private _event = _this select 0;

// Every event carries the machine it came from (#1091). The event log hands events on later, in a
// script of their own, where remoteExecutedOwner no longer says who sent it, so it is noted here.
// The event log takes one event or a list of them, so each one in a list is stamped too, and the
// stamp always overwrites, so an event sent through here can't name a sender of its own choosing.
// A modified client that skips this function altogether is not stopped by it. -1: not sent from
// another machine.
private _sender = [-1, remoteExecutedOwner] select isRemoteExecuted;
private _isHash = { _this isEqualType [] && {count _this > 2} && {(_this select 0) isEqualTo "#CBA_HASH#"} && {(_this select 1) isEqualType []} && {(_this select 2) isEqualType []} };
if (_event call _isHash) then {
    [_event, "sender", _sender] call ALIVE_fnc_hashSet;
} else {
    if (_event isEqualType []) then {
        { if (_x call _isHash) then { [_x, "sender", _sender] call ALIVE_fnc_hashSet } } forEach _event;
    };
};

[ALIVE_eventLog,"addEvent", _event] call ALIVE_fnc_eventLog;