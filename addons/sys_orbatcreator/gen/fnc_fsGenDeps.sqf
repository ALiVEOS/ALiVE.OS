#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsGenDeps);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsGenDeps

Description:
Works out which addons an exported faction needs. Looks at every base, outside
crew and gunner, #Class group member, every class in every loadout and every
insignia, and the supply crates, and takes only the addon that first defined each class (the first of
configSourceAddonList). The parent chain is not walked: the defining addon
already needs its parents, and walking it is what pulled every patching addon
(ACE on vanilla soldiers) into the classic export. ALiVE's own addons are left
out (ALiVE is never a dependency); another studio export's ALiVE_FS_ patch is
kept. cba_xeh is always added. A class that is not loaded has no addon and
gives W_GEAR_MISSING.

It also keeps the addons of each entry on its own (key "of": a unit, vehicle or
group id to its addons, lower-case, a group holding only its #Class members),
and the mod each addon comes from ("modOf"), which the plan uses to split
optional entries by the mods they need.

Parameters:
    _faction - HASHMAP - the export's snapshot

Returns:
    HASHMAP - addons (sorted ARRAY), counts (HASHMAP addon to class count),
    mods (ARRAY of [name, workshop id or "", official BOOL, class count]),
    warnings (ARRAY of [key, args]), of (HASHMAP id to ARRAY of lower-case
    addons), modOf (HASHMAP lower-case addon to mod name)

Examples:
    (begin example)
    private _deps = [_snapshot] call ALiVE_fnc_fsGenDeps;
    (end)

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_faction", createHashMap, [createHashMap]]];

private _units = _faction getOrDefault ["units", createHashMap];
private _vehicles = _faction getOrDefault ["vehicles", createHashMap];
private _counts = createHashMap;
private _warnings = [];
// lower-case class to the addon it gave ("" for none), so an entry that names a class again still records it
private _seen = createHashMap;
// the addons of the entry being walked (lower-case keys), and every entry's when done
private _cur = createHashMap;
private _of = createHashMap;

private _ownAddon = {
    private _l = toLower _this;
    (_l select [0, 6]) isEqualTo "alive_" && {!((_l select [0, 9]) isEqualTo "alive_fs_")}
};
private _take = {
    params ["_cfg", "_class", "_isVehicle"];
    private _addon = (configSourceAddonList _cfg) param [0, ""];
    if (_addon isEqualTo "" && {_isVehicle}) then { _addon = (unitAddons _class) param [0, ""] };
    if (_addon isEqualTo "" || {_addon call _ownAddon}) exitWith { "" };
    _counts set [_addon, (_counts getOrDefault [_addon, 0]) + 1];
    _cur set [toLower _addon, true];
    _addon
};
// a class already walked: its addon counts for this entry too
private _again = {
    private _a = _seen get (toLower _this);
    if !(_a isEqualTo "") then { _cur set [toLower _a, true] };
};
// a gear class: the first root that has it
private _gear = {
    params ["_class", "_who"];
    if (_class isEqualTo "") exitWith {};
    if ((toLower _class) in _seen) exitWith { _class call _again };
    _seen set [toLower _class, ""];
    private _root = ["CfgWeapons", "CfgMagazines", "CfgVehicles", "CfgGlasses"] select { isClass (configFile >> _x >> _class) } param [0, ""];
    if (_root isEqualTo "") exitWith { _warnings pushBack ["W_GEAR_MISSING", [_who, _class]] };
    _seen set [toLower _class, [configFile >> _root >> _class, _class, _root == "CfgVehicles"] call _take];
};
private _strings = {
    params ["_v", "_who"];
    if (_v isEqualType "") exitWith { [_v, _who] call _gear };
    if (_v isEqualType []) then { { [_x, _who] call _strings } forEach _v };
};
// bases, crews, gunners and #Class members; a missing one is the plan's business, not a gear warning
private _vehicleClass = {
    params ["_class"];
    if (_class isEqualTo "") exitWith {};
    if ((toLower _class) in _seen) exitWith { _class call _again };
    _seen set [toLower _class, ""];
    private _cfg = configFile >> "CfgVehicles" >> _class;
    if (isClass _cfg) then { _seen set [toLower _class, [_cfg, _class, true] call _take] };
};

{
    _cur = createHashMap;
    private _who = _y getOrDefault ["name", _x];
    [_y getOrDefault ["base", ""]] call _vehicleClass;
    [_y getOrDefault ["loadout", []], _who] call _strings;
    private _ins = (_y getOrDefault ["identity", createHashMap]) getOrDefault ["insignia", ""];
    if !(_ins isEqualTo "") then {
        if ((toLower _ins) in _seen) then { _ins call _again } else {
            _seen set [toLower _ins, ""];
            private _cfg = configFile >> "CfgUnitInsignia" >> _ins;
            if (isClass _cfg) then { _seen set [toLower _ins, [_cfg, _ins, false] call _take] } else { _warnings pushBack ["W_GEAR_MISSING", [_who, _ins]] };
        };
    };
    // his gear pools' items
    {
        { [_x getOrDefault ["class", ""], _who] call _gear; [_x getOrDefault ["weapon", []], _who] call _strings } forEach (((_faction getOrDefault ["pools", createHashMap]) getOrDefault [_x, createHashMap]) getOrDefault ["entries", []]);
    } forEach (_y getOrDefault ["pools", []]);
    _of set [_x, keys _cur];
} forEach _units;
{
    _cur = createHashMap;
    [_y getOrDefault ["base", ""]] call _vehicleClass;
    [_y getOrDefault ["crewClass", ""]] call _vehicleClass;
    { [_x getOrDefault ["gunnerClass", ""]] call _vehicleClass } forEach (_y getOrDefault ["turrets", []]);
    { if !(_x isEqualTo "") then { [_x, _y getOrDefault ["name", ""]] call _gear } } forEach (_y getOrDefault ["pylons", []]);
    if ((_y getOrDefault ["cargoMode", 0]) == 2) then {
        private _who = _y getOrDefault ["name", _x];
        { [_x getOrDefault ["class", ""], _who] call _gear } forEach (_y getOrDefault ["cargo", []]);
    };
    _of set [_x, keys _cur];
} forEach _vehicles;
{
    _cur = createHashMap;
    {
        private _ref = _x getOrDefault ["ref", ""];
        if ((_ref select [0, 1]) == "#") then { [_ref select [1]] call _vehicleClass };
    } forEach (_y getOrDefault ["members", []]);
    _of set [_x, keys _cur];
} forEach (_faction getOrDefault ["groups", createHashMap]);
_cur = createHashMap;
// supply crates: their boxes and what is in them. The classes named only in the ALiVE lists are not
// needed: ALiVE leaves out any that is not loaded, so a list may name an ALiVE crate without requiring ALiVE
if (((_faction getOrDefault ["alive", createHashMap]) getOrDefault ["hook", true]) && {(_faction getOrDefault ["side", 1]) != 3}) then {
    {
        private _who = _x getOrDefault ["name", ""];
        [_x getOrDefault ["base", ""]] call _vehicleClass;
        { [_x getOrDefault ["class", ""], _who] call _gear } forEach (_x getOrDefault ["cargo", []]);
    } forEach (([_faction] call ALiVE_fnc_fsAliveCrates) select 0);
};

private _addons = keys _counts;
_addons pushBackUnique "cba_xeh";
_addons sort true;

// the mod each addon comes from, for the README and W_DEP
// getLoadedModsInfo rows: [name, modDir, isDefault, isOfficial, origin, hash, hashShort, itemID]
private _modsInfo = getLoadedModsInfo;
private _mods = createHashMap;
private _modOf = createHashMap;
{
    if !(_x isEqualTo "cba_xeh") then {
        private _addon = _x;
        private _dir = toLower (configSourceMod (configFile >> "CfgPatches" >> _addon));
        private _row = (_modsInfo select { (toLower (_x select 1)) == _dir }) param [0, []];
        private _name = _row param [0, _dir];
        private _entry = _mods getOrDefault [_name, [_name, "", true, 0]];
        if (count _row > 0) then {
            private _item = _row param [7, ""];
            if (_item isEqualType 0) then { _item = if (_item > 0) then { _item toFixed 0 } else { "" } };
            _entry set [1, _item];
            _entry set [2, (_row param [2, false]) || {_row param [3, false]}];
        };
        _entry set [3, (_entry select 3) + (_counts getOrDefault [_addon, 0])];
        _mods set [_name, _entry];
        _modOf set [toLower _addon, _name];
    };
} forEach _addons;

createHashMapFromArray [
    ["addons", _addons],
    ["counts", _counts],
    ["mods", values _mods],
    ["warnings", _warnings],
    ["of", _of],
    ["modOf", _modOf]
]
