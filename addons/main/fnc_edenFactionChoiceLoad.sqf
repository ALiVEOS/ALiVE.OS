#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenFactionChoiceLoad);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenFactionChoiceLoad

Description:
Eden-attribute `attributeLoad` handler for the ALiVE_FactionChoice control
family. Populates the Combo with factions from CfgFactionClasses
(missionConfig + main config), grouped by side, filtered to the per-control
side allowlist passed in via the call argument.

Three control variants share this one handler:
    ALiVE_FactionChoice           sides [0,1,2,3]  (all)
    ALiVE_FactionChoice_Military  sides [0,1,2]    (no civilians)
    ALiVE_FactionChoice_Civilian  sides [3]        (civilians only)

Each variant's Cfg3DEN attributeLoad expression looks like:
    [_this, [<allowed side ints>]] call compile preprocessFileLineNumbers '...'

Side allowlist filtering happens at TWO points:
  - Enumeration: factions whose side isn't in the allowlist are skipped
    entirely (not just hidden). Keeps populated counts accurate.
  - Bucket population: only iterate buckets whose side is in the allowlist.

Defensive enumeration:
  - Missing displayName falls back to classname
  - Missing/invalid side dropped (was "Other" bucket pre-Phase 1)
  - Empty CfgFactionClasses entries skipped silently
  - Duplicate classnames across missionConfig + configFile deduped

Case-insensitive matching when restoring the selected value (closes #651).

(unrecognised) entries land at TOP of the dropdown.

Cfg3rdPartyFactions registry consulted for per-faction overrides
(displayName cleanup, exclusion).

Lives in its own .sqf file because Arma's config preprocessor struggles
with multi-line `"..."` strings containing backslash-newline continuations
on Windows CRLF files (same rationale as mil_ied's edenIntegrationChoice
handlers).

The variable name on the logic and the Eden value slot is configurable
via the third element of _this. Defaults to "faction" because that
is the property name used by the majority of single-select faction
attributes (mil_placement, civ_placement, mil_ato, sys_quickstart
etc.). Modules whose faction attribute is named something else
(e.g. `ambientVehicleFaction` in amb_civ_placement, `ambientCrowdFaction`
in amb_civ_population) reach this handler through a variant control
class (e.g. ALiVE_FactionChoice_Civilian_AmbientVehicleFaction in
addons/main/CfgVehicles.hpp) that itself defines attributeLoad with
the right _varName argument. Per-attribute attributeLoad overrides
on the `class X { control = "Y"; }` shape are silently ignored by
Eden, so the variant control class is the only honoured hook.

Parameters:
    [_display, _allowedSides, _varName]
    _display      : DISPLAY - Eden attribute display. Combo control IDC 100.
    _allowedSides : ARRAY of NUMBERs - sides to include in the dropdown.
                    Defaults to [0,1,2,3] (all) if missing/invalid.
    _varName      : STRING - name of the logic variable storing the value.
                    Defaults to "faction".

Author:
Jman
---------------------------------------------------------------------------- */

// Unpack invocation. New-style call from the variant control classes is
//   [_display, _allowedSides, _varName] call compile preprocessFileLineNumbers '...'
// Legacy direct call is just _this = display (older Cfg3DEN attributeLoad
// shape, kept compatible so anyone overriding outside of our control
// classes still works).
private _display = controlNull;
private _allowedSides = [0,1,2,3];
private _varName = "faction";
if (typeName _this == "ARRAY") then {
    _display = _this select 0;
    if (count _this > 1 && {typeName (_this select 1) == "ARRAY"}) then {
        _allowedSides = _this select 1;
    };
    if (count _this > 2 && {typeName (_this select 2) == "STRING"} && {(_this select 2) != ""}) then {
        _varName = _this select 2;
    };
} else {
    _display = _this;
};

// ------------------------------------------------------------------------
// 1. Resolve the currently-stored faction string.
//    Priority: logic variable > Eden attribute value slot > side-aware default.
//
//    Default is side-aware so the Civilian variant doesn't fall back to a
//    military faction classname (OPF_F). For civilian-only controls the
//    default is CIV_F (vanilla A3 civilians); for military / all-sides
//    variants it stays OPF_F. Without this, civilian modules whose
//    defaultValue is empty render "(unrecognised) OPF_F" at the top of
//    the dropdown on first open.
// ------------------------------------------------------------------------
private _selected = get3DENSelected "logic";
private _storedFromLogic = if (count _selected > 0) then {
    (_selected select 0) getVariable [_varName, nil]
} else {
    nil
};
private _edenValue = _display getVariable "value";

private _value = if (_allowedSides isEqualTo [3]) then { "CIV_F" } else { "OPF_F" };
if (!isNil "_edenValue" && {typeName _edenValue == "STRING"} && {_edenValue != ""}) then {
    _value = _edenValue;
};
if (!isNil "_storedFromLogic" && {typeName _storedFromLogic == "STRING"} && {_storedFromLogic != ""}) then {
    _value = _storedFromLogic;  // logic variable wins - re-opening the panel picks up the just-saved value
};

// Defensive: strip surrounding single quotes from the stored value. Legacy
// missions saved with an earlier version of the Combo defaultValue format
// (`"""'OPF_F'"""`) accidentally wrote a 7-char quoted string `'OPF_F'`
// instead of the intended 5-char `OPF_F`, because the config-level triple-
// quote + inner-single-quote combination evaluated to an SQF literal that
// kept the apostrophes. Stripping them here heals those missions on next
// save (the Save handler returns clean lbData).
private _len = count _value;
if (
    _len >= 2 &&
    {(_value select [0, 1]) == "'"} &&
    {(_value select [_len - 1, 1]) == "'"}
) then {
    _value = _value select [1, _len - 2];
};

// ------------------------------------------------------------------------
// 2. Locate the Combo control inside the attribute display.
//    BI Combo template exposes its combo at IDC 100.
// ------------------------------------------------------------------------
private _ctrl = _display controlsGroupCtrl 100;
if (isNull _ctrl) exitWith {
    diag_log "ALIVE FactionChoice LOAD: combo control (IDC 100) not found";
};

lbClear _ctrl;

// ------------------------------------------------------------------------
// 3. Enumerate factions defensively.
//
//    Two filters:
//    (a) STRICT SIDE FILTER: only include factions with side 0/1/2/3
//        (OPFOR / BLUFOR / INDFOR / CIVILIAN). Drops BI internals like
//        "Default", "Alive", "Buildings" which use side 7 for logic /
//        non-combat purposes.
//    (b) STRUCTURAL USABILITY FILTER: only include factions that actually
//        have CfgGroups entries for their side. mil_placement /
//        civ_placement spawn UNIT GROUPS, so a faction with no CfgGroups
//        coverage can't be used by these modules. This auto-excludes BI
//        internals like "Virtual" (VR training), "Civilian Other
//        (Interactive)" (Argo-era interactive content), mod dummy-faction
//        stubs, etc. - without needing a maintained blacklist.
//
//    Design choice: structural filter beats hardcoded blacklist because it
//    stays correct as new mods and BI updates introduce new internal
//    factions. If a mod later registers a faction WITH CfgGroups that
//    shouldn't appear, Phase 2's Cfg3rdPartyFactions registry will
//    provide a config-driven exclusion hook.
// ------------------------------------------------------------------------

// Side index -> CfgGroups top-level class name. Side 0/1/2/3 only; the
// bad-side filter below handles everything else.
private _sideCfgGroupsName = ["East", "West", "Indep", "Civilian"];

// Civilian-only blacklist. Civilians are exempt from the CfgGroups
// structural filter (they spawn as individuals, not groups), so we need
// a targeted list for internal / non-real civilian-side factions that
// have CfgVehicles units but aren't meaningful mission-maker choices.
// Extend as new edge cases surface. Phase 2's Cfg3rdPartyFactions
// registry will turn this into a config-driven exclusion hook.
// Entries MUST be lowercase classnames for the toLower comparison below.
// (Caveat: BI's CfgFactionClasses uses _F suffix on most internal
// civilian classes - blacklist by classname, not displayName.)
private _civilianBlacklist = [
    "virtual_f",      // BI VR / Virtual Arsenal training faction (displayName "Virtual")
    "interactive_f"   // BI Argo-era interactive content (displayName "Other (Interactive)")
];

// ------------------------------------------------------------------------
// Build registry overrides map from Cfg3rdPartyFactions. Walks each
// registry subclass whose cfgPatchesName is loaded, collects any per-
// faction overrides (displayName / sourceLabel / excluded) into a
// hashmap keyed by lowercase faction classname. Empty/no-overrides
// registry is fine - the auto-detection paths below run unmodified.
// ------------------------------------------------------------------------
private _registryOverrides = createHashMap;
private _registry = configFile >> "Cfg3rdPartyFactions";
if (isClass _registry) then {
    for "_i" from 0 to (count _registry - 1) do {
        private _entry = _registry select _i;
        if (isClass _entry) then {
            private _cp = getText (_entry >> "cfgPatchesName");
            if (_cp != "" && {isClass (configFile >> "CfgPatches" >> _cp)}) then {
                private _factionsClass = _entry >> "factions";
                if (isClass _factionsClass) then {
                    for "_j" from 0 to (count _factionsClass - 1) do {
                        private _facOverride = _factionsClass select _j;
                        if (isClass _facOverride) then {
                            private _facCN = configName _facOverride;
                            private _override = createHashMap;
                            if (isText (_facOverride >> "displayName")) then {
                                _override set ["displayName", getText (_facOverride >> "displayName")];
                            };
                            if (isNumber (_facOverride >> "excluded")) then {
                                _override set ["excluded", getNumber (_facOverride >> "excluded") > 0];
                            };
                            _registryOverrides set [toLower _facCN, _override];
                        };
                    };
                };
            };
        };
    };
};

private _seen = createHashMap; // lowercase classname -> true, for dedup
private _entries = [];
private _totalScanned = 0;
private _droppedBadSide = 0;
private _droppedSideFiltered = 0;
private _droppedNoGroups = 0;
private _droppedRegistryExcluded = 0;

private _configPaths = [
    missionConfigFile >> "CfgFactionClasses",
    configFile >> "CfgFactionClasses"
];
{
    private _root = _x;
    for "_i" from 0 to (count _root - 1) do {
        private _fac = _root select _i;
        if (isClass _fac) then {
            _totalScanned = _totalScanned + 1;
            private _cn = configName _fac;
            private _cnLower = toLower _cn;
            if !(_cnLower in _seen) then {
                _seen set [_cnLower, true];
                // getNumber follows inheritance and returns 0 for missing,
                // so use it directly then validate the result is a real side.
                private _side = getNumber (_fac >> "side");
                // isNumber check distinguishes "explicitly 0" from "missing".
                // If side property is entirely absent (not even inherited),
                // treat as -1 so the validation below drops the entry.
                if !(isNumber (_fac >> "side")) then { _side = -1 };

                if !(_side in [0, 1, 2, 3]) then {
                    _droppedBadSide = _droppedBadSide + 1;
                } else {
                    // SQF doesn't support `else if` - after `else` the parser
                    // expects a {...} code block, not another `if`. Nested if
                    // here as the workaround.
                    if !(_side in _allowedSides) then {
                        // Per-control side allowlist filter: civilian modules
                        // shouldn't see military factions and vice versa.
                        _droppedSideFiltered = _droppedSideFiltered + 1;
                    } else {
                    // Structural usability filter:
                    //   Military sides (0/1/2) spawn via CfgGroups entries
                    //   (squads / platoons / companies). A military faction
                    //   with no CfgGroups is unusable by mil_placement.
                    //   Civilian side (3) spawns INDIVIDUAL units via
                    //   findVehicleType "Man" + createUnit. Vanilla A3's
                    //   CfgGroups >> Civilian >> CIV_F is empty (no defined
                    //   squads), but CIV_F is the primary faction for every
                    //   civilian placement mission. Exempt civilians from
                    //   the CfgGroups check.
                    private _usable = if (_side == 3) then {
                        // Civilian: always include UNLESS blacklisted as a
                        // known internal / non-real civilian-side faction
                        // (see _civilianBlacklist above).
                        !((toLower _cn) in _civilianBlacklist)
                    } else {
                        // Military side. Two paths to "usable":
                        // (a) faction has proper CfgGroups for its side -
                        //     existing infrastructure handles spawning
                        // (b) faction has CfgVehicles Man-class units, even
                        //     without CfgGroups - Phase 3c.1 inference
                        //     registers a redirect-only mapping at runtime
                        //     (see ALiVE_fnc_inferFactionMappingsAll), so
                        //     the faction IS spawnable by mission start.
                        //     Spawned units are vanilla A3 of the right
                        //     side until Phase 3c.2 lands unit
                        //     substitution.
                        private _sideName = _sideCfgGroupsName select _side;
                        private _groupsEntry = configFile >> "CfgGroups" >> _sideName >> _cn;
                        if (isClass _groupsEntry && {count _groupsEntry > 0}) then {
                            true
                        } else {
                            // Inferability check: does the faction have any
                            // CfgVehicles Man-class units? If yes, runtime
                            // inference will produce a redirect mapping.
                            private _vehicles = "true" configClasses (configFile >> "CfgVehicles");
                            private _factionTagLower = toLower _cn;
                            (_vehicles findIf {
                                (toLower (getText (_x >> "faction"))) == _factionTagLower &&
                                {(configName _x) isKindOf "Man"}
                            }) >= 0
                        };
                    };
                    if (_usable) then {
                        // Consult Cfg3rdPartyFactions registry for per-
                        // faction overrides (excluded / displayName).
                        // Empty hashmap if no override.
                        private _override = _registryOverrides getOrDefault [_cnLower, createHashMap];

                        if (_override getOrDefault ["excluded", false]) then {
                            _droppedRegistryExcluded = _droppedRegistryExcluded + 1;
                        } else {
                            // displayName: registry override > config > classname
                            private _dn = _override getOrDefault ["displayName", ""];
                            if (_dn isEqualTo "") then {
                                _dn = getText (_fac >> "displayName");
                                if (_dn isEqualTo "") then { _dn = _cn };
                            };
                            _entries pushBack [_cn, _dn, _side];
                        };
                    } else {
                        _droppedNoGroups = _droppedNoGroups + 1;
                    };
                    }; // close inner else (side-allowlist filter wrap from `} else { if !(_side in _allowedSides) ...`)
                };
            };
        };
    };
} forEach _configPaths;

// ------------------------------------------------------------------------
// 4. Pre-check stored value against the in-memory entries list.
//    If the stored value doesn't match any entry, the "(unrecognised)
//    <value>" placeholder is added FIRST so it sits at the TOP of the
//    dropdown. Better UX than tucking unknown values at the end of a
//    long alphabetical list - mission-makers immediately see that their
//    stored faction isn't in the current loadout.
// ------------------------------------------------------------------------
private _valueLower = toLower _value;
private _hasMatch = (_entries findIf {
    _x params ["_cn"];
    (toLower _cn) == _valueLower
}) >= 0;

private _foundIdx = -1;

if (!_hasMatch && _value != "") then {
    private _idx = _ctrl lbAdd format ["(unrecognised) %1", _value];
    _ctrl lbSetData [_idx, _value];
    _foundIdx = _idx;  // top entry is the unrecognised one
};

// ------------------------------------------------------------------------
// 5. Populate combo grouped by side.
//    Order: OPFOR, BLUFOR, INDFOR, CIVILIAN. Within each bucket, entries
//    sorted alphabetically by classname for deterministic ordering.
// ------------------------------------------------------------------------
private _sideBuckets = [
    [0, "OPFOR"],
    [1, "BLUFOR"],
    [2, "INDFOR"],
    [3, "CIVILIAN"]
];

{
    _x params ["_sideValue", "_sideLabel"];
    // Skip the entire bucket if its side isn't in this control's allowlist
    // (e.g. _Civilian variant skips OPFOR/BLUFOR/INDFOR buckets entirely
    // - their entries already got filtered out at enumeration too, but
    // skipping the bucket loop avoids any wasted lbAdd calls).
    if !(_sideValue in _allowedSides) then { continue };
    private _bucketEntries = _entries select {
        _x params ["", "", "_s"];
        _s == _sideValue
    };
    _bucketEntries sort true; // by classname ascending

    {
        _x params ["_cn", "_dn"];
        // Suffix the label with the faction classname - this is what
        // ALiVE uses internally as the faction identifier (referenced by
        // mission scripts, _additional class lists, mil/civ_placement
        // runtime, OPCOM, etc.). Mission-makers reading the dropdown can
        // immediately see the canonical token without separately looking
        // it up. When displayName already IS the classname (no override,
        // empty CfgFactionClasses displayName), don't duplicate it.
        private _label = if (_dn == _cn) then {
            format ["%1 - %2", _sideLabel, _dn]
        } else {
            format ["%1 - %2 (%3)", _sideLabel, _dn, _cn]
        };
        private _idx = _ctrl lbAdd _label;
        _ctrl lbSetData [_idx, _cn];
        // If this is the matching entry, remember the index for selection.
        if (_foundIdx == -1 && (toLower _cn) == _valueLower) then {
            _foundIdx = _idx;
        };
    } forEach _bucketEntries;
} forEach _sideBuckets;

if (_foundIdx < 0) then { _foundIdx = 0 }; // defensive: empty list somehow
_ctrl lbSetCurSel _foundIdx;

// ------------------------------------------------------------------------
// Diagnostic logging: helps debug cases where a user expected a faction
// to appear in the dropdown but didn't see it. RPT output includes:
//  - total CfgFactionClasses entries scanned (mission + base config)
//  - how many were dropped by the strict side filter (side != 0/1/2/3)
//  - count of entries populated into the combo
//  - the stored value being matched against
//  - match outcome (index + resolved lbData, or "(added as unrecognised)")
// ------------------------------------------------------------------------
diag_log format [
    "ALIVE FactionChoice LOAD: allowedSides=%1 scanned=%2 dropped(bad side)=%3 dropped(side filter)=%4 dropped(no CfgGroups)=%5 dropped(registry excluded)=%6 populated=%7 stored='%8' selected=%9 (lbData='%10')",
    _allowedSides,
    _totalScanned,
    _droppedBadSide,
    _droppedSideFiltered,
    _droppedNoGroups,
    _droppedRegistryExcluded,
    count _entries,
    _value,
    _foundIdx,
    if (_foundIdx >= 0 && _foundIdx < lbSize _ctrl) then { _ctrl lbData _foundIdx } else { "(none)" }
];
