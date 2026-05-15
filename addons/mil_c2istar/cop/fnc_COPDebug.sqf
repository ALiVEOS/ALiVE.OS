#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(COPDebug);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_COPDebug

Description:
    Seeds 11 debug console commands for COP. All are globals that can be
    called from the debug console at runtime without a restart.

    Admin-visible: dumps and toggles always produce RPT output via
    ALiVE_fnc_dump (bypassing the Tier 2 `_debug` module gate), plus an
    audit-trail dump entry so admin actions always appear in RPT.

    Seeded globals:
      ALIVE_fnc_COPDebugDumpAll         — full state dump of every layer
      ALIVE_fnc_COPDebugDumpIntel       — enemy intel per side
      ALIVE_fnc_COPDebugDumpBft         — BFT clusters per side
      ALIVE_fnc_COPDebugDumpObjectives  — OPCOM objectives per side
      ALIVE_fnc_COPDebugDumpAsym        — asymmetric layer (activity/host/infra)
      ALIVE_fnc_COPDebugForceBroadcast  — (server) wipe hash cache
      ALIVE_fnc_COPDebugShowStats       — (client) hint with counts
      ALIVE_fnc_COPDebugSetLevel        — change ALIVE_COP_DEBUG_LEVEL (0-5)
      ALIVE_fnc_COPDebugToggleCategory  — flip a Tier 4 category gate
      ALIVE_fnc_COPDebugInspectOpcom    — (server) dump a tracked OPCOM
      ALIVE_fnc_COPDebugListOpcoms      — (server) list all tracked OPCOMs

Parameters:
    (none)

Returns:
    BOOL - true after command globals are seeded.

Author:
    Goldwep (ALiVE Mod Team)
---------------------------------------------------------------------------- */

TRACE_1("COPDebug - input",_this);

// ============================================================================
// State dumps (admin-visible — bypass module _debug gate via ALiVE_fnc_dump)
// ============================================================================

ALIVE_fnc_COPDebugDumpIntel = {
    {
        private _key = _x;
        private _data = missionNamespace getVariable [format ["ALiVE_COP_IntelData_%1", _key], []];
        ["COP - Debug: IntelData_%1: %2 entries", _key, count _data] call ALiVE_fnc_dump;
        {
            _x params [["_pos", [0,0,0]], ["_side", "?"], ["_type", "?"], ["_faction", "?"],
                       ["_count", 0], ["_size", "?"], ["_activity", ""], ["_heading", 0],
                       ["_speed", 0], ["_age", 0], ["_isMixed", false], ["_trail", []]];
            ["COP - Debug:   [%1] pos=%2 side=%3 type=%4 fac=%5 cnt=%6 sz=%7 act=%8 hdg=%9 spd=%10 mixed=%11 trail=%12",
                _forEachIndex, _pos, _side, _type, _faction, _count, _size, _activity, _heading, _speed, _isMixed, count _trail] call ALiVE_fnc_dump;
        } forEach _data;
    } forEach ["WEST", "EAST", "GUER"];
};

ALIVE_fnc_COPDebugDumpBft = {
    {
        private _key = _x;
        private _data = missionNamespace getVariable [format ["ALiVE_COP_BftData_%1", _key], []];
        ["COP - Debug: BftData_%1: %2 entries", _key, count _data] call ALiVE_fnc_dump;
        {
            _x params [["_pos", [0,0,0]], ["_type", "?"], ["_count", 0], ["_size", "?"]];
            ["COP - Debug:   [%1] pos=%2 type=%3 cnt=%4 sz=%5", _forEachIndex, _pos, _type, _count, _size] call ALiVE_fnc_dump;
        } forEach _data;
    } forEach ["WEST", "EAST", "GUER"];
};

ALIVE_fnc_COPDebugDumpObjectives = {
    {
        private _key = _x;
        private _data = missionNamespace getVariable [format ["ALiVE_COP_ObjectivesData_%1", _key], []];
        ["COP - Debug: ObjectivesData_%1: %2 entries", _key, count _data] call ALiVE_fnc_dump;
        {
            _x params [["_pos", [0,0,0]], ["_size", 0], ["_state", "?"], ["_loc", "?"], ["_prio", 0]];
            ["COP - Debug:   [%1] pos=%2 r=%3m state=%4 loc=%5 prio=%6", _forEachIndex, _pos, _size, _state, _loc, _prio] call ALiVE_fnc_dump;
        } forEach _data;
    } forEach ["WEST", "EAST", "GUER"];
};

ALIVE_fnc_COPDebugDumpAsym = {
    private _act   = missionNamespace getVariable ["ALiVE_COP_AsymActivityData", []];
    private _host  = missionNamespace getVariable ["ALiVE_COP_AsymHostilityData", []];
    private _infra = missionNamespace getVariable ["ALiVE_COP_AsymInfraData", []];

    ["COP - Debug: AsymActivityData: %1 entries", count _act] call ALiVE_fnc_dump;
    {
        _x params [["_state", "?"], ["_pos", [0,0,0]], ["_size", 0], ["_loc", "?"]];
        ["COP - Debug:   [%1] state=%2 pos=%3 r=%4m loc=%5", _forEachIndex, _state, _pos, _size, _loc] call ALiVE_fnc_dump;
    } forEach _act;

    ["COP - Debug: AsymHostilityData: %1 entries", count _host] call ALiVE_fnc_dump;
    {
        _x params [["_pos", [0,0,0]], ["_size", 0], ["_hostArr", []]];
        ["COP - Debug:   [%1] pos=%2 r=%3m hostility=%4", _forEachIndex, _pos, _size, _hostArr] call ALiVE_fnc_dump;
    } forEach _host;

    ["COP - Debug: AsymInfraData: %1 entries", count _infra] call ALiVE_fnc_dump;
    {
        _x params [["_type", "?"], ["_pos", [0,0,0]]];
        ["COP - Debug:   [%1] type=%2 pos=%3", _forEachIndex, _type, _pos] call ALiVE_fnc_dump;
    } forEach _infra;
};

ALIVE_fnc_COPDebugDumpAll = {
    ["COP - Debug: DumpAll invoked"] call ALiVE_fnc_dump;
    ["COP - Debug: ============================================================"] call ALiVE_fnc_dump;
    ["COP - Debug: FULL DATA DUMP"] call ALiVE_fnc_dump;
    ["COP - Debug: Time: %1 | Side cache: %2 | Anchor: %3m",
        time,
        missionNamespace getVariable ["ALIVE_COP_playerSideKey", "?"],
        missionNamespace getVariable ["ALIVE_COP_ANCHOR_DISTANCE", 1000]
    ] call ALiVE_fnc_dump;
    ["COP - Debug: Log level: %1 | Layers: enemies=%2 bft=%3 obj=%4 asym=%5",
        missionNamespace getVariable ["ALIVE_COP_DEBUG_LEVEL", 3],
        ALIVE_COP_LAYER_ENEMIES, ALIVE_COP_LAYER_BFT,
        ALIVE_COP_LAYER_OBJECTIVES, ALIVE_COP_LAYER_ASYMMETRIC
    ] call ALiVE_fnc_dump;
    ["COP - Debug: ------------------------------------------------------------"] call ALiVE_fnc_dump;
    call ALIVE_fnc_COPDebugDumpIntel;
    ["COP - Debug: ------------------------------------------------------------"] call ALiVE_fnc_dump;
    call ALIVE_fnc_COPDebugDumpBft;
    ["COP - Debug: ------------------------------------------------------------"] call ALiVE_fnc_dump;
    call ALIVE_fnc_COPDebugDumpObjectives;
    ["COP - Debug: ------------------------------------------------------------"] call ALiVE_fnc_dump;
    call ALIVE_fnc_COPDebugDumpAsym;
    ["COP - Debug: ============================================================"] call ALiVE_fnc_dump;
    if (hasInterface) then { systemChat "[COP] Dumped to RPT. Check arma3.rpt log." };
};

// ============================================================================
// Force broadcast (server only — wipes hash cache)
// ============================================================================

ALIVE_fnc_COPDebugForceBroadcast = {
    if (!isServer) exitWith {
        if (hasInterface) then { systemChat "[COP] Force broadcast must run on server." };
        ["[WARN] COP - Debug: ForceBroadcast invoked on non-server machine"] call ALiVE_fnc_dump;
    };

    if (!isNil "ALIVE_COP_LAST_HASH") then {
        ALIVE_COP_LAST_HASH = createHashMap;
    };
    if (!isNil "ALIVE_COP_LAST_HASH_ASYM") then {
        ALIVE_COP_LAST_HASH_ASYM = createHashMap;
    };

    ["COP - Debug: Hash cache cleared — next cycle will broadcast all data"] call ALiVE_fnc_dump;
    if (hasInterface) then { systemChat "[COP] Hash cleared. Wait up to 60s for next broadcast." };
};

// ============================================================================
// On-screen stats (client only)
// ============================================================================

ALIVE_fnc_COPDebugShowStats = {
    if (!hasInterface) exitWith {};

    private _sideKey = missionNamespace getVariable ["ALIVE_COP_playerSideKey", "?"];
    private _intel = missionNamespace getVariable [format ["ALiVE_COP_IntelData_%1", _sideKey], []];
    private _bft   = missionNamespace getVariable [format ["ALiVE_COP_BftData_%1", _sideKey], []];
    private _obj   = missionNamespace getVariable [format ["ALiVE_COP_ObjectivesData_%1", _sideKey], []];
    private _asymA = missionNamespace getVariable ["ALiVE_COP_AsymActivityData", []];
    private _asymH = missionNamespace getVariable ["ALiVE_COP_AsymHostilityData", []];
    private _asymI = missionNamespace getVariable ["ALiVE_COP_AsymInfraData", []];

    private _msg = format [
        "COP — DEBUG STATS\n\nSide: %1\nAnchor: %2 m\n\nLayer 2 (Enemy): %3 clusters\nLayer 3 (BFT): %4 clusters\nLayer 4 (Objectives): %5 entries\n\nLayer 5 — Asymmetric:\n  Activity zones: %6\n  Hostility entries: %7\n  Infrastructure: %8\n\nLog level: %9 (0=silent, 5=trace)\n\nLayers enabled:\n  Enemies: %10\n  BFT: %11\n  Objectives: %12\n  Asymmetric: %13",
        _sideKey,
        missionNamespace getVariable ["ALIVE_COP_ANCHOR_DISTANCE", 1000],
        count _intel, count _bft, count _obj,
        count _asymA, count _asymH, count _asymI,
        missionNamespace getVariable ["ALIVE_COP_DEBUG_LEVEL", 3],
        ALIVE_COP_LAYER_ENEMIES, ALIVE_COP_LAYER_BFT,
        ALIVE_COP_LAYER_OBJECTIVES, ALIVE_COP_LAYER_ASYMMETRIC
    ];

    hint _msg;
    ["COP - Debug: ShowStats emitted hint to client"] call ALiVE_fnc_dump;
};

// ============================================================================
// Runtime Tier 4 filter toggles (emit dump audit trail)
// ============================================================================

ALIVE_fnc_COPDebugSetLevel = {
    private _newLevel = _this max 0 min 5;
    private _oldLevel = missionNamespace getVariable ["ALIVE_COP_DEBUG_LEVEL", 3];
    ALIVE_COP_DEBUG_LEVEL = _newLevel;
    private _msg = format ["COP - Debug: level changed %1 -> %2", _oldLevel, _newLevel];
    [_msg] call ALiVE_fnc_dump;
    if (hasInterface) then { systemChat format ["[COP] Log level: %1 -> %2", _oldLevel, _newLevel] };
};

ALIVE_fnc_COPDebugToggleCategory = {
    private _cat = toLower _this;
    private _varName = switch (_cat) do {
        case "server":     { "ALIVE_COP_DEBUG_SERVER" };
        case "objectives": { "ALIVE_COP_DEBUG_OBJECTIVES" };
        case "asym":       { "ALIVE_COP_DEBUG_ASYM" };
        case "client":     { "ALIVE_COP_DEBUG_CLIENT" };
        case "render":     { "ALIVE_COP_DEBUG_RENDER" };
        case "perf":       { "ALIVE_COP_DEBUG_PERF" };
        case "broadcast":  { "ALIVE_COP_DEBUG_BROADCAST" };
        case "profile":    { "ALIVE_COP_DEBUG_PROFILE" };
        default            { "" };
    };

    if (_varName == "") exitWith {
        if (hasInterface) then {
            systemChat format ["[COP] Unknown category: %1", _cat];
            systemChat "Valid: server, objectives, asym, client, render, perf, broadcast, profile";
        };
        [format ["[WARN] COP - Debug: ToggleCategory unknown category '%1'", _cat]] call ALiVE_fnc_dump;
    };

    private _current = missionNamespace getVariable [_varName, false];
    private _new = !_current;
    missionNamespace setVariable [_varName, _new];
    private _msg = format ["COP - Debug: category %1 = %2 (was %3)", _cat, _new, _current];
    [_msg] call ALiVE_fnc_dump;
    if (hasInterface) then { systemChat format ["[COP] %1: %2 -> %3", _cat, _current, _new] };
};

// ============================================================================
// OPCOM introspection (server only)
// ============================================================================

ALIVE_fnc_COPDebugInspectOpcom = {
    private _key = toUpper _this;

    if (!isServer) exitWith {
        if (hasInterface) then { systemChat "[COP] OPCOM inspection must run on server." };
        ["[WARN] COP - Debug: InspectOpcom invoked on non-server machine"] call ALiVE_fnc_dump;
    };

    if (isNil "ALIVE_COP_OPCOMS") exitWith {
        if (hasInterface) then { systemChat "[COP] ALIVE_COP_OPCOMS not initialised." };
        ["COP - Debug: ALIVE_COP_OPCOMS not initialised"] call ALiVE_fnc_dump;
    };

    if (!(_key in ALIVE_COP_OPCOMS)) exitWith {
        if (hasInterface) then { systemChat format ["[COP] No OPCOM tracked for side: %1", _key] };
        ["COP - Debug: no OPCOM tracked for side %1", _key] call ALiVE_fnc_dump;
    };

    private _opcom = ALIVE_COP_OPCOMS get _key;
    private _name = [_opcom, "name", ""] call ALiVE_fnc_HashGet;
    private _ctrl = [_opcom, "controltype", ""] call ALiVE_fnc_HashGet;
    private _factions = [_opcom, "factions", []] call ALiVE_fnc_HashGet;
    private _objectives = [_opcom, "objectives", []] call ALiVE_fnc_HashGet;
    private _known = [_opcom, "knownentities", []] call ALiVE_fnc_HashGet;

    [format ["COP - Debug: InspectOpcom %1", _key]] call ALiVE_fnc_dump;
    ["COP - Debug: === OPCOM %1 ===", _key] call ALiVE_fnc_dump;
    ["COP - Debug:   name: %1", _name] call ALiVE_fnc_dump;
    ["COP - Debug:   controltype: %1", _ctrl] call ALiVE_fnc_dump;
    ["COP - Debug:   factions: %1", _factions] call ALiVE_fnc_dump;
    ["COP - Debug:   objectives: %1", count _objectives] call ALiVE_fnc_dump;
    ["COP - Debug:   knownentities: %1", count _known] call ALiVE_fnc_dump;

    if (hasInterface) then { systemChat format ["[COP] %1 OPCOM: %2 obj, %3 known. Details in RPT.", _key, count _objectives, count _known] };
};

ALIVE_fnc_COPDebugListOpcoms = {
    if (!isServer) exitWith {
        if (hasInterface) then { systemChat "[COP] OPCOM list must run on server." };
        ["[WARN] COP - Debug: ListOpcoms invoked on non-server machine"] call ALiVE_fnc_dump;
    };

    if (isNil "ALIVE_COP_OPCOMS") exitWith {
        if (hasInterface) then { systemChat "[COP] ALIVE_COP_OPCOMS not initialised." };
        ["COP - Debug: ALIVE_COP_OPCOMS not initialised"] call ALiVE_fnc_dump;
    };

    ["COP - Debug: ListOpcoms invoked"] call ALiVE_fnc_dump;
    ["COP - Debug: === Tracked OPCOMs ==="] call ALiVE_fnc_dump;
    ["COP - Debug:   Conventional: %1", count ALIVE_COP_OPCOMS] call ALiVE_fnc_dump;
    {
        private _name = [_y, "name", ""] call ALiVE_fnc_HashGet;
        private _ctrl = [_y, "controltype", ""] call ALiVE_fnc_HashGet;
        private _objs = [_y, "objectives", []] call ALiVE_fnc_HashGet;
        private _known = [_y, "knownentities", []] call ALiVE_fnc_HashGet;
        ["COP - Debug:     %1: %2 (%3) — %4 obj, %5 known", _x, _name, _ctrl, count _objs, count _known] call ALiVE_fnc_dump;
    } forEach ALIVE_COP_OPCOMS;

    if (!isNil "ALIVE_COP_ASYM_OPCOM") then {
        private _name = [ALIVE_COP_ASYM_OPCOM, "name", ""] call ALiVE_fnc_HashGet;
        private _objs = [ALIVE_COP_ASYM_OPCOM, "objectives", []] call ALiVE_fnc_HashGet;
        ["COP - Debug:   Asymmetric: %1 — %2 objectives", _name, count _objs] call ALiVE_fnc_dump;
    } else {
        ["COP - Debug:   Asymmetric: not found"] call ALiVE_fnc_dump;
    };

    if (hasInterface) then { systemChat "[COP] OPCOM list dumped to RPT." };
};

["COP - Debug: 11 commands seeded"] call ALiVE_fnc_dump;

private _result = true;
TRACE_1("COPDebug - output",_result);
_result
