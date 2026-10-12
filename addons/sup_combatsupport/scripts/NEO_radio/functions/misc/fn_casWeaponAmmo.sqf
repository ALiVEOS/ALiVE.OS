// NEO_fnc_casWeaponAmmo
// ------------------------------------------------------------------
// The rounds a CAS aircraft has left for one weapon: every magazine on the turret holding
// it that any of its muzzles can fire. "_veh ammo _weapon" reads only the magazine in use
// on the first muzzle, so it got both of these wrong (measured on 15 vanilla and RHS
// aircraft, 23 of 42 usable weapons misread):
//   - a gun whose ammo sits under named muzzles (the Kajman's 30 mm, the Ka-52's 2A42, HE
//     and AP) read 0 with 500 rounds aboard, so it was never picked and counted as empty;
//   - a pylon weapon read only the pylon in use: a Wipeout with 4 bombs read 1.
//
// Params: [_veh, _weapon]
// Returns: number of rounds
//
// Author: Jman
// ------------------------------------------------------------------
params ["_veh", "_weapon"];
if (isNull _veh || {_weapon isEqualTo ""}) exitWith { 0 };

private _turret = [-1];
{ if (_weapon in (_veh weaponsTurret _x)) exitWith { _turret = _x } } forEach ([[-1]] + allTurrets [_veh, false]);

private _muzzles = (getArray (configFile >> "CfgWeapons" >> _weapon >> "muzzles")) apply { if (_x == "this") then { _weapon } else { _x } };
if (_muzzles isEqualTo []) then { _muzzles = [_weapon] };
private _compat = [];
{ _compat append ((compatibleMagazines [_weapon, _x]) apply { toLower _x }) } forEach _muzzles;

private _rounds = 0;
{
    _x params ["_mag", "_t", "_n"];
    if (_t isEqualTo _turret && {(toLower _mag) in _compat}) then { _rounds = _rounds + _n };
} forEach (magazinesAllTurrets _veh);
// never less than the game's own count: a mod pylon weapon whose magazines its config doesn't list
_rounds max (_veh ammo _weapon)
