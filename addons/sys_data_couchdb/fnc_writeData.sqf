#include "script_component.hpp"
SCRIPT(writeData_couchdb);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_writeData_couchdb

Description:
Writes data to an external couchdb (using JSON string)

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

// Check to see if ARRAY rather than CBA HASH has been passed as data
if (typeName (_data select 0) != "STRING") then {
	private ["_tmp"];
	_tmp = [] call CBA_fnc_hashCreate;
	{
		private ["_key","_value"];
		_key = _x select 0;
		_value = _x select 1;
		[_tmp, _key, _value] call CBA_fnc_hashSet;
	} foreach _data;
	_data = _tmp;
};

// Check to see if document needs to be written or appended. If appending, use PUT method
_rev = [_data, "_rev", "MISSING"] call ALIVE_fnc_hashGet;
if (_rev != "MISSING") then {
	// Update mission data
	_method = "PUT";
} else {
	_method = "POST";
};

// Add the async flag
if (count _args > 2) then {
	_async = _args select 2;
} else {
	_async = false;
	_uid = "";
};

// If the UID is specified then add it to the URL
if (count _args > 3) then {
	_uid = _args select 3;
	_module = format ["%1/%2", _module, _uid];
	_method = "PUT";
};

// From data passed create couchDB string
_cmd = "";
_json = "";
_string = "";

// Build the JSON command
//_cmd = format ["SendJSON ['POST', '%1', '%2', '%3'", _module, _data, _databaseName];
// ["SendJSON ['POST', 'events', '{key:value,key:value}', 'arma3live'];

if (!_async) then {
	_cmd = format ["SendJSON ['%2','%1'", _module, _method];
} else {
	_cmd = format ["SendJSONAsync ['%2','%1'", _module, _method];
};

_json = [_logic, "convert", [_data]] call ALIVE_fnc_Data;

_string = _cmd + ",'" + _json + "'";

// Add databaseName
//_db = [_logic, "databaseName", "arma3live"] call ALIVE_fnc_hashGet;

// Append cmd with db
_string = _string + "]";

TRACE_1("COUCH WRITE DATA", _string);

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["ALiVE SYS_DATA_COUCHDB - WRITE DATA: (%1) %2",[str(_string)] call CBA_fnc_strLen,_string] call ALIVE_fnc_dump;
};

// Send JSON to plugin
if (!_async) then {
	_response = [_string] call ALIVE_fnc_sendToPlugIn; // if you need a returned UID then you have to go with synchronous op
} else {
	_response = [_string] call ALIVE_fnc_sendToPlugInAsync; //SendJSON is an async addin function so does not return a response until asked for a second time.
};

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["ALiVE SYS_DATA_COUCHDB - WRITE DATA RESULT: %1",_response] call ALIVE_fnc_dump;
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