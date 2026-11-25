#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsImportMan);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsImportMan

Description:
A man class to a studio unit entry, with no spawn: getUnitLoadout of the class
name builds the loadout from its weapon, magazine, item and linked-item lists the
way the engine does for a new unit, in microseconds, with no init handler run and
nothing to clean up. A mod that dresses its units from an init script (random gear)
imports with its config gear.

    - base and class as ALiVE_fnc_fsImportBase: an owned class keeps its own name
      (classAuto false) so a re-export replaces it; any other class gets an
      automatic name later and src is the class;
    - an old ORBAT export reads its stored loadout (ALiVE_fnc_fsImportOldLoadout),
      a studio export its ALiVE_FS_loadout;
    - identity: types = identityTypes; insignia = ALiVE_FS_insignia, else
      ALiVE_orbatCreator_insignia; face and speaker from ALiVE_FS_face and
      ALiVE_FS_speaker when set (then fixed is true);
    - name = displayName; category = the faction category named like the Eden
      subcategory of the class, added when missing.
Every value passes the rules of ALiVE_fnc_fsDataCheckValue first: a name is cut
to 60 characters (else the class name is used), a class-valued string that fails
is left empty, a loadout that fails is replaced by an empty one; each change is a
note naming the class.

Parameters:
    _class   - STRING - the class
    _faction - HASHMAP - the faction the entry is for (its categories are used and
               may get one more); optional
    _notes   - ARRAY - notes are appended here; optional

Returns:
    HASHMAP - a unit entry, ready for ALiVE_fnc_fsDataUnit "add"

Examples:
    (begin example)
    private _entry = ["B_Soldier_F", _faction, _notes] call ALiVE_fnc_fsImportMan;
    ["add", [_entry], _faction] call ALiVE_fnc_fsDataUnit;
    (end)

See Also:
    ALiVE_fnc_fsImportFaction, ALiVE_fnc_fsImportBase, ALiVE_fnc_fsDataUnit

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_class", "", [""]], ["_faction", createHashMap, [createHashMap]], ["_notes", [], [[]]]];

private _cfg = configFile >> "CfgVehicles" >> _class;
private _ok = { ([_this select 0, _this select 1] call ALiVE_fnc_fsDataCheckValue) isEqualTo "" };

// Free text: control characters to spaces, cut to 60 characters, else the class name.
private _text60 = {
    params ["_t", "_fallback"];
    private _cut = toString (((toArray _t) apply { if (_x < 32) then { 32 } else { _x } }) select [0, 60]);
    if !(_cut isEqualTo _t) then { _notes pushBack format ["%1: name shortened.", _class] };
    if ([_cut, "text60"] call _ok) then { _cut } else { _fallback }
};
// A class-valued string that fails its rule is left empty.
private _gear = {
    params ["_v"];
    if ([_v, "gear"] call _ok) then { _v } else {
        _notes pushBack format ["%1: %2 is not a usable class name and was left out.", _class, _v];
        ""
    }
};

([_class] call ALiVE_fnc_fsImportBase) params ["_base", "_owned"];

// Loadout.
private _loadout = switch (_owned) do {
    case "orbat": { [_class, _notes] call ALiVE_fnc_fsImportOldLoadout };
    case "studio": {
        private _stored = getArray (_cfg >> "ALiVE_FS_loadout");
        if (([_stored] call ALiVE_fnc_fsDataLoadoutCheck) select 0) then { _stored } else { getUnitLoadout _class }
    };
    default { getUnitLoadout _class };
};
private _clean = {
    params ["_a"];
    _a apply {
        if (_x isEqualType "") then { [_x] call _gear } else { if (_x isEqualType []) then { [_x] call _clean } else { _x } }
    }
};
// A whole loadout that passes the check needs no cleaning: the check holds every string to the gear rule.
// Only a failing one is walked string by string, which is slow on a big faction.
if !(([_loadout] call ALiVE_fnc_fsDataLoadoutCheck) select 0) then {
    _loadout = [_loadout] call _clean;
    if !(([_loadout] call ALiVE_fnc_fsDataLoadoutCheck) select 0) then {
        _notes pushBack format ["%1: its loadout could not be read and was left empty.", _class];
        _loadout = [[], [], [], [], [], [], "", "", [], ["", "", "", "", "", ""]];
    };
};

// Identity.
private _types = (getArray (_cfg >> "identityTypes")) select { _x isEqualType "" && {[_x, "gear"] call _ok} };
private _insignia = getText (_cfg >> "ALiVE_FS_insignia");
if (_insignia isEqualTo "") then { _insignia = getText (_cfg >> "ALiVE_orbatCreator_insignia") };
private _face = [getText (_cfg >> "ALiVE_FS_face")] call _gear;
private _speaker = [getText (_cfg >> "ALiVE_FS_speaker")] call _gear;
private _identity = createHashMapFromArray [
    ["types", _types select [0, 32]],
    ["face", _face],
    ["speaker", _speaker],
    ["insignia", [_insignia] call _gear],
    ["pitch", 0],
    ["fixed", !(_face isEqualTo "") || {!(_speaker isEqualTo "")}]
];

// Engineer, EOD, Medic and UAV Hacker: 0 or 1 where the class differs from its base, else -1 (as the base).
private _differs = {
    private _own = getNumber (_cfg >> _this) > 0;
    [[0, 1] select _own, -1] select (_own isEqualTo (getNumber (configFile >> "CfgVehicles" >> _base >> _this) > 0))
};

// Category: the one named like the Eden subcategory of the class.
private _category = "";
private _sub = getText (_cfg >> "editorSubcategory");
private _subName = [getText (configFile >> "CfgEditorSubcategories" >> _sub >> "displayName"), ""] call _text60;
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
    ["base", [_base, ""] select !([_base, "class"] call _ok)],
    ["src", [_class] call _gear],
    ["category", _category],
    ["loadout", _loadout],
    ["identity", _identity],
    // Engineer, EOD, Medic and UAV Hacker: kept only where the class differs from its base
    ["engineer", "engineer" call _differs],
    ["eod", "canDeactivateMines" call _differs],
    ["medic", "attendant" call _differs],
    ["uavHacker", "uavHacker" call _differs]
]
