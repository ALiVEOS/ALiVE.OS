#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(inferFactionMappingsAll);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_inferFactionMappingsAll

Description:
Walks every CfgFactionClasses entry and runs ALiVE_fnc_inferFactionMapping
on it. For each faction where inference produces a mapping, registers the
mapping into ALiVE_factionCustomMappings.

Called from addons/main/static/staticData.sqf right after CustomFactions.hpp
has loaded its hand-curated mappings. The order matters:
  1. CustomFactions.hpp populates ALiVE_factionCustomMappings with curated
     entries (RHS USAF/USMC/AFRF/GREF/SAF and the BLU_G_F example).
  2. inferFactionMappingsAll fills the gaps - any loaded faction NOT in
     the curated set AND lacking proper CfgGroups gets an inferred
     redirect-only mapping (Phase 3c.1).
  3. Module init proceeds with a complete mapping coverage.

Phase 3c.1 inference is redirect-only: the mapping itself just routes
the faction's groups to the vanilla A3 redirect target. Phase 3c.2
(2a infantry, 2b vehicles + statics) hooks the spawn pipeline to
substitute the resulting vanilla classes for mod-faction equivalents,
so the mod's actual units / vehicles appear in-game.

Parameters:
None

Returns:
SCALAR - number of newly-registered inferred mappings

Examples:
(begin example)
_inferred = call ALiVE_fnc_inferFactionMappingsAll;
["ALiVE inferred %1 faction mappings", _inferred] call ALiVE_fnc_dump;
(end)

See Also:
- ALiVE_fnc_inferFactionMapping  (singular per-faction inference)
- addons/main/static/CustomFactions.hpp  (manually-curated mappings, run first)

Author:
Jman
---------------------------------------------------------------------------- */

if (isNil "ALiVE_factionCustomMappings") then {
    // Defensive: if staticData hasn't initialized the mappings hashmap yet,
    // do it here so we have somewhere to write.
    ALiVE_factionCustomMappings = [] call ALiVE_fnc_hashCreate;
};

private _inferredCount = 0;
private _skippedAlreadyMapped = 0;
private _skippedNoUnits = 0;
private _factions = "true" configClasses (configFile >> "CfgFactionClasses");

{
    private _faction = configName _x;
    if (_faction in (ALiVE_factionCustomMappings select 1)) then {
        _skippedAlreadyMapped = _skippedAlreadyMapped + 1;
    } else {
        private _mapping = _faction call ALiVE_fnc_inferFactionMapping;
        if (isNil "_mapping") then {
            _skippedNoUnits = _skippedNoUnits + 1;
        } else {
            [ALiVE_factionCustomMappings, _faction, _mapping] call ALiVE_fnc_hashSet;
            _inferredCount = _inferredCount + 1;
        };
    };
} forEach _factions;

[
    "ALiVE faction inference (Phase 3c.1 redirect-only): scanned=%1 already_mapped=%2 inferred=%3 skipped(no_units / vanilla / bad_side)=%4",
    count _factions,
    _skippedAlreadyMapped,
    _inferredCount,
    _skippedNoUnits
] call ALiVE_fnc_dump;

_inferredCount
