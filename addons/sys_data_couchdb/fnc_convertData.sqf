/* ----------------------------------------------------------------------------
Function: ALIVE_sys_data_couchdb_fnc_convertData

Description:
Converts CBA Hash of key/value pairs into a valid JSON String

Parameters:
Array = CBA Hash

Returns:
String - Returns JSON string

Examples:
(begin example)

_json = [_datahandler, "convert", [_data]] call ALIVE_fnc_Data;

(end)

Author:
Tupolov
Wolffy.au
Peer Reviewed:

---------------------------------------------------------------------------- */
#include "script_component.hpp"
SCRIPT(convertData_couchdb);

// -------------------------------------------------------------------
// Functions

private "_convert";
_convert = {
	private ["_type","_data","_result","_key"];
	_key = _this select 0;
	_data = _this select 1;

	if (isNil "_data") exitWith {
		["NULL DATA! For the key %1", _key] call ALiVE_fnc_dump;
		_result = """""""""";
		_result;
	};

	// Get the type we are dealing with
	_type = typeName _data;
	if ([_data] call ALIVE_fnc_isHash) then {
		_type = "HASH";
	};

	// Store the type with the key in the dictionary
	if ([_logic,"storeType", false] call CBA_fnc_hashGet && _type != "STRING") then {
		[ALIVE_DataDictionary, "setDataDictionary", [_key, _type]] call ALIVE_fnc_Data;
	};
	//TRACE_2("ConvertData", _type, _data);

	switch(_type) do {
		case "ARRAY": {
			private ["_tmp","_i"];
//			TRACE_2("ARRAY CONVERSION DATA", _data, typeName _data);
			_tmp = "";
			_i = 0;
			{
				private ["_tmpKey","_value"];
//				TRACE_2("ARRAY CONVERSION X", _x, typeName _x);
				_tmpKey = _key + "_" + str(_i);

				// Convert Values
				if !(isNil "_x") then {
					_value = [_tmpKey, _x] call _convert;
	//				TRACE_2("ARRAY CONVERTED VALUE", typename _value, _value);
				} else {
					["NULL DATA! For the value %1", _x] call ALiVE_fnc_dump;
					_value = """""""""";
				};

				_tmp = _tmp + "," + _value;

				_i = _i + 1;
			} foreach _data;

			_result = "[" + _tmp + "]";

			// Get rid of any left over commas
			_result = [_result, "[,", "["] call CBA_fnc_replace;

//			TRACE_2("ARRAY CONVERSION RESULT", typename _result, _result);
		};
		case "BOOL": {
			private["_tmp"];
			_tmp = if(_data) then {"true"} else {"false"};
			_result = format["""%1""", _tmp]; // double quotes around string
		};
		case "GROUP": {
			_result = format["""%1""", _data];
		};
		case "HASH" : {
			_result = [_logic, "convert", [_data]] call ALIVE_fnc_Data;
		};
		case "OBJECT": {
			_result = format["""%1""", _data];
		};
		case "SCALAR": {
			_result = str(_data);
		};
		case "SIDE": {
			_result = format["""%1""", _data]; // double quotes around string
		};
		case "TEXT": {
			_result = format["""%1""", _data];
		};

		default {
			if ([_data] call CBA_fnc_strLen == 0) then {
				_data = "";
			};
			_result = format["""%1""", _data]; // double quotes around string
		};
	};
	_result;
};

private "_convertHash";
_convertHash = {
	private ["_convertedValue"];
	if (isNil "_value") then {
		["NULL VALUE! For the key %1", _key] call ALiVE_fnc_dump;
		_convertedValue = """";
	} else {
		_convertedValue = [_key, _value] call _convert;
	};
	_string = _string + "," + """" +_key + """" + ":" + _convertedValue;
};

// --------------------------------------------------------
// Main

private ["_result","_logic","_hash","_string"];

_logic = _this select 0;
_hash = (_this select 1) select 0;

_string = "";

if(isNil "_hash") exitWith {
	"ConvertData <null> type" call ALIVE_fnc_logger;
};

[_hash, _convertHash] call CBA_fnc_hashEachPair;

_result = "{" + _string + "}";

// replace {,
_result = [_result, "{,", "{"] call CBA_fnc_replace;

_result;
