#include "\x\alive\addons\mil_OPCOM\script_component.hpp"
SCRIPT(OPCOMfriendlyDisableInstallations);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_OPCOMfriendlyDisableInstallations

Description:
Implements issue #697. Allows friendly (non-insurgent-side) forces to
automatically disable enemy asymmetric installations (IED factories,
Recruitment HQs, Weapons depots) without requiring a player to walk up
and hold the interaction key.

Two triggers, gated independently by the OPCOM's friendlyDisableMode
attribute:

  "proximity" / "both" - any friendly-side unit (enemy to this OPCOM)
    within ~150 m of an installation building triggers the disable.
    Phase 2.2 behaviour.

  "capture" / "both" - a friendly OPCOM (one whose side is in this
    insurgent OPCOM's sidesenemy list) has an objective within ~200 m
    of the insurgent objective's center AND that friendly objective's
    opcom_state is "defending" (OPCOM state machine reaches "defending"
    after successful capture - see opcom.fsm ~441). Phase 2.3 behaviour.

  "off" - short-circuit exit. Player hold-action remains the only
    disable path.

For "both", either trigger fires independently - in practice proximity
usually wins because it has no hold-state requirement, but capture can
still fire first when friendlies take the objective from range (e.g.
artillery / air support).

Runs a single-pass scan over one asymmetric OPCOM's objectives. For
each alive, not-already-disabled installation of the three player-
disable types (factory / HQ / depot), evaluates both triggers per the
mode gate, and on first hit invokes the same disable path the player
hold-action uses - building variable flag + ALIVE_fnc_INS_buildingKilledEH
cleanup + per-side subtitle.

Intended to be called periodically (e.g. every 30 seconds) from a spawn
loop started at OPCOM init.

Parameters:
    _this select 0: OPCOM handler hashmap (required)

Returns:
    Nothing

Author:
Jman
---------------------------------------------------------------------------- */

if !(isServer) exitWith {};

params [["_handler", [], [[]]]];

// Safety: if the OPCOM's logic has been disposed since the spawn loop
// scheduled this call, skip. The handler hashmap persists in memory
// (referenced by the spawn scope) but the module object is nulled on
// dispose.
private _module = [_handler, "module", objNull] call ALiVE_fnc_HashGet;
if (isNull _module) exitWith {};

// Gate: only asymmetric OPCOMs
private _controltype = [_handler, "controltype", ""] call ALiVE_fnc_HashGet;
if (_controltype != "asymmetric") exitWith {};

private _friendlyDisableMode = [_handler, "friendlyDisableMode", "off"] call ALiVE_fnc_HashGet;
if (_friendlyDisableMode == "off") exitWith {};

// Flag which triggers are active for this scan. Both can be true
// simultaneously under "both".
private _proximityEnabled = _friendlyDisableMode in ["proximity", "both"];
private _captureEnabled   = _friendlyDisableMode in ["capture",   "both"];

// Convert the OPCOM's enemy-side list to side objects for the
// `side (group _x)` comparison below. "enemy" here means enemy of the
// insurgent OPCOM - i.e. the friendly-side units the issue refers to.
private _sidesEnemy = [_handler, "sidesenemy", []] call ALiVE_fnc_HashGet;
private _sideObjectsEnemy = _sidesEnemy apply {[_x] call ALiVE_fnc_sideTextToObject};
if (count _sideObjectsEnemy == 0) exitWith {};

// Installation specs: keys match the objective-hashmap entries written by
// spawnIEDfactory / spawnHQ / spawnDepot. disabledVar / subtitle title /
// subtitle text mirror the hold-action calls in those spawn functions
// exactly so mission-makers see the same UX whether the player or AI
// triggered the disable.
private _installationSpecs = [
    ["factory", "ALiVE_MIL_OPCOM_FACTORY_DISABLED", "Nice Job", "%1 disabled the IED factory at grid %2!"],
    ["HQ",      "ALiVE_MIL_OPCOM_HQ_DISABLED",      "Congratulations", "%1 disabled the Recruitment HQ at grid %2!"],
    ["depot",   "ALiVE_MIL_OPCOM_DEPOT_DISABLED",   "Good work", "%1 disabled the weapons depot at grid %2!"]
];

// Proximity radius around each installation building in meters. If
// friendlies are operating within 150 m of an insurgent installation
// and the insurgents haven't killed them, the area is effectively
// interdicted.
private _PROXIMITY_RADIUS = 150;

// Capture-overlap radius: how close a friendly OPCOM's "defending"
// objective center must be to the insurgent objective's center for
// the insurgent objective to count as captured. OPCOM objective
// sizes are typically 100-300 m; 200 m catches most overlapping-
// placement scenarios without false-matching across distant
// objectives.
private _CAPTURE_RADIUS = 200;

private _objectives = [_handler, "objectives", []] call ALiVE_fnc_HashGet;
private _processedBuildings = [];

{
    private _objective = _x;
    private _objCenter = [_objective, "center", [0,0,0]] call ALiVE_fnc_HashGet;

    // Capture check: does any friendly OPCOM hold an overlapping
    // objective in state "defending"? Compute once per insurgent
    // objective (not per installation) because all installations on
    // the same objective share the same capture status.
    private _capturedByFriendly = false;
    if (_captureEnabled) then {
        {
            private _otherOpcom = _x;
            private _otherSide = [_otherOpcom, "side", ""] call ALiVE_fnc_HashGet;
            // Only check OPCOMs whose side this insurgent considers
            // hostile - those are the friendlies from the mission-
            // maker's POV. Skip self and already-found matches.
            if (_otherSide in _sidesEnemy && {!_capturedByFriendly}) then {
                private _otherObjs = [_otherOpcom, "objectives", []] call ALiVE_fnc_HashGet;
                {
                    private _otherCenter = [_x, "center", [0,0,0]] call ALiVE_fnc_HashGet;
                    private _otherState  = [_x, "opcom_state", ""] call ALiVE_fnc_HashGet;
                    if (_otherState == "defending" && {(_objCenter distance _otherCenter) < _CAPTURE_RADIUS}) then {
                        _capturedByFriendly = true;
                    };
                } forEach _otherObjs;
            };
        } forEach OPCOM_instances;
    };

    {
        _x params ["_installationKey", "_disabledVar", "_subtitleTitle", "_subtitleText"];

        // Convert stored [pos, typeName] array back to the actual building
        // object. Reuses the same convertObject dispatch the existing
        // OPCOMToggleInstallations + holdAction paths use, so we match
        // their resolution semantics exactly. All validity checks nest
        // in one `then {}` block - exitWith inside forEach is "break" in
        // SQF, not "continue", so using it to skip mid-iteration would
        // wrongly abandon the remaining installation types for the same
        // objective (e.g. factory missing -> HQ + depot never checked).
        private _stored = [_objective, _installationKey, []] call ALiVE_fnc_HashGet;
        private _building = [_handler, "convertObject", _stored] call ALiVE_fnc_OPCOM;

        private _canProceed = !isNull _building
            && {alive _building}
            && {!(_building in _processedBuildings)}
            // Idempotence: if a player hold-action (or an earlier scan)
            // already disabled this building, don't re-fire. The hold-
            // action path sets this same variable at fnc_INS_helpers.sqf
            // ~1359.
            && {!(_building getVariable [_disabledVar, false])};

        if (_canProceed) then {
            private _triggered = false;
            private _caller = objNull;

            // Capture trigger first: objective-level signal is already
            // computed, so this branch is cheap per-installation. For
            // naming purposes pick a nearby friendly unit if any exists
            // within the capture radius; fall back to objNull (generic
            // "Friendly forces" subtitle below).
            if (_captureEnabled && _capturedByFriendly) then {
                _triggered = true;
                private _candidates = (_objCenter nearEntities [["Man","Car","Tank","Air","Ship"], _CAPTURE_RADIUS]) select {
                    alive _x && {(side (group _x)) in _sideObjectsEnemy}
                };
                if (count _candidates > 0) then {
                    _caller = _candidates select 0;
                };
            };

            // Proximity trigger: spatial query at the building itself.
            // Only run if capture hasn't already triggered (saves a
            // nearEntities call in the common "both" case where capture
            // fires first).
            if (!_triggered && {_proximityEnabled}) then {
                private _nearbyEnemies = (_building nearEntities [["Man","Car","Tank","Air","Ship"], _PROXIMITY_RADIUS]) select {
                    alive _x && {(side (group _x)) in _sideObjectsEnemy}
                };
                if (count _nearbyEnemies > 0) then {
                    _triggered = true;
                    _caller = _nearbyEnemies select 0;
                };
            };

            if (_triggered) then {
                _processedBuildings pushBack _building;
                [_building, _caller] call ALiVE_fnc_INS_disableBuildingInstallations;

                // Subtitle: if we have a specific caller (proximity or
                // capture with unit nearby) use their name and target
                // their side. If not (capture at range, no units within
                // radius) use a generic "Friendly forces" label and
                // broadcast to every friendly side of this OPCOM.
                if (isNull _caller) then {
                    private _msg = format [_subtitleText, "Friendly forces", mapGridPosition _building];
                    {
                        [_subtitleTitle, _msg] remoteExec ["BIS_fnc_showSubtitle", _x];
                    } forEach _sideObjectsEnemy;
                } else {
                    [_subtitleTitle, format [_subtitleText, name _caller, mapGridPosition _building]] remoteExec ["BIS_fnc_showSubtitle", side (group _caller)];
                };
            };
        };
    } forEach _installationSpecs;
} forEach _objectives;
