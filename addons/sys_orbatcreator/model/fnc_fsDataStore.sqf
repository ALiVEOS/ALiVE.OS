#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsDataStore);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsDataStore

Description:
Profile storage of studio factions. Needs no UI, so it runs the same on a
dedicated server. Variable names are fixed strings because allVariables
profileNamespace is empty on a dedicated server.

Profile variables:
    ALiVE_FS_current    - plain form of the working faction, or []
    ALiVE_FS_library    - [name, [y,m,d,h,mi], units, vehicles, groups, sizeChars, shareText],
                          newest first, at most FS_MAX_LIBRARY
    ALiVE_FS_backup     - the working copy as it was before the last replace
    ALiVE_FS_quarantine - the raw ALiVE_FS_current the last time a load refused it
    ALiVE_FS_prefs      - [key, value] pairs
Model state in missionNamespace: ALiVE_FS_faction (the working faction),
ALiVE_FS_loadState ("none", "ok", "refused"), ALiVE_FS_dirty, ALiVE_FS_lastSave.

A working copy that will not load is never written over: while the load state is
"refused", saveCurrent and backup write nothing, until an operation replaces the
working faction (replace, libraryLoad, restoreBackup).

Operations that change only the library save the profile themselves, since a
refused working copy stops ALiVE_fnc_fsDataTouch from saving. The others leave
the write to the forced ALiVE_fnc_fsDataTouch that follows them.

Parameters:
    _op   - STRING - the operation
    _args - ARRAY - its arguments

Operations:
    "loadCurrent"   - []: reads ALiVE_FS_current. Returns [state, faction, problems, notes],
                      state "none", "ok" or "refused". The caller sets ALiVE_FS_faction.
    "saveCurrent"   - []: writes ALiVE_FS_faction. Returns [ok, sizeChars, level],
                      level 0 fine, 1 at or above FS_SIZE_WARN (S_SAVE_BIG).
    "backup"        - []: working copy to the backup. Returns BOOL.
    "restoreBackup" - []: swaps the working copy and the backup. Returns BOOL.
    "replace"       - [faction]: backup, then the faction becomes the working copy and
                      the load state is "ok". Returns BOOL.
    "libraryList"   - []: list of [name, date, units, vehicles, groups, sizeChars].
    "librarySave"   - [name]: same name replaces. Returns [ok, statusKey, args]; keys
                      S_LIB_SAVED, S_SAVE_REFUSED, S_LIB_FULL, S_LIB_TOO_BIG, S_TEXT_BAD.
                      KB figures are text written with toFixed 0.
    "libraryLoad"   - [name]: as ALiVE_fnc_fsDataParse; on success backs up and replaces.
    "libraryDelete" - [name]: Returns BOOL.
    "prefGet"       - [key, default]: Returns the value.
    "prefSet"       - [key, value]: Returns BOOL.

Returns:
    per operation, see above

Examples:
    (begin example)
    (["loadCurrent"] call ALiVE_fnc_fsDataStore) params ["_state", "_faction", "_problems", "_notes"];
    ["librarySave", ["Altis Militia"]] call ALiVE_fnc_fsDataStore;
    (end)

See Also:
    ALiVE_fnc_fsDataTouch, ALiVE_fnc_fsDataParse, ALiVE_fnc_fsDataToText

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_op", "", [""]], ["_args", [], [[]]]];

private _state = missionNamespace getVariable ["ALiVE_FS_loadState", "none"];

// The working faction, or nil.
private _working = {
    private _f = missionNamespace getVariable "ALiVE_FS_faction";
    if (!isNil "_f" && {_f isEqualType createHashMap}) then { _f } else { nil }
};

// A stored plain form to [ok, faction, problems, notes], through the migration hook.
private _readPlain = {
    params ["_raw"];
    if (!(_raw isEqualType []) || {_raw isEqualTo []}) exitWith { [false, createHashMap, [["S_PASTE_BAD", "not a list"]], []] };
    private _from = 1;
    private _at = _raw findIf { _x isEqualType [] && {(count _x) == 2} && {(_x select 0) isEqualTo "schema"} };
    if (_at >= 0) then { _from = (_raw select _at) select 1 };
    private _m = [_raw, _from] call ALiVE_fnc_fsDataMigrate;
    if !(_m select 0) exitWith { [false, createHashMap, _m select 2, []] };
    private _r = [_m select 1] call ALiVE_fnc_fsDataFromPlain;
    if (_r select 0) then { (_r select 3) append (_m select 2) };
    _r
};

private _library = {
    private _lib = profileNamespace getVariable [FS_VAR_LIBRARY, []];
    if (_lib isEqualType []) then {
        _lib select { _x isEqualType [] && {(count _x) == 7} && {(_x select 0) isEqualType ""} && {(_x select 5) isEqualType 0} }
    } else { [] }
};

private _kb = { ((_this / 1000) max 0) toFixed 0 };

switch (_op) do {

    case "loadCurrent": {
        private _raw = profileNamespace getVariable FS_VAR_CURRENT;
        if (isNil "_raw" || {_raw isEqualTo []}) then {
            missionNamespace setVariable ["ALiVE_FS_loadState", "none"];
            ["none", createHashMap, [], []]
        } else {
            private _r = [_raw] call _readPlain;
            if (_r select 0) then {
                missionNamespace setVariable ["ALiVE_FS_loadState", "ok"];
                ["ok", _r select 1, [], _r select 3]
            } else {
                profileNamespace setVariable [FS_VAR_QUARANTINE, if (_raw isEqualType []) then { +_raw } else { _raw }];
                saveProfileNamespace;
                missionNamespace setVariable ["ALiVE_FS_loadState", "refused"];
                ["refused", createHashMap, _r select 2, []]
            };
        };
    };

    case "saveCurrent": {
        private _f = call _working;
        if (_state isEqualTo "refused" || {isNil "_f"}) then {
            [false, 0, 0]
        } else {
            private _plain = [_f] call ALiVE_fnc_fsDataToPlain;
            private _size = count (str _plain);
            profileNamespace setVariable [FS_VAR_CURRENT, _plain];
            saveProfileNamespace;
            missionNamespace setVariable ["ALiVE_FS_dirty", false];
            missionNamespace setVariable ["ALiVE_FS_lastSave", diag_tickTime];
            [true, _size, [0, 1] select (_size >= FS_SIZE_WARN)]
        };
    };

    case "backup": {
        if (_state isEqualTo "refused") then {
            false
        } else {
            private _f = call _working;
            private _plain = if (isNil "_f") then { profileNamespace getVariable [FS_VAR_CURRENT, []] } else { [_f] call ALiVE_fnc_fsDataToPlain };
            profileNamespace setVariable [FS_VAR_BACKUP, if (_plain isEqualType []) then { +_plain } else { [] }];
            true
        };
    };

    case "restoreBackup": {
        private _raw = profileNamespace getVariable [FS_VAR_BACKUP, []];
        private _r = [_raw] call _readPlain;
        if !(_r select 0) then {
            false
        } else {
            private _f = call _working;
            private _cur = if (isNil "_f") then { [] } else { [_f] call ALiVE_fnc_fsDataToPlain };
            profileNamespace setVariable [FS_VAR_BACKUP, _cur];
            missionNamespace setVariable ["ALiVE_FS_faction", _r select 1];
            missionNamespace setVariable ["ALiVE_FS_loadState", "ok"];
            true
        };
    };

    case "replace": {
        _args params [["_new", createHashMap, [createHashMap]]];
        ["backup"] call ALiVE_fnc_fsDataStore;
        missionNamespace setVariable ["ALiVE_FS_faction", _new];
        missionNamespace setVariable ["ALiVE_FS_loadState", "ok"];
        true
    };

    case "libraryList": {
        (call _library) apply { _x select [0, 6] }
    };

    case "librarySave": {
        _args params [["_name", "", [""]]];
        private _f = call _working;
        switch (true) do {
            case (isNil "_f"): { [false, "S_PASTE_EMPTY", []] };
            case (_name isEqualTo "" || {!(([_name, "text60"] call ALiVE_fnc_fsDataCheckValue) isEqualTo "")}): { [false, "S_TEXT_BAD", [_name]] };
            default {
                private _plain = [_f] call ALiVE_fnc_fsDataToPlain;
                private _size = count (str _plain);
                private _lib = (call _library) select { !((_x select 0) == _name) };
                private _replacing = (count _lib) < (count (call _library));
                private _total = _size;
                { _total = _total + (_x select 5) } forEach _lib;
                switch (true) do {
                    case (_size >= FS_SIZE_MAX): { [false, "S_SAVE_REFUSED", [_size call _kb, FS_SIZE_MAX call _kb]] };
                    case (!_replacing && {(count _lib) >= FS_MAX_LIBRARY}): { [false, "S_LIB_FULL", [(count _lib) toFixed 0]] };
                    case (_total >= FS_LIBRARY_MAX): { [false, "S_LIB_TOO_BIG", [_total call _kb, FS_LIBRARY_MAX call _kb]] };
                    default {
                        private _entry = [
                            _name,
                            systemTime select [0, 5],
                            count (_f getOrDefault ["units", createHashMap]),
                            count (_f getOrDefault ["vehicles", createHashMap]),
                            count (_f getOrDefault ["groups", createHashMap]),
                            _size,
                            [_plain] call ALiVE_fnc_fsDataToText
                        ];
                        profileNamespace setVariable [FS_VAR_LIBRARY, [_entry] + _lib];
                        saveProfileNamespace;
                        [true, "S_LIB_SAVED", [_name]]
                    };
                }
            };
        }
    };

    case "libraryLoad": {
        _args params [["_name", "", [""]]];
        private _lib = call _library;
        private _at = _lib findIf { (_x select 0) == _name };
        if (_at < 0) then {
            [false, createHashMap, [["S_PASTE_BAD", "not in the saved factions"]], []]
        } else {
            private _text = (_lib select _at) select 6;
            private _r = if (_text isEqualType "") then { [_text] call ALiVE_fnc_fsDataParse } else { [false, createHashMap, [["S_PASTE_BAD", "not text"]], []] };
            if (_r select 0) then { ["replace", [_r select 1]] call ALiVE_fnc_fsDataStore };
            _r
        };
    };

    case "libraryDelete": {
        _args params [["_name", "", [""]]];
        private _all = call _library;
        private _lib = _all select { !((_x select 0) == _name) };
        if ((count _lib) == (count _all)) then {
            false
        } else {
            profileNamespace setVariable [FS_VAR_LIBRARY, _lib];
            saveProfileNamespace;
            true
        };
    };

    case "prefGet": {
        _args params [["_key", "", [""]], "_default"];
        private _prefs = profileNamespace getVariable [FS_VAR_PREFS, []];
        private _at = if (_prefs isEqualType []) then { _prefs findIf { _x isEqualType [] && {(count _x) == 2} && {(_x select 0) isEqualTo _key} } } else { -1 };
        if (_at < 0) then { _default } else { (_prefs select _at) select 1 }
    };

    case "prefSet": {
        _args params [["_key", "", [""]], "_value"];
        if (isNil "_value") then {
            false
        } else {
            private _prefs = profileNamespace getVariable [FS_VAR_PREFS, []];
            if !(_prefs isEqualType []) then { _prefs = [] };
            _prefs = _prefs select { _x isEqualType [] && {(count _x) == 2} && {!((_x select 0) isEqualTo _key)} };
            _prefs pushBack [_key, _value];
            profileNamespace setVariable [FS_VAR_PREFS, _prefs];
            true
        };
    };

    default {
        diag_log format ["ALiVE_fnc_fsDataStore - unknown operation: %1", _op];
        nil
    };
}
