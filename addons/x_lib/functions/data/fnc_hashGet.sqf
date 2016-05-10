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

private ["_hash","_key","_default","_result"];

_hash = _this select 0;
_key = _this select 1;

//Avoid passing a non-existing hash or key to the CBA function
if (isnil "_hash" || {isnil "_key"} || {!(typeName _hash == "ARRAY")}) exitwith {
    ["ALiVE_fnc_HashGet retrieved wrong input %1 from %2!",_this,_fnc_scriptNameParent] call ALiVE_fnc_Dump;
};

if(count _this > 2) then {
	_default = _this select 2;
	_result = [_hash, _key, _default] call CBA_fnc_hashGet;
} else {
	_result = [_hash, _key] call CBA_fnc_hashGet;
};
// check for default value
if(!(isNil "_result") && {typeName _result == "STRING"} && {_result == "UNDEF"} && {count _this > 2}) then {
	_default = _this select 2;
	_result = _default;
};

if !(isnil "_result") then {_result} else {nil};