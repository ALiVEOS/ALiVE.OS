// NEO_fnc_casWeaponFamily
// ------------------------------------------------------------------
// Classify a vehicle weapon into the family the CAS code cares about:
// "GUN" | "ROCKETS" | "MISSILE" | "BOMB" | "OTHER".
// The ONE shared classifier - the Choose Weapon list labels AND the
// automatic weapon-priority pick both call this, so what the player reads
// and what the pilot flies can never disagree.
//
// NOTE: this family split is deliberately FINER than the delivery script's
// guided/unguided binary. It drives labels and pick priority ONLY - the
// actual delivery path (guided tiering, cadence, gun run) stays owned by the
// per-weapon setup in NEO_fnc_casScriptedAttack. Never wire this string into
// a delivery decision.
//
// Detection is by parent-chain NAME token (not a clean class tree) because
// mods don't share one: RHS's rhs_weap_gbu12 has no BombLauncher parent,
// cursorAim != "bomb" and canLock 0 - only the BOMB/LGB name token finds it.
// The thresholds mirror the delivery script's own _guided test (canLock > 1,
// MISSILE/BOMB/LGB tokens). Check order matters: gun first (cannon/MG parents
// never carry missile/bomb tokens), bomb before missile (LGB launchers can
// carry lock flags), rockets before missile (an unguided pod is not a missile).
//
// Params: [_weapon] - CfgWeapons classname
// Returns: family string
//
// Author: Jman
// ------------------------------------------------------------------
params ["_weapon"];

private _cfg = configFile >> "CfgWeapons" >> _weapon;
private _pu = ([_cfg, true] call BIS_fnc_returnParents) apply { toUpper _x };
private _ammoC = getText (configFile >> "CfgMagazines" >> ((getArray (_cfg >> "magazines")) param [0, ""]) >> "ammo");
private _sim0 = toLower getText (configFile >> "CfgAmmo" >> _ammoC >> "simulation");

// cannon/MG parents, OR a bullet-firing weapon on a mod-custom base that inherits neither
// (e.g. CSLA UK59 door gun) - a shotBullet weapon is always a gun/MG
if (_weapon isKindOf ["CannonCore", configFile >> "CfgWeapons"] || {"MGUNCORE" in _pu} || {_sim0 == "shotbullet"}) exitWith { "GUN" };
if ((_pu findIf { ((_x find "BOMB") >= 0) || {(_x find "LGB") >= 0} } > -1)
    || {getText (_cfg >> "cursorAim") == "bomb"}) exitWith { "BOMB" };
private _canLock = getNumber (_cfg >> "canLock");

// Unguided rocket pods vs guided missiles. RHS/CUP frequently model a rocket pod as a
// locking missile (canLock 2, MissileBase ammo, missile cursor) - config alone cannot tell
// a Hydra from a Maverick - so fall back to a name check on the well-known unguided rocket
// families. A pod on the vanilla RocketPods base (or any ROCKET-named parent) that does NOT
// auto-lock is also rockets. A guided rocket (DAGR-style: canLock 2, no rocket name) stays a
// missile via the check below.
private _ammo0 = toUpper _ammoC;
private _wu = toUpper _weapon;
if ( ( (("ROCKETPODS" in _pu) || {(_pu findIf { (_x find "ROCKET") >= 0 }) > -1}) && {_canLock <= 1} )
     || {["HYDRA","FFAR","ZUNI"] findIf { ((_wu find _x) >= 0) || {(_ammo0 find _x) >= 0} } > -1} ) exitWith { "ROCKETS" };
// auto-locking / missile-based launcher = guided missile (IR/laser/radar AGM, ATGM)
if ((_pu findIf { (_x find "MISSILE") >= 0 } > -1) || {_canLock > 1}) exitWith { "MISSILE" };

"OTHER"
