#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ALIVE_sys_statistics_fnc_weaponKind
Description:
The kind of weapon a class is, for the War Room's pictures: one word from a fixed list, worked out from
config so vanilla, the CDLCs, RHS and CUP all answer the same way.

Parameters:
String - a CfgWeapons class (a soldier's weapon, a vehicle's gun, or "Throw" / "Put")

Returns:
String - rifle, sniper, mg, smg, pistol, shotgun, launcher, grenade, explosive, cannon, missile, bomb,
artillery or other ("runover" is set by the kill handler itself)

Examples:
(begin example)
"arifle_MX_F" call ALIVE_sys_statistics_fnc_weaponKind; // "rifle"
(end)

Author:
Jman
---------------------------------------------------------------------------- */
private _class = _this;
if !(_class isEqualType "") exitWith {"other"};
private _cfg = configFile >> "CfgWeapons" >> _class;
if (_class == "" || {!isClass _cfg}) exitWith {"other"};
if (_class isKindOf ["Throw", configFile >> "CfgWeapons"]) exitWith {"grenade"};
if (_class isKindOf ["Put", configFile >> "CfgWeapons"]) exitWith {"explosive"};

private _type = getNumber (_cfg >> "type");
private _cursor = toLower getText (_cfg >> "cursor");

// carried weapons: 1 primary, 2 handgun, 4 launcher
if (_type == 2) exitWith {"pistol"};
if (_type == 4) exitWith {"launcher"};
if (_type == 1) exitWith {
    switch (true) do {
        case (_cursor == "srifle"): {"sniper"};
        case (_cursor == "mg"): {"mg"};
        case (_cursor == "smg"): {"smg"};
        case (_cursor in ["sgun", "shotgun"]): {"shotgun"};
        // buckshot: the first magazine's round spreads or splits into pellets
        case (call {
            private _a = configFile >> "CfgAmmo" >> getText (configFile >> "CfgMagazines" >> ((getArray (_cfg >> "magazines")) param [0, ""]) >> "ammo");
            isClass _a && {(toLower getText (_a >> "simulation")) == "shotspread" || {isArray (_a >> "submunitionConeType")} || {(toLower getText (_a >> "submunitionAmmo")) find "pellet" >= 0}}
        }): {"shotgun"};
        case (_class isKindOf ["Rifle_Long_Base_F", configFile >> "CfgWeapons"] && {_cursor != "arifle"}): {"sniper"};
        default {
            // a rifle with no automatic fire mode is a marksman's or sniper's (RHS and CUP leave the cursor
            // as arifle on most of theirs)
            private _modes = (getArray (_cfg >> "modes")) apply { if (_x == "this") then {_cfg} else {_cfg >> _x} };
            private _auto = _modes findIf { getNumber (_x >> "autoFire") == 1 || {getNumber (_x >> "burst") > 1} };
            if (_modes isNotEqualTo [] && {_auto < 0}) then {"sniper"} else {"rifle"}
        };
    };
};

// a vehicle's weapon: by what its first magazine fires
private _mags = getArray (_cfg >> "magazines");
if (_mags isEqualTo []) then {
    {
        _mags = getArray (_cfg >> _x >> "magazines");
        if (_mags isNotEqualTo []) exitWith {};
    } forEach ((getArray (_cfg >> "muzzles")) - ["this"]);
};
if (_mags isEqualTo []) exitWith {"other"};
private _ammo = getText (configFile >> "CfgMagazines" >> (_mags select 0) >> "ammo");
private _acfg = configFile >> "CfgAmmo" >> _ammo;
if (!isClass _acfg) exitWith {"other"};
private _sim = toLower getText (_acfg >> "simulation");
switch (true) do {
    case (_ammo isKindOf ["BombCore", configFile >> "CfgAmmo"]): {"bomb"};
    case (_sim in ["shotmissile", "shotrocket"]): {"missile"};
    case (_sim in ["shotshell", "shotsubmunitions"]): {
        if (getNumber (_acfg >> "artilleryLock") == 1 || {getNumber (_cfg >> "ballisticsComputer") == 4}) then {"artillery"} else {"cannon"}
    };
    case (_class isKindOf ["CannonCore", configFile >> "CfgWeapons"]): {
        if (getNumber (_acfg >> "artilleryLock") == 1) then {"artillery"} else {"cannon"}
    };
    case (_sim in ["shotbullet", "shotspread"]): {"mg"};
    case (_sim in ["shotmine", "shotdirectionalbomb", "shotboundingmine", "shotpipebomb"]): {"explosive"};
    case (_sim == "shotgrenade"): {"grenade"};
    default {"other"};
};
