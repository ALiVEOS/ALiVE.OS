// NEO_fnc_casRearmService
// ------------------------------------------------------------------
// Rearm-by-landing cycle for a Combat Support aircraft, spawned by the
// cas.fsm RTB state (__2) the same way the attack states spawn
// NEO_fnc_casScriptedAttack. Runs alongside the FSM's own landing flow
// and covers the two things the FSM cannot do on its own:
//
//   1. LANDING WATCHDOG - the FSM waits for "on the ground within 20m of
//      the spawn position", which a landAt taxi rarely satisfies. If the
//      aircraft has not parked within the timeout, it is teleported onto
//      the airfield's taxi-in parking point (mil_ato's parking recipe:
//      damage-proofed move, engine off, settle) and flagged parked so the
//      FSM's at_base gate releases.
//
//   2. SERVICE WAIT - when the aircraft flew home because it was low on
//      ammo/fuel/damaged (ALIVE_resupply_needsService, set by the attack
//      loop's RTB hand-off), hold it parked while the resupply watchdog
//      dispatches a ground truck. If the truck cycle never completes,
//      FORCE-RECOVER: fully rearm/refuel/repair, teleport the aircraft
//      back into the air over the field and queue a loiter at its base so
//      it re-enters normal tasking. The asset is never left wedged.
//
// A player-ordered RTB (no service flag) only gets the landing watchdog.
// UAVs keep their own FSM handling (__6) and are excluded.
//
// Params: [_veh, _grp, _callsign, _airport, _base, _audio]
// Returns: nothing
//
// Author: Jman
// ------------------------------------------------------------------

params ["_veh", "_grp", "_callsign", "_airport", "_base", "_audio"];

if (isNull _veh || {!alive _veh}) exitWith {};
if (unitIsUAV _veh) exitWith {};
if (_veh getVariable ["NEO_casRearmCycleActive", false]) exitWith {};
_veh setVariable ["NEO_casRearmCycleActive", true];
_veh setVariable ["ALIVE_cas_parked", false];

private _needsService = _veh getVariable ["ALIVE_resupply_needsService", false];
private _isHeli = _veh isKindOf "Helicopter";

if (!isNil "ALiVE_sup_combatsupport_debug" && {ALiVE_sup_combatsupport_debug}) then { ["CAS-REARM: cycle start %1 needsService=%2 heli=%3 airport=%4", _callsign, _needsService, _isHeli, _airport] call ALiVE_fnc_dump; };

// a NEW player task (anything but the RTB itself) hands control back to the FSM
private _fnc_retasked = {
    private _ct = _veh getVariable ["NEO_radioCurrentTask", []];
    !(_ct isEqualTo []) && {(_ct param [0, ""]) != "RTB"}
};

// ---- Phase 1: landing watchdog --------------------------------------------
private _t0 = time;
private _parked = false;
while {alive _veh && {!_parked} && {!(call _fnc_retasked)} && {time - _t0 < 300}} do {
    if (((getPosATL _veh) select 2) < 1 && {(abs speed _veh) < 2}) then {
        _parked = true;
    } else {
        sleep 5;
    };
};

if (alive _veh && {!_parked} && {!(call _fnc_retasked)}) then {
    // stuck landing - teleport onto the airfield's taxi-in parking point
    private _park = getPosATL _veh;
    if (_airport isEqualType 0 && {_airport >= 0} && {_airport < 100}) then {
        private _taxi = [];
        if (_airport == 0) then {
            _taxi = getArray (configFile >> "CfgWorlds" >> worldName >> "ilsTaxiIn");
        } else {
            private _sec = configProperties [configFile >> "CfgWorlds" >> worldName >> "SecondaryAirports", "isClass _x", true];
            if (_airport - 1 < count _sec) then {
                _taxi = getArray ((_sec select (_airport - 1)) >> "ilsTaxiIn");
            };
        };
        if (count _taxi >= 2) then {
            _park = [_taxi select (count _taxi - 2), _taxi select (count _taxi - 1), 0];
        };
    };
    // don't drop onto another parked airframe
    private _try = 0;
    while {_try < 6 && {count ((_park nearEntities [["Air"], 15]) select {_x != _veh}) > 0}} do {
        _park = _park getPos [30, random 360];
        _park set [2, 0];
        _try = _try + 1;
    };
    _veh allowDamage false;
    _veh engineOn false;
    _veh setVelocity [0, 0, 0];
    _veh setPosATL [_park select 0, _park select 1, 0];
    _veh setVectorUp [0, 0, 1];
    _veh setVelocity [0, 0, 0];
    sleep 5;
    _veh allowDamage true;
    _parked = true;
    if (!isNil "ALiVE_sup_combatsupport_debug" && {ALiVE_sup_combatsupport_debug}) then { ["CAS-REARM: %1 stuck landing - teleported to parking at %2", _callsign, _park] call ALiVE_fnc_dump; };
};

if (_parked && {alive _veh}) then {
    _veh setVariable ["ALIVE_cas_parked", true];   // releases the FSM's at_base gate
};

// ---- Phase 2: hold for the resupply truck ---------------------------------
if (_parked && _needsService && {alive _veh} && {!(call _fnc_retasked)}) then {
    // the resupply watchdog reads ALIVE_resupply_needsService and dispatches a
    // truck once the aircraft is parked; service restores ammo 1 / fuel 0.5 / damage 0.
    // "Serviced" means the SERVICE COMPLETED (lastDispatch is stamped at completion,
    // incl. the max-retries force-service), or every resource genuinely reads healthy -
    // fuel and damage alone are NOT enough: a winchester RTB parks with plenty of fuel
    // and no damage but empty pylons, and must keep waiting for the truck.
    private _t1 = time;
    private _svcStart = serverTime;
    private _fnc_serviced = {
        if ((_veh getVariable ["ALIVE_resupply_lastDispatch", 0]) > _svcStart) exitWith { true };
        if (fuel _veh < 0.45 || {damage _veh > 0.1}) exitWith { false };
        // no ordnance type below 25% of capacity (mirrors the resupply watchdog's check)
        private _low = false;
        {
            private _current = _x select 1;
            private _max = _x select 2;
            if (_max > 0 && {(_current / _max) < 0.25}) exitWith { _low = true };
        } forEach (_veh call ALiVE_fnc_vehicleGetAmmo);
        !_low
    };
    while {alive _veh && {!(call _fnc_serviced)} && {!(call _fnc_retasked)} && {time - _t1 < 900}} do {
        sleep 10;
    };

    if (alive _veh && {!(call _fnc_retasked)}) then {
        if (call _fnc_serviced) then {
            _veh setVariable ["ALIVE_resupply_needsService", false, true];
            [[_veh, format ["%1 is rearmed, refuelled and ready for tasking. Out.", _callsign], "side"], "NEO_fnc_messageBroadcast", true, false] spawn BIS_fnc_MP;
            if (!isNil "ALiVE_sup_combatsupport_debug" && {ALiVE_sup_combatsupport_debug}) then { ["CAS-REARM: %1 serviced by ground crew (fuel=%2 damage=%3)", _callsign, fuel _veh, damage _veh] call ALiVE_fnc_dump; };
        } else {
            // service cycle wedged (truck lost / pool empty / pathing) - force-recover:
            // full restore, teleport airborne over the field, resume via a loiter at base
            if (!isNil "ALiVE_sup_combatsupport_debug" && {ALiVE_sup_combatsupport_debug}) then { ["CAS-REARM: %1 service cycle timed out - force recovery (fuel=%2 damage=%3)", _callsign, fuel _veh, damage _veh] call ALiVE_fnc_dump; };
            _veh setVariable ["ALIVE_resupply_needsService", false, true];
            _veh setVehicleAmmo 1;
            _veh setFuel 1;
            _veh setDamage 0;
            private _dir = if (_veh distance2D _base < 50) then { random 360 } else { _veh getDir _base };
            private _spd = if (_isHeli) then { 40 } else { 120 };
            _veh allowDamage false;
            _veh engineOn true;
            _veh setPosATL [(getPosATL _veh) select 0, (getPosATL _veh) select 1, 300];
            _veh setVectorDirAndUp [[sin _dir, cos _dir, 0], [0, 0, 1]];
            _veh setVelocity [(sin _dir) * _spd, (cos _dir) * _spd, 0];
            sleep 3;
            _veh allowDamage true;
            _veh setVariable ["NEO_radioCasNewTask", ["LOITER", _base, 500, 150, "", "", objNull], true];
            [[_veh, format ["%1 is airborne and available for tasking. Out.", _callsign], "side"], "NEO_fnc_messageBroadcast", true, false] spawn BIS_fnc_MP;
        };
    };
};

_veh setVariable ["NEO_casRearmCycleActive", false];
