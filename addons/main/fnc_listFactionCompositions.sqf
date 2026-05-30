#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(listFactionCompositions);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_listFactionCompositions

Description:
    Feeder for ALiVE_CompositionChoice. Walks CfgGroups>Empty>{Military|
    Guerrilla} for the given faction, returning each composition as a
    6-tuple `[class_name, display_name, side, size, category, source]`
    so the Eden picker can group / filter the listbox by Side / Size /
    Category / Source mod.

    Side detection: substring match on the composition class name
    (e.g. "Camp_BLU_F" -> "WEST"). Compositions without a side suffix are
    tagged "Universal".

    Size detection: parsed from the parent CATEGORY class name suffix
    (e.g. "CampsLarge" -> size "Large", category "Camps"). More reliable
    than parsing the composition class name itself.

    Category detection: parent CATEGORY class name with size suffix
    stripped (e.g. "CampsLarge" -> "Camps", "FieldHQ" -> "FieldHQ").

    Civilian compositions are NOT included - this feeder targets military
    placement modules (mil_placement_custom, future mil_placement, mil_ato,
    civ_placement which is military-objective-in-civilian-areas).

    Enemy-faction filter mirrors ALiVE_fnc_getCompositions: compositions
    whose class name contains an enemy-faction string are excluded.

Parameters:
    0: STRING - faction class name (e.g. "BLU_F", "OPF_F", "rhs_faction_usarmy_d")

Returns:
    ARRAY of [STRING, STRING, STRING, STRING, STRING, STRING] tuples:
      [class_name, display_name, side, size, category, source]
    `source` is "Vanilla" for stock A3 compositions, otherwise the mod
    identifier returned by configSourceMod (e.g. "Zeus Enhanced").
    Sorted alphabetically by class name. Empty array if the faction has
    no matching compositions or is invalid.

Examples:
    (begin example)
    private _comps = ["rhs_faction_usarmy_d"] call ALiVE_fnc_listFactionCompositions;
    {
        _x params ["_class", "_dispName", "_side", "_size", "_category", "_source"];
        _ctrl lbAdd format ["%1 [%2/%3] (%4) {%5}", _dispName, _side, _size, _class, _source];
        _ctrl lbSetData [_forEachIndex, _class];
    } forEach _comps;
    (end)

See Also:
    ALiVE_fnc_getCompositions
    ALiVE_fnc_edenCompositionChoiceLoad

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_faction", "", [""]]];

if (_faction == "") exitWith { [] };

private _compType = "Military";
if ((_faction call ALiVE_fnc_factionSide) == RESISTANCE) then {
    _compType = "Guerrilla";
};

// Enemy-faction list (mirrors ALiVE_fnc_getCompositions exclusion rule).
private _enemyFactions = [];
private _friendlySide = _faction call ALiVE_fnc_factionSide;
private _enemySides = switch (_friendlySide) do {
    case EAST: { [WEST] };
    case WEST: { [EAST] };
    case RESISTANCE: { [WEST, EAST] };
    default { [EAST] };
};
{
    private _enemy = _x;
    private _enemyNum = [_enemy] call ALIVE_fnc_sideObjectToNumber;
    private _enemyTxt = [_enemyNum] call ALIVE_fnc_sideNumberToText;
    {
        if !(_x in _enemyFactions) then { _enemyFactions pushBack _x };
    } forEach (_enemyTxt call ALiVE_fnc_getSideFactions);
} forEach _enemySides;

// Walk CfgGroups>Empty>{compType}
private _result = [];
private _configPath = configFile >> "CfgGroups" >> "Empty" >> _compType;
if (!isClass _configPath) exitWith { _result };

// Size suffixes to detect on category names.
private _sizeSuffixes = ["Large", "Medium", "Small"];

for "_i" from 0 to ((count _configPath) - 1) do {
    private _categoryClass = _configPath select _i;
    if (isClass _categoryClass) then {
        private _catName = configName _categoryClass;

        // Derive size from suffix; default empty (no size info).
        private _size = "";
        {
            if ((_catName select [count _catName - count _x]) == _x) exitWith {
                _size = _x;
            };
        } forEach _sizeSuffixes;

        // Strip size suffix from category name.
        private _category = _catName;
        if (_size != "") then {
            _category = _category select [0, count _category - count _size];
        };

        // Walk compositions in this category.
        for "_j" from 0 to ((count _categoryClass) - 1) do {
            private _comp = _categoryClass select _j;
            if (isClass _comp) then {
                private _className = configName _comp;
                if (_className != "") then {
                    // Enemy-faction filter.
                    private _excluded = false;
                    {
                        if (_className find _x != -1) exitWith { _excluded = true };
                    } forEach _enemyFactions;

                    if (!_excluded) then {
                        // Display name from `name` config; localise $STR_ keys.
                        private _displayName = getText (_comp >> "name");
                        if (_displayName != "" && {(_displayName select [0, 1]) == "$"}) then {
                            private _localised = localize (_displayName select [1]);
                            if (_localised != (_displayName select [1])) then {
                                _displayName = _localised;
                            };
                        };
                        if (_displayName == "") then { _displayName = _className };

                        // Side from class-name suffix.
                        private _side = "Universal";
                        if (_className find "BLU_F" != -1) then { _side = "WEST" };
                        if (_className find "OPF_F" != -1) then { _side = "EAST" };
                        if (_className find "IND_F" != -1) then { _side = "Independent" };
                        if (_className find "CIV_F" != -1) then { _side = "Civilian" };

                        // Source mod identifier. Empty for vanilla Arma 3
                        // stock content (CfgPatches with no `mod` field).
                        // Mod-supplied compositions return their addon's
                        // mod identifier (e.g. "Zeus Enhanced", "ALiVE").
                        private _source = configSourceMod _comp;
                        if (_source == "") then { _source = "Vanilla" };

                        _result pushBack [_className, _displayName, _side, _size, _category, _source];
                    };
                };
            };
        };
    };
};

// Sort by class name (first element of each tuple). Stable across re-opens.
_result sort true;

["ALIVE listFactionCompositions: faction=%1 compType=%2 returned=%3 enemyFactions=%4", _faction, _compType, count _result, count _enemyFactions] call ALiVE_fnc_dump;

_result
