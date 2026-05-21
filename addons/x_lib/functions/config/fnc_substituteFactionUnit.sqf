#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(substituteFactionUnit);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_substituteFactionUnit

Description:
Phase 3c.2 of the mil_placement overhaul. Given a vanilla A3 unit class
(produced by spawning through an inferred-faction redirect) and the
original mod faction the user actually selected, return a role-equivalent
unit from the mod faction so the spawned units look like the mod's units
instead of vanilla A3.

Caller flow (sys_profile/createProfilesFromGroupConfig):
  1. Mission-maker selected mod faction X (no CfgGroups).
  2. Phase 3c.1 inference produced a redirect: X -> OPF_F (or BLU_F /
     IND_F depending on dominant side).
  3. createProfilesFromGroupConfig follows the redirect, looks up
     OPF_F's CfgGroups, gets vanilla unit classes like "O_Soldier_AT_F".
  4. Before pushing each vanilla unit into the spawn list, the caller
     calls THIS function with [vanillaUnit, X]. We classify the vanilla
     unit's role, then return a same-role unit from X's CfgVehicles pool.

Per-faction role pools are cached in ALiVE_factionRolePoolCache. First
call for a faction enumerates its CfgVehicles Man units, classifies each
via ALiVE_fnc_inferUnitRole, buckets by role. Subsequent calls just
look up the cached pool. Caching matters: a typical mil_placement spawn
substitutes hundreds of units per mission, and CfgVehicles enumeration +
weapons walking is the expensive part.

Fallback chain (per substitution):
  1. Target faction has units of the requested role     -> random pick
  2. Target faction has Riflemen but not requested role -> random Rifleman
  3. Target faction has no usable Man units             -> source unchanged

The third case shouldn't normally happen (inference itself requires at
least one Man unit) but the guard keeps the function total: every input
returns a spawnable classname.

Parameters:
Array - [_sourceUnit, _targetFaction]
    _sourceUnit    : STRING - vanilla A3 unit classname produced by the
                              inferred redirect (e.g. "O_Soldier_AT_F").
    _targetFaction : STRING - the mod faction classname the mission-maker
                              originally selected (e.g. "rhs_faction_vdv").

Returns:
STRING - substituted unit classname from _targetFaction, or _sourceUnit
         unchanged if substitution is impossible.

Examples:
(begin example)
_sub = ["O_Soldier_AT_F", "rhs_faction_vdv"] call ALiVE_fnc_substituteFactionUnit;
// -> e.g. "rhs_msv_emr_at"
(end)

See Also:
- ALiVE_fnc_inferUnitRole          (classifier used by both source and pool)
- ALiVE_fnc_inferFactionMapping    (Phase 3c.1 redirect that triggers this)
- ALIVE_fnc_createProfilesFromGroupConfig  (consumer)

Author:
Jman
---------------------------------------------------------------------------- */

params [
    ["_sourceUnit",    "", [""]],
    ["_targetFaction", "", [""]]
];

if (_sourceUnit == "" || _targetFaction == "") exitWith { _sourceUnit };

// Lazy-init the global pool cache. HashMap-of-hashmaps keyed by faction
// classname. Inner hashmap: role -> array of unit classnames in that role.
if (isNil "ALiVE_factionRolePoolCache") then {
    ALiVE_factionRolePoolCache = createHashMap;
};

// ------------------------------------------------------------------------
// 1. Get (or build) the role pool for _targetFaction.
//
// Cache lookup gotcha: SQF arrays drop literal `nil` elements at parse
// time, so `getOrDefault [_target, nil]` becomes `getOrDefault [_target]`
// (one-arg form), which silently returns nil EVEN when the key exists -
// the cache never hits and we rebuild the pool every call. Using `in`
// against the hashmap key set sidesteps the nil-in-array trap.
// ------------------------------------------------------------------------
private _pool = if (_targetFaction in ALiVE_factionRolePoolCache) then {
    ALiVE_factionRolePoolCache get _targetFaction
};
if (isNil "_pool") then {
    _pool = createHashMap;

    // Enumerate every CfgVehicles Man-class unit belonging to _targetFaction.
    // Cache miss is the expensive path - configClasses across CfgVehicles is
    // ~3000+ entries on a heavily-modded loadout. We pay it once per faction
    // per mission session.
    private _factionTagLower = toLower _targetFaction;
    private _vehicles = "true" configClasses (configFile >> "CfgVehicles");
    {
        private _vCfg = _x;
        private _vCN  = configName _vCfg;
        if (
            (toLower (getText (_vCfg >> "faction"))) == _factionTagLower &&
            {_vCN isKindOf "Man"}
        ) then {
            // Skip non-spawnable scope=0/1 entries - those are base classes
            // / hidden helpers that would error on createUnit.
            private _scope = getNumber (_vCfg >> "scope");
            if (_scope >= 2) then {
                private _role = _vCN call ALiVE_fnc_inferUnitRole;
                if (_role != "") then {
                    private _bucket = _pool getOrDefault [_role, []];
                    _bucket pushBack _vCN;
                    _pool set [_role, _bucket];
                };
            };
        };
    } forEach _vehicles;

    ALiVE_factionRolePoolCache set [_targetFaction, _pool];

    // Diagnostic - logged once per faction at first cache miss. Helps
    // verify which roles a mod faction actually populates and whether
    // odd substitutions stem from a sparse pool (e.g. faction with only
    // Riflemen and no AT will get all-Rifleman substitutions for AT
    // requests).
    private _summary = [];
    {
        _summary pushBack format ["%1=%2", _x, count _y];
    } forEach _pool;
    [
        "ALiVE substituteFactionUnit: built role pool for '%1' (%2 roles: %3)",
        _targetFaction, count _pool, _summary joinString ", "
    ] call ALiVE_fnc_dump;
};

// ------------------------------------------------------------------------
// 2. Classify the source unit's role.
//    Use the same inferUnitRole heuristic on the vanilla A3 unit so source
//    and pool buckets agree. ("" return means class missing or not Man -
//    fall straight back to source unchanged.)
// ------------------------------------------------------------------------
private _sourceRole = _sourceUnit call ALiVE_fnc_inferUnitRole;
if (_sourceRole == "") exitWith { _sourceUnit };

// ------------------------------------------------------------------------
// 3. Resolve via fallback chain.
// ------------------------------------------------------------------------
private _candidates = _pool getOrDefault [_sourceRole, []];
if (count _candidates == 0) then {
    // No exact-role match; fall back to Rifleman pool.
    _candidates = _pool getOrDefault ["Rifleman", []];
};
if (count _candidates == 0) exitWith {
    // Faction has no usable Man units at all - return source unchanged
    // so the spawn still works (vanilla A3 unit appears, same as 3c.1).
    _sourceUnit
};

private _result = selectRandom _candidates;

// Diagnostic - log the FIRST substitution per (faction, sourceRole) pair
// so we can verify in-RPT that the mod faction's units are actually
// being returned. Subsequent substitutions for the same pair are silent
// to avoid log spam (a typical mission produces hundreds of subs).
if (isNil "ALiVE_factionSubstitutionSeen") then {
    ALiVE_factionSubstitutionSeen = createHashMap;
};
private _seenKey = format ["%1::%2", _targetFaction, _sourceRole];
if !(_seenKey in ALiVE_factionSubstitutionSeen) then {
    ALiVE_factionSubstitutionSeen set [_seenKey, true];
    [
        "ALiVE substituteFactionUnit: '%1' (%2) -> '%3' [faction=%4, pool=%5 candidates]",
        _sourceUnit, _sourceRole, _result, _targetFaction, count _candidates
    ] call ALiVE_fnc_dump;
};

_result
