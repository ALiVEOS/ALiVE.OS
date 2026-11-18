#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsDataPool);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsDataPool

Description:
The faction's shared gear pools: named lists of weighted items for one slot,
which any number of units can use. A unit wearing a pool gets one of its items
at random in that slot when he is made (the rest of his loadout as stored).

    "add"     - [name, slot]: the new id, or "" (bad name, or FS_MAX_POOLS reached)
    "rename"  - [id, name]: "" or a status key
    "slot"    - [id, slot]: "" or a status key; the items are emptied, they were
                for the old slot
    "entries" - [id, list of [item, weight, weapon]]: "" or a status key
    "delete"  - [id]: the number of units that used it (they no longer do)
    "use"     - [unitId, poolId, on]: "" or a status key. A unit has one pool per
                slot, so turning one on turns off his other pool for that slot
    "users"   - [id]: the unit ids using it, in unit order

Slots: 0 primary weapon, 1 handgun, 2 launcher, 3 uniform, 4 vest, 5 backpack,
6 headgear, 7 facewear. A weapon item carries its whole loadout entry (weapon,
attachments, loaded magazines); the other items are a class name.

Parameters:
    _op      - STRING - as above
    _args    - ARRAY - as above
    _faction - HASHMAP - optional, default missionNamespace ALiVE_FS_faction

Returns:
    As above

Examples:
    (begin example)
    private _id = ["add", ["Rifles", 0]] call ALiVE_fnc_fsDataPool;
    ["use", ["u3", _id, true]] call ALiVE_fnc_fsDataPool;
    (end)

See Also:
    ALiVE_fnc_fsStudioPools, ALiVE_fnc_fsPoolRoll

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_op", "", [""]], ["_args", [], [[]]], ["_faction", objNull]];

if !(_faction isEqualType createHashMap) then { _faction = missionNamespace getVariable ["ALiVE_FS_faction", createHashMap] };

private _dict = _faction getOrDefault ["pools", createHashMap];
if !("pools" in _faction) then { _faction set ["pools", _dict] };
private _order = _faction getOrDefault ["poolOrder", []];
if !("poolOrder" in _faction) then { _faction set ["poolOrder", _order] };
private _units = _faction getOrDefault ["units", createHashMap];

private _okSlot = { _this isEqualType 0 && {_this in [0, 1, 2, 3, 4, 5, 6, 7]} };

switch (_op) do {

    case "add": {
        _args params [["_name", "", [""]], ["_slot", 0, [0]]];
        if ((count _dict) >= FS_MAX_POOLS || {_name isEqualTo ""} || {!(_slot call _okSlot)} || {!(([_name, "text60"] call ALiVE_fnc_fsDataCheckValue) isEqualTo "")}) then {
            ""
        } else {
            private _id = [_faction, "p"] call ALiVE_fnc_fsDataId;
            _dict set [_id, createHashMapFromArray [["id", _id], ["name", _name], ["slot", _slot], ["entries", []]]];
            _order pushBack _id;
            _id
        };
    };

    case "rename": {
        _args params [["_id", "", [""]], ["_name", "", [""]]];
        private _why = [_name, "text60"] call ALiVE_fnc_fsDataCheckValue;
        if (_name isEqualTo "") then { _why = "S_TEXT_BAD" };
        if !(_id in _dict) then { _why = "S_PASTE_BAD" };
        if (_why isEqualTo "") then { (_dict get _id) set ["name", _name] };
        _why
    };

    case "slot": {
        _args params [["_id", "", [""]], ["_slot", 0, [0]]];
        if (!(_id in _dict) || {!(_slot call _okSlot)}) exitWith { "S_PASTE_BAD" };
        private _pool = _dict get _id;
        if ((_pool get "slot") == _slot) exitWith { "" };
        _pool set ["slot", _slot];
        _pool set ["entries", []];
        // a unit already wearing another pool for that slot keeps that one
        {
            private _u = _units getOrDefault [_x, createHashMap];
            private _list = _u getOrDefault ["pools", []];
            if ((_list findIf { !(_x isEqualTo _id) && {((_dict getOrDefault [_x, createHashMap]) getOrDefault ["slot", -1]) == _slot} }) >= 0) then {
                _u set ["pools", _list - [_id]];
            };
        } forEach (["users", [_id], _faction] call ALiVE_fnc_fsDataPool);
        ""
    };

    case "entries": {
        _args params [["_id", "", [""]], ["_list", [], [[]]]];
        if !(_id in _dict) exitWith { "S_PASTE_BAD" };
        if ((count _list) > 32) exitWith { "S_POOL_FULL" };
        private _slot = (_dict get _id) get "slot";
        private _weaponSlot = _slot in [0, 1, 2];
        private _out = [];
        private _bad = false;
        {
            _x params [["_item", ""], ["_weight", 1], ["_weapon", []]];
            private _ok = ([_item, "gear"] call ALiVE_fnc_fsDataCheckValue) isEqualTo ""
                && {!(_item isEqualTo "")}
                && {([_weight, [1, 100]] call ALiVE_fnc_fsDataCheckValue) isEqualTo ""}
                && {([_weapon, "poolWeapon"] call ALiVE_fnc_fsDataCheckValue) isEqualTo ""}
                && {_weaponSlot isEqualTo !(_weapon isEqualTo [])};
            if (_ok) then {
                _out pushBack createHashMapFromArray [["class", _item], ["weight", round _weight], ["weapon", +_weapon]];
            } else { _bad = true };
        } forEach _list;
        if (_bad) exitWith { "S_PASTE_BAD" };
        (_dict get _id) set ["entries", _out];
        ""
    };

    case "delete": {
        _args params [["_id", "", [""]]];
        if !(_id in _dict) exitWith { 0 };
        private _n = 0;
        {
            private _list = _y getOrDefault ["pools", []];
            if (_id in _list) then { _y set ["pools", _list - [_id]]; _n = _n + 1 };
        } forEach _units;
        _dict deleteAt _id;
        _faction set ["poolOrder", _order - [_id]];
        _n
    };

    case "use": {
        _args params [["_uid", "", [""]], ["_id", "", [""]], ["_on", true, [true]]];
        if (!(_uid in _units) || {!(_id in _dict)}) exitWith { "S_PASTE_BAD" };
        private _u = _units get _uid;
        private _slot = (_dict get _id) get "slot";
        private _list = (_u getOrDefault ["pools", []]) select { !(_x isEqualTo _id) && {((_dict getOrDefault [_x, createHashMap]) getOrDefault ["slot", -1]) != _slot || {!_on}} };
        if (_on) then { _list pushBack _id };
        _u set ["pools", _list];
        ""
    };

    case "users": {
        _args params [["_id", "", [""]]];
        (_faction getOrDefault ["unitOrder", []]) select { _id in ((_units getOrDefault [_x, createHashMap]) getOrDefault ["pools", []]) }
    };

    default {
        diag_log format ["ALiVE_fnc_fsDataPool - unknown operation: %1", _op];
        nil
    };
}
