#include "\x\alive\addons\mil_placement\script_component.hpp"
SCRIPT(MPplaceAA);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_MPplaceAA

Description:
Places a placement module's anti-air: up to the AA Count of the AA classes (or the
faction's default AA) spread over its objectives, as Military Placement always has.
Lifted out of fnc_MP so Civilian Placement places AA the same way.

Parameters:
Object - the placement module
Array - its objectives (clusters)
String - faction
String - side text
Number - how many to place
String - "static" or "roaming"
String - the AA classes picked, comma separated, or ""
Boolean - debug
String - on each spawn code
Boolean - on each spawn once

Returns:
Number - profiles created

Author:
Jman
---------------------------------------------------------------------------- */

params ["_logic", "_clusters", "_faction", "_side", "_aaCount", ["_aaBehaviour", "static"], ["_aaClasses", ""], ["_debug", false], ["_onEachSpawn", ""], ["_onEachSpawnOnce", true]];
private _countProfiles = 0;

    // AA placement.
    //
    // Per-cluster distribution: ceil(_aaCount / _clusterCount) slots
    // per cluster, capped at _aaCount total. Each slot validated via
    // findCompositionSpawnPosition mode="field" with envelope=10m
    // (unit footprint, not a composition envelope) so AA lands
    // on a clear non-runway / non-taxiway position. The mode is
    // spelled out below where the call is made; it is field, not
    // ato, and the difference matters because field keeps the
    // building check that ato skips. Crewed via
    // createProfileVehicle - the profile system populates the gun /
    // launcher crew and the engine AI engages incoming aircraft.
    //
    // Class resolution: picker CSV first, ALIVE_factionDefaultAA
    // hash fallback. Empty result skips the block with a debug
    // log so faction-default gaps are surfaced.
    //
    // _aaBehaviour ("static" / "roaming") tracked on
    // ALIVE_aaProfileBehaviour hash keyed by profileID - read-side
    // is consumed by OPCOM for movement decisions.
    if (_aaCount > 0 && {!isNil "_clusters"} && {count _clusters > 0}) then {
        private _resolved = [];
        if (_aaClasses != "") then {
            {
                private _t = _x;
                while {count _t > 0 && {(_t select [0, 1]) == " "}} do { _t = _t select [1] };
                while {count _t > 0 && {(_t select [count _t - 1, 1]) == " "}} do {
                    _t = _t select [0, count _t - 1];
                };
                if (_t != "") then { _resolved pushBackUnique _t };
            } forEach ([_aaClasses, ","] call CBA_fnc_split);
        };
        if (count _resolved == 0 && {!isNil "ALIVE_factionDefaultAA"}) then {
            // The faction's own list first, then, for a compiled faction, its config faction's,
            // which is where the supplies and supports look.
            private _hashVal = [ALIVE_factionDefaultAA, _faction] call ALIVE_fnc_hashGet;
            if (isNil "_hashVal") then { _hashVal = [ALIVE_factionDefaultAA, [_faction] call ALiVE_fnc_factionCompilerGetConfigFaction] call ALIVE_fnc_hashGet };
            if (!isNil "_hashVal" && {typeName _hashVal == "ARRAY"}) then { _resolved = _hashVal };
        };

        if (count _resolved > 0) then {
            private _aaPlaced = 0;
            private _aaSlotsPerCluster = ceil (_aaCount / (count _clusters));
            // Used-positions list shared across the cluster loop -
            // findCompositionSpawnPosition has no memory of prior
            // calls, so without an explicit exclusion the validator
            // returns near-identical positions on each call (the
            // "best" spot in a 50m radius is often a single dominant
            // candidate). 30m minimum separation - labels are
            // pushed to a 60m radial offset from cluster centre
            // with per-AA angular jitter, so AA-AA label spacing
            // is independent of AA-AA physical spacing.
            private _usedAAPositions = [];

            // Neighbour-aware search radius cap. Default 150m
            // gives the validator more room than the prior 50m
            // (which often yielded a single dominant candidate
            // and forced separation to fail). Cap at half the
            // distance to the nearest other placement-class
            // module so AA from this module never spawns into
            // territory another module owns. Floor 50m so
            // close-packed modules still have a workable area;
            // ceiling 200m so a lone module on a giant TAOR
            // doesn't search a useless 1km radius.
            private _aaNeighbours = [];
            {
                _aaNeighbours = _aaNeighbours + (allMissionObjects _x);
            } forEach ["ALiVE_mil_placement", "ALiVE_mil_placement_custom",
                       "ALiVE_mil_placement_spe", "ALiVE_civ_placement",
                       "ALiVE_civ_placement_custom", "ALiVE_mil_ato"];
            _aaNeighbours = _aaNeighbours - [_logic];
            {
                if (_aaPlaced >= _aaCount) exitWith {};
                // _clusters elements are hashmaps - "center" key
                // holds the cluster centre position (existing pattern
                // at fnc_MP.sqf:840 / 902 / 1921). `position _x`
                // throws Type Array vs Object on hashmaps.
                private _clusterPos = [_x, "center"] call ALIVE_fnc_hashGet;
                if (isNil "_clusterPos" || {typeName _clusterPos != "ARRAY"}) then { _clusterPos = [0,0,0] };

                // Per-cluster search radius - cap at half-distance
                // to nearest neighbouring placement module from
                // THIS cluster's position (clusters in a large
                // module can be 200m+ from the module's editor
                // position, so neighbour distance varies).
                private _aaSearchRadius = 150;
                {
                    private _gap = (position _x) distance2D _clusterPos;
                    if (_gap > 0 && {_gap / 2 < _aaSearchRadius}) then {
                        _aaSearchRadius = _gap / 2;
                    };
                } forEach _aaNeighbours;
                if (_aaSearchRadius < 50) then { _aaSearchRadius = 50 };
                if (_aaSearchRadius > 200) then { _aaSearchRadius = 200 };
                if (_debug) then {
                    ["MP [%1] - AA cluster radius=%2m (neighbours=%3)", _faction, _aaSearchRadius, count _aaNeighbours] call ALiVE_fnc_dump;
                };

                for "_i" from 1 to _aaSlotsPerCluster do {
                    if (_aaPlaced >= _aaCount) exitWith {};
                    private _aaClass = selectRandom _resolved;
                    // mode="field" excludes buildings + helipads
                    // + runways/taxiways + ALL roads. Static AA
                    // shouldn't sit in hangars (mode="ato" allows
                    // that), on helipads (block resupply), on
                    // runways (block aircraft), or on roads (block
                    // vehicle traffic + AA tips on cambered road
                    // surfaces). field mode is the only one with
                    // the road-exclusion flag set.
                    //
                    // Angular sweep: build a ring-grid of candidate
                    // centres around _clusterPos (12 angles x 4
                    // distance rings = 48 candidates), shuffle for
                    // run-to-run variation, then validate each in
                    // shuffled order until one passes the field-
                    // mode clear check AND the 30m separation
                    // check. Candidates beyond _aaSearchRadius
                    // (neighbour-aware cap) are skipped, so the
                    // sweep never infringes on an adjacent
                    // placement module's territory.
                    private _safePos = [];
                    private _safeDir = 0;
                    private _accepted = false;
                    private _candidates = [];
                    {
                        private _ring = _x;
                        for "_a" from 0 to 11 do {
                            private _angle = _a * 30 + (random 25);
                            _candidates pushBack [
                                (_clusterPos select 0) + _ring * (sin _angle),
                                (_clusterPos select 1) + _ring * (cos _angle),
                                _clusterPos param [2, 0]
                            ];
                        };
                    } forEach [40, 70, 100, 130];
                    _candidates = _candidates call BIS_fnc_arrayShuffle;
                    {
                        if (_accepted) exitWith {};
                        private _cand = _x;
                        if ((_cand distance2D _clusterPos) <= _aaSearchRadius) then {
                            private _aaResult = [_cand, 20, 10, "field", random 360, _debug, 0.6] call ALiVE_fnc_findCompositionSpawnPosition;
                            if (count _aaResult >= 2) then {
                                private _testPos = _aaResult select 0;
                                // Post-validator road backstop -
                                // layered. nearRoads catches CfgRoads;
                                // isOnRoad ring samples catch
                                // unclassified drivable surfaces.
                                private _onRoad = count (_testPos nearRoads 15) > 0;
                                if (!_onRoad) then {
                                    for "_a" from 0 to 7 do {
                                        private _samplePt = _testPos getPos [6, _a * 45];
                                        if (isOnRoad _samplePt) exitWith { _onRoad = true; };
                                    };
                                };
                                private _tooClose = _onRoad;
                                { if (_testPos distance2D _x < 30) exitWith { _tooClose = true } } forEach _usedAAPositions;
                                if (!_tooClose) then {
                                    _safePos = _testPos;
                                    _safeDir = _aaResult select 1;
                                    _accepted = true;
                                };
                            };
                        };
                    } forEach _candidates;
                    if (_accepted) then {
                        _usedAAPositions pushBack _safePos;
                        // Crew-bearing classes (POOK SAM SA-19 / SA-22
                        // family and any non-StaticWeapon mod AA
                        // vehicle) need explicit crew profiles -
                        // createProfileVehicle alone leaves the
                        // gunner seat empty, so the gun never
                        // engages. createProfilesCrewedVehicle
                        // adds the crew unit profiles + vehicle
                        // assignment so gunner / loader spawn
                        // alongside the vehicle.
                        private _aaCrewClass = getText (configFile >> "CfgVehicles" >> _aaClass >> "crew");
                        private _aaProfile = if (_aaCrewClass != "") then {
                            private _profiles = [_aaClass, _side, _faction, "PRIVATE", _safePos, _safeDir, false, _faction] call ALIVE_fnc_createProfilesCrewedVehicle;
                            // The On unit spawn scripts go on the crew, as they do for the module's other groups.
                            [_profiles select 0, "onEachSpawn", _onEachSpawn] call ALIVE_fnc_profileEntity;
                            [_profiles select 0, "onEachSpawnOnce", _onEachSpawnOnce] call ALIVE_fnc_profileEntity;
                            _profiles select 1
                        } else {
                            [_aaClass, _side, _faction, _safePos, _safeDir, false, _faction] call ALIVE_fnc_createProfileVehicle
                        };
                        // aaBehaviour stored on a side-channel hash
                        // keyed by profileID. fnc_profileVehicle is
                        // fixed-case dispatch, no generic field
                        // setter; the OPCOM consumer reads from
                        // ALIVE_aaProfileBehaviour to decide
                        // movement orders.
                        if (!isNil "_aaProfile") then {
                            private _profileID = [_aaProfile, "profileID"] call ALIVE_fnc_profileVehicle;
                            if (typeName _profileID == "STRING" && {_profileID != ""}) then {
                                if (isNil "ALIVE_aaProfileBehaviour") then {
                                    ALIVE_aaProfileBehaviour = [] call ALIVE_fnc_hashCreate;
                                };
                                [ALIVE_aaProfileBehaviour, _profileID, _aaBehaviour] call ALIVE_fnc_hashSet;
                            };
                            // Force upright when behaviour is static.
                            // Helper records position-grid key in a
                            // registry + class init EH so re-
                            // activations after virtualisation
                            // re-apply setVectorUp (profile schema
                            // only stores pos+dir, not vectorUp).
                            // Roaming AA skipped - vehicles need
                            // terrain alignment for normal physics.
                            if (_aaBehaviour == "static") then {
                                // Profile-spawn path: slot 10 is
                                // objNull until the profile activates.
                                // Pass classname + position so the
                                // helper wires the class init EH that
                                // fires when the engine creates the
                                // entity on activation.
                                [objNull, _safeDir, _aaClass, _safePos] call ALIVE_fnc_registerForceUpright;
                            };
                        };
                        _countProfiles = _countProfiles + 1;
                        _aaPlaced = _aaPlaced + 1;

                        if (_debug) then {
                            // Anchor dot at actual spawn position +
                            // labeled marker at radial offset away
                            // from cluster centre. Pushes the AA
                            // label clear of the cluster's own
                            // label (e.g. "FACTION|MIL|size|prio")
                            // which renders at the cluster anchor.
                            // Per-index angular jitter fans labels
                            // of co-radial AA out to different
                            // angles so they don't stack either.
                            private _aaLabel = format ["AA #%1 [%2]", _aaPlaced, _aaBehaviour];
                            private _dx = (_safePos select 0) - (_clusterPos select 0);
                            private _dy = (_safePos select 1) - (_clusterPos select 1);
                            private _norm = sqrt (_dx * _dx + _dy * _dy);
                            if (_norm < 1) then { _dx = 1; _dy = 0; _norm = 1 };
                            _dx = _dx / _norm; _dy = _dy / _norm;
                            private _jitterAngles = [0, 30, -30, 60, -60, 90, -90];
                            private _jit = _jitterAngles select ((_aaPlaced - 1) mod (count _jitterAngles));
                            private _cosJ = cos _jit; private _sinJ = sin _jit;
                            private _rdx = _cosJ * _dx - _sinJ * _dy;
                            private _rdy = _sinJ * _dx + _cosJ * _dy;
                            private _labelPos = [(_safePos select 0) + _rdx * 60, (_safePos select 1) + _rdy * 60, _safePos param [2, 0]];
                            [_safePos, 1, "", "ColorBlue"] call ALIVE_fnc_placeDebugMarker;
                            [_labelPos, 3, _aaLabel, "ColorBlue"] call ALIVE_fnc_placeDebugMarker;
                        };
                    };
                };
            } forEach _clusters;

            if (_debug) then {
                ["MP [%1] - AA units placed: %2 of %3 (behaviour=%4, sources=%5)",
                    _faction, _aaPlaced, _aaCount, _aaBehaviour,
                    if (_aaClasses != "") then {"picker"} else {"factionDefault"}
                ] call ALiVE_fnc_dump;
            };
        } else {
            if (_debug) then {
                ["MP [%1] - AA spawn skipped: picker empty AND no ALIVE_factionDefaultAA entry for this faction", _faction] call ALiVE_fnc_dump;
            };
        };
    };

_countProfiles
