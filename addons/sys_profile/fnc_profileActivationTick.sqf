#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileActivationTick);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_profileActivationTick

Description:
Single per-frame entry point for profile activation. Ticks each registered
profile activator, applies its claim batch, and invokes the profile spawner to
execute queued transitions.

Author:
SpyderBlack723
---------------------------------------------------------------------------- */

if (isGamePaused) exitWith {};

private _args = _this select 0;
_args params ["_coordinator"];

private _paused = [MOD(profileSystem),"paused"] call ALiVE_fnc_hashGet;

if (_paused) exitWith {
    if !(_coordinator get "paused") then {
        [_coordinator,"reset"] call ALiVE_fnc_profileActivationCoordinator;
        _coordinator set ["paused",true];
    };
};

_coordinator set ["paused",false];

{
    private _batch = [_x,"tick"] call (_x get "implementation");
    [_coordinator,"applyBatch",_batch] call ALiVE_fnc_profileActivationCoordinator;
} forEach (_coordinator get "activators");

[_coordinator] call ALiVE_fnc_profileSpawner;
