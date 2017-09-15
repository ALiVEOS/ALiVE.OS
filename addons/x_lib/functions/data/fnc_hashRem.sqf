#include <\x\alive\addons\x_lib\script_component.hpp>
#include <\x\cba\addons\hashes\script_hashes.hpp>
SCRIPT(hashRem);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_hashRem

Description:
Wrapper for CBA_fnc_hashRem

Parameters:
Array - The hash
String - The key to remove

Returns:

Examples:
(begin example)
_result = [_hash, "key"] call ALiVE_fnc_hashRem;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

params ["_hash","_key"];

[_hash, _key, _hash select HASH_DEFAULT_VALUE] call ALIVE_fnc_hashSet;

_hash