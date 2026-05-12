/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_advciv_brainTick
Description:
    Core state-machine tick for a single AdvCiv civilian unit. Executed
    repeatedly by the brain loop, this function reads the unit's current
    state (CALM, ALERT, PANIC, HIDING, HIT_REACT, ORDERED) and drives the
    appropriate AI behaviour each cycle. Handles state transitions, player
    order execution (FOLLOW, STAY, GOHOME, HANDSUP, GETDOWN, KNEEL, GETIN),
    vehicle escape logic, panic fleeing and building-shelter seeking, post-hide
    recovery, and home-drift correction. Also maintains debug label output when
    ALiVE_advciv_debug is enabled.
Parameters:
    _this select 0: OBJECT - The civilian unit to process
Returns:
    Nil
See Also:
    ALIVE_fnc_advciv_ambientLife, ALIVE_fnc_advciv_brainLoop,
    ALIVE_fnc_advciv_findHouse, ALIVE_fnc_advciv_react,
    ALIVE_fnc_advciv_isVehicleProtected
Author:
    Jman (advanced civs)
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!alive _unit} || {isPlayer _unit}) exitWith {};
if (!(_unit getVariable ["ALiVE_advciv_active", false])) exitWith {};
if ((_unit getVariable ["ALiVE_advciv_blacklist", false]) || {[_unit] call ALiVE_fnc_advciv_isMissionCritical}) exitWith {
    _unit setVariable ["ALiVE_advciv_active", false, true];
    ALiVE_advciv_activeUnits = ALiVE_advciv_activeUnits - [_unit];
};

// If the unit's side has changed (e.g. killed and replaced), deregister it
if (side _unit != civilian) exitWith {
    _unit setVariable ["ALiVE_advciv_active", false, true];
    ALiVE_advciv_activeUnits = ALiVE_advciv_activeUnits - [_unit];
};

// Skip the tick while boarding or driving a vehicle escape — those spawned
// scripts manage their own flow and must not be interrupted
if (_unit getVariable ["ALiVE_advciv_boarding", false]) exitWith {};
if (_unit getVariable ["ALiVE_advciv_vehicleEscaping", false]) exitWith {};

private _state    = _unit getVariable ["ALiVE_advciv_state", "CALM"];
private _homePos  = _unit getVariable ["ALiVE_advciv_homePos", getPos _unit];
private _timer    = _unit getVariable ["ALiVE_advciv_stateTimer", 0];
private _order    = _unit getVariable ["ALiVE_advciv_order", "NONE"];

// Detect state transitions so one-time entry actions are only run once
private _prevState    = _unit getVariable ["ALiVE_advciv_prevState", ""];
private _stateChanged = (_state != _prevState);
if (_stateChanged) then {
    _unit setVariable ["ALiVE_advciv_prevState", _state, true];
};

// Update the 3D debug label visible when ALiVE_advciv_debug is enabled
if (ALiVE_advciv_debug) then {
    private _nearShots = _unit getVariable ["ALiVE_advciv_nearShots", 0];
    private _label = if (_order != "NONE") then {
        format ["%1 [%2] | Shots:%3", _state, _order, floor _nearShots]
    } else {
        format ["%1 | Shots:%2", _state, floor _nearShots]
    };
    _unit setVariable ["ALiVE_advciv_dbgState", _label, true];
};

// =========================================================================
// ORDERED STATE — handle player-issued commands each tick
// exitWith keeps each case self-contained; the main state switch below is
// skipped entirely while a unit is under a player order.
// =========================================================================
if (_state == "ORDERED") exitWith {
    switch (_order) do {

        // FOLLOW: if in the player's group let group AI handle movement;
        // otherwise nudge the unit manually toward the target each tick.
        case "FOLLOW": {
            private _target = _unit getVariable ["ALiVE_advciv_orderTarget", objNull];
            if (!isNull _target && {alive _target}) then {
                // Group AI is handling it — nothing to do this tick
                if (group _unit == group _target) exitWith {};

                if (vehicle _unit != _unit) exitWith {};
                private _dist = _unit distance _target;
                if (_dist > 5) then {
                    _unit doMove (getPos _target);
                    _unit setSpeedMode (if (_dist > 20) then {"FULL"} else {"NORMAL"});
                } else {
                    doStop _unit;
                };
            } else {
                // Target gone — cancel the order and return to CALM
                _unit setVariable ["ALiVE_advciv_order", "NONE", true];
                _unit setVariable ["ALiVE_advciv_state", "CALM", true];
            };
        };

        // STAY: halt once on state entry; nothing to do on subsequent ticks
        case "STAY": {
            if (_stateChanged) then { doStop _unit; };
        };

        // GOHOME: nudge the unit toward home on entry; clear order on arrival
        case "GOHOME": {
            if (vehicle _unit != _unit) exitWith {};
            if (_unit distance _homePos < 5) then {
                _unit setVariable ["ALiVE_advciv_order", "NONE", true];
                _unit setVariable ["ALiVE_advciv_state", "CALM", true];
                doStop _unit;
            } else {
                if (_stateChanged) then { _unit doMove _homePos; };
            };
        };

        // HANDSUP / GETDOWN / KNEEL: lock movement on entry, no per-tick work needed
        case "HANDSUP": {
            if (_stateChanged) then {
                doStop _unit;
                _unit disableAI "PATH";
            };
        };

        case "GETDOWN": {
            if (_stateChanged) then {
                doStop _unit;
                _unit disableAI "PATH";
                if (vehicle _unit == _unit) then { _unit setUnitPos "DOWN"; };
            };
        };

        case "KNEEL": {
            if (_stateChanged) then {
                doStop _unit;
                _unit disableAI "PATH";
                if (vehicle _unit == _unit) then { _unit setUnitPos "MIDDLE"; };
            };
        };

        // GETIN: walk to the vehicle then board it. Assigns a seat role before
        // calling orderGetIn; a fallback spawn loop uses moveIn* if the engine
        // animation fails to complete within the timeout window.
        case "GETIN": {
            private _veh = _unit getVariable ["ALiVE_advciv_orderVehicle", objNull];

            // Abort if the vehicle is no longer valid or is now protected
            if (isNull _veh || {!alive _veh} || {!canMove _veh}) exitWith {
                _unit setVariable ["ALiVE_advciv_order", "NONE", true];
                _unit setVariable ["ALiVE_advciv_state", "CALM", true];
                _unit setVariable ["ALiVE_advciv_boarding", false, true];
            };

            if ([_veh] call ALiVE_fnc_advciv_isVehicleProtected) exitWith {
                _unit setVariable ["ALiVE_advciv_order", "NONE", true];
                _unit setVariable ["ALiVE_advciv_state", "CALM", true];
                _unit setVariable ["ALiVE_advciv_boarding", false, true];
            };

            if (vehicle _unit == _veh) exitWith {};   // Already boarded
            if (vehicle _unit != _unit) exitWith {};   // In a different vehicle

            private _dist = _unit distance _veh;
            private _isBoarding = _unit getVariable ["ALiVE_advciv_boarding", false];

            if (_dist < 8 && {!_isBoarding}) then {
                _unit setVariable ["ALiVE_advciv_boarding", true, true];

                // Assign a role before orderGetIn so the engine knows which seat
                if (isNull driver _veh) then {
                    _unit assignAsDriver _veh;
                } else {
                    if (_veh emptyPositions "cargo" > 0) then {
                        _unit assignAsCargo _veh;
                    } else {
                        // No seat available — cancel gracefully
                        _unit setVariable ["ALiVE_advciv_order", "NONE", true];
                        _unit setVariable ["ALiVE_advciv_state", "CALM", true];
                        _unit setVariable ["ALiVE_advciv_boarding", false, true];
                    };
                };

                if (_unit getVariable ["ALiVE_advciv_order", "NONE"] == "GETIN") then {
                    [_unit] orderGetIn true;

                    // Fallback: if the boarding animation doesn't complete within
                    // 15 s (e.g. the unit clips through geometry), force moveIn directly
                    [_unit, _veh] spawn {
                        params ["_u", "_v"];
                        private _timeout = time + 15;
                        waitUntil { sleep 0.5; !alive _u || vehicle _u == _v || time > _timeout };

                        if (alive _u && {vehicle _u != _v} && {_u distance _v < 12}) then {
                            if (isNull driver _v) then {
                                [_u, _v] remoteExecCall ["moveInDriver", 0];
                            } else {
                                if (_v emptyPositions "cargo" > 0) then {
                                    [_u, _v] remoteExecCall ["moveInCargo", 0];
                                };
                            };
                        };

                        sleep 0.5;
                        if (alive _u) then {
                            _u setVariable ["ALiVE_advciv_boarding", false, true];
                        };
                    };
                };

            } else {
                // Still approaching — keep moving toward the vehicle
                if (!_isBoarding) then {
                    _unit doMove (getPos _veh);
                    _unit setSpeedMode "FULL";
                };
            };
        };
    };
};


// =========================================================================
// MAIN STATE MACHINE
// =========================================================================
switch (_state) do {

    // CALM: reset flags on entry, then run ambient life each tick
    case "CALM": {
        if (_stateChanged) then {
            _unit setBehaviour "CARELESS";
            _unit setSpeedMode "LIMITED";
            if (vehicle _unit == _unit) then { _unit setUnitPos "UP"; };
            _unit enableAI "PATH";
            // Reset escape/panic flags so they're clean for the next threat
            _unit setVariable ["ALiVE_advciv_vehicleEscapeTried", false];
            _unit setVariable ["ALiVE_advciv_nearShots", 0];
            _unit setVariable ["ALiVE_advciv_panicRunStart", 0];
            _unit setVariable ["ALiVE_advciv_hidingBuilding", objNull, true];
        };
        if (vehicle _unit == _unit) then {
            [_unit] call ALiVE_fnc_advciv_ambientLife;
        };
    };

    // ALERT: watch the danger source for a short window, then re-evaluate.
    // If a confirmed hostile is still nearby after the timer, escalate to PANIC;
    // otherwise de-escalate back to CALM.
    case "ALERT": {
        if (_stateChanged) then {
            _unit setBehaviour "AWARE";
            _unit setSpeedMode "LIMITED";
            if (vehicle _unit == _unit) then { _unit setUnitPos "UP"; };
            _unit setVariable ["ALiVE_advciv_stateTimer", time + 8 + random 12];
            _unit setVariable ["ALiVE_advciv_vehicleEscapeTried", false];
            private _source = _unit getVariable ["ALiVE_advciv_panicSource", [0,0,0]];
            if !(_source isEqualTo [0,0,0]) then { _unit doWatch _source; };
        };

        private _alertTimer = _unit getVariable ["ALiVE_advciv_stateTimer", 0];
        if (_alertTimer > 0 && {time > _alertTimer}) then {
            private _lastShot = _unit getVariable ["ALiVE_advciv_lastShotTime", 0];
            private _shots    = _unit getVariable ["ALiVE_advciv_nearShots", 0];

            // Only escalate to PANIC if: shot memory is fresh AND stress is high
            // AND a unit that actually fired at a civilian (or has low rating) is nearby
            private _realThreat = false;
            if ((time - _lastShot) < ALiVE_advciv_shotMemoryTime && {_shots > 5}) then {
                private _hostiles = _unit nearEntities ["CAManBase", ALiVE_advciv_reactionRadius];
                _hostiles = _hostiles select {
                    alive _x
                    && {side _x != civilian}
                    && {side _x != sideLogic}
                    && {(_x getVariable ["ALiVE_advciv_firedAtCiv", false]) || {rating _x < -500}}
                };
                _realThreat = (count _hostiles > 0);
            };

            if (_realThreat) then {
                _unit setVariable ["ALiVE_advciv_state", "PANIC", true];
                _unit setVariable ["ALiVE_advciv_stateTimer", 0];
                _unit setVariable ["ALiVE_advciv_hidingPos", [], true];
            } else {
                _unit setVariable ["ALiVE_advciv_state", "CALM", true];
                _unit setVariable ["ALiVE_advciv_stateTimer", 0];
                _unit setVariable ["ALiVE_advciv_nearShots", 0];
                _unit doWatch objNull;
            };
        };
    };

    // PANIC: attempt vehicle escape first (once per panic episode), then
    // either flee to a building or run in the open. Transitions to HIDING
    // once a destination is reached or the flee timer expires.
    case "PANIC": {
        if (!alive _unit) exitWith {};

        private _inVehicle = (vehicle _unit != _unit);

        if (_stateChanged) then {
            _unit setBehaviour "AWARE";
            _unit setSpeedMode "FULL";
            if (!_inVehicle) then { _unit setUnitPos "UP"; };
            _unit enableAI "PATH";
            _unit setVariable ["ALiVE_advciv_panicRunStart", 0];
            _unit setVariable ["ALiVE_advciv_hidingBuilding", objNull, true];
        };

        // If currently a passenger (not the driver), bail out and re-enter
        // the PANIC flow on foot once the exit animation completes
        if (_inVehicle) exitWith {
            private _veh = vehicle _unit;
            if (driver _veh == _unit) exitWith {};   // Driving — let escape logic run
            if (_order == "GETIN") exitWith {};        // Player ordered them in — don't bail

            doGetOut _unit;
            [{
                params ["_u"];
                !alive _u || vehicle _u == _u
            }, {
                params ["_u"];
                if (alive _u) then {
                    _u setVariable ["ALiVE_advciv_state", "PANIC", true];
                    _u setVariable ["ALiVE_advciv_hidingPos", [], true];
                };
            }, [_unit], 10] call CBA_fnc_waitUntilAndExecute;
        };

        // ---------------------------------------------------------------
        // Vehicle escape attempt (only once per PANIC episode, chance-gated)
        // ---------------------------------------------------------------
        private _triedVeh = _unit getVariable ["ALiVE_advciv_vehicleEscapeTried", false];
        if (!_triedVeh && {ALiVE_advciv_vehicleEscape}) then {

            _unit setVariable ["ALiVE_advciv_vehicleEscapeTried", true];

            if (random 1 < ALiVE_advciv_vehicleEscapeChance) then {
                // Find the nearest suitable unoccupied, unlocked, fuelled vehicle
                private _vehicles = nearestObjects [_unit, ["Car","Truck","Motorcycle"], 80];
                _vehicles = _vehicles select {
                    alive _x
                    && {canMove _x}
                    && {locked _x < 2}
                    && {isNull driver _x}
                    && {speed _x < 1}
                    && {fuel _x > 0}
                    && {!([_x] call ALiVE_fnc_advciv_isVehicleProtected)}
                };

                if (count _vehicles > 0) then {
                    // Pick closest qualifying vehicle
                    _vehicles = [_vehicles, [], { _unit distance _x }, "ASCEND"] call BIS_fnc_sortBy;
                    private _veh = _vehicles select 0;

                    _unit setVariable ["ALiVE_advciv_vehicleEscaping", true, true];
                    _unit setVariable ["ALiVE_advciv_boarding", true, true];
                    _unit doMove (getPos _veh);
                    _unit setSpeedMode "FULL";
                    _unit forceSpeed -1;

                    // Spawned script manages the full board → drive → exit sequence
                    // independently of the brain tick to avoid tick interference
                    [_unit, _veh] spawn {
                        params ["_u", "_v"];
                        private _timeout = time + 25;
                        waitUntil { sleep 0.5; !alive _u || _u distance _v < 6 || time > _timeout };

                        // Abort if unit died or took too long to reach the vehicle
                        if (!alive _u || time > _timeout) exitWith {
                            if (alive _u) then {
                                _u setVariable ["ALiVE_advciv_vehicleEscaping", false, true];
                                _u setVariable ["ALiVE_advciv_boarding", false, true];
                            };
                        };

                        // Board as driver if seat is free
                        if (isNull driver _v && {alive _v} && {canMove _v}) then {
                            _u assignAsDriver _v;
                            [_u] orderGetIn true;

                            private _boardTimeout = time + 12;
                            waitUntil { sleep 0.5; !alive _u || vehicle _u == _v || time > _boardTimeout };

                            // Fallback direct seat assignment if animation failed
                            if (alive _u && {vehicle _u != _v} && {_u distance _v < 15} && {isNull driver _v}) then {
                                _u moveInDriver _v;
                            };
                        };

                        _u setVariable ["ALiVE_advciv_boarding", false, true];

                        // If boarding failed, clear flags and return to normal PANIC flow
                        if (!alive _u || vehicle _u != _v) exitWith {
                            if (alive _u) then {
                                _u setVariable ["ALiVE_advciv_vehicleEscaping", false, true];
                            };
                        };

                        sleep 1;
                        private _escapeStartPos = getPos _u;

                        // Drive away from the danger source with a random angular spread
                        private _source = _u getVariable ["ALiVE_advciv_panicSource", [0,0,0]];
                        private _escapeDir = if !(_source isEqualTo [0,0,0]) then {
                            (_source getDir _escapeStartPos) + (-30 + random 60)
                        } else { random 360 };
                        private _escapePos = _escapeStartPos getPos [500 + random 300, _escapeDir];

                        // Clear any existing waypoints and set a single escape waypoint
                        private _grp = group _u;
                        while {count waypoints _grp > 0} do { deleteWaypoint [_grp, 0]; };
                        private _wp = _grp addWaypoint [_escapePos, 0];
                        _wp setWaypointType "MOVE";
                        _wp setWaypointSpeed "FULL";
                        _wp setWaypointBehaviour "CARELESS";
                        _wp setWaypointCompletionRadius 50;

                        private _driveStart   = time;
                        private _lastDrivePos = getPos _u;
                        private _stuckCount   = 0;
                        private _minDriveTime = 15;   // Don't exit the vehicle too soon

                        // Drive until: escaped far enough, been driving too long,
                        // vehicle is disabled/out of fuel, or stuck for too many checks
                        waitUntil {
                            sleep 3;
                            if (!alive _u || vehicle _u != _v) exitWith { true };
                            if (!canMove _v || fuel _v <= 0) exitWith { true };

                            private _elapsed = time - _driveStart;

                            if (_u distance _lastDrivePos < 3) then {
                                _stuckCount = _stuckCount + 1;
                            } else {
                                _stuckCount = 0;
                                _lastDrivePos = getPos _u;
                            };
                            if (_stuckCount > 6) exitWith { true };   // Stuck too long
                            if (_elapsed > 90)   exitWith { true };   // Hard time limit

                            if (_elapsed > _minDriveTime) then {
                                if (_u distance _escapeStartPos > 400) exitWith { true };
                            };

                            false
                        };

                        // Dismount and reset back to CALM at the new location
                        if (alive _u) then {
                            if (vehicle _u == _v) then {
                                doGetOut _u;
                                sleep 5;
                            };

                            private _grp2 = group _u;
                            while {count waypoints _grp2 > 0} do { deleteWaypoint [_grp2, 0]; };

                            _u setVariable ["ALiVE_advciv_vehicleEscaping", false, true];
                            _u setVariable ["ALiVE_advciv_boarding", false, true];
                            _u setVariable ["ALiVE_advciv_hidingPos", [], true];
                            _u setVariable ["ALiVE_advciv_panicRunStart", 0];
                            // Update home pos to where the unit ended up so it doesn't
                            // immediately try to walk all the way back across the map
                            _u setVariable ["ALiVE_advciv_homePos", getPos _u, true];
                            _u setVariable ["ALiVE_advciv_state", "CALM", true];
                        };
                    };
                };
            };
        };

        // ---------------------------------------------------------------
        // On-foot panic flee: seek a building or run in the open
        // ---------------------------------------------------------------
        private _hidingPos = _unit getVariable ["ALiVE_advciv_hidingPos", []];

        if (_hidingPos isEqualTo []) then {

            // Local function: flee in the open (no building found or not preferred)
            private _fnc_fleeOpen = {
                params ["_u"];
                private _source = _u getVariable ["ALiVE_advciv_panicSource", [0,0,0]];
                // Run away from source with random spread; random direction if no source
                private _dir = if !(_source isEqualTo [0,0,0]) then {
                    _source getDir (getPos _u)
                } else { random 360 };
                private _fleeDist = (ALiVE_advciv_fleeRadius * 0.5) + random (ALiVE_advciv_fleeRadius * 0.5);
                private _fleePos = (getPos _u) getPos [_fleeDist, _dir + (-30 + random 60)];
                _u doMove _fleePos;
                _u forceSpeed -1;
                [_u, "GUNFIRE"] call ALiVE_fnc_advciv_react;

                // After ~25 s of running, transition to HIDING wherever they ended up
                [{
                    params ["_u2"];
                    if (alive _u2 && {_u2 getVariable ["ALiVE_advciv_state", "CALM"] == "PANIC"}) then {
                        if (vehicle _u2 == _u2) then { _u2 setUnitPos "DOWN"; };
                        _u2 setVariable ["ALiVE_advciv_state", "HIDING", true];
                        _u2 setVariable ["ALiVE_advciv_stateTimer", time + ALiVE_advciv_hideTimeMin + random (ALiVE_advciv_hideTimeMax - ALiVE_advciv_hideTimeMin)];
                    };
                }, [_u], 25] call CBA_fnc_waitAndExecute;
            };

            if (ALiVE_advciv_preferBuildings) then {
                private _houseData = [_unit] call ALiVE_fnc_advciv_findHouse;
                private _building  = _houseData select 0;
                private _positions = _houseData select 1;

                if (!isNull _building && {count _positions > 0}) then {
                    private _targetPos = selectRandom _positions;
                    _unit setVariable ["ALiVE_advciv_hidingPos", _targetPos, true];
                    _unit setVariable ["ALiVE_advciv_hidingBuilding", _building, true];
                    _unit doMove _targetPos;
                    _unit setSpeedMode "FULL";
                    _unit forceSpeed -1;
                    [_unit, "GUNFIRE"] call ALiVE_fnc_advciv_react;
                } else {
                    [_unit] call _fnc_fleeOpen;
                };
            } else {
                [_unit] call _fnc_fleeOpen;
            };

        } else {
            // A hiding destination is already set — track progress toward it
            private _dist = 999;
            if (typeName _hidingPos == "ARRAY" && {count _hidingPos >= 2}) then {
                _dist = _unit distance _hidingPos;
            };

            if (_dist < 3) then {
                // Arrived at hiding spot — transition to HIDING
                _unit setVariable ["ALiVE_advciv_state", "HIDING", true];
                _unit setVariable ["ALiVE_advciv_hidingPos", [], true];
                _unit setVariable ["ALiVE_advciv_stateTimer", time + ALiVE_advciv_hideTimeMin + random (ALiVE_advciv_hideTimeMax - ALiVE_advciv_hideTimeMin)];
            } else {
                // Still en route — nudge if speed dropped (e.g. AI re-routed itself)
                if (_dist < 999 && {speed _unit < 1}) then {
                    _unit doMove _hidingPos;
                    _unit setSpeedMode "FULL";
                    _unit forceSpeed -1;
                };

                // Start panic-run timer on first movement tick
                if (_unit getVariable ["ALiVE_advciv_panicRunStart", 0] == 0) then {
                    _unit setVariable ["ALiVE_advciv_panicRunStart", time];
                };

                // If the unit has been running for 30 s without arriving, give up and
                // drop into HIDING in place rather than running forever
                if (time - (_unit getVariable ["ALiVE_advciv_panicRunStart", time]) > 30) then {
                    _unit setVariable ["ALiVE_advciv_hidingPos", [], true];
                    _unit setVariable ["ALiVE_advciv_panicRunStart", 0];
                    _unit setVariable ["ALiVE_advciv_hidingBuilding", objNull, true];
                    if (vehicle _unit == _unit) then { _unit setUnitPos "DOWN"; };
                    _unit setVariable ["ALiVE_advciv_state", "HIDING", true];
                    _unit setVariable ["ALiVE_advciv_stateTimer", time + 60 + random 60];
                };
            };
        };
    };

    // HIT_REACT: the reaction animation (managed in initUnit's Hit EH) plays for
    // up to 20 s; after that, escalate to PANIC
    case "HIT_REACT": {
        if (time - (_unit getVariable ["ALiVE_advciv_hitReactStart", time]) > 20) then {
            _unit setVariable ["ALiVE_advciv_state", "PANIC", true];
            _unit setVariable ["ALiVE_advciv_hitReacting", false, true];
            _unit setVariable ["ALiVE_advciv_hitReactStart", 0];
            _unit setVariable ["ALiVE_advciv_hidingPos", [], true];
            _unit enableAI "PATH";
        };
    };

    // HIDING: crouch/prone and hold position. Re-evaluate once the timer
    // expires; extend the timer if hostiles or recent shots are still detected.
    // On recovery, stage movement out of upper floors before heading home.
    case "HIDING": {
        if (_stateChanged) then {
            _unit disableAI "PATH";
            _unit setBehaviour "AWARE";
            _unit setSpeedMode "LIMITED";
            // Apply posture once on state entry — re-setting it every tick is
            // redundant and causes visible jitter when the unit shifts slightly.
            if (vehicle _unit == _unit) then {
                _unit setUnitPos (selectRandom ["DOWN","DOWN","MIDDLE"]);
            };
        };

        // Re-watch the danger source every tick so the unit tracks movement
        // (e.g. a vehicle slowly driving past). Cheap enough to run per-tick.
        private _source = _unit getVariable ["ALiVE_advciv_panicSource", [0,0,0]];
        if !(_source isEqualTo [0,0,0]) then { _unit doWatch _source; };

        // Occasional ambient hiding voice — low chance, long cooldown
        private _lastVoice = _unit getVariable ["ALiVE_advciv_lastVoice", 0];
        if (ALiVE_advciv_voiceEnabled && {time - _lastVoice > 20} && {random 1 < 0.15}) then {
            [_unit, selectRandom ALiVE_advciv_voiceLines_hiding] remoteExec ["say3D", 0];
            _unit setVariable ["ALiVE_advciv_lastVoice", time];
        };

        if (_timer > 0 && {time > _timer}) then {
            private _lastShot = _unit getVariable ["ALiVE_advciv_lastShotTime", 0];

            // Count confirmed threats still within reaction radius
            private _hostileNear = {
                alive _x
                && {side _x != civilian}
                && {side _x != sideLogic}
                && {(_x getVariable ["ALiVE_advciv_firedAtCiv", false]) || {rating _x < -500}}
            } count (_unit nearEntities ["CAManBase", ALiVE_advciv_reactionRadius]);

            if (_hostileNear > 0 && {(time - _lastShot) < ALiVE_advciv_shotMemoryTime}) then {
                // Still dangerous — extend the hide timer and keep hiding
                _unit setVariable ["ALiVE_advciv_stateTimer", time + ALiVE_advciv_hideTimeMin + random (ALiVE_advciv_hideTimeMax - ALiVE_advciv_hideTimeMin)];
            } else {
                // Safe — transition back to ALERT for a brief observation window
                _unit setVariable ["ALiVE_advciv_state", "ALERT", true];
                _unit setVariable ["ALiVE_advciv_stateTimer", 0];
                _unit setVariable ["ALiVE_advciv_nearShots", 0];
                _unit enableAI "PATH";
                // setUnitPos "UP" applies regardless of vehicle state. The
                // engine treats setUnitPos as a stance preference that
                // applies on next dismount when in a vehicle, so the
                // previous `if (vehicle _unit == _unit)` gate left a
                // dismount-after-HIDING civ stuck on the MIDDLE / DOWN
                // pose set during HIDING entry, walking around crouched
                // once they exited the vehicle.
                _unit setUnitPos "UP";
                _unit doWatch objNull;

                private _hidingBld = _unit getVariable ["ALiVE_advciv_hidingBuilding", objNull];
                _unit setVariable ["ALiVE_advciv_hidingBuilding", objNull, true];

                // If the unit hid on an upper floor, route it to the ground first
                // before sending it home to avoid it leaping from height
                if (_unit distance _homePos > 30 && {vehicle _unit == _unit}) then {
                    if (!isNull _hidingBld) then {
                        private _unitZ = (getPosATL _unit) select 2;
                        private _bldZ  = (getPosATL _hidingBld) select 2;

                        if ((_unitZ - _bldZ) > 3.5) then {
                            // Unit is elevated — move to a ground-floor position first
                            private _groundPos = [_hidingBld, 3.5, _unit] call ALiVE_fnc_advciv_getSafePositions;
                            if (count _groundPos > 0) then {
                                _unit doMove (selectRandom _groundPos);
                                [{
                                    params ["_u", "_hp"];
                                    if (alive _u && {vehicle _u == _u}) then { _u doMove _hp; };
                                }, [_unit, _homePos], 15] call CBA_fnc_waitAndExecute;
                            } else {
                                // No ground positions found — move to building base then home
                                _unit doMove (getPos _hidingBld);
                                [{
                                    params ["_u", "_hp"];
                                    if (alive _u && {vehicle _u == _u}) then { _u doMove _hp; };
                                }, [_unit, _homePos], 15] call CBA_fnc_waitAndExecute;
                            };
                        } else {
                            _unit doMove _homePos;
                        };
                    } else {
                        _unit doMove _homePos;
                    };
                };
            };
        };
    };
};

// =========================================================================
// Home-drift correction: if CALM or ALERT with no active order and the unit
// has wandered beyond its home radius, nudge it back toward home
// =========================================================================
if (_order == "NONE" && {_state in ["CALM", "ALERT"]}) then {
    if (vehicle _unit == _unit && {_unit distance _homePos > ALiVE_advciv_homeRadius}) then {
        _unit doMove _homePos;
    };
};
