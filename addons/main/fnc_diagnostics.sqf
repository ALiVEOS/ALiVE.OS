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

// CPS (Jman 23 Nov): a scheduled loop that counts its own turns, so a row can say how often the scheduler got round to
// a waiting script over its 30 s. It rests while the diagnostics are off
ALiVE_diag_cpsN = 0;
ALiVE_diag_cpsAt = diag_tickTime;
ALiVE_diag_cpsH = [] spawn {
    while {true} do {
        if (ALiVE_diag_active) then {
            ALiVE_diag_cpsN = ALiVE_diag_cpsN + 1;
            sleep 0.001;
        } else {
            sleep 5;
        };
    };
};

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

// Every 10 minutes (each 20th row, and the first): the 15 scripts running most, counted by script name and file, as
// "count name (file)" joined by "; ", to see which of them pile up on a long mission (Jman 23 Nov)
ALiVE_diag_fnc_scriptTop = {
    private _n = createHashMap;
    {
        private _f = _x select 1;
        if (_f select [0, 1] == "\") then { _f = _f select [1] };
        private _parts = _f splitString "\";
        if (count _parts > 3) then { _f = (_parts select [count _parts - 3]) joinString "\" };
        // a ";" in a name or file would split its entry on the page, and a name can be long code text
        private _nm = ((_x select 0) splitString ";") joinString ",";
        if (count _nm > 60) then { _nm = (_nm select [0, 57]) + "..." };
        private _k = [_nm, (_f splitString ";") joinString ","];
        _n set [_k, (_n getOrDefault [_k, 0]) + 1];
    } forEach diag_activeSQFScripts;
    private _rows = (keys _n) apply { [_n get _x, _x select 0, _x select 1] };
    _rows sort false;
    private _text = "";
    {
        _x params ["_c", "_nm", "_fl"];
        private _t = format ["%1 %2 (%3)", _c, _nm, _fl];
        if (count _text + count _t + 2 > 990) exitWith {};
        _text = if (_text == "") then { _t } else { _text + "; " + _t };
    } forEach (_rows select [0, 15]);
    ["SERVER", "SERVER_SCRIPT_TOP", _text] call ALiVE_fnc_diagEvent;
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
    if (!_on) exitWith { ALiVE_diag_fpsMin = 1000; ALiVE_diag_errors = 0; ALiVE_diag_next = time + 30; ALiVE_diag_cpsN = 0; ALiVE_diag_cpsAt = diag_tickTime };
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

    // (Jman 23 Nov) the CPS over this row's time, the AI with no ALiVE profile by the side of its group, and where all
    // AI runs: the server, each headless client (HC1, HC2... in their order), or a player's machine
    private _cps = round (ALiVE_diag_cpsN / ((diag_tickTime - ALiVE_diag_cpsAt) max 1) * 10) / 10;
    ALiVE_diag_cpsN = 0;
    ALiVE_diag_cpsAt = diag_tickTime;
    private _otherSide = [0, 0, 0, 0];
    private _hcIds = (entities "HeadlessClient_F") apply { owner _x };
    private _mach = [["server", 0, 0]];
    { _mach pushBack [format ["HC%1", _forEachIndex + 1], 0, 0] } forEach _hcIds;
    _mach pushBack ["players", 0, 0];
    {
        private _mine = !isNil { _x getVariable "profileID" };
        if (!_mine) then {
            private _i = [west, east, resistance, civilian] find (side group _x);
            if (_i >= 0) then { _otherSide set [_i, (_otherSide select _i) + 1] };
        };
        private _o = owner _x;
        private _h = _hcIds find _o;
        private _row = _mach select (if (_o == 2) then { 0 } else { if (_h >= 0) then { _h + 1 } else { count _mach - 1 } });
        if (_mine) then { _row set [1, (_row select 1) + 1] } else { _row set [2, (_row select 2) + 1] };
    } forEach _ai;

    ALiVE_diag_seq = ALiVE_diag_seq + 1;
    ALiVE_diag_snap pushBack [
        ALiVE_diag_seq, round (time * 10) / 10, round (diag_fps * 10) / 10, round (ALiVE_diag_fpsMin * 10) / 10,
        diag_activeScripts, _profiles, _active, _groups, _opcoms, _mls, _jobs,
        ALiVE_diag_spawns, ALiVE_diag_despawns,
        _aiOther, count vehicles, count allDead, count agents, ALiVE_diag_errors,
        count _ai - _aiOther,
        _cps, _otherSide, _mach
    ];
    if (count ALiVE_diag_snap > 120) then { ALiVE_diag_snap deleteAt 0 };
    ALiVE_diag_spawns = 0;
    ALiVE_diag_despawns = 0;
    ALiVE_diag_errors = 0;
    ALiVE_diag_fpsMin = 1000;

    if (!ALiVE_diag_modsSent) then { ALiVE_diag_modsSent = true; call ALiVE_diag_fnc_mods };
    ALiVE_diag_snapCount = ALiVE_diag_snapCount + 1;
    if (ALiVE_diag_snapCount % 2 == 0) then { call ALiVE_diag_fnc_scripts };
    if (ALiVE_diag_snapCount % 20 == 1) then { call ALiVE_diag_fnc_scriptTop };
}, 1] call CBA_fnc_addPerFrameHandler;
