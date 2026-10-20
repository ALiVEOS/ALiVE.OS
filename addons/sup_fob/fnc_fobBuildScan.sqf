#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobBuildScan);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fobBuildScan

Description:
The build catalog: what players can build at a FOB and what each costs, worked out once on the
server from the game's own config, so it covers whatever mods are loaded without a hand-typed
price list.

Fortifications are the military walls, fences and structures the editor lists (sandbags,
H-barriers, bunkers, towers, camo nets), a mod's own walls, fences and structures categories
included, plus portable lights. Supply objects are the ones that
rearm, refuel, repair or heal (ammo and fuel containers, repair depots, medical tents) and
helipads. Static weapons are offered to their own side, crewed by it. Ruins, wrecks and anything
wider than 40 m are left out.

A fortification's price grows with how tough it is and how big:
    3 + 72 x min(1, armour / 500) x sqrt(min(1, volume / 600)), 3 to 75
with a floor for what it does (wire 10, camo net 20, tower 40, light 5). A supply object's
price grows with how much it holds, 20 to 50; medical 35, helipads 25. Every price is then
multiplied by the module's Cost Scale and rounded, never below 1. A static weapon's price comes
from its role (machine gun 60, grenade launcher 75, mortar 100, AT and AA 125, howitzer 250),
moved up or down by how hard its hardest round hits, 50 to 250.

Vehicles: land vehicles and boats, never aircraft, priced by role and armour, 75 to 600 (see
_vehiclePrice). Static weapons and vehicles are offered from the factions the side's AI
Commanders field (all of its own side's when it has none), so a NATO FOB facing CSAT builds
NATO equipment.

Some items need a FOB of a higher tier: towers and machine guns or grenade launchers tier 2,
mortars, AT and AA launchers, howitzers and vehicles tier 3.

A mission or mod can change the catalog through CfgALiVEFOBBuildables, in description.ext or a
mod's config (the mission's wins):
    class CfgALiVEFOBBuildables {
        blacklist[] = {"Land_Razorwire_F"};      // never offered
        whitelist[] = {"Land_Pallets_F"};        // offered, priced as a fortification
        only[] = {"Land_BagFence_Short_F"};      // if set, the menu is exactly these
        class Land_HBarrier_5_F { cost = 7; };   // a fixed price (1 to 100000)
    };
A price that isn't a whole number from 1 to 100000 is refused with a warning in the RPT and
the worked-out price is used instead. The module's Never Build and Also Build fields add to the
blacklist and whitelist.

Sizes come from a local, unsimulated copy of each object, measured a few at a time, and are
kept in the server's profile, so later starts skip the measuring.

Parameters:
None

Returns:
Number - the catalog's size. Sets ALiVE_FOB_catalog on every machine:
[[class, display name, category, cost, picture, tier needed, side, faction (lower case)], ...]
and ALiVE_FOB_sideFactions: [[side, [factions its commanders field]], ...]

Author:
Jman
---------------------------------------------------------------------------- */

if (isRemoteExecuted && {remoteExecutedOwner != 2} && {isNil "_ALiVE_fobCaller"}) exitWith {};
if (!isServer) exitWith {0};

// ["factions"]: the factions each side's AI Commanders field, lower case, sent to every machine
// when they change. Static weapons and vehicles are offered from these factions only; a side
// with no commander is offered its own side's.
if ((_this param [0, ""]) isEqualTo "factions") exitWith {
    private _bySide = ["WEST", "EAST", "GUER"] apply {
        private _side = _x;
        private _f = [];
        { if (([_x, "side", ""] call ALiVE_fnc_HashGet) == _side) then { { _f pushBackUnique toLower _x } forEach ([_x, "factions", []] call ALiVE_fnc_HashGet) } } forEach (missionNamespace getVariable ["OPCOM_instances", []]);
        _f sort true;
        [_side, _f]
    };
    if !(_bySide isEqualTo (missionNamespace getVariable ["ALiVE_FOB_sideFactions", []])) then {
        ALiVE_FOB_sideFactions = _bySide;
        publicVariable "ALiVE_FOB_sideFactions";
        ["ALiVE Player FOBs - factions offered static weapons and vehicles: %1", _bySide] call ALiVE_fnc_dump;
    };
    _bySide
};

private _logic = missionNamespace getVariable ["ALiVE_sup_fob", objNull];
private _scale = [_logic, "attribute", ["fob_cost_scale"]] call ALiVE_fnc_FOB;
private _t0 = diag_tickTime;

// Overrides: the mission's config first, then any mod's
private _blacklist = [];
private _whitelist = [];
private _only = [];
private _fixed = createHashMap;
{
    private _root = _x >> "CfgALiVEFOBBuildables";
    if (isClass _root) then {
        _blacklist append ((getArray (_root >> "blacklist")) select { _x isEqualType "" } apply { toLower _x });
        _whitelist append ((getArray (_root >> "whitelist")) select { _x isEqualType "" });
        // only[]: the menu is exactly these; the mission's list, else the first mod's
        if (_only isEqualTo []) then { _only = (getArray (_root >> "only")) select { _x isEqualType "" } };
        {
            private _k = toLower configName _x;
            if (!(_k in _fixed) && {isNumber (_x >> "cost")}) then {
                private _c = getNumber (_x >> "cost");
                if (_c >= 1 && {_c <= 100000} && {_c == floor _c}) then {
                    _fixed set [_k, _c];
                } else {
                    ["ALiVE Player FOBs - CfgALiVEFOBBuildables: cost %1 for %2 isn't a whole number from 1 to 100000; using the worked-out price", _c, configName _x] call ALiVE_fnc_dumpR;
                };
            };
        } forEach ("true" configClasses _root);
    };
} forEach [missionConfigFile, configFile];
// and the module's own Never Build and Also Build lists, class names separated by commas
_blacklist append (([_logic, "attribute", ["fob_blacklist"]] call ALiVE_fnc_FOB) splitString ", ;" apply { toLower _x });
_whitelist append (([_logic, "attribute", ["fob_whitelist"]] call ALiVE_fnc_FOB) splitString ", ;");
// never the kit or supply crate themselves: one built here would be a crate of supply for its build price
_blacklist append ["alive_fob_kit", "alive_fob_supplycrate"];
// and the mission's own kit and crate objects, if it sets any
{
    { private _p = _x splitString "= "; if (_p isNotEqualTo []) then { _blacklist pushBack toLower (_p select (count _p - 1)) } } forEach (([_logic, "attribute", [_x]] call ALiVE_fnc_FOB) splitString ",;");
} forEach ["fob_kit_class", "fob_crate_class"];

// Sizes measured on earlier starts
private _sizes = profileNamespace getVariable ["ALiVE_FOB_sizes", createHashMap];
if !(_sizes isEqualType createHashMap) then { _sizes = createHashMap };
private _measured = 0;

// [volume m3, widest side m] of a class, measured on a local copy once and kept
private _size = {
    params ["_class"];
    private _have = _sizes get _class;
    if (!isNil "_have") exitWith { _have };
    private _o = createSimpleObject [_class, [0, 0, 1000], true];
    private _s = [0, 0];
    if (!isNull _o) then {
        private _d = ((boundingBoxReal _o) select 1) vectorDiff ((boundingBoxReal _o) select 0);
        _s = [abs ((_d select 0) * (_d select 1) * (_d select 2)), (abs (_d select 0)) max (abs (_d select 1))];
        deleteVehicle _o;
    };
    _sizes set [_class, _s];
    _measured = _measured + 1;
    if (_measured % 25 == 0) then { sleep 0.01 };
    _s
};

private _service = ["transportAmmo", "transportFuel", "transportRepair", "attendant"];
private _isRuin = { params ["_c", "_cfg"]; (_c isKindOf "Ruins_F") || {"ruin" in toLower _c} || {"wreck" in toLower _c} || {"Ruins" in getText (_cfg >> "editorCategory")} };

private _price = {
    params ["_class", "_cfg", "_kind"];
    private _lc = toLower _class;
    if (_kind == "SUPPLY") exitWith {
        if ("helipad" in _lc) exitWith { 25 };
        if (getNumber (_cfg >> "attendant") > 0) exitWith { 35 };
        private _u = ((getNumber (_cfg >> "transportAmmo")) max 0 min 2000) / 2000
            + ((getNumber (_cfg >> "transportFuel")) max 0 min 2000) / 2000
            + ((getNumber (_cfg >> "transportRepair")) max 0 min 2000) / 2000
            + ((getNumber (_cfg >> "maximumLoad")) max 0 min 4000) / 4000;
        round (20 + 30 * (_u min 1))
    };
    ([_class] call _size) params ["_vol"];
    private _a = (getNumber (_cfg >> "armor")) max 0;
    private _c = 3 + 72 * ((_a / 500) min 1) * sqrt ((_vol / 600) min 1);
    private _floor = switch (true) do {
        case ("tower" in _lc || {"patrol" in _lc}): {40};
        case ("camonet" in _lc): {20};
        case ("wire" in _lc): {10};
        case ("light" in _lc): {5};
        default {3};
    };
    round ((_c max _floor) min 75)
};

// A static weapon's role and price: what it fires and how hard it hits
//   MG 60, grenade launcher 75, mortar 100, AT 125, AA 125, howitzer 250, each from 0.85 to
//   1.15 times that by the hardest-hitting round it has; heavy AA and AT a fifth more; then
//   kept inside the role's own band (MG 50-70, grenade launcher 60-90, mortar 90-110, AT
//   125-180, AA 125-150, howitzer 200-250).
// A missile that can't lock on to aircraft makes it AT, tested first, so a gun with both kinds
// is AT; one with only air-locking missiles is AA.
private _staticPrice = {
    params ["_class", "_cfg"];
    private _maxHit = 0;
    private _groundMissile = false;
    private _airLock = false;
    private _grenade = false;
    private _turrets = [];
    private _walk = { params ["_t"]; { _turrets pushBack _x; [_x >> "Turrets"] call _walk } forEach ("true" configClasses _t) };
    [_cfg >> "Turrets"] call _walk;
    {
        private _t = _x;
        { if (getNumber (configFile >> "CfgWeapons" >> _x >> "airLock") >= 2) then { _airLock = true } } forEach (getArray (_t >> "weapons"));
        {
            private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
            private _a = configFile >> "CfgAmmo" >> _ammo;
            private _hit = (getNumber (_a >> "hit")) max 0 min 5000;
            _maxHit = _maxHit max _hit;
            if (_ammo isKindOf ["MissileBase", configFile >> "CfgAmmo"] || {_ammo isKindOf ["RocketBase", configFile >> "CfgAmmo"]}) then {
                if (getNumber (_a >> "airLock") >= 2) then { _airLock = true } else { _groundMissile = true };
            };
            if (_ammo isKindOf ["G_40mm_HE", configFile >> "CfgAmmo"] || {_ammo isKindOf ["G_20mm_HE", configFile >> "CfgAmmo"]}) then { _grenade = true };
        } forEach (getArray (_t >> "magazines"));
    } forEach _turrets;
    if (_maxHit <= 0) exitWith { [-1, ""] };
    ([
        [_class isKindOf "StaticMortar", ["MORTAR", 100, 60, 90, 110]],
        [getNumber (_cfg >> "artilleryScanner") == 1, ["HOWITZER", 250, 120, 200, 250]],
        [_groundMissile, ["AT", 125, 400, 125, 180]],
        [_airLock, ["AA", 125, 30, 125, 150]],
        [_grenade, ["GMG", 75, 40, 60, 90]],
        [true, ["MG", 60, 15, 50, 70]]
    ] select { _x select 0 } select 0 select 1) params ["_role", "_base", "_href", "_lo", "_hi"];
    private _c = _base * (0.85 + 0.3 * ((_maxHit / (2 * _href)) min 1));
    if (_role == "AA" && {_maxHit >= 30}) then { _c = _c * 1.2 };
    if (_role == "AT" && {_maxHit >= 500}) then { _c = _c * 1.2 };
    [round ((_c max _lo) min _hi), _role]
};

// A vehicle's role and price, from its armour, chassis and the hardest-hitting round it carries:
//   artillery 500-600, tank killers (a round hitting 250 or more) 450-600, tracked armed vehicles
//   250-330, wheeled armed APCs 200-250, MRAPs (armoured cars) 150-200, light armed vehicles
//   100-150, trucks 75-100 by seats, unarmed light vehicles 75; boats 150 armed, 75 not.
// Within a band, more armour costs more. Aircraft are never offered.
private _vehiclePrice = {
    params ["_class", "_cfg"];
    private _maxHit = 0;
    private _turrets = [];
    private _walk = { params ["_t"]; { _turrets pushBack _x; [_x >> "Turrets"] call _walk } forEach ("true" configClasses _t) };
    [_cfg >> "Turrets"] call _walk;
    private _mags = getArray (_cfg >> "magazines");
    { _mags append (getArray (_x >> "magazines")) } forEach _turrets;
    {
        private _a = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
        _maxHit = _maxHit max (((getNumber (configFile >> "CfgAmmo" >> _a >> "hit")) max 0) min 5000);
    } forEach _mags;
    private _A = ((getNumber (_cfg >> "armor")) max 0) min 5000;
    private _armed = _maxHit >= 25;
    private _seats = (getNumber (_cfg >> "transportSoldier")) max 0;
    private _c = switch (true) do {
        case (_class isKindOf "Ship"): { [75, 100 + 50 * ((_maxHit / 25) min 1)] select _armed };
        case (getNumber (_cfg >> "artilleryScanner") == 1): { 500 + 100 * ((_A / 600) min 1) };
        case (_maxHit >= 250): { 450 + 150 * ((_A / 900) min 1) };
        case (_class isKindOf "Tank" && _armed): { 250 + 80 * ((_A / 700) min 1) };
        case (_class isKindOf "Wheeled_APC_F" && _armed): { 200 + 50 * ((_A / 500) min 1) };
        case (_class isKindOf "Truck_F"): { 75 + 25 * ((_seats / 16) min 1) };
        case (_A >= 150): { 150 + 50 * ((_maxHit / 50) min 1) };
        case (_armed): { 100 + 50 * ((_maxHit / 25) min 1) };
        default { 75 };
    };
    round ((_c max 75) min 600)
};

private _rows = [];
private _seen = createHashMap;
private _add = {
    params ["_class", "_cfg", "_kind"];
    private _lc = toLower _class;
    if (_lc in _seen || {_lc in _blacklist}) exitWith {};
    _seen set [_lc, true];
    private _cost = _fixed getOrDefault [_lc, -1];
    private _side = "";
    private _tier = 1;
    switch (_kind) do {
        case "STATIC": {
            _side = ["EAST", "WEST", "GUER"] param [getNumber (_cfg >> "side"), ""];
            ([_class, _cfg] call _staticPrice) params ["_p", "_role"];
            if (_p < 0 && {_cost < 0}) exitWith { _cost = -1 };
            if (_cost < 0) then { _cost = (round (_p * _scale)) max 1 };
            // machine guns and grenade launchers from tier 2, the heavy weapons from tier 3
            _tier = [3, 2] select (_role in ["MG", "GMG", ""]);
            if (_side == "") exitWith { _cost = -1 };
        };
        case "VEHICLE": {
            _side = ["EAST", "WEST", "GUER"] param [getNumber (_cfg >> "side"), ""];
            if (_side == "") exitWith { _cost = -1 };
            if (_cost < 0) then { _cost = (round (([_class, _cfg] call _vehiclePrice) * _scale)) max 1 };
            _tier = 3;
        };
        default {
            if (_cost < 0) then { _cost = (round (([_class, _cfg, _kind] call _price) * _scale)) max 1 };
            // towers from tier 2
            if (_kind == "FORTIFICATION" && {"tower" in _lc || {"patrol" in _lc}}) then { _tier = 2 };
        };
    };
    if (_cost < 0) exitWith {};
    private _pic = getText (_cfg >> "editorPreview");
    _rows pushBack [_class, getText (_cfg >> "displayName"), _kind, _cost, _pic, _tier, _side, toLower getText (_cfg >> "faction")];
};

{
    private _cfg = _x;
    private _class = configName _cfg;
    // Static weapons with something to fire, crewed by their own side; not drones
    if (_class isKindOf "StaticWeapon" && {getNumber (_cfg >> "isUav") != 1} && {getNumber (_cfg >> "side") in [0, 1, 2]}) then {
        [_class, _cfg, "STATIC"] call _add;
    };
    // Land vehicles and boats with a driver's seat, crewed by nobody until players get in; not
    // drones, not aircraft
    if ((_class isKindOf "LandVehicle" || {_class isKindOf "Ship"}) && {!(_class isKindOf "StaticWeapon")} && {!(_class isKindOf "Man")}
        && {getNumber (_cfg >> "isUav") != 1} && {getNumber (_cfg >> "hasDriver") == 1} && {getNumber (_cfg >> "side") in [0, 1, 2]}
        && {getText (_cfg >> "model") != ""} && {!([_class, _cfg] call _isRuin)}) then {
        [_class, _cfg, "VEHICLE"] call _add;
    };
    if (getText (_cfg >> "model") != "" && {!(_class isKindOf "AllVehicles")} && {!([_class, _cfg] call _isRuin)}) then {
        private _cat = getText (_cfg >> "editorCategory");
        private _sub = getText (_cfg >> "editorSubcategory");
        private _isService = (_service findIf { getNumber (_cfg >> _x) > 0 }) > -1;
        private _kind = switch (true) do {
            case (_isService && {_cat == "EdCat_Supplies" || {_sub == "EdSubcat_Military"}}): {"SUPPLY"};
            case (_sub == "EdSubcat_Helipads"): {"SUPPLY"};
            // any walls, fences or structures category: a mod's own (CUP's EdCat_CUP_Walls) as well as the game's
            case (_sub == "EdSubcat_Military" && {(["walls", "fences", "structures"] findIf { _x in toLower _cat }) >= 0} && {!("ruins" in toLower _cat)}): {"FORTIFICATION"};
            case (_sub == "EdSubcat_Lamps" && {"portablelight" in toLower _class}): {"FORTIFICATION"};
            default {""};
        };
        if (_kind != "") then {
            ([_class] call _size) params ["", "_wide"];
            if (_wide <= 40) then { [_class, _cfg, _kind] call _add };
        };
    };
} forEach ("getNumber (_x >> 'scope') == 2" configClasses (configFile >> "CfgVehicles"));

// Whitelisted classes the rules didn't pick, priced as fortifications
{
    private _cfg = configFile >> "CfgVehicles" >> _x;
    if (isClass _cfg) then { [configName _cfg, _cfg, "FORTIFICATION"] call _add } else {
        ["ALiVE Player FOBs - CfgALiVEFOBBuildables: whitelist class %1 isn't in this game", _x] call ALiVE_fnc_dumpR;
    };
} forEach _whitelist;

// only[]: exactly these, each priced by the rules (or as a fortification when the rules don't
// pick it) unless it has a cost; the blacklist still applies
if (_only isNotEqualTo []) then {
    private _have = _rows apply { toLower (_x select 0) };
    {
        private _cfg = configFile >> "CfgVehicles" >> _x;
        if (isClass _cfg) then {
            if !(toLower _x in _have) then { [configName _cfg, _cfg, "FORTIFICATION"] call _add };
        } else {
            ["ALiVE Player FOBs - CfgALiVEFOBBuildables: only class %1 isn't in this game", _x] call ALiVE_fnc_dumpR;
        };
    } forEach _only;
    private _keep = _only apply { toLower _x };
    _rows = _rows select { toLower (_x select 0) in _keep };
};

_rows sort true;
if (_measured > 0) then {
    profileNamespace setVariable ["ALiVE_FOB_sizes", _sizes];
    saveProfileNamespace;
};

ALiVE_FOB_catalog = _rows;
publicVariable "ALiVE_FOB_catalog";
// With Debug on, every row in the RPT, one per line, for the Player FOBs build list page on the
// ALiVE website: [class, name, category, cost, tier, side, faction]
if ([_logic, "attribute", ["fob_debug"]] call ALiVE_fnc_FOB) then {
    { diag_log text ("ALiVE_FOB_CATALOG " + str [_x select 0, _x select 1, _x select 2, _x select 3, _x select 5, _x select 6, _x select 7]) } forEach _rows;
};
["ALiVE Player FOBs - build catalog: %1 fortifications, %2 supply, %3 static weapons, %4 vehicles, %5 measured, %6 ms",
    { (_x select 2) == "FORTIFICATION" } count _rows, { (_x select 2) == "SUPPLY" } count _rows, { (_x select 2) == "STATIC" } count _rows,
    { (_x select 2) == "VEHICLE" } count _rows, _measured, round ((diag_tickTime - _t0) * 1000)] call ALiVE_fnc_dump;
["factions"] call ALiVE_fnc_fobBuildScan;
count _rows
