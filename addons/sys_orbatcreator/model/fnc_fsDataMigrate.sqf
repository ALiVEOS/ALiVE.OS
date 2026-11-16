#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsDataMigrate);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsDataMigrate

Description:
Brings a plain studio faction from an older schema up to FS_SCHEMA. Runs on the
plain form before the schema walk of ALiVE_fnc_fsDataFromPlain.

Rule for every later phase: adding a key with a default needs no schema bump;
renaming, removing or changing the meaning of a key does, with a case below.

A schema above FS_SCHEMA is refused (S_PASTE_NEWER): this build cannot know what
the newer keys mean.

Parameters:
    _plain - ARRAY - the plain form
    _from  - NUMBER - the schema it was written with

Returns:
    ARRAY - [ok, plain, notes]; when ok is false, notes holds the one problem as
            [key, args...] (S_PASTE_NEWER with the schema, or S_PASTE_BAD)

Examples:
    (begin example)
    ([_plain, 1] call ALiVE_fnc_fsDataMigrate) params ["_ok", "_plain", "_notes"];
    (end)

See Also:
    ALiVE_fnc_fsDataParse, ALiVE_fnc_fsDataStore

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_plain", [], [[]]], ["_from", 0]];

if (!(_from isEqualType 0) || {!(finite _from)} || {_from < 1} || {_from != floor _from}) exitWith {
    [false, _plain, [["S_PASTE_BAD", "no schema number"]]]
};
if (_from > FS_SCHEMA) exitWith { [false, _plain, [["S_PASTE_NEWER", _from toFixed 0]]] };

private _notes = [];

while { _from < FS_SCHEMA } do {
    switch (_from) do {
        // case 1: { rewrite _plain from schema 1 to 2, then note it };
        default {};
    };
    _from = _from + 1;
};

[true, _plain, _notes]
