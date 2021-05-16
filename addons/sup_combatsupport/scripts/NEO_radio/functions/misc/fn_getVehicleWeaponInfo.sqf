params ["_vehicle"];

private _weapons = [typeof _vehicle] call BIS_fnc_weaponsEntityType;
private _pylonMagazines = getPylonMagazines _vehicle;

private _weaponInfo = createHashMap;

{
    if (_x != "") then {
        private _magazine = _x;
        private _pylon = _foreachindex + 1;
        private _magazineConfig = configfile >> "CfgMagazines" >> _magazine;
        private _pylonAmmo = _vehicle ammoOnPylon _pylon;
        
        private _weapon = gettext (_magazineConfig >> "pylonWeapon");
        private _weaponDisplayName = gettext (configfile >> "CfgWeapons" >> _weapon >> "displayName");
        
        private _existingWeaponData = _weaponInfo get _weapon;
        if (isnil "_existingWeaponData") then {
            _existingWeaponData = createHashMapFromArray [
                ["weapon", _weapon],
                ["weaponDisplayName", _weaponDisplayName], 
                ["pylons", createHashMap]
            ];
            _weaponInfo set [_weapon, _existingWeaponData];
        };
        
        private _pylons = _existingWeaponData get "pylons";
        _pylons set [_pylon, [_magazine, _pylonAmmo]];
    };
} foreach _pylonMagazines;

_weaponInfo