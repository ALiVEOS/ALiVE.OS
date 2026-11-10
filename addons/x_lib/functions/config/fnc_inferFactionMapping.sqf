#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(inferFactionMapping);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_inferFactionMapping

Description:
Builds an ALiVE_factionCustomMappings-shaped hashmap for a faction that
ships without proper CfgGroups support, by determining the dominant side
from its CfgVehicles units and producing a REDIRECT mapping to a vanilla
A3 faction on the same side.

This is Phase 3c.1 of the mil_placement overhaul - the foundational
"redirect-only" tier of inference. The faction becomes selectable in
ALiVE's faction dropdown and spawns units of the correct side. Phase
3c.2a + 3c.2b add spawn-time substitution (infantry, vehicles, and
statics) so the mod's actual units / vehicles appear instead of the
vanilla A3 redirect-target's. The Inferred flag this function sets
on each mapping is what those substitution hooks check to gate the
swap (curated mappings have no flag and are skipped).

Skips factions where inference is unnecessary or impossible:
  - already mapped via CustomFactions.hpp / sys_orbatcreator output /
    Cfg3rdPartyFactions registry (don't override explicit mappings)
  - already has proper CfgGroups entries on its expected side (the
    existing infrastructure already handles them)
  - no CfgVehicles Man-class units (can't determine dominant side)
  - non-standard CfgFactionClasses side value (logic / internal classes)

Parameters:
String - faction classname

Returns:
HashMap - mapping in same shape as CustomFactions.hpp produces.
nil     - if inference is unnecessary / impossible for this faction.

Examples:
(begin example)
_mapping = "rhs_faction_some_unmapped_thing" call ALiVE_fnc_inferFactionMapping;
if (!isNil "_mapping") then {
    [ALiVE_factionCustomMappings, "rhs_faction_some_unmapped_thing", _mapping] call ALiVE_fnc_hashSet;
};
(end)

See Also:
- ALiVE_fnc_inferFactionMappingsAll  (walks every loaded faction)

Author:
Jman
---------------------------------------------------------------------------- */

private _faction = _this;
if (typeName _faction != "STRING" || {_faction == ""}) exitWith { nil };

// SQF gotcha: `exitWith` only exits the NEAREST enclosing code block.
// Nesting `if (cond) exitWith { nil }` inside an outer `then { ... }`
// just exits the then-block - the function continues. The skip checks
// below have to be flat at function-body level (their exitWith returns
// from the function), or compute a flag and check it at function-body
// level. The CfgGroups check is the latter pattern because the test
// itself only applies to non-civilian sides.

// Skip 1: already explicitly mapped (CustomFactions.hpp / orbatcreator /
// Cfg3rdPartyFactions). Don't override curated data with inferred guesses.
private _alreadyMapped = false;
if (!isNil "ALiVE_factionCustomMappings") then {
    _alreadyMapped = _faction in (ALiVE_factionCustomMappings select 1);
};
if (_alreadyMapped) exitWith { nil };

// Skip 2: faction class itself doesn't exist or has invalid side
private _factionConfig = configFile >> "CfgFactionClasses" >> _faction;
if !(isClass _factionConfig) exitWith { nil };
private _side = getNumber (_factionConfig >> "side");
if !(_side in [0, 1, 2, 3]) exitWith { nil };

// Skip 3: faction already has proper CfgGroups for its side (no inference
// needed, existing infrastructure handles it). Skip the structural check
// for civilians; they don't use CfgGroups (spawn as individuals via
// createUnit). Compute as flag, then exit at function-body level.
private _hasProperCfgGroups = false;
if (_side != 3) then {
    private _sideCfgGroupsName = ["East", "West", "Indep"] select _side;
    private _existingGroups = configFile >> "CfgGroups" >> _sideCfgGroupsName >> _faction;
    _hasProperCfgGroups = isClass _existingGroups && {count _existingGroups > 0};
};
if (_hasProperCfgGroups) exitWith { nil };

// Skip 4: faction IS one of the vanilla A3 base factions used as redirect
// TARGETS. Those should never be redirect SOURCES (a self-redirect mapping
// is meaningless - the spawn already produces the right faction's units).
// Skip 3 catches OPF_F/BLU_F/IND_F via their CfgGroups, but CIV_F has no
// CfgGroups and is exempt from Skip 3, so it would otherwise leak through
// and self-redirect. Explicit list keeps the intent obvious.
private _vanillaTargets = ["OPF_F", "BLU_F", "IND_F", "CIV_F"];
if (_faction in _vanillaTargets) exitWith { nil };

// Probe: faction must have at least one CfgVehicles Man-class unit.
// Without that we can't establish that the faction is meant for unit
// spawning at all (e.g. mod might define a faction class for static-
// object decoration, no actual units).
// Read from the set ALiVE_fnc_inferFactionMappingsAll builds in one pass when it is there. Walking every vehicle
// class once per faction took 4.5 minutes of startup on a large mod set (393 factions, 79,525 classes).
private _factionTagLower = toLower _faction;
private _hasManUnit = if (isNil "ALiVE_inferManFactions") then {
    (("true" configClasses (configFile >> "CfgVehicles")) findIf {
        (toLower (getText (_x >> "faction"))) == _factionTagLower &&
        {(configName _x) isKindOf "Man"}
    }) >= 0
} else {
    _factionTagLower in ALiVE_inferManFactions
};
if (!_hasManUnit) exitWith { nil };

// Build the redirect mapping. Side and GroupSideName use the all-caps
// convention from CustomFactions.hpp ("EAST" / "WEST" / "INDEP" / "CIV").
// Note INDEP not GUER - configGetFactionGroups normalizes both but
// CustomFactions.hpp uses INDEP-style.
private _sideText = ["EAST", "WEST", "INDEP", "CIV"] select _side;
private _redirectTarget = ["OPF_F", "BLU_F", "IND_F", "CIV_F"] select _side;

private _mapping = [] call ALiVE_fnc_hashCreate;
[_mapping, "Side", _sideText] call ALiVE_fnc_hashSet;
[_mapping, "GroupSideName", _sideText] call ALiVE_fnc_hashSet;
[_mapping, "FactionName", _faction] call ALiVE_fnc_hashSet;
[_mapping, "GroupFactionName", _redirectTarget] call ALiVE_fnc_hashSet;

// Phase 3c.2 marker: inferred (vs curated) mappings get unit/vehicle/
// static substitution at spawn time so the mod's actual classes appear
// instead of the redirect target's vanilla A3 ones. Curated mappings
// (CustomFactions.hpp / sys_orbatcreator output) deliberately use the
// redirect target's specific groups and don't want substitution applied.
// The Inferred flag is what the substitution hooks
// (substituteFactionUnit / substituteFactionVehicle consumers in
// sys_profile) check to gate the swap.
[_mapping, "Inferred", true] call ALiVE_fnc_hashSet;

// Empty GroupFactionTypes + Groups - the consumers (fnc_configGetRandomGroup
// in particular) fall through to the redirect target's CfgGroups when
// these are empty. The redirect-target's vanilla groups drive the spawn;
// Phase 3c.2 substitution swaps the resulting individual units / vehicles
// to the mod faction's equivalents. This is simpler and more robust than
// synthesizing Groups arrays from the mod's CfgVehicles (which was the
// original Tier 2 ambition but isn't needed given the substitution
// approach).
private _typeMappings = [] call ALiVE_fnc_hashCreate;
[_mapping, "GroupFactionTypes", _typeMappings] call ALiVE_fnc_hashSet;

private _emptyGroups = [] call ALiVE_fnc_hashCreate;
[_mapping, "Groups", _emptyGroups] call ALiVE_fnc_hashSet;

_mapping
