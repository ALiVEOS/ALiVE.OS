#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(hashGet);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_hashGet

Description:
Wrapper for CBA_fnc_hashGet

Parameters:
Array - The hash
String - The key to get value of
Mixed - The default value to return if key not found

Returns:
Mixed - The value

Examples:
(begin example)
// get from hash key
_result = [_hash, "key"] call ALiVE_fnc_hashGet;

// get from hash key with default value
_result = [_hash, "key", "value"] call ALiVE_fnc_hashGet;
(end)

See Also:

Author:
ARJay
Wolffy
---------------------------------------------------------------------------- */

params ["_hash","_key","_default"];

//Avoid passing a non-existing hash or key to the CBA function
if (isnil "_hash" || {isnil "_key"} || {!(_hash isEqualType [])}) exitwith {
    ["ALiVE_fnc_HashGet retrieved wrong input %1 from %2!", _this, _fnc_scriptNameParent] call ALiVE_fnc_Dump;
};

// check if default value was passed

private "_result";

if(!isnil "_default") then {
    _result = [_hash, _key, _default] call CBA_fnc_hashGet;

    // check for default value

    if (!isnil "_result" && {_result isEqualTo "UNDEF"}) then {
        _result = _default;
    };
} else {
    _result = [_hash, _key] call CBA_fnc_hashGet;
};

if !(isnil "_result") then {_result} else {nil};