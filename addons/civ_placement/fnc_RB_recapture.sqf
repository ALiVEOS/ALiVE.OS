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

// Spawn new garrison. Profile-system path preferred; real-AI fallback
// when profile handler isn't loaded.
if !(isnil "ALiVE_ProfileHandler") then {
    private _group = ["Infantry", _newFaction] call ALIVE_fnc_configGetRandomGroup;
    if (count _group > 0) then {
        private _guards = [_group, _pos, random 360, true, _newFaction, true]
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
        if (_debug) then {
            diag_log format ["ALIVE_RB_recapture: profile-system spawned %1 guards for %2", count _guards, _newFaction];
        };
    } else {
        if (_debug) then {
            diag_log format ["ALIVE_RB_recapture: no Infantry group config for faction %1, skipping garrison", _newFaction];
        };
    };
} else {
    [_pos, _newSide, _newFaction] spawn {
        params ["_p", "_s", "_f"];
        private _blockers = [_p, _s, "Infantry", _f] call ALiVE_fnc_randomGroupByType;
        sleep 1;
        [_blockers, _p, 100, true, false, 1, nil, 50] call ALIVE_fnc_groupGarrison;
    };
    if (_debug) then {
        diag_log format ["ALIVE_RB_recapture: real-AI path spawned for faction %1", _newFaction];
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
