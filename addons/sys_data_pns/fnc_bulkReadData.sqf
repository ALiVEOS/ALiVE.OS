/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_bulkReadData

Description:
Reads data from an external datasource (pns) and coverts to a hash of documents (key/value pairs)

Parameters:
Object - data handler object
Array - Array of module name (string) and then unique identifer (string)

Returns:
Array - Returns a response error or data in the form of key value pairs

Examples:
(begin example)
    [ _logic, [ _module, [_uids] ] ] call ALIVE_fnc_readData;
(end)

Author:
Tupolov
Peer Reviewed:

---------------------------------------------------------------------------- */
#include "script_component.hpp"
SCRIPT(bulkReadData_pns);

["SYS DATA PNS - Operation bulkRead unsupported! Called by %1 - input %2",_fnc_scriptNameParent,_this] call ALiVE_fnc_dump;

"SYS DATA ERROR";
