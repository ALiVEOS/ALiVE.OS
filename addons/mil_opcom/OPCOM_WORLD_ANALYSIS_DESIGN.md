# OPCOM background world-analysis design

## Goal

Keep OPCOM message processing responsive while occupation, troop, and enemy analysis runs. Analysis computes a new world snapshot in scheduled background work; OPCOM publishes that snapshot later through its existing FIFO queue.

This is an internal change. Public handler keys, objective shapes, operation return values, persistence, and conventional mission behavior remain unchanged.

## Ownership model

OPCOM remains the only owner allowed to publish world-analysis results.

- The analysis worker reads live world state and writes only to a private result buffer.
- Message processing continues against the last committed snapshot.
- The worker queues a lightweight completion message when its buffer is ready.
- OPCOM validates and commits the buffer when that message reaches the head of `_OPCOM_QUEUE`.

SQF `spawn` provides scheduled concurrency rather than a separate CPU thread. The worker must therefore yield normally and should later be divided into time-budgeted batches if profiling shows frame spikes.

## Runtime state

Keep ephemeral analysis state on the OPCOM FSM or another non-persisted internal owner:

```text
analysisGeneration
analysisActiveGeneration
analysisWorker
analysisStartedAt
analysisDeadline
analysisBuffer
lastWorldAnalysisCommittedAt
nextWorldAnalysisAt
```

Only one generation may be active. None of this state is saved as canonical mission data.

## Worker flow

When `time >= nextWorldAnalysisAt` and no generation is active:

1. Allocate a new generation and deadline.
2. Capture the inputs or revisions needed to validate later objective updates.
3. Start one owned worker.
4. Compute occupation, troop categories, force strength, and known enemies without publishing them.
5. Store the completed result in `analysisBuffer`.
6. Append the following message to `_OPCOM_QUEUE`:

```sqf
["commit_world_analysis", [_generation]]
```

The queue message carries only the generation. The potentially large result remains in the private buffer.

The analysis operations need internal no-publish variants. In particular, background occupation analysis must not directly change `opcom_state`, `opcom_orders`, or `danger`; troop analysis must not update category arrays or force strength; and enemy analysis must not update `knownentities` or create spot reports before commit.

## Buffered result

The buffer contains all values required for one coherent publication:

```text
generation
startedAt
completedAt
clusterOccupation
troopCategories
currentForceStrength
knownEntities
objectiveUpdates
```

Each proposed objective update records enough prior state to detect a conflict:

```text
[objectiveID, observedState, proposedState, otherUpdates]
```

## Queue commit

When OPCOM dispatches `commit_world_analysis`:

1. Ignore the message unless its generation matches the active generation and buffer.
2. Reject results that failed, timed out, or reference an invalid generation.
3. Publish the aggregate handler fields from the buffer in one queue turn.
4. Apply an objective update only when the objective still exists and its relevant state still matches `observedState`.
5. Skip conflicting objective updates rather than overwriting newer confirmation or completion effects.
6. Create spot reports from the accepted enemy result.
7. Set `lastWorldAnalysisCommittedAt` and calculate `nextWorldAnalysisAt`.
8. Clear the worker and buffer, then mark strategic planning dirty.

The commit should contain no waits or scheduled delays. It should be measured to ensure that per-objective publication does not create a new single-frame spike.

## Scheduling and failure behavior

Message activity must not change `nextWorldAnalysisAt`. OPCOM continues draining normal FIFO work while analysis is active.

If the worker reaches its deadline, fails, or is superseded:

- retain the last committed snapshot;
- terminate any owned worker that is still running;
- clear the tentative buffer;
- record a diagnostic outcome;
- schedule a retry with bounded backoff.

On OPCOM shutdown, terminate the owned worker and discard its uncommitted buffer before removing the FSM handle.

Late or duplicate commit messages are harmless because their generation no longer matches the active generation.

## First-iteration boundaries

The first iteration should implement:

- independent world-analysis scheduling;
- a single owned worker and deadline;
- no-publish analysis paths;
- one private double buffer;
- generation-checked FIFO commit;
- conflict-aware objective updates;
- strategic replanning after a successful commit;
- timeout and shutdown cleanup.

It does not need to introduce derived indexes, a new public runtime object, persistent analysis state, or fully batched multi-frame algorithms. Those can follow after the ownership and publication boundary is working and measured.

## Required tests

- Confirmations and completions continue to dispatch while analysis runs.
- A successful generation publishes all aggregate fields together.
- A completion that changes an objective during analysis is not overwritten at commit.
- Late, duplicate, timed-out, and mismatched generation commits are ignored.
- A failed generation leaves the last committed snapshot unchanged.
- Sustained message traffic does not postpone the next analysis start indefinitely.
- Stop terminates the worker and prevents later publication.
