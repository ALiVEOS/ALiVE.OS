#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(zombieFactionCompile);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_zombieFactionCompile

Description:
Outbreak game mode: registers every faction listed as zombies on the Virtual AI module as a
runtime compiled faction on the zombie side, so Military Placement and the AI Commander field
it the way they field a Faction Compiler faction. Groups come from the faction's own CfgGroups
(Infantry and SpecOps, men only); a faction with none (every civilian faction) gets eight
groups of 6 to 12 men under each of Infantry and SpecOps, sixteen in all, drawn from its scope-2 CAManBase classes. A faction the Faction
Compiler built keeps its groups and moves to the zombie side. Server only, after static data has loaded.

Parameters:
Array - lower-case faction names (ALiVE_zombieFactions)

Returns:
Scalar - factions registered

Examples:
(begin example)
[ALiVE_zombieFactions] call ALiVE_fnc_zombieFactionCompile;
(end)

See Also:
ALiVE_fnc_factionCompilerInit, ALiVE_fnc_profileSystemInit

Author:
Jman
---------------------------------------------------------------------------- */

params [["_factions", [], [[]]]];

if (!isServer || {_factions isEqualTo []}) exitWith {0};

// Static data makes the mapping hash afresh when it loads (CustomFactions.hpp), so wait for it
// first or the entries written here are thrown away.
call ALiVE_fnc_staticDataHandler;
if (isNil "ALIVE_factionCustomMappings") then { ALIVE_factionCustomMappings = [] call ALIVE_fnc_hashCreate };
if (isNil "ALIVE_compiledFactions") then { ALIVE_compiledFactions = [] call ALIVE_fnc_hashCreate };

private _zombieSide = toUpper (missionNamespace getVariable ["ALiVE_ZOMBIESIDE", "EAST"]);
if !(_zombieSide in ["EAST", "WEST", "GUER"]) then { _zombieSide = "EAST" };
private _standardCategories = ["Infantry", "SpecOps", "Motorized", "Motorized_MTP", "Mechanized", "Mechanized_MTP", "Armored", "Air", "Naval", "Support", "Artillery"];
private _allVehicles = "true" configClasses (configFile >> "CfgVehicles");
private _registered = 0;

{
    private _factionLower = _x;

    // A faction the Faction Compiler built keeps its groups, made-up names included, but moves to the
    // zombie side: everything else (fnc_factionSide, Military Placement, the AI Commander) now answers the
    // zombie side for it, and its profiles take their side from the compiled groups.
    private _fcName = (ALIVE_factionCustomMappings select 1) findIf { toLower _x == _factionLower };
    private _existing = if (_fcName >= 0) then { [ALIVE_factionCustomMappings, (ALIVE_factionCustomMappings select 1) select _fcName] call ALIVE_fnc_hashGet } else { nil };
    if (!isNil "_existing" && {[_existing, "CompiledFaction", false] call ALIVE_fnc_hashGet} && {!([_existing, "ZombieFaction", false] call ALIVE_fnc_hashGet)}) then {
        private _fcFaction = (ALIVE_factionCustomMappings select 1) select _fcName;
        [_existing, "Side", _zombieSide] call ALIVE_fnc_hashSet;
        [_existing, "GroupSideName", _zombieSide] call ALIVE_fnc_hashSet;
        if (_fcFaction in (ALIVE_compiledFactions select 1)) then {
            private _fcData = [ALIVE_compiledFactions, _fcFaction] call ALIVE_fnc_hashGet;
            [_fcData, "side", _zombieSide] call ALIVE_fnc_hashSet;
            private _fcGroups = [_fcData, "compiledGroups", []] call ALIVE_fnc_hashGet;
            if (_fcGroups isEqualType [] && {count _fcGroups > 2}) then {
                { [_x, "side", _zombieSide] call ALIVE_fnc_hashSet } forEach (_fcGroups select 2);
            };
        };
        _registered = _registered + 1;
        ["ALiVE Profile System - Outbreak: zombie faction %1 was built by a Faction Compiler module: its groups are used as they are, on %2", _fcFaction, _zombieSide] call ALiVE_fnc_dump;
        continue;
    };

    private _factionConfig = _factionLower call ALiVE_fnc_configGetFactionClass;
    if !(isClass _factionConfig) then {
        ["ALiVE Profile System - Outbreak: zombie faction %1 is not in CfgFactionClasses, so nothing fields it", _factionLower] call ALiVE_fnc_dumpR;
        continue;
    };
    private _faction = configName _factionConfig;

    // A faction already on the zombie side with groups of its own (WebKnight's own faction with ALiVE's
    // groups for it) places as it always did, every category included.
    private _configSideNumber = getNumber (_factionConfig >> "side");
    private _ownGroupsRoot = configFile >> "CfgGroups" >> (["East", "West", "Indep", "Civilian"] select ((_configSideNumber max 0) min 3)) >> _faction;
    if (_configSideNumber == (["EAST", "WEST", "GUER"] find _zombieSide) && {isClass _ownGroupsRoot} && {count ("isClass _x" configClasses _ownGroupsRoot) > 0}) then {
        ["ALiVE Profile System - Outbreak: zombie faction %1 is already on %2 with its own groups, so it places as it is", _faction, _zombieSide] call ALiVE_fnc_dump;
        continue;
    };

    private _compiledGroups = [] call ALIVE_fnc_hashCreate;
    private _groupsByCategory = [] call ALIVE_fnc_hashCreate;
    private _unitClasses = [];
    private _groupIndex = 0;

    // One compiled group from a list of [class, rank, distance, bearing, height]
    private _addGroup = {
        params ["_category", "_name", "_members"];
        _groupIndex = _groupIndex + 1;
        private _groupId = format ["%1_ZOMBIES_%2", _faction, _groupIndex];
        private _unitEntries = [];
        {
            _x params ["_class", "_rank", "_distance", "_bearing", "_height"];
            private _unitData = [] call ALIVE_fnc_hashCreate;
            [_unitData, "class", _class] call ALIVE_fnc_hashSet;
            [_unitData, "rank", _rank] call ALIVE_fnc_hashSet;
            [_unitData, "damage", 0] call ALIVE_fnc_hashSet;
            // [] keeps the class's own kit (fnc_factionCompilerApplyLoadout leaves the unit alone)
            [_unitData, "loadout", []] call ALIVE_fnc_hashSet;
            [_unitData, "offsetDistance", _distance] call ALIVE_fnc_hashSet;
            [_unitData, "offsetBearing", _bearing] call ALIVE_fnc_hashSet;
            [_unitData, "offsetHeight", _height] call ALIVE_fnc_hashSet;
            _unitEntries pushBack _unitData;
            _unitClasses pushBackUnique _class;
        } forEach _members;
        private _groupData = [] call ALIVE_fnc_hashCreate;
        [_groupData, "groupId", _groupId] call ALIVE_fnc_hashSet;
        [_groupData, "name", _name] call ALIVE_fnc_hashSet;
        [_groupData, "category", _category] call ALIVE_fnc_hashSet;
        [_groupData, "side", _zombieSide] call ALIVE_fnc_hashSet;
        [_groupData, "units", _unitEntries] call ALIVE_fnc_hashSet;
        [_groupData, "vehicles", []] call ALIVE_fnc_hashSet;
        [_compiledGroups, _groupId, _groupData] call ALIVE_fnc_hashSet;
        private _list = [_groupsByCategory, _category, []] call ALIVE_fnc_hashGet;
        _list pushBack _groupId;
        [_groupsByCategory, _category, _list] call ALIVE_fnc_hashSet;
    };

    // The faction's own CfgGroups, read under its CONFIG side: fnc_factionSide answers the zombie
    // side from now on, so the usual group lookup would search the wrong side. Men only.
    private _configSide = getNumber (_factionConfig >> "side");
    if (_configSide in [0, 1, 2]) then {
        private _sideName = ["East", "West", "Indep"] select _configSide;
        private _groupsRoot = missionConfigFile >> "CfgGroups" >> _sideName >> _faction;
        if !(isClass _groupsRoot) then { _groupsRoot = configFile >> "CfgGroups" >> _sideName >> _faction };
        {
            private _category = _x;
            {
                private _groupClass = _x;
                private _members = [];
                private _leaderPos = [0, 0, 0];
                {
                    private _class = getText (_x >> "vehicle");
                    if (_class != "" && {_class isKindOf "Man"}) then {
                        private _pos = getArray (_x >> "position");
                        if (count _pos < 3) then { _pos = [0, 0, 0] };
                        if (_members isEqualTo []) then { _leaderPos = _pos };
                        private _dx = (_pos select 0) - (_leaderPos select 0);
                        private _dy = (_pos select 1) - (_leaderPos select 1);
                        _members pushBack [_class, toUpper (getText (_x >> "rank")), sqrt (_dx * _dx + _dy * _dy), _dx atan2 _dy, (_pos select 2) - (_leaderPos select 2)];
                    };
                } forEach ("isClass _x" configClasses _groupClass);
                if (count _members > 1) then {
                    [_category, getText (_groupClass >> "name"), _members] call _addGroup;
                };
            } forEach ("isClass _x" configClasses (_groupsRoot >> _category));
        } forEach ["Infantry", "SpecOps"];
    };

    // No groups of its own: eight hordes of 6 to 12 of its men in a loose wedge, under both
    // infantry categories so Military Placement and the commander always find one.
    if (_groupIndex == 0) then {
        private _men = (_allVehicles select {
            getNumber (_x >> "scope") == 2
            && {(toLower (getText (_x >> "faction"))) == _factionLower}
            && {(configName _x) isKindOf "CAManBase"}
        }) apply { configName _x };
        if (_men isEqualTo []) then {
            ["ALiVE Profile System - Outbreak: zombie faction %1 has no groups and no men, so nothing fields it", _faction] call ALiVE_fnc_dumpR;
            continue;
        };
        {
            private _category = _x;
            for "_i" from 1 to 8 do {
                private _members = [];
                for "_m" from 0 to (5 + floor random 7) do {
                    _members pushBack [selectRandom _men, ["SERGEANT", "PRIVATE"] select (_m > 0), 3 * ceil (_m / 2), [135, 225] select (_m mod 2), 0];
                };
                [_category, format ["%1 horde %2", _category, _i], _members] call _addGroup;
            };
        } forEach ["Infantry", "SpecOps"];
    };

    // The same two hashes the Faction Compiler writes (fnc_factionCompilerInit). Only categories
    // with groups appear under Groups: a listed but empty one reads as "nothing to place".
    private _typeMappings = [] call ALIVE_fnc_hashCreate;
    { [_typeMappings, _x, _x] call ALIVE_fnc_hashSet } forEach _standardCategories;
    private _mapping = [] call ALIVE_fnc_hashCreate;
    [_mapping, "Side", _zombieSide] call ALIVE_fnc_hashSet;
    [_mapping, "GroupSideName", _zombieSide] call ALIVE_fnc_hashSet;
    [_mapping, "FactionName", _faction] call ALIVE_fnc_hashSet;
    [_mapping, "ConfigFactionName", _faction] call ALIVE_fnc_hashSet;
    [_mapping, "GroupFactionName", _faction] call ALIVE_fnc_hashSet;
    [_mapping, "GroupFactionTypes", _typeMappings] call ALIVE_fnc_hashSet;
    [_mapping, "Groups", _groupsByCategory] call ALIVE_fnc_hashSet;
    [_mapping, "CompiledFaction", true] call ALIVE_fnc_hashSet;
    [_mapping, "ZombieFaction", true] call ALIVE_fnc_hashSet;
    [_mapping, "DisplayName", format ["%1 (zombies)", getText (_factionConfig >> "displayName")]] call ALIVE_fnc_hashSet;
    [ALIVE_factionCustomMappings, _faction, _mapping] call ALIVE_fnc_hashSet;

    private _factionData = [] call ALIVE_fnc_hashCreate;
    [_factionData, "factionId", _faction] call ALIVE_fnc_hashSet;
    [_factionData, "displayName", [_mapping, "DisplayName"] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
    [_factionData, "proxyFaction", _faction] call ALIVE_fnc_hashSet;
    [_factionData, "side", _zombieSide] call ALIVE_fnc_hashSet;
    [_factionData, "groupsByCategory", _groupsByCategory] call ALIVE_fnc_hashSet;
    [_factionData, "compiledGroups", _compiledGroups] call ALIVE_fnc_hashSet;
    [_factionData, "unitClasses", _unitClasses] call ALIVE_fnc_hashSet;
    [_factionData, "vehicleClasses", []] call ALIVE_fnc_hashSet;
    [ALIVE_compiledFactions, _faction, _factionData] call ALIVE_fnc_hashSet;

    _registered = _registered + 1;
    ["ALiVE Profile System - Outbreak: %1 fields %2 zombie groups on %3", _faction, _groupIndex, _zombieSide] call ALiVE_fnc_dump;
} forEach _factions;

_registered
