#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsGenConfig);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsGenConfig

Description:
The whole config.cpp of an exported faction mod, as lines: CfgPatches (with an
empty class for each old mod name kept), CfgFactionClasses,
CfgEditorSubcategories, CfgVehicles (outside classes named only, turret stubs,
backpacks, men, vehicles), CfgGroups, CfgFunctions and the three CBA XEH blocks
that apply the loadout. No #include, no macro, no __EVAL: any packer can pack it
as it is. Every class the mod defines carries the faction's tag, so two
exported factions never define the same class.

Given one row of the plan's optional list, it writes that optional part instead:
CfgPatches with skipWhenMissingDependencies (so the game leaves the part out,
with no message, when one of its mods is not loaded), its CfgVehicles (forward
declarations, its stubs and backpacks, men, vehicles), its groups under the
faction's own CfgGroups class, and the XEH blocks of its men and vehicles. Its
men use the main part's applyLoadout function.

Parameters:
    _plan    - HASHMAP - from ALiVE_fnc_fsGenPlan (no errors)
    _faction - HASHMAP - the snapshot
    _opt     - ARRAY - (optional) a row of the plan's optional list; [] for the main part

Returns:
    ARRAY - config lines; join with endl to write

Examples:
    (begin example)
    private _lines = [_plan, _snapshot] call ALiVE_fnc_fsGenConfig;
    ([_lines] call ALiVE_fnc_fsGenCheck) params ["_ok", "_line"];
    (end)

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_plan", createHashMap, [createHashMap]], ["_faction", createHashMap, [createHashMap]], ["_opt", [], [[]]]];

private _q = { [_this] call ALiVE_fnc_fsGenQuote };
private _a = { [_this] call ALiVE_fnc_fsGenArray };
private _tag = _plan get "tag";
private _patch = _plan get "patch";
private _fnc = _plan get "fnc";
private _classOf = _plan get "classOf";
private _isOpt = count _opt > 0;
private _men = if (_isOpt) then { _opt select 2 } else { _plan get "men" };
private _vehicles = if (_isOpt) then { _opt select 3 } else { _plan get "vehicles" };
private _forward = if (_isOpt) then { _opt select 6 } else { _plan get "forward" };
private _stubs = if (_isOpt) then { _opt select 7 } else { _plan get "stubs" };
private _backpacks = if (_isOpt) then { _opt select 8 } else { _plan get "backpacks" };
// the XEH blocks name the patch that adds them
private _xehPatch = if (_isOpt) then { _opt select 0 } else { _patch };
private _side = _faction getOrDefault ["side", 1];
private _name = _faction getOrDefault ["name", _tag];
private _flag = _faction getOrDefault ["flag", ""];
private _icon = _faction getOrDefault ["icon", ""];
if (_icon isEqualTo "") then { _icon = _flag };
private _version = getText (configFile >> "CfgPatches" >> "ALiVE_main" >> "versionStr");
systemTime params ["_year", "_month", "_day"];
private _date = format ["%1-%2%3-%4%5", _year toFixed 0, ["", "0"] select (_month < 10), _month toFixed 0, ["", "0"] select (_day < 10), _day toFixed 0];

private _menClasses = _men apply { _classOf get _x };
private _crates = if (_isOpt) then { [] } else { _plan getOrDefault ["crates", []] };
private _all = _menClasses + (_vehicles apply { _classOf get _x }) + (_crates apply { _x select 0 });
private _requires = +((_plan get "deps") get "addons");
private _legacy = _plan get "legacy";

private _lines = [];
if (_isOpt) then {
    _lines = [
        format ["// %1 (%2), optional part %3. Written by ALiVE %4 on %5.", _name, _tag, _opt select 0, _version, _date],
        "// The game leaves this part out, with no message, when one of the mods it needs is not loaded.",
        "",
        "class CfgPatches {",
        format ["    class %1 {", _opt select 0],
        "        name = " + ((_name + " (" + ((_opt select 1) joinString ", ") + ")") call _q) + ";",
        "        author = " + ((_faction getOrDefault ["author", ""]) call _q) + ";",
        "        units[] = " + (_all call _a) + ";",
        "        weapons[] = {};",
        "        requiredVersion = 2.14;",
        "        requiredAddons[] = " + (([_patch] + (_opt select 5)) call _a) + ";",
        "        skipWhenMissingDependencies = 1;",
        "        ALiVE_FS_tag = " + (_tag call _q) + ";",
        "        ALiVE_FS_optional = 1;",
        "    };",
        "};",
        "",
        "class CfgVehicles {",
        "    // classes from other mods and from the main part: named, never changed"
    ];
} else {
    _lines = [
        // the name can hold anything text60 allows; a line end cannot reach a comment line
        format ["// %1 (%2). Written by ALiVE %3 on %4.", _name, _tag, _version, _date],
        "// Change the faction in ALiVE and export again; edits made here are lost on the next export.",
        "",
        "class CfgPatches {",
        format ["    class %1 {", _patch],
        "        name = " + (_name call _q) + ";",
        "        author = " + ((_faction getOrDefault ["author", ""]) call _q) + ";",
        "        units[] = " + (_all call _a) + ";",
        "        weapons[] = {};",
        "        requiredVersion = 2.14;",
        "        requiredAddons[] = " + (_requires call _a) + ";",
        "        ALiVE_FS_schema = 1;",
        "        ALiVE_FS_id = " + ((_faction getOrDefault ["id", ""]) call _q) + ";",
        "        ALiVE_FS_tag = " + (_tag call _q) + ";",
        "        ALiVE_FS_legacyPatches[] = " + (_legacy call _a) + ";"
    ];
    // this export declares the faction to ALiVE (CfgALiVEFactions below)
    if (_plan getOrDefault ["hook", false]) then { _lines pushBack "        ALiVE_FS_alive = 1;" };
    _lines pushBack "    };";
    // a mission saved with a unit of the old export lists the old patch; without the class it will not load
    {
        _lines pushBack format ["    class %1 { units[] = {}; weapons[] = {}; requiredVersion = 2.14; requiredAddons[] = %2; ALiVE_FS_tag = %3; };", _x, [_patch] call _a, _tag call _q];
    } forEach _legacy;
    _lines append [
        "};",
        "",
        "class CfgFactionClasses {",
        format ["    class %1 {", _faction getOrDefault ["class", _tag]],
        "        displayName = " + (_name call _q) + ";",
        "        side = " + (_side toFixed 0) + ";",
        "        flag = " + (_flag call _q) + ";",
        "        icon = " + (_icon call _q) + ";",
        "        priority = " + ((_faction getOrDefault ["priority", 1]) toFixed 0) + ";",
        "        ALiVE_FS_tag = " + (_tag call _q) + ";",
        "    };",
        "};",
        "",
        "class CfgEditorSubcategories {"
    ];
    {
        _x params ["_class", "_display"];
        _lines pushBack format ["    class %1 { displayName = %2; };", _class, _display call _q];
    } forEach (_plan get "subcats");
    _lines append ["};", "", "class CfgVehicles {", "    // classes from other mods: named, never changed"];
};
{ _lines pushBack format ["    class %1;", _x] } forEach _forward;

if (count _stubs > 0) then {
    _lines append ["", "    // turret and pylon stubs, used by this faction only"];
    {
        _x params ["_base", "_names", "_paths"];
        {
            private _k = _forEachIndex + 1;
            _lines pushBack format ["    class %1 : %2 {", _x, [_base, _names select ((_k - 2) max 0)] select (_k > 1)];
            _lines pushBack (["        scope = 0; scopeCurator = 0;", "        scope = 0; scopeCurator = 0; ALiVE_FS_stub = 1;"] select (_k == 1));
            _lines append ([_paths, _k, createHashMap, "        "] call ALiVE_fnc_fsGenTree);
            _lines pushBack "    };";
        } forEach _names;
    } forEach _stubs;
};

if (count _backpacks > 0) then {
    _lines append ["", "    // backpacks with their contents"];
    {
        _x params ["_class", "_base", "_mags", "_items", "_weapons"];
        _lines pushBack format ["    class %1 : %2 {", _class, _base];
        _lines pushBack "        scope = 1;";
        {
            _x params ["_root", "_list", "_key"];
            if (count _list == 0) then {
                _lines pushBack format ["        class %1 {};", _root];
            } else {
                _lines pushBack format ["        class %1 {", _root];
                {
                    _lines pushBack format ["            class _xx_%1 { %2 = %3; count = %4; };", (_forEachIndex + 1) toFixed 0, _key, (_x select 0) call _q, (_x select 1) toFixed 0];
                } forEach _list;
                _lines pushBack "        };";
            };
        } forEach [["TransportMagazines", _mags, "magazine"], ["TransportItems", _items, "name"], ["TransportWeapons", _weapons, "weapon"]];
        _lines pushBack "    };";
    } forEach _backpacks;
};

if (count _men > 0) then {
    _lines append ["", "    // soldiers"];
    { _lines append ([_plan, _faction, _x] call ALiVE_fnc_fsGenMan) } forEach _men;
};
if (count _vehicles > 0) then {
    _lines append ["", "    // vehicles"];
    { _lines append ([_plan, _faction, _x] call ALiVE_fnc_fsGenVehicle) } forEach _vehicles;
};
// supply crates: all four Transport classes always written, so none of the base box's own contents come through
if (count _crates > 0) then {
    _lines append ["", "    // supply crates"];
    {
        _x params ["_class", "_base", "_display", "_rows", "_key"];
        _lines append [
            format ["    class %1 : %2 {", _class, _base],
            "        author = " + ((_faction getOrDefault ["author", ""]) call _q) + ";",
            "        scope = 2;",
            "        scopeCurator = 2;",
            "        displayName = " + (_display call _q) + ";"
        ];
        _lines append ([_rows, "        "] call ALiVE_fnc_fsGenCargo);
        _lines append [
            "        ALiVE_FS_owned = 1;",
            "        ALiVE_FS_tag = " + (_tag call _q) + ";",
            "        ALiVE_FS_crate = " + (_key call _q) + ";",
            "    };"
        ];
    } forEach _crates;
};
_lines pushBack "};";

if (_isOpt) then {
    // its groups, under the faction's class and the categories' names (the main part may have none of them)
    private _groupLines = [_plan, _faction, _opt select 4] call ALiVE_fnc_fsGenGroups;
    if (count _groupLines > 0) then { _lines pushBack ""; _lines append _groupLines };
} else {
    // the gear pools worn by a soldier, read by the runtime (rt\fn_applyLoadout.sqf); an optional part's men too,
    // since the pools are only names
    private _poolDict = _faction getOrDefault ["pools", createHashMap];
    private _worn = [];
    {
        { if !(_x in _worn) then { _worn pushBack _x } } forEach (((_faction getOrDefault ["units", createHashMap]) getOrDefault [_x, createHashMap]) getOrDefault ["pools", []]);
    } forEach (_plan getOrDefault ["menAll", _men]);
    _worn = (_faction getOrDefault ["poolOrder", []]) select { _x in _worn && {count ((_poolDict getOrDefault [_x, createHashMap]) getOrDefault ["entries", []]) > 0} };
    if (count _worn > 0) then {
        _lines append ["", format ["class ALiVE_FS_Pools_%1 {", _plan get "tag"]];
        {
            private _pool = _poolDict get _x;
            private _weaponSlot = (_pool get "slot") in [0, 1, 2];
            private _entries = _pool get "entries";
            _lines pushBack format ["    class %1 {", _x];
            _lines pushBack ("        name = " + ((_pool get "name") call _q) + ";");
            _lines pushBack format ["        slot = %1;", (_pool get "slot") toFixed 0];
            _lines pushBack ("        items[] = " + ((_entries apply { [_x get "class", _x get "weapon"] select _weaponSlot }) call _a) + ";");
            _lines pushBack ("        weights[] = " + ((_entries apply { _x get "weight" }) call _a) + ";");
            _lines pushBack "    };";
        } forEach _worn;
        _lines pushBack "};";
    };

    private _groupLines = [_plan, _faction] call ALiVE_fnc_fsGenGroups;
    if (count _groupLines > 0) then { _lines pushBack ""; _lines append _groupLines };
    private _aliveLines = [_plan, _faction] call ALiVE_fnc_fsGenAlive;
    if (count _aliveLines > 0) then { _lines pushBack ""; _lines append _aliveLines };

    _lines append [
        "",
        "class CfgFunctions {",
        format ["    class %1 {", _patch],
        "        class rt {",
        "            file = " + (("\" + (_plan get "prefix") + "\functions") call _q) + ";",
        "            class applyLoadout {};",
        "        };",
        "    };",
        "};"
    ];
};
// Paint and parts, exactly, on the machine the vehicle is local to. textureList[] and animationList[] above
// only work when the base's own init calls BIS_fnc_initVehicle, which some mod vehicles never do. Left alone:
// a vehicle that already has an explicit appearance (Eden's Edit Vehicle Appearance, or a mission script),
// which BIS_fnc_initVehicle marks with BIS_fnc_initVehicle_customization. A respawned vehicle is new, so this
// runs again for it.
private _looks = [];
{
    private _e = (_faction getOrDefault ["vehicles", createHashMap]) getOrDefault [_x, createHashMap];
    private _texture = _e getOrDefault ["texture", ""];
    private _parts = [];
    {
        private _source = _x getOrDefault ["source", ""];
        if !(_source isEqualTo "") then { _parts append [_source, [0, 1] select ((_x getOrDefault ["value", 0]) > 0.5)] };
    } forEach (_e getOrDefault ["components", []]);
    // markings taken off (a roundel, an emblem, a number): the base's hidden selection indices, cleared 0.3 s on,
    // after the paint, since a paint can carry a roundel and some mods put their own markings on at init
    private _sels = (getArray (configFile >> "CfgVehicles" >> (_e getOrDefault ["base", ""]) >> "hiddenSelections")) apply { if (_x isEqualType "") then { toLower _x } else { "" } };
    private _markIdx = [];
    { private _k = _sels find (toLower _x); if (_k >= 0) then { _markIdx pushBack _k } } forEach (_e getOrDefault ["markingsOff", []]);
    if (!(_texture isEqualTo "") || {count _parts > 0} || {count _markIdx > 0}) then {
        private _cmd = "private _v = _this select 0;";
        if (!(_texture isEqualTo "") || {count _parts > 0}) then {
            // class-rule names only, so single quotes are safe inside the handler string
            private _paint = if (_texture isEqualTo "") then { "false" } else { format ["['%1',1]", _texture] };
            private _anims = if (count _parts == 0) then { "false" } else {
                "[" + ((_parts apply { if (_x isEqualType "") then { "'" + _x + "'" } else { _x toFixed 0 } }) joinString ",") + "]"
            };
            _cmd = _cmd + format [" if (local _v && {isNil {_v getVariable 'BIS_fnc_initVehicle_customization'}}) then {[_v, %1, %2] call BIS_fnc_initVehicle};", _paint, _anims];
        };
        if (count _markIdx > 0) then {
            _cmd = _cmd + format [" if (local _v) then {[{{(_this select 0) setObjectTextureGlobal [_x, '']} forEach (_this select 1)}, [_v, %1], 0.3] call CBA_fnc_waitAndExecute};", str _markIdx];
        };
        _looks pushBack [_classOf get _x, _cmd];
    };
} forEach _vehicles;

// The faction author's Init Code, after the loadout or the looks. CBA runs an InitPost handler for its class and every
// class made from it, so the code is wrapped to run only for this exact class: a child unit runs its own code, never
// its parent's: the class check comes first and leaves the handler. CBA compiles the handler string as it is, with
// no preprocessor, so a comment would be a script error on every machine: comments are taken out here (the text in
// quotes left alone), before the line breaks become spaces (ALiVE_fnc_fsGenQuote). ALiVE_FS_initCode keeps them.
private _noComments = {
    private _in = toArray _this;
    private _n = count _in;
    private _out = [];
    private _i = 0;
    private _quote = -1;
    while { _i < _n } do {
        private _c = _in select _i;
        private _next = _in param [_i + 1, -1];
        if (_quote >= 0) then {
            // inside "..." or '...', where a doubled quote is one quote character
            _out pushBack _c;
            if (_c == _quote) then { if (_next == _quote) then { _out pushBack _next; _i = _i + 1 } else { _quote = -1 } };
        } else {
            switch (true) do {
                case (_c == 34 || {_c == 39}): { _quote = _c; _out pushBack _c };
                // a // comment runs to the end of its line; the line break itself is kept
                case (_c == 47 && {_next == 47}): {
                    while { _i < _n && {!((_in select _i) in [10, 13])} } do { _i = _i + 1 };
                    _i = _i - 1;
                };
                case (_c == 47 && {_next == 42}): {
                    _i = _i + 2;
                    while { _i < _n && {!((_in select _i) == 42 && {(_in param [_i + 1, -1]) == 47})} } do { _i = _i + 1 };
                    _i = _i + 1;
                    _out pushBack 32;
                };
                default { _out pushBack _c };
            };
        };
        _i = _i + 1;
    };
    toString _out
};
private _codeOf = {
    params ["_dict", "_id"];
    private _code = (((_faction getOrDefault [_dict, createHashMap]) getOrDefault [_id, createHashMap]) getOrDefault ["initCode", ""]) call _noComments;
    if ((trim _code) isEqualTo "") exitWith { "" };
    format ["; if !(typeOf (_this select 0) isEqualTo '%1') exitWith {}; %2", _classOf get _id, _code]
};
{
    private _code = ["vehicles", _x] call _codeOf;
    if !(_code isEqualTo "") then {
        private _cls = _classOf get _x;
        private _at = _looks findIf { (_x select 0) isEqualTo _cls };
        if (_at >= 0) then { (_looks select _at) set [1, ((_looks select _at) select 1) + _code] } else { _looks pushBack [_cls, _code select [2]] };
    };
} forEach _vehicles;

// the loadout: a frame after a man is made, on respawn, and when he becomes local somewhere else
private _init = (_men apply { [_classOf get _x, format ["[_this select 0, 'init'] call %1", _fnc] + (["units", _x] call _codeOf)] }) + _looks;
{
    _x params ["_root", "_key", "_entries"];
    if (count _entries > 0) then {
        _lines pushBack "";
        _lines pushBack format ["class %1 {", _root];
        { _lines pushBack format ["    class %1 { class %2 { %3 = %4; }; };", _x select 0, _xehPatch, _key, (_x select 1) call _q] } forEach _entries;
        _lines pushBack "};";
    };
} forEach [
    ["Extended_InitPost_EventHandlers", "init", _init],
    ["Extended_Local_EventHandlers", "local", _menClasses apply { [_x, format ["if (_this select 1) then {[_this select 0, 'local'] call %1}", _fnc]] }],
    ["Extended_Respawn_EventHandlers", "respawn", _menClasses apply { [_x, format ["[{[_this, 'respawn'] call %1}, _this select 0] call CBA_fnc_execNextFrame", _fnc]] }]
];
_lines
