/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_bulkReadData

Description:
Reads data from an external datasource (couchdb) and coverts to a hash of documents (key/value pairs)

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
SCRIPT(readData_couchdb);

private ["_response","_result","_error","_module","_data","_pairs","_cmd","_json","_logic","_args","_convert","_db","_key","_call","_dockeys"];

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
_key = _args select 1;
_uids = _args select 2;
_dockeys = [];

_cmd = format ["SendBulkJSON ['POST','%1'", _module];

// Add mission key to each doc
{
	private ["_temp"];
	_temp = _key + "-" + _x;
	_dockeys set [_forEachIndex, _temp];
} foreach _uids;

// Use the index array to create a JSON string of doc ids
_data = ",'{""keys"":" + str(_dockeys) + "}'";
_cmd = _cmd + _data;

// Add databaseName
//_db = [_logic, "databaseName", "arma3live"] call ALIVE_fnc_hashGet;

// Append cmd with db
_json = _cmd + "]";

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["ALiVE SYS_DATA_COUCHDB - BULK READ: %1",_json] call ALIVE_fnc_dump;
};

// Send JSON to plugin
_response = [_json] call ALIVE_fnc_sendToPlugIn;

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["ALiVE SYS_DATA_COUCHDB - COUCH RESPONSE: %1",_response] call ALIVE_fnc_dump;
};

// From response create key/value pair arrays
if (_response == "READY" || _response == "OK") then {

	// Now poll data stack until all documents are collected
	private ["_data","_temp"];
	_data = "";
	_temp = [] call ALiVE_fnc_hashCreate;
	_json = format ["GetBulkJSON ['%1']", _module];
	While {_data != "END"} do {
		private ["_tempDoc","_id"];
		_data = [_json] call ALIVE_fnc_sendToPlugIn;
		TRACE_1("COUCH DATA", _data);
		if (_data == "SYS_DATA_ERROR") exitWith {diag_log format["There was an error loading data! Report it to ALiVE Devs. Module: %1, Key: %2, Records: %3",_module, _key, _uids];};
			if (_data != "END") then{
				_tempDoc = [_logic, "restore", [_data]] call ALIVE_fnc_Data;
				//["TEMPDOC DUMP %1",_tempDoc] call ALiVE_fnc_dump;
				_id = [_tempDoc,"_id"] call ALiVE_fnc_hashGet;
				[_temp, _id, _tempDoc] call ALiVE_fnc_hashSet;
			};
	};

	// Restore original module index (without mission key) for each document
	_result = [] call ALiVE_fnc_hashCreate;
	{
		private ["_mkey","_record"];
		_mkey = _key + "-" + _x;

		_record = [_temp, _mkey] call ALiVE_fnc_hashGet;
		if!(isNil "_record") then {
		    [_result, _x, _record] call ALiVE_fnc_hashSet;
        }else{

            if(ALiVE_SYS_DATA_DEBUG_ON) then {
                ["ALiVE SYS_DATA_COUCHDB - RECORD IS NIL! LOOKING FOR KEY: %1 IN HASH:",_mkey] call ALIVE_fnc_dump;
            };

            (_temp select 1) call ALIVE_fnc_inspectArray;
        };
	} foreach _uids;

    if(ALiVE_SYS_DATA_DEBUG_ON) then {
	    ["ALiVE SYS_DATA_COUCHDB - BULK READ RESULT: %1",[str(_result)] call CBA_fnc_strLen] call ALIVE_fnc_dump;
    };


} else {
	_result = _response;

    if(ALiVE_SYS_DATA_DEBUG_ON) then {
	    ["ALiVE SYS_DATA_COUCHDB - BULK READ RESULT: %1",_result] call ALIVE_fnc_dump;
    };
};


/*
	// Handle data error
	private["_err"];
	_err = format["The Couch database %1 did not respond with %2. The data returned was: %3", _databaseName, typeName _result, _result];
	ERROR_WITH_TITLE(str _logic, _err);
*/

_result;


