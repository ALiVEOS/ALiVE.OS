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
- notes which enemy sides have found it (Contact targeting), so their commanders get it as an
  objective, and at tier 2 or 3 reports the enemy groups it can see to its own side's
  intelligence;
- starts taking it for the enemy when enemy soldiers, and none of its own side, are inside the
  Capture Radius, and hands it over when the Capture Time runs out; any defender in the radius
  stops the count;
- asks the side's Military Logistics for a supply truck when it runs below the Resupply
  Threshold, at most every 10 minutes;
- keeps a garrison at a tier 2 or 3 FOB, paying for a new one when the last is gone, and puts a
  garrisoned tier 3 FOB on its side's Military Logistics supply network;
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
    private _rFind = "fob_discovery_radius" call _set;
    private _rAlert = ("fob_alert_radius" call _set) max _rCap;
    private _rLook = _rAlert max _rFind;
    private _seen = [];
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
                    if (_d <= _rFind) then { _seen pushBackUnique _ps };
                    if (_d <= _rCap && {!([_x, "isPlayer", false] call ALIVE_fnc_hashGet)}) then { _taking set [_ps, (_taking getOrDefault [_ps, 0]) + 1] };
                };
                if (_ps == _side && {_d <= _rCap}) then { _held = true };
            };
        } forEach ([_pos, _rLook, ["all", "entity"], true] call ALiVE_fnc_getNearProfiles);
    };
    private _engineer = false;
    {
        if (alive _x && {!captive _x} && {lifeState _x != "INCAPACITATED"}) then {
            private _us = str side group _x;
            private _d = _x distance2D _pos;
            if (_us in _enemies) then {
                if (_d <= _rAlert) then { _alert = true };
                if (_d <= _rFind) then { _seen pushBackUnique _us };
                if (_d <= _rCap && {!isPlayer _x}) then { _taking set [_us, (_taking getOrDefault [_us, 0]) + 1] };
            };
            if (_us == _side) then {
                if (_d <= _rCap) then { _held = true };
                if (_d <= 25 && {_x getUnitTrait "engineer"}) then { _engineer = true };
            };
        };
    } forEach (_pos nearEntities [["CAManBase"], _rLook]);
    [_taking, _held, _alert, _engineer, _seen]
};

private _say = {
    params ["_side", "_key", ["_fmt", []]];
    [_logic, "radio", [_side, _key, _fmt]] call ALiVE_fnc_FOB;
};

private _tick = {
    params ["_dt"];
    // the factions each side's commanders field, for static weapons and vehicles; sent on change
    ["factions"] call ALiVE_fnc_fobBuildScan;
    {
        private _id = _x;
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry") then { continue };
        private _side = [_entry, "side", "WEST"] call ALIVE_fnc_hashGet;
        private _name = [_entry, "name", _id] call ALIVE_fnc_hashGet;
        ([_entry] call _presence) params ["_taking", "_held", "_alert", "_engineer", "_seen"];
        // Contact targeting: an enemy side that came within the Discovery Radius has found the FOB
        if (("fob_enemy_targeting" call _set) == "CONTACT") then {
            private _found = [_entry, "discoveredBy", []] call ALIVE_fnc_hashGet;
            { if !(_x in _found) then { _found pushBack _x; ALiVE_FOB_dirty = true } } forEach _seen;
        };
        // A tier 2 or 3 FOB reports the enemy groups it can see, out to its Alert Radius times its
        // tier, to its side's commanders' intelligence
        private _tier = [_entry, "tier", 1] call ALIVE_fnc_hashGet;
        if (_tier >= 2 && {!isNil "ALiVE_ProfileHandler"} && {([_entry, "status", ""] call ALIVE_fnc_hashGet) == "active"}) then {
            private _enemySides = ([_side] call ALiVE_fnc_getSideAllegiances) param [0, []];
            private _spotted = (([[_entry, "pos", [0,0,0]] call ALIVE_fnc_hashGet, ("fob_alert_radius" call _set) * _tier, ["all", "entity"], true] call ALiVE_fnc_getNearProfiles)
                select { ([_x, "side", ""] call ALIVE_fnc_hashGet) in _enemySides }) apply { [_x, "profileID", ""] call ALIVE_fnc_hashGet };
            if (_spotted isNotEqualTo []) then {
                { if (([_x, "side", ""] call ALiVE_fnc_HashGet) == _side) then { [_x, "createSpotrepForProfiles", _spotted] call ALiVE_fnc_OPCOM } } forEach (missionNamespace getVariable ["OPCOM_instances", []]);
            };
        };
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
                [_side, "STR_ALIVE_FOB_RADIO_TAKING", [_name, round ("fob_capture_radius" call _set), round _capTime]] call _say;
            } else {
                private _left = [_entry, "captureRemaining", 0] call ALIVE_fnc_hashGet;
                if (_left <= 0) then {
                    ["flip", [_id, _taker]] call ALiVE_fnc_fobOps;
                    continue;
                };
                if (_left < _capTime / 2) then { [_side, "STR_ALIVE_FOB_RADIO_FALLING", [_name, round _left]] call _say };
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
                [_side, "STR_ALIVE_FOB_RADIO_CONTACT", [_name]] call _say;
            };
        };

        // A steady trickle of supply, Supply Per Minute, when the module sets one (FOB supply mode only)
        private _trickle = if (("fob_supply_source" call _set) == "FOBPOOL") then { [_logic, "typeAttribute", [[_entry, "type", ""] call ALIVE_fnc_hashGet, "fob_supply_trickle"]] call ALiVE_fnc_FOB } else { 0 };
        if (_trickle > 0 && {("fob_supply_source" call _set) == "FOBPOOL"} && {([_entry, "status", ""] call ALIVE_fnc_hashGet) == "active"}) then {
            // Supply Per Minute, for the time this pass covers
            ["credit", [_id, _trickle * _dt / 60, "trickle"]] call ALiVE_fnc_fobSupply;
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
            // told once until a truck gets there, not every 10 minutes while none comes
            if !([_entry, "lowTold", false] call ALIVE_fnc_hashGet) then {
                [_entry, "lowTold", true] call ALIVE_fnc_hashSet;
                [_side, "STR_ALIVE_FOB_RADIO_LOW", [_name, round (["balance", [_id]] call ALiVE_fnc_fobSupply)]] call _say;
            };
        };

        // A tier 2 or 3 FOB keeps a garrison: a new one, paid for, when the last one is gone
        private _active = ([_entry, "status", ""] call ALIVE_fnc_hashGet) == "active";
        private _garrisoned = ["garrisonAlive", [_id]] call ALiVE_fnc_fobOps;
        if (_active && {_tier >= 2} && {!_garrisoned} && {!isNil "ALiVE_ProfileHandler"} && {time >= ([_entry, "garrisonNext", 0] call ALIVE_fnc_hashGet)}) then {
            _garrisoned = ["garrison", [_id, false]] call ALiVE_fnc_fobOps;
        };

        // A garrisoned tier 3 FOB is a place its side's Military Logistics sends supplies from
        if (!isNil "ALIVE_ML_supplyNetwork") then {
            private _pos = [_entry, "pos", [0,0,0]] call ALIVE_fnc_hashGet;
            private _faction = [_entry, "faction", ""] call ALIVE_fnc_hashGet;
            private _want = _active && {_tier >= 3} && {_garrisoned} && {_faction != ""};
            {
                private _fac = _x;
                private _nodes = [ALIVE_ML_supplyNetwork, _fac, []] call ALIVE_fnc_hashGet;
                private _i = _nodes findIf { ((_x select 0) distance2D _pos) < 1 && {!(_x param [2, false])} };
                if (_i > -1 && {!_want || {_fac != _faction}}) then { _nodes deleteAt _i };
            } forEach (ALIVE_ML_supplyNetwork select 1);
            if (_want) then {
                private _nodes = [ALIVE_ML_supplyNetwork, _faction, []] call ALIVE_fnc_hashGet;
                private _i = _nodes findIf { ((_x select 0) distance2D _pos) < 1 && {!(_x param [2, false])} };
                private _node = [_pos, +([_entry, "garrison", []] call ALIVE_fnc_hashGet), false];
                if (_i > -1) then { _nodes set [_i, _node] } else { _nodes pushBack _node };
                [ALIVE_ML_supplyNetwork, _faction, _nodes] call ALIVE_fnc_hashSet;
            };
        };

        // A destroyed headquarters: repaired in time, or the FOB is lost
        if (([_entry, "status", ""] call ALIVE_fnc_hashGet) == "damaged" && {([_entry, "repairRemaining", 0] call ALIVE_fnc_hashGet) <= 0}) then {
            [_side, "STR_ALIVE_FOB_RADIO_LOST_REPAIR", [_name]] call _say;
            ["salvage", [_id]] call ALiVE_fnc_fobOps;
            continue;
        };
        // Built objects that were destroyed or removed come off the list, with nothing back
        private _objects = [_entry, "objects", []] call ALIVE_fnc_hashGet;
        private _kept = _objects select {
            private _o = _x param [0, objNull];
            switch (true) do {
                // a static weapon lives as long as its gun's profile does
                // one waiting to be made again on the next start has no profile id yet
                case (_o in ["static", "vehicle"]): { (_x param [3, ""]) == "" || {isNil "ALiVE_ProfileHandler"} || {!isNil {[ALiVE_ProfileHandler, "getProfile", _x param [3, ""]] call ALIVE_fnc_profileHandler}} };
                case (!(_o isEqualType objNull)): { true };
                default { !isNull _o && {alive _o} && {damage _o < 1} };
            }
        };
        if (count _kept != count _objects) then {
            [_entry, "objects", _kept] call ALIVE_fnc_hashSet;
            ALiVE_FOB_dirty = true;
        };
        // Raised troops: a row whose men are all dead comes off, freeing its place; one still
        // waiting to be made (no Virtual AI System when the save was loaded) is made now, free
        if (!isNil "ALiVE_ProfileHandler") then {
            if ([_entry, "troopsPending", false] call ALIVE_fnc_hashGet) then { ["restoreTroops", [_id]] call ALiVE_fnc_fobOps };
            private _troops = [_entry, "troops", []] call ALIVE_fnc_hashGet;
            if (_troops isEqualType [] && {_troops isNotEqualTo []}) then {
                {
                    if ((_x param [3, []]) isEqualTo [] && {_active}) then {
                        (["spawnTroops", [_id, _x select 0, _x param [7, ""], _x param [4, ""], _x param [5, ""]]] call ALiVE_fnc_fobOps) params ["_newIds", "_newMen"];
                        if (_newIds isNotEqualTo []) then { _x set [3, _newIds]; _x set [6, _newMen] } else {
                            // can't be made (its mod isn't loaded now): dropped, not tried again every pass
                            ["ALiVE Player FOBs - %1: raised %2 can't be made again, so it's dropped", _id, _x select 1] call ALiVE_fnc_dumpR;
                            _x set [3, ["-"]];
                        };
                        ALiVE_FOB_dirty = true;
                    };
                } forEach _troops;
                // a row stays while any of its men is left, or while it waits to be made (a damaged FOB's)
                private _left = _troops select {
                    private _ids = _x param [3, []];
                    _ids isEqualTo [] || {(_ids findIf { !isNil {[ALiVE_ProfileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler} }) > -1}
                };
                if (count _left != count _troops) then {
                    [_entry, "troops", _left] call ALIVE_fnc_hashSet;
                    ALiVE_FOB_dirty = true;
                    [_logic, "broadcastMirror"] call ALiVE_fnc_FOB;
                };
            };
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

// The loop calls this function for each pass rather than running _tick itself: a spawned script
// sees none of this function's local helpers (_set, _presence, _say), so a pass has to be made
// inside a fresh call of the function, where they exist.
ALiVE_FOB_watchdog = [_logic] spawn {
    params ["_logic"];
    private _last = time;
    while { !isNull _logic } do {
        sleep 30;
        private _dt = ((time - _last) max 0) min 60;
        _last = time;
        if !(_logic getVariable ["pause", false]) then {
            // one pass, unscheduled inside, so it is never cut in half by the scheduler
            ["tick", _dt] call ALiVE_fnc_fobWatchdog;
            // the FOB limit moves with the ground a side holds
            [_logic, "broadcastRoom"] call ALiVE_fnc_FOB;
            if (ALiVE_FOB_dirty) then {
                [_logic, "broadcastMirror"] call ALiVE_fnc_FOB;
                ["save", [false]] call ALiVE_fnc_fobPersistence;
            };
        };
    };
};
