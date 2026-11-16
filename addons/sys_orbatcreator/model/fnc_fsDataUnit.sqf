#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsDataUnit);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsDataUnit

Description:
Edits the units (men) of a studio faction. ALiVE_fnc_fsDataVehicle runs the same
code on vehicles by passing _kind "vehicle".

"add" takes a ready-built entry (a unit hashmap, from the import or the class
browser) and gives it an id, a free class and a category; it reads no config, so
the model does not depend on import/. Keys the entry lacks take their schema
defaults.

Parameters:
    _op      - STRING - the operation
    _args    - ARRAY - its arguments
    _faction - HASHMAP - optional, default missionNamespace ALiVE_FS_faction
    _kind    - STRING - "unit" (default) or "vehicle"

Operations:
    "add"       - [entry]: Returns the new id, or "" at the FS_MAX_UNITS / FS_MAX_VEHICLES limit.
    "set"       - [id, key, value]: one key. The value passes the key's schema rule;
                  name renames the class while classAuto is on; class is checked for
                  use and turns classAuto off; classAuto on renames the class;
                  category, crewUnit must exist; identity and turrets go through the
                  schema walk of a reload and the walked copy is stored (turret
                  gunners must exist). Returns "" or the problem key
                  (S_NAME_BAD, S_NAME_TAKEN, S_TAG_BAD, S_TEXT_BAD, E_BAD_LOADOUT,
                  S_PASTE_BAD for an unknown id or key).
    "duplicate" - [id]: a copy right after it, new id, automatic class.
                  Returns the new id or "".
    "delete"    - [id]: also removes every use of it (ALiVE_fnc_fsDataRefs "clean").
                  Returns [groups, seats] it was taken out of, or [] for an unknown id.
    "move"      - [id, delta]: -1 up, 1 down in the list order. Returns BOOL.

Returns:
    per operation, see above

Examples:
    (begin example)
    private _id = ["add", [_entry]] call ALiVE_fnc_fsDataUnit;
    ["set", [_id, "name", "Rifleman"]] call ALiVE_fnc_fsDataUnit;
    (end)

See Also:
    ALiVE_fnc_fsDataVehicle, ALiVE_fnc_fsDataRefs, ALiVE_fnc_fsDataClassName

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_op", "", [""]], ["_args", [], [[]]], ["_faction", objNull], ["_kind", "unit", [""]]];

if !(_faction isEqualType createHashMap) then { _faction = missionNamespace getVariable ["ALiVE_FS_faction", createHashMap] };

private _isVehicle = _kind isEqualTo "vehicle";
private _dictKey = ["units", "vehicles"] select _isVehicle;
private _orderKey = ["unitOrder", "vehicleOrder"] select _isVehicle;
private _letter = ["u", "v"] select _isVehicle;
private _max = [FS_MAX_UNITS, FS_MAX_VEHICLES] select _isVehicle;
private _schema = call ALiVE_fnc_fsDataSchema;

private _dict = _faction getOrDefault [_dictKey, createHashMap];
if !(_dictKey in _faction) then { _faction set [_dictKey, _dict] };
private _order = _faction getOrDefault [_orderKey, []];
if !(_orderKey in _faction) then { _faction set [_orderKey, _order] };

// Missing keys take their schema defaults (maps one level down too).
private _fill = {
    params ["_map", "_spec"];
    {
        _x params ["_key", "_type", "_default"];
        private _sub = _type select [2];
        private _isMap = (_type select [0, 2]) isEqualTo "M:";
        if !(_key in _map) then {
            _map set [_key, if (_isMap) then { [createHashMap, _sub] call _fill } else { if (_default isEqualType []) then { +_default } else { _default } }];
        } else {
            if (_isMap && {(_map get _key) isEqualType createHashMap}) then { [_map get _key, _sub] call _fill };
        };
    } forEach (_schema getOrDefault [_spec, []]);
    _map
};

// Deep copy through the schema (nested maps and lists of maps are copied too).
private _copy = {
    params ["_map", "_spec"];
    private _out = createHashMap;
    {
        _x params ["_key", "_type"];
        if (_key in _map) then {
            private _v = _map get _key;
            private _sub = _type select [2];
            switch (_type select [0, 2]) do {
                case "M:": { _v = [_v, _sub] call _copy };
                case "L:": { _v = _v apply { [_x, _sub] call _copy } };
                default { if (_v isEqualType []) then { _v = +_v } };
            };
            _out set [_key, _v];
        };
    } forEach (_schema getOrDefault [_spec, []]);
    _out
};

// A map, or a list of maps, from the caller: turned into its plain form with its
// spec and read back through the same schema walk a reload uses. Returns
// [ok, walked copy]; the caller's hashmaps are never stored.
private _walk = {
    params ["_value", "_type", "_limit"];
    private _sub = _type select [2];
    private _one = {
        params ["_m"];
        if !(_m isEqualType createHashMap) exitWith { [false, createHashMap] };
        private _r = [[_m, _sub] call ALiVE_fnc_fsDataToPlain, _sub] call ALiVE_fnc_fsDataFromPlain;
        [_r select 0, _r select 1]
    };
    if ((_type select [0, 2]) isEqualTo "M:") exitWith { [_value] call _one };
    if (!(_value isEqualType []) || {_limit > 0 && {(count _value) > _limit}}) exitWith { [false, []] };
    private _out = [];
    private _ok = true;
    {
        private _r = [_x] call _one;
        if (_r select 0) then { _out pushBack (_r select 1) } else { _ok = false };
    } forEach _value;
    [_ok, _out]
};

private _autoClass = {
    params ["_entry"];
    _entry set ["class", ["auto", _faction, _entry get "name", _entry get "id", _kind] call ALiVE_fnc_fsDataClassName];
    _entry set ["classAuto", true];
};

private _firstCat = (_faction getOrDefault ["categoryOrder", []]) param [0, ""];

switch (_op) do {

    case "add": {
        _args params [["_entry", createHashMap, [createHashMap]]];
        if ((count _dict) >= _max) then {
            ""
        } else {
            [_entry, _kind] call _fill;
            private _id = [_faction, _letter] call ALiVE_fnc_fsDataId;
            _entry set ["id", _id];
            if !((_entry get "category") in (_faction getOrDefault ["categories", createHashMap])) then { _entry set ["category", _firstCat] };
            if ((_entry get "classAuto") || {!((["check", _faction, _entry get "class", _id, _kind] call ALiVE_fnc_fsDataClassName) select 0)}) then {
                [_entry] call _autoClass;
            };
            _dict set [_id, _entry];
            _order pushBack _id;
            _id
        };
    };

    case "set": {
        _args params [["_id", "", [""]], ["_key", "", [""]], "_value"];
        private _entry = _dict getOrDefault [_id, createHashMap];
        private _rows = _schema getOrDefault [_kind, []];
        private _at = _rows findIf { (_x select 0) isEqualTo _key };
        if ((count _entry) == 0 || {_at < 0} || {_key isEqualTo "id"} || {isNil "_value"}) then {
            "S_PASTE_BAD"
        } else {
            (_rows select _at) params ["", "_type", "_default", "_rule", ["_limit", 0]];
            private _store = if (_value isEqualType []) then { +_value } else { _value };
            private _why = switch (true) do {
                case (_type isEqualTo "B"): { ["S_TEXT_BAD", ""] select (_value isEqualType true) };
                case (_type isEqualTo "LS"): {
                    if (_value isEqualType [] && {_limit <= 0 || {(count _value) <= _limit}} && {(_value findIf { !(([_x, _rule] call ALiVE_fnc_fsDataCheckValue) isEqualTo "") }) < 0}) then { "" } else { "S_TEXT_BAD" }
                };
                case ((_type select [0, 2]) in ["M:", "L:"]): {
                    private _w = [_value, _type, _limit] call _walk;
                    _store = _w select 1;
                    ["S_PASTE_BAD", ""] select (_w select 0)
                };
                default { [_value, _rule] call ALiVE_fnc_fsDataCheckValue };
            };
            if (_why isEqualTo "") then {
                switch (_key) do {
                    case "class": {
                        private _check = ["check", _faction, _value, _id, _kind] call ALiVE_fnc_fsDataClassName;
                        if !(_check select 0) then { _why = ["S_NAME_TAKEN", "S_NAME_BAD"] select ((_check select 1) isEqualTo "") };
                    };
                    case "category": {
                        if !(_value in (_faction getOrDefault ["categories", createHashMap])) then { _why = "S_PASTE_BAD" };
                    };
                    case "crewUnit": {
                        if (!(_value isEqualTo "") && {!(_value in (_faction getOrDefault ["units", createHashMap]))}) then { _why = "S_PASTE_BAD" };
                    };
                    case "turrets": {
                        private _units = _faction getOrDefault ["units", createHashMap];
                        if ((_store findIf { !((_x get "gunnerUnit") isEqualTo "") && {!((_x get "gunnerUnit") in _units)} }) >= 0) then { _why = "S_PASTE_BAD" };
                    };
                };
            };
            if (_why isEqualTo "") then {
                _entry set [_key, _store];
                if (_key isEqualTo "class") then { _entry set ["classAuto", false] };
                if ((_key isEqualTo "name" && {_entry get "classAuto"}) || {_key isEqualTo "classAuto" && {_value}}) then { [_entry] call _autoClass };
            };
            _why
        };
    };

    case "duplicate": {
        _args params [["_id", "", [""]]];
        private _source = _dict getOrDefault [_id, createHashMap];
        if ((count _source) == 0 || {(count _dict) >= _max}) then {
            ""
        } else {
            private _entry = [_source, _kind] call _copy;
            private _newId = [_faction, _letter] call ALiVE_fnc_fsDataId;
            _entry set ["id", _newId];
            [_entry] call _autoClass;
            _dict set [_newId, _entry];
            private _i = _order find _id;
            if (_i < 0) then {
                _order pushBack _newId;
            } else {
                _faction set [_orderKey, (_order select [0, _i + 1]) + [_newId] + (_order select [_i + 1])];
            };
            _newId
        };
    };

    case "delete": {
        _args params [["_id", "", [""]]];
        if !(_id in _dict) then {
            []
        } else {
            private _uses = ["clean", _id, _faction] call ALiVE_fnc_fsDataRefs;
            _dict deleteAt _id;
            _faction set [_orderKey, _order - [_id]];
            _uses
        };
    };

    case "move": {
        _args params [["_id", "", [""]], ["_delta", 0, [0]]];
        private _i = _order find _id;
        private _j = _i + _delta;
        if (_i < 0 || {_j < 0} || {_j >= (count _order)} || {_delta == 0}) then {
            false
        } else {
            private _other = _order select _j;
            _order set [_j, _id];
            _order set [_i, _other];
            true
        };
    };

    default {
        diag_log format ["ALiVE_fnc_fsDataUnit - unknown operation: %1", _op];
        nil
    };
}
