params ["_entity"];

private _arty = _entity getvariable "artilleryClassname";
systemchat format ["Entity: %1", allvariables _entity];
systemchat format ["Arty: %1", _arty];
private _weapons = _arty call BIS_fnc_weaponsEntityType;
private _magazines = [];

private _cfgMagazines = configfile >> "CfgMagazines";
systemchat format ["Weapons: %1", _weapons];
{
    private _weapon = _x;
    private _weaponMagazines = [_x] call BIS_fnc_compatibleMagazines;

    {
        private _weaponMagazine = _x;
        private _weaponMagazineConfig = _cfgMagazines >> _weaponMagazine;

        private _displayName = gettext (_weaponMagazineConfig >> "displayName");
        private _displayNameShort = gettext (_weaponMagazineConfig >> "displayNameShort");
        private _displayNameType = gettext (_weaponMagazineConfig >> "displayNameMFDFormat");
        private _ammo = gettext (_weaponMagazineConfig >> "ammo");
//systemchat format ["Checking: %1", [_weaponMagazine, _displayName, _displayNameShort, _displayNameType, _ammo]];
        _magazines pushback [_weaponMagazine, _displayName, _displayNameShort, _displayNameType, _ammo];
    } foreach _weaponMagazines;
} foreach _weapons;

// split above into dedicated function
// for now, parse into necessary format

private _magazinesValue = _magazines apply {
    [_x select 0, 30]
};

//systemchat str [_magazinesValue];

str _magazinesValue