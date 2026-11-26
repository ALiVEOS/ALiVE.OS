#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsImportFaction);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsImportFaction

Description:
A config faction to an "incoming" studio faction. No object is created anywhere.
ALiVE static data must be loaded first for the group mappings (the studio start
does it; a probe spawns ALiVE_fnc_staticDataHandler itself).

    1. faction fields from ALiVE_fnc_configGetFactionClass: name, side, flag, icon,
       priority, each through the rules of ALiVE_fnc_fsDataCheckValue;
    2. owned detection:
       - studio export: ALiVE_FS_tag is set on the faction class; tag and class are
         taken from it, meta.legacyPatches from CfgPatches ALiVE_FS_<TAG>;
       - old ORBAT export: a unit of the faction has ALiVE_orbatCreator_owned 1;
         class is kept, tag is the class up to its first _ (upper-cased, cut to 8,
         to be confirmed by the player), meta.legacyPatches is every CfgPatches
         name configSourceAddonList gives for the owned classes (at most 8);
       - otherwise tag and class are left empty for the caller;
    3. men first (ALiVE_fnc_fsImportMan), then the other classes
       (ALiVE_fnc_fsImportVehicle), so vehicles can point at imported crew; in
       a studio export, a class from one of its optional parts
       (ALiVE_FS_<TAG>_O_..., the first of configSourceAddonList) is ticked
       Optional. An optional part whose mods are not loaded here is not in the
       config, so its entries are not imported (load the export's data file for
       them);
    4. ALiVE_fnc_fsImportGroups;
    5. meta.source = "config:<faction>";
    6. for a studio export, its CfgALiVEFactions block and supply crates: rarity,
       redirects, outside supplies and containers, and the crates and lists that
       differ from what the studio works out (the others stay automatic).
The class index is built first when it does not exist yet.

Parameters:
    _factionClass - STRING - the CfgFactionClasses class

Returns:
    ARRAY - [faction, notes]: the incoming faction (HASHMAP) and the notes (ARRAY of
            STRING); the faction is empty when the class is not a faction

Examples:
    (begin example)
    (["BLU_F"] call ALiVE_fnc_fsImportFaction) params ["_incoming", "_notes"];
    (end)

See Also:
    ALiVE_fnc_fsImportMerge, ALiVE_fnc_fsImportMan, ALiVE_fnc_fsImportVehicle, ALiVE_fnc_fsImportGroups

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_factionClass", "", [""]]];

private _notes = [];
private _ok = { ([_this select 0, _this select 1] call ALiVE_fnc_fsDataCheckValue) isEqualTo "" };

private _index = uiNamespace getVariable "ALiVE_FS_index";
if (isNil "_index") then { _index = call ALiVE_fnc_fsIndexBuild };
private _rows = _index getOrDefault ["rows", []];
private _mine = ((_index getOrDefault ["byFaction", createHashMap]) getOrDefault [toLower _factionClass, []]) apply { _rows select _x };

private _cfg = _factionClass call ALiVE_fnc_configGetFactionClass;
if (!isClass _cfg && {(count _mine) == 0}) exitWith { [createHashMap, [format ["%1 is not a faction.", _factionClass]]] };

// 1. Faction fields.
private _side = getNumber (_cfg >> "side");
if ((count _mine) > 0 && {!isClass _cfg}) then { _side = (_mine select 0) select 4 };
_side = (_side max 0) min 3;
private _name = getText (_cfg >> "displayName");
if (_name isEqualTo "") then { _name = _factionClass };

// 2. Owned detection.
private _tag = "";
private _class = "";
private _legacy = [];
private _ownedFaction = false;
private _studioTag = getText (_cfg >> "ALiVE_FS_tag");
if !(_studioTag isEqualTo "") then {
    _ownedFaction = true;
    _tag = _studioTag;
    _class = configName _cfg;
    _legacy = getArray (configFile >> "CfgPatches" >> ("ALiVE_FS_" + _tag) >> "ALiVE_FS_legacyPatches");
} else {
    private _ownedRows = _mine select { getNumber (configFile >> "CfgVehicles" >> (_x select 0) >> "ALiVE_orbatCreator_owned") == 1 };
    if ((count _ownedRows) > 0) then {
        _ownedFaction = true;
        _class = _factionClass;
        _tag = toUpper (((_factionClass splitString "_") param [0, ""]) select [0, 8]);
        {
            { _legacy pushBackUnique _x } forEach (configSourceAddonList (configFile >> "CfgVehicles" >> (_x select 0)));
        } forEach _ownedRows;
        _notes pushBack format ["%1 was exported by the classic ORBAT Creator; check the tag %2.", _factionClass, _tag];
    };
};
if !([_tag, "tag"] call _ok) then { _tag = "" };
_legacy = (_legacy select { _x isEqualType "" && {[_x, "class"] call _ok} }) select [0, 8];

private _incoming = [_name, _tag, _side] call ALiVE_fnc_fsDataNew;
_incoming set ["class", [_class, ""] select !([_class, "class?"] call _ok)];
if !(_ownedFaction) then { _incoming set ["modName", ""] };
private _flag = getText (_cfg >> "flag");
if ([_flag, "path"] call _ok) then { _incoming set ["flag", _flag] } else {
    _notes pushBack format ["%1: the flag path was not usable, the default flag is used.", _factionClass];
};
private _icon = getText (_cfg >> "icon");
if ([_icon, "path"] call _ok) then { _incoming set ["icon", _icon] } else {
    _notes pushBack format ["%1: the icon path was not usable and was left out.", _factionClass];
};
_incoming set ["priority", ((getNumber (_cfg >> "priority")) max 0) min 100];
private _meta = _incoming get "meta";
_meta set ["legacyPatches", _legacy];
private _source = toString ((toArray ("config:" + _factionClass)) select [0, 60]);
_meta set ["source", [_source, "config"] select !([_source, "text60"] call _ok)];

// 3. Men, then everything else.
private _classToId = createHashMap;
private _optPrefix = if (_studioTag isEqualTo "") then { "" } else { toLower ("ALiVE_FS_" + _studioTag + "_O_") };
private _fromOptional = {
    !(_optPrefix isEqualTo "") && {((toLower ((configSourceAddonList (configFile >> "CfgVehicles" >> _this)) param [0, ""])) select [0, count _optPrefix]) isEqualTo _optPrefix}
};
private _optCount = 0;
{
    _x params ["_rowClass", "", "", "", "", "_kind"];
    if (_kind == 0) then {
        private _entry = [_rowClass, _incoming, _notes] call ALiVE_fnc_fsImportMan;
        if (_rowClass call _fromOptional) then { _entry set ["optional", true]; _optCount = _optCount + 1 };
        private _id = ["add", [_entry], _incoming] call ALiVE_fnc_fsDataUnit;
        if (_id isEqualTo "") then { _notes pushBack format ["%1: the faction is full, so it was left out.", _rowClass] } else { _classToId set [toLower _rowClass, _id] };
    };
} forEach _mine;
{
    _x params ["_rowClass", "", "", "", "", "_kind"];
    if (_kind != 0) then {
        private _entry = [_rowClass, _classToId, _incoming, _notes] call ALiVE_fnc_fsImportVehicle;
        if (_rowClass call _fromOptional) then { _entry set ["optional", true]; _optCount = _optCount + 1 };
        private _id = ["add", [_entry], _incoming] call ALiVE_fnc_fsDataVehicle;
        if (_id isEqualTo "") then { _notes pushBack format ["%1: the faction is full, so it was left out.", _rowClass] } else { _classToId set [toLower _rowClass, _id] };
    };
} forEach _mine;

if (_optCount > 0) then { _notes pushBack format ["%1: %2 units and vehicles came from optional parts and are ticked Optional. An optional part whose mods are not loaded here was not imported; load the export's data file to keep its entries.", _factionClass, _optCount toFixed 0] };

// 4. Groups.
{
    private _id = ["add", [_x], _incoming] call ALiVE_fnc_fsDataGroup;
    if (_id isEqualTo "") then { _notes pushBack format ["%1: the faction is full, so a group was left out.", _factionClass] };
} forEach ([_factionClass, _classToId, _ownedFaction, _notes] call ALiVE_fnc_fsImportGroups);

// 5. A studio export's ALiVE block and crates, so exporting it again writes the same block. A list or the
// crates that match what the studio works out by itself stay automatic, so new gear and vehicles still reach them.
private _block = configFile >> "CfgALiVEFactions" >> _factionClass;
if (!(_studioTag isEqualTo "") && {isClass _block}) then {
    private _alive = _incoming get "alive";
    private _auto = +(_alive get "auto");
    _alive set ["rarity", getNumber (_block >> "rarity") == 1];
    // crates: the faction's boxes, with their four Transport classes
    private _crates = [];
    {
        private _c = _x;
        private _cargo = [];
        {
            _x params ["_root", "_key", "_kind"];
            {
                private _item = getText (_x >> _key);
                if !(_item isEqualTo "") then { _cargo pushBack createHashMapFromArray [["class", _item], ["kind", _kind], ["count", ((getNumber (_x >> "count")) max 1) min 999]] };
            } forEach ("true" configClasses (_c >> _root));
        } forEach [["TransportWeapons", "weapon", 0], ["TransportMagazines", "magazine", 1], ["TransportItems", "name", 2], ["TransportBackpacks", "backpack", 3]];
        _crates pushBack createHashMapFromArray [
            ["key", getText (_c >> "ALiVE_FS_crate")],
            ["name", (getText (_c >> "displayName")) select [0, 60]],
            ["class", configName _c],
            ["classAuto", true],
            ["base", configName (inheritsFrom _c)],
            ["cargo", _cargo select [0, FS_MAX_CRATE_ROWS]]
        ];
    } forEach ((format ["getText (_x >> 'ALiVE_FS_tag') == '%1' && {isText (_x >> 'ALiVE_FS_crate')}", _studioTag]) configClasses (configFile >> "CfgVehicles"));
    _crates = _crates select [0, FS_MAX_CRATES];
    // compared without order: the config keeps the four Transport classes apart and the boxes in config order
    private _plain = { params ["_list"]; private _out = _list apply {
        private _rows = (_x get "cargo") apply { [toLower (_x get "class"), _x get "kind", _x get "count"] };
        _rows sort true;
        [_x get "key", toLower (_x get "class"), toLower (_x get "base"), _rows]
    }; _out sort true; str _out };
    // the author's own crates (New crate) are kept whatever; only the others are compared with the worked-out ones
    private _custom = _crates select { (_x get "key") isEqualTo "custom" };
    private _others = _crates select { !((_x get "key") isEqualTo "custom") };
    private _view = +_incoming;
    (_view get "alive") set ["crates", []];
    if !(([_others] call _plain) isEqualTo ([([_view] call ALiVE_fnc_fsAliveCrates) select 0] call _plain)) then {
        _alive set ["crates", _crates];
        _auto = _auto - ["crates"];
    } else {
        _alive set ["crates", _custom];
    };
    _alive set ["auto", _auto];
    // the lists: one of the faction's own vehicles by its id, anything else as an outside class
    private _picks = [_incoming] call ALiVE_fnc_fsAlivePicks;
    private _crateClasses = _crates apply { toLower (_x get "class") };
    {
        private _name = _x;
        private _refs = (getArray (_block >> _name)) apply { private _id = _classToId getOrDefault [toLower _x, ""]; if (_id isEqualTo "") then { "#" + _x } else { _id } };
        if !((_refs apply { toLower _x }) isEqualTo ((_picks getOrDefault [_name, []]) apply { toLower _x })) then {
            _alive set [_name, _refs select { ([_x, "ref"] call ALiVE_fnc_fsDataCheckValue) isEqualTo "" }];
            _auto = _auto - [_name];
        };
    } forEach FS_ALIVE_REFLISTS;
    _alive set ["auto", _auto];
    _alive set ["suppliesExtra", ((getArray (_block >> "supplies")) select { !((toLower _x) in _crateClasses) && {([_x, "gear"] call _ok)} }) select [0, 32]];
    _alive set ["containers", ((getArray (_block >> "containers")) select { [_x, "gear"] call _ok }) select [0, 16]];
    // redirects: an empty ALiVE category drawn from another of the faction's categories
    _alive set ["redirects", (((configProperties [_block >> "GroupTypes", "isText _x", true]) select { (configName _x) in FS_ALIVE_CATEGORIES }) apply { createHashMapFromArray [["from", configName _x], ["to", getText _x]] }) select [0, 11]];
};

[_incoming, _notes]
