params ["_entity"];

private _arty = _entity getvariable "ArtilleryClass";

private _vehicleAmmo = createHashMap;
private _magazineAmmo = magazinesAmmo _arty;

private _getMagazineInfo = {
    params ["_magazine"];
    
    private _magazineClass = configfile >> "CfgMagazines" >> _magazine;
    if (isClass _magazineClass) then {
        createHashMapFromArray [
            ["displayNameShort", getText (_magazineClass >> "displayNameShort")],
            ["displayNameType", getText (_magazineClass >> "displayNameMFDFormat")],
            ["magazine", _magazine],
            ["ammo", getText (_magazineClass >> "ammo")]
        ]
    };
};

{
    _x params ["_magazineType","_magazineAmmo"];
    
    private _magDetails = _vehicleAmmo get _magazineType;
    if (isnil "_magDetails") then {
        _magDetails = [_magazineType] call _getMagazineInfo;
        _magDetails set ["roundsLeft", 0];
        
        _vehicleAmmo set [_magazineType, _magDetails];
    };
    
    _magDetails set ["roundsLeft", (_magDetails get "roundsLeft") + _magazineAmmo];
} foreach _magazineAmmo;

_vehicleAmmo

str [
	["HE", 30],
	["WP", 30],
	["SMOKE", 30],
	["FLARE", 30]
]