#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(getArtyMagazines);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getArtyMagazines

Description:
Collect every magazine classname an artillery vehicle can fire. Walks the
turret tree recursively (mod artillery often nests the gun turret) and, for
each turret, gathers magazines from three places: the turret's magazines[]
array, its magazineWell[] entries (resolved through CfgMagazineWells), and
its weapons[] - many vehicles list no magazines on the turret at all and
define them on the weapon (CfgWeapons magazines[]/magazineWell, including
per-muzzle definitions).

Parameters:
String - vehicle classname

Returns:
Array of magazine classnames (may contain duplicates across turrets)

Examples:
(begin example)
_mags = "RHS_BM21_MSV_01" call ALIVE_fnc_getArtyMagazines;
(end)

Author:
Jman
---------------------------------------------------------------------------- */

private _class = _this;
private _mags = [];

// magazineWell indirection: each well class holds one or more arrays of
// magazine names (typically one array per contributing addon)
private _fnc_wells = {
    params ["_cfg"];
    {
        private _well = configFile >> "CfgMagazineWells" >> _x;
        if (isClass _well) then {
            {
                _mags append (getArray _x);
            } forEach configProperties [_well, "isArray _x", true];
        };
    } forEach (getArray (_cfg >> "magazineWell"));
};

// weapons carry their own magazine lists (and per-muzzle lists)
private _fnc_weapon = {
    params ["_wName"];
    private _w = configFile >> "CfgWeapons" >> _wName;
    if (!isClass _w) exitWith {};
    _mags append (getArray (_w >> "magazines"));
    [_w] call _fnc_wells;
    {
        _mags append (getArray (_x >> "magazines"));
        [_x] call _fnc_wells;
    } forEach ("isClass _x" configClasses _w);
};

private _fnc_collect = {
    params ["_cfg"];
    _mags append (getArray (_cfg >> "magazines"));
    [_cfg] call _fnc_wells;
    {
        [_x] call _fnc_weapon;
    } forEach (getArray (_cfg >> "weapons"));
};

private _fnc_walkTurrets = {
    params ["_cfg"];
    {
        [_x] call _fnc_collect;
        if (isClass (_x >> "Turrets")) then {
            [_x >> "Turrets"] call _fnc_walkTurrets;
        };
    } forEach ("isClass _x" configClasses _cfg);
};

private _vehCfg = configFile >> "CfgVehicles" >> _class;

[_vehCfg] call _fnc_collect;
if (isClass (_vehCfg >> "Turrets")) then {
    [_vehCfg >> "Turrets"] call _fnc_walkTurrets;
};

_mags
