/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_advciv_handleFired
Description:
    Server-side handler called when a non-civilian unit fires a weapon near
    AdvCiv civilians. Determines effective hearing range based on whether the
    weapon is suppressed, then applies a distance-scaled stress increment to
    all nearby civilian units. Triggers immediate PANIC with flee movement for
    units within close range, graduating to PANIC with less urgent flight at
    medium range, and ALERT or probabilistic state changes at longer distances.
    Also registers the firer as a threat on civilians within 50 m. Civilians
    under player orders (HANDSUP, GETDOWN, KNEEL) are not redirected but
    have their hide timer refreshed if already hiding. Optionally plays
    contextual voice lines on affected civilians.
Parameters:
    _this select 0: ARRAY   - World position [x,y,z] of the shot origin
    _this select 1: OBJECT  - The unit that fired (may be objNull)
    _this select 2: BOOLEAN - True if the weapon has a suppressor attached
Returns:
    Nil
See Also:
    ALIVE_fnc_advciv_handleExplosion, ALIVE_fnc_advciv_brainTick
Author:
    Jman (advanced civs)
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params [
    ["_pos", [0,0,0], [[]]],
    ["_firer", objNull, [objNull]],
    ["_hasSuppressor", false, [false]]
];

if (!isServer) exitWith {};

// Defensive: the AdvCiv system publishes its globals from
// fnc_civilianPopulationSystemInit. A shot can fire BEFORE that init runs
// (early mission preview, intro firefight, scenarios where the AdvCiv
// module loads after the first shot lands here) - at which point the
// globals are nil and any read crashes. `if (!ALiVE_advciv_enabled)` was
// itself unsafe: `!nil` errors on its own, never mind reaching the
// nearEntities call below where _range = nil produced
// "Type Any, expected Number" at line 40. Treat any missing config
// global as "system not ready, silently no-op".
if (isNil "ALiVE_advciv_enabled" || {!ALiVE_advciv_enabled}) exitWith {};
if (
    isNil "ALiVE_advciv_suppressedRange" ||
    {isNil "ALiVE_advciv_unsuppressedRange"}
) exitWith {};

if (!isNull _firer && {side _firer == civilian}) exitWith {};   // Ignore civilian-fired shots

// Suppressed weapons have a significantly reduced awareness radius
private _range    = if (_hasSuppressor) then { ALiVE_advciv_suppressedRange } else { ALiVE_advciv_unsuppressedRange };
private _nearCivs = _pos nearEntities ["CAManBase", _range];

// Tag the firer once per shot if ANY valid civilian is within 50 m, so the
// ALERT / HIDING-exit threat check in brainTick can find them. Hoisted out
// of the per-civ loop below so a single shot near N civilians produces ONE
// timestamp write + broadcast, not N redundant ones - the writes are
// idempotent (same timestamp) but each setVariable broadcast=true fires a
// publicVariable, so collapsing them is a network-side perf win.
if (!isNull _firer) then {
    private _civsWithin50 = _nearCivs select {
        alive _x
        && {side _x == civilian}
        && {!isPlayer _x}
        && {_x getVariable ["ALiVE_advciv_active", false]}
        && {(_x distance _pos) < 50}
    };
    if (count _civsWithin50 > 0) then {
        _firer setVariable ["ALiVE_advciv_firedAtCivTime", time, true];
        if (ALiVE_advciv_debug) then { diag_log format ["[ALiVE Threat DEBUG] firedAtCivTime SET unit=%1 side=%2 time=%3 origin=FiredNear civsInRange=%4", name _firer, side _firer, time, count _civsWithin50]; };
    };
};

{
    private _civ = _x;

    // Skip non-AdvCiv units and those already dead or under player control
    if (!alive _civ || {side _civ != civilian} || {isPlayer _civ} || {!(_civ getVariable ["ALiVE_advciv_active", false])}) then {
    } else {

        private _dist  = _civ distance _pos;
        private _order = _civ getVariable ["ALiVE_advciv_order", "NONE"];

        // Accumulate shot stress scaled by proximity (max 10 at point blank, min 1 at range edge)
        private _intensity = linearConversion [0, _range, _dist, 10, 1, true];
        private _cur = _civ getVariable ["ALiVE_advciv_nearShots", 0];
        private _newShots = (_cur + _intensity) min 20;
        _civ setVariable ["ALiVE_advciv_nearShots", _newShots];
        _civ setVariable ["ALiVE_advciv_lastShotTime", time];

        if (_order in ["HANDSUP", "GETDOWN", "KNEEL"]) then {
            // Under a restrictive order — extend hide timer but don't break pose
            if (_civ getVariable ["ALiVE_advciv_state", "CALM"] == "HIDING") then {
                _civ setVariable ["ALiVE_advciv_stateTimer", time + ALiVE_advciv_hideTimeMin + random (ALiVE_advciv_hideTimeMax - ALiVE_advciv_hideTimeMin)];
            };
        } else {

            private _state   = _civ getVariable ["ALiVE_advciv_state", "CALM"];
            private _onFoot  = (vehicle _civ == _civ);

            // ---------------------------------------------------------------
            // Three distance bands with escalating reaction severity
            // ---------------------------------------------------------------

            // Band 1 — Very close (< 30 m): immediate PANIC + sprint away
            if (_dist < 30 && {_state in ["CALM","ALERT"]}) then {

                _civ setVariable ["ALiVE_advciv_state", "PANIC", true];
                _civ setVariable ["ALiVE_advciv_panicSource", _pos, true];
                _civ setVariable ["ALiVE_advciv_hidingPos", [], true];
                _civ enableAI "PATH";
                _civ enableAI "MOVE";

                if (_onFoot) then {
                    [_civ, ""] remoteExec ["switchMove", 0];   // Cancel current animation

                    _civ setUnitPos "UP";
                    _civ setBehaviour "AWARE";
                    _civ setSpeedMode "FULL";
                    _civ forceSpeed -1;

                    private _fleeDir = (_pos getDir (getPos _civ)) + (-40 + random 80);
                    private _fleePos = (getPos _civ) getPos [30 + random 40, _fleeDir];
                    _civ doMove _fleePos;
                };

                // Higher voice chance for close shots — the civilian definitely heard it
                if (ALiVE_advciv_voiceEnabled && {random 1 < 0.85}) then {
                    private _lastVoice = _civ getVariable ["ALiVE_advciv_lastVoice", 0];
                    if (time - _lastVoice > 2) then {
                        [_civ, selectRandom ALiVE_advciv_voiceLines_panic] remoteExec ["say3D", 0];
                        _civ setVariable ["ALiVE_advciv_lastVoice", time];
                    };
                };

            } else {
            // Band 2 — Medium range (< 75 m): PANIC but less urgency
            if (_dist < 75 && {_state in ["CALM","ALERT"]}) then {

                _civ setVariable ["ALiVE_advciv_state", "PANIC", true];
                _civ setVariable ["ALiVE_advciv_panicSource", _pos, true];
                _civ setVariable ["ALiVE_advciv_hidingPos", [], true];
                _civ enableAI "PATH";

                if (_onFoot) then {
                    if (_state == "CALM") then {
                        [_civ, ""] remoteExec ["switchMove", 0];
                    };

                    _civ setUnitPos "UP";
                    _civ setBehaviour "AWARE";
                    _civ setSpeedMode "FULL";
                    _civ forceSpeed -1;

                    private _fleeDir = (_pos getDir (getPos _civ)) + (-30 + random 60);
                    _civ doMove ((getPos _civ) getPos [30 + random 30, _fleeDir]);
                };

                if (ALiVE_advciv_voiceEnabled && {random 1 < 0.6}) then {
                    private _lastVoice = _civ getVariable ["ALiVE_advciv_lastVoice", 0];
                    if (time - _lastVoice > 3) then {
                        [_civ, selectRandom ALiVE_advciv_voiceLines_panic] remoteExec ["say3D", 0];
                        _civ setVariable ["ALiVE_advciv_lastVoice", time];
                    };
                };

            } else {
            // Band 3 — Far (< 50% of range): lower intensity reaction
            if (_dist < _range * 0.5 && {_state in ["CALM","ALERT"]}) then {

                _civ setVariable ["ALiVE_advciv_state", "PANIC", true];
                _civ setVariable ["ALiVE_advciv_panicSource", _pos, true];
                _civ setVariable ["ALiVE_advciv_hidingPos", [], true];
                _civ setSpeedMode "FULL";
                if (_onFoot) then { _civ setUnitPos "UP"; };
                _civ setBehaviour "AWARE";
                _civ enableAI "PATH";
                if (_onFoot) then {
                    private _fleeDir = (_pos getDir (getPos _civ)) + (-30 + random 60);
                    _civ doMove ((getPos _civ) getPos [30 + random 30, _fleeDir]);
                };

            } else {

                // Outermost range — probabilistic response based on alertness and stress
                switch (_state) do {

                    case "CALM": {
                        // Alert chance scales up with accumulated stress
                        private _alertRoll = ALiVE_advciv_alertChance + (_newShots * 0.05);
                        if (random 1 < _alertRoll) then {
                            if (_newShots > 4) then {
                                // High stress despite range — go straight to PANIC
                                _civ setVariable ["ALiVE_advciv_state", "PANIC", true];
                                _civ setVariable ["ALiVE_advciv_panicSource", _pos, true];
                                _civ setVariable ["ALiVE_advciv_hidingPos", [], true];
                                _civ setSpeedMode "FULL";
                                if (_onFoot) then { _civ setUnitPos "UP"; };
                                _civ setBehaviour "AWARE";
                                _civ enableAI "PATH";
                                if (_onFoot) then {
                                    private _fleeDir = (_pos getDir (getPos _civ)) + (-30 + random 60);
                                    _civ doMove ((getPos _civ) getPos [30 + random 30, _fleeDir]);
                                };
                            } else {
                                // Low stress — just become alert and watch
                                _civ setVariable ["ALiVE_advciv_state", "ALERT", true];
                                _civ setVariable ["ALiVE_advciv_panicSource", _pos, true];
                                _civ setVariable ["ALiVE_advciv_stateTimer", 0];
                                _civ setBehaviour "AWARE";
                                if (_onFoot) then { _civ setUnitPos "UP"; };
                                _civ doWatch _pos;
                            };
                        };
                    };

                    case "ALERT": {
                        // Already alert: escalate to PANIC if stress is significant
                        if (_dist < _range * 0.75 || {_newShots > 3}) then {
                            _civ setVariable ["ALiVE_advciv_state", "PANIC", true];
                            _civ setVariable ["ALiVE_advciv_panicSource", _pos, true];
                            _civ setVariable ["ALiVE_advciv_hidingPos", [], true];
                            _civ setSpeedMode "FULL";
                            if (_onFoot) then { _civ setUnitPos "UP"; };
                            _civ setBehaviour "AWARE";
                            _civ enableAI "PATH";
                            if (_onFoot) then {
                                private _fleeDir = (_pos getDir (getPos _civ)) + (-30 + random 60);
                                _civ doMove ((getPos _civ) getPos [30 + random 30, _fleeDir]);
                            };
                        };
                    };

                    // Already hiding — refresh the hide timer, don't interrupt
                    case "HIDING": {
                        _civ setVariable ["ALiVE_advciv_stateTimer", time + ALiVE_advciv_hideTimeMin + random (ALiVE_advciv_hideTimeMax - ALiVE_advciv_hideTimeMin)];
                    };

                    // Break FOLLOW if the player fires near the civilian
                    case "ORDERED": {
                        if (_order == "FOLLOW" && {_dist < 30}) then {
                            _civ setVariable ["ALiVE_advciv_order", "NONE", true];
                            _civ setVariable ["ALiVE_advciv_state", "PANIC", true];
                            _civ setVariable ["ALiVE_advciv_panicSource", _pos, true];
                            _civ setVariable ["ALiVE_advciv_hidingPos", [], true];
                            _civ setSpeedMode "FULL";
                            if (_onFoot) then { _civ setUnitPos "UP"; };
                            _civ enableAI "PATH";
                            if (_onFoot) then {
                                private _fleeDir = (_pos getDir (getPos _civ)) + (-30 + random 60);
                                _civ doMove ((getPos _civ) getPos [40, _fleeDir]);
                            };
                        };
                    };
                };

            }; }; };
        };
    };
} forEach _nearCivs;
