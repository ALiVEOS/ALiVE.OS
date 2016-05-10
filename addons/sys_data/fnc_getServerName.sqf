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
Peer Reviewed:

---------------------------------------------------------------------------- */
private ["_response"];

if (isNil QGVAR(ServerName)) then {
	_response = ["ServerName"] call ALIVE_fnc_sendToPlugIn;
	GVAR(ServerName) = _response;
} else {
	_response = GVAR(ServerName);
};
_response;