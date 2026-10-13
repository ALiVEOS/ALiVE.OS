#include "\x\alive\addons\sys_perf\script_component.hpp"
SCRIPT(perfServer);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_perfServer
Description:
Server performance monitor (#1031). Runs on the server (the host's machine in single
player or on a listen server). While it runs it takes a sample every interval, writes it
to the RPT as one line starting "ALiVE PERF", and broadcasts the latest sample so an
admin's Show Perf readout can display it. It does not depend on the War Room: the old
web-service recorder in fnc_perfInit.sqf is untouched and still off.

An admin's Start Perf and Stop Perf reach this by remoteExecCall; a call from a machine
whose player is not a logged-in or voted admin is refused.

While an admin has Show Perf open, the server also takes a sample every 10 seconds for the
readout alone ("watch"), whether or not monitoring runs; those aren't written to the RPT.

Parameters:
_this select 0: STRING - "start", "stop", "sample" or "watch"
_this select 1: NUMBER - seconds between samples, for "start" (optional, default 60); for
"watch", 1 to start watching and 0 to stop

Returns:
Nil

Examples:
(begin example)
["start"] remoteExecCall ["ALIVE_fnc_perfServer", 2];
(end)

See Also:
- <ALIVE_fnc_perfMenuInit>
- <ALIVE_fnc_perfMenuDef>

Author:
Jman

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

params [["_operation", "", [""]], ["_interval", 60, [0]], ["_log", true, [true]]];

if (!isServer) exitWith {};

// Only an admin, or the host on a listen server (owner 2), can start or stop it remotely
if (isRemoteExecuted && {remoteExecutedOwner != 2} && {(admin remoteExecutedOwner) == 0}) exitWith {
    ["ALiVE PERF - refused a %1 request from a machine without admin rights (owner %2)", _operation, remoteExecutedOwner] call ALiVE_fnc_dump;
};

switch (_operation) do {

    case "sample": {
        private _units = allUnits;
        private _players = {alive _x && {isPlayer _x}} count _units;
        private _localAI = {alive _x && {local _x} && {!isPlayer _x}} count _units;
        private _remoteAI = ({alive _x} count _units) - _players - _localAI;
        private _active = -1;
        private _inactive = -1;
        if (!isNil "ALIVE_profileHandler") then {
            _active = count ([ALIVE_profileHandler, "getActiveEntities"] call ALIVE_fnc_profileHandler);
            _inactive = count ([ALIVE_profileHandler, "getInActiveEntities"] call ALIVE_fnc_profileHandler);
        };
        private _scripts = diag_activeScripts;

        private _sample = [
            ["time", round time],
            ["fps", round diag_fps],
            ["fpsMin", round diag_fpsmin],
            ["players", _players],
            ["localAI", _localAI],
            ["remoteAI", _remoteAI],
            ["groups", count allGroups],
            ["vehicles", count vehicles],
            ["dead", count allDead],
            ["profilesActive", _active],
            ["profilesInactive", _inactive],
            ["scripts", (_scripts select 0) + (_scripts select 1) + (_scripts select 2)],
            ["fsms", _scripts select 3]
        ];

        if (_log) then { diag_log text format ["ALiVE PERF | %1", (_sample apply {format ["%1=%2", _x select 0, _x select 1]}) joinString " "] };

        GVAR(LAST) = _sample;
        publicVariable QGVAR(LAST);
    };

    case "start": {
        if (missionNamespace getVariable [QGVAR(RUNNING), false]) exitWith {};
        GVAR(RUNNING) = true;
        publicVariable QGVAR(RUNNING);
        GVAR(INTERVAL) = (_interval max 10);
        ["ALiVE PERF - monitoring started, a sample every %1 s", GVAR(INTERVAL)] call ALiVE_fnc_dump;

        // one loop at a time: a stop then a quick start leaves the old loop to end on its own
        GVAR(LOOP) = (missionNamespace getVariable [QGVAR(LOOP), 0]) + 1;
        [GVAR(LOOP)] spawn {
            params ["_loop"];
            while {GVAR(RUNNING) && {GVAR(LOOP) == _loop}} do {
                ["sample"] call ALIVE_fnc_perfServer;
                sleep GVAR(INTERVAL);
            };
        };
    };

    // An admin's Show Perf opening (1) or closing (0): while anyone watches, a fresh sample
    // every 10 seconds for the readout. Watchers who leave are dropped.
    case "watch": {
        private _who = if (isRemoteExecuted) then { remoteExecutedOwner } else { clientOwner };
        private _watchers = (missionNamespace getVariable [QGVAR(WATCHERS), []]) - [_who];
        if (_interval > 0) then { _watchers pushBack _who };
        GVAR(WATCHERS) = _watchers;
        if (_watchers isEqualTo [] || {!isNil QGVAR(WATCHLOOP)}) exitWith {};
        GVAR(WATCHLOOP) = [] spawn {
            while { (missionNamespace getVariable [QGVAR(WATCHERS), []]) isNotEqualTo [] } do {
                ["sample", 0, false] call ALIVE_fnc_perfServer;
                sleep 10;
                private _here = (allPlayers apply { owner _x }) + [2, clientOwner];
                GVAR(WATCHERS) = GVAR(WATCHERS) select { _x in _here };
            };
            GVAR(WATCHLOOP) = nil;
        };
    };

    case "stop": {
        if !(missionNamespace getVariable [QGVAR(RUNNING), false]) exitWith {};
        GVAR(RUNNING) = false;
        publicVariable QGVAR(RUNNING);
        ["ALiVE PERF - monitoring stopped"] call ALiVE_fnc_dump;
    };
};
