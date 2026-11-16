#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsImportFactionList);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsImportFactionList

Description:
Every faction of the class index with its unit, vehicle and group counts, for
the "Import a faction" list. Units and vehicles are counted from the index rows;
groups are the group classes with at least one unit under the CfgGroups class the
import would read (the mapped one, or the faction's own when its mapping is
Inferred or CompiledFaction, as ALiVE_fnc_fsImportGroups decides). Factions with
nothing to import are left out. The class index is built first when it does not
exist yet.

Parameters:
    None

Returns:
    ARRAY - [class, displayName, side, units, vehicles, groups], sorted by class

Examples:
    (begin example)
    private _list = [] call ALiVE_fnc_fsImportFactionList;
    (end)

See Also:
    ALiVE_fnc_fsImportFaction, ALiVE_fnc_fsIndexBuild

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

private _index = uiNamespace getVariable "ALiVE_FS_index";
if (isNil "_index") then { _index = call ALiVE_fnc_fsIndexBuild };
private _rows = _index getOrDefault ["rows", []];
private _byFaction = _index getOrDefault ["byFaction", createHashMap];

private _groupRoot = {
    params ["_faction", "_side"];
    private _mapping = nil;
    if (!isNil "ALiVE_factionCustomMappings" && {_faction in (ALiVE_factionCustomMappings select 1)}) then {
        _mapping = [ALiVE_factionCustomMappings, _faction] call ALiVE_fnc_hashGet;
    };
    private _skip = !isNil "_mapping" && {([_mapping, "Inferred", false] call ALiVE_fnc_hashGet) || {[_mapping, "CompiledFaction", false] call ALiVE_fnc_hashGet}};
    if (isNil "_mapping" || {_skip}) then {
        private _sideName = ["East", "West", "Indep", "Civilian"] select ((_side max 0) min 3);
        private _root = missionConfigFile >> "CfgGroups" >> _sideName >> _faction;
        if !(isClass _root) then { _root = configFile >> "CfgGroups" >> _sideName >> _faction };
        _root
    } else {
        _faction call ALiVE_fnc_configGetFactionGroups
    };
};

private _list = [];
{
    _x params ["_class", "_name", "_side"];
    private _numbers = _byFaction getOrDefault [toLower _class, []];
    private _units = { ((_rows select _x) select 5) == 0 } count _numbers;
    private _vehicles = (count _numbers) - _units;
    private _groups = 0;
    private _root = [_class, _side] call _groupRoot;
    if (isClass _root) then {
        {
            _groups = _groups + ({ (count (configProperties [_x, "isClass _x", true])) > 0 } count ("isClass _x" configClasses _x));
        } forEach ("isClass _x" configClasses _root);
    };
    if (_units + _vehicles + _groups > 0) then {
        _list pushBack [_class, _name, _side, _units, _vehicles, _groups];
    };
} forEach (_index getOrDefault ["factions", []]);

_list sort true;
_list
