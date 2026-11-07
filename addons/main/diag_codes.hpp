/* ----------------------------------------------------------------------------
Diagnostics: the fixed event codes and what each number in a snapshot means.

DEV builds only, on the server only. ALiVE_fnc_diagnostics keeps two rings in
missionNamespace for the War Room extension (alive_wr) to read; a release build
has neither. Both rings share one sequence number, ALiVE_diag_seq, so a reader
asks for every row above the last one it took.

ALiVE_diag_schema = 1
ALiVE_diag_build  = ALiVE version string, e.g. "3.2.0.26110700 DEV"

ALiVE_diag_snap, a ring of 120, one row every 30 s:
  [seq, serverTime (s), fps, fpsMin (lowest over the 30 s),
   [spawn, execVM, exec, execFSM] (scripts running),
   profiles (all), activeProfiles (spawned),
   [west, east, resistance, civilian] (groups),
   [[side, lastCycleS], ...] (each AI Commander, seconds since its cycle last moved on),
   [[faction, lastCycleS, queued], ...] (each Military Logistics module; lastCycleS is -1, not tracked yet),
   pathfinderQueue (route requests waiting),
   spawnsSinceLast, despawnsSinceLast (profiles, since the previous row)]

ALiVE_diag_events, a ring of 200:
  [seq, serverTime (s), category, code, text (200 characters at most), [x, y] or [], repeatCount]
  repeatCount, the 7th element, is there only when the row stands for more than one
  occurrence: past 6 a minute for one code, the rest are counted and carried on the
  next row of that code.

No player names or UIDs go in either ring.
---------------------------------------------------------------------------- */

// categories
#define DIAG_PATH  "PATH"
#define DIAG_ML    "ML"
#define DIAG_SPAWN "SPAWN"
#define DIAG_OPCOM "OPCOM"
#define DIAG_ERROR "ERROR"

// codes
// a ground route between two different cells came back as a single point: the unit stays put
#define DIAG_PATH_ONE_POINT        "PATH_ONE_POINT"
// Military Logistics turned a road delivery down, its route crossing water with pathfinding off
#define DIAG_ML_ROAD_WATER         "ML_ROAD_WATER"
// Military Logistics sent a delivery by air because its road crossed water with pathfinding off
#define DIAG_ML_HELI_WATER         "ML_HELI_WATER"
// no spot found for a composition
#define DIAG_SPAWN_COMPOSITION     "SPAWN_COMPOSITION"
// no spawn position found for a vehicle; the caller fell back
#define DIAG_SPAWN_VEHICLE         "SPAWN_VEHICLE"
