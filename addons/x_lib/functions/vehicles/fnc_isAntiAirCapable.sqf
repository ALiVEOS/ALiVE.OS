#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(isAntiAirCapable);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_isAntiAirCapable

Description:
    Reports whether a ground vehicle can actually engage aircraft.

    Written for suppression-of-air-defence target selection, which previously
    reported unarmed cars and troop carriers as air defence (#828). Two separate
    tests were responsible, and both asked the wrong question:

      threat[2] > 0.4 && isKindOf LandVehicle && cost > 20000
        threat[] is a coarse hint about how dangerous the AI should treat
        something, inherited from base classes, and says nothing about what a
        vehicle can shoot at. With a price floor attached this asked little more
        than "is this an expensive land vehicle?".

      maxElev > 65 && artilleryScanner == 0     (ALiVE_fnc_isAA)
        satisfied by any hull carrying a high-elevation remote mount, armed or
        not. Still the right question for other callers - it is about where a
        turret can point, which is what the virtual damage model wants to know -
        so ALiVE_fnc_isAA is deliberately left alone.

    This asks what the vehicle can shoot with instead.

Parameters:
    _class : STRING or OBJECT - vehicle class name, or a live vehicle

Returns:
    BOOL - true when the vehicle carries munitions able to engage aircraft, or
    is an armed high-elevation mount of the kind used for gun-based air defence.

Examples:
    (begin example)
    if ([_vehicleClass] call ALiVE_fnc_isAntiAirCapable) then { ... };
    (end)

See Also:
    ALiVE_fnc_isAA - turret elevation test, used by the damage model
    ALiVE_fnc_getAircraftCapabilities - the equivalent question for aircraft

Author:
    Jman
---------------------------------------------------------------------------- */

params [
    ["_class", "", ["", objNull]]
];

if (_class isEqualType objNull) then { _class = typeOf _class };
if (_class == "") exitWith { false };

// A mission maker's own word comes first (ren on Discord, 11 Nov: modded IFVs such as the BTR-82
// pass the gun test, so Air Defence Spawning kept spawning them). Each list holds class names, and
// a class counts if it is or inherits from one of them, so a base class covers its variants. Read
// before the cache, so a list changed mid-mission applies at once. Set on the server, e.g. in init.sqf:
//   ALiVE_antiAirExclude = ["rhs_btr80a_msv"];   never anti-air
//   ALiVE_antiAirInclude = ["my_aa_truck"];      always anti-air
// The ALiVE (Required) module's Anti-air: never count and Anti-air: always count fields (ren, 13 Nov) add to
// these lists without init.sqf; both are read, so neither overwrites the other.
private _lists = missionNamespace getVariable "ALiVE_antiAirModuleLists";
if (isNil "_lists") then {
    _lists = [[], []];
    {
        private _module = _x;
        {
            private _text = _module getVariable [_x, ""];
            if (_text isEqualType "") then { (_lists select _forEachIndex) append ((_text splitString ", ;") select { _x != "" }) };
        } forEach ["ALiVE_AA_NEVER", "ALiVE_AA_ALWAYS"];
    } forEach (entities "ALiVE_require");
    // the module exists once the mission is running; before that, look again next time
    if (time > 0) then { ALiVE_antiAirModuleLists = _lists };
};
private _exclude = missionNamespace getVariable ["ALiVE_antiAirExclude", []];
if !(_exclude isEqualType []) then { _exclude = [] };
_exclude = _exclude + (_lists select 0);
if ((_exclude findIf { _x isEqualType "" && {_x != ""} && {_class isKindOf _x} }) >= 0) exitWith { false };
private _include = missionNamespace getVariable ["ALiVE_antiAirInclude", []];
if !(_include isEqualType []) then { _include = [] };
_include = _include + (_lists select 1);
if ((_include findIf { _x isEqualType "" && {_x != ""} && {_class isKindOf _x} }) >= 0) exitWith { true };

if (isNil "ALIVE_isAntiAirCapableCache") then {
    ALIVE_isAntiAirCapableCache = createHashMap;
};

if (_class in ALIVE_isAntiAirCapableCache) exitWith {
    ALIVE_isAntiAirCapableCache get _class
};

if !(_class isKindOf "LandVehicle") exitWith {
    ALIVE_isAntiAirCapableCache set [_class, false];
    false
};

// Nothing to shoot with, nothing to suppress. On its own this removes the
// unarmed vehicles that prompted the report.
private _magazines = [];
if (!isNil "BIS_fnc_magazinesEntityType") then {
    _magazines = [_class, true] call BIS_fnc_magazinesEntityType;
};
if (count _magazines == 0) exitWith {
    ALIVE_isAntiAirCapableCache set [_class, false];
    false
};

// Munitions that can take a lock on something moving at aircraft speed.
// airLock is the engine's own distinction and it is exact: 1 locks ground
// targets, 2 locks air - so an anti-tank missile is excluded and an anti-air
// missile is not. missileLockMaxSpeed covers launchers that express the same
// thing as a tracking speed instead.
private _airCapable = false;
{
    private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
    if (_ammo != "") then {
        private _ammoCfg = configFile >> "CfgAmmo" >> _ammo;
        if (
            getNumber (_ammoCfg >> "airLock") > 1
            || {getNumber (_ammoCfg >> "missileLockMaxSpeed") >= 150}
        ) exitWith { _airCapable = true };
    };
} forEach _magazines;

if (_airCapable) exitWith {
    ALIVE_isAntiAirCapableCache set [_class, true];
    true
};

// Gun-based air defence carries no guided rounds, so fall back to a turret that
// elevates far enough to track aircraft and is not an artillery piece. Only
// reached by vehicles already established as armed, which is what keeps an
// unarmed hull with a high-elevation mount out of the result.
private _maxElev = getNumber (configFile >> "CfgVehicles" >> _class >> "Turrets" >> "MainTurret" >> "maxElev");
private _isArtillery = getNumber (configFile >> "CfgVehicles" >> _class >> "artilleryScanner") > 0;
// The elevation test is for gun air defence (an autocannon's rounds don't lock on, so the ammo test above
// misses it). A missile launcher whose missiles failed that test is AT, however high it aims: static AT
// launchers (Titan AT, Mini-Spike, AT-3) point near straight up and were all called air defence, so each
// one became an air defence task (A. Ares on Discord, 16 Oct). Only a vehicle with a gun counts here.
// (not the engine's FakeAmmo: every static launcher carries that dummy, and it is a bullet with hit 13)
private _hasGun = (_magazines findIf {
    private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
    !(_ammo isKindOf ["FakeAmmo", configFile >> "CfgAmmo"])
    && {(getText (configFile >> "CfgAmmo" >> _ammo >> "simulation")) in ["shotBullet", "shotShell", "shotSpread"]}
}) > -1;
private _result = (_maxElev > 65) && {!_isArtillery} && {_hasGun};

ALIVE_isAntiAirCapableCache set [_class, _result];

_result
