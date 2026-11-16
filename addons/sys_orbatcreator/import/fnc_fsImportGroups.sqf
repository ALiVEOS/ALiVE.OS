#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsImportGroups);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsImportGroups

Description:
The groups ALiVE itself would place for a faction, filed under ALiVE category
names, so the re-exported faction (which has no mapping of its own) places the
same way. Needs ALiVE static data (ALiVE_fnc_staticDataHandler) for the mappings;
without it the faction's own CfgGroups class is read, with a note.

Which mapping counts: the faction's entry in ALiVE_factionCustomMappings.
    - Inferred or CompiledFaction set: ignored. An inferred mapping points a
      faction with no groups at a stock faction's groups, which would hand the new
      faction somebody else's units. The faction's own CfgGroups class is read.
    - otherwise ALiVE_fnc_configGetFactionGroups, the path placement uses.
Category of each group, first rule that fits:
    1. the mapping's Groups lists name the group class: that list's ALiVE category;
    2. a GroupFactionTypes value equals the config category (case-insensitive):
       that ALiVE category (first in FS_ALIVE_CATEGORIES order wins);
    3. else the config category name is kept.
Each group class with at least one unit class: name, icon, rarity (rarityGroup,
0 becomes 0.5), category, src "<Side>/<Faction>/<Category>/<Group>". An owned
faction keeps the group's config class (classAuto false); any other gets an
automatic class later. Members in UnitN order: ref = the imported id or
"#<vehicle>", numbered ranks turned into names (#1062), pos = position[].

Parameters:
    _factionClass - STRING - the CfgFactionClasses class
    _classToId    - HASHMAP - lower class name to the id imported in this run
    _owned        - BOOL - the faction is an earlier export (keep group classes)
    _notes        - ARRAY - notes are appended here; optional

Returns:
    ARRAY - group entries (HASHMAP), ready for ALiVE_fnc_fsDataGroup "add"

Examples:
    (begin example)
    private _groups = ["BLU_F", _classToId, false, _notes] call ALiVE_fnc_fsImportGroups;
    (end)

See Also:
    ALiVE_fnc_fsImportFaction, ALiVE_fnc_configGetFactionGroups

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_factionClass", "", [""]], ["_classToId", createHashMap, [createHashMap]], ["_owned", false, [false]], ["_notes", [], [[]]]];

private _ok = { ([_this select 0, _this select 1] call ALiVE_fnc_fsDataCheckValue) isEqualTo "" };
private _text60 = {
    params ["_t", "_fallback"];
    private _cut = toString (((toArray _t) apply { if (_x < 32) then { 32 } else { _x } }) select [0, 60]);
    if ([_cut, "text60"] call _ok) then { _cut } else { _fallback }
};

// Mapping and root.
private _mapping = nil;
if (isNil "ALiVE_factionCustomMappings") then {
    _notes pushBack format ["%1: ALiVE static data is not loaded, so the own groups of the faction were read.", _factionClass];
} else {
    if (_factionClass in (ALiVE_factionCustomMappings select 1)) then {
        _mapping = [ALiVE_factionCustomMappings, _factionClass] call ALiVE_fnc_hashGet;
    };
};
private _skip = !isNil "_mapping" && {([_mapping, "Inferred", false] call ALiVE_fnc_hashGet) || {[_mapping, "CompiledFaction", false] call ALiVE_fnc_hashGet}};

private _root = configNull;
if (isNil "_mapping" || {_skip}) then {
    private _side = getNumber ((_factionClass call ALiVE_fnc_configGetFactionClass) >> "side");
    private _sideName = ["East", "West", "Indep", "Civilian"] select ((_side max 0) min 3);
    _root = missionConfigFile >> "CfgGroups" >> _sideName >> _factionClass;
    if !(isClass _root) then { _root = configFile >> "CfgGroups" >> _sideName >> _factionClass };
} else {
    _root = _factionClass call ALiVE_fnc_configGetFactionGroups;
};
if !(isClass _root) exitWith {
    _notes pushBack format ["%1: this faction has no groups of its own.", _factionClass];
    []
};

// Category maps: lower group class to ALiVE category, lower config category to ALiVE category.
private _byGroup = createHashMap;
private _byType = createHashMap;
if (!isNil "_mapping" && {!_skip}) then {
    private _lists = [_mapping, "Groups", []] call ALiVE_fnc_hashGet;
    if ([_lists] call ALiVE_fnc_isHash) then {
        {
            private _cat = _x;
            private _names = [_lists, _cat, []] call ALiVE_fnc_hashGet;
            if (_cat isEqualType "" && {_names isEqualType []}) then {
                { if (_x isEqualType "" && {!((toLower _x) in _byGroup)}) then { _byGroup set [toLower _x, _cat] } } forEach _names;
            };
        } forEach (_lists select 1);
    };
    private _types = [_mapping, "GroupFactionTypes", []] call ALiVE_fnc_hashGet;
    if ([_types] call ALiVE_fnc_isHash) then {
        {
            private _value = [_types, _x, ""] call ALiVE_fnc_hashGet;
            if (_value isEqualType "" && {!(_value isEqualTo "")} && {!((toLower _value) in _byType)}) then { _byType set [toLower _value, _x] };
        } forEach FS_ALIVE_CATEGORIES;
    };
};

private _hierarchy = configHierarchy _root;
private _sideText = if ((count _hierarchy) >= 2) then { configName (_hierarchy select ((count _hierarchy) - 2)) } else { "" };
private _ranks = ["PRIVATE", "CORPORAL", "SERGEANT", "LIEUTENANT", "CAPTAIN", "MAJOR", "COLONEL"];
private _out = [];

{
    private _catCfg = _x;
    private _catName = configName _catCfg;
    {
        private _grpCfg = _x;
        private _unitCfgs = configProperties [_grpCfg, "isClass _x", true];
        if ((count _unitCfgs) > 0 && {(count _out) < FS_MAX_GROUPS}) then {
            private _grpName = configName _grpCfg;
            private _category = _byGroup getOrDefault [toLower _grpName, _byType getOrDefault [toLower _catName, _catName]];
            if !([_category, "class"] call _ok) then { _category = "Infantry" };

            private _members = [];
            {
                private _vehicle = getText (_x >> "vehicle");
                private _id = _classToId getOrDefault [toLower _vehicle, ""];
                private _ref = if (_id isEqualTo "") then { "#" + _vehicle } else { _id };
                if !([_ref, "ref"] call _ok) then {
                    _notes pushBack format ["%1: member %2 is not a usable class name and was left out.", _grpName, _vehicle];
                } else {
                    private _rank = toUpper (getText (_x >> "rank"));
                    private _rankNo = ["0", "1", "2", "3", "4", "5", "6", "7"] find _rank;
                    if (_rankNo >= 0) then { _rank = _ranks select (_rankNo min 6) };
                    if !(_rank in _ranks) then { _rank = "PRIVATE" };
                    private _pos = getArray (_x >> "position");
                    if !([_pos, "pos"] call _ok) then { _pos = [] };
                    _members pushBack createHashMapFromArray [["ref", _ref], ["rank", _rank], ["pos", _pos]];
                };
            } forEach (_unitCfgs select [0, FS_MAX_MEMBERS]);

            private _rarity = getNumber (_grpCfg >> "rarityGroup");
            if (_rarity == 0) then { _rarity = 0.5 };
            private _icon = getText (_grpCfg >> "icon");
            if !([_icon, "path"] call _ok) then { _icon = "" };
            private _src = format ["%1/%2/%3/%4", _sideText, configName _root, _catName, _grpName];
            if !([_src, "cfgPath"] call _ok) then { _src = "" };
            private _keepClass = _owned && {[_grpName, "class"] call _ok};

            _out pushBack createHashMapFromArray [
                ["id", ""],
                ["name", [getText (_grpCfg >> "name"), _grpName select [0, 60]] call _text60],
                ["class", ["", _grpName] select _keepClass],
                ["classAuto", !_keepClass],
                ["src", _src],
                ["category", _category],
                ["icon", _icon],
                ["rarity", (_rarity max 0) min 1],
                ["members", _members]
            ];
        };
    } forEach ("isClass _x" configClasses _catCfg);
} forEach ("isClass _x" configClasses _root);

_out
