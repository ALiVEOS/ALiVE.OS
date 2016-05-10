#include "script_component.hpp"
SCRIPT(loadData_couchdb);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_loadData_couchdb

Description:
Loads multiple records from a table

Parameters:
Object - Data handler logic
Array - Module (string), mission key (string), Async (bool)

Returns:
String - Returns a CBA Hash of data

Examples:
(begin example)
	_result = [_logic, "load", ["sys_player", _missionKey, _ondisconnect]] call ALIVE_fnc_Data;
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

TRACE_3("loadData", _logic, _args, _flag);

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["ALiVE SYS_DATA_COUCHDB - LOAD DATA: %1",_args] call ALIVE_fnc_dump;
};

// Read in index document for unique mission key (for this module)
_indexDoc = [_logic, "read", [_module, [], _missionKey]] call ALIVE_fnc_Data;

TRACE_1("Load IndexDoc",_indexDoc);

if (typeName _indexDoc == "ARRAY") then {

	// Set the index revision on the module data handler for purposes of saving a new index later
	_indexRev = [_indexDoc, "_rev"] call CBA_fnc_hashGet;
	[_logic,"indexRev",_indexRev] call CBA_fnc_hashSet;

	_data = [] call CBA_fnc_hashCreate;

	// Grab index
	_index = [_indexDoc, "index"] call CBA_fnc_hashGet; // Should be an array of key values

    if(ALiVE_SYS_DATA_DEBUG_ON) then {
	    ["ALiVE SYS_DATA_COUCHDB - LOAD DATA LOAD INDEX: %1",_index] call ALIVE_fnc_dump;
    };

	TRACE_1("Load index", _index);
	// Read in documents (mission key + doc key) and restore original module index (without mission key)
	{
		private ["_key","_record"];
		_key = _missionKey + "-" + _x;
		_record = [_logic, "read", [_module, [], _key]] call ALIVE_fnc_Data;
		[_data, _x, _record] call CBA_fnc_hashSet;
	} foreach _index;

	// Return data as hash
	_result = _data;

    if(ALiVE_SYS_DATA_DEBUG_ON) then {
	    ["ALiVE SYS_DATA_COUCHDB - LOAD DATA RESULT: %1",[str(_result)] call CBA_fnc_strLen] call ALIVE_fnc_dump;
    };
} else {
	_result = false;

    if(ALiVE_SYS_DATA_DEBUG_ON) then {
	    ["ALiVE SYS_DATA_COUCHDB - LOAD RESULT: %1",_result] call ALIVE_fnc_dump;
    };
};

_result;