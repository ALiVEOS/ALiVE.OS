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

private ["_hash","_key","_defaultValue"];

_hash = _this select 0;
_key = _this select 1;

private ["_defaultValue"];

_defaultValue = _hash select HASH_DEFAULT_VALUE;
[_hash, _key, if (isNil "_defaultValue") then { nil } else { _defaultValue }] call ALIVE_fnc_hashSet;

_hash; // Return.
