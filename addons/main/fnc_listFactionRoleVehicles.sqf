#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(listFactionRoleVehicles);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_listFactionRoleVehicles

Description:
    Enumerates every spawnable CfgVehicles class suitable for a Combat
    Support role, across ALL loaded factions. Feeder for the Eden vehicle
    pickers on the SUP CAS / SUP Artillery / SUP Transport modules.

    Roles:
      "cas"       - armed aircraft (planes and helicopters, incl. UAVs)
      "arty"      - artillery pieces (artilleryScanner + high-elevation gun,
                    covers self-propelled guns, MLRS, static mortars)
      "transport" - helicopters that can carry troops or slingload

    Results are cached per role in uiNamespace for the Eden session - the
    full CfgVehicles walk only runs once per role.

Parameters:
    0 - role [string]

Returns:
    Array of [class, displayName, sideText, factionDisplay, sourceMod]

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_role", "cas", [""]]];
_role = toLower _role;

private _cacheKey = format ["ALiVE_roleVehicleCache_%1", _role];
private _cached = uiNamespace getVariable [_cacheKey, []];
if !(_cached isEqualTo []) exitWith { _cached };

// utility weapons that don't make an aircraft "armed"
private _utilityWeapons = ["fakeweapon", "cmflarelauncher", "smokelauncher", "rockets_smoke"];

private _fnc_isArmedAir = {
    params ["_cfg"];
    private _weps = getArray (_cfg >> "weapons");
    {
        _weps append (getArray (_x >> "weapons"));
    } forEach ("isClass _x" configClasses (_cfg >> "Turrets"));
    private _armed = false;
    {
        private _w = toLower _x;
        if !(_w in _utilityWeapons || {(_w select [0, 15]) == "laserdesignator"}) exitWith { _armed = true };
    } forEach _weps;
    _armed
};

private _fnc_isArtillery = {
    params ["_cfg", "_class"];
    if (getNumber (_cfg >> "artilleryScanner") <= 0) exitWith { false };
    // any turret elevating past 45 degrees counts (walk all turrets, not
    // just MainTurret - mod artillery often mounts the gun elsewhere).
    // 45 rather than 65 so rocket artillery's ~55-degree tubes qualify
    private _high = false;
    {
        if (getNumber (_x >> "maxElev") > 45) exitWith { _high = true };
    } forEach ("isClass _x" configClasses (_cfg >> "Turrets"));
    _high
};

private _result = [];
private _seen = createHashMap;

{
    private _cfg = _x;
    private _class = configName _cfg;
    private _classLower = toLower _class;
    if !(_classLower in _seen) then {
        _seen set [_classLower, true];
        if (getNumber (_cfg >> "scope") >= 2) then {

            // cheap kind gate first, expensive predicate second
            private _keep = switch (_role) do {
                case "cas": {
                    (_class isKindOf "Plane" || {_class isKindOf "Helicopter"})
                    && {[_cfg] call _fnc_isArmedAir}
                };
                case "arty": {
                    _class isKindOf "LandVehicle"
                    && {[_cfg, _class] call _fnc_isArtillery}
                };
                case "transport": {
                    _class isKindOf "Helicopter"
                    && {getNumber (_cfg >> "transportSoldier") > 0 || {getNumber (_cfg >> "slingLoadMaxCargoMass") > 0}}
                };
                default { false };
            };

            if (_keep) then {
                private _display = getText (_cfg >> "displayName");
                if (_display == "") then { _display = _class };

                private _vehFaction = getText (_cfg >> "faction");
                private _fCfg = configFile >> "CfgFactionClasses" >> _vehFaction;
                private _sideText = "Other";
                private _factionDisplay = "";
                if (isClass _fCfg) then {
                    _sideText = switch (getNumber (_fCfg >> "side")) do {
                        case 0: { "EAST" };
                        case 1: { "WEST" };
                        case 2: { "GUER" };
                        case 3: { "CIV" };
                        default { "Other" };
                    };
                    _factionDisplay = getText (_fCfg >> "displayName");
                };
                if (_factionDisplay == "") then { _factionDisplay = if (_vehFaction != "") then { _vehFaction } else { "No faction" } };

                private _source = configSourceMod _cfg;
                if (_source == "") then { _source = "Vanilla" };

                _result pushBack [_class, _display, _sideText, _factionDisplay, _source];
            };
        };
    };
} forEach ("true" configClasses (configFile >> "CfgVehicles"));

_result sort true;

uiNamespace setVariable [_cacheKey, _result];

_result
