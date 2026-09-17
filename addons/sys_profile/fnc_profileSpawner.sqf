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

///////////////////////////////////////
//     Report Discarded Profiles
///////////////////////////////////////

// A group that reaches the front of the spawn queue while the Active Limiter is
// full is thrown away rather than held back, which used to happen in silence.
// Anyone tuning placement density had no way to tell a group that was discarded
// from one that simply never came.
//
// Said here rather than where it happens, because this function is entered every
// frame whether or not anything was discarded, and the discard branch is not: it
// fires in a burst and then stops. Waiting a couple of seconds lets the burst
// finish so the count is the real one, and ten seconds between reports keeps
// sustained pressure readable instead of filling the log with itself.
private _discardedPending = _coordinator getOrDefault ["limiterDiscarded",0];

if (_discardedPending > 0) then {
    private _firstDiscard = _coordinator getOrDefault ["limiterFirstDiscard",time];
    private _lastReport = _coordinator getOrDefault ["limiterLastReport",-100000];

    if (time - _firstDiscard >= 2 && {time - _lastReport >= 10}) then {
        // The limit and the count, not how many are active right now. This runs a
        // couple of seconds after the fact, by which time the active count may
        // have fallen back under the limit, and a line that says "full" beside a
        // number below the limit reads like a fault in the message itself.
        private _limit = [MOD(profileSystem),"activeLimiter"] call ALiVE_fnc_profileSystem;

        ["ALIVE_fnc_profileSpawner - the Active Limiter filled up at %1 group(s), so %2 group(s) that were due to spawn have been thrown away. They are gone rather than delayed, and they will not come back. Raise the Active Limiter on the Virtual AI System module, or place fewer groups so fewer of them try to spawn at once.",
            _limit, _discardedPending] call ALiVE_fnc_dump;

        _coordinator set ["limiterDiscarded",0];
        _coordinator set ["limiterLastReport",time];
    };
};

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
//   Remove Stale Spawn Queue Heads
///////////////////////////////////////

private _spawnQueue = _coordinator get "spawnQueue";
private _spawnQueueMembership = _coordinator get "spawnQueueMembership";
private _spawnQueueChecksRemaining = 10;
private _checkingStaleQueueHead = true;

while {
    _spawnQueueChecksRemaining > 0 &&
    {_spawnQueue isNotEqualTo []} &&
    {_checkingStaleQueueHead}
} do {
    private _profileID = _spawnQueue select 0;
    private _stale = isNil {_claimCounts get _profileID};

    if (_stale) then {
        _spawnQueue deleteAt 0;
        _spawnQueueMembership deleteAt _profileID;
        _spawnQueueChecksRemaining = _spawnQueueChecksRemaining - 1;
    } else {
        _checkingStaleQueueHead = false;
    };
};

///////////////////////////////////////
//          Spawn Profiles
///////////////////////////////////////

private _lastProfileSpawnedTime = _coordinator get "lastSpawnTime";

if (
    _spawnQueue isNotEqualTo [] &&
    {time - _lastProfileSpawnedTime > ALiVE_smoothSpawn}
) then {
    private _profileToSpawn = nil;

    while {
        _spawnQueueChecksRemaining > 0 &&
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
            _spawnQueueChecksRemaining = _spawnQueueChecksRemaining - 1;
        } else {
            _profileToSpawn = _profile;
        };
    };

    if (!isNil "_profileToSpawn") then {
        private _profileID = _spawnQueue deleteAt 0;
        _spawnQueueMembership deleteAt _profileID;

        private _profile = _profileToSpawn;
        private _profileData = _profile select 2;
        private _activeLimiter = [MOD(profileSystem),"activeLimiter"] call ALiVE_fnc_profileSystem;
        private _activeEntityCount = count ([MOD(profileHandler),"getActiveEntities"] call ALiVE_fnc_profileHandler);
        private _spawnAllowed = _activeEntityCount < _activeLimiter;

        if (_spawnAllowed) then {
            if ((_profileData select 5) == "entity") then {
                [_profile,"spawn"] spawn ALiVE_fnc_profileEntity;
            } else {
                private _vehicleAssignments = [_profile,"vehicleAssignments"] call ALiVE_fnc_hashGet;

                if (
                    isNil "_vehicleAssignments" ||
                    {(_vehicleAssignments select 1) isEqualTo []}
                ) then {
                    [_profile,"spawn"] spawn ALiVE_fnc_profileVehicle;
                };
            };

            _coordinator set ["lastSpawnTime",time];
        } else {
            // Preserve the current active-limiter behavior.
            if (
                !(_profileData select 1) &&
                {(_profileData select 5) == "entity"}
            ) then {
                {
                    private _vehicleProfile = _profilesById get _x;

                    if (!isNil "_vehicleProfile") then {
                        [MOD(profileHandler),"unregisterProfile",_vehicleProfile] call ALiVE_fnc_profileHandler;
                    };
                } forEach (_profileData select 8);

                [MOD(profileHandler),"unregisterProfile",_profile] call ALiVE_fnc_profileHandler;

                // That group has just been thrown away, along with any vehicle it
                // was commanding. It is not held back for later: the spawn queue is
                // refilled from the profile handler, and it is no longer in there.
                //
                // Only counted here. Saying it here instead would undercount badly,
                // because this branch leaves lastSpawnTime alone and so runs again
                // on the very next frame: a queue of twelve goes in a fifth of a
                // second, and the line would name the first one and swallow the
                // other eleven. The count is reported at the top of this function.
                private _discarded = _coordinator getOrDefault ["limiterDiscarded",0];

                if (_discarded isEqualTo 0) then {
                    _coordinator set ["limiterFirstDiscard",time];
                };

                _coordinator set ["limiterDiscarded",_discarded + 1];
            };
        };
    };
};
