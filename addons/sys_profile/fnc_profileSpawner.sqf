#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileSpawner);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_profileSpawner

Description:
Executes queued profile spawn and despawn transitions. Profile selection and
queue population are owned by profile activators and the activation
coordinator.

Notes:
    - Processes at most one pending despawn per frame
    - Spawns at most one profile per configured smooth-spawn interval
    - Validates queue entries immediately before executing them
    - A profile that cannot get an Active Limiter slot stays queued and virtual;
      freed slots go to the queued profile nearest a spawn source

Parameters:
HashMap - Profile activation coordinator

Returns:
Nil

Author:
SpyderBlack723
Jman
---------------------------------------------------------------------------- */

params ["_coordinator"];

private _claimState = _coordinator get "claimState";
private _activators = _claimState select 0;
private _completedIterations = _claimState select 1;
private _claimCounts = _claimState select 2;
private _profilesById = [MOD(profileHandler),"profilesById"] call ALiVE_fnc_hashGet;

// A group counts as active only once its last man is in, and the spawn sleeps
// one smooth-spawn interval per man, so a freshly dispatched group is invisible
// to the active count for a moment. Left uncounted, a single free slot would
// let one group through every interval until the first of them finished. What
// is in flight is tracked here and counted against the limit below.
//
// The value is a DEADLINE, not the dispatch time: the wait is one interval per
// man and the interval is a free-text setting with no upper bound, so a fixed
// timeout expires while a big group on a slow setting is still spawning, and
// the cap is then overshot by one for every such group. The deadline is worked
// out once, where the group is in hand, so this runs without a lookup.
//
// Pruned before the queue sweep rather than inside the spawn block, so the
// sweep and the waiting count below both read an honest map on every frame.
private _pendingSpawns = _coordinator getOrDefault ["pendingSpawns",createHashMap,true];

{
    private _pendingProfile = _profilesById get _x;

    if (isNil "_pendingProfile") then {
        _pendingSpawns deleteAt _x;
    } else {
        // "locked" brackets the whole spawn: it goes on before the first man is
        // made and comes off after the group has been registered active, so
        // while it is set the group really is on its way in and cannot be
        // counted any other way yet. Trust that over the deadline, because a
        // spawn runs scheduled and shares a small per-frame budget with every
        // other one, so on a busy mission start it takes considerably longer
        // than the sleeps inside it.
        private _deadline = _pendingSpawns get _x;
        private _spawning = [_pendingProfile,"locked",false] call ALiVE_fnc_hashGet;

        // The deadline is still the get-out, and the wider one is there because
        // something other than a spawn can hold that lock. A held lock must not
        // keep a slot reserved for the rest of the mission.
        if (
            (!_spawning && {((_pendingProfile select 2) select 1) || {time > _deadline}}) ||
            {time > (_deadline + 60)}
        ) then {
            _pendingSpawns deleteAt _x;
        };
    };
} forEach (keys _pendingSpawns);

///////////////////////////////////////
//          Despawn Profiles
///////////////////////////////////////

private _despawnQueue = _coordinator get "despawnQueue";

if !(_despawnQueue isEqualTo []) then {
    private _despawnEntry = _despawnQueue select 0;
    _despawnEntry params ["_profileID","_despawnIterations"];

    private _allActivatorsAdvanced = true;

    {
        private _activatorID = _x get "id";
        private _queuedIteration = _despawnIterations get _activatorID;

        if (isNil "_queuedIteration") then {
            _queuedIteration = 0;
        };

        if (
            (_completedIterations get _activatorID) <=
            _queuedIteration
        ) exitWith {
            _allActivatorsAdvanced = false;
        };
    } forEach _activators;

    if (_allActivatorsAdvanced) then {
        _despawnQueue deleteAt 0;

        if (isNil {_claimCounts get _profileID}) then {
            private _profile = _profilesById get _profileID;

            if (!isNil "_profile") then {
                private _profileData = _profile select 2;
                private _leader = _profileData select 10;

                // Preserve the current rule: airborne profiles do not despawn.
                if ((getPos _leader) select 2 < 3) then {
                    if ((_profileData select 5) == "entity") then {
                        [_profile,"despawn"] call ALiVE_fnc_profileEntity;
                    } else {
                        private _vehicleAssignments = [_profile,"vehicleAssignments"] call ALiVE_fnc_hashGet;

                        if (
                            isNil "_vehicleAssignments" ||
                            {(_vehicleAssignments select 1) isEqualTo []}
                        ) then {
                            [_profile,"despawn"] call ALiVE_fnc_profileVehicle;
                        };
                    };
                };
            };
        };
    };
};

///////////////////////////////////////
//        Sweep the Spawn Queue
///////////////////////////////////////

// Nothing leaves this queue except through this function. While the Active
// Limiter is full nothing is popped, so a queue that only ever lost its head
// would silt up with every profile that wandered into range and then died or
// walked out of it. Walk a few entries from a rotating cursor every frame
// instead, so stale entries anywhere in the queue are gone within seconds and
// the count reported below is the real one.
private _spawnQueue = _coordinator get "spawnQueue";
private _spawnQueueMembership = _coordinator get "spawnQueueMembership";
private _sweepCursor = _coordinator getOrDefault ["spawnQueueSweepCursor",0];
private _sweepChecksRemaining = 10 min (count _spawnQueue);

while {
    _sweepChecksRemaining > 0 &&
    {_spawnQueue isNotEqualTo []}
} do {
    if (_sweepCursor >= count _spawnQueue) then {
        _sweepCursor = 0;
    };

    private _profileID = _spawnQueue select _sweepCursor;

    private _profile = if (isNil {_claimCounts get _profileID}) then {
        nil
    } else {
        _profilesById get _profileID
    };

    // In flight counts as gone from the queue. A dispatched group clears its
    // membership before it finishes spawning, so the next activator pass puts
    // it straight back in while it is still inactive. Left there it would
    // inflate the waiting count in the report and push the selection below
    // into nearest-first when arrival order would have done.
    if (
        isNil "_profile" ||
        {(_profile select 2) select 1} ||
        {!isNil {_pendingSpawns get _profileID}}
    ) then {
        _spawnQueue deleteAt _sweepCursor;
        _spawnQueueMembership deleteAt _profileID;
    } else {
        _sweepCursor = _sweepCursor + 1;
    };

    _sweepChecksRemaining = _sweepChecksRemaining - 1;
};

_coordinator set ["spawnQueueSweepCursor",_sweepCursor];

// Contention can end by the queue draining rather than by a slot freeing, and
// the block below never runs on an empty queue, so clear the settle timer here.
if (
    _spawnQueue isEqualTo [] &&
    {(_coordinator getOrDefault ["limiterFullSince",0]) != 0}
) then {
    _coordinator set ["limiterFullSince",0];
};

///////////////////////////////////////
//          Spawn Profiles
///////////////////////////////////////

private _lastProfileSpawnedTime = _coordinator get "lastSpawnTime";

// #1027: Smooth Spawn does two jobs and 0 suits one of them and never this one. At 0 the
// per-man sleep gives an instant spawn, which somebody may well want, but the test below
// is then true on every frame and the whole selection runs on all of them. That scan was
// measured at 1.52 ms: half a percent of CPU once per 0.3 s, nearer 8 percent of a 20 ms
// frame every frame. The floor is on the SELECTION only, so a deliberate 0 keeps its
// instant per-man spawn and just stops rebuilding the queue dozens of times a second.
// At 0.05 s that is one frame at 20 fps, so nobody watching can tell.
if (
    _spawnQueue isNotEqualTo [] &&
    {time - _lastProfileSpawnedTime > (ALiVE_smoothSpawn max 0.05)}
) then {
    // The limit counts active groups only. Vehicle profiles never enter
    // entitiesActive, so they neither count toward it nor free a slot.
    private _activeLimiter = [MOD(profileSystem),"activeLimiter"] call ALiVE_fnc_profileSystem;
    private _activeEntityCount =
        count ([MOD(profileHandler),"getActiveEntities"] call ALiVE_fnc_profileHandler) +
        count _pendingSpawns;
    private _freeSlots = _activeLimiter - _activeEntityCount;

    ///////////////////////////////////////
    //   Report Profiles Held Back
    ///////////////////////////////////////

    // A group that reached the front of the queue while the Active Limiter was
    // full used to be thrown away. Now it waits, virtual, and the nearest
    // waiting profile takes each slot as one frees up. Anyone tuning placement
    // density still needs to know the limiter is why a group has not appeared.
    //
    // The thing worth reporting is CONTENTION, not an instant with no free
    // slot. A running mission frees a slot every second or two as groups die
    // or walk out of range and fills it on the next frame, so a test for zero
    // free slots restarts the settle below every time and the line never
    // prints while a hundred groups wait. More queued than there is room for
    // is the real condition, and it is the same test the selection uses.
    private _contended = count _spawnQueue > _freeSlots;

    if (_contended) then {
        private _heldSince = _coordinator getOrDefault ["limiterFullSince",0];

        if (_heldSince isEqualTo 0) then {
            _heldSince = time;
            _coordinator set ["limiterFullSince",time];
        };

        // Two seconds before the first line, so a brief spike on a busy
        // frame says nothing, then at most one line every ten seconds.
        if (
            time - _heldSince >= 2 &&
            {time - (_coordinator getOrDefault ["limiterLastReport",-100000]) >= 10}
        ) then {
            ["ALIVE_fnc_profileSpawner - more profiles are in range than the Active Limiter allows: %1 waiting to spawn, against a limit of %2 group(s). They stay virtual and take slots as they free up, nearest to a player first. Raise the Active Limiter on the Virtual AI System module if you want more of them active at once.",
                count _spawnQueue, _activeLimiter] call ALiVE_fnc_dump;

            _coordinator set ["limiterLastReport",time];
        };
    } else {
        if ((_coordinator getOrDefault ["limiterFullSince",0]) != 0) then {
            _coordinator set ["limiterFullSince",0];
        };
    };

    if (_freeSlots > 0) then {
        private _profileToSpawn = nil;
        private _spawnIndex = 0;

        if (_contended) then {
            ///////////////////////////////////////
            //   Pick the Nearest Queued Profile
            ///////////////////////////////////////

            // More queued than there is room for, so the queue order (the order
            // the activators happened to meet them) is the wrong order. Measure
            // each one against every spawn source and take the closest, the way
            // the civilian cluster activator fills its limit. Done here rather
            // than carried through the claims because a stored distance is
            // stale the moment a player moves, and this only runs when a slot
            // is actually free, at most once per smooth-spawn interval.
            // Collapsing the sources costs a comparison per pair, so a full
            // server runs to thousands of them, and this sits in a per-frame
            // handler with no budget to spend. Nobody moves far enough in two
            // seconds to change which profile is nearest when the gaps being
            // ranked are hundreds of metres, so the list is built at most that
            // often and kept on the coordinator in between.
            private _sourcePositions = _coordinator getOrDefault ["nearestSources",[]];

            if (time > ((_coordinator getOrDefault ["nearestSourcesAt",-1000]) + 2)) then {
                // Nothing prunes ALiVE_SpawnSources, so a mission that puts its
                // own objects in there leaves null entries behind when they
                // die, and getPos on a null object reads as the map origin,
                // which would make a profile in that corner look nearest to
                // everything.
                private _spawnSources = (
                    allPlayers +
                    (allUnitsUAV select {isUavConnected _x}) +
                    ALiVE_SpawnSources
                ) select {!isNull _x};

                if ([MOD(profileSystem),"zeusSpawn"] call ALiVE_fnc_hashGet) then {
                    _spawnSources append allCurators;
                };

                // Same 30 m collapse as the proximity activator: a squad
                // standing together is one source, not four.
                _sourcePositions = [];

                {
                    private _sourcePosition = getPos _x;

                    if (_sourcePositions findIf {_x distance _sourcePosition <= 30} == -1) then {
                        _sourcePositions pushBack _sourcePosition;
                    };
                } forEach _spawnSources;

                _coordinator set ["nearestSources",_sourcePositions];
                _coordinator set ["nearestSourcesAt",time];
            };

            // Bounded on the WORK, not the entry count: this measures one
            // distance per entry per source, so a server with sources spread
            // across the map looks at fewer entries per pass to keep the
            // product in the same place. Entries past the budget wait their
            // turn as the head shrinks; nothing is ever skipped for good.
            private _bestDistance = 1e10;
            private _index = 0;
            private _scanBudget = 1 max (100 min floor (2000 / (1 max (count _sourcePositions))));

            while {
                _index < count _spawnQueue &&
                {_scanBudget > 0}
            } do {
                private _profileID = _spawnQueue select _index;

                private _profile = if (isNil {_claimCounts get _profileID}) then {
                    nil
                } else {
                    _profilesById get _profileID
                };

                private _invalid = isNil "_profile" ||
                    {(_profile select 2) select 1} ||
                    {!isNil {_pendingSpawns get _profileID}};

                if (!_invalid) then {
                    private _position = (_profile select 2) select 2;
                    private _distance = 1e10;

                    {
                        _distance = _distance min (_position distance _x);
                    } forEach _sourcePositions;

                    if (isNil "_profileToSpawn" || {_distance < _bestDistance}) then {
                        // Locked is checked only on a would-be winner: it is a
                        // linear key search on the profile hash, and most of
                        // the queue never becomes the best seen.
                        if ([_profile,"locked",false] call ALiVE_fnc_hashGet) then {
                            _invalid = true;
                        } else {
                            _bestDistance = _distance;
                            _spawnIndex = _index;
                            _profileToSpawn = _profile;
                        };
                    };
                };

                if (_invalid) then {
                    _spawnQueue deleteAt _index;
                    _spawnQueueMembership deleteAt _profileID;
                } else {
                    _index = _index + 1;
                };

                _scanBudget = _scanBudget - 1;
            };
        } else {
            // Room for everything queued: take them in the order they arrived.
            // Its own budget, deliberately. The sweep above spends a separate
            // one every frame, and sharing a counter with it would leave this
            // loop nothing to spend and stop the spawner dead under the cap.
            private _fifoChecksRemaining = 10;

            while {
                _fifoChecksRemaining > 0 &&
                {_spawnQueue isNotEqualTo []} &&
                {isNil "_profileToSpawn"}
            } do {
                private _profileID = _spawnQueue select 0;
                private _stale = isNil {_claimCounts get _profileID};

                private _profile = if (_stale) then {
                    nil
                } else {
                    _profilesById get _profileID
                };

                private _invalid = _stale ||
                    {isNil "_profile"} ||
                    {(_profile select 2) select 1} ||
                    {[_profile,"locked",false] call ALiVE_fnc_hashGet};

                if (_invalid) then {
                    _spawnQueue deleteAt 0;
                    _spawnQueueMembership deleteAt _profileID;
                    _fifoChecksRemaining = _fifoChecksRemaining - 1;
                } else {
                    _profileToSpawn = _profile;
                };
            };
        };

        if (!isNil "_profileToSpawn") then {
            private _profileID = _spawnQueue deleteAt _spawnIndex;
            _spawnQueueMembership deleteAt _profileID;

            private _profileData = _profileToSpawn select 2;

            if ((_profileData select 5) == "entity") then {
                [_profileToSpawn,"spawn"] spawn ALiVE_fnc_profileEntity;

                // One interval per man, plus a margin for the rest of the
                // spawn, so a big group on a slow setting is still counted
                // while it is on its way in.
                _pendingSpawns set [
                    _profileID,
                    time +
                    ((count ([_profileToSpawn,"unitClasses",[]] call ALiVE_fnc_hashGet)) * ALiVE_smoothSpawn) +
                    15
                ];
            } else {
                private _vehicleAssignments = [_profileToSpawn,"vehicleAssignments"] call ALiVE_fnc_hashGet;

                if (
                    isNil "_vehicleAssignments" ||
                    {(_vehicleAssignments select 1) isEqualTo []}
                ) then {
                    [_profileToSpawn,"spawn"] spawn ALiVE_fnc_profileVehicle;
                };
            };

            _coordinator set ["lastSpawnTime",time];
        };
    };
    // Limiter full: everything queued stays queued and virtual. lastSpawnTime
    // is left alone so the first slot to free up is filled on the next frame.
};
