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

// Once a second: whether it is on, and the lowest frame rate since the last row
ALiVE_diag_pfh = [{
    private _on = if (isNil "ALiVE_WR_diagOn") then {
        missionNamespace getVariable ["ALiVE_diagEnabled", true]
    } else {
        ALiVE_WR_diagOn isEqualTo true
    };
    ALiVE_diag_active = _on;
    if (!_on) exitWith { ALiVE_diag_fpsMin = 1000; ALiVE_diag_next = time + 30 };
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

    ALiVE_diag_seq = ALiVE_diag_seq + 1;
    ALiVE_diag_snap pushBack [
        ALiVE_diag_seq, round (time * 10) / 10, round (diag_fps * 10) / 10, round (ALiVE_diag_fpsMin * 10) / 10,
        diag_activeScripts, _profiles, _active, _groups, _opcoms, _mls, _jobs,
        ALiVE_diag_spawns, ALiVE_diag_despawns
    ];
    if (count ALiVE_diag_snap > 120) then { ALiVE_diag_snap deleteAt 0 };
    ALiVE_diag_spawns = 0;
    ALiVE_diag_despawns = 0;
    ALiVE_diag_fpsMin = 1000;
}, 1] call CBA_fnc_addPerFrameHandler;
