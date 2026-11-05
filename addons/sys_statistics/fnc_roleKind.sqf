#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ALIVE_sys_statistics_fnc_roleKind
Description:
The kind of soldier a player is, for the War Room's role picture: medic and engineer from the unit's
abilities, the rest from its role and the words in its class name.

Parameters:
Object or String - a unit, or a CfgVehicles class

Returns:
String - rifleman, medic, engineer, pilot, crew, sniper, mg, at, officer, diver or other

Examples:
(begin example)
player call ALIVE_sys_statistics_fnc_roleKind;
(end)

Author:
Jman
---------------------------------------------------------------------------- */
private _class = if (_this isEqualType objNull) then { if (isNull _this) then {""} else {typeOf _this} } else { _this };
if !(_class isEqualType "") exitWith {"other"};
private _cfg = configFile >> "CfgVehicles" >> _class;
if (_class == "" || {!isClass _cfg} || {!(_class isKindOf "CAManBase")}) exitWith {"other"};

if (getNumber (_cfg >> "attendant") == 1) exitWith {"medic"};

// the role first (vanilla and the CDLCs fill it in), then the words of the class name. Crews and pilots
// come before engineers: RHS lets its crewmen repair, and they're still crew.
private _role = toLower getText (_cfg >> "role");
private _lower = toLower _class;
if ((["pilot", "aviator"] findIf { (_lower find _x) >= 0 }) >= 0) exitWith {"pilot"};
if (_role == "crewman" || {(_lower find "crew") >= 0}) exitWith {"crew"};
if (getNumber (_cfg >> "engineer") == 1 || {getNumber (_cfg >> "canDeactivateMines") == 1}) exitWith {"engineer"};
private _words = _lower splitString "_";
private _any = { (_this findIf { _x in _words }) >= 0 };
private _part = { (_this findIf { (_lower find _x) >= 0 }) >= 0 };
switch (true) do {
    case (["diver", "frogman"] call _part): {"diver"};
    case (_role in ["marksman", "sniper"] || {["sniper", "marksman", "spotter", "sharpshooter"] call _part} || {["m", "dmr", "sn", "sp"] call _any}): {"sniper"};
    case (_role == "machinegunner" || {["mg", "ar", "lmg", "hmg", "mmg"] call _any} || {["machinegun", "autorifle"] call _part}): {"mg"};
    case (_role == "missilespecialist" || {["at", "aa", "lat", "hat", "rpg", "maaws", "smaw", "javelin", "stinger", "igla"] call _any}): {"at"};
    case (["officer", "commander", "sl", "tl", "squadleader", "teamleader", "leader", "captain"] call _any || {["officer", "leader", "commander"] call _part}): {"officer"};
    default {"rifleman"};
};
