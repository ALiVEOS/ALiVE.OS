#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(substituteFactionVehicle);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_substituteFactionVehicle

Description:
Phase 3c.2b of the mil_placement overhaul. Vehicle/static counterpart to
ALiVE_fnc_substituteFactionUnit. Given a vanilla A3 vehicle class
(produced by spawning through an inferred-faction redirect or by
mil_placement's side-default fallback when the mod faction has no
vehicles in a category) and the original mod faction the user actually
selected, return a same-kindOf vehicle from the mod faction so the
spawned vehicles look like the mod's instead of vanilla A3.

Three caller paths:
  1. createProfilesFromGroupConfig - vehicles inside a CfgGroups group
     (a Motorized Squad's transport truck, a Mortar Team's mortar, etc.)
  2. createProfilesCrewedVehicle - standalone crewed vehicles spawned by
     mil_placement (HQ helis, supply trucks, motorised/mech/armoured,
     statics in support placements)
  3. createProfilesUnCrewedVehicle - standalone uncrewed vehicles
     (parked supplies, empty heli pads)

Bucketing starts from ALiVE_fnc_vehicleGetKindOf's canonical 8-category
model (Car / Tank / Armored / Truck / Ship / Helicopter / Plane /
StaticWeapon) so substitution preserves vehicle role-intent within a
group - a transport truck never substitutes to a tank. THREE families
get finer sub-bucketing where the canonical category lumps tactically-
distinct vehicles together:

  Car         -> Car_Armored (Wheeled APC / MRAP / LSV / armor>=200) vs
                 Car (Offroad / Hatchback / SUV / Quadbike). Prevents an
                 MRAP-for-Hatchback or Hatchback-for-APC mismatch.
  Helicopter  -> Helicopter_Attack (dedicated gunship - vanilla bases
                 plus the universal "transportSoldier <= 2" heuristic
                 for mod attack helis) vs Helicopter (transport /
                 multirole, including those with door guns).
  StaticWeapon-> StaticMortar / StaticATWeapon / StaticAAWeapon /
                 StaticGMGWeapon / StaticMGWeapon / StaticWeapon. A
                 mortar-for-HMG swap would break tactical intent.

Tank / Armored / Ship / Plane are kept as single buckets - finer splits
showed marginal value in audit (mod factions usually have only 1-3
vehicles per category) and would create empty buckets that trigger the
source-unchanged fallback unnecessarily.

Per-faction vehicle pools are cached in ALiVE_factionVehiclePoolCache.
First call for a faction enumerates its CfgVehicles non-Man scope>=2
entries, classifies each by kindOf, buckets accordingly. Subsequent
calls just look up the cached pool. Same nil-in-array cache lookup
trap that hit substituteFactionUnit applies here - use `in` against
the hashmap key set rather than `getOrDefault [k, nil]`.

Fallback chain (per substitution):
  1. Target faction has vehicles of the requested kindOf -> random pick
  2. Otherwise -> source unchanged (vanilla A3 vehicle stays)

NOTE: NO cross-category fallback. Unlike infantry where "Rifleman"
makes a sensible catch-all, vehicles have no universal fallback -
a Plane-for-Helicopter swap, or Tank-for-Truck, would be worse than
keeping the vanilla A3 vehicle. Sparse-pool factions just keep their
vanilla A3 fallbacks for missing categories. This is consistent with
3c.1's redirect-only behaviour for Phase 3c.1-only factions.

Parameters:
Array - [_sourceVehicle, _targetFaction]
    _sourceVehicle : STRING - vanilla A3 (or otherwise unsubstituted)
                              vehicle classname.
    _targetFaction : STRING - the mod faction classname the mission-maker
                              originally selected.

Returns:
STRING - substituted vehicle classname from _targetFaction, or
         _sourceVehicle unchanged if no same-kindOf vehicle exists.

Examples:
(begin example)
_sub = ["O_Truck_03_transport_F", "rhsgref_faction_un"] call ALiVE_fnc_substituteFactionVehicle;
// -> e.g. "rhsgref_BTR60_un" (or unchanged if UN has no Truck-kindOf vehicles)
(end)

See Also:
- ALiVE_fnc_vehicleGetKindOf       (canonical kindOf bucketing)
- ALiVE_fnc_substituteFactionUnit  (infantry counterpart - 3c.2a)
- ALiVE_fnc_inferFactionMapping    (Phase 3c.1 redirect that triggers this)

Author:
Jman
---------------------------------------------------------------------------- */

params [
    ["_sourceVehicle", "", [""]],
    ["_targetFaction", "", [""]]
];

if (_sourceVehicle == "" || _targetFaction == "") exitWith { _sourceVehicle };

// Lazy-init the global pool cache. HashMap-of-hashmaps keyed by faction
// classname. Inner hashmap: kindOf-bucket -> array of vehicle classnames.
if (isNil "ALiVE_factionVehiclePoolCache") then {
    ALiVE_factionVehiclePoolCache = createHashMap;
};

// ------------------------------------------------------------------------
// Helper: classify a vehicle into a substitution bucket.
//
// Most non-statics defer to ALiVE_fnc_vehicleGetKindOf's canonical 8-
// category convention. THREE families get finer-grained dispatch where
// the canonical bucket lumps tactically-distinct vehicles together:
//
//   1. StaticWeapon   -> StaticMortar / StaticATWeapon / StaticAAWeapon /
//                        StaticGMGWeapon / StaticMGWeapon / StaticWeapon.
//                        A mortar request must not resolve to an HMG.
//   2. Car            -> Car_Armored / Car. The vanilla A3 "Car" class
//                        spans Hatchback through Marid APC; without a
//                        split, a soft-transport request could resolve
//                        to an MRAP and vice versa.
//   3. Helicopter     -> Helicopter_Attack / Helicopter. Vanilla and mod
//                        attack helis have no troop transport role - a
//                        transport-heli request must not return a Kajman.
//
// Subdivision uses kindOf chains where the source is vanilla A3 (clean
// classification), with config-property fallbacks (armor / transport
// capacity) for mod vehicles that don't derive from the A3 base classes.
//
// Truck is checked BEFORE Car because A3's Truck inherits from Car, so
// both isKindOf checks fire and "Truck" is the more specific category.
// ------------------------------------------------------------------------
private _classify = {
    params ["_v"];

    // Statics: finer dispatch by weapon role.
    if (_v isKindOf "StaticWeapon") exitWith {
        switch (true) do {
            case (_v isKindOf "StaticMortar")     : { "StaticMortar" };
            case (_v isKindOf "StaticATWeapon")   : { "StaticATWeapon" };
            case (_v isKindOf "StaticAAWeapon")   : { "StaticAAWeapon" };
            case (_v isKindOf "StaticGMGWeapon")  : { "StaticGMGWeapon" };
            case (_v isKindOf "StaticMGWeapon")   : { "StaticMGWeapon" };
            default                               { "StaticWeapon" };
        };
    };

    // Truck before Car (Truck inherits Car in A3 - more specific wins).
    if (_v isKindOf "Truck") exitWith { "Truck" };

    // Car: armored (wheeled APC / MRAP / LSV / armor>=200) vs regular
    // (Offroad / Hatchback / SUV / Quadbike). The kindOf checks catch
    // vanilla A3 naming; the armor>=200 fallback catches mod-specific
    // armored cars that don't derive from the A3 base classes.
    if (_v isKindOf "Car") exitWith {
        private _armor = getNumber (configFile >> "CfgVehicles" >> _v >> "armor");
        private _isArmored =
            (_v isKindOf "Wheeled_APC_F") ||
            {_v isKindOf "MRAP_01_base_F"} ||
            {_v isKindOf "MRAP_02_base_F"} ||
            {_v isKindOf "MRAP_03_base_F"} ||
            {_v isKindOf "LSV_01_base_F"} ||
            {_v isKindOf "LSV_02_base_F"} ||
            {_armor >= 200};
        if (_isArmored) then { "Car_Armored" } else { "Car" };
    };

    // Helicopter: dedicated attack vs transport/multirole. Vanilla A3
    // attack-heli bases are Heli_Attack_01_base_F (Blackfoot) and
    // Heli_Attack_02_base_F (Kajman). Mod attack helis (Apache / Mi-24 /
    // Ka-52 in RHS) often don't derive from those bases - the
    // transportSoldier <= 2 fallback catches the universal "attack helis
    // carry pilot+gunner only, transports carry 6+" pattern.
    if (_v isKindOf "Helicopter") exitWith {
        private _transport = getNumber (configFile >> "CfgVehicles" >> _v >> "transportSoldier");
        private _isAttack =
            (_v isKindOf "Heli_Attack_01_base_F") ||
            {_v isKindOf "Heli_Attack_02_base_F"} ||
            {_transport <= 2};
        if (_isAttack) then { "Helicopter_Attack" } else { "Helicopter" };
    };

    // Tank / Armored / Ship / Plane: defer to canonical convention.
    _v call ALiVE_fnc_vehicleGetKindOf
};

// ------------------------------------------------------------------------
// 1. Get (or build) the vehicle pool for _targetFaction.
//
// Cache lookup gotcha (same as substituteFactionUnit): SQF arrays drop
// literal `nil` elements at parse time, so `getOrDefault [_target, nil]`
// silently returns nil EVEN when the key exists. Using `in` against the
// hashmap key set sidesteps the nil-in-array trap.
// ------------------------------------------------------------------------
private _pool = if (_targetFaction in ALiVE_factionVehiclePoolCache) then {
    ALiVE_factionVehiclePoolCache get _targetFaction
};
if (isNil "_pool") then {
    _pool = createHashMap;

    // Enumerate every CfgVehicles non-Man scope>=2 entry belonging to
    // _targetFaction. Cache miss is the expensive path (configClasses
    // across CfgVehicles is ~3000+ entries on a heavily-modded loadout)
    // - we pay it once per faction per mission session.
    private _factionTagLower = toLower _targetFaction;
    private _vehicles = "true" configClasses (configFile >> "CfgVehicles");
    {
        private _vCfg = _x;
        private _vCN  = configName _vCfg;
        // Skip Man (handled by substituteFactionUnit) and scope=0/1
        // (base classes / hidden helpers that would error on createVehicle).
        if (
            (toLower (getText (_vCfg >> "faction"))) == _factionTagLower &&
            {!(_vCN isKindOf "Man")} &&
            {getNumber (_vCfg >> "scope") >= 2}
        ) then {
            private _kind = [_vCN] call _classify;
            // _classify returns "Vehicle" generic for entries that don't
            // match any kindOf - those are usually props / decoration /
            // weird mod helpers. Skip them to keep the pool clean.
            if (_kind != "Vehicle") then {
                private _bucket = _pool getOrDefault [_kind, []];
                _bucket pushBack _vCN;
                _pool set [_kind, _bucket];
            };
        };
    } forEach _vehicles;

    ALiVE_factionVehiclePoolCache set [_targetFaction, _pool];

    // Diagnostic - logged once per faction at first cache miss. Helps
    // verify what categories a mod faction actually populates and
    // whether vanilla-A3 fallbacks happen because the mod simply has
    // no vehicles of that kindOf.
    private _summary = [];
    {
        _summary pushBack format ["%1=%2", _x, count _y];
    } forEach _pool;
    [
        "ALiVE substituteFactionVehicle: built vehicle pool for '%1' (%2 buckets: %3)",
        _targetFaction, count _pool, _summary joinString ", "
    ] call ALiVE_fnc_dump;
};

// ------------------------------------------------------------------------
// 2. Classify the source vehicle's bucket.
// ------------------------------------------------------------------------
private _sourceKind = [_sourceVehicle] call _classify;
if (_sourceKind == "Vehicle") exitWith { _sourceVehicle };

// ------------------------------------------------------------------------
// 3. Resolve via fallback chain. NO cross-category fallback - sparse-pool
//    factions just keep their vanilla A3 source for missing categories.
// ------------------------------------------------------------------------
private _candidates = _pool getOrDefault [_sourceKind, []];
if (count _candidates == 0) exitWith {
    // Target faction has no vehicles of this kindOf - keep source
    // unchanged. Same outcome as Phase 3c.1 redirect-only behaviour.
    _sourceVehicle
};

private _result = selectRandom _candidates;

// Diagnostic - log the FIRST substitution per (faction, sourceKind)
// pair so we can verify in-RPT that the mod faction's vehicles are
// actually being returned. Subsequent substitutions for the same pair
// are silent to avoid log spam.
if (isNil "ALiVE_factionVehicleSubstitutionSeen") then {
    ALiVE_factionVehicleSubstitutionSeen = createHashMap;
};
private _seenKey = format ["%1::%2", _targetFaction, _sourceKind];
if !(_seenKey in ALiVE_factionVehicleSubstitutionSeen) then {
    ALiVE_factionVehicleSubstitutionSeen set [_seenKey, true];
    [
        "ALiVE substituteFactionVehicle: '%1' (%2) -> '%3' [faction=%4, pool=%5 candidates]",
        _sourceVehicle, _sourceKind, _result, _targetFaction, count _candidates
    ] call ALiVE_fnc_dump;
};

_result
