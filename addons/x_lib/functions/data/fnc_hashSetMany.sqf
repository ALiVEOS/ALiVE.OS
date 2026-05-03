#include "\x\alive\addons\x_lib\script_component.hpp"
#include "\x\cba\addons\hashes\script_hashes.hpp"
SCRIPT(hashSetMany);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_hashSetMany

Description:
Sets multiple key-value pairs on a CBA hash

Parameters:
Array - The hash
Array - The array of key-value pairs
    String - The key
    Any - The value

Returns:
Array - The hash

Examples:
(begin example)
_result = [_hash, [
    "key1", "value1",
    "key2", "value2",
    "key3", "value3"
]] call ALiVE_fnc_hashSetMany;
(end)

See Also:

Author:
SpyderBlack723
---------------------------------------------------------------------------- */

params ["_hash","_pairs"];

_hash params ["_keys","_values","_defaultValue"];

{
    _x params ["_key","_value"];

    private _isDefault = _value isequalto _defaultValue;

    private _keyIndex = _keys find _key;
    if (_keyIndex != -1) then {
        if (_isDefault) then {
            _keys deleteat _keyIndex;
            _values deleteat _keyIndex;
        } else {
            _values set [_keyIndex, _value];
        }
    } else {
        if (!_isDefault) then {
            _keys pushBack _key;
            _values pushBack _value;
        };
    };
} foreach _pairs;

_hash
