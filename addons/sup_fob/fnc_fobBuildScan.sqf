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
helipads (not a mod's copy of the invisible one), and the FOB Arsenal when the Arsenal setting is on
(60 supply, tier 2, kept with Build Only These set). Static weapons are offered to their own side, crewed by it. Ruins, wrecks and anything
wider than 40 m are left out.

A fortification's price grows with how tough it is and how big:
    3 + 72 x min(1, armour / 500) x sqrt(min(1, volume / 600)), 3 to 75
with a floor for what it does (wire 10, camo net 20, tower 40, light 5). A supply object's
price grows with how much it holds, 20 to 50; medical 35, helipads 25. Every price is then
multiplied by the module's Cost Multiplier and rounded, never below 1. A static weapon's price comes
from its role (machine gun 60, grenade launcher 75, mortar 100, AT and AA 125, howitzer 250),
moved up or down by how hard its hardest round hits, 50 to 250.

Vehicles: land vehicles and boats, priced by role and armour, 75 to 600 (see _vehiclePrice);
helicopters, 300 to 800, and planes, 350 to 1000 (see _airPrice), in the same Vehicles tab. A
helicopter is built on a helipad within the FOB's build range, a plane on an airfield's taxiway
or parking area (ALiVE_fnc_fobPlacement "airSpot"). No drones, no parachutes. Static weapons and
vehicles are offered from the factions the side's AI Commanders field (all of its own side's
when it has none), so a NATO FOB facing CSAT builds NATO equipment.

Some items need a FOB of a higher tier: towers and machine guns or grenade launchers tier 2,
mortars, AT and AA launchers, howitzers, vehicles and aircraft tier 3.

A mission or mod can change the catalog through CfgALiVEFOBBuildables, in description.ext or a
mod's config (the mission's wins):
    class CfgALiVEFOBBuildables {
        blacklist[] = {"Land_Razorwire_F"};      // never offered
        whitelist[] = {"Land_Pallets_F"};        // offered, priced as a fortification
        only[] = {"Land_BagFence_Short_F"};      // if set, the menu is these plus whitelist[]
        class Land_HBarrier_5_F { cost = 7; };   // a fixed price (1 to 100000)
    };
A price that isn't a whole number from 1 to 100000 is refused with a warning in the RPT and
the worked-out price is used instead. The module's Never Build and Also Build fields add to the
blacklist and whitelist, and its Build Only These field to only[]. A class in Build Only These
can carry its price, Class=463, which wins over a cost in CfgALiVEFOBBuildables. With an only list,
a FOB type's extras are still built, and one the list doesn't have is that type's alone.

The Build List Preset cuts the catalog by kind (Outpost, Fortified Base, Infantry, Logistics Hub).
A FOB type can name its own (preset= in FOB Types); one that doesn't, and the plain FOB, use the
module's. Only what every preset in use leaves out is dropped here; what some presets keep and
others don't stays in the catalog and is published per preset as ALiVE_FOB_presetDrop, for
ALiVE_fnc_FOB "typeAllows" to hide at the FOBs whose preset leaves it out.

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
        // only[]: the menu is these plus whitelist[]; the mission's list, else the first mod's
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
_blacklist append ((([_logic, "attribute", ["fob_blacklist"]] call ALiVE_fnc_FOB) regexReplace ["\s*>\s*", ">"]) splitString ", ;" apply { toLower _x });
_whitelist append ((([_logic, "attribute", ["fob_whitelist"]] call ALiVE_fnc_FOB) regexReplace ["\s*>\s*", ">"]) splitString ", ;");
// Build Only These (Jman, 25 Oct): an inclusion list set in Eden, as the website's Build List page
// writes it, added to any only[]; each class once, whatever its case. Class=463 also sets its price,
// in place of any cost in CfgALiVEFOBBuildables (spaces round the = are allowed)
{
    private _p = _x splitString "=";
    if (_p isNotEqualTo []) then {
        private _cls = _p select 0;
        _only pushBack _cls;
        if (count _p > 1) then {
            private _c = parseNumber (_p select 1);
            if (_c >= 1 && {_c <= 100000} && {_c == floor _c}) then {
                _fixed set [toLower _cls, _c];
            } else {
                ["ALiVE Player FOBs - Build Only These: price %1 for %2 isn't a whole number from 1 to 100000; ignored", _p select 1, _cls] call ALiVE_fnc_dumpR;
            };
        };
    };
} forEach ((([_logic, "attribute", ["fob_only"]] call ALiVE_fnc_FOB) regexReplace [" *= *", "="] regexReplace ["\s*>\s*", ">"]) splitString ", ;");
private _onlySeen = [];
_only = _only select { private _k = toLower _x; if (_k in _onlySeen) then { false } else { _onlySeen pushBack _k; true } };
// The Build List (Build List Preset, or Custom and a name): a named list from CfgALiVELists, ready-made
// or the mission's. Its only, never and also join the lists above and its prices sit under theirs; its
// kinds cut the scan below. Not set, or a name no list has, is FOB_STANDARD: Infantry, one of each model.
private _listName = [_logic, "attribute", ["fob_buildpreset"]] call ALiVE_fnc_FOB;
if (_listName == "CUSTOM") then {
    _listName = trim ([_logic, "attribute", ["fob_buildpreset_name"]] call ALiVE_fnc_FOB);
    if (_listName == "") then { ["ALiVE Player FOBs - Build List Preset is Custom but Custom List Name is empty, so FOB_STANDARD is used"] call ALiVE_fnc_dumpR };
};
if (_listName == "" || {!(isClass (missionConfigFile >> "CfgALiVELists" >> _listName) || {isClass (configFile >> "CfgALiVELists" >> _listName)})}) then {
    if (_listName != "") then { ["ALiVE Player FOBs - Build List %1 isn't a list in CfgALiVELists, so FOB_STANDARD is used", _listName] call ALiVE_fnc_dumpR };
    _listName = "FOB_STANDARD";
};
private _listRules = ["get", _listName] call ALIVE_fnc_lists;
private _listToken = { if ((_x select 0) == "") then { _x select 1 } else { (_x select 0) + ">" + (_x select 1) } };
// a backpack sits in both the Classes and Gear lists, so each name joins once
{
    if !((toLower _x) in _onlySeen) then { _onlySeen pushBack toLower _x; _only pushBack _x };
} forEach ((_listRules get "onlyClasses") + ((_listRules get "onlyGroups") apply _listToken) + (_listRules get "onlyGear"));
{ _blacklist pushBackUnique toLower _x } forEach ((_listRules get "neverClasses") + ((_listRules get "neverGroups") apply _listToken) + (_listRules get "neverGear"));
{
    private _k = toLower _x;
    if ((_whitelist findIf { toLower _x == _k }) < 0) then { _whitelist pushBack _x };
} forEach ((_listRules get "alsoClasses") + ((_listRules get "alsoGroups") apply _listToken) + (_listRules get "alsoGear"));
{ if !(_x in _fixed) then { _fixed set [_x, _y] } } forEach (_listRules get "prices");
// what the mission names (Build Only These, Also Build, its Build List, a FOB type's extras below) is
// offered whatever faction it is from (ALiVE_fnc_FOB factionAllows)
private _namedAll = (_only + _whitelist) apply { toLower _x };
// never the kit or supply crate themselves: one built here would be a crate of supply for its build price
_blacklist append ["alive_fob_kit", "alive_fob_supplycrate"];
// nor a mod's stand-in that only looks like a vehicle to the config: the USS Nimitz mod's spawner (an
// invisible ship that assembles the carrier around itself) and its catapult shuttle (a plane class)
_blacklist append ["jdg_carrier_spawner", "jdg_shuttle"];
// and the mission's own kit and crate objects, if it sets any
{
    { private _p = _x splitString "= "; if (_p isNotEqualTo []) then { _blacklist pushBack toLower (_p select (count _p - 1)) } } forEach (([_logic, "attribute", [_x]] call ALiVE_fnc_FOB) splitString ",;");
} forEach ["fob_kit_class", "fob_crate_class"];
// the FOB Arsenal, only with the Arsenal setting on (scope 1 keeps it out of the main pass below)
private _arsenal = [_logic, "attribute", ["fob_arsenal"]] call ALiVE_fnc_FOB;
if !(_arsenal) then { _blacklist pushBack "alive_fob_arsenal" };
// the same lists set the Arsenal's gear: a weapon, magazine, item, glasses or backpack class is the
// Arsenal's, anything else the build menu's, and a list naming only one kind leaves the other alone.
// Gear never reaches the build menu, Arsenal setting on or off: a list made on the Build List page
// with gear ticked, used with the setting off, would otherwise leave the menu holding only gear,
// which can't be built, so nothing at all.
private _isGear = {
    params ["_c"];
    private _v = configFile >> "CfgVehicles" >> _c;
    // something that can be built stays the build menu's, whatever else shares its name
    if (isClass _v && {getNumber (_v >> "isBackpack") != 1}) exitWith { false };
    isClass _v || {isClass (configFile >> "CfgWeapons" >> _c)} || {isClass (configFile >> "CfgMagazines" >> _c)} || {isClass (configFile >> "CfgGlasses" >> _c)}
};
private _gearOnly = _only select { [_x] call _isGear };
private _gearAlso = _whitelist select { [_x] call _isGear };
_only = _only - _gearOnly;
_whitelist = _whitelist - _gearAlso;
if (_arsenal) then {
    ALiVE_FOB_gearOverrides = [+_blacklist, _gearOnly, _gearAlso, +_fixed];
};

// Troops (Jman, 27 Oct): the same lists take soldier classes and group names, which go to the Troops
// tab. A group is named BUS_InfSquad (that group in every faction) or BLU_F>BUS_InfSquad (one
// faction's), as on the tablet's catalogue. Each list touches troops only when it names one, so a list
// of fortifications leaves the Troops tab as it is, and a list of troops leaves the fortifications.
private _troopCap = [_logic, "attribute", ["fob_troop_cap"]] call ALiVE_fnc_FOB;
private _troopBase = [_logic, "attribute", ["fob_troop_cost"]] call ALiVE_fnc_FOB;
private _forcePool = ([_logic, "attribute", ["fob_supply_source"]] call ALiVE_fnc_FOB) == "FORCEPOOL";
// with Troops Per Tier at 0 nothing is a troop, so the lists read as they did before troops
private _isSoldier = {
    params ["_c"];
    private _v = configFile >> "CfgVehicles" >> _c;
    _troopCap > 0 && {isClass _v} && {configName _v isKindOf "CAManBase"} && {getNumber (_v >> "side") in [0, 1, 2]}
};
// every CfgGroups group by its lower case name: [[CfgGroups faction (lower case), category, config], ...]
private _groupIndex = createHashMap;
{
    {
        private _gf = toLower configName _x;
        {
            private _cat = configName _x;
            {
                private _k = toLower configName _x;
                private _l = _groupIndex getOrDefault [_k, []];
                _l pushBack [_gf, _cat, _x];
                _groupIndex set [_k, _l];
            } forEach ("true" configClasses _x);
        } forEach ("true" configClasses _x);
    } forEach ("true" configClasses _x);
} forEach ("true" configClasses (configFile >> "CfgGroups"));
private _isGroupToken = { params ["_t"]; _troopCap > 0 && {((_t find ">") > -1) || {!isClass (configFile >> "CfgVehicles" >> _t) && {(toLower _t) in _groupIndex}}} };
private _isTroop = { params ["_t"]; ([_t] call _isSoldier) || {[_t] call _isGroupToken} };
private _soldierOnly = (_only select { [_x] call _isSoldier }) apply { configName (configFile >> "CfgVehicles" >> _x) };
private _soldierAlso = (_whitelist select { [_x] call _isSoldier }) apply { configName (configFile >> "CfgVehicles" >> _x) };
private _groupOnly = _only select { [_x] call _isGroupToken };
private _groupAlso = _whitelist select { [_x] call _isGroupToken };
private _groupNever = _blacklist select { [_x] call _isGroupToken };
_only = _only select { !([_x] call _isTroop) };
_whitelist = _whitelist select { !([_x] call _isTroop) };
// a Build List whose kinds leave out gear (Supplies, a mission's own) has no FOB Arsenal, unless Build
// Only These or Also Build names gear, which the Arsenal then keeps alone. An Only list of objects sets
// the build list itself, so its kinds don't count.
ALiVE_FOB_gearCut = false;
private _listKinds = _listRules get "kinds";
if (_arsenal && {_listKinds isNotEqualTo []} && {!("GEAR" in _listKinds)} && {_only isEqualTo []}) then {
    if ((_gearOnly + _gearAlso) isEqualTo []) then {
        _blacklist pushBack "alive_fob_arsenal";
        ALiVE_FOB_gearCut = true;
        ["ALiVE Player FOBs - Build List %1 leaves out gear, so the FOB Arsenal is left out", _listName] call ALiVE_fnc_dumpR;
    } else {
        ALiVE_FOB_gearOverrides = [+_blacklist, _gearOnly + _gearAlso, [], +_fixed];
    };
};
private _troopRules = createHashMap;
// a FOB type's own groups answer only to Never Build, as its other extras do
private _troopNeverRules = createHashMap;
if (!isNil "ALIVE_fnc_PRCatalogueRules") then {
    _troopRules = ["parse", [_groupOnly joinString ",", _groupNever joinString ",", _groupAlso joinString ","]] call ALIVE_fnc_PRCatalogueRules;
    _troopNeverRules = ["parse", ["", _groupNever joinString ",", ""]] call ALIVE_fnc_PRCatalogueRules;
};

// Sizes measured on earlier starts
private _sizes = profileNamespace getVariable ["ALiVE_FOB_sizes", createHashMap];
if !(_sizes isEqualType createHashMap) then { _sizes = createHashMap };
private _measured = 0;

// [volume m3, widest side m, height m] of a class, measured on a local copy once and kept
// (a size kept before the height was measured is measured again)
private _size = {
    params ["_class"];
    private _have = _sizes get _class;
    if (!isNil "_have" && {count _have > 2}) exitWith { _have };
    private _o = createSimpleObject [_class, [0, 0, 1000], true];
    private _s = [0, 0, 0];
    if (!isNull _o) then {
        private _d = ((boundingBoxReal _o) select 1) vectorDiff ((boundingBoxReal _o) select 0);
        _s = [abs ((_d select 0) * (_d select 1) * (_d select 2)), (abs (_d select 0)) max (abs (_d select 1)), abs (_d select 2)];
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
        if (_lc == "alive_fob_arsenal") exitWith { 60 };
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

// The hardest-hitting round a vehicle or aircraft carries, from its own magazines and every turret's
private _maxHitOf = {
    params ["_cfg"];
    private _maxHit = 0;
    private _turrets = [];
    private _walk = { params ["_t"]; { _turrets pushBack _x; [_x >> "Turrets"] call _walk } forEach ("true" configClasses _t) };
    [_cfg >> "Turrets"] call _walk;
    private _mags = getArray (_cfg >> "magazines");
    { _mags append (getArray (_x >> "magazines")) } forEach _turrets;
    // an aircraft with an editable loadout carries its rockets, missiles and bombs on pylons, not in
    // its magazines: without these a Buzzard CAS was priced as an unarmed plane
    { _mags pushBack getText (_x >> "attachment") } forEach ("true" configClasses (_cfg >> "Components" >> "TransportPylonsComponent" >> "Pylons"));
    {
        private _a = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
        _maxHit = _maxHit max (((getNumber (configFile >> "CfgAmmo" >> _a >> "hit")) max 0) min 5000);
    } forEach _mags;
    _maxHit
};

// A vehicle's role and price, from its armour, chassis and the hardest-hitting round it carries:
//   artillery 500-600, tank killers (a round hitting 250 or more) 450-600, tracked armed vehicles
//   250-330, wheeled armed APCs 200-250, MRAPs (armoured cars) 150-200, light armed vehicles
//   100-150, trucks 75-100 by seats, unarmed light vehicles 75; boats 150 armed, 75 not.
// Within a band, more armour costs more. Aircraft have their own bands (_airPrice).
private _vehiclePrice = {
    params ["_class", "_cfg"];
    private _maxHit = [_cfg] call _maxHitOf;
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

// An aircraft's price (Jman, 26 Oct), from what it carries, its armour and its seats:
//   helicopters 300-800: attack (a round hitting 250 or more) 700-800 by armour, armed light
//   450-550 by its hardest round, transport 300-450 by seats (MH-9 356, Ghost Hawk 412, Huron 450);
//   planes 350-1000: armed 800-1000 by its hardest round (every vanilla jet 1000), unarmed 350-600
//   by seats, a VTOL never under 500.
private _airPrice = {
    params ["_class", "_cfg"];
    private _maxHit = [_cfg] call _maxHitOf;
    private _A = ((getNumber (_cfg >> "armor")) max 0) min 5000;
    private _seats = (getNumber (_cfg >> "transportSoldier")) max 0;
    if (_class isKindOf "Helicopter") exitWith {
        private _c = switch (true) do {
            case (_maxHit >= 250): { 700 + 100 * ((_A / 150) min 1) };
            case (_maxHit >= 25): { 450 + 100 * ((_maxHit / 100) min 1) };
            default { 300 + 150 * ((_seats / 16) min 1) };
        };
        round ((_c max 300) min 800)
    };
    private _c = if (_maxHit >= 25) then { 800 + 200 * ((_maxHit / 250) min 1) } else { 350 + 250 * ((_seats / 32) min 1) };
    if (_class isKindOf "VTOL_Base_F") then { _c = _c max 500 };
    round ((_c max 350) min 1000)
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
            if (_cost < 0) then { _cost = (round (([_class, _cfg] call ([_vehiclePrice, _airPrice] select (_class isKindOf "Air"))) * _scale)) max 1 };
            _tier = 3;
        };
        default {
            if (_cost < 0) then { _cost = (round (([_class, _cfg, _kind] call _price) * _scale)) max 1 };
            // towers from tier 2
            if (_kind == "FORTIFICATION" && {"tower" in _lc || {"patrol" in _lc}}) then { _tier = 2 };
            // and the Arsenal
            if (_lc == "alive_fob_arsenal") then { _tier = 2 };
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
    // drones (aircraft just below)
    if ((_class isKindOf "LandVehicle" || {_class isKindOf "Ship"}) && {!(_class isKindOf "StaticWeapon")} && {!(_class isKindOf "Man")}
        && {getNumber (_cfg >> "isUav") != 1} && {getNumber (_cfg >> "hasDriver") == 1} && {getNumber (_cfg >> "side") in [0, 1, 2]}
        && {getText (_cfg >> "model") != ""} && {!([_class, _cfg] call _isRuin)}) then {
        [_class, _cfg, "VEHICLE"] call _add;
    };
    // Helicopters and planes, the same way: empty, with a pilot's seat; not drones, and not a
    // parachute (the game counts those as helicopters) or an ejection seat
    if ((_class isKindOf "Helicopter" || {_class isKindOf "Plane"}) && {!(_class isKindOf "ParachuteBase")} && {!("ejection" in toLower _class)}
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
            // a mod's copy of the invisible helipad is something else with nothing to see (Firewill's
            // FIR_I_TGT_FAKE is a lock-on target), so only the game's own invisible pad is offered
            case (_sub == "EdSubcat_Helipads" && {!(_class isKindOf "Land_HelipadEmpty_F") || {_class == "Land_HelipadEmpty_F"}}): {"SUPPLY"};
            // any walls, fences or structures category: a mod's own (CUP's EdCat_CUP_Walls) as well as the game's
            case (_sub == "EdSubcat_Military" && {(["walls", "fences", "structures"] findIf { _x in toLower _cat }) >= 0} && {!("ruins" in toLower _cat)}): {"FORTIFICATION"};
            case (_sub == "EdSubcat_Lamps" && {"portablelight" in toLower _class}): {"FORTIFICATION"};
            default {""};
        };
        // firing-range props (Jman, 29 Oct): wooden, concrete and SAM targets sit in the same
        // structures categories but aren't anything to build. Also Build still adds one by name.
        if (_kind == "FORTIFICATION" && {"target" in toLower _class || {"target" in toLower getText (_cfg >> "displayName")}}) then { _kind = "" };
        if (_kind != "") then {
            ([_class] call _size) params ["", "_wide"];
            if (_wide <= 40) then { [_class, _cfg, _kind] call _add };
        };
    };
} forEach ("getNumber (_x >> 'scope') == 2" configClasses (configFile >> "CfgVehicles"));

// Build List Preset (Jman, 29 Oct): a ready-made cut of what the scan found, by kind and by the kind
// of vehicle, so it suits any mod. Build Only These sets the list itself, so a preset gives way to it.
// Also Build and a FOB type's extras still add past it: what it drops is kept aside, and one of
// those lists naming it puts its own row back (its real kind, price, tier and side).
// [kinds, kinds of vehicle, the heaviest static weapon's tier, troops, field works only], [] for
// everything. Field works (Jman, 29 Oct) are the fortifications no taller than 3 m (sandbags,
// barriers, hedgehogs, wire, small bunkers, lamps) plus camouflage nets and tents: walls, towers,
// big bunkers and buildings are left out. No preset
// keeps artillery, a static weapon that fires as artillery (a mortar, a howitzer) included.
// A FOB type can name its own preset (Jman, 29 Oct). The presets in use are the module's (the plain
// FOB's and every type's without one) and each type's own: a row all of them leave out is dropped,
// one only some leave out stays and is listed against those presets in _presetDrop.
private _presetTroops = true;
private _presetDropped = createHashMap;
private _presetDrop = createHashMap;
// a list's cut from CfgALiVELists (ALIVE_fnc_lists), [] when it cuts nothing
private _presetSpec = {
    params ["_p"];
    private _r = ["get", _p] call ALIVE_fnc_lists;
    private _k = _r get "kinds";
    if (_k isEqualTo [] && {(_r get "staticTier") < 0} && {!(_r get "fieldWorksOnly")}) exitWith { [] };
    [_k, _r get "vehicleKinds", [_r get "staticTier", 3] select ((_r get "staticTier") < 0), _k isEqualTo [] || {"TROOPS" in _k}, _r get "fieldWorksOnly"]
};
private _preset = _listName;
private _fobTypes = missionNamespace getVariable ["ALiVE_FOB_types", []];
// The module's preset always counts, even when every type names its own: a FOB with no type (a saved
// one whose type is gone) falls back to it
private _inUse = [_preset];
{ if ((_x param [13, ""]) != "") then { _inUse pushBackUnique (_x select 13) } } forEach _fobTypes;
private _rulesOf = createHashMapFromArray (_inUse apply { [_x, [_x] call _presetSpec] });
private _cuts = (_inUse findIf { (_rulesOf get _x) isNotEqualTo [] }) >= 0;
if (_cuts && {_only isNotEqualTo []}) then {
    ["ALiVE Player FOBs - Build List Preset %1 not used: a Build Only These list sets the build list", _inUse - ["ALL"]] call ALiVE_fnc_dumpR;
};
if (_cuts && {_only isEqualTo []}) then {
    _presetTroops = (_inUse findIf { private _r = _rulesOf get _x; _r isEqualTo [] || {_r select 3} }) >= 0;
    private _vehicleKind = {
        params ["_class"];
        switch (true) do {
            case (_class isKindOf "Air"): {"AIR"};
            case (_class isKindOf "Ship"): {"BOAT"};
            case (getNumber (configFile >> "CfgVehicles" >> _class >> "artilleryScanner") == 1): {"ARTILLERY"};
            case (_class isKindOf "Tank" || {_class isKindOf "Wheeled_APC_F"}): {"ARMOUR"};
            case (_class isKindOf "Truck_F"): {"TRUCK"};
            default {"CAR"};
        }
    };
    private _isFieldWork = {
        params ["_class"];
        private _lc = toLower _class;
        (["camonet", "tent", "canvascover", "masking"] findIf { _x in _lc }) >= 0 || {(([_class] call _size) param [2, 99]) <= 3}
    };
    private _keepRow = {
        params ["_row", "_r"];
        if (_r isEqualTo []) exitWith {true};
        _r params ["_kinds", "_vehicles", "_staticTier", "", ["_fieldOnly", false]];
        _row params ["_class", "", "_kind", "", "", "_tier"];
        (_kinds isEqualTo [] || {_kind in _kinds})
        && {_kind != "FORTIFICATION" || {!_fieldOnly} || {[_class] call _isFieldWork}}
        && {_kind != "STATIC" || {_tier <= _staticTier && {getNumber (configFile >> "CfgVehicles" >> _class >> "artilleryScanner") != 1}}}
        && {_kind != "VEHICLE" || {_vehicles isEqualTo []} || {([_class] call _vehicleKind) in _vehicles}}
    };
    private _before = count _rows;
    private _kept = [];
    {
        private _row = _x;
        private _by = _inUse select { !([_row, _rulesOf get _x] call _keepRow) };
        if (count _by == count _inUse) then {
            _presetDropped set [toLower (_row select 0), _row];
        } else {
            _kept pushBack _row;
            {
                private _l = _presetDrop getOrDefault [_x, []];
                if (_l isEqualTo []) then { _presetDrop set [_x, _l] };
                _l pushBack toLower (_row select 0);
            } forEach _by;
        };
    } forEach _rows;
    _rows = _kept;
    ["ALiVE Player FOBs - Build List Preset %1 keeps %2 of %3 items", _inUse, count _rows, _before] call ALiVE_fnc_dumpR;
};

// One of each model when the Build List folds (FOB_STANDARD does): camo and loadout variants into the
// plainest, per side and faction for vehicles and static weapons, as the menu offers those by faction.
// Never what Also Build, a price or a FOB type names, nor anything under a Build Only These list.
// A list in use that doesn't fold (a type's preset=ALL) keeps every variant: a row only some lists fold
// away stays and is listed against those in _presetDrop, as the kind cut does.
private _folders = _inUse select { ((["get", _x] call ALIVE_fnc_lists) get "fold") > 0 };
if (_folders isNotEqualTo [] && {_only isEqualTo []}) then {
    private _named = (_whitelist apply { toLower _x }) + (keys _fixed);
    { _named append (_x select 5) } forEach _fobTypes;
    private _foldRules = createHashMapFromArray [["fold", 1], ["alsoClasses", _named]];
    private _groups = createHashMap;
    {
        private _g = if ((_x select 2) in ["VEHICLE", "STATIC"]) then { (_x select 6) + "|" + (_x select 7) } else { "" };
        private _l = _groups getOrDefault [_g, []];
        if (_l isEqualTo []) then { _groups set [_g, _l] };
        _l pushBack (_x select 0);
    } forEach _rows;
    private _keepFold = createHashMap;
    { { _keepFold set [toLower _x, true] } forEach (["fold", [_foldRules, _y]] call ALIVE_fnc_lists) } forEach _groups;
    private _before = count _rows;
    if (count _folders == count _inUse) then {
        _rows = _rows select { (toLower (_x select 0)) in _keepFold };
    } else {
        {
            private _c = toLower (_x select 0);
            if !(_c in _keepFold) then {
                {
                    private _l = _presetDrop getOrDefault [_x, []];
                    if (_l isEqualTo []) then { _presetDrop set [_x, _l] };
                    _l pushBackUnique _c;
                } forEach _folders;
            };
        } forEach _rows;
    };
    ["ALiVE Player FOBs - Build List %1: one of each model keeps %2 of %3 items", _folders, count _keepFold, _before] call ALiVE_fnc_dumpR;
};

if (_arsenal && {isClass (configFile >> "CfgVehicles" >> "ALiVE_FOB_Arsenal")}) then { ["ALiVE_FOB_Arsenal", configFile >> "CfgVehicles" >> "ALiVE_FOB_Arsenal", "SUPPLY"] call _add };

// Whitelisted classes the rules didn't pick, priced as fortifications (an aircraft here is one the
// rules turned down: a civilian one, a drone or one with no pilot's seat, so it stays one too)
{
    private _cfg = configFile >> "CfgVehicles" >> _x;
    private _dropped = _presetDropped getOrDefault [toLower _x, []];
    // a class the Build List Preset dropped comes back as it was
    if (_dropped isNotEqualTo []) then { _rows pushBack _dropped; _presetDropped deleteAt toLower _x } else {
        if (isClass _cfg) then { [configName _cfg, _cfg, "FORTIFICATION"] call _add } else {
            ["ALiVE Player FOBs - CfgALiVEFOBBuildables: whitelist class %1 isn't in this game", _x] call ALiVE_fnc_dumpR;
        };
    };
} forEach _whitelist;
// Also Build beats every preset, at every FOB
private _wl = _whitelist apply { toLower _x };
{ _presetDrop set [_x, (_presetDrop get _x) - _wl] } forEach (keys _presetDrop);

// Every FOB type's extras (FOB Types). One the catalog already has stays everyone's; one only a
// type brings is priced as a fortification and kept for the types that list it (ALiVE_FOB_typeOnly).
private _typeOnly = [];
{
    {
        private _cfg = configFile >> "CfgVehicles" >> _x;
        private _dropped = _presetDropped getOrDefault [toLower _x, []];
        if (_dropped isNotEqualTo []) then {
            _rows pushBack _dropped;
            _presetDropped deleteAt toLower _x;
            _typeOnly pushBackUnique toLower _x;
        };
        if (isClass _cfg && {!(toLower _x in _seen)} && {!(toLower _x in _blacklist)} && {!([_x] call _isTroop)}) then {
            [configName _cfg, _cfg, "FORTIFICATION"] call _add;
            _typeOnly pushBackUnique toLower _x;
        };
    } forEach (_x select 5);
} forEach (missionNamespace getVariable ["ALiVE_FOB_types", []]);

// only[]: these plus the whitelist, each priced by the rules (or as a fortification when the rules don't
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
    // Also Build adds past the list, as the tablet's Also Requisition does; Never Build still wins
    // (_add skipped those)
    private _keep = (_only + _whitelist) apply { toLower _x };
    // the Arsenal is the setting's, not the list's: a list made before it was turned on keeps it
    if (_arsenal) then { _keep pushBack "alive_fob_arsenal" };
    // a FOB type's extras still count (Jman, 25 Oct): one the list doesn't have is that type's own,
    // so Build Only These sets the plain FOB's menu and each type adds to it
    {
        {
            if !(_x in _keep) then { _typeOnly pushBackUnique _x; _keep pushBack _x };
        } forEach (((_x select 5) - _blacklist) select { !([_x] call _isTroop) });
    } forEach (missionNamespace getVariable ["ALiVE_FOB_types", []]);
    _rows = _rows select { toLower (_x select 0) in _keep };
};

// Troops: soldiers from tier 1, groups from tier 2, priced per man (Soldier Cost x Cost Multiplier), or
// 1 from the faction's force pool in Force pool mode, as a Combat Logistics requisition costs.
// A group is keyed faction>group in lower case, one row per faction that has it.
// [key, name, "SOLDIER" or "GROUP", cost, picture, tier, side, faction, men, leader class, [faction, class] as configured]
private _troopRows = [];
private _troopSeen = createHashMap;
private _sideOf = { params ["_n"]; ["EAST", "WEST", "GUER"] param [_n, ""] };
private _addSoldier = {
    params ["_class", ["_isTypeOnly", false]];
    private _cfg = configFile >> "CfgVehicles" >> _class;
    private _k = toLower _class;
    if (_k in _troopSeen || {_k in _blacklist}) exitWith {};
    private _side = [getNumber (_cfg >> "side")] call _sideOf;
    if (_side == "") exitWith {};
    _troopSeen set [_k, true];
    private _cost = [_fixed getOrDefault [_k, (round (_troopBase * _scale)) max 1], 1] select _forcePool;
    _troopRows pushBack [configName _cfg, getText (_cfg >> "displayName"), "SOLDIER", _cost, getText (_cfg >> "editorPreview"), 1, _side, toLower getText (_cfg >> "faction"), 1, configName _cfg, [getText (_cfg >> "faction"), configName _cfg]];
    if (_isTypeOnly) then { _typeOnly pushBackUnique _k };
};
// a group token's matches: [[key, faction, side, config, name], ...]; a faction token matches the
// faction's own name or the CfgGroups faction a custom mapping borrows its groups from
private _resolveGroup = {
    params ["_token"];
    private _parts = (toLower _token) splitString ">";
    private _ft = ["", _parts select 0] select (count _parts == 2);
    private _g = _parts select (count _parts - 1);
    private _mapped = _ft;
    if (_ft != "" && {!isNil "ALIVE_factionCustomMappings"}) then {
        private _i = (ALIVE_factionCustomMappings select 1) findIf { toLower _x == _ft };
        if (_i > -1) then {
            private _gfn = [[ALIVE_factionCustomMappings, (ALIVE_factionCustomMappings select 1) select _i] call ALIVE_fnc_hashGet, "GroupFactionName", _ft] call ALIVE_fnc_hashGet;
            if (_gfn isEqualType "" && {_gfn != ""}) then { _mapped = toLower _gfn };
        };
    };
    private _hits = [];
    {
        _x params ["_gf", "_cat", "_cfg"];
        private _faction = getText (_cfg >> "faction");
        if !(isClass (configFile >> "CfgFactionClasses" >> _faction)) then { _faction = _gf };
        if (isClass (configFile >> "CfgFactionClasses" >> _faction)) then {
            _faction = configName (configFile >> "CfgFactionClasses" >> _faction);
            if (_ft == "" || {_ft == toLower _faction} || {_mapped == _gf}) then {
                // a faction that borrows these groups through a custom mapping raises its own men
                // under its own name: the spawner applies the mapping itself
                if (_ft != "" && {_ft != toLower _faction} && {isClass (configFile >> "CfgFactionClasses" >> _ft)}) then {
                    _faction = configName (configFile >> "CfgFactionClasses" >> _ft);
                };
                private _side = [getNumber (configFile >> "CfgFactionClasses" >> _faction >> "side")] call _sideOf;
                if (_side != "") then { _hits pushBack [(toLower _faction) + ">" + toLower configName _cfg, _faction, _side, _cfg, getText (_cfg >> "name")] };
            };
        };
    } forEach (_groupIndex getOrDefault [_g, []]);
    _hits
};
private _addGroup = {
    params ["_hit", ["_isTypeOnly", false]];
    _hit params ["_k", "_faction", "_side", "_cfg", "_name"];
    if (_k in _troopSeen) exitWith {};
    private _rules = [_troopRules, _troopNeverRules] select _isTypeOnly;
    if (count _rules > 0 && {!(["allowsGroup", [_rules, toLower _faction, configName _cfg]] call ALIVE_fnc_PRCatalogueRules)}) exitWith {};
    // men as the spawner makes them: each soldier, and each vehicle's crew on foot (not a drone's)
    private _men = 0;
    private _leader = "";
    {
        private _v = getText (_x >> "vehicle");
        if (isClass (configFile >> "CfgVehicles" >> _v)) then {
            if (_v isKindOf "CAManBase") then {
                _men = _men + 1;
                if (_leader == "") then { _leader = _v };
            } else {
                if (getNumber (configFile >> "CfgVehicles" >> _v >> "isUav") != 1) then {
                    private _p = [_v] call ALIVE_fnc_configGetVehicleEmptyPositions;
                    private _n = 0;
                    for "_i" from 0 to count _p - 3 do { _n = _n + (_p select _i) };
                    if (_n < 2 && {[_v] call ALIVE_fnc_isArtillery}) then { _n = 2 };
                    _men = _men + _n;
                    if (_leader == "") then { _leader = _v call ALIVE_fnc_configGetVehicleCrew };
                };
            };
        };
    } forEach ("isClass _x" configClasses _cfg);
    if (_men < 1) exitWith {};
    _troopSeen set [_k, true];
    private _bare = toLower configName _cfg;
    private _cost = _fixed getOrDefault [_k, _fixed getOrDefault [_bare, (round (_men * _troopBase * _scale)) max 1]];
    if (_forcePool) then { _cost = 1 };
    if (_name == "") then { _name = configName _cfg };
    _troopRows pushBack [_k, _name, "GROUP", _cost, getText (configFile >> "CfgVehicles" >> _leader >> "editorPreview"), 2, _side, toLower _faction, _men, _leader, [_faction, configName _cfg]];
    if (_isTypeOnly) then { _typeOnly pushBackUnique _k };
};
if (_troopCap > 0) then {
    private _troopOnly = (_soldierOnly + _groupOnly) isNotEqualTo [];
    { [_x] call _addSoldier } forEach (([[], _soldierOnly] select _troopOnly) + _soldierAlso);
    // with no troops on Build Only These, every faction's infantry groups: those in a category with
    // infantry in its name (a mod like RHS names its own, rhs_group_nato_usarmy_d_infantry), and those
    // a faction's ALiVE mapping lists as Infantry. A Build List Preset without troops leaves them out.
    private _infFrom = count _troopRows;
    if (!_troopOnly && {_presetTroops}) then {
        {
            private _gname = _x;
            if ((_y findIf { ((toLower (_x select 1)) find "infantry") > -1 }) > -1) then {
                { [_x] call _addGroup } forEach ([_gname] call _resolveGroup);
            };
        } forEach _groupIndex;
        if (!isNil "ALIVE_factionCustomMappings") then {
            {
                private _f = _x;
                private _groups = [[ALIVE_factionCustomMappings, _f] call ALIVE_fnc_hashGet, "Groups", []] call ALIVE_fnc_hashGet;
                if (_groups isEqualType [] && {count _groups > 2}) then {
                    private _infantry = [_groups, "Infantry", []] call ALIVE_fnc_hashGet;
                    if (_infantry isEqualType []) then {
                        { if (_x isEqualType "") then { { [_x] call _addGroup } forEach ([_f + ">" + _x] call _resolveGroup) } } forEach _infantry;
                    };
                };
            } forEach (ALIVE_factionCustomMappings select 1);
        };
    };
    // those default groups are left out at the FOBs whose preset has no troops, an Also Build group excepted
    private _infKeys = (_troopRows select [_infFrom]) apply { toLower (_x select 0) };
    { { _infKeys = _infKeys - [toLower (_x select 0)] } forEach ([_x] call _resolveGroup) } forEach _groupAlso;
    // only when a preset cut the list: a Build Only These list sets it instead
    if (_infKeys isNotEqualTo [] && {_cuts} && {_only isEqualTo []}) then {
        {
            private _r = _rulesOf get _x;
            if (_r isNotEqualTo [] && {!(_r select 3)}) then { _presetDrop set [_x, (_presetDrop getOrDefault [_x, []]) + _infKeys] };
        } forEach _inUse;
    };
    {
        private _hits = [_x] call _resolveGroup;
        if (_hits isEqualTo []) then { ["ALiVE Player FOBs - %1 is no group in this game, so it isn't offered", _x] call ALiVE_fnc_dumpR };
        { [_x] call _addGroup } forEach _hits;
    } forEach (([[], _groupOnly] select _troopOnly) + _groupAlso);
    // a FOB type's troops: one the catalogue hasn't got is that type's own
    {
        {
            if ([_x] call _isSoldier) then { [_x, true] call _addSoldier } else {
                if ([_x] call _isGroupToken) then { { [_x, true] call _addGroup } forEach ([_x] call _resolveGroup) };
            };
        } forEach ((_x select 5) - _blacklist);
    } forEach (missionNamespace getVariable ["ALiVE_FOB_types", []]);
};
_rows append _troopRows;

_rows sort true;
if (_measured > 0) then {
    profileNamespace setVariable ["ALiVE_FOB_sizes", _sizes];
    saveProfileNamespace;
};

// the server prices raised troops from its own copy, which no client's publicVariable can reach
uiNamespace setVariable ["ALiVE_FOB_catalogServer", +_rows];
ALiVE_FOB_catalog = _rows;
publicVariable "ALiVE_FOB_catalog";
ALiVE_FOB_typeOnly = _typeOnly;
publicVariable "ALiVE_FOB_typeOnly";
// [[preset, [what it leaves out that another preset in use keeps]], ...] and the module's preset
ALiVE_FOB_presetDrop = (keys _presetDrop) apply { [_x, _presetDrop get _x] };
ALiVE_FOB_presetDefault = _preset;
publicVariable "ALiVE_FOB_presetDrop";
publicVariable "ALiVE_FOB_presetDefault";
// the build menu offers static weapons, vehicles and troops from the player's own faction, or the side's
ALiVE_FOB_factionScope = [_logic, "attribute", ["fob_faction_scope"]] call ALiVE_fnc_FOB;
publicVariable "ALiVE_FOB_factionScope";
{ _namedAll append (_x select 5) } forEach (missionNamespace getVariable ["ALiVE_FOB_types", []]);
ALiVE_FOB_named = _namedAll arrayIntersect _namedAll;
publicVariable "ALiVE_FOB_named";
// a type's extra that can't be built after all says why, rather than just not being in the menu
{
    private _tid = _x select 0;
    {
        private _c = _x;
        if ((_rows findIf { private _k = toLower (_x select 0); _k == _c || {(_k select [(_k find ">") + 1]) == _c} }) < 0) then {
            ["ALiVE Player FOBs - FOB Types: %1's extra %2 can't be built (not in this game, or on Never Build)", _tid, _c] call ALiVE_fnc_dumpR;
        };
    } forEach (_x select 5);
} forEach (missionNamespace getVariable ["ALiVE_FOB_types", []]);
// With Debug on, every row in the RPT, one per line, for the Player FOBs build list page on the
// ALiVE website: [class, name, category, cost, tier, side, faction]
if ([_logic, "attribute", ["fob_debug"]] call ALiVE_fnc_FOB) then {
    { diag_log text ("ALiVE_FOB_CATALOG " + str [_x select 0, _x select 1, _x select 2, _x select 3, _x select 5, _x select 6, _x select 7]) } forEach _rows;
};
["ALiVE Player FOBs - build catalog: %1 fortifications, %2 supply, %3 static weapons, %4 vehicles, %7 soldiers, %8 groups, %5 measured, %6 ms",
    { (_x select 2) == "FORTIFICATION" } count _rows, { (_x select 2) == "SUPPLY" } count _rows, { (_x select 2) == "STATIC" } count _rows,
    { (_x select 2) == "VEHICLE" } count _rows, _measured, round ((diag_tickTime - _t0) * 1000),
    { (_x select 2) == "SOLDIER" } count _rows, { (_x select 2) == "GROUP" } count _rows] call ALiVE_fnc_dump;
["factions"] call ALiVE_fnc_fobBuildScan;
count _rows
