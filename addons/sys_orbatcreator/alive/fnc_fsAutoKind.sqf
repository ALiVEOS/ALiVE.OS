#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsAutoKind);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsAutoKind

Description:
What kind of vehicle a studio vehicle is, for AUTO GROUPS and the ALiVE lists,
and how many men it carries. Read from its base class's config only; nothing is
spawned. Cargo seats are transportSoldier plus every turret (at any depth) that
a passenger sits in (isPersonTurret above 0). Kinds, first match:
    uav, static        - a drone; a static weapon (never grouped)
    artillery          - has an artillery computer
    aa                 - listed by the game as anti-air
    support            - carries ammo, fuel or repairs, or is a medical vehicle
    heli, plane, boat
    tank               - a tank or wheeled APC the game lists under Tanks (some carry
                         passengers, so seats alone cannot tell)
    carrier_armoured   - any other tank or wheeled APC with 4 or more cargo seats
    tank               - one with fewer
    carrier_soft       - a car with 2 or more cargo seats
    car                - any other car
    ""                 - none of these

Parameters:
    _vehicle - HASHMAP or STRING - a studio vehicle, or a CfgVehicles class

Returns:
    ARRAY - [kind, cargoSeats]

Examples:
    (begin example)
    ([_veh] call ALiVE_fnc_fsAutoKind) params ["_kind", "_seats"];
    (end)

See Also:
    ALiVE_fnc_fsAutoRole, ALiVE_fnc_fsAutoGroups

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_vehicle", "", ["", createHashMap]]];

private _class = if (_vehicle isEqualType "") then { _vehicle } else { _vehicle getOrDefault ["base", ""] };
private _cfg = configFile >> "CfgVehicles" >> _class;
if (!isClass _cfg) exitWith { ["", 0] };

private _seats = getNumber (_cfg >> "transportSoldier");
private _walk = {
    params ["_turrets"];
    {
        if (getNumber (_x >> "isPersonTurret") > 0) then { _seats = _seats + 1 };
        [_x >> "Turrets"] call _walk;
    } forEach ("true" configClasses _turrets);
};
[_cfg >> "Turrets"] call _walk;

private _is = { _class isKindOf [_this, configFile >> "CfgVehicles"] };
private _armour = "Tank" call _is || {"Wheeled_APC_F" call _is};

private _kind = switch (true) do {
    case (getNumber (_cfg >> "isUav") == 1): { "uav" };
    case ("StaticWeapon" call _is): { "static" };
    case (getNumber (_cfg >> "artilleryScanner") == 1): { "artillery" };
    case (getText (_cfg >> "editorSubcategory") isEqualTo "EdSubcat_AAs"): { "aa" };
    case (getNumber (_cfg >> "transportAmmo") > 0 || {getNumber (_cfg >> "transportFuel") > 0} || {getNumber (_cfg >> "transportRepair") > 0} || {getNumber (_cfg >> "attendant") == 1}): { "support" };
    case ("Helicopter" call _is): { "heli" };
    case ("Plane" call _is): { "plane" };
    case ("Ship" call _is): { "boat" };
    case (_armour && {(getText (_cfg >> "editorSubcategory")) isEqualTo "EdSubcat_Tanks"}): { "tank" };
    case (_armour && {_seats >= 4}): { "carrier_armoured" };
    case (_armour): { "tank" };
    case ("Car" call _is && {_seats >= 2}): { "carrier_soft" };
    case ("Car" call _is): { "car" };
    default { "" };
};
[_kind, _seats]
