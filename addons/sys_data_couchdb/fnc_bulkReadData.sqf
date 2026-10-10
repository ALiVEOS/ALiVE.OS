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

private ["_response","_result","_error","_module","_data","_pairs","_cmd","_json","_logic","_args","_convert","_db","_key","_call","_dockeys","_uids"];

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
    ["SYS_DATA_COUCHDB - BULK READ: %1",_json] call ALiVE_fnc_dump;
};

// Send JSON to plugin
_response = [_json] call ALIVE_fnc_sendToPlugIn;

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["SYS_DATA_COUCHDB - COUCH RESPONSE: %1",_response] call ALiVE_fnc_dump;
};

// From response create key/value pair arrays
if (_response == "READY" || _response == "OK") then {

    // Profiles may recover a partial campaign; other modules require a complete batch.
    private _allowPartial = _module == "sys_profile";
    private _failed = false;
    private _temp = [] call ALiVE_fnc_hashCreate;
    private _data = "";
    _json = format ["GetBulkJSON ['%1']", _module];
    while {_data != "END"} do {
        _data = [_json] call ALIVE_fnc_sendToPlugIn;
        TRACE_1("COUCH DATA", _data);
        if (_data == "SYS_DATA_ERROR") exitWith {_failed = true};
        if (_data != "END") then {
            private _tempDoc = [_logic, "restore", [_data]] call ALIVE_fnc_Data;
            if !([_tempDoc] call ALIVE_fnc_isHash) exitWith {
                _failed = true;
                ["SYS_DATA_COUCHDB - SKIPPING INVALID DOCUMENT: Module: %1, Key: %2", _module, _key] call ALiVE_fnc_dump;
            };
            private _id = [_tempDoc, "_id", ""] call ALIVE_fnc_hashGet;
            if !(_id in _dockeys) exitWith {
                _failed = true;
                ["SYS_DATA_COUCHDB - SKIPPING UNEXPECTED DOCUMENT ID: Module: %1, Key: %2, ID: %3", _module, _key, _id] call ALiVE_fnc_dump;
            };
            [_temp, _id, _tempDoc] call ALiVE_fnc_hashSet;
        };
    };

    _result = [] call ALiVE_fnc_hashCreate;
    private _missing = [];
    {
        private _mkey = _key + "-" + _x;
        private _record = [_temp, _mkey] call ALiVE_fnc_hashGet;
        if (isNil "_record") then {
            _missing pushBack _x;
        } else {
            [_result, _x, _record] call ALiVE_fnc_hashSet;
        };
    } forEach _uids;
    if (_failed || {count _missing > 0}) then {
        ["SYS_DATA_COUCHDB - INCOMPLETE BULK READ: Module: %1, Key: %2, Loaded: %3/%4, Missing: %5",
            _module, _key, count (_result select 1), count _uids, _missing] call ALiVE_fnc_dump;
        // A failed nonempty download must never look like a saved empty campaign.
        if (!_allowPartial || {count (_result select 1) == 0}) then {
            _result = "SYS_DATA_ERROR";
        };
    };

    if(ALiVE_SYS_DATA_DEBUG_ON) then {
        ["SYS_DATA_COUCHDB - BULK READ RESULT: %1",[str(_result)] call CBA_fnc_strLen] call ALiVE_fnc_dump;
    };


} else {
    _result = _response;

    if(ALiVE_SYS_DATA_DEBUG_ON) then {
        ["SYS_DATA_COUCHDB - BULK READ RESULT: %1",_result] call ALiVE_fnc_dump;
    };
};


/*
    // Handle data error
    private["_err"];
    _err = format["The Couch database %1 did not respond with %2. The data returned was: %3", _databaseName, typeName _result, _result];
    ERROR_WITH_TITLE(str _logic, _err);
*/

_result;


