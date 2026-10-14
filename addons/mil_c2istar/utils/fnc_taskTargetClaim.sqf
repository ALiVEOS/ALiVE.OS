#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskTargetClaim);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskTargetClaim

Description:
Keeps the destroy tasks (SEAD, DCA, Destroy Vehicles, Destroy Infantry) off targets another task is
already aimed at. Each picks the enemy profile nearest the task, so an open, failed or expired task
left its target alive and the next task picked the same one again; with several players or sides
they piled up on the same few positions. A task now claims its target for 30 minutes, and the next
one skips claimed targets. A claim runs out on its own, so a target nobody dealt with comes round
again later. Server only.

Parameters:
    _this select 0: STRING - "free" or "claim"
    _this select 1: ARRAY  - "free": the profile IDs to choose from, nearest first
                    STRING - "claim": the profile ID a new task is aimed at
    _this select 2: NUMBER - "claim": seconds (optional, 1800)

Returns:
    "free": ARRAY - the IDs nobody has claimed, in the same order
    "claim": nothing

Author:
Jman
---------------------------------------------------------------------------- */

params ["_mode", "_arg", ["_seconds", 1800]];

private _claims = missionNamespace getVariable ["ALiVE_C2_taskTargetClaims", createHashMap];
missionNamespace setVariable ["ALiVE_C2_taskTargetClaims", _claims];

switch (_mode) do {
    case "free": {
        _arg select { !(_x isEqualType "") || {(_claims getOrDefault [_x, -1]) < serverTime} }
    };
    case "claim": {
        if (_arg isEqualType "" && {_arg != ""}) then { _claims set [_arg, serverTime + _seconds] };
    };
};
