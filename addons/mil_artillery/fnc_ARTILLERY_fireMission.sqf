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
// danger-close: when on, batteries fire even with friendlies in the impact
// area (the module's ignore-nearby-friendlies toggle - use with caution)
private _dangerClose = [_logic, "dangerClose"] call ALIVE_fnc_MilArtillery;

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
    // marker survives a war-state save so the module init sweep can heal
    // holds this thread never got to release
    [_p,"ALiVE_artyHold",true] call ALiVE_fnc_hashSet;
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
            [_p,"ALiVE_artyHold",false] call ALiVE_fnc_hashSet;
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
if (_mag == "") then {
    // ask the live gun what it is holding. The config read is only ever as good
    // as where it looks - every rocket launcher hid from it until it learned to
    // read pylons - and there may be somewhere else it still does not look.
    // Prefer an HE-classified magazine, else take the first offered.
    private _liveMags = getArtilleryAmmo [_gunLead];
    if (count _liveMags > 0) then {
        private _idx = _liveMags findIf { ["HE", _x] call ALIVE_fnc_isMagazineOfOrdnanceType };
        _mag = _liveMags select (_idx max 0);
        if (_debug) then {
            ["ALiVE MIL_ARTILLERY - ordnance resolved from the live gun for %1: %2", typeOf _gunLead, _mag] call ALiVE_fnc_dump;
        };
    };
};
if (_mag == "") then {
    // last resort: an artillery piece only carries artillery magazines - take
    // whatever the config lists rather than standing down
    private _cfgMags = (typeOf _gunLead) call ALIVE_fnc_getArtyMagazines;
    if (count _cfgMags > 0) then {
        _mag = _cfgMags select 0;
        if (_debug) then {
            ["ALiVE MIL_ARTILLERY - ordnance unclassifiable for %1, falling back to its first magazine %2", typeOf _gunLead, _mag] call ALiVE_fnc_dump;
        };
    };
};
if (_mag == "") exitWith {
    ["ALiVE MIL_ARTILLERY - fire mission aborted: no usable ordnance found for %1 - battery stood down", typeOf _gunLead] call ALiVE_fnc_dump;
    [1] call _fnc_release;
};

// first-activation capability probe: measure the gun's real engagement
// envelope, because no config heuristic predicts it - the RHS Grad turned out
// to be an 8-20km system, nothing like the howitzer defaults. Cached on the
// record so battery picks stop offering it unreachable targets.
if !([_record,"probed",false] call ALiVE_fnc_hashGet) then {
    private _probeMag = (getArtilleryAmmo [_gunLead]) param [0, _mag];
    if (_probeMag != "") then {
        private _minR = -1;
        private _maxR = -1;
        {
            if ((_gunLead getPos [_x, 0]) inRangeOfArtillery [[_gunLead], _probeMag]) then {
                if (_minR < 0) then { _minR = _x; };
                _maxR = _x;
            };
        } forEach [500, 1000, 2000, 4000, 6000, 8000, 12000, 16000, 20000, 24000];
        if (_minR > 0) then {
            // only a SUCCESSFUL sweep pins the flag - a blank sweep (bad
            // probe magazine, terrain blanking the samples) must retry on
            // the next mission or the coarse defaults are frozen forever
            [_record,"probed",true] call ALiVE_fnc_hashSet;
            [_record,"minRange", _minR * 0.75] call ALiVE_fnc_hashSet;
            [_record,"maxRange", _maxR] call ALiVE_fnc_hashSet;
            if (_debug) then {
                ["ALiVE MIL_ARTILLERY - battery %1 envelope probed: %2m to %3m (%4)", _entityID, round (_minR * 0.75), _maxR, _probeMag] call ALiVE_fnc_dump;
            };
        };
    };
};

private _aimBase = [_targetPos select 0, _targetPos select 1, 0];

// real range check now a crewed gun exists; refine the coarse default so the
// next battery pick knows this battery's true reach
if !(_aimBase inRangeOfArtillery [_guns, _mag]) exitWith {
    private _dist = _gunLead distance2D _aimBase;
    private _maxRange = [_record,"maxRange"] call ALiVE_fnc_hashGet;
    // only revise unprobed defaults - a measured envelope is authoritative
    if (!([_record,"probed",false] call ALiVE_fnc_hashGet) && {_dist > _maxRange * 0.5}) then {
        [_record,"maxRange", ((_dist * 0.9) max 1500)] call ALiVE_fnc_hashSet;
    };
    if (_debug) then {
        // name the round, and say what the gun is actually carrying. What refused
        // the shot is the engine being asked whether THIS gun can put THIS
        // magazine there - the envelope below is only a record of an earlier
        // measurement, taken with whatever the gun reported carrying, and it
        // takes no part in the decision. A magazine the gun cannot fire is
        // refused at every range, and reads exactly like a range problem unless
        // the round is named: if the round below is not among what it carries,
        // the range is a red herring and the ordnance lookup is the fault.
        ["ALiVE MIL_ARTILLERY - fire mission aborted: %1 will not put %2 on a target %3m away. It is carrying %4. Envelope last measured %5m to %6m",
            typeOf _gunLead, _mag, round _dist,
            getArtilleryAmmo [_gunLead],
            round ([_record,"minRange",300] call ALiVE_fnc_hashGet),
            [_record,"maxRange"] call ALiVE_fnc_hashGet] call ALiVE_fnc_dump;
    };
    [0.5] call _fnc_release;
};

// friendly-fire check on the impact area (skipped on a forced debug strike,
// or when the module's danger-close / ignore-friendlies toggle is on)
private _sideObject = [_sideText] call ALIVE_fnc_sideTextToObject;
private _ffRadius = _dispersion + 150;
private _ffBlocked = false;

if (!_force && !_dangerClose) then {
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

// players about to be shelled get a radio warning from their HQ, and being
// shelled reveals the battery: a destroy-artillery task is raised for the
// victim side (approximate position - counter-battery intel, not psychic)
private _victimPlayers = (allPlayers - entities "HeadlessClient_F") select {
    (_x distance2D _aimBase < 600) && {!([side group _x, _sideObject] call BIS_fnc_sideIsFriendly)}
};
if (count _victimPlayers > 0) then {
    private _victimSides = [];
    { _victimSides pushBackUnique (side group _x) } forEach _victimPlayers;

    {
        private _vSide = _x;
        private _vSideText = str _vSide;

        // one warning per side per 10 minutes
        private _lastVar = format ["artyWarnLast_%1", _vSideText];
        if (time - (_logic getVariable [_lastVar, -3600]) > 600) then {
            _logic setVariable [_lastVar, time];
            private _hqClass = switch (_vSide) do { case west: {"BLU"}; case east: {"OPF"}; case resistance: {"IND"}; default {"HQ"} };
            private _hqid = getText (configFile >> "CfgHQIdentities" >> _hqClass >> "name");
            private _message = format [localize "STR_ALIVE_MIL_ARTILLERY_INCOMING", _hqid, mapGridPosition _aimBase];
            private _radioBroadcast = [objNull, _message, "side", _vSide, false, false, false, true, _hqClass];
            [_vSideText, _radioBroadcast] call ALIVE_fnc_radioBroadcastToSide;
        };

        // destroy-artillery task, once per battery per side, via the task system
        if (([_logic,"generateTasks"] call ALIVE_fnc_MilArtillery)
            && {["ALiVE_mil_c2istar"] call ALiVE_fnc_IsModuleAvailable}) then {
            private _taskedVar = format ["artyTasked_%1", _vSideText];
            private _tasked = _logic getVariable [_taskedVar, []];
            if !(_entityID in _tasked) then {
                _tasked pushBack _entityID;
                _logic setVariable [_taskedVar, _tasked];

                private _sidePlayers = [_vSideText] call ALiVE_fnc_getPlayersDataSource;
                _sidePlayers = [_sidePlayers select 1, _sidePlayers select 0];
                // attribute the task to a victim of THIS side - with two
                // hostile sides in the impact area the first victim overall
                // may belong to the other one
                private _vFaction = faction (_victimPlayers select ((_victimPlayers findIf { side group _x == _vSide }) max 0));
                private _batFaction = [_record,"faction",""] call ALiVE_fnc_hashGet;
                private _revealPos = ([_entityProfile,"position"] call ALiVE_fnc_hashGet) getPos [50 + random 150, random 360];
                private _requestID = format ["ARTY_%1_%2", _entityID, floor time];
                private _taskData = [_requestID, "ARTY", _vSideText, _vFaction, "DestroyVehicles", "NULL", _revealPos, _sidePlayers, _batFaction, "Y", "Side", +_vehicleIDs];
                private _tEvent = ["TASK_GENERATE", _taskData, "MilArtillery"] call ALIVE_fnc_event;
                [ALIVE_eventLog, "addEvent", _tEvent] call ALIVE_fnc_eventLog;

                if (_debug) then {
                    ["ALiVE MIL_ARTILLERY - destroy-artillery task raised for %1 against battery %2", _vSideText, _entityID] call ALiVE_fnc_dump;
                };
            };
        };
    } forEach _victimSides;
};

// the battery's own side hears the fire-support call too - players allied
// with the guns get the HQ announcement wherever they are on the map
private _friendlyPlayers = (allPlayers - entities "HeadlessClient_F") select {
    [side group _x, _sideObject] call BIS_fnc_sideIsFriendly
};
if (count _friendlyPlayers > 0) then {
    private _friendlySides = [];
    { _friendlySides pushBackUnique (side group _x) } forEach _friendlyPlayers;
    {
        private _fSide = _x;
        private _fSideText = str _fSide;
        private _hqClass = switch (_fSide) do { case west: {"BLU"}; case east: {"OPF"}; case resistance: {"IND"}; default {"HQ"} };
        private _hqid = getText (configFile >> "CfgHQIdentities" >> _hqClass >> "name");
        private _message = format [localize "STR_ALIVE_MIL_ARTILLERY_FIRE_SUPPORT", _hqid, mapGridPosition _aimBase];
        private _radioBroadcast = [objNull, _message, "side", _fSide, false, false, false, true, _hqClass];
        [_fSideText, _radioBroadcast] call ALIVE_fnc_radioBroadcastToSide;
    } forEach _friendlySides;
};

// fired watchdog counters - no fire event within the window means a broken
// battery (wrong mags, engine refusal) and it must not spin on retries
// add the counters where each gun is LOCAL (guns can live on a headless
// client) and publish the count so the server-side watchdog reads it
{
    _x setVariable ["ALiVE_artyMissionFired", 0, true];
    [_x, {
        // count only artillery ordnance - a battery defending itself with its
        // machine gun must not satisfy the volley watchdog (or feed the enemy
        // counter-battery watch a volley that never flew). Classify by the
        // fired AMMO's simulation family: shells/rockets/missiles count,
        // bullets and countermeasure smoke do not. Judging the round that
        // actually flew needs no config read at all, so nothing can hide
        private _eh = _this addEventHandler ["Fired", {
            params ["_unit","","","","_ammo"];
            // #876 - flares excluded: the night illumination pre-shot must not
            // satisfy the volley watchdog - only lethal ordnance proves the
            // volley flew. Vanilla flares usually fail the tests below anyway;
            // this guards mod illum ammo parented under its HE shell tree.
            if ((_ammo isKindOf ["ShellBase", configFile >> "CfgAmmo"]
                || {_ammo isKindOf ["RocketBase", configFile >> "CfgAmmo"]}
                || {_ammo isKindOf ["MissileBase", configFile >> "CfgAmmo"]})
                && {!(_ammo isKindOf ["FlareCore", configFile >> "CfgAmmo"])}) then {
                _unit setVariable ["ALiVE_artyMissionFired", (_unit getVariable ["ALiVE_artyMissionFired", 0]) + 1, true];
            };
        }];
        _this setVariable ["ALiVE_artyMissionFiredEH", _eh];
    }] remoteExec ["call", _x];
} forEach _guns;

private _fnc_firedCount = {
    private _n = 0;
    { _n = _n + (_x getVariable ["ALiVE_artyMissionFired", 0]) } forEach _guns;
    _n
};

private _volleyStart = time;

// #876 - when it's properly dark, put one illumination round dead-centre on the
// target ahead of everything else, so the ranging round and HE volley that
// follow land under the flare. sunOrMoon < 0.3 = genuinely dark (skips dusk/dawn
// twilight, where a flare adds little). Fire and forget: a gun with no illum
// magazine, or one out of flare range, just proceeds exactly as in daylight.
// This runs only on the real-fire path (a player is near), so a flare is always
// seen; virtual missions never reach this file.
private _sunOrMoon = sunOrMoon;
private _illumMag = if (_sunOrMoon < 0.3) then {
    [_gunLead, "ILLUM"] call ALIVE_fnc_getArtyMagazineType
} else { "" };
// illum magazines have their own (usually shorter) firing solution - if the
// flare cannot reach the target the engine silently refuses the order, so skip
// the shot and its delay rather than pay 20s for nothing
if (_illumMag != "" && {!(_aimBase inRangeOfArtillery [[_gunLead], _illumMag])}) then {
    if (_debug) then {
        ["ALiVE MIL_ARTILLERY - illumination skipped: target outside %1's envelope for %2", typeOf _gunLead, _illumMag] call ALiVE_fnc_dump;
    };
    _illumMag = "";
};
if (_illumMag != "") then {
    [_gunLead, [_aimBase, _illumMag, 1]] remoteExec ["doArtilleryFire", _gunLead];
    if (_debug) then {
        ["ALiVE MIL_ARTILLERY - illumination round ordered: %1 firing %2 at %3 (sunOrMoon %4)", typeOf _gunLead, _illumMag, _aimBase, _sunOrMoon] call ALiVE_fnc_dump;
    };
    // let the flare leave the tube before the same gun takes its next order -
    // a fresh doArtilleryFire overrides one still being laid
    sleep 20;
};

// ranging round next - it doubles as the audible warning at the target end
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

// counter-battery self-verification: if the shell watch missed THIS volley
// (wrong event name or params, per-client locality, guns local to a headless
// client), record the volley ourselves so AI-vs-AI detection never depends on
// the engine event. Weight is the volley size - the watch counts per shell
if (_fired > 0 && {!isNil "ALIVE_artyShellEvents"}) then {
    private _events = ALIVE_artyShellEvents;
    if ((_events findIf { (_x select 0) in _vehicleIDs && {(_x select 3) > _volleyStart} }) == -1) then {
        // IN-PLACE mutation only - see the watch installer in the monitor
        _events pushBack [_vehicleIDs param [0, ""], getPosATL _gunLead, toUpper str _sideObject, time, _roundsPerMission + 1, time];
        while {count _events > 30} do { _events deleteAt 0; };
        if (_debug) then {
            ["ALiVE MIL_ARTILLERY - counter-battery: fallback fire event recorded for battery %1 (%2 shell(s))", _entityID, _roundsPerMission + 1] call ALiVE_fnc_dump;
        };
    };
};

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
