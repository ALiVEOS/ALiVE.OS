#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsDataGroup);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsDataGroup

Description:
Edits the groups of a studio faction. A group's automatic class is
<TAG>_<Category>_<Name>; the first member is the leader.

Parameters:
    _op      - STRING - the operation
    _args    - ARRAY - its arguments
    _faction - HASHMAP - optional, default missionNamespace ALiVE_FS_faction

Operations:
    "add"          - [entry]: a ready-built group hashmap (missing keys take their
                     defaults; members that do not exist are dropped). Returns the
                     new id, or "" at FS_MAX_GROUPS.
    "set"          - [id, key, value]: one key, checked by its schema rule (members go
                     through the schema walk of a reload, every ref must exist, and
                     the walked copy is stored); name and
                     category rename the class while classAuto is on; class is
                     checked for use and turns classAuto off. Returns "" or the
                     problem key (as ALiVE_fnc_fsDataUnit).
    "duplicate"    - [id]: a copy right after it. Returns the new id or "".
    "delete"       - [id]: Returns BOOL.
    "move"         - [id, delta]: swaps with the next group of the same category
                     up (-1) or down (1). Returns BOOL.
    "memberAdd"    - [id, ref, rank]: ref is a unit or vehicle id of this faction or
                     "#ClassName"; rank defaults to PRIVATE. Returns the member's
                     index, or -1 (bad ref or rank, or FS_MAX_MEMBERS reached).
    "memberRemove" - [id, index]: Returns BOOL.
    "memberMove"   - [id, index, delta]: Returns BOOL.
    "memberRank"   - [id, index, rank]: Returns BOOL.

Returns:
    per operation, see above

Examples:
    (begin example)
    private _gid = ["add", [createHashMapFromArray [["name", "Rifle Squad"], ["category", "Infantry"]]]] call ALiVE_fnc_fsDataGroup;
    ["memberAdd", [_gid, "u3", "SERGEANT"]] call ALiVE_fnc_fsDataGroup;
    (end)

See Also:
    ALiVE_fnc_fsDataUnit, ALiVE_fnc_fsDataClassName

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_op", "", [""]], ["_args", [], [[]]], ["_faction", objNull]];

if !(_faction isEqualType createHashMap) then { _faction = missionNamespace getVariable ["ALiVE_FS_faction", createHashMap] };

private _schema = call ALiVE_fnc_fsDataSchema;
private _dict = _faction getOrDefault ["groups", createHashMap];
if !("groups" in _faction) then { _faction set ["groups", _dict] };
private _order = _faction getOrDefault ["groupOrder", []];
if !("groupOrder" in _faction) then { _faction set ["groupOrder", _order] };

private _refOk = {
    params ["_ref"];
    _ref isEqualType "" && {([_ref, "ref"] call ALiVE_fnc_fsDataCheckValue) isEqualTo ""} && {
        ((_ref select [0, 1]) isEqualTo "#") || {_ref in (_faction getOrDefault ["units", createHashMap])} || {_ref in (_faction getOrDefault ["vehicles", createHashMap])}
    }
};

// Deep copy through the schema, missing keys taking their defaults.
private _build = {
    params ["_map", "_spec"];
    private _out = createHashMap;
    {
        _x params ["_key", "_type", "_default"];
        private _v = if (_key in _map) then { _map get _key } else { if (_default isEqualType []) then { +_default } else { _default } };
        private _sub = _type select [2];
        if ((_type select [0, 2]) isEqualTo "L:") then {
            _v = if (_v isEqualType []) then { (_v select { _x isEqualType createHashMap }) apply { [_x, _sub] call _build } } else { [] };
        } else {
            if (_v isEqualType []) then { _v = +_v };
        };
        _out set [_key, _v];
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
    params ["_grp"];
    _grp set ["class", ["auto", _faction, (_grp get "category") + " " + (_grp get "name"), _grp get "id", "group"] call ALiVE_fnc_fsDataClassName];
    _grp set ["classAuto", true];
};

private _member = {
    params ["_id", "_index"];
    private _grp = _dict getOrDefault [_id, createHashMap];
    private _members = _grp getOrDefault ["members", []];
    if (_index isEqualType 0 && {_index >= 0} && {_index < (count _members)}) then { _members } else { [] }
};

switch (_op) do {

    case "add": {
        _args params [["_entry", createHashMap, [createHashMap]]];
        if ((count _dict) >= FS_MAX_GROUPS) then {
            ""
        } else {
            private _grp = [_entry, "group"] call _build;
            private _id = [_faction, "g"] call ALiVE_fnc_fsDataId;
            _grp set ["id", _id];
            _grp set ["members", ((_grp get "members") select { [_x getOrDefault ["ref", ""]] call _refOk }) select [0, FS_MAX_MEMBERS]];
            if !(([_grp get "category", "class"] call ALiVE_fnc_fsDataCheckValue) isEqualTo "") then { _grp set ["category", "Infantry"] };
            if ((_grp get "classAuto") || {!((["check", _faction, _grp get "class", _id, "group"] call ALiVE_fnc_fsDataClassName) select 0)}) then {
                [_grp] call _autoClass;
            };
            _dict set [_id, _grp];
            _order pushBack _id;
            _id
        };
    };

    case "set": {
        _args params [["_id", "", [""]], ["_key", "", [""]], "_value"];
        private _grp = _dict getOrDefault [_id, createHashMap];
        private _rows = _schema getOrDefault ["group", []];
        private _at = _rows findIf { (_x select 0) isEqualTo _key };
        if ((count _grp) == 0 || {_at < 0} || {_key isEqualTo "id"} || {isNil "_value"}) then {
            "S_PASTE_BAD"
        } else {
            (_rows select _at) params ["", "_type", "_default", "_rule", ["_limit", 0]];
            private _store = if (_value isEqualType []) then { +_value } else { _value };
            private _why = switch (true) do {
                case (_type isEqualTo "B"): { ["S_TEXT_BAD", ""] select (_value isEqualType true) };
                case ((_type select [0, 2]) in ["M:", "L:"]): {
                    // Members: the schema walk (ref, rank, pos), then every ref must exist.
                    private _w = [_value, _type, _limit] call _walk;
                    _store = _w select 1;
                    private _ok = (_w select 0) && {(_store findIf { !([_x get "ref"] call _refOk) }) < 0};
                    ["S_PASTE_BAD", ""] select _ok
                };
                default { [_value, _rule] call ALiVE_fnc_fsDataCheckValue };
            };
            if (_why isEqualTo "" && {_key isEqualTo "class"}) then {
                private _check = ["check", _faction, _value, _id, "group"] call ALiVE_fnc_fsDataClassName;
                if !(_check select 0) then { _why = ["S_NAME_TAKEN", "S_NAME_BAD"] select ((_check select 1) isEqualTo "") };
            };
            if (_why isEqualTo "") then {
                _grp set [_key, _store];
                if (_key isEqualTo "class") then { _grp set ["classAuto", false] };
                if (((_key in ["name", "category"]) && {_grp get "classAuto"}) || {_key isEqualTo "classAuto" && {_value}}) then { [_grp] call _autoClass };
            };
            _why
        };
    };

    case "duplicate": {
        _args params [["_id", "", [""]]];
        private _source = _dict getOrDefault [_id, createHashMap];
        if ((count _source) == 0 || {(count _dict) >= FS_MAX_GROUPS}) then {
            ""
        } else {
            private _grp = [_source, "group"] call _build;
            private _newId = [_faction, "g"] call ALiVE_fnc_fsDataId;
            _grp set ["id", _newId];
            // a copy is the player's own: AUTO GROUPS never replaces it
            _grp set ["auto", ""];
            [_grp] call _autoClass;
            _dict set [_newId, _grp];
            private _i = _order find _id;
            if (_i < 0) then {
                _order pushBack _newId;
            } else {
                _faction set ["groupOrder", (_order select [0, _i + 1]) + [_newId] + (_order select [_i + 1])];
            };
            _newId
        };
    };

    case "delete": {
        _args params [["_id", "", [""]]];
        if !(_id in _dict) then {
            false
        } else {
            _dict deleteAt _id;
            _faction set ["groupOrder", _order - [_id]];
            true
        };
    };

    case "move": {
        _args params [["_id", "", [""]], ["_delta", 0, [0]]];
        private _i = _order find _id;
        private _done = false;
        if (_i >= 0 && {_delta != 0}) then {
            private _cat = (_dict getOrDefault [_id, createHashMap]) getOrDefault ["category", ""];
            private _step = [-1, 1] select (_delta > 0);
            private _j = _i + _step;
            while { !_done && {_j >= 0} && {_j < (count _order)} } do {
                if (((_dict getOrDefault [_order select _j, createHashMap]) getOrDefault ["category", ""]) == _cat) then {
                    _order set [_i, _order select _j];
                    _order set [_j, _id];
                    _done = true;
                };
                _j = _j + _step;
            };
        };
        _done
    };

    case "memberAdd": {
        _args params [["_id", "", [""]], ["_ref", "", [""]], ["_rank", "PRIVATE", [""]]];
        private _grp = _dict getOrDefault [_id, createHashMap];
        private _members = _grp getOrDefault ["members", []];
        if ((count _grp) == 0 || {(count _members) >= FS_MAX_MEMBERS} || {!([_ref] call _refOk)} || {!(([_rank, "rank"] call ALiVE_fnc_fsDataCheckValue) isEqualTo "")}) then {
            -1
        } else {
            _members pushBack (createHashMapFromArray [["ref", _ref], ["rank", _rank], ["pos", []]]);
            _grp set ["members", _members];
            (count _members) - 1
        };
    };

    case "memberRemove": {
        _args params [["_id", "", [""]], ["_index", -1, [0]]];
        private _members = [_id, _index] call _member;
        if (_members isEqualTo []) then { false } else { _members deleteAt _index; true };
    };

    case "memberMove": {
        _args params [["_id", "", [""]], ["_index", -1, [0]], ["_delta", 0, [0]]];
        private _members = [_id, _index] call _member;
        private _j = _index + _delta;
        if (_members isEqualTo [] || {_delta == 0} || {_j < 0} || {_j >= (count _members)}) then {
            false
        } else {
            private _other = _members select _j;
            _members set [_j, _members select _index];
            _members set [_index, _other];
            true
        };
    };

    case "memberRank": {
        _args params [["_id", "", [""]], ["_index", -1, [0]], ["_rank", "", [""]]];
        private _members = [_id, _index] call _member;
        if (_members isEqualTo [] || {!(([_rank, "rank"] call ALiVE_fnc_fsDataCheckValue) isEqualTo "")}) then {
            false
        } else {
            (_members select _index) set ["rank", _rank];
            true
        };
    };

    default {
        diag_log format ["ALiVE_fnc_fsDataGroup - unknown operation: %1", _op];
        nil
    };
}
