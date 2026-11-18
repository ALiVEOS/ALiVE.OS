#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsGenLoadoutArrays);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsGenLoadoutArrays

Description:
A getUnitLoadout array to the class arrays a soldier config carries, so Eden,
Zeus and a respawn show a believable soldier before (or without) the faction
runtime:
    - weapons: primary, launcher, handgun and binocular, then Throw and Put;
    - magazines: each loaded magazine once, then every magazine in the uniform
      and vest, repeated by count;
    - items: every other item in the uniform and vest, repeated by count;
    - linkedItems: vest, headgear, facewear, then the assigned items.
Counts are capped at 100 an entry. Backpack contents are handed back apart,
for the generated backpack class.

Parameters:
    _loadout - ARRAY - getUnitLoadout shape, 10 slots

Returns:
    HASHMAP - weapons, magazines, items, linkedItems (ARRAY), uniform,
    backpack (STRING), pack: [magazines, items, weapons] each a list of
    [class, count]

Examples:
    (begin example)
    private _la = [getUnitLoadout "B_Soldier_F"] call ALiVE_fnc_fsGenLoadoutArrays;
    (end)

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_loadout", [], [[]]]];

private _slot = { private _s = _loadout param [_this, []]; if (_s isEqualType []) then { _s } else { [] } };
private _weapons = [];
private _magazines = [];
private _items = [];
private _linked = [];

{
    private _w = _x call _slot;
    if (count _w > 0 && {!((_w select 0) isEqualTo "")}) then {
        _weapons pushBack (_w select 0);
        {
            private _m = _w param [_x, []];
            if (_m isEqualType [] && {count _m > 0} && {!((_m select 0) isEqualTo "")}) then { _magazines pushBack (_m select 0) };
        } forEach [4, 5];
    };
} forEach [0, 1, 2, 8];
_weapons append ["Throw", "Put"];

// [class, count] item, [class, count, ammo] magazine, [weaponArray, count] weapon (left to the runtime)
{
    private _c = _x call _slot;
    {
        if (_x isEqualType [] && {count _x >= 2}) then {
            private _what = _x select 0;
            private _n = ((_x select 1) min 100) max 0;
            if (_what isEqualType "" && {!(_what isEqualTo "")}) then {
                private _to = [_items, _magazines] select (count _x >= 3);
                for "_k" from 1 to _n do { _to pushBack _what };
            };
        };
    } forEach (_c param [1, []]);
} forEach [3, 4];

private _vest = (4 call _slot) param [0, ""];
{
    if (_x isEqualType "" && {!(_x isEqualTo "")}) then { _linked pushBack _x };
} forEach ([_vest, _loadout param [6, ""], _loadout param [7, ""]] + (9 call _slot));

// backpack contents, summed by class
private _packMags = createHashMap;
private _packItems = createHashMap;
private _packWeapons = createHashMap;
{
    if (_x isEqualType [] && {count _x >= 2}) then {
        private _what = _x select 0;
        private _n = (_x select 1) max 0;
        switch (true) do {
            case (_what isEqualType [] && {count _what > 0}): {
                private _c = _what select 0;
                _packWeapons set [_c, (_packWeapons getOrDefault [_c, 0]) + _n];
            };
            case (!(_what isEqualType "") || {_what isEqualTo ""}): {};
            case (count _x >= 3): { _packMags set [_what, (_packMags getOrDefault [_what, 0]) + _n] };
            default { _packItems set [_what, (_packItems getOrDefault [_what, 0]) + _n] };
        };
    };
} forEach ((5 call _slot) param [1, []]);
private _pairs = {
    private _m = _this;
    private _k = keys _m;
    _k sort true;
    _k apply { [_x, (_m get _x) min 100] }
};

createHashMapFromArray [
    ["weapons", _weapons],
    ["magazines", _magazines],
    ["items", _items],
    ["linkedItems", _linked],
    ["uniform", (3 call _slot) param [0, ""]],
    ["backpack", (5 call _slot) param [0, ""]],
    ["pack", [_packMags call _pairs, _packItems call _pairs, _packWeapons call _pairs]]
]
