#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsStudioTabUnits);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsStudioTabUnits

Description:
The Units tab: the list of the working faction's units and the selected unit's
fields, with the selection driving the preview.

    - "refresh": fills the list in the faction's unit order (name, class as right
      text, red when the base class is not loaded) and selects the session's
      selUnit, else the first unit;
    - "select": the list's selection: stores selUnit, fills the fields and the
      category combo, and puts the unit on the stage (a body already showing that
      unit is kept, so a refresh after a field edit does not rebuild it);
    - "duplicate", "delete", "up", "down": the list buttons, through
      ALiVE_fnc_fsDataUnit; a delete selects the row that takes its place;
    - "name", "class", "classAuto", "category", "fixed": the fields. A value the
      model refuses puts the stored value back and says why in the status box;
      "fixed" keeps the body's face and voice in the unit's identity;
    - "engineer", "eod", "medic", "uavHacker": Engineer, EOD, Medic and UAV
      Hacker, ticked as the base class until changed; a tick that matches the
      base class is stored as "as the base" (-1), so the export writes engineer,
      canDeactivateMines, attendant and uavHacker only where he differs;
    - "add", "base": open the class browser (ALiVE_fnc_fsStudioBrowser), in multi
      and single mode;
    - "arsenal": the Arsenal choice, kept in the session and the prefs (ACE only
      when it is loaded).
The fields also show the loadout summary (ALiVE_fnc_fsStudioLoadoutText) and
the face, voice and insignia; Edit loadout and Undo last Arsenal are on when
they can be used.
Every change marks the faction changed (ALiVE_fnc_fsDataTouch, not forced) and
redraws the list.

Parameters:
    _op   - STRING - the event
    _args - ARRAY - the event arguments

Returns:
    Nothing

Examples:
    (begin example)
    ["refresh", []] call ALiVE_fnc_fsStudioTabUnits;
    (end)

See Also:
    ALiVE_fnc_fsStudioTab, ALiVE_fnc_fsStudioPreview

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\data\ui\studio\idc.hpp"
#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

disableSerialization;

params [["_op", "", [""]], ["_args", []]];

private _session = missionNamespace getVariable "ALiVE_FS_session";
if (isNil "_session") exitWith {};
private _display = _session getOrDefault ["display", displayNull];
if (isNull _display) exitWith {};

private _faction = missionNamespace getVariable ["ALiVE_FS_faction", createHashMap];
private _units = _faction getOrDefault ["units", createHashMap];
private _list = _display displayCtrl FS_IDC_U_LIST;

// the selected unit's fields and the stage
private _show = {
    params ["_id"];
    private _entry = _units getOrDefault [_id, createHashMap];
    _session set ["selUnit", _id];
    (_display displayCtrl FS_IDC_U_NAME) ctrlSetText (_entry getOrDefault ["name", ""]);
    (_display displayCtrl FS_IDC_U_CLASS) ctrlSetText (_entry getOrDefault ["class", ""]);
    (_display displayCtrl FS_IDC_U_CLASSAUTO) cbSetChecked (_entry getOrDefault ["classAuto", true]);
    (_display displayCtrl FS_IDC_U_FIXED) cbSetChecked ((_entry getOrDefault ["identity", createHashMap]) getOrDefault ["fixed", false]);
    private _base = _entry getOrDefault ["base", ""];
    private _baseName = getText (configFile >> "CfgVehicles" >> _base >> "displayName");
    (_display displayCtrl FS_IDC_U_BASE) ctrlSetText (if (_baseName isEqualTo "") then { _base } else { format ["%1 (%2)", _base, _baseName] });
    private _combo = _display displayCtrl FS_IDC_U_CATEGORY;
    lbClear _combo;
    private _cat = _entry getOrDefault ["category", ""];
    private _cats = _faction getOrDefault ["categories", createHashMap];
    {
        private _i = _combo lbAdd ((_cats get _x) getOrDefault ["name", _x]);
        _combo lbSetData [_i, _x];
        if (_x == _cat) then { _combo lbSetCurSel _i };
    } forEach ((_faction getOrDefault ["categoryOrder", []]) select { _x in _cats });
    // loadout summary, identity line, Arsenal buttons
    private _identity = _entry getOrDefault ["identity", createHashMap];
    (_display displayCtrl FS_IDC_U_SUMMARY) ctrlSetStructuredText parseText (if (_id isEqualTo "") then { "" } else { [_entry getOrDefault ["loadout", []]] call ALiVE_fnc_fsStudioLoadoutText });
    // as tall as the summary, so no line is cut; the tab scrolls if it runs past the bottom
    private _sum = _display displayCtrl FS_IDC_U_SUMMARY;
    private _sp = ctrlPosition _sum;
    _sum ctrlSetPosition [_sp select 0, _sp select 1, _sp select 2, (ctrlTextHeight _sum) max (4.94 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25))];
    _sum ctrlCommit 0;
    // the pools row and Roll under the summary
    private _cell = (((safezoneW / safezoneH) min 1.2) / 1.2) / 25;
    private _below = (_sp select 1) + (((ctrlTextHeight _sum) max (4.94 * _cell))) + 0.35 * _cell;
    {
        _x params ["_idc", "_row"];
        private _c = _display displayCtrl _idc;
        private _cp = ctrlPosition _c;
        _c ctrlSetPosition [_cp select 0, _below + _row * 1.15 * _cell, _cp select 2, _cp select 3];
        _c ctrlCommit 0;
    } forEach [[FS_IDC_U_POOLSLABEL, 0], [FS_IDC_U_POOLS, 0], [FS_IDC_U_POOLSEDIT, 0], [FS_IDC_U_ROLL, 1], [FS_IDC_U_UNROLL, 1],
        [FS_IDC_U_ROLELABEL, 2], [FS_IDC_U_ROLE, 2], [FS_IDC_U_SPECOPS, 2], [FS_IDC_U_SPECOPSLABEL, 2],
        [FS_IDC_U_ENGINEER, 3], [FS_IDC_U_ENGINEERLABEL, 3], [FS_IDC_U_EOD, 3], [FS_IDC_U_EODLABEL, 3],
        [FS_IDC_U_MEDIC, 4], [FS_IDC_U_MEDICLABEL, 4], [FS_IDC_U_UAVHACKER, 4], [FS_IDC_U_UAVHACKERLABEL, 4]];
    // his part in AUTO GROUPS; Automatic names the part worked out
    _session set ["roleFilling", true];
    private _roleCombo = _display displayCtrl FS_IDC_U_ROLE;
    lbClear _roleCombo;
    private _role = _entry getOrDefault ["role", ""];
    private _worked = if (_id isEqualTo "") then { "" } else { private _copy = +_entry; _copy set ["role", ""]; [_copy] call ALiVE_fnc_fsAutoRole };
    {
        private _i = _roleCombo lbAdd (if (_x isEqualTo "") then {
            format [localize "STR_ALIVE_FS_U_ROLE_AUTO", if (_worked isEqualTo "") then { "" } else { localize ("STR_ALIVE_FS_ROLE_" + toUpper _worked) }]
        } else { localize ("STR_ALIVE_FS_ROLE_" + toUpper _x) });
        _roleCombo lbSetData [_i, _x];
        if (_x == _role) then { _roleCombo lbSetCurSel _i };
    } forEach ([""] + FS_ROLES);
    _session set ["roleFilling", false];
    (_display displayCtrl FS_IDC_U_SPECOPS) cbSetChecked (_entry getOrDefault ["specOps", false]);
    (_display displayCtrl FS_IDC_U_OPTIONAL) cbSetChecked (_entry getOrDefault ["optional", false]);
    // Engineer, EOD, Medic and UAV Hacker: his own setting, else his base class's
    {
        _x params ["_idc", "_key", "_prop"];
        private _v = _entry getOrDefault [_key, -1];
        (_display displayCtrl _idc) cbSetChecked (if (_v < 0) then { getNumber (configFile >> "CfgVehicles" >> _base >> _prop) > 0 } else { _v > 0 });
    } forEach [[FS_IDC_U_ENGINEER, "engineer", "engineer"], [FS_IDC_U_EOD, "eod", "canDeactivateMines"],
        [FS_IDC_U_MEDIC, "medic", "attendant"], [FS_IDC_U_UAVHACKER, "uavHacker", "uavHacker"]];
    { (_display displayCtrl _x) ctrlEnable !(_id isEqualTo "") } forEach [FS_IDC_U_ROLE, FS_IDC_U_SPECOPS, FS_IDC_U_OPTIONAL, FS_IDC_U_ENGINEER, FS_IDC_U_EOD, FS_IDC_U_MEDIC, FS_IDC_U_UAVHACKER];
    private _poolDict = _faction getOrDefault ["pools", createHashMap];
    private _worn = (_entry getOrDefault ["pools", []]) select { _x in _poolDict };
    (_display displayCtrl FS_IDC_U_POOLS) ctrlSetText (if (_worn isEqualTo []) then { localize "STR_ALIVE_FS_PL_NONE" } else { (_worn apply { (_poolDict get _x) getOrDefault ["name", _x] }) joinString ", " });
    { (_display displayCtrl _x) ctrlEnable !(_id isEqualTo "") } forEach [FS_IDC_U_POOLSEDIT, FS_IDC_U_UNROLL];
    (_display displayCtrl FS_IDC_U_ROLL) ctrlEnable (!(_id isEqualTo "") && {!(_worn isEqualTo [])});
    (_display displayCtrl FS_IDC_U_IDENTITY) ctrlSetText (if (_id isEqualTo "") then { "" } else {
        format [localize "STR_ALIVE_FS_ID_READOUT", _identity getOrDefault ["face", "-"], _identity getOrDefault ["speaker", "-"], _identity getOrDefault ["insignia", "-"]]
    });
    private _armed = !isNil "ALiVE_fnc_fsStudioArsenal";
    (_display displayCtrl FS_IDC_U_LOADOUT) ctrlEnable (_armed && {!(_id isEqualTo "")} && {isClass (configFile >> "CfgVehicles" >> _base)});
    private _undo = _session getOrDefault ["arsenalUndo", createHashMap];
    (_display displayCtrl FS_IDC_U_UNDO) ctrlEnable (_armed && {_undo isEqualType createHashMap} && {_id in _undo});
    private _ca = _display displayCtrl FS_IDC_U_ARSENAL;
    if (lbSize _ca == 0) then {
        private _ace = _armed && {["available"] call ALiVE_fnc_fsStudioArsenal};
        {
            _x params ["_key", "_data", "_on"];
            private _i = _ca lbAdd (localize _key);
            _ca lbSetData [_i, _data];
            if (!_on) then { _ca lbSetColor [_i, [0.5, 0.5, 0.5, 1]] };
            if (_data == (_session getOrDefault ["arsenal", "BIS"])) then { _ca lbSetCurSel _i };
        } forEach [["STR_ALIVE_ORBATCREATOR_ARSENAL_TYPE_BIS", "BIS", true], ["STR_ALIVE_ORBATCREATOR_ARSENAL_TYPE_ACE", "ACE", _ace]];
    };
    switch (true) do {
        case (_id isEqualTo ""): { ["clear"] call ALiVE_fnc_fsStudioPreview };
        case ((_session getOrDefault ["bodyRef", ""]) != _id || {isNull (_session getOrDefault ["body", objNull])}): { ["unit", _id] call ALiVE_fnc_fsStudioPreview };
        default {
            // same body: only the caption follows a renamed unit
            (_display displayCtrl FS_IDC_CAPTION) ctrlSetText format ["%1  %2", typeOf (_session get "body"), _entry getOrDefault ["name", ""]];
        };
    };
};

// a change to the faction: mark it, redraw the list, say what happened
private _changed = {
    params ["_reason", ["_status", []]];
    [_reason, false] call ALiVE_fnc_fsDataTouch;
    ["refresh", []] call ALiVE_fnc_fsStudioTabUnits;
    if !(_status isEqualTo []) then { _status call ALiVE_fnc_fsStudioStatus } else { [-1] call ALiVE_fnc_fsStudioStatus };
};

// one field through the model's "set"; a refusal puts the stored value back
private _set = {
    params ["_key", "_value"];
    private _id = _session getOrDefault ["selUnit", ""];
    if (_id isEqualTo "" || {!(_id in _units)}) exitWith {};
    private _current = (_units get _id) get _key;
    if (!isNil "_current" && {_current isEqualTo _value}) exitWith {};
    private _why = ["set", [_id, _key, _value]] call ALiVE_fnc_fsDataUnit;
    if (_why isEqualTo "") then {
        ["unit " + _key] call _changed;
    } else {
        [_id] call _show;
        [1, _why] call ALiVE_fnc_fsStudioStatus;
    };
};

switch (_op) do {
    case "refresh": {
        lbClear _list;
        private _order = (_faction getOrDefault ["unitOrder", []]) select { _x in _units };
        { if !(_x in _order) then { _order pushBack _x } } forEach (keys _units);
        private _sel = _session getOrDefault ["selUnit", ""];
        private _selIndex = -1;
        {
            private _entry = _units get _x;
            private _i = _list lbAdd (_entry getOrDefault ["name", _x]);
            _list lbSetData [_i, _x];
            private _class = _entry getOrDefault ["class", ""];
            _list lbSetTextRight [_i, if (_entry getOrDefault ["optional", false]) then { _class + "  " + localize "STR_ALIVE_FS_OPT_ROW" } else { _class }];
            private _base = _entry getOrDefault ["base", ""];
            if (!(_base isEqualTo "") && {!isClass (configFile >> "CfgVehicles" >> _base)}) then {
                _list lbSetColor [_i, [1, 0.35, 0.3, 1]];
                _list lbSetColorRight [_i, [1, 0.35, 0.3, 1]];
            };
            if (_x == _sel) then { _selIndex = _i };
        } forEach _order;
        if (_selIndex < 0 && {lbSize _list > 0}) then { _selIndex = 0 };
        if (_selIndex >= 0) then {
            // lbSetCurSel fires "select", which shows the unit
            _list lbSetCurSel _selIndex;
            // the event may not run here; the body on the stage says whether it did
            private _id = _list lbData _selIndex;
            if ((_session getOrDefault ["bodyRef", ""]) != _id) then { [_id] call _show };
        } else {
            [""] call _show;
        };
    };
    case "select": {
        _args params [["_ctrl", controlNull], ["_index", -1]];
        if (_index < 0) exitWith {};
        private _id = _list lbData _index;
        if (_id isEqualTo "") exitWith {};
        [_id] call _show;
    };
    case "duplicate": {
        private _id = _session getOrDefault ["selUnit", ""];
        if !(_id in _units) exitWith {};
        private _new = ["duplicate", [_id]] call ALiVE_fnc_fsDataUnit;
        if (_new isEqualTo "") exitWith {};
        _session set ["selUnit", _new];
        ["unit duplicate", [0, "S_DUPLICATED", [(_units get _new) getOrDefault ["class", _new]]]] call _changed;
    };
    case "delete": {
        private _id = _session getOrDefault ["selUnit", ""];
        if !(_id in _units) exitWith {};
        private _name = (_units get _id) getOrDefault ["name", _id];
        private _order = (_faction getOrDefault ["unitOrder", []]) select { _x in _units };
        private _i = _order find _id;
        private _uses = ["delete", [_id]] call ALiVE_fnc_fsDataUnit;
        if (_uses isEqualTo []) exitWith {};
        // the row below takes its place, or the one above at the end of the list
        private _rest = _order - [_id];
        _session set ["selUnit", if (_rest isEqualTo []) then { "" } else { _rest select ((_i min ((count _rest) - 1)) max 0) }];
        ["unit delete", [0, "S_UNIT_DELETED", [_name, _uses param [0, 0], _uses param [1, 0]]]] call _changed;
    };
    case "up";
    case "down": {
        private _id = _session getOrDefault ["selUnit", ""];
        if !(_id in _units) exitWith {};
        if (["move", [_id, [1, -1] select (_op == "up")]] call ALiVE_fnc_fsDataUnit) then { ["unit move"] call _changed };
    };
    case "name": {
        ["name", ctrlText (_display displayCtrl FS_IDC_U_NAME)] call _set;
    };
    case "class": {
        ["class", ctrlText (_display displayCtrl FS_IDC_U_CLASS)] call _set;
    };
    case "classAuto": {
        ["classAuto", cbChecked (_display displayCtrl FS_IDC_U_CLASSAUTO)] call _set;
    };
    case "role": {
        _args params [["_ctrl", controlNull], ["_index", -1]];
        if (_index < 0 || {_session getOrDefault ["roleFilling", false]}) exitWith {};
        ["role", _ctrl lbData _index] call _set;
    };
    case "specOps": {
        ["specOps", cbChecked (_display displayCtrl FS_IDC_U_SPECOPS)] call _set;
    };
    case "optional": {
        ["optional", cbChecked (_display displayCtrl FS_IDC_U_OPTIONAL)] call _set;
    };
    case "category": {
        _args params [["_ctrl", controlNull], ["_index", -1]];
        if (_index < 0) exitWith {};
        ["category", _ctrl lbData _index] call _set;
    };
    case "engineer";
    case "eod";
    case "medic";
    case "uavHacker": {
        private _id = _session getOrDefault ["selUnit", ""];
        if !(_id in _units) exitWith {};
        private _k = ["engineer", "eod", "medic", "uavHacker"] find _op;
        private _on = cbChecked (_display displayCtrl ([FS_IDC_U_ENGINEER, FS_IDC_U_EOD, FS_IDC_U_MEDIC, FS_IDC_U_UAVHACKER] select _k));
        // the same as his base class is kept as -1, so a later change of base class still carries through
        private _baseOn = getNumber (configFile >> "CfgVehicles" >> ((_units get _id) getOrDefault ["base", ""]) >> (["engineer", "canDeactivateMines", "attendant", "uavHacker"] select _k)) > 0;
        [_op, [[0, 1] select _on, -1] select (_on isEqualTo _baseOn)] call _set;
    };
    case "fixed": {
        private _id = _session getOrDefault ["selUnit", ""];
        if !(_id in _units) exitWith {};
        private _on = cbChecked (_display displayCtrl FS_IDC_U_FIXED);
        private _identity = +((_units get _id) getOrDefault ["identity", createHashMap]);
        if ((_identity getOrDefault ["fixed", false]) isEqualTo _on) exitWith {};
        _identity set ["fixed", _on];
        // keep the face and voice the body has now
        private _body = _session getOrDefault ["body", objNull];
        if (_on && {!isNull _body} && {(_session getOrDefault ["bodyRef", ""]) == _id}) then {
            _identity set ["face", face _body];
            _identity set ["speaker", speaker _body];
        };
        ["identity", _identity] call _set;
    };
    case "add": {
        if (!isNil "ALiVE_fnc_fsStudioBrowser") then { ["open", ["multi", 0]] call ALiVE_fnc_fsStudioBrowser };
    };
    case "base": {
        if (!isNil "ALiVE_fnc_fsStudioBrowser") then { ["open", ["single", 0]] call ALiVE_fnc_fsStudioBrowser };
    };
    case "arsenal": {
        _args params [["_ctrl", controlNull], ["_index", -1]];
        if (_index < 0) exitWith {};
        private _pick = _ctrl lbData _index;
        if (_pick == (_session getOrDefault ["arsenal", "BIS"])) exitWith {};
        // ACE stays on the Virtual Arsenal when it is not loaded
        if (_pick == "ACE" && {isNil "ALiVE_fnc_fsStudioArsenal" || {!(["available"] call ALiVE_fnc_fsStudioArsenal)}}) exitWith {
            _ctrl lbSetCurSel 0;
            [1, "S_ACE_MISSING", []] call ALiVE_fnc_fsStudioStatus;
        };
        _session set ["arsenal", _pick];
        ["prefSet", ["arsenal", _pick]] call ALiVE_fnc_fsDataStore;
    };
    default {};
};
