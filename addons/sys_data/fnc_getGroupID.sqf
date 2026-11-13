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

// The old plugin (@ALiVEServer, removed) answered "SYS_DATA_ERROR" once its service was gone. The group
// is now the Data module's: the ALiVE > Server > Old War Room Group Name setting, else "ALiVE"
_response = missionNamespace getVariable ["ALIVE_sys_data_GROUP_ID", ""];
if !(_response isEqualType "" && {_response != ""}) then {
    _response = missionNamespace getVariable ["ALiVE_dataGroupName", ""];
    if !(_response isEqualType "" && {_response != ""}) then {_response = "ALiVE"};
};

TRACE_1("GET GROUP ID: ", _response);

_response;