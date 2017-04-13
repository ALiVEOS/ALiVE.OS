#include "script_component.hpp"
SCRIPT(loadData_pns);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_loadData_pns

Description:
Loads multiple records from a table

Parameters:
Object - Data handler logic
Array - Module (string), mission key (string), Async (bool)

Returns:
String - Returns a CBA Hash of data

Examples:
(begin example)
    _result = [_logic, "load", ["sys_player", _missionKey, _ondisconnect]] call ALIVE_fnc_Data;
(end)

Author:
Tupolov
Peer Reviewed:

---------------------------------------------------------------------------- */
#include "script_component.hpp"
SCRIPT(loadData_pns);

["ALiVE SYS DATA PNS - Operation loadData unsupported! Called by %1 - input %2",_fnc_scriptNameParent,_this] call ALiVE_fnc_Dump;

"SYS DATA ERROR";
