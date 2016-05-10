#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(isHash);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_isHash

Description:
Is this a hash?

This was needed because of an existing bug in CBA_fnc_isHash...

Parameters:
Array - hash
Array - whitelist keys
Array - blacklist keys

Returns:
Array - The new hash

Examples:
(begin example)
_result = [_hash, ["apples","oranges"], ["grapes"]] call ALiVE_fnc_isHash;
(end)

See Also:

Author:
CBA
---------------------------------------------------------------------------- */

#define HASH_ID 0
#define TYPE_HASH "#CBA_HASH#"

private ["_value","_result"];

_value = _this select 0;

_result = false;

if ((typeName _value) == "ARRAY" && {(count _value) == 4} && {(typeName (_value select HASH_ID)) == (typeName TYPE_HASH)}) then {
	_result = ((_value select HASH_ID) == TYPE_HASH);
};

_result;
