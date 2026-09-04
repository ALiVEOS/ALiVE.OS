#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(resolvePreferredGarrisonPositions);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_resolvePreferredGarrisonPositions

Description:
Resolver for the preferredGarrisonPositions attribute. Parses the canonical
Class1=1,2,3;Class2=0,4 string into a hash keyed by lower-cased building
classname, each value the list of buildingPos indices to seat first, in the
order written. Entries may also be separated by line breaks, since the
attribute is a multi-line Eden field and a line per entry is the natural way
to fill one in.

Grammar and the skip rather than throw treatment of malformed segments follow
ALIVE_fnc_resolveFactionStaticChoice. Two things are reported that it does not
report, because both otherwise read as "the setting does nothing":

    a segment that cannot be understood at all, and
    a classname that parses cleanly but names nothing in CfgVehicles.

The second is the likelier mistake of the two. Land_vn_hut_1 with the zero
missing is perfectly well formed, so nothing but a config lookup can tell it
from a real class.

Whether a model actually carries a written index cannot be known here. That
depends on a placed instance rather than on config, so range checking stays
with the seating loop, which already drops a position reading as the world
origin.

Parameters:
    _value : STRING - canonical Class=idx,idx;... string. Empty is a no-op.

Returns:
    HASH - lower-cased classname to index array. Empty hash when nothing
    usable was written; the seating path treats an empty hash as no override.

Examples:
(begin example)
private _hash = ["Land_vn_hut_01=1,2,3;Land_vn_bunker_01=0,4"] call ALIVE_fnc_resolvePreferredGarrisonPositions;
(end)

See Also:
- <ALIVE_fnc_resolveFactionStaticChoice>

Author:
Jman
---------------------------------------------------------------------------- */

params [
    ["_value", "", [""]]
];

private _hash = [] call ALIVE_fnc_hashCreate;

if (_value == "") exitWith { _hash };

// The attribute comes from a multi-line Eden control, so a line break is as
// likely a separator as the documented semicolon, and pasted text can carry
// tabs and carriage returns. Tabs fold to spaces, because a tab inside an entry
// must not cut it in two; line ends fold to entry breaks. After that the
// space-only trims below are enough, and they stay identical to the ones in
// fnc_resolveFactionStaticChoice.
_value = (_value splitString toString [9]) joinString " ";
_value = (_value splitString toString [13,10]) joinString ";";

private _rejected = [];
private _unknown = [];

{
    private _entry = _x;
    while {count _entry > 0 && {(_entry select [0, 1]) == " "}} do { _entry = _entry select [1] };
    while {count _entry > 0 && {(_entry select [count _entry - 1, 1]) == " "}} do { _entry = _entry select [0, count _entry - 1] };

    if (_entry != "") then {
        private _applied = false;
        private _eqIdx = _entry find "=";

        if (_eqIdx > 0) then {
            private _classPart = _entry select [0, _eqIdx];
            private _indexPart = _entry select [_eqIdx + 1];
            while {count _classPart > 0 && {(_classPart select [count _classPart - 1, 1]) == " "}} do { _classPart = _classPart select [0, count _classPart - 1] };
            while {count _indexPart > 0 && {(_indexPart select [0, 1]) == " "}} do { _indexPart = _indexPart select [1] };

            private _indexList = [];
            {
                private _token = _x;
                while {count _token > 0 && {(_token select [0, 1]) == " "}} do { _token = _token select [1] };
                while {count _token > 0 && {(_token select [count _token - 1, 1]) == " "}} do { _token = _token select [0, count _token - 1] };

                // Digits only. parseNumber reads "1a" as 1 and "x" as 0, and zero is a
                // real position index, so a typo must never quietly become a seat.
                private _isIndex = _token != "";
                { if (_x < 48 || {_x > 57}) then { _isIndex = false }; } forEach toArray _token;

                if (_isIndex) then {
                    private _idx = parseNumber _token;
                    // First occurrence keeps its rank. The list is an ordering, not a set.
                    if !(_idx in _indexList) then { _indexList pushBack _idx };
                };
            } forEach ([_indexPart, ","] call CBA_fnc_split);

            if (_classPart != "" && {count _indexList > 0}) then {
                // Classnames are case insensitive everywhere else in Arma, so the key is
                // stored folded and every lookup folds the same way. The capitalisation
                // somebody happens to type must never decide whether their setting works.
                [_hash, toLower _classPart, _indexList] call ALIVE_fnc_hashSet;
                _applied = true;

                if !(isClass (configFile >> "CfgVehicles" >> _classPart)) then {
                    _unknown pushBack _classPart;
                };
            };
        };

        if (!_applied) then { _rejected pushBack _entry };
    };
} forEach ([_value, ";"] call CBA_fnc_split);

// Reported once per distinct string rather than once per garrison. The seating
// path parses on every spawn, so an unconditional line here would repeat for
// every group at every objective and again on each respawn.
if !(_rejected isEqualTo [] && {_unknown isEqualTo []}) then {
    private _seen = missionNamespace getVariable ["ALiVE_preferredGarrisonReported", []];
    if !(_value in _seen) then {
        _seen pushBack _value;
        missionNamespace setVariable ["ALiVE_preferredGarrisonReported", _seen];

        if !(_rejected isEqualTo []) then {
            ["ALiVE preferredGarrisonPositions - %1 class(es) accepted, %2 segment(s) not understood and skipped: %3",
             count (_hash select 1), count _rejected, _rejected] call ALiVE_fnc_dump;
        };
        if !(_unknown isEqualTo []) then {
            ["ALiVE preferredGarrisonPositions - %1 class(es) named in the setting do not exist in CfgVehicles and will match nothing: %2",
             count _unknown, _unknown] call ALiVE_fnc_dump;
        };
    };
};

_hash
