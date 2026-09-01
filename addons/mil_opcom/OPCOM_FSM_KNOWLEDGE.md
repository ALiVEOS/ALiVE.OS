# OPCOM FSM knowledge — occupation and invasion

## Scope and evidence

This knowledge covers `addons/mil_opcom/opcom.fsm`, the conventional military OPCOM FSM. It is started with the paired `tacom.fsm` for `controltype = "occupation"` and `"invasion"` by `ALiVE_fnc_OPCOM` (`addons/mil_opcom/fnc_OPCOM.sqf`, `start`, around lines 574-588). `asymmetric` starts `insurgency.fsm` instead, so insurgency is only mentioned as a boundary.

Every fact below is observed in `opcom.fsm` or the named supporting SQF. “Handler” means the hash object passed as `_this select 0`. “Mailbox” means an FSM variable, not a handler key.

## State map

`opcom.fsm` contains 16 executable states. The visual condition nodes in the FSM header are link predicates, not additional executable states.

```text
INIT -- paired handles ready --> INITIALIZE --> COLLECT_TO_QUEUE
                                               |
                                               v
       +----------------------------------- ANALYZE <----------------+
       |             |              |        |                        |
       |             |              |        +-- order --> ORDER_TACOM
       |             |              |                       |      |
       |             |              |                       |
       |             |              |                  NOT_BUSY_1
       |             |              |                       |      |
       |             |              +-- analysis --> PERFORM_CLEANUP
       |             |                                  -> PERFORM_ANALYSIS
       |             |                                  -> PERFORM_POSTANAL
       |             |                                  -> RESET ------------+
       |             +-- reinforce --> REQUEST_REEINFOR ---------------------+
       +-- QRF/RECON/OCA --> REQUEST_QRF/REQUEST_RECON/REQUEST_OCA ----------+

ANALYZE, NOT_BUSY, NOT_BUSY_1, PERFORM_ANALYSIS -- _exitFSM --> END
END removes handler.OPCOM_FSM and is final.
```

Request states and `RESET` publish `["analyze",nil]`; the common receiver and collector bring that token back to `ANALYZE`. Cleanup and the three analysis jobs are the separate analysis sub-flow.

| State | Normal role / successor | Alternate or failure route |
| --- | --- | --- |
| `INIT` | Captures configuration and waits, then `INITIALIZE`. | Waits indefinitely without valid paired handles. |
| `INITIALIZE` | Writes `["init",true]`, then receiver → collector. | Pause blocks receiver. |
| `COLLECT_TO_QUEUE` | Consumes one mailbox item into FIFO, then `ANALYZE`. | Self-receives additional items; no direct END edge. |
| `ANALYZE` | Consumes one action; dispatches ordering, analysis, reinforcement, or air requests. | Priority-99 exit → END. |
| `ORDER_TACOM` | Registers and queues a correlated TACOM attack/defend/reserve request, then returns immediately. | Always → `NOT_BUSY_1`; confirmation and expiry are later ordinary queue work. |
| `NOT_BUSY` | Idle/reset after a skipped objective. | Exit → END; receiver failsafe after cycle time. |
| `NOT_BUSY_1` | Idle gate after dispatch. | Exit → END; same receiver behavior. |
| `PERFORM_CLEANUP` | Spawns duplicate-section cleanup → `PERFORM_ANALYSIS`. | No timeout/exit link. |
| `PERFORM_ANALYSIS` | Spawns 3 analyses → post-analysis after all `scriptDone`. | Exit → END; completion results are not checked. |
| `PERFORM_POSTANAL` | Calculates force deficit → `RESET`. | Always continues; no direct logistics call. |
| `RESET` | Clears skip set, primes analysis → collector. | Pause can hold it; no direct END edge. |
| `REQUEST_REEINFOR` | Starts detached LOGCOM waves → collector. | Missing base/logistics drops request. |
| `REQUEST_QRF` | Best-effort strike/profile attack → collector. | Missing target/assets silently returns to analysis. |
| `REQUEST_RECON` | Best-effort ATO Recce request → collector. | ATO initialization is given 30 seconds; timeout/stop skips dispatch and returns to analysis. |
| `REQUEST_OCA` | Best-effort ATO OCA request → collector. | Missing target/building/ATO silently returns. |
| `END` | Removes handler `OPCOM_FSM` and terminates. | No outgoing links; does not cancel child scripts/orders. |

## Lifecycle and scheduling

### Start

`INIT` reads the handler's configuration into FSM locals: side/faction relationships, control type, simultaneous-objective limit, reinforcement ratio, debug flag, and reconnaissance building types. It initializes queue/control variables; it does not create objectives. Startup in `fnc_OPCOM.sqf` creates/loads objectives, runs initial support analysis, starts the paired FSMs, and stores their handles before `INIT_COMPLETE` can succeed.

The sole INIT transition re-reads handler keys `OPCOM_FSM` and `TACOM_FSM`; both must be non-nil and numerically positive. Its lack of timeout is intentional behavior, not a readiness proof. This two-handle setup is the conventional-mode boundary: asymmetric startup does not provide the TACOM handle.

`INITIALIZE` supplies `["init",true]` to the mailbox. After collection, `ANALYZE` handles `init` by optionally enabling the OPCOM monitor, then supplying `["analyze",nil]` and clearing `_busy`. Startup therefore enters the regular queue loop rather than a separate first-cycle path.

### Mailbox and queue

`_OPCOM_QUEUE` is the authoritative internal FIFO with observed tags `init`, `analyze`, `completed`, `expire_order`, `confirmed`, `QRF`, `RECON`, `OCA`, and `custom`. `_OPCOM_DATA` is a legacy single-slot ingress initialized to `[]`. Each receiver iteration checks both sources; `COLLECT_TO_QUEUE` appends a nonempty legacy entry and resets the slot to `[]`. `ANALYZE` removes one queued entry using `deleteAt 0`.

Internal producers append directly to the FIFO. Legacy code can still overwrite the single `_OPCOM_DATA` slot if it writes more than once before collection; payload shape is not validated.

The shared `OPCOM_RECEIVER` link appears from initialization, both not-busy states, reset, all request states, and on the collector itself. Its precondition computes `_failsafe = (time - _timestamp) > _cycleTime`; INIT sets the cycle default to 300 seconds. It accepts a nonempty legacy slot, queued data, `_orderFailed`, or fail-safe expiry only when `!_pause`. On error/fail-safe, it clears flags, queues `["analyze",nil]`, and makes `_busy=false`. Its condition assigns `_OPCOM_status="waiting for data"`, so status changes while evaluating the predicate.

The collector sends work to ANALYZE if the queue is nonempty (or a cycle elapsed), at least 0.5 seconds have passed since `_lastAnalyze`, and `_busy` is false. This edge does not inspect `_pause`, unlike the receiver. Thus queued/periodic work can still reach ANALYZE while pause blocks receiver transitions. ANALYZE also self-feeds if `time - _lastAnalyze > _cycleTime`.

### Spawn and wait semantics

`PERFORM_CLEANUP` starts `cleanupduplicatesections` in a scheduled `spawn`, then waits for `scriptDone _cleanup`. `PERFORM_ANALYSIS` starts three scheduled scripts and requires all three handles to be done:

1. `analyzeclusteroccupation`
2. `scantroops`
3. `scanFriendliesForNearEnemies`

These are concurrent scheduled scripts, not independent CPU threads. There is no timeout or result validation: a script that terminates early/erroring is not distinguished from a successful completion. Each TACOM order record has its own 10-second absolute confirmation deadline.

### Stop

`ALiVE_fnc_OPCOM` `stop` sets `_exitFSM=true` on both conventional FSMs and waits in one-second polling loops for their handler keys to disappear (`fnc_OPCOM.sqf`, `stop`, around 2124-2144). Only ANALYZE, NOT_BUSY, NOT_BUSY_1, and PERFORM_ANALYSIS have priority-99 END edges. END removes `OPCOM_FSM`; that deletion is the observed completion signal.

**Inference:** stop latency depends on reaching one of those four states. States without an exit edge can delay termination. PERFORM_ANALYSIS can exit while analysis children continue, because END only removes the hash key.

## Data contract

### Handler keys

| Key | Observed meaning |
| --- | --- |
| `OPCOM_FSM`, `TACOM_FSM` | Conventional paired FSM handles. INIT waits for both; ORDER_TACOM writes TACOM's mailbox; END removes OPCOM's key. |
| `objectives`, `objectivesByID` | Objective array and ID index. Selection/cleanup iterate the array; QRF/recon/OCA use `getobjectivebyid`. |
| `clusteroccupation` | `[friendly,enemy,contested,timestamp]`. Empty/stale data triggers full analysis. |
| `side`, `factions`, `sidesenemy`, `sidesfriendly` | Force identity/relation input. `factions select 0` is used for ATO/LOGCOM payloads. |
| `controltype`, `simultanobjectives` | Invasion/occupation objective priority and attack concurrency threshold. |
| `reinforcements` | Fractional reinforcement threshold, default 0.9. |
| `startForceStrength`, `currentForceStrength` | Eight-category vectors maintained by `scantroops` and compared after analysis. |
| `knownentities`, `attackedentities`, `pendingorders` | Indirect profile-operation state used by enemy scan, QRF, cleanup, and issued orders. |

Objective hashes must preserve the positional layout used by ANALYZE (documented near `fnc_OPCOM.sqf` lines 3127-3143): ID, center, size, objective type, priority, then `opcom_state` at index 5. Relevant fields/states are:

- `opcom_state`: `unassigned`, `attack`, `defend`, `reserve`, `attacking`, `defending`, `reserving`, `idle`, `internal`.
- `opcom_orders`: `attack`, `defend`, `reserve`, `none`.
- `deleted`: a target guard in confirmation and air-support paths.

### FSM locals

| Variable | Contract |
| --- | --- |
| `_OPCOM_DATA` / `_OPCOM_QUEUE` | Legacy single-slot ingress initialized/reset to `[]`, and authoritative unbounded FIFO work queue. |
| `_unconfirmedOrders` | In-flight TACOM requests as `[orderID, operation, objective, expiresAt]`; selection excludes their objectives until confirmation or expiry. |
| `_nextOrderID`, `_orderConfirmationTimeout` | Monotonic correlation source and per-order acknowledgement deadline. |
| `_busy` | ANALYZE sets true; reset/request/receiver paths clear it. Collector requires false. |
| `_timestamp`, `_lastAnalyze`, `_cycleTime` | Receiver watchdog and analysis scheduling (default cycle 300). |
| `_pause`, `_exitFSM`, `_orderFailed`, `_failsafe` | Pause/stop/recovery controls. |
| `_OPCOM_SKIP_OBJECTIVES` | TACOM-rejected IDs; selection excludes them until RESET clears the list. |
| `_attack`, `_defend`, `_reserve`, `_custom` | Per-pass outputs of ANALYZE for ORDER_TACOM. |
| `_analyze`, `_reinforce`, `_qrf`, `_recon`, `_oca` | Per-pass dispatch variables. |
| `_reinforcementsInProgress` | Blocks a second reinforcement dispatch while multi-wave LOGCOM work runs. |

## Objective and TACOM operation flow

### Analysis and selection

On an `analyze` action, ANALYZE first requests a refresh when `clusteroccupation` is empty/stale or when TACOM asked for `analysis`. This clears busy and routes through cleanup; no order is selected in that turn. A pending reinforcement also pre-empts ordinary selection when no reinforcement is already in progress.

Otherwise ANALYZE seeds the active count with every unconfirmed attack request, then walks every non-skipped objective. It retains only the first item in each of the `unassigned`, `attack`, `defend`, and `reserve` buckets, while adding every `attacking` objective to the active count. An objective with any unconfirmed request is excluded from the scan, preventing its pending attack from being counted twice. A shared capacity check gates both `attack` and `unassigned` selections, because an unassigned objective is issued as an attack. Defend and reserve selection remain unrestricted. Objective-array order is therefore the tiebreaker.

| Control type | First eligible priority |
| --- | --- |
| Invasion | reserve → unassigned/attack when active plus unconfirmed attacks is below `simultanobjectives` → defend |
| Occupation | reserve → defend → attack/unassigned when active plus unconfirmed attacks is below `simultanobjectives` |

An unassigned selection becomes an attack order. Attack/unassigned selection is suppressed if a synchronized `EmptyDetector` trigger on the module is inactive; defend and reserve bypass this gate. The selected hash receives `opcom_orders` before TACOM handoff.

### TACOM boundary

ORDER_TACOM allocates an ID, stores `[orderID, operation, objective, expiresAt]`, appends `["analyze_order",[orderID,operation,objective,expiresAt]]` to `_TACOM_QUEUE`, and immediately resumes ordinary work. TACOM uses the immutable request operation and deadline instead of rereading mutable objective state. It rejects work already expired at dequeue and rechecks the deadline after section planning and before issuing orders, then appends `["confirmed",[boolean,[target,return],orderID,confirmedAt]]` to `_OPCOM_QUEUE`. `ANALYZE` requires that exact correlated confirmation shape and removes only the record matching both ID and objective; malformed, ID-less, stale, and mismatched confirmations are ignored. Expiry is also queued as `expire_order`, preserving FIFO, while `confirmedAt` prevents a late reply from being accepted merely because expiry processing was backlogged.

TACOM reports lifecycle completion with `completed` and `[completedOperation, objective]`. OPCOM owns the lifecycle mapping: recon continues as attack, capture continues as reserve, and defend continues as defend for tactical reassessment. OPCOM rejects deleted objectives and duplicate in-flight follow-ups, then routes accepted follow-ups through the same `ORDER_TACOM` registration path as newly selected work.

On confirmation, ANALYZE:

- sets target `opcom_state` to attacking, defending, or reserving;
- for the highest-priority attacking objective, queries enemy profiles in the objective radius clamped to 200-500 m and calls `ALiVE_fnc_taskRequest` for `CaptureObjective`;
- queues RECON after attack confirmation;
- publishes `OPCOM_ORDER_CONFIRMED` to `ALIVE_eventLog`.

The task-request return is not checked. A failed confirmation adds the ID to the cycle-local skip list, sets `opcom_orders="none"`, primes analysis, and routes to NOT_BUSY. RESET clears the skip list.

`custom` reaches ORDER_TACOM but has no implementation in that state, so it sends no TACOM payload. No defensive checks validate an FSM handle or confirmation/payload shape.

## Profile analysis and operations

### Cleanup and analysis

`cleanupduplicatesections` reads objectives, section members, profile waypoints, and pending orders (`fnc_OPCOM.sqf`, `cleanupduplicatesections`). It resets missing-profile orders; when a non-unassigned/non-idle objective has a nonempty section with zero total waypoints, it resets every section profile and the objective. `resetObjective` clears the section, puts TACOM state to none, OPCOM state to unassigned, danger to -1 and orders to none, and emits `TACOM_ORDER_COMPLETE`. Pending orders for missing profiles or older than 3,600 seconds are deleted.

`PERFORM_ANALYSIS` then launches:

- `analyzeclusteroccupation`: for each objective, uses a 500-m nearby-profile query, writes `clusteroccupation`, and for both conventional modes maps friendly/enemy/contested results to reserve/attack/defend through `setstatebyclusteroccupation`.
- `scantroops`: classifies controlled profiles into infantry, motorized, mechanized, armored, air, sea, artillery, and AAA; refreshes current force (including an explicit zero vector for no profiles) and initializes start force only from a nonempty first snapshot.
- `scanFriendliesForNearEnemies`: scans friendly profiles, performs profile-grid and visibility work, writes `knownentities`, and can create G2 spot reports.

PERFORM_POSTANAL compares start/current vectors, clamps per-category deficit to zero, and prepares `_reinforce` only if both totals are nonzero, LOGCOM is available, and `current / start < _reinforcementRatio`. It always proceeds to RESET and makes no logistics event itself.

### Reinforcement

REQUEST_REEINFOR selects a base through `findReinforcementBase`, using active objectives and reserve/reserving/idle FOB candidates. It starts a detached worker which creates `LOGCOM_REQUEST` events with source `OPCOM`; OPCOM does not await or receive acceptance/delivery/failure.

It explicitly zeroes the air force slot (ATO is expected to handle it). Large infantry/motorized deficits are emitted in waves after 10 seconds with 200-second gaps. The worker sets `_reinforcementsInProgress` only for multi-wave behavior and clears it after the final wave. Missing base or LOGCOM clears the pending FSM variable without a retry.

Observed interface caveat: SCANTROOPS uses an eight-slot vector containing sea, whereas LOGCOM's six-slot makeup treats its sixth slot as helicopters (`addons/mil_logistics/fnc_ML.sqf`, force-makeup contract). The single-request path supplies sea count at that position; multi-wave requests discard it. This is an observed boundary, not a redesign proposal.

### QRF, recon, and OCA

All three air-support states clear their pending variable, set `["analyze",nil]`, clear busy, and return via collector. They do not wait for an acknowledgement.

- REQUEST_QRF resolves objective ID first. Objective targets select a recognized building and make a hard-coded ATO Strike request. Otherwise it treats the target as a profile ID and calls `attackentity` for one section. That helper may request CAS, select profile sections/waypoints, and request artillery; an empty candidate set simply returns.
- REQUEST_RECON requires a live objective, an enemy entity within 1,000 m, size greater than 150, and a matching building. If ATO is available, it waits up to 30 seconds for initialization; successful initialization sends Recce, while timeout or `_exitFSM` skips the event.
- REQUEST_OCA resolves an objective, filters for hangar/radar/airport/control-tower buildings, and sends an OCA request. The event position is one randomly selected building while the full filtered building list is the target array.

ATO event processing is asynchronous through `ALIVE_eventLog`. ATO can reject a request for faction, asset, HQ, type, or sortie-limit reasons with no feedback into this FSM. QRF/OCA skip absent ATO; recon also skips dispatch when an available ATO does not initialize within 30 seconds.

## Invariants, recovery, and failure boundaries

- Conventional operation assumes two valid FSM handles, well-formed handler/objective hashes, and correctly-shaped mailbox payloads. The FSM does not validate all of them.
- One ANALYZE turn prepares at most one ordinary objective order; successive turns drain FIFO actions.
- Collector dispatch requires `_busy=false`. ANALYZE sets it true; the early analysis path and reset/request/receiver paths clear it.
- Deleted objectives are ignored in confirmation and air-support paths. Empty objectives do not stop scheduling, but produce no candidate order.
- Negative confirmations and per-record expiry inject new analysis work; the 300-second receiver failsafe remains separate. Pause blocks receiver-driven recovery, including failsafe; it does not block collector dispatch.
- No timeout covers INIT readiness, cleanup, or spawned analysis. Recon's ATO initialization wait is bounded to 30 seconds and observes `_exitFSM`.
- Post-analysis intentionally requires nonzero current force, so complete force loss does not produce a reinforcement request. When no profiles exist, `scantroops` now clears all category arrays and publishes zero current strength, while leaving `startForceStrength` available as the historical baseline.
- A cleanup/analysis script failure can look like success to the `scriptDone` gate. This is a direct consequence of the gate; no state-level result channel exists.

## Descriptive hot paths

These are observed cost concentrations, not an optimization plan.

1. ANALYZE walks all objectives every normal selection turn even though it keeps one candidate per state.
2. `analyzeclusteroccupation` walks every objective and makes a nearby-profile query for each.
3. Friendly-enemy scanning walks controlled profiles, uses spatial-grid lookups and potentially terrain visibility checks; SCANTROOPS walks all configured-faction profiles.
4. Cleanup walks objectives, section members, and pending orders; base selection walks/sorts relevant objectives.
5. Request states use `nearestObjects` and building filtering over objective radii. Their external event dispatch is asynchronous.

## Source index

- `addons/mil_opcom/opcom.fsm`: state bodies, links, priorities, mailbox/failsafe behavior.
- `addons/mil_opcom/fnc_OPCOM.sqf`: lifecycle, cleanup, profile scans, objective lookup/state setting, reinforcement base, attack-entity behavior.
- `addons/mil_opcom/tacom.fsm`: TACOM data consumer and OPCOM confirmation/QRF/OCA producers.
- `addons/mil_logistics/fnc_ML.sqf`: LOGCOM request/vector contract.
- `addons/mil_ato/fnc_ATO.sqf`: ATO request consumer and sortie acceptance/handling.
- `addons/sys_profile/fnc_getNearProfiles.sqf`: spatial profile querying.

