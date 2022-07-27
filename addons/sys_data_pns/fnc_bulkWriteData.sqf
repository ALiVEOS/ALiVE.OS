#include "script_component.hpp"
SCRIPT(bulkWriteData_pns);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_bulkWriteData_pns

Description:
Writes data to an external pns (using JSON string) using the Bulk API

Parameters:
Object - Data handler logic
Array - Module (string), Data (array), Async (bool) optional, UID (string) optional

Returns:
String - Returns a response error or confirmation of write

Examples:
(begin example)
    [ _logic, [ _module, [[key,value],[key,value],[key,value]], _async, _uid ] ] call ALIVE_fnc_writeData;
(end)

Author:
Tupolov
Peer Reviewed:

---------------------------------------------------------------------------- */
#include "script_component.hpp"
SCRIPT(bulkWriteData_pns);

["SYS DATA PNS - Operation bulkWrite unsupported! Called by %1 - input %2",_fnc_scriptNameParent,_this] call ALiVE_fnc_dump;

"SYS DATA ERROR";