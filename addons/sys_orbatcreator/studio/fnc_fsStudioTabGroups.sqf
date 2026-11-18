#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsStudioTabGroups);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsStudioTabGroups

Description:
The Groups tab: groups by ALiVE category, the selected group's fields and its
members.

    - "refresh": the category combo (the eleven ALiVE categories with their group
      counts, then any other category the faction has), the groups of the chosen
      category, the selected group's fields and members, and the note
      (CAT_EMPTY, or CAT_NOT_DRAWN for a category ALiVE's placement never draws);
    - "category", "select": the category and the group;
    - "new", "duplicate", "delete": groups, through ALiVE_fnc_fsDataGroup;
    - "name", "class", "classAuto", "rarity", "icon": the fields;
    - "memberSelect": the member stands on the stage;
    - "memberAdd": the unit or vehicle picked in the combo joins the group;
    - "memberRemove", "memberUp", "memberDown", "rank": the selected member.

Parameters:
    _op   - STRING - the event
    _args - ARRAY - the event arguments

Returns:
    Nothing

Examples:
    (begin example)
    ["refresh", []] call ALiVE_fnc_fsStudioTabGroups;
    (end)

See Also:
    ALiVE_fnc_fsDataGroup, ALiVE_fnc_fsStudioTabUnits

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
private _groups = _faction getOrDefault ["groups", createHashMap];
private _units = _faction getOrDefault ["units", createHashMap];
private _vehicles = _faction getOrDefault ["vehicles", createHashMap];
private _ranks = ["PRIVATE", "CORPORAL", "SERGEANT", "LIEUTENANT", "CAPTAIN", "MAJOR", "COLONEL"];
private _ctrl = { _display displayCtrl _this };

// a member's name: the unit or vehicle's name, or the class after #
private _refName = {
    params ["_ref"];
    switch (true) do {
        case (_ref in _units): { (_units get _ref) getOrDefault ["name", _ref] };
        case (_ref in _vehicles): { (_vehicles get _ref) getOrDefault ["name", _ref] };
        case ((_ref select [0, 1]) == "#"): {
            private _c = _ref select [1];
            private _n = getText (configFile >> "CfgVehicles" >> _c >> "displayName");
            if (_n isEqualTo "") then { _c } else { _n }
        };
        default { _ref };
    }
};

// the selected group's fields and members
private _show = {
    params ["_id"];
    private _grp = _groups getOrDefault [_id, createHashMap];
    _session set ["selGroup", _id];
    _session set ["grpFilling", true];
    (FS_IDC_G_NAME call _ctrl) ctrlSetText (_grp getOrDefault ["name", ""]);
    (FS_IDC_G_CLASS call _ctrl) ctrlSetText (_grp getOrDefault ["class", ""]);
    (FS_IDC_G_CLASSAUTO call _ctrl) cbSetChecked (_grp getOrDefault ["classAuto", true]);
    private _slider = FS_IDC_G_RARITY call _ctrl;
    _slider sliderSetRange [0, 1];
    _slider sliderSetSpeed [0.05, 0.1];
    _slider sliderSetPosition (_grp getOrDefault ["rarity", 0.5]);
    (FS_IDC_G_RARITYVALUE call _ctrl) ctrlSetText ((_grp getOrDefault ["rarity", 0.5]) toFixed 2);

    // map icons: none, then the NATO markers in the faction's side colour
    private _icon = FS_IDC_G_ICON call _ctrl;
    lbClear _icon;
    private _i = _icon lbAdd (localize "STR_ALIVE_FS_TEXTURE_DEFAULT");
    _icon lbSetData [_i, ""];
    _icon lbSetCurSel _i;
    private _prefix = ["o", "b", "n", "n"] select (((_faction getOrDefault ["side", 1]) max 0) min 3);
    {
        private _path = format ["\A3\ui_f\data\map\markers\nato\%1_%2.paa", _prefix, _x];
        _i = _icon lbAdd _x;
        _icon lbSetData [_i, _path];
        _icon lbSetPicture [_i, _path];
        if ((toLower _path) == toLower (_grp getOrDefault ["icon", ""])) then { _icon lbSetCurSel _i };
    } forEach ["inf", "motor_inf", "mech_inf", "armor", "art", "air", "plane", "naval", "recon", "support", "maint", "med", "mortar", "uav", "unknown"];

    // members
    private _members = FS_IDC_G_MEMBERS call _ctrl;
    private _was = (lbCurSel _members) max 0;
    lbClear _members;
    {
        private _ref = _x getOrDefault ["ref", ""];
        _i = _members lbAdd ([_ref] call _refName);
        _members lbSetTextRight [_i, _x getOrDefault ["rank", "PRIVATE"]];
        if !((_ref in _units) || {_ref in _vehicles} || {isClass (configFile >> "CfgVehicles" >> (_ref select [1]))}) then { _members lbSetColor [_i, [1, 0.35, 0.3, 1]] };
    } forEach (_grp getOrDefault ["members", []]);
    if (lbSize _members > 0) then { _members lbSetCurSel (_was min ((lbSize _members) - 1)) };
    private _rank = FS_IDC_G_RANK call _ctrl;
    lbClear _rank;
    private _member = (_grp getOrDefault ["members", []]) param [lbCurSel _members, createHashMap];
    {
        _i = _rank lbAdd _x;
        _rank lbSetData [_i, _x];
        if (_x == (_member getOrDefault ["rank", "PRIVATE"])) then { _rank lbSetCurSel _i };
    } forEach _ranks;

    // what can join: the faction's units, then its vehicles
    // rebuilt every time: a rename, or a delete and an add, keeps the count the same
    private _pick = FS_IDC_G_MEMBERPICK call _ctrl;
    private _picked = if (lbCurSel _pick >= 0) then { _pick lbData (lbCurSel _pick) } else { "" };
    if (true) then {
        lbClear _pick;
        {
            _x params ["_dict", "_order"];
            {
                if (_x in _dict) then {
                    _i = _pick lbAdd ((_dict get _x) getOrDefault ["name", _x]);
                    _pick lbSetData [_i, _x];
                };
            } forEach (_faction getOrDefault [_order, []]);
        } forEach [[_units, "unitOrder"], [_vehicles, "vehicleOrder"]];
        private _at = 0;
        for "_j" from 0 to (lbSize _pick) - 1 do { if ((_pick lbData _j) == _picked) then { _at = _j } };
        if (lbSize _pick > 0) then { _pick lbSetCurSel _at };
    };
    { (_x call _ctrl) ctrlEnable !(_id isEqualTo "") } forEach [FS_IDC_G_NAME, FS_IDC_G_CLASS, FS_IDC_G_CLASSAUTO, FS_IDC_G_RARITY, FS_IDC_G_ICON, FS_IDC_G_MEMBERADD, FS_IDC_G_DUPLICATE, FS_IDC_G_DELETE];
    { (_x call _ctrl) ctrlEnable (lbSize _members > 0) } forEach [FS_IDC_G_MEMBERREMOVE, FS_IDC_G_MEMBERUP, FS_IDC_G_MEMBERDOWN, FS_IDC_G_RANK];
    _session set ["grpFilling", false];
    if (lbSize _members > 0) then { ["memberSelect", [_members, lbCurSel _members]] call ALiVE_fnc_fsStudioTabGroups } else { ["clear"] call ALiVE_fnc_fsStudioPreview };
};

private _changed = {
    params ["_reason", ["_status", []]];
    [_reason, false] call ALiVE_fnc_fsDataTouch;
    ["refresh", []] call ALiVE_fnc_fsStudioTabGroups;
    if !(_status isEqualTo []) then { _status call ALiVE_fnc_fsStudioStatus } else { [-1] call ALiVE_fnc_fsStudioStatus };
};

private _set = {
    params ["_key", "_value"];
    private _id = _session getOrDefault ["selGroup", ""];
    if !(_id in _groups) exitWith {};
    private _current = (_groups get _id) get _key;
    if (!isNil "_current" && {_current isEqualTo _value}) exitWith {};
    private _why = ["set", [_id, _key, _value]] call ALiVE_fnc_fsDataGroup;
    if (_why isEqualTo "") then { ["group " + _key] call _changed } else { [_id] call _show; [1, _why] call ALiVE_fnc_fsStudioStatus };
};

// the selected member's index, or -1
private _memberIndex = { lbCurSel (FS_IDC_G_MEMBERS call _ctrl) };

switch (_op) do {
    case "refresh": {
        private _cat = _session getOrDefault ["groupCategory", "Infantry"];
        private _cats = +FS_ALIVE_CATEGORIES;
        { private _c = _y getOrDefault ["category", ""]; if !(_c in _cats) then { _cats pushBack _c } } forEach _groups;
        if !(_cat in _cats) then { _cat = "Infantry" };
        _session set ["groupCategory", _cat];
        _session set ["grpFilling", true];
        private _combo = FS_IDC_G_CATEGORY call _ctrl;
        lbClear _combo;
        {
            private _c = _x;
            private _n = { (_x getOrDefault ["category", ""]) == _c } count (values _groups);
            private _i = _combo lbAdd format ["%1 (%2)", _c, _n];
            _combo lbSetData [_i, _c];
            if !(_c in FS_ALIVE_DRAWN) then { _combo lbSetColor [_i, [0.7, 0.7, 0.7, 1]] };
            if (_c == _cat) then { _combo lbSetCurSel _i };
        } forEach _cats;

        private _list = FS_IDC_G_LIST call _ctrl;
        lbClear _list;
        private _sel = _session getOrDefault ["selGroup", ""];
        private _selIndex = -1;
        {
            if (_x in _groups && {((_groups get _x) getOrDefault ["category", ""]) == _cat}) then {
                private _g = _groups get _x;
                private _i = _list lbAdd (_g getOrDefault ["name", _x]);
                _list lbSetData [_i, _x];
                private _n = str count (_g getOrDefault ["members", []]);
                _list lbSetTextRight [_i, if ((_g getOrDefault ["auto", ""]) isEqualTo "") then { _n } else { format ["%1  %2", localize "STR_ALIVE_FS_G_AUTO_MARK", _n] }];
                if (_x == _sel) then { _selIndex = _i };
            };
        } forEach (_faction getOrDefault ["groupOrder", []]);
        if (_selIndex < 0 && {lbSize _list > 0}) then { _selIndex = 0 };
        if (_selIndex >= 0) then { _list lbSetCurSel _selIndex };
        _session set ["grpFilling", false];

        private _note = FS_IDC_G_NOTE call _ctrl;
        // an empty drawn category: what ALiVE does without it, and whether AUTO GROUPS can fill it
        private _state = ([_faction] call ALiVE_fnc_fsAliveCheck) select { (_x select 0) == _cat };
        _state = _state param [0, [_cat, "ok", 0, ""]];
        _note ctrlSetStructuredText parseText (switch (true) do {
            case !(_cat in FS_ALIVE_DRAWN): { format ["<t color='#E6B422'>%1</t>", format [localize "STR_ALIVE_FS_CAT_NOT_DRAWN", _cat]] };
            case ((_state select 1) == "fillable"): { format ["<t color='#E6B422'>%1 %2</t>", localize ("STR_ALIVE_FS_EC_" + toUpper _cat), localize "STR_ALIVE_FS_EC_FILLABLE"] };
            case ((_state select 1) == "redirect"): { format [localize "STR_ALIVE_FS_EC_REDIRECT", _state select 3] };
            case (lbSize _list == 0): { format ["%1", format [localize "STR_ALIVE_FS_CAT_EMPTY", _cat]] };
            default { "" };
        });
        (FS_IDC_G_AUTOREBUILD call _ctrl) ctrlEnable (((values _groups) findIf { !((_x getOrDefault ["auto", ""]) isEqualTo "") }) >= 0);
        [if (_selIndex >= 0) then { _list lbData _selIndex } else { "" }] call _show;
    };
    case "category": {
        _args params [["_c", controlNull], ["_index", -1]];
        if (_index < 0 || {_session getOrDefault ["grpFilling", false]}) exitWith {};
        _session set ["groupCategory", _c lbData _index];
        _session set ["selGroup", ""];
        ["refresh", []] call ALiVE_fnc_fsStudioTabGroups;
    };
    case "select": {
        _args params [["_c", controlNull], ["_index", -1]];
        if (_index < 0 || {_session getOrDefault ["grpFilling", false]}) exitWith {};
        [_c lbData _index] call _show;
    };
    case "new": {
        private _cat = _session getOrDefault ["groupCategory", "Infantry"];
        private _n = 1 + ({ (_x getOrDefault ["category", ""]) == _cat } count (values _groups));
        private _id = ["add", [createHashMapFromArray [["name", format ["%1 %2", _cat, _n]], ["category", _cat]]]] call ALiVE_fnc_fsDataGroup;
        if (_id isEqualTo "") exitWith {};
        _session set ["selGroup", _id];
        ["group new", [0, "S_UNIT_ADDED", [1]]] call _changed;
    };
    case "duplicate": {
        private _id = _session getOrDefault ["selGroup", ""];
        if !(_id in _groups) exitWith {};
        private _new = ["duplicate", [_id]] call ALiVE_fnc_fsDataGroup;
        if (_new isEqualTo "") exitWith {};
        _session set ["selGroup", _new];
        ["group duplicate", [0, "S_DUPLICATED", [(_groups get _new) getOrDefault ["class", _new]]]] call _changed;
    };
    case "auto": {
        ([_faction, "add"] call ALiVE_fnc_fsAutoGroups) params ["_added", "_kept", "", "_notes"];
        private _status = switch (true) do {
            case ((_faction getOrDefault ["side", 1]) == 3): { [1, "S_AUTO_CIV", []] };
            case (count _notes > 0): { [1, "S_AUTO_CAP", [FS_MAX_AUTO_GROUPS]] };
            default { [0, "S_AUTO_DONE", [_added, _kept]] };
        };
        ["group auto", _status] call _changed;
    };
    case "rebuild": {
        private _n = { !((_x getOrDefault ["auto", ""]) isEqualTo "") } count (values _groups);
        if (_n == 0) exitWith {};
        ["open", [format [localize "STR_ALIVE_FS_G_REBUILD_ASK", _n], nil, {
            params ["_ok"];
            if (!_ok) exitWith {};
            private _f = missionNamespace getVariable ["ALiVE_FS_faction", createHashMap];
            ([_f, "rebuild"] call ALiVE_fnc_fsAutoGroups) params ["_added", "", "_removed"];
            (missionNamespace getVariable "ALiVE_FS_session") set ["selGroup", ""];
            ["group rebuild", false] call ALiVE_fnc_fsDataTouch;
            ["refresh", []] call ALiVE_fnc_fsStudioTabGroups;
            [0, "S_AUTO_REBUILT", [_removed, _added]] call ALiVE_fnc_fsStudioStatus;
        }]] call ALiVE_fnc_fsStudioPrompt;
    };
    case "delete": {
        private _id = _session getOrDefault ["selGroup", ""];
        if !(_id in _groups) exitWith {};
        private _name = (_groups get _id) getOrDefault ["name", _id];
        if (["delete", [_id]] call ALiVE_fnc_fsDataGroup) then {
            _session set ["selGroup", ""];
            ["group delete", [0, "S_UNIT_DELETED", [_name, 0, 0]]] call _changed;
        };
    };
    case "name": { ["name", ctrlText (FS_IDC_G_NAME call _ctrl)] call _set };
    case "class": { ["class", ctrlText (FS_IDC_G_CLASS call _ctrl)] call _set };
    case "classAuto": { ["classAuto", cbChecked (FS_IDC_G_CLASSAUTO call _ctrl)] call _set };
    case "rarity": {
        _args params [["_c", controlNull], ["_pos", 0.5]];
        if (_session getOrDefault ["grpFilling", false]) exitWith {};
        private _v = parseNumber ((_pos max 0 min 1) toFixed 2);
        (FS_IDC_G_RARITYVALUE call _ctrl) ctrlSetText (_v toFixed 2);
        private _id = _session getOrDefault ["selGroup", ""];
        if !(_id in _groups) exitWith {};
        if ((["set", [_id, "rarity", _v]] call ALiVE_fnc_fsDataGroup) isEqualTo "") then { ["group rarity", false] call ALiVE_fnc_fsDataTouch };
    };
    case "icon": {
        _args params [["_c", controlNull], ["_index", -1]];
        if (_index < 0 || {_session getOrDefault ["grpFilling", false]}) exitWith {};
        ["icon", _c lbData _index] call _set;
    };
    case "memberSelect": {
        _args params [["_c", controlNull], ["_index", -1]];
        // while the tab fills, the refresh calls this once itself when it is done
        if (_index < 0 || {_session getOrDefault ["grpFilling", false]}) exitWith {};
        private _id = _session getOrDefault ["selGroup", ""];
        private _member = ((_groups getOrDefault [_id, createHashMap]) getOrDefault ["members", []]) param [_index, createHashMap];
        private _ref = _member getOrDefault ["ref", ""];
        // the rank combo follows the member
        if !(_session getOrDefault ["grpFilling", false]) then {
            _session set ["grpFilling", true];
            private _rank = FS_IDC_G_RANK call _ctrl;
            for "_j" from 0 to (lbSize _rank) - 1 do { if ((_rank lbData _j) == (_member getOrDefault ["rank", "PRIVATE"])) then { _rank lbSetCurSel _j } };
            _session set ["grpFilling", false];
        };
        // a #Class member's body is kept under its bare class name
        private _shown = if ((_ref select [0, 1]) == "#") then { _ref select [1] } else { _ref };
        if ((_session getOrDefault ["bodyRef", ""]) == _shown && {!isNull (_session getOrDefault ["body", objNull])}) exitWith {};
        switch (true) do {
            case (_ref in _units): { ["unit", _ref] call ALiVE_fnc_fsStudioPreview };
            case (_ref in _vehicles): { ["vehicle", _ref] call ALiVE_fnc_fsStudioPreview };
            case ((_ref select [0, 1]) == "#"): { ["class", _ref select [1]] call ALiVE_fnc_fsStudioPreview };
            default { ["clear"] call ALiVE_fnc_fsStudioPreview };
        };
    };
    case "memberAdd": {
        private _id = _session getOrDefault ["selGroup", ""];
        private _pick = FS_IDC_G_MEMBERPICK call _ctrl;
        if (!(_id in _groups) || {lbCurSel _pick < 0}) exitWith {};
        private _ref = _pick lbData (lbCurSel _pick);
        // the first member leads the group
        private _rank = ["PRIVATE", "SERGEANT"] select (((_groups get _id) getOrDefault ["members", []]) isEqualTo []);
        private _at = ["memberAdd", [_id, _ref, _rank]] call ALiVE_fnc_fsDataGroup;
        if (_at < 0) exitWith {};
        ["group member add"] call _changed;
        private _members = FS_IDC_G_MEMBERS call _ctrl;
        _members lbSetCurSel _at;
    };
    case "memberRemove": {
        private _id = _session getOrDefault ["selGroup", ""];
        private _at = call _memberIndex;
        if (!(_id in _groups) || {_at < 0}) exitWith {};
        if (["memberRemove", [_id, _at]] call ALiVE_fnc_fsDataGroup) then { ["group member remove"] call _changed };
    };
    case "memberUp";
    case "memberDown": {
        private _id = _session getOrDefault ["selGroup", ""];
        private _at = call _memberIndex;
        if (!(_id in _groups) || {_at < 0}) exitWith {};
        private _delta = [1, -1] select (_op == "memberUp");
        if (["memberMove", [_id, _at, _delta]] call ALiVE_fnc_fsDataGroup) then {
            ["group member move"] call _changed;
            (FS_IDC_G_MEMBERS call _ctrl) lbSetCurSel (_at + _delta);
        };
    };
    case "rank": {
        _args params [["_c", controlNull], ["_index", -1]];
        if (_index < 0 || {_session getOrDefault ["grpFilling", false]}) exitWith {};
        private _id = _session getOrDefault ["selGroup", ""];
        private _at = call _memberIndex;
        if (!(_id in _groups) || {_at < 0}) exitWith {};
        if (["memberRank", [_id, _at, _c lbData _index]] call ALiVE_fnc_fsDataGroup) then {
            ["group rank", false] call ALiVE_fnc_fsDataTouch;
            (FS_IDC_G_MEMBERS call _ctrl) lbSetTextRight [_at, _c lbData _index];
        };
    };
    default {};
};
