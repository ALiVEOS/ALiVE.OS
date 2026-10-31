#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(lists);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_lists

Description:
Named lists of what players may have: one set of rules the Player FOBs, the Player Logistics
tablet and the Logistics Hub can all read. A list is a class in CfgALiVELists (the mission's
description.ext first, then the mod's built-in ones) or three typed fields, read into a rules hash
and asked yes or no.

A list holds:
  only[]  - offer these and nothing else
  never[] - never offer these, whatever else says so
  also[]  - offer these on top
  kinds[] - a cut by kind: FORTIFICATION, SUPPLY, STATIC, VEHICLE (or VEHICLE:CAR,TRUCK,ARMOUR,
            ARTILLERY,AIR,BOAT), TROOPS, GEAR; none means every kind
  staticTier     - the heaviest static weapon kept: 2 machine guns and grenade launchers, 3 all
  fieldWorksOnly - fortifications no taller than 3 m (the FOB only, it needs measured sizes)
  fold           - 1 offers one of each vehicle, static weapon and crate model (camo and loadout
                   variants folded into the plainest), never folding soldiers or a class the
                   lists name; it changes what a catalogue shows, not what may be asked for
  inherit        - another list to start from; this one's kinds and tier replace its own. A
                   mission list named like a built-in one inherits it by naming itself
                   (class INFANTRY { inherit = "INFANTRY"; ... })
  only, never, also and kinds may be written as arrays or as one text of names
  class <Class> { cost = N; } - a FOB price, as Class=N in a list does

Names in the lists are vehicle, crate, soldier and gear class names, group classes (BUS_InfSquad,
that group in every faction) or faction>group (BLU_F>BUS_InfSquad), in any case. A name that is
none of those in this game is dropped with one RPT line.

The order a class is judged in: Never, then Also, then Only These when it names an object (an
Only list of objects IS the list, so the kind cut is off), else the kind cut and then Only These.
Artillery static weapons (mortars, howitzers) are left out by any kind cut.

Parameters:
    ["get", name] - rules of a named list, cached; "" or an unknown name gives empty rules
    ["reset"] - clears the caches
    ["parse", [onlyText, neverText, alsoText, [kinds, staticTier, fieldWorksOnly, fold]]] - rules hash
    ["merge", [base, over, inherit, own]] - one set of rules: lists joined, over's prices win, kinds
        and vehicle kinds only what both keep, the lower static tier, field works and fold when either asks.
        An Only list of objects turns the kind cut off only when the other side has no cut, unless
        own is true: a module's named list (base) under its own typed lists (over), where the typed
        Only list of objects sets the list, as it does today.
    ["allows", [rules, class]] - true when the class may be offered
    ["allowsGroup", [rules, faction, groupClass]] - true when the group may be offered
    ["blocked", [rules, forceMakeup]] - the first class or group in a tablet request that Never or
        the kind cut leaves out, "" when none (Only These is not tested here)
    ["kindOf", class] - [kind, tier, sub-kind]: the sub-kind is the kind of vehicle for VEHICLE
        and the weapon's role (MG, GMG, MORTAR, HOWITZER, AT, AA) for STATIC
    ["empty", rules] - true when the rules leave everything in
    ["fold", [rules, classes]] - the classes with one of each model when the rules fold, the
        plainest kept (shortest name, then shortest class name); crates of different contents and
        vehicles of different support roles count apart; soldiers and the classes the lists name
        are always kept
    ["describe", [rules, withList]] - one line of what the rules keep and the names in them that aren't in
        this game (a module's typed fields, and the named list's own when withList is true)
    ["problem", text] - (server) a list problem for admins: kept in ALiVE_lists_problems and shown as a hint
    ["show"] - (a player's machine) the hint of list problems, to an admin only
    ["report"] - one RPT line for every named list in the game and the mission

Returns:
See above

Examples:
(begin example)
private _rules = ["get", "INFANTRY"] call ALIVE_fnc_lists;
["allows", [_rules, "B_MBT_01_cannon_F"]] call ALIVE_fnc_lists; // false: no armour
(end)

Author:
Jman
---------------------------------------------------------------------------- */

params [["_operation", ""], ["_args", []]];

private _kindNames = ["FORTIFICATION", "SUPPLY", "STATIC", "VEHICLE", "TROOPS", "GEAR"];
private _vehicleKindNames = ["CAR", "TRUCK", "ARMOUR", "ARTILLERY", "AIR", "BOAT"];

// Every group class name in the game, lower case, for telling a bare group name from a typing
// mistake (shared with the tablet's catalogue rules)
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
    private _i = if (isNil "ALIVE_factionCustomMappings") then { -1 } else { (ALIVE_factionCustomMappings select 1) findIf { _x == _faction } };
    if (_i > -1) then {
        private _mapping = [ALIVE_factionCustomMappings, (ALIVE_factionCustomMappings select 1) select _i] call ALIVE_fnc_hashGet;
        private _groupFaction = [_mapping, "GroupFactionName", _faction] call ALIVE_fnc_hashGet;
        if (_groupFaction isEqualType "" && {_groupFaction != ""}) then { _result = _groupFaction };
    };
    toLower _result
};

// [faction, group] against a list of [faction, group] tokens, faction "" matching any faction
private _fnc_groupIn = {
    params ["_faction", "_group", "_tokens"];
    private _f = [_faction] call _fnc_groupFaction;
    private _g = toLower _group;
    (_tokens findIf { (_x select 1) == _g && {(_x select 0) == "" || {([_x select 0] call _fnc_groupFaction) == _f}} }) > -1
};

// A gear item's config, or configNull
private _fnc_gearConfig = {
    params ["_class"];
    private _cfg = configNull;
    { if (isClass (configFile >> _x >> _class)) exitWith { _cfg = configFile >> _x >> _class } } forEach ["CfgWeapons", "CfgMagazines", "CfgGlasses"];
    _cfg
};

// One typed list: [classes, groups, gear, names not in this game]
private _fnc_tokens = {
    params ["_text", "_prices"];
    private _missing = [];
    private _classes = [];
    private _groups = [];
    private _gear = [];
    if (_text isEqualType []) then { _text = (_text select { _x isEqualType "" }) joinString "," };
    if !(_text isEqualType "") then { _text = "" };
    // "BLU_F > BUS_InfSquad" is one token, not three; so is "B_MRAP_01_F = 450"
    _text = (_text regexReplace ["\s*>\s*", ">"]) regexReplace ["\s*=\s*", "="];
    {
        private _token = _x trim [" ", 0];
        private _price = -1;
        if ((_token find "=") > -1) then {
            private _parts = _token splitString "=";
            _token = _parts param [0, ""];
            _price = parseNumber (_parts param [1, ""]);
        };
        if (_token != "") then {
            if ((_token find ">") > -1) then {
                private _parts = _token splitString ">";
                if (count _parts == 2) then {
                    private _pair = [toLower ((_parts select 0) trim [" ", 0]), toLower ((_parts select 1) trim [" ", 0])];
                    if !(_pair in _groups) then { _groups pushBack _pair };
                } else {
                    _missing pushBackUnique _token;
                };
            } else {
                call {
                    // a backpack is gear to the Arsenal, and stays in the class list as well, where
                    // the tablet's config sort and the placement blacklist (parachutes) expect it
                    if (getNumber (configFile >> "CfgVehicles" >> _token >> "isBackpack") == 1) exitWith {
                        private _real = configName (configFile >> "CfgVehicles" >> _token);
                        _gear pushBackUnique _real;
                        _classes pushBackUnique _real;
                    };
                    if (isClass (configFile >> "CfgVehicles" >> _token)) exitWith {
                        private _real = configName (configFile >> "CfgVehicles" >> _token);
                        _classes pushBackUnique _real;
                        if (_price > 0) then { _prices set [toLower _real, _price] };
                    };
                    if ((toLower _token) in (call _fnc_groupNames)) exitWith {
                        private _pair = ["", toLower _token];
                        if !(_pair in _groups) then { _groups pushBack _pair };
                    };
                    private _gearCfg = [_token] call _fnc_gearConfig;
                    if (!isNull _gearCfg) exitWith { _gear pushBackUnique configName _gearCfg };
                    // kept, not logged here: the module that reads the list says which field it was in
                    _missing pushBackUnique _token;
                };
            };
        };
    } forEach (_text splitString ",; []'""");
    [_classes, _groups, _gear, _missing]
};

// kinds[] into [kinds, vehicle kinds]; VEHICLE:CAR,TRUCK keeps VEHICLE and names the kinds of vehicle
private _fnc_kinds = {
    params ["_spec"];
    if (_spec isEqualType "") then { _spec = _spec splitString " ;" };
    if !(_spec isEqualType []) then { _spec = [] };
    private _kinds = [];
    private _vehicleKinds = [];
    {
        if (_x isEqualType "") then {
            private _parts = (toUpper _x) splitString ":";
            private _kind = (_parts param [0, ""]) trim [" ", 0];
            if (_kind in _kindNames) then {
                _kinds pushBackUnique _kind;
                if (_kind == "VEHICLE" && {count _parts > 1}) then {
                    {
                        private _v = _x trim [" ", 0];
                        if (_v in _vehicleKindNames) then { _vehicleKinds pushBackUnique _v } else {
                            ["ALiVE Lists: '%1' is not a kind of vehicle (CAR, TRUCK, ARMOUR, ARTILLERY, AIR, BOAT)", _v] call ALiVE_fnc_dumpR;
                        };
                    } forEach ((_parts select 1) splitString ", ");
                };
            } else {
                if (_kind != "") then { ["ALiVE Lists: '%1' is not a kind (FORTIFICATION, SUPPLY, STATIC, VEHICLE, TROOPS, GEAR)", _kind] call ALiVE_fnc_dumpR };
            };
        };
    } forEach _spec;
    // a list that names kinds, all of them misspelt, keeps nothing rather than everything
    if (_kinds isEqualTo [] && {(_spec findIf { _x isEqualType "" && {(_x trim [" ", 0]) != ""} }) > -1}) then { _kinds = ["NONE"] };
    if ("VEHICLE" in _kinds && {_vehicleKinds isEqualTo []} && {(_spec findIf { _x isEqualType "" && {(toUpper _x) find "VEHICLE:" == 0} }) > -1}) then { _vehicleKinds = ["NONE"] };
    [_kinds, _vehicleKinds]
};

// Two sets of kinds, [] meaning every kind: only what both keep. Nothing in common is ["NONE"], so
// it can't read back as "every kind".
private _fnc_meet = {
    params ["_a", "_b"];
    if (_a isEqualTo []) exitWith { +_b };
    if (_b isEqualTo []) exitWith { +_a };
    private _both = _a arrayIntersect _b;
    if (_both isEqualTo []) then { ["NONE"] } else { _both }
};

private _fnc_emptyRules = {
    createHashMapFromArray [
        ["onlyClasses", []], ["neverClasses", []], ["alsoClasses", []],
        ["onlyGroups", []], ["neverGroups", []], ["alsoGroups", []],
        ["onlyGear", []], ["neverGear", []], ["alsoGear", []],
        ["prices", createHashMap], ["kinds", []], ["vehicleKinds", []],
        ["staticTier", -1], ["fieldWorksOnly", false], ["fieldWorksSet", false], ["fold", -1], ["onlyObjects", false], ["name", ""],
        // names not in this game: [name, field] typed into a module, and a named list's own
        ["missing", []], ["listMissing", []]
    ]
};

// The kind cut alone: true when the class's kind is kept
private _fnc_kindKept = {
    params ["_rules", "_class"];
    private _kinds = _rules getOrDefault ["kinds", []];
    if (_kinds isEqualTo []) exitWith { true };
    (["kindOf", _class] call ALIVE_fnc_lists) params ["_kind", "_tier", "_sub"];
    if (_kind == "") exitWith { true };
    private _staticTier = _rules getOrDefault ["staticTier", -1];
    private _vehicleKinds = _rules getOrDefault ["vehicleKinds", []];
    (_kind in _kinds)
    && {_kind != "STATIC" || {(_staticTier < 0 || {_tier <= _staticTier}) && {getNumber (configFile >> "CfgVehicles" >> _class >> "artilleryScanner") != 1}}}
    && {_kind != "VEHICLE" || {_vehicleKinds isEqualTo []} || {_sub in _vehicleKinds}}
};

private _result = nil;

switch (_operation) do {

    case "parse": {
        _args params [["_onlyText", ""], ["_neverText", ""], ["_alsoText", ""], ["_kindsSpec", []]];
        private _rules = call _fnc_emptyRules;
        private _prices = _rules get "prices";
        private _missing = _rules get "missing";
        {
            _x params ["_text", "_name", "_field"];
            ([_text, _prices] call _fnc_tokens) params ["_classes", "_groups", "_gear", "_bad"];
            { _missing pushBackUnique [_x, _field] } forEach _bad;
            _rules set [_name + "Classes", _classes];
            _rules set [_name + "Groups", _groups];
            _rules set [_name + "Gear", _gear];
        } forEach [[_onlyText, "only", "Only"], [_neverText, "never", "Never"], [_alsoText, "also", "Also"]];
        if !(_kindsSpec isEqualType []) then { _kindsSpec = [] };
        _kindsSpec params [["_kindList", []], ["_staticTier", -1], ["_fieldWorks", false], ["_fold", -1]];
        ([_kindList] call _fnc_kinds) params ["_kinds", "_vehicleKinds"];
        _rules set ["kinds", _kinds];
        _rules set ["vehicleKinds", _vehicleKinds];
        _rules set ["staticTier", if (_staticTier isEqualType 0) then { _staticTier } else { -1 }];
        // -1 (or false) is "not set", so a list that inherits keeps its parent's
        _rules set ["fieldWorksOnly", if (_fieldWorks isEqualType 0) then { _fieldWorks > 0 } else { _fieldWorks isEqualTo true }];
        _rules set ["fieldWorksSet", if (_fieldWorks isEqualType 0) then { _fieldWorks >= 0 } else { _fieldWorks isEqualTo true }];
        _rules set ["fold", if (_fold isEqualType 0) then { _fold max -1 min 1 } else { [-1, 1] select (_fold isEqualTo true) }];
        _rules set ["onlyObjects", ((_rules get "onlyClasses") findIf { !(_x isKindOf "Man") && {getNumber (configFile >> "CfgVehicles" >> _x >> "isBackpack") != 1} }) > -1];
        _result = _rules;
    };

    case "merge": {
        _args params ["_base", "_over", ["_inherit", false], ["_own", false]];
        private _rules = call _fnc_emptyRules;
        {
            private _key = _x;
            private _list = +(_base getOrDefault [_key, []]);
            { if !(_x in _list) then { _list pushBack _x } } forEach (_over getOrDefault [_key, []]);
            _rules set [_key, _list];
        } forEach ["onlyClasses", "neverClasses", "alsoClasses", "onlyGroups", "neverGroups", "alsoGroups", "onlyGear", "neverGear", "alsoGear"];
        private _missing = +(_base getOrDefault ["missing", []]);
        { _missing pushBackUnique _x } forEach (_over getOrDefault ["missing", []]);
        _rules set ["missing", _missing];
        private _prices = +(_base getOrDefault ["prices", createHashMap]);
        _prices merge [_over getOrDefault ["prices", createHashMap], true];
        _rules set ["prices", _prices];
        private _tierA = _base getOrDefault ["staticTier", -1];
        private _tierB = _over getOrDefault ["staticTier", -1];
        if (_inherit) then {
            // a list that inherits replaces the cut it started from when it sets one
            private _kindsB = _over getOrDefault ["kinds", []];
            _rules set ["kinds", if (_kindsB isEqualTo []) then { +(_base getOrDefault ["kinds", []]) } else { +_kindsB }];
            _rules set ["vehicleKinds", if (_kindsB isEqualTo []) then { +(_base getOrDefault ["vehicleKinds", []]) } else { +(_over getOrDefault ["vehicleKinds", []]) }];
            _rules set ["staticTier", [_tierB, _tierA] select (_tierB < 0)];
        } else {
            _rules set ["kinds", [_base getOrDefault ["kinds", []], _over getOrDefault ["kinds", []]] call _fnc_meet];
            _rules set ["vehicleKinds", [_base getOrDefault ["vehicleKinds", []], _over getOrDefault ["vehicleKinds", []]] call _fnc_meet];
            _rules set ["staticTier", call { if (_tierA < 0) exitWith { _tierB }; if (_tierB < 0) exitWith { _tierA }; _tierA min _tierB }];
        };
        private _fwA = _base getOrDefault ["fieldWorksOnly", false];
        private _fwB = _over getOrDefault ["fieldWorksOnly", false];
        _rules set ["fieldWorksOnly", if (_inherit && {_over getOrDefault ["fieldWorksSet", false]}) then { _fwB } else { _fwA || _fwB }];
        _rules set ["fieldWorksSet", (_base getOrDefault ["fieldWorksSet", false]) || {_over getOrDefault ["fieldWorksSet", false]}];
        private _foldA = _base getOrDefault ["fold", -1];
        private _foldB = _over getOrDefault ["fold", -1];
        _rules set ["fold", if (_inherit && {_foldB >= 0}) then { _foldB } else { _foldA max _foldB }];
        private _objA = _base getOrDefault ["onlyObjects", false];
        private _objB = _over getOrDefault ["onlyObjects", false];
        if (_inherit || _own) then {
            _rules set ["onlyObjects", _objA || _objB];
        } else {
            // an Only list of objects turns the kind cut off only when the other side has no cut
            // of its own, so a hub's Only list can't bring back what the tablet's kinds left out
            _rules set ["onlyObjects", (_objA || {(_base getOrDefault ["kinds", []]) isEqualTo []}) && {_objB || {(_over getOrDefault ["kinds", []]) isEqualTo []}} && {_objA || _objB}];
        };
        _rules set ["name", ([_base getOrDefault ["name", ""], _over getOrDefault ["name", ""]] select { _x != "" }) joinString "+"];
        _result = _rules;
    };

    case "get": {
        private _name = _args;
        private _depth = 0;
        if (_args isEqualType []) then { _name = _args param [0, ""]; _depth = _args param [1, 0] };
        if !(_name isEqualType "") then { _name = "" };
        private _cache = missionNamespace getVariable "ALiVE_lists_cache";
        if (isNil "_cache") then { _cache = createHashMap; ALiVE_lists_cache = _cache };
        private _key = toLower _name;
        if (_key in _cache) then { _result = _cache get _key } else {
            // one list class into rules, following inherit
            private _fnc_read = {
                params ["_cfg", "_depth"];
                // a list key may be written as an array or as one text of names
                private _list = { params ["_e"]; if (isText _e) then { getText _e } else { getArray _e } };
                private _kindsEntry = _cfg >> "kinds";
                private _rules = ["parse", [
                    [_cfg >> "only"] call _list, [_cfg >> "never"] call _list, [_cfg >> "also"] call _list,
                    [if (isText _kindsEntry) then { getText _kindsEntry } else { getArray _kindsEntry },
                        if (isNumber (_cfg >> "staticTier")) then { getNumber (_cfg >> "staticTier") } else { -1 }, if (isNumber (_cfg >> "fieldWorksOnly")) then { getNumber (_cfg >> "fieldWorksOnly") } else { -1 },
                        if (isNumber (_cfg >> "fold")) then { getNumber (_cfg >> "fold") } else { -1 }]
                ]] call ALIVE_fnc_lists;
                // class Land_HBarrier_5_F { cost = 7; };
                private _prices = _rules get "prices";
                {
                    if (isNumber (_x >> "cost") && {getNumber (_x >> "cost") > 0} && {isClass (configFile >> "CfgVehicles" >> configName _x)}) then {
                        _prices set [toLower configName _x, getNumber (_x >> "cost")];
                    };
                } forEach ("true" configClasses _cfg);
                private _own = configName _cfg;
                _rules set ["name", _own];
                private _parent = getText (_cfg >> "inherit");
                if (_parent != "") then {
                    private _base = call {
                        // a mission list of a built-in list's name builds on that built-in list
                        private _modCfg = configFile >> "CfgALiVELists" >> _own;
                        private _self = toLower _parent == toLower _own;
                        if (_self && {isClass _modCfg} && {!(_cfg isEqualTo _modCfg)}) exitWith { [_modCfg, _depth + 1] call _fnc_read };
                        if (_self) exitWith {
                            ["ALiVE Lists: %1 inherits itself, so its inherit is left out", _own] call ALiVE_fnc_dumpR;
                            nil
                        };
                        if (_depth >= 4) exitWith {
                            ["ALiVE Lists: %1 inherits %2 more than four lists deep (or in a loop), so the rest are left out", _own, _parent] call ALiVE_fnc_dumpR;
                            nil
                        };
                        ["get", [_parent, _depth + 1]] call ALIVE_fnc_lists
                    };
                    if (!isNil "_base") then {
                        _rules = ["merge", [_base, _rules, true]] call ALIVE_fnc_lists;
                        _rules set ["name", _own];
                    };
                };
                _rules
            };
            private _cfg = missionConfigFile >> "CfgALiVELists" >> _name;
            if !(isClass _cfg) then { _cfg = configFile >> "CfgALiVELists" >> _name };
            if (_name == "" || {!isClass _cfg}) then {
                if (_name != "") then { ["ALiVE Lists: no list named %1 (CfgALiVELists)", _name] call ALiVE_fnc_dumpR };
                _result = call _fnc_emptyRules;
            } else {
                _result = [_cfg, _depth] call _fnc_read;
                // a named list's bad names are its own: the list report prints them once, and a
                // module that picks the list doesn't repeat them as its typed fields' mistakes
                _result set ["listMissing", _result getOrDefault ["missing", []]];
                _result set ["missing", []];
            };
            // only a list asked for by name is kept: one read part way down another's inherit
            // chain may have been cut short there
            if (_depth == 0) then { _cache set [_key, _result] };
        };
    };

    case "reset": {
        ALiVE_lists_cache = nil;
        ALiVE_lists_kindCache = nil;
        _result = true;
    };

    case "kindOf": {
        private _class = _args;
        if !(_class isEqualType "") then { _class = "" };
        private _cache = missionNamespace getVariable "ALiVE_lists_kindCache";
        if (isNil "_cache") then { _cache = createHashMap; ALiVE_lists_kindCache = _cache };
        private _lc = toLower _class;
        if (_lc in _cache) then { _result = _cache get _lc } else {
            private _cfg = configFile >> "CfgVehicles" >> _class;
            _result = call {
                if (_class == "") exitWith { ["", 0, ""] };
                if !(isClass _cfg) exitWith { if (isNull ([_class] call _fnc_gearConfig)) then { ["", 0, ""] } else { ["GEAR", 1, ""] } };
                if (getNumber (_cfg >> "isBackpack") == 1) exitWith { ["GEAR", 1, ""] };
                if (_class isKindOf "Man") exitWith { ["TROOPS", 1, ""] };
                if (_class isKindOf "StaticWeapon") exitWith {
                    // the weapon's role, as the FOB's build list prices it
                    private _maxHit = 0;
                    private _groundMissile = false;
                    private _airLock = false;
                    private _grenade = false;
                    private _turrets = [];
                    private _walk = { params ["_t"]; { _turrets pushBack _x; [_x >> "Turrets"] call _walk } forEach ("true" configClasses _t) };
                    [_cfg >> "Turrets"] call _walk;
                    {
                        private _t = _x;
                        { if (getNumber (configFile >> "CfgWeapons" >> _x >> "airLock") >= 2) then { _airLock = true } } forEach (getArray (_t >> "weapons"));
                        {
                            private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
                            private _a = configFile >> "CfgAmmo" >> _ammo;
                            _maxHit = _maxHit max ((getNumber (_a >> "hit")) max 0 min 5000);
                            if (_ammo isKindOf ["MissileBase", configFile >> "CfgAmmo"] || {_ammo isKindOf ["RocketBase", configFile >> "CfgAmmo"]}) then {
                                if (getNumber (_a >> "airLock") >= 2) then { _airLock = true } else { _groundMissile = true };
                            };
                            if (_ammo isKindOf ["G_40mm_HE", configFile >> "CfgAmmo"] || {_ammo isKindOf ["G_20mm_HE", configFile >> "CfgAmmo"]}) then { _grenade = true };
                        } forEach (getArray (_t >> "magazines"));
                    } forEach _turrets;
                    private _role = switch (true) do {
                        case (_maxHit <= 0): {""};
                        case (_class isKindOf "StaticMortar"): {"MORTAR"};
                        case (getNumber (_cfg >> "artilleryScanner") == 1): {"HOWITZER"};
                        case (_groundMissile): {"AT"};
                        case (_airLock): {"AA"};
                        case (_grenade): {"GMG"};
                        default {"MG"};
                    };
                    // machine guns and grenade launchers from tier 2, the heavy weapons from tier 3
                    ["STATIC", [3, 2] select (_role in ["MG", "GMG", ""]), _role]
                };
                if (_class isKindOf "AllVehicles") exitWith {
                    private _vk = switch (true) do {
                        case (_class isKindOf "Air"): {"AIR"};
                        case (_class isKindOf "Ship"): {"BOAT"};
                        case (getNumber (_cfg >> "artilleryScanner") == 1): {"ARTILLERY"};
                        case (_class isKindOf "Tank" || {_class isKindOf "Wheeled_APC_F"}): {"ARMOUR"};
                        case (_class isKindOf "Truck_F"): {"TRUCK"};
                        default {"CAR"};
                    };
                    ["VEHICLE", 3, _vk]
                };
                if (_lc == "alive_fob_arsenal") exitWith { ["SUPPLY", 2, ""] };
                private _cat = getText (_cfg >> "editorCategory");
                private _sub = getText (_cfg >> "editorSubcategory");
                private _isService = (["transportAmmo", "transportFuel", "transportRepair", "attendant"] findIf { getNumber (_cfg >> _x) > 0 }) > -1;
                if (_isService && {_cat == "EdCat_Supplies" || {_sub == "EdSubcat_Military"}}) exitWith { ["SUPPLY", 1, ""] };
                if (_sub == "EdSubcat_Helipads") exitWith { ["SUPPLY", 1, ""] };
                // ammo and supply crates, the tablet's stores
                if (_cat == "EdCat_Supplies" || {_class isKindOf "ReammoBox_F"} || {_class isKindOf "ReammoBox"}) exitWith { ["SUPPLY", 1, ""] };
                // anything else placed is built as a fortification; towers from tier 2
                ["FORTIFICATION", [1, 2] select ("tower" in _lc || {"patrol" in _lc}), ""]
            };
            _cache set [_lc, _result];
        };
    };

    case "allows": {
        _args params ["_rules", ["_class", ""]];
        private _cfg = configFile >> "CfgVehicles" >> _class;
        private _isGear = false;
        private _real = _class;
        // a backpack sits in the class lists as well as the gear ones, and is judged by the class
        // lists, as the tablet always has; the kind cut still counts it as gear
        if (isClass _cfg) then { _real = configName _cfg } else {
            private _gearCfg = [_class] call _fnc_gearConfig;
            if (!isNull _gearCfg) then { _real = configName _gearCfg; _isGear = true };
        };
        private _set = ["Classes", "Gear"] select _isGear;
        _result = call {
            if (_real in (_rules getOrDefault ["never" + _set, []])) exitWith { false };
            if (_real in (_rules getOrDefault ["also" + _set, []])) exitWith { true };
            private _only = _rules getOrDefault ["only" + _set, []];
            if (_rules getOrDefault ["onlyObjects", false]) exitWith { (count _only == 0) || {_real in _only} };
            if !([_rules, _real] call _fnc_kindKept) exitWith { false };
            (count _only == 0) || {_real in _only}
        };
    };

    case "allowsGroup": {
        _args params ["_rules", ["_faction", ""], ["_group", ""]];
        _result = call {
            if ([_faction, _group, _rules getOrDefault ["neverGroups", []]] call _fnc_groupIn) exitWith { false };
            if ([_faction, _group, _rules getOrDefault ["alsoGroups", []]] call _fnc_groupIn) exitWith { true };
            private _kinds = _rules getOrDefault ["kinds", []];
            if (!(_rules getOrDefault ["onlyObjects", false]) && {_kinds isNotEqualTo []} && {!("TROOPS" in _kinds)}) exitWith { false };
            private _only = _rules getOrDefault ["onlyGroups", []];
            (count _only == 0) || {[_faction, _group, _only] call _fnc_groupIn}
        };
    };

    case "blocked": {
        _args params ["_rules", ["_forceMakeup", []]];
        _result = "";
        private _neverClasses = _rules getOrDefault ["neverClasses", []];
        private _neverGroups = _rules getOrDefault ["neverGroups", []];
        private _alsoClasses = _rules getOrDefault ["alsoClasses", []];
        private _alsoGroups = _rules getOrDefault ["alsoGroups", []];
        private _kinds = _rules getOrDefault ["kinds", []];
        private _cut = _kinds isNotEqualTo [] && {!(_rules getOrDefault ["onlyObjects", false])};
        if ((count _neverClasses + count _neverGroups > 0 || {_cut}) && {_forceMakeup isEqualType []}) then {
            // [requestID, crates and stores, vehicles, 3 x individuals, 3 x groups]
            private _isOut = {
                params ["_class"];
                private _real = if (isClass (configFile >> "CfgVehicles" >> _class)) then { configName (configFile >> "CfgVehicles" >> _class) } else { _class };
                (_real in _neverClasses) || {_cut && {!(_real in _alsoClasses)} && {!([_rules, _real] call _fnc_kindKept)}}
            };
            {
                if (_x isEqualType "" && {[_x] call _isOut}) exitWith { _result = _x };
            } forEach (_forceMakeup param [1, []]);
            if (_result == "") then {
                {
                    {
                        if (_x isEqualType [] && {[_x param [0, ""]] call _isOut}) exitWith { _result = _x select 0 };
                    } forEach (_forceMakeup param [_x, []]);
                    if (_result != "") exitWith {};
                } forEach [2, 3, 4, 5];
            };
            if (_result == "") then {
                private _troopsCut = _cut && {!("TROOPS" in _kinds)};
                {
                    {
                        if (_x isEqualType []) then {
                            _x params [["_group", ""], ["_info", []]];
                            private _faction = if (_info isEqualType []) then { _info param [1, ""] } else { "" };
                            if (_group isEqualType "" && {_faction isEqualType ""}
                                && {([_faction, _group, _neverGroups] call _fnc_groupIn) || {_troopsCut && {!([_faction, _group, _alsoGroups] call _fnc_groupIn)}}}) exitWith { _result = _group };
                        };
                    } forEach (_forceMakeup param [_x, []]);
                    if (_result != "") exitWith {};
                } forEach [6, 7, 8];
            };
        };
    };

    case "empty": {
        private _rules = _args;
        _result = (["onlyClasses", "neverClasses", "alsoClasses", "onlyGroups", "neverGroups", "alsoGroups", "onlyGear", "neverGear", "alsoGear", "kinds"] findIf { (_rules getOrDefault [_x, []]) isNotEqualTo [] }) < 0
            && {(_rules getOrDefault ["staticTier", -1]) < 0}
            && {!(_rules getOrDefault ["fieldWorksOnly", false])};
    };

    case "fold": {
        _args params [["_rules", createHashMap], ["_classes", []]];
        _result = _classes;
        if ((_rules getOrDefault ["fold", -1]) > 0) then {
            private _named = createHashMap;
            { _named set [toLower _x, true] } forEach ((_rules getOrDefault ["onlyClasses", []]) + (_rules getOrDefault ["alsoClasses", []]));
            // model and cargo -> [display name length, class name length, class name]; the order
            // kept is the first appearance of each, so a sorted list stays sorted. The cargo keeps
            // crates of different contents and ammo, fuel, repair and medical vehicles apart.
            private _best = createHashMap;
            private _order = [];
            {
                private _cfg = configFile >> "CfgVehicles" >> _x;
                private _model = toLower getText (_cfg >> "model");
                if (_model != "") then {
                    private _cargo = [];
                    {
                        private _kind = _x;
                        { _cargo pushBack (_kind + toLower getText (_x >> "name") + toLower getText (_x >> "magazine") + toLower getText (_x >> "weapon") + toLower getText (_x >> "backpack") + str getNumber (_x >> "count")) } forEach ("true" configClasses (_cfg >> _kind));
                    } forEach ["TransportMagazines", "TransportWeapons", "TransportItems", "TransportBackpacks"];
                    _cargo sort true;
                    _model = _model + "|" + (_cargo joinString ",") + "|" + str (["transportAmmo", "transportFuel", "transportRepair", "attendant"] apply { getNumber (_cfg >> _x) > 0 });
                };
                if (_x isKindOf "Man" || {_model == ""} || {(toLower _x) in _named}) then {
                    _order pushBack [_x];
                } else {
                    private _score = [count getText (_cfg >> "displayName"), count _x, toLower _x];
                    private _have = _best get _model;
                    if (isNil "_have") then {
                        _best set [_model, [_score, _x]];
                        _order pushBack _model;
                    } else {
                        // the plainest variant: shortest name, then shortest class name, then the
                        // first by spelling, so every machine keeps the same one
                        private _old = _have select 0;
                        private _better = call {
                            if ((_score select 0) != (_old select 0)) exitWith { (_score select 0) < (_old select 0) };
                            if ((_score select 1) != (_old select 1)) exitWith { (_score select 1) < (_old select 1) };
                            // strings don't compare with <, so sort the two
                            private _pair = [_score select 2, _old select 2];
                            _pair sort true;
                            (_pair select 0) == (_score select 2) && {(_score select 2) != (_old select 2)}
                        };
                        if (_better) then {
                            _best set [_model, [_score, _x]];
                        };
                    };
                };
            } forEach _classes;
            _result = _order apply { if (_x isEqualType []) then { _x select 0 } else { (_best get _x) select 1 } };
        };
    };

    case "describe": {
        // [rules, with the list's own bad names] - one line: what the rules keep, and the names not in this game
        _args params ["_rules", ["_withList", false]];
        private _kinds = _rules getOrDefault ["kinds", []];
        private _vk = _rules getOrDefault ["vehicleKinds", []];
        private _tier = _rules getOrDefault ["staticTier", -1];
        private _n = { params ["_box"]; count (_rules getOrDefault [_box + "Classes", []]) + count (_rules getOrDefault [_box + "Groups", []]) + count (_rules getOrDefault [_box + "Gear", []]) };
        private _bad = (_rules getOrDefault ["missing", []]) apply { format ["%1 (%2)", _x select 0, _x select 1] };
        if (_withList) then { _bad append ((_rules getOrDefault ["listMissing", []]) apply { format ["%1 (%2 in list %3)", _x select 0, _x select 1, _rules getOrDefault ["name", ""]] }) };
        _result = format ["kinds %1%2%3%4%5, only %6, never %7, also %8, %9 prices%10",
            ["every kind", _kinds joinString " "] select (_kinds isNotEqualTo []),
            ["", format [", vehicles %1", _vk joinString " "]] select (_vk isNotEqualTo []),
            ["", format [", statics to tier %1", _tier]] select (_tier >= 0),
            ["", ", field works only"] select (_rules getOrDefault ["fieldWorksOnly", false]),
            ["", ", one of each model"] select ((_rules getOrDefault ["fold", -1]) > 0),
            ["only"] call _n, ["never"] call _n, ["also"] call _n,
            count (_rules getOrDefault ["prices", createHashMap]),
            ["", format ["; %1 not in this game: %2", count _bad, _bad joinString ", "]] select (_bad isNotEqualTo [])
        ];
    };

    // [text] on the server - a list problem a mission maker should fix: kept for admins who join later,
    // and shown to every admin as a hint (main's postInit listens on players' machines)
    case "problem": {
        if (!isServer) exitWith {};
        if (isNil "ALiVE_lists_problems") then { ALiVE_lists_problems = [] };
        if (_args isEqualType "" && {!(_args in ALiVE_lists_problems)}) then {
            ALiVE_lists_problems pushBack _args;
            publicVariable "ALiVE_lists_problems";
            // a public variable's handler doesn't run where it was sent from: a hosted or SP server shows it here
            if (hasInterface) then { ["show"] call ALIVE_fnc_lists };
        };
    };

    // a hint to an admin of what's wrong with the mission's lists, with the RPT for the rest
    case "show": {
        if (!hasInterface || {!(call ALIVE_fnc_isServerAdmin)}) exitWith {};
        private _all = missionNamespace getVariable ["ALiVE_lists_problems", []];
        if (_all isEqualTo []) exitWith {};
        hintSilent parseText format ["<t size='1.1'>ALiVE lists: %1 to fix</t><br/><t align='left' size='0.9'>%2%3</t><br/><t size='0.8'>The server's RPT has the full lists report (ALiVE Lists).</t>",
            [format ["%1 problems", count _all], "1 problem"] select (count _all == 1),
            ((_all select [0, 3]) apply { "- " + (_x regexReplace ["<", "&lt;"]) }) joinString "<br/>",
            ["", format ["<br/>and %1 more", count _all - 3]] select (count _all > 3)];
    };

    case "report": {
        private _names = [];
        { _names pushBackUnique configName _x } forEach ("true" configClasses (configFile >> "CfgALiVELists"));
        { _names pushBackUnique configName _x } forEach ("true" configClasses (missionConfigFile >> "CfgALiVELists"));
        {
            private _rules = ["get", _x] call ALIVE_fnc_lists;
            private _from = ["mod", "mission"] select (isClass (missionConfigFile >> "CfgALiVELists" >> _x));
            ["ALiVE Lists: %1 (%2) - %3", _x, _from, ["describe", [_rules, true]] call ALIVE_fnc_lists] call ALiVE_fnc_dump;
            private _bad = _rules getOrDefault ["listMissing", []];
            if (_bad isNotEqualTo []) then { ["problem", format ["list %1 names %2, not in this game", _x, (_bad apply { _x select 0 }) joinString ", "]] call ALIVE_fnc_lists };
        } forEach _names;
        _result = count _names;
    };
};

if (isNil "_result") then { nil } else { _result }
