#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(COPConfig);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_COPConfig

Description:
    Master configuration for the COP (Common Operational Picture) commander
    intel overlay. Seeds default values on missionNamespace so they can be
    overridden by missions (before c2istar init) or tweaked at runtime via
    the debug console.

    All values use `if (isNil ...)` defensive guards so mission-level overrides
    set earlier in init.sqf are preserved.

Parameters:
    Optional operation string (currently unused — config always runs once).

Returns:
    true

Examples:
    // Implicitly called once during module init. Missions override like so
    // before the mil_c2istar module inits:
    //   ALIVE_COP_CLUSTER_RADIUS = 300;
    //   ALIVE_COP_BFT_ALPHA      = 0.4;

Author:
    Goldwep (ALiVE Mod Team)
    Jman
---------------------------------------------------------------------------- */

TRACE_1("COPConfig - input",_this);

// ============================================================================
// DEBUG / LOGGING — Tier 4 filter (per-category + per-level gates)
// ============================================================================
// Sits ABOVE ALiVE's baseline `_debug` module-attribute gate. When the module's
// debug attribute is set to No, all Tier 2/4 output is silenced regardless of
// these flags. When set to Yes, these flags let you further filter.
//
//   LEVEL: 0=silent, 1=error, 2=warn, 3=info, 4=debug, 5=trace
//
// Runtime edit via debug console, no restart required:
//   ALIVE_COP_DEBUG_LEVEL = 4;
//   ALIVE_COP_DEBUG_RENDER = true;
if (isNil "ALIVE_COP_DEBUG_LEVEL")         then { ALIVE_COP_DEBUG_LEVEL         = 3 };

if (isNil "ALIVE_COP_DEBUG_SERVER")        then { ALIVE_COP_DEBUG_SERVER        = true };
if (isNil "ALIVE_COP_DEBUG_OBJECTIVES")    then { ALIVE_COP_DEBUG_OBJECTIVES    = true };
if (isNil "ALIVE_COP_DEBUG_ASYM")          then { ALIVE_COP_DEBUG_ASYM          = true };
if (isNil "ALIVE_COP_DEBUG_CLIENT")        then { ALIVE_COP_DEBUG_CLIENT        = true };
if (isNil "ALIVE_COP_DEBUG_RENDER")        then { ALIVE_COP_DEBUG_RENDER        = false };
if (isNil "ALIVE_COP_DEBUG_PERF")          then { ALIVE_COP_DEBUG_PERF          = true };
if (isNil "ALIVE_COP_DEBUG_BROADCAST")     then { ALIVE_COP_DEBUG_BROADCAST     = true };
if (isNil "ALIVE_COP_DEBUG_PROFILE")       then { ALIVE_COP_DEBUG_PROFILE       = false };

// Threshold for auto-WARN when a server-loop cycle exceeds this many wall-clock
// milliseconds. Set against wall-clock (not work time) so it includes inter-phase
// sleep yields — Arma's scheduler can delay a `sleep 0.01` by 30-100 ms each on a
// busy server, and Loop A has five such yields per cycle. 250 ms is comfortably
// above idle baseline (typical idle: 200-300 ms) but still flags pathological
// multi-second steady-state cycles.
if (isNil "ALIVE_COP_DEBUG_PERF_WARN_MS")  then { ALIVE_COP_DEBUG_PERF_WARN_MS  = 250 };

// Separate, higher threshold for cycle 1 of each server loop. Cycle 1 pays
// one-time cold-start costs (compile cache warm-up, spatial-grid bucket
// population, CfgVehicles config lookups, profile snapshot enumeration).
// Production missions consistently hit 3-6 seconds on Loop A cycle 1 and
// 1-2 seconds on Loop B cycle 1; the warn at the regular 250 ms threshold
// fires every mission load and is pure noise. 10 s gives plenty of headroom
// for cold-start while still flagging genuinely pathological cycle-1 work.
if (isNil "ALIVE_COP_DEBUG_PERF_WARN_CYCLE1_MS") then { ALIVE_COP_DEBUG_PERF_WARN_CYCLE1_MS = 10000 };

// ============================================================================
// MASTER LAYER TOGGLES
// ============================================================================
if (isNil "ALIVE_COP_LAYER_ENEMIES")       then { ALIVE_COP_LAYER_ENEMIES       = true };
if (isNil "ALIVE_COP_LAYER_BFT")           then { ALIVE_COP_LAYER_BFT           = true };
if (isNil "ALIVE_COP_LAYER_OBJECTIVES")    then { ALIVE_COP_LAYER_OBJECTIVES    = true };
if (isNil "ALIVE_COP_LAYER_ASYMMETRIC")    then { ALIVE_COP_LAYER_ASYMMETRIC    = true };

// ============================================================================
// REFRESH INTERVALS (server-side polling, seconds)
// ============================================================================
if (isNil "ALIVE_COP_INTERVAL_FAST")       then { ALIVE_COP_INTERVAL_FAST       = 30 };
if (isNil "ALIVE_COP_INTERVAL_SLOW")       then { ALIVE_COP_INTERVAL_SLOW       = 60 };

// ============================================================================
// ANCHOR DISTANCE (client-side proximity gate — Eden attribute overrides this)
// ============================================================================
// Radius around the player within which COP intel is drawn on the map.
// Overridden at module init by the copAnchorDistance Eden attribute (any
// number ≥ 100 m; values below 100 are clamped to the default by the
// MAINCLASS shim in fnc_C2ISTAR.sqf). Stored here as the fallback default.
if (isNil "ALIVE_COP_ANCHOR_DISTANCE")     then { ALIVE_COP_ANCHOR_DISTANCE     = 1000 };

// ============================================================================
// LAYER 2 — ENEMY INTEL FEATURES
// ============================================================================

// Tier 1 — recommended
if (isNil "ALIVE_COP_FEAT_SIZE")           then { ALIVE_COP_FEAT_SIZE           = true };
if (isNil "ALIVE_COP_FEAT_MOVEMENT")       then { ALIVE_COP_FEAT_MOVEMENT       = true };
if (isNil "ALIVE_COP_FEAT_ACTIVITY")       then { ALIVE_COP_FEAT_ACTIVITY       = true };
if (isNil "ALIVE_COP_FEAT_AGE")            then { ALIVE_COP_FEAT_AGE            = true };

// Tier 2 — optional
if (isNil "ALIVE_COP_FEAT_FACTION")        then { ALIVE_COP_FEAT_FACTION        = true };
if (isNil "ALIVE_COP_FEAT_CONFIDENCE")     then { ALIVE_COP_FEAT_CONFIDENCE     = true };
if (isNil "ALIVE_COP_FEAT_TRAIL")          then { ALIVE_COP_FEAT_TRAIL          = true };
if (isNil "ALIVE_COP_TRAIL_LENGTH")        then { ALIVE_COP_TRAIL_LENGTH        = 3 };

// Tier 3 — power features
if (isNil "ALIVE_COP_FEAT_THREAT")         then { ALIVE_COP_FEAT_THREAT         = true };
if (isNil "ALIVE_COP_FEAT_COMPOSITION")    then { ALIVE_COP_FEAT_COMPOSITION    = true };

// Threat priority (always highlighted, always shown)
if (isNil "ALIVE_COP_THREAT_TYPES")        then { ALIVE_COP_THREAT_TYPES        = ["air", "armor", "at", "aa", "art"] };

// Clustering
if (isNil "ALIVE_COP_CLUSTER_RADIUS")      then { ALIVE_COP_CLUSTER_RADIUS      = 200 };
if (isNil "ALIVE_COP_FILTER_LONE_INF")     then { ALIVE_COP_FILTER_LONE_INF     = true };
if (isNil "ALIVE_COP_ALWAYS_SHOW")         then { ALIVE_COP_ALWAYS_SHOW         = ["air", "armor", "at", "aa"] };
if (isNil "ALIVE_COP_PLAYER_RADIUS")       then { ALIVE_COP_PLAYER_RADIUS       = 1000 };

// Threat hierarchy — dominant type wins when clustering mixed groups
if (isNil "ALIVE_COP_THREAT_ORDER")        then { ALIVE_COP_THREAT_ORDER        = ["air", "armor", "mech", "motor", "infantry", "unknown"] };

// Confidence border thresholds (seconds since last update)
if (isNil "ALIVE_COP_CONFIDENCE_FRESH")    then { ALIVE_COP_CONFIDENCE_FRESH    = 60 };
if (isNil "ALIVE_COP_CONFIDENCE_AGING")    then { ALIVE_COP_CONFIDENCE_AGING    = 120 };

// Age fade
if (isNil "ALIVE_COP_AGE_FRESH")           then { ALIVE_COP_AGE_FRESH           = 60 };
if (isNil "ALIVE_COP_AGE_FADED")           then { ALIVE_COP_AGE_FADED           = 180 };
if (isNil "ALIVE_COP_AGE_MIN_ALPHA")       then { ALIVE_COP_AGE_MIN_ALPHA       = 0.35 };

// ============================================================================
// LAYER 3 — BFT (Friendly Force Tracking)
// ============================================================================
if (isNil "ALIVE_COP_BFT_FEAT_SIZE")       then { ALIVE_COP_BFT_FEAT_SIZE       = true };
if (isNil "ALIVE_COP_BFT_FEAT_TYPE")       then { ALIVE_COP_BFT_FEAT_TYPE       = true };
if (isNil "ALIVE_COP_BFT_CLUSTER_RADIUS")  then { ALIVE_COP_BFT_CLUSTER_RADIUS  = 300 };
if (isNil "ALIVE_COP_BFT_ALPHA")           then { ALIVE_COP_BFT_ALPHA           = 0.55 };
if (isNil "ALIVE_COP_BFT_SEARCH_RADIUS")   then { ALIVE_COP_BFT_SEARCH_RADIUS   = 8000 };
if (isNil "ALIVE_COP_BFT_LABEL_MIN_COUNT") then { ALIVE_COP_BFT_LABEL_MIN_COUNT = 5 };

// ============================================================================
// LAYER 4 — OPCOM OBJECTIVES (Commander's Intent)
// ============================================================================
if (isNil "ALIVE_COP_OBJ_SHOW_ATTACK")     then { ALIVE_COP_OBJ_SHOW_ATTACK     = true };
if (isNil "ALIVE_COP_OBJ_SHOW_DEFEND")     then { ALIVE_COP_OBJ_SHOW_DEFEND     = true };
if (isNil "ALIVE_COP_OBJ_SHOW_RECON")      then { ALIVE_COP_OBJ_SHOW_RECON      = true };
if (isNil "ALIVE_COP_OBJ_SHOW_RESERVE")    then { ALIVE_COP_OBJ_SHOW_RESERVE    = false };
// Held-objective flag overlay - drawn when ALiVE_fnc_isHeldObjective passes
// for an objective in the Reserve bucket (tacom_state=reserve + section
// profiles alive + <3 enemies within 300m). Visible regardless of the
// Reserve circle toggle since held is the more tactically-useful signal
// (commander knows this anchor is currently friendly).
if (isNil "ALIVE_COP_OBJ_SHOW_HELD")       then { ALIVE_COP_OBJ_SHOW_HELD       = true };
if (isNil "ALIVE_COP_OBJ_HELD_ICON_SIZE")  then { ALIVE_COP_OBJ_HELD_ICON_SIZE  = 24 };
if (isNil "ALIVE_COP_OBJ_AXIS_ARROWS")     then { ALIVE_COP_OBJ_AXIS_ARROWS     = true };
if (isNil "ALIVE_COP_OBJ_LABEL_LOCATIONS") then { ALIVE_COP_OBJ_LABEL_LOCATIONS = true };
if (isNil "ALIVE_COP_OBJ_SHOW_PRIORITY")   then { ALIVE_COP_OBJ_SHOW_PRIORITY   = true };
if (isNil "ALIVE_COP_OBJ_MIN_RADIUS")      then { ALIVE_COP_OBJ_MIN_RADIUS      = 100 };

// Per-state caps
if (isNil "ALIVE_COP_OBJ_MAX_ATTACK")      then { ALIVE_COP_OBJ_MAX_ATTACK      = 10 };
if (isNil "ALIVE_COP_OBJ_MAX_DEFEND")      then { ALIVE_COP_OBJ_MAX_DEFEND      = 10 };
if (isNil "ALIVE_COP_OBJ_MAX_RECON")       then { ALIVE_COP_OBJ_MAX_RECON       = 5 };
if (isNil "ALIVE_COP_OBJ_MAX_RESERVE")     then { ALIVE_COP_OBJ_MAX_RESERVE     = 5 };

// Zoom-aware cutoffs (map scale: 0.05 = max zoom in, 1.0 = max zoom out)
if (isNil "ALIVE_COP_ZOOM_LABEL_MAX")      then { ALIVE_COP_ZOOM_LABEL_MAX      = 0.5 };
if (isNil "ALIVE_COP_ZOOM_ARROW_MAX")      then { ALIVE_COP_ZOOM_ARROW_MAX      = 0.4 };
if (isNil "ALIVE_COP_ZOOM_BFT_MAX")        then { ALIVE_COP_ZOOM_BFT_MAX        = 0.6 };
if (isNil "ALIVE_COP_ZOOM_INTEL_DETAIL")   then { ALIVE_COP_ZOOM_INTEL_DETAIL   = 0.4 };

// ============================================================================
// LAYER 5 — ASYMMETRIC INTEL
// ============================================================================
if (isNil "ALIVE_COP_ASYM_SHOW_ACTIVITY")  then { ALIVE_COP_ASYM_SHOW_ACTIVITY  = true };
if (isNil "ALIVE_COP_ASYM_SHOW_HOSTILITY") then { ALIVE_COP_ASYM_SHOW_HOSTILITY = true };

if (isNil "ALIVE_COP_ASYM_STATES")         then { ALIVE_COP_ASYM_STATES         = ["terrorize", "attack"] };

// Hostility thresholds
if (isNil "ALIVE_COP_ASYM_FRIENDLY_MAX")   then { ALIVE_COP_ASYM_FRIENDLY_MAX   = -25 };
if (isNil "ALIVE_COP_ASYM_HOSTILE_MIN")    then { ALIVE_COP_ASYM_HOSTILE_MIN    = 25 };
if (isNil "ALIVE_COP_ASYM_STRONGHOLD_MIN") then { ALIVE_COP_ASYM_STRONGHOLD_MIN = 75 };

// Skeleton hooks — OFF by default to preserve COIN gameplay. Server broadcasts
// the data regardless; client gates rendering. Runtime-toggleable to enable
// without a restart.
if (isNil "ALIVE_COP_ASYM_SHOW_IED")       then { ALIVE_COP_ASYM_SHOW_IED       = false };
if (isNil "ALIVE_COP_ASYM_SHOW_FACTORY")   then { ALIVE_COP_ASYM_SHOW_FACTORY   = false };
if (isNil "ALIVE_COP_ASYM_SHOW_DEPOT")     then { ALIVE_COP_ASYM_SHOW_DEPOT     = false };
if (isNil "ALIVE_COP_ASYM_SHOW_HQ")        then { ALIVE_COP_ASYM_SHOW_HQ        = false };
if (isNil "ALIVE_COP_ASYM_SHOW_SUICIDE")   then { ALIVE_COP_ASYM_SHOW_SUICIDE   = false };
if (isNil "ALIVE_COP_ASYM_SHOW_SABOTAGE")  then { ALIVE_COP_ASYM_SHOW_SABOTAGE  = false };
if (isNil "ALIVE_COP_ASYM_SHOW_ROADBLOCK") then { ALIVE_COP_ASYM_SHOW_ROADBLOCK = false };

// ============================================================================
// SIZING — marker pixel sizes
// ============================================================================
if (isNil "ALIVE_COP_SIZE_ENEMY")          then { ALIVE_COP_SIZE_ENEMY          = 36 };
if (isNil "ALIVE_COP_SIZE_BFT")            then { ALIVE_COP_SIZE_BFT            = 24 };
if (isNil "ALIVE_COP_SIZE_BADGE")          then { ALIVE_COP_SIZE_BADGE          = 14 };
if (isNil "ALIVE_COP_TEXT_SIZE")           then { ALIVE_COP_TEXT_SIZE           = 0.045 };

// ============================================================================
// FONTS & TEXT
// ============================================================================
if (isNil "ALIVE_COP_FONT_MAIN")           then { ALIVE_COP_FONT_MAIN           = "PuristaMedium" };
if (isNil "ALIVE_COP_FONT_BOLD")           then { ALIVE_COP_FONT_BOLD           = "PuristaBold" };
if (isNil "ALIVE_COP_TEXT_SIZE_LABEL")     then { ALIVE_COP_TEXT_SIZE_LABEL     = 0.04 };
if (isNil "ALIVE_COP_TEXT_SIZE_BADGE")     then { ALIVE_COP_TEXT_SIZE_BADGE     = 0.05 };
if (isNil "ALIVE_COP_TEXT_SIZE_COMPOSITION") then { ALIVE_COP_TEXT_SIZE_COMPOSITION = 0.035 };
if (isNil "ALIVE_COP_TEXT_SIZE_BFT_FACTOR") then { ALIVE_COP_TEXT_SIZE_BFT_FACTOR = 0.85 };

// ============================================================================
// LAYOUT OFFSETS (world meters — positions relative to marker center)
// ============================================================================

// Size indicator (NATO dots/bars above frame)
if (isNil "ALIVE_COP_SIZE_OFFSET_Y")       then { ALIVE_COP_SIZE_OFFSET_Y       = 22 };
if (isNil "ALIVE_COP_SIZE_DOT_SPACING")    then { ALIVE_COP_SIZE_DOT_SPACING    = 8 };
if (isNil "ALIVE_COP_SIZE_DOT_PX")         then { ALIVE_COP_SIZE_DOT_PX         = 6 };
if (isNil "ALIVE_COP_SIZE_BAR_HALF_LEN")   then { ALIVE_COP_SIZE_BAR_HALF_LEN   = 12 };
if (isNil "ALIVE_COP_SIZE_BAR_GAP")        then { ALIVE_COP_SIZE_BAR_GAP        = 3 };

// Activity badge (top-right of frame)
if (isNil "ALIVE_COP_BADGE_OFFSET_X")      then { ALIVE_COP_BADGE_OFFSET_X      = 18 };
if (isNil "ALIVE_COP_BADGE_OFFSET_Y")      then { ALIVE_COP_BADGE_OFFSET_Y      = 14 };

// Composition label (below frame)
if (isNil "ALIVE_COP_COMPOSITION_OFFSET_Y") then { ALIVE_COP_COMPOSITION_OFFSET_Y = -28 };

// Objective label (above circle)
if (isNil "ALIVE_COP_OBJ_LABEL_OFFSET_Y")  then { ALIVE_COP_OBJ_LABEL_OFFSET_Y  = 20 };

// Asym zone label (above circle)
if (isNil "ALIVE_COP_ASYM_LABEL_OFFSET_Y") then { ALIVE_COP_ASYM_LABEL_OFFSET_Y = 18 };

// ============================================================================
// MOVEMENT VECTOR ARROW (Layer 2)
// ============================================================================
if (isNil "ALIVE_COP_MOVEMENT_LEN_SLOW")   then { ALIVE_COP_MOVEMENT_LEN_SLOW   = 25 };
if (isNil "ALIVE_COP_MOVEMENT_LEN_MED")    then { ALIVE_COP_MOVEMENT_LEN_MED    = 45 };
if (isNil "ALIVE_COP_MOVEMENT_LEN_FAST")   then { ALIVE_COP_MOVEMENT_LEN_FAST   = 80 };
if (isNil "ALIVE_COP_MOVEMENT_HEAD_LEN")   then { ALIVE_COP_MOVEMENT_HEAD_LEN   = 8 };
if (isNil "ALIVE_COP_MOVEMENT_HEAD_ANGLE") then { ALIVE_COP_MOVEMENT_HEAD_ANGLE = 0.45 };

// Speed classification (m/s from profile speedPerSecond)
if (isNil "ALIVE_COP_SPEED_STATIONARY")    then { ALIVE_COP_SPEED_STATIONARY    = 0.5 };
if (isNil "ALIVE_COP_SPEED_SLOW")          then { ALIVE_COP_SPEED_SLOW          = 4 };
if (isNil "ALIVE_COP_SPEED_MED")           then { ALIVE_COP_SPEED_MED           = 12 };

// ============================================================================
// TRAIL (Layer 2 Tier 2)
// ============================================================================
if (isNil "ALIVE_COP_TRAIL_ALPHA_FACTOR")  then { ALIVE_COP_TRAIL_ALPHA_FACTOR  = 0.6 };

// ============================================================================
// THREAT HIGHLIGHT RING (Layer 2 Tier 3)
// ============================================================================
if (isNil "ALIVE_COP_THREAT_RING_RADIUS")  then { ALIVE_COP_THREAT_RING_RADIUS  = 35 };
if (isNil "ALIVE_COP_THREAT_PULSE_SPEED")  then { ALIVE_COP_THREAT_PULSE_SPEED  = 180 };
if (isNil "ALIVE_COP_THREAT_ALPHA_MIN")    then { ALIVE_COP_THREAT_ALPHA_MIN    = 0.4 };
if (isNil "ALIVE_COP_THREAT_ALPHA_RANGE")  then { ALIVE_COP_THREAT_ALPHA_RANGE  = 0.5 };

// ============================================================================
// CONFIDENCE RING (Layer 2 Tier 2)
// ============================================================================
if (isNil "ALIVE_COP_CONFIDENCE_RING_ALPHA")  then { ALIVE_COP_CONFIDENCE_RING_ALPHA  = 0.4 };
if (isNil "ALIVE_COP_CONFIDENCE_RING_DASHED") then { ALIVE_COP_CONFIDENCE_RING_DASHED = 28 };
if (isNil "ALIVE_COP_CONFIDENCE_RING_DOTTED") then { ALIVE_COP_CONFIDENCE_RING_DOTTED = 35 };

// ============================================================================
// AXIS-OF-ADVANCE ARROW (Layer 4)
// ============================================================================
if (isNil "ALIVE_COP_AXIS_MIN_DIST")       then { ALIVE_COP_AXIS_MIN_DIST       = 200 };
if (isNil "ALIVE_COP_AXIS_SEG_LEN")        then { ALIVE_COP_AXIS_SEG_LEN        = 30 };
if (isNil "ALIVE_COP_AXIS_GAP_LEN")        then { ALIVE_COP_AXIS_GAP_LEN        = 20 };
if (isNil "ALIVE_COP_AXIS_HEAD_OFFSET")    then { ALIVE_COP_AXIS_HEAD_OFFSET    = 25 };
if (isNil "ALIVE_COP_AXIS_HEAD_WIDTH")     then { ALIVE_COP_AXIS_HEAD_WIDTH     = 12 };
if (isNil "ALIVE_COP_AXIS_ALPHA")          then { ALIVE_COP_AXIS_ALPHA          = 0.5 };

// ============================================================================
// ASYMMETRIC LAYER TUNABLES
// ============================================================================
if (isNil "ALIVE_COP_ASYM_HOSTILITY_RADIUS") then { ALIVE_COP_ASYM_HOSTILITY_RADIUS = 250 };
if (isNil "ALIVE_COP_ASYM_ZONE_ALPHA")     then { ALIVE_COP_ASYM_ZONE_ALPHA     = 0.5 };
if (isNil "ALIVE_COP_ASYM_WARN_ICON_PX")   then { ALIVE_COP_ASYM_WARN_ICON_PX   = 18 };
if (isNil "ALIVE_COP_ASYM_INFRA_ICON_PX")  then { ALIVE_COP_ASYM_INFRA_ICON_PX  = 22 };

// ============================================================================
// LOCATION NAME LOOKUP (helpers)
// ============================================================================
if (isNil "ALIVE_COP_LOC_SEARCH_RADIUS")   then { ALIVE_COP_LOC_SEARCH_RADIUS   = 800 };
if (isNil "ALIVE_COP_LOC_CACHE_BUCKET")    then { ALIVE_COP_LOC_CACHE_BUCKET    = 50 };
// Max entries in ALIVE_COP_LOC_CACHE. Hit-cap drops the oldest 25% to keep
// memory bounded on long-running missions that explore large maps.
if (isNil "ALIVE_COP_LOC_CACHE_MAX")       then { ALIVE_COP_LOC_CACHE_MAX       = 1000 };

// ============================================================================
// SIZE INDICATOR COUNT THRESHOLDS (helpers)
// Counts are PROFILES (groups), not individual soldiers.
// ============================================================================
if (isNil "ALIVE_COP_SIZE_THRESH_SQUAD")   then { ALIVE_COP_SIZE_THRESH_SQUAD   = 1 };
if (isNil "ALIVE_COP_SIZE_THRESH_PLATOON") then { ALIVE_COP_SIZE_THRESH_PLATOON = 3 };
if (isNil "ALIVE_COP_SIZE_THRESH_COMPANY") then { ALIVE_COP_SIZE_THRESH_COMPANY = 7 };

// ============================================================================
// TEXTURE PATHS — centralised so custom asset packs can override
// ============================================================================
if (isNil "ALIVE_COP_TEX_DOT")        then { ALIVE_COP_TEX_DOT        = "\A3\ui_f\data\map\markers\military\dot_ca.paa" };
if (isNil "ALIVE_COP_TEX_WARNING")    then { ALIVE_COP_TEX_WARNING    = "\A3\ui_f\data\map\markers\military\warning_ca.paa" };
if (isNil "ALIVE_COP_TEX_INSTALL")    then { ALIVE_COP_TEX_INSTALL    = "\A3\ui_f\data\map\markers\military\install_ca.paa" };
if (isNil "ALIVE_COP_TEX_BOX")        then { ALIVE_COP_TEX_BOX        = "\A3\ui_f\data\map\markers\military\box_ca.paa" };
if (isNil "ALIVE_COP_TEX_FLAG")       then { ALIVE_COP_TEX_FLAG       = "\A3\ui_f\data\map\markers\military\flag_ca.paa" };
if (isNil "ALIVE_COP_TEX_OBJECTIVE")  then { ALIVE_COP_TEX_OBJECTIVE  = "\A3\ui_f\data\map\markers\military\objective_ca.paa" };
if (isNil "ALIVE_COP_TEX_UNKNOWN")    then { ALIVE_COP_TEX_UNKNOWN    = "\A3\ui_f\data\map\markers\military\unknown_ca.paa" };

// Procedural white fill (tintable by colour param) for sentiment heat shading
if (isNil "ALIVE_COP_TEX_FILL_WHITE") then { ALIVE_COP_TEX_FILL_WHITE = "#(rgb,8,8,3)color(1,1,1,1)" };

// NATO marker path template — %1 = side prefix (b_/o_/n_), %2 = type (inf/armor/...)
if (isNil "ALIVE_COP_NATO_PATH_TEMPLATE") then { ALIVE_COP_NATO_PATH_TEMPLATE = "\A3\ui_f\data\map\markers\nato\%1_%2.paa" };

// ============================================================================
// COLORS — RGBA arrays for drawIcon
// ============================================================================

// Side colours (Arma 3 standard ColorWEST/EAST/Independent)
if (isNil "ALIVE_COP_COLOR_BLUFOR")       then { ALIVE_COP_COLOR_BLUFOR       = [0.0,  0.298, 0.6,  1.0] };
if (isNil "ALIVE_COP_COLOR_OPFOR")        then { ALIVE_COP_COLOR_OPFOR        = [0.5,  0.0,   0.0,  1.0] };
if (isNil "ALIVE_COP_COLOR_INDEP")        then { ALIVE_COP_COLOR_INDEP        = [0.0,  0.498, 0.0,  1.0] };
if (isNil "ALIVE_COP_COLOR_ASYM")         then { ALIVE_COP_COLOR_ASYM         = [0.8,  0.4,   0.0,  1.0] };
// Scratch copy for per-frame alpha mutation (avoids array deep-copy per marker)
if (isNil "ALIVE_COP_COLOR_ASYM_SCRATCH") then { ALIVE_COP_COLOR_ASYM_SCRATCH = +ALIVE_COP_COLOR_ASYM };

// Per-frame scratch for asym-infrastructure leaf draws (factory/cache/HQ/etc).
// Kept SEPARATE from ALIVE_COP_COLOR_ASYM_SCRATCH (which serves the asym-zone
// alpha-fade in fnc_COPRender.sqf:410) so the two paths don't share state.
if (isNil "ALIVE_COP_COLOR_ASYM_INFRA_SCRATCH") then { ALIVE_COP_COLOR_ASYM_INFRA_SCRATCH = +ALIVE_COP_COLOR_ASYM };

// OPCOM objective colours
if (isNil "ALIVE_COP_COLOR_OBJ_ATTACK")   then { ALIVE_COP_COLOR_OBJ_ATTACK   = [0.8,  0.13,  0.13, 0.8] };
if (isNil "ALIVE_COP_COLOR_OBJ_DEFEND")   then { ALIVE_COP_COLOR_OBJ_DEFEND   = [0.2,  0.5,   0.9,  0.8] };
if (isNil "ALIVE_COP_COLOR_OBJ_RECON")    then { ALIVE_COP_COLOR_OBJ_RECON    = [0.96, 0.79,  0.36, 0.8] };
if (isNil "ALIVE_COP_COLOR_OBJ_RESERVE")  then { ALIVE_COP_COLOR_OBJ_RESERVE  = [0.53, 0.53,  0.53, 0.8] };
if (isNil "ALIVE_COP_COLOR_OBJ_HELD")     then { ALIVE_COP_COLOR_OBJ_HELD     = [0.10, 0.78,  0.20, 0.95] };

// Activity badge colours
if (isNil "ALIVE_COP_COLOR_ACT_ATTACK")   then { ALIVE_COP_COLOR_ACT_ATTACK   = [0.8,  0.13,  0.13, 1.0] };
if (isNil "ALIVE_COP_COLOR_ACT_DEFEND")   then { ALIVE_COP_COLOR_ACT_DEFEND   = [0.2,  0.5,   0.9,  1.0] };
if (isNil "ALIVE_COP_COLOR_ACT_MOVE")     then { ALIVE_COP_COLOR_ACT_MOVE     = [0.96, 0.79,  0.36, 1.0] };
if (isNil "ALIVE_COP_COLOR_ACT_GARRISON") then { ALIVE_COP_COLOR_ACT_GARRISON = [0.53, 0.53,  0.53, 1.0] };
if (isNil "ALIVE_COP_COLOR_ACT_RESERVE")  then { ALIVE_COP_COLOR_ACT_RESERVE  = [0.24, 0.75,  0.24, 1.0] };

// Threat priority highlight ring
if (isNil "ALIVE_COP_COLOR_THREAT_RING")    then { ALIVE_COP_COLOR_THREAT_RING    = [1.0, 0.67, 0.0, 0.9] };
if (isNil "ALIVE_COP_COLOR_THREAT_SCRATCH") then { ALIVE_COP_COLOR_THREAT_SCRATCH = +ALIVE_COP_COLOR_THREAT_RING };

// Per-frame scratch for fading trail segments — RGB copied from caller's
// per-marker colour, alpha mutated per segment. If a mission overrides
// any base colour at runtime, also re-init this scratch via deep-copy.
if (isNil "ALIVE_COP_COLOR_TRAIL_SCRATCH") then { ALIVE_COP_COLOR_TRAIL_SCRATCH = +ALIVE_COP_COLOR_THREAT_RING };

// Per-frame scratch for the aging-intel confidence ring — RGB copied from
// caller's per-marker colour, alpha fixed at ALIVE_COP_CONFIDENCE_RING_ALPHA.
if (isNil "ALIVE_COP_COLOR_CONFIDENCE_SCRATCH") then { ALIVE_COP_COLOR_CONFIDENCE_SCRATCH = +ALIVE_COP_COLOR_THREAT_RING };

// Per-frame scratch for BFT (friendly force tracking) marker colour — RGB
// copied from the caller's side colour, alpha fixed at ALIVE_COP_BFT_ALPHA.
// Kept SEPARATE from the other scratches so the BFT path doesn't share state
// with intel/asym draws.
if (isNil "ALIVE_COP_COLOR_BFT_SCRATCH") then { ALIVE_COP_COLOR_BFT_SCRATCH = +ALIVE_COP_COLOR_THREAT_RING };

// Per-frame scratch for objective axis-of-advance arrows — RGB copied from
// ALIVE_COP_COLOR_OBJ_ATTACK, alpha fixed at ALIVE_COP_AXIS_ALPHA. Kept
// SEPARATE from the other scratches per the same isolation rule.
if (isNil "ALIVE_COP_COLOR_AXIS_SCRATCH") then { ALIVE_COP_COLOR_AXIS_SCRATCH = +ALIVE_COP_COLOR_THREAT_RING };

// Per-frame scratch for enemy intel marker — RGB copied from the side's
// base colour, alpha = baseAlpha * COPAgeAlpha(_age). Read by Trail,
// ConfidenceFrame, MovementArrow, SizeIndicator, Composition, and drawIcon
// downstream; all consumers either copy out synchronously or pass to engine,
// so a single scratch shared per-entity-per-frame is safe.
if (isNil "ALIVE_COP_COLOR_ENEMY_SCRATCH") then { ALIVE_COP_COLOR_ENEMY_SCRATCH = +ALIVE_COP_COLOR_THREAT_RING };

// Civilian sentiment overlay
if (isNil "ALIVE_COP_COLOR_HOSTILE")      then { ALIVE_COP_COLOR_HOSTILE      = [0.8,  0.4,   0.0,  0.35] };
if (isNil "ALIVE_COP_COLOR_STRONGHOLD")   then { ALIVE_COP_COLOR_STRONGHOLD   = [0.8,  0.4,   0.0,  0.6] };
if (isNil "ALIVE_COP_COLOR_FRIENDLY")     then { ALIVE_COP_COLOR_FRIENDLY     = [0.18, 0.8,   0.44, 0.25] };

// ============================================================================
// FACTION SHORT CODE MAPPING (faction classname → display code)
// Default coverage: common RHS/RHSGREF/RHSSAF + vanilla factions.
// Missions extend at runtime via:
//   ALIVE_COP_FACTION_CODES_OVERRIDES = createHashMapFromArray [["custom_faction", "CODE"]];
// Overrides are consulted FIRST in ALIVE_fnc_COPFactionShortCode.
// ============================================================================
if (isNil "ALIVE_COP_FACTION_CODES") then {
    ALIVE_COP_FACTION_CODES = createHashMapFromArray [
        ["rhs_faction_usarmy_d",        "USA"],
        ["rhs_faction_usarmy_wd",       "USA"],
        ["rhs_faction_usmc_d",          "USMC"],
        ["rhs_faction_usmc_wd",         "USMC"],
        ["rhs_faction_msv",             "MSV"],
        ["rhs_faction_vdv",             "VDV"],
        ["rhs_faction_vdv_recon",       "VDV"],
        ["rhs_faction_tv",              "TV"],
        ["rhs_faction_vmf",             "VMF"],
        ["rhs_faction_vvs",             "VVS"],
        ["rhs_faction_vvs_c",           "VVS"],
        ["rhsgref_faction_nationalist", "NAT"],
        ["rhsgref_faction_cdf",         "CDF"],
        ["rhsgref_faction_hidf",        "HIDF"],
        ["rhsgref_faction_un",          "UN"],
        ["rhssaf_faction_army",         "SAF"],
        ["BLU_F",                       "NATO"],
        ["OPF_F",                       "CSAT"],
        ["IND_F",                       "AAF"],
        ["IND_G_F",                     "FIA"]
    ];
};

// ============================================================================
// SERVER-SIDE RUNTIME STATE (initialised here so stubs don't error)
// ============================================================================
if (isNil "ALIVE_COP_SERVER_RUNNING") then { ALIVE_COP_SERVER_RUNNING = false };
if (isNil "ALIVE_COP_ASYM_RUNNING")   then { ALIVE_COP_ASYM_RUNNING   = false };
if (isNil "ALIVE_COP_OPCOMS")         then { ALIVE_COP_OPCOMS         = createHashMap };
if (isNil "ALIVE_COP_TRAILS")         then { ALIVE_COP_TRAILS         = createHashMap };
if (isNil "ALIVE_COP_LAST_HASH")      then { ALIVE_COP_LAST_HASH      = createHashMap };
if (isNil "ALIVE_COP_LAST_HASH_ASYM") then { ALIVE_COP_LAST_HASH_ASYM = createHashMap };
if (isNil "ALIVE_COP_ICON_CACHE")     then { ALIVE_COP_ICON_CACHE     = createHashMap };
if (isNil "ALIVE_COP_TYPE_CACHE")     then { ALIVE_COP_TYPE_CACHE     = createHashMap };
if (isNil "ALIVE_COP_LOC_CACHE")      then { ALIVE_COP_LOC_CACHE      = createHashMap };

// Lifecycle log (Tier 1 — always emits via ALiVE_fnc_dump).
["COP - Config: loaded"] call ALiVE_fnc_dump;

private _result = true;
TRACE_1("COPConfig - output",_result);
_result
