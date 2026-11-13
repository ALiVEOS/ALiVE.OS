#include "script_component.hpp"
SCRIPT(getServerName);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getServerName

Description:
Gets the current server hostname via arma2net plugins

Parameters:
None

Returns:
String - Returns the server hostname

Examples:
(begin example)
 _serverName = [] call ALIVE_fnc_getServerName
(end)

Author:
Tupolov
Jman
Peer Reviewed:

---------------------------------------------------------------------------- */
private ["_response"];

if (isNil QGVAR(ServerName)) then {
    _response = "SYS_DATA_ERROR"; // what the old plugin (@ALiVEServer, removed) answered once its service was gone
    GVAR(ServerName) = _response;
} else {
    _response = GVAR(ServerName);
};
_response;