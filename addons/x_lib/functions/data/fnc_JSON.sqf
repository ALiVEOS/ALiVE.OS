
/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_JSON

Description:
	An object for reading and writing JSON-formatted strings.
	
Parameters:
	0: ANY - object data reference
	1: STRING - member function name
	2: ANY - member function arguments
	
Member(s):
	"encode" - encodes a JSON string from SQF data
		Argument(s): ANY - SQF data value
		Returns: STRING - JSON encoded string
		Note(s): Must use the "ALiVE_fnc_unorderedMap" object for JSON objects.

	"decode" - decodes a JSON string to SQF data
		Argument(s): STRING - JSON encoded string
		Returns: ARRAY - SQF-based JSON DOM tree

	"get" - retrieves a SQF data value from a decoded JSON object
		Argument(s): ARRAY - JSON DOM path
		Returns: ANY - SQF data value
		
Returns:
	See Members

Attributes:
	N/A

Examples:
	N/A

See Also:

Author:
	Naught
---------------------------------------------------------------------------- */

private ["_data", "_func", "_args"];
_data = _this select 0;
_func = _this select 1;
_args = _this param [2, []];

#define JSON_DATA_TYPES ["","BOOL","SCALAR","STRING","ARRAY"]

switch (_func) do
{
	case "encode": // _args = any
	{
		private ["_fnc_varSqfToJson"];
		_fnc_varSqfToJson = {
			if (isNil "_this") exitWith {"null"};

			private ["_typeName"];
			_typeName = typeName _this;

			if (_typeName == "ARRAY") exitWith
			{
				if (!(_this isEqualTo []) && {typeName(_this select 0) == "STRING"} && {(_this select 0) == "unordered_map"}) then
				{
					private ["_values", "_ret"];
					_values = _this select 2;
					_ret = "{";

					{ // forEach
						if (_forEachIndex != 0) then {_ret = _ret + ','};
						_ret = _ret + format["%1:",str(_x)] + ((_values select _forEachIndex) call _fnc_varSqfToJson);
					} forEach (_this select 1);

					_ret + "}" // Return js object
				}
				else // Standard array
				{
					private ["_ret"];
					_ret = "[";

					{ // forEach
						if (_forEachIndex != 0) then {_ret = _ret + ','};
						_ret = _ret + (_x call _fnc_varSqfToJson);
					} forEach _this;

					_ret + "]" // Return array
				};
			};

			str(if (_typeName in JSON_DATA_TYPES) then {_this} else {str(_this)});
		};

		_args call _fnc_varSqfToJson; // Return JSON-encoded string
	};

	case "decode": // _args = "JSON-encoded string"
	{
		private ["_jsonStr"];
		_jsonStr = toArray(_args);

		private ["_inString", "_newChar"];
		_inString = false;

		{ // Replace JSON chars with SQF equivalents
			_inString = if (_inString) then {_x != 34} else {_x == 34}; // _inString XOR (_x == 34)

			if (!_inString) then
			{
				_newChar = (switch (_x) do
				{
					case 123: {91}; // '{' => '['
					case 125: {93}; // '}' => ']'
					case 058: {44}; // ':' => ','
/*					case 110: // "null" => "nil "
					{
						_jsonStr set [(_forEachIndex + 1), 105]; // 'u' => 'i'
						_jsonStr set [(_forEachIndex + 2), 108]; // 'l' => 'l'
						_jsonStr set [(_forEachIndex + 3), 032]; // 'l' => ' '

						-1 // Return -1 as replacement complete
					};*/
					default {-1};
				});

				if (_newChar >= 0) then
				{
					_jsonStr set [_forEachIndex, _newChar];
				};
			};
		} forEach _jsonStr;

		call compile toString(_jsonStr) // Return JSON object-array
	};

	case "get": // _args = ["json", "object", "path"]
	{
		{ // forEach
			private ["_i"];
			_i = (_data find _x) + 1;

			if ((_i % 2) == 0) exitWith // Node path not found
			{
				_data = nil; // Return nil on failure
			};

			_data = _data select _i;
		} forEach _args;

		_data // Return JSON node reference on success
	};
};
