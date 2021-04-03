#include "script_component.hpp"
SCRIPT(saveData_pns);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_saveData_pns

Description:
Saves multiple records to a table

Parameters:
Object - Data handler logic
Array - Module (string), Data (CBA Hash), mission key (string), Async (bool) optional

Returns:
String - Returns a response error or confirmation of write

Examples:
(begin example)
    _result = [_logic, "save", ["sys_player", GVAR(player_data), _missionKey, _ondisconnect]] call ALIVE_fnc_Data;
(end)

Author:
Tupolov
Peer Reviewed:

---------------------------------------------------------------------------- */
#include "script_component.hpp"
SCRIPT(saveData_pns);

["SYS DATA PNS - Operation saveData unsupported! Called by %1 - input %2",_fnc_scriptNameParent,_this] call ALiVE_fnc_dump;

"SYS DATA ERROR";
