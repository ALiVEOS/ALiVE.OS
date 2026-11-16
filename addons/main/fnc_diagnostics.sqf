#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(diagnostics);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_diagnostics

Description:
Starts the DEV-build diagnostics on the server: a snapshot of the server's state
every 30 s, and the event ring that ALiVE_fnc_diagEvent writes to, both read by
the War Room extension (alive_wr). What each row holds is in diag_codes.hpp.

Release builds and clients do nothing. While running, the War Room's own switch
decides when it has set ALiVE_WR_diagOn; until then the CBA setting
ALiVE_diagEnabled does (on by default). Switched off, nothing is collected.

Parameters:
None

Returns:
Nothing

Examples:
(begin example)
[] call ALiVE_fnc_diagnostics;
(end)

Author:
Jman
---------------------------------------------------------------------------- */

if (!isServer) exitWith {};
if (!isNil "ALiVE_diag_pfh") exitWith {};
// the packed config says what shipped; the macro only when it can't be read (as XEH_preInit's version line)
private _patch = configFile >> "CfgPatches" >> QUOTE(ADDON);
private _buildType = getText (_patch >> "buildType");
if (_buildType isEqualTo "") then { _buildType = BUILDTYPE };
if (_buildType != "DEV") exitWith {};

ALiVE_diag_schema = 1;
ALiVE_diag_build = format ["%1 %2", getText (_patch >> "versionStr"), _buildType];
ALiVE_diag_seq = 0;
ALiVE_diag_snap = [];
ALiVE_diag_events = [];
ALiVE_diag_codeTimes = createHashMap;
ALiVE_diag_codeHeld = createHashMap;
ALiVE_diag_spawns = 0;
ALiVE_diag_despawns = 0;
ALiVE_diag_fpsMin = 1000;
ALiVE_diag_next = time + 30;
ALiVE_diag_active = false;
ALiVE_diag_snapCount = 0;
ALiVE_diag_modsSent = false;
// script errors anywhere on the server (any mod or the mission), counted by the engine's ScriptError event
ALiVE_diag_errors = 0;
addMissionEventHandler ["ScriptError", { ALiVE_diag_errors = ALiVE_diag_errors + 1 }];

// Every minute (each 2nd row): the scripts running, by where their file comes from, and the mission FSMs
ALiVE_diag_fnc_scripts = {
    private _groups = createHashMap;
    {
        private _f = toLower (_x select 1);
        if (_f select [0, 1] == "\") then { _f = _f select [1] };
        private _parts = _f splitString "\";
        private _key = switch (true) do {
            case (_f == ""): { "no file" };
            case (_f select [0, 8] == "x\alive\"): { "ALiVE" };
            case (_f select [0, 6] == "x\cba\"): { "CBA" };
            case (_f select [0, 6] == "z\ace\"): { "ACE" };
            case ("mpmissions\" in _f || {"__cur_mp" in _f} || {count _parts < 3}): { "mission" };
            default { (_parts select 0) + "\" + (_parts select 1) };
        };
        _groups set [_key, (_groups getOrDefault [_key, 0]) + 1];
    } forEach diag_activeSQFScripts;
    private _rows = (keys _groups) apply { [_groups get _x, _x] };
    _rows sort false;
    private _text = format ["%1; FSMs %2", (_rows apply { format ["%1 %2", _x select 1, _x select 0] }) joinString ", ", count diag_activeMissionFSMs];
    ["SERVER", "SERVER_SCRIPTS", _text] call ALiVE_fnc_diagEvent;
};

// Once a run: the loaded mods by name, split over several events past 1000 characters
ALiVE_diag_fnc_mods = {
    private _names = getLoadedModsInfo apply { _x select 0 };
    private _chunk = "";
    {
        if (count _chunk + count _x + 2 > 990) then {
            ["SERVER", "SERVER_MODS", _chunk] call ALiVE_fnc_diagEvent;
            _chunk = "";
        };
        _chunk = if (_chunk == "") then { _x } else { _chunk + ", " + _x };
    } forEach _names;
    if (_chunk != "") then { ["SERVER", "SERVER_MODS", _chunk] call ALiVE_fnc_diagEvent };
};

// Once a second: whether it is on, and the lowest frame rate since the last row
ALiVE_diag_pfh = [{
    private _on = if (isNil "ALiVE_WR_diagOn") then {
        missionNamespace getVariable ["ALiVE_diagEnabled", true]
    } else {
        ALiVE_WR_diagOn isEqualTo true
    };
    ALiVE_diag_active = _on;
    if (!_on) exitWith { ALiVE_diag_fpsMin = 1000; ALiVE_diag_errors = 0; ALiVE_diag_next = time + 30 };
    ALiVE_diag_fpsMin = ALiVE_diag_fpsMin min diag_fpsMin;
    if (time < ALiVE_diag_next) exitWith {};
    ALiVE_diag_next = time + 30;

    private _profiles = -1;
    private _active = -1;
    if (!isNil "ALIVE_profileHandler") then {
        private _all = [ALIVE_profileHandler, "profiles"] call ALIVE_fnc_hashGet;
        if (!isNil "_all") then { _profiles = count (_all select 1) };
        _active = count ([ALIVE_profileHandler, "profilesActive", []] call ALIVE_fnc_hashGet);
    };

    private _groups = [west, east, resistance, civilian] apply { private _s = _x; {side _x == _s} count allGroups };

    // each AI Commander: seconds since its cycle last moved on
    private _opcoms = (missionNamespace getVariable ["OPCOM_instances", []]) apply {
        private _fsm = [_x, "OPCOM_FSM"] call ALiVE_fnc_HashGet;
        private _stamp = if (isNil "_fsm") then { nil } else { _fsm getFSMVariable "_timestamp" };
        [[_x, "side", ""] call ALiVE_fnc_HashGet, if (isNil "_stamp") then { -1 } else { round (time - _stamp) }]
    };

    // each Military Logistics module: its faction and the requests it holds
    if (isNil "ALiVE_diag_mls") then { ALiVE_diag_mls = (allMissionObjects "Logic") select { typeOf _x == "ALiVE_mil_logistics" } };
    private _mls = ALiVE_diag_mls apply {
        private _queue = [_x, "eventQueue"] call ALIVE_fnc_ML;
        [((([_x, "factions"] call ALIVE_fnc_ML) param [0, []]) param [1, []]) param [0, ""], -1, if (isNil "_queue") then { -1 } else { count (_queue select 1) }]
    };

    private _jobs = if (isNil "alive_pathfinder") then { -1 } else { count (alive_pathfinder getOrDefault ["pathJobs", []]) };

    // what else costs frame rate: AI with no ALiVE profile (ALiVE marks every unit it spawns or takes over with
    // the "profileID" variable; CQB and mission-placed AI count here), vehicles, dead bodies and wrecks, agents
    private _ai = allUnits select { !isPlayer _x };
    private _aiOther = { isNil { _x getVariable "profileID" } } count _ai;

    ALiVE_diag_seq = ALiVE_diag_seq + 1;
    ALiVE_diag_snap pushBack [
        ALiVE_diag_seq, round (time * 10) / 10, round (diag_fps * 10) / 10, round (ALiVE_diag_fpsMin * 10) / 10,
        diag_activeScripts, _profiles, _active, _groups, _opcoms, _mls, _jobs,
        ALiVE_diag_spawns, ALiVE_diag_despawns,
        _aiOther, count vehicles, count allDead, count agents, ALiVE_diag_errors,
        count _ai - _aiOther
    ];
    if (count ALiVE_diag_snap > 120) then { ALiVE_diag_snap deleteAt 0 };
    ALiVE_diag_spawns = 0;
    ALiVE_diag_despawns = 0;
    ALiVE_diag_errors = 0;
    ALiVE_diag_fpsMin = 1000;

    if (!ALiVE_diag_modsSent) then { ALiVE_diag_modsSent = true; call ALiVE_diag_fnc_mods };
    ALiVE_diag_snapCount = ALiVE_diag_snapCount + 1;
    if (ALiVE_diag_snapCount % 2 == 0) then { call ALiVE_diag_fnc_scripts };
}, 1] call CBA_fnc_addPerFrameHandler;
