#include <\x\alive\addons\x_lib\script_component.hpp>
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

Peer reviewed:
nil
---------------------------------------------------------------------------- */

private ["_event"];

_event = _this select 0;

[ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
