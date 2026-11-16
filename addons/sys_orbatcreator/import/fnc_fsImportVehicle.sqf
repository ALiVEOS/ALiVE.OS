#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsImportVehicle);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsImportVehicle

Description:
A vehicle class to a studio vehicle entry. Nothing is created: seats are read
from config only.

    - base and class as ALiVE_fnc_fsImportBase;
    - crew: getText crew. A class imported in this run gives crewUnit (its id), so
      the vehicle follows its own faction's crewman; else a crew that differs from
      the base's gives crewClass; else both stay empty;
    - turrets: configProperties [Turrets, isClass, true], which includes inherited
      turrets, and each turret's own Turrets the same way, at most three levels and
      16 seats. Per seat: cfg (class names joined with /), name (gunnerName) and
      gunnerType handled like crew. path stays [] (check V14 failed: the
      enumeration order does not match allTurrets), so a seat is found by cfg;
    - texture: ALiVE_orbatCreator_texture, else the one name in textureList[] of a
      studio export, else "";
    - textures: hiddenSelectionsTextures of an owned class whose list differs from
      its base's, else [].
Every value passes the rules of ALiVE_fnc_fsDataCheckValue first; each change is
a note naming the class.

Parameters:
    _class     - STRING - the class
    _classToId - HASHMAP - lower class name to unit id, for crew made in this run
    _faction   - HASHMAP - the faction the entry is for (its categories); optional
    _notes     - ARRAY - notes are appended here; optional

Returns:
    HASHMAP - a vehicle entry, ready for ALiVE_fnc_fsDataVehicle "add"

Examples:
    (begin example)
    private _entry = ["B_MRAP_01_hmg_F", _classToId, _faction, _notes] call ALiVE_fnc_fsImportVehicle;
    (end)

See Also:
    ALiVE_fnc_fsImportFaction, ALiVE_fnc_fsImportBase, ALiVE_fnc_fsDataVehicle

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_class", "", [""]], ["_classToId", createHashMap, [createHashMap]], ["_faction", createHashMap, [createHashMap]], ["_notes", [], [[]]]];

private _cfg = configFile >> "CfgVehicles" >> _class;
private _ok = { ([_this select 0, _this select 1] call ALiVE_fnc_fsDataCheckValue) isEqualTo "" };
private _text60 = {
    params ["_t", "_fallback"];
    private _cut = toString (((toArray _t) apply { if (_x < 32) then { 32 } else { _x } }) select [0, 60]);
    if ([_cut, "text60"] call _ok) then { _cut } else { _fallback }
};
private _gear = {
    params ["_v"];
    if ([_v, "gear"] call _ok) then { _v } else {
        _notes pushBack format ["%1: %2 is not a usable class name and was left out.", _class, _v];
        ""
    }
};

([_class] call ALiVE_fnc_fsImportBase) params ["_base", "_owned"];
private _baseCfg = configFile >> "CfgVehicles" >> _base;

// Crew, or a gunner: an imported unit, else a class that differs from the base.
private _who = {
    params ["_type", "_baseType"];
    private _id = _classToId getOrDefault [toLower _type, ""];
    if !(_id isEqualTo "") exitWith { [_id, ""] };
    if (_type isEqualTo "" || {_type == _baseType}) exitWith { ["", ""] };
    ["", [_type] call _gear]
};
([getText (_cfg >> "crew"), getText (_baseCfg >> "crew")] call _who) params ["_crewUnit", "_crewClass"];

// Seats.
private _turrets = [];
private _walk = {
    params ["_turretsCfg", "_prefix", "_depth"];
    {
        private _name = configName _x;
        private _path = if (_prefix isEqualTo "") then { _name } else { _prefix + "/" + _name };
        if ((count _turrets) < 16 && {[_path, "cfgPath"] call _ok}) then {
            private _baseTurret = _baseCfg;
            { _baseTurret = _baseTurret >> "Turrets" >> _x } forEach (_path splitString "/");
            ([getText (_x >> "gunnerType"), getText (_baseTurret >> "gunnerType")] call _who) params ["_gunnerUnit", "_gunnerClass"];
            _turrets pushBack createHashMapFromArray [
                ["path", []],
                ["cfg", _path],
                ["name", [getText (_x >> "gunnerName"), ""] call _text60],
                ["gunnerUnit", _gunnerUnit],
                ["gunnerClass", _gunnerClass]
            ];
            if (_depth < 3) then { [_x >> "Turrets", _path, _depth + 1] call _walk };
        };
    } forEach configProperties [_turretsCfg, "isClass _x", true];
};
[_cfg >> "Turrets", "", 1] call _walk;
if ((count (configProperties [_cfg >> "Turrets", "isClass _x", true])) > 16) then {
    _notes pushBack format ["%1: only the first 16 seats were read.", _class];
};

// Paint.
private _texture = getText (_cfg >> "ALiVE_orbatCreator_texture");
if (_texture isEqualTo "" && {_owned isEqualTo "studio"}) then {
    private _list = getArray (_cfg >> "textureList");
    if ((count _list) == 2 && {(_list select 0) isEqualType ""}) then { _texture = _list select 0 };
};
private _textures = [];
if !(_owned isEqualTo "") then {
    private _own = getArray (_cfg >> "hiddenSelectionsTextures");
    if !(_own isEqualTo (getArray (_baseCfg >> "hiddenSelectionsTextures"))) then {
        {
            if (_x isEqualType "" && {[_x, "path"] call _ok}) then { _textures pushBack _x } else {
                _notes pushBack format ["%1: a texture path was not usable and was left out.", _class];
            };
        } forEach (_own select [0, 16]);
    };
};

// Category: the one named like the Eden subcategory of the class.
private _category = "";
private _subName = [getText (configFile >> "CfgEditorSubcategories" >> getText (_cfg >> "editorSubcategory") >> "displayName"), ""] call _text60;
if !(_subName isEqualTo "") then {
    {
        if ((_y getOrDefault ["name", ""]) == _subName) exitWith { _category = _x };
    } forEach (_faction getOrDefault ["categories", createHashMap]);
    if (_category isEqualTo "" && {count _faction > 0}) then {
        _category = ["add", [_subName], _faction] call ALiVE_fnc_fsDataCategory;
    };
};

private _keepClass = !(_owned isEqualTo "") && {[_class, "class"] call _ok};

createHashMapFromArray [
    ["id", ""],
    ["name", [getText (_cfg >> "displayName"), _class select [0, 60]] call _text60],
    ["class", ["", _class] select _keepClass],
    ["classAuto", !_keepClass],
    ["base", _base],
    ["src", [_class] call _gear],
    ["category", _category],
    ["crewUnit", _crewUnit],
    ["crewClass", _crewClass],
    ["turrets", _turrets],
    ["texture", [_texture] call _gear],
    ["textures", _textures]
]
