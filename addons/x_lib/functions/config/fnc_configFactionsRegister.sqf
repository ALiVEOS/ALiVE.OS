#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(configFactionsRegister);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_configFactionsRegister

Description:
Reads what faction mods declare about themselves under CfgALiVEFactions (see
main\CfgALiVEFactions.hpp) and adds it to ALiVE's faction data: their supply,
support, transport, air transport, container and AA class lists, and a faction
mapping when a faction borrows another's groups or renames its categories.

Called once as static data loads, after CustomFactions.hpp and before faction
inference, so what ALiVE already lists for a faction wins and a faction this
maps is never inferred. A mission's description.ext is read first, then the
game's config for any faction the mission did not declare.

Class names that are not loaded are left out, an empty list is never written
(so the side's list still applies), and table keys take the spelling of the
faction's CfgFactionClasses class, whatever the declaration typed.

Parameters:
Array - (optional) the parts to read: "mappings" and/or "tables" (default both).
        Eden has no mapping table, so its pickers ask for "tables" only.

Returns:
Array - [factions read, mappings added, list entries added]

Examples:
(begin example)
call ALiVE_fnc_configFactionsRegister;
[["tables"]] call ALiVE_fnc_configFactionsRegister;
(end)

See Also:
ALiVE_fnc_inferFactionMappingsAll

Author:
Jman
---------------------------------------------------------------------------- */

params [["_parts", ["mappings", "tables"]]];
// a bare "call" hands on the caller's _this, which need not be a list
if !(_parts isEqualType [] && {_parts isNotEqualTo []} && {(_parts select 0) isEqualType ""}) then { _parts = ["mappings", "tables"] };

private _doMappings = "mappings" in _parts && {!isNil "ALIVE_factionCustomMappings"};
private _doTables = "tables" in _parts;

// list property -> the table it fills
private _lists = [
    ["supplies", "ALIVE_factionDefaultSupplies"],
    ["supports", "ALIVE_factionDefaultSupports"],
    ["transport", "ALIVE_factionDefaultTransport"],
    ["airTransport", "ALIVE_factionDefaultAirTransport"],
    ["containers", "ALIVE_factionDefaultContainers"],
    ["aa", "ALIVE_factionDefaultAA"]
];

ALiVE_factionConfigDeclared = createHashMap;
private _seen = createHashMap;
private _mappingsAdded = 0;
private _entriesAdded = 0;
private _keptCurated = 0;
private _unknown = 0;
private _read = 0;

private _mappedLower = if (_doMappings) then { (ALIVE_factionCustomMappings select 1) apply { toLower _x } } else { [] };

{
    _x params ["_root", "_source"];
    {
        private _block = _x;
        private _declared = configName _block;
        private _lower = toLower _declared;
        if (_lower in _seen) then { continue };
        _seen set [_lower, true];
        _read = _read + 1;

        // the faction must exist; its own class name is the key from here on
        private _factionCfg = missionConfigFile >> "CfgFactionClasses" >> _declared;
        if !(isClass _factionCfg) then { _factionCfg = configFile >> "CfgFactionClasses" >> _declared };
        if !(isClass _factionCfg) then {
            _unknown = _unknown + 1;
            ["ALiVE config faction %1: no such faction is loaded, so its declaration was skipped", _declared] call ALiVE_fnc_dump;
            continue;
        };
        private _faction = configName _factionCfg;
        private _sideNum = getNumber (_factionCfg >> "side");
        if (_sideNum < 0 || {_sideNum > 3}) then { _sideNum = 3 };

        if (getNumber (_block >> "version") > 1) then {
            ["ALiVE config faction %1: declared for a later ALiVE (version %2); the parts this build knows are read", _faction, getNumber (_block >> "version")] call ALiVE_fnc_dump;
        };

        // mapping part
        private _mappingNote = "none, own groups";
        private _mapped = false;
        if (_doMappings) then {
            private _groupSide = getText (_block >> "groupSide");
            if (_groupSide == "") then { _groupSide = ["East", "West", "Indep", "Civilian"] select _sideNum };
            private _groupFaction = getText (_block >> "groupFaction");
            if (_groupFaction == "") then { _groupFaction = _faction };
            private _groupsCfg = configFile >> "CfgGroups" >> _groupSide >> _groupFaction;

            private _types = [] call ALiVE_fnc_hashCreate;
            {
                private _target = getText _x;
                if (_target != "" && {isClass (_groupsCfg >> _target)}) then {
                    [_types, configName _x, _target] call ALiVE_fnc_hashSet;
                } else {
                    ["ALiVE config faction %1: GroupTypes %2 = %3 names no category of %4 and was left out", _faction, configName _x, _target, _groupFaction] call ALiVE_fnc_dump;
                };
            } forEach (configProperties [_block >> "GroupTypes", "isText _x", true]);

            private _groups = [] call ALiVE_fnc_hashCreate;
            if (isClass (_block >> "Groups")) then {
                private _known = createHashMap;
                { private _cat = _x; { _known set [toLower configName _x, configName _x] } forEach ("true" configClasses _cat) } forEach ("true" configClasses _groupsCfg);
                {
                    private _names = ((getArray _x) select { _x isEqualType "" && {(toLower _x) in _known} }) apply { _known get (toLower _x) };
                    if (count _names < count getArray _x) then {
                        ["ALiVE config faction %1: Groups %2 names %3 group(s) %4 does not have; they were left out", _faction, configName _x, count getArray _x - count _names, _groupFaction] call ALiVE_fnc_dump;
                    };
                    if (_names isNotEqualTo []) then { [_groups, configName _x, _names arrayIntersect _names] call ALiVE_fnc_hashSet };
                } forEach (configProperties [_block >> "Groups", "isArray _x", true]);
            };

            private _declaresMapping = (toLower _groupFaction) != _lower || {count (_types select 1) > 0} || {count (_groups select 1) > 0};
            if (_declaresMapping) then {
                if (_lower in _mappedLower) then {
                    _mappingNote = "kept curated";
                    _keptCurated = _keptCurated + 1;
                } else {
                    private _sideText = switch (toLower _groupSide) do {
                        case "east": { "EAST" };
                        case "west": { "WEST" };
                        case "indep";
                        case "guer";
                        case "resistance": { "INDEP" };
                        default { ["EAST", "WEST", "INDEP", "CIV"] select _sideNum };
                    };
                    private _mapping = [] call ALiVE_fnc_hashCreate;
                    [_mapping, "Side", _sideText] call ALiVE_fnc_hashSet;
                    [_mapping, "GroupSideName", _sideText] call ALiVE_fnc_hashSet;
                    [_mapping, "FactionName", _faction] call ALiVE_fnc_hashSet;
                    [_mapping, "GroupFactionName", _groupFaction] call ALiVE_fnc_hashSet;
                    // declared, not inferred: the groups are used as written, with no unit swap
                    [_mapping, "ConfigDeclared", true] call ALiVE_fnc_hashSet;
                    [_mapping, "GroupFactionTypes", _types] call ALiVE_fnc_hashSet;
                    // always present, as inference writes it: readers look the key up with no default
                    [_mapping, "Groups", _groups] call ALiVE_fnc_hashSet;
                    [ALIVE_factionCustomMappings, _faction, _mapping] call ALiVE_fnc_hashSet;
                    _mappedLower pushBack _lower;
                    _mappingsAdded = _mappingsAdded + 1;
                    _mapped = true;
                    _mappingNote = "registered";
                };
            };
        };

        // tables part
        private _written = [];
        if (_doTables) then {
            {
                _x params ["_prop", "_tableName"];
                private _table = missionNamespace getVariable [_tableName, nil];
                if (!isNil "_table" && {isArray (_block >> _prop)}) then {
                    private _all = (getArray (_block >> _prop)) select { _x isEqualType "" };
                    private _names = [];
                    {
                        private _cfg = configFile >> "CfgVehicles" >> _x;
                        if (isClass _cfg) then { _names pushBackUnique configName _cfg };
                    } forEach _all;
                    if (count _names < count _all) then {
                        ["ALiVE config faction %1: %2 of %3[] are not loaded classes and were left out: %4", _faction, count _all - count _names, _prop, _all select { !isClass (configFile >> "CfgVehicles" >> _x) }] call ALiVE_fnc_dump;
                    };
                    if (_names isNotEqualTo []) then {
                        private _had = [_table, _faction, []] call ALiVE_fnc_hashGet;
                        if (_had isEqualType [] && {_had isNotEqualTo []}) then {
                            _keptCurated = _keptCurated + 1;
                            ["ALiVE config faction %1: %2 kept curated (ALiVE already lists %3)", _faction, _prop, count _had] call ALiVE_fnc_dump;
                        } else {
                            [_table, _faction, _names] call ALiVE_fnc_hashSet;
                            _written pushBack _prop;
                            _entriesAdded = _entriesAdded + 1;
                        };
                    };
                };
            } forEach _lists;
        };

        ALiVE_factionConfigDeclared set [toLower _faction, createHashMapFromArray [
            ["mapping", _mapped], ["tables", _written], ["rarity", getNumber (_block >> "rarity") == 1], ["source", _source]
        ]];
        ["ALiVE config faction %1: mapping %2, tables %3", _faction, _mappingNote, if (_written isEqualTo []) then { "none" } else { _written joinString "," }] call ALiVE_fnc_dump;
    } forEach ("true" configClasses _root);
} forEach [[missionConfigFile >> "CfgALiVEFactions", "mission"], [configFile >> "CfgALiVEFactions", "config"]];

["ALiVE config factions: scanned=%1 mappings=%2 tables=%3 kept_curated=%4 unknown_faction=%5", _read, _mappingsAdded, _entriesAdded, _keptCurated, _unknown] call ALiVE_fnc_dump;

[_read, _mappingsAdded, _entriesAdded]
