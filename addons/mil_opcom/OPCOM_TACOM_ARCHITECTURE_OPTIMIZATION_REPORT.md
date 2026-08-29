# OPCOM/TACOM architecture optimization report

## Scope

This report covers the conventional `occupation` and `invasion` paths implemented by:

- `addons/mil_opcom/opcom.fsm`
- `addons/mil_opcom/tacom.fsm`
- their shared implementation in `addons/mil_opcom/fnc_OPCOM.sqf`

Insurgency is intentionally outside scope. The behavioral baseline is documented in:

- `addons/mil_opcom/OPCOM_FSM_KNOWLEDGE.md`
- `addons/mil_opcom/TACOM_FSM_KNOWLEDGE.md`

The aim is to reduce frame cost and repeated work without changing the established public interface: handler and objective shapes, `ALiVE_fnc_OPCOM` operations and return values, FSM handle keys, persistence behavior, event payloads, or conventional mission behavior.

## Executive assessment

OPCOM and TACOM already have a useful high-level division:

- OPCOM owns strategic objective selection, world/force analysis, reinforcement decisions, and requests to ATO/LOGCOM.
- TACOM owns tactical section composition, waypoint issue, order synchronization, and objective completion effects.

The expensive behavior does not primarily come from having two FSMs. It comes from four implementation characteristics:

1. Cross-FSM and waypoint traffic first enters a single mutable mailbox slot, so bursts can overwrite work before the FIFO collector sees it.
2. Derived facts are repeatedly rediscovered from canonical arrays: objective-state candidates, pending-order membership, eligible profiles, nearby occupation, and building candidates.
3. Heavy work is often `spawn`ed but not divided into bounded units. It is asynchronous from the FSM, yet can still consume a large scheduler slice and compete with other spawned analysis jobs.
4. Scheduling uses “time since any analysis action” for multiple meanings. Frequent messages can postpone periodic world analysis, while some spawned work is read before it completes or has no timeout.

The recommended architecture keeps the current public interface as a façade and adds one deep runtime module behind it. That module should own reliable inboxes, derived indexes, work cursors, transaction state, validation, and compatibility adaptation. The FSMs should decide *what happens next*; the runtime implementation should hide *how queues, indexes, and multi-frame jobs are maintained*.

## Compatibility ledger

The following are constraints, not suggested migration targets.

### Preserve unchanged

- Handler keys and values already consumed externally, including `objectives`, `pendingorders`, `ProfileIDsReserve`, profile category arrays, `clusteroccupation`, `knownentities`, `OPCOM_FSM`, and `TACOM_FSM`.
- Objective hashes and their fields. In particular, the positional layout used by `opcom.fsm` must not be reordered.
- Existing `ALiVE_fnc_OPCOM` operation names, aliases, accepted arguments, synchronous/asynchronous behavior visible to callers, and return shapes.
- Existing confirmation, completion, ATO, LOGCOM, task, and event-log payloads.
- `pendingorders` records as `[position, profileID, objectiveID, time]`.
- The `objectives` array as the authoritative ordered priority list.
- Save/load compatibility. Derived runtime state must not be persisted as canonical mission state.
- Legacy access to FSM variables such as `_OPCOM_DATA`, `_TACOM_DATA`, `_pause`, `_exitFSM`, and section-count locals.

### Additive changes that are safe in principle

- New optional handler keys, provided old keys remain authoritative and state extraction excludes ephemeral data.
- New internal operations or helper functions used only by OPCOM/TACOM.
- Shadow indexes that can always be rebuilt from public arrays/hashes.
- Additional fields at the end of internal envelopes, provided legacy payloads are unwrapped before existing consumers see them.
- New FSM states that preserve the old externally observable lifecycle and outcomes.

### Changes to avoid

- Replacing handler/objective hash arrays wholesale with native hash maps.
- Replacing `objectives` or `pendingorders` with a different public representation.
- Changing capture's current negative tactical acknowledgement as part of a performance-only patch.
- Making an existing synchronous `ALiVE_fnc_OPCOM` operation return a script handle instead of its current value.
- Persisting caches, queue cursors, live script handles, or native derived indexes.

## Recommended internal seam

Keep `ALiVE_fnc_OPCOM` as the public façade. Behind it, introduce an internal OPCOM runtime module with a small interface used by both FSMs:

```text
enqueue(destination, legacyMessage, metadata)
nextWork(destination, now)
commitMutation(mutation)
stepJob(jobID, timeBudget)
rebuildDerivedState(reason)
validateDerivedState(level)
```

This is intended as a deep module: callers should not know queue layout, index layout, compaction rules, transaction IDs, job cursors, or repair strategy. Those details belong in its implementation. The public façade remains the external seam; this runtime module is an internal seam shared by the two FSMs and their tests.

Store its rebuildable state under one optional handler key such as `runtime`. Add that key to the exclusion list used by the `state` operation. A possible internal layout is:

```text
runtime
├─ schemaVersion
├─ opcomInbox: [items, head]
├─ tacomInbox: [items, head]
├─ nextMessageSequence
├─ transactionsByID
├─ pendingOrderByProfileID
├─ pendingCountByObjectiveID
├─ objectiveIDsByState
├─ activeObjectiveCount
├─ eligibleProfileIDsByType
├─ objectiveBuildingCandidates
├─ analysisJob
└─ diagnostics
```

`objectives`, `pendingorders`, objective `section`, and the current indexes remain canonical. Runtime structures are shadows: rebuild on start, load, control-type change, detected inconsistency, and developer request.

## Prioritized findings and improvements

### P0 — Replace internal single-slot writes with reliable enqueue

#### Observed problem

`_OPCOM_DATA` and `_TACOM_DATA` are single mutable slots. Collection into FIFO occurs later and only in states that expose a receiver link. Internal producers include both FSMs and every issued profile waypoint. Several profile completions can therefore write `_TACOM_DATA` before TACOM reaches `COLLECT_TO_QUEUE`; only the latest value is guaranteed to remain. OPCOM confirmations, QRF, OCA, and analysis messages have the same structural risk.

This is both a correctness problem and a performance problem. Lost completion messages leave `pendingorders` alive until another completion, repair, death, or the one-hour stale cleanup. The system then performs extra synchronization and cleanup work around an order that already completed.

#### Recommended flow

- Change all *internal* producers to call `enqueue` directly instead of setting the scalar FSM variable.
- Give every internal message a monotonically increasing sequence and enqueue timestamp.
- Give order request/confirmation pairs a correlation ID stored only in the runtime envelope.
- Store inboxes as append-only arrays plus a head index. Do not use `deleteAt 0` on every dequeue; compact occasionally when the head passes a threshold.
- Preserve `_OPCOM_DATA` and `_TACOM_DATA` as legacy ingress. A compatibility adapter checks them, enqueues the legacy two-element payload, then clears the slot.
- Unwrap internal metadata before invoking the existing dispatch logic, so current payload shapes and events remain unchanged.

Legacy external writers can still overwrite each other before adaptation, but converting all internal high-volume writers removes the dominant risk without breaking compatibility.

#### Queue policy

- Never coalesce `confirmed` or `completed` messages.
- Coalesce duplicate maintenance `analyze` requests when no payload depends on them.
- QRF/OCA/RECON may only be coalesced by identical target and operation.
- Process confirmations/completions ahead of maintenance, but guarantee a periodic analysis turn after a bounded number of tactical messages.
- Record maximum depth and oldest-message age; do not silently drop on overflow.

### P0 — Separate activity time from world-analysis deadlines

#### Observed problem

OPCOM writes `_lastAnalyze = time` after every `ANALYZE` action, including confirmations and air-support messages. TACOM similarly updates `_lastanalyze` after queue actions. Under sustained traffic, “time since last action” can remain small indefinitely and postpone periodic occupation/force/enemy analysis.

#### Recommendation

Use separate clocks:

- `lastMessageDispatchAt`
- `lastWorldAnalysisStartedAt`
- `lastWorldAnalysisCommittedAt`
- `nextWorldAnalysisAt`
- `lastEnemyScanCommittedAt`

Only a committed world analysis advances `nextWorldAnalysisAt`. Tactical activity must not reset it. When the deadline is reached, schedule maintenance even if messages continue, subject to a small fairness bound rather than an all-or-nothing priority.

This change can be added internally while retaining `_lastAnalyze` for monitor compatibility.

### P0 — Make analysis publication transactional

#### Observed problem

`PERFORM_ANALYSIS` launches occupation, troop, and enemy scans together and waits only for `scriptDone`. The scripts publish separate handler keys as they finish. Consumers can therefore see values produced from different moments. Script termination is treated like success because there is no result channel.

`scantroops` also returns early when no profiles exist without clearing the previously published category and force-strength keys. TACOM's internal enemy scan is spawned and `knownentities` is read immediately, so it can deliberately consume the prior snapshot.

#### Recommendation

Build an analysis job with a private result buffer:

1. Capture objective/profile generation and start time.
2. Produce occupation, force, and enemy results into job-local fields.
3. Validate required fields and generation before publication.
4. Commit all public handler keys together.
5. On error/timeout, keep the last valid snapshot, record failure, and retry with backoff.

Zero profiles must commit empty profile categories and a zero `currentForceStrength` vector. TACOM should request the shared enemy snapshot; if it is stale, start or join the scan and continue only after the new result commits.

### P0 — Add bounded waits and owned-child cleanup

The following waits have no effective failure bound:

- paired-handle readiness in both `INIT` states;
- OPCOM cleanup and analysis job waits;
- TACOM section-selection wait;
- recon waiting for ATO initialization;
- `stop`, load, and control-type change waiting for FSM-key removal.

Add a deadline and explicit recovery result to every job. New recovery states should cancel child handles owned by the job, clear only their tentative data, emit diagnostics, and return to a known queue state. `END` should terminate registered child jobs before removing its FSM key. `stop` should have a bounded fallback that records which state failed to acknowledge shutdown.

Do not use one universal timeout. For example, order acknowledgement may remain near its current short deadline, while a large analysis job gets a configurable item/time budget and a much longer wall-clock deadline.

### P0 — Correct narrow observed hazards before measuring performance

These are small, high-confidence fixes with disproportionate debugging value:

- TACOM's attack/OCA branch must derive the objective ID from the current objective before sending OCA; it currently reads `_objectiveID` without establishing it in that branch.
- Reset `_TAC_confirmed` and `_data` at `ISSUE_ORDERS` entry so custom/unknown operations cannot inherit stale state.
- Treat an empty `setSectionOrders` result as no issued order even if `section` was nonempty but all profile IDs were stale.
- Publish empty troop arrays/zero force strength on a zero-profile scan.
- Bound the ATO initialization wait and fail best-effort recon cleanly.
- On TACOM internal scan, wait for the scan result or consume an explicitly versioned last-known snapshot rather than assuming the spawned scan is current.

These preserve public shapes and should precede deeper optimization so profiling reflects valid state.

## Derived data structures

### Objective state index

Add ordered `objectiveIDsByState` buckets and `activeObjectiveCount`.

Requirements:

- Bucket order must match the canonical `objectives` array, because current priority uses first-in-array semantics.
- `objectives` remains authoritative.
- Core internal state mutations should pass through `commitMutation`, which updates the objective and bucket together.
- Direct external objective mutation remains supported. Mark the index dirty on known external entry points and rebuild periodically or when validation detects a mismatch.
- Rebuild after load, add/remove/reorder, control-type change, and state restore.

This removes the recurring full objective scan from normal order selection. It does not remove the occupation scan, which is spatial analysis rather than ID lookup.

An even safer first step is to build the buckets while committing `analyzeclusteroccupation`, then use that snapshot until a later mutation marks it dirty. That fuses two objective passes without requiring perfect incremental maintenance on day one.

### Pending-order indexes

Keep `pendingorders` unchanged and add:

- `pendingOrderByProfileID: profileID -> record/index`
- `pendingCountByObjectiveID: objectiveID -> count`

Use them to:

- replace linear profile lookup in `synchronizeorders`;
- determine “last completion” in constant expected time;
- remove/reissue an existing profile order without scanning all pending records;
- visit only objectives with assigned/pending work during cleanup;
- distinguish profile IDs from full pending-order records in availability filtering.

Array mutations and shadow indexes must go through one implementation. A diagnostic rebuild compares both representations and repairs the shadows, never the public array silently.

### Profile eligibility sets

Keep the public category arrays, but derive native hash-map sets for membership tests:

```text
eligibleProfileIDsByType[type][profileID] = true
assignedProfileIDs[profileID] = objectiveID
reservedProfileIDs[profileID] = true
pendingProfileIDs[profileID] = true
```

`NearestAvailableSection` currently performs array membership/subtraction while processing repeated expanding-radius results. Sets make these tests constant expected time and remove ambiguity between pending-order records and profile IDs.

Rebuild eligibility after the troop snapshot commits. Apply live busy/stationary/static-AA/travel checks immediately before assignment so a cached category never authorizes a stale profile.

### Building-candidate cache

Objective centers/sizes and map buildings are normally static. Cache per objective:

- recon-compatible buildings;
- OCA-compatible buildings;
- QRF/strike-compatible buildings if its filter differs.

Cache objective IDs and object references, not event payloads. Validate `!isNull` before use and invalidate on objective remove/recreate, state load, or explicit cache rebuild. This removes repeated `nearestObjects` plus substring scans from support requests.

### Transaction registry

Maintain internal transaction records for OPCOM→TACOM orders and detached LOGCOM/ATO work:

```text
transactionID -> [kind, objectiveID, state, createdAt, deadline, childHandles]
```

This registry does not replace current boolean confirmation/event shapes. It provides correlation, duplicate suppression, timeout ownership, shutdown cleanup, and diagnostics behind the compatibility adapter.

For reinforcement, use a request cooldown/in-flight record even for a single wave. The current multi-wave flag does not cover all detached requests, so a new analysis can request more before delivered forces appear in `currentForceStrength`.

## Multi-frame execution

`spawn` makes work scheduled; it does not guarantee a useful per-frame budget. Divide large loops into explicit jobs with cursors and a small time budget.

### Budget policy

- Prefer a `diag_tickTime` budget over a fixed item count because objectives and profiles have unequal costs.
- Check the budget every small block (for example, 8 items) rather than after every item.
- Yield with the established CBA scheduling mechanism or an FSM wait state.
- Store cursor, partial results, source generation, deadline, and last progress time in the runtime job.
- Commit only when complete and validated.
- Allow high-priority completion/confirmation messages between batches.

Engine commands such as `nearestObjects`, terrain intersection, pathfinder calls, or a single spatial query may remain atomic. The surrounding iteration and sorting can still be split, cached, or reduced.

### OPCOM analysis states

Replace the opaque three-spawn wait with an explicit sub-flow:

```text
ANALYSIS_BEGIN
  -> ANALYSIS_OBJECTIVES_BATCH
  -> ANALYSIS_FORCES_BATCH
  -> ANALYSIS_ENEMIES_BATCH
  -> ANALYSIS_COMMIT
  -> PERFORM_POSTANAL

any batch timeout/error -> ANALYSIS_RECOVER -> queue
```

The jobs may round-robin rather than run strictly sequentially, but only one expensive batch should consume the configured OPCOM budget at a time. `ANALYSIS_COMMIT` publishes the coherent snapshot and advances the world-analysis deadline.

### TACOM section and issue states

Use:

```text
SECTION_SELECT_BEGIN
  -> SECTION_SELECT_BATCH
  -> SECTION_SELECT_COMMIT
  -> ISSUE_ORDERS_BEGIN
  -> ISSUE_ORDERS_BATCH
  -> ISSUE_ORDERS_COMMIT

timeout/deletion/stop -> ORDER_RECOVER
```

`SECTION_SELECT_BATCH` should:

- use eligibility sets;
- track `seenProfileIDs` across expanding radii so profiles are not re-filtered at 2, 4, 6, ... km;
- stop when it has enough valid candidates, not when it has strictly more than requested;
- maintain only the best requested candidates instead of sorting an unnecessarily large array;
- validate chosen profiles again at commit.

`ISSUE_ORDERS_BATCH` should install a bounded number of profile orders per frame. The existing public `setSectionOrders` remains synchronous for external callers; the FSM uses a new internal job path. Confirmation is sent only after the whole batch commits or an explicit partial/failure outcome is determined.

## Flow improvements

### Make inbox collection state-independent

Once producers enqueue into the runtime module, receiving no longer depends on whether the current FSM state has a receiver link. The FSM only needs a `DEQUEUE_WORK` decision state. This eliminates duplicated receiver predicates and allows stop/urgent completions to be observed while a multi-frame job is between batches.

Keep legacy scalar ingestion in the existing receiver-compatible paths and in `DEQUEUE_WORK`.

### Separate plan, side effects, and completion

The current `ANALYZE` and `ISSUE_ORDERS` states mix decision logic, mutation, external requests, and acknowledgement. Split them conceptually:

1. Build a pure plan from a snapshot.
2. Validate the plan against current generations.
3. Commit objective/assignment mutations.
4. Perform side effects through adapters (waypoints, events, ATO, LOGCOM).
5. Record and transmit the existing result shape.

This deepens the runtime module and gives tests a stable seam: a plan can be checked without spawning profiles or requiring a live event log.

### Use one enemy-scan producer

OPCOM and TACOM both initiate friendly-near-enemy scanning. Maintain one versioned snapshot with `startedAt`, `committedAt`, `inProgress`, and consumer freshness requirements. TACOM can accept the last snapshot for low-priority internal reaction or join an in-flight refresh; it should not launch a duplicate scan and immediately read the old key.

### Keep support requests best-effort but observable

ATO/LOGCOM behavior may remain asynchronous and best-effort for compatibility. Record internal outcomes:

- not requested: no objective/building/module;
- queued to event log;
- rejected/expired when feedback exists;
- unknown after dispatch.

This avoids adding public callbacks while making repeated failures and wasted building scans visible in profiling.

### Improve stop as a control message

Enqueue a high-priority internal stop token and set `_exitFSM` for legacy behavior. Each multi-frame state checks the token between batches, cancels owned children, and enters END. END removes the same handler FSM key as today. The public `stop` operation retains its result, but its internal wait becomes bounded and diagnostic.

## Simple improvements with low implementation risk

These can be performed before the larger runtime work, provided parity tests exist:

1. Cache synchronized attack-gate triggers during initialization instead of rescanning all synchronized objects on each attack/unassigned selection.
2. Cache lowercase building-type lists and per-objective candidates.
3. Use a head index for both FSM FIFO arrays to avoid `deleteAt 0` shifting backlog entries.
4. Convert troop/category arrays to local membership sets inside `NearestAvailableSection`, even before persistent eligibility sets exist.
5. Track `seenProfileIDs` across expanding radius queries.
6. Stop radius expansion when `count candidates >= requestedSize` rather than requiring more candidates than requested.
7. Restrict duplicate-section cleanup to objective IDs present in `profileObjectiveAssignment`/pending indexes, retaining a periodic full repair pass.
8. Reuse `objectivesByID` and `profileObjectiveAssignment` on normal paths; retain full scans only as explicit repair fallbacks.
9. Avoid rebuilding or logging debug-only objective state counts when debug/monitoring is disabled.
10. Validate message tags and minimum payload shape before `select`/`params`; malformed work should be diagnosed and quarantined, not crash a state.

## Spatial optimization decision

Do not add a second general spatial grid immediately. `ALIVE_fnc_getNearProfiles` already uses the profile spatial grid. First optimize the callers:

- eliminate duplicate scans;
- cache eligibility membership;
- avoid reprocessing profiles across expanding radii;
- batch objective queries;
- profile spatial-query duration and returned-candidate counts.

If `analyzeclusteroccupation` remains dominant, then evaluate a batch interface over the existing spatial-grid implementation. A useful batch operation would accept all objective circles and a side filter, reuse cell results across overlapping circles, and return occupation classifications. That creates leverage at the existing spatial seam without maintaining a competing position index.

## Validation strategy

### Behavioral parity tests

Test through the preserved public interface and observable event/profile outcomes:

- occupation and invasion objective priority order;
- one ordinary order per strategic turn;
- inactive trigger suppression for attack/unassigned only;
- positive/negative TACOM confirmation behavior;
- capture's current acknowledgement semantics;
- recon→capture, defend→reserve, and reserve→idle progression;
- skip-list reset behavior;
- pause, stop, load, and control-type change;
- exact operation aliases and return shapes;
- exact public handler/objective/pending-order/event shapes.

### Reliability tests

- Deliver many waypoint completions in one frame; every profile must be synchronized exactly once.
- Interleave confirmation, QRF, OCA, and analysis messages; no message may be overwritten.
- Remove an objective/profile during section selection and order issue.
- Stop during every FSM state and every new batch state.
- Simulate a child-job error and timeout; last good snapshot must remain visible.
- Transition from nonzero profiles to zero profiles; category arrays and current strength must become empty/zero.
- Verify OCA always carries the current objective ID.
- Rebuild every derived index from canonical data and compare equality.

### Invariant checks

- Every profile in an objective `section` maps to that objective in `profileObjectiveAssignment`.
- A profile belongs to at most one objective section.
- `objectivesByID` resolves every nondeleted canonical objective and no deleted one.
- State buckets contain each live objective exactly once and preserve canonical priority order.
- `pendingOrderByProfileID`, `pendingCountByObjectiveID`, and `pendingorders` agree.
- A committed analysis snapshot has one version/timestamp across occupation, force, and enemy results.
- Every live runtime transaction has a deadline and owned-child list.

### Performance fixtures

Measure at representative sizes, for example 20/80/200 objectives and low/medium/high profile counts:

- time and maximum single-frame cost per FSM state and `ALiVE_fnc_OPCOM` operation;
- objectives/profiles/buildings processed;
- spatial query count, returned candidate count, and repeated candidate count;
- inbox depth, oldest age, and dequeue cost;
- pending-order count and oldest age;
- analysis snapshot age and job batch count;
- section search maximum radius and candidates rejected by reason.

Use percentiles and worst-frame cost, not only total scheduled-script duration.

## Suggested implementation order

### Phase 0 — Establish correctness and measurement

- Add parity/invariant tests and lightweight counters.
- Fix OCA objective identity, stale issue state, zero-profile publication, stale immediate enemy read, and unbounded recon initialization wait.
- Add explicit job outcomes and diagnostics around current spawned analysis/selection.

### Phase 1 — Reliable runtime messaging

- Introduce the runtime module and exclude it from saved state.
- Convert internal OPCOM/TACOM/waypoint writers to reliable enqueue.
- Add queue head indexes, sequence IDs, correlation, and legacy scalar adapters.
- Add pending-order shadow indexes.

### Phase 2 — Cheap derived indexes and caches

- Add objective-state buckets/active count.
- Add profile eligibility sets.
- Cache trigger lists and building candidates.
- Reduce cleanup to assigned/pending objectives with periodic full validation.
- Optimize expanding-radius selection with seen sets and bounded top candidates.

### Phase 3 — Explicit multi-frame jobs and states

- Introduce transactional OPCOM analysis states.
- Introduce TACOM section-selection/order-issue batch states.
- Add deadlines, recovery states, child ownership, and bounded stop.
- Separate world-analysis deadlines from message activity.

### Phase 4 — Spatial batch work if profiling still justifies it

- Extend the existing profile spatial seam with batched objective occupation queries.
- Re-profile before considering any additional spatial structure.

## Expected result

The target shape retains the familiar OPCOM/TACOM public interface and mission behavior while changing the implementation underneath:

- messages are lossless and correlated;
- canonical arrays/hashes remain compatible;
- repeated selections use rebuildable indexes;
- analysis publishes coherent versioned snapshots;
- heavy loops advance within a frame budget;
- stop and error paths are bounded;
- expensive spatial/building work is reused rather than rediscovered;
- the FSMs express strategic/tactical flow instead of also owning queue and index mechanics.

That preserves the current shape while making the implementation more performant, recoverable, testable, and easier to evolve.
