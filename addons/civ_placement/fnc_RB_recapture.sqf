#include "\x\alive\addons\civ_placement\script_component.hpp"
SCRIPT(RB_recapture);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_RB_recapture

Description:
    Spawns a new garrison for a captured roadblock and updates the
    anchor's state vars. Called from the capture watchdog when the
    contested-hold timer expires.

    Garrison spawn path mirrors the initial roadblock spawn in
    fnc_createRoadblock.sqf:
      - Profile-system path (preferred) when ALiVE_ProfileHandler is
        loaded: configGetRandomGroup -> createProfilesFromGroupConfig
        -> garrison setActiveCommand
      - Real-AI fallback when profile system isn't loaded:
        randomGroupByType -> groupGarrison

    Anchor state mutates:
      ALiVE_RB_currentFaction -> _newFaction
      ALiVE_RB_currentSide    -> side of _newFaction
      ALiVE_RB_state          -> "captured"
      ALiVE_RB_lastFlap       -> diag_tickTime (resets the post-capture
                                 hold window)

    Debug-mode draws a red ColorRed marker over the spawn position
    labelled "RoadBlock - <newFaction> (CAPTURED from <oldFaction>)" so
    captured roadblocks are distinguishable from the original brown
    spawn markers in Eden / preview.

    Future hook: an OPCOM event fires here so commanders can react
    (counter-attack tasks, objective re-prioritisation). Consumer not
    yet wired; the watchdog state change is observable via setVariable
    until then.

Parameters:
    _anchor      : OBJECT - logic anchor from fnc_RB_captureWatchdog
    _newFaction  : STRING - faction taking control (dominant attacker
                            faction picked by the watchdog)

Returns:
    BOOL - true on garrison spawn attempted, false on null inputs.

Examples:
    (begin example)
    [_anchor, "OPF_F"] call ALIVE_fnc_RB_recapture;
    (end)

See Also:
    ALIVE_fnc_RB_captureWatchdog
    ALIVE_fnc_createRoadblock

Author:
    Jman
---------------------------------------------------------------------------- */

params [
    ["_anchor", objNull, [objNull]],
    ["_newFaction", "", [""]]
];

if (isNull _anchor) exitWith {
    diag_log "ALIVE_fnc_RB_recapture: null anchor";
    false
};
if (_newFaction == "") exitWith {
    diag_log "ALIVE_fnc_RB_recapture: empty faction";
    false
};

private _pos         = _anchor getVariable ["ALiVE_RB_anchorPos", getPosATL _anchor];
private _oldFaction  = _anchor getVariable ["ALiVE_RB_currentFaction", ""];
private _oldSide     = _anchor getVariable ["ALiVE_RB_currentSide", civilian];
private _debug       = _anchor getVariable ["ALiVE_RB_debug", false];
private _newSide     = _newFaction call ALiVE_fnc_factionSide;

if (_debug) then {
    diag_log format [
        "ALIVE_RB_recapture: %1 (%2) -> %3 (%4) at %5",
        _oldFaction, _oldSide, _newFaction, _newSide, _pos
    ];
};

// Spawn new garrison off-camera. Issue #883 reported "friendly AI
// teleporting" at cleared roadblocks - the player who just attacked
// the position would see attacker-faction units materialise next to
// them the moment the contested-hold timer flipped ownership. Deferred
// spawn waits until no player is within 300m of the anchor (or a
// safety timeout fires) before instantiating the profile. The capture
// state has already flipped on the anchor state vars above, so the
// debug marker / watchdog reflect the new ownership immediately - only
// the visible unit spawn is delayed.
//
// Bail conditions:
//   - anchor deleted (mission cleanup)
//   - currentFaction changed (faction flipped again under us before
//     our garrison materialised - the new owner will spawn its own)
[_anchor, _newFaction, _pos, _newSide, _debug] spawn {
    params ["_a", "_f", "_p", "_s", "_d"];
    private _safetyTimeout = diag_tickTime + 600;  // 10 min cap

    // Short-circuit `||` with code blocks: stops at the first true and
    // returns it as the waitUntil result. `exitWith` inside an if-then
    // block here would only exit that if-scope, NOT the waitUntil
    // (per reference_sqf_exitwith_scope.md) - so flow would continue
    // to the getVariable call on a null anchor and error.
    waitUntil {
        sleep 5;
        isNull _a ||
        {(_a getVariable ["ALiVE_RB_currentFaction", ""]) != _f} ||
        {diag_tickTime > _safetyTimeout} ||
        {({(_x distance2D _p) < 300} count allPlayers) == 0}
    };

    if (isNull _a) exitWith {
        if (_d) then { diag_log "ALIVE_RB_recapture: anchor deleted before deferred spawn" };
    };
    if ((_a getVariable ["ALiVE_RB_currentFaction", ""]) != _f) exitWith {
        if (_d) then { diag_log format ["ALIVE_RB_recapture: %1 ownership flipped before deferred spawn, abandoning", _f] };
    };

    if !(isnil "ALiVE_ProfileHandler") then {
        private _group = ["Infantry", _f] call ALIVE_fnc_configGetRandomGroup;
        if (count _group > 0) then {
            private _guards = [_group, _p, random 360, true, _f, true]
                call ALIVE_fnc_createProfilesFromGroupConfig;
            {
                if (([_x, "type"] call ALiVE_fnc_HashGet) == "entity") then {
                    [
                        _x,
                        "setActiveCommand",
                        ["ALIVE_fnc_garrison", "spawn", [30, "false", [0,0,0], "", 1, 1]]
                    ] call ALIVE_fnc_profileEntity;
                    [_x, "busy", true] call ALIVE_fnc_hashSet;
                };
            } forEach _guards;
            if (_d) then {
                diag_log format ["ALIVE_RB_recapture: deferred profile spawn %1 guards for %2", count _guards, _f];
            };
        } else {
            if (_d) then {
                diag_log format ["ALIVE_RB_recapture: no Infantry group config for faction %1, skipping garrison", _f];
            };
        };
    } else {
        private _blockers = [_p, _s, "Infantry", _f] call ALiVE_fnc_randomGroupByType;
        sleep 1;
        [_blockers, _p, 100, true, false, 1, nil, 50] call ALIVE_fnc_groupGarrison;
        if (_d) then {
            diag_log format ["ALIVE_RB_recapture: deferred real-AI spawn for faction %1", _f];
        };
    };
};

// Mutate anchor state - the watchdog reads these on the NEXT tick.
_anchor setVariable ["ALiVE_RB_currentFaction", _newFaction];
_anchor setVariable ["ALiVE_RB_currentSide", _newSide];
_anchor setVariable ["ALiVE_RB_state", "captured"];
_anchor setVariable ["ALiVE_RB_lastFlap", diag_tickTime];

if (_debug) then {
    // Replace the brown spawn marker with a red captured marker at the
    // same deterministic name so the labels don't stack and overlap.
    // fnc_createRoadblock places the original under the same scheme.
    private _rbMarkerName = format ["ALiVE_RB_M_%1_%2", floor (_pos select 0), floor (_pos select 1)];
    deleteMarker _rbMarkerName;
    [
        _pos,
        1,
        format ["RoadBlock - %1 (CAPTURED from %2)", _newFaction, _oldFaction],
        "ColorRed",
        "",
        _rbMarkerName
    ] call ALiVE_fnc_placeDebugMarker;
};

// Future: OPCOM event fire site. When mil_opcom grows a consumer for
// roadblock-capture events (counter-attack tasks, objective priority
// shifts), publish here. State on the anchor is observable in the
// meantime via getVariable from any scope.

true
