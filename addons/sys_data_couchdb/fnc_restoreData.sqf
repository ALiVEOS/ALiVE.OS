/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_restoreData

Description:
Converts Couchdb type strings back into ARMA2 data types, map objects, and created vehicles

Parameters:
Object - datahandler object
String - JSON formatted string

Returns:
Hash - Array of key / value pairs

Examples:
(begin example)
// An array of different data types
_result = "ARRAY:[""BOOL:1"",""SCALAR:123.456"",""SIDE:GUER""]" call ALIVE_fnc_restoreData
// returns [true, 123.456, resistance]
(end)

Author:
Tupolov
Wolffy.au
Peer Reviewed:

---------------------------------------------------------------------------- */
#include "script_component.hpp"
SCRIPT(restoreData_couchdb);

private ["_logic","_input","_hash"];

_logic = _this select 0;
_input = (_this select 1) select 0;

// Convert string to Hash
_hash = [_input] call ALIVE_fnc_parseJSON;
TRACE_1("RESTORE DATA", _hash);

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["ALiVE SYS_DATA_COUCHDB - RESTORE DATA BEGIN:"] call ALIVE_fnc_dump;
    _hash call ALIVE_fnc_inspectHash;
};



// Restore Data types in hash

// for each pair, process key and value
ALIVE_fnc_restore = {

	private ["_type","_data","_tkey","_tVal","_arrayResult"];

	_tkey = _this select 0;
	_tVal = _this select 1;



	if (count _this > 2) then {
		_arrayResult = _this select 2;
		TRACE_3("Restore Check", _key, _tkey, _tVal);
		_type = [ALIVE_DataDictionary, "getDataDictionary", [_tkey]] call ALIVE_fnc_Data;
		_value = _tVal;
	} else {
		_arrayResult = false;
		_type = [ALIVE_DataDictionary, "getDataDictionary", [_key]] call ALIVE_fnc_Data;
	};

	TRACE_2("FUNC RESTORE",_value, _key);

	if (isNil "_type") then {
		_type = "STRING";
	};

	// Address each data type accordingly
	switch(_type) do {
			case "HASH": {
					_data = [_logic, "restore", [_value]] call ALIVE_fnc_Data;
			};
			case "STRING": {
					_data = _value;
			};
			case "TEXT": {
					_data = text _value;
			};
			case "BOOL": {
					private["_tmp"];
					_tmp = if (_value == "false") then {false} else {true};
					_data = _tmp;
			};
			case "SCALAR": {
					_data = parseNumber _value;
			};
			case "SIDE": {
					_data = switch(_value) do {
							case "WEST": {west;};
							case "EAST": {east;};
							case "GUER": {resistance;};
							case "CIV": {civilian;};
							case "LOGIC": {sideLogic;};
							case "0": {"EAST"};
							case "1": {"WEST"};
							case "2": {"GUER"};
							case "3": {"CIV"};
							default {"WEST"};
					};
			};
			case "ARRAY": {
					private ["_tmp","_i","_tmpKey"];
					TRACE_3("ARRAY RESTORE", _key, typeName _value, _value);

					/*if (typeName _value != "ARRAY") then {
						_value = [_value, "any", "nil"] call CBA_fnc_replace;
						_tmp = call compile _value;
					} else {
						_tmp = + _value;
					};*/

					_data = [];
					_i = 0;
					{
						private "_item";
						if (_arrayResult) then {
							_tmpKey = _tkey + "_" + str(_i);
						} else {
							_tmpKey = _key + "_" + str(_i);
						};
						_item = _x;
						TRACE_1("",_item);
						_data set [count _data, [_tmpKey, _item, true] call ALIVE_fnc_restore];
						_i = _i + 1;
					} forEach _value;

					TRACE_1("ARRAY RESTORED",_data);
			};
			default {
				_data = _value;
			};
	};


	if (isNil "_data" || typeName _data == "STRING") then {
		if (isNil "_data" || _data == "any" || _data == "null") then {_data = "";};
	};

	//TRACE_1("DATA RESTORED",_data);

	if (_arrayResult) exitWith {
		_arrayResult = false;
		_data
	};


	TRACE_3("COUCH RESTORE KEY/DATA", _key, _data, _type);
	[_hash, _key, _data] call ALIVE_fnc_hashSet;
};

if (typeName _hash == "ARRAY") then {
	[_hash, ALIVE_fnc_restore] call CBA_fnc_hashEachPair;
};

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["ALiVE SYS_DATA_COUCHDB - RESTORE DATA END:"] call ALIVE_fnc_dump;
    _hash call ALIVE_fnc_inspectHash;
};

_hash;
