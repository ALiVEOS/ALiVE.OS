#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsPoolRoll);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsPoolRoll

Description:
A loadout with one weighted random pick from each gear pool put in its slot:
the studio's Roll and the exported runtime do the same (rt\fn_applyLoadout.sqf
holds a copy of this code, as the faction mod ships without ALiVE; keep the two
alike).

    - weapons (slots 0 primary, 1 handgun, 2 launcher): the picked loadout entry
      replaces the old one, and every spare magazine of the old weapon (in the
      uniform, vest or backpack) becomes the same number of the new weapon's
      magazine. A man with no old weapon gets two spare magazines;
    - uniform, vest, backpack (3 to 5): the container changes, what is in it stays;
    - headgear, facewear (6, 7): the class.

Parameters:
    _loadout - ARRAY - a getUnitLoadout array
    _pools   - ARRAY - [slot, items, weights] for each pool

Returns:
    ARRAY - the new loadout

Examples:
    (begin example)
    _body setUnitLoadout ([getUnitLoadout _body, [[6, ["H_HelmetB", "H_Cap_red"], [3, 1]]]] call ALiVE_fnc_fsPoolRoll);
    (end)

See Also:
    ALiVE_fnc_fsDataPool, ALiVE_fnc_fsStudioPools

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_loadout", [], [[]]], ["_pools", [], [[]]]];

if (count _loadout != 10) exitWith { _loadout };
private _out = +_loadout;
{
    _x params [["_slot", -1], ["_items", []], ["_weights", []]];
    if (count _items > 0 && {count _items == count _weights}) then {
        private _pick = _items selectRandomWeighted _weights;
        private _at = [0, 2, 1, 3, 4, 5, 6, 7] param [_slot, -1];
        switch (true) do {
            case (_slot in [0, 1, 2] && {_pick isEqualType []} && {count _pick > 0}): {
                private _old = _out select _at;
                _out set [_at, +_pick];
                private _oldMags = if (_old isEqualType [] && {count _old > 0}) then { ([_old select 0] call BIS_fnc_compatibleMagazines) apply { toLower _x } } else { [] };
                private _newMags = ([_pick select 0] call BIS_fnc_compatibleMagazines) apply { toLower _x };
                private _mag = (_pick param [4, []]) param [0, ""];
                if (_mag isEqualTo "") then { _mag = ([_pick select 0] call BIS_fnc_compatibleMagazines) param [0, ""] };
                if !(_mag isEqualTo "") then {
                    private _ammo = getNumber (configFile >> "CfgMagazines" >> _mag >> "count");
                    private _swapped = 0;
                    {
                        private _box = _out select _x;
                        if (_box isEqualType [] && {count _box > 1}) then {
                            {
                                private _what = _x select 0;
                                if (_what isEqualType "" && {(toLower _what) in _oldMags} && {!((toLower _what) in _newMags)}) then {
                                    (_box select 1) set [_forEachIndex, [_mag, _x param [1, 1], _ammo]];
                                    _swapped = _swapped + 1;
                                };
                            } forEach (_box select 1);
                        };
                    } forEach [3, 4, 5];
                    if (_swapped == 0 && {_oldMags isEqualTo []}) then {
                        private _box = [4, 3, 5] findIf { private _b = _out select _x; _b isEqualType [] && {count _b > 1} };
                        if (_box >= 0) then { ((_out select ([4, 3, 5] select _box)) select 1) pushBack [_mag, 2, _ammo] };
                    };
                };
            };
            case (_slot in [3, 4, 5] && {_pick isEqualType ""}): {
                private _old = _out select _at;
                _out set [_at, [_pick, if (_old isEqualType [] && {count _old > 1}) then { +(_old select 1) } else { [] }]];
            };
            case (_slot in [6, 7] && {_pick isEqualType ""}): { _out set [_at, _pick] };
            default {};
        };
    };
} forEach _pools;
_out
