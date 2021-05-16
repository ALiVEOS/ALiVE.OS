params ["_veh","_keepWeapon"];

private _vehicleWeaponInfo = [_veh] call NEO_fnc_getVehicleWeaponInfo;
private _disabledWeaponsAmmoCount = createHashMap;

{
    private _weapon = _x;
    if (_weapon != _keepWeapon) then {
        private _pylons = _y get "pylons";
        private _weaponPylonsAmmoCount = [];

        {
            _y params ["_magazine","_magazineAmmoCount"];

            private _pylon = _x;
            _weaponPylonsAmmoCount pushback [_pylon, _magazineAmmoCount];

            private _pylon = _x;
            _veh setAmmoOnPylon [_pylon, 0];
        } foreach _pylons;

        _disabledWeaponsAmmoCount set [_weapon, _weaponPylonsAmmoCount];
    };
} foreach _vehicleWeaponInfo;

_disabledWeaponsAmmoCount