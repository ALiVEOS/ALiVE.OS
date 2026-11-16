#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsDataClassName);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsDataClassName

Description:
Builds and checks the class names of a studio faction.

"auto": <TAG>_<Name>. From the name keep letters, digits and _, turn spaces and
dashes into _, drop everything else, collapse repeated _, cut to 64. When the
result is taken, _2, _3 and so on are added. For a group pass "<Category> <Name>"
as the name, giving <TAG>_<Category>_<Name>.

"check": is a class name free.
    Taken means another entry of this faction has it (lower-cased compare, config
    is case-insensitive) or, for units and vehicles, CfgVehicles has it and it is
    not this faction's own earlier export.
    Own means getText ALiVE_FS_tag equals the tag, or an old ORBAT export
    (ALiVE_orbatCreator_owned 1) whose faction is this faction's class. Own is
    allowed; the owner then names its CfgPatches class so the caller can raise
    W_OLD_LOADED.

Parameters:
    _op      - STRING - "auto" or "check"
    _faction - HASHMAP - the faction
    _text    - STRING - the name ("auto") or the class name ("check")
    _ownId   - STRING - the id of the entry the name is for, never counted as taken
    _kind    - STRING - "unit", "vehicle" or "group" (default "unit")

Returns:
    "auto"  - STRING - a free class name
    "check" - ARRAY - [ok, owner]:
              [true, ""] free; [true, patch] own earlier export (W_OLD_LOADED);
              [false, ""] not a valid class name (S_NAME_BAD);
              [false, owner] taken (S_NAME_TAKEN): an entry id of this faction,
              or the CfgPatches class that defines it

Examples:
    (begin example)
    private _class = ["auto", _faction, "Rifleman (AT)", "u12", "unit"] call ALiVE_fnc_fsDataClassName;
    (["check", _faction, "AMIL_Rifleman", "u12"] call ALiVE_fnc_fsDataClassName) params ["_ok", "_owner"];
    (end)

See Also:
    ALiVE_fnc_fsDataUnit, ALiVE_fnc_fsDataGroup

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_op", "check", [""]], ["_faction", createHashMap, [createHashMap]], ["_text", "", [""]], ["_ownId", "", [""]], ["_kind", "unit", [""]]];

private _tag = _faction getOrDefault ["tag", ""];
private _dicts = if (_kind isEqualTo "group") then { ["groups"] } else { ["units", "vehicles"] };

// Every class the faction already uses, lower case to id, built once per call: the "auto" loop below may
// test many names, and scanning every entry for each one made a big import slow.
private _taken = createHashMap;
{
    {
        if !(_x == _ownId) then { _taken set [toLower (_y getOrDefault ["class", ""]), _x] };
    } forEach (_faction getOrDefault [_x, createHashMap]);
} forEach _dicts;

private _check = {
    params ["_class"];
    if !(([_class, "class"] call ALiVE_fnc_fsDataCheckValue) isEqualTo "") exitWith { [false, ""] };
    private _hit = _taken getOrDefault [toLower _class, ""];
    if !(_hit isEqualTo "") exitWith { [false, _hit] };
    if (_kind isEqualTo "group") exitWith { [true, ""] };
    private _cfg = configFile >> "CfgVehicles" >> _class;
    if !(isClass _cfg) exitWith { [true, ""] };
    private _patch = (configSourceAddonList _cfg) param [0, "CfgVehicles"];
    private _own = (!(_tag isEqualTo "") && {(getText (_cfg >> "ALiVE_FS_tag")) == _tag})
        || {(getNumber (_cfg >> "ALiVE_orbatCreator_owned")) == 1 && {(getText (_cfg >> "faction")) == (_faction getOrDefault ["class", ""])}};
    [_own, _patch]
};

if (_op isEqualTo "check") exitWith { [_text] call _check };

// "auto"
private _codes = [];
{
    if ((_x >= 48 && {_x <= 57}) || {_x >= 65 && {_x <= 90}} || {_x >= 97 && {_x <= 122}}) then {
        _codes pushBack _x;
    } else {
        if (_x in [32, 45, 95]) then { _codes pushBack 95 };
    };
} forEach (toArray _text);
// splitString drops empty pieces, so this collapses repeated _ and trims the ends.
private _clean = ((toString _codes) splitString "_") joinString "_";
if (_clean isEqualTo "") then { _clean = ["Unit", "Group"] select (_kind isEqualTo "group") };

private _base = if (_tag isEqualTo "") then { _clean } else { _tag + "_" + _clean };
// A class name starts with a letter.
private _first = (toArray _base) param [0, 0];
if !((_first >= 65 && {_first <= 90}) || {_first >= 97 && {_first <= 122}}) then { _base = "C_" + _base };
_base = _base select [0, 64];

private _name = _base;
private _n = 1;
while { !(([_name] call _check) select 0) && {_n < 1000} } do {
    _n = _n + 1;
    private _suffix = "_" + (_n toFixed 0);
    _name = (_base select [0, 64 - (count _suffix)]) + _suffix;
};
_name
