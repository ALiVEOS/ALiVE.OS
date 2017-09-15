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

private _value = _this select 0;

if (_value isEqualType [] && {(count _value) == 4} && {(_value select HASH_ID) isEqualType TYPE_HASH}) then {
    (_value select HASH_ID) isEqualTo TYPE_HASH
} else {
    false
};