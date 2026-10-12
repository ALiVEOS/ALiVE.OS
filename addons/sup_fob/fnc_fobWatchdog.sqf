#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobWatchdog);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fobWatchdog

Description:
The one server loop the FOBs run on, every 30 seconds. Each pass, for each FOB:
- looks at who is near it, virtual groups and soldiers on the ground alike;
- counts down its timers by the time that really passed (capped at 60 s, so a stall doesn't
  fire a deadline all at once);
- tells its side on the radio when the enemy comes within the Alert Radius;
- starts taking it for the enemy when enemy soldiers, and none of its own side, are inside the
  Capture Radius, and hands it over when the Capture Time runs out; any defender in the radius
  stops the count;
- asks the side's Military Logistics for a supply truck when it runs below the Resupply
  Threshold, at most every 10 minutes;
- loses it when its headquarters was destroyed and the Repair Time ran out unrepaired;
- saves if something changed.
While the module is paused (an empty server) it does nothing at all, so no timer runs out
overnight.

Timers are seconds left, never a clock time, so they carry across a save and a pause unchanged.
Each pass also gives back any FOB objective a commander has lost.

Parameters:
Object - The module, to start the loop
or
String "tick", Number - one pass now, as if that many seconds had passed (for tests)

Returns:
Nothing (start) or the number of FOBs ticked

Author:
Jman
---------------------------------------------------------------------------- */

if (isRemoteExecuted && {remoteExecutedOwner != 2} && {isNil "_ALiVE_fobCaller"}) exitWith {};
if (!isServer) exitWith {};

private _timers = ["repairRemaining", "captureRemaining", "alertCooldown", "resupplyCooldown"];
private _logic = missionNamespace getVariable ["ALiVE_sup_fob", objNull];
private _set = { [_logic, "attribute", [_this]] call ALiVE_fnc_FOB };

// Who is near a FOB: [enemy soldiers in the capture radius, by side; any of its own side in the
// capture radius; anyone hostile, players too, in the alert radius; an engineer of its side
// within 25 m]. Virtual groups are counted where the Virtual AI System has them; spawned
// soldiers by what's on the ground, so a spawned group isn't counted twice. Enemy players
// don't take a FOB (they still raise the alert); its own players defend it.
private _presence = {
    params ["_entry"];
    private _pos = [_entry, "pos", [0,0,0]] call ALIVE_fnc_hashGet;
    private _side = [_entry, "side", "WEST"] call ALIVE_fnc_hashGet;
    private _rCap = "fob_capture_radius" call _set;
    private _rAlert = ("fob_alert_radius" call _set) max _rCap;
    private _enemies = ([_side] call ALiVE_fnc_getSideAllegiances) param [0, []];
    private _taking = createHashMap;
    private _held = false;
    private _alert = false;
    if (!isNil "ALiVE_ProfileHandler") then {
        {
            if !([_x, "active", false] call ALIVE_fnc_hashGet) then {
                private _ps = [_x, "side", ""] call ALIVE_fnc_hashGet;
                private _d = ([_x, "position", [0,0,0]] call ALIVE_fnc_hashGet) distance2D _pos;
                if (_ps in _enemies) then {
                    if (_d <= _rAlert) then { _alert = true };
                    if (_d <= _rCap && {!([_x, "isPlayer", false] call ALIVE_fnc_hashGet)}) then { _taking set [_ps, (_taking getOrDefault [_ps, 0]) + 1] };
                };
                if (_ps == _side && {_d <= _rCap}) then { _held = true };
            };
        } forEach ([_pos, _rAlert, ["all", "entity"], true] call ALiVE_fnc_getNearProfiles);
    };
    private _engineer = false;
    {
        if (alive _x && {!captive _x} && {lifeState _x != "INCAPACITATED"}) then {
            private _us = str side group _x;
            private _d = _x distance2D _pos;
            if (_us in _enemies) then {
                _alert = true;
                if (_d <= _rCap && {!isPlayer _x}) then { _taking set [_us, (_taking getOrDefault [_us, 0]) + 1] };
            };
            if (_us == _side) then {
                if (_d <= _rCap) then { _held = true };
                if (_d <= 25 && {_x getUnitTrait "engineer"}) then { _engineer = true };
            };
        };
    } forEach (_pos nearEntities [["CAManBase"], _rAlert]);
    [_taking, _held, _alert, _engineer]
};

private _say = {
    params ["_side", "_text"];
    ["ALiVE Player FOBs - radio to %1: %2", _side, _text] call ALiVE_fnc_dump;
    [_side, [_logic, _text, "side", [_side] call ALiVE_fnc_sideTextToObject, false, true, false, true, "HQ"]] call ALIVE_fnc_radioBroadcastToSide;
};

private _tick = {
    params ["_dt"];
    {
        private _id = _x;
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry") then { continue };
        private _side = [_entry, "side", "WEST"] call ALIVE_fnc_hashGet;
        private _name = [_entry, "name", _id] call ALIVE_fnc_hashGet;
        ([_entry] call _presence) params ["_taking", "_held", "_alert", "_engineer"];
        [_entry, "engineerNear", _engineer] call ALIVE_fnc_hashSet;

        // Timers; a repair count stops while an engineer is at the FOB
        {
            private _left = [_entry, _x, 0] call ALIVE_fnc_hashGet;
            if (_left > 0 && {!(_x == "repairRemaining" && _engineer)}) then {
                [_entry, _x, (_left - _dt) max 0] call ALIVE_fnc_hashSet;
                ALiVE_FOB_dirty = true;
            };
        } forEach _timers;

        // Capture: enemy soldiers and none of its own in the capture radius
        private _capTime = "fob_capture_time" call _set;
        private _was = [_entry, "captureSide", ""] call ALIVE_fnc_hashGet;
        if (count _taking > 0 && {!_held}) then {
            // the side with the most men there takes it
            private _by = (keys _taking) apply { [_taking get _x, _x] };
            _by sort false;
            private _taker = (_by select 0) select 1;
            if (_was != _taker) then {
                [_entry, "captureSide", _taker] call ALIVE_fnc_hashSet;
                [_entry, "captureRemaining", _capTime] call ALIVE_fnc_hashSet;
                ALiVE_FOB_dirty = true;
                [_side, format ["%1 is being taken by the enemy. Get men back inside %2 m within %3 s.", _name, round ("fob_capture_radius" call _set), round _capTime]] call _say;
            } else {
                private _left = [_entry, "captureRemaining", 0] call ALIVE_fnc_hashGet;
                if (_left <= 0) then {
                    ["flip", [_id, _taker]] call ALiVE_fnc_fobOps;
                    continue;
                };
                if (_left < _capTime / 2) then { [_side, format ["%1 is about to fall: %2 s left.", _name, round _left]] call _say };
            };
        } else {
            if (_was != "") then {
                [_entry, "captureSide", ""] call ALIVE_fnc_hashSet;
                [_entry, "captureRemaining", 0] call ALIVE_fnc_hashSet;
                ALiVE_FOB_dirty = true;
            };
            // Alert: enemy near and not already said in the last two minutes
            if (_alert && {([_entry, "alertCooldown", 0] call ALIVE_fnc_hashGet) <= 0}) then {
                [_entry, "alertCooldown", 120] call ALIVE_fnc_hashSet;
                [_side, format ["%1 reports enemy movement nearby.", _name]] call _say;
            };
        };

        // A steady trickle of supply, when the module sets one (FOB supply mode only)
        private _trickle = "fob_supply_trickle" call _set;
        if (_trickle > 0 && {("fob_supply_source" call _set) == "FOBPOOL"} && {([_entry, "status", ""] call ALIVE_fnc_hashGet) == "active"}) then {
            ["credit", [_id, _trickle, "trickle"]] call ALiVE_fnc_fobSupply;
        };

        // Running low: ask the side's Military Logistics for a supply truck, at most every 10
        // minutes (FOB supply mode, active FOBs; a Resupply Threshold of 0 turns it off)
        private _threshold = "fob_resupply_threshold" call _set;
        if (_threshold > 0 && {("fob_supply_source" call _set) == "FOBPOOL"} && {([_entry, "status", ""] call ALIVE_fnc_hashGet) == "active"}
            && {([_entry, "resupplyCooldown", 0] call ALIVE_fnc_hashGet) <= 0}
            && {(["balance", [_id]] call ALiVE_fnc_fobSupply) < (["cap", [_id]] call ALiVE_fnc_fobSupply) * _threshold / 100}
            && {!isNil "ALIVE_eventLog"}
            // a Military Logistics module of this side that has its factions (it says it has
            // started a little before it has them, and a request before then sends nothing)
            && {(allMissionObjects "ALiVE_mil_logistics") findIf { ([_x, "side"] call ALiVE_fnc_ML) == _side && {([_x, "factions"] call ALiVE_fnc_ML) isNotEqualTo []} } > -1}) then {
            private _ev = ["LOGCOM_FOB_RESUPPLY", [[_entry, "pos", [0,0,0]] call ALIVE_fnc_hashGet, _side, "FOB", _name, _id], "SupFOB"] call ALIVE_fnc_event;
            [ALIVE_eventLog, "addEvent", _ev] call ALIVE_fnc_eventLog;
            [_entry, "resupplyCooldown", 600] call ALIVE_fnc_hashSet;
            ALiVE_FOB_dirty = true;
            ["ALiVE Player FOBs - %1 is low on supply; asked Military Logistics for a truck", _id] call ALiVE_fnc_dump;
        };

        // A destroyed headquarters: repaired in time, or the FOB is lost
        if (([_entry, "status", ""] call ALIVE_fnc_hashGet) == "damaged" && {([_entry, "repairRemaining", 0] call ALIVE_fnc_hashGet) <= 0}) then {
            [_side, format ["%1 couldn't be repaired in time and is lost.", _name]] call _say;
            ["salvage", [_id]] call ALiVE_fnc_fobOps;
            continue;
        };
        // Built objects that were destroyed or removed come off the list, with nothing back
        private _objects = [_entry, "objects", []] call ALIVE_fnc_hashGet;
        private _kept = _objects select {
            private _o = _x param [0, objNull];
            switch (true) do {
                // a static weapon lives as long as its gun's profile does
                case (_o isEqualTo "static"): { isNil "ALiVE_ProfileHandler" || {!isNil {[ALiVE_ProfileHandler, "getProfile", _x param [3, ""]] call ALIVE_fnc_profileHandler}} };
                case (!(_o isEqualType objNull)): { true };
                default { !isNull _o && {alive _o} && {damage _o < 1} };
            }
        };
        if (count _kept != count _objects) then {
            [_entry, "objects", _kept] call ALIVE_fnc_hashSet;
            ALiVE_FOB_dirty = true;
        };
        // A commander that reloaded its objectives has lost the FOB's; this puts it back
        ["reconcile", [_id]] call ALiVE_fnc_fobObjectives;
    } forEach +(ALiVE_FOB_registry select 1);
    count (ALiVE_FOB_registry select 1)
};

if ((_this param [0, objNull]) isEqualType "") exitWith {
    // A test asks for one pass, as the loop would make it
    private _logic = missionNamespace getVariable ["ALiVE_sup_fob", objNull];
    if (_logic getVariable ["pause", false]) exitWith {0};
    private _n = 0;
    isNil { _n = [_this param [1, 30]] call _tick };
    _n
};

params [["_logic", objNull, [objNull]]];
if (!isNil "ALiVE_FOB_watchdog") then { terminate ALiVE_FOB_watchdog };

ALiVE_FOB_watchdog = [_logic, _tick] spawn {
    params ["_logic", "_tick"];
    private _last = time;
    while { !isNull _logic } do {
        sleep 30;
        private _dt = ((time - _last) max 0) min 60;
        _last = time;
        if !(_logic getVariable ["pause", false]) then {
            // Unscheduled, so a pass is never cut in half by the scheduler
            isNil { [_dt] call _tick };
            if (ALiVE_FOB_dirty) then {
                [_logic, "broadcastMirror"] call ALiVE_fnc_FOB;
                ["save", [false]] call ALiVE_fnc_fobPersistence;
            };
        };
    };
};
