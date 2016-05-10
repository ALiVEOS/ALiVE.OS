#include "script_component.hpp"
SCRIPT(bulkWriteData_couchdb);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_bulkWriteData_couchdb

Description:
Writes data to an external couchdb (using JSON string) using the Bulk API

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
private ["_response","_result","_error","_module","_data","_uid","_async","_string","_cmd","_json","_logic","_args","_db","_method"];

_logic = _this select 0;
_args = _this select 1;

// Write data to a data source
// Function is expecting the module name (preferably matching table name for db access) and the key/value pairs where the key would be the column id for a DB or the attribute to a JSON object
// Values should be in string form (use the convertData function)
// Call to external datasource uses an arma2net plugin call
// For SQL this is an INSERT command followed by the column ids and values
// Outgoing calls to callExtension have a check to ensure they do not exceed 16kb
// Avoided using the format command as it has a 2kb limt

// Need to check if document already exists... with couchdb, record should have a _rev field. For SQL, just delete?

// Validate params passed to function

_error = "parameters provided not valid";
ASSERT_DEFINED("_logic", _err);
ASSERT_OP(typeName _logic, == ,"ARRAY", _err);
ASSERT_DEFINED("_args", _err);
ASSERT_OP(typeName _args, == ,"ARRAY", _err);

// Validate args
_module = _args select 0;
_data = _args select 1;

// Add the async flag
if (count _args > 2) then {
	_async = _args select 2;
} else {
	_async = false;
	_uid = "";
};

_method = "POST";

// From data passed create couchDB string
_cmd = "";
_json = "";
_string = "";

// If the UID is specified then add it to the URL
if (count _args > 3) then {
	_uid = _args select 3;
};

// Add bulk docs tag
_module = _module + "/_bulk_docs";

// Build the JSON command
//_cmd = format ["SendJSON ['POST', '%1', '%2', '%3'", _module, _data, _databaseName];
/*
["SendJSON ['POST', 'sys_profiles', '{
  "docs": [
    {"_id": "0", "_rev": "1-62657917", "_deleted": true},
    {"_id": "1", "_rev": "1-2089673485", "integer": 2, "string": "2"},
    {"_id": "2", "_rev": "1-2063452834", "integer": 3, "string": "3"}
  ]
}', 'arma3live'];
*/

if (!_async) then {
	_cmd = format ["SendJSON ['%2','%1'", _module, _method];
} else {
	_cmd = format ["SendJSONAsync ['%2','%1'", _module, _method];
};

//Create the bulk docs format
private ["_bulkstart", "_bulkend", "_docs"];
_bulkstart = "{""docs"":[";
_bulkend = "]}";
_docs = "";

TRACE_1("",_bulkstart);

_parse = {
	private "_json";
	// create the doc ID
	[_value, "_id", _uid + "-" + _key] call ALIVE_fnc_hashSet;

	// convert hash to JSON string
	_json = [_logic, "convert", [_value]] call ALIVE_fnc_Data;
	TRACE_1("",_json);

	_docs = _docs + _json + ",";
};

// For each hash create a JSON string
[_data, _parse] call CBA_fnc_hashEachPair;

TRACE_1("",_bulkend);

_string = _cmd + ",'" + _bulkstart + _docs + _bulkend + "'";

// remove trailing , from string
_string = [_string, ",]}", "]}"] call CBA_fnc_replace;

// Add databaseName
//_db = [_logic, "databaseName", "arma3live"] call ALIVE_fnc_hashGet;

// Append cmd with db
_string = _string + "]";

TRACE_1("COUCH WRITE DATA", _string);

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["ALiVE SYS_DATA_COUCHDB - BULK WRITE DATA: (%1) %2",[str(_string)] call CBA_fnc_strLen,_string] call ALIVE_fnc_dump;
};

// Send JSON to plugin
if (!_async) then {
	_response = [_string] call ALIVE_fnc_sendToPlugIn; // if you need a returned UID then you have to go with synchronous op
} else {
	_response = [_string] call ALIVE_fnc_sendToPlugInAsync; //SendJSON is an async addin function so does not return a response until asked for a second time.
};

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["ALiVE SYS_DATA_COUCHDB - BULK WRITE DATA RESULT: %1",_response] call ALIVE_fnc_dump;
};

// Need to send the response to restore function
// Then handle response for couch

/*
// Handle result of write
if (typeName _response == "ARRAY") then {
	_result = _response select 0;
} else {
	// Handle data error
	private["_err"];
	_err = format["The Couch database %1 did not respond with %2. The data returned was: %3", _databaseName, typeName _result, _result];
	ERROR_WITH_TITLE(str _logic, _err);
};*/

// Get UID of written record and add to result

_response;