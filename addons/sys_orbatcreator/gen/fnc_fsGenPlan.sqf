#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsGenPlan);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsGenPlan

Description:
Turns a faction into an export plan: final class names, the order things are
written in, generated backpacks, turret stubs, groups with their member classes
and positions, the old mod names to keep, dependencies, and every problem. It is
the one place where names and problems are decided, so the generators only
print. Nothing is written. Always given the export's own snapshot, never the
faction being edited.

Errors (the export stops): E_NO_UNITS, E_COLLISION, E_MISSING_BASE (an entry on
a missing base that a group or a vehicle crew needs), E_BAD_LOADOUT, E_OPT_SETS.
The rest are warnings (the N_ ones are notes, shown with them).

Optional entries: a unit or vehicle ticked Optional goes in an optional part,
with every vehicle that has him in a seat and every group he or that vehicle is
in. The main part's mods are worked out from the rest alone; an optional entry's
set is what it needs beyond them, and entries with the same set share one part,
ALiVE_FS_<TAG>_O_<6 hex of the sorted set>. Backpacks and turret stubs go with
the parts that use them (a copy in each optional part when no main entry does).
The crates are made from the main part's men. With nothing ticked, the plan is
the same as before optional parts existed.

Parameters:
    _faction - HASHMAP - the snapshot

Returns:
    HASHMAP - the plan (keys in the spec's table: tag, tagLower, patch, prefix,
    pbo, fnc, root, men, vehicles, classOf, backpacks, packOf, stubs, parentOf,
    crewOf, gunnersOf, pylonsOf, stubTreeOf,
    forward, subcats, subOf, groups, legacy, deps, errors, warnings,
    hook, crates, alive, aliveTypes, menAll, optional). men, vehicles,
    backpacks, stubs, forward and groups are the main part's; menAll is every
    man written; optional is a list, one per optional part, of
    [patch, mod names, men, vehicles, groups (category to list, as groups),
    addons, forward, stubs, backpacks, pbo, prefix, mods (rows as deps mods)]

Examples:
    (begin example)
    private _plan = [_snapshot] call ALiVE_fnc_fsGenPlan;
    if (count (_plan get "errors") > 0) then { ... };
    (end)

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_faction", createHashMap, [createHashMap]]];

private _errors = [];
private _warnings = [];
private _tag = _faction getOrDefault ["tag", ""];
private _tagLower = toLower _tag;
private _patch = "ALiVE_FS_" + _tag;
private _side = _faction getOrDefault ["side", 1];
private _units = _faction getOrDefault ["units", createHashMap];
private _vehicles = _faction getOrDefault ["vehicles", createHashMap];
private _groupsIn = _faction getOrDefault ["groups", createHashMap];
private _legacyIn = (_faction getOrDefault ["meta", createHashMap]) getOrDefault ["legacyPatches", []];
private _legacyLower = _legacyIn apply { toLower _x };
private _isLoaded = { isClass (configFile >> "CfgVehicles" >> _this) };

// the faction class: taken by another mod is a collision; this faction's own earlier export is fine
private _factionClass = _faction getOrDefault ["class", _tag];
private _fcfg = configFile >> "CfgFactionClasses" >> _factionClass;
if (isClass _fcfg) then {
    private _from = (configSourceAddonList _fcfg) param [0, "CfgFactionClasses"];
    private _own = (getText (_fcfg >> "ALiVE_FS_tag")) == _tag || {(toLower _from) in _legacyLower};
    if (!_own) then { _errors pushBack ["E_COLLISION", [_factionClass, _from]] };
};
private _pcfg = configFile >> "CfgPatches" >> _patch;
if (isClass _pcfg && {!((getText (_pcfg >> "ALiVE_FS_id")) isEqualTo (_faction getOrDefault ["id", ""]))}) then {
    _warnings pushBack ["W_SAME_TAG", [_tag]];
};

// the entries to write, in list order; one on a missing base is left out
private _men = [];
private _vehs = [];
private _missing = createHashMap;
{
    private _e = _units getOrDefault [_x, createHashMap];
    if (count _e > 0) then {
        if ((_e getOrDefault ["base", ""]) call _isLoaded) then {
            _men pushBack _x;
            if !(([_e getOrDefault ["loadout", []]] call ALiVE_fnc_fsDataLoadoutCheck) param [0, false]) then {
                _errors pushBack ["E_BAD_LOADOUT", [_e getOrDefault ["name", _x]]];
            };
        } else {
            _missing set [_x, true];
        };
    };
} forEach (_faction getOrDefault ["unitOrder", []]);
{
    private _e = _vehicles getOrDefault [_x, createHashMap];
    if (count _e > 0) then {
        if ((_e getOrDefault ["base", ""]) call _isLoaded) then { _vehs pushBack _x } else { _missing set [_x, true] };
    };
} forEach (_faction getOrDefault ["vehicleOrder", []]);
if ((count _men) + (count _vehs) == 0) then { _errors pushBack ["E_NO_UNITS", []] };

private _entryOf = { _units getOrDefault [_this, _vehicles getOrDefault [_this, createHashMap]] };
private _missingNeeded = createHashMap;
private _needs = {
    // _this: an id that something written needs
    if (_this in _missing && {!(_this in _missingNeeded)}) then {
        _missingNeeded set [_this, true];
        private _e = _this call _entryOf;
        _errors pushBack ["E_MISSING_BASE", [_e getOrDefault ["name", _this], _e getOrDefault ["base", ""]]];
    };
};
// reported once each; the export goes on without them unless something needs them
private _missingNote = [];

// final class names, checked again: the loaded mods may have changed since they were typed
private _classOf = createHashMap;
private _oldLoaded = createHashMap;
{
    private _id = _x;
    private _e = _id call _entryOf;
    private _class = _e getOrDefault ["class", ""];
    (["check", _faction, _class, _id, ["unit", "vehicle"] select (_id in _vehicles)] call ALiVE_fnc_fsDataClassName) params ["_ok", "_hit"];
    if (_ok) then {
        if (!(_hit isEqualTo "") && {_class call _isLoaded} && {!(_hit in _oldLoaded)}) then {
            _oldLoaded set [_hit, true];
            _warnings pushBack ["W_OLD_LOADED", [_class, _hit]];
        };
    } else {
        private _where = if (_hit in _units || {_hit in _vehicles}) then { (_hit call _entryOf) getOrDefault ["name", _hit] } else { [_hit, "CfgVehicles"] select (_hit isEqualTo "") };
        _errors pushBack ["E_COLLISION", [_class, _where]];
    };
    _classOf set [_id, _class];
} forEach (_men + _vehs);

// optional entries: their parts (the header says how). With none ticked, nothing here runs
private _partOf = createHashMap;
private _sets = [];
private _setAddons = createHashMap;
private _reqView = _faction;
private _full = createHashMap;
private _part = { _partOf getOrDefault [_this, ""] };
private _anyOpt = ((_men + _vehs) findIf { (_x call _entryOf) getOrDefault ["optional", false] }) >= 0;
if (_anyOpt) then {
    _full = [_faction] call ALiVE_fnc_fsGenDeps;
    private _ofAll = _full get "of";
    private _spell = createHashMap;
    { _spell set [toLower _x, _x] } forEach (keys (_full get "counts"));
    // the faction without the optional entries; without its crates when _hook is false
    private _view = {
        params ["_skipE", "_skipG", "_hook"];
        private _v = createHashMap;
        { _v set [_x, _y] } forEach _faction;
        {
            _x params ["_key", "_skip"];
            private _d = createHashMap;
            { if !(_x in _skip) then { _d set [_x, _y] } } forEach (_faction getOrDefault [_key, createHashMap]);
            _v set [_key, _d];
        } forEach [["units", _skipE], ["vehicles", _skipE], ["groups", _skipG]];
        if (!_hook) then {
            private _al = +(_faction getOrDefault ["alive", createHashMap]);
            _al set ["hook", false];
            _v set ["alive", _al];
        };
        _v
    };
    private _seats = { private _e = _vehicles get _this; [_e getOrDefault ["crewUnit", ""]] + ((_e getOrDefault ["turrets", []]) apply { _x getOrDefault ["gunnerUnit", ""] }) };
    private _ticked = createHashMap;
    { if ((_x call _entryOf) getOrDefault ["optional", false]) then { _ticked set [_x, true] } } forEach (_men + _vehs);
    private _nothing = [];
    private _opt = createHashMap;
    private _optG = createHashMap;
    private _pulled = [];
    private _req = createHashMap;
    private _setOf = createHashMap;
    private _again = true;
    while {_again} do {
        _again = false;
        _opt = +_ticked;
        _pulled = [];
        // a vehicle with an optional man in a seat goes with him
        {
            if (!(_x in _opt) && {((_x call _seats) findIf { _x in _opt }) >= 0}) then {
                _opt set [_x, true];
                _pulled pushBack _x;
            };
        } forEach _vehs;
        // a group with an optional member is optional
        _optG = createHashMap;
        {
            if ((((_groupsIn getOrDefault [_x, createHashMap]) getOrDefault ["members", []]) findIf { (_x getOrDefault ["ref", ""]) in _opt }) >= 0) then { _optG set [_x, true] };
        } forEach (_faction getOrDefault ["groupOrder", []]);
        // the main part's addons (lower-case), crates not counted yet
        _req = createHashMap;
        { _req set [toLower _x, true] } forEach (([[_opt, _optG, false] call _view] call ALiVE_fnc_fsGenDeps) get "addons");
        private _union = { params ["_into", "_from"]; { _into set [_x, true] } forEach (keys _from) };
        private _beyond = {
            private _m = createHashMap;
            { if !(_x in _req) then { _m set [_x, true] } } forEach (_ofAll getOrDefault [_this, []]);
            _m
        };
        // each optional entry's set: men, then vehicles with their men's sets, then groups with their members'
        _setOf = createHashMap;
        { if (_x in _units) then { _setOf set [_x, _x call _beyond] } } forEach (keys _opt);
        {
            if (_x in _vehicles) then {
                private _m = _x call _beyond;
                { if (_x in _setOf) then { [_m, _setOf get _x] call _union } } forEach (_x call _seats);
                _setOf set [_x, _m];
            };
        } forEach (keys _opt);
        {
            private _m = _x call _beyond;
            {
                private _r = _x getOrDefault ["ref", ""];
                if (_r in _setOf) then { [_m, _setOf get _r] call _union };
            } forEach ((_groupsIn get _x) getOrDefault ["members", []]);
            _setOf set [_x, _m];
        } forEach (keys _optG);
        // ticked, but it needs nothing beyond the main part: it is written there
        {
            if (count (_setOf getOrDefault [_x, createHashMap]) == 0) then {
                _ticked deleteAt _x;
                _nothing pushBack _x;
                _again = true;
            };
        } forEach (keys _ticked);
    };
    { _warnings pushBack ["N_OPT_NOTHING", [(_x call _entryOf) getOrDefault ["name", _x]]] } forEach _nothing;
    // the sets, in faction order
    {
        if (_x in _setOf) then {
            private _l = keys (_setOf get _x);
            _l sort true;
            private _k = _l joinString ",";
            _partOf set [_x, _k];
            if !(_k in _setAddons) then {
                _sets pushBack _k;
                _setAddons set [_k, _l apply { _spell getOrDefault [_x, _x] }];
            };
        };
    } forEach (_men + _vehs + (_faction getOrDefault ["groupOrder", []]));
    private _modOf = _full get "modOf";
    {
        private _names = [];
        { private _m = _modOf getOrDefault [toLower _x, _x]; if !(_m in _names) then { _names pushBack _m } } forEach (_setAddons get (_partOf get _x));
        _warnings pushBack ["N_OPT_PULLED", [(_vehicles get _x) getOrDefault ["name", _x], _names joinString ", "]];
    } forEach _pulled;
    if (count _sets > FS_MAX_OPT_PATCHES) then { _errors pushBack ["E_OPT_SETS", [(count _sets) toFixed 0, FS_MAX_OPT_PATCHES toFixed 0]] };
    // the main part, crates included; a crate row set by hand that only an optional part's mods give is left out
    _reqView = [_opt, _optG, true] call _view;
    private _optAddons = createHashMap;
    { { _optAddons set [toLower _x, true] } forEach _y } forEach _setAddons;
    private _aliveV = _reqView getOrDefault ["alive", createHashMap];
    if !("crates" in (_aliveV getOrDefault ["auto", FS_ALIVE_LISTS])) then {
        _aliveV = +_aliveV;
        private _addonOf = {
            private _class = _this;
            private _root = ["CfgWeapons", "CfgMagazines", "CfgVehicles", "CfgGlasses"] select { isClass (configFile >> _x >> _class) } param [0, ""];
            if (_root isEqualTo "") exitWith { "" };
            toLower ((configSourceAddonList (configFile >> _root >> _class)) param [0, ""])
        };
        {
            private _crate = _x;
            _crate set ["cargo", (_crate getOrDefault ["cargo", []]) select {
                private _c = _x getOrDefault ["class", ""];
                private _drop = (_c call _addonOf) in _optAddons;
                if (_drop) then { _warnings pushBack ["W_OPT_CRATE", [_crate getOrDefault ["name", ""], _c]] };
                !_drop
            }];
        } forEach (_aliveV getOrDefault ["crates", []]);
        _reqView set ["alive", _aliveV];
    };
};

// the class of a member, crew or gunner reference: one of ours, or an outside class
private _refClass = {
    params ["_unitId", "_class"];
    if !(_unitId isEqualTo "") exitWith { _unitId call _needs; _classOf getOrDefault [_unitId, ""] };
    _class
};

// generated backpacks: one class per real backpack and contents, shared by every man that carries it
private _backpacks = [];
private _packOf = createHashMap;
private _packKeys = createHashMap;
private _forward = createHashMap;
// per optional part: its own forward declarations, and which parts use each backpack and each stub chain
private _fwdOf = createHashMap;
private _packUsers = createHashMap;
private _stubUsers = createHashMap;
private _fwd = {
    params ["_class", "_p"];
    if (_class isEqualTo "") exitWith {};
    if (_p isEqualTo "") then { _forward set [toLower _class, _class] } else {
        private _m = _fwdOf getOrDefault [_p, createHashMap];
        _m set [toLower _class, _class];
        _fwdOf set [_p, _m];
    };
};
private _addForward = { [_this, ""] call _fwd };
{
    private _e = _units get _x;
    private _p = _x call _part;
    [_e getOrDefault ["base", ""], _p] call _fwd;
    private _la = [_e getOrDefault ["loadout", []]] call ALiVE_fnc_fsGenLoadoutArrays;
    private _pack = _la get "backpack";
    private _contents = _la get "pack";
    if (!(_pack isEqualTo "") && {(_contents findIf { count _x > 0 }) >= 0}) then {
        private _key = toLower str [_pack, _contents];
        private _class = _packKeys getOrDefault [_key, ""];
        if (_class isEqualTo "") then {
            _class = format ["%1_pack_%2", _tag, ((count _backpacks) + 1) toFixed 0];
            _packKeys set [_key, _class];
            _backpacks pushBack [_class, _pack, _contents select 0, _contents select 1, _contents select 2];
        };
        [_pack, _p] call _fwd;
        private _users = _packUsers getOrDefault [_class, []];
        _users pushBackUnique _p;
        _packUsers set [_class, _users];
        _packOf set [_x, _class];
    };
} forEach _men;

// vehicles: stubs only for a base where a gunner or a pylon is set. The stubs name, one level at a time, the
// base's classes a vehicle writes into: its Turrets (and a turret's own Turrets down to a nested seat that is
// set) and Components >> TransportPylonsComponent >> Pylons. A stub sk declares the classes at depth k of
// that tree (ALiVE_fnc_fsGenTree), and each vehicle on the stubs writes the whole tree again. Named with the
// tag (#872): two factions never share one
private _stubs = [];
private _parentOf = createHashMap;
private _crewOf = createHashMap;
private _gunnersOf = createHashMap;
private _pylonsOf = createHashMap;
private _treeOf = createHashMap;
private _valuesOf = createHashMap;
// per base (lowercase): [base, paths, depth]
private _bases = createHashMap;
private _q = { [_this] call ALiVE_fnc_fsGenQuote };
private _pylonNames = {
    params ["_base"];
    (configProperties [configFile >> "CfgVehicles" >> _base >> "Components" >> "TransportPylonsComponent" >> "Pylons", "isClass _x", true]) apply { configName _x }
};
// a turret's config from its seat path ("MainTurret/CommanderOptics")
private _turretCfg = {
    params ["_base", "_seat"];
    private _c = configFile >> "CfgVehicles" >> _base;
    { _c = _c >> "Turrets" >> _x } forEach (_seat splitString "/");
    _c
};
// configClasses, not configProperties: a parent's bare "class X;" names no turret, and declaring it would add an empty one
private _realTurrets = { ("true" configClasses (_this >> "Turrets")) apply { configName _x } };
{
    private _id = _x;
    private _e = _vehicles get _id;
    private _base = _e getOrDefault ["base", ""];
    [_base, _id call _part] call _fwd;
    private _name = _e getOrDefault ["name", _id];
    private _crew = [_e getOrDefault ["crewUnit", ""], _e getOrDefault ["crewClass", ""]] call _refClass;
    _crewOf set [_id, _crew];
    private _values = createHashMap;
    private _paths = [];
    private _add = { private _p = _this; if ((_paths findIf { _x == _p }) < 0) then { _paths pushBack _p } };
    // gunners, nested seats too: the path to a seat names each turret's Turrets on the way
    private _gunners = [];
    {
        private _g = [_x getOrDefault ["gunnerUnit", ""], _x getOrDefault ["gunnerClass", ""]] call _refClass;
        private _seat = _x getOrDefault ["cfg", ""];
        if (!(_g isEqualTo "") && {isClass ([_base, _seat] call _turretCfg)}) then {
            _gunners pushBack [_seat, _g];
            private _parts = _seat splitString "/";
            private _cfgPath = "Turrets";
            private _done = [];
            {
                // every real turret at this level, so none of them is lost
                private _at = if (_done isEqualTo []) then { configFile >> "CfgVehicles" >> _base } else { [_base, _done joinString "/"] call _turretCfg };
                _cfgPath call _add;
                private _level = _cfgPath;
                { (_level + "/" + _x) call _add } forEach (_at call _realTurrets);
                _done pushBack _x;
                _cfgPath = _cfgPath + "/" + _x + "/Turrets";
            } forEach _parts;
            _values set [toLower ("Turrets/" + (_parts joinString "/Turrets/")), format ["gunnerType = %1;", _g call _q]];
        };
    } forEach (_e getOrDefault ["turrets", []]);
    _gunnersOf set [_id, _gunners];
    // pylons: [pylon class, magazine] for each one set ("" keeps the base's)
    private _names = [_base] call _pylonNames;
    private _pylons = [];
    {
        if (_forEachIndex < count _names && {!(_x isEqualTo "")}) then { _pylons pushBack [_names select _forEachIndex, _x] };
    } forEach (_e getOrDefault ["pylons", []]);
    _pylonsOf set [_id, _pylons];
    if (count _pylons > 0) then {
        private _top = "Components/TransportPylonsComponent/Pylons";
        { _x call _add } forEach ["Components", "Components/TransportPylonsComponent", _top];
        { (_top + "/" + _x) call _add } forEach _names;
        { _values set [toLower (_top + "/" + (_x select 0)), format ["attachment = %1;", (_x select 1) call _q]] } forEach _pylons;
    };
    _valuesOf set [_id, _values];
    if (count _paths > 0) then {
        private _key = toLower _base;
        private _b = _bases getOrDefault [_key, [_base, [], 0]];
        { private _p = _x; if (((_b select 1) findIf { _x == _p }) < 0) then { (_b select 1) pushBack _p } } forEach _paths;
        _b set [2, (_b select 2) max (selectMax (_paths apply { count (_x splitString "/") }))];
        _bases set [_key, _b];
        _treeOf set [_id, _key];
        private _users = _stubUsers getOrDefault [_key, []];
        _users pushBackUnique (_id call _part);
        _stubUsers set [_key, _users];
    };
    if (count _gunners > 0) then {
        // ALiVE crews every seat of a profiled vehicle from crew alone
        private _crewNow = if (_crew isEqualTo "") then { getText (configFile >> "CfgVehicles" >> _base >> "crew") } else { _crew };
        if ((_gunners findIf { (toLower (_x select 1)) != toLower _crewNow }) >= 0) then {
            _warnings pushBack ["W_ALIVE_CREW", [_name, _crewNow]];
        };
    };
} forEach _vehs;
// one chain per base: [base, [s1 .. sN], paths]; a vehicle on it takes sN and writes the whole tree
private _lastOf = createHashMap;
{
    _y params ["_base", "_paths", "_depth"];
    private _names = [];
    for "_k" from 1 to _depth do { _names pushBack format ["%1_FS_%2_s%3", _base, _tag, _k] };
    _stubs pushBack [_base, _names, _paths];
    _lastOf set [_x, _names select (count _names - 1)];
} forEach _bases;
private _stubTreeOf = createHashMap;
{
    private _base = (_vehicles get _x) getOrDefault ["base", ""];
    private _key = _treeOf getOrDefault [_x, ""];
    if (_key isEqualTo "") then {
        _parentOf set [_x, _base];
    } else {
        _parentOf set [_x, _lastOf get _key];
        _stubTreeOf set [_x, [(_bases get _key) select 1, _valuesOf get _x]];
    };
} forEach _vehs;

// Eden subcategories in use
private _cats = _faction getOrDefault ["categories", createHashMap];
private _subcats = [];
private _subOf = createHashMap;
{
    private _c = (_x call _entryOf) getOrDefault ["category", ""];
    if (!(_c in _subOf) && {_c in _cats}) then {
        private _sub = format ["ALiVE_FS_%1_%2", _tag, _c];
        _subOf set [_c, _sub];
        _subcats pushBack [_sub, (_cats get _c) getOrDefault ["name", _c]];
    };
} forEach (_men + _vehs);

// groups by category; a civilian faction has none (the game has no civilian group root)
private _groups = createHashMap;
// per optional part: its groups, as _groups; and every category that has groups in any part
private _groupsOf = createHashMap;
private _allCats = createHashMap;
private _groupCount = 0;
if (count _groupsIn > 0 && {_side == 3}) then {
    _warnings pushBack ["W_CIV_GROUPS", []];
} else {
    {
        private _g = _groupsIn getOrDefault [_x, createHashMap];
        private _members = [];
        private _hasVehicle = false;
        {
            private _ref = _x getOrDefault ["ref", ""];
            private _class = "";
            private _mside = _side;
            if ((_ref select [0, 1]) == "#") then {
                _class = _ref select [1];
                if (_class call _isLoaded) then {
                    _mside = getNumber (configFile >> "CfgVehicles" >> _class >> "side");
                } else {
                    _errors pushBack ["E_MISSING_BASE", [_g getOrDefault ["name", ""], _class]];
                    _class = "";
                };
            } else {
                _class = [_ref, ""] call _refClass;
            };
            if !(_class isEqualTo "") then {
                if !(_class isKindOf "Man") then { _hasVehicle = true };
                _members pushBack [_class, _x getOrDefault ["rank", "PRIVATE"], _x getOrDefault ["pos", []], _mside];
            };
        } forEach (_g getOrDefault ["members", []]);
        if (count _members > 0) then {
            // positions not set: the leader at the centre, the rest in a widening V behind him
            private _s = [5, 15] select _hasVehicle;
            {
                if !((_x select 2) isEqualType [] && {count (_x select 2) == 3}) then {
                    private _i = _forEachIndex;
                    private _step = ceil (_i / 2);
                    private _px = _step * _s * ([1, -1] select (_i % 2 == 0));
                    _x set [2, [_px, -_step * _s, 0]];
                };
            } forEach _members;
            private _cat = _g getOrDefault ["category", "Infantry"];
            private _p = _x call _part;
            private _into = _groups;
            if !(_p isEqualTo "") then {
                if !(_p in _groupsOf) then { _groupsOf set [_p, createHashMap] };
                _into = _groupsOf get _p;
            };
            private _list = _into getOrDefault [_cat, []];
            _list pushBack [_g getOrDefault ["class", ""], _g getOrDefault ["name", ""], _g getOrDefault ["icon", ""], _g getOrDefault ["rarity", 0.5], _members];
            _into set [_cat, _list];
            _allCats set [_cat, true];
            _groupCount = _groupCount + 1;
        };
    } forEach (_faction getOrDefault ["groupOrder", []]);
    if (_groupCount == 0) then {
        if (_side != 3) then { _warnings pushBack ["W_NO_GROUPS", []] };
    } else {
        if !("Infantry" in _allCats) then { _warnings pushBack ["W_EMPTY_CAT", ["Infantry"]] };
        // the same checks on the main part alone: categories that have groups only with an optional part loaded
        private _only = (keys _allCats) select { !(_x in _groups) };
        if (count _only > 0) then {
            _only sort true;
            _warnings pushBack ["W_OPT_ONLY", [_only joinString ", "]];
        };
    };
};

// missing entries nothing needs: left out, and said so
{
    if !(_x in _missingNeeded) then {
        private _e = _x call _entryOf;
        _warnings pushBack ["E_MISSING_BASE", [_e getOrDefault ["name", _x], _e getOrDefault ["base", ""]]];
    };
} forEach (keys _missing);

// old mod names: kept unless another loaded mod still defines the name
private _legacy = _legacyIn select {
    private _c = configFile >> "CfgPatches" >> _x;
    !((toLower _x) isEqualTo (toLower _patch)) && {!(isClass _c) || {(getText (_c >> "ALiVE_FS_tag")) == _tag} || {((getArray (_c >> "requiredAddons")) apply { toLower _x }) isEqualTo [toLower _patch]}}
};
if (count _legacy > 0) then { _warnings pushBack ["W_LEGACY_PATCH", [_legacy joinString ", "]] };

// ALiVE: the supply crates and the CfgALiVEFactions block (ALiVE_fnc_fsGenAlive)
private _aliveIn = _faction getOrDefault ["alive", createHashMap];
private _hook = _aliveIn getOrDefault ["hook", true];
private _crates = [];
private _aliveLists = createHashMap;
private _aliveTypes = [];
if (_hook) then {
    private _crateMaps = [];
    if (_side != 3) then {
        {
            private _crate = _x;
            private _class = _crate getOrDefault ["class", ""];
            private _base = _crate getOrDefault ["base", ""];
            private _rows = (_crate getOrDefault ["cargo", []]) select { !((_x getOrDefault ["class", ""]) isEqualTo "") };
            if (!(_base call _isLoaded)) then {
                _warnings pushBack ["W_GEAR_MISSING", [_crate getOrDefault ["name", _class], _base]];
            } else {
                (["check", _faction, _class, "", "unit"] call ALiVE_fnc_fsDataClassName) params ["_ok", "_hit"];
                if (!_ok) then {
                    private _where = if (_hit in _units || {_hit in _vehicles}) then { (_hit call _entryOf) getOrDefault ["name", _hit] } else { [_hit, "CfgVehicles"] select (_hit isEqualTo "") };
                    _errors pushBack ["E_COLLISION", [_class, _where]];
                } else {
                    if (!(_hit isEqualTo "") && {_class call _isLoaded} && {!(_hit in _oldLoaded)}) then {
                        _oldLoaded set [_hit, true];
                        _warnings pushBack ["W_OLD_LOADED", [_class, _hit]];
                    };
                    _crates pushBack [_class, _base, _crate getOrDefault ["name", _class], _rows, _crate getOrDefault ["key", ""]];
                    _crateMaps pushBack _crate;
                    _base call _addForward;
                };
            };
        } forEach (([_reqView] call ALiVE_fnc_fsAliveCrates) select 0);
    };
    // every list as class names: a vehicle id through its final class, an outside class as it is
    private _picks = [_faction, _crateMaps] call ALiVE_fnc_fsAlivePicks;
    {
        private _name = _x;
        private _out = [];
        {
            // a vehicle on a missing base is left out of the list (it is reported as left out of the mod)
            private _c = if ((_x select [0, 1]) isEqualTo "#") then { _x select [1] } else { _classOf getOrDefault [_x, ""] };
            if (!(_c isEqualTo "") && {(_out findIf { _x == _c }) < 0}) then { _out pushBack _c };
        } forEach (_picks getOrDefault [_name, []]);
        _aliveLists set [_name, _out];
    } forEach ["supplies", "supports", "transport", "airTransport", "containers", "aa"];
    // redirects only to a category that has groups
    {
        private _from = _x getOrDefault ["from", ""];
        private _to = _x getOrDefault ["to", ""];
        switch (true) do {
            case (_to in _groups): { _aliveTypes pushBack [_from, _to] };
            // kept: with the optional part loaded the category has groups
            case (_to in _allCats): { _aliveTypes pushBack [_from, _to]; _warnings pushBack ["W_OPT_REDIRECT", [_from, _to]] };
            default { _warnings pushBack ["W_ALIVE_REDIRECT", [_from, _to]] };
        };
    } forEach (_aliveIn getOrDefault ["redirects", []]);
    // the faction's own earlier export, loaded here, had no ALiVE block
    if (isClass _pcfg && {(getText (_pcfg >> "ALiVE_FS_id")) isEqualTo (_faction getOrDefault ["id", ""])} && {getNumber (_pcfg >> "ALiVE_FS_alive") != 1}) then {
        _warnings pushBack ["W_ALIVE_ADDED", []];
    };
} else {
    _warnings pushBack ["W_ALIVE_OFF", []];
};
// ALiVE categories that are empty but that AUTO GROUPS could fill
if (_side != 3 && {_groupCount > 0}) then {
    private _fillable = (([_faction] call ALiVE_fnc_fsAliveCheck) select { (_x select 1) isEqualTo "fillable" && {!((_x select 0) isEqualTo "Infantry")} }) apply { _x select 0 };
    if (count _fillable > 0) then { _warnings pushBack ["W_ALIVE_EMPTY", [_fillable joinString ", "]] };
};

private _deps = [_reqView] call ALiVE_fnc_fsGenDeps;
_warnings append (_deps get "warnings");
{
    _x params ["_mod", "", "_official", "_n"];
    if (!_official) then { _warnings pushBack ["W_DEP", [_mod, _n toFixed 0]] };
} forEach (_deps get "mods");

// the parts: the main part's lists, then one row per optional part
private _menMain = _men select { (_x call _part) isEqualTo "" };
private _vehsMain = _vehs select { (_x call _part) isEqualTo "" };
private _optional = [];
if (_anyOpt) then {
    private _modOf = _full get "modOf";
    private _modRows = _full get "mods";
    // a backpack or a stub chain no main entry uses is written in every optional part that does
    {
        _x params ["_class", "_users"];
        if (!("" in _users) && {count _users > 1}) then { _warnings pushBack ["N_OPT_SHARED", [_class, (count _users) toFixed 0]] };
    } forEach ((_backpacks apply { [_x select 0, _packUsers getOrDefault [_x select 0, []]] }) + (_stubs apply { [_x select 0, _stubUsers getOrDefault [toLower (_x select 0), []]] }));
    {
        private _k = _x;
        private _addons = _setAddons get _k;
        private _names = [];
        { private _m = _modOf getOrDefault [toLower _x, _x]; if !(_m in _names) then { _names pushBack _m } } forEach _addons;
        // the name: 6 hex of the set, two 12-bit sums so every step is a whole number a float holds exactly
        private _a = 7;
        private _b = 11;
        { _a = ((_a * 31) + _x) mod 4093; _b = ((_b * 131) + _x) mod 4091 } forEach (toArray _k);
        private _hash = "";
        { _hash = _hash + ("0123456789abcdef" select [floor (_x / 256), 1]) + ("0123456789abcdef" select [floor ((_x mod 256) / 16), 1]) + ("0123456789abcdef" select [_x mod 16, 1]) } forEach [_a, _b];
        private _optPatch = _patch + "_O_" + _hash;
        private _optMen = _men select { (_x call _part) isEqualTo _k };
        private _optVehs = _vehs select { (_x call _part) isEqualTo _k };
        private _optGroups = _groupsOf getOrDefault [_k, createHashMap];
        private _gn = 0;
        { _gn = _gn + count _x } forEach (values _optGroups);
        _optional pushBack [
            _optPatch,
            _names,
            _optMen,
            _optVehs,
            _optGroups,
            _addons,
            values (_fwdOf getOrDefault [_k, createHashMap]),
            _stubs select { _k in (_stubUsers getOrDefault [toLower (_x select 0), []]) },
            _backpacks select { private _u = _packUsers getOrDefault [_x select 0, []]; !("" in _u) && {_k in _u} },
            "alive_fs_" + _tagLower + "_o_" + _hash,
            "alive_fs\" + _tagLower + "_o_" + _hash,
            _modRows select { (_x select 0) in _names }
        ];
        _warnings pushBack ["N_OPT_PATCH", [_optPatch, _names joinString ", ", (count _optMen) toFixed 0, (count _optVehs) toFixed 0, _gn toFixed 0]];
    } forEach _sets;
    _stubs = _stubs select { "" in (_stubUsers getOrDefault [toLower (_x select 0), []]) };
    _backpacks = _backpacks select { "" in (_packUsers getOrDefault [_x select 0, []]) };
};

createHashMapFromArray [
    ["tag", _tag],
    ["tagLower", _tagLower],
    ["patch", _patch],
    ["prefix", "alive_fs\" + _tagLower],
    ["pbo", "alive_fs_" + _tagLower],
    ["fnc", format ["ALiVE_FS_%1_fnc_applyLoadout", _tag]],
    ["root", format ["orbat/%1/", _faction getOrDefault ["modName", "ALiVE_" + _tag]]],
    ["men", _menMain],
    ["vehicles", _vehsMain],
    ["menAll", _men],
    ["classOf", _classOf],
    ["backpacks", _backpacks],
    ["packOf", _packOf],
    ["stubs", _stubs],
    ["parentOf", _parentOf],
    ["crewOf", _crewOf],
    ["gunnersOf", _gunnersOf],
    ["pylonsOf", _pylonsOf],
    ["stubTreeOf", _stubTreeOf],
    ["forward", values _forward],
    ["subcats", _subcats],
    ["subOf", _subOf],
    ["groups", _groups],
    ["legacy", _legacy],
    ["deps", _deps],
    ["errors", _errors],
    ["warnings", _warnings],
    ["hook", _hook],
    ["crates", _crates],
    ["alive", _aliveLists],
    ["aliveTypes", _aliveTypes],
    ["optional", _optional]
]
