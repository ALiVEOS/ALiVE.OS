#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(activateReserve);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_activateReserve

Description:
    Reserve-pool activation tick for a single placement-module cluster.
    Called periodically by the activation watcher PFH started at the
    end of each placement module's cluster loop.

    Module-agnostic: works for any placement module that exposes the
    standard reserve-pool attributes (reserveActivationThreshold,
    reserveActivationCooldown, reserveEngagementMultiplier,
    reserveOrphanCrewBehaviour, guardRadius, guardPatrolPercentage).
    The owning module is identified via the cluster's "reserveModuleClass"
    hash entry, which the placement code stores when it sets up the
    reserve pool. The class is the module's MAINCLASS function (e.g.
    ALIVE_fnc_MP for mil_placement, ALIVE_fnc_CP for civ_placement).

    Cascade:
      1. Cluster has reserves remaining? If pool empty, exit.
      2. Active force still above threshold? Compare alive count to
         the cluster's activeAtSpawn snapshot. Only kills decrement -
         virtualisation does not.
      3. Cooldown elapsed since last activation? (Default 30 s.)
      4. Player(s) within objective engagement radius? No point
         reinforcing an empty area.
      5. Candidate building available? Building must be inside the
         objective radius, >= 80 m from any player, and have at
         least one BIS_fnc_buildingPositions slot.
      6. Pop one group config from the reserve pool, place it as a
         garrison profile in the candidate building, tag it with the
         home cluster, register in the active list, stamp lastReserveWake.

Parameters:
    _this select 0: HASH   - cluster (placement module's cluster hash)
    _this select 1: OBJECT - placement module logic (for live attrs)

Returns:
    BOOLEAN - true if a reserve was activated this tick, false otherwise.

Examples:
    (begin example)
    private _activated = [_cluster, _logic] call ALIVE_fnc_activateReserve;
    (end)

See Also:
    ALIVE_fnc_MP, ALIVE_fnc_CP, ALIVE_fnc_CPC, ALIVE_fnc_CMP

Author:
    Jman
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params [
    ["_cluster", [], [[]]],
    ["_logic", objNull, [objNull]]
];

if (count _cluster == 0 || {isNull _logic}) exitWith { false };

// Owning module's MAINCLASS function, stored on the cluster by the
// placement code when it set up the reserve pool. Without this we
// can't read the module's attributes; treat as a hard fail.
private _modClass = [_cluster, "reserveModuleClass", {nil}] call ALiVE_fnc_hashGet;
if (isNil "_modClass") exitWith { false };

private _debug = !isNil "ALiVE_vehicleSpawn_debug" && {ALiVE_vehicleSpawn_debug};

// 1. Reserves remaining? Silent skip in steady state - no point
//    logging clusters that have no reserves to begin with.
private _reservePool = [_cluster, "reservePool", []] call ALiVE_fnc_hashGet;
if (count _reservePool == 0) exitWith { false };

private _center = [_cluster, "center"] call ALiVE_fnc_hashGet;

// Resolve a human-readable label for the cluster so debug logs are
// readable on the map. nearestLocation returns the closest named
// location (a Location object, not a position - convert via
// locationPosition before distance check). Guard with a 600 m sanity
// distance - clusters that aren't near a named feature fall back to
// raw coords, which the reader can punch into the map.
private _clusterLabel = ([] call {
    private _loc = nearestLocation [_center, ""];
    if (isNull _loc) exitWith { format ["%1", _center] };
    private _locPos = locationPosition _loc;
    if ((_center distance2D _locPos) > 600) exitWith { format ["%1", _center] };
    private _name = text _loc;
    if (_name == "") exitWith { format ["%1", _center] };
    format ["%1 (%2)", _name, _center]
});

// 2. Threshold check - alive vs activeAtSpawn.
//    Edge case: activeAtSpawn==0 means placement put groups into this
//    cluster's reserve pool but never spawned an active group there
//    (typical when group distribution + Readiness leaves a tail
//    cluster with all-reserve infantry). Fall back to proximity-only
//    activation - skip the threshold check, let the player-presence
//    and candidate-building gates decide. Subject to the cooldown so
//    the cluster doesn't waterfall on first contact.
private _activeAtSpawn = [_cluster, "reserveActiveAtSpawn", 0] call ALiVE_fnc_hashGet;
private _activeIDs = [_cluster, "activeProfileIDs", []] call ALiVE_fnc_hashGet;
private _aliveCount = {
    private _p = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
    !isNil "_p"
} count _activeIDs;

private _threshold = parseNumber ([_logic, "reserveActivationThreshold"] call _modClass);

// Threshold gate. When activeAtSpawn > 0 AND fraction > threshold,
// the force is healthy - skip silently. When activeAtSpawn == 0,
// fall through (proximity-only activation; see comment above).
if (_activeAtSpawn > 0 && {(_aliveCount / _activeAtSpawn) > _threshold}) exitWith { false };

// 3. Cooldown elapsed?
private _cooldown = parseNumber ([_logic, "reserveActivationCooldown"] call _modClass);
private _lastWake = [_cluster, "lastReserveWake", -999] call ALiVE_fnc_hashGet;
if ((serverTime - _lastWake) < _cooldown) exitWith {
    if (_debug) then {
        diag_log format ["[ALiVE Reserve DEBUG] SKIP cluster=%1 reason=cooldown waiting=%2s remaining=%3s reserves=%4 activeAlive=%5/%6",
            _clusterLabel, _cooldown, round (_cooldown - (serverTime - _lastWake)),
            count _reservePool, _aliveCount, _activeAtSpawn];
    };
    false
};

// 4. Players within engagement radius?
private _size = [_cluster, "size", 200] call ALiVE_fnc_hashGet;
// Multiplier comes from the placement module attribute. Default 3x
// (a 150 m cluster gives 450 m engagement). Larger values wake the
// pool earlier as the player approaches; smaller values keep the
// reserve dormant until the player is right on top of the cluster.
private _engagementMultiplier = parseNumber ([_logic, "reserveEngagementMultiplier"] call _modClass);
if (_engagementMultiplier <= 0) then { _engagementMultiplier = 3 };
private _engagementRadius = _size * _engagementMultiplier;
private _playersInArea = (allPlayers - entities "HeadlessClient_F")
    select { (_x distance2D _center) < _engagementRadius };
if (_playersInArea isEqualTo []) exitWith {
    if (_debug) then {
        diag_log format ["[ALiVE Reserve DEBUG] SKIP cluster=%1 reason=no-player-in-area engagementRadius=%2 reserves=%3 activeAlive=%4/%5",
            _clusterLabel, _engagementRadius, count _reservePool, _aliveCount, _activeAtSpawn];
    };
    false
};

// 5. Peek at first entry to determine type. Reserve pool entries
//    have a type discriminator at index 0:
//      "VEHICLE"  - empty vehicle profile already spawned at parking;
//                   crew added to the existing empty entity profile.
//      "INFANTRY" - group config held; crew spawned at a building.
//    Legacy v1 entries had no discriminator (4-element shape); for
//    forward-compat treat type-less as "INFANTRY".
private _reserveEntry = _reservePool select 0;
private _entryType = if (count _reserveEntry > 0 && {(_reserveEntry select 0) isEqualType ""}) then {
    _reserveEntry select 0
} else {
    "INFANTRY"
};

private _guardRadius = parseNumber ([_logic, "guardRadius"] call _modClass);
private _guardPatrolPercentage = parseNumber ([_logic, "guardPatrolPercentage"] call _modClass);
private _activated = false;

// Helper: orphaned-crew → infantry fallback. Activates as if INFANTRY,
// using the group class from the orphan entry. Shared between vehicle-
// reserve orphan branch and (potentially) future fall-throughs.
private _fnc_activateAsInfantry = {
    params ["_group", "_faction", "_onEachSpawn", "_onEachSpawnOnce"];

    // Building check. The 80 m proximity gate keeps reserves from
    // popping in next to the player. The optional "lock cleared
    // buildings" mode (per-module attribute) further disqualifies
    // any building this cluster's spawn picker has previously seen
    // inside the proximity bubble - touched once = locked for the
    // rest of the mission. Without the lock-cleared mode, the gate
    // re-checks each activation (a building you've moved well past
    // becomes eligible again).
    private _proximityGate = 80;
    private _lockCleared = (parseNumber ([_logic, "reserveLockClearedBuildings"] call _modClass)) > 0;
    private _clearedBuildings = [_cluster, "clearedBuildings", []] call ALiVE_fnc_hashGet;
    private _buildingsInArea = nearestObjects [_center, ["Building", "House"], _size];
    private _candidateBuilding = objNull;
    {
        private _b = _x;
        private _slots = _b call BIS_fnc_buildingPositions;
        if (count _slots == 0) then { continue };
        if (_lockCleared && {_b in _clearedBuildings}) then { continue };
        private _tooClose = _playersInArea findIf { (_b distance2D _x) < _proximityGate };
        if (_tooClose >= 0) then {
            if (_lockCleared && {!(_b in _clearedBuildings)}) then {
                _clearedBuildings pushBack _b;
            };
            continue
        };
        _candidateBuilding = _b;
    } forEach _buildingsInArea;
    if (_lockCleared) then {
        [_cluster, "clearedBuildings", _clearedBuildings] call ALiVE_fnc_hashSet;
    };

    if (isNull _candidateBuilding) exitWith {
        if (_debug) then {
            diag_log format ["[ALiVE Reserve DEBUG] SKIP cluster=%1 reason=no-safe-building reserves=%2 activeAlive=%3/%4",
                _clusterLabel, count _reservePool, _aliveCount, _activeAtSpawn];
        };
        false
    };

    // Spawn 5-15 m outside the building.
    private _spawnPos = [position _candidateBuilding, 5 + random 10] call CBA_fnc_RandPos;
    private _profiles = [_group, _spawnPos, random 360, true, _faction, false, false, "STEALTH", _onEachSpawn, _onEachSpawnOnce] call ALIVE_fnc_createProfilesFromGroupConfig;

    {
        if (([_x, "type"] call ALiVE_fnc_hashGet) == "entity") then {
            // Force patrolPercentage = 1 so newly-activated reserve
            // infantry patrol the cluster instead of standing inside
            // the candidate building waiting for OPCOM. OPCOM tasks
            // on its own cadence (busy=false at activation), so the
            // patrol stage is just "stay useful in the meantime".
            [_x, "setActiveCommand", ["ALIVE_fnc_garrison", "spawn", [_guardRadius, "true", [0,0,0], "", 1, 1]]] call ALIVE_fnc_profileEntity;
            [_x, "homeCluster", _cluster] call ALiVE_fnc_hashSet;
            _activeIDs pushBack ([_x, "profileID"] call ALiVE_fnc_hashGet);
        };
    } forEach _profiles;

    if (_debug) then {
        diag_log format ["[ALiVE Reserve DEBUG] ACTIVATE-INFANTRY faction=%1 cluster=%2 building=%3 activeAlive=%4/%5 reservesRemaining=%6",
            _faction, _clusterLabel, typeOf _candidateBuilding,
            _aliveCount, _activeAtSpawn, count _reservePool - 1];
    };

    true
};

if (_entryType == "VEHICLE") then {
    _reserveEntry params ["", "_groupClass", "_vehicleProfileID", "_entityProfileID", "_entryFaction", "_entryOnSpawn", "_entryOnSpawnOnce"];

    // Look up profiles by ID. Pool entries store IDs (strings) not
    // array references to avoid the recursive-array cycle (entity has
    // homeCluster=cluster, cluster has reservePool, so embedding the
    // entity array in reservePool would form a loop).
    private _profileVehicle = [ALIVE_profileHandler, "getProfile", _vehicleProfileID] call ALIVE_fnc_profileHandler;
    private _profileEntity = [ALIVE_profileHandler, "getProfile", _entityProfileID] call ALIVE_fnc_profileHandler;

    // Orphan check: profile missing (unregistered = profile killed and
    // the handler removed it) OR the live in-world vehicle is dead.
    // Don't check the profile's "damage" hash field - that stores an
    // array of [hitPoint, damage] pairs (see vehicleGetDamage), not a
    // scalar. Profile-handler-based detection is reliable on its own;
    // the in-world alive-check covers the brief window between vehicle
    // destruction and handler unregistration.
    private _vehicleMissing = isNil "_profileVehicle";
    private _vehicleObject = if (_vehicleMissing) then { objNull } else { [_profileVehicle, "vehicle", objNull] call ALiVE_fnc_hashGet };
    private _isOrphaned = _vehicleMissing
        || {!isNull _vehicleObject && {!alive _vehicleObject}};

    if (_isOrphaned) then {
        private _orphanBehaviour = [_logic, "reserveOrphanCrewBehaviour"] call _modClass;
        // Pop orphan from pool first - either way, this entry is consumed.
        _reservePool deleteAt 0;

        if (_orphanBehaviour == "Drop") then {
            if (_debug) then {
                diag_log format ["[ALiVE Reserve DEBUG] DROP-ORPHAN cluster=%1 vehicleClass=%2 reservesRemaining=%3",
                    _clusterLabel, [_profileVehicle, "vehicleClass", "?"] call ALiVE_fnc_hashGet, count _reservePool];
            };
            // Activated=false (no real activation), but still update
            // lastReserveWake so we don't spin every tick burning CPU on
            // the same orphan that's already gone.
            [_cluster, "lastReserveWake", serverTime] call ALiVE_fnc_hashSet;
        } else {
            // SpawnAsInfantry - reuse the infantry helper.
            _activated = [_groupClass, _entryFaction, _entryOnSpawn, _entryOnSpawnOnce] call _fnc_activateAsInfantry;
        };
    } else {
        // Vehicle alive - add crew to the existing empty entity profile,
        // clear busy flags, unlock if applicable, then despawn / spawn
        // the entity so the new crew materialises inside the truck.
        private _vehicleClass = [_profileVehicle, "vehicleClass"] call ALiVE_fnc_hashGet;
        private _crew = _vehicleClass call ALIVE_fnc_configGetVehicleCrew;
        private _vehiclePositions = [_vehicleClass] call ALIVE_fnc_configGetVehicleEmptyPositions;
        private _countCrewPositions = 0;
        for "_i" from 0 to (count _vehiclePositions) - 3 do {
            _countCrewPositions = _countCrewPositions + (_vehiclePositions select _i);
        };
        private _vehiclePos = [_profileVehicle, "position", _center] call ALiVE_fnc_hashGet;

        // Add vehicle's own crew (driver/gunner/commander).
        for "_i" from 0 to _countCrewPositions - 1 do {
            [_profileEntity, "addUnit", [_crew, _vehiclePos, 0, "PRIVATE"]] call ALIVE_fnc_profileEntity;
        };

        // Add dismount infantry from group config (Man entries).
        private _groupConfig = [_entryFaction, _groupClass] call ALIVE_fnc_configGetGroup;
        for "_i" from 0 to (count _groupConfig) - 1 do {
            private _entry = _groupConfig select _i;
            if (isClass _entry) then {
                private _entryVehicle = getText (_entry >> "vehicle");
                private _entryRank = getText (_entry >> "rank");
                if (_entryVehicle isKindOf "Man") then {
                    [_profileEntity, "addUnit", [_entryVehicle, _vehiclePos, 0, _entryRank]] call ALIVE_fnc_profileEntity;
                };
            };
        };

        // Sync unitCount + (re)create vehicle assignment. profileEntity's
        // `addUnit` case appends to unitClasses but doesn't update
        // `unitCount`, and the empty-vehicle profile was created with
        // an empty vehicle assignment. Without these two steps, the
        // entity's spawn flow ignores the new crew (unitIndexes is
        // derived from unitCount, vehicle assignment maps unitIndexes
        // to seats) and the crew materialises next to the truck on
        // foot instead of inside it.
        private _unitClasses = [_profileEntity, "unitClasses"] call ALiVE_fnc_hashGet;
        [_profileEntity, "unitCount", count _unitClasses] call ALiVE_fnc_hashSet;
        [_profileEntity, _profileVehicle] call ALiVE_fnc_createProfileVehicleAssignment;

        if (_debug) then {
            private _entityActive = [_profileEntity, "active", false] call ALiVE_fnc_hashGet;
            private _entityLocked = [_profileEntity, "locked", false] call ALiVE_fnc_hashGet;
            private _vehicleActive = [_profileVehicle, "active", false] call ALiVE_fnc_hashGet;
            private _vehicleObj = [_profileVehicle, "vehicle", objNull] call ALiVE_fnc_hashGet;
            private _ea = [_profileEntity, "vehicleAssignments"] call ALiVE_fnc_hashGet;
            private _va = [_profileVehicle, "vehicleAssignments"] call ALiVE_fnc_hashGet;
            diag_log format ["[ALiVE Reserve DEBUG] PRE-SPAWN class=%1 entityActive=%2 entityLocked=%3 vehicleActive=%4 vehicleObj=%5 vehicleLocked=%6 unitClasses=%7 entityAssignmentValues=%8 vehicleAssignmentValues=%9",
                _vehicleClass, _entityActive, _entityLocked, _vehicleActive, _vehicleObj,
                if (!isNull _vehicleObj) then {locked _vehicleObj} else {-1},
                _unitClasses, _ea select 2, _va select 2];
        };

        // Clear busy flags - OPCOM picks them up next tick.
        [_profileEntity, "busy", false] call ALIVE_fnc_profileEntity;
        [_profileVehicle, "busy", false] call ALIVE_fnc_profileVehicle;

        // Unlock the world vehicle for the despawn/spawn cycle below.
        // Empirically, lock 2 blocks moveInDriver/moveInGunner when
        // the unit isn't in the vehicle's group - reserve crew is
        // freshly-created in a new group with no link to the vehicle,
        // so the moveIn calls in profileVehicleAssignmentToVehicleAssignment
        // silently no-op. Crew ends up created in the world but not
        // mounted. Unlocking here lets the moveIn succeed; if the
        // vehicle later ends up empty (crew killed) the next
        // virtualisation cycle will lock again via the
        // `reserveLockFlag && crewCount==0` gate in profileVehicle.
        if (!isNull _vehicleObject) then { _vehicleObject lock 0 };

        // Set active command BEFORE the despawn/spawn cycle. Vehicle
        // reserves use ambientMovement so the crew stays mounted and
        // the truck patrols on roads - garrison would have the crew
        // dismount and seek cover in buildings, defeating the point
        // of waking a vehicle. The reserve is essentially an AI patrol
        // group that joins the cluster's active force; OPCOM picks
        // them up at next tick (busy=false above) and re-tasks as
        // needed.
        [_profileEntity, "setActiveCommand", ["ALIVE_fnc_ambientMovement", "spawn", [_guardRadius, "SAFE", [0,0,0]]]] call ALIVE_fnc_profileEntity;

        // Despawn + spawn cycle on the entity to materialise the new
        // crew. The vehicle profile is independent and stays as-is, so
        // no visual flicker on the truck itself - just crew popping
        // into the seats on the next tick.
        //
        // Wrapped in a scheduled spawn because the PFH that called us
        // runs in unscheduled context, but fnc_profileEntity's "spawn"
        // path uses `sleep ALiVE_smoothSpawn` internally - which errors
        // "Suspending not allowed in this context" if call'd from a PFH.
        [_profileEntity, _profileVehicle, _vehicleClass, _debug] spawn {
            params ["_pe", "_pv", "_vc", "_dbg"];
            [_pe, "despawn"] call ALIVE_fnc_profileEntity;
            [_pe, "spawn"] call ALIVE_fnc_profileEntity;

            // After the entity spawn, check if the vehicle assignment
            // dispatch actually mounted the crew. If not (lock state,
            // group mismatch, whatever - the chain is fragile), do a
            // manual moveIn pass: driver first, then gunner/commander
            // turret slots, then cargo. Brute-force but deterministic.
            sleep 1;
            private _veh = [_pv, "vehicle", objNull] call ALiVE_fnc_hashGet;
            private _units = [_pe, "units", []] call ALiVE_fnc_hashGet;
            if (!isNull _veh && {count _units > 0} && {count crew _veh < count _units}) then {
                if (locked _veh > 0) then { _veh lock 0 };
                private _seated = 0;
                if (isNull driver _veh && {_seated < count _units}) then {
                    private _u = _units select _seated;
                    if (!isNull _u) then {
                        _u assignAsDriver _veh;
                        _u moveInDriver _veh;
                        _seated = _seated + 1;
                    };
                };
                // Gunner / commander / turret seats
                private _turrets = allTurrets [_veh, true];
                {
                    if (_seated >= count _units) exitWith {};
                    private _path = _x;
                    if (isNull (_veh turretUnit _path)) then {
                        private _u = _units select _seated;
                        if (!isNull _u) then {
                            _u assignAsTurret [_veh, _path];
                            _u moveInTurret [_veh, _path];
                            _seated = _seated + 1;
                        };
                    };
                } forEach _turrets;
                // Cargo
                while {_seated < count _units && {(_veh emptyPositions "cargo") > 0}} do {
                    private _u = _units select _seated;
                    if (!isNull _u) then {
                        _u assignAsCargo _veh;
                        _u moveInCargo _veh;
                    };
                    _seated = _seated + 1;
                };
            };

            if (_dbg) then {
                sleep 4;
                private _unitCount = [_pe, "unitCount"] call ALIVE_fnc_profileEntity;
                private _entityActive = [_pe, "active", false] call ALiVE_fnc_hashGet;
                diag_log format ["[ALiVE Reserve DEBUG] POST-SPAWN class=%1 vehicle=%2 entityActive=%3 unitCount=%4 unitsInWorld=%5 crewInVehicle=%6 vehiclePos=%7 vehicleLocked=%8",
                    _vc, _veh, _entityActive, _unitCount, count _units, count crew _veh, getPosATL _veh,
                    if (!isNull _veh) then {locked _veh} else {-1}];
            };
        };

        // Track in cluster's active list so subsequent threshold checks
        // count this entity.
        _activeIDs pushBack ([_profileEntity, "profileID"] call ALiVE_fnc_hashGet);

        _reservePool deleteAt 0;
        _activated = true;

        if (_debug) then {
            // Threshold display with NaN guard. _threshold has been
            // observed to log as "scalar NaN" through the format
            // chain in some attribute-reading paths; guard so the log
            // is readable rather than chasing the underlying type bug.
            private _thresholdStr = if (_threshold > 0 && _threshold <= 1) then { str (round (_threshold * 100)) } else { "?" };
            diag_log format ["[ALiVE Reserve DEBUG] ACTIVATE-VEHICLE faction=%1 cluster=%2 vehicleClass=%3 crewCount=%4 activeAlive=%5/%6 threshold=%7%% reservesRemaining=%8",
                _entryFaction, _clusterLabel, _vehicleClass, _countCrewPositions,
                _aliveCount, _activeAtSpawn, _thresholdStr, count _reservePool];
        };
    };
} else {
    // INFANTRY reserve. Legacy 4-element entries fall here too (treated
    // as INFANTRY).
    private _group = if (_entryType == "INFANTRY") then {
        _reserveEntry select 1
    } else {
        _reserveEntry select 0  // legacy v1 shape
    };
    private _entryFaction = if (_entryType == "INFANTRY") then {
        _reserveEntry select 2
    } else {
        _reserveEntry select 1
    };
    private _entryOnSpawn = if (_entryType == "INFANTRY") then {
        _reserveEntry select 3
    } else {
        _reserveEntry select 2
    };
    private _entryOnSpawnOnce = if (_entryType == "INFANTRY") then {
        _reserveEntry select 4
    } else {
        _reserveEntry select 3
    };

    private _ok = [_group, _entryFaction, _entryOnSpawn, _entryOnSpawnOnce] call _fnc_activateAsInfantry;
    if (_ok) then {
        _reservePool deleteAt 0;
        _activated = true;
    };
};

// Common post-success bookkeeping.
if (_activated) then {
    [_cluster, "reservePool", _reservePool] call ALiVE_fnc_hashSet;
    [_cluster, "activeProfileIDs", _activeIDs] call ALiVE_fnc_hashSet;
    [_cluster, "lastReserveWake", serverTime] call ALiVE_fnc_hashSet;
};

_activated
