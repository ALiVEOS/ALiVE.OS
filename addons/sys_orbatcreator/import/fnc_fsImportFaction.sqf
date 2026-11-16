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
       (ALiVE_fnc_fsImportVehicle), so vehicles can point at imported crew;
    4. ALiVE_fnc_fsImportGroups;
    5. meta.source = "config:<faction>".
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
{
    _x params ["_rowClass", "", "", "", "", "_kind"];
    if (_kind == 0) then {
        private _entry = [_rowClass, _incoming, _notes] call ALiVE_fnc_fsImportMan;
        private _id = ["add", [_entry], _incoming] call ALiVE_fnc_fsDataUnit;
        if (_id isEqualTo "") then { _notes pushBack format ["%1: the faction is full, so it was left out.", _rowClass] } else { _classToId set [toLower _rowClass, _id] };
    };
} forEach _mine;
{
    _x params ["_rowClass", "", "", "", "", "_kind"];
    if (_kind != 0) then {
        private _entry = [_rowClass, _classToId, _incoming, _notes] call ALiVE_fnc_fsImportVehicle;
        private _id = ["add", [_entry], _incoming] call ALiVE_fnc_fsDataVehicle;
        if (_id isEqualTo "") then { _notes pushBack format ["%1: the faction is full, so it was left out.", _rowClass] } else { _classToId set [toLower _rowClass, _id] };
    };
} forEach _mine;

// 4. Groups.
{
    private _id = ["add", [_x], _incoming] call ALiVE_fnc_fsDataGroup;
    if (_id isEqualTo "") then { _notes pushBack format ["%1: the faction is full, so a group was left out.", _factionClass] };
} forEach ([_factionClass, _classToId, _ownedFaction, _notes] call ALiVE_fnc_fsImportGroups);

[_incoming, _notes]
