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
Jman
---------------------------------------------------------------------------- */

private ["_hash","_key","_value","_index","_isDefault"];

_hash = _this select 0;
_key = _this select 1;
_value = _this select 2;

private ["_index", "_isDefault"];

if (isNil "BIS_fnc_areEqual") then { LOG( "WARNING: BIS_fnc_areEqual is Nil") };

// DIAG-STRIP : Phase 6 hashSet "Zero divisor" trace logger. Gated OFF
// by default - hashSet is hot enough that an unconditional dump
// produces ~200k RPT lines per short test run, drowning every other
// signal. Set the global flag at debug-console / init.sqf to enable:
//
//     ALiVE_DIAG_HASHSET = true;
//
// When enabled, every hashSet call writes its key + valueType + value
// to the RPT so the line immediately preceding any future "Zero
// divisor" engine error inside fnc_hashSet's default-value-removal
// branch identifies the offending pair. Investigation context
// (single-occurrence ~3 min after mission init, civilian-agent
// virtual-to-real transition, not reliably reproducible) is captured
// in the project memory. Tagged DIAG-STRIP for easy removal /
// extension.
//
// Nil _value is a valid call shape (signals default-removal branch) -
// the original code's isNil check below handles it. Diag guards the
// format call or it spams "Undefined variable in expression: _value".
if (!isNil "ALiVE_DIAG_HASHSET" && {ALiVE_DIAG_HASHSET}) then {
    [
        "DIAG-STRIP hashSet: key=%1 valueType=%2 value=%3",
        _key,
        if (isNil "_value") then { "nil" } else { typeName _value },
        if (isNil "_value") then { "<nil>" } else { _value }
    ] call ALiVE_fnc_dump;
};

// Work out whether the new value is the default value for this assoc.
_isDefault = [if (isNil "_value") then { nil } else { _value },
_hash select HASH_DEFAULT_VALUE] call (uiNamespace getVariable "BIS_fnc_areEqual");

_index = (_hash select HASH_KEYS) find _key;
if (_index >= 0) then
{
    if (_isDefault) then
    {
        // Remove the key, if the new value is the default value.
        // Do this by copying the key and value of the last element
        // in the hash to the position of the element to be removed.
        // Then, shrink the key and value arrays by one. (#2407)
        private ["_keys", "_values", "_last"];

        _keys = _hash select HASH_KEYS;
        _values = _hash select HASH_VALUES;
        _last = (count _keys) - 1;

        // Defensive guard (Jman 2026-05-28): a malformed hash reaching this
        // swap-and-shrink removal branch threw "Zero divisor" at the
        // `_values select _last` step -- _keys was a sane array but _values
        // was nil / wrong-type / shorter than _keys (HASH_VALUES out of sync
        // with HASH_KEYS). Verify the structure is consistent before
        // mutating; if not, log the offending state once and leave the hash
        // untouched rather than crash. Captured during military-placement
        // spawn (not the civilian transition the memo first hypothesised).
        if (!(_keys isEqualType []) || !(_values isEqualType [])
            || {_last < 0} || {_index > _last}
            || {count _values != count _keys}) then {
            // Malformed hash — leave it untouched instead of running the
            // swap-and-shrink, which would throw "Zero divisor" on the
            // out-of-range select. The skipped key holds the default value
            // anyway, so keeping it is functionally harmless (just one
            // redundant entry). Trace gated behind the same flag as the
            // canary above (default off; set ALiVE_DIAG_HASHSET = true to
            // surface), via ALiVE_fnc_dump for the standard prefix. DIAG-STRIP.
            if (!isNil "ALiVE_DIAG_HASHSET" && {ALiVE_DIAG_HASHSET}) then {
                [
                    "DIAG-STRIP hashSet: skipped malformed removal key=%1 idx=%2 last=%3 keysT=%4 valuesT=%5 nK=%6 nV=%7",
                    _key, _index, _last, typeName _keys, typeName _values,
                    if (_keys isEqualType []) then { count _keys } else { -1 },
                    if (_values isEqualType []) then { count _values } else { -1 }
                ] call ALiVE_fnc_dump;
            };
        } else {
            _keys set [_index, _keys select _last];
            _keys resize _last;

            _values set [_index, _values select _last];
            _values resize _last;
        };
    } else {
        // Replace the original value for this key.
        (_hash select HASH_VALUES) set [_index, _value];
    };
} else {
    // Ignore values that are the same as the default.
    if (not _isDefault) then
    {
        // Root-cause guard (Jman 2026-05-29): keep HASH_KEYS and HASH_VALUES
        // in lock-step on insert. `pushBack nil` is a silent no-op, so a nil
        // _value here pushes the key but NOT the value, leaving keys one longer
        // than values (nK = nV + 1) -- the desync the removal branch later trips
        // the "Zero divisor" on. The nil check above can also miss this: a nil
        // _value is routed through BIS_fnc_areEqual inside a [nil, ...] array,
        // and SQF drops nils from array literals, so _isDefault isn't reliable
        // for the nil case. A nil/absent value means "no entry" anyway (hashGet
        // returns the default for a missing key), so push only when the value is
        // real, and push both together. Observed: profiles registered before
        // their position is set (fnc_profileHandler position index).
        if (!isNil "_value") then {
            PUSH(_hash select HASH_KEYS,_key);
            PUSH(_hash select HASH_VALUES,_value);
        } else {
            if (!isNil "ALiVE_DIAG_HASHSET" && {ALiVE_DIAG_HASHSET}) then {
                ["DIAG-STRIP hashSet: skipped nil-value insert for new key=%1 (would desync keys/values)", _key] call ALiVE_fnc_dump;
            };
        };
    };
};

_hash; // Return.
