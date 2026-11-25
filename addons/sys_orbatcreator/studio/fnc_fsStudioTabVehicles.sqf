#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsStudioTabVehicles);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsStudioTabVehicles

Description:
The Vehicles tab: the working faction's vehicles, the selected one's fields,
crew, gunners, paint and parts, with the selection on the stage.

    - "refresh", "select": as the Units tab (selVehicle in the session);
    - "duplicate", "delete", "up", "down", "name", "class", "classAuto",
      "category": as the Units tab, through ALiVE_fnc_fsDataVehicle;
    - "add", "base": the class browser for vehicles;
    - "crew": the crew for every seat ("As the base vehicle", or a unit of the
      faction);
    - "seat", "gunner": a gunner seat and the unit in it;
    - "texture": the paint (Default, or one of the base's TextureSources);
    - "part": a click on a part turns it on or off; a click on a marking (a
      roundel, emblem or number, the rows under the parts) takes it off or puts
      it back (markingsOff, the base's hidden selections other than the paint). The parts are the base's
      animationSources that Eden's Edit Vehicle Appearance shows (a displayName
      and scope above 1 or no scope, the Garage's rule); only the ones changed from the base are stored;
    - "pylons": the base's pylon presets ("As the base vehicle" stores nothing;
      a preset stores its magazine per pylon; Custom is a stored list no preset
      matches, shown and kept);
    - "cargo": the cargo popup (ALiVE_fnc_fsStudioCargo); the row under the
      parts shows As the base vehicle, Empty, or the list's kinds and total.
Every change redraws the preview. The note W_ALIVE_CREW shows when a gunner is
set that Crew does not match.

Parameters:
    _op   - STRING - the event
    _args - ARRAY - the event arguments

Returns:
    Nothing

Examples:
    (begin example)
    ["refresh", []] call ALiVE_fnc_fsStudioTabVehicles;
    (end)

See Also:
    ALiVE_fnc_fsStudioTabUnits, ALiVE_fnc_fsDataVehicle, ALiVE_fnc_fsStudioPreview

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\data\ui\studio\idc.hpp"

disableSerialization;

params [["_op", "", [""]], ["_args", []]];

private _session = missionNamespace getVariable "ALiVE_FS_session";
if (isNil "_session") exitWith {};
private _display = _session getOrDefault ["display", displayNull];
if (isNull _display) exitWith {};

private _faction = missionNamespace getVariable ["ALiVE_FS_faction", createHashMap];
private _vehicles = _faction getOrDefault ["vehicles", createHashMap];
private _units = _faction getOrDefault ["units", createHashMap];
private _list = _display displayCtrl FS_IDC_V_LIST;
private _checked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
private _unchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";

// the parts Eden's appearance editor shows for a class: [source, displayName, initPhase]
private _partsOf = {
    params ["_class"];
    private _out = [];
    {
        // the Garage's own rule (fn_garage.sqf): a displayName, and scope above 1 or no scope at all (vanilla
        // parts such as the Marshall's slat armour have none); inherited sources count
        if (!(getText (_x >> "displayName") isEqualTo "") && {getNumber (_x >> "scope") > 1 || {!isNumber (_x >> "scope")}}) then {
            _out pushBack [configName _x, getText (_x >> "displayName"), getNumber (_x >> "initPhase")];
        };
    } forEach (configProperties [configFile >> "CfgVehicles" >> _class >> "animationSources", "isClass _x", true]);
    _out
};

// the base's pylons, in config order
private _pylonsOf = {
    params ["_class"];
    (configProperties [configFile >> "CfgVehicles" >> _class >> "Components" >> "TransportPylonsComponent" >> "Pylons", "isClass _x", true]) apply { configName _x }
};
// a preset's attachments made as long as the pylon list ("" for a pylon it leaves out)
private _fitPylons = {
    params ["_list", "_n"];
    private _out = (_list select [0, _n]) apply { if (_x isEqualType "") then { _x } else { "" } };
    while { count _out < _n } do { _out pushBack "" };
    _out
};

// a combo of "As the base vehicle" then every unit of the faction
private _unitCombo = {
    params ["_combo", "_selected"];
    lbClear _combo;
    private _i = _combo lbAdd (localize "STR_ALIVE_FS_CREW_INHERIT");
    _combo lbSetData [_i, ""];
    if (_selected isEqualTo "") then { _combo lbSetCurSel _i };
    {
        if (_x in _units) then {
            _i = _combo lbAdd ((_units get _x) getOrDefault ["name", _x]);
            _combo lbSetData [_i, _x];
            if (_x == _selected) then { _combo lbSetCurSel _i };
        };
    } forEach (_faction getOrDefault ["unitOrder", []]);
};

// the selected vehicle's fields and the stage
private _show = {
    params ["_id", ["_rebuild", false]];
    private _entry = _vehicles getOrDefault [_id, createHashMap];
    _session set ["selVehicle", _id];
    _session set ["vehFilling", true];
    (_display displayCtrl FS_IDC_V_NAME) ctrlSetText (_entry getOrDefault ["name", ""]);
    (_display displayCtrl FS_IDC_V_CLASS) ctrlSetText (_entry getOrDefault ["class", ""]);
    (_display displayCtrl FS_IDC_V_CLASSAUTO) cbSetChecked (_entry getOrDefault ["classAuto", true]);
    (_display displayCtrl FS_IDC_V_OPTIONAL) cbSetChecked (_entry getOrDefault ["optional", false]);
    (_display displayCtrl FS_IDC_V_OPTIONAL) ctrlEnable !(_id isEqualTo "");
    // the Init Code, first line only
    private _code = _entry getOrDefault ["initCode", ""];
    private _first = trim ((_code splitString (toString [10, 13])) param [0, ""]);
    (_display displayCtrl FS_IDC_V_INIT) ctrlSetText (if (_code isEqualTo "") then { localize "STR_ALIVE_FS_INIT_NONE" } else {
        (_first select [0, 40]) + (["", "..."] select ((count _first) > 40 || {(count (_code splitString (toString [10]))) > 1}))
    });
    (_display displayCtrl FS_IDC_V_INITEDIT) ctrlEnable !(_id isEqualTo "");
    private _base = _entry getOrDefault ["base", ""];
    private _baseName = getText (configFile >> "CfgVehicles" >> _base >> "displayName");
    (_display displayCtrl FS_IDC_V_BASE) ctrlSetText (if (_baseName isEqualTo "") then { _base } else { format ["%1 (%2)", _base, _baseName] });

    private _combo = _display displayCtrl FS_IDC_V_CATEGORY;
    lbClear _combo;
    private _cats = _faction getOrDefault ["categories", createHashMap];
    {
        private _i = _combo lbAdd ((_cats get _x) getOrDefault ["name", _x]);
        _combo lbSetData [_i, _x];
        if (_x == (_entry getOrDefault ["category", ""])) then { _combo lbSetCurSel _i };
    } forEach ((_faction getOrDefault ["categoryOrder", []]) select { _x in _cats });

    [_display displayCtrl FS_IDC_V_CREW, _entry getOrDefault ["crewUnit", ""]] call _unitCombo;

    private _seats = _display displayCtrl FS_IDC_V_SEATS;
    private _seatWas = (lbCurSel _seats) max 0;
    lbClear _seats;
    {
        private _i = _seats lbAdd (_x getOrDefault ["name", str (_x getOrDefault ["path", []])]);
        private _g = _x getOrDefault ["gunnerUnit", ""];
        _seats lbSetTextRight [_i, if (_g in _units) then { (_units get _g) getOrDefault ["name", _g] } else { localize "STR_ALIVE_FS_CREW_INHERIT" }];
    } forEach (_entry getOrDefault ["turrets", []]);
    if (lbSize _seats > 0) then { _seats lbSetCurSel (_seatWas min ((lbSize _seats) - 1)) };
    private _turret = (_entry getOrDefault ["turrets", []]) param [lbCurSel _seats, createHashMap];
    private _gunner = _display displayCtrl FS_IDC_V_GUNNER;
    [_gunner, _turret getOrDefault ["gunnerUnit", ""]] call _unitCombo;
    _gunner ctrlEnable (lbSize _seats > 0);

    private _paint = _display displayCtrl FS_IDC_V_TEXTURE;
    lbClear _paint;
    private _i = _paint lbAdd (localize "STR_ALIVE_FS_TEXTURE_DEFAULT");
    _paint lbSetData [_i, ""];
    _paint lbSetCurSel _i;
    {
        _i = _paint lbAdd getText (_x >> "displayName");
        _paint lbSetData [_i, configName _x];
        if ((configName _x) == (_entry getOrDefault ["texture", ""])) then { _paint lbSetCurSel _i };
    } forEach ("true" configClasses (configFile >> "CfgVehicles" >> _base >> "TextureSources"));

    // pylons: As the base vehicle, the base's presets; Custom when the stored list matches none of them
    private _pyl = _display displayCtrl FS_IDC_V_PYLONS;
    lbClear _pyl;
    private _pylonCount = count ([_base] call _pylonsOf);
    if (_pylonCount == 0) then {
        _pyl lbSetCurSel (_pyl lbAdd (localize "STR_ALIVE_FS_PYLONS_NONE"));
    } else {
        private _stored = _entry getOrDefault ["pylons", []];
        _i = _pyl lbAdd (localize "STR_ALIVE_FS_CREW_INHERIT");
        _pyl lbSetData [_i, ""];
        if (_stored isEqualTo []) then { _pyl lbSetCurSel _i };
        {
            _i = _pyl lbAdd getText (_x >> "displayName");
            _pyl lbSetData [_i, configName _x];
            if (!(_stored isEqualTo []) && {([getArray (_x >> "attachment"), _pylonCount] call _fitPylons) isEqualTo _stored}) then { _pyl lbSetCurSel _i };
        } forEach ("isArray (_x >> 'attachment') && {(getArray (_x >> 'attachment')) findIf { _x isEqualType '' && {!(_x isEqualTo '')} } >= 0}" configClasses (configFile >> "CfgVehicles" >> _base >> "Components" >> "TransportPylonsComponent" >> "Presets"));
        if (lbCurSel _pyl < 0) then {
            _i = _pyl lbAdd (localize "STR_ALIVE_FS_PYLONS_CUSTOM");
            _pyl lbSetData [_i, "#custom"];
            _pyl lbSetCurSel _i;
        };
    };
    _pyl ctrlEnable (_pylonCount > 0);

    // parts: ticked from the stored value, else from the base
    private _parts = _display displayCtrl FS_IDC_V_PARTS;
    lbClear _parts;
    private _stored = createHashMap;
    { _stored set [_x getOrDefault ["source", ""], _x getOrDefault ["value", 0]] } forEach (_entry getOrDefault ["components", []]);
    private _all = [_base] call _partsOf;
    {
        _x params ["_source", "_name", "_init"];
        private _on = (_stored getOrDefault [_source, _init]) > 0.5;
        _i = _parts lbAdd _name;
        _parts lbSetData [_i, _source];
        _parts lbSetValue [_i, [0, 1] select _on];
        _parts lbSetPicture [_i, [_unchecked, _checked] select _on];
    } forEach _all;
    // markings: the base's hidden selections other than the paint, the classic editor's list, ticked unless taken off
    private _off = _entry getOrDefault ["markingsOff", []];
    private _markRow = localize "STR_ALIVE_FS_MARKING_ROW";
    if (_markRow isEqualTo "") then { _markRow = "Marking: %1" };
    {
        private _sel = _x select 1;
        private _on = !(_sel in _off);
        _i = _parts lbAdd format [_markRow, _sel];
        _parts lbSetData [_i, "#mark:" + _sel];
        _parts lbSetValue [_i, [0, 1] select _on];
        _parts lbSetPicture [_i, [_unchecked, _checked] select _on];
    } forEach (if (_base isEqualTo "") then { [] } else { [objNull, "getVehicleMarkings", _base] call ALiVE_fnc_orbatCreator });
    if (lbSize _parts == 0 && {!(_id isEqualTo "")}) then { _parts lbAdd (localize "STR_ALIVE_FS_PARTS_NONE") };
    _parts lbSetCurSel -1;
    // as tall as its rows (1 to 6, whole rows, never half a row); the crew note follows below it
    private _rowH = 0.9 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25);
    private _pp = ctrlPosition _parts;
    private _ph = (((lbSize _parts) max 1) min 6) * _rowH;
    _parts ctrlSetPosition [_pp select 0, _pp select 1, _pp select 2, _ph];
    _parts ctrlCommit 0;
    // the cargo row under the parts, the Init Code row under it, the crew note under that
    private _below = (_pp select 1) + _ph + (_rowH / 3);
    {
        _x params ["_idc", "_row"];
        private _c = _display displayCtrl _idc;
        private _cp = ctrlPosition _c;
        _c ctrlSetPosition [_cp select 0, _below + _row * _rowH * (1 + 1 / 3), _cp select 2, _cp select 3];
        _c ctrlCommit 0;
    } forEach [[FS_IDC_V_CARGOLABEL, 0], [FS_IDC_V_CARGO, 0], [FS_IDC_V_CARGOEDIT, 0], [FS_IDC_V_INITLABEL, 1], [FS_IDC_V_INIT, 1], [FS_IDC_V_INITEDIT, 1]];
    private _note = _display displayCtrl FS_IDC_V_NOTE;
    private _np = ctrlPosition _note;
    _note ctrlSetPosition [_np select 0, _below + 2 * _rowH * (1 + 1 / 3), _np select 2, _np select 3];
    _note ctrlCommit 0;

    // cargo: As the base vehicle, Empty, or "N kinds, M in all"
    private _cargo = _entry getOrDefault ["cargo", []];
    private _total = 0;
    { _total = _total + (_x getOrDefault ["count", 1]) } forEach _cargo;
    (_display displayCtrl FS_IDC_V_CARGO) ctrlSetText (switch (_entry getOrDefault ["cargoMode", 0]) do {
        case 1: { localize "STR_ALIVE_FS_CG_SUM_EMPTY" };
        case 2: { format [localize "STR_ALIVE_FS_CG_SUM_LIST", count _cargo, _total] };
        default { localize "STR_ALIVE_FS_CG_SUM_BASE" };
    });
    (_display displayCtrl FS_IDC_V_CARGOEDIT) ctrlEnable !(_id isEqualTo "");

    // the crew note: a gunner Crew does not match
    private _crew = _entry getOrDefault ["crewUnit", ""];
    private _odd = (_entry getOrDefault ["turrets", []]) findIf { private _g = _x getOrDefault ["gunnerUnit", ""]; !(_g isEqualTo "") && {_g != _crew} };
    (_display displayCtrl FS_IDC_V_NOTE) ctrlSetStructuredText parseText (if (_odd < 0) then { "" } else {
        format ["<t color='#E6B422'>%1</t>", format [localize "STR_ALIVE_FS_W_ALIVE_CREW", _entry getOrDefault ["name", _id], if (_crew in _units) then { (_units get _crew) getOrDefault ["name", _crew] } else { getText (configFile >> "CfgVehicles" >> (getText (configFile >> "CfgVehicles" >> _base >> "crew")) >> "displayName") }]]
    });
    _session set ["vehFilling", false];

    switch (true) do {
        case (_id isEqualTo ""): { ["clear"] call ALiVE_fnc_fsStudioPreview };
        case (_rebuild || {_session getOrDefault ["bodyStale", false]} || {(_session getOrDefault ["bodyRef", ""]) != _id} || {isNull (_session getOrDefault ["body", objNull])}): {
            _session set ["bodyStale", false];
            ["vehicle", _id] call ALiVE_fnc_fsStudioPreview;
        };
        default {
            (_display displayCtrl FS_IDC_CAPTION) ctrlSetText format ["%1  %2", typeOf (_session get "body"), _entry getOrDefault ["name", ""]];
        };
    };
};

private _changed = {
    params ["_reason", ["_status", []], ["_rebuild", false]];
    [_reason, false] call ALiVE_fnc_fsDataTouch;
    // shown again by the refresh; bodyRef is kept, so the preview knows it is the same vehicle (in place, same view)
    if (_rebuild) then { _session set ["bodyStale", true] };
    ["refresh", []] call ALiVE_fnc_fsStudioTabVehicles;
    if !(_status isEqualTo []) then { _status call ALiVE_fnc_fsStudioStatus } else { [-1] call ALiVE_fnc_fsStudioStatus };
};

private _set = {
    params ["_key", "_value", ["_rebuild", false]];
    private _id = _session getOrDefault ["selVehicle", ""];
    if (_id isEqualTo "" || {!(_id in _vehicles)}) exitWith {};
    private _current = (_vehicles get _id) get _key;
    if (!isNil "_current" && {_current isEqualTo _value}) exitWith {};
    private _why = ["set", [_id, _key, _value]] call ALiVE_fnc_fsDataVehicle;
    if (_why isEqualTo "") then {
        ["vehicle " + _key, [], _rebuild] call _changed;
    } else {
        [_id] call _show;
        [1, _why] call ALiVE_fnc_fsStudioStatus;
    };
};

switch (_op) do {
    case "refresh": {
        lbClear _list;
        private _order = (_faction getOrDefault ["vehicleOrder", []]) select { _x in _vehicles };
        { if !(_x in _order) then { _order pushBack _x } } forEach (keys _vehicles);
        private _sel = _session getOrDefault ["selVehicle", ""];
        private _selIndex = -1;
        {
            private _entry = _vehicles get _x;
            private _i = _list lbAdd (_entry getOrDefault ["name", _x]);
            _list lbSetData [_i, _x];
            _list lbSetTextRight [_i, if (_entry getOrDefault ["optional", false]) then { (_entry getOrDefault ["class", ""]) + "  " + localize "STR_ALIVE_FS_OPT_ROW" } else { _entry getOrDefault ["class", ""] }];
            private _base = _entry getOrDefault ["base", ""];
            if (!(_base isEqualTo "") && {!isClass (configFile >> "CfgVehicles" >> _base)}) then {
                _list lbSetColor [_i, [1, 0.35, 0.3, 1]];
                _list lbSetColorRight [_i, [1, 0.35, 0.3, 1]];
            };
            if (_x == _sel) then { _selIndex = _i };
        } forEach _order;
        if (_selIndex < 0 && {lbSize _list > 0}) then { _selIndex = 0 };
        if (_selIndex >= 0) then {
            _list lbSetCurSel _selIndex;
            [_list lbData _selIndex] call _show;
        } else {
            [""] call _show;
        };
    };
    case "select": {
        _args params [["_ctrl", controlNull], ["_index", -1]];
        if (_index < 0) exitWith {};
        private _id = _list lbData _index;
        if (_id isEqualTo "" || {_id == (_session getOrDefault ["selVehicle", ""]) && {(_session getOrDefault ["bodyRef", ""]) == _id}}) exitWith {};
        [_id] call _show;
    };
    case "duplicate": {
        private _id = _session getOrDefault ["selVehicle", ""];
        if !(_id in _vehicles) exitWith {};
        private _new = ["duplicate", [_id]] call ALiVE_fnc_fsDataVehicle;
        if (_new isEqualTo "") exitWith {};
        _session set ["selVehicle", _new];
        ["vehicle duplicate", [0, "S_DUPLICATED", [(_vehicles get _new) getOrDefault ["class", _new]]]] call _changed;
    };
    case "delete": {
        private _id = _session getOrDefault ["selVehicle", ""];
        if !(_id in _vehicles) exitWith {};
        private _name = (_vehicles get _id) getOrDefault ["name", _id];
        private _order = (_faction getOrDefault ["vehicleOrder", []]) select { _x in _vehicles };
        private _i = _order find _id;
        private _uses = ["delete", [_id]] call ALiVE_fnc_fsDataVehicle;
        if (_uses isEqualTo []) exitWith {};
        private _rest = _order - [_id];
        _session set ["selVehicle", if (_rest isEqualTo []) then { "" } else { _rest select ((_i min ((count _rest) - 1)) max 0) }];
        ["vehicle delete", [0, "S_UNIT_DELETED", [_name, _uses param [0, 0], _uses param [1, 0]]]] call _changed;
    };
    case "up";
    case "down": {
        private _id = _session getOrDefault ["selVehicle", ""];
        if !(_id in _vehicles) exitWith {};
        if (["move", [_id, [1, -1] select (_op == "up")]] call ALiVE_fnc_fsDataVehicle) then { ["vehicle move"] call _changed };
    };
    case "name": { ["name", ctrlText (_display displayCtrl FS_IDC_V_NAME)] call _set };
    case "class": { ["class", ctrlText (_display displayCtrl FS_IDC_V_CLASS)] call _set };
    case "classAuto": { ["classAuto", cbChecked (_display displayCtrl FS_IDC_V_CLASSAUTO)] call _set };
    case "optional": { ["optional", cbChecked (_display displayCtrl FS_IDC_V_OPTIONAL)] call _set };
    case "category": {
        _args params [["_ctrl", controlNull], ["_index", -1]];
        if (_index < 0 || {_session getOrDefault ["vehFilling", false]}) exitWith {};
        ["category", _ctrl lbData _index] call _set;
    };
    case "crew": {
        _args params [["_ctrl", controlNull], ["_index", -1]];
        if (_index < 0 || {_session getOrDefault ["vehFilling", false]}) exitWith {};
        ["crewUnit", _ctrl lbData _index] call _set;
    };
    case "seat": {
        _args params [["_ctrl", controlNull], ["_index", -1]];
        if (_index < 0 || {_session getOrDefault ["vehFilling", false]}) exitWith {};
        private _id = _session getOrDefault ["selVehicle", ""];
        private _turret = ((_vehicles getOrDefault [_id, createHashMap]) getOrDefault ["turrets", []]) param [_index, createHashMap];
        _session set ["vehFilling", true];
        [_display displayCtrl FS_IDC_V_GUNNER, _turret getOrDefault ["gunnerUnit", ""]] call _unitCombo;
        _session set ["vehFilling", false];
    };
    case "gunner": {
        _args params [["_ctrl", controlNull], ["_index", -1]];
        if (_index < 0 || {_session getOrDefault ["vehFilling", false]}) exitWith {};
        private _id = _session getOrDefault ["selVehicle", ""];
        if !(_id in _vehicles) exitWith {};
        private _seat = lbCurSel (_display displayCtrl FS_IDC_V_SEATS);
        private _turrets = +((_vehicles get _id) getOrDefault ["turrets", []]);
        if (_seat < 0 || {_seat >= count _turrets}) exitWith {};
        private _t = +(_turrets select _seat);
        _t set ["gunnerUnit", _ctrl lbData _index];
        _turrets set [_seat, _t];
        ["turrets", _turrets] call _set;
    };
    case "texture": {
        _args params [["_ctrl", controlNull], ["_index", -1]];
        if (_index < 0 || {_session getOrDefault ["vehFilling", false]}) exitWith {};
        ["texture", _ctrl lbData _index, true] call _set;
    };
    case "part": {
        _args params [["_ctrl", controlNull], ["_index", -1]];
        if (_index < 0 || {_session getOrDefault ["vehFilling", false]}) exitWith {};
        private _source = _ctrl lbData _index;
        private _id = _session getOrDefault ["selVehicle", ""];
        if (_source isEqualTo "" || {!(_id in _vehicles)}) exitWith {};
        private _entry = _vehicles get _id;
        if ((_source select [0, 6]) isEqualTo "#mark:") exitWith {
            private _sel = _source select [6];
            private _off = +(_entry getOrDefault ["markingsOff", []]);
            if (_sel in _off) then { _off = _off - [_sel] } else { _off pushBack _sel };
            ["markingsOff", _off, true] call _set;
        };
        private _now = 1 - (_ctrl lbValue _index);
        private _init = (([_entry getOrDefault ["base", ""]] call _partsOf) select { (_x select 0) == _source }) param [0, ["", "", 0]] select 2;
        // only what differs from the base is stored
        private _comps = (_entry getOrDefault ["components", []]) select { (_x getOrDefault ["source", ""]) != _source } apply { +_x };
        if ((_now > 0.5) isNotEqualTo (_init > 0.5)) then { _comps pushBack createHashMapFromArray [["source", _source], ["value", _now]] };
        ["components", _comps, true] call _set;
    };
    case "pylons": {
        _args params [["_ctrl", controlNull], ["_index", -1]];
        if (_index < 0 || {_session getOrDefault ["vehFilling", false]}) exitWith {};
        private _id = _session getOrDefault ["selVehicle", ""];
        if !(_id in _vehicles) exitWith {};
        private _preset = _ctrl lbData _index;
        if (_preset == "#custom") exitWith {};
        private _base = (_vehicles get _id) getOrDefault ["base", ""];
        private _list = if (_preset isEqualTo "") then { [] } else {
            [getArray (configFile >> "CfgVehicles" >> _base >> "Components" >> "TransportPylonsComponent" >> "Presets" >> _preset >> "attachment"), count ([_base] call _pylonsOf)] call _fitPylons
        };
        ["pylons", _list, true] call _set;
    };
    case "cargo": { ["open"] call ALiVE_fnc_fsStudioCargo };
    case "initCode": {
        private _id = _session getOrDefault ["selVehicle", ""];
        if !(_id in _vehicles) exitWith {};
        private _entry = _vehicles get _id;
        ["open", [format [localize "STR_ALIVE_FS_Q_INITCODE_V", _entry getOrDefault ["name", _id]], _entry getOrDefault ["initCode", ""], {
            params ["_ok", "_text", "_cbArgs"];
            if (_ok) then { ["initCodeSet", [_cbArgs select 0, _text]] call ALiVE_fnc_fsStudioTabVehicles };
        }, [_id], "ALiVE_FS_CodePrompt"]] call ALiVE_fnc_fsStudioPrompt;
    };
    case "initCodeSet": {
        _args params [["_id", "", [""]], ["_text", "", [""]]];
        if !(_id in _vehicles) exitWith {};
        _session set ["selVehicle", _id];
        // kept as typed, line breaks included; joined onto one line only in the export
        ["initCode", trim ((_text splitString (toString [13])) joinString "")] call _set;
    };
    case "add": {
        if (!isNil "ALiVE_fnc_fsStudioBrowser") then { ["open", ["multi", 1]] call ALiVE_fnc_fsStudioBrowser };
    };
    case "base": {
        if (!isNil "ALiVE_fnc_fsStudioBrowser") then { ["open", ["single", 1]] call ALiVE_fnc_fsStudioBrowser };
    };
    default {};
};
