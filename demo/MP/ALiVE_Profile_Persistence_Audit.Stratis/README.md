# Profile persistence reproduction mission

A small Stratis mission for the profile persistence audit. Requires CBA and a development ALiVE build containing the code under review; no ACE or Cloud account is needed. The mission uses **Local/PNS** persistence.

## Start

Copy this whole folder to your Arma profile's missions directory, retaining the .Stratis suffix. Open **ALiVE_Profile_Persistence_Audit.Stratis** in Eden and preview, or host it in multiplayer. On a dedicated server, log in as admin and use the single playable slot.

The player action menu is the test console. Wait for **[PA] Ready**. Results go to chat and the **server RPT** with [PA] PASS, [PA] FAIL, and [PA] BLOCKED. A FAIL is a broken invariant, not an exception that stops remaining checks. Unfixed defect assertions should fail while controls pass. With the empty-save fix loaded, the empty-save assertions should pass. With the mounted-speed fix loaded, speed and cached unit-count checks should also pass. BLOCKED is not a passing test.

Use the development mod build you intend to audit. These files call functions from that loaded mod; they do not automatically load repository source over an older installed PBO.

## Runs

1. **Run Local save/load reproductions** builds fresh fixtures, captures a baseline, queues a real pathfinding order, saves through ALIVE_fnc_profilesSaveData, and reloads through ALIVE_fnc_profilesLoadData. It checks identity, ranks, assignments and an applied waypoint as controls, then checks the suspected losses. Mounted-speed checks are repeated with entity-first and vehicle-first save ordering, including fully mounted, partly mounted, multiple-vehicle and walking groups.
2. **Reproduce an empty campaign save** writes a valid zero-profile save, creates an existing seed profile, and invokes the production loader. A correct loader keeps persistence enabled and removes the seed to honor the empty save. The action also checks missing, malformed, empty and populated documents through both the normal and legacy PNS loaders; it restores the original test save afterward.
3. **Run isolated Cloud backend reproductions** runs the real CouchDB bulk-save, bulk-load and encoder functions against an in-memory I/O boundary. It checks a 2,400-profile save, shrinks it to one profile, injects a document-write failure, and exercises quoted spawn code.
4. **Save fresh fixtures for a mission restart** prepares and saves the same local baseline without reloading. Use **ordinary Abort**, then restart this exact mission. Verification runs automatically after ALiVE initializes. Do **not** select ALiVE Save and Exit: that takes a later snapshot, after the pending path could have completed.
5. **Verify the last saved baseline** reruns observations without preparing or repairing fixtures.
6. **Spawn restored hook and attrition fixtures** physically spawns the restored infantry and crew nearby. It checks whether the hook's PA_hookRan marker actually appears. Inspect the vehicle and wounded infantry for their condition. Run fresh Local tests before repeating comparisons after spawning.

## Coverage and expected evidence

| Finding | Fixture / observation |
| --- | --- |
| Empty saves rejected | Empty save is accepted as persistent / leaves no non-player profiles; both assertions should PASS with the fix; the original bug left the warm-load seed in place. Tests the production loader directly, without requiring a placement module. |
| Mounted speed lost | Fully mounted MRAP crew keeps vehicle speed; a partly mounted quadbike group keeps walking speed; a group using a quadbike and truck uses the slower transport; an on-foot group keeps walking speed. Both record orders must work, and unresolved vehicle references must return a complete walking-speed array. |
| Cached unit count lost | Inspect raw unitCount immediately after load, before a getter/performance consumer can repair it. The mounted-speed restoration pass now rebuilds it because partly mounted groups depend on the correct count. |
| Spawn hooks lost | Non-empty code and onEachSpawnOnce=false; compare fields, then optionally spawn and check the unit marker. |
| Cargo / sling relationships lost | A cargo truck with B_supplyCrate_F, a helicopter referencing that truck, and the reciprocal slung field. Compare both sides, independently of sling-load physics. |
| Pending orders lost | A real queued pathfinding request is saved in the same unscheduled block as its creation, before a callback can run. The destination must remain in restored applied or pending orders. An applied waypoint is a control. |
| Attrition reset | Real vehicle getters capture fuel=0.25, partial ammo and damage from a temporary MRAP; infantry starts at damage=0.4. Equality tests the policy; a reset may be intentional. |
| Old Cloud pages resurrect profiles | First save must have multiple pages and load 2,400 records. After shrinking to one record, removed IDs must not reappear. |
| Cloud failure masked | A working control save precedes injected failure. Bulk save must return an error and leave the previous index published. |
| Cloud quote escaping | The production encoder must escape quotes inside ordinary spawn-code strings. |

## Isolation and limits

- Use this mission, not a live campaign. Local tests reset its non-player profiles and write sys_profile under its own mission store key.
- Expectations use that key plus _PA_BASELINE_V1. **Clear this test mission's saved state** clears only its profile record and manifest, retaining other module records and other missions.
- Automatic profile simulation and activation stay paused. This prevents movement, combat or cached-value repair from hiding the state observed immediately after loading.
- The pending pathfinding job is real; creation and saving share one CBA_fnc_directCall block. Warm reload cancels the original test jobs after saving, modeling an engine restart so an old callback cannot repair an imported profile. Callbacks can run after the save-only block.
- Cloud tests register a unique pa_memory source. Production Data functions are not replaced. The boundary implements revisions and record lookup, but does not validate network/plugin behavior or exercise a live CouchDB deployment.
- Installation does not establish runtime validation. Keep the server RPT from an actual run to confirm reproductions and identify unexpected script errors.
