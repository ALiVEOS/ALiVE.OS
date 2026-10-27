#include "\x\alive\addons\sup_player_resupply\script_component.hpp"
SCRIPT(PRCatalogueRules);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_PRCatalogueRules

Description:
The tablet catalogue's three lists, Only These, Never and Also, read once into a rules hash and
asked yes or no. Each list takes vehicle, crate and soldier class names and group names together,
separated by commas, semicolons or spaces, in any case. A group is named by its group class
(BUS_InfSquad: that group in every faction on the catalogue's side) or by faction and group class
joined with > (BLU_F>BUS_InfSquad: that faction's one only), the spelling the catalogue page shows.

Never beats everything. Also adds on top of the side or faction catalogue, past Only These: Only
These narrows what the side or faction would offer, so it cannot bring in another faction's
vehicle, and Also is the one way to. Only These touches groups only when it names a group, so a
list of vehicles leaves the Groups tab as it was.

A name that is no vehicle, crate, soldier or group in this game is dropped with one RPT line, so a
list written for a mod that isn't loaded behaves as an empty one.

Parameters:
    ["parse", [onlyString, neverString, alsoString]] - rules hash
    ["parseLogic", logic] - reads the module's three lists plus the mission's custom lists, stores
        the rules on the module as pr_catalogueRules and returns them
    ["allows", [rules, class]] - true when the class may be offered
    ["allowsGroup", [rules, faction, groupClass]] - true when the group may be offered
    ["blocked", [rules, forceMakeup]] - the first class or group in a tablet request that Never
        names, "" when none (the server's check on a request)
    ["filterGroups", [rules, sortedGroups, sideText]] - applies the lists to a sorted groups hash
        (faction > category > group) in place and adds the Also groups
    ["addAlso", [rules, sortedVehicles]] - adds the Also classes to a sorted vehicles hash in place

Returns:
See above

Examples:
(begin example)
private _rules = ["parse", ["B_MRAP_01_F, BLU_F>BUS_InfSquad", "", "O_MRAP_02_F"]] call ALIVE_fnc_PRCatalogueRules;
["allows", [_rules, "B_MRAP_01_F"]] call ALIVE_fnc_PRCatalogueRules; // true
(end)

Author:
Jman
---------------------------------------------------------------------------- */

params [["_operation", ""], ["_args", []]];

// Every group class name in the game, lower case, for telling a bare group name from a typing mistake
private _fnc_groupNames = {
    private _cache = missionNamespace getVariable "ALiVE_PR_groupNameCache";
    if (isNil "_cache") then {
        _cache = createHashMap;
        {
            {
                {
                    { if (isClass _x) then { _cache set [toLower configName _x, true] } } forEach ("true" configClasses _x);
                } forEach ("true" configClasses _x);
            } forEach ("true" configClasses _x);
        } forEach ("true" configClasses (configFile >> "CfgGroups"));
        missionNamespace setVariable ["ALiVE_PR_groupNameCache", _cache];
    };
    _cache
};

// A faction as the groups hash keys it: the custom mappings name the CfgGroups faction a
// CfgFactionClasses faction borrows its groups from
private _fnc_groupFaction = {
    params ["_faction"];
    private _result = _faction;
    // names arrive lower case from the lists, the mapping keys keep their config case
    private _i = if (isNil "ALIVE_factionCustomMappings") then { -1 } else { (ALIVE_factionCustomMappings select 1) findIf { _x == _faction } };
    if (_i > -1) then {
        private _mapping = [ALIVE_factionCustomMappings, (ALIVE_factionCustomMappings select 1) select _i] call ALIVE_fnc_hashGet;
        private _groupFaction = [_mapping, "GroupFactionName", _faction] call ALIVE_fnc_hashGet;
        if (_groupFaction isEqualType "" && {_groupFaction != ""}) then { _result = _groupFaction };
    };
    toLower _result
};

// The faction a list names, in its CfgFactionClasses spelling, which is how the tablet keys its
// factions and what a request sends; "" when there is none. A mission maker may also have typed
// the CfgGroups name a custom mapping points at (Guerilla for BLU_G_F).
private _fnc_factionClass = {
    params ["_faction"];
    if (isClass (configFile >> "CfgFactionClasses" >> _faction)) exitWith { configName (configFile >> "CfgFactionClasses" >> _faction) };
    if (isNil "ALIVE_factionCustomMappings") exitWith { "" };
    private _keys = ALIVE_factionCustomMappings select 1;
    private _i = _keys findIf { ([_x] call _fnc_groupFaction) == toLower _faction };
    if (_i > -1) then { _keys select _i } else { "" }
};

// [faction, group] against a list of [faction, group] tokens, faction "" matching any faction
private _fnc_groupIn = {
    params ["_faction", "_group", "_tokens"];
    private _f = [_faction] call _fnc_groupFaction;
    private _g = toLower _group;
    (_tokens findIf { (_x select 1) == _g && {(_x select 0) == "" || {([_x select 0] call _fnc_groupFaction) == _f}} }) > -1
};

private _result = nil;

switch (_operation) do {

    case "parse": {
        _args params [["_onlyText", ""], ["_neverText", ""], ["_alsoText", ""]];
        private _rules = createHashMap;
        {
            _x params ["_text", "_name"];
            private _classes = [];
            private _groups = [];
            if (_text isEqualType []) then { _text = _text joinString "," };
            if !(_text isEqualType "") then { _text = "" };
            // "BLU_F > BUS_InfSquad" is one token, not three
            _text = _text regexReplace ["\s*>\s*", ">"];
            {
                private _token = _x trim [" ", 0];
                if (_token != "") then {
                    if ((_token find ">") > -1) then {
                        private _parts = _token splitString ">";
                        if (count _parts == 2) then {
                            private _pair = [toLower ((_parts select 0) trim [" ", 0]), toLower ((_parts select 1) trim [" ", 0])];
                            if !(_pair in _groups) then { _groups pushBack _pair };
                        } else {
                            ["SUP_PR - catalogue: '%1' is not a vehicle, crate, soldier or group in this game", _token] call ALiVE_fnc_dump;
                        };
                    } else {
                        if (isClass (configFile >> "CfgVehicles" >> _token)) then {
                            _classes pushBackUnique configName (configFile >> "CfgVehicles" >> _token);
                        } else {
                            if ((toLower _token) in (call _fnc_groupNames)) then {
                                private _pair = ["", toLower _token];
                                if !(_pair in _groups) then { _groups pushBack _pair };
                            } else {
                                ["SUP_PR - catalogue: '%1' is not a vehicle, crate, soldier or group in this game", _token] call ALiVE_fnc_dump;
                            };
                        };
                    };
                };
            } forEach (_text splitString ",; []'""");
            _rules set [_name + "Classes", _classes];
            _rules set [_name + "Groups", _groups];
        } forEach [[_onlyText, "only"], [_neverText, "never"], [_alsoText, "also"]];
        _result = _rules;
    };

    case "parseLogic": {
        private _logic = _args;
        private _list = {
            params ["_var", "_extra"];
            private _value = _logic getVariable [_var, ""];
            if (_value isEqualType []) then { _value = _value joinString "," };
            if !(_value isEqualType "") then { _value = "" };
            private _more = missionNamespace getVariable [_extra, []];
            if (_more isEqualType [] && {count _more > 0}) then { _value = _value + "," + (_more joinString ",") };
            _value
        };
        private _never = ["pr_restrictionBlacklist", "ALiVE_PR_CUSTOM_BLACKLIST"] call _list;
        // ALiVE's own placement blacklist names classes from mods that may not be loaded: those are
        // left out quietly, as the warning is for names a mission maker typed
        private _placement = missionNamespace getVariable ["ALiVE_PLACEMENT_VEHICLEBLACKLIST", []];
        if (_placement isEqualType []) then { _placement = _placement select { _x isEqualType "" && {isClass (configFile >> "CfgVehicles" >> _x)} } } else { _placement = [] };
        if (count _placement > 0) then { _never = _never + "," + (_placement joinString ",") };
        _result = ["parse", [
            ["pr_restrictionWhitelist", "ALiVE_PR_CUSTOM_WHITELIST"] call _list,
            _never,
            ["pr_restrictionAlso", "ALiVE_PR_CUSTOM_ALSO"] call _list
        ]] call ALIVE_fnc_PRCatalogueRules;
        _logic setVariable ["pr_catalogueRules", _result];
    };

    case "allows": {
        _args params ["_rules", ["_class", ""]];
        private _real = if (isClass (configFile >> "CfgVehicles" >> _class)) then { configName (configFile >> "CfgVehicles" >> _class) } else { _class };
        _result = call {
            if (_real in (_rules getOrDefault ["neverClasses", []])) exitWith { false };
            if (_real in (_rules getOrDefault ["alsoClasses", []])) exitWith { true };
            private _only = _rules getOrDefault ["onlyClasses", []];
            (count _only == 0) || {_real in _only}
        };
    };

    case "allowsGroup": {
        _args params ["_rules", ["_faction", ""], ["_group", ""]];
        _result = call {
            if ([_faction, _group, _rules getOrDefault ["neverGroups", []]] call _fnc_groupIn) exitWith { false };
            if ([_faction, _group, _rules getOrDefault ["alsoGroups", []]] call _fnc_groupIn) exitWith { true };
            private _only = _rules getOrDefault ["onlyGroups", []];
            (count _only == 0) || {[_faction, _group, _only] call _fnc_groupIn}
        };
    };

    case "blocked": {
        _args params ["_rules", ["_forceMakeup", []]];
        _result = "";
        private _neverClasses = _rules getOrDefault ["neverClasses", []];
        private _neverGroups = _rules getOrDefault ["neverGroups", []];
        if (count _neverClasses + count _neverGroups > 0 && {_forceMakeup isEqualType []}) then {
            // [requestID, crates and stores, vehicles, 3 x individuals, 3 x groups]
            private _isNever = {
                params ["_class"];
                private _real = if (isClass (configFile >> "CfgVehicles" >> _class)) then { configName (configFile >> "CfgVehicles" >> _class) } else { _class };
                _real in _neverClasses
            };
            {
                if (_x isEqualType "" && {[_x] call _isNever}) exitWith { _result = _x };
            } forEach (_forceMakeup param [1, []]);
            if (_result == "") then {
                {
                    {
                        if (_x isEqualType [] && {[_x param [0, ""]] call _isNever}) exitWith { _result = _x select 0 };
                    } forEach (_forceMakeup param [_x, []]);
                    if (_result != "") exitWith {};
                } forEach [2, 3, 4, 5];
            };
            if (_result == "") then {
                {
                    {
                        if (_x isEqualType []) then {
                            _x params [["_group", ""], ["_info", []]];
                            private _faction = if (_info isEqualType []) then { _info param [1, ""] } else { "" };
                            if (_group isEqualType "" && {_faction isEqualType ""} && {[_faction, _group, _neverGroups] call _fnc_groupIn}) exitWith { _result = _group };
                        };
                    } forEach (_forceMakeup param [_x, []]);
                    if (_result != "") exitWith {};
                } forEach [6, 7, 8];
            };
        };
    };

    case "filterGroups": {
        _args params ["_rules", "_sortedGroups", ["_sideText", "WEST"]];
        private _never = _rules getOrDefault ["neverGroups", []];
        private _only = _rules getOrDefault ["onlyGroups", []];
        private _also = _rules getOrDefault ["alsoGroups", []];
        if (count _never + count _only > 0) then {
            {
                private _faction = _x;
                private _categories = [_sortedGroups, _faction] call ALIVE_fnc_hashGet;
                if (!isNil "_categories" && {_categories isEqualType []} && {count _categories > 1}) then {
                    {
                        private _groups = [_categories, _x] call ALIVE_fnc_hashGet;
                        if (!isNil "_groups" && {_groups isEqualType []} && {count _groups > 1}) then {
                            {
                                if !(["allowsGroup", [_rules, _faction, _x]] call ALIVE_fnc_PRCatalogueRules) then {
                                    [_groups, _x] call ALIVE_fnc_hashRem;
                                };
                            } forEach +(_groups select 1);
                            if (count (_groups select 1) == 0) then { [_categories, _x] call ALIVE_fnc_hashRem };
                        };
                    } forEach +(_categories select 1);
                    if (count (_categories select 1) == 0) then { [_sortedGroups, _faction] call ALIVE_fnc_hashRem };
                };
            } forEach +(_sortedGroups select 1);
        };
        // Also: a faction and group from the catalogue's own side, looked up in the game's groups
        private _sideConfig = configFile >> "CfgGroups" >> (["West", "East", "Indep", "Civilian"] select ((["WEST", "EAST", "GUER", "CIV"] find _sideText) max 0));
        {
            _x params ["_faction", "_group"];
            if (_faction == "") then {
                ["SUP_PR - catalogue: the group '%1' in Also needs its faction too, as on the catalogue page (Faction>Group)", _group] call ALiVE_fnc_dump;
            } else {
                // the tablet keys factions by their CfgFactionClasses name (BLU_G_F) and spawns the
                // group as that faction, while the group itself sits under the CfgGroups faction a
                // custom mapping names (Guerilla)
                private _fClass = [_faction] call _fnc_factionClass;
                private _found = [];
                if (_fClass != "" && {([_fClass call ALiVE_fnc_factionSide] call ALiVE_fnc_sideToSideText) == _sideText}) then {
                    private _groupFaction = [_fClass] call _fnc_groupFaction;
                    private _factionConfig = ("true" configClasses _sideConfig) select { toLower configName _x == _groupFaction };
                    if (count _factionConfig > 0) then {
                        {
                            private _category = _x;
                            { if (toLower configName _x == _group) exitWith { _found = [_fClass, configName _category, configName _x, getText (_x >> "name")] } } forEach ("true" configClasses _category);
                            if (count _found > 0) exitWith {};
                        } forEach ("true" configClasses (_factionConfig select 0));
                    };
                };
                if (count _found == 0) then {
                    ["SUP_PR - catalogue: the group '%1>%2' in Also is not a group of side %3, so it is left out", _faction, _group, _sideText] call ALiVE_fnc_dump;
                } else {
                    _found params ["_fKey", "_cKey", "_gKey", "_gName"];
                    if !([_fKey, _gKey, _never] call _fnc_groupIn) then {
                        // reuse an existing key whatever its case, so the tablet sees one faction and one category
                        private _fi = (_sortedGroups select 1) findIf { toLower _x == toLower _fKey };
                        if (_fi > -1) then { _fKey = (_sortedGroups select 1) select _fi } else { [_sortedGroups, _fKey, [] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet };
                        private _categories = [_sortedGroups, _fKey] call ALIVE_fnc_hashGet;
                        private _ci = (_categories select 1) findIf { toLower _x == toLower _cKey };
                        if (_ci > -1) then { _cKey = (_categories select 1) select _ci } else { [_categories, _cKey, [] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet };
                        private _groups = [_categories, _cKey] call ALIVE_fnc_hashGet;
                        if !(_gKey in (_groups select 1)) then { [_groups, _gKey, _gName] call ALIVE_fnc_hashSet };
                    };
                };
            };
        } forEach _also;
        _result = _sortedGroups;
    };

    case "addAlso": {
        _args params ["_rules", "_sortedVehicles"];
        private _never = _rules getOrDefault ["neverClasses", []];
        {
            private _class = _x;
            if (!(_class in _never) && {getNumber (configFile >> "CfgVehicles" >> _class >> "scope") >= 2}) then {
                private _category = getText (configFile >> "CfgVehicles" >> _class >> "vehicleClass");
                if (_category == "") then { _category = "Other" };
                private _ci = (_sortedVehicles select 1) findIf { toLower _x == toLower _category };
                if (_ci > -1) then { _category = (_sortedVehicles select 1) select _ci };
                private _list = [_sortedVehicles, _category, []] call ALIVE_fnc_hashGet;
                if (isNil "_list" || {!(_list isEqualType [])}) then { _list = [] };
                _list pushBackUnique _class;
                [_sortedVehicles, _category, _list] call ALIVE_fnc_hashSet;
            };
        } forEach (_rules getOrDefault ["alsoClasses", []]);
        _result = _sortedVehicles;
    };
};

if (isNil "_result") then { nil } else { _result }
