#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsAliveLive);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsAliveLive

Description:
What ALiVE has read for the faction's class from the export loaded in this game,
taken from ALiVE's own tables, so it can be set beside ALiVE_fnc_fsAlivePreview:
    - group counts per ALiVE category, looked up the way a placement draws a
      group (the mapping's GroupFactionTypes, then the group config);
    - the six lists from ALiVE's faction tables (ALIVE_factionDefaultSupplies
      and the others);
    - the mapping kind: "none", "curated", "declared" (from a CfgALiVEFactions
      block), "inferred" or "compiled".
Needs ALiVE's static data; returns an empty HASHMAP without it, or when the
faction's class is not loaded.

Parameters:
    _faction - HASHMAP - the studio faction

Returns:
    HASHMAP - cats (ARRAY of [category, groups]), lists (ARRAY of [name, classes]),
              mapping (STRING), rarity (BOOL)

Examples:
    (begin example)
    private _live = [_faction] call ALiVE_fnc_fsAliveLive;
    (end)

See Also:
    ALiVE_fnc_fsAlivePreview

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_faction", createHashMap, [createHashMap]]];

private _class = _faction getOrDefault ["class", ""];
if (_class isEqualTo "" || {isNil "ALIVE_factionDefaultSupplies"} || {!isClass (_class call ALiVE_fnc_configGetFactionClass)}) exitWith { createHashMap };

private _mapping = nil;
if (!isNil "ALIVE_factionCustomMappings" && {_class in (ALIVE_factionCustomMappings select 1)}) then {
    _mapping = [ALIVE_factionCustomMappings, _class] call ALIVE_fnc_hashGet;
};
private _kind = "none";
private _groupFaction = _class;
private _types = nil;
private _named = nil;
if (!isNil "_mapping") then {
    _kind = switch (true) do {
        case ([_mapping, "CompiledFaction", false] call ALIVE_fnc_hashGet): { "compiled" };
        case ([_mapping, "Inferred", false] call ALIVE_fnc_hashGet): { "inferred" };
        case ([_mapping, "ConfigDeclared", false] call ALIVE_fnc_hashGet): { "declared" };
        default { "curated" };
    };
    _groupFaction = [_mapping, "GroupFactionName", _class] call ALIVE_fnc_hashGet;
    _types = [_mapping, "GroupFactionTypes"] call ALIVE_fnc_hashGet;
    if ("Groups" in (_mapping select 1)) then { _named = [_mapping, "Groups"] call ALIVE_fnc_hashGet };
};

private _root = _groupFaction call ALiVE_fnc_configGetFactionGroups;
private _cats = FS_ALIVE_DRAWN apply {
    private _type = _x;
    if (!isNil "_types") then {
        private _to = [_types, _type] call ALIVE_fnc_hashGet;
        if (!isNil "_to") then { _type = _to };
    };
    private _n = -1;
    if (!isNil "_named" && {count (_named select 1) > 0} && {_type in (_named select 1)}) then {
        _n = count ([_named, _type] call ALIVE_fnc_hashGet);
    };
    if (_n < 0) then { _n = count ("isClass _x" configClasses (_root >> _type)) };
    [_x, _n]
};

private _lists = [
    ["supplies", "ALIVE_factionDefaultSupplies"],
    ["supports", "ALIVE_factionDefaultSupports"],
    ["transport", "ALIVE_factionDefaultTransport"],
    ["airTransport", "ALIVE_factionDefaultAirTransport"],
    ["containers", "ALIVE_factionDefaultContainers"],
    ["aa", "ALIVE_factionDefaultAA"]
] apply {
    _x params ["_name", "_global"];
    private _table = missionNamespace getVariable _global;
    private _got = if (isNil "_table") then { [] } else { [_table, _class, []] call ALIVE_fnc_hashGet };
    [_name, [[], _got] select (_got isEqualType [])]
};

private _declared = if (isNil "ALiVE_factionConfigDeclared") then { createHashMap } else { ALiVE_factionConfigDeclared getOrDefault [toLower _class, createHashMap] };

createHashMapFromArray [
    ["cats", _cats],
    ["lists", _lists],
    ["mapping", _kind],
    ["rarity", _declared getOrDefault ["rarity", false]]
]
