// NEO_fnc_casNextWeapon
// ------------------------------------------------------------------
// Pick what the pilot should fire next: the first usable weapon with ammo
// remaining, walked in family priority order Missile > Bomb > Rockets > Gun
// (precision/standoff ordnance first, gun as the always-works fallback),
// loadout order within a family. Drives AUTO's first pick and every
// switch-on-depletion re-pick, so the behaviour is one rule everywhere.
//
// Params: [_veh, _usableWeapons] - _usableWeapons from NEO_fnc_casUsableWeapons
// Returns: weapon classname, or "" when every usable weapon is dry
//
// Author: Jman
// ------------------------------------------------------------------
params ["_veh", "_usable"];

private _loaded = _usable select { (_veh ammo _x) > 0 };
if (_loaded isEqualTo []) exitWith { "" };

private _pick = "";
{
    private _fam = _x;
    private _i = _loaded findIf { ([_x] call NEO_fnc_casWeaponFamily) == _fam };
    if (_i > -1) exitWith { _pick = _loaded select _i; };
} forEach ["MISSILE", "BOMB", "ROCKETS", "GUN"];
if (_pick isEqualTo "") then { _pick = _loaded select 0; };   // OTHER-family fallback

_pick
