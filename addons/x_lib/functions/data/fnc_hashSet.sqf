#include <\x\alive\addons\x_lib\script_component.hpp>
#include <\x\cba\addons\hashes\script_hashes.hpp>
SCRIPT(hashSet);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_hashSet

Description:
Wrapper for CBA_fnc_hashSet

Parameters:
Array - The hash
String - The key to set value of
Mixed - The value to store

Returns:
Array - The hash

Examples:
(begin example)
_result = [_hash, "key", "value"] call ALiVE_fnc_hashSet;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_hash","_key","_value","_index","_isDefault"];

_hash = _this select 0;
_key = _this select 1;
_value = _this select 2;

private ["_index", "_isDefault"];

if (isNil "BIS_fnc_areEqual") then { LOG( "WARNING: BIS_fnc_areEqual is Nil") };

// Work out whether the new value is the default value for this assoc.
_isDefault = [if (isNil "_value") then { nil } else { _value },
_hash select HASH_DEFAULT_VALUE] call (uiNamespace getVariable "BIS_fnc_areEqual");

_index = (_hash select HASH_KEYS) find _key;
if (_index >= 0) then
{
	if (_isDefault) then
	{
		// Remove the key, if the new value is the default value.
		// Do this by copying the key and value of the last element
		// in the hash to the position of the element to be removed.
		// Then, shrink the key and value arrays by one. (#2407)
		private ["_keys", "_values", "_last"];
		
		_keys = _hash select HASH_KEYS;
		_values = _hash select HASH_VALUES;
		_last = (count _keys) - 1;
		
		_keys set [_index, _keys select _last];
		_keys resize _last;
		
		_values set [_index, _values select _last];
		_values resize _last;
	} else {
		// Replace the original value for this key.
		(_hash select HASH_VALUES) set [_index, _value];
	};
} else {
	// Ignore values that are the same as the default.
	if (not _isDefault) then
	{
		PUSH(_hash select HASH_KEYS,_key);
		PUSH(_hash select HASH_VALUES,_value);
	};
};

_hash; // Return.
