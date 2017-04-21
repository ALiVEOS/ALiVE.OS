#include "script_component.hpp"
SCRIPT(bulkLoadData_pns);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_bulkLoadData_pns

Description:
Loads multiple records from a table using the bulk read API

Parameters:
Object - Data handler logic
Array - Module (string), mission key (string), Async (bool)

Returns:
String - Returns a CBA Hash of data

Examples:
(begin example)
    _result = [_logic, "bulkload", ["sys_player", _missionKey, _ondisconnect]] call ALIVE_fnc_Data;
(end)

Author:
Tupolov
Peer Reviewed:

---------------------------------------------------------------------------- */
private ["_response","_result","_error","_module","_data","_missionKey","_indexDoc","_index","_flag"];

_logic = _this select 0;
_args = _this select 1;

_module = _args select 0;
_missionKey  = _args select 1;
_flag = _args select 2;

TRACE_3("PNS bulkLoadData", _logic, _args, _flag);

_data = +(profileNamespace getvariable _missionKey);

if (isnil "_data") exitwith {false};

_result = [_data,_module] call ALiVE_fnc_HashGet;

if (isnil "_result") exitwith {false};

_result;
