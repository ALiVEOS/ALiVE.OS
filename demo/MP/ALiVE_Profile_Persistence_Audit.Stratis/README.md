# Profile persistence reproduction mission

A small Stratis mission for the profile persistence audit. Requires CBA and a development ALiVE build containing the code under review; no ACE or Cloud account is needed. The mission uses **Local/PNS** persistence.

## Start

Copy this whole folder to your Arma profile's missions directory, retaining the .Stratis suffix. Open **ALiVE_Profile_Persistence_Audit.Stratis** in Eden and preview, or host it in multiplayer. On a dedicated server, log in as admin and use the single playable slot.

The player action menu is the test console. Wait for **[PA] Ready**. Results go to chat and the **server RPT** with [PA] PASS, [PA] FAIL, and [PA] BLOCKED. A FAIL is a broken invariant, not an exception that stops remaining checks. Unfixed defect assertions should fail while controls pass. With the empty-save fix loaded, the empty-save assertions should pass. With the mounted-speed fix loaded, speed and cached unit-count checks should also pass. With the spawn-customization fix loaded, hook fields and physical execution checks should pass. With the infantry-damage fix loaded, wounded soldiers should retain their damage through loading and spawning. With the transport fix loaded, saved cargo and sling relationships should be restored and recreated when vehicles spawn. With the pending-order fix loaded, unfinished orders should be requeued and reach the applied route after pathfinding completes. BLOCKED is not a passing test.

Use the development mod build you intend to audit. These files call functions from that loaded mod; they do not automatically load repository source over an older installed PBO.

## Runs

1. **Run Local save/load reproductions** builds fresh fixtures, captures a baseline, queues a real pathfinding order, saves through ALIVE_fnc_profilesSaveData, and reloads through ALIVE_fnc_profilesLoadData. It checks identity, ranks, assignments and an applied waypoint as controls, then checks the suspected losses. Mounted-speed checks are repeated with entity-first and vehicle-first save ordering, including fully mounted, partly mounted, multiple-vehicle and walking groups.
2. **Reproduce an empty campaign save** writes a valid zero-profile save, creates an existing seed profile, and invokes the production loader. A correct loader keeps persistence enabled and removes the seed to honor the empty save. The action also checks missing, malformed, empty and populated documents through both the normal and legacy PNS loaders; it restores the original test save afterward.
3. **Run isolated Cloud backend reproductions** runs the real CouchDB bulk-save, bulk-load and encoder functions against an in-memory I/O boundary. It checks a 2,400-profile save, shrinks it to one profile, injects a document-write failure, and exercises quoted spawn code.
4. **Save fresh fixtures for a mission restart** prepares and saves the same local baseline without reloading. Use **ordinary Abort**, then restart this exact mission. Verification runs automatically after ALiVE initializes. Do **not** select ALiVE Save and Exit: that takes a later snapshot, after the pending path could have completed.
5. **Verify the last saved baseline** reruns observations without preparing or repairing fixtures.
6. **Spawn restored hook and attrition fixtures** physically spawns the restored infantry and crew nearby. It checks whether the hook's PA_hookRan marker actually appears. Inspect the vehicle and wounded infantry for their condition. Run fresh Local tests before repeating comparisons after spawning.

7. **Run spawn customization regressions** creates repeat, once-only and legacy two-unit fixtures. It saves and loads through real Local/PNS twice and physically spawns/despawns each group after each load. Checks code, flags, hook arguments and invocation counts, including suppression of a once-only hook after it has already executed. Legacy payloads omit customization fields to verify the default empty code and once=true behavior.

8. **Run infantry damage regressions** saves virtual wounds and live soldiers whose current damage differs from the cached profile. It checks both normal and legacy PNS loaders and physically spawns every restored fixture. Covers mixed healthy/wounded groups, old saves without damage, short arrays, numeric strings and damage alignment when invalid class entries are filtered out.

9. **Run cargo and sling regressions** saves duplicate truck cargo, a helicopter linked to a profiled quadbike, and a helicopter slinging a class-created supply crate. Checks cargo inside both loads, both sides of the profile link, empty arrays and older saves without transport fields. Uses normal and legacy PNS loaders, carrier-first/load-first activation, physical sling attachments and cleanup of spawned cargo objects.

10. **Run pending movement regressions** queues two appended orders and a front insertion for walking and mounted groups in the same unscheduled block as saving. Confirms the durable format, exclusion of canceled/ambient orders and sanitization of old callbacks. Exercises both import orders, normal/legacy loaders, the older raw pending format, numeric strings and disabled pathfinding. Waits for real pathfinding jobs to drain and verifies the resulting order sequence.

## Automated dedicated-server run

From the repository root on Windows, run:

```powershell
python utils/run_profile_persistence_audit.py
```

The launcher uses the installed arma3server_x64.exe, CBA, and ALiVE dependencies. It packages the current repository sys_profile addon and this mission for every run. Use --game-dir, --alive-mod, or --cba-mod for other installation paths.

Each run has a fresh persistence profile and logs under %TEMP%/ALiVE_Profile_Persistence_Audit. The server binds to 127.0.0.1, starts the mission without a player, runs the Local roundtrip, physical spawn-customization, infantry-damage, cargo/sling, pending-order and empty-save suites, then is stopped by the launcher. A uniquely named mission PBO is temporarily staged in the game's MPMissions directory and removed afterward. The manifest records the commit, launch command, and profile source hashes; result.json and the RPT retain the evidence.

The launcher requires every focused empty-save, mounted-speed, raw unit-count, spawn-customization, infantry-damage, cargo/sling and pending-order assertion to report PASS. Missing assertions, timeouts and script errors cannot pass. result.json reports focused_passed separately from the full audit, which returns exit code 1 if any assertion fails, including other persistence findings. Cloud, physical attrition inspection and cold-restart checks use the manual actions described above.

The PA_Automated mission parameter defaults to Manual; the launcher opts into Automated in its server configuration.

## Coverage and expected evidence

| Finding | Fixture / observation |
| --- | --- |
| Empty saves rejected | Empty save is accepted as persistent / leaves no non-player profiles; both assertions should PASS with the fix; the original bug left the warm-load seed in place. Tests the production loader directly, without requiring a placement module. |
| Mounted speed lost | Fully mounted MRAP crew keeps vehicle speed; a partly mounted quadbike group keeps walking speed; a group using a quadbike and tracked APC uses the slower transport; an on-foot group keeps walking speed. Both record orders must work, and unresolved vehicle references must return a complete walking-speed array. |
| Cached unit count lost | Inspect raw unitCount immediately after load, before a getter/performance consumer can repair it. The unitClasses setter maintains it during import, before the speed restoration pass reads it. |
| Spawn hooks lost | Non-empty code and onEachSpawnOnce=false survive the roundtrip. The scheduled spawn suite executes restored code on every unit, repeats it after another save/load when once=false, suppresses an already-run once=true hook, and checks legacy defaults. |
| Cargo / sling relationships lost | Cargo, slingload and slung survive the roundtrip. The transport suite checks duplicate cargo, both relationship directions, actual profiled/class sling attachments, nested cargo, activation ordering and legacy defaults through both loaders. |
| Pending orders lost | Real queued requests are saved before callbacks run. Logical pendingWaypointOrders retain sanitized waypoint settings and append/insert methods; import requeues after vehicle registration. The order suite checks legacy pendingWaypointPaths records and waits for new jobs to apply the expected sequence. An existing waypoint remains a control. |
| Attrition reset | Real vehicle getters capture fuel=0.25, partial ammo and damage from a temporary MRAP; infantry starts at damage=0.4 and must retain it. The damage suite checks virtual/live saves, restored physical damage and legacy fallbacks through both loaders. |
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
