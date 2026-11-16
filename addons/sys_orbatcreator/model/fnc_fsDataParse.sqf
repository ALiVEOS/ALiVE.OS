#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsDataParse);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsDataParse

Description:
Reads share text (ALIVEFS|<schema>|<length>|<payload>) back into a studio
faction. The text may come from anyone, so it is never compiled: the header is
checked first, then parseSimpleArray, which can only make strings, numbers,
bools and arrays, and then the schema walk of ALiVE_fnc_fsDataFromPlain.

In order; any failure returns [false, createHashMap, [problem], []] and nothing
else is touched:
    1. trim; empty text: S_PASTE_EMPTY.
    2. first 8 characters are not ALIVEFS| : S_PASTE_NOT.
    3. the next two bars; schema and length must be 1 to 8 digits: else S_PASTE_NOT.
    4. schema above FS_SCHEMA: S_PASTE_NEWER.
    5. payload length differs from the header: S_PASTE_CUT with both numbers.
       Length above FS_SIZE_MAX: S_PASTE_BAD.
    6. payload does not start with [ and end with ]: S_PASTE_BAD.
    7. parseSimpleArray; nil, not an array, empty, or holding a nil anywhere: S_PASTE_BAD.
    8. ALiVE_fnc_fsDataMigrate, then ALiVE_fnc_fsDataFromPlain.

Parameters:
    _text - STRING - the share text

Returns:
    ARRAY - [ok, faction, problems, notes]
        problems - ARRAY of [key, args...]: S_PASTE_EMPTY, S_PASTE_NOT,
                   S_PASTE_NEWER (schema), S_PASTE_CUT (have, expected),
                   S_PASTE_BAD (detail); numbers are text written with toFixed 0

Examples:
    (begin example)
    ([copyFromClipboard] call ALiVE_fnc_fsDataParse) params ["_ok", "_faction", "_problems", "_notes"];
    (end)

See Also:
    ALiVE_fnc_fsDataToText, ALiVE_fnc_fsDataFromPlain, ALiVE_fnc_presetParse

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_text", "", [""]]];

private _no = { [false, createHashMap, [_this], []] };

_text = trim _text;
if (_text isEqualTo "") exitWith { ["S_PASTE_EMPTY"] call _no };
if !((_text select [0, 8]) isEqualTo "ALIVEFS|") exitWith { ["S_PASTE_NOT"] call _no };

private _rest = _text select [8];
private _bar1 = _rest find "|";
if (_bar1 < 0) exitWith { ["S_PASTE_NOT"] call _no };
private _schemaText = _rest select [0, _bar1];
_rest = _rest select [_bar1 + 1];
private _bar2 = _rest find "|";
if (_bar2 < 0) exitWith { ["S_PASTE_NOT"] call _no };
private _lengthText = _rest select [0, _bar2];
private _payload = _rest select [_bar2 + 1];

if (!(_schemaText regexMatch "^[0-9]{1,8}$") || {!(_lengthText regexMatch "^[0-9]{1,8}$")}) exitWith { ["S_PASTE_NOT"] call _no };

private _schema = parseNumber _schemaText;
private _length = parseNumber _lengthText;

if (_schema > FS_SCHEMA) exitWith { ["S_PASTE_NEWER", _schema toFixed 0] call _no };
if ((count _payload) != _length) exitWith { ["S_PASTE_CUT", (count _payload) toFixed 0, _length toFixed 0] call _no };
if (_length > FS_SIZE_MAX) exitWith { ["S_PASTE_BAD", "too long"] call _no };

// Asked before parseSimpleArray, which logs an engine error on text that is not an array.
if (!((_payload select [0, 1]) isEqualTo "[") || {!((_payload select [(count _payload) - 1]) isEqualTo "]")}) exitWith {
    ["S_PASTE_BAD", "not a list"] call _no
};

private _plain = parseSimpleArray _payload;
if (isNil "_plain" || {!(_plain isEqualType [])} || {_plain isEqualTo []}) exitWith { ["S_PASTE_BAD", "not a list"] call _no };

// No element anywhere may be nil: every later check assumes a value is there.
private _hasNil = {
    params ["_a"];
    (_a findIf { (isNil "_x") || {_x isEqualType [] && {[_x] call _hasNil}} }) >= 0
};
if ([_plain] call _hasNil) exitWith { ["S_PASTE_BAD", "an empty value"] call _no };

// parseSimpleArray stops at the first thing it cannot read, logs an error and still hands back what it
// read so far. The payload is always written by str, so a whole, untouched one reads back to the same text.
if !((str _plain) isEqualTo _payload) exitWith { ["S_PASTE_BAD", "not a whole list"] call _no };

private _migrated = [_plain, _schema] call ALiVE_fnc_fsDataMigrate;
_migrated params ["_migratedOk", "_migratedPlain", "_migrateNotes"];
if (!_migratedOk) exitWith { [false, createHashMap, _migrateNotes, []] };

private _result = [_migratedPlain] call ALiVE_fnc_fsDataFromPlain;
if (_result select 0) then {
    (_result select 3) append _migrateNotes;
};
_result
