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
if !(_class isKindOf "LandVehicle") exitWith { false };

// Nothing to shoot with, nothing to suppress. On its own this removes the
// unarmed vehicles that prompted the report.
private _magazines = [];
if (!isNil "BIS_fnc_magazinesEntityType") then {
    _magazines = [_class, true] call BIS_fnc_magazinesEntityType;
};
if (count _magazines == 0) exitWith { false };

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

if (_airCapable) exitWith { true };

// Gun-based air defence carries no guided rounds, so fall back to a turret that
// elevates far enough to track aircraft and is not an artillery piece. Only
// reached by vehicles already established as armed, which is what keeps an
// unarmed hull with a high-elevation mount out of the result.
private _maxElev = getNumber (configFile >> "CfgVehicles" >> _class >> "Turrets" >> "MainTurret" >> "maxElev");
private _isArtillery = getNumber (configFile >> "CfgVehicles" >> _class >> "artilleryScanner") > 0;

(_maxElev > 65) && {!_isArtillery}
