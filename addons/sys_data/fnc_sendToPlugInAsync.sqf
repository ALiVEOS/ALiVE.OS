#include "script_component.hpp"
SCRIPT(sendToPlugIn);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sendToPlugInAsync

Description:
Sends valid commands and data to arma2net plugins using an Async function. Sends the command to the ASYNC_QUEUE to be handled.

Parameters:
String - Text to be sent to external source

Returns:
String

Examples:
(begin example)
 ["ARMA2NetMySQLCommand ['arma','SELECT * FROM missions'] "] call ALIVE_fnc_sendToPlugInAsync
(end)
(begin example)
 ["SendJSON ['http://msostore.iriscouch.com','POST','missions','{'key':'value'}'] "] call ALIVE_fnc_sendToPlugInAsync
(end)

Author:
Tupolov
Peer Reviewed:

---------------------------------------------------------------------------- */
private ["_cmd","_response","_resp"];
PARAMS_1(_cmd);

// Send command to the async call handler (PVEH)

// update the async queue, send back response immediately
GVAR(ASYNC_QUEUE) pushBack _cmd;

if(ALiVE_SYS_DATA_DEBUG_ON) then {
	["ALiVE SYS_DATA - SEND TO PLUGIN ASYNC: %1, %2", _cmd, count GVAR(ASYNC_QUEUE)] call ALIVE_fnc_dump;
};

// Is this needed? No longer using PVEH
if (!isDedicated) then {
	publicVariableServer QGVAR(ASYNC_QUEUE);
};

_response = "SENT";

_response;
