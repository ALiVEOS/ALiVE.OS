#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(PauseModulesAuto);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_PauseModulesAuto

Description:
Adds connected EHs with checks for players on server to auto-pause the main modules

Parameters:
- none

Examples:
(begin example)
call ALiVE_fnc_pauseModulesAuto
(end)

See Also:
ALiVE_fnc_PauseModule

Author:
Highhead
Jman
---------------------------------------------------------------------------- */

if !(isServer) exitwith {};

["- Auto Pause Modules Initialising..."] call ALiVE_fnc_dump;


// Opens the task clock's pause window. Flag and PAUSEDAT are set before pauseModule, which can block for minutes.
MOD(PAUSEMODULES_PAUSE) = {
    if (!isNil QGVAR(PAUSEMODULES_PAUSED)) exitWith {};
    GVAR(PAUSEMODULES_PAUSED) = true;
    publicVariable QGVAR(PAUSEMODULES_PAUSED);
    // keep an open window if a deferred close has not run yet (re-pause before anyone loaded in)
    if ((missionNamespace getVariable [QMOD(PAUSEMODULES_PAUSEDAT), -1]) < 0) then {
        MOD(PAUSEMODULES_PAUSEDAT) = serverTime;
        publicVariable QMOD(PAUSEMODULES_PAUSEDAT);
    };

    ["- Pausing Modules"] call ALiVE_fnc_dumpR;

    [
        "ALIVE_SYS_PROFILE",
        "ALIVE_MIL_OPCOM",
        "ALiVE_MIL_CQB",
        "ALiVE_SUP_FOB",
        "ALIVE_AMB_CIV_POPULATION"
    ] call ALiVE_fnc_pauseModule;
};

// _waitForPlayer: true from PlayerConnected (fires in the lobby); a probe passes false.
MOD(PAUSEMODULES_RESUME) = {
    params [["_waitForPlayer", true]];
    if (isNil QGVAR(PAUSEMODULES_PAUSED)) exitWith {};
    GVAR(PAUSEMODULES_PAUSED) = nil;
    publicVariable QGVAR(PAUSEMODULES_PAUSED);

    ["- Starting Modules"] call ALiVE_fnc_dumpR;

    [
        "ALIVE_SYS_PROFILE",
        "ALIVE_MIL_OPCOM",
        "ALiVE_MIL_CQB",
        "ALiVE_SUP_FOB",
        "ALIVE_AMB_CIV_POPULATION"
    ] call ALiVE_fnc_unPauseModule;

    // task clock stays stopped until a player is actually in the world (cap 900 s)
    [_waitForPlayer] spawn {
        params ["_waitForPlayer"];
        private _t0 = diag_tickTime;
        if (_waitForPlayer) then {
            waitUntil {
                sleep 2;
                ((allPlayers - entities "HeadlessClient_F") findIf {alive _x}) >= 0
                || {diag_tickTime - _t0 > 900}
                || {!isNil QGVAR(PAUSEMODULES_PAUSED)}
            };
        };
        if (!isNil QGVAR(PAUSEMODULES_PAUSED)) exitWith {}; // paused again: window stays open
        private _at = missionNamespace getVariable [QMOD(PAUSEMODULES_PAUSEDAT), -1];
        private _pausedFor = if (_at >= 0) then { serverTime - _at } else { 0 };
        MOD(PAUSEMODULES_PAUSEDTOTAL) = (missionNamespace getVariable [QMOD(PAUSEMODULES_PAUSEDTOTAL), 0]) + _pausedFor;
        MOD(PAUSEMODULES_PAUSEDAT) = -1;
        publicVariable QMOD(PAUSEMODULES_PAUSEDTOTAL);
        publicVariable QMOD(PAUSEMODULES_PAUSEDAT);
        ["- Task clock running again (paused %1 s)", round _pausedFor] call ALiVE_fnc_dumpR;
    };
};

MOD(PAUSEMODULES_EH_DISCONNECTED) = addMissionEventHandler ["PlayerDisconnected", {
    [] spawn {
        sleep 30;
        if (({isPlayer _x} count playableUnits) == 0) then { call MOD(PAUSEMODULES_PAUSE) };
    };
}];

MOD(PAUSEMODULES_EH_CONNECTED) = addMissionEventHandler ["PlayerConnected", {
    [true] call MOD(PAUSEMODULES_RESUME);
}];
