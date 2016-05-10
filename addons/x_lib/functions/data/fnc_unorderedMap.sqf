
/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_unorderedMap

Description:
	An object for manipulating an unordered map.
	
Parameters:
	0: ANY - object data reference
	1: STRING - member function name
	2: ANY - member function arguments

Member(s):
	"new" - creates a new, empty unordered map
		Argument(s): NONE
		Returns: ARRAY - unordered map data
		
	"delete" - clears an unordered map
		Argument(s): NONE
		Returns: ARRAY - unordered map data
		
	"at" - accesses a value at a specific key
		Argument(s):
			0: STRING - key
			1 (Optional): ANY - default value
		Returns: ANY - value
		
	"find" - returns the index of a specific key
		Argument(s): STRING - key
		Returns: NUMBER - key index
		
	"size" - returns the number of map values
		Argument(s): NONE
		Returns: NUMBER - map size
		
	"count" - returns the number of occurences of a key
		Argument(s): STRING - key
		Returns: NUMBER - occurence count
		
	"in" - checks if a key is in the map
		Argument(s): STRING - key
		Returns: BOOL - key found
		
	"insert" - inserts a key/value pair in the map (overwrites)
		Argument(s):
			0: STRING - key
			1: ANY - value
		Returns: NUMBER - key index
		
	"erase" - erases a key/value pair from the map
		Argument(s): STRING - key
		Returns: BOOL - erase success	

Returns:
	See Members

Attributes:
	N/A

Examples:
	N/A

See Also:
	- <>

Author:
	Naught
---------------------------------------------------------------------------- */

private ["_data", "_func", "_args"];
_data = _this select 0;
_func = _this select 1;
_args = _this param [2, []];

switch (_func) do
{
	case "new": // _args = nil
	{
		["unordered_map", [], []] // Return empty map data
	};
	
	case "delete": // _args = nil
	{
		_data set [1, []];
		_data set [2, []];
		true; // Return true on success
	};
	
	case "at": // _args = "key" or ["key", default]
	{
		private ["_index"];
		_index = (_data select 1) find ([_args, 0, ""] call BIS_fnc_param);
		
		if (_index >= 0) then
		{
			(_data select 2) select _index;
		}
		else
		{
			[_args, 1, nil] call BIS_fnc_param; // Return default or nil on failure
		};
	};
	
	case "find": // _args = "key"
	{
		(_data select 1) find _args;
	};
	
	case "size": // _args = nil
	{
		count (_data select 1);
	};
	
	case "count": // _args = "key"
	{
		{_x == _args} count (_data select 1);
	};
	
	case "in": // _args = "key"
	{
		_args in (_data select 1);
	};
	
	case "insert": // _args = ["key", value]
	{
		private ["_key", "_keys"];
		_key = _args select 0;
		_keys = _data select 1;
		
		private ["_index"];
		_index = _keys find _key;
		
		if (_index < 0) then
		{
			_index = count _keys;
			_keys set [_index, _key];
		};
		
		(_data select 2) set [_index, (_args select 1)];
		
		_index
	};
	
	case "erase": // _args = "key"
	{
		private ["_keys", "_values"];
		_keys = _data select 1;
		_values = _data select 2;
		
		private ["_index"];
		_index = _keys find _args;
		
		if (_index >= 0) then
		{
			_keys set [_index, objNull];
			_data set [1, (_keys - [objNull])];
			
			_values set [_index, objNull];
			_data set [2, (_values - [objNull])];
			
			true; // Return true on success
		}
		else
		{
			false; // Return false on failure
		};
	};
};
