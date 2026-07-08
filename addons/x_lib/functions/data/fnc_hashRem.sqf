#include "\x\alive\addons\x_lib\script_component.hpp"
#include "\x\cba\addons\hashes\script_hashes.hpp"
SCRIPT(hashRem);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_hashRem

Description:
Removes a key/value pair from an ALiVE hash (direct find + deleteAt)

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
Jman
---------------------------------------------------------------------------- */

private ["_hash","_key","_keys","_values","_index"];

_hash = _this select 0;
_key = _this select 1;

// Remove the key/value pair directly instead of delegating to
// ALiVE_fnc_hashSet's set-back-to-default path. That path silently kept
// the key behind: BIS_fnc_areEqual is unreliable when the hash default
// is nil, and hashSet's malformed-hash guard compared keys/values by
// VALUE, so any hash storing each key as its own value (the C2ISTAR
// task index hashes: activeTasks/managedTasks/sideTasks/playerTasks all
// store [taskID, taskID]) always looked aliased and the removal was
// skipped. The stale keys wedged the task manager after the first auto
// task completed -- no completion teardown, no next task, no errors
// (#942). deleteAt mutates one entry per array per call and has no
// `select _last` step, so it cannot throw the out-of-range "Zero
// divisor" the old swap-and-shrink removal could.
_keys = _hash select HASH_KEYS;
_values = _hash select HASH_VALUES;

if (_keys isEqualType [] && {_values isEqualType []}
    && {!(_keys isEqualRef _values)}
    && {count _keys == count _values}) then {

    _index = _keys find _key;

    if (_index >= 0) then {
        _keys deleteAt _index;
        _values deleteAt _index;
    };
} else {
    // Malformed hash (keys/values are the same array reference, or the
    // counts are desynced) -- leave it untouched, same policy as the
    // removal-branch guard in ALiVE_fnc_hashSet. DIAG-STRIP.
    if (!isNil "ALiVE_DIAG_HASHSET" && {ALiVE_DIAG_HASHSET}) then {
        [
            "DIAG-STRIP hashRem: skipped malformed removal key=%1 keysT=%2 valuesT=%3",
            _key,
            if (isNil "_keys") then { "nil" } else { typeName _keys },
            if (isNil "_values") then { "nil" } else { typeName _values }
        ] call ALiVE_fnc_dump;
    };
};

_hash; // Return.
