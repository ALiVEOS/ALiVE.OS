/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_advciv_react
Description:
    Executes an immediate behavioural reaction on a civilian unit in response
    to an event type. Handles the following reaction types:
      GUNFIRE  - Triggers panic cascade to nearby calm civilians, plays voice
                 line, and sets the unit running.
      HIT      - Plays a randomised hit reaction (hands up, drop prone, freeze,
                 scream, or crawl) via a weighted probability roll, then
                 transitions to PANIC. Also alerts nearby civilians within
                 one-third of the reaction radius.
      HIDING   - Sets the unit prone or crouched and watches the danger source.
                 Occasionally plays a hiding voice line.
      FOLLOW   - Orders the unit to join the player's group and follow. If the
                 unit is a createAgent-spawned crowd civilian (null group), it
                 is first converted to a full unit with a proper group before
                 the join is performed (Smart Hybrid conversion).
      STAY     - Halts the unit and disables movement AI.
      GOHOME   - Sets the unit to navigate back to its home position.
      HANDSUP  - Halts the unit and plays a surrender animation.
      GETDOWN  - Halts the unit and forces prone stance.
      KNEEL    - Halts the unit and forces kneeling stance.
      CALM     - Resets the unit to the CALM state, clearing all panic variables.
      GETIN    - Orders the unit to board a vehicle. If the caller passes
                 a specific vehicle as the extra parameter that vehicle is
                 used; otherwise the unit boards the nearest empty unlocked
                 LandVehicle within 50 m, or no-ops if none in range.
      GETOUT   - Dismounts the unit from their current vehicle, then
                 locks them in HANDSUP next to the vehicle (player-coerced
                 dismount, mirrors STOP_VEHICLE's post-dismount lock).
                 No-op if the unit is already on foot.
      STOP_VEHICLE - Civ-driver compliance: cancel current AI move, brake to a
                 stop, kill the engine, dismount, then transition to HANDSUP
                 so the player can engage with the now-stopped driver.
                 Triggered by the per-frame civ-vehicle handler in
                 XEH_postInit (weapon-aim or stop-gesture path). Refusal
                 gates (hostility >= 60, already-triggered debounce) are
                 pre-checked at the trigger site so the case body assumes
                 the driver is willing to comply.
Parameters:
    _this select 0: OBJECT - The civilian unit to react
    _this select 1: STRING - The reaction type (see above)
    _this select 2: ANY    - Optional extra parameter (vehicle OBJECT for GETIN
                             and STOP_VEHICLE)
Returns:
    Nil
See Also:
    ALIVE_fnc_advciv_brainTick, ALIVE_fnc_advciv_orderMenu
Author:
    Jman (advanced civs)
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params [["_unit", objNull, [objNull]], ["_type", "GUNFIRE", [""]], ["_extraParam", nil]];

if (isNull _unit || {!alive _unit}) exitWith {};
if (isPlayer _unit) exitWith {};
if (_unit getVariable ["ALiVE_advciv_blacklist", false]) exitWith {};
if (vehicle _unit != _unit && {_type == "HIT"}) exitWith {};   // Don't react to HIT while in a vehicle

private _inVehicle = (vehicle _unit != _unit);

// Shared voice helper: plays a random line from the given pool, rate-limited
// and chance-gated. Defined locally so all cases can call it cleanly.
private _fnc_shout = {
    params ["_unit", "_lines"];
    if (!ALiVE_advciv_voiceEnabled) exitWith {};
    if (random 1 > ALiVE_advciv_voiceChance) exitWith {};
    private _lastVoice = _unit getVariable ["ALiVE_advciv_lastVoice", 0];
    if (time - _lastVoice < 5) exitWith {};
    [_unit, selectRandom _lines] remoteExec ["say3D", 0];
    _unit setVariable ["ALiVE_advciv_lastVoice", time];
};

// Order-change animation cleanup: HANDSUP is the only order that locks the
// unit into a custom playMove (the surrender anim
// AmovPercMstpSnonWnonDnon_AmovPercMstpSsurWnonDnon set in the HANDSUP case
// below). setUnitPos changes alone don't escape a playMove loop, so any
// subsequent player order other than HANDSUP itself needs an explicit
// switchMove "" to clear the locked animation - otherwise the unit walks /
// kneels / lies prone with hands still raised.
//
// Centralised here so each individual order case can do its pose work
// without duplicating the cleanup. Reactions (GUNFIRE / HIT / HIDING / etc.)
// are intentionally excluded - those don't change the player-issued order
// variable, so the previous HANDSUP intent should persist through a
// transient event reaction.
private _priorOrder = _unit getVariable ["ALiVE_advciv_order", "NONE"];
if (
    _priorOrder == "HANDSUP" &&
    {_type in ["FOLLOW", "STAY", "GOHOME", "CALM", "KNEEL", "GETDOWN", "GETIN"]}
) then {
    _unit switchMove "";
};

// Stand-up transition from a low-pose order to a stand-pose order.
// Per BIKI's setUnitPos page, the command updates the AI's stance
// preference but does NOT force an animation transition out of a
// current rest-loop animation - so a KNEEL'd civ getting setUnitPos
// "UP" from a follow-up order would stay visibly kneeling. switchMove
// "" would snap to standing without transition (jarring). playAction
// "Stand" plays the engine's natural stand-up transition animation
// smoothly. Skipped when prior order is HANDSUP because that civ is
// already standing - the centralised switchMove "" above clears the
// surrender anim and re-animating standing would be redundant.
if (
    _priorOrder in ["KNEEL", "GETDOWN"] &&
    {_type in ["FOLLOW", "STAY", "GOHOME", "CALM", "GETIN"]}
) then {
    _unit playAction "Stand";
};

switch (_type) do {

    // -----------------------------------------------------------------------
    // GUNFIRE: trigger a panic cascade to nearby calm civilians, play a voice
    // line, and set the unit running. State/flee destination is set by brainTick.
    // -----------------------------------------------------------------------
    case "GUNFIRE": {
        if (ALiVE_advciv_debug) then {
            private _currentState = _unit getVariable ["ALiVE_advciv_state", "CALM"];
            if (_currentState in ["CALM", "ALERT"]) then {
                systemChat format ["[AdvCiv] %1 → PANIC", name _unit];
            };
        };

        [_unit, ALiVE_advciv_voiceLines_panic] call _fnc_shout;

        if (!_inVehicle) then {
            _unit setUnitPos "UP";
            _unit setSpeedMode "FULL";
        };

        // Propagate alert state to calm civilians within the cascade radius
        if (ALiVE_advciv_cascadeRadius > 0) then {
            private _mySource = _unit getVariable ["ALiVE_advciv_panicSource", [0,0,0]];
            if !(_mySource isEqualTo [0,0,0]) then {
                {
                    if (alive _x
                        && {side _x == civilian}
                        && {!isPlayer _x}
                        && {_x != _unit}
                        && {_x getVariable ["ALiVE_advciv_state", "CALM"] == "CALM"}
                        && {random 1 < ALiVE_advciv_cascadeChance}
                        // Rate-limit cascade per unit to prevent chain reactions every frame
                        && {(time - (_x getVariable ["ALiVE_advciv_lastCascadeTime", 0])) > 10}
                    ) then {
                        _x setVariable ["ALiVE_advciv_state", "ALERT", true];
                        _x setVariable ["ALiVE_advciv_stateTimer", 0];
                        _x setVariable ["ALiVE_advciv_panicSource", _mySource, true];
                        _x setVariable ["ALiVE_advciv_lastCascadeTime", time];
                    };
                } forEach (_unit nearEntities ["CAManBase", ALiVE_advciv_cascadeRadius]);
            };
        };
    };

    // -----------------------------------------------------------------------
    // HIT: play a weighted random hit reaction, then transition to PANIC.
    // Nearby civilians also become alert or panic depending on distance.
    // -----------------------------------------------------------------------
    case "HIT": {
        if (ALiVE_advciv_debug) then {
            systemChat format ["[AdvCiv] %1 → HIT reaction", name _unit];
        };

        [_unit, ALiVE_advciv_voiceLines_hit] call _fnc_shout;

        // Cumulative probability distribution for hit reaction selection
        private _roll       = random 1;
        private _cumHandsUp = ALiVE_advciv_handsUpChance;
        private _cumDrop    = _cumHandsUp + ALiVE_advciv_dropChance;
        private _cumFreeze  = _cumDrop + ALiVE_advciv_freezeChance;
        private _cumScream  = _cumFreeze + ALiVE_advciv_screamChance;

        private _reaction = "CRAWL";   // Default if all thresholds missed
        if (_roll < _cumHandsUp)      then { _reaction = "STOP_STAND"; }
        else { if (_roll < _cumDrop)   then { _reaction = "DROP"; }
        else { if (_roll < _cumFreeze) then { _reaction = "FREEZE"; }
        else { if (_roll < _cumScream) then { _reaction = "SCREAM"; }; }; }; };

        switch (_reaction) do {

            // Freeze standing, then panic after a short delay
            case "STOP_STAND": {
                doStop _unit;
                _unit setSpeedMode "LIMITED";
                _unit setUnitPos "UP";
                [{
                    params ["_u"];
                    if (alive _u) then {
                        _u setVariable ["ALiVE_advciv_state", "PANIC", true];
                        _u setVariable ["ALiVE_advciv_hitReacting", false, true];
                        _u setVariable ["ALiVE_advciv_hidingPos", [], true];
                    };
                }, [_unit], 3 + random 3] call CBA_fnc_waitAndExecute;
            };

            // Drop prone, then stand up and panic after a short delay
            case "DROP": {
                doStop _unit;
                _unit setUnitPos "DOWN";
                _unit setSpeedMode "LIMITED";
                [{
                    params ["_u"];
                    if (alive _u) then {
                        _u setUnitPos "UP";
                        _u setVariable ["ALiVE_advciv_state", "PANIC", true];
                        _u setVariable ["ALiVE_advciv_hitReacting", false, true];
                        _u setVariable ["ALiVE_advciv_hidingPos", [], true];
                    };
                }, [_unit], 4 + random 5] call CBA_fnc_waitAndExecute;
            };

            // Crouch and freeze, then panic
            case "FREEZE": {
                doStop _unit;
                _unit setUnitPos "MIDDLE";
                _unit setSpeedMode "LIMITED";
                [{
                    params ["_u"];
                    if (alive _u) then {
                        _u setVariable ["ALiVE_advciv_state", "PANIC", true];
                        _u setVariable ["ALiVE_advciv_hitReacting", false, true];
                        _u setVariable ["ALiVE_advciv_hidingPos", [], true];
                    };
                }, [_unit], 3 + random 4] call CBA_fnc_waitAndExecute;
            };

            // Scream and immediately sprint away from the danger source
            case "SCREAM": {
                [_unit, selectRandom ALiVE_advciv_voiceLines_panic] remoteExec ["say3D", 0];
                _unit setSpeedMode "FULL";
                private _source = _unit getVariable ["ALiVE_advciv_panicSource", [0,0,0]];
                if !(_source isEqualTo [0,0,0]) then {
                    // Run away from source: bearing from unit to source + 180 degrees
                    _unit doMove (_unit getPos [30 + random 20, (_unit getDir _source) + 180]);
                };
                [{
                    params ["_u"];
                    if (alive _u) then {
                        _u setVariable ["ALiVE_advciv_state", "PANIC", true];
                        _u setVariable ["ALiVE_advciv_hitReacting", false, true];
                        _u setVariable ["ALiVE_advciv_hidingPos", [], true];
                    };
                }, [_unit], 2 + random 2] call CBA_fnc_waitAndExecute;
            };

            // Crawl away prone, then stand and panic
            case "CRAWL": {
                _unit setUnitPos "DOWN";
                _unit enableAI "PATH";
                _unit setSpeedMode "FULL";
                private _source = _unit getVariable ["ALiVE_advciv_panicSource", [0,0,0]];
                if !(_source isEqualTo [0,0,0]) then {
                    _unit doMove (_unit getPos [15 + random 10, _unit getDir _source]);
                };
                [{
                    params ["_u"];
                    if (alive _u) then {
                        _u setUnitPos "UP";
                        _u setVariable ["ALiVE_advciv_state", "PANIC", true];
                        _u setVariable ["ALiVE_advciv_hitReacting", false, true];
                        _u setVariable ["ALiVE_advciv_hidingPos", [], true];
                    };
                }, [_unit], 5 + random 5] call CBA_fnc_waitAndExecute;
            };
        };

        // Spread the alarm to witnesses: civilians very close go straight to PANIC,
        // those further away become ALERT
        {
            if (alive _x && {side _x == civilian} && {!isPlayer _x} && {_x != _unit}) then {
                private _civState = _x getVariable ["ALiVE_advciv_state", "CALM"];
                if (_civState in ["CALM", "ALERT"]) then {
                    if (_x distance _unit < 15) then {
                        _x setVariable ["ALiVE_advciv_state", "PANIC", true];
                        _x setVariable ["ALiVE_advciv_panicSource", getPos _unit, true];
                        _x setVariable ["ALiVE_advciv_hidingPos", [], true];
                        _x setVariable ["ALiVE_advciv_lastShotTime", time];
                    } else {
                        _x setVariable ["ALiVE_advciv_state", "ALERT", true];
                        _x setVariable ["ALiVE_advciv_panicSource", getPos _unit, true];
                        _x setVariable ["ALiVE_advciv_stateTimer", 0];
                    };
                };
            };
        } forEach (_unit nearEntities ["CAManBase", ALiVE_advciv_reactionRadius * 0.33]);
    };

    // -----------------------------------------------------------------------
    // HIDING: apply a low/prone posture and watch the danger source.
    // Called each tick while in HIDING state so posture stays applied.
    // -----------------------------------------------------------------------
    case "HIDING": {
        if (ALiVE_advciv_debug) then {
            systemChat format ["[AdvCiv] %1 → HIDING", name _unit];
        };

        if (!_inVehicle) then {
            // Alternate between prone and crouched to vary appearance
            _unit setUnitPos (selectRandom ["DOWN","DOWN","MIDDLE"]);
        };
        private _source = _unit getVariable ["ALiVE_advciv_panicSource", [0,0,0]];
        if !(_source isEqualTo [0,0,0]) then { _unit doWatch _source; };

        // Occasional ambient hiding sounds — low chance, long cooldown
        private _lastVoice = _unit getVariable ["ALiVE_advciv_lastVoice", 0];
        if (ALiVE_advciv_voiceEnabled && {time - _lastVoice > 20} && {random 1 < 0.15}) then {
            [_unit, ALiVE_advciv_voiceLines_hiding] call _fnc_shout;
        };
    };

    // -----------------------------------------------------------------------
    // FOLLOW: join the player's group.
    // Smart Hybrid: createAgent crowd civilians have a null group and cannot
    // use joinSilent directly. Detect this and convert the agent to a full unit
    // with a real group before performing the join.
    // -----------------------------------------------------------------------
    case "FOLLOW": {
        if (ALiVE_advciv_debug) then {
            systemChat format ["[AdvCiv] %1 ordered: FOLLOW", name _unit];
        };

        if (isNull (group _unit)) then {
            // --- Agent conversion path ---
            // This unit was spawned via createAgent and has no group.
            // createGroup/createUnit must always run on the server, but this
            // function may be called from a client addAction callback.
            // The requesting player object is captured here (client-side, where
            // 'player' is valid) and passed to the server conversion function so
            // it is not evaluated as objNull on a dedicated server.
            private _requestingPlayer = player;
            [_unit, _requestingPlayer] remoteExecCall ["ALiVE_fnc_advciv_convertAgentAndFollow", 2];

        } else {
            // --- Standard unit path (already has a real group) ---
            _unit setVariable ["ALiVE_advciv_state", "ORDERED", true];
            _unit setVariable ["ALiVE_advciv_order", "FOLLOW", true];
            _unit setVariable ["ALiVE_advciv_orderTarget", player, true];
            _unit setVariable ["ALiVE_advciv_nearShots", 0, true];
            _unit setVariable ["ALiVE_advciv_hidingPos", [], true];

            [_unit] joinSilent (group player);
            // setUnitPos "UP" not "AUTO": AUTO lets the AI choose stance based
            // on combat / awareness, so a civ that was previously KNEEL'd or
            // HIDING with elevated AWARE behaviour can stay crouched after
            // the order. Forcing UP guarantees the visible standing pose
            // expected for a follow order on a non-combatant.
            _unit setUnitPos "UP";
            _unit enableAI "MOVE";
            _unit enableAI "PATH";
            _unit setSpeedMode "NORMAL";
        };
    };

    // -----------------------------------------------------------------------
    // STAY: halt the unit and lock movement until a different order is issued
    // -----------------------------------------------------------------------
    case "STAY": {
        if (ALiVE_advciv_debug) then {
            systemChat format ["[AdvCiv] %1 ordered: STAY", name _unit];
        };

        _unit setVariable ["ALiVE_advciv_state", "ORDERED", true];
        _unit setVariable ["ALiVE_advciv_order", "STAY", true];
        _unit setVariable ["ALiVE_advciv_nearShots", 0, true];
        _unit setVariable ["ALiVE_advciv_hidingPos", [], true];

        doStop _unit;
        _unit disableAI "MOVE";
        // setUnitPos "UP" not "AUTO" - see CALM case for rationale.
        _unit setUnitPos "UP";
    };

    // -----------------------------------------------------------------------
    // GOHOME: leave the player's group if necessary, then navigate home.
    // brainTick's GOHOME case handles the actual movement each tick.
    // -----------------------------------------------------------------------
    case "GOHOME": {
        if (ALiVE_advciv_debug) then {
            systemChat format ["[AdvCiv] %1 ordered: GO HOME", name _unit];
        };

        _unit setVariable ["ALiVE_advciv_state", "ORDERED", true];
        _unit setVariable ["ALiVE_advciv_order", "GOHOME", true];
        _unit setVariable ["ALiVE_advciv_nearShots", 0, true];
        _unit setVariable ["ALiVE_advciv_hidingPos", [], true];

        // Remove from player's group so the player doesn't lose a squad member
        if (group _unit == group player) then {
            [_unit] joinSilent (createGroup civilian);
        };

        _unit enableAI "MOVE";
        _unit enableAI "PATH";
        // setUnitPos "UP" not "AUTO" - see CALM case for rationale.
        _unit setUnitPos "UP";
        _unit setSpeedMode "LIMITED";
    };

    // -----------------------------------------------------------------------
    // HANDSUP: lock in place with surrender animation
    // -----------------------------------------------------------------------
    case "HANDSUP": {
        if (ALiVE_advciv_debug) then {
            systemChat format ["[AdvCiv] %1 ordered: HANDS UP", name _unit];
        };

        _unit setVariable ["ALiVE_advciv_state", "ORDERED", true];
        _unit setVariable ["ALiVE_advciv_order", "HANDSUP", true];

        doStop _unit;
        _unit disableAI "MOVE";
        _unit setUnitPos "UP";
        // Per BIKI's playMove page, the command plays the named
        // animation ONCE then returns the unit to its AI-default
        // animation. So this transition (stand -> surrender) plays
        // smoothly, but afterwards the AI reverts to regular standing
        // rest (CARELESS+UP unarmed civ default), dropping the hands.
        // Lock the surrender rest pose AmovPercMstpSsurWnonDnon via a
        // delayed switchMove (per BIKI, switchMove sets the unit's
        // current animation in a way the AI cannot override). The 2 s
        // delay matches the approximate transition duration; the
        // reentrancy guard checks the order is still HANDSUP in case
        // the player issued a different order during the transition.
        _unit playMove "AmovPercMstpSnonWnonDnon_AmovPercMstpSsurWnonDnon";
        [{
            params ["_unit"];
            if (
                alive _unit &&
                {_unit getVariable ["ALiVE_advciv_order", "NONE"] == "HANDSUP"}
            ) then {
                _unit switchMove "AmovPercMstpSsurWnonDnon";
            };
        }, [_unit], 2] call CBA_fnc_waitAndExecute;
    };

    // -----------------------------------------------------------------------
    // GETDOWN: lock prone
    // -----------------------------------------------------------------------
    case "GETDOWN": {
        if (ALiVE_advciv_debug) then {
            systemChat format ["[AdvCiv] %1 ordered: GET DOWN", name _unit];
        };

        _unit setVariable ["ALiVE_advciv_state", "ORDERED", true];
        _unit setVariable ["ALiVE_advciv_order", "GETDOWN", true];

        doStop _unit;
        _unit disableAI "MOVE";
        _unit setUnitPos "DOWN";
    };

    // -----------------------------------------------------------------------
    // KNEEL: lock crouched
    // -----------------------------------------------------------------------
    case "KNEEL": {
        if (ALiVE_advciv_debug) then {
            systemChat format ["[AdvCiv] %1 ordered: KNEEL", name _unit];
        };

        _unit setVariable ["ALiVE_advciv_state", "ORDERED", true];
        _unit setVariable ["ALiVE_advciv_order", "KNEEL", true];

        doStop _unit;
        _unit disableAI "MOVE";
        _unit setUnitPos "MIDDLE";
    };

    // -----------------------------------------------------------------------
    // CALM: cancel all orders and reset the unit to calm ambient behaviour
    // -----------------------------------------------------------------------
    case "CALM": {
        if (ALiVE_advciv_debug) then {
            systemChat format ["[AdvCiv] %1 ordered: CALM DOWN", name _unit];
        };

        _unit setVariable ["ALiVE_advciv_state", "CALM", true];
        _unit setVariable ["ALiVE_advciv_order", "NONE", true];
        _unit setVariable ["ALiVE_advciv_nearShots", 0, true];
        _unit setVariable ["ALiVE_advciv_hidingPos", [], true];
        _unit setVariable ["ALiVE_advciv_panicSource", [0,0,0], true];

        _unit enableAI "MOVE";
        _unit enableAI "PATH";
        // setUnitPos "UP" not "AUTO": AUTO lets the AI keep crouched stance
        // when prior behaviour was AWARE (KNEEL'd / HIDING / etc.) so the
        // unit could stay visibly crouched even after CALM. Forcing UP
        // matches the expected "civilian stands and chills" semantics of
        // CALM. The brainTick CALM stateChange handler still runs and sets
        // CARELESS behaviour, so the AI's overall calm posture takes hold
        // on the next tick alongside the now-explicit standing pose. The
        // HANDSUP-specific animation cleanup is handled centrally at the
        // top of this function (see issue #855 reference).
        _unit setUnitPos "UP";
        _unit setSpeedMode "LIMITED";

        doStop _unit;
    };

    // -----------------------------------------------------------------------
    // GETIN: order the unit to board a specific vehicle.
    // _extraParam must be the vehicle OBJECT.
    // brainTick's GETIN case handles approach and boarding each tick.
    // -----------------------------------------------------------------------
    case "GETIN": {
        // Resolve the target vehicle. If the caller passed one explicitly
        // (legacy dialog path), use it. Otherwise the literal nearest
        // alive movable LandVehicle within 50 m. nearestObjects returns
        // results in distance order, so `select 0` is the nearest. The
        // brain-tick GETIN handler downgrades gracefully if the chosen
        // vehicle turns out to be locked or full (cancels back to CALM)
        // - we don't pre-filter on those here because the player picks
        // the action expecting the visibly-nearest vehicle, not the
        // nearest "empty unlocked" one.
        private _vehicle = if (!isNil "_extraParam" && {_extraParam isEqualType objNull} && {!isNull _extraParam}) then {
            _extraParam
        } else {
            private _candidates = nearestObjects [_unit, ["LandVehicle"], 50] select {
                alive _x && {canMove _x}
            };
            if (count _candidates > 0) then { _candidates select 0 } else { objNull };
        };

        if (isNull _vehicle) exitWith {
        };

        _unit setVariable ["ALiVE_advciv_state", "ORDERED", true];
        _unit setVariable ["ALiVE_advciv_order", "GETIN", true];
        _unit setVariable ["ALiVE_advciv_orderVehicle", _vehicle, true];

        // Reset the boarding flag. brain-tick GETIN gates both the
        // approach (doMove) and assign-seat branches on `!_isBoarding`,
        // and the only path that clears the flag is the brain-tick's
        // own 15 s timeout spawn - which never fires unless the assign
        // branch ran first. So a stale boarding=true (left over from a
        // previous GETIN that completed via vehicle entry, or from any
        // earlier interrupted GETIN) silently blocks every subsequent
        // GETIN until a few minutes pass and something clears it.
        _unit setVariable ["ALiVE_advciv_boarding", false, true];

        // Clear any prior switchMove-locked animation (e.g. the surrender
        // rest pose set by the HANDSUP case after a GETOUT or
        // STOP_VEHICLE). switchMove locks override AI movement; without
        // this the civ stays rooted in the previous pose even after
        // re-enabling MOVE / PATH below.
        [_unit, ""] remoteExec ["switchMove", _unit];

        _unit enableAI "MOVE";
        _unit enableAI "PATH";
        _unit setUnitPos "AUTO";
        _unit assignAsCargo _vehicle;
        [_unit] orderGetIn true;
    };

    // -----------------------------------------------------------------------
    // GETOUT: dismount the unit if they are currently in a vehicle, then
    // lock them in surrender pose next to the vehicle. Counterpart to
    // GETIN. Player-coerced dismount, so the post-dismount lock is HANDSUP
    // (not CALM) - same shape as the post-dismount tail of STOP_VEHICLE.
    // No-op if the unit is already on foot.
    // -----------------------------------------------------------------------
    case "GETOUT": {
        if (vehicle _unit == _unit) exitWith {
        };

        _unit setVariable ["ALiVE_advciv_state", "ORDERED", true];
        _unit setVariable ["ALiVE_advciv_order", "GETOUT", true];

        unassignVehicle _unit;
        [_unit] orderGetIn false;

        // After the dismount animation, lock to HANDSUP so the civ stays
        // next to the vehicle in surrender pose rather than running off.
        // HANDSUP plays the stand->surrender animation and switchMove-locks
        // the rest pose; brain-tick respects ORDERED state and doesn't
        // override.
        [
            {
                params ["_unit"];
                if (isNull _unit || {!alive _unit}) exitWith {};
                if (vehicle _unit == _unit) then {
                    [_unit, "HANDSUP"] call ALIVE_fnc_advciv_react;
                };
            },
            [_unit],
            3
        ] call CBA_fnc_waitAndExecute;
    };

    // -----------------------------------------------------------------------
    // STOP_VEHICLE: civ-driver compliance flow. Cancel current move, brake the
    // vehicle to a stop, cut the engine, dismount, then lock the dismounted
    // civ to STAY so the player can engage on foot. Sequenced via CBA wait
    // chains so the engine-off and dismount play their natural animations
    // rather than snapping. Reuses the existing STAY case for the final
    // post-dismount lock - no separate "stopped on foot" state needed.
    // -----------------------------------------------------------------------
    case "STOP_VEHICLE": {
        if (isNil "_extraParam" || {!(_extraParam isEqualType objNull)} || {isNull _extraParam}) exitWith {};
        private _vehicle = _extraParam;
        if (!alive _vehicle) exitWith {};

        if (ALiVE_advciv_debug) then {
            systemChat format ["[AdvCiv] %1 ordered: STOP VEHICLE", name _unit];
        };

        _unit setVariable ["ALiVE_advciv_state", "ORDERED", true];
        _unit setVariable ["ALiVE_advciv_order", "STOP_VEHICLE", true];
        _unit setVariable ["ALiVE_CivPop_VehicleStopTriggered", true, true];

        doStop _unit;
        _vehicle limitSpeed 0;
        // Immediate hard brake. limitSpeed 0 alone only caps the AI's
        // commanded speed; the vehicle still coasts metres before stopping
        // at typical road speeds, and a player in front of the vehicle
        // gets run over. Drop velocity immediately to ~15% of current to
        // simulate hard braking, then let the engine-off path take over.
        // setVelocity [0,0,0] is too jarring; the partial scale keeps the
        // physics smooth while shedding most of the kinetic energy in the
        // first tick.
        _vehicle setVelocity ((velocity _vehicle) vectorMultiply 0.15);

        // Wait for the vehicle to slow below 1 m/s, then engine-off + dismount
        // chain. setVelocity-style instant stops are physics-jarring; limitSpeed
        // 0 + brake-to-rest looks natural at any approach speed.
        [
            {
                params ["_unit", "_vehicle"];
                isNull _unit ||
                {!alive _unit} ||
                {isNull _vehicle} ||
                {!alive _vehicle} ||
                {speed _vehicle < 1}
            },
            {
                params ["_unit", "_vehicle"];
                if (isNull _unit || {!alive _unit} || {isNull _vehicle} || {!alive _vehicle}) exitWith {};

                _unit action ["EngineOff", _vehicle];

                // Allow the engine-off animation a beat, then dismount.
                [
                    {
                        params ["_unit", "_vehicle"];
                        if (isNull _unit || {!alive _unit}) exitWith {};
                        unassignVehicle _unit;
                        [_unit] orderGetIn false;

                        // After the dismount animation, lock the civ in
                        // surrender pose next to the vehicle. HANDSUP plays
                        // the stand->surrender animation and switchMove-locks
                        // the surrender rest pose, sets state=ORDERED +
                        // order=HANDSUP (brain-tick respects ORDERED and
                        // doesn't override). Without this lock the civ runs
                        // off on dismount because the brain-tick resumes
                        // normal pathing or escalates to PANIC from the
                        // weapon-raised player nearby.
                        [
                            {
                                params ["_unit"];
                                if (isNull _unit || {!alive _unit}) exitWith {};
                                if (vehicle _unit == _unit) then {
                                    [_unit, "HANDSUP"] call ALIVE_fnc_advciv_react;
                                };
                            },
                            [_unit],
                            3
                        ] call CBA_fnc_waitAndExecute;
                    },
                    [_unit, _vehicle],
                    1.5
                ] call CBA_fnc_waitAndExecute;
            },
            [_unit, _vehicle],
            10  // safety timeout: if the vehicle never slows below 1 m/s in 10 s, abandon
        ] call CBA_fnc_waitUntilAndExecute;
    };
};
