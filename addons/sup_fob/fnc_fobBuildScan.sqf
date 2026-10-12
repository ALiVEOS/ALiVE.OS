#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobBuildScan);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fobBuildScan

Description:
The build catalog: what players can build at a FOB and what each costs, worked out once on the
server from the game's own config, so it covers whatever mods are loaded without a hand-typed
price list.

Fortifications are the military walls, fences and structures the editor lists (sandbags,
H-barriers, bunkers, towers, camo nets), plus portable lights. Supply objects are the ones that
rearm, refuel, repair or heal (ammo and fuel containers, repair depots, medical tents) and
helipads. Ruins, wrecks and anything wider than 40 m are left out.

A fortification's price grows with how tough it is and how big:
    3 + 72 x min(1, armour / 500) x sqrt(min(1, volume / 600)), 3 to 75
with a floor for what it does (wire 10, camo net 20, tower 40, light 5). A supply object's
price grows with how much it holds, 20 to 50; medical 35, helipads 25. Every price is then
multiplied by the module's Cost Scale and rounded, never below 1.

A mission or mod can change the catalog through CfgALiVEFOBBuildables, in description.ext or a
mod's config (the mission's wins):
    class CfgALiVEFOBBuildables {
        blacklist[] = {"Land_Razorwire_F"};      // never offered
        whitelist[] = {"Land_Pallets_F"};        // offered, priced as a fortification
        class Land_HBarrier_5_F { cost = 7; };   // a fixed price (1 to 100000)
    };
A price that isn't a whole number from 1 to 100000 is refused with a warning in the RPT and
the worked-out price is used instead.

Sizes come from a local, unsimulated copy of each object, measured a few at a time, and are
kept in the server's profile, so later starts skip the measuring.

Parameters:
None

Returns:
Number - the catalog's size. Sets ALiVE_FOB_catalog on every machine:
[[class, display name, category, cost, picture, tier needed], ...]

Author:
Jman
---------------------------------------------------------------------------- */

if (isRemoteExecuted && {remoteExecutedOwner != 2} && {isNil "_ALiVE_fobCaller"}) exitWith {};
if (!isServer) exitWith {0};

private _logic = missionNamespace getVariable ["ALiVE_sup_fob", objNull];
private _scale = [_logic, "attribute", ["fob_cost_scale"]] call ALiVE_fnc_FOB;
private _t0 = diag_tickTime;

// Overrides: the mission's config first, then any mod's
private _blacklist = [];
private _whitelist = [];
private _fixed = createHashMap;
{
    private _root = _x >> "CfgALiVEFOBBuildables";
    if (isClass _root) then {
        _blacklist append ((getArray (_root >> "blacklist")) select { _x isEqualType "" } apply { toLower _x });
        _whitelist append ((getArray (_root >> "whitelist")) select { _x isEqualType "" });
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

private _rows = [];
private _seen = createHashMap;
private _add = {
    params ["_class", "_cfg", "_kind"];
    private _lc = toLower _class;
    if (_lc in _seen || {_lc in _blacklist}) exitWith {};
    _seen set [_lc, true];
    private _cost = _fixed getOrDefault [_lc, -1];
    if (_cost < 0) then { _cost = (round (([_class, _cfg, _kind] call _price) * _scale)) max 1 };
    private _pic = getText (_cfg >> "editorPreview");
    _rows pushBack [_class, getText (_cfg >> "displayName"), _kind, _cost, _pic, 1];
};

{
    private _cfg = _x;
    private _class = configName _cfg;
    if (getText (_cfg >> "model") != "" && {!(_class isKindOf "AllVehicles")} && {!([_class, _cfg] call _isRuin)}) then {
        private _cat = getText (_cfg >> "editorCategory");
        private _sub = getText (_cfg >> "editorSubcategory");
        private _isService = (_service findIf { getNumber (_cfg >> _x) > 0 }) > -1;
        private _kind = switch (true) do {
            case (_isService && {_cat == "EdCat_Supplies" || {_sub == "EdSubcat_Military"}}): {"SUPPLY"};
            case (_sub == "EdSubcat_Helipads"): {"SUPPLY"};
            case (_sub == "EdSubcat_Military" && {_cat in ["EdCat_Walls", "EdCat_Fences"] || {_cat find "EdCat_Structures" == 0}}): {"FORTIFICATION"};
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

_rows sort true;
if (_measured > 0) then {
    profileNamespace setVariable ["ALiVE_FOB_sizes", _sizes];
    saveProfileNamespace;
};

ALiVE_FOB_catalog = _rows;
publicVariable "ALiVE_FOB_catalog";
["ALiVE Player FOBs - build catalog: %1 fortifications, %2 supply, %3 measured, %4 ms",
    { (_x select 2) == "FORTIFICATION" } count _rows, { (_x select 2) == "SUPPLY" } count _rows, _measured, round ((diag_tickTime - _t0) * 1000)] call ALiVE_fnc_dump;
count _rows
