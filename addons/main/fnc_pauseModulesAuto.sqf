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
    // ends a staged start still running (Ease In After Idle) and its logistics hold
    MOD(PAUSEMODULES_EASEGEN) = (missionNamespace getVariable [QMOD(PAUSEMODULES_EASEGEN), 0]) + 1;
    MOD(PAUSEMODULES_EASEUNTIL) = -1;
    // keep an open window if a deferred close has not run yet (re-pause before anyone loaded in)
    if ((missionNamespace getVariable [QMOD(PAUSEMODULES_PAUSEDAT), -1]) < 0) then {
        MOD(PAUSEMODULES_PAUSEDAT) = serverTime;
        publicVariable QMOD(PAUSEMODULES_PAUSEDAT);
    };

    ["- Pausing Modules"] call ALiVE_fnc_dumpR;
    // for the War Room's Server Health, which marks the pause on its charts
    if (isServer && {!isNil "ALiVE_fnc_diagEvent"}) then {
        private _active = if (isNil "ALIVE_profileHandler") then { [] } else { [ALIVE_profileHandler, "getActiveEntities"] call ALIVE_fnc_profileHandler };
        ["SERVER", "AUTO_PAUSE", format ["%1 spawned groups", if (_active isEqualType []) then { count _active } else { 0 }], [0,0]] call ALiVE_fnc_diagEvent;
    };

    // The profile system pauses last. Paused at once, its spawning stops before the groups spawned around the last
    // player have been put away, and they stayed live AI all through the pause (68 to 81 groups overnight on an empty
    // server, 19 Nov). Left running with nobody on, it despawns them within a few rounds; it pauses once none are
    // left, or after 3 minutes at most. A player joining in that time calls the pause off (the flag is cleared).
    [] spawn {
        private _t0 = diag_tickTime;
        private _spawned = {
            if (isNil "ALIVE_profileHandler") exitWith { 0 };
            private _active = [ALIVE_profileHandler, "getActiveEntities"] call ALIVE_fnc_profileHandler;
            if (isNil "_active" || {!(_active isEqualType [])}) exitWith { 0 };
            count _active
        };
        private _atPause = call _spawned;
        waitUntil { sleep 5; isNil QGVAR(PAUSEMODULES_PAUSED) || {(call _spawned) == 0} || {diag_tickTime - _t0 > 180} };
        if (isNil QGVAR(PAUSEMODULES_PAUSED)) exitWith {};
        ["- Profiles paused last: %1 spawned groups when the other modules paused, %2 after %3 s", _atPause, call _spawned, round (diag_tickTime - _t0)] call ALiVE_fnc_dumpR;
        ["ALIVE_SYS_PROFILE"] call ALiVE_fnc_pauseModule;
    };

    [
        "ALIVE_MIL_OPCOM",
        "ALiVE_MIL_CQB",
        "ALiVE_SUP_FOB",
        "ALIVE_AMB_CIV_POPULATION",
        "ALiVE_MIL_ATO"
    ] call ALiVE_fnc_pauseModule;
};

// _waitForPlayer: true from PlayerConnected (fires in the lobby); a probe passes false.
MOD(PAUSEMODULES_RESUME) = {
    params [["_waitForPlayer", true]];
    if (isNil QGVAR(PAUSEMODULES_PAUSED)) exitWith {};
    GVAR(PAUSEMODULES_PAUSED) = nil;
    publicVariable QGVAR(PAUSEMODULES_PAUSED);

    ["- Starting Modules"] call ALiVE_fnc_dumpR;
    if (isServer && {!isNil "ALiVE_fnc_diagEvent"}) then {
        private _at = missionNamespace getVariable [QMOD(PAUSEMODULES_PAUSEDAT), -1];
        ["SERVER", "AUTO_RESUME", if (_at < 0) then { "" } else { format ["paused %1 s", round (serverTime - _at)] }, [0,0]] call ALiVE_fnc_diagEvent;
    };

    // Ease In After Idle (Required module, off by default): everything starting in the same minute as the first
    // player cost the server 29 s of game time in 26 minutes (19 Nov, stalls up to 2.5 s as groups, convoys and
    // aircraft were made). On, the modules start in stages over the delay, the profile system first so the player
    // has AI round them at once, and Military Logistics holds vehicle convoys and deliveries that fly until the delay is up.
    if (missionNamespace getVariable [QMOD(PAUSEMODULES_EASEIN), false]) then {
        private _delay = missionNamespace getVariable [QMOD(PAUSEMODULES_EASEDELAY), 180];
        MOD(PAUSEMODULES_EASEUNTIL) = time + _delay;
        private _gen = (missionNamespace getVariable [QMOD(PAUSEMODULES_EASEGEN), 0]) + 1;
        MOD(PAUSEMODULES_EASEGEN) = _gen;
        ["- Easing in after idle: the profile system now, the other modules over %1 s, logistics holds vehicle convoys and deliveries that fly until then", _delay] call ALiVE_fnc_dumpR;
        ["ALIVE_SYS_PROFILE"] call ALiVE_fnc_unPauseModule;
        [_gen, _delay] spawn {
            params ["_gen", "_delay"];
            private _t0 = diag_tickTime;
            {
                _x params ["_share", "_modules"];
                // each stage at its share of the delay from the resume, not from the stage before
                private _at = _t0 + _delay * _share;
                waitUntil { sleep 2; diag_tickTime >= _at || {(missionNamespace getVariable [QMOD(PAUSEMODULES_EASEGEN), 0]) != _gen} };
                // paused again, or a newer resume took over: stop here
                if ((missionNamespace getVariable [QMOD(PAUSEMODULES_EASEGEN), 0]) != _gen || {!isNil QGVAR(PAUSEMODULES_PAUSED)}) exitWith {};
                ["- Easing in after idle: starting %1", _modules] call ALiVE_fnc_dumpR;
                // in one frame, as the all-at-once start from the connect handler: scheduled, a busy scheduler stretched
                // one stage to 2-3 minutes on the rig and the next stages slipped behind it
                isNil { _modules call ALiVE_fnc_unPauseModule };
            } forEach [
                [1/3, ["ALiVE_MIL_CQB", "ALIVE_AMB_CIV_POPULATION"]],
                [2/3, ["ALIVE_MIL_OPCOM", "ALiVE_SUP_FOB"]],
                [1, ["ALiVE_MIL_ATO"]]
            ];
        };
    } else {
    [
        "ALIVE_SYS_PROFILE",
        "ALIVE_MIL_OPCOM",
        "ALiVE_MIL_CQB",
        "ALiVE_SUP_FOB",
        "ALIVE_AMB_CIV_POPULATION",
        "ALiVE_MIL_ATO"
    ] call ALiVE_fnc_unPauseModule;
    };

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

// Connected players, headless clients left out, so an HC joining never starts the modules again (Jman, 17 Nov,
// RSS7). Counted from the connected users, so a player still in the lobby counts too.
MOD(PAUSEMODULES_PLAYERS) = {
    // a dedicated server is never a player (owner 2); on a hosted game owner 2 is the host, who is
    { private _i = getUserInfo _x; count _i > 7 && {!(_i select 7)} && {!(isDedicated && {(_i select 1) == 2})} } count allUsers
};

MOD(PAUSEMODULES_EH_DISCONNECTED) = addMissionEventHandler ["PlayerDisconnected", {
    [] spawn {
        sleep 30;
        if ((call MOD(PAUSEMODULES_PLAYERS)) == 0) then { call MOD(PAUSEMODULES_PAUSE) };
    };
}];

MOD(PAUSEMODULES_EH_CONNECTED) = addMissionEventHandler ["PlayerConnected", {
    params ["", ["_uid", ""], "", "", "", ["_idstr", ""]];
    private _info = getUserInfo _idstr;
    private _isHC = (count _info > 7 && {_info select 7}) || {(_uid select [0, 2]) isEqualTo "HC"};
    if (_isHC) exitWith {};
    [true] call MOD(PAUSEMODULES_RESUME);
}];

// A server that starts with nobody on it pauses as well: the pause above only ever ran when someone left. Checked
// once the mission has been going two minutes, so the modules have started, and again 30 s later before pausing.
[] spawn {
    waitUntil { sleep 5; time > 120 };
    if ((call MOD(PAUSEMODULES_PLAYERS)) > 0) exitWith {};
    sleep 30;
    if ((call MOD(PAUSEMODULES_PLAYERS)) == 0) then {
        ["- No players on the server since it started, so the modules pause"] call ALiVE_fnc_dumpR;
        call MOD(PAUSEMODULES_PAUSE);
    };
};
