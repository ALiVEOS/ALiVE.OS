params ["_veh","_disabledWeaponsAmmoCount"];

{
    private _weapon = _x;
    private _weaponPylonsAmmoCount = _y;

    {
        _X params ["_pylon","_pylonAmmo"];
        _veh setAmmoOnPylon [_pylon, _pylonAmmo];
    } foreach _weaponPylonsAmmoCount;
} foreach _disabledWeaponsAmmoCount;