#include "script_component.hpp"
SCRIPT(bulkLoadData_couchdb);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_bulkLoadData_couchdb

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

TRACE_3("loadData", _logic, _args, _flag);

// Read in index document for unique mission key (for this module)
_indexDoc = [_logic, "read", [_module, [], _missionKey]] call ALIVE_fnc_Data;

TRACE_1("Load IndexDoc",_indexDoc);

if (typeName _indexDoc == "ARRAY") then {

	_indexRev = [[_indexDoc, "_rev"] call CBA_fnc_hashGet];

	// Grab index
	_index = [_indexDoc, "index"] call CBA_fnc_hashGet; // Should be an array of key values

	// Try loading more index entries
	private ["_i","_indexName","_newresponse"];
	_i = 1;
	while {_indexName = format["%1_%2_%3", ALIVE_SYS_DATA_GROUP_ID, missionName, _i]; _newresponse = [_logic, "read", [_module, [], _indexName]] call ALIVE_fnc_Data; typeName _newresponse != "STRING"} do {
		private ["_tempIndex"];

		_tempIndex = [_newresponse, "index"] call CBA_fnc_hashGet; // Should be an array of key values

		{
			_index set [count _index, _tempIndex select _foreachIndex];
		} foreach _tempIndex;

		_indexRev set [count _indexRev, [_newresponse, "_rev"] call CBA_fnc_hashGet];
		_i = _i + 1;
	};

	// Capture index revision information
	[_logic, "indexRevs", _indexRev] call CBA_fnc_hashSet;

	TRACE_1("Index Revisions",_indexRev);

	// Create the hash to return and call bulkread
	_data = [] call CBA_fnc_hashCreate;

	TRACE_1("Load index", _index);
	// Send bulkread request (send array of doc ids)

	_data = [_logic, "bulkRead", [_module, _missionKey, _index]] call ALIVE_fnc_Data;

	// Return data as hash
	_result = _data;
} else {
	_result = false;
};

_result;