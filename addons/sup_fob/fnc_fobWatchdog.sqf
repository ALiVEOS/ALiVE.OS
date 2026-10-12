#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobWatchdog);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fobWatchdog

Description:
The one server loop the FOBs run on, every 30 seconds. Each pass counts down every FOB's
timers by the time that really passed (capped at 60 s, so a stall doesn't fire a deadline all
at once) and saves if something changed. While the module is paused (an empty server) it does
nothing at all, so no timer runs out overnight.

Timers are seconds left, never a clock time, so they carry across a save and a pause unchanged.
Alerts, capture and repairs join this loop in later parts of the module.

Parameters:
Object - The module, to start the loop
or
String "tick", Number - one pass now, as if that many seconds had passed (for tests)

Returns:
Nothing (start) or the number of FOBs ticked

Author:
Jman
---------------------------------------------------------------------------- */

if (isRemoteExecuted && {remoteExecutedOwner != 2} && {isNil "_ALiVE_fobCaller"}) exitWith {};
if (!isServer) exitWith {};

private _timers = ["repairRemaining", "captureRemaining", "alertCooldown", "resupplyCooldown"];

private _tick = {
    params ["_dt"];
    {
        private _entry = [ALiVE_FOB_registry, _x] call ALIVE_fnc_hashGet;
        {
            private _left = [_entry, _x, 0] call ALIVE_fnc_hashGet;
            if (_left > 0) then {
                [_entry, _x, (_left - _dt) max 0] call ALIVE_fnc_hashSet;
                ALiVE_FOB_dirty = true;
            };
        } forEach _timers;
    } forEach (ALiVE_FOB_registry select 1);
    count (ALiVE_FOB_registry select 1)
};

if ((_this param [0, objNull]) isEqualType "") exitWith {
    // A test asks for one pass, as the loop would make it
    private _logic = missionNamespace getVariable ["ALiVE_sup_fob", objNull];
    if (_logic getVariable ["pause", false]) exitWith {0};
    private _n = 0;
    isNil { _n = [_this param [1, 30]] call _tick };
    _n
};

params [["_logic", objNull, [objNull]]];
if (!isNil "ALiVE_FOB_watchdog") then { terminate ALiVE_FOB_watchdog };

ALiVE_FOB_watchdog = [_logic, _tick] spawn {
    params ["_logic", "_tick"];
    private _last = time;
    while { !isNull _logic } do {
        sleep 30;
        private _dt = ((time - _last) max 0) min 60;
        _last = time;
        if !(_logic getVariable ["pause", false]) then {
            // Unscheduled, so a pass is never cut in half by the scheduler
            isNil { [_dt] call _tick };
            if (ALiVE_FOB_dirty) then {
                [_logic, "broadcastMirror"] call ALiVE_fnc_FOB;
                ["save", [false]] call ALiVE_fnc_fobPersistence;
            };
        };
    };
};
