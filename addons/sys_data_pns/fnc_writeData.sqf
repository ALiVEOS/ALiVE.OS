#include "script_component.hpp"
SCRIPT(writeData_pns);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_writeData_pns

Description:
Writes data to an external pns (using JSON string)

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
private ["_result","_error","_module","_data","_async","_missionKey","_saveData", "_indexRev","_indexDoc","_index","_newIndexDoc","_createIndex","_indexArray","_tempIndexDoc","_indexCount","_indexRevs"];

_logic = _this select 0;
_args = _this select 1;

_module = _args select 0;
_data = _args select 1;
_async = _args select 2;
_missionKey  = _args select 3;

_data = +_data;

TRACE_3("Saving data", _logic, _args);

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["SYS_DATA_PNS - BULK SAVE"] call ALiVE_fnc_dump;
};

_result = "";

MOD(PNS_STORE) = +(profileNamespace getVariable [_missionKey, [] call ALiVE_fnc_HashCreate]);

[MOD(PNS_STORE),_module,_data] call ALiVE_fnc_HashSet;

profileNamespace setVariable [_missionKey, MOD(PNS_STORE)];

// Save Docs
TRACE_3("Saving Data", _data);
saveProfileNamespace;

_result;
