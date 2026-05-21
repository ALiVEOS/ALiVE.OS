# COP — Common Operational Picture

A commander-intel map overlay feature of the `mil_c2istar` module. COP
renders a real-time situational picture on each client's map, built from data
that ALiVE's OPCOM already produces.

Where the existing **T.R.A.C.E.** system (the `displayTraceGrid` sector
shading) simulates **ELINT-style intel** — areas of *potential* presence
based on probabilistic control — COP simulates **confirmed KNOWN intel**:
actual contact reports the commander has received from OPCOM, with unit
size, type, movement vector, age, and confidence decay. The two systems are
complementary; either can be enabled independently from the Eden module
attribute panel.

---

## Eden Attributes

Three attributes on the `mil_c2istar` module drive COP:

| Attribute | Type | Default | Description |
|---|---|---|---|
| **Commander Intel Mode (COP)** | Off / Basic / Partial / Full / Advanced | Off | Master tier selector. When Off, zero COP code runs — no RPT output, no publicVariables, no cost. See the tier table below for what each non-Off tier enables. |
| **Commander Intel — Asymmetric** | Yes / No | No | When Yes (and mode != Off) the Layer 5 asymmetric loop starts and the asymmetric overlay can render. When No, `ALIVE_COP_LAYER_ASYMMETRIC` is forced false so clients gate it out. |
| **COP Anchor Distance** | 100 / 200 / 500 / 1000 / 3000 m | 1000 m | Radius around each player within which COP intel renders on the map. Higher values with many objectives or high unit counts may reduce client frame rate with the map open. |

### Commander Intel Mode tiers

Each tier preset applies via `ALiVE_fnc_COPApplyTier` which uses `if (isNil ...)`
guards — so any `ALIVE_COP_*` override set in your mission's `init.sqf` BEFORE
module init still wins. Tiers only fill in defaults for unset globals.

| Tier | Layer 2 (Enemy) | Layer 3 (BFT) | Layer 4 (Objectives) | Tier-3 features | Notes |
|---|---|---|---|---|---|
| **Off** | — | — | — | — | Kill switch — no COP code runs. |
| **Basic** | off | off | circles only (no axis arrows) | off | Commander's intent without ground truth. |
| **Partial** | clusters only (no movement vector) | off | circles only (no axis arrows) | off | Enemy clusters + objectives. |
| **Full** | clusters + movement + size + age | on | circles only (no axis arrows) | off | All baseline features, no power features. |
| **Advanced** | full feature set | on | full feature set including axis arrows | on | All defaults from `fnc_COPConfig.sqf` honoured. |

Tier-3 features = TRAIL (movement history), THREAT (priority highlight ring),
CONFIDENCE (border style by age), COMPOSITION ("MIXED" labels). All Tier-3
features are individually re-enable-able post-tier via the per-feature globals
(see "Per-feature toggles" further down).

### Migration from the legacy `enableLiveCommanderIntel` attribute

The legacy `enableLiveCommanderIntel` Yes/No attribute is preserved as a hidden
Eden attribute for backwards compatibility. A migration shim inside the MAINCLASS
`commanderIntelMode` case applies the following rule:

1. If `commanderIntelMode` has been explicitly set (any value other than the
   default `Off`), it wins. Legacy attribute is ignored.
2. Otherwise, if the legacy `enableLiveCommanderIntel` attribute is present:
   - `true`  → behave as `commanderIntelMode = "Advanced"`.
   - `false` → behave as `commanderIntelMode = "Off"`.

**Known migration surprise:** explicitly picking `commanderIntelMode = "Off"` in
Eden while the legacy `enableLiveCommanderIntel` is also set to `true` on the
same logic (typical when migrating an older mission) is **indistinguishable from
the default** — the shim sees mode at default and lets legacy drive, so Off
becomes Advanced. To fully disable COP on a migrated mission, either delete the
legacy attribute from the SQM, or leave it set to `false` while picking any
non-Off tier in Eden.

---

## Layers

| # | Layer | Source | Update | Visibility |
|---|---|---|---|---|
| 2 | Enemy intel | OPCOM `knownentities` | 30 s | Player's side only |
| 3 | BFT (friendly tracking) | `ALIVE_fnc_getNearProfiles` spatial query | 30 s | Player's side only |
| 4 | OPCOM objectives | OPCOM `objectives` array | 60 s | Player's side only |
| 5 | Asymmetric intel | Asymmetric OPCOM | 60 s | All sides (radio chatter) |

---

## File layout

```
addons/mil_c2istar/cop/
├── fnc_COPConfig.sqf    — master configuration (163 tunables)
├── fnc_COPApplyTier.sqf — applies the commanderIntelMode tier preset
├── fnc_COPLog.sqf       — four-tier logging dispatcher
├── fnc_COPHelpers.sqf   — 18 pure helper globals
├── fnc_COPServer.sqf    — Loop A (enemies+BFT, 30 s) + Loop B (objectives, 60 s)
├── fnc_COPAsym.sqf      — Layer 5 loop (60 s)
├── fnc_COPClient.sqf    — client init + map Draw EH
├── fnc_COPRender.sqf    — 15 draw functions + top-level dispatcher
├── fnc_COPDebug.sqf     — 11 admin debug commands
└── fnc_COPInit.sqf      — entry-point orchestrator (startServer/Asym/Client/stop)
```

All functions are registered under `class C2ISTAR` in
`addons/mil_c2istar/CfgFunctions.hpp` as `ALIVE_fnc_COP<Name>`.

---

## Data flow

```
ALiVE OPCOM (knownentities, objectives, hostility)
        |
        v
fnc_COPServer.sqf  (Loop A: 30 s fast, Loop B: 60 s slow)
fnc_COPAsym.sqf    (Layer 5: 60 s)
        |
        v  setVariable [..., true]  (hash-diff gated, side-filtered, JIP-persistent)
        |
ALiVE_COP_IntelData_WEST / _EAST / _GUER       enemy contacts
ALiVE_COP_BftData_WEST / _EAST / _GUER         friendly clusters
ALiVE_COP_ObjectivesData_WEST / _EAST / _GUER  commander objectives
ALiVE_COP_AsymActivityData                     insurgent activity zones
ALiVE_COP_AsymHostilityData                    civilian sentiment per cluster
ALiVE_COP_AsymInfraData                        insurgent infrastructure
        |
        v
fnc_COPClient.sqf attaches Draw EH on map (event-driven via Map mission EH)
        |
        v
ALIVE_fnc_COPDrawAll applies anchor-distance + viewport gates, then
dispatches to per-feature render functions in layer order.
```

---

## Logging

COP adopts ALiVE's three-tier logging system plus an optional per-category
filter (Tier 4):

1. **Tier 1 — Lifecycle** (init, errors, critical): emitted via
   `ALiVE_fnc_dump` with an inline severity prefix (`[ERROR]`, `[WARN]`,
   `[CRITICAL]`). Always emits, regardless of module debug attribute —
   matches the direct-dump pattern used by `mil_opcom` and `mil_logistics`.
2. **Tier 2 — Runtime observability** (cycle summaries, state transitions):
   `ALiVE_fnc_dump`, gated by the `mil_c2istar` module's `debug` attribute.
   Same pattern used by `mil_opcom`, `mil_logistics`, `civ_placement`.
3. **Tier 3 — Function traces** (entry/exit): CBA `TRACE_1/TRACE_2` macros,
   compile-time gated by `DEBUG_ENABLED_MIL_C2ISTAR` in
   `addons/main/script_mod.hpp`.
4. **Tier 4 — Granular filter** (per-category + per-level): the COP-specific
   addition. Silence specific categories at runtime without killing the
   whole debug stream.

All COP code uses a single entry point `ALIVE_fnc_COPLog` which dispatches
to the appropriate tier. Log messages follow the module-abbreviation
convention `"COP - <Category>: <message>"` (matching `"ML - "`, `"OPCOM - "`,
`"C2ISTAR - "`).

### Tier 4 runtime toggles (debug console)

```sqf
4 call ALIVE_fnc_COPDebugSetLevel;          // 0=silent, 1=error, 2=warn, 3=info, 4=debug, 5=trace
"render"  call ALIVE_fnc_COPDebugToggleCategory;
"profile" call ALIVE_fnc_COPDebugToggleCategory;
```

Per-category booleans (all default `true` except `render` and `profile`):
`ALIVE_COP_DEBUG_SERVER`, `_OBJECTIVES`, `_ASYM`, `_CLIENT`, `_RENDER`,
`_PERF`, `_BROADCAST`, `_PROFILE`.

Performance warning threshold (auto-logs when a cycle exceeds):
`ALIVE_COP_DEBUG_PERF_WARN_MS` (default 250 ms).

---

## Debug commands

All callable from the debug console at runtime.

```sqf
// State dumps (admin-visible; bypass module debug gate):
call ALIVE_fnc_COPDebugDumpAll;
call ALIVE_fnc_COPDebugDumpIntel;
call ALIVE_fnc_COPDebugDumpBft;
call ALIVE_fnc_COPDebugDumpObjectives;
call ALIVE_fnc_COPDebugDumpAsym;
call ALIVE_fnc_COPDebugListOpcoms;           // server only
"EAST" call ALIVE_fnc_COPDebugInspectOpcom;  // server only

// Runtime filter:
4 call ALIVE_fnc_COPDebugSetLevel;           // 0-5
"render" call ALIVE_fnc_COPDebugToggleCategory;

// Cache / visibility:
call ALIVE_fnc_COPDebugForceBroadcast;       // server only — wipe hash cache
call ALIVE_fnc_COPDebugShowStats;            // client only — hint with counts
```

---

## Configuration

All 163 tunables live in `fnc_COPConfig.sqf` as `ALIVE_COP_*` globals seeded
with defensive `if (isNil ...)` guards. Missions override by assigning the
globals **before** the `mil_c2istar` module initialises (e.g. in the
mission's `init.sqf`):

```sqf
// Tighter clusters, more transparent BFT, shorter trail history:
ALIVE_COP_CLUSTER_RADIUS = 300;
ALIVE_COP_BFT_ALPHA      = 0.4;
ALIVE_COP_TRAIL_LENGTH   = 2;
```

Runtime tweaks via debug console work identically — the globals are live.

### Per-layer toggles

```sqf
ALIVE_COP_LAYER_ENEMIES    = false;   // disable Layer 2 entirely
ALIVE_COP_LAYER_BFT        = false;   // disable Layer 3 entirely
ALIVE_COP_LAYER_OBJECTIVES = false;   // disable Layer 4 entirely
ALIVE_COP_LAYER_ASYMMETRIC = false;   // disable Layer 5 entirely
```

### Per-feature toggles (within layers)

```sqf
ALIVE_COP_FEAT_TRAIL       = false;   // hide enemy-cluster trails
ALIVE_COP_FEAT_COMPOSITION = false;   // hide MIXED labels
ALIVE_COP_OBJ_SHOW_RESERVE = true;    // show reserve objectives (default off)
```

### Insurgent infrastructure (all OFF by default — preserves COIN gameplay)

Server broadcasts the data regardless; clients gate rendering. Flip any at
runtime to surface that infrastructure type:

```sqf
ALIVE_COP_ASYM_SHOW_IED     = true;
ALIVE_COP_ASYM_SHOW_DEPOT   = true;
ALIVE_COP_ASYM_SHOW_FACTORY = true;
// etc.
```

### Faction short-code map

The bundled `ALIVE_COP_FACTION_CODES` hashmap covers ~20 common
RHS/RHSGREF/RHSSAF/vanilla factions. Missions extend via a
mission-namespace override that is consulted FIRST:

```sqf
ALIVE_COP_FACTION_CODES_OVERRIDES = createHashMapFromArray [
    ["my_custom_faction_a",    "CUST"],
    ["another_mod_faction_b",  "XXX"]
];
```

No addon edit required.

---

## Performance envelope (reference)

Targets (measured on a 40-player mission with 3 conventional OPCOMs + 1
asymmetric OPCOM):

| Path | Budget | Typical | Notes |
|---|---|---|---|
| Loop A cycle (enemies + BFT) | < 50 ms p99 | ~20-30 ms | Spatial-grid player filter + spatial-bucket BFT anchors keep this well under budget |
| Loop B cycle (objectives) | < 20 ms | ~5-8 ms | Per-state cap (10 atk / 10 def / 5 rcn / 5 rsv per side) keeps output bounded |
| Asym loop cycle | < 15 ms | ~2-5 ms | `_anyInfraEnabled` short-circuit means infra reads only happen when any toggle is on |
| Client Draw EH (map open) | < 1 ms/frame | ~0.3-0.7 ms | Cached viewport bounds + inlined proximity/viewport gates + zoom-aware detail drop |
| Client Draw EH (map closed) | 0 ms | 0 ms | EH only fires when map is visible |
| Network per cycle | variable | ~0-2 KB | Hash-diff skips unchanged broadcasts; typical cycles broadcast nothing |

### Tuning knobs

If a client reports low FPS with the map open, the first tunables to lower:

1. `ALIVE_COP_FEAT_TRAIL = false` — stops drawing movement trails (saves 1-3 lines per enemy cluster per frame)
2. `ALIVE_COP_FEAT_COMPOSITION = false` — stops the "MIXED" composition label
3. `ALIVE_COP_BFT_SEARCH_RADIUS` from 8000 m down to 2000-5000 m (server-side; reduces profile queries)
4. `ALIVE_COP_ANCHOR_DISTANCE` — shorter Eden attribute value cuts the per-frame marker count
5. `ALIVE_COP_CLUSTER_RADIUS` up from 200 m — more aggressive clustering = fewer markers
6. `ALIVE_COP_TRAIL_LENGTH` from 3 down to 1-2 — shorter trails
7. `ALIVE_COP_LAYER_ASYMMETRIC = false` if you don't need it — kills Layer 5 entirely

### Performance-warning log

Set `ALIVE_COP_DEBUG_PERF_WARN_MS = N` (default 250) to get a WARN log line when
any cycle exceeds N milliseconds. Loop A/B/Asym all respect this threshold.

### Deferred optimizations

Two architectural changes were evaluated and intentionally deferred until a
`diag_codePerformance` profile justifies them:

- **Server-side label pre-formatting.** The 9 per-frame `format[]` calls in
  `COPDrawEnemyMarker`, `COPDrawBftMarker`, `COPDrawObjective`, and
  `COPDrawAsymZone` could be moved into the server-cycle broadcast struct.
  Rejected because label content is gated by client-local toggles
  (`ALIVE_COP_render_showLabels`, `ALIVE_COP_FEAT_FACTION`, `ALIVE_COP_FEAT_AGE`,
  `ALIVE_COP_OBJ_SHOW_PRIORITY`); pre-formatting on the server would collapse
  the per-client tuning surface. Including an age string in the broadcast also
  flips the `ALIVE_fnc_COPBroadcastIfChanged` hash gate every minute per entity
  even when tactical data is unchanged — amplifying network traffic for a
  cosmetic field.
- **Marker persistence (`createMarker*` materialization).** Same draws could
  become engine-native markers mutated per cycle. Rejected because
  `setMarkerColorLocal` consumes CfgMarkerColors names, not RGBA literals
  (breaks per-entity alpha fade); polyline trails, dashed axis arrows,
  movement arrowheads, and activity badges don't fit the marker primitive
  cleanly; and `createMarker` (global) breaks the per-side intel-visibility
  filter that the `publicVariable` channels already enforce.

Per-frame `format[]` only fires when `ALIVE_COP_render_showLabels` is true
(zoom-gated) AND the entry passes anchor + viewport gates — typically &lt;30
markers in view, well under any measurable threshold. If a profile later shows
label-build time on the hot path, the preferred fix is a per-client label
cache keyed on `hashValue _entry` (array identity is stable per allocation;
server rebuilds the broadcast array each cycle, so cache invalidates
naturally), NOT either of the rejected architectures.

---

## Edge cases handled

COP inherits a battle-tested edge-case matrix from the DWA source it was
ported from. Each of the following scenarios is covered:

1. **ALiVE not yet ready** — server loops `waitUntil` OPCOM_instances populated + 45 s post-detection sleep for first analysis cycle.
2. **JIP players** — every broadcast channel uses `setVariable [name, value, true]` (third-arg JIP-persistent), so a late joiner immediately receives the latest intel / BFT / objective / asym structs the server has computed, plus the anchor distance. No waiting for the next server cycle.
3. **OPCOMs destroyed mid-mission** — profile reads wrapped in `isNil` + count guards.
4. **Empty knownentities** — handled gracefully, broadcasts empty array.
5. **Player without a side (sideUnknown)** — waits for resolution before caching; CIV faction resolved to real side via `ALiVE_fnc_factionSide`.
6. **Captured objectives** — represented as idle state, filtered by state whitelist.
7. **Insurgent OPCOM** — handled separately by `ALIVE_fnc_COPAsym`, independent shutdown flag.
8. **Profile lookup race** — guarded with `isNil` checks at every read site.
9. **Mod removed mid-mission** — type classification falls back to "unknown".
10. **Server FPS dropping** — loops yield (`sleep 0.01`) between OPCOMs and between BFT side builds, so neither starves the other.
11. **Killed enemies** — disappear within one cycle (OPCOM re-scan drops dead entities).
12. **Side enum/string mismatch** — `COPGetSideKey` + `COPGetSideFromKey` pair handles both directions.
13. **Player respawn** — `PlayerRespawned` mission event refreshes the side cache (works correctly across multiple respawns and side switches).
14. **Map closed during draw** — Draw EH only fires when map is visible; cost is zero with map closed.
15. **Multiple OPCOMs per side** — keeps the one with the most objectives (tiebreaker).
16. **Friendly fire / multi-faction** — BFT groups by side, not faction.
17. **Network latency** — hash-diff prevents redundant broadcasts.
18. **Objective size = 0** — clamped to `ALIVE_COP_OBJ_MIN_RADIUS` (100 m).
19. **Independent player** — works the same as WEST/EAST.
20. **nearestLocation empty** — falls back to `mapGridPosition`.
21. **Floating-point jitter in hash** — positions rounded to 10 m before hashing.
22. **Asymmetric cluster lookup fails** — wrapped in `isNil` check, skipped silently.
23. **Hostility value nil** — default 0, no marker drawn.
24. **Mid-cycle TACOM dispatch** — accepted; next cycle catches the state change.
25. **Loop B starvation** — Loop A and B run in separate spawn threads; neither blocks the other.
26. **Module destroyed mid-mission** — `"destroy"` operation dispatches `["stop"] call ALIVE_fnc_COPInit`, flipping the `_RUNNING` flags so spawned loops exit on their next cycle.
27. **Headless client** — `isServer = false, hasInterface = false` means zero COP work runs on HC (every COP operation is gated by one of those).
28. **Duplicate start dispatch** — `ALIVE_COP_SERVER_RUNNING` and `ALIVE_COP_ASYM_RUNNING` flags guard against double-start on re-init.
29. **Long-running missions** — `ALIVE_COP_LOC_CACHE` has an explicit 1000-entry cap with oldest-25% eviction to bound memory growth.

---

## Architecture notes

- Server-side state (`ALIVE_COP_OPCOMS`, `ALIVE_COP_TRAILS`,
  `ALIVE_COP_LAST_HASH`) uses **vanilla** `createHashMap`, not ALiVE hashes.
  Internal caches don't need the ALiVE hash wrapper.
- OPCOM reads (`[opcom, "objectives", []] call ALiVE_fnc_HashGet`) use the
  ALiVE hash API because those are ALiVE hash objects.
- The grid-bucket clusterer (`ALIVE_fnc_COPClusterByGrid`) is a stateless
  per-frame bucketer and is NOT substitutable with `ALIVE_fnc_cluster` (the
  strategic cluster OO class). They serve different contracts.
- Publicvariable channel names are mixed-case `ALiVE_COP_*` (matching
  ALiVE brand convention); function and global names are uppercase-ALIVE
  `ALIVE_fnc_COP*` / `ALIVE_COP_*` to match the `mil_c2istar` module's own
  function prefix style.
