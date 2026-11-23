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
   spawnsSinceLast, despawnsSinceLast (profiles, since the previous row),
   aiOther (AI units with no ALiVE profile: mission-placed, CQB, other mods; units ALiVE spawns or takes
   over carry the "profileID" variable), vehicles (count vehicles), dead (count allDead), agents (count agents),
   scriptErrorsSinceLast (every script error on the server, any mod or the mission, from the engine's ScriptError event),
   aliveUnits (AI units ALiVE spawned or took over, the ones carrying "profileID"),
   cps (scheduler cycles a second over the 30 s: how often a waiting scheduled script got a turn),
   [west, east, resistance, civilian] (aiOther by the side of its group),
   [[machine, aliveUnits, aiOther], ...] (where the AI is local: "server", "HC1", "HC2"... in the order of the
   headless clients, then "players" for AI in groups local to a player's machine)]
  Indexes: 0 seq, 1 time, 2 fps, 3 fpsMin, 4 scripts, 5 profiles, 6 activeProfiles, 7 groups, 8 commanders,
  9 logistics, 10 pathfinderQueue, 11 spawns, 12 despawns, 13 aiOther, 14 vehicles, 15 dead, 16 agents, 17 scriptErrors, 18 aliveUnits,
  19 cps, 20 aiOtherBySide, 21 aiByMachine.
  Rows written before 16 Nov 2026 end at 12; before 23 Nov 2026 at 18.

ALiVE_diag_events, a ring of 200:
  [seq, serverTime (s), category, code, text (1000 characters at most), [x, y] or [], repeatCount]
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
#define DIAG_SERVER "SERVER"

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
// every minute (each 2nd row): the scripts running, counted by where their file comes from (ALiVE, CBA, ACE, mission, other
// mods by their first two path segments, "no file"), then "; FSMs <n>" for the mission FSMs
#define DIAG_SERVER_SCRIPTS        "SERVER_SCRIPTS"
// once a run: the loaded mods by name, several rows when the list is longer than 1000 characters
#define DIAG_SERVER_MODS           "SERVER_MODS"
