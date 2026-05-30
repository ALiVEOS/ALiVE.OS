#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(COPServer);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_COPServer

Description:
    Server-side COP polling entry point.

    Wiring:
      1. Wait for OPCOM_instances and ALiVE_ProfileHandler.
      2. Discover one conventional OPCOM per side ("WEST"/"EAST"/"GUER"),
         preferring the one with the most objectives if multiple exist.
         Asymmetric OPCOMs are handled in ALIVE_fnc_COPAsym.
      3. Seed four inner helpers as globals (COPBuildSpotrep,
         COPClusterEnemy, COPBuildBFT, COPDeriveActivity).
      4. Initialise publicVariable channels with empty arrays for JIP.
      5. Spawn Loop A (30 s cycle: enemies + BFT).
      6. Spawn Loop B (60 s cycle: objectives).

    Graceful shutdown via ALIVE_COP_SERVER_RUNNING flag.

Parameters:
    (none — called via `[] spawn ALIVE_fnc_COPServer` from COPInit)

Returns:
    BOOL - true when the loops have been spawned; false on any guard failure.

Author:
    Goldwep (ALiVE Mod Team)
    Jman
---------------------------------------------------------------------------- */

TRACE_1("COPServer - input",_this);

if (!isServer) exitWith {
    ["error", "server", "COPServer invoked on non-server machine — aborting"] call ALIVE_fnc_COPLog;
    false
};

["info", "server", "Starting COP server loops..."] call ALIVE_fnc_COPLog;

// ============================================================================
// WAIT FOR ALiVE
// ============================================================================
["debug", "server", "Waiting for OPCOM_instances and ALiVE_ProfileHandler..."] call ALIVE_fnc_COPLog;

waitUntil { sleep 5; !isNil "OPCOM_instances" && {count OPCOM_instances > 0} };
waitUntil { sleep 5; !isNil "ALiVE_ProfileHandler" };

// OPCOM needs one analysis cycle to populate objectives + knownentities.
["debug", "server", "OPCOM detected; waiting 45s for first analysis cycle..."] call ALIVE_fnc_COPLog;
sleep 45;

["info", "server", "ALiVE ready. %1 OPCOM instance(s) found.", [count OPCOM_instances]] call ALIVE_fnc_COPLog;

// ============================================================================
// OPCOM DISCOVERY — one canonical OPCOM per side (prefer most objectives)
// ============================================================================
ALIVE_COP_OPCOMS = createHashMap;

{
    private _opcom = _x;
    private _side = [_opcom, "side", ""] call ALiVE_fnc_HashGet;
    private _controltype = [_opcom, "controltype", ""] call ALiVE_fnc_HashGet;

    // Asymmetric OPCOMs are Layer 5 — handled in ALIVE_fnc_COPAsym.
    if (_controltype == "asymmetric") then { continue };

    if (_side != "" && {_side in ["WEST", "EAST", "GUER"]}) then {
        private _objectives = [_opcom, "objectives", []] call ALiVE_fnc_HashGet;
        private _newCount = count _objectives;

        if (_side in ALIVE_COP_OPCOMS) then {
            private _existing = ALIVE_COP_OPCOMS get _side;
            private _existingObjs = [_existing, "objectives", []] call ALiVE_fnc_HashGet;
            if (_newCount > count _existingObjs) then {
                ALIVE_COP_OPCOMS set [_side, _opcom];
                ["info", "server", "Replaced %1 OPCOM (had %2 objectives, new has %3).", [_side, count _existingObjs, _newCount]] call ALIVE_fnc_COPLog;
            };
        } else {
            ALIVE_COP_OPCOMS set [_side, _opcom];
            ["info", "server", "Tracking %1 OPCOM (%2 objectives, controltype: %3).", [_side, _newCount, _controltype]] call ALIVE_fnc_COPLog;
        };
    };
} forEach OPCOM_instances;

if (count ALIVE_COP_OPCOMS == 0) exitWith {
    ["warn", "server", "No conventional OPCOMs found. Loop A/B will not start (Layer 5 asym may still run independently)."] call ALIVE_fnc_COPLog;
    ALIVE_COP_SERVER_RUNNING = false;
    false
};

// ============================================================================
// PROFILE FIRST-SEEN TRACKING (for marker age / staleness display)
// ============================================================================
// OPCOM's knownentities is rebuilt each TACOM cycle as [profileID, pos] pairs
// with no timestamp. To produce a meaningful age value for the COP marker
// label ("(Nm)") and the alpha-fade logic, COP tracks first-sighting time
// per profileID itself. Loop A stamps new IDs with `diag_tickTime`, leaves
// existing stamps untouched, and prunes IDs that drop out of every OPCOM's
// known list this cycle. A re-acquired contact after dropout gets a fresh
// stamp — the field is "duration of CURRENT continuous-contact engagement",
// not lifetime sighting.
if (isNil "ALIVE_COP_PROFILE_FIRST_SEEN") then {
    ALIVE_COP_PROFILE_FIRST_SEEN = createHashMap;
};

// ============================================================================
// INITIALISE BROADCAST CHANNELS (empty arrays for JIP)
// Third-arg `true` makes these JIP-persistent — a late joiner receives the
// last broadcast value (initially []), so the Draw EH always finds the
// variable defined and never reads the missing-variable default. The
// COPBroadcastIfChanged helper uses the same pattern for cycle updates.
// ============================================================================
missionNamespace setVariable ["ALiVE_COP_IntelData_WEST",      [], true];
missionNamespace setVariable ["ALiVE_COP_IntelData_EAST",      [], true];
missionNamespace setVariable ["ALiVE_COP_IntelData_GUER",      [], true];

missionNamespace setVariable ["ALiVE_COP_BftData_WEST",        [], true];
missionNamespace setVariable ["ALiVE_COP_BftData_EAST",        [], true];
missionNamespace setVariable ["ALiVE_COP_BftData_GUER",        [], true];

missionNamespace setVariable ["ALiVE_COP_ObjectivesData_WEST", [], true];
missionNamespace setVariable ["ALiVE_COP_ObjectivesData_EAST", [], true];
missionNamespace setVariable ["ALiVE_COP_ObjectivesData_GUER", [], true];

// ============================================================================
// INNER HELPERS (globals so spawned loops can call them)
// ============================================================================

// ----------------------------------------------------------------------------
// ALIVE_fnc_COPBuildSpotrep — profile → single enemy spotrep entry
// Returns: [pos, sideKey, type, factionCode, count, sizeInd, activity,
//           heading, speed, age]  or nil if profile invalid
// Age is supplied by Loop A from ALIVE_COP_PROFILE_FIRST_SEEN, expressed in
// seconds since the contact was first established in this engagement.
// ----------------------------------------------------------------------------
ALIVE_fnc_COPBuildSpotrep = {
    params [["_profileID", "", [""]], ["_pos", [0,0,0], [[]]], ["_age", 0, [0]]];

    private _profile = [ALiVE_ProfileHandler, "getProfile", _profileID] call ALiVE_fnc_ProfileHandler;
    if (isNil "_profile") exitWith { nil };

    private _profileSide = "";
    private _faction = "";
    private _units = [];
    private _speedArr = [0, 0];

    // Defensive count guards — ALiVE profile tuple indexes (sys_profile):
    //   data[3]  = side        data[21] = units
    //   data[5]  = type         data[22] = speedPerSecond tuple
    //   data[8]  = vehicles     data[16] = waypoints (for heading)
    //   data[29] = faction
    if (count _profile >= 3) then {
        private _data = _profile select 2;
        if (count _data >= 4)  then { _profileSide = _data select 3; };
        if (count _data >= 30) then { _faction     = _data select 29; };
        if (count _data >= 22) then { _units       = _data select 21; };
        if (count _data >= 23) then { _speedArr    = _data select 22; };
    };

    private _type = [_profile] call ALIVE_fnc_COPTypeFromProfile;
    private _factionCode = [_faction] call ALIVE_fnc_COPFactionShortCode;
    private _count = count _units max 1;
    private _sizeInd = [_count] call ALIVE_fnc_COPSizeIndicator;

    // Speed classification: 0=stationary, 1=slow, 2=med, 3=fast
    private _speedVal = if (_speedArr isEqualType []) then {
        ((_speedArr select 1) max 0) min 99
    } else { 0 };
    private _speed = if (_speedVal < ALIVE_COP_SPEED_STATIONARY) then { 0 }
                   else { if (_speedVal < ALIVE_COP_SPEED_SLOW)  then { 1 }
                   else { if (_speedVal < ALIVE_COP_SPEED_MED)   then { 2 }
                   else { 3 } } };

    // Heading from first waypoint if available; fall back to 0.
    private _heading = 0;
    if (count _profile >= 3) then {
        private _data = _profile select 2;
        if (count _data >= 17) then {
            private _waypoints = _data select 16;
            if (_waypoints isEqualType [] && {count _waypoints > 0}) then {
                private _wp = (_waypoints select 0);
                if (_wp isEqualType [] && {count _wp >= 2}) then {
                    private _wpPos = _wp select 1;
                    // Stricter dimension check: getDir expects a 2- or 3-element
                    // position. Some profile types put a non-position object at
                    // waypoint[1] (observed: 13-element array). Treat anything
                    // outside the position shape as no-heading rather than
                    // letting getDir throw mid-spotrep build.
                    if (
                        _wpPos isEqualType []
                        && {count _wpPos >= 2}
                        && {count _wpPos <= 3}
                        && {_pos isEqualType []}
                        && {count _pos >= 2}
                        && {count _pos <= 3}
                    ) then {
                        _heading = _pos getDir _wpPos;
                    };
                };
            };
        };
    };

    // Activity derived later from observing commander's nearest objective.
    [_pos, _profileSide, _type, _factionCode, _count, _sizeInd, "", _heading, _speed, _age]
};

// ----------------------------------------------------------------------------
// ALIVE_fnc_COPClusterEnemy — cluster + filter spotreps for one side
// Output entry: [pos, sideKey, type, factionCode, count, sizeInd, activity,
//                heading, speed, age=0, isMixed, trail]
// ----------------------------------------------------------------------------
ALIVE_fnc_COPClusterEnemy = {
    params [["_spotreps", [], [[]]]];

    if (count _spotreps == 0) exitWith { [] };

    // Grid-bucket player positions for the lone-infantry filter. Bucket size
    // equals ALIVE_COP_PLAYER_RADIUS so each spotrep only needs to check its
    // own cell plus the 8 neighbors to find any player within radius. At
    // 40-player scale this turns an O(spotreps × players) scan into an
    // effectively O(spotreps × k) where k is the average players-per-cell
    // (typically 2-3 even in concentrated FOBs).
    private _playerBucketSize = ALIVE_COP_PLAYER_RADIUS;
    private _playerBuckets = createHashMap;
    {
        private _ppos = _x;
        private _pbx = floor ((_ppos select 0) / _playerBucketSize);
        private _pby = floor ((_ppos select 1) / _playerBucketSize);
        private _pkey = format ["%1_%2", _pbx, _pby];
        private _pbucket = _playerBuckets getOrDefault [_pkey, []];
        _pbucket pushBack _ppos;
        _playerBuckets set [_pkey, _pbucket];
    } forEach (allPlayers apply { getPos _x });

    // Lone-infantry filter before clustering.
    private _filtered = [];
    {
        private _spotrep = _x;
        private _type = _spotrep select 2;
        private _count = _spotrep select 4;
        private _keep = false;

        if (_type in ALIVE_COP_ALWAYS_SHOW) then {
            _keep = true;
        } else {
            if (_count > 1) then {
                _keep = true;
            } else {
                if (ALIVE_COP_FILTER_LONE_INF && {_type == "infantry"}) then {
                    private _spotPos = _spotrep select 0;
                    private _sbx = floor ((_spotPos select 0) / _playerBucketSize);
                    private _sby = floor ((_spotPos select 1) / _playerBucketSize);
                    // Check the 9 cells around the spotrep (its own + 8 neighbors).
                    for "_dx" from -1 to 1 do {
                        if (_keep) exitWith {};
                        for "_dy" from -1 to 1 do {
                            if (_keep) exitWith {};
                            private _pkey = format ["%1_%2", _sbx + _dx, _sby + _dy];
                            private _pbucket = _playerBuckets getOrDefault [_pkey, []];
                            {
                                if (_spotPos distance2D _x < ALIVE_COP_PLAYER_RADIUS) exitWith {
                                    _keep = true;
                                };
                            } forEach _pbucket;
                        };
                    };
                } else {
                    _keep = true;
                };
            };
        };

        if (_keep) then { _filtered pushBack _spotrep };
    } forEach _spotreps;

    // Grid-bucket clustering.
    private _clusters = [_filtered, ALIVE_COP_CLUSTER_RADIUS] call ALIVE_fnc_COPClusterByGrid;

    // Reduce each cluster to a single entry.
    private _result = [];
    {
        private _cluster = _x;
        if (count _cluster == 0) then { continue };

        private _center = [_cluster] call ALIVE_fnc_COPClusterCenter;
        private _types = _cluster apply { _x select 2 };
        private _dominant = [_types] call ALIVE_fnc_COPDominantType;
        private _totalCount = 0;
        { _totalCount = _totalCount + (_x select 4); } forEach _cluster;

        // Dominant unit's faction code (first cluster member is representative).
        private _factionCode = (_cluster select 0) select 3;
        private _sizeInd = [_totalCount] call ALIVE_fnc_COPSizeIndicator;

        // Movement from the first moving unit, if any.
        private _heading = 0;
        private _speed = 0;
        {
            if ((_x select 8) > 0) exitWith {
                _heading = _x select 7;
                _speed = _x select 8;
            };
        } forEach _cluster;

        // Activity from first cluster member (re-derived below from objectives).
        private _activity = (_cluster select 0) select 6;

        // Stable key for trail tracking.
        private _bx = floor ((_center select 0) / ALIVE_COP_CLUSTER_RADIUS);
        private _by = floor ((_center select 1) / ALIVE_COP_CLUSTER_RADIUS);
        private _trailKey = format ["%1_%2_%3", _dominant, _bx, _by];

        private _trail = ALIVE_COP_TRAILS getOrDefault [_trailKey, []];
        _trail = [_center] + _trail;
        if (count _trail > ALIVE_COP_TRAIL_LENGTH) then {
            _trail resize ALIVE_COP_TRAIL_LENGTH;
        };
        ALIVE_COP_TRAILS set [_trailKey, _trail];

        // Cluster side from first member (all share same side — grouped from
        // the same OPCOM's knownentities).
        private _clusterSide = (_cluster select 0) select 1;

        // Compact "isMixed" bool instead of broadcasting the full types array.
        private _isMixed = false;
        {
            if (_x != _dominant) exitWith { _isMixed = true; };
        } forEach _types;

        // Cluster age = youngest member (most recent refresh). When a fresh
        // contact joins a stale cluster the cluster appears fresh again —
        // matches "intel was just refreshed somewhere in this group" intuition
        // and keeps the alpha-fade from making active engagements look dead.
        // Spotrep tuple index 9 is age (added by COPBuildSpotrep).
        private _youngestAge = 1e9;
        {
            private _spotrepAge = _x select 9;
            if (_spotrepAge < _youngestAge) then { _youngestAge = _spotrepAge };
        } forEach _cluster;
        if (_youngestAge >= 1e9) then { _youngestAge = 0 };

        _result pushBack [_center, _clusterSide, _dominant, _factionCode, _totalCount, _sizeInd,
                          _activity, _heading, _speed, _youngestAge, _isMixed, _trail];
    } forEach _clusters;

    _result
};

// ----------------------------------------------------------------------------
// ALIVE_fnc_COPBuildBFT — friendly-force tracking for one side
// Anchors = players only (no mission-specific FOB/hub sources per port principles).
// Deduplicates anchors within 2 km of each other to avoid redundant spatial
// queries when players are clustered.
// ----------------------------------------------------------------------------
ALIVE_fnc_COPBuildBFT = {
    params [["_sideKey", "", [""]]];

    // ALiVE's getNearProfiles side filter is a FLAT string ("WEST"/"EAST"/
    // "GUER"/"CIV"). Wrapping in an extra array silently returns zero.
    private _sideStr = _sideKey;

    // Grid-bucket anchor selection: one anchor per 5 km cell. Replaces the
    // prior O(anchors²) 2 km dedup loop with an O(players) hash-bucket pass.
    // At 40 players clustered in 3-5 AOs this reduces the subsequent
    // getNearProfiles call count from ~15-20 down to ~3-8, proportional to
    // distinct AOs rather than raw player count.
    private _anchorBucketSize = 5000;
    private _anchorBuckets = createHashMap;
    {
        if (([side group _x] call ALIVE_fnc_COPGetSideKey) == _sideKey) then {
            private _pos = getPos _x;
            private _abx = floor ((_pos select 0) / _anchorBucketSize);
            private _aby = floor ((_pos select 1) / _anchorBucketSize);
            private _akey = format ["%1_%2", _abx, _aby];
            if (!(_akey in _anchorBuckets)) then {
                // First player seen in this cell becomes the query anchor.
                _anchorBuckets set [_akey, _pos];
            };
        };
    } forEach allPlayers;

    private _anchors = values _anchorBuckets;

    if (count _anchors == 0) exitWith {
        ["debug", "server", "[BFT %1] no player anchors — skipping", [_sideKey]] call ALIVE_fnc_COPLog;
        []
    };

    // Spatial query around each anchor.
    private _searchRadius = ALIVE_COP_BFT_SEARCH_RADIUS;
    private _seen = createHashMap;
    private _positions = [];
    private _rawProfileCount = 0;

    {
        private _anchor = _x;
        private _nearProfiles = [_anchor, _searchRadius, [_sideStr, "entity"]] call ALIVE_fnc_getNearProfiles;
        _rawProfileCount = _rawProfileCount + count _nearProfiles;
        {
            private _profile = _x;
            // Dedup by profileID across overlapping anchor queries.
            private _profileID = "";
            if (count _profile >= 3) then {
                private _data = _profile select 2;
                if (count _data >= 5) then { _profileID = _data select 4; };
            };
            if (_profileID != "" && {!(_profileID in _seen)}) then {
                _seen set [_profileID, true];

                private _pos = [0, 0, 0];
                private _units = [];
                private _faction = "";
                if (count _profile >= 3) then {
                    private _data = _profile select 2;
                    if (count _data >= 3)  then { _pos     = _data select 2; };
                    if (count _data >= 22) then { _units   = _data select 21; };
                    if (count _data >= 30) then { _faction = _data select 29; };
                };
                private _type = [_profile] call ALIVE_fnc_COPTypeFromProfile;
                private _factionCode = [_faction] call ALIVE_fnc_COPFactionShortCode;
                private _count = count _units max 1;
                _positions pushBack [_pos, _type, _count, _factionCode];
            };
        } forEach _nearProfiles;
    } forEach _anchors;

    // Cluster.
    private _clusters = [_positions, ALIVE_COP_BFT_CLUSTER_RADIUS] call ALIVE_fnc_COPClusterByGrid;

    private _result = [];
    {
        private _cluster = _x;
        if (count _cluster == 0) then { continue };

        private _center = [_cluster] call ALIVE_fnc_COPClusterCenter;
        private _types = _cluster apply { _x select 1 };
        private _dominant = [_types] call ALIVE_fnc_COPDominantType;
        private _totalCount = 0;
        { _totalCount = _totalCount + (_x select 2); } forEach _cluster;
        private _sizeInd = [_totalCount] call ALIVE_fnc_COPSizeIndicator;

        // Faction code = first cluster member's faction (matches enemy
        // cluster-reduce convention in COPClusterEnemy). Mixed-faction
        // friendly clusters are rare; if they ever become common a dominant-
        // by-count reduction can replace the "first member" pick.
        private _factionCode = (_cluster select 0) select 3;
        if (isNil "_factionCode") then { _factionCode = "" };

        // Side at index 1 mirrors the enemy spotrep tuple shape ([pos, side,
        // type, ...]). Lets the client renderer color BFT markers correctly
        // when copDisplaySides has the player combining multiple side feeds
        // — without the explicit side field, all BFT entries would render in
        // the player's own side colour regardless of origin.
        _result pushBack [_center, _sideKey, _dominant, _totalCount, _sizeInd, _factionCode];
    } forEach _clusters;

    // Zero profiles despite anchors → info-level (not warning) so it surfaces
    // in normal RPT without flooding. Anchor positions included for diagnosis
    // (rounded to integer to keep the line readable) — lets the operator verify
    // whether the search happened where they expected, e.g. when allPlayers
    // reports players but their positions are off-map / at spawn lobby / etc.
    private _anchorSummary = _anchors apply {
        format ["[%1,%2]", round (_x select 0), round (_x select 1)]
    };
    if (count _anchors > 0 && _rawProfileCount == 0) then {
        ["info", "server", "[BFT %1] 0 profiles from %2 anchor(s) at r=%3m | anchors=%4", [_sideKey, count _anchors, _searchRadius, _anchorSummary]] call ALIVE_fnc_COPLog;
    } else {
        ["debug", "server", "[BFT %1] anchors=%2 rawProfiles=%3 deduped=%4 clusters=%5 | anchors=%6", [_sideKey, count _anchors, _rawProfileCount, count _positions, count _result, _anchorSummary]] call ALIVE_fnc_COPLog;
    };

    _result
};

// ----------------------------------------------------------------------------
// ALIVE_fnc_COPDeriveActivity — derive activity letter from nearest objective
// Accepts optional cached objectives array so the caller can avoid one
// ALiVE_fnc_HashGet per cluster (saves O(clusters) hash reads per cycle).
// ----------------------------------------------------------------------------
ALIVE_fnc_COPDeriveActivity = {
    params [["_pos", [0,0,0], [[]]], ["_sideKey", "", [""]], ["_cachedObjectives", [], [[]]]];

    private _objectives = _cachedObjectives;

    if (count _objectives == 0) then {
        if (!(_sideKey in ALIVE_COP_OPCOMS)) exitWith {};
        private _opcom = ALIVE_COP_OPCOMS get _sideKey;
        _objectives = [_opcom, "objectives", []] call ALiVE_fnc_HashGet;
    };

    if (count _objectives == 0) exitWith { "" };

    private _closestIdx = -1;
    private _closestDist = 1e9;
    {
        private _center = [_x, "center", [0,0,0]] call ALiVE_fnc_HashGet;
        private _d = _pos distance2D _center;
        if (_d < _closestDist) then {
            _closestDist = _d;
            _closestIdx = _forEachIndex;
        };
    } forEach _objectives;

    if (_closestIdx == -1) exitWith { "" };

    private _closest = _objectives select _closestIdx;
    private _state = [_closest, "opcom_state", ""] call ALiVE_fnc_HashGet;
    [_state] call ALIVE_fnc_COPGetActivityFromState
};

// ============================================================================
// LOOP A — INTEL + BFT (fast cycle, 30 s default)
// ============================================================================
[] spawn {
    ["info", "server", "Loop A starting (interval: %1s)", [ALIVE_COP_INTERVAL_FAST]] call ALIVE_fnc_COPLog;

    private _cycleCount = 0;

    while {ALIVE_COP_SERVER_RUNNING} do {

        private _tStart = diag_tickTime;
        _cycleCount = _cycleCount + 1;

        // ----- Build per-side enemy spotrep arrays -----
        private _enemiesWEST = [];
        private _enemiesEAST = [];
        private _enemiesGUER = [];
        private _profilesProcessed = 0;
        private _profilesFailed = 0;

        // Profiles seen by ANY OPCOM this cycle — used at end of phase to
        // prune dropped entries from ALIVE_COP_PROFILE_FIRST_SEEN so a
        // re-acquired contact starts age tracking fresh.
        private _seenThisCycle = createHashMap;

        if (ALIVE_COP_LAYER_ENEMIES) then {
            private _now = diag_tickTime;
            {
                private _opcomSide = _x;
                private _opcom = _y;

                private _known = [_opcom, "knownentities", []] call ALiVE_fnc_HashGet;

                ["debug", "server", "[Cycle %1] OPCOM %2 knows %3 enemies", [_cycleCount, _opcomSide, count _known]] call ALIVE_fnc_COPLog;

                {
                    _x params ["_profileID", "_pos"];

                    // First-seen tracking: stamp on first sight, keep on
                    // subsequent. Age = current time - first sight.
                    if (!(_profileID in ALIVE_COP_PROFILE_FIRST_SEEN)) then {
                        ALIVE_COP_PROFILE_FIRST_SEEN set [_profileID, _now];
                    };
                    _seenThisCycle set [_profileID, true];
                    private _age = _now - (ALIVE_COP_PROFILE_FIRST_SEEN get _profileID);

                    private _spotrep = [_profileID, _pos, _age] call ALIVE_fnc_COPBuildSpotrep;
                    if (!isNil "_spotrep") then {
                        _profilesProcessed = _profilesProcessed + 1;
                        // Bucket by the OBSERVING commander's side — that's whose
                        // intel feed sees this contact.
                        switch (toUpper _opcomSide) do {
                            case "WEST": { _enemiesWEST pushBack _spotrep };
                            case "EAST": { _enemiesEAST pushBack _spotrep };
                            case "GUER": { _enemiesGUER pushBack _spotrep };
                        };
                    } else {
                        _profilesFailed = _profilesFailed + 1;
                        ["debug", "profile", "Failed to build spotrep for profile %1 at %2", [_profileID, _pos]] call ALIVE_fnc_COPLog;
                    };
                } forEach _known;
            } forEach ALIVE_COP_OPCOMS;

            // Prune profile IDs that no OPCOM saw this cycle. A re-acquired
            // contact next cycle gets a fresh first-seen stamp.
            private _toRemove = [];
            {
                if (!(_x in _seenThisCycle)) then { _toRemove pushBack _x };
            } forEach (keys ALIVE_COP_PROFILE_FIRST_SEEN);
            { ALIVE_COP_PROFILE_FIRST_SEEN deleteAt _x } forEach _toRemove;
        };

        private _tEnemyDone = diag_tickTime;
        ["debug", "perf", "[Cycle %1] enemy spotrep build: %2ms", [_cycleCount, round ((_tEnemyDone - _tStart) * 1000)]] call ALIVE_fnc_COPLog;

        // Yield to scheduler between phases so other spawned loops aren't starved.
        sleep 0.01;

        // Cluster + filter each side's enemies.
        private _rawW = count _enemiesWEST;
        private _rawE = count _enemiesEAST;
        private _rawG = count _enemiesGUER;

        private _clusteredW = [_enemiesWEST] call ALIVE_fnc_COPClusterEnemy;
        private _clusteredE = [_enemiesEAST] call ALIVE_fnc_COPClusterEnemy;
        private _clusteredG = [_enemiesGUER] call ALIVE_fnc_COPClusterEnemy;

        private _tClusterDone = diag_tickTime;
        ["debug", "perf", "[Cycle %1] enemy clustering: %2ms", [_cycleCount, round ((_tClusterDone - _tEnemyDone) * 1000)]] call ALIVE_fnc_COPLog;

        // Prune stale trail entries not seen this cycle.
        private _allTrailKeys = createHashMap;
        { _allTrailKeys set [format ["%1_%2_%3", (_x select 2), floor ((_x select 0 select 0) / ALIVE_COP_CLUSTER_RADIUS), floor ((_x select 0 select 1) / ALIVE_COP_CLUSTER_RADIUS)], true]; } forEach (_clusteredW + _clusteredE + _clusteredG);
        private _staleKeys = (keys ALIVE_COP_TRAILS) select { !(_x in _allTrailKeys) };
        { ALIVE_COP_TRAILS deleteAt _x; } forEach _staleKeys;
        if (count _staleKeys > 0) then {
            ["debug", "server", "Pruned %1 stale trail entries (%2 remaining)", [count _staleKeys, count ALIVE_COP_TRAILS]] call ALIVE_fnc_COPLog;
        };

        sleep 0.01;

        // Cache objectives once per side per cycle — eliminates O(clusters)
        // ALiVE hash lookups during activity derivation.
        private _objCache = createHashMap;
        {
            private _sKey = _x;
            if (_sKey in ALIVE_COP_OPCOMS) then {
                private _opcom = ALIVE_COP_OPCOMS get _sKey;
                _objCache set [_sKey, [_opcom, "objectives", []] call ALiVE_fnc_HashGet];
            };
        } forEach ["WEST", "EAST", "GUER"];

        // Derive activity from each contact's OWN commander's nearest objective.
        {
            {
                private _contactSide = _x select 1;
                private _cachedObjs = _objCache getOrDefault [_contactSide, []];
                private _activity = [(_x select 0), _contactSide, _cachedObjs] call ALIVE_fnc_COPDeriveActivity;
                _x set [6, _activity];
            } forEach _x;
        } forEach [_clusteredW, _clusteredE, _clusteredG];

        private _tActivityDone = diag_tickTime;
        ["debug", "perf", "[Cycle %1] activity derivation: %2ms", [_cycleCount, round ((_tActivityDone - _tClusterDone) * 1000)]] call ALIVE_fnc_COPLog;

        sleep 0.01;

        // Build BFT per side.
        private _bftWEST = if (ALIVE_COP_LAYER_BFT) then { ["WEST"] call ALIVE_fnc_COPBuildBFT } else { [] };
        sleep 0.01;
        private _bftEAST = if (ALIVE_COP_LAYER_BFT) then { ["EAST"] call ALIVE_fnc_COPBuildBFT } else { [] };
        sleep 0.01;
        private _bftGUER = if (ALIVE_COP_LAYER_BFT) then { ["GUER"] call ALIVE_fnc_COPBuildBFT } else { [] };

        private _tBftDone = diag_tickTime;
        ["debug", "perf", "[Cycle %1] BFT build: %2ms (W=%3 E=%4 G=%5)", [_cycleCount, round ((_tBftDone - _tActivityDone) * 1000), count _bftWEST, count _bftEAST, count _bftGUER]] call ALIVE_fnc_COPLog;

        // ----- Hash diff and broadcast only what changed -----
        private _broadcastCount = 0;
        {
            _x params ["_varName", "_data"];
            if ([_varName, _data, ALIVE_COP_LAST_HASH] call ALIVE_fnc_COPBroadcastIfChanged) then {
                _broadcastCount = _broadcastCount + 1;
            };
        } forEach [
            ["ALiVE_COP_IntelData_WEST", _clusteredW],
            ["ALiVE_COP_IntelData_EAST", _clusteredE],
            ["ALiVE_COP_IntelData_GUER", _clusteredG],
            ["ALiVE_COP_BftData_WEST",   _bftWEST],
            ["ALiVE_COP_BftData_EAST",   _bftEAST],
            ["ALiVE_COP_BftData_GUER",   _bftGUER]
        ];

        // ----- Cycle summary -----
        private _cycleMs = round ((diag_tickTime - _tStart) * 1000);

        ["info", "server",
            "[Cycle %1] enemies: W=%2->%3 E=%4->%5 G=%6->%7 | bft: W=%8 E=%9 G=%10 | profiles: %11 ok %12 fail | broadcasts: %13/6 | %14ms",
            [_cycleCount,
             _rawW, count _clusteredW,
             _rawE, count _clusteredE,
             _rawG, count _clusteredG,
             count _bftWEST, count _bftEAST, count _bftGUER,
             _profilesProcessed, _profilesFailed,
             _broadcastCount,
             _cycleMs]
        ] call ALIVE_fnc_COPLog;

        // Cycle 1 cold-start exemption: separate higher threshold for the
        // first cycle (compile warm-up + spatial-grid + config lookups).
        private _warnThreshold = if (_cycleCount == 1) then { ALIVE_COP_DEBUG_PERF_WARN_CYCLE1_MS } else { ALIVE_COP_DEBUG_PERF_WARN_MS };
        if (_cycleMs > _warnThreshold) then {
            ["warn", "perf", "Loop A cycle %1 took %2ms (threshold: %3ms)", [_cycleCount, _cycleMs, _warnThreshold]] call ALIVE_fnc_COPLog;
        };

        sleep ALIVE_COP_INTERVAL_FAST;
    };

    ["info", "server", "Loop A stopped (ALIVE_COP_SERVER_RUNNING cleared)."] call ALIVE_fnc_COPLog;
};

// ============================================================================
// LOOP B — OPCOM OBJECTIVES (slow cycle, 60 s default)
// ============================================================================
[] spawn {
    ["info", "objectives", "Loop B starting (interval: %1s)", [ALIVE_COP_INTERVAL_SLOW]] call ALIVE_fnc_COPLog;

    private _validStates = ["attack", "attacking", "capture", "defend", "defending", "recon", "reserve", "reserving"];
    private _cycleCount = 0;

    while {ALIVE_COP_SERVER_RUNNING} do {

        private _tStart = diag_tickTime;
        _cycleCount = _cycleCount + 1;

        private _objW = [];
        private _objE = [];
        private _objG = [];
        private _totalObjScanned = 0;
        private _totalObjMatched = 0;
        private _totalObjPlaceholder = 0;

        if (ALIVE_COP_LAYER_OBJECTIVES) then {
            {
                private _sideKey = _x;
                private _opcom = _y;

                private _objectives = [_opcom, "objectives", []] call ALiVE_fnc_HashGet;
                _totalObjScanned = _totalObjScanned + count _objectives;

                // Bucket by state so we can sort + cap each independently.
                // Held objectives get their own bucket (own generous cap) so a
                // side that holds many objectives doesn't lose most of them to
                // the small per-state reserve cap.
                private _bucketAttack  = [];
                private _bucketDefend  = [];
                private _bucketRecon   = [];
                private _bucketReserve = [];
                private _bucketHeld    = [];

                {
                    // Held-objective flag (same predicate mil_logistics
                    // HELI_INSERT routing uses, so the COP visual matches
                    // the routing decision). Computed BEFORE the
                    // _validStates gate because tacom_state is an
                    // independent state machine from opcom_state (set in
                    // mil_opcom/tacom.fsm:402 vs :726): reserve anchors
                    // typically have opcom_state="idle" which doesn't
                    // appear in _validStates, so the gate would otherwise
                    // drop them before the held check ever runs.
                    // requireReserve=false — "controlled" mode: COP surfaces
                    // every objective the side holds, not just OPCOM reserve
                    // anchors (heli-insert routing keeps the strict default).
                    private _isHeld = [_x, _sideKey, 300, false] call ALiVE_fnc_isHeldObjective;

                    private _state = [_x, "opcom_state", ""] call ALiVE_fnc_HashGet;

                    if (_state in _validStates || _isHeld) then {
                        private _center = [_x, "center", [0,0,0]] call ALiVE_fnc_HashGet;
                        // Skip placeholder positions (uncaptured/uninitialised objectives).
                        if ((_center distance2D [0,0,0]) > 100) then {
                            private _size = [_x, "size", 200] call ALiVE_fnc_HashGet;
                            if (_size < ALIVE_COP_OBJ_MIN_RADIUS) then { _size = ALIVE_COP_OBJ_MIN_RADIUS };
                            private _priority = [_x, "priority", 0] call ALiVE_fnc_HashGet;

                            // Normalise state. A held objective is always shown
                            // as a reserve, whatever its opcom_state says — the
                            // holding side isn't attacking or defending ground it
                            // already holds quietly. opcom_state lags tacom_state
                            // (it stays "attacking" right after a successful
                            // capture, since it's set from the OPCOM order and not
                            // reset on capture), so held has to take precedence or
                            // a just-captured objective reads "<side> Attacking"
                            // on ground that side now holds.
                            private _normState = if (_isHeld) then { "reserve" } else {
                                switch (toLower _state) do {
                                    case "attacking";
                                    case "capture":   { "attack" };
                                    case "defending": { "defend" };
                                    case "reserving": { "reserve" };
                                    default           { _state };
                                };
                            };

                            // Defer location name lookup until after capping —
                            // saves nearestLocation calls on discarded objectives.
                            private _entry = [_priority, _center, _size, _normState, _isHeld];

                            // Held objectives → their own bucket (own cap), so a
                            // side holding many objectives doesn't lose them to the
                            // small per-state reserve cap. They keep "reserve"
                            // normState so no stale attack/defend ring draws — only
                            // the HELD flag. Non-held objectives bucket by state.
                            if (_isHeld) then {
                                _bucketHeld pushBack _entry;
                            } else {
                                switch (_normState) do {
                                    case "attack":  { _bucketAttack  pushBack _entry };
                                    case "defend":  { _bucketDefend  pushBack _entry };
                                    case "recon":   { _bucketRecon   pushBack _entry };
                                    case "reserve": { _bucketReserve pushBack _entry };
                                };
                            };
                        } else {
                            _totalObjPlaceholder = _totalObjPlaceholder + 1;
                        };
                    };
                } forEach _objectives;

                // Sort ascending by priority (lower number = higher priority) and cap.
                private _sortByPriority = {
                    params ["_bucket", "_max"];
                    _bucket sort true;
                    if (count _bucket > _max) then { _bucket resize _max };
                    _bucket
                };

                _bucketAttack  = [_bucketAttack,  ALIVE_COP_OBJ_MAX_ATTACK]  call _sortByPriority;
                _bucketDefend  = [_bucketDefend,  ALIVE_COP_OBJ_MAX_DEFEND]  call _sortByPriority;
                _bucketRecon   = [_bucketRecon,   ALIVE_COP_OBJ_MAX_RECON]   call _sortByPriority;
                _bucketReserve = [_bucketReserve, ALIVE_COP_OBJ_MAX_RESERVE] call _sortByPriority;
                _bucketHeld    = [_bucketHeld,    ALIVE_COP_OBJ_MAX_HELD]    call _sortByPriority;

                // Resolve location names only for survivors; append to this side's array.
                private _outArr = switch (toUpper _sideKey) do {
                    case "WEST": { _objW };
                    case "EAST": { _objE };
                    case "GUER": { _objG };
                    default      { [] };
                };

                private _matchedThisOpcom = 0;
                {
                    {
                        _x params ["_priority", "_center", "_size", "_normState", "_held"];
                        private _locName = [_center] call ALIVE_fnc_COPGetLocationName;
                        _outArr pushBack [_center, _size, _normState, _locName, _priority, _held];
                        _matchedThisOpcom = _matchedThisOpcom + 1;
                    } forEach _x;
                } forEach [_bucketAttack, _bucketDefend, _bucketRecon, _bucketReserve, _bucketHeld];

                _totalObjMatched = _totalObjMatched + _matchedThisOpcom;
                ["debug", "objectives",
                    "[Cycle %1] OPCOM %2: %3/%4 obj kept (atk=%5 def=%6 rcn=%7 rsv=%8)",
                    [_cycleCount, _sideKey, _matchedThisOpcom, count _objectives,
                     count _bucketAttack, count _bucketDefend, count _bucketRecon, count _bucketReserve]
                ] call ALIVE_fnc_COPLog;

                // Yield between OPCOMs.
                sleep 0.01;
            } forEach ALIVE_COP_OPCOMS;
        };

        // Hash diff and broadcast.
        private _broadcastCount = 0;
        {
            _x params ["_varName", "_data"];
            if ([_varName, _data, ALIVE_COP_LAST_HASH] call ALIVE_fnc_COPBroadcastIfChanged) then {
                _broadcastCount = _broadcastCount + 1;
            };
        } forEach [
            ["ALiVE_COP_ObjectivesData_WEST", _objW],
            ["ALiVE_COP_ObjectivesData_EAST", _objE],
            ["ALiVE_COP_ObjectivesData_GUER", _objG]
        ];

        private _cycleMs = round ((diag_tickTime - _tStart) * 1000);

        // Held-count snapshot per side (each entry's 6th field is the
        // held flag). Surfaced in the cycle summary so testers can
        // sanity-check the predicate is matching anything.
        private _heldW = count (_objW select { (_x select 5) });
        private _heldE = count (_objE select { (_x select 5) });
        private _heldG = count (_objG select { (_x select 5) });

        ["info", "objectives",
            "[Cycle %1] objs scanned: %2 | matched: %3 | placeholder: %4 | per side: W=%5 E=%6 G=%7 | held: W=%8 E=%9 G=%10 | broadcasts: %11/3 | %12ms",
            [_cycleCount, _totalObjScanned, _totalObjMatched, _totalObjPlaceholder,
             count _objW, count _objE, count _objG,
             _heldW, _heldE, _heldG,
             _broadcastCount, _cycleMs]
        ] call ALIVE_fnc_COPLog;

        // DIAG-STRIP held-count visibility log (always logged via
        // ALiVE_fnc_dump independent of ALIVE_COP_DEBUG_LEVEL, gated by
        // mil_c2istar's debug attribute). Helps testers confirm the
        // predicate is firing without bumping COP debug level. Sweep
        // out alongside the other DIAG-STRIP entries during the
        // end-of-overhauls cleanup pass.
        if (!isNil "ALiVE_mil_c2istar_debug" && {ALiVE_mil_c2istar_debug}) then {
            ["ALIVE-%1 COP DIAG-STRIP - held count [Cycle %2] W=%3 E=%4 G=%5 (objs scanned %6, matched %7)",
                time, _cycleCount, _heldW, _heldE, _heldG, _totalObjScanned, _totalObjMatched] call ALiVE_fnc_dump;
        };

        // Cycle 1 cold-start exemption (same rationale as Loop A).
        private _warnThreshold = if (_cycleCount == 1) then { ALIVE_COP_DEBUG_PERF_WARN_CYCLE1_MS } else { ALIVE_COP_DEBUG_PERF_WARN_MS };
        if (_cycleMs > _warnThreshold) then {
            ["warn", "perf", "Loop B cycle %1 took %2ms (threshold: %3ms)", [_cycleCount, _cycleMs, _warnThreshold]] call ALIVE_fnc_COPLog;
        };

        sleep ALIVE_COP_INTERVAL_SLOW;
    };

    ["info", "objectives", "Loop B stopped (ALIVE_COP_SERVER_RUNNING cleared)."] call ALIVE_fnc_COPLog;
};

["info", "server", "Loops A+B spawned. Server init complete."] call ALIVE_fnc_COPLog;

private _result = true;
TRACE_1("COPServer - output",_result);
_result
