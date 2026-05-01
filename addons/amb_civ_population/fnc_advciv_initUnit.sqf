/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_advciv_initUnit
Description:
    Initialises a single unit into the AdvCiv system.

    Non-civilian units (including players of any non-civilian side):
        Registers a FiredMan event handler that routes gunshot and explosive
        events into the civilian reaction pipeline, then exits. No further
        initialisation is performed.

    Civilian units (server-side only):
        Sets all required state variables, configures AI behaviour flags, and
        attaches Hit and Deleted event handlers. Finishes by adding the order
        menu and registering the unit in the brain loop.

Parameters:
    _this select 0: OBJECT - The unit to initialise
Returns:
    Nil
See Also:
    ALIVE_fnc_advciv_brainLoop, ALIVE_fnc_advciv_orderMenu,
    ALIVE_fnc_advciv_handleFired, ALIVE_fnc_advciv_handleExplosion
Author:
    Jman (advanced civs)
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!alive _unit}) exitWith {};

// =========================================================================
// Non-civilian path: register FiredMan EH and exit.
//
// Covers both players and AI on any non-civilian side. The outer check
// on side already excludes civilian-side units, so no inner player guard
// is needed. A single handler body is defined as a named code variable
// to avoid duplication across the two original separate branches.
// =========================================================================
if (side _unit != civilian) exitWith {

    if !(_unit getVariable ["ALiVE_advciv_firedEH", false]) then {
        _unit setVariable ["ALiVE_advciv_firedEH", true];

        private _firedManHandler = {
            params ["_firer", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile"];

            // Rate-limit: suppress repeat calls from automatic fire
            private _lastFired = _firer getVariable ["ALiVE_advciv_lastFiredTime", 0];
            if (time - _lastFired < 0.25) exitWith {};
            _firer setVariable ["ALiVE_advciv_lastFiredTime", time];

            private _veh         = vehicle _firer;
            private _isInVehicle = (_veh != _firer);
            private _pos = if (_isInVehicle) then { getPos _veh } else { getPos _firer };

            // Detect suppressor: check the muzzle slot of the fired weapon
            private _hasSuppressor = false;
            if (!_isInVehicle && {_weapon != ""}) then {
                if (_weapon == currentWeapon _firer) then {
                    private _acc = _firer weaponAccessories _weapon;
                    if (count _acc > 0) then {
                        private _muzzleItem = _acc select 0;
                        if (typeName _muzzleItem == "STRING" && {_muzzleItem != ""}) then {
                            _hasSuppressor = true;
                        };
                    };
                };
            };

            // Classify ammo: explosives are routed through handleExplosion
            // via a per-frame projectile tracker; everything else through handleFired
            private _isExplosive = false;
            private _ammoConfig = configFile >> "CfgAmmo" >> _ammo;
            if (isClass _ammoConfig) then {
                private _ammoSim = getText (_ammoConfig >> "simulation");
                if (_ammoSim in ["shotShell","shotRocket","shotMissile","shotGrenade","shotMine"]) then {
                    _isExplosive = true;
                };
            };

            if (_isExplosive) then {
                if (!isNull _projectile) then {
                    // Track the projectile each frame; fire handleExplosion at impact
                    private _trackData = [_projectile, _firer, time + 30, getPos _projectile];
                    [{
                        params ["_args", "_handle"];
                        _args params ["_proj", "_src", "_timeout", "_lastPos"];
                        if (!isNull _proj) then {
                            _args set [3, getPos _proj];
                        } else {
                            [_lastPos, _src] remoteExecCall ["ALiVE_fnc_advciv_handleExplosion", 2];
                            [_handle] call CBA_fnc_removePerFrameHandler;
                        };
                        if (time > _timeout) then {
                            [_handle] call CBA_fnc_removePerFrameHandler;
                        };
                    }, 0.1, _trackData] call CBA_fnc_addPerFrameHandler;
                };
            } else {
                [_pos, _firer, _hasSuppressor] remoteExecCall ["ALiVE_fnc_advciv_handleFired", 2];
            };
        };

        _unit addEventHandler ["FiredMan", _firedManHandler];
    };

};


// =========================================================================
// Civilian path: server-side initialisation only from here
// =========================================================================
if (!isServer) exitWith {};
if (isPlayer _unit) exitWith {};
if (_unit getVariable ["ALiVE_advciv_active", false]) exitWith {};     // Already initialised
if ([_unit] call ALiVE_fnc_advciv_isMissionCritical) exitWith {};      // Protected unit


// =========================================================================
// State variable initialisation
// =========================================================================
_unit setVariable ["ALiVE_advciv_active", true, true];
_unit setVariable ["ALiVE_advciv_state", "CALM", true];
if (ALiVE_advciv_debug) then {
    _unit setVariable ["ALiVE_advciv_dbgState", "CALM", true];
};
_unit setVariable ["ALiVE_advciv_prevState", "", true];
_unit setVariable ["ALiVE_advciv_homePos", getPos _unit, true];
_unit setVariable ["ALiVE_advciv_nearShots", 0];
_unit setVariable ["ALiVE_advciv_stateTimer", 0];
_unit setVariable ["ALiVE_advciv_panicSource", [0,0,0], true];
_unit setVariable ["ALiVE_advciv_hidingPos", [], true];
_unit setVariable ["ALiVE_advciv_hidingBuilding", objNull, true];
_unit setVariable ["ALiVE_advciv_hitReacting", false, true];
_unit setVariable ["ALiVE_advciv_hitReactStart", 0];
_unit setVariable ["ALiVE_advciv_panicRunStart", 0];
_unit setVariable ["ALiVE_advciv_lastAction", time + 20 + random 40];  // Staggered start to spread load
_unit setVariable ["ALiVE_advciv_actionType", "NONE", true];
_unit setVariable ["ALiVE_advciv_lastVoice", 0];
_unit setVariable ["ALiVE_advciv_vehicleEscaping", false, true];
_unit setVariable ["ALiVE_advciv_vehicleEscapeTried", false];
_unit setVariable ["ALiVE_advciv_order", "NONE", true];
_unit setVariable ["ALiVE_advciv_orderTarget", objNull, true];
_unit setVariable ["ALiVE_advciv_orderVehicle", objNull, true];
_unit setVariable ["ALiVE_advciv_boarding", false, true];
_unit setVariable ["ALiVE_advciv_lastShotTime", 0];

// Disable fleeing AI and set baseline CARELESS/slow behaviour
_unit allowFleeing 0;
_unit enableAI "PATH";
_unit setBehaviour "CARELESS";
_unit setSpeedMode "LIMITED";
if (vehicle _unit == _unit) then { _unit setUnitPos "UP"; };


// =========================================================================
// Hit event handler — manages damage reactions and vehicle bail-out
// =========================================================================
_unit addEventHandler ["Hit", {
    params ["_unit", "_source", "_damage", "_instigator"];

    if (isNull _unit || {!alive _unit}) exitWith {};
    if (isPlayer _unit) exitWith {};
    if (_damage < 0.01) exitWith {};                                           // Ignore negligible hits

    // Bump the civ's personal hostility when wounded by a player. Damage
    // is the per-hit delta (0-1), scaled by 80 so a light wound nudges
    // the victim toward Wary, a heavy wound pushes them firmly into
    // Hostile. Clamped to 100. Repeated hits compound up to the cap.
    // Applied BEFORE the hitReacting early-exit below so the hostility
    // bump still lands on civs that are mid-react from a prior hit.
    //
    // Two write paths:
    // - The runtime variable on the unit object - covers civs without
    //   an agentID (read by the non-agent branch of case "getData").
    // - The agent profile's "posture" key (which lives at
    //   `_civProfile select 2 select 12`) - canonical source read by
    //   the agent branch of case "getData" for the questioning /
    //   Gather Intel / hostility-indicator flows. Updating the runtime
    //   variable alone leaves agent-tracked civs (the typical case in
    //   advciv-active missions) showing stale hostility in the dialog.
    //   Server-authoritative; isServer-gated since Hit fires on the
    //   unit's owner.
    if (!isNull _instigator && {isPlayer _instigator}) then {
        private _bump = round (_damage * 80);

        private _currentHostility = _unit getVariable ["ALiVE_CivPop_Hostility", 30];
        private _newHostility = (_currentHostility + _bump) min 100;
        _unit setVariable ["ALiVE_CivPop_Hostility", _newHostility, true];

        if (isServer) then {
            private _civID = _unit getVariable ["agentID", ""];
            if (_civID != "") then {
                private _civProfile = [ALIVE_agentHandler, "getAgent", _civID] call ALIVE_fnc_agentHandler;
                if (!isNil "_civProfile") then {
                    private _profileHostility = (_civProfile select 2) select 12;
                    private _newProfileHostility = (_profileHostility + _bump) min 100;
                    [_civProfile, "posture", _newProfileHostility] call ALiVE_fnc_hashSet;
                };
            };
        };
    };

    if (_unit getVariable ["ALiVE_advciv_hitReacting", false]) exitWith {};    // Already reacting

    _unit setVariable ["ALiVE_advciv_order", "NONE", true];
    _unit setVariable ["ALiVE_advciv_lastShotTime", time];

    // Resolve danger position: prefer instigator, then source, then self
    private _dangerPos = getPos _unit;
    if (!isNull _instigator) then { _dangerPos = getPos _instigator; }
    else { if (!isNull _source) then { _dangerPos = getPos _source; }; };
    _unit setVariable ["ALiVE_advciv_panicSource", _dangerPos, true];

    if (vehicle _unit != _unit) then {
        private _veh = vehicle _unit;

        if (alive _veh && {driver _veh == _unit}) then {
            // Unit is driving — accelerate away before eventually bailing out
            _unit setVariable ["ALiVE_advciv_vehicleEscaping", true, true];
            _unit setSpeedMode "FULL";
            private _escapeDir = if (!isNull _instigator) then {
                (_dangerPos getDir (getPos _unit)) + (-30 + random 60)
            } else { random 360 };
            private _escapePos = (getPos _unit) getPos [200 + random 150, _escapeDir];
            private _grp = group _unit;
            while {count waypoints _grp > 0} do { deleteWaypoint [_grp, 0]; };
            private _wp = _grp addWaypoint [_escapePos, 0];
            _wp setWaypointType "MOVE";
            _wp setWaypointSpeed "FULL";
            _wp setWaypointBehaviour "CARELESS";

            // After a delay, exit the vehicle and transition to foot PANIC
            [{
                params ["_u", "_v"];
                if (alive _u && {vehicle _u == _v}) then {
                    doGetOut _u;
                    [{
                        params ["_u2"];
                        if (alive _u2) then {
                            _u2 setVariable ["ALiVE_advciv_vehicleEscaping", false, true];
                            _u2 setVariable ["ALiVE_advciv_state", "PANIC", true];
                            _u2 setVariable ["ALiVE_advciv_hidingPos", [], true];
                        };
                    }, [_u], 3] call CBA_fnc_waitAndExecute;
                } else {
                    if (alive _u) then {
                        _u setVariable ["ALiVE_advciv_vehicleEscaping", false, true];
                        _u setVariable ["ALiVE_advciv_state", "PANIC", true];
                    };
                };
            }, [_unit, _veh], 8 + random 8] call CBA_fnc_waitAndExecute;

        } else {
            // Passenger — bail out then play a hit react animation on foot
            if (alive _veh) then { doGetOut _unit; };

            [{
                params ["_u"];
                if (alive _u && {vehicle _u == _u}) then {
                    _u setVariable ["ALiVE_advciv_state", "HIT_REACT", true];
                    _u setVariable ["ALiVE_advciv_hitReacting", true, true];
                    _u setVariable ["ALiVE_advciv_hitReactStart", time];
                    [_u, "HIT"] call ALiVE_fnc_advciv_react;
                } else {
                    if (alive _u) then { _u setVariable ["ALiVE_advciv_state", "PANIC", true]; };
                };
            }, [_unit], 4] call CBA_fnc_waitAndExecute;
        };

    } else {
        // On foot — play hit reaction immediately
        _unit setVariable ["ALiVE_advciv_state", "HIT_REACT", true];
        _unit setVariable ["ALiVE_advciv_hitReacting", true, true];
        _unit setVariable ["ALiVE_advciv_hitReactStart", time];
        [_unit, "HIT"] call ALiVE_fnc_advciv_react;
    };
}];


// =========================================================================
// Deleted event handler — deregisters the unit from all AdvCiv tracking
// =========================================================================
_unit addEventHandler ["Deleted", {
    params ["_unit"];
    _unit setVariable ["ALiVE_advciv_active", false];
    _unit setVariable ["ALiVE_advciv_brainRunning", false];
    ALiVE_advciv_activeUnits = ALiVE_advciv_activeUnits - [_unit];
    // Clear any pending remote exec for this unit's order menu channel
    remoteExec ["", format ["ALiVE_advciv_menu%1", netId _unit]];
}];

// Register in the active units array, add the order menu, then start the brain loop
[_unit] call ALiVE_fnc_advciv_orderMenu;
[_unit] call ALiVE_fnc_advciv_brainLoop;

if (ALiVE_advciv_debug) then {
    ["ALiVE Advanced Civilians - initUnit complete: %1 | in array: %2", _unit, _unit in ALiVE_advciv_activeUnits] call ALIVE_fnc_dump;
};
