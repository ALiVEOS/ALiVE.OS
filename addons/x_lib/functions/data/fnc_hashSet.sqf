#include "\x\alive\addons\x_lib\script_component.hpp"
#include "\x\cba\addons\hashes\script_hashes.hpp"
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

if (isnil "_hash") then {
    ["====================== ALIVE_FNC_HASHSET - NIL HASH PASSED FROM %1", _fnc_scriptNameParent] call ALiVE_fnc_Dump;
};

private _hashDefault = _hash select HASH_DEFAULT_VALUE;
private _isDefault = if (!isnil "_value") then {
    if (isnil "_hashDefault") then {
        false
    } else {
        _value isequalto (_hash select HASH_DEFAULT_VALUE)
    };
} else {
    // return true if both values are nil
    isnil "_hashDefault"
};

private _index = (_hash select HASH_KEYS) find _key;
if (_index >= 0) then {
    if (!_isDefault) then {
        // Replace existing value for this key.
        (_hash select HASH_VALUES) set [_index, _value];
    } else {
        // If the new value is the default value, remove the key.

        (_hash select HASH_KEYS) deleteat _index;
        (_hash select HASH_VALUES) deleteat _index;
    };
} else {
    // Add new key
    if (!_isDefault) then {
        (_hash select HASH_KEYS) pushback _key;
        (_hash select HASH_VALUES) pushback _value;
    };
};

_hash
