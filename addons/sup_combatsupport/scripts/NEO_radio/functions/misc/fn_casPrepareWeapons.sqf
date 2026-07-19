// NEO_fnc_casPrepareWeapons
// ------------------------------------------------------------------
// Attack-order loadout prep - called once by the cas.fsm Attack link in place
// of the old "zero every weapon but the one chosen":
//  - zeroes ONLY the never-usable stores (countermeasures/illum/smoke,
//    air-to-air-only missiles, laser designator, no-damage dummies). Every
//    ground-attack weapon stays LOADED so the delivery script can switch to it
//    as ammo runs out. This is safe ONLY because the Attack link re-asserts
//    disableAi "TARGET"/"AUTOTARGET" on the group (nr_position later forces
//    YELLOW/AWARE/enableAttack true and SAD re-enables targeting, so the
//    disableAi pair is the one leash that survives into delivery) - a loaded
//    store can never be fired autonomously; every shot is scripted on a named
//    weapon.
//  - resolves "AUTO" (or an invalid / already-empty specific pick) to a concrete
//    weapon via the shared priority pick, so the delivery script only ever sees
//    real classnames.
//
// _ammoCount keeps the exact positional contract NEO_fnc_reenableWeapons
// expects (-1 = untouched, skip on restore); built once over weapons _veh,
// which does not change mid-flight, so it stays valid across any number of
// weapon switches. Because the usable set is recorded -1, a later re-task
// restores only the never-usable stores - spent usable ammo correctly stays
// spent for the resupply watchdog.
//
// Params: [_veh, _weaponPick] - _weaponPick = classname or "AUTO"
// Returns: [_weapon, _ammoCount]
//
// Author: Jman
// ------------------------------------------------------------------
params ["_veh", "_weaponPick"];

private _usable = [_veh] call NEO_fnc_casUsableWeapons;

private _ammoCount = [];
{
    if (_x in _usable) then {
        _ammoCount pushBack -1;
    } else {
        _ammoCount pushBack (_veh ammo _x);
        _veh setAmmo [_x, 0];
    };
} forEach (weapons _veh);

private _weapon = _weaponPick;
if (_weapon == "AUTO" || {!(_weapon in _usable)} || {(_veh ammo _weapon) <= 0}) then {
    _weapon = [_veh, _usable] call NEO_fnc_casNextWeapon;
};
// completely dry / weaponless airframe: fall back to the first real weapon so the
// downstream config lookups stay harmless - the delivery loop's dry gate then
// exits immediately and flags the RTB
if (_weapon isEqualTo "") then { _weapon = (weapons _veh) param [0, ""]; };

[_weapon, _ammoCount]
