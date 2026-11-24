#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(MCSCompat);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_MCSCompat

Description:
    Works alongside the MCS containers mod (Steam Workshop 3844340520) when it
    is loaded. ALiVE ships and changes no MCS file: every MCS name it reads
    (its CfgPatches class, container classes and container variables) is in
    the one list below and is checked at run time. If a name is missing (an
    MCS update renamed it), one line is logged and that part is left off.

    With the Player FOBs option "MCS Containers In Build List" on, the MCS
    containers are offered in a FOB's build menu, under Supply, at the prices
    and tiers below (a price in the module's lists or CfgALiVEFOBBuildables
    wins, and Never Build still drops one). A container built at a FOB belongs
    to the FOB's side, and works under MCS's own power rules: the containers
    that need power need a generator on a cable, as MCS has it.

    The armory container's arsenal follows "MCS Armory Arsenal":
        SIDE  (default) the gear the side's soldiers carry: the uniforms,
              weapons, magazines, items and backpacks of the soldiers of the
              factions the side's AI Commanders field (its own side's when it
              has none);
        FULL  every item, as MCS gives with no list set;
        NONE  the armory is not offered.

    "loaded":  true when MCS is loaded.
    "rows":    [[class, cost, tier], ...] for the build scan; [] when off.
    "onBuilt": [object, side string] after a FOB builds or rebuilds a
               container (server).

Parameters:
    0: STRING - mode
    1: ARRAY - arguments

Returns:
    BOOL for "loaded", ARRAY for "rows", nothing otherwise

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_mode", "loaded", [""]], ["_args", [], [[]]]];

// every MCS name ALiVE reads, in one place
private _N = createHashMapFromArray [
    ["patch", "mcs_ew"],
    // [class, cost, tier]: the command post, medical, EW and mast containers do the work, the
    // generator powers them, the armory holds the arsenal
    ["build", [
        ["Land_MCS_Generator_F", 60, 1],
        ["Land_MCS_CommandPost_F", 150, 2],
        ["Land_MCS_MedContainer_F", 120, 2],
        ["Land_MCS_ArmoryContainer_F", 150, 2],
        ["Land_MCS_EWContainer_F", 200, 3],
        ["Land_MCS_MastContainer_F", 80, 3]
    ]],
    ["armory", "Land_MCS_ArmoryContainer_F"],
    // the side a jammer or mast container works for (MCS sets it from its first user otherwise)
    ["net", "mcs_net"],
    ["netClasses", ["Land_MCS_EWContainer_F", "Land_MCS_MastContainer_F"]]
];

private _loaded = isClass (configFile >> "CfgPatches" >> (_N get "patch"));
if (_mode == "loaded") exitWith { _loaded };
if (!_loaded || {!isServer}) exitWith { [[], nil] select (_mode != "rows") };

private _logic = missionNamespace getVariable ["ALiVE_sup_fob", objNull];

switch (_mode) do {
    case "rows": {
        if !([_logic, "attribute", ["fob_mcs_build"]] call ALiVE_fnc_FOB) exitWith { [] };
        private _armory = [_logic, "attribute", ["fob_mcs_armory"]] call ALiVE_fnc_FOB;
        private _rows = (_N get "build") select { _armory != "NONE" || {(_x select 0) != (_N get "armory")} };
        private _missing = _rows select { !isClass (configFile >> "CfgVehicles" >> (_x select 0)) };
        if (_missing isNotEqualTo []) then {
            ["ALiVE Player FOBs - MCS: these MCS containers are not in this version of MCS, so they are not offered: %1", _missing apply { _x select 0 }] call ALiVE_fnc_dump;
        };
        _rows = _rows - _missing;
        ["ALiVE Player FOBs - MCS is loaded: %1 MCS containers offered in the build list (armory arsenal %2)", count _rows, _armory] call ALiVE_fnc_dump;
        _rows
    };

    case "onBuilt": {
        _args params [["_o", objNull, [objNull]], ["_side", "", [""]]];
        if (isNull _o) exitWith {};
        private _class = typeOf _o;
        if ((_N get "build") findIf { (_x select 0) == _class } < 0) exitWith {};
        if (_class in (_N get "netClasses") && {_side != ""}) then { _o setVariable [_N get "net", _side, true] };
        if (_class != (_N get "armory")) exitWith {};
        if (([_logic, "attribute", ["fob_mcs_armory"]] call ALiVE_fnc_FOB) != "SIDE") exitWith {};

        // the side's soldiers' gear, worked out once per side and set of factions
        private _cache = missionNamespace getVariable ["ALiVE_MCS_sideGear", createHashMap];
        private _factions = ((missionNamespace getVariable ["ALiVE_FOB_sideFactions", []]) select { (_x select 0) == _side }) param [0, ["", []]] select 1;
        private _key = _side + str _factions;
        if !(_key in _cache) then {
            private _sideNum = ["EAST", "WEST", "GUER"] find _side;
            private _gear = createHashMap;
            private _bags = createHashMap;
            {
                private _cfg = _x;
                private _f = toLower getText (_cfg >> "faction");
                if ((_factions isEqualTo [] && {getNumber (_cfg >> "side") == _sideNum}) || {_f in _factions}) then {
                    {
                        if (_x isEqualType "" && {_x != ""} && {!(_x in ["Throw", "Put"])}) then { _gear set [[_x] call BIS_fnc_baseWeapon, true] };
                    } forEach getArray (_cfg >> "weapons");
                    { if (_x isEqualType "" && {_x != ""}) then { _gear set [_x, true] } } forEach (getArray (_cfg >> "magazines") + getArray (_cfg >> "items") + getArray (_cfg >> "linkedItems") + [getText (_cfg >> "uniformClass")]);
                    private _b = getText (_cfg >> "backpack");
                    if (_b != "" && {isClass (configFile >> "CfgVehicles" >> _b)}) then { _bags set [_b, true] };
                };
            } forEach ("getNumber (_x >> 'scope') == 2 && {configName _x isKindOf 'CAManBase'}" configClasses (configFile >> "CfgVehicles"));
            // a prefilled backpack's plain parent, as the arsenal lists bags
            private _plainBags = (keys _bags) apply {
                private _p = configFile >> "CfgVehicles" >> _x;
                while { isClass (inheritsFrom _p) && {count ("true" configClasses (_p >> "TransportItems")) + count ("true" configClasses (_p >> "TransportMagazines")) + count ("true" configClasses (_p >> "TransportWeapons")) > 0} } do { _p = inheritsFrom _p };
                configName _p
            };
            _cache set [_key, [keys _gear, _plainBags arrayIntersect _plainBags]];
            missionNamespace setVariable ["ALiVE_MCS_sideGear", _cache];
            ["ALiVE Player FOBs - MCS armory for %1: %2 items and %3 backpacks from factions %4", _side, count keys _gear, count (_plainBags arrayIntersect _plainBags), [_factions, "its own side's"] select (_factions isEqualTo [])] call ALiVE_fnc_dump;
        };
        (_cache get _key) params ["_items", "_backpacks"];
        if (_items isEqualTo [] && {_backpacks isEqualTo []}) exitWith {};
        // the item list only: MCS opens the arsenal from its own lockers and racks (mcs_fnc_arOpen)
        if (!isNil "ace_arsenal_fnc_addVirtualItems") then {
            [_o, _items + _backpacks, true] call ace_arsenal_fnc_addVirtualItems;
        } else {
            private _w = _items select { isClass (configFile >> "CfgWeapons" >> _x) && {getNumber (configFile >> "CfgWeapons" >> _x >> "type") in [1, 2, 4]} };
            private _m = _items select { isClass (configFile >> "CfgMagazines" >> _x) };
            [_o, _w, true] call BIS_fnc_addVirtualWeaponCargo;
            [_o, _m, true] call BIS_fnc_addVirtualMagazineCargo;
            [_o, (_items - _w) - _m, true] call BIS_fnc_addVirtualItemCargo;
            [_o, _backpacks, true] call BIS_fnc_addVirtualBackpackCargo;
        };
    };
};
