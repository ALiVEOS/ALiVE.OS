#include "\x\alive\addons\mil_IED\script_component.hpp"
SCRIPT(armIED);

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_ied

// Arms an IED with proximity detonation.
//
// Detonation model:
//   - Non-engineer units (or vehicle-borne engineers, or AI in aiTriggerable mode
//     who lack the engineer qualification) trip the IED instantly when inside the
//     proximity radius.
//   - Qualifying engineers build per-engineer-per-IED "trip pressure" each
//     0.5s poll, modulated by distance, stance, movement speed and skill. When
//     pressure crosses a per-IED randomized threshold the IED detonates. Trip
//     pressure decays when the engineer leaves the radius.
//
//     Engineer qualification (any of, while on foot):
//       - configured IED_Detection_Device (default "MineDetector") in items _u
//       - CfgVehicles displayName == "Explosive Specialist"
//       - vehicleVarName matches CBA "EOD" trait via CBA_fnc_find
//       - engine `getUnitTrait "explosiveSpecialist"` returns true (Ares 2026-05-14)
//       - ACE_isEngineer module variable > 0 (ACE level 1 or 2; Ares 2026-05-14)
//       - ACE_isEOD module variable true (ACE explosives-specialist role)
//
// Tunables (ADDON getVariable):
//   IED_Engineer_Trip_Base         - per-tick base increment (default 0.02)
//   IED_Engineer_Trip_ThresholdMin - min randomized threshold (default 0.7)
//   IED_Engineer_Trip_ThresholdMax - max randomized threshold (default 1.3)
//   IED_Engineer_Decay_Rate        - per-tick decay when clear (default 0.01)

private ["_IED","_type","_shell","_proximity","_debug"];

if !(isServer) exitWith {["ArmIED Not running on server!"] call ALiVE_fnc_dump;};

_debug     = ADDON getVariable ["debug", false];
_detection = ADDON getVariable ["IED_Detection", 1];
_device    = ADDON getVariable ["IED_Detection_Device", "MineDetector"];

private _aiTriggerable = ADDON getVariable ["aiTriggerable", false];

_IED  = _this select 0;
_type = _this select 1;

if (count _this > 2) then {
    _shell = _this select 2;
} else {
    // Pool of ammo classes that DETONATE when spawned static at rest via
    // createVehicle (#890). The M_Mo_*_AT / _AT_LG mortar rounds the previous
    // fix used spawn fine (non-null) but are guided/ballistic ammo that just
    // sits inert with no velocity or lock -> the IED did no damage. Confirmed
    // by in-game test 2026-05-30: only R_60mm_HE + Bomb_03_F + Bomb_04_F
    // actually explode on creation; Sh_*_AMOS, G_40mm_HE and all M_Mo_*_AT*
    // spawn inert. Weighted toward the smaller R_60mm_HE for the common case,
    // with the two larger bombs rarer. Fallback below still catches any class
    // that returns objNull.
    _shell = [["R_60mm_HE","Bomb_03_F","Bomb_04_F"],[8,1,1]] call BIS_fnc_selectRandomWeighted;
};

_proximity = 2 + floor(random 10);

// Per-IED randomized trip threshold. Stored on the IED so debug/inspection tools
// can read it without re-rolling. Hidden from the player by design.
// Module-attribute type coercion is handled by fnc_IED.sqf's case handlers at
// init, so these reads are guaranteed SCALAR.
private _tripThresholdMin = ADDON getVariable ["IED_Engineer_Trip_ThresholdMin", 0.7];
private _tripThresholdMax = ADDON getVariable ["IED_Engineer_Trip_ThresholdMax", 1.3];
private _tripThreshold    = _tripThresholdMin + random (_tripThresholdMax - _tripThresholdMin);
_IED setVariable ["ALiVE_IED_TripThreshold", _tripThreshold];

if (_debug) then {
    ["ALIVE-%1 IED: arming IED at %2 of %3 as %4 with proximity %5, trip threshold %6",
        time, getposATL _IED, _type, _shell, _proximity, _tripThreshold] call ALiVE_fnc_dump;
};

_IED remoteExec ["ALiVE_fnc_addActionIED", 0, true];

// Arm-time grace period: trigger creation is delayed so an IED cannot detonate
// instantly on placement if a player is already present at spawn time. See the
// EmptyDetector rationale in git history - creating triggers with ANY/PRESENT
// against already-present units fires them synchronously, so we defer.
private _gracePeriod = 15;

[_IED, _type, _shell, _proximity, _gracePeriod] spawn {
    params ["_ied", "_type", "_shell", "_proximity", "_grace"];

    sleep _grace;

    if (isNull _ied || !alive _ied) exitWith {};

    // Wait for all players to clear the blast radius + buffer before we arm,
    // OR fall through after a hard timeout. AI are intentionally not held back
    // -- they are valid targets once armed.
    //
    // The timeout matters because IEDs spawn when a player triggers the town
    // EmptyDetector -- so at spawn time there is BY DEFINITION at least one
    // player inside the town radius. A small town (or a player slot placed
    // near an IED candidate position) means the player may never naturally
    // move outside this IED's clear radius, leaving the polling loop below
    // permanently un-entered. Reported on Discord 2026-05-12 (Eric): stepping
    // on a placed IED produced no detonation. The behaviour regressed in
    // commit 707ef292 which added the unbounded wait; before that, arming
    // happened on a flat 15s sleep regardless of player proximity.
    //
    // Cap chosen so a player legitimately trying to clear has time to do so
    // (typical foot speed: 60s @ ~5 km/h ~= 80m, well beyond _proximity+15),
    // while a player camping the spot eventually gets the right behaviour
    // (boom).
    private _clearRadius = _proximity + 15;
    private _maxWait = diag_tickTime + 60;
    waitUntil {
        if (isNull _ied || !alive _ied) exitWith { true };
        if (diag_tickTime > _maxWait) exitWith { true };
        sleep 0.5;
        ({(vehicle _x) distance _ied < _clearRadius} count ([] call BIS_fnc_listPlayers)) == 0
    };

    if (isNull _ied || !alive _ied) exitWith {};

    // A trigger man (#578). With Trigger Man Chance set, an IED may get a civilian watching it
    // from 60-150 m with a clear view. While he is alive and free he sets it off himself when
    // someone comes near, whoever they are, so an engineer's careful approach doesn't help.
    // Kill him, detain him or make him surrender and nobody is left to set it off: it no longer
    // goes off when approached, and is disarmed the usual way. ALiVE's own IEDs only.
    private _dickerChance = ADDON getVariable ["IED_Dicker_Chance", 0];
    if (_dickerChance isEqualType "") then { _dickerChance = parseNumber _dickerChance };
    if (_dickerChance > 0 && {(ADDON getVariable ["resolvedIntegrationMode", "alive"]) != "mine"} && {random 100 < _dickerChance}) then {
        private _target = (getPosASL _ied) vectorAdd [0, 0, 0.5];
        private _spot = [];
        for "_i" from 1 to 30 do {
            private _p = (getPosATL _ied) getPos [60 + random 90, random 360];
            _p set [2, 0];
            private _eye = (ATLToASL _p) vectorAdd [0, 0, 1.6];
            if (!surfaceIsWater _p && {!(terrainIntersectASL [_eye, _target])}
                && {(lineIntersectsSurfaces [_eye, _target, _ied, objNull, true, 1, "VIEW", "FIRE"]) isEqualTo []}
                && {([_p, 300] call ALiVE_fnc_anyPlayersInRange) == 0}) exitWith { _spot = _p };
        };
        if (_spot isEqualTo []) exitWith {};
        // Dressed like the people of the place: the class of a civilian already about, if any.
        private _civs = (allUnits + (agents apply { agent _x })) select { (side group _x) isEqualTo civilian && {_x isKindOf "CAManBase"} && {!isPlayer _x} };
        private _cls = if (_civs isNotEqualTo []) then { typeOf (selectRandom _civs) } else { "C_man_1" };
        private _d = (createGroup [civilian, true]) createUnit [_cls, _spot, [], 0, "CAN_COLLIDE"];
        if (isNull _d) exitWith {};
        _d setDir (_d getDir _ied);
        _d disableAI "PATH";
        _d setBehaviour "CARELESS";
        _d setUnitPos (selectRandom ["UP", "MIDDLE"]);
        _d doWatch (getPosATL _ied);
        if (isClass (configFile >> "CfgWeapons" >> "ACE_Cellphone")) then { _d addItem "ACE_Cellphone" };
        _d setVariable ["ALiVE_advciv_blacklist", true, true];
        _d setVariable ["ALiVE_CivPop_InsurgentContact", true, true];
        _d setVariable ["ALiVE_IED_DickerOf", _ied, true];
        _ied setVariable ["ALiVE_IED_Dicker", _d, true];
        _ied setVariable ["ALiVE_IED_DickerMode", true, true];
        if (ADDON getVariable ["debug", false]) then {
            ["ALIVE-%1 IED: trigger man %2 (%3) watching IED at %4 from %5 m", time, name _d, _cls, getPosATL _ied, round (_d distance _ied)] call ALiVE_fnc_dump;
        };
    };

    // ---------------------------------------------------------------------
    // Polling-loop detonation model.
    // EmptyDetector-based triggers with ANY/PRESENT have synchronous-fire
    // edge cases; a polling loop is immune and lets us run the per-engineer
    // trip-pressure model below.
    // ---------------------------------------------------------------------
    [_ied, _type, _shell, _proximity] spawn {
        params ["_ied", "_type", "_shell", "_proximity"];

        private _aiTriggerable    = ADDON getVariable ["aiTriggerable", false];
        private _device           = ADDON getVariable ["IED_Detection_Device", "MineDetector"];
        private _detection        = ADDON getVariable ["IED_Detection", 1];
        private _challengeEnabled = (ADDON getVariable ["IED_Engineer_Challenge", 1]) == 1;
        private _tripBase         = ADDON getVariable ["IED_Engineer_Trip_Base", 0.02];
        private _decayRate        = ADDON getVariable ["IED_Engineer_Decay_Rate", 0.01];
        private _threshold        = _ied getVariable ["ALiVE_IED_TripThreshold", 1.0];
        // Trigger man (#578): set above when this IED got one.
        private _dickerMode = _ied getVariable ["ALiVE_IED_DickerMode", false];
        private _dicker     = _ied getVariable ["ALiVE_IED_Dicker", objNull];
        private _dickerAt   = -1;
        private _fnc_dickerFree = {
            alive _dicker && {!captive _dicker} && {lifeState _dicker != "INCAPACITATED"}
            && {!(_dicker getVariable ["ace_captives_isHandcuffed", false])} && {!(_dicker getVariable ["ace_captives_isSurrendering", false])}
            && {(_dicker distance _ied) < 400}
        };
        private _debugLocal       = ADDON getVariable ["debug", false];
        private _stompRadius      = ADDON getVariable ["resolvedStompRadius", 0];

        private _detectedOnce = false;
        private _detonated    = false;
        // Per-engineer trip counters, keyed by netId. Lives for the IED's lifetime.
        private _tripMap = createHashMap;
        // Per-engineer "immune log already fired" latch, keyed by netId. Lives
        // for the IED's lifetime so we don't spam the once-per-0.5s poll. See
        // the silent-immunity branch below.
        private _loggedImmune = [];


        while {
            !_detonated &&
            !isNull _ied &&
            alive _ied &&
            !(_ied getVariable ["ALiVE_IED_Disarmed", false])
        } do {
            sleep 0.5;

            if (isNull _ied || !alive _ied || (_ied getVariable ["ALiVE_IED_Disarmed", false])) then {
                _detonated = true;   // reuse the loop-exit flag; container may stay alive post-disarm
            } else {

                // --- Detection hint (engineer / mine detector) ---
                private _detectList = _ied nearEntities ["Man", _proximity + 5];
                if (!_detectedOnce) then {
                    private _detectors = _detectList select {
                        alive _x &&
                        ((getposATL _x) select 2 < 8) &&
                        (
                            (_device in (items _x)) ||
                            (getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName") == "Explosive Specialist") ||
                            ([vehicleVarName _x, "EOD"] call CBA_fnc_find != -1) ||
                            (_x getUnitTrait "explosiveSpecialist") ||           // vanilla A3 explosives-specialist trait
                            ((_x getVariable ["ACE_isEngineer", 0]) in [true, 1, 2]) || // ACE engineer, level 1 or 2 or true
                            (_x getVariable ["ACE_isEOD", false])                 // ACE EOD specialist (explosives role)
                        ) &&
                        // Players only, whatever AI Units Trigger IEDs says: the warning is a hint
                        // or a sound for a player, and an AI engineer used up the one warning an
                        // IED gives before any player got it.
                        (_x in ([] call BIS_fnc_listPlayers))
                    };
                    if (count _detectors > 0) then {
                        [_ied, _detection, _detectors, _detection, _device] call ALiVE_fnc_detectIED;
                        // detectIED only warns a unit carrying the detector, so only that uses up the
                        // one warning: an engineer without one nearby mustn't take it from the next man.
                        if ((_detectors findIf { _device in (items _x) }) > -1) then { _detectedOnce = true };
                    };
                };

                // --- Detonation / accumulator check ---
                // Candidate pool: men + ground vehicles within proximity, alive, ground level.
                //
                // Velocity-anticipation: scan a wider radius (_proximity + 5m)
                // and accept candidates whose projected position one poll
                // cycle from now is inside _proximity. Buffers against
                // scheduler drift on low-FPS dedis where the 0.5s sleep can
                // stretch to 1-2s, causing a walking player to clear the
                // small proximity radius between polls. Stationary
                // candidates (velocity 0) behave identically to the prior
                // tight-radius check. Anticipated displacement is capped at
                // 5m so fast vehicles don't trigger at long range. Reported
                // 2026-05-24 (Ares #890): "no luck at all" on a retest with
                // server FPS <25 - the polling loop was missing his passes
                // through tight proximity radii.
                private _anticipateMax = 5;     // metres - cap on look-ahead distance
                private _pollLookahead = 0.5;   // seconds - matches the loop's sleep above
                private _detonateList = _ied nearEntities ["Man", _proximity + _anticipateMax];
                _detonateList append (_ied nearEntities ["LandVehicle", _proximity + _anticipateMax]);
                // Men and crewed vehicles only: with AI Units Trigger IEDs on, an empty car, an
                // unmanned static weapon or an animal (all found by the searches above) set it off.
                _detonateList = _detonateList select {
                    alive _x && ((getposATL (vehicle _x)) select 2 < 8) &&
                    {(_x isKindOf "CAManBase") || {!(_x isKindOf "Man") && {({alive _x} count (crew _x)) > 0}}} &&
                    {
                        private _speedMs    = vectorMagnitude (velocity (vehicle _x));
                        private _anticipate = (_speedMs * _pollLookahead) min _anticipateMax;
                        ((_x distance _ied) - _anticipate) <= _proximity
                    }
                };

                private _players       = [] call BIS_fnc_listPlayers;
                private _shouldDetonate = false;
                private _engineersSeen = [];

                // --- Stomp check (per-integration pressure-trigger) ---
                // For pressure-mine integrations (e.g. RHS) where stepping on
                // the mine should detonate immediately. Bypasses the engineer
                // accumulator entirely - intentional, because the fundamental
                // contract of a pressure mine is "weight on it = boom" and no
                // amount of skill or careful stance changes that. Engineers
                // can still defuse from outside the stomp radius via the
                // 3m addAction.
                //
                // Uses 2D (horizontal) distance, NOT nearEntities's 3D radius.
                // A standing player has a center ~0.9m above the ground - their
                // 3D distance to a ground-level mine is ~0.9m even when standing
                // on top of it, so a 3D 0.6m radius would never match. Cast a
                // wider 3D net (4m) to capture candidates, then filter by 2D
                // ground distance against the configured stompRadius.
                // Vehicles included so driving over a mine fires the same path.
                if (_stompRadius > 0) then {
                    private _stompCandidates = _ied nearEntities ["Man", 4];
                    _stompCandidates append (_ied nearEntities ["LandVehicle", 4]);
                    private _stompList = _stompCandidates select {
                        alive _x &&
                        ((getposATL (vehicle _x)) select 2 < 8) &&
                        ((_x isKindOf "CAManBase") || {!(_x isKindOf "Man") && {({alive _x} count (crew _x)) > 0}}) &&
                        ((_x in _players) || {(vehicle _x) in _players} || {((crew _x) findIf {_x in _players}) > -1} || {_aiTriggerable && {_x call ALiVE_fnc_iedAICounts}}) &&
                        ((_x distance2D _ied) < _stompRadius)
                    };
                    if (count _stompList > 0) then {
                        _shouldDetonate = true;
                        if (_debugLocal) then {
                            ["ALIVE-%1 IED stomp: detonating, %2 unit(s) within 2D %3m of mine at %4",
                                time, count _stompList, _stompRadius, getposATL _ied] call ALiVE_fnc_dump;
                        };
                    };
                };

                {
                    private _u = _x;
                    // A vehicle is a candidate in its own right (the search finds it, not the men in
                    // it), so a player in it counts through its crew; compared as it stood, a player's
                    // vehicle never did.
                    private _isPlayer = (_u in _players) || {(vehicle _u) in _players} || {((crew _u) findIf {_x in _players}) > -1};
                    // With AI triggering on, AI count only on a player's side or one friendly to it.
                    private _relevant = _isPlayer || {_aiTriggerable && {_u call ALiVE_fnc_iedAICounts}};

                    if (_relevant && !_shouldDetonate) then {
                        private _inVehicle = (vehicle _u) != _u;

                        // Engineer qualification applies to dismounted units only.
                        // Vehicle-borne engineers lose the exemption - vehicles aren't
                        // "carefully approaching". Shared with the disarm-action gate
                        // via ALiVE_fnc_iedUnitQualifies (which also enforces dismounted).
                        private _qualifies = [_u, _device] call ALiVE_fnc_iedUnitQualifies;

                        if (!_qualifies) then {
                            // Non-engineer or vehicle-borne: instant detonation (legacy behaviour).
                            _shouldDetonate = true;
                        } else {
                            if (!_challengeEnabled) then {
                                // Master toggle off: qualifying engineer is fully immune (legacy).
                                // Nothing to do - fall through without accumulating.
                                //
                                // With Debug on, say once per engineer per IED that
                                // this one is immune, so a tester can see why a qualifying
                                // unit walked through without anything happening (kept
                                // on purpose after #890; the other traces were removed).
                                private _key = netId _u;
                                if (_debugLocal && !(_key in _loggedImmune)) then {
                                    _loggedImmune pushBack _key;
                                    ["ALIVE-%1 IED: %2 qualifies as engineer AND IED_Engineer_Challenge is disabled -- IED is immune to this unit, will not detonate",
                                        time, name _u] call ALiVE_fnc_dump;
                                };
                            } else {
                            // Engineer: accumulate trip pressure.
                            private _key = netId _u;
                            _engineersSeen pushBack _key;
                            private _trip = _tripMap getOrDefault [_key, 0];

                            // Distance factor: quadratic falloff, with a close-contact boost.
                            private _dist = _u distance _ied;
                            private _distFactor = if (_dist < 1) then {
                                1.5
                            } else {
                                ((1 - (_dist / _proximity)) ^ 2) max 0
                            };

                            // Stance factor.
                            private _stanceFactor = switch (unitPos _u) do {
                                case "DOWN":   { 0.3 };
                                case "MIDDLE": { 0.6 };
                                default        { 1.0 };   // "UP" / "AUTO"
                            };

                            // Speed factor (kph, absolute value).
                            private _spd = abs (speed _u);
                            private _speedFactor = switch (true) do {
                                case (_spd <= 1):  { 0.3 };
                                case (_spd <= 4):  { 0.6 };
                                case (_spd <= 8):  { 1.2 };
                                default            { 2.0 };
                            };

                            // Skill factor is a divisor, clamped. Player skill is typically 1.0
                            // in MP so the variance mainly matters for AI engineers.
                            private _skill = _u skillFinal "commanding";
                            private _skillFactor = ((_skill + 0.5) max 0.5) min 2.0;

                            private _increment = _tripBase * _distFactor * _stanceFactor * _speedFactor / _skillFactor;
                            _trip = _trip + _increment;
                            _tripMap set [_key, _trip];

                            if (_debugLocal) then {
                                ["ALIVE-%1 IED accum: %2 trip=%3/%4 (d=%5 st=%6 sp=%7 sk=%8)",
                                    time, name _u, _trip toFixed 3, _threshold toFixed 3,
                                    _distFactor toFixed 2, _stanceFactor, _speedFactor, _skillFactor toFixed 2] call ALiVE_fnc_dump;
                            };

                            if (_trip >= _threshold) then {
                                _shouldDetonate = true;
                            };
                            }; // end else (challengeEnabled)
                        };
                    };
                } forEach _detonateList;

                // Decay trip pressure for engineers no longer in range.
                {
                    private _key = _x;
                    if !(_key in _engineersSeen) then {
                        private _trip = (_tripMap getOrDefault [_key, 0]) - _decayRate;
                        if (_trip <= 0) then {
                            _tripMap deleteAt _key;
                        } else {
                            _tripMap set [_key, _trip];
                        };
                    };
                } forEach (+(keys _tripMap));

                // With a trigger man the IED is his to set off, not a pressure device: free, he
                // fires it a second or two after anyone comes within 15 m of the blast radius;
                // gone, nothing sets it off.
                if (_dickerMode) then {
                    _shouldDetonate = false;
                    if (call _fnc_dickerFree) then {
                        private _near = ((_ied nearEntities [["Man", "LandVehicle"], _proximity + 15]) select {
                            alive _x && {((getposATL (vehicle _x)) select 2) < 8} && {!(_x isEqualTo _dicker)}
                            && {(_x in _players) || {((crew _x) findIf {_x in _players}) > -1} || {_aiTriggerable && {_x call ALiVE_fnc_iedAICounts}}}
                        }) isNotEqualTo [];
                        if (!_near) then { _dickerAt = -1 } else {
                            if (_dickerAt < 0) then { _dickerAt = time + 1 + random 2 };
                            if (time >= _dickerAt) then {
                                _shouldDetonate = true;
                                if (_debugLocal) then { ["ALIVE-%1 IED: trigger man %2 set off the IED at %3", time, name _dicker, getPosATL _ied] call ALiVE_fnc_dump };
                            };
                        };
                    };
                };

                if (_shouldDetonate) then {
                    private _iedPos = getpos _ied;
                    deletevehicle (_ied getVariable ["Detect_Trigger", objNull]);
                    deletevehicle (_ied getVariable ["Det_Trigger",    objNull]);
                    deletevehicle (_ied getVariable ["Trigger",        objNull]);
                    [ALiVE_mil_ied, "removeIED", _ied] call ALiVE_fnc_IED;
                    private _explosionPos = [_iedPos select 0, _iedPos select 1, 0];
                    private _explosionVehicle = _shell createVehicle _explosionPos;
                    // Fallback: defensive guard for any future ammo class
                    // that silently returns objNull from createVehicle the
                    // way M_Mo_120mm_AT does. R_60mm_HE is in the pool
                    // above and verified spawnable on the Ares retest.
                    if (isNull _explosionVehicle) then {
                        _explosionVehicle = "R_60mm_HE" createVehicle _explosionPos;
                    };
                    deletevehicle _ied;
                    _detonated = true;
                };

            }; // end isNull check
        }; // end while

        // The IED is gone, disarmed or blown. A trigger man still free walks off and is removed
        // once no player is within 400 m; a detained or dead one is left to the players.
        private _fnc_dickerLoose = { alive _dicker && {!captive _dicker} && {!(_dicker getVariable ["ace_captives_isHandcuffed", false])} };
        if (_dickerMode && _fnc_dickerLoose) then {
            _dicker enableAI "PATH";
            _dicker setUnitPos "AUTO";
            _dicker doWatch objNull;
            _dicker doMove (_dicker getPos [300, random 360]);
            waitUntil { sleep 10; !(call _fnc_dickerLoose) || {([getPosATL _dicker, 400] call ALiVE_fnc_anyPlayersInRange) == 0} };
            if (call _fnc_dickerLoose) then { deleteVehicle _dicker };
        };
    };

    // Stub triggers. Condition is hardcoded "false" so they never fire; detonation is
    // driven entirely by the polling loop above. They're kept on the IED, for every
    // machine, as removeIED and a player's disarm delete them by name.
    private _trg = createTrigger ["EmptyDetector", getposATL _ied];
    _trg setTriggerArea [1, 1, 0, false];
    _trg setTriggerActivation ["NONE", "PRESENT", false];
    _trg setTriggerStatements ["false", "", ""];
    _ied setVariable ["Trigger", _trg, true];

    private _trgDetect = createTrigger ["EmptyDetector", getposATL _ied];
    _trgDetect setTriggerArea [1, 1, 0, false];
    _trgDetect setTriggerActivation ["NONE", "PRESENT", false];
    _trgDetect setTriggerStatements ["false", "", ""];
    _ied setVariable ["Detect_Trigger", _trgDetect, true];

    private _trgDisarm = createTrigger ["EmptyDetector", getposATL _ied];
    _trgDisarm setTriggerArea [1, 1, 0, false];
    _trgDisarm setTriggerActivation ["NONE", "PRESENT", false];
    _trgDisarm setTriggerStatements ["false", "", ""];
    _ied setVariable ["Det_Trigger", _trgDisarm, true];
};

// Note: the per-IED triggers are created asynchronously above after the grace period.
// The IED object itself exists immediately; only the trigger creation is deferred.
