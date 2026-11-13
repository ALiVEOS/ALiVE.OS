#include "script_component.hpp"
SCRIPT(getGroupID);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getGroupID

Description:
Gets the group ID set in the alive.cfg file

Parameters:
None

Returns:
String - Returns the group name/id

Examples:
(begin example)
 _group = [] call ALIVE_fnc_getGroupID
(end)

Author:
Tupolov
Jman
Peer Reviewed:

---------------------------------------------------------------------------- */
private ["_response"];

_response = "SYS_DATA_ERROR"; // what the old plugin (@ALiVEServer, removed) answered once its service was gone

TRACE_1("GET GROUP ID: ", _response);

_response;