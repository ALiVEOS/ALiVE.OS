#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(COPLog);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_COPLog

Description:
    Four-tier logging dispatcher for the COP commander intel overlay.
    Provides a single entry point for all COP code while internally routing
    to the appropriate ALiVE logging machinery so output is indistinguishable
    from other ALiVE modules.

    Tier 1 — Lifecycle (error/warn/critical): emitted via ALiVE_fnc_dump
             with an inline severity prefix ([ERROR], [WARN], [CRITICAL]).
             Always logs, regardless of module debug attribute. Matches the
             direct ALiVE_fnc_dump usage pattern in mil_opcom / mil_logistics.

    Tier 2 — Runtime observability (info/debug/trace): ALiVE_fnc_dump,
             gated by the mil_c2istar module's `debug` attribute.
             Output format (produced by fnc_dump.sqf):
               ALiVE <time> : <tickTime> - COP - <category>: <message>

    Tier 4 — Granular filter (CATEGORY + LEVEL): additional per-category
             booleans and a master level threshold, applied only to Tier 2
             output. Silence render-spam without killing the whole stream.

    Tier 3 — Function entry/exit traces use the CBA TRACE_1 / TRACE_2 macros
             called inline at each function header — those are NOT routed
             through this dispatcher. The "trace" severity level accepted by
             this function below is the Tier 2/4 level-5 verbose tier, which
             is distinct from the CBA TRACE_* macro path.

Parameters:
    0: STRING - Severity level. One of:
                "error", "critical", "warn", "info", "debug", "trace"
    1: STRING - Category (used for Tier 4 filter and formatting prefix).
                One of: "server", "objectives", "asym", "client", "render",
                        "perf", "broadcast", "profile", "init", "debug"
    2: STRING - Format string with %1, %2, ... placeholders.
    3: ARRAY  - (optional) Arguments for the format placeholders. Default [].

Returns:
    BOOL - true if the message was emitted, false if suppressed by a gate.

Examples:
    (begin example)
    // Lifecycle (always logs, bypasses module debug gate):
    ["info", "init", "COP enabled, anchor distance %1m", [_anchorDist]] call ALIVE_fnc_COPLog;

    // Error (always logs, prefixed [ERROR]):
    ["error", "server", "getNearProfiles returned nil for side %1", [_side]] call ALIVE_fnc_COPLog;

    // Info-level runtime summary (gated by module _debug + category + level):
    ["info", "server", "LoopA cycle %1 | %2ms", [_cycle, _ms]] call ALIVE_fnc_COPLog;

    // Perf warning (always logs, prefixed [WARN]):
    ["warn", "perf", "Loop A cycle %1 took %2ms (threshold %3ms)", [_cycle, _ms, _th]] call ALIVE_fnc_COPLog;
    (end)

Author:
    Goldwep (ALiVE Mod Team)
---------------------------------------------------------------------------- */

params [
    ["_level",    "info",  [""]],
    ["_category", "debug", [""]],
    ["_format",   "",      [""]],
    ["_args",     [],      [[]]]
];

private _msg = if (_args isEqualTo []) then {
    _format
} else {
    format ([_format] + _args)
};

private _prefixed = format ["COP - %1: %2", _category, _msg];

// ---- Tier 1: lifecycle — always dump via ALiVE_fnc_dump (bypass module gate) ----
// Severity prefix is inline in the message text since ALiVE_fnc_dump is
// severity-agnostic (same pattern used by mil_logistics warnings).
switch (toLower _level) do {
    case "error": {
        [format ["[ERROR] %1", _prefixed]] call ALiVE_fnc_dump;
        true
    };
    case "critical": {
        [format ["[CRITICAL] %1", _prefixed]] call ALiVE_fnc_dump;
        true
    };
    case "warn": {
        [format ["[WARN] %1", _prefixed]] call ALiVE_fnc_dump;
        true
    };

    // ---- Tier 2: runtime — gated by module _debug attribute + Tier 4 filter ----
    default {
        // Module debug gate: resolve c2istar module's `debug` attribute.
        // If the module reference is nil or destroyed, suppress (Tier 2 off).
        private _moduleDebug = false;
        if (!isNil { MOD(MIL_C2ISTAR) }) then {
            _moduleDebug = (MOD(MIL_C2ISTAR)) getVariable ["debug", false];
        };
        if (!_moduleDebug) exitWith { false };

        // Tier 4 level filter
        private _levelNum = switch (toLower _level) do {
            case "info":  { 3 };
            case "debug": { 4 };
            case "trace": { 5 };
            default { 3 };
        };
        if (_levelNum > (missionNamespace getVariable ["ALIVE_COP_DEBUG_LEVEL", 3])) exitWith { false };

        // Tier 4 category filter (one boolean per category)
        private _categoryGate = switch (toLower _category) do {
            case "server":     { missionNamespace getVariable ["ALIVE_COP_DEBUG_SERVER",     true] };
            case "objectives": { missionNamespace getVariable ["ALIVE_COP_DEBUG_OBJECTIVES", true] };
            case "asym":       { missionNamespace getVariable ["ALIVE_COP_DEBUG_ASYM",       true] };
            case "client":     { missionNamespace getVariable ["ALIVE_COP_DEBUG_CLIENT",     true] };
            case "render":     { missionNamespace getVariable ["ALIVE_COP_DEBUG_RENDER",     false] };
            case "perf":       { missionNamespace getVariable ["ALIVE_COP_DEBUG_PERF",       true] };
            case "broadcast":  { missionNamespace getVariable ["ALIVE_COP_DEBUG_BROADCAST",  true] };
            case "profile":    { missionNamespace getVariable ["ALIVE_COP_DEBUG_PROFILE",    false] };
            // init / debug / unknown categories: no extra gate
            default { true };
        };
        if (!_categoryGate) exitWith { false };

        // Emit via ALiVE's standard dump (same formatter as every other module)
        [_prefixed] call ALiVE_fnc_dump;
        true
    };
};
