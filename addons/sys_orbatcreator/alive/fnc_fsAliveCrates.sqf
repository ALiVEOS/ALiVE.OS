#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsAliveCrates);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsAliveCrates

Description:
The faction's supply crates, which the export writes as its own boxes and
declares to ALiVE as the faction's supplies. While "crates" is in alive.auto
they are worked out here, every time, from every man's stored loadout and every
gear pool a man wears (a man ticked Optional is left out), so new gear reaches the crates by itself:
    ammo      - rifle and handgun magazines, 20 each; grenades and explosives, 10
    weapons   - rifles and handguns, 5 each, with their attachments, 5 each
    launchers - launchers, 3 each, and their missiles, 6 each (left out with none)
    support   - map, radio, compass and other assigned items, binoculars,
                medical and tool items, 5 each
    uniforms  - uniforms, vests, headgear and facewear, 5 each; backpacks, 3
Most-used gear first, at most FS_MAX_CRATE_ROWS rows a crate. A crate with
nothing in it is left out, and a civilian faction gets none. Once a crate is
edited by hand, alive.crates is used as it is. A crate made with New crate
(key "custom") is the faction author's own: it stays in alive.crates and comes
after the worked-out crates while they are automatic, so the others still follow
the men's gear.

Parameters:
    _faction - HASHMAP - the studio faction

Returns:
    ARRAY - [crates, notes]; each crate a HASHMAP of the crate spec
            (key, name, class, classAuto, base, cargo)

Examples:
    (begin example)
    ([_faction] call ALiVE_fnc_fsAliveCrates) params ["_crates", "_notes"];
    (end)

See Also:
    ALiVE_fnc_fsAlivePicks, ALiVE_fnc_fsGenPlan

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_faction", createHashMap, [createHashMap]]];

private _alive = _faction getOrDefault ["alive", createHashMap];
private _side = _faction getOrDefault ["side", 1];
if (_side == 3) exitWith { [[], []] };
if !("crates" in (_alive getOrDefault ["auto", FS_ALIVE_LISTS])) exitWith { [+(_alive getOrDefault ["crates", []]), []] };
// the author's own crates, after the worked-out ones
private _custom = (_alive getOrDefault ["crates", []]) select { (_x getOrDefault ["key", ""]) isEqualTo "custom" };

private _tag = _faction getOrDefault ["tag", ""];
private _fname = _faction getOrDefault ["name", _tag];
private _notes = [];

// per crate key: class (lower) to [class, kind, count used]
private _bins = createHashMap;
{ _bins set [_x, createHashMap] } forEach ["ammo", "weapons", "launchers", "support", "uniforms"];
private _put = {
    params ["_bin", "_class", "_kind"];
    if (!(_class isEqualType "") || {_class isEqualTo ""}) exitWith {};
    private _m = _bins get _bin;
    private _k = toLower _class;
    private _row = _m getOrDefault [_k, [_class, _kind, 0]];
    _row set [2, (_row select 2) + 1];
    _m set [_k, _row];
};

private _launcherMags = [];
// a weapon entry of a loadout: [weapon, muzzle, side, optic, [mag, ammo], [mag, ammo], bipod]
private _weapon = {
    params ["_w", ["_isLauncher", false]];
    if (!(_w isEqualType []) || {count _w == 0} || {(_w select 0) isEqualTo ""}) exitWith {};
    if (_isLauncher) then {
        ["launchers", _w select 0, 0] call _put;
        _launcherMags append (([_w select 0] call BIS_fnc_compatibleMagazines) apply { toLower _x });
    } else {
        ["weapons", _w select 0, 0] call _put;
        { if (_x isEqualType "" && {!(_x isEqualTo "")}) then { ["weapons", _x, 2] call _put } } forEach [_w param [1, ""], _w param [2, ""], _w param [3, ""], _w param [6, ""]];
    };
};
private _mags = [];
private _items = [];
// a container entry: [class, [[item, count] or [mag, count, ammo] or [[weapon entry], count]]]
private _container = {
    params ["_c", "_bin", "_kind"];
    if (!(_c isEqualType []) || {count _c == 0} || {(_c select 0) isEqualTo ""}) exitWith {};
    [_bin, _c select 0, _kind] call _put;
    {
        private _what = _x param [0, ""];
        if (_what isEqualType []) then {
            [_what, (getNumber (configFile >> "CfgWeapons" >> (_what param [0, "x"]) >> "type")) == 4] call _weapon;
        } else {
            if (count _x > 2 || {isClass (configFile >> "CfgMagazines" >> _what)}) then { _mags pushBack _what } else { _items pushBack _what };
        };
    } forEach (_c param [1, []]);
};

// an optional unit's gear is left out: the crates are in the main part, which loads without his mods
private _units = createHashMap;
{ if !(_y getOrDefault ["optional", false]) then { _units set [_x, _y] } } forEach (_faction getOrDefault ["units", createHashMap]);
private _pools = _faction getOrDefault ["pools", createHashMap];
{
    private _l = _y getOrDefault ["loadout", []];
    [_l param [0, []]] call _weapon;
    [_l param [1, []], true] call _weapon;
    [_l param [2, []]] call _weapon;
    { private _w = _l param [_x, []]; if (_w isEqualType [] && {count _w > 5}) then { { if (_x isEqualType [] && {count _x > 0}) then { _mags pushBack (_x select 0) } } forEach [_w select 4, _w select 5] } } forEach [0, 1, 2];
    [_l param [3, []], "uniforms", 2] call _container;
    [_l param [4, []], "uniforms", 2] call _container;
    [_l param [5, []], "uniforms", 3] call _container;
    ["uniforms", _l param [6, ""], 2] call _put;
    ["uniforms", _l param [7, ""], 2] call _put;
    private _bino = _l param [8, []];
    if (_bino isEqualType [] && {count _bino > 0}) then { ["support", _bino select 0, 0] call _put };
    { ["support", _x, 2] call _put } forEach (_l param [9, []]);
    // gear pools he wears
    {
        private _pool = _pools getOrDefault [_x, createHashMap];
        private _slot = _pool getOrDefault ["slot", -1];
        {
            private _w = _x getOrDefault ["weapon", []];
            switch (true) do {
                // pool slots: 0 rifle, 1 handgun, 2 launcher, 3 uniform, 4 vest, 5 backpack, 6 headgear, 7 facewear
                case (_slot in [0, 1, 2]): {
                    [_w, _slot == 2] call _weapon;
                    if (count _w > 5) then { { if (_x isEqualType [] && {count _x > 0}) then { _mags pushBack (_x select 0) } } forEach [_w select 4, _w select 5] };
                };
                case (_slot == 5): { ["uniforms", _x getOrDefault ["class", ""], 3] call _put };
                default { ["uniforms", _x getOrDefault ["class", ""], 2] call _put };
            };
        } forEach (_pool getOrDefault ["entries", []]);
    } forEach (_y getOrDefault ["pools", []]);
} forEach _units;

// magazines: missiles to the launcher crate, grenades and explosives 10, the rest 20
{
    private _low = toLower _x;
    switch (true) do {
        case (_low in _launcherMags): { ["launchers", _x, 1] call _put };
        default { ["ammo", _x, 1] call _put };
    };
} forEach _mags;
{ ["support", _x, 2] call _put } forEach _items;

private _countOf = {
    params ["_bin", "_class", "_kind"];
    switch (_bin) do {
        case "ammo": {
            private _t = ([_class] call BIS_fnc_itemType) param [1, ""];
            [20, 10] select (_t in ["Grenade", "SmokeShell", "Flare", "Mine", "MineBounding", "MineDirectional", "Explosive", "Bomb", "IRGrenade"])
        };
        case "launchers": { [3, 6] select (_kind == 1) };
        case "uniforms": { [5, 3] select (_kind == 3) };
        default { 5 };
    };
};

private _bases = createHashMapFromArray [
    ["ammo", ["Box_East_Ammo_F", "Box_NATO_Ammo_F", "Box_IND_Ammo_F"]],
    ["weapons", ["Box_East_Wps_F", "Box_NATO_Wps_F", "Box_IND_Wps_F"]],
    ["launchers", ["Box_East_WpsLaunch_F", "Box_NATO_WpsLaunch_F", "Box_IND_WpsLaunch_F"]],
    ["support", ["Box_East_Support_F", "Box_NATO_Support_F", "Box_IND_Support_F"]],
    ["uniforms", ["Box_East_Uniforms_F", "Box_NATO_Uniforms_F", "Box_IND_Uniforms_F"]]
];
private _crates = [];
{
    _x params ["_key", "_suffix", "_str"];
    private _rows = values (_bins get _key);
    if (count _rows > 0) then {
        // most-used first, then by name so the order never changes between exports
        _rows = [_rows, [], { ((100000 - (_x select 2)) toFixed 0) + (toLower (_x select 0)) }] call BIS_fnc_sortBy;
        if (count _rows > FS_MAX_CRATE_ROWS) then {
            _notes pushBack format [localize "STR_ALIVE_FS_N_CRATE_CUT", _key, (count _rows - FS_MAX_CRATE_ROWS) toFixed 0];
            _rows resize FS_MAX_CRATE_ROWS;
        };
        _crates pushBack createHashMapFromArray [
            ["key", _key],
            ["name", (format [localize _str, _fname]) select [0, 60]],
            ["class", format ["%1_Crate_%2", _tag, _suffix]],
            ["classAuto", true],
            ["base", ((_bases get _key) select (_side min 2))],
            ["cargo", _rows apply { createHashMapFromArray [["class", _x select 0], ["kind", _x select 1], ["count", [_key, _x select 0, _x select 1] call _countOf]] }]
        ];
    };
} forEach [
    ["ammo", "Ammo", "STR_ALIVE_FS_CR_AMMO"],
    ["weapons", "Weapons", "STR_ALIVE_FS_CR_WEAPONS"],
    ["launchers", "Launchers", "STR_ALIVE_FS_CR_LAUNCHERS"],
    ["support", "Support", "STR_ALIVE_FS_CR_SUPPORT"],
    ["uniforms", "Uniforms", "STR_ALIVE_FS_CR_UNIFORMS"]
];

[_crates + (_custom apply { +_x }), _notes]
