#include "script_component.hpp"

LOG(MSG_INIT);

// ---- Task AO marker driver (#689) ------------------------------------------
//
// Polls the player's currentTask + state once a second and triggers a
// marker refresh whenever the signature changes. Robust across all task
// sources - c2istar tablet, BI task UI Assign button, scripted
// setCurrentTask - because the BI runtime is the single source of truth
// for "what's the player working on right now".
//
// Cheap when idle (string comparison + setVariable on no-change), so the
// 1s interval is fine. Client-side only - hasInterface gates the
// register so a headless / dedicated server doesn't run the PFH.
if (hasInterface) then {
    [
        {
            params ["_args", "_handle"];
            private _ct = currentTask player;
            private _ctName = if (!isNull _ct) then { str _ct } else { "" };
            private _state = if (!isNull _ct) then { taskState _ct } else { "" };
            private _key = format ["%1|%2", _ctName, _state];
            private _last = missionNamespace getVariable ["ALIVE_C2ISTAR_lastTaskKey", ""];
            if (_key != _last) then {
                missionNamespace setVariable ["ALIVE_C2ISTAR_lastTaskKey", _key];
                call ALIVE_fnc_taskRefreshAoMarker;
            };
        },
        1,
        []
    ] call CBA_fnc_addPerFrameHandler;
};

// ---- Downed pilot watcher (C2ISTAR rescue) --------------------------------
//
// Server only. Every 2 s it notes who sits in a plane's crew seat, spots the
// same men a moment later in an ejection seat or under a canopy, follows them
// to the ground and raises a rescue task where they land. The body is the
// "watchTick" operation in tasks/fnc_taskCSAR.sqf; it returns at once while
// there is no C2ISTAR task handler.
//
// This file runs once per C2ISTAR module, so the handler is registered once
// per mission however many modules are placed.
if (isServer && {isNil "ALiVE_c2istar_csarWatcher"}) then {
    ALiVE_c2istar_csarWatcher = [
        {
            ["watchTick", "", [], [], false] call ALIVE_fnc_taskCSAR;
        },
        2,
        []
    ] call CBA_fnc_addPerFrameHandler;
};
