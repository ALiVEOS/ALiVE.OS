// NEO_fnc_casUsableWeapons
// ------------------------------------------------------------------
// The weapons on a CAS airframe the pilot can actually deliver against a
// ground/laser point, in loadout order. ONE filter shared by the Choose
// Weapon list AND the in-flight prepare/switch logic, so the picker can never
// offer a weapon the pilot won't fly, nor a switch land on one the picker hid.
// Keeps guns + rockets + bombs + ground-capable missiles; drops laser
// designators, countermeasures/illum/smoke, air-to-air-only missiles,
// magazine-less pseudo weapons and no-damage dummy/pylon launchers.
//
// Params: [_veh]
// Returns: array of weapon classnames
//
// Author: Jman
// ------------------------------------------------------------------
params ["_veh"];

(weapons _veh) select {
    private _w = _x;
    private _keep = false;
    // a mounted laser designator appears in weapons _veh but is not a weapon.
    // The engine base class is the reliable gate (vanilla/RHS/CUP/ACE designators
    // inherit Laserdesignator); the name/displayName token is a mod-safety backstop
    // for a designator rooted outside that tree. Checked FIRST - the old damage-based
    // inference (hit/indirectHit both 0) is mod-dependent and let some designators through.
    private _isDesignator = _w isKindOf ["Laserdesignator", configFile >> "CfgWeapons"]
        || {((toLower _w) find "designat") >= 0}
        || {((toLower getText (configFile >> "CfgWeapons" >> _w >> "displayName")) find "designator") >= 0};
    if (!_isDesignator) then {
        // gun/cannon: always usable (may declare magazines per-muzzle)
        if (_w isKindOf ["CannonCore", configFile >> "CfgWeapons"]) then {
            _keep = true;
        } else {
            private _mags = getArray (configFile >> "CfgWeapons" >> _w >> "magazines");
            // no magazine = pseudo/utility weapon (master-arm-safe, dummy launcher) -> drop
            if !(_mags isEqualTo []) then {
                private _ammoCfg = configFile >> "CfgAmmo" >> getText (configFile >> "CfgMagazines" >> (_mags select 0) >> "ammo");
                private _sim = toLower getText (_ammoCfg >> "simulation");
                private _isUtility = (_sim find "shotcm") == 0 || {_sim in ["shotilluminating", "shotsmoke", "laserdesignate"]};
                // air-to-air ONLY missile (airLock 2 locks air, cannot designate ground); ground AGMs are airLock 0/1
                private _isAirToAir = getNumber (_ammoCfg >> "airLock") >= 2;
                // placeholder/pylon-management launchers (e.g. RHS DummyLauncher) carry real-looking
                // magazines but their ammo does no damage - drop anything that can't actually hurt the ground
                private _doesNoDamage = (getNumber (_ammoCfg >> "hit") <= 0) && {(getNumber (_ammoCfg >> "indirectHit") <= 0)};
                _keep = !_isUtility && !_isAirToAir && !_doesNoDamage;
            };
        };
    };
    _keep
}
