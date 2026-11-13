#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(hashCopy);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_hashCopy

Description:
Copies a hash.

Parameters:
Array - hash
Array - whitelist keys
Array - blacklist keys

Returns:
Array - The new hash

Examples:
(begin example)
_result = [_hash, ["apples","oranges"], ["grapes"]] call ALiVE_fnc_hashCopy;
(end)

See Also:

Author:
ARJay
Jman
---------------------------------------------------------------------------- */

params ["_target", ["_whitelist", []], ["_blacklist", []]];

// Builds the copy's key and value lists directly. The old loop went through
// hashGet and hashSet for every key, and each hashSet searched the keys built
// so far, so copying every profile for a save took most of the save's time in
// the one frame the autosave holds the server. The result is the same: a
// blacklist, when given, wins over the whitelist; nested hashes are copied
// with the same lists; other arrays are copied; and the copy has the plain
// nil default of a new hash, as before.
private _fnc_copy = {
    params ["_source"];
    private _keys = [];
    private _values = [];
    private _sourceValues = _source select 2;
    {
        private _copy = if (_blacklist isNotEqualTo []) then { !(_x in _blacklist) } else { _whitelist isEqualTo [] || {_x in _whitelist} };
        if (_copy) then {
            private _value = _sourceValues select _forEachIndex;
            if (!isNil "_value") then {
                if (_value isEqualType []) then {
                    _value = if ([_value] call ALIVE_fnc_isHash) then { [_value] call _fnc_copy } else { +_value };
                };
                _keys pushBack _x;
                _values pushBack _value;
            };
        };
    } forEach (_source select 1);
    private _hash = [] call ALIVE_fnc_hashCreate;
    _hash set [1, _keys];
    _hash set [2, _values];
    _hash
};

[_target] call _fnc_copy
