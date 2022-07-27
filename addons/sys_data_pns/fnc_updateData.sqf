#include "script_component.hpp"
SCRIPT(updateData_pns);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_updateData_pns

Description:
Updates data stored in an external pns (using JSON string)

Parameters:
Object - Data handler logic
Array - Module (string), Data (array), Async (bool), UID (string)

Returns:
String - Returns a response error or confirmation of write

Examples:
(begin example)
    [ _logic, [ _module, [[key,value],[key,value],[key,value]], _async, _uid ] ] call ALIVE_fnc_updateData;
(end)

Author:
Tupolov
Peer Reviewed:

---------------------------------------------------------------------------- */
#include "script_component.hpp"
SCRIPT(updateData_pns);

["SYS DATA PNS - Operation updateData unsupported! Called by %1 - input %2",_fnc_scriptNameParent,_this] call ALiVE_fnc_dump;

"SYS DATA ERROR";
