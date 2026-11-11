#include "script_component.hpp"
SCRIPT(getServerTime);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getServerTime

Description:
Gets the current server local or UTC time, as "dd/mm/yyyy HH:MM:SS", from the engine clock
(it used to come from ALiVEPlugIn, on a dedicated server only)

Parameters:
BOOL - True indicates the time returned should be local not UTC

Returns:
String - Returns the server local or UTC time

Examples:
(begin example)
 _serverTime = [] call ALIVE_fnc_getServerTime
(end)
(begin example)
 _serverTime = [true] call ALIVE_fnc_getServerTime
(end)

Author:
Tupolov
Jman
Peer Reviewed:

---------------------------------------------------------------------------- */
private _UTC = true;
private _response = [];

TRACE_1("GET SERVER TIME: ", time);

if (count _this == 1) then {
	_UTC = false;
};

private _t = [systemTime, systemTimeUTC] select _UTC;
private _pad = { if (_this < 10) then {"0" + str _this} else {str _this} };
_response = format ["%1/%2/%3 %4:%5:%6", (_t select 2) call _pad, (_t select 1) call _pad, _t select 0, (_t select 3) call _pad, (_t select 4) call _pad, (_t select 5) call _pad];

TRACE_1("GET SERVER TIME: ", _response);

_response;
