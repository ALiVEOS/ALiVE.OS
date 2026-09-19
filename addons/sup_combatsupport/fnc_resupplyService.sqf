#include "\x\alive\addons\sup_combatsupport\script_component.hpp"
SCRIPT(resupplyService);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_resupplyService
Description:
    Performs rearm, refuel, and repair on a support asset. Called by the
    delivery monitor when a resupply vehicle arrives within range, or as
    a force-service fallback when delivery fails.

    For Transport/CAS the passed object is the actual vehicle and we service
    it directly. For Artillery the passed object is either the leader soldier
    (when called via watchdog dispatch) or a tank (when called via the LOGCOM
    handler which receives the primary vehicle). Either way we resolve to the
    whole battery (all vehicles sharing the leader's group) and reset the
    NEO_radioArtyBatteryRounds on the leader so the FSM can queue fire
    missions again.

Parameters:
    _this select 0: OBJECT - Support asset vehicle OR artillery leader

Returns:
    Nothing

Author:
    Goldwep
    Jman
---------------------------------------------------------------------------- */

params ["_veh"];

if (isNull _veh || {!alive _veh}) exitWith {
    ["ALIVE Resupply Service: Target is null or destroyed"] call ALiVE_fnc_dump;
};

// Resolve to the group leader. For artillery, the leader carries the
// NEO_radioArtyBatteryRounds hash the radio UI reads off, regardless of
// whether we were called with a tank (LOGCOM dispatch flow) or with the
// leader itself (force-service fallback). For Transport/CAS the "leader"
// is just the heli/jet's own crew chief and won't have battery rounds.
private _leader = leader (group _veh);
private _batteryRounds = _leader getVariable ["NEO_radioArtyBatteryRounds", nil];
private _isArty = !(isNil "_batteryRounds");

if (_isArty) then {
    // Artillery battery: walk the leader's group and service every vehicle in it.
    private _batteryVehicles = [];
    {
        private _v = vehicle _x;
        if (_v != _x && {!(_v in _batteryVehicles)}) then { _batteryVehicles pushBack _v };
    } forEach (units (group _leader));

    // Topped up to half a tank, never drained to it, the same as below.
    {
        _x setVehicleAmmo 1;
        _x setFuel ((fuel _x) max 0.5);
        _x setDamage 0;
    } forEach _batteryVehicles;

    // Reset the rounds array the radio UI and FSM read, so the tablet
    // stops showing "no HE / no SMOKE" and fire missions can queue again.
    private _defaultRounds = _leader getVariable ["ALIVE_resupply_defaultRounds", []];
    if (count _defaultRounds > 0) then {
        _leader setVariable ["NEO_radioArtyBatteryRounds", +_defaultRounds, true];
    };

    ["ALIVE Resupply Service: ARTY battery serviced (leader %1, %2 tanks, %3 ordnance types restored)",
        _leader, count _batteryVehicles, count _defaultRounds] call ALiVE_fnc_dump;
} else {
    // Transport or CAS: _veh IS the vehicle.
    _veh setVehicleAmmo 1;
    // Topped up to half a tank, never drained to it. Setting 0.5 outright took
    // an aircraft that came back with 0.97 and sent it out on its next sortie
    // with 0.50.
    //
    // An aircraft the air tasking module is holding on its stand for a launch
    // has its tank kept empty, so its crew cannot drive it out while it waits,
    // and what the tank held is kept aside and given back when it goes. The
    // fuel goes there instead: put in the tank, a crewed plane waiting for the
    // runway rolls out of its hangar.
    private _atoHeld = _veh getVariable ["ALiVE_mil_ato_heldFuel", -1];
    private _held = (_atoHeld isEqualType 0) && {_atoHeld >= 0};
    if (_held) then {
        _veh setVariable ["ALiVE_mil_ato_heldFuel", _atoHeld max 0.5, true];
    } else {
        _veh setFuel ((fuel _veh) max 0.5);
    };
    _veh setDamage 0;
    _veh setVariable ["ALIVE_resupply_needsService", false, true];
    ["ALIVE Resupply Service: Vehicle %1 serviced (ammo, fuel %2, damage 0)", _veh,
        if (_held) then { format ["%1, kept for its launch", (_veh getVariable ["ALiVE_mil_ato_heldFuel", 0]) toFixed 2] } else { (fuel _veh) toFixed 2 }] call ALiVE_fnc_dump;
};
