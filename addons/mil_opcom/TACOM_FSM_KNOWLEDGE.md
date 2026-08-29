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
                                             │ incoming _TACOM_DATA, ! _pause
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
   *assigns* `_TACOM_status = "waiting for data"`, then requires non-nil
   `_TACOM_DATA` and `!_pause`. This is an observed assignment expression, not
   a comparison-only status guard. `COLLECT_TO_QUEUE` appends that payload,
   clears the mailbox, and waits for an idle TACOM and a 0.5-second analysis
   throttle.

3. **Decision and completion — `ANALYZE`.** The queue is FIFO: one entry is
   removed with `deleteAt 0`. After 15 seconds with no entry it synthesizes
   `analyze_internal`. Ordinary `['analyze', objective]` work converts the
   OPCOM order into a tactical descriptor. A completed waypoint returns as
   `['completed', [profileID, objectiveID, orders]]`; TACOM synchronizes the
   objective’s pending orders and then advances its objective/profile state.

4. **Composition — `SELECT_SECTION` and `PREPARE_ORDERS`.** The selection
   state validates existing section IDs, starts an asynchronous nearest-force
   lookup when short, and writes tentative IDs to `objective.sectionAssist`.
   Preparation waits for that handle, commits as many assists as available,
   trims surplus members, and reconciles the assignment index. It may pass a
   still-short section onward; it does not retry selection itself.

5. **Issue and acknowledge — `ISSUE_ORDERS` plus the TRANSMIT states.** The
   state materializes operation-specific waypoints and asks OPCOM to install
   them. Its boolean `_TAC_confirmed` selects a positive or negative response
   mailbox for OPCOM. This is acknowledgement of tactical preparation/order
   issue, not objective completion. Waypoint completion re-enters the mailbox
   loop.

6. **Shutdown — `END`.** The final state removes the `TACOM_FSM` key from the
   OPCOM handler. It does not clear queued work, profile waypoints, assignments,
   or the OPCOM FSM.

## Per-state contracts

| State | Observed responsibility and normal successor | Important exceptional path |
|---|---|---|
| `INIT` | Initializes local state/config/profile cache; waits for paired handles; then `INITIALIZE`. | Missing handles wait indefinitely. Missing profile IDs are logged; category duplicates are processed more than once. |
| `INITIALIZE` | Debug-only setup; waits for mailbox and goes to `COLLECT_TO_QUEUE`. | No timeout or exit edge; pause/no data can retain it. |
| `COLLECT_TO_QUEUE` | Enqueues one payload and clears `_TACOM_DATA`; then `ANALYZE` when idle/throttled. | Priority-99 exit discards queued work by ending. |
| `ANALYZE` | Consumes one action, decides an operation or handles a completion; routes to section selection, order issue, itself, or mailbox receive. | Deleted objective goes directly to `ISSUE_ORDERS`; malformed action payloads are not shape-checked. |
| `SELECT_SECTION` | Repairs dead IDs and asynchronously finds eligible candidates; then `PREPARE_ORDERS` when `_hdl` completes. | `_exitFSM` can end it while the spawned lookup is still live. |
| `PREPARE_ORDERS` | Commits/trim section membership, then always enters `ISSUE_ORDERS`. | A deleted objective exits only the state init; `ISSUE_ORDERS` performs the final deleted-objective response. |
| `ISSUE_ORDERS` | Builds waypoints, changes `tacom_state`, logs issuance, and chooses confirmation transport. | Deleted/no-group/undersized outcomes are negative; capture intentionally sends a negative preparation acknowledgement while attack remains in progress. |
| `TRANSMIT_TO_OPCO` | Writes `['confirmed',[true,_data]]` to OPCOM. | Remains to receive next data unless stopping; no acknowledgement/retry validation. |
| `TRANSMIT_TO_OPCO_1` | Writes `['confirmed',[false,_data]]` to OPCOM. | Same receive wait; the upstream 30-second condition is only an entry fallback. |
| `END` | Removes handler key `TACOM_FSM` and terminates. | Does not terminate a selection worker or clean operational state. |

## Data and mailbox contract

### FSM-local state

| Name | Meaning / owner |
|---|---|
| `_TACOM_DATA` | Single-slot inbound mailbox. OPCOM and profile-waypoint statements write it; the collect state consumes and clears it. |
| `_TACOM_QUEUE` | FIFO buffer of mailbox payloads. No capacity/back-pressure is implemented. |
| `_busy`, `_lastanalyze`, `_timestamp` | Serialization and timing. Analysis clears `_busy` and stamps `_lastanalyze`; collection requires 0.5 seconds since it. |
| `_pause`, `_exitFSM` | External control flags. Receive links require not paused; several states test exit at priority 99. |
| `_recon`, `_capture`, `_defend`, `_reserve`, `_custom` | One-operation scratch descriptors, conventionally `[objective, requestedSize]`, selected by `ANALYZE` and consumed by selection/order issue. |
| `_TAC_confirmed`, `_data` | Result-routing boolean and payload. `ISSUE_ORDERS` determines them; a transport wraps `_data` for OPCOM. |

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
  `opcom_state`, `tacom_state`, `danger`, `section`, `sectionAssist`;
- handler keys: `pendingorders` (records `[position, profileID, objectiveID,
  time]`), `ProfileIDsReserve`, `profileObjectiveAssignment`, `objectivesByID`,
  `knownentities`;
- cross-FSM mailboxes: TACOM writes `_OPCOM_FSM` variable `_OPCOM_DATA` and
  OPCOM/profile waypoint statements write TACOM `_TACOM_DATA`.

The confirmation payload must be `['confirmed', [boolean, [objective,
details]]]`. `opcom.fsm` dereferences that structure in its confirmed handler:
positive results advance conventional OPCOM objective states; false results
skip/clear the order and resume OPCOM analysis. Neither transport validates the
shape, so nil or malformed `_data` is a protocol failure risk.

## Operations and profile flows

### Decision

In `ANALYZE`, an OPCOM `attack` order chooses recon while `danger < 0`, then
capture once danger is known. A danger value above zero requests OCA via
`_OPCOM_DATA`. A `defend` order uses `findProfilesNearPosition`: enemies select
defend (and may request one air attacker); no enemies select reserve and log a
defend-complete event. `reserve` selects reserve. `custom` has no implemented
decision/order body in this FSM.

**Observed caveat:** the attack/OCA branch uses `_objectiveID` without assigning
it in that branch. The completion payload does assign that variable, but this
is not a reliable local precondition. It is therefore likely (inference) that
an OCA request can carry nil/stale objective identity unless other FSM-scope
state happens to provide it.

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
a 1–10 second delayed callback that sets `_TACOM_DATA` to `completed`.
Stale profile IDs are skipped. Therefore a nonempty `section` can produce an
empty order batch; `ISSUE_ORDERS` does not check the helper’s returned batch
before logging/confirming in some branches.

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
- Internal enemy scanning is throttled to 60 seconds. It is spawned and TACOM
  immediately reads `knownentities`, so the read can observe the prior scan’s
  data (observed asynchronous race).
- `SELECT_SECTION` progresses only after `scriptDone _hdl`; no explicit
  timeout exists. The selector is bounded, but stop can bypass the later
  `terminate _hdl` in `PREPARE_ORDERS`.
- `ISSUE_ORDERS` has a 30-second negative-confirmation fallback. The paired
  OPCOM `ORDER_TACOM` wait has its own, separate timeout.
- Missing/deleted objective on a completion invokes `resetProfileOrders` and
  clears the mailbox. Missing completion profile requeues an `analyze` action.
  `synchronizeorders` is also responsible for dead/aged pending-order cleanup.
- `END` only becomes reachable in the states that carry an exit link. This is
  why a paused/no-data `INITIALIZE` and an ongoing state init are lifecycle
  recovery hazards: the conventional stop procedure waits without a timeout
  for the handler key to be removed.

## TACOM ↔ OPCOM touchpoints

1. `fnc_OPCOM` launches/publishes both FSM handles for conventional control;
   TACOM `INIT` waits on that publication.
2. OPCOM’s `ORDER_TACOM` sends `['analyze', objective]` through TACOM’s
   mailbox. `addTask` and `setSectionOrders` are other observed mailbox
   producers.
3. TACOM requests OPCOM-level QRF and OCA by setting `_OPCOM_DATA`; it also
   invokes shared helpers for attack entities, candidate selection, section
   assignment, scans, and reset/synchronization.
4. TACOM sends `confirmed` responses. OPCOM converts a true response into its
   attacking/defending/reserving objective progression; false causes skip/reset
   behavior and new analysis.
5. TACOM completion mutates the same objective and assignment indexes OPCOM
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
