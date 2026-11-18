#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsAutoRole);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsAutoRole

Description:
A studio man's part in AUTO GROUPS. His own "role" when one is set; otherwise
worked out from his stored loadout, his name and his base class, first match:
    pilot, crew - the name or base class says pilot, or crew
    leader      - the name says leader, officer, commander or sergeant
    medic       - the base class is a medic (attendant), or he carries a Medikit
    aa, at      - he has a launcher; aa when its missile locks on to aircraft
    mg          - his rifle is a machine gun
    marksman    - his rifle is a sniper rifle
    rifleman    - everyone else
Reads config only; nothing is spawned.

Parameters:
    _unit - HASHMAP - a studio unit

Returns:
    STRING - one of FS_ROLES

Examples:
    (begin example)
    private _role = [_unit] call ALiVE_fnc_fsAutoRole;
    (end)

See Also:
    ALiVE_fnc_fsAutoKind, ALiVE_fnc_fsAutoGroups

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_unit", createHashMap, [createHashMap]]];

private _set = _unit getOrDefault ["role", ""];
if (_set in FS_ROLES) exitWith { _set };

private _name = toLower (_unit getOrDefault ["name", ""]);
private _base = _unit getOrDefault ["base", ""];
private _baseLow = toLower _base;
private _cfg = configFile >> "CfgVehicles" >> _base;
private _loadout = _unit getOrDefault ["loadout", []];
private _has = { params ["_text", "_words"]; (_words findIf { (_text find _x) >= 0 }) >= 0 };

// every class name anywhere in the loadout
private _items = [];
private _gather = {
    params ["_a"];
    { if (_x isEqualType "") then { _items pushBack toLower _x } else { if (_x isEqualType []) then { [_x] call _gather } } } forEach _a;
};
[_loadout] call _gather;

if ([_name, ["pilot"]] call _has || {[_baseLow, ["pilot"]] call _has}) exitWith { "pilot" };
if ([_name, ["crew"]] call _has || {[_baseLow, ["crew"]] call _has}) exitWith { "crew" };
if ([_name, ["leader", "officer", "commander", "sergeant"]] call _has) exitWith { "leader" };
if (getNumber (_cfg >> "attendant") == 1 || {"medikit" in _items}) exitWith { "medic" };

private _launcher = _loadout param [1, []];
if (_launcher isEqualType [] && {count _launcher > 0} && {!((_launcher select 0) isEqualTo "")}) exitWith {
    private _mag = (_launcher param [4, []]) param [0, ""];
    if (_mag isEqualTo "") then { _mag = ([_launcher select 0] call BIS_fnc_compatibleMagazines) param [0, ""] };
    private _ammo = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
    if (getNumber (configFile >> "CfgAmmo" >> _ammo >> "airLock") == 2) then { "aa" } else { "at" }
};

private _primary = _loadout param [0, []];
private _type = if (_primary isEqualType [] && {count _primary > 0} && {!((_primary select 0) isEqualTo "")}) then { ([_primary select 0] call BIS_fnc_itemType) param [1, ""] } else { "" };
if (_type isEqualTo "MachineGun") exitWith { "mg" };
if (_type isEqualTo "SniperRifle") exitWith { "marksman" };
"rifleman"
