#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(listFactionAAUnits);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_listFactionAAUnits

Description:
    Feeder for ALiVE_AAUnitChoiceMulti. Walks CfgVehicles for entries
    on the same SIDE as the given faction whose class qualifies as a
    primary AA system. Returns 6-tuples `[class, display, side, role,
    category, source]` so the Eden picker can group / filter the
    listbox by side / role / source mod.

    Side match (not exact faction match): vehicles in any faction
    whose CfgFactionClasses side equals the module faction's side
    are surfaced. An RHS USAF (WEST) module shows vanilla
    B_APC_Tracked_01_AA_F, RHS Stinger pods, and any other WEST-side
    AA from loaded mods. The source mod tag in the label distinguishes
    them.

    AA predicate (inline, see body): combined behavioural + semantic.
        - Behavioural: LandVehicle, not artilleryScanner, has at least
          one turret with maxElev > 65 AND a weapon on that turret
          whose ammo has airLock > 0.
        - Semantic: classname / displayName contains a recognised AA
          marker (AA, SAM, Stinger, Igla, ZSU, ZU-23 etc.) OR vehicle
          inherits from a canonical AA base class.
        - Exclusions: StaticMG/AT/GrenadeLauncher/Mortar, radars, laser
          designators (kindOf + substring).
        Without the semantic gate, the airLock test alone surfaces
        dual-purpose IFVs (BMP-2 family) and direct-fire howitzers.

    Role classification:
        "Static"   - StaticWeapon descendants (emplaced AA guns)
        "Vehicle"  - everything else passing the AA predicate (mobile
                     AAA, SAM systems, AA APCs)

    Category: "SAM" if vehicle inherits from SAM_System_0[1-4]_base_F,
    otherwise "AAA". Used by the picker for visual grouping.

    Source detection: configSourceMod, fallback to "Vanilla". Mod-
    identifier tag rendered in the picker label.

    scope >= 1 filter excludes hidden / base classes.

Parameters:
    0: STRING - faction class name (e.g. "BLU_F", "rhs_faction_usarmy_d")

Returns:
    ARRAY of [STRING, STRING, STRING, STRING, STRING, STRING] tuples:
      [class, display, side, role, category, source]
    Sorted alphabetically by class. Empty array if no matches.

Examples:
    (begin example)
    private _aa = ["BLU_F"] call ALiVE_fnc_listFactionAAUnits;
    // -> [["B_APC_Tracked_01_AA_F", "Bardelas", "WEST", "Vehicle", "AAA", "Vanilla"], ...]
    (end)

See Also:
    ALiVE_fnc_edenAAUnitChoiceLoad
    ALiVE_fnc_edenAAUnitChoiceSave

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_faction", "", [""]]];

if (_faction == "") exitWith { [] };

// AA predicate: combined behavioural + semantic test.
//
// BEHAVIOURAL: vehicle has at least one turret with maxElev > 65 AND a
// weapon on that turret whose ammo has airLock > 0 (engine flag set on
// AA missiles, AAA cannon shells, SAM warheads; 0 on MG bullets, GMG
// grenades, generic howitzer shells, slingloader/spotter turrets).
//
// SEMANTIC: vehicle classname OR displayName must contain a recognised
// AA marker (AA, SAM, Stinger, Igla, ZSU, ZU-23, Tunguska, Pantsir,
// Tor, Buk, Praetorian, Patriot, Centurion, Tigris, Cheetah, Bardelas
// etc.) OR inherit from a canonical AA base class. Without this gate
// the airLock test alone surfaces dual-purpose IFVs (BMP-2 has
// airLock=1 on the 2A42 30mm autocannon - real-life dual-use,
// culturally not AA) and howitzers whose direct-fire shells some mods
// flag airLock=1.
//
// Walking all turret subclasses (not just MainTurret) catches AA APCs
// like the Cheetah whose AAA gun is on a non-MainTurret slot.
//
// Combined exclusions (base-class kindOf + substring + scanner flag)
// drop static MGs, GMGs, ATGMs, mortars, radars, laser designators,
// demining UGVs, CROWS turrets with anti-personnel weapons.
private _isAA = {
    params ["_c"];
    if (
        _c isKindOf "StaticMGWeapon"      ||
        {_c isKindOf "StaticATWeapon"}    ||
        {_c isKindOf "StaticGrenadeLauncher"} ||
        {_c isKindOf "StaticMortar"}      ||
        {(toLower _c) find "radar" >= 0}  ||
        {(toLower _c) find "designator" >= 0} ||
        {(toLower (getText (configFile >> "CfgVehicles" >> _c >> "displayName"))) find "designator" >= 0}
    ) exitWith { false };
    if !(_c isKindOf "LandVehicle") exitWith { false };
    if (getNumber (configFile >> "CfgVehicles" >> _c >> "artilleryScanner") != 0) exitWith { false };

    // Semantic gate: classname / displayName / inheritance must mark
    // this as a primary AA system. Filters dual-purpose 30mm IFVs
    // (BMP-2 family) and direct-fire howitzers that would otherwise
    // pass the behavioural airLock test.
    private _classL = toLower _c;
    private _displayL = toLower (getText (configFile >> "CfgVehicles" >> _c >> "displayName"));
    private _markers = ["_aa_", "_aa.", "aa_pod", "aapod", "anti_air",
                        "anti-air", "antiair", "_sam_", "stinger",
                        "igla", "avenger", "tunguska", "shilka", "zsu",
                        "zu23", "zu_23", "zu-23", "praetorian",
                        "patriot", "centurion", "pantsir", "tigris",
                        "bardelas", "buk", "manpad", " tor ", "_tor_",
                        "rapier", "starstreak", "strela", "roland",
                        "2s6"];
    private _isSemanticAA = false;
    {
        if ((_classL find _x >= 0) || {_displayL find _x >= 0}) exitWith {
            _isSemanticAA = true;
        };
    } forEach _markers;
    if !(_isSemanticAA) then {
        private _aaBases = ["APC_Tracked_01_AA_base_F",
                            "APC_Tracked_02_AA_base_F",
                            "SAM_System_01_base_F",
                            "SAM_System_02_base_F",
                            "SAM_System_04_base_F",
                            "AAA_System_01_base_F"];
        {
            if (_c isKindOf _x) exitWith { _isSemanticAA = true };
        } forEach _aaBases;
    };
    if !(_isSemanticAA) exitWith { false };

    // Behavioural gate: at least one high-elev turret with airLock-
    // enabled ammo on one of its weapons.
    private _isAACapable = false;
    private _turrets = "true" configClasses (configFile >> "CfgVehicles" >> _c >> "Turrets");
    {
        if (_isAACapable) exitWith {};
        if ((getNumber (_x >> "maxElev")) > 65) then {
            private _weapons = getArray (_x >> "weapons");
            {
                if (_isAACapable) exitWith {};
                private _mags = getArray (configFile >> "CfgWeapons" >> _x >> "magazines");
                {
                    private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
                    if (getNumber (configFile >> "CfgAmmo" >> _ammo >> "airLock") > 0) exitWith {
                        _isAACapable = true;
                    };
                } forEach _mags;
            } forEach _weapons;
        };
    } forEach _turrets;
    _isAACapable
};

// Filter scope is SIDE-based not exact-faction-match. An RHS USAF
// (WEST) module's AA picker needs to surface vanilla B_APC_Tracked_01_AA_F
// alongside RHS variants, plus any other mod's WEST-side AA. Exact
// faction matching would cut the listbox to the module's namesake mod
// only, missing canonical BIS classes that work fine for cross-mod
// missions. Source mod tag in the label lets the user distinguish
// vanilla vs RHS vs other.
private _factionSide = getNumber (configFile >> "CfgFactionClasses" >> _faction >> "side");
private _result = [];
private _seen = createHashMap;

// Single CfgVehicles walk. Filter chain: scope >= 1 + faction match +
// AA predicate. configClasses with "true" condition is the canonical
// way to enumerate descendants.
private _all = "true" configClasses (configFile >> "CfgVehicles");

{
    private _cfg = _x;
    private _class = configName _cfg;
    private _classLower = toLower _class;
    if !(_classLower in _seen) then {
        _seen set [_classLower, true];
        if (getNumber (_cfg >> "scope") >= 1) then {
            // Filter by side: vehicle's parent faction's side must
            // match the module faction's side. Lookup chain:
            //   vehicle -> getText "faction" -> CfgFactionClasses ->
            //   getNumber "side"
            private _vehFaction = getText (_cfg >> "faction");
            private _vehSide = getNumber (configFile >> "CfgFactionClasses" >> _vehFaction >> "side");
            if (_vehSide == _factionSide) then {
                if ([_class] call _isAA) then {
                    private _display = getText (_cfg >> "displayName");
                    if (_display == "") then { _display = _class };

                    private _side = switch (_factionSide) do {
                        case 0: { "EAST" };
                        case 1: { "WEST" };
                        case 2: { "GUER" };
                        case 3: { "CIV"  };
                        default { "Unknown" };
                    };

                    // Role classification
                    private _role = if (_class isKindOf "StaticWeapon") then {
                        "Static"
                    } else {
                        "Vehicle"
                    };

                    // Category - second-level parent class name (after
                    // CfgVehicles), the conventional taxonomy slot
                    private _category = "AAA";
                    if (_class isKindOf "SAM_System_01_base_F" || _class isKindOf "SAM_System_02_base_F" ||
                        _class isKindOf "SAM_System_03_base_F" || _class isKindOf "SAM_System_04_base_F") then {
                        _category = "SAM";
                    };

                    // Source mod identifier
                    private _source = configSourceMod _cfg;
                    if (_source == "") then { _source = "Vanilla" };

                    _result pushBack [_class, _display, _side, _role, _category, _source];
                };
            };
        };
    };
} forEach _all;

// Sort alphabetically by class name for stable picker order
_result sort true;

_result
