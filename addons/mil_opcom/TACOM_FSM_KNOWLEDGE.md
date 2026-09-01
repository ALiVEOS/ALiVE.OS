# TACOM FSM knowledge

## Scope and evidence

This is a behavioral reference for the conventional tactical-command FSM in
`addons/mil_opcom/tacom.fsm`. It applies to the `occupation` and `invasion`
OPCOM control types: `fnc_OPCOM.sqf` starts both `opcom.fsm` and `tacom.fsm`
and publishes their handles as `OPCOM_FSM` and `TACOM_FSM`. `asymmetric`
instead starts `insurgency.fsm` and marks `TACOM_FSM` as `-1`; it is therefore
outside this document except where the boundary is relevant.

The claims below were checked against the FSM and the direct OPCOM helpers in
`addons/mil_opcom/fnc_OPCOM.sqf`, especially `setSectionOrders`,
`setObjectiveSection`, `resetProfileOrders`, `NearestAvailableSection`,
`synchronizeorders`, and the enemy-scan helpers. “Observed” means literal
source behavior. “Inference” is explicitly labelled.

## State and transition map

```text
INIT
  └─ (both FSM handles exist and are > 0) ─► INITIALIZE
                                             │
                                             │ queued or nonempty legacy data, ! _pause
                                             ▼
                                      COLLECT_TO_QUEUE
                                             │ queue nonempty, idle, >0.5 s
                                             ▼
ANALYZE ◄────────────────────────────────────┘
  │  │\
  │  │ └─ every >15 s: internal-analysis self loop
  │  ├─ deleted objective ───────────────► ISSUE_ORDERS
  │  └─ recon/capture/defend/reserve/custom decision ─► SELECT_SECTION
  │                                                        │ scriptDone _hdl
  │                                                        ▼
  │                                                  PREPARE_ORDERS
  │                                                        │ always
  └───────────────────────────────────────────────────────► ISSUE_ORDERS
                                                              │
                                      confirmed ──────────────┼─► TRANSMIT_TO_OPCO
                                      not confirmed / >30 s ──└─► TRANSMIT_TO_OPCO_1
                                                                    │
                                                        next incoming data, !pause
                                                                    ▼
                                                             COLLECT_TO_QUEUE

END is reachable at priority 99 when _exitFSM is tested in ANALYZE,
ISSUE_ORDERS, both TRANSMIT states, COLLECT_TO_QUEUE, or SELECT_SECTION.
```

`INITIALIZE` and `PREPARE_ORDERS` have no direct `END` edge. Consequently,
stop responsiveness depends on reaching their successor; the stop routine in
`fnc_OPCOM.sqf` waits for the `TACOM_FSM` handler key to disappear.

## Lifecycle narrative

1. **Bootstrap — `INIT`.** The state sets FSM-local defaults (`_busy=false`,
   `_exitFSM=false`, an empty `_TACOM_QUEUE`, timestamps, pause state, section
   settings) and caches conventional OPCOM configuration. It combines the
   profile categories into `_profiles` and restores ambient movement for a
   vehicle-command profile with no active command. It only advances once both
   published FSM handles are non-nil and positive. Empty category lists are
   harmless; a missing handle has no timeout and leaves it waiting.

2. **Mailbox wait — `INITIALIZE` then `COLLECT_TO_QUEUE`.** `INITIALIZE` is
   intentionally almost empty (debug logging only). Its receive condition
   *assigns* `_TACOM_status = "waiting for data"`, then requires a nonempty
   `_TACOM_DATA` legacy slot or queued work and `!_pause`. This is an observed
   assignment expression, not a comparison-only status guard. The legacy slot
   is initialized to `[]`; `COLLECT_TO_QUEUE` appends a nonempty payload, resets
   the slot to `[]`, and waits for an idle TACOM and a 0.5-second analysis
   throttle.

3. **Decision and completion — `ANALYZE`.** The queue is FIFO: one entry is
   removed with `deleteAt 0`. After 15 seconds with no entry it synthesizes
   `analyze_internal`; a due internal enemy scan publishes its completed result
   back as `['enemy_scan_complete', [generation, targets]]`. TACOM owns one
   generation/worker/deadline at a time and publishes the shared contact snapshot
   only after accepting that active generation. Conventional
   `['analyze_order', [orderID, operation, objective, expiresAt]]` work validates
   its immutable correlation/deadline snapshot before converting it into a
   tactical descriptor. Exact-profile
   `['manual_order', [operation, objective, profileIDs]]` work instead marks the
   request manual and installs only its supplied IDs. A completed
   waypoint returns as `['completed', [profileID, objectiveID, orders]]`; TACOM
   synchronizes the objective’s pending orders and then advances its
   objective/profile state.

4. **Composition — `SELECT_SECTION` and `PREPARE_ORDERS`.** The selection
   state validates existing section IDs, starts an asynchronous nearest-force
   lookup when a conventional request is short, and writes tentative IDs to
   `objective.sectionAssist`. Preparation waits for that handle, commits as many
   assists as available, trims surplus conventional members, and reconciles the
   assignment index. Manual requests bypass recruitment and trimming: missing
   supplied IDs may be discarded, but no replacement is selected. A conventional
   request may pass a still-short section onward; selection does not retry itself.

5. **Issue and acknowledge — `ISSUE_ORDERS` plus the TRANSMIT states.** The
   state materializes operation-specific waypoints and asks OPCOM to install
   them. For conventional work, `_TAC_confirmed` selects a positive or negative
   response queued to OPCOM. Manual work suppresses that response and removes
   its transient objective after failure or final waypoint completion. A
   conventional response acknowledges tactical preparation/order issue, not
   objective completion. Waypoint completion re-enters the mailbox loop.

6. **Shutdown — `END`.** The final state removes the `TACOM_FSM` key from the
   OPCOM handler. It does not clear queued work, profile waypoints, assignments,
   or the OPCOM FSM.

## Per-state contracts

| State | Observed responsibility and normal successor | Important exceptional path |
|---|---|---|
| `INIT` | Initializes local state/config/profile cache; waits for paired handles; then `INITIALIZE`. | Missing handles wait indefinitely. Missing profile IDs are logged; category duplicates are processed more than once. |
| `INITIALIZE` | Debug-only setup; waits for mailbox and goes to `COLLECT_TO_QUEUE`. | No timeout or exit edge; pause/no data can retain it. |
| `COLLECT_TO_QUEUE` | Enqueues a nonempty legacy payload and resets `_TACOM_DATA` to `[]`; then `ANALYZE` when idle/throttled. | Priority-99 exit discards queued work by ending. |
| `ANALYZE` | Consumes one action, validates correlated `analyze_order` or exact-profile `manual_order`, owns/version-checks internal enemy scans, handles waypoint completion, or decides an operation; routes to section selection, order issue, itself, or mailbox receive. | Expired/malformed conventional orders are refused before issue. Deleted objectives go directly to `ISSUE_ORDERS`; failed/timed-out scans release ownership and late generations cannot react. |
| `SELECT_SECTION` | Repairs dead IDs and asynchronously finds eligible candidates for conventional work; manual work keeps only live supplied IDs and never recruits substitutes. Then `PREPARE_ORDERS` when `_hdl` completes. | `_exitFSM` can end it while a spawned conventional lookup is still live. |
| `PREPARE_ORDERS` | Commits/trims conventional membership, or preserves the exact surviving manual list, then always enters `ISSUE_ORDERS`. | A deleted objective exits only the state init; `ISSUE_ORDERS` performs the final deleted-objective response. |
| `ISSUE_ORDERS` | Resets result scratch state, builds waypoints, changes `tacom_state`, logs only a nonempty issued batch, and chooses confirmation transport. Manual work suppresses transport and removes its transient objective on failure. | Deleted/no-group/undersized/zero-issued-waypoint outcomes are negative. Conventional capture intentionally sends a negative preparation acknowledgement while attack remains in progress; manual capture may proceed with the supplied IDs and receives no OPCOM acknowledgement. |
| `TRANSMIT_TO_OPCO` | Queues `['confirmed',[true,_data,orderID,confirmedAt]]` to OPCOM. | Remains to receive next data unless stopping; no acknowledgement/retry validation. |
| `TRANSMIT_TO_OPCO_1` | Queues `['confirmed',[false,_data,orderID,confirmedAt]]` to OPCOM. | Same receive wait; the upstream 30-second condition is only an entry fallback. |
| `END` | Terminates an owned enemy-scan worker, removes handler key `TACOM_FSM`, and terminates. | Does not terminate a section-selection worker or clean other operational state. |

## Data and mailbox contract

### FSM-local state

| Name | Meaning / owner |
|---|---|
| `_TACOM_DATA` | Legacy single-slot inbound mailbox initialized/reset to `[]`; the collect state appends a nonempty value to the queue. |
| `_TACOM_QUEUE` | Authoritative FIFO buffer. OPCOM, internal TACOM work, exact-profile `addTask` requests, and profile-waypoint callbacks append to it. No capacity/back-pressure is implemented. |
| `_busy`, `_lastanalyze`, `_timestamp` | Serialization and timing. Analysis clears `_busy` and stamps `_lastanalyze`; collection requires 0.5 seconds since it. |
| `_pause`, `_exitFSM` | External control flags. Receive links require not paused; several states test exit at priority 99. |
| `_recon`, `_capture`, `_defend`, `_reserve`, `_custom` | One-operation scratch descriptors, conventionally `[objective, requestedSize]`, selected by `ANALYZE` and consumed by selection/order issue. `manual_order` creates these only after its FIFO dequeue. |
| `_manualOrder` | Marks the currently executing tactical request as an exact-profile manual task. Section selection may discard missing IDs but may not add or substitute profiles, and transmit states suppress ordinary OPCOM confirmations. |
| `_TAC_confirmed`, `_data`, `_orderID` | Result-routing boolean, payload, and OPCOM correlation ID. `ISSUE_ORDERS` determines the result; a transport wraps it for OPCOM. |

### Handler/objective contract

`INIT` reads the handler configuration `debug`, `side`, `factions`,
`sidesenemy`, the three `sectionsamount_*` values, category arrays
(`infantry`, `motorized`, `mechanized`, `armored`, `artillery`, `AAA`, `air`,
`sea`), and task profile-type overrides through `getTaskProfileTypes`.
The defaults are attack: infantry/motorized/mechanized/armored; defend and
reserve add sea. `scantroops` is expected to have populated those categories
before startup.

The main shared mutable structures are:

- objective keys: `deleted`, `center`, `objectiveID`, `opcom_orders`,
  `opcom_state`, `tacom_state`, `danger`, `section`, `sectionAssist`,
  `manualTask` (transient exact-profile objectives only);
- handler keys: `pendingorders` (records `[position, profileID, objectiveID,
  time]`), `ProfileIDsReserve`, `profileObjectiveAssignment`, `objectivesByID`,
  `knownentities`;
- cross-FSM queues: TACOM appends to OPCOM's `_OPCOM_QUEUE`, while OPCOM and
  profile-waypoint statements append to `_TACOM_QUEUE`; `_OPCOM_DATA` and
  `_TACOM_DATA` remain supported legacy ingress slots.

The internal correlated confirmation payload is `['confirmed', [boolean, [objective,
details], orderID, confirmedAt]]`. `opcom.fsm` requires this exact shape and an
ID/objective match against a live request. ID-less, malformed, stale, and mismatched
confirmations are ignored. Positive results advance conventional OPCOM objective
states; false results skip/clear the order and resume OPCOM analysis.

## Operations and profile flows

### Decision

In `ANALYZE`, an OPCOM `attack` order chooses recon while `danger < 0`, then
capture once danger is known. A danger value above zero requests OCA via
`_OPCOM_QUEUE`, using the objective ID read from the current objective. A
`defend` order uses `findProfilesNearPosition`: enemies select
defend (and may request one air attacker); no enemies select reserve and log a
defend-complete event. `reserve` selects reserve. `custom` has no implemented
decision/order body in this FSM.

### Section selection and assignment

`NearestAvailableSection` builds a type-filtered troop pool, removes reserves,
and normally excludes already assigned profiles. For requests of size five or
more it permits reassignment. It expands spatial searches from 2 km through a
bounded 16 km, filters busy/static-AA/stationary and travel-incompatible
profiles, sorts by distance, and returns at most the requested size.

`PREPARE_ORDERS` uses `setObjectiveSection` to deduplicate membership and keep
`profileObjectiveAssignment` synchronized. Reassigning a profile removes it
from its previous objective and reserve list; emptied objectives are reset.
Removing excess members uses `resetorders`, which also removes pending/reserve
records and restores ambient movement for suitable inactive profiles.

### Waypoint issue and completion

`ISSUE_ORDERS` builds one batch per valid profile:

- recon: alternating flanks around the objective, with a water safe-position
  fallback, and requires the full attack section;
- capture/defend: random positions within 50 m of center;
- reserve: random positions within 15 m.

`setSectionOrders` clears existing waypoints/active commands, creates
aware/normal profile waypoints, appends `pendingorders`, and gives each waypoint
a 1–10 second delayed callback that appends `completed` to `_TACOM_QUEUE`.
Stale profile IDs are skipped. `ISSUE_ORDERS` checks the returned waypoint
batch: an empty result is reported as no valid groups, returns `tacom_state` to
`none`, emits no order-issued event, and cannot produce a positive
confirmation. Result scratch variables are reset on every entry so custom or
unknown operations cannot inherit a previous outcome.

On each completion, `ANALYZE` calls `synchronizeorders`. Until all objective
profiles finish, it defers downstream effects. The last completion:

- recon scans visible enemies, updates `danger`, possibly requests QRF, and
  schedules re-analysis;
- capture changes `opcom_state`/`opcom_orders` to reserve and re-analyzes;
- defend re-analyzes;
- reserve registers the profile as reserved, garrisons it, clears waypoints and
  active commands, resets `danger` to `-1`, and makes the objective idle/none.

Events are emitted through `ALIVE_eventLog` (`TACOM_ORDER_ISSUED`,
`TACOM_ORDER_COMPLETE`, and the relevant `OPCOM_*` event). Re-analysis after
completion is suppressed for an objective whose `opcom_state` was `internal`.

## Scheduling, waits, and recovery

- There is no sleep in the FSM states. FSM link conditions are repeatedly
  evaluated; `_lastanalyze` governs the 0.5-second collection gate and the
  15-second internal-analysis feeder.
- Internal enemy scanning is throttled to 60 seconds. It remains asynchronous,
  but the worker enqueues `enemy_scan_complete` with its returned targets and
  TACOM reacts only when that completion entry is consumed; it no longer reads
  the previous `knownentities` snapshot immediately after spawning.
- `SELECT_SECTION` progresses only after `scriptDone _hdl`; no explicit
  timeout exists. The selector is bounded, but stop can bypass the later
  `terminate _hdl` in `PREPARE_ORDERS`.
- `ISSUE_ORDERS` has a 30-second negative-confirmation fallback. OPCOM includes
  each request's absolute deadline in the correlated envelope. TACOM rejects an
  expired request at dequeue and rechecks it after planning and before issue.
- Missing/deleted objective on a completion invokes `resetProfileOrders` and
  resets the legacy slot to `[]`. Missing completion profiles request a new OPCOM analysis turn.
  `synchronizeorders` is also responsible for dead/aged pending-order cleanup.
- `END` only becomes reachable in the states that carry an exit link. This is
  why a paused/no-data `INITIALIZE` and an ongoing state init are lifecycle
  recovery hazards: the conventional stop procedure waits without a timeout
  for the handler key to be removed.

## TACOM ↔ OPCOM touchpoints

1. `fnc_OPCOM` launches/publishes both FSM handles for conventional control;
   TACOM `INIT` waits on that publication.
2. OPCOM’s `ORDER_TACOM` appends `['analyze_order', [orderID, operation, objective, expiresAt]]` to TACOM’s queue. This is the conventional correlated order shape; TACOM does not infer the operation from the objective's `opcom_orders` field and does not issue expired work. `addTask` instead appends `['manual_order',[operation,objective,profileIDs]]`. Manual orders accept `recon`, `capture`, `defend`, or `reserve`, assign only the deduplicated supplied profile IDs, never fill a short section, and use a transient internal objective so they do not confirm or continue through OPCOM. `setSectionOrders` waypoint callbacks are another queue producer.
3. TACOM requests OPCOM-level QRF and OCA through `_OPCOM_QUEUE`; it also
   invokes shared helpers for attack entities, candidate selection, section
   assignment, scans, and reset/synchronization.
4. TACOM sends `confirmed` responses. OPCOM converts a true response into its
   attacking/defending/reserving objective progression; false causes skip/reset
   behavior and new analysis.
5. Recon, capture, and defend completion append `completed` with the completed
   tactical operation and objective to OPCOM. OPCOM derives the next strategic
   operation and registers it as a new correlated request before returning it to TACOM.
6. TACOM completion mutates the same objective and assignment indexes OPCOM
   owns. Correctness relies on `section`, `objectivesByID`, and
   `profileObjectiveAssignment` staying coherent; `setObjectiveSection` is the
   intended reconciliation seam.

## Likely hot paths (descriptive only)

- Full `INIT` profile traversal and ambient-command restoration scale with the
  concatenated category arrays.
- `scanFriendliesForNearEnemies` traverses controlled faction profiles; its
  per-profile scan has spatial lookup plus visibility/terrain tests. Recon
  completion performs another visible-enemy scan.
- `NearestAvailableSection` performs up to eight expanding spatial queries,
  then filters and distance-sorts candidates. It is the dominant selection
  cost, even though it is spawned.
- `ISSUE_ORDERS` does per-section waypoint construction. Recon adds
  safe-position searches; its insufficient-section regroup fallback is roughly
  profiles times idle objectives.
- Queue dequeue with `deleteAt 0` shifts the remaining array, so a bursty
  mailbox can make FIFO handling more expensive as backlog grows.
- `resetProfileOrders` is normally index-assisted by
  `profileObjectiveAssignment`, but legacy/inconsistent data falls back to a
  full objective scan.

This document intentionally describes observed behavior and risks; it does not
recommend a cross-FSM optimization or redesign.
