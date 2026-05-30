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
