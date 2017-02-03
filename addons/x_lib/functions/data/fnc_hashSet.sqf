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

params ["_hash","_key","_value"];

// is bew vakye the default value for this hash?
// if new value is nil = default

// selecting default value 3 times is faster than storing it
private _isDefault = if (
    isnil "_value" && isnil {_hash select HASH_DEFAULT_VALUE} ||
    {
        !isnil {_hash select HASH_DEFAULT_VALUE} &&
        {_value isEqualTo (_hash select HASH_DEFAULT_VALUE)}
    }
) then {true} else {false};

private _index = (_hash select HASH_KEYS) find _key;
if (_index >= 0) then {
    if (_isDefault) then {
        // Remove the key, if the new value is the default value.
        // Do this by copying the key and value of the last element
        // in the hash to the position of the element to be removed.
        // Then, shrink the key and value arrays by one. (#2407)

        private _keys = _hash select HASH_KEYS;
        private _values = _hash select HASH_VALUES;
        private _last = (count _keys) - 1;

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

    if (!_isDefault) then {
        (_hash select HASH_KEYS) pushback _key;
        (_hash select HASH_VALUES) pushback _value;
    };
};

_hash