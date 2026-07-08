#include "\x\alive\addons\sup_combatsupport\script_component.hpp"
SCRIPT(resupplyWatchdog);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_resupplyWatchdog
Description:
    Monitors support assets with Military Logistics Simulation enabled and
    dispatches LOGCOM resupply requests when ammo, fuel, or damage thresholds
    are reached.

    Scans the NEO_radio per-side asset arrays on every tick rather than using
    a static registry, so newly-respawned assets are picked up automatically
    and dead-asset references are pruned by the live side-array reads.

    Runs server-side as a spawned loop started by fnc_combatSupport after all
    support assets are registered.

Parameters:
    None (reads NEO_radioLogic arrays live each tick).

Returns:
    Nothing (runs indefinitely)

Author:
    Goldwep
---------------------------------------------------------------------------- */

// Watchdog constants.
#define WATCHDOG_INTERVAL 30
#define AMMO_LOW_THRESHOLD 0.25
#define FUEL_THRESHOLD 0.15
#define DAMAGE_THRESHOLD 0.5
#define COOLDOWN_SECONDS 600
#define MAX_CONCURRENT_DISPATCHES 3

if (!isServer) exitWith {};

["ALIVE Resupply Watchdog started - scanning NEO_radio arrays each cycle"] call ALiVE_fnc_dump;

private _sides = [WEST, EAST, RESISTANCE, CIVILIAN];

while {true} do {

    // Build this tick's live asset list by walking each side's NEO_radio arrays and
    // deduping by vehicle object reference. Side-sharing copies each asset into every
    // friendly side's array, so a single physical vehicle can appear multiple times.
    private _seen = [];
    private _assets = [];   // [_veh, _type, _side, _callsign]

    {
        private _sideCheck = _x;

        {
            private _veh = _x select 0;
            private _callsign = _x select 2;
            if (!isNull _veh && {alive _veh} && {!(_veh in _seen)}) then {
                _seen pushBack _veh;
                _assets pushBack [_veh, "TRANSPORT", _sideCheck, _callsign];
            };
        } forEach (NEO_radioLogic getVariable [format ["NEO_radioTrasportArray_%1", _sideCheck], []]);

        {
            private _veh = _x select 0;
            private _callsign = _x select 2;
            if (!isNull _veh && {alive _veh} && {!(_veh in _seen)}) then {
                _seen pushBack _veh;
                _assets pushBack [_veh, "CAS", _sideCheck, _callsign];
            };
        } forEach (NEO_radioLogic getVariable [format ["NEO_radioCasArray_%1", _sideCheck], []]);

        {
            private _veh = _x select 0;
            private _callsign = _x select 2;
            if (!isNull _veh && {alive _veh} && {!(_veh in _seen)}) then {
                _seen pushBack _veh;
                _assets pushBack [_veh, "ARTY", _sideCheck, _callsign];
            };
        } forEach (NEO_radioLogic getVariable [format ["NEO_radioArtyArray_%1", _sideCheck], []]);

    } forEach _sides;

    // Iterate the live set and check thresholds.
    {
        private _veh = _x select 0;
        private _type = _x select 1;
        private _side = _x select 2;
        private _callsign = _x select 3;

        // Skip if logistics isn't enabled on this asset (opt-in via the module attribute).
        if (!(_veh getVariable ["ALIVE_logistics_enabled", false])) then { continue };

        // For artillery _veh is leader _grp (soldier). The tank is referenced via
        // ALIVE_resupply_primaryVehicle. For Transport/CAS _veh is already the vehicle.
        // _primaryVeh is the single source of truth for resupply state because LOGCOM
        // writes inProgress/lastDispatch back to it on completion.
        private _primaryVeh = _veh getVariable ["ALIVE_resupply_primaryVehicle", _veh];

        // Guard: primary vehicle died (e.g. tank destroyed but leader soldier still alive).
        if (isNull _primaryVeh || {!alive _primaryVeh}) then { continue };

        // Guard: skip if resupply already in progress.
        if (_primaryVeh getVariable ["ALIVE_resupply_inProgress", false]) then { continue };

        // Guard: skip if cooldown not expired. _lastDispatch is 0 before the first
        // dispatch, so only enforce the cooldown once one has actually happened.
        private _lastDispatch = _primaryVeh getVariable ["ALIVE_resupply_lastDispatch", 0];
        if (_lastDispatch > 0 && {serverTime - _lastDispatch < COOLDOWN_SECONDS}) then { continue };

        // --- Threshold checks ---

        // Ammo trigger: any ordnance type below AMMO_LOW_THRESHOLD (25%) of its original capacity.
        // The 25% margin gives the supply truck/heli travel time to arrive before the asset is
        // fully dry, rather than dispatching after the battery is already useless.
        private _needsAmmo = false;

        if (_type == "ARTY") then {
            // Artillery has two depletion signals and we watch BOTH:
            //   (1) NEO_radioArtyBatteryRounds - tracked by alivearty.fsm for player fire missions.
            //       The FSM REMOVES a type from the array once its count hits 0 (not zero it),
            //       so a full depletion shows up as count dropping below the defaults snapshot.
            //   (2) Real vehicle magazines on each battery tank - catches mods (CBA arty control,
            //       AI CAS, etc.) firing the gun outside NEO_radio accounting so ordnance can be
            //       gone even when the tracked array still shows full rounds.
            private _batteryRounds = _veh getVariable ["NEO_radioArtyBatteryRounds", []];
            private _defaultRounds = _veh getVariable ["ALIVE_resupply_defaultRounds", _batteryRounds];

            // Check (1a): FSM has removed one of the tracked types (full depletion). alivearty.fsm
            // only ever deletes entries - it never adds - so count dropping below the defaults
            // snapshot means an ordnance type ran out and got pruned from the array.
            if (count _batteryRounds < count _defaultRounds) then { _needsAmmo = true };

            // Check (1b): any surviving type below 25% of its original count?
            if (!_needsAmmo) then {
                {
                    private _typeName = _x select 0;
                    private _currentCount = _x select 1;
                    private _defaultForType = 0;
                    {
                        if ((_x select 0) == _typeName) exitWith { _defaultForType = _x select 1 };
                    } forEach _defaultRounds;
                    if (_defaultForType > 0 && {(_currentCount / _defaultForType) < AMMO_LOW_THRESHOLD}) exitWith {
                        _needsAmmo = true;
                    };
                } forEach _batteryRounds;
            };

            // Check (2): any real vehicle magazine below 25% on any tank in the battery?
            // vehicleGetAmmo returns [magazine, currentCount, maxCount] entries.
            if (!_needsAmmo) then {
                {
                    private _v = vehicle _x;
                    if (_v != _x) then {
                        {
                            private _current = _x select 1;
                            private _max = _x select 2;
                            if (_max > 0 && {(_current / _max) < AMMO_LOW_THRESHOLD}) exitWith {
                                _needsAmmo = true;
                            };
                        } forEach (_v call ALiVE_fnc_vehicleGetAmmo);
                    };
                    if (_needsAmmo) exitWith {};
                } forEach (units (group _veh));
            };
        } else {
            // Transport/CAS: any real vehicle magazine below 25% on the heli/jet.
            private _ammoArray = _primaryVeh call ALiVE_fnc_vehicleGetAmmo;
            {
                private _current = _x select 1;
                private _max = _x select 2;
                if (_max > 0 && {(_current / _max) < AMMO_LOW_THRESHOLD}) exitWith { _needsAmmo = true };
            } forEach _ammoArray;
        };

        // Fuel and damage: read off the primary vehicle (the tank / heli / jet), not the
        // leader soldier - soldier fuel is always 1 and soldier damage is body hp.
        private _needsFuel = fuel _primaryVeh < FUEL_THRESHOLD;
        private _needsRepair = damage _primaryVeh > DAMAGE_THRESHOLD && {damage _primaryVeh < 1};

        // RTB hand-off flag from the CAS attack loop: the aircraft flew home specifically to be
        // serviced, so treat it as a dispatch trigger even when no numeric threshold is tripped
        // (the RTB fuel trigger fires at <0.2 while the fuel threshold here is <0.15).
        if (!_needsAmmo && {!_needsFuel} && {!_needsRepair} && {_primaryVeh getVariable ["ALIVE_resupply_needsService", false]}) then {
            _needsAmmo = true;
        };

        // No thresholds hit — skip.
        if (!_needsAmmo && {!_needsFuel} && {!_needsRepair}) then { continue };

        // Guard: skip if in active combat (enemy within 500m of the primary vehicle).
        private _nearestEnemy = _primaryVeh findNearestEnemy _primaryVeh;
        if (!isNull _nearestEnemy && {_primaryVeh distance _nearestEnemy < 500}) then { continue };

        // Guard: for air assets only dispatch once the aircraft is on the ground.
        // Log once when we start waiting, not every tick.
        if (_primaryVeh isKindOf "Air") then {
            private _agl = (getPosATL _primaryVeh) select 2;
            if (_agl > 3 || {!(isTouchingGround _primaryVeh)}) then {
                if (!(_primaryVeh getVariable ["ALIVE_resupply_waitingRTB", false])) then {
                    _primaryVeh setVariable ["ALIVE_resupply_waitingRTB", true, true];
                    ["ALIVE Resupply Watchdog: %1 (%2) needs resupply - waiting for RTB",
                        _callsign, _type] call ALiVE_fnc_dump;
                };
                continue
            };
            _primaryVeh setVariable ["ALIVE_resupply_waitingRTB", false, true];
        };

        // Guard: concurrent dispatch limit.
        private _activeDispatches = missionNamespace getVariable ["ALIVE_resupply_activeCount", 0];
        if (_activeDispatches >= MAX_CONCURRENT_DISPATCHES) then { continue };

        // --- Dispatch resupply ---
        // State lives on the primary vehicle (single source of truth). Mirror the user-visible
        // state string onto the leader so the sitrep/tablet read on the arty leader is in sync.
        _primaryVeh setVariable ["ALIVE_resupply_inProgress", true, true];
        _primaryVeh setVariable ["ALIVE_resupply_state", "dispatched", true];
        if (_veh != _primaryVeh) then {
            _veh setVariable ["ALIVE_resupply_state", "dispatched", true];
        };
        missionNamespace setVariable ["ALIVE_resupply_activeCount", _activeDispatches + 1, true];

        private _needs = [_needsAmmo, _needsFuel, _needsRepair];
        private _sideText = str _side;
        private _source = _veh getVariable ["ALIVE_logistics_source", 0];

        // Pass the primary vehicle position/object to LOGCOM so the truck drives to the actual tank,
        // not to the soldier leader standing somewhere else.
        private _eventData = [getPos _primaryVeh, _sideText, _type, _callsign, _source, _needs, _primaryVeh];
        private _event = ['LOGCOM_RESUPPLY', _eventData, "CombatSupport"] call ALIVE_fnc_event;
        [ALIVE_eventLog, "addEvent", _event] call ALIVE_fnc_eventLog;

        [
            "ALIVE Resupply Watchdog: Dispatching for %1 (%2) | Ammo: %3, Fuel: %4, Repair: %5",
            _callsign, _type, _needsAmmo, _needsFuel, _needsRepair
        ] call ALiVE_fnc_dump;

    } forEach _assets;

    sleep WATCHDOG_INTERVAL;
};
