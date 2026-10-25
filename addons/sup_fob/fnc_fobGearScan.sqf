#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobGearScan);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fobGearScan

Description:
The FOB Arsenal's gear and what each item costs, worked out once on the server from the loaded
config (Arsenal setting on). Kept on the server: ALiVE_FOB_gearPrice maps each lowercased class to
[cost, kind, rounds], and ALiVE_FOB_gearClasses holds [weapons, magazines, items, backpacks] by
config name for the arsenal box. A client is sent the class lists when it first opens an arsenal.

What is offered: every arsenal-visible (scope 2, scopeArsenal 2 when set) weapon, its base class
only; the magazines those weapons take, through magazines[] and magazine wells on every muzzle;
attachments, uniforms, vests, headgear, night vision, binoculars and designators, medical, tools
and other items; facewear; plain backpacks (not prefilled, not a static weapon or drone bag).
Grenades, mines and charges only with Arsenal Grenades and Explosives on.

The Player FOBs module's lists and CfgALiVEFOBBuildables apply to gear as to the build menu: Never
Build drops a class, Also Build adds one the rules left out, a price (cost, or Class=N in Build Only
These) is used as it is, and Build Only These naming any gear means exactly that gear, each gun
with its magazines. Sorted into gear and build-menu classes by fnc_fobBuildScan.

Prices before Cost Scale (rounded, never below 1):
    pistol 5-12, rifle 15-40, machine gun 40-70, sniper 60-90 by the hardest round, grenade launcher 35,
    shotgun 20
    launcher: AT 60-125, AA 90-125
    magazine 1-3 by its round, charged by the rounds taken; rockets, grenades and charges 5-25
    uniform 3, vest 3-25 and headgear 3-25 by armour, backpack 2-20 by how much it holds
    binoculars 3, designator 40, night vision 25, thermal 60, attachment 3-10
    first aid kit 2, medikit 10, toolkit 8, UAV terminal 25, GPS 5, radio 3, map/compass/watch 1
    ACE and KAT: bandages, tourniquets and chest seals 1, drugs 2, fluids 5, kits 10
    anything else by its mass, 1 to 25

Parameters:
none

Returns:
nothing; sets ALiVE_FOB_gearPrice and ALiVE_FOB_gearClasses

Author:
Jman
---------------------------------------------------------------------------- */

if (!isServer) exitWith {};

private _logic = missionNamespace getVariable ["ALiVE_sup_fob", objNull];
private _scale = [_logic, "attribute", ["fob_cost_scale"]] call ALiVE_fnc_FOB;
private _explosives = [_logic, "attribute", ["fob_arsenal_explosives"]] call ALiVE_fnc_FOB;
private _debug = [_logic, "attribute", ["fob_debug"]] call ALiVE_fnc_FOB;
private _t0 = diag_tickTime;

private _prices = createHashMap;
private _weapons = [];
private _magazines = [];
private _items = [];
private _backpacks = [];

// the module's lists, sorted by the build scan: [never, only, also, fixed prices]
(missionNamespace getVariable ["ALiVE_FOB_gearOverrides", [[], [], [], createHashMap]]) params ["_never", "_onlyList", "_alsoList", "_fixed"];

private _put = {
    params ["_class", "_cfg", "_cost", "_kind", "_list", ["_rounds", 0]];
    private _k = toLower _class;
    if (_k in _prices || {_k in _never}) exitWith {};
    // a price set in the lists is used as it is, as the build menu does
    private _c = _fixed getOrDefault [_k, (round (_cost * _scale)) max 1];
    _prices set [_k, [_c, _kind, _rounds]];
    _list pushBack _class;
    if (_debug) then { diag_log format ["ALiVE_FOB_GEAR %1", [_class, getText (_cfg >> "displayName"), _kind, _c, configSourceMod _cfg]] };
};

// what the arsenal itself would show
private _visible = {
    params ["_cfg"];
    getNumber (_cfg >> "scope") == 2
        && {!isNumber (_cfg >> "scopeArsenal") || {getNumber (_cfg >> "scopeArsenal") == 2}}
        && {getText (_cfg >> "displayName") != ""}
};

// every magazine a weapon takes, on every muzzle, through magazines[] and its magazine wells
private _magsOf = {
    params ["_wcfg", ["_firstOnly", false]];
    private _out = [];
    private _muzzles = getArray (_wcfg >> "muzzles");
    if (_muzzles isEqualTo []) then { _muzzles = ["this"] };
    if (_firstOnly) then { _muzzles = [_muzzles select 0] };
    {
        private _m = if (_x == "this") then { _wcfg } else { _wcfg >> _x };
        _out append ((getArray (_m >> "magazines")) select { _x isEqualType "" });
        {
            private _well = configFile >> "CfgMagazineWells" >> _x;
            { _out append ((getArray _x) select { _x isEqualType "" }) } forEach (configProperties [_well, "isArray _x", true]);
        } forEach ((getArray (_m >> "magazineWell")) select { _x isEqualType "" });
    } forEach _muzzles;
    _out arrayIntersect _out
};

private _hitOf = { params ["_mag"]; getNumber (configFile >> "CfgAmmo" >> (getText (configFile >> "CfgMagazines" >> _mag >> "ammo")) >> "hit") };

// a magazine's price for a full one, and an explosive's
private _magPrice = {
    params ["_mag", "_mcfg", ["_forceExplosive", false]];
    private _ammo = configFile >> "CfgAmmo" >> getText (_mcfg >> "ammo");
    private _hit = getNumber (_ammo >> "hit");
    if (_forceExplosive || {getNumber (_ammo >> "explosive") > 0.5 && {_hit >= 50}}) exitWith { 5 + 20 * ((_hit / 600) min 1) };
    1 + 2 * ((_hit / 15) min 1)
};

private _armour = {
    params ["_cfg"];
    private _a = 0;
    { _a = _a max (getNumber (_x >> "armor")) } forEach ("true" configClasses (_cfg >> "ItemInfo" >> "HitpointsProtectionInfo"));
    _a
};

private _byMass = {
    params ["_cfg"];
    private _m = getNumber (_cfg >> "ItemInfo" >> "mass");
    if (_m <= 0) then { _m = getNumber (_cfg >> "WeaponSlotsInfo" >> "mass") };
    ((ceil (_m / 10)) max 1) min 25
};

// ACE and KAT medical, by name: the classes differ between versions
private _aceMedical = isClass (configFile >> "CfgPatches" >> "ace_medical_treatment");
private _misc = configFile >> "CfgWeapons" >> "CBA_MiscItem";
private _acePrice = {
    params ["_lc"];
    if (["blood", "plasma", "saline", "_iv"] findIf { _x in _lc } > -1) exitWith { 5 };
    if (["personalaidkit", "surgicalkit", "bodybag"] findIf { _x in _lc } > -1) exitWith { 10 };
    if (["morphine", "epinephrine", "adenosine", "painkiller"] findIf { _x in _lc } > -1) exitWith { 2 };
    if (["bandage", "dressing", "packing", "elastic", "quikclot", "tourniquet", "splint", "chestseal"] findIf { _x in _lc } > -1) exitWith { 1 };
    -1
};

private _wantMags = [];
// one CfgWeapons class: a gun, binoculars or night vision, or an item
private _classify = {
    params ["_cfg"];
    private _class = configName _cfg;
    private _type = getNumber (_cfg >> "type");
        switch (true) do {
            // guns and launchers, their base class only
            case (_type in [1, 2, 4]): {
                private _base = [_class] call BIS_fnc_baseWeapon;
                private _bcfg = configFile >> "CfgWeapons" >> _base;
                if !(isClass _bcfg && {[_bcfg] call _visible}) then { _base = _class; _bcfg = _cfg };
                if (toLower _base in _prices) exitWith {};
                private _main = [_bcfg, true] call _magsOf;
                // something with nothing to fire is no gun (a laser pointer or mortar barrel filed as one)
                if (_main isEqualTo []) exitWith {};
                // a machine gun by its own magazine: a rifle's well can take a machine gun's (the MX takes the 100-round MX SW one)
                private _cap = getNumber (configFile >> "CfgMagazines" >> ((getArray (_bcfg >> "magazines")) param [0, ""]) >> "count");
                // a grenade launcher or shotgun by its own magazine too: its other rounds can be flares,
                // smoke or slugs
                private _own = configFile >> "CfgAmmo" >> getText (configFile >> "CfgMagazines" >> ((getArray (_bcfg >> "magazines")) param [0, ""]) >> "ammo");
                // (a laser aiming device files its beam as an explosive round that does no harm)
                private _gl = (getNumber (_own >> "explosive") > 0.5 && {getNumber (_own >> "indirectHit") > 0}) || {getText (_own >> "simulation") in ["shotShell", "shotGrenade"]};
                private _shotgun = toLower getText (_bcfg >> "cursor") == "sgun" || {getText (_own >> "simulation") == "shotSpread"} || {getText (_own >> "submunitionAmmo") != ""} || {isArray (_own >> "submunitionAmmo")};
                private _hit = 0; private _aa = false;
                {
                    _hit = _hit max ([_x] call _hitOf);
                    if (getNumber (configFile >> "CfgAmmo" >> (getText (configFile >> "CfgMagazines" >> _x >> "ammo")) >> "airLock") == 2) then { _aa = true };
                } forEach _main;
                // nor is a long gun whose rounds hurt nobody (US85's AN/PAQ-1 laser)
                if (_type == 1 && {!_gl} && {_hit <= 0}) exitWith {};
                // machine guns and sniper rifles by the game's own cursor, which a mod's guns inherit from
                // the base game's; by magazine size and round only when the cursor says nothing
                private _cursor = toLower getText (_bcfg >> "cursor");
                private _kind = switch (true) do {
                    case (_type == 2): { "PISTOL" };
                    case (_type == 4): { ["AT", "AA"] select _aa };
                    case (_gl): { "GL" };
                    case (_shotgun): { "SHOTGUN" };
                    case (_cursor == "mg"): { "MG" };
                    case (_cursor == "arifle"): { "RIFLE" };
                    case (_cap >= 75): { "MG" };
                    // a marksman's or sniper's rifle fires a full-power round, whatever its cursor says
                    case ((_cursor == "srifle" || {_hit >= 20}) && {_hit >= 10}): { "SNIPER" };
                    default { "RIFLE" };
                };
                private _p = switch (_kind) do {
                    case "PISTOL": { 5 + 7 * ((_hit / 10) min 1) };
                    case "AA": { 90 + 35 * ((_hit / 100) min 1) };
                    case "AT": { 60 + 65 * ((_hit / 600) min 1) };
                    case "GL": { 35 };
                    case "SHOTGUN": { 20 };
                    case "MG": { 40 + 30 * ((_hit / 15) min 1) };
                    case "SNIPER": { 60 + 30 * (((_hit - 10) / 20) max 0 min 1) };
                    default { 15 + 25 * ((_hit / 12) min 1) };
                };
                [_base, _bcfg, _p, _kind, _weapons] call _put;
                _wantMags append ([_bcfg] call _magsOf);
            };
            // binoculars, designators and night vision
            case (_type == 4096): {
                if (getText (_cfg >> "simulation") == "NVGoggles") exitWith {
                    private _ti = (getArray (_cfg >> "visionMode")) findIf { _x isEqualType "" && {toUpper _x == "TI"} } > -1;
                    [_class, _cfg, [25, 60] select _ti, "NVG", _items] call _put;
                };
                if ((getArray (_cfg >> "magazines")) isNotEqualTo []) exitWith { [_class, _cfg, 40, "DESIGNATOR", _weapons] call _put };
                [_class, _cfg, 3, "BINOCULARS", _weapons] call _put;
            };
            case (_type == 131072): {
                private _lc = toLower _class;
                private _it = getNumber (_cfg >> "ItemInfo" >> "type");
                private _sim = getText (_cfg >> "simulation");
                private _ace = if (_aceMedical && {"ace_" in _lc || {"kat_" in _lc}}) then { [_lc] call _acePrice } else { -1 };
                // CBA files its loose items (ACE's, KAT's) in the bipod slot
                private _isMisc = isClass _misc && {_class isKindOf ["CBA_MiscItem", configFile >> "CfgWeapons"]};
                switch (true) do {
                    case (_ace > 0): { [_class, _cfg, _ace, "MEDICAL", _items] call _put };
                    case (_it == 101): { [_class, _cfg, 5, "MUZZLE", _items] call _put };
                    case (_it == 201): { [_class, _cfg, 10, "OPTIC", _items] call _put };
                    case (_isMisc): { [_class, _cfg, [_cfg] call _byMass, "ITEM", _items] call _put };
                    case (_it in [301, 302]): { [_class, _cfg, 3, ["POINTER", "BIPOD"] select (_it == 302), _items] call _put };
                    case (_it == 401): { [_class, _cfg, 2, "MEDICAL", _items] call _put };
                    case (_it == 605): { [_class, _cfg, 3 + 22 * ((([_cfg] call _armour) / 10) min 1), "HEADGEAR", _items] call _put };
                    case (_it == 616): { [_class, _cfg, 25, "NVG", _items] call _put };
                    case (_it == 619): { [_class, _cfg, 10, "MEDICAL", _items] call _put };
                    case (_it == 620): { [_class, _cfg, 8, "TOOL", _items] call _put };
                    case (_it == 621): { [_class, _cfg, 25, "TERMINAL", _items] call _put };
                    case (_it == 701): { [_class, _cfg, 3 + 22 * ((([_cfg] call _armour) / 24) min 1), "VEST", _items] call _put };
                    case (_it == 801): { [_class, _cfg, 3, "UNIFORM", _items] call _put };
                    case (_sim in ["ItemMap", "ItemCompass", "ItemWatch"]): { [_class, _cfg, 1, "ITEM", _items] call _put };
                    case (_sim == "ItemGPS"): { [_class, _cfg, 5, "ITEM", _items] call _put };
                    case (_sim == "ItemRadio"): { [_class, _cfg, 3, "RADIO", _items] call _put };
                    default { [_class, _cfg, [_cfg] call _byMass, "ITEM", _items] call _put };
                };
            };
        };
};
{
    if ([_x] call _visible) then { [_x] call _classify };
} forEach ("getNumber (_x >> 'scope') == 2" configClasses (configFile >> "CfgWeapons"));

// classes Also Build or Build Only These name that the scan above left out (a class hidden from
// the arsenal, say), priced by the same rules
private _named = [];
{
    private _c = _x;
    switch (true) do {
        case (isClass (configFile >> "CfgWeapons" >> _c)): {
            // a price given for a gun's variant (arifle_MX_ACO_F=50) goes on the gun the arsenal offers
            private _base = toLower ([_c] call BIS_fnc_baseWeapon);
            if (toLower _c in _fixed && {!(_base in _fixed)}) then { _fixed set [_base, _fixed get (toLower _c)] };
            [configFile >> "CfgWeapons" >> _c] call _classify;
        };
        case (isClass (configFile >> "CfgMagazines" >> _c)): { _named pushBack _c };
        case (isClass (configFile >> "CfgGlasses" >> _c)): { [_c, configFile >> "CfgGlasses" >> _c, 1, "FACEWEAR", _items] call _put };
        default {
            private _b = configFile >> "CfgVehicles" >> _c;
            [_c, _b, 2 + 18 * (((getNumber (_b >> "maximumLoad")) / 320) min 1), "BACKPACK", _backpacks] call _put;
        };
    };
} forEach (_alsoList + _onlyList);

// the magazines those weapons take
_wantMags = _wantMags arrayIntersect _wantMags;
{
    private _mcfg = configFile >> "CfgMagazines" >> _x;
    if (isClass _mcfg && {[_mcfg] call _visible}) then {
        private _n = (getNumber (_mcfg >> "count")) max 1;
        [configName _mcfg, _mcfg, [_x, _mcfg] call _magPrice, "MAGAZINE", _magazines, _n] call _put;
    };
} forEach _wantMags;
{
    private _mcfg = configFile >> "CfgMagazines" >> _x;
    [configName _mcfg, _mcfg, [_x, _mcfg] call _magPrice, "MAGAZINE", _magazines, (getNumber (_mcfg >> "count")) max 1] call _put;
} forEach _named;

// ACE's and KAT's medicines that come as a magazine of doses (painkillers), with no gun to fire them
if (_aceMedical) then {
    {
        private _lc = toLower configName _x;
        private _p = if ("ace_" in _lc || {"kat_" in _lc}) then { [_lc] call _acePrice } else { -1 };
        if (_p > 0 && {!(_lc in _prices)} && {[_x] call _visible}) then {
            [configName _x, _x, _p, "MEDICAL", _magazines, (getNumber (_x >> "count")) max 1] call _put;
        };
    } forEach ("getNumber (_x >> 'scope') == 2" configClasses (configFile >> "CfgMagazines"));
};

// grenades, mines and charges
if (_explosives) then {
    {
        private _wcfg = configFile >> "CfgWeapons" >> _x;
        {
            private _mcfg = configFile >> "CfgMagazines" >> _x;
            if (isClass _mcfg && {[_mcfg] call _visible}) then {
                [configName _mcfg, _mcfg, [_x, _mcfg, true] call _magPrice, "EXPLOSIVE", _magazines, (getNumber (_mcfg >> "count")) max 1] call _put;
            };
        } forEach ([_wcfg] call _magsOf);
    } forEach ["Throw", "Put"];
};

// facewear
{
    [configName _x, _x, 1, "FACEWEAR", _items] call _put;
} forEach ("getNumber (_x >> 'scope') == 2 && {getText (_x >> 'displayName') != ''}" configClasses (configFile >> "CfgGlasses"));

// plain backpacks
{
    private _cfg = _x;
    private _filled = ["TransportMagazines", "TransportItems", "TransportWeapons", "TransportBackpacks"] findIf { count ("true" configClasses (_cfg >> _x)) > 0 } > -1;
    // and one that carries something: a static weapon's tripod or gun bag holds nothing
    if ([_cfg] call _visible && {getText (_cfg >> "assembleInfo" >> "assembleTo") == ""} && {!_filled} && {getNumber (_cfg >> "maximumLoad") > 0}) then {
        [configName _cfg, _cfg, 2 + 18 * (((getNumber (_cfg >> "maximumLoad")) / 320) min 1), "BACKPACK", _backpacks] call _put;
    };
} forEach ("getNumber (_x >> 'isBackpack') == 1 && {getNumber (_x >> 'scope') == 2}" configClasses (configFile >> "CfgVehicles"));

// Build Only These with gear in it: exactly that gear, each gun with the magazines it takes
if (_onlyList isNotEqualTo []) then {
    private _keep = createHashMap;
    {
        _keep set [toLower _x, true];
        if (isClass (configFile >> "CfgWeapons" >> _x)) then {
            private _base = toLower ([_x] call BIS_fnc_baseWeapon);
            _keep set [_base, true];
            if (_base in _prices) then {
                { _keep set [toLower _x, true] } forEach ([configFile >> "CfgWeapons" >> _base] call _magsOf);
            };
        };
    } forEach _onlyList;
    _weapons = _weapons select { toLower _x in _keep };
    _magazines = _magazines select { toLower _x in _keep };
    _items = _items select { toLower _x in _keep };
    _backpacks = _backpacks select { toLower _x in _keep };
    { _prices deleteAt _x } forEach ((keys _prices) select { !(_x in _keep) });
};

ALiVE_FOB_gearPrice = _prices;
ALiVE_FOB_gearClasses = [_weapons, _magazines, _items, _backpacks];

["ALiVE Player FOBs - FOB Arsenal: %1 weapons, %2 magazines, %3 items, %4 backpacks in %5 ms",
    count _weapons, count _magazines, count _items, count _backpacks, round ((diag_tickTime - _t0) * 1000)] call ALiVE_fnc_dump;
