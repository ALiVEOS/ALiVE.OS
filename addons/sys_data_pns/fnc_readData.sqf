#include "script_component.hpp"
SCRIPT(readData_pns);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_readData

Description:
Reads data from an external datasource (pns) and coverts to an array of key/value pairs

Parameters:
Object - data handler object
Array - Array of module name (string) and then unique identifer (string)

Returns:
Array - Returns a response error or data in the form of key value pairs

Examples:
(begin example)
    [ _logic, [ _module, [_key,_key etc], _uid ] ] call ALIVE_fnc_readData;
(end)

Author:
Tupolov
Peer Reviewed:

---------------------------------------------------------------------------- */

private ["_response","_result","_error","_module","_data","_missionKey","_indexDoc","_index","_flag"];

_logic = _this select 0;
_args = _this select 1;

// Validate args
_module = _args select 0;
_keys = _args select 1;
_uid = _args select 2;

TRACE_3("PNS readData", _logic, _args);

_data = profileNamespace getvariable _uid;

if (isnil "_data") exitwith {"SYS_DATA_ERROR"};

_result = [_data,_module] call ALiVE_fnc_HashGet;

if (isnil "_result") exitwith {"SYS_DATA_ERROR"};

_result;