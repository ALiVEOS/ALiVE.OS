#include "script_component.hpp"
SCRIPT(getServerIP);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getServerIP

Description:
Gets the current server IP address via arma2net plugins

Parameters:
None

Returns:
String - Returns the server IP address

Examples:
(begin example)
 _serverIP = [] call ALIVE_fnc_getServerIP
(end)

Author:
Tupolov
Jman
Peer Reviewed:

---------------------------------------------------------------------------- */
private ["_response"];

if (isNil QGVAR(ServerIP)) then {
    _response = "SYS_DATA_ERROR"; // what the old plugin (@ALiVEServer, removed) answered once its service was gone
    GVAR(ServerIP) = _response;
} else {
    _response = GVAR(ServerIP);
};
_response;
