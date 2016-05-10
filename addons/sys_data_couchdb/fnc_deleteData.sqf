/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_deleteData

Description:
Deletes data from an external datasource (couchdb)

Parameters:
Object - data handler object
Array - Array of module name (string) and then unique identifer (string)

Returns:
Array - Returns a response error or data in the form of key value pairs

Examples:
(begin example)
	[ _logic, [ _module, [_key,_key etc], _uid ] ] call ALIVE_fnc_deleteData;
(end)

Author:
Tupolov
Peer Reviewed:

---------------------------------------------------------------------------- */
#include "script_component.hpp"
SCRIPT(deleteData_couchdb);

private ["_response","_result","_error","_module","_data","_pairs","_cmd","_json","_logic","_args","_convert","_db","_rev"];

// Avoided using the format command as it has a 2kb limt

_logic = _this select 0;
_args = _this select 1;

_error = "parameters provided not valid";
ASSERT_DEFINED("_logic", _err);
ASSERT_OP(typeName _logic, == ,"ARRAY", _err);
ASSERT_DEFINED("_args", _err);
ASSERT_OP(typeName _args, == ,"ARRAY", _err);

// Validate args
_module = _args select 0;
_async = _args select 1;
_uid = _args select 2;
_rev = _args select 3;

if (_rev == "MISSING" || _rev == "") exitWith {false};

if (_uid != "") then {
	// use doc id to grab document
	_cmd = format ["SendJSONAsync ['DELETE','%1/%2?rev=%3',''", _module, _uid, _rev];
};

// Add databaseName
//_db = [_logic, "databaseName", "arma3live"] call ALIVE_fnc_hashGet;

// Append cmd with db
_json = _cmd + "]";

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["ALiVE SYS_DATA_COUCHDB - DELETE DATA: %1",_json] call ALIVE_fnc_dump;
};

TRACE_1("COUCH DELETE DATA", _json);

// Send JSON to plugin
_response = [_json] call ALIVE_fnc_sendToPlugInAsync;

TRACE_1("COUCH RESPONSE", _response);

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["ALiVE SYS_DATA_COUCHDB - DELETE DATA RESULT: %1",_response] call ALIVE_fnc_dump;
};

/*
	// Handle data error
	private["_err"];
	_err = format["The Couch database %1 did not respond with %2. The data returned was: %3", _databaseName, typeName _result, _result];
	ERROR_WITH_TITLE(str _logic, _err);
*/

_response


