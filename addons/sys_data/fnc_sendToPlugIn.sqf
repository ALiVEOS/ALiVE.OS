#include "script_component.hpp"
SCRIPT(sendToPlugIn);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sendToPlugIn

Description:
Sends valid commands and data to arma2net plugins

Parameters:
String - Text to be sent to external source

Returns:
String - Returns a response error

Examples:
(begin example)
 ["ARMA2NetMySQLCommand ['arma','SELECT * FROM missions'] "] call ALIVE_fnc_sendToPlugIn
(end)
(begin example)
 ["SendJSON ['http://msostore.iriscouch.com','POST','missions','{'key':'value'}'] "] call ALIVE_fnc_sendToPlugIn
(end)

Author:
Tupolov
Peer Reviewed:
Wolffy.au 24 Oct 2012
---------------------------------------------------------------------------- */
private ["_cmd","_response","_resp"];
PARAMS_1(_cmd);

TRACE_1("SEND TO PLUGIN CMD: ", _cmd);

_response = "ALiVEPlugIn" callExtension _cmd;

// diag_log format ["RESPONSE: %2:%1", _response, typeName _response];

if (isNil "_response" || _response == "") exitWith { diag_log "THERE IS A PROBLEM WITH THE ALIVE PLUGIN!"; _response = "SYS_DATA_ERROR"; _response};

_response = call compile _response;

TRACE_1("SEND TO PLUGIN: ", _response);


if (typeName _response == "ARRAY") then {
	if (count _response == 1) then {
		_response = _response select 0;
	};
};


// Need to check for errors here with new plugin grab 2nd and 3rd array values.
if (([_response, "ERROR"] call CBA_fnc_find != -1 || [_response, "error"] call CBA_fnc_find != -1) && [_response, "terror"] call CBA_fnc_find == -1) then {

	_response = "SYS_DATA_ERROR";
};

_response;
