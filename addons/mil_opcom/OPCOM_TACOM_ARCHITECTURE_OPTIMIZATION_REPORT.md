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

1. Legacy scalar ingress remains a single mutable mailbox slot, but current internal cross-FSM and waypoint traffic appends directly to the existing FIFO queues.
2. Derived facts are repeatedly rediscovered from canonical arrays: objective-state candidates, pending-order membership, eligible profiles, nearby occupation, and building candidates.
3. Heavy work is often `spawn`ed but not divided into bounded units. It is asynchronous from the FSM, yet can still consume a large scheduler slice and compete with other spawned analysis jobs.
4. Scheduling uses “time since any analysis action” for multiple meanings. Frequent messages can postpone periodic world analysis, while several spawned jobs still have no timeout or validated result channel.

The recommended architecture keeps the current public interface as a façade and improves the implementation in stages. The first stage is deliberately small: make the existing `_OPCOM_QUEUE` and `_TACOM_QUEUE` arrays the authoritative internal inboxes and have internal producers append their existing two-element messages directly. Broader runtime indexes, jobs, and validation seams remain later proposals rather than prerequisites for reliable messaging.

## Compatibility ledger

The following are constraints, not suggested migration targets.

### Preserve unchanged

- Handler keys and values already consumed externally, including `objectives`, `pendingorders`, `ProfileIDsReserve`, profile category arrays, `clusteroccupation`, `knownentities`, `OPCOM_FSM`, and `TACOM_FSM`.
- Objective hashes and their fields. In particular, the positional layout used by `opcom.fsm` must not be reordered.
- Existing `ALiVE_fnc_OPCOM` operation names, aliases, accepted arguments, synchronous/asynchronous behavior visible to callers, and return shapes.
- Existing public confirmation, completion, ATO, LOGCOM, task, and event-log payloads. The private OPCOM/TACOM confirmation envelope may append a correlation ID while retaining legacy input support.
- `pendingorders` records as `[position, profileID, objectiveID, time]`.
- The `objectives` array as the authoritative ordered priority list.
- Save/load compatibility. Derived runtime state must not be persisted as canonical mission state.
- Legacy access to FSM variables such as `_OPCOM_DATA`, `_TACOM_DATA`, `_pause`, `_exitFSM`, and section-count locals.

### Additive changes that are safe in principle

- New optional handler keys, provided old keys remain authoritative and state extraction excludes ephemeral data.
- New internal operations or helper functions used only by OPCOM/TACOM.
- Shadow indexes that can always be rebuilt from public arrays/hashes.
- New internal metadata, provided it is introduced only after a demonstrated need and existing consumers continue to receive the current payload shapes.
- New FSM states that preserve the old externally observable lifecycle and outcomes.

### Changes to avoid

- Replacing handler/objective hash arrays wholesale with native hash maps.
- Replacing `objectives` or `pendingorders` with a different public representation.
- Changing capture's current negative tactical acknowledgement as part of a performance-only patch.
- Making an existing synchronous `ALiVE_fnc_OPCOM` operation return a script handle instead of its current value.
- Persisting caches, queue cursors, live script handles, or native derived indexes.

## Recommended internal seam

Keep `ALiVE_fnc_OPCOM` as the public façade. For the first change, do not add a handler `runtime` object or a new queue abstraction. Reuse the two queues already owned by the FSMs:

```text
_OPCOM_QUEUE = [[operation, payload], ...]
_TACOM_QUEUE = [[operation, payload], ...]
```

Internal producers obtain the destination queue and `pushBack` the unchanged legacy-shaped entry. The destination FSM removes entries in FIFO order and dispatches them through its existing logic. `_OPCOM_DATA` and `_TACOM_DATA` remain compatibility ingress for code that still writes the scalar variables. Both are initialized to `[]`; on each receiver iteration, a nonempty legacy value wakes the FSM, and `COLLECT_TO_QUEUE` appends it to the corresponding queue before resetting the slot to `[]`.

Conceptually, an internal write becomes:

```sqf
(_TACOM_FSM getFSMVariable "_TACOM_QUEUE") pushBack ["analyze_order", [_orderID, _operation, _objective, _expiresAt]];
```

The queues must therefore be initialized before their FSM handles are published to producers, as they are today. A small internal helper may later centralize destination lookup and diagnostics, but it is not necessary to establish the queue contract.

This seam is intentionally narrow. It fixes the overwrite hazard without changing handler state, save data, operation payloads, or return values. A deeper runtime module may still become useful for derived indexes and multi-frame jobs, but it should be introduced independently and only where its leverage justifies the added structure.

## Prioritized findings and improvements

### P0 — Replace internal single-slot writes with reliable enqueue

#### Baseline problem, addressed for internal producers

`_OPCOM_DATA` and `_TACOM_DATA` were the single mutable path used by internal producers. Collection into FIFO occurred later and only in states that exposed a receiver link. Several profile completions could therefore write `_TACOM_DATA` before TACOM reached `COLLECT_TO_QUEUE`; only the latest value was guaranteed to remain. OPCOM confirmations, QRF, OCA, and analysis messages had the same structural risk.

This was both a correctness problem and a performance problem. Lost completion messages could leave `pendingorders` alive until another completion, repair, death, or the one-hour stale cleanup, causing extra synchronization and cleanup around an order that had already completed.

#### Implemented flow

- `_OPCOM_QUEUE` and `_TACOM_QUEUE` are the authoritative internal inboxes.
- Internal producers `pushBack` `[operation, payload]` entries onto the destination queue. Correlated OPCOM orders use the internal `analyze_order` envelope described below.
- `_OPCOM_DATA` and `_TACOM_DATA` remain legacy single-slot ingress initialized to `[]`. Each receiver iteration tests whether the slot is nonempty; `COLLECT_TO_QUEUE` appends that entry, resets the slot to `[]`, and then proceeds with any work already present in the queue.
- Receiver/wake conditions test queue depth as well as whether the legacy scalar contains a nonempty array, so queue-only work wakes TACOM while `_TACOM_DATA` is `[]`.
- OPCOM's `ORDER_TACOM` registers an in-flight record, queues the request, and immediately returns to normal dispatch.
- Ordinary consumption retains the existing FIFO behavior, including `deleteAt 0`.
- Confirmations are ordinary queued messages and are correlated when `ANALYZE` reaches them.

Legacy external writers can still overwrite each other if they write the same scalar slot repeatedly before collection. That residual behavior preserves legacy access without adding a compatibility layer; converting all internal high-volume writers removes the dominant risk.

The initial producer conversion includes:

- OPCOM order transmission to TACOM (`analyze_order` with order ID, operation, objective, and absolute deadline);
- TACOM confirmation, QRF, and OCA transmission to OPCOM;
- waypoint completion callbacks writing `completed` messages to TACOM;
- OPCOM/TACOM initialization, request, reset, and other self-messages;
- exact-profile `addTask` transmission (`manual_order` with operation, transient objective, and supplied profile IDs), plus the remaining internal initialization, reset, and self-message producers.

#### Queue policy

- Ordinary dispatch remains strict FIFO.
- Multiple tactical requests may be in flight. OPCOM stores each as `[orderID, operation, objective, expiresAt]` and excludes that objective from reselection until the record is confirmed or expires.
- `ORDER_TACOM` sends `['analyze_order',[orderID,operation,objective,expiresAt]]`; TACOM uses the immutable operation/deadline snapshot, rejects expired work before tactical issue, and returns `['confirmed',[boolean,[objective,details],orderID,confirmedAt]]`.
- Confirmation dispatch removes only the record matching both order ID and objective. Late or duplicate confirmations are ignored and cannot resolve a newer retry for the same objective.
- A delayed callback queues `expire_order` at each deadline. Expiry therefore observes FIFO order, and the confirmation timestamp distinguishes an on-time reply delayed by backlog from a reply actually produced after its deadline.
- Unconfirmed attack requests consume `simultanobjectives` capacity immediately. New attack selection requires the combined confirmed-active and pending-attack count to remain strictly below the configured limit.
- TACOM queues `completed` with the completed tactical operation and objective. OPCOM owns the lifecycle mapping, deduplicates the resulting follow-up against live records, and sends it through the normal correlated order path, preserving recon→attack, capture→reserve, and defend reassessment without relying on generic objective selection.
- `addTask` queues a self-contained `manual_order` carrying operation, transient internal objective, and an exact deduplicated profile-ID list. TACOM never supplements that list, suppresses normal correlated confirmation/continuation, and removes the transient objective after failure or final completion.
- No coalescing, ordinary-message reordering, priority lanes, overflow dropping, or backpressure in the first patch.
- No head cursor or compaction policy in the first patch; optimize dequeue mechanics only if profiling shows meaningful queue-shift cost.

This policy makes the correction easy to audit: every internal write becomes one append, ordinary work dispatches in insertion order, and order lifecycle state is isolated in the in-flight registry rather than encoded in the FSM's current state.

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

The current tree already closes two independent stale-publication cases: `scantroops` publishes empty categories and zero current force strength when no profiles exist, and TACOM reacts to an `enemy_scan_complete` queue entry instead of reading `knownentities` immediately after spawn. The broader analysis pass still publishes occupation, troop, and enemy fields independently, so consumers can observe mixed-generation data.

#### Recommendation

Build an analysis job with a private result buffer:

1. Capture objective/profile generation and start time.
2. Produce occupation, force, and enemy results into job-local fields.
3. Validate required fields and generation before publication.
4. Commit all public handler keys together.
5. On error/timeout, keep the last valid snapshot, record failure, and retry with backoff.

Zero profiles must commit empty profile categories and a zero `currentForceStrength` vector. TACOM should request the shared enemy snapshot; if it is stale, start or join the scan and continue only after the new result commits.

### P0 — Add bounded waits and owned-child cleanup

The following waits still have no effective failure bound:

- paired-handle readiness in both `INIT` states;
- OPCOM cleanup and analysis job waits;
- TACOM section-selection wait;
- `stop`, load, and control-type change waiting for FSM-key removal.

Recon's ATO initialization wait is now bounded to 30 seconds and observes `_exitFSM`; the remaining waits should receive job-specific deadlines rather than inheriting that value.

Add a deadline and explicit recovery result to every job. New recovery states should cancel child handles owned by the job, clear only their tentative data, emit diagnostics, and return to a known queue state. `END` should terminate registered child jobs before removing its FSM key. `stop` should have a bounded fallback that records which state failed to acknowledge shutdown.

Do not use one universal timeout. For example, order acknowledgement may remain near its current short deadline, while a large analysis job gets a configurable item/time budget and a much longer wall-clock deadline.

### P0 — Correct narrow observed hazards before measuring performance

These small, high-confidence fixes are implemented in the current tree:

- TACOM's attack/OCA branch derives the objective ID from the current objective before sending OCA.
- `ISSUE_ORDERS` resets `_TAC_confirmed` and `_data` on entry so custom/unknown operations cannot inherit stale state.
- An empty `setSectionOrders` result is treated as no issued order even if `section` was nonempty but all profile IDs were stale.
- A zero-profile scan publishes empty troop arrays and zero current force strength.
- Recon bounds ATO initialization to 30 seconds and skips best-effort dispatch on timeout or stop.
- TACOM internal scans enqueue their completed result; TACOM no longer assumes a newly spawned scan has already updated `knownentities`.

These preserve public shapes and should precede deeper optimization so profiling reflects valid state.

### P0 — Track multiple in-flight tactical orders

#### Implemented correction

`ORDER_TACOM` no longer blocks the OPCOM FSM waiting for one target. It allocates a monotonic order ID, records the objective and absolute deadline, includes that deadline in the correlated TACOM request, and resumes strategic dispatch. TACOM rejects requests that expired in its queue and rechecks the deadline after section planning and before issue. This allows unrelated objectives and queued messages to progress while TACOM works serially through its inbox without stale requests producing tactical side effects.

TACOM echoes the order ID in its positive or negative confirmation. Confirmations remain ordinary FIFO entries; OPCOM handles them only when dequeued and accepts one only when ID and objective both match a live record. Records expire independently, and a scheduled wake ensures an idle OPCOM eventually performs the expiry check. Late, duplicate, or mismatched confirmations are ignored.

The legacy scalar ingress remains accepted, but confirmations require the full correlated envelope. Confirmations without an ID, malformed payloads, and ID/objective mismatches are ignored. TACOM reports lifecycle completion to OPCOM so the next tactical request is registered through the same path.

### P0 — Own TACOM enemy-scan lifetime and ordering

#### Implemented correction

TACOM now owns one enemy-scan worker with an in-flight flag, active generation, script handle, and 120-second deadline. `_lastEnemyScan` is a committed-scan timestamp: it advances only after TACOM accepts the active generation, so an active worker cannot be duplicated merely because it runs longer than the normal 60-second interval.

Internal completion payloads carry their generation. TACOM accepts a completion only when it is still running, owns that generation, and remains within its deadline. Timed-out or failed workers release ownership; late/superseded completions are ignored; `END` terminates a live owned worker. The scan operation's existing public behavior remains the default, while TACOM uses an internal no-publish option and commits `knownentities` plus spot reports only after accepting the generation. Thus a discarded worker cannot publish shared scan state or cause QRF/infantry reactions.

The later single-producer analysis design should absorb this ownership model so OPCOM and TACOM can join the same versioned scan rather than independently repeating the expensive profile/visibility walk.

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
- Check the destination queue between batches so ordinary FIFO messages are not delayed for the full duration of a multi-frame job.

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

Once producers append to the existing FSM queues, receiver transitions must inspect queue depth directly rather than depend on a scalar write. A later `DEQUEUE_WORK` decision state could centralize the duplicated receiver predicates, but it is not required for the initial correction.

Keep legacy scalar ingestion in `COLLECT_TO_QUEUE` and any existing receiver-compatible paths. If `DEQUEUE_WORK` is introduced later, it must retain that adapter.

### Separate plan, side effects, and completion

The current `ANALYZE` and `ISSUE_ORDERS` states mix decision logic, mutation, external requests, and acknowledgement. Split them conceptually:

1. Build a pure plan from a snapshot.
2. Validate the plan against current generations.
3. Commit objective/assignment mutations.
4. Perform side effects through adapters (waypoints, events, ATO, LOGCOM).
5. Record and transmit the existing result shape.

This creates a focused internal planning seam and gives tests a stable target: a plan can be checked without spawning profiles or requiring a live event log.

### Use one enemy-scan producer

OPCOM and TACOM both initiate friendly-near-enemy scanning. Maintain one versioned snapshot with `generation`, `startedAt`, `committedAt`, `inProgress`, owner/worker handle, deadline, and consumer freshness requirements. TACOM can accept the last snapshot for low-priority internal reaction or join an in-flight refresh. Only the active generation may publish or cause a tactical reaction; late generations are discarded.

### Keep support requests best-effort but observable

ATO/LOGCOM behavior may remain asynchronous and best-effort for compatibility. Record internal outcomes:

- not requested: no objective/building/module;
- queued to event log;
- rejected/expired when feedback exists;
- unknown after dispatch.

This avoids adding public callbacks while making repeated failures and wasted building scans visible in profiling.

### Improve stop as a control message

Keep `_exitFSM` as the stop signal so shutdown does not require queue priority. Each multi-frame state checks it between batches, cancels owned children, and enters END. END removes the same handler FSM key as today. The public `stop` operation retains its result, but its internal wait becomes bounded and diagnostic.

## Simple improvements with low implementation risk

These can be performed before the larger runtime work, provided parity tests exist:

1. Cache synchronized attack-gate triggers during initialization instead of rescanning all synchronized objects on each attack/unassigned selection.
2. Cache lowercase building-type lists and per-objective candidates.
3. Profile FIFO dequeue cost after reliable append is deployed; add a head index only if `deleteAt 0` shifting is material at observed queue depths.
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
- Verify internal messages are dispatched in the same order they were appended.
- Queue unrelated OPCOM work before a TACOM confirmation; all entries must remain FIFO and the confirmation must be processed only on its ordinary turn.
- Dispatch several different objectives before confirmations arrive; each must have an independent ID and deadline, and none may be selected again while in flight.
- Expire an order, retry the same objective, then deliver the old confirmation; the old ID must not remove or resolve the retry.
- Exercise positive, negative, duplicate, mismatched, malformed/ID-less, and timeout outcomes.
- Verify `_OPCOM_DATA` and `_TACOM_DATA` initialize to `[]`.
- Write a legacy entry through each scalar slot; every nonempty entry must be appended, reset to `[]`, and dispatched without disturbing entries already queued.
- Verify both FSMs wake and drain work when their scalar data slot is `[]` but their queue is nonempty.
- Remove an objective/profile during section selection and order issue.
- Stop during every FSM state and every new batch state.
- Simulate a child-job error and timeout; last good snapshot must remain visible.
- Transition from nonzero profiles to zero profiles; category arrays and current strength must become empty/zero.
- Verify OCA always carries the current objective ID.
- Delay an enemy scan beyond its normal interval; no overlapping TACOM scan may start, and only the active generation may cause one reaction.
- Deliver enemy-scan completions out of order and after stop/timeout; superseded results must be ignored and failed workers must eventually release scan ownership.
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
- Completed: fix OCA objective identity, stale issue state, empty issued batches, zero-profile publication, stale immediate enemy reads, and unbounded recon initialization wait.
- Completed: replace the single blocking `_orderTarget` handshake with correlated in-flight records, per-order deadlines, and ordinary queued confirmations.
- Completed: own TACOM enemy scans by generation/handle/deadline, defer publication until acceptance, and ignore late completions.
- Add explicit job outcomes and diagnostics around current spawned analysis/selection.

### Phase 1 — Reliable FIFO messaging

- Completed: make the existing queues authoritative, convert internal writers to direct append, wake on queue-only work, and process correlated TACOM confirmations as ordinary FIFO messages.
- Completed: retain `_OPCOM_DATA` and `_TACOM_DATA` as scalar legacy ingress initialized/reset to `[]`, without introducing a separate compatibility layer.
- Completed: preserve FIFO ordinary dispatch and the current `deleteAt 0` dequeue behavior.
- Remaining: add burst, FIFO-order, queue-only wake, and legacy-ingress runtime tests.

### Phase 2 — Cheap derived indexes and caches

- Add pending-order shadow indexes if profiling or invariant checks justify them.
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

- internal messages are queued instead of overwritten; tactical requests and replies carry private correlation IDs while legacy shapes remain accepted;
- canonical arrays/hashes remain compatible;
- repeated selections use rebuildable indexes;
- analysis publishes coherent versioned snapshots;
- heavy loops advance within a frame budget;
- stop and error paths are bounded;
- expensive spatial/building work is reused rather than rediscovered;
- the FSMs express strategic/tactical flow instead of also owning queue and index mechanics.

That preserves the current shape while making the implementation more performant, recoverable, testable, and easier to evolve.
