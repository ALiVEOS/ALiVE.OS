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
//       - engine `getUnitTrait "explosivesSpecialist"` returns true (Ares 2026-05-14)
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
    _shell = [["M_Mo_120mm_AT","M_Mo_120mm_AT_LG","M_Mo_82mm_AT_LG","R_60mm_HE","Bomb_04_F","Bomb_03_F"],[4,8,2,1,1,1]] call BIS_fnc_selectRandomWeighted;
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

        // DIAG-STRIP: confirm polling-loop entered post-waitUntil-cap.
        // Eric's RPT (Discord 2026-05-14) shows IEDs arming but no accum
        // / detonation logs -- distinguishing "loop never ran" from
        // "player never reached proximity" needs an entry log + a
        // first-candidate log. Strip once root cause identified.
        if (_debugLocal) then {
            ["ALIVE-%1 IED DIAG: polling loop entered for IED at %2 (proximity %3, threshold %4)",
                time, getposATL _ied, _proximity, _threshold toFixed 3] call ALiVE_fnc_dump;
        };
        private _loggedFirstCandidate = false;
        private _loggedFirstApproach = false;

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
                            (_x getUnitTrait "explosivesSpecialist") ||           // vanilla A3 explosives-specialist trait
                            ((_x getVariable ["ACE_isEngineer", 0]) > 0) ||       // ACE engineer level 1 or 2
                            (_x getVariable ["ACE_isEOD", false])                 // ACE EOD specialist (explosives role)
                        ) &&
                        (if (_aiTriggerable) then { true } else { _x in ([] call BIS_fnc_listPlayers) })
                    };
                    if (count _detectors > 0) then {
                        [_ied, _detection, _detectors, _detection, _device] call ALiVE_fnc_detectIED;
                        _detectedOnce = true;
                    };
                };

                // --- Detonation / accumulator check ---
                // Candidate pool: men + ground vehicles within proximity, alive, ground level.
                private _detonateList = _ied nearEntities ["Man", _proximity];
                _detonateList append (_ied nearEntities ["LandVehicle", _proximity]);
                _detonateList = _detonateList select {
                    alive _x && ((getposATL (vehicle _x)) select 2 < 8)
                };

                // DIAG-STRIP: 30m approach detection per IED. Companion to the
                // first-candidate log below. Eric's #890 retest (2026-05-15)
                // showed polling loop entered but no first-candidate log --
                // need to distinguish "player got near the area but missed
                // the tight 3-11m proximity" from "player never came close
                // at all". One-shot latch per IED.
                if (_debugLocal && !_loggedFirstApproach) then {
                    private _approachList = (_ied nearEntities ["Man", 30]) select {
                        alive _x && (_x in ([] call BIS_fnc_listPlayers))
                    };
                    if (count _approachList > 0) then {
                        private _details = _approachList apply {
                            format ["%1[%2]@%3m", name _x, typeOf _x, round (_x distance _ied)]
                        };
                        ["ALIVE-%1 IED DIAG: player(s) approached within 30m of IED at %2: %3",
                            time, getposATL _ied, _details] call ALiVE_fnc_dump;
                        _loggedFirstApproach = true;
                    };
                };

                // DIAG-STRIP: first-candidate visibility per IED. Confirms
                // a player actually entered this IED's proximity at least
                // once (companion to the polling-loop entry log above).
                // Strip once Eric's case is closed.
                if (_debugLocal && !_loggedFirstCandidate && count _detonateList > 0) then {
                    private _names = _detonateList apply { format ["%1[%2]", name _x, typeOf _x] };
                    ["ALIVE-%1 IED DIAG: first candidate(s) in proximity of IED at %2: %3",
                        time, getposATL _ied, _names] call ALiVE_fnc_dump;
                    _loggedFirstCandidate = true;
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
                        (_aiTriggerable || (_x in _players) || ((vehicle _x) in _players)) &&
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
                    private _isPlayer = (_u in _players) || (vehicle _u in _players);
                    private _relevant = _aiTriggerable || _isPlayer;

                    if (_relevant && !_shouldDetonate) then {
                        private _inVehicle = (vehicle _u) != _u;

                        // Engineer qualification applies to dismounted units only.
                        // Vehicle-borne engineers lose the exemption - vehicles aren't
                        // "carefully approaching".
                        private _qualifies = (!_inVehicle) && (
                            (_device in (items _u)) ||
                            (getText (configFile >> "CfgVehicles" >> typeOf _u >> "displayName") == "Explosive Specialist") ||
                            ([vehicleVarName _u, "EOD"] call CBA_fnc_find != -1) ||
                            (_u getUnitTrait "explosivesSpecialist") ||           // vanilla A3 explosives-specialist trait
                            ((_u getVariable ["ACE_isEngineer", 0]) > 0) ||       // ACE engineer level 1 or 2
                            (_u getVariable ["ACE_isEOD", false])                 // ACE EOD specialist (explosives role)
                        );

                        if (!_qualifies) then {
                            // Non-engineer or vehicle-borne: instant detonation (legacy behaviour).
                            _shouldDetonate = true;
                        } else {
                            if (!_challengeEnabled) then {
                                // Master toggle off: qualifying engineer is fully immune (legacy).
                                // Nothing to do - fall through without accumulating.
                                //
                                // DIAG-STRIP: surface this silent-immunity case so
                                // testers can see WHY a qualifying unit walked
                                // through proximity without anything happening.
                                // Ares's #890 dedicated-server RPT (2026-05-18)
                                // showed candidate-in-proximity but no accum / no
                                // detonation -- with the engineer-immune branch
                                // logging nothing, the silence was indistinguish-
                                // able from the loop having stalled. One log per
                                // engineer per IED via _loggedImmune (persists
                                // across the 0.5s poll cycles).
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

                if (_shouldDetonate) then {
                    deletevehicle (_ied getVariable ["Detect_Trigger", objNull]);
                    deletevehicle (_ied getVariable ["Det_Trigger",    objNull]);
                    deletevehicle (_ied getVariable ["Trigger",        objNull]);
                    [ALiVE_mil_ied, "removeIED", _ied] call ALiVE_fnc_IED;
                    _shell createVehicle [(getpos _ied) select 0, (getpos _ied) select 1, 0];
                    deletevehicle _ied;
                    _detonated = true;
                };

            }; // end isNull check
        }; // end while
    };

    // Stub triggers - kept so fnc_removeIED's nearObjects ["EmptyDetector",3] finds
    // something to clean up. Condition is hardcoded "false" so they never fire;
    // detonation is driven entirely by the polling loop above.
    private _trg = createTrigger ["EmptyDetector", getposATL _ied];
    _trg setTriggerArea [1, 1, 0, false];
    _trg setTriggerActivation ["NONE", "PRESENT", false];
    _trg setTriggerStatements ["false", "", ""];
    _ied setVariable ["Trigger", _trg];

    private _trgDetect = createTrigger ["EmptyDetector", getposATL _ied];
    _trgDetect setTriggerArea [1, 1, 0, false];
    _trgDetect setTriggerActivation ["NONE", "PRESENT", false];
    _trgDetect setTriggerStatements ["false", "", ""];
    _ied setVariable ["Detect_Trigger", _trgDetect];

    private _trgDisarm = createTrigger ["EmptyDetector", getposATL _ied];
    _trgDisarm setTriggerArea [1, 1, 0, false];
    _trgDisarm setTriggerActivation ["NONE", "PRESENT", false];
    _trgDisarm setTriggerStatements ["false", "", ""];
    _ied setVariable ["Det_Trigger", _trgDisarm];
};

// Note: the per-IED triggers are created asynchronously above after the grace period.
// The IED object itself exists immediately; only the trigger creation is deferred.
