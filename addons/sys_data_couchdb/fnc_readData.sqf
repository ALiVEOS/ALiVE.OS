/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_readData

Description:
Reads data from an external datasource (couchdb) and coverts to an array of key/value pairs

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
#include "script_component.hpp"
SCRIPT(readData_couchdb);

private ["_response","_result","_error","_module","_data","_pairs","_cmd","_json","_logic","_args","_convert","_db"];

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
_keys = _args select 1;
_uid = _args select 2;

if (_uid != "") then {
	// use doc id to grab document
	_cmd = format ["SendJSON ['GET','%1/%2',''", _module, _uid];
} else {
	// use keys to grab one or more documents
	_cmd = format ["SendJSON ['GET','%1/_all_docs?startkey=%2&endkey=%3&include_docs=true',''", _module, str(_keys select 0), str(_keys select 1)];
};

// Add databaseName
// _db = [_logic, "databaseName", "arma3live"] call ALIVE_fnc_hashGet;

// Append cmd with db
_json = _cmd + "]";

TRACE_1("COUCH READ DATA", _json);

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["ALiVE SYS_DATA_COUCHDB - READ DATA: %1",_json] call ALIVE_fnc_dump;
};

// Send JSON to plugin
_response = [_json] call ALIVE_fnc_sendToPlugIn;

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["ALiVE SYS_DATA_COUCHDB - READ DATA RESPONSE: %1",_response] call ALIVE_fnc_dump;
};

// From response create key/value pair arrays
if (([_response, "SYS_DATA_ERROR"] call CBA_fnc_find == -1) && _response != "UNAUTHORISED!") then {

	_result = [_logic, "restore", [_response]] call ALIVE_fnc_Data;

} else {
	_result = _response;
};

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["ALiVE SYS_DATA_COUCHDB - READ DATA RESULT: %1",_result] call ALIVE_fnc_dump;
};

/*
	// Handle data error
	private["_err"];
	_err = format["The Couch database %1 did not respond with %2. The data returned was: %3", _databaseName, typeName _result, _result];
	ERROR_WITH_TITLE(str _logic, _err);
*/

_result;


