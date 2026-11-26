#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsStudioTabFaction);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsStudioTabFaction

Description:
The Faction tab: the faction's own fields, the saved factions, share text,
import and files.

    - "refresh": fills every field, the side and flag combos, the counts and the
      saved-factions list;
    - "name", "tag", "class", "side", "flag", "flagPath", "author", "modName":
      the fields, each checked with the schema's rule; a refused value is put
      back and the status says why. A new tag also renames whatever followed
      the old one: the faction class, the mod folder and every automatic class
      name of the units, vehicles and groups. "tag" also takes the tag as a
      STRING argument (the faction picker and "askTag" use that);
    - "askTag": asks for a tag (Q_TAG);
    - "libSave": asks for a name (Q_SAVE, the faction's name filled in);
    - "libLoad", "libDelete": the picked saved faction, after a question;
    - "new": a new empty faction with the same tag and side, after Q_REPLACE;
    - "restore": swaps the working faction and the one the last replace kept;
    - "import": the faction picker;
    - "copy": the share text to the clipboard, and shown in the text popup;
    - "paste": the share text typed or pasted into the question popup (in single
      player it is filled from the clipboard);
    - "file": <name>.alivefaction.txt from Documents\Arma 3\ALiVE\orbat\import.
Everything that replaces the working faction asks first, keeps a backup
(Restore brings it back) and saves at once.

Parameters:
    _op   - STRING - as above
    _args - ARRAY - the event arguments, or the tag for "tag"

Returns:
    Nothing

Examples:
    (begin example)
    ["refresh", []] call ALiVE_fnc_fsStudioTabFaction;
    (end)

See Also:
    ALiVE_fnc_fsDataStore, ALiVE_fnc_fsStudioPrompt, ALiVE_fnc_fsStudioFactionPicker

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"
#include "\x\alive\addons\sys_orbatcreator\data\ui\studio\idc.hpp"

disableSerialization;

params [["_op", "", [""]], ["_args", []]];

private _session = missionNamespace getVariable "ALiVE_FS_session";
if (isNil "_session") exitWith {};
private _display = _session getOrDefault ["display", displayNull];
if (isNull _display) exitWith {};

private _faction = missionNamespace getVariable ["ALiVE_FS_faction", createHashMap];
private _ctrl = { _display displayCtrl _this };

// the rule each field is checked with (the faction rows of fsDataSchema)
private _rules = createHashMapFromArray [
    ["name", "text60"], ["tag", "tag?"], ["class", "class?"], ["flag", "path"],
    ["author", "text60"], ["modName", "modName?"]
];
private _fields = [
    ["name", FS_IDC_F_NAME], ["tag", FS_IDC_F_TAG], ["class", FS_IDC_F_CLASS],
    ["author", FS_IDC_F_AUTHOR], ["modName", FS_IDC_F_MODNAME]
];

// after the working faction was replaced: nothing selected, saved at once, redrawn
private _replaced = {
    params ["_reason"];
    // also called a frame later from a prompt callback, where the caller's _session is not in scope
    private _session = missionNamespace getVariable ["ALiVE_FS_session", createHashMap];
    _session set ["selUnit", ""];
    _session set ["selVehicle", ""];
    _session set ["bodyRef", ""];
    ["clear"] call ALiVE_fnc_fsStudioPreview;
    [_reason, true] call ALiVE_fnc_fsDataTouch;
    ["refresh", []] call ALiVE_fnc_fsStudioTabFaction;
};

// the first problem of a parse, on the status line
private _problem = {
    params ["_problems"];
    private _p = _problems param [0, ["S_PASTE_BAD", ""]];
    if !(_p isEqualType []) then { _p = ["S_PASTE_BAD", str _p] };
    [1, _p select 0, (_p select [1]) apply { if (_x isEqualType "") then { _x } else { str _x } }] call ALiVE_fnc_fsStudioStatus;
};

// one field: checked, stored, the faction marked changed
private _set = {
    params ["_key", "_value"];
    private _why = [_value, _rules getOrDefault [_key, "text60"]] call ALiVE_fnc_fsDataCheckValue;
    if !(_why isEqualTo "") exitWith {
        ["refresh", []] call ALiVE_fnc_fsStudioTabFaction;
        [1, _why, [_value]] call ALiVE_fnc_fsStudioStatus;
        false
    };
    if ((_faction getOrDefault [_key, ""]) isEqualTo _value) exitWith { true };
    _faction set [_key, _value];
    ["faction " + _key, false] call ALiVE_fnc_fsDataTouch;
    true
};

switch (_op) do {
    case "refresh": {
        { _x params ["_key", "_idc"]; (_idc call _ctrl) ctrlSetText (_faction getOrDefault [_key, ""]) } forEach _fields;

        private _cs = FS_IDC_F_SIDE call _ctrl;
        _session set ["factionFilling", true];
        lbClear _cs;
        {
            _x params ["_text", "_value"];
            private _i = _cs lbAdd _text;
            _cs lbSetValue [_i, _value];
            if (_value == (_faction getOrDefault ["side", 1])) then { _cs lbSetCurSel _i };
        } forEach [[localize "STR_WEST", 1], [localize "STR_EAST", 0], [localize "STR_GUERRILA", 2], [localize "STR_CIVILIAN", 3]];

        // every flag a config faction uses, once, then "Flag file" for a path of the faction's own
        private _cf = FS_IDC_F_FLAG call _ctrl;
        lbClear _cf;
        private _flag = _faction getOrDefault ["flag", ""];
        private _seen = [];
        private _pick = -1;
        {
            private _path = getText (_x >> "flag");
            if (!(_path isEqualTo "") && {!((toLower _path) in _seen)}) then {
                _seen pushBack toLower _path;
                private _i = _cf lbAdd getText (_x >> "displayName");
                _cf lbSetData [_i, _path];
                _cf lbSetPicture [_i, _path];
                if ((toLower _path) == (toLower _flag)) then { _pick = _i };
            };
        } forEach ("true" configClasses (configFile >> "CfgFactionClasses"));
        private _custom = _cf lbAdd (localize "STR_ALIVE_FS_L_FLAG_CUSTOM");
        _cf lbSetData [_custom, "*"];
        if (_pick < 0 && {!(_flag isEqualTo "")}) then { _pick = _custom };
        _cf lbSetCurSel _pick;
        private _fp = FS_IDC_F_FLAGPATH call _ctrl;
        _fp ctrlSetText _flag;
        _fp ctrlEnable (_pick == _custom);
        _session set ["factionFilling", false];

        private _plain = [_faction] call ALiVE_fnc_fsDataToPlain;
        (FS_IDC_F_COUNTS call _ctrl) ctrlSetText format ["%1   %2",
            format [localize "STR_ALIVE_FS_COUNTS", count (_faction getOrDefault ["units", createHashMap]), count (_faction getOrDefault ["vehicles", createHashMap]), count (_faction getOrDefault ["groups", createHashMap])],
            format [localize "STR_ALIVE_FS_SIZE", ((count str _plain) / 1024) toFixed 0]];

        private _lib = FS_IDC_F_LIBLIST call _ctrl;
        private _was = if (lbCurSel _lib < 0) then { "" } else { _lib lbData (lbCurSel _lib) };
        lbClear _lib;
        {
            _x params ["_name", "_date", "_u", "_v", "_g"];
            _date params [["_y", 0], ["_m", 0], ["_d", 0], ["_h", 0], ["_mi", 0]];
            private _i = _lib lbAdd _name;
            _lib lbSetData [_i, _name];
            _lib lbSetTextRight [_i, format ["%1-%2-%3 %4:%5   %6/%7/%8", _y, [_m, 2] call CBA_fnc_formatNumber, [_d, 2] call CBA_fnc_formatNumber, [_h, 2] call CBA_fnc_formatNumber, [_mi, 2] call CBA_fnc_formatNumber, _u, _v, _g]];
            if (_name == _was) then { _lib lbSetCurSel _i };
        } forEach (["libraryList"] call ALiVE_fnc_fsDataStore);
        [-1] call ALiVE_fnc_fsStudioStatus;
    };

    case "name";
    case "class";
    case "author";
    case "modName": {
        private _idc = (_fields select (_fields findIf { (_x select 0) == _op })) select 1;
        [_op, ctrlText (_idc call _ctrl)] call _set;
        [-1] call ALiVE_fnc_fsStudioStatus;
    };

    case "tag": {
        private _tag = toUpper (if (_args isEqualType "") then { _args } else { ctrlText (FS_IDC_F_TAG call _ctrl) });
        private _old = _faction getOrDefault ["tag", ""];
        if (_tag isEqualTo _old) exitWith { (FS_IDC_F_TAG call _ctrl) ctrlSetText _tag };
        if !(["tag", _tag] call _set) exitWith {};
        // whatever followed the old tag follows the new one
        if ((_faction getOrDefault ["class", ""]) in ["", _old]) then { _faction set ["class", _tag] };
        if ((_faction getOrDefault ["modName", ""]) in ["", "ALiVE_" + _old]) then { _faction set ["modName", "ALiVE_" + _tag] };
        {
            _x params ["_dictKey", "_fn"];
            {
                if (_y getOrDefault ["classAuto", false]) then { ["set", [_x, "classAuto", true]] call _fn };
            } forEach (_faction getOrDefault [_dictKey, createHashMap]);
        } forEach [["units", ALiVE_fnc_fsDataUnit], ["vehicles", ALiVE_fnc_fsDataVehicle], ["groups", ALiVE_fnc_fsDataGroup]];
        // the author's own crates (New crate) follow the tag too
        {
            private _cls = _x getOrDefault ["class", ""];
            private _head = _old + "_Crate_C";
            if ((_x getOrDefault ["key", ""]) isEqualTo "custom" && {(toLower (_cls select [0, count _head])) isEqualTo (toLower _head)}) then {
                _x set ["class", _tag + "_Crate_C" + (_cls select [count _head])];
            };
        } forEach ((_faction getOrDefault ["alive", createHashMap]) getOrDefault ["crates", []]);
        ["refresh", []] call ALiVE_fnc_fsStudioTabFaction;
    };

    case "askTag": {
        ["open", [localize "STR_ALIVE_FS_Q_TAG", _faction getOrDefault ["tag", ""], {
            params ["_ok", "_text"];
            if (_ok) then { ["tag", _text] call ALiVE_fnc_fsStudioTabFaction };
        }]] call ALiVE_fnc_fsStudioPrompt;
    };

    case "side": {
        _args params [["_c", controlNull], ["_index", -1]];
        if (_index < 0 || {_session getOrDefault ["factionFilling", false]}) exitWith {};
        private _side = _c lbValue _index;
        if ((_faction getOrDefault ["side", 1]) == _side) exitWith {};
        _faction set ["side", _side];
        ["faction side", false] call ALiVE_fnc_fsDataTouch;
        [-1] call ALiVE_fnc_fsStudioStatus;
    };

    case "flag": {
        _args params [["_c", controlNull], ["_index", -1]];
        if (_index < 0 || {_session getOrDefault ["factionFilling", false]}) exitWith {};
        private _path = _c lbData _index;
        private _fp = FS_IDC_F_FLAGPATH call _ctrl;
        _fp ctrlEnable (_path == "*");
        if (_path == "*") exitWith { ctrlSetFocus _fp };
        ["flag", _path] call _set;
        _fp ctrlSetText _path;
        [-1] call ALiVE_fnc_fsStudioStatus;
    };

    case "flagPath": {
        ["flag", ctrlText (FS_IDC_F_FLAGPATH call _ctrl)] call _set;
        [-1] call ALiVE_fnc_fsStudioStatus;
    };

    case "libSave": {
        ["open", [localize "STR_ALIVE_FS_Q_SAVE", _faction getOrDefault ["name", ""], {
            params ["_ok", "_text"];
            if (!_ok) exitWith {};
            (["librarySave", [_text]] call ALiVE_fnc_fsDataStore) params ["_done", "_key", "_keyArgs"];
            if (_done) then { ["library save", true] call ALiVE_fnc_fsDataTouch };
            ["refresh", []] call ALiVE_fnc_fsStudioTabFaction;
            [[1, 0] select _done, _key, _keyArgs] call ALiVE_fnc_fsStudioStatus;
        }]] call ALiVE_fnc_fsStudioPrompt;
    };

    case "libLoad": {
        private _lib = FS_IDC_F_LIBLIST call _ctrl;
        if (lbCurSel _lib < 0) exitWith {};
        ["open", [localize "STR_ALIVE_FS_Q_REPLACE", nil, {
            params ["_ok", "", "_cbArgs"];
            _cbArgs params ["_name", "_replaced", "_problem"];
            if (!_ok) exitWith {};
            (["libraryLoad", [_name]] call ALiVE_fnc_fsDataStore) params ["_done", "", "_problems"];
            if (!_done) exitWith { [_problems] call _problem };
            ["library load"] call _replaced;
            [0, "S_LIB_LOADED", [_name]] call ALiVE_fnc_fsStudioStatus;
        }, [_lib lbData (lbCurSel _lib), _replaced, _problem]]] call ALiVE_fnc_fsStudioPrompt;
    };

    case "libDelete": {
        private _lib = FS_IDC_F_LIBLIST call _ctrl;
        if (lbCurSel _lib < 0) exitWith {};
        private _name = _lib lbData (lbCurSel _lib);
        ["open", [format [localize "STR_ALIVE_FS_Q_DELETE", _name], nil, {
            params ["_ok", "", "_cbArgs"];
            _cbArgs params ["_name"];
            if (!_ok) exitWith {};
            if (["libraryDelete", [_name]] call ALiVE_fnc_fsDataStore) then {
                ["library delete", true] call ALiVE_fnc_fsDataTouch;
                ["refresh", []] call ALiVE_fnc_fsStudioTabFaction;
                [0, "S_LIB_DELETED", [_name]] call ALiVE_fnc_fsStudioStatus;
            };
        }, [_name]]] call ALiVE_fnc_fsStudioPrompt;
    };

    case "new": {
        ["open", [localize "STR_ALIVE_FS_Q_REPLACE", nil, {
            params ["_ok", "", "_cbArgs"];
            _cbArgs params ["_replaced"];
            if (!_ok) exitWith {};
            private _old = missionNamespace getVariable ["ALiVE_FS_faction", createHashMap];
            ["replace", [["", _old getOrDefault ["tag", ""], _old getOrDefault ["side", 1]] call ALiVE_fnc_fsDataNew]] call ALiVE_fnc_fsDataStore;
            ["new faction"] call _replaced;
            [0, "S_READY_NEW", [FS_NAME]] call ALiVE_fnc_fsStudioStatus;
        }, [_replaced]]] call ALiVE_fnc_fsStudioPrompt;
    };

    case "restore": {
        if !(["restoreBackup"] call ALiVE_fnc_fsDataStore) exitWith { [1, "S_RESTORE_NONE", []] call ALiVE_fnc_fsStudioStatus };
        ["restore"] call _replaced;
        [0, "S_RESTORED", []] call ALiVE_fnc_fsStudioStatus;
    };

    case "import": {
        ["open", []] call ALiVE_fnc_fsStudioFactionPicker;
    };

    case "copy": {
        private _text = [_faction] call ALiVE_fnc_fsDataToText;
        copyToClipboard _text;
        ["open", [localize "STR_ALIVE_FS_SHARE_COPY", _text]] call ALiVE_fnc_fsStudioTextBox;
        [0, "S_SHARE_COPIED", [(count _text) toFixed 0]] call ALiVE_fnc_fsStudioStatus;
    };

    case "paste": {
        // the clipboard can only be read in single player; in multiplayer the text is pasted into the line
        private _clip = if (isMultiplayer) then { "" } else { copyFromClipboard };
        ["open", [localize "STR_ALIVE_FS_Q_PASTE", _clip, {
            params ["_ok", "_text", "_cbArgs"];
            _cbArgs params ["_replaced", "_problem"];
            if (!_ok) exitWith {};
            ([_text] call ALiVE_fnc_fsDataParse) params ["_done", "_new", "_problems"];
            if (!_done) exitWith { [_problems] call _problem };
            // pasted text can come from anyone, so no Init Code is taken from it
            private _dropped = 0;
            {
                { if !((_y getOrDefault ["initCode", ""]) isEqualTo "") then { _y set ["initCode", ""]; _dropped = _dropped + 1 } } forEach (_new getOrDefault [_x, createHashMap]);
            } forEach ["units", "vehicles"];
            ["replace", [_new]] call ALiVE_fnc_fsDataStore;
            ["paste"] call _replaced;
            private _missing = 0;
            {
                { if !(isClass (configFile >> "CfgVehicles" >> (_y getOrDefault ["base", ""]))) then { _missing = _missing + 1 } } forEach (_new getOrDefault [_x, createHashMap]);
            } forEach ["units", "vehicles"];
            [0, ["S_PASTE_OK", "S_PASTE_OK_NOCODE"] select (_dropped > 0), [_new getOrDefault ["name", ""], _missing]] call ALiVE_fnc_fsStudioStatus;
        }, [_replaced, _problem]]] call ALiVE_fnc_fsStudioPrompt;
    };

    case "file": {
        private _name = ctrlText (FS_IDC_F_FILENAME call _ctrl);
        ["open", [localize "STR_ALIVE_FS_Q_REPLACE", nil, {
            params ["_ok", "", "_cbArgs"];
            _cbArgs params ["_name", "_replaced", "_problem"];
            if (!_ok) exitWith {};
            ([_name] call ALiVE_fnc_fsDataFileRead) params ["_done", "_new", "_problems"];
            if (!_done) exitWith { [_problems] call _problem };
            ["replace", [_new]] call ALiVE_fnc_fsDataStore;
            ["file load"] call _replaced;
            [0, "S_LIB_LOADED", [_name]] call ALiVE_fnc_fsStudioStatus;
        }, [_name, _replaced, _problem]]] call ALiVE_fnc_fsStudioPrompt;
    };

    default {};
};
