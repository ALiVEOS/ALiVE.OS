#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsIndexBuild);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsIndexBuild

Description:
Builds the class index of the studio in one pass over CfgVehicles, kept in
uiNamespace ALiVE_FS_index for the whole game session.

A class is kept when scope >= 2, side is 0..3, it isKindOf AllVehicles and it is
not isKindOf Animal. Each row:
    [class, toLower displayName, displayName, toLower faction, side, kind, editorSubcategory]
kind 0 is a man (CAManBase), 1 anything else.

The index is a HashMap:
    rows      - ARRAY of rows
    byFaction - HashMap lower faction name to row numbers
    factions  - [class, displayName, side] of every faction: the CfgFactionClasses
                ones (ALiVE_fnc_configGetFactions), plus the factions no mod defines
                (#1099), named after the Eden category of their first class

One build at a time: the caller sets missionNamespace ALiVE_FS_indexBuilding
before it spawns the build; the build clears it as its last line.

Parameters:
    None

Returns:
    HASHMAP - the index

Examples:
    (begin example)
    missionNamespace setVariable ["ALiVE_FS_indexBuilding", true];
    [] spawn ALiVE_fnc_fsIndexBuild;
    (end)

See Also:
    ALiVE_fnc_fsIndexFilter, ALiVE_fnc_fsImportFactionList

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

private _rows = [];
private _byFaction = createHashMap;
private _firstOf = createHashMap;
private _cfgVehicles = configFile >> "CfgVehicles";

for "_i" from 0 to (count _cfgVehicles) - 1 do {
    private _entry = _cfgVehicles select _i;
    if (isClass _entry && {getNumber (_entry >> "scope") >= 2}) then {
        private _side = getNumber (_entry >> "side");
        private _class = configName _entry;
        if (_side >= 0 && {_side <= 3} && {_class isKindOf "AllVehicles"} && {!(_class isKindOf "Animal")}) then {
            private _name = getText (_entry >> "displayName");
            private _factionText = getText (_entry >> "faction");
            private _faction = toLower _factionText;
            _rows pushBack [_class, toLower _name, _name, _faction, _side, [1, 0] select (_class isKindOf "CAManBase"), getText (_entry >> "editorSubcategory")];
            if !(_faction in _byFaction) then {
                _byFaction set [_faction, []];
                _firstOf set [_faction, [_factionText, getText (_entry >> "editorCategory"), _side]];
            };
            (_byFaction get _faction) pushBack ((count _rows) - 1);
        };
    };
};

// Factions defined in CfgFactionClasses, once each.
private _factions = [];
private _seen = createHashMap;
{
    private _cfg = _x call ALiVE_fnc_configGetFactionClass;
    private _side = getNumber (_cfg >> "side");
    private _lower = toLower (configName _cfg);
    if (isClass _cfg && {_side >= 0} && {_side <= 3} && {!(_lower in _seen)}) then {
        _seen set [_lower, true];
        _factions pushBack [configName _cfg, getText (_cfg >> "displayName"), _side];
    };
} forEach ([] call ALiVE_fnc_configGetFactions);

// Factions no mod defines (#1099): a mod that only adds an Eden category.
{
    if (!(_x in _seen) && {!(_x isEqualTo "")}) then {
        _y params ["_factionText", "_category", "_side"];
        private _name = getText (configFile >> "CfgEditorCategories" >> _category >> "displayName");
        if (_name isEqualTo "") then { _name = _factionText };
        _seen set [_x, true];
        _factions pushBack [_factionText, _name, _side];
    };
} forEach _firstOf;

private _index = createHashMapFromArray [["rows", _rows], ["byFaction", _byFaction], ["factions", _factions]];
uiNamespace setVariable ["ALiVE_FS_index", _index];

missionNamespace setVariable ["ALiVE_FS_indexBuilding", nil];
_index
