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

private ["_hash", "_key", "_value", "_keys", "_values", "_default", "_index", "_isDefault"];

_hash = _this select 0;
_key = _this select 1;
_value = _this select 2;

_keys = _hash select HASH_KEYS;
_values = _hash select HASH_VALUES;
_default = _hash select HASH_DEFAULT_VALUE;

// Almost all ALiVE hashes use nil as their default. Keep that path native and
// reproduce BIS_fnc_areEqual only for backwards-compatible custom defaults.
_isDefault = if (isNil "_default") then {
    isNil "_value"
} else {
    if (isNil "_value") then {
        false
    } else {
        private _areEqual = {
            private ["_left", "_right", "_leftType", "_rightType"];

            _left = _this select 0;
            _right = _this select 1;

            _leftType = if (isNil "_left") then { "UNDEF" } else { typeName _left };
            _rightType = if (isNil "_right") then { "UNDEF" } else { typeName _right };

            if (_leftType != _rightType) exitWith { false };

            switch _leftType do {
                case "ARRAY": {
                    private _count = count _left;
                    if (_count != count _right) exitWith { false };

                    private _equal = true;
                    private _index = 0;
                    while {_index < _count && {_equal}} do {
                        _equal = [_left select _index, _right select _index] call _areEqual;
                        _index = _index + 1;
                    };
                    _equal
                };
                case "BOOL": { str _left == str _right };
                case "CODE": { str _left == str _right };
                case "SCRIPT": { !scriptDone _left && {str _left == str _right} };
                case "UNDEF": { true };
                case "OBJECT": { if (isNull _left) then { isNull _right } else { _left == _right } };
                case "GROUP": { if (isNull _left) then { isNull _right } else { _left == _right } };
                case "CONTROL": { if (isNull _left) then { isNull _right } else { _left == _right } };
                case "DISPLAY": { if (isNull _left) then { isNull _right } else { _left == _right } };
                default { _left == _right };
            };
        };

        [_value, _default] call _areEqual
    };
};

_index = _keys find _key;
if (_index >= 0) then {
    if (_isDefault) then {
        // _index came from _keys, so equal array lengths also make it valid for
        // _values. Reject malformed or aliased storage before mutating either.
        if (!(_keys isEqualType [])
            || {!(_values isEqualType [])}
            || {_keys isEqualRef _values}
            || {count _keys != count _values}) then {
            if (!isNil "ALiVE_DIAG_HASHSET" && {ALiVE_DIAG_HASHSET}) then {
                [
                    "DIAG-STRIP hashSet: skipped malformed removal key=%1 idx=%2 keysT=%3 valuesT=%4 nK=%5 nV=%6",
                    _key, _index, typeName _keys, typeName _values,
                    if (_keys isEqualType []) then { count _keys } else { -1 },
                    if (_values isEqualType []) then { count _values } else { -1 }
                ] call ALiVE_fnc_dump;
            };
        } else {
            _keys deleteAt _index;
            _values deleteAt _index;
        };
    } else {
        // Replace the original value for this key.
        _values set [_index, _value];
    };
} else {
    // Ignore values that are the same as the default.
    if (!_isDefault) then {
        // Root-cause guard (Jman 2026-05-29): keep HASH_KEYS and HASH_VALUES
        // in lock-step on insert. `pushBack nil` is a silent no-op, so a nil
        // _value here pushes the key but NOT the value, leaving keys one longer
        // than values (nK = nV + 1) -- the desync the removal branch later trips
        // the "Zero divisor" on. A nil/absent value means "no entry" anyway
        // (hashGet returns the default for a missing key), so push only when the
        // value is real, and push both together. Observed: profiles registered
        // before their position is set (fnc_profileHandler position index).
        if (!isNil "_value") then {
            _keys pushback _key;
            _values pushback _value;
        } else {
            if (!isNil "ALiVE_DIAG_HASHSET" && {ALiVE_DIAG_HASHSET}) then {
                ["DIAG-STRIP hashSet: skipped nil-value insert for new key=%1 (would desync keys/values)", _key] call ALiVE_fnc_dump;
            };
        };
    };
};

_hash
