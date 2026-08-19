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
            };
        };
    };
};
