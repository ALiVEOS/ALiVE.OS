#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsStudioCargo);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsStudioCargo

Description:
The cargo popup (ALiVE_FS_Cargo, 14830): what a vehicle carries when it spawns,
or what one of the faction's supply crates holds.

    - "open" [target]: target ["vehicle", id] (the default: the selected vehicle)
      or ["crate", index] (alive.crates, from the ALiVE tab); fills the popup from
      the vehicle's cargoMode and cargo, or the crate's cargo. A crate always
      writes its own list, so its mode combo is fixed on This list;
    - "mode": As the base vehicle (nothing written, the base's own cargo), Empty,
      or This list. Changing the list switches to This list;
    - "select": the picked row's count goes in the count box;
    - "count": the count box (1 to 999) for the picked row;
    - "remove" / "clear": the picked row, or every row;
    - "unit": adds a faction unit's gear (from the unit combo): its weapons,
      magazines, items and backpack, each counted once per time it is worn;
    - "base": adds the base vehicle's own cargo;
    - "close".
Every change is saved at once (the model's "set" of cargo and cargoMode, or the
crate's cargo). A vehicle keeps 64 rows, a crate FS_MAX_CRATE_ROWS.

Parameters:
    _op   - STRING - as above
    _args - ARRAY - the event arguments

Returns:
    Nothing

Examples:
    (begin example)
    ["open"] call ALiVE_fnc_fsStudioCargo;
    (end)

See Also:
    ALiVE_fnc_fsStudioTabVehicles, ALiVE_fnc_fsStudioTabAlive, ALiVE_fnc_fsGenCargo

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"
#include "\x\alive\addons\sys_orbatcreator\data\ui\studio\idc.hpp"

disableSerialization;

params [["_op", "", [""]], ["_args", []]];

private _session = missionNamespace getVariable "ALiVE_FS_session";
if (isNil "_session") exitWith {};
private _popup = findDisplay FS_IDD_CARGO;
private _faction = missionNamespace getVariable ["ALiVE_FS_faction", createHashMap];
private _vehicles = _faction getOrDefault ["vehicles", createHashMap];
private _units = _faction getOrDefault ["units", createHashMap];
// what the popup works on, set when it opens
if (_op isEqualTo "open") then {
    _session set ["cargoTarget", if (_args isEqualType [] && {count _args == 2}) then { +_args } else { ["vehicle", _session getOrDefault ["selVehicle", ""]] }];
};
(_session getOrDefault ["cargoTarget", ["vehicle", ""]]) params [["_targetKind", "vehicle"], ["_targetKey", ""]];
private _isCrate = _targetKind isEqualTo "crate";
private _crates = (_faction getOrDefault ["alive", createHashMap]) getOrDefault ["crates", []];
private _id = ["", _targetKey] select (_targetKey isEqualType "");
if (_isCrate && {!(_targetKey isEqualType 0) || {_targetKey < 0} || {_targetKey >= count _crates}}) exitWith { if (!isNull _popup) then { _popup closeDisplay 2 } };
if (!_isCrate && {!(_id in _vehicles)}) exitWith { if (!isNull _popup) then { _popup closeDisplay 2 } };
private _entry = if (_isCrate) then { _crates select _targetKey } else { _vehicles get _id };
private _maxRows = [64, FS_MAX_CRATE_ROWS] select _isCrate;

// 0 weapon, 1 magazine, 2 item, 3 backpack; -1 not a gear class
private _kindOf = {
    params ["_class"];
    switch (true) do {
        case (isClass (configFile >> "CfgMagazines" >> _class)): { 1 };
        case (isClass (configFile >> "CfgVehicles" >> _class)): { [-1, 3] select (_class isKindOf "Bag_Base") };
        case (isClass (configFile >> "CfgWeapons" >> _class)): {
            // rifles, handguns, launchers and binoculars go in as weapons, the rest as items
            [2, 0] select ((getNumber (configFile >> "CfgWeapons" >> _class >> "type")) in [1, 2, 4, 4096])
        };
        case (isClass (configFile >> "CfgGlasses" >> _class)): { 2 };
        default { -1 };
    }
};
private _nameOf = {
    params ["_class", "_kind"];
    private _root = ["CfgWeapons", "CfgMagazines", "CfgWeapons", "CfgVehicles"] select _kind;
    if (_kind == 2 && {isClass (configFile >> "CfgGlasses" >> _class)}) then { _root = "CfgGlasses" };
    private _n = getText (configFile >> _root >> _class >> "displayName");
    if (_n isEqualTo "") then { _class } else { _n }
};

// saves the list (and This list as the mode), then redraws
private _save = {
    params ["_list", ["_mode", 2]];
    if (_isCrate) exitWith {
        _entry set ["cargo", _list select [0, FS_MAX_CRATE_ROWS]];
        ["alive crate cargo", false] call ALiVE_fnc_fsDataTouch;
        ["fill"] call ALiVE_fnc_fsStudioCargo;
        ["refresh", []] call ALiVE_fnc_fsStudioTabAlive;
    };
    private _why = ["set", [_id, "cargo", _list]] call ALiVE_fnc_fsDataVehicle;
    if (_why isEqualTo "") then { _why = ["set", [_id, "cargoMode", _mode]] call ALiVE_fnc_fsDataVehicle };
    if !(_why isEqualTo "") exitWith { [1, _why] call ALiVE_fnc_fsStudioStatus };
    ["vehicle cargo", false] call ALiVE_fnc_fsDataTouch;
    ["fill"] call ALiVE_fnc_fsStudioCargo;
    ["refresh", []] call ALiVE_fnc_fsStudioTabVehicles;
};
// adds [class, count] pairs to the list, merging a class already there; the row limit is kept
private _addAll = {
    params ["_pairs"];
    private _list = (_entry getOrDefault ["cargo", []]) apply { +_x };
    private _skipped = 0;
    {
        _x params ["_class", "_n"];
        private _kind = [_class] call _kindOf;
        if (_kind >= 0 && {_n > 0}) then {
            private _at = _list findIf { (toLower (_x getOrDefault ["class", ""])) == toLower _class };
            if (_at >= 0) then {
                private _row = _list select _at;
                _row set ["count", ((_row getOrDefault ["count", 1]) + _n) min 999];
            } else {
                if (count _list < _maxRows) then {
                    _list pushBack createHashMapFromArray [["class", _class], ["kind", _kind], ["count", (round _n) min 999]];
                } else { _skipped = _skipped + 1 };
            };
        };
    } forEach _pairs;
    [_list] call _save;
    if (_skipped > 0) then { [1, "S_CARGO_FULL", [_skipped]] call ALiVE_fnc_fsStudioStatus };
};
// a getUnitLoadout array as [class, count] pairs
private _gearOf = {
    params ["_loadout"];
    private _out = [];
    private _weapon = {
        params ["_w"];
        if !(_w isEqualType [] && {count _w > 0}) exitWith {};
        // the bare weapon: a preset class (arifle_MX_ACO_pointer_F) already carries the attachments listed next
        _out pushBack [[_w select 0] call BIS_fnc_baseWeapon, 1];
        { if (_x isEqualType "" && {!(_x isEqualTo "")}) then { _out pushBack [_x, 1] } } forEach (_w select [1, 3]);
        { if (_x isEqualType [] && {count _x > 0}) then { _out pushBack [_x select 0, 1] } } forEach (_w select [4, 2]);
        private _bipod = _w param [6, ""];
        if (_bipod isEqualType "" && {!(_bipod isEqualTo "")}) then { _out pushBack [_bipod, 1] };
    };
    private _container = {
        params ["_c"];
        if !(_c isEqualType [] && {count _c > 0}) exitWith {};
        _out pushBack [_c select 0, 1];
        {
            // [class, count], [class, count, ammo] or [[weapon], count]
            private _what = _x select 0;
            if (_what isEqualType []) then {
                for "_k" from 1 to (_x param [1, 1]) do { [_what] call _weapon };
            } else {
                _out pushBack [_what, _x param [1, 1]];
            };
        } forEach (_c param [1, []]);
    };
    _loadout params [["_primary", []], ["_launcher", []], ["_handgun", []], ["_uniform", []], ["_vest", []], ["_pack", []], ["_helmet", ""], ["_face", ""], ["_binocular", []], ["_assigned", []]];
    { [_x] call _weapon } forEach [_primary, _launcher, _handgun, _binocular];
    { [_x] call _container } forEach [_uniform, _vest, _pack];
    { if (_x isEqualType "" && {!(_x isEqualTo "")}) then { _out pushBack [_x, 1] } } forEach ([_helmet, _face] + _assigned);
    _out
};

switch (_op) do {
    case "open": {
        private _studio = _session getOrDefault ["display", displayNull];
        if (isNull _studio) exitWith {};
        if (!isNull _popup) then { _popup closeDisplay 2 };
        _popup = _studio createDisplay "ALiVE_FS_Cargo";
        if (isNull _popup) exitWith {};
        (_popup displayCtrl FS_IDC_CG_TITLE) ctrlSetText format [localize "STR_ALIVE_FS_CG_TITLE", _entry getOrDefault ["name", _id]];
        private _mode = _popup displayCtrl FS_IDC_CG_MODE;
        { _mode lbAdd localize _x } forEach ["STR_ALIVE_FS_CG_MODE_BASE", "STR_ALIVE_FS_CG_MODE_EMPTY", "STR_ALIVE_FS_CG_MODE_LIST"];
        private _who = _popup displayCtrl FS_IDC_CG_UNIT;
        {
            if (_x in _units) then {
                private _i = _who lbAdd ((_units get _x) getOrDefault ["name", _x]);
                _who lbSetData [_i, _x];
            };
        } forEach (_faction getOrDefault ["unitOrder", []]);
        if (lbSize _who > 0) then { _who lbSetCurSel 0 };
        ["fill"] call ALiVE_fnc_fsStudioCargo;
    };
    case "fill": {
        if (isNull _popup) exitWith {};
        _session set ["cargoFilling", true];
        (_popup displayCtrl FS_IDC_CG_MODE) lbSetCurSel ([_entry getOrDefault ["cargoMode", 0], 2] select _isCrate);
        (_popup displayCtrl FS_IDC_CG_MODE) ctrlEnable !_isCrate;
        private _l = _popup displayCtrl FS_IDC_CG_LIST;
        private _was = lbCurSel _l;
        lbClear _l;
        {
            private _class = _x getOrDefault ["class", ""];
            private _kind = _x getOrDefault ["kind", 2];
            private _i = _l lbAdd ([_class, _kind] call _nameOf);
            _l lbSetData [_i, _class];
            _l lbSetTooltip [_i, _class];
            _l lbSetTextRight [_i, format ["%1  x%2", localize (["STR_ALIVE_FS_CG_K0", "STR_ALIVE_FS_CG_K1", "STR_ALIVE_FS_CG_K2", "STR_ALIVE_FS_CG_K3"] select _kind), _x getOrDefault ["count", 1]]];
            if !(isClass (configFile >> (["CfgWeapons", "CfgMagazines", "CfgWeapons", "CfgVehicles"] select _kind) >> _class) || {isClass (configFile >> "CfgGlasses" >> _class)}) then {
                _l lbSetColor [_i, [1, 0.35, 0.3, 1]];
            };
        } forEach (_entry getOrDefault ["cargo", []]);
        if (lbSize _l > 0) then { _l lbSetCurSel ((_was max 0) min ((lbSize _l) - 1)) };
        private _row = (_entry getOrDefault ["cargo", []]) param [lbCurSel _l, createHashMap];
        (_popup displayCtrl FS_IDC_CG_COUNT) ctrlSetText str (_row getOrDefault ["count", 1]);
        _session set ["cargoFilling", false];
    };
    case "mode": {
        _args params [["_ctrl", controlNull], ["_index", -1]];
        if (_index < 0 || {_isCrate} || {_session getOrDefault ["cargoFilling", false]}) exitWith {};
        [(_entry getOrDefault ["cargo", []]) apply { +_x }, _index] call _save;
    };
    case "select": {
        _args params [["_ctrl", controlNull], ["_index", -1]];
        if (_index < 0 || {_session getOrDefault ["cargoFilling", false]}) exitWith {};
        private _row = (_entry getOrDefault ["cargo", []]) param [_index, createHashMap];
        (_popup displayCtrl FS_IDC_CG_COUNT) ctrlSetText str (_row getOrDefault ["count", 1]);
    };
    case "count": {
        private _i = lbCurSel (_popup displayCtrl FS_IDC_CG_LIST);
        private _list = (_entry getOrDefault ["cargo", []]) apply { +_x };
        if (_i < 0 || {_i >= count _list}) exitWith {};
        private _n = parseNumber ctrlText (_popup displayCtrl FS_IDC_CG_COUNT);
        if (!(finite _n) || {_n < 1}) exitWith { [1, "S_CARGO_COUNT"] call ALiVE_fnc_fsStudioStatus };
        (_list select _i) set ["count", (round _n) min 999];
        [_list] call _save;
    };
    case "remove": {
        private _i = lbCurSel (_popup displayCtrl FS_IDC_CG_LIST);
        private _list = (_entry getOrDefault ["cargo", []]) apply { +_x };
        if (_i < 0 || {_i >= count _list}) exitWith {};
        _list deleteAt _i;
        [_list] call _save;
    };
    case "clear": { [[]] call _save };
    case "unit": {
        private _who = _popup displayCtrl FS_IDC_CG_UNIT;
        private _uid = if (lbCurSel _who < 0) then { "" } else { _who lbData (lbCurSel _who) };
        if !(_uid in _units) exitWith {};
        [[(_units get _uid) getOrDefault ["loadout", []]] call _gearOf] call _addAll;
    };
    case "base": {
        private _cfg = configFile >> "CfgVehicles" >> (_entry getOrDefault ["base", ""]);
        private _pairs = [];
        {
            _x params ["_box", "_key"];
            {
                private _class = getText (_x >> _key);
                if !(_class isEqualTo "") then { _pairs pushBack [_class, getNumber (_x >> "count")] };
            } forEach configProperties [_cfg >> _box, "isClass _x", true];
        } forEach [["TransportWeapons", "weapon"], ["TransportMagazines", "magazine"], ["TransportItems", "name"], ["TransportBackpacks", "backpack"]];
        if (_pairs isEqualTo []) exitWith { [1, "S_CARGO_BASE_NONE"] call ALiVE_fnc_fsStudioStatus };
        [_pairs] call _addAll;
    };
    case "close": {
        if (!isNull _popup) then { _popup closeDisplay 2 };
    };
    default {};
};
