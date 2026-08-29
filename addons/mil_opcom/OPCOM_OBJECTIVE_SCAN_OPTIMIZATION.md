# OPCOM Objective Scan Optimization

## Purpose

This document records the objective-collection scans in `mil_opcom`, ranks them by likely runtime frequency, and identifies which can be reduced using the native `objectivesByID` and `profileObjectiveAssignment` hashmaps.

The focus is conventional OPCOM (`occupation` and `invasion`). Insurgency-specific code is intentionally out of scope.

## Scope and terminology

The inventory treats these as full passes:

- `forEach` over an objective collection.
- `select {}` or `apply {}` over an objective collection.
- Code-block `count` predicates, which evaluate every element.
- `ALiVE_fnc_SortBy` calls that receive an objective collection.

The inventory does not treat `findIf` as an unconditional full pass, but records it separately because it can traverse the entire collection when no match is found.

Excluded from this audit:

- `insurgency.fsm`.
- `fnc_INS_*.sqf`.
- Asymmetric installation-maintenance paths such as `createAsymmetricInstallation`, `seedAsymmetricInstallations`, and `OPCOMAsymmetricState`.
- Per-objective section, pending-order, profile, and installation loops that do not scan the objective collection itself.

Frequency estimates assume debug is disabled, `MONITOR_FULL` is false, and the mission is using conventional OPCOM. Actual frequency depends on the number of OPCOM instances, task activity, assigned sections, and player interaction.

## Ranked scan inventory

The ordering below goes from likely highest production impact to lowest. Conditional and lifecycle-only scans are marked accordingly.

| Rank | Location | Operation / FSM node | Likely cadence and cost |
| ---: | --- | --- | --- |
| 1 | `opcom.fsm:352` | FSM node `ANALYZE` | Runs whenever OPCOM processes an analysis action or timeout. Buckets every objective by state and counts active objectives. |
| 2 | `fnc_OPCOM.sqf:3556` | `analyzeclusteroccupation` | Runs during startup and each OPCOM analysis cycle. Scans every objective and performs a nearby-profile query for each one. |
| 3 | `fnc_OPCOM.sqf:775` | `cleanupduplicatesections` | Runs once per analysis cycle. Inspects every objective and then each objective section. |
| 4 | `fnc_OPCOM.sqf:3810` | `setstatebyclusteroccupation` | Runs after occupation analysis. Fully processes each derived occupied-objective list, but not the complete objective store. |
| 5 | `tacom.fsm:709` and `tacom.fsm:732` | FSM node `ISSUE_ORDERS` | Fallback-only. Filters the complete objective list, then scans all idle objectives once per profile during recon regrouping. Potentially `profiles × idle objectives`. |
| 6 | `fnc_OPCOMgetHighestPrioObjective.sqf:57` | `ALIVE_fnc_OPCOMgetHighestPrioObjective` | Called on confirmed attacks. Exits on the first matching state, but reaches the end when no match exists. |
| 7 | `fnc_OPCOM.sqf:3344` and `fnc_OPCOM.sqf:3345` | `nearestObjectives` | Called by task, C2ISTAR, and player-order consumers. Filters all objectives, then sorts matching objectives by distance. |
| 8 | `fnc_OPCOM.sqf:2082` and `fnc_OPCOM.sqf:2085` | `findReinforcementBase` | Reinforcement-only. Scans all objectives to partition attack/defend and reserve candidates, then sorts the reserve subset. |
| 9 | `fnc_OPCOMcompositions.sqf:56` | `ALIVE_fnc_OPCOM` compositions query | External query path. Scans all objectives while filtering by state. |
| 10 | `fnc_OPCOM.sqf:3424` and `fnc_OPCOM.sqf:3434` | `joinObjectiveClient` | Player join UI path. Scans the supplied list to create markers, then sorts it by the player's map click. |
| 11 | `fnc_OPCOM.sqf:1527` | `resetProfileOrders` fallback | Only runs when `profileObjectiveAssignment` cannot resolve the profile. It exits on the first matching objective, but can scan the whole store for stale or legacy data. |
| 12 | `fnc_OPCOM.sqf:1647`, `1665`, `1680`, and `1778` | `sortObjectives` | Startup and control-type changes. Performs validation, sorting, and deleted-objective filtering. |
| 13 | `fnc_OPCOM.sqf:1587` and `fnc_OPCOM.sqf:1616` | `rebuildObjectiveIndexes` | Two complete passes used to rebuild `objectivesByID` and `profileObjectiveAssignment`. Necessary index-maintenance work. |
| 14 | `fnc_OPCOM.sqf:3239` and `fnc_OPCOM.sqf:3280` | `createObjectives` | Two passes over the input collection while converting source objectives into OPCOM objective hashes. |
| 15 | `fnc_OPCOM.sqf:705` | `getModuleObjectives` | Initialization-only pass over each placement module's objective list to stamp `objectiveType`. |
| 16 | `fnc_OPCOM.sqf:2789`, `2798`, and `2841` | `saveData` | Autosave/exit lifecycle. Collects, logs, and exports persistent objectives. Line 2798 is an unconditional pass whose body only performs work when debug is enabled. |
| 17 | `fnc_OPCOM.sqf:3021`, `3050`, and `3089` | `loadObjectivesDB` | Load lifecycle. Scans DB records, rebuilds hashes, and resets or initializes every loaded objective. |
| 18 | `fnc_OPCOM.sqf:3290` and `3328` | `createObjectiveDebugMarkers` | Debug-only marker generation. Builds a full objective-ID list and then iterates the marker input list. |
| 19 | `fnc_OPCOM.sqf:4072` | `changeControlType` | User-triggered lifecycle operation. Removes every existing objective before rebuilding the new control-type state. |
| Conditional | `fnc_OPCOM.sqf:3984` | `OPCOM_monitor` | If `MONITOR_FULL` is enabled, scans all objectives every second. This becomes the highest-frequency scan, but is monitor/debug-only. |

## Worst-case searches that are not unconditional full passes

These use early-exit lookup logic, but can still walk the entire objective array:

- `fnc_OPCOMgetHighestPrioObjective.sqf:57` — no matching state.
- `fnc_OPCOM.sqf:1527` — assignment-map miss during `resetProfileOrders` fallback.
- `fnc_OPCOM.sqf:1987` — `removeObjective` locating the object reference in the ordered array.
- `fnc_OPCOM.sqf:2044` — `reorderObjective` locating the object reference in the ordered array.
- `fnc_OPCOM.sqf:3829` — `selectordersbystate` finding the first eligible objective.

## Existing lookup structures

`mil_opcom` now maintains two native hashmaps:

- `objectivesByID`: `objectiveID -> objective hash`.
- `profileObjectiveAssignment`: `profileID -> objectiveID`.

The normal `getObjectiveByID` path already uses `objectivesByID` at `fnc_OPCOM.sqf:1563`. The state-update path at `fnc_OPCOM.sqf:3803` and the FSM calls to `getobjectivebyid` therefore already avoid an objective-array search.

The assignment map is maintained by `setObjectiveSection` and rebuilt by `rebuildObjectiveIndexes`. Its invariant is that every profile in an objective's `section` appears once as a key, mapped to that objective's ID.

## Easy or likely optimizations using the existing indexes

### 1. Restrict `cleanupduplicatesections` to assigned objectives

**Location:** `fnc_OPCOM.sqf:775`

Current behaviour inspects every objective, including objectives with empty sections.

Likely replacement: collect unique objective IDs from `values _profileObjectiveAssignment`, resolve each object with `_objectivesByID get _objectiveID`, and perform the existing section-waypoint checks only for those objectives.

The implementation must retain stale-profile cleanup and tolerate missing objective IDs. If nearly every objective is assigned, the savings will be smaller, but most missions should avoid scanning empty objectives.

**Assessment:** likely easy, medium-to-high priority; requires consistency validation.

### 2. Keep the `resetProfileOrders` fallback off the normal path

**Location:** `fnc_OPCOM.sqf:1527`

The normal path at `fnc_OPCOM.sqf:1491-1510` already resolves the profile's objective through `profileObjectiveAssignment` and `objectivesByID`. The full scan is only a repair path for legacy or externally mutated section data.

Recommended approach: retain the scan as an explicit debug/repair operation, or guard it behind a consistency-diagnostic mode instead of allowing it on ordinary resets.

**Assessment:** easy if the index invariant is accepted; otherwise retain as a safety fallback.

## Optimizations that need a new index or different data structure

### `removeObjective` and `reorderObjective`

Locations: `fnc_OPCOM.sqf:1987` and `fnc_OPCOM.sqf:2044`.

`objectivesByID` already resolves the objective hash. The remaining scan finds that object's position in the ordered `_objectives` array. Eliminating it requires a companion `objectiveIndexByID` map, with updates on add, delete, and reorder.

`objectivesByID` alone does not solve this.

### OPCOM state bucketing and priority selection

Locations: `opcom.fsm:352` node `ANALYZE`, `fnc_OPCOM.sqf:3829`, and `fnc_OPCOMgetHighestPrioObjective.sqf:57`.

These scans depend on state, skip lists, eligibility, and array priority order. They need state-specific ordered buckets or another priority index. A simple ID hashmap cannot answer these queries.

### Spatial objective selection

Locations: `fnc_OPCOM.sqf:3344-3345`, `fnc_OPCOM.sqf:3434`, and `tacom.fsm:709-732` node `ISSUE_ORDERS`.

These operations need objective centers, state filters, and distance ordering. They require a spatial index or cached state-specific position lists, not just `objectiveID -> object` lookup.

### Occupation analysis

Location: `fnc_OPCOM.sqf:3556`.

This is fundamentally a positional scan followed by `getNearProfiles`. `objectivesByID` offers no shortcut. The likely optimization seam is spatial bucketing or caching objective centers, which is a larger change.

### Reinforcement-base selection

Locations: `fnc_OPCOM.sqf:2082-2085`.

The function classifies objectives by `opcom_orders` and `opcom_state`, then chooses the nearest reserve base. It needs state/order indexes plus distance ordering to avoid the scan.

## Recommended implementation order

1. Change `cleanupduplicatesections` to visit only unique assigned objective IDs.
2. Make the `resetProfileOrders` scan diagnostic-only or explicitly repair-only.
3. Profile the recurring scans at `opcom.fsm:352` and `fnc_OPCOM.sqf:3556` before introducing state or spatial indexes.
4. Add `objectiveIndexByID` only if remove/reorder operations show up materially in profiling.

## Validation requirements

Any change that relies on `profileObjectiveAssignment` should verify:

- Adding a profile to a section creates exactly one map entry.
- Removing or reassigning a profile removes or updates the old entry.
- Resetting an objective clears its assignments.
- Loading saved data rebuilds the map before section-selection calls.
- Deleted objectives do not remain reachable through either index.

No runtime code changes are included in this document.
