#include "\x\alive\addons\amb_civ_population\script_component.hpp"
SCRIPT(advciv_civAimReact);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_advciv_civAimReact
Description:
    Server-side civilian aim-pressure reaction dispatch. Triggered when a
    player sustains weapon aim on a civilian for civWeaponAimHoldTime
    (default 2 s, per the aim-pressure handler in XEH_postInit.sqf). Reaction varies by the civilian's
    hostility bucket, mirroring the bucket model used by the hostility
    indicator and Gather Intel arc.

    Bucket reactions:
      Friendly  - Confused shrug (Gesture_What). No state change. Civ
                  keeps walking.
      Neutral   - HandsUp surrender via the canonical advciv_react
                  HANDSUP path.
      Wary      - Same as Neutral plus an ALiVE_advciv_traumatised flag
                  on the civ, which halves how fast both decay passes
                  calm them down (it does not slow the drift back up
                  toward neutral).
      Defiant   - Emphatic head-shake refusal (Gesture_NoLong) plus
                  PANIC flee. Does not comply.
      Hostile   - Same as Defiant plus a +5 hostility bump through
                  ALiVE_fnc_civSetHostility, which writes both copies.

Parameters:
    _this select 0: OBJECT - civilian
    _this select 1: STRING - bucket label ("Friendly" / "Neutral" /
                             "Wary" / "Defiant" / "Hostile")
    _this select 2: OBJECT - the triggering player (used by the release
                             watcher for Neutral / Wary HandsUp - the
                             civ resumes normal behaviour once that
                             specific player has moved further than
                             civWeaponAimRange + 3 m for 2 s).
Returns:
    Nil
See Also:
    ALIVE_fnc_advciv_react, ALIVE_fnc_advciv_civAimRelease
Author:
    Jman
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params [["_civ", objNull, [objNull]], ["_bucket", "Neutral", [""]], ["_triggerPlayer", objNull, [objNull]]];

if (!isServer) exitWith {};
if (isNull _civ || {!alive _civ}) exitWith {};
if (_civ getVariable ["ALiVE_advciv_blacklist", false]) exitWith {};

// Skip if civ is already in a target state from another trigger (prior
// aim-press, brain-loop PANIC from a near-shot, etc.). Avoids stacking
// a Defiant flee on top of an active HandsUp, or replaying gestures.
private _state = _civ getVariable ["ALiVE_advciv_state", "CALM"];
private _order = _civ getVariable ["ALiVE_advciv_order", "NONE"];
if ((_state in ["PANIC", "HIDING"]) || {_order == "HANDSUP"}) exitWith {};

private _fnc_panicFlee = {
    params ["_civ"];
    _civ setVariable ["ALiVE_advciv_state", "PANIC", true];
    _civ setVariable ["ALiVE_advciv_panicSource", getPos _civ, true];
    _civ setVariable ["ALiVE_advciv_hidingPos", [], true];
    _civ enableAI "PATH";
    _civ enableAI "MOVE";
};

// Release watcher: started for Neutral / Wary HandsUp triggers. Polls
// every 1 s; releases the civ when the triggering player has been
// further than civWeaponAimRange + 3 m hysteresis for 2 s. The flag
// `ALiVE_advciv_aimTriggeredHandsUp` is set so the watcher can tell
// the trigger originated here (vs an ORDERED HandsUp from the order
// menu, which the player explicitly issued and shouldn't auto-release).
private _fnc_startReleaseWatcher = {
    params ["_civ", "_triggerPlayer"];

    _civ setVariable ["ALiVE_advciv_aimTriggeredHandsUp", true, true];
    _civ setVariable ["ALiVE_advciv_aimTriggeredBy", _triggerPlayer, true];
    _civ setVariable ["ALiVE_advciv_aimFarSince", nil, true];

    [{
        params ["_args", "_handle"];
        _args params ["_civ", "_triggerPlayer"];

        if (isNull _civ || {!alive _civ}) exitWith {
            [_handle] call CBA_fnc_removePerFrameHandler;
        };
        if (!(_civ getVariable ["ALiVE_advciv_aimTriggeredHandsUp", false])) exitWith {
            // Already released by another path (mission CALM reset, etc.)
            [_handle] call CBA_fnc_removePerFrameHandler;
        };
        // Trigger player gone (disconnected / killed) - release immediately.
        if (isNull _triggerPlayer || {!alive _triggerPlayer}) exitWith {
            [_civ] call ALIVE_fnc_advciv_civAimRelease;
            [_handle] call CBA_fnc_removePerFrameHandler;
        };

        private _aimRange = missionNamespace getVariable ["ALiVE_amb_civ_population_WeaponAimRange", 15];
        private _dist = _triggerPlayer distance _civ;

        if (_dist > (_aimRange + 3)) then {
            private _farSince = _civ getVariable ["ALiVE_advciv_aimFarSince", -1];
            if (_farSince < 0) then {
                _civ setVariable ["ALiVE_advciv_aimFarSince", time, true];
            } else {
                if ((time - _farSince) >= 2) then {
                    [_civ] call ALIVE_fnc_advciv_civAimRelease;
                    [_handle] call CBA_fnc_removePerFrameHandler;
                };
            };
        } else {
            // Within trigger range again - reset the far-since timer so
            // the 2 s release counter starts over once the player walks
            // away again.
            if !(isNil {_civ getVariable "ALiVE_advciv_aimFarSince"}) then {
                _civ setVariable ["ALiVE_advciv_aimFarSince", nil, true];
            };
        };
    }, 1, [_civ, _triggerPlayer]] call CBA_fnc_addPerFrameHandler;
};

switch (_bucket) do {
    case "Friendly": {
        [_civ, "Gesture_What"] remoteExec ["playAction", 0];
    };
    case "Neutral": {
        [_civ, "HANDSUP"] call ALIVE_fnc_advciv_react;
        [_civ, _triggerPlayer] call _fnc_startReleaseWatcher;
    };
    case "Wary": {
        _civ setVariable ["ALiVE_advciv_traumatised", true, true];
        [_civ, "HANDSUP"] call ALIVE_fnc_advciv_react;
        [_civ, _triggerPlayer] call _fnc_startReleaseWatcher;
    };
    case "Defiant": {
        [_civ, "Gesture_NoLong"] remoteExec ["playAction", 0];
        [_civ] call _fnc_panicFlee;
    };
    case "Hostile": {
        [_civ, "Gesture_NoLong"] remoteExec ["playAction", 0];
        [_civ] call _fnc_panicFlee;

        // +5, both copies (the agent record and the unit's broadcast value), through
        // the shared setter the wound bump and the dialog use too.
        [_civ, 5] call ALiVE_fnc_civSetHostility;
    };
};
