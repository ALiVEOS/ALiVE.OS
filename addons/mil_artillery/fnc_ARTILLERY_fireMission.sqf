#include "\x\alive\addons\mil_artillery\script_component.hpp"
SCRIPT(ARTILLERY_fireMission);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_MilArtilleryFireMission

Description:
Executes one AI fire mission. Force-spawns the battery and the target with
preventDespawn, waits for the guns to be crewed, resolves the magazine,
checks range and friendlies at the impact area, fires a ranging round then
the main volley with extra dispersion, and releases everything afterwards.
Every abort path releases the profiles and stamps a cooldown so a broken
battery can never wedge the system. Spawned, not called.

Parameters:
Object - module logic
Hash - battery registry record
String - target profile ID
Array - target position (as known at request time)

Returns:
Nil

Author:
Jman
---------------------------------------------------------------------------- */

params ["_logic","_record","_targetID","_targetPos",["_force", false, [false]]];

// _force = a debug/test strike: skip the friendly-fire abort so the strike is
// always observable (the caller accepts firing near friendlies)
private _debug = [_logic, "debug"] call ALIVE_fnc_MilArtillery;
private _settings = _logic getVariable ["intensityProfile", [420,120,75,6,3,1,90]];
_settings params ["_cooldownBase","_cooldownJitter","_dispersion","_roundsPerMission","_minContacts","_maxConcurrent","_ledgerSize"];

private _entityID = [_record,"entityID"] call ALiVE_fnc_hashGet;
private _vehicleIDs = [_record,"vehicleIDs"] call ALiVE_fnc_hashGet;
private _sideText = [_record,"side"] call ALiVE_fnc_hashGet;
private _released = false;

// every profile this mission holds is recorded with the spawnType it had
// before, so release restores holds owned by other systems (e.g. an air
// component preventDespawn on the same target) instead of clobbering them
private _priorHolds = [];

private _fnc_hold = {
    params ["_p","_pid","_pkind"];
    private _prior = [_p,"spawnType",[]] call ALiVE_fnc_hashGet;
    _priorHolds pushBack [_pid, _pkind, +_prior];
    if (_pkind == "vehicle") then {
        [_p,"spawnType",["preventDespawn"]] call ALiVE_fnc_profileVehicle;
    } else {
        [_p,"spawnType",["preventDespawn"]] call ALiVE_fnc_profileEntity;
    };
};

// single release point - every exit runs through here exactly once
private _fnc_release = {
    params ["_cooldownFactor"];
    if (_released) exitWith {};
    _released = true;

    {
        _x params ["_pid","_pkind","_prior"];
        private _p = [ALIVE_profileHandler, "getProfile", _pid] call ALIVE_fnc_profileHandler;
        if (!isNil "_p") then {
            if (_pkind == "vehicle") then {
                [_p,"spawnType",_prior] call ALiVE_fnc_profileVehicle;
            } else {
                [_p,"spawnType",_prior] call ALiVE_fnc_profileEntity;
            };
        };
    } forEach _priorHolds;

    if (([_record,"rounds"] call ALiVE_fnc_hashGet) <= 0) then {
        [_record,"state","DRY"] call ALiVE_fnc_hashSet;
        if (_debug) then {
            ["ALiVE MIL_ARTILLERY - battery %1 is out of ammunition and falls silent", _entityID] call ALiVE_fnc_dump;
        };
    } else {
        [_record,"state","IDLE"] call ALiVE_fnc_hashSet;
    };
    [_record,"cooldownUntil", time + (_cooldownBase * _cooldownFactor) + random _cooldownJitter] call ALiVE_fnc_hashSet;

    _logic setVariable ["activeMissions", ((_logic getVariable ["activeMissions", 1]) - 1) max 0];
};

if (_debug) then {
    ["ALiVE MIL_ARTILLERY - fire mission: battery %1 (%2 gun(s)) -> %3", _entityID, count _vehicleIDs, _targetPos] call ALiVE_fnc_dump;
};

// activate battery and target - the same preventDespawn pattern the air
// component uses, so the profile system keeps both ends physical until release
private _entityProfile = [ALIVE_profileHandler, "getProfile", _entityID] call ALIVE_fnc_profileHandler;
if (isNil "_entityProfile") exitWith { [1] call _fnc_release; };

[_entityProfile, _entityID, "entity"] call _fnc_hold;
{
    private _vp = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
    if (!isNil "_vp") then {
        [_vp, _x, "vehicle"] call _fnc_hold;
    };
} forEach _vehicleIDs;

if !([_entityProfile,"active"] call ALiVE_fnc_hashGet) then {
    [_entityProfile,"spawn"] call ALiVE_fnc_profileEntity;
};

// _targetID "" = a position-only strike (the debug force-fire path passes no
// target profile); fire at _targetPos without spawning anything at that end
if (_targetID != "") then {
    private _targetProfile = [ALIVE_profileHandler, "getProfile", _targetID] call ALIVE_fnc_profileHandler;
    if (!isNil "_targetProfile") then {
        private _tType = [_targetProfile,"type",""] call ALiVE_fnc_hashGet;
        if (_tType == "vehicle") then {
            [_targetProfile, _targetID, "vehicle"] call _fnc_hold;
            if !([_targetProfile,"active"] call ALiVE_fnc_hashGet) then {
                [_targetProfile,"spawn"] call ALiVE_fnc_profileVehicle;
            };
        } else {
            [_targetProfile, _targetID, "entity"] call _fnc_hold;
            if !([_targetProfile,"active"] call ALiVE_fnc_hashGet) then {
                [_targetProfile,"spawn"] call ALiVE_fnc_profileEntity;
            };
        };
    };
};

// wait for physical, crewed guns - spawn latency doubles as the realistic
// call-for-fire delay
private _guns = [];
private _deadline = time + 90;
waitUntil {
    sleep 5;
    _guns = [];
    {
        private _vp = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
        if (!isNil "_vp") then {
            private _veh = [_vp,"vehicle"] call ALiVE_fnc_hashGet;
            if (!isNil "_veh" && {!isNull _veh} && {alive _veh} && {count crew _veh > 0}) then {
                _guns pushBack _veh;
            };
        };
    } forEach _vehicleIDs;
    (count _guns > 0) || {time > _deadline}
};

if (count _guns == 0) exitWith {
    if (_debug) then {
        ["ALiVE MIL_ARTILLERY - fire mission aborted: battery %1 never produced a crewed gun", _entityID] call ALiVE_fnc_dump;
    };
    [0.5] call _fnc_release;
};

// resolve the magazine - HE first, then whatever the gun actually carries
private _gunLead = _guns select 0;
private _mag = [_gunLead, "HE"] call ALIVE_fnc_getArtyMagazineType;
if (_mag == "") then {
    private _types = (typeOf _gunLead) call ALiVE_fnc_GetArtyRounds;
    if (count _types > 0) then {
        _mag = [_gunLead, _types select 0] call ALIVE_fnc_getArtyMagazineType;
    };
};
if (_mag == "") exitWith {
    ["ALiVE MIL_ARTILLERY - fire mission aborted: no usable ordnance found for %1 - battery stood down", typeOf _gunLead] call ALiVE_fnc_dump;
    [1] call _fnc_release;
};

private _aimBase = [_targetPos select 0, _targetPos select 1, 0];

// real range check now a crewed gun exists; refine the coarse default so the
// next battery pick knows this battery's true reach
if !(_aimBase inRangeOfArtillery [_guns, _mag]) exitWith {
    private _dist = _gunLead distance2D _aimBase;
    private _maxRange = [_record,"maxRange"] call ALiVE_fnc_hashGet;
    if (_dist > _maxRange * 0.5) then {
        [_record,"maxRange", ((_dist * 0.9) max 1500)] call ALiVE_fnc_hashSet;
    };
    if (_debug) then {
        ["ALiVE MIL_ARTILLERY - fire mission aborted: target out of range for %1 at %2m (range default revised)", typeOf _gunLead, round _dist] call ALiVE_fnc_dump;
    };
    [0.5] call _fnc_release;
};

// friendly-fire check on the impact area (skipped on a forced debug strike)
private _sideObject = [_sideText] call ALIVE_fnc_sideTextToObject;
private _ffRadius = _dispersion + 150;
private _ffBlocked = false;

if (!_force) then {
{
    if (!_ffBlocked && {([_x,"type",""] call ALiVE_fnc_hashGet) in ["entity","vehicle"]}) then {
        private _pSide = [_x,"side",""] call ALiVE_fnc_hashGet;
        if (_pSide isEqualType "" && {_pSide != ""}) then {
            if ([([_pSide] call ALIVE_fnc_sideTextToObject), _sideObject] call BIS_fnc_sideIsFriendly) then {
                if (([_x,"position"] call ALiVE_fnc_hashGet) distance2D _aimBase < _ffRadius) then {
                    _ffBlocked = true;
                };
            };
        };
    };
} forEach (([ALIVE_profileHandler, "profiles"] call ALIVE_fnc_hashGet) select 2);

if (!_ffBlocked) then {
    _ffBlocked = ((allPlayers - entities "HeadlessClient_F") findIf {
        (_x distance2D _aimBase < _ffRadius) && {[side group _x, _sideObject] call BIS_fnc_sideIsFriendly}
    }) > -1;
};
};

if (_ffBlocked) exitWith {
    if (_debug) then {
        ["ALiVE MIL_ARTILLERY - fire mission aborted: friendlies inside the impact area at %1", _aimBase] call ALiVE_fnc_dump;
    };
    [0.5] call _fnc_release;
};

// fired watchdog counters - no fire event within the window means a broken
// battery (wrong mags, engine refusal) and it must not spin on retries
// add the counters where each gun is LOCAL (guns can live on a headless
// client) and publish the count so the server-side watchdog reads it
{
    _x setVariable ["ALiVE_artyMissionFired", 0, true];
    [_x, {
        private _eh = _this addEventHandler ["Fired", {
            params ["_unit"];
            _unit setVariable ["ALiVE_artyMissionFired", (_unit getVariable ["ALiVE_artyMissionFired", 0]) + 1, true];
        }];
        _this setVariable ["ALiVE_artyMissionFiredEH", _eh];
    }] remoteExec ["call", _x];
} forEach _guns;

private _fnc_firedCount = {
    private _n = 0;
    { _n = _n + (_x getVariable ["ALiVE_artyMissionFired", 0]) } forEach _guns;
    _n
};

// ranging round first - it doubles as the audible warning at the target end
private _rangingAim = _aimBase getPos [random _dispersion, random 360];
[_gunLead, [_rangingAim, _mag, 1]] remoteExec ["doArtilleryFire", _gunLead];

if (_debug) then {
    ["ALiVE MIL_ARTILLERY - ranging round ordered: %1 firing %2 at %3", typeOf _gunLead, _mag, _rangingAim] call ALiVE_fnc_dump;
};

sleep 25;

// main volley - every gun, per-round aim offset via the mission dispersion
private _roundsPerGun = 1 max ceil (_roundsPerMission / count _guns);
{
    private _volleyAim = _aimBase getPos [random _dispersion, random 360];
    [_x, [_volleyAim, _mag, _roundsPerGun]] remoteExec ["doArtilleryFire", _x];
} forEach _guns;

if (_debug) then {
    ["ALiVE MIL_ARTILLERY - volley ordered: %1 gun(s), %2 round(s) each, dispersion %3m", count _guns, _roundsPerGun, _dispersion] call ALiVE_fnc_dump;
};

_deadline = time + 90;
waitUntil {
    sleep 5;
    ((call _fnc_firedCount) > 0) || {time > _deadline}
};

private _fired = call _fnc_firedCount;

if (_fired == 0) then {
    ["ALiVE MIL_ARTILLERY - battery %1 (%2) took a fire order but never fired - stood down for a full cooldown", _entityID, typeOf _gunLead] call ALiVE_fnc_dump;
} else {
    // dwell so the rounds land and the AI settles before anything despawns,
    // then re-read the true total (the waitUntil above exits on the FIRST
    // round, so _fired would otherwise report 1 for the whole volley)
    sleep 90;
    _fired = call _fnc_firedCount;
};

{
    [_x, {
        private _eh = _this getVariable ["ALiVE_artyMissionFiredEH", -1];
        if (_eh >= 0) then { _this removeEventHandler ["Fired", _eh]; };
        _this setVariable ["ALiVE_artyMissionFiredEH", nil];
    }] remoteExec ["call", _x];
} forEach _guns;

// logical ammunition ledger - the long-term cadence cap
[_record,"rounds", (([_record,"rounds"] call ALiVE_fnc_hashGet) - (_roundsPerMission + 1)) max 0] call ALiVE_fnc_hashSet;

if (_debug) then {
    ["ALiVE MIL_ARTILLERY - fire mission complete: battery %1 fired %2 round(s), %3 left in the ledger", _entityID, _fired, [_record,"rounds"] call ALiVE_fnc_hashGet] call ALiVE_fnc_dump;
};

[1] call _fnc_release;
