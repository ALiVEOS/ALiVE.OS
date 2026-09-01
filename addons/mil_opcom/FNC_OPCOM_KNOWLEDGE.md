# `fnc_OPCOM.sqf` knowledge map

## Scope and method

This is a direct, dispatcher-focused analysis of `addons/mil_opcom/fnc_OPCOM.sqf` (lines 1-4318), based on one isolated review for each public operation body plus a final cross-check of the dispatcher. There are **63 in-scope operation bodies** and **69 in-scope case labels**: six bodies have two case-label aliases. The requested exclusions are deliberately omitted: `create` (80-93), `init` (94-114), and `validateStartupState` (4111-4305). This map records direct calls only; a listed callee is not recursively expanded in the caller's entry.

## Dispatcher conventions

Every call arrives as `[_logic, _operation, _args]`, parsed at 57-61. `_logic` defaults to `objNull` but is normally the OPCOM handler hash; some public paths accept the module object or an identifier string. `_operation` is a string. `_args` defaults to `objNull` and is broadly type-permitted by the outer dispatcher, so each case's actual shape guards matter.

`MAINCLASS` is `ALIVE_fnc_OPCOM` (52-53). `_result` starts as `nil` (62); the epilogue returns `_result` only when defined, otherwise `nil` (4315-4318). Several mutators intentionally do not assign `_result`. Server-only cases commonly forward clients with `remoteExec ["ALiVE_fnc_OPCOM",2]`; that remote request does not return the server's value to the caller. Hash fields are read/written through the ALiVE hash helpers unless a native `HashMap` is explicitly noted.

## Operation index

| Operation label(s) | Lines | Role |
|---|---:|---|
| start | 115-604 | Build handler and begin controllers |
| listen | 605-615 | Register profile-attack listener |
| handleEvent | 616-646 | React to profile attack events |
| createSpotrepForProfiles | 647-660 | Create G2 spot reports |
| getModuleObjectives | 661-739 | Extract placement/location objectives |
| cleanupduplicatesections | 740-787 | Repair stale/no-waypoint sections |
| NearestAvailableSection | 788-883 | Select usable nearest profiles |
| findProfilesNearPosition | 884-914 | Spatial profile query |
| attackentity | 915-1237 | Attack/contact response |
| setorders / setOrders | 1238-1251 | Single-profile order wrapper |
| setSectionOrders | 1252-1316 | Create batched profile waypoints |
| setObjectiveSection | 1317-1404 | Reconcile objective membership |
| synchronizeorders / synchronizeOrders | 1405-1441 | Consume/clean completion order |
| resetorders / resetProfileOrders | 1442-1521 | Remove a profile's orders/membership |
| getOPCOMbyid / getOPCOMByID | 1522-1532 | Global handler lookup |
| getobjectivebyid / getObjectiveByID | 1533-1550 | Objective lookup |
| rebuildObjectiveIndexes | 1551-1601 | Rebuild objective/profile indexes |
| sortObjectives | 1602-1766 | Sort and asymmetrically seed objectives |
| resetObjective | 1767-1802 | Clear/reset one objective |
| initObjective | 1803-1940 | Initialize asymmetric objective assets |
| removeObjective | 1941-2008 | Delete objective and cleanup |
| reorderObjective | 2009-2045 | Reorder objective array |
| findReinforcementBase | 2046-2072 | Choose reserve FOB |
| addTask | 2073-2117 | Queue an exact-profile manual TACOM task |
| pause | 2118-2146 | Set/query controller pause |
| stop | 2147-2169 | Stop controller FSMs |
| createhashobject | 2170-2177 | Server fresh hash factory |
| parseTaskProfileCountOverrides | 2178-2219 | Parse count overrides |
| parseTaskProfileTypeOverrides | 2220-2284 | Parse type overrides |
| normalizeAsymmetricInstallationType | 2285-2305 | Normalize installation alias |
| parseAsymmetricInstallationCountOverrides | 2306-2350 | Parse installation-count overrides |
| createAsymmetricInstallation | 2351-2604 | Place one asymmetric installation |
| seedAsymmetricInstallations | 2605-2665 | Apply per-source installation overrides |
| getTaskProfileCount | 2666-2688 | Resolve count override |
| getTaskProfileTypes | 2689-2717 | Resolve type override |
| convertObject | 2718-2743 | Serialize/resolve object reference |
| saveData | 2744-2866 | Persist objectives |
| loadData | 2867-2920 | Reload/restart controller state |
| loadObjectivesDB | 2921-3086 | Reconstruct persisted objectives |
| objectives | 3087-3098 | Objective getter/setter |
| findOPCOMByAllegiance | 3099-3115 | Find handler by side/faction |
| addObjective | 3116-3193 | Create/index one objective |
| createObjectives / createobjectives | 3194-3257 | Build/sort objective set |
| createObjectiveDebugMarkers | 3258-3300 | Render objective markers |
| nearestObjectives | 3301-3318 | Find state-matching objectives |
| nearestEntity | 3319-3342 | Find a profile in nearest objective |
| joinObjectiveClient | 3343-3410 | Client map selection UI |
| joinObjectiveServer | 3411-3469 | Server profile/group join |
| analyzeclusteroccupation | 3470-3564 | Classify objective occupation |
| scanForNearEnemies | 3565-3578 | Delegate enemy spatial scan |
| scanFriendliesForNearEnemies | 3579-3616 | Collect contacts/spot reports |
| scanTroops | 3617-3761 | Categorize controlled profiles |
| setstatebyclusteroccupation | 3762-3790 | Apply occupation priority state |
| selectordersbystate | 3791-3824 | Select objective/order by state |
| sectionsamount_attack | 3825-3835 | Attack section size getter/setter |
| sectionsamount_reserve | 3836-3846 | Reserve section size getter/setter |
| sectionsamount_defend | 3847-3858 | Defend section size getter/setter |
| destroy | 3859-3883 | Dispose instance/module |
| debug | 3884-3893 | Debug flag getter/setter |
| OPCOM_monitor | 3894-3986 | Start/stop diagnostic monitor |
| changeControlType | 3987-4071 | Rebuild for another mode |
| state | 4072-4110 | Export/restore handler state |
| convert | 4306-4308 | Backward-compatible array parser |

## Per-operation contracts

### start (115-604)

Requires server and a module-like `_logic`; ignores `_args`, constructs the handler hash, stores handler/module/global `OPCOM_instances`/`OPCOM_<n>` state, and starts conventional or insurgency FSMs. It parses module configuration (including faction precedence/default `BLU_F`), waits for CQB/profile readiness, may spawn C2ISTAR and friendly-installation scans, and returns `nil`. Direct internal edges: `parseTaskProfileCountOverrides`, `parseTaskProfileTypeOverrides`, `getTaskProfileCount`, `loadObjectivesDB`, `rebuildObjectiveIndexes`, `getModuleObjectives`, `createObjectives`, `validateStartupState`, `analyzeclusteroccupation`, `scanTroops`, `listen`; external edges include hash/data/profile/C2ISTAR/INS helpers and `execFSM`. Non-server, missing profile module, failed startup validation, unready synchronization, and unknown control type are exit/stall paths.

### listen (605-615)

Ignores `_args`; requires handler `G2` to exist. It registers `_logic` on global `ALiVE_eventLog` for `PROFILE_ATTACK_START` and `PROFILE_ATTACK_END`, then writes handler `listenerID`; returns `nil`. Missing `G2` is a silent no-op. Repeated calls can leave duplicate/stale listeners because only the newest ID is retained. External edges: `ALiVE_fnc_eventLog`, `HashGet`, `HashSet`.

### handleEvent (616-646)

Treats `_args` as an event hash with `data` and `type`, returning `nil` synchronously. It reads handler `side` and, for matching-side START, calls `createSpotrepForProfiles(_targets)`; for matching-side END and defined `G2`, calls `G2.removeProfileSpotreps(_targetsKilled)`. Missing/malformed event fields can fail; unknown type, opposite side, and absent G2 are no-ops. Event routing is side-only, so the first data field is read but not used to reject stale/misrouted events.

### createSpotrepForProfiles (647-660)

Expects `_args` array of profile IDs/data. Reads handler `G2`; absent G2 or empty input does nothing and returns `nil`. For each item it calls `G2.buildSpotrepForProfile([item,0])` then `G2.createSpotrep(data)` when defined. These are synchronous G2 calls; stale/missing profiles are skipped when the builder returns nil.

### getModuleObjectives (661-739)

`_args` must be a placement module or `LocationBase_F`. Placement modules wait for `startupComplete`, obtain their `objectives` through `OOsimpleOperation`, stamp `objectiveType`, and return the array. Civilian placement with asymmetric control additionally calls `parseAsymmetricInstallationCountOverrides` and writes override/source fields. Locations return one newly created objective hash. Unsupported module types yield nil; unready placements can wait indefinitely.

### cleanupduplicatesections (740-787)

Ignores `_args`, reads handler `objectives`, `pendingorders`, profile map, and each section's waypoint slot. It calls `resetProfileOrders(profileID)` for missing section profiles and, when a non-idle/non-unassigned populated section has zero waypoints, calls it for every member then `resetObjective(objectiveID)`. It removes pending rows whose profile is missing or older than 3600 seconds, returns nil, and is normally invoked from a spawned FSM task; snapshots can be stale and malformed profile/order shapes fail.

### NearestAvailableSection (788-883)

Args are `[position, size, [types,["infantry"]]]`. Reads category arrays, `pendingorders`, `profileObjectiveAssignment`, reserves, side/sea/pathfinding globals and profile flags; returns nearest-first profile IDs capped only for positive exact count behavior. It rejects busy/reserved/static/stationary/incompatible candidates and expands query radius 2-16 km. No writes; missing maps or malformed values fail, and stale IDs are simply excluded.

### findProfilesNearPosition (884-914)

Args `[position,sides,requireVisibility]` are required. It uses `ALIVE_fnc_getNearProfiles` at 800 m and returns `[profileID,profilePosition]` pairs; with visibility, accepts only <500 m terrain-clear pairs after ATL/ASL adjustment. No persistent writes or scheduling. Empty query returns `[]`; malformed profile records/arguments fail. Internal caller: `scanForNearEnemies`.

### attackentity (915-1237)

Args `[targetProfileID,size,type]` select maneuver assets. It cleans/writes handler `knownentities`, `attackedentities`, and optionally `artyRequestedEntities`, emits ATO/ARTY events, and creates profile waypoints; returns selected IDs, except ATO/artillery early exits return nil. It reads side/factions/enemies/reserves and target/profile state; stale target returns `[]`, empty force pool logs/no-ops. No direct OPCOM edge; external edges include ProfileHandler, event log, profile waypoint/entity APIs, artillery/ATO modules.

### setorders / setOrders (1238-1251)

Args `[position,profileID,objectiveID,orders]`; builds one order batch and directly calls `setSectionOrders([[],objectiveID,orders,[[position,profileID]]])`, returning its first waypoint or `[]`. No local scheduling; malformed args fail and a stale profile produces no waypoint after delegated cleanup.

### setSectionOrders (1252-1316)

Args `[targetObjective,objectiveID,orders,orderBatch]`. Empty batch returns `[]`; otherwise it deduplicates by profile ID, optionally resolves/reconciles legacy `[]` objective through `setObjectiveSection`, removes old pending rows, clears profiles' waypoints/commands, creates new waypoints, and appends `[position,profileID,objectiveID,time]` to `pendingorders`. Delayed `CBA_fnc_waitAndExecute` pushes completion into TACOM FSM `_TACOM_QUEUE`. Missing profiles are skipped but their old pending orders are removed; malformed FSM/profile/hash state fails.

### setObjectiveSection (1317-1404)

Args `[objective,newSection]`; invalid non-array/nil objective returns `[[],[],[]]`. It deduplicates membership, computes added/removed/reassigned IDs, writes `objectivesByID`, `profileObjectiveAssignment`, and target/old objective `section`/`sectionAssist`, removes reassigned reserves, and calls `resetObjective` for emptied old objectives. Returns `[added,removed,reassigned]` synchronously. Stale assignment/index references are only partly repaired; malformed empty-array objectives can be indexed under `""`.

### synchronizeorders / synchronizeOrders (1405-1441)

Takes a profile ID and returns true only if its consumed pending-order objective has no remaining live, <3600-second-old orders. It deletes the first matching pending row then removes stale same-objective rows in place; no match returns false. Reads profile map/time, has no internal edge, and malformed order rows fail. TACOM completion handling is its direct caller.

### resetorders / resetProfileOrders (1442-1521)

Takes profile ID and always returns true after best-effort cleanup. It removes first matching reserve/pending row, uses assignment/index then fallback objective scan to call `setObjectiveSection` and possibly `resetObjective`, deletes the assignment key, and resets inactive profile commands to ambient movement. Missing data is no-op; duplicates/stale entries beyond first can remain. External edges: ProfileHandler/profileEntity.

### getOPCOMbyid / getOPCOMByID (1522-1532)

Requires string `_args` (asserted), scans global `OPCOM_instances` by handler `opcomID`, and synchronously returns the first handler or nil. No writes. Undefined global/malformed handler fails; empty ID can match a handler missing `opcomID`, and position-derived duplicate IDs resolve first.

### getobjectivebyid / getObjectiveByID (1533-1550)

Takes unvalidated ID. A nonempty array `_logic` searches only that handler's `objectivesByID`; all other receivers scan global `OPCOM_INSTANCES` until first match. Returns objective or nil, with no writes/scheduling. It can return deleted/stale indexed objectives and does not fall back globally after a specific-handler miss.

### rebuildObjectiveIndexes (1551-1601)

Ignores `_args`; reconstructs native maps `objectivesByID` and `profileObjectiveAssignment` from `objectives`, normalizes duplicate/conflicting sections and clears their `sectionAssist`, then calls `resetObjective` for objectives emptied by repair. Returns `[objectivesByID,profileObjectiveAssignment]`. Duplicate/missing IDs collide, deleted/stale profiles are retained, and malformed inputs fail.

### sortObjectives (1602-1766)

`_args` is sort type; nil returns existing objectives unchanged. It validates centers, sorts distance/strategic/asymmetric (or leaves `size`/unknown unchanged), and in asymmetric mode calls `convertObject`, `seedAsymmetricInstallations`, and `createAsymmetricInstallation`. It removes `deleted` objectives, writes handler `objectives`, calls `rebuildObjectiveIndexes`, and optionally `createObjectiveDebugMarkers`; returns sorted array. Randomized scores and installation attempts make output non-deterministic; malformed fields still fail after center validation.

### resetObjective (1767-1802)

Takes objective ID; nil/missing yields current objectives unchanged. It calls `getObjectiveByID` and `setObjectiveSection([objective,[]])`, writes `tacom_state`, `opcom_state`, `danger`, `opcom_orders`, and objective type reset values, emits `TACOM_ORDER_COMPLETE`, updates debug marker, and returns current objectives. It does not clear pending orders itself; repeated resets emit repeated completion events.

### initObjective (1803-1940)

Nil args returns objectives; otherwise asserts string ID, resolves it with `getObjectiveByID`, converts configured assets with `convertObject`, sets objective `agents`/`objectiveType`, and spawns asymmetric factory/recruit/depot/roadblock/IED/ambush/sabotage/suicide helpers for live modules. Returns objectives, not the objective. Missing objective/assets can fail or skip; repeated calls duplicate spawns/actions.

### removeObjective (1941-2008)

Clients remote-forward; server nil args is getter, otherwise requires string ID. It finds the canonical indexed objective by reference in `objectives`, marks it `deleted`, and deletes relevant markers. Normal objectives reset copied section profiles, call `resetObjective`, and then leave the array/index. Transient objectives marked `manualTask` leave the array/index first and then reset copied profiles, skipping `resetObjective` so manual cleanup cannot publish a second, contradictory completion. It returns the remaining live objectives. A missing/stale ID is marker-cleanup/no-op; a stale index whose object is absent from the array leaves assignment/index state orphaned.

### reorderObjective (2009-2045)

Clients remote-forward; server args `[objectiveID,newIndex]` default to `""`/0. It reads objective array/index map, reference-finds the object, clamps destination, deletes/inserts it in place, and returns array. Missing/stale ID returns unchanged; no map/marker update occurs. The two-step mutation exposes a transient absent array entry to interleaved work.

### findReinforcementBase (2046-2072)

Ignores args and returns nearest reserve/reserving/idle FOB candidate relative to first attack/defend order objective, first unsorted FOB if no active objective, or nil. It reads objective `opcom_orders`, `opcom_state`, `center` and only calls HashGet/SortBy; no writes/scheduling.

### addTask (2073-2117)

Args `[operation,position,profileIDs]`, where operation is `recon`, `capture`, `defend`, or `reserve`. It validates the request, removes non-string and duplicate profile IDs, creates a uniquely identified transient objective with internal state, and appends `['manual_order',[operation,objective,profileIDs]]` to `_TACOM_QUEUE`. The queued payload is authoritative: no TACOM scratch state or section assignment is mutated before dequeue. TACOM uses only those profile IDs, never recruits replacements, suppresses correlated OPCOM confirmation/continuation, and removes the transient objective on failure or final completion. The operation returns the created objective.

### pause (2118-2146)

Intended bool setter/query: it reads/writes handler `pause`, waits for startup/FSM readiness, and sets both FSM `_pause` flags, returning requested/current bool (the already-paused early exit can return nil). Omitted `_args` is outer-default `objNull`, so it incorrectly hits bool assertion instead of query. No server guard, unbounded wait, and asymmetric `TACOM_FSM` absence can fail.

### stop (2147-2169)

Ignores args, reads FSM handles, sets `_exitFSM=true`/`_busy=false`, waits until TACOM then OPCOM handler keys disappear, logs, and returns true. Missing handles are successful no-ops; stale/nonterminating FSM keys stall indefinitely. `loadData` directly calls it.

### createhashobject (2170-2177)

Server creates an empty ALiVE hash, removes inherited `super`/`class`, and returns it. Clients return nil. It ignores logic/args and has no other state writes; `loadObjectivesDB` calls it.

### parseTaskProfileCountOverrides (2178-2219)

Accepts array or SQF string; string is `call compile`d. It returns a new hash keyed by lowercased task names with nonnegative floored numeric counts; invalid entries/parse failures leave an empty/partial hash, duplicates overwrite. No persistent writes. Compile is executable configuration, not data-only parsing.

### parseTaskProfileTypeOverrides (2220-2284)

Accepts array or compiled string and returns hash of lowercased task keys to canonicalized/deduplicated allowed type arrays. Empty explicit arrays are preserved; malformed input/token-only arrays are rejected. No writes/internal edges; whitespace is not trimmed and compile carries executable-input risk.

### normalizeAsymmetricInstallationType (2285-2305)

Accepts a string, lowercases it, and returns canonical `HQ`, `depot`, `factory`, `ied`, or `roadblocks`; aliases include recruit/recruitmentHQ, IED factory, and singular roadblock. Non-string/unknown returns `""`; no reads/writes/scheduling.

### parseAsymmetricInstallationCountOverrides (2306-2350)

Array/compiled-string parser equivalent to count overrides but normalizes installation aliases first. Returns hash of canonical installation type to floored nonnegative count; invalid/unknown entries skip and later duplicates overwrite. No persistent writes; `call compile` is the material trust boundary.

### createAsymmetricInstallation (2351-2604)

Args select objective/type/position context and validate objective/profile/feature availability. It resolves/stamps installation object/hash fields and starts relevant INS modules (factory, depot, HQ, IED, roadblocks), returning success/failure. It reads objectives, side/factions, buildings/roads and existing installations; side effects include spawned INS processes, marker/action/world state. Direct internal edge: `getObjectiveByID`, `convertObject` where used. Invalid type/objective, no viable building/road, disabled feature, or client locality are failure/no-op paths.

### seedAsymmetricInstallations (2605-2665)

Reads objective override hashes/source keys, groups objectives by source, invokes `createAsymmetricInstallation` up to requested counts, logs under-placement, and returns handled objective IDs. It writes no direct handler fields. A failed override still marks its group handled, so later normal seeding excludes it; source-key collisions reuse the first group's override map.

### getTaskProfileCount (2666-2688)

Args `[task,default,fallbackTask]`; reads handler `taskProfileCountOverrides`, tries lowercased task then fallback, and returns numeric override else default. No writes/scheduling; malformed/nonhash override safely preserves default.

### getTaskProfileTypes (2689-2717)

Args `[task,defaultArray,fallbackTask]`; reads `taskProfileTypeOverrides`, returns a shallow copy of matching task/fallback array or default. No writes/scheduling; nonhash/invalid values are no-op fallback.

### convertObject (2718-2743)

Accepts a live object or `[position,class]` serialized reference. It returns object, serialized form, `[]`, `objNull`, or nil according to liveness/proximity resolution; no persistent writes. Used by asymmetric asset paths. Malformed/unsupported args return default/undefined rather than a stable error.

### saveData (2744-2866)

Server/data-module-gated; ignores args, throttles using global `OBJECTIVES_DB_SAVE`, serializes persistent non-player-created objectives and optional force state, lazily creates/configures data handler, invokes synchronous `Data.bulkSave`, and returns save result/messages when it runs. Writes cache globals and database records; missing/disabled data, throttle, or empty data return nil after diagnostics. External edges are Data/hash/CBA helpers.

### loadData (2867-2920)

Server/data-module-gated reload: calls `stop`, `loadObjectivesDB`, replaces objectives/rebuilds indexes, sets control-specific FSM handles, and returns its result (normally nil). It assumes loaded objectives are an array; failed DB load can write false before restart. Unknown control type leaves the instance stopped.

### loadObjectivesDB (2921-3086)

Server/data-module-gated and cached at 300 seconds. It bulk-loads `mil_opcom`, filters by handler `opcomID`, recreates cleaned objective hashes, writes/rebuilds objective indexes, clears profile orders, and calls `resetObjective` or asymmetric `initObjective`; returns reconstructed objective array/false. It can emit events/spawn INS work during restoration; bad DB shapes/stale cached data remain gaps.

### objectives (3087-3098)

Nil `_args` returns `objectives`; array `_args` writes it, calls `rebuildObjectiveIndexes`, returns it; other non-nil types return nil without mutation. No copy/server guard; its direct internal edge is `rebuildObjectiveIndexes`.

### findOPCOMByAllegiance (3099-3115)

Requires string identifier, lowercases it, scans global `OPCOM_instances`, and returns first handler whose `side` equals it or whose `factions` contains it. No writes/scheduling; non-string/no match returns nil and undefined/malformed global state fails.

### addObjective (3116-3193)

Accepts handler or side/faction string resolved through `findOPCOMByAllegiance`, then an objective argument tuple with defaults. It creates objective hash (`objectiveID`, center/size/type/priority/state/cluster/opcom metadata, deleted/revision/player-created), appends/inserts into `objectives`, writes `objectivesByID`, optionally renders debug markers, and returns objective. Invalid logic/args return nil. Duplicate IDs overwrite index but leave older array entry; callers must allocate unique IDs, as `addTask` now does for transient manual objectives.

### createObjectives / createobjectives (3194-3257)

Nil args returns existing objectives; otherwise args `[sourceObjectives,sortStrategy]` generate IDs and call `addObjective` for each, copy asymmetric override metadata, then call `sortObjectives`, returning objectives. It extends rather than clears existing state; source/objective malformed fields fail. Direct edges: `addObjective`, `sortObjectives`.

### createObjectiveDebugMarkers (3258-3300)

Optional array args selects objectives, otherwise reads all. It deletes/recreates global `ALiVE_OPCOM_<objectiveID>` markers using side/color/index/type, returning nil. It mutates marker world state only. Center array is modified with offset in-place, a possible accumulated-position/stale-marker risk; duplicate/empty IDs collide.

### nearestObjectives (3301-3318)

Args `[position,[opcomState,"attacking"]]`; reads objectives, filters exact `opcom_state`, SortBy distance to `center`, returns shallow sorted array, with `[]` for no objectives. No writes/scheduling; malformed positions/centers can fail.

### nearestEntity (3319-3342)

Args `[unit,[state,"attacking"]]`; gets unit position, calls `nearestObjectives`, reads each section and profile map, returns first live profile ID or nil. No writes/scheduling. Direct edge: `nearestObjectives([getPosATL unit,state])`; malformed unit/profile map fails.

### joinObjectiveClient (3343-3410)

Args default `[player,[],"COLORYELLOW"]`. In interface context it creates local area markers, opens map, waits indefinitely for click global, sorts clicked-nearest objective, calls `joinObjectiveServer`, closes/deletes markers, returns nil. Empty objectives hints/no-ops. Non-interface remote branch references `_unit` before argument unpacking; marker names based on positions can collide.

### joinObjectiveServer (3411-3469)

Args `[unit,objective]`; clients remote-forward. Server validates target/caller profiles, fades player UI, sleeps/waits, teleports/joinGroups/formations or vehicle cargo, copies target waypoints, fades back, returns nil. It mutates world position, group membership, profile waypoints, and UI; destroyed/missing profiles hint/dump/exit, and unready profiles/unit groups can wait/fail.

### analyzeclusteroccupation (3470-3564)

Args `[friendlySides,enemySides]`; reads objectives/controltype, resets empty-section objective state, queries all entity profiles within 500 m, builds friendly/enemy/contested triples, writes `clusteroccupation=[friendly,enemy,contested,time]`, calls `setstatebyclusteroccupation` for reserve/attack/defend, returns tuple. Unknown controltype leaves priority mapping undefined; snapshots and profile side layouts can be stale/malformed.

### scanForNearEnemies (3565-3578)

Args `[position,[requireVisibility,true]]`; reads `sidesenemy` and directly calls `findProfilesNearPosition([position,sidesenemy,requireVisibility])`, returning that result. No writes/scheduling. Default finder behavior is 800 m query / 500 m LOS acceptance.

### scanFriendliesForNearEnemies (3579-3616)

Optional args are `[[publishResult,true]]`. The operation reads factions and ProfileHandler faction profiles, calls `scanForNearEnemies` for each valid friendly profile, deduplicates contacts, and returns pairs. By default it calls `createSpotrepForProfiles(contactIDs)` and writes `knownentities`; TACOM passes `false` so its worker returns a private result that is published only after the FSM accepts the active scan generation. Missing profiles/no factions gives `[]`; with publication enabled this clears `knownentities`. Direct edges are the two named operations.

### scanTroops (3617-3761)

Ignores args; gathers faction profiles, categorizes valid non-player assets into infantry/motorized/mechanized/armored/air/sea/artillery/AAA, writes all category keys and `currentForceStrength`, initializes `startForceStrength` only from a nonempty first snapshot, and returns eight arrays in that order. No profiles publishes all eight categories as empty plus a zero `currentForceStrength` vector, preventing a prior snapshot from remaining visible; helicopter/plane categorization is commented so air remains empty.

### setstatebyclusteroccupation (3762-3790)

Args `[objectiveEntries,operation]`; resolves each ID via `getObjectiveByID`, skips nil/deleted, compares state against protected states, and writes `opcom_state` when eligible; returns nil. Unknown operation uses default protected list but writes unknown string. Direct edge: `getObjectiveByID(id)`.

### selectordersbystate (3791-3824)

Takes requested state, reads ordered objectives, OPCOM FSM `_OPCOM_SKIP_OBJECTIVES`, module EmptyDetector triggers, selects first eligible matching state, maps unassigned to attack, writes objective `opcom_orders`, returns `["execute",objective]`; no selection returns nil. Attack/unassigned are trigger-gated, defend/reserve are not. Missing FSM/module/hash state fails.

### sectionsamount_attack (3825-3835)

Non-scalar args get handler `sectionsamount_attack`; scalar args write it and TACOM FSM `_sectionsamount_attack`, returning nil. No range/integer/FSM existence validation; conventional initialization supplies defaults then profile-count normalization.

### sectionsamount_reserve (3836-3846)

Same getter/setter pattern for `sectionsamount_reserve` and TACOM `_sectionsamount_reserve`; omitted default `objNull` is getter. No validation; setter returns nil and assumes TACOM FSM.

### sectionsamount_defend (3847-3858)

Same getter/setter pattern for `sectionsamount_defend` and TACOM `_sectionsamount_defend`; no value or FSM validation and setter returns nil.

### destroy (3859-3883)

Accepts module object or handler, reads FSM/module keys, sets both `_exitFSM`, removes handler from global `OPCOM_instances`, clears module superclass/class, deletes module/group, returns nil. It does not remove mission namespace/intel/listener state. Missing asymmetric TACOM handle can error before cleanup; no idempotence/validation.

### debug (3884-3893)

Boolean `_args` writes handler debug flag and returns it; all other args read flag default false. No scheduling/external effects beyond hash write.

### OPCOM_monitor (3894-3986)

Requires boolean enable. It reads/writes handler `monitor`, spawns/stores a once-per-second diagnostic loop or terminates existing handle, returning handle. Loop reads FSM states/data/queues/objectives and can hint/log; after severe debug timeout it resets `_OPCOM_DATA` to `[]` and clears busy. Re-enabling duplicates monitors; disabling with default false/no handle falls through to start; malformed/nonexistent FSM data can fail.

### changeControlType (3987-4071)

Clients remote-forward; server args `[newControlType]` must be invasion/occupation/asymmetric and handler startup must be complete. It stops FSMs with unbounded waits, removes all objectives via `removeObjective`, recreates/sorts them via `createObjectives`, clears `pendingorders`, writes controltype, starts appropriate FSM(s), returns true; invalid/not-ready/same type returns false. It does not rerun analysis/scans/listener/cache and stale FSM end keys block indefinitely.

### state (4072-4110)

Array `_args` means restore: requires ALiVE hash, writes every supplied key except `objectivesByID`/`profileObjectiveAssignment`, calls `rebuildObjectiveIndexes`, returns nil. Non-array extracts a new hash of all handler keys except `super`, `class`, and those two indexes, returning it. Restore does not delete omitted existing keys and can write supplied `super`/`class`; direct edge: `rebuildObjectiveIndexes`.

### convert (4306-4308)

Backward-compatibility alias only: passes `[_args]` to `ALiVE_fnc_parseArrayFromString` and returns that value. It has no handler/global writes, scheduling, or direct OPCOM edge; malformed parsing behavior belongs to the external helper.

## Direct internal call graph

Only direct dispatcher edges are shown.

```text
start -> parseTaskProfileCountOverrides, parseTaskProfileTypeOverrides,
         getTaskProfileCount, loadObjectivesDB, rebuildObjectiveIndexes,
         getModuleObjectives, createObjectives, validateStartupState [excluded
         operation], analyzeclusteroccupation, scanTroops, listen
handleEvent -> createSpotrepForProfiles
getModuleObjectives -> parseAsymmetricInstallationCountOverrides
cleanupduplicatesections -> resetProfileOrders, resetObjective
setOrders / setorders -> setSectionOrders
setSectionOrders -> setObjectiveSection
setObjectiveSection -> resetObjective
resetProfileOrders / resetorders -> setObjectiveSection, resetObjective
rebuildObjectiveIndexes -> resetObjective
sortObjectives -> convertObject, seedAsymmetricInstallations,
                  createAsymmetricInstallation, rebuildObjectiveIndexes,
                  createObjectiveDebugMarkers
resetObjective -> getObjectiveByID, setObjectiveSection
initObjective -> getObjectiveByID, convertObject
removeObjective -> resetProfileOrders, resetObjective [non-manual objectives]
addTask -> addObjective
parseAsymmetricInstallationCountOverrides ->
    normalizeAsymmetricInstallationType
createAsymmetricInstallation -> normalizeAsymmetricInstallationType,
    getObjectiveByID, convertObject
seedAsymmetricInstallations -> createAsymmetricInstallation
loadData -> stop, loadObjectivesDB, rebuildObjectiveIndexes
loadObjectivesDB -> createhashobject, rebuildObjectiveIndexes,
                    resetProfileOrders, resetObjective, initObjective
objectives -> rebuildObjectiveIndexes
addObjective -> findOPCOMByAllegiance, createObjectiveDebugMarkers
createObjectives / createobjectives -> addObjective, sortObjectives
nearestEntity -> nearestObjectives
joinObjectiveClient -> joinObjectiveServer
analyzeclusteroccupation -> setstatebyclusteroccupation
scanForNearEnemies -> findProfilesNearPosition
scanFriendliesForNearEnemies -> scanForNearEnemies, createSpotrepForProfiles
setstatebyclusteroccupation -> getObjectiveByID
changeControlType -> removeObjective, createObjectives, objectives
state -> rebuildObjectiveIndexes
```

Important direct external-edge families are: ALiVE hash APIs; ProfileHandler/profile entity waypoint/command APIs; event log and G2; Data persistence; CBA delayed execution/string/hash helpers; INS helper/module functions; engine `execFSM`, `remoteExec`, marker/UI/group/vehicle/position commands. The direct external edges with stateful consequences are identified in the individual sections above.

## Shared state and key catalog

| Owner | Key/variable | Meaning and primary writers |
|---|---|---|
| Handler | `objectives` | Ordered objective hash array; start/create/sort/load/objectives/reorder/remove mutate it. |
| Handler | `objectivesByID` | Native map ID -> objective; rebuilt by `rebuildObjectiveIndexes`, incrementally written by add/remove/section. |
| Handler | `profileObjectiveAssignment` | Native map profile ID -> objective ID; section/reset/index repair own it. |
| Handler | `pendingorders` | `[position,profileID,objectiveID,time]` rows written by section orders, consumed by synchronize/reset/cleanup/control switch. |
| Handler | `OPCOM_FSM`, `TACOM_FSM` | Controller handles (`TACOM_FSM=-1` asymmetric); start/load/control/stop/destroy/pause use them. |
| Handler | `startupComplete`, `controltype`, `pause`, `monitor`, `manualTaskSequence` | Lifecycle/control flags plus the monotonic suffix used to allocate unique transient manual-objective IDs. |
| Handler | `factions`, `side`, `sidesenemy`, `sidesfriendly`, `position`, `opcomID` | Identity and query context established at startup. |
| Handler | troop category keys and force keys | `infantry`, `motorized`, `mechanized`, `armored`, `air`, `sea`, `artillery`, `AAA`, `startForceStrength`, `currentForceStrength`; scanTroops writes. |
| Handler | `knownentities`, `attackedentities`, `artyRequestedEntities`, `clusteroccupation` | Contact/attack/occupation snapshots. |
| Objective | `objectiveID`, `center`, `size`, `objectiveType`, `priority`, `clusterID` | Core identity/geometry/source fields. |
| Objective | `section`, `sectionAssist`, `opcom_state`, `opcom_orders`, `tacom_state`, `danger`, `deleted`, `manualTask` | Assignment/controller lifecycle state; `manualTask` identifies transient exact-profile objectives whose cleanup bypasses normal completion publication. |
| Globals | `OPCOM_instances`, `OPCOM_<n>`, `OBJECTIVES_DB_SAVE`, `OPCOM_INSTANCES` | Instance registry/persistence cache; capitalization use is inconsistent and should be validated. |
| FSM | `_OPCOM_SKIP_OBJECTIVES`, `_unconfirmedOrders`, `_manualOrder`, `_OPCOM_DATA`, `_TACOM_DATA`, `_OPCOM_QUEUE`, `_TACOM_QUEUE`, `_busy`, `_exitFSM`, `_pause` | FSM-local coordination slots. `_unconfirmedOrders` holds `[orderID, operation, objective, expiresAt]`; `_manualOrder` prevents TACOM from recruiting/substituting profiles or transmitting conventional confirmations; data slots are legacy ingress initialized/reset to `[]`; queues are authoritative internal inboxes written through handle `setFSMVariable`. |

## Cross-operation workflows

1. **Objective lifecycle:** module extraction (`getModuleObjectives`) -> creation (`createObjectives`/`addObjective`) -> ordering/seeding (`sortObjectives`) -> index construction (`rebuildObjectiveIndexes`) -> section assignment/orders (`setObjectiveSection`, `setSectionOrders`) -> completion cleanup (`synchronizeOrders`, `resetProfileOrders`, `resetObjective`) -> deletion/persistence (`removeObjective`, `saveData`).
2. **Conventional command loop:** `scanTroops` and `analyzeclusteroccupation` update pools/state; `selectordersbystate` selects an objective; TACOM uses section-size values/`NearestAvailableSection`; `setSectionOrders` emits delayed completion into `_TACOM_QUEUE`; `synchronizeOrders` declares the objective ready for terminal completion.
3. **Contact/intelligence loop:** `scanFriendliesForNearEnemies` -> `scanForNearEnemies` -> `findProfilesNearPosition`, writes `knownentities`, then `createSpotrepForProfiles`; event listener `handleEvent` does the same for profile attack start and removes G2 reports at attack end.
4. **Persistence/control transition:** `saveData` exports persistent non-player objectives; `loadData` stops FSMs, reloads/reindexes/resets/initializes objectives, then launches mode-appropriate FSMs. `changeControlType` similarly stops, removes, recreates/sorts, clears pending orders, and restarts controllers.
5. **Exact-profile manual task:** `addTask` validates the operation and supplied IDs, creates a uniquely named `manualTask` objective, and queues one self-contained `manual_order`. TACOM uses only the supplied profiles, suppresses the conventional correlation/continuation path, and calls `removeObjective` after failure or final waypoint completion. Manual removal drops the transient objective from indexes before profile reset so reset callbacks cannot turn cleanup into a second completion.

## Invariants and recurring failure patterns

- Objective IDs should be unique, and each profile should be in at most one objective `section`; indexes are intended to enforce this but duplicate IDs/stale references can violate it.
- `objectives`, `objectivesByID`, and `profileObjectiveAssignment` must be changed together or followed by `rebuildObjectiveIndexes`.
- `pendingorders` row shape and time are trusted by cleanup/synchronize; only first profile match is commonly removed, so duplicates can survive.
- Conventional-only paths assume a valid TACOM FSM. Asymmetric mode uses `TACOM_FSM=-1`, making unguarded pause/destroy/section-size writes hazardous.
- Several waits lack timeout: startup synchronization, pause, stop, load, control-type changes, client map selection, server profile activation. A stale FSM/module can block scheduled work indefinitely.
- Many mutators have no locality/type guards. Client forwarding is only implemented in selected lifecycle/objective cases.
- Module override parsers intentionally use `call compile`; mission configuration text is executable SQF.

## Ambiguities and validation gaps

- The public dispatcher header documents only a subset of later labels (20-34 versus actual cases), so documentation is incomplete.
- `convert` at 4306-4308 is only `parseArrayFromString`; it should not be confused with data-layer conversion functions of the same name elsewhere.
- `OPCOM_instances` is written at 339-347/3836, while global objective fallback reads `OPCOM_INSTANCES` at 1541; confirm whether a compatibility alias is initialized elsewhere.
- `joinObjectiveClient` references `_unit` in its non-interface remote branch before `params` assigns it (3324-3328).
- `OPCOM_monitor` disable false/no-handle path starts a monitor rather than remaining stopped (3864-3872); validate intended toggle semantics.
- Roadblock viability/placement in `createAsymmetricInstallation` should be reviewed around 2533-2550: candidate filtering and selected-road use do not clearly align.
- Objective center arrays are mutated while rendering debug markers (3255 onward); verify whether HashGet returns a mutable stored reference in the deployed hash implementation.
