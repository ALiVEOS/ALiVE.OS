#include "\x\alive\addons\fnc_analysis\script_component.hpp"
SCRIPT(indexViabilityEdenCheck);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_indexViabilityEdenCheck

Description:
Eden-side viability advisory. Spawned from main/XEH_preInit.sqf
once per terrain (latched on worldName).

Loads the bundled static index data for the current world (if
any), runs the full assessor, and fires a 3DEN notification for any
sub-Good terrain (Reduced / Poor / Critical). For Good (>= 80)
terrains the function exits silently -- those don't need maker
attention.

The runtime assessor + its hashGet/dump helpers + the hashCreate/
hashSet helpers the bundled data file calls during compile are
all inline-compiled in main/XEH_preInit.sqf before the spawn-and-
poll registers our call. That works around pure-Eden's missing
CfgFunctions postInit phase (under which ALIVE_fnc_* would
normally compile).

Toast severity maps to tier so the colour matches the verdict's
gravity. BIS_fnc_3DENNotification only supports three severity
values (clamped 0-2; anything higher silently truncates):
  - 0 = default (green)
  - 1 = error   (red)
  - 2 = warning (orange)
Mapped to tier:
  - Critical (score 0-39):   severity 1 (red)
  - Poor     (score 40-59):  severity 1 (red)
  - Reduced  (score 60-79):  severity 2 (orange)
  - Good     (score 80+):    severity 0 (green) -- positive
                             confirmation that the index is
                             healthy.

Parameters: none

Returns: nothing

Author:
Jman
---------------------------------------------------------------------------- */

if (!is3DEN) exitWith {
    diag_log "ALiVE Eden Viability check: not in 3DEN, exiting.";
};

// Reset state so the Eden check + the runtime gridImport in a
// subsequent mission preview both fire their assessor + RPT block
// cleanly. (3DEN and mission preview share missionNamespace; a
// stale latch / data hash from a previous run would silently
// poison the next run.)
ALIVE_indexViabilityAssessed = nil;
ALIVE_gridData               = nil;
ALIVE_gridDataSource         = nil;
ALiVE_indexViabilityScore    = nil;
ALiVE_indexViabilityTier     = nil;

private _worldLower = toLower worldName;
private _filePath = format ["\x\alive\addons\fnc_analysis\data\data.%1.sqf", _worldLower];

diag_log format ["ALiVE Eden Viability check: entered. worldName='%1', loading file '%2'.", worldName, _filePath];

// Inline-load the bundled static index data for the current world.
// The data file is just SQF that mutates ALIVE_gridData via
// ALIVE_fnc_hashCreate / ALIVE_fnc_hashSet -- both inline-
// compiled in XEH_preInit so the call works in pure-Eden.
call compile preprocessFileLineNumbers _filePath;

if (isNil "ALIVE_gridData") then {
    ALIVE_gridDataSource = "none";
} else {
    ALIVE_gridDataSource = "bundled";
};

// Run the assessor. Publishes ALiVE_indexViabilityScore +
// ALiVE_indexViabilityTier as globals, prints the score block to
// RPT via ALIVE_fnc_dump (so the Eden RPT carries the same
// breakdown the runtime would).
[] call ALIVE_fnc_assessIndexViability;

if (isNil "ALiVE_indexViabilityScore") exitWith {
    diag_log "ALiVE Eden Viability check: assessor returned no score, exiting silently.";
};

// Surface a notification for every tier. BIS_fnc_3DENNotification only
// honours three severity values (clamped 0-2 internally; anything
// higher silently truncates to 2):
//   0 (green)  -- Good        positive confirmation
//   1 (red)    -- Poor / Critical
//   2 (orange) -- Reduced     advisory
// Duration 20s gives the maker time to read.
private _tier = ALiVE_indexViabilityTier;
private _severity = switch (_tier) do {
    case "Critical": { 1 };
    case "Poor":     { 1 };
    case "Reduced":  { 2 };
    case "Good":     { 0 };
    default          { 2 };
};
private _detail = switch (_tier) do {
    case "Good":     { "terrain index is healthy -- modules will use pre-computed sector data, standard init expected" };
    case "Reduced":  { "some sectors have gaps OR terrain has unfavourable conditions; slower init expected -- see RPT for per-metric breakdown" };
    case "Poor":     { "significant sector gaps OR severe terrain conditions; substantial init delay expected -- see RPT for per-metric breakdown" };
    case "Critical": { "no static index loaded -- modules fall back to per-call engine queries instead of pre-computed sector data" };
    default          { "see RPT for the per-metric breakdown" };
};
private _msg = format [
    "ALiVE Index Viability: %1 (%2) -- %3. RPT carries the per-metric breakdown.",
    _tier,
    round ALiVE_indexViabilityScore,
    _detail
];
[_msg, _severity, 20] call BIS_fnc_3DENNotification;
diag_log format ["ALiVE Eden Viability check: score=%1 (%2) -- 3DEN notification fired (severity %3).",
    round ALiVE_indexViabilityScore, _tier, _severity];
