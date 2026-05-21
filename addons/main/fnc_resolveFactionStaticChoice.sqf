#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(resolveFactionStaticChoice);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_resolveFactionStaticChoice

Description:
Module-init resolver for the ALiVE_FactionStaticDataChoice family. Parses
the canonical FACTION1=class1,class2;FACTION2=class3 string saved by the
attribute and merges each faction's class list into the supplied static-
data registry hash via ALIVE_fnc_hashSet.

Two merge modes:
    "REPLACE" (default) - faction's entry in the registry is fully
                          replaced with the user-supplied list.
                          Matches the legacy init.sqf override pattern
                          (mission-makers paste raw hashSet calls into
                          init.sqf which simply overwrite).
    "APPEND"            - faction's existing classes are kept and the
                          user-supplied list is added on top, deduped.
                          Useful when extending stock factions with a
                          handful of mod classes without losing the
                          existing entries.

A faction with an empty class list under either mode is a no-op for
that faction (REPLACE doesn't wipe the registry to empty; APPEND has
nothing to add).

Parameters:
    [_value, _hash, _mode]
    _value  : STRING - canonical FACTION=class,class;... string from the
              saved attribute. Empty string is a no-op.
    _hash   : HASH   - target static-data registry (e.g.
              ALIVE_factionDefaultTransport).
    _mode   : STRING - "REPLACE" or "APPEND" (default REPLACE).

Returns:
    SCALAR - number of factions whose registry entry was touched.

Examples:
(begin example)
private _value = _logic getVariable ["customLandTransport", ""];
[_value, ALIVE_factionDefaultTransport, "REPLACE"] call ALIVE_fnc_resolveFactionStaticChoice;
(end)

Author:
Jman
---------------------------------------------------------------------------- */

params [
    ["_value", "", [""]],
    ["_hash", nil],
    ["_mode", "REPLACE", [""]]
];

if (_value == "") exitWith { 0 };
if (isNil "_hash") exitWith {
    ["ALIVE resolveFactionStaticChoice: nil registry hash"] call ALiVE_fnc_dump;
    0
};

_mode = toUpper _mode;
if !(_mode in ["REPLACE", "APPEND"]) then {
    ["ALIVE resolveFactionStaticChoice: unknown mode '%1', defaulting to REPLACE", _mode] call ALiVE_fnc_dump;
    _mode = "REPLACE";
};

private _touched = 0;

private _entries = [_value, ";"] call CBA_fnc_split;
{
    private _entry = _x;
    while {count _entry > 0 && {(_entry select [0, 1]) == " "}} do { _entry = _entry select [1] };
    while {count _entry > 0 && {(_entry select [count _entry - 1, 1]) == " "}} do { _entry = _entry select [0, count _entry - 1] };
    if (_entry != "") then {
        private _eqIdx = _entry find "=";
        if (_eqIdx > 0) then {
            private _factionPart = _entry select [0, _eqIdx];
            private _classesPart = _entry select [_eqIdx + 1];
            while {count _factionPart > 0 && {(_factionPart select [count _factionPart - 1, 1]) == " "}} do { _factionPart = _factionPart select [0, count _factionPart - 1] };
            while {count _classesPart > 0 && {(_classesPart select [0, 1]) == " "}} do { _classesPart = _classesPart select [1] };

            private _classList = [];
            {
                private _cls = _x;
                while {count _cls > 0 && {(_cls select [0, 1]) == " "}} do { _cls = _cls select [1] };
                while {count _cls > 0 && {(_cls select [count _cls - 1, 1]) == " "}} do { _cls = _cls select [0, count _cls - 1] };
                if (_cls != "") then { _classList pushBackUnique _cls };
            } forEach ([_classesPart, ","] call CBA_fnc_split);

            if (_factionPart != "" && {count _classList > 0}) then {
                if (_mode == "APPEND") then {
                    private _existing = [_hash, _factionPart, []] call ALIVE_fnc_hashGet;
                    {
                        if !(_x in _existing) then { _existing pushBack _x };
                    } forEach _classList;
                    [_hash, _factionPart, _existing] call ALIVE_fnc_hashSet;
                } else {
                    [_hash, _factionPart, _classList] call ALIVE_fnc_hashSet;
                };
                _touched = _touched + 1;
            };
        };
    };
} forEach _entries;

_touched
