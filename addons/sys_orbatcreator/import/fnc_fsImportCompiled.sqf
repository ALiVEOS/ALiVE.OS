#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsImportCompiled);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsImportCompiled

Description:
A faction built by ALiVE's Faction Compiler in this mission to an "incoming"
studio faction, the same shape ALiVE_fnc_fsImportFaction gives, so the picker's
New and Merge take it. The compiled data (ALIVE_compiledFactions) exists only
where the compiler ran, on the server: single player or the host of a listen
server. Nothing is created.
    - faction: name from displayName, side from its text, tag from the faction
      id (first 8 letters and digits, to be confirmed by the player), class
      empty, flag and icon from the proxy faction when usable, meta.source
      "compiled:<id>"; ALiVE settings at their defaults (declared, automatic);
    - men: one unit per class and kit (ALiVE_fnc_fsImportMan, then the captured
      loadout). Men with the same kit, ammunition counts aside, are one unit;
    - vehicles: one per class (ALiVE_fnc_fsImportVehicle); its driver, gunner
      and commander from the first group that has it (the captured seating),
      note N_CMP_CREW when another group crews it with other men;
    - groups: one per compiled group with its category and name; the vehicles
      first, then the men who are not their driver, gunner or commander (a
      vehicle brings its own crew), with their ranks.

Parameters:
    _factionId - STRING - a key of ALIVE_compiledFactions

Returns:
    ARRAY - [faction, notes]; the faction is empty when the id is not compiled here

Examples:
    (begin example)
    (["MY_FACTION"] call ALiVE_fnc_fsImportCompiled) params ["_incoming", "_notes"];
    (end)

See Also:
    ALiVE_fnc_fsImportFaction, ALiVE_fnc_fsStudioFactionPicker

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_factionId", "", [""]]];

private _notes = [];
if (isNil "ALIVE_compiledFactions" || {isNil "ALIVE_fnc_hashGet"}) exitWith { [createHashMap, [format ["%1 was not compiled in this mission.", _factionId]]] };
private _data = [ALIVE_compiledFactions, _factionId] call ALIVE_fnc_hashGet;
if (isNil "_data") exitWith { [createHashMap, [format ["%1 was not compiled in this mission.", _factionId]]] };
private _get = { params ["_h", "_k", "_d"]; private _v = [_h, _k] call ALIVE_fnc_hashGet; if (isNil "_v") then { _d } else { _v } };
private _compiled = [_data, "compiledGroups", []] call _get;
if !(_compiled isEqualType [] && {count _compiled >= 3}) exitWith { [createHashMap, [format ["%1 has no groups to import.", _factionId]]] };

private _ok = { ([_this select 0, _this select 1] call ALiVE_fnc_fsDataCheckValue) isEqualTo "" };
private _sideText = toUpper ([_data, "side", "WEST"] call _get);
private _side = switch (_sideText) do { case "EAST": { 0 }; case "WEST": { 1 }; case "CIV": { 3 }; default { 2 } };
private _name = [_data, "displayName", _factionId] call _get;
if !([_name, "text60"] call _ok) then { _name = _factionId select [0, 60] };
private _tag = toUpper ((((toArray _factionId) select { (_x >= 48 && {_x <= 57}) || {(_x >= 65 && {_x <= 90})} || {(_x >= 97 && {_x <= 122})} }) apply { toString [_x] }) joinString "");
// a tag starts with a letter
while { count _tag > 0 && {!((_tag select [0, 1]) regexMatch "[A-Z]")} } do { _tag = _tag select [1] };
_tag = _tag select [0, 8];
if !([_tag, "tag"] call _ok) then { _tag = "" };

private _incoming = [_name, _tag, _side] call ALiVE_fnc_fsDataNew;
_incoming set ["class", ""];
_incoming set ["modName", ""];
private _proxy = ([_data, "proxyFaction", ""] call _get) call ALiVE_fnc_configGetFactionClass;
if (isClass _proxy) then {
    private _flag = getText (_proxy >> "flag");
    if ([_flag, "path"] call _ok && {!(_flag isEqualTo "")}) then { _incoming set ["flag", _flag] };
    private _icon = getText (_proxy >> "icon");
    if ([_icon, "path"] call _ok && {!(_icon isEqualTo "")}) then { _incoming set ["icon", _icon] };
};
private _source = toString ((toArray ("compiled:" + _factionId)) select [0, 60]);
(_incoming get "meta") set ["source", [_source, "compiled"] select !([_source, "text60"] call _ok)];
_notes pushBack format ["%1 came from the Faction Compiler; check the tag %2.", _factionId, _tag];

// a kit for comparing men: loaded and carried magazines without their round counts, and a numbered radio as its base
private _kitKey = {
    params ["_class", "_l"];
    private _w = { if (_this isEqualType [] && {count _this > 0}) then { _this apply { if (_x isEqualType [] && {count _x == 2} && {(_x select 0) isEqualType ""}) then { _x select 0 } else { _x } } } else { _this } };
    private _c = { if (_this isEqualType [] && {count _this > 1}) then { [_this select 0, (_this select 1) apply { if (count _x > 2) then { [_x select 0, _x select 1] } else { _x } }] } else { _this } };
    private _items = (_l param [9, []]) apply { if (_x isEqualType "") then { _x regexReplace ["_[0-9]+$", ""] } else { _x } };
    toLower str [_class, (_l param [0, []]) call _w, (_l param [1, []]) call _w, (_l param [2, []]) call _w, (_l param [3, []]) call _c, (_l param [4, []]) call _c, (_l param [5, []]) call _c, _l param [6, ""], _l param [7, ""], _l param [8, []], _items]
};

// 1. men, one per kit
private _kitToId = createHashMap;
private _classToId = createHashMap;
private _named = createHashMap;
private _groupKeys = (_compiled select 1);
{
    private _g = [_compiled, _x] call ALIVE_fnc_hashGet;
    {
        private _class = [_x, "class", ""] call _get;
        private _l = [_x, "loadout", []] call _get;
        private _key = [_class, _l] call _kitKey;
        if (!(_key in _kitToId) && {isClass (configFile >> "CfgVehicles" >> _class)}) then {
            private _entry = [_class, _incoming, _notes] call ALiVE_fnc_fsImportMan;
            if ([_l, "loadout"] call _ok) then { _entry set ["loadout", +_l] } else { _notes pushBack format ["%1: the captured kit was not usable, the class's own is used.", _class] };
            private _n = (_named getOrDefault [_class, 0]) + 1;
            _named set [_class, _n];
            if (_n > 1) then { _entry set ["name", ((_entry getOrDefault ["name", _class]) select [0, 55]) + " " + str _n] };
            private _id = ["add", [_entry], _incoming] call ALiVE_fnc_fsDataUnit;
            if (_id isEqualTo "") then { _notes pushBack format ["%1: the faction is full, so it was left out.", _class] } else {
                _kitToId set [_key, _id];
                if !((toLower _class) in _classToId) then { _classToId set [toLower _class, _id] };
            };
        };
    } forEach ([_g, "units", []] call _get);
} forEach _groupKeys;
private _manId = { params ["_u"]; _kitToId getOrDefault [[[_u, "class", ""] call _get, [_u, "loadout", []] call _get] call _kitKey, ""] };

// 2. vehicles, one per class, crewed from the first group that has it
private _vehToId = createHashMap;
private _crewOf = createHashMap;
{
    private _g = [_compiled, _x] call ALIVE_fnc_hashGet;
    private _men = [_g, "units", []] call _get;
    {
        private _class = [_x, "class", ""] call _get;
        private _a = [_x, "assignment", []] call _get;
        private _seat = { params ["_i"]; private _idx = (_a param [_i, []]) param [0, -1]; if (_idx < 0) then { "" } else { [_men param [_idx, []]] call _manId } };
        private _crew = [0 call _seat, 1 call _seat, 2 call _seat];
        if (!((toLower _class) in _vehToId) && {isClass (configFile >> "CfgVehicles" >> _class)}) then {
            private _entry = [_class, _classToId, _incoming, _notes] call ALiVE_fnc_fsImportVehicle;
            _crew params ["_driver", "_gunner", "_commander"];
            private _main = [_driver, _gunner, _commander] select { !(_x isEqualTo "") } param [0, ""];
            if !(_main isEqualTo "") then { _entry set ["crewUnit", _main]; _entry set ["crewClass", ""] };
            {
                // cfg is the turret class names joined with /; a nested turret sits in its parent's Turrets
                private _cfg = configFile >> "CfgVehicles" >> _class;
                { _cfg = _cfg >> "Turrets" >> _x } forEach ((_x getOrDefault ["cfg", ""]) splitString "/");
                private _who = switch (true) do {
                    case (getNumber (_cfg >> "primaryGunner") == 1): { _gunner };
                    case (getNumber (_cfg >> "primaryObserver") == 1): { _commander };
                    default { "" };
                };
                if !(_who isEqualTo "") then { _x set ["gunnerUnit", _who]; _x set ["gunnerClass", ""] };
            } forEach (_entry getOrDefault ["turrets", []]);
            private _id = ["add", [_entry], _incoming] call ALiVE_fnc_fsDataVehicle;
            if (_id isEqualTo "") then { _notes pushBack format ["%1: the faction is full, so it was left out.", _class] } else {
                _vehToId set [toLower _class, _id];
                _crewOf set [toLower _class, _crew];
            };
        } else {
            if (((toLower _class) in _crewOf) && {!((_crewOf get (toLower _class)) isEqualTo _crew)} && {!(_crew isEqualTo ["", "", ""])}) then {
                _notes pushBack format [localize "STR_ALIVE_FS_N_CMP_CREW", _class];
                _crewOf set [toLower _class, _crew];
            };
        };
    } forEach ([_g, "vehicles", []] call _get);
} forEach _groupKeys;

// 3. groups: vehicles first, then the men who do not crew them
{
    private _g = [_compiled, _x] call ALIVE_fnc_hashGet;
    private _men = [_g, "units", []] call _get;
    private _crewIdx = [];
    private _members = [];
    {
        private _vid = _vehToId getOrDefault [toLower ([_x, "class", ""] call _get), ""];
        if !(_vid isEqualTo "") then { _members pushBack createHashMapFromArray [["ref", _vid], ["rank", "SERGEANT"]] };
        private _a = [_x, "assignment", []] call _get;
        { _crewIdx append (_a param [_x, []]) } forEach [0, 1, 2, 3];
    } forEach ([_g, "vehicles", []] call _get);
    {
        private _id = [_x] call _manId;
        if (!(_forEachIndex in _crewIdx) && {!(_id isEqualTo "")}) then {
            private _rank = toUpper ([_x, "rank", "PRIVATE"] call _get);
            if !([_rank, "rank"] call _ok) then { _rank = "PRIVATE" };
            _members pushBack createHashMapFromArray [["ref", _id], ["rank", _rank]];
        };
    } forEach _men;
    if (count _members > FS_MAX_MEMBERS) then { _notes pushBack format ["%1: only the first %2 members were kept.", _x, FS_MAX_MEMBERS]; _members resize FS_MAX_MEMBERS };
    if (count _members > 0) then {
        private _cat = [_g, "category", "Infantry"] call _get;
        if !(_cat in FS_ALIVE_CATEGORIES) then { _cat = "Infantry" };
        private _gname = [_g, "name", _cat] call _get;
        if !([_gname, "text60"] call _ok) then { _gname = _cat };
        private _gid = ["add", [createHashMapFromArray [["name", _gname], ["category", _cat], ["members", _members]]], _incoming] call ALiVE_fnc_fsDataGroup;
        if (_gid isEqualTo "") then { _notes pushBack format ["%1: the faction is full, so a group was left out.", _factionId] };
    };
} forEach _groupKeys;

// override mode compiles only the categories it replaces
private _mapping = if (isNil "ALIVE_factionCustomMappings") then { nil } else { [ALIVE_factionCustomMappings, _factionId] call ALIVE_fnc_hashGet };
if (!isNil "_mapping" && {!(([_mapping, "ConfigFactionName", _factionId] call _get) isEqualTo ([_data, "proxyFaction", ""] call _get))}) then {
    _notes pushBack format [localize "STR_ALIVE_FS_N_CMP_PARTIAL", _factionId];
};

[_incoming, _notes]
