#include "\x\alive\addons\x_lib\script_component.hpp"
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
//
// The length test matters as much as the type test. A hash holds its default,
// its keys and its values, so anything shorter than three entries cannot be
// read from. An empty array is still an array, so it used to sail past the
// type test and then fail on the next line with "0 elements provided, 2
// expected", which points at this file and tells the reader nothing about who
// actually passed the bad value. Callers hand one over more easily than it
// looks: asking for a missing key with a default of [] returns exactly that.
// Caught in the field from the civilian crowd code, where a lookup for a
// cluster that had gone inactive returned [] and took the next two lines down
// with it. Turning it away here reports the caller by name instead.
if (isnil "_hash" || {isnil "_key"} || {!(typeName _hash == "ARRAY")} || {count _hash < 3}) exitwith {
    ["ALiVE_fnc_HashGet retrieved wrong input from %2 - %1",_this,_fnc_scriptNameParent] call ALiVE_fnc_Dump;
};

private _keyIndex = (_hash select 1) find _key;
if (_keyIndex >= 0) then {
    (_hash select 2) select _keyIndex
} else {
    if (isnil "_default") then {
        nil
    } else {
        if (_default isequaltype []) then {
            +_default
        } else {
            _default
        }
    }
}