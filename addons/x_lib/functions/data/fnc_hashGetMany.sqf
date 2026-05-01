#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(hashGetMany);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_hashGetMany

Description:
Retrieves many keys from a CBA hash

Parameters:
Array - The hash
String - The key to get value of
Mixed - The default value to return if key not found

Returns:
Array - A list of values for each of the passed keys

Examples:
(begin example)
// retrieve many keys at once
_values = [_hash, ["key1","key2","key3"]] call ALiVE_fnc_hashGetMany;

// retrieve many keys and pull them into local variables
([_hash, ["key1","key2","key3"]] call ALiVE_fnc_hashGetMany) params ["_value1","_value2",["_value3","defaultValue"]];
(end)

See Also:

Author:
ARJay
Wolffy
---------------------------------------------------------------------------- */

params ["_hash","_keys"];

private _hashKeys = _hash select 1;
private _hashValues = _hash select 2;

_keys apply {
    private _keyIndex = _hashKeys find _x;
    if (_keyIndex >= 0) then {
        _hashValues select _keyIndex
    };
}