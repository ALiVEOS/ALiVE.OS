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

Peer reviewed:
nil
---------------------------------------------------------------------------- */

[ALIVE_eventLog,"addEvent", _this select 0] call ALIVE_fnc_eventLog;