#include "\x\ALiVE\addons\sys_profile\script_component.hpp"
SCRIPT(profileSpawner);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_profileSpawner

Description:
Spawns and despawns from profiles based on player distance

Notes:
    - Loops through spawn sources, one per frame
    - Profiles are spawned as they are found, one per frame
    - Processes one pending despawn per frame while spawn-source iteration continues
    - Despawn candidates are collected only after all spawn sources have been checked

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
SpyderBlack723
Jman
---------------------------------------------------------------------------- */

if (ALiVE_gamePaused) exitwith {};

_this = _this select 0;

([
    MOD(profileSystem),
    ["profileSpawnQueueState","profilesToDespawn","profileInRangeIterations","paused","profileSpawnSources"]
] call ALiVE_fnc_hashGetMany) params [
    "_profileSpawnQueueState",
    "_profilesToDespawnQueue",
    "_profileInRangeIterations",
    "_paused",
    "_spawnSources"
];

private _profilesToSpawnQueue = _profileSpawnQueueState get "queue";
private _profilesToSpawnIterations = _profileSpawnQueueState get "iterationsByProfile";
private _currentSpawnIteration = _profileSpawnQueueState get "currentIteration";
private _completedSpawnIteration = _profileSpawnQueueState get "completedIteration";

private _getSpawnRadius = {
    params ["_spawnSource"];

    private _radius = ALIVE_spawnRadius;

    if (vehicle _spawnSource isKindOf "Helicopter") then {
        _radius = ALIVE_spawnRadiusHeli;
    };

    if (vehicle _spawnSource isKindOf "Plane") then {
        _radius = ALIVE_spawnRadiusJet;
    };

    if (unitIsUAV _spawnSource) then {
        _radius = [
            ALIVE_spawnRadiusUAV,
            ALIVE_spawnRadius + 800
        ] select (ALIVE_spawnRadiusUAV == -1);
    };

    _radius
};

if (_paused) exitwith {
    _profilesToSpawnQueue resize 0;
    _profileSpawnQueueState set ["iterationsByProfile", createHashMap];
    _profileSpawnQueueState set ["currentIteration", 0];
    _profileSpawnQueueState set ["completedIteration", 0];
    _profilesToDespawnQueue resize 0;

    [MOD(profileSystem),"profileInRangeIterations",createHashMap] call ALiVE_fnc_hashSet;
    [MOD(profileSystem),"profileSpawnSources", []] call ALiVE_fnc_hashSet;
};

///////////////////////////////////////
//          Process Spawn Queue
///////////////////////////////////////

if (_spawnSources isEqualTo []) then {
    // Begin the next spawn-source iteration without waiting for despawns.

    _currentSpawnIteration = _currentSpawnIteration + 1;
    _profileSpawnQueueState set ["currentIteration",_currentSpawnIteration];

    private _spawnSourcesUnfiltered = allPlayers + (allUnitsUAV select {isUavConnected _x}) + ALiVE_SpawnSources;

    private _zeusSpawn = [MOD(profileSystem),"zeusSpawn"] call ALiVE_fnc_hashGet;
    if (_zeusSpawn) then {
        _spawnSourcesUnfiltered append allCurators;
    };

    // Treat nearby units as a single spawn source.
    while {!(_spawnSourcesUnfiltered isEqualTo [])} do {
        private _spawnSource = _spawnSourcesUnfiltered deleteat 0;
        _spawnSources pushback _spawnSource;

        _spawnSourcesUnfiltered = _spawnSourcesUnfiltered select {
            _x distance _spawnSource > 30
        };
    };

    // An empty source list is already a completed iteration.
    if (_spawnSources isEqualTo []) then {
        _completedSpawnIteration = _currentSpawnIteration;
        _profileSpawnQueueState set ["completedIteration",_completedSpawnIteration];
    };

    //["TRACE | Checked Spawn Sources %1 - unfiltered %2",_spawnSources,_spawnSourcesUnfiltered] call ALiVE_fnc_Dump;
} else {

    // find entities to spawn

    private _spawnSource = _spawnSources deleteat 0;

    private _center = getpos _spawnSource;
    private _radius = [_spawnSource] call _getSpawnRadius;

    private _profilesInDeactivationRange = [_center,_radius * 1.2, ["all","all"], true] call ALiVE_fnc_getNearProfiles;

    {
        //private _type = [_x,"type","entity"] call ALiVE_fnc_HashGet;
        //private _emptyVehicle = (_type == "vehicle") && {(([_x,"entitiesInCommandOf",[]] call ALiVE_fnc_HashGet) + ([_x,"entitiesInCargoOf",[]] call ALiVE_fnc_HashGet)) isEqualTo []};

        // don't spawn or despawn player profiles
        if (!([_x,"isPlayer", false] call ALiVE_fnc_hashGet)) then {
            if (!(_x select 2 select 1)) then {  // if profile active
                if ((_x select 2 select 2) distance _center <= _radius) then {  // if profile within spawn distance radius
                    private _isShip = false;
                	private _isWater = false;

                    ([
                        _x,
                        ["position","objectType","vehicleAssignments","vehiclesInCommandOf","vehiclesInCargoOf"]
                    ] call ALiVE_fnc_hashGetMany) params [
                        "_position",
                        "_objectTypeRaw",
                        "_vehicleAssignments",
                        ["_vehiclesInCommandOf", []],
                        ["_vehiclesInCargoOf", []]
                    ];

                    private _objectType = toLower _objectTypeRaw;

                    // if profile is in water
                	if (surfaceIsWater (_position)) then { _isWater = true; };

                	// if ship
                	if (_objectType == "ship") then {_isShip = true; };

                	// if _objectType contains boat or ship
                    if (!_isShip && {!((_vehicleAssignments select 1) isEqualTo [])}) then {
                        if (["boat", _objectType] call BIS_fnc_inString || ["ship", _objectType] call BIS_fnc_inString) then {
                            _isWater = false;
                        };
                    };

                    if (_isWater && !_isShip && {_vehiclesInCommandOf isEqualTo [] && {_vehiclesInCargoOf isEqualTo []}}) exitWith {  // #923: don't skip boat crews/passengers - they spawn into the vehicle, not the sea
                    // ["Profile Spawner - Profile in Water & Not a Ship : Don't Spawn!. _type: %4, _isWater: %5, _faction %1, _profileID: %2, _objectType: %3", _faction, _profileID, _objectType, _type, _isWater] call ALiVE_fnc_dump;   
                  };

                  private _profileID = _x select 2 select 4;
                  if (isNil {_profilesToSpawnIterations get _profileID}) then {
                      _profilesToSpawnQueue pushback _profileID;
                  };

                  // Refresh demand for this profile. Existing queue entries are
                  // not duplicated; only their last-seen iteration changes.
                  _profilesToSpawnIterations set [_profileID, _currentSpawnIteration];
  
                };
                
            } else {
                // if leader is null
                // find new leader
                if (isnull (_x select 2 select 10) && {(_x select 2 select 5) == "entity"}) then {
                    private _leader = leader (_x select 2 select 13); // group

                    if (!isnull _leader) then {
                        [_x,"leader", _leader] call ALiVE_fnc_hashSet;
                    };
                };

                // Record the latest iteration that found this active profile
                // inside a deactivation radius.
                _profileInRangeIterations set [
                    _x select 2 select 4,
                    _currentSpawnIteration
                ];
            };
        };
    } foreach _profilesInDeactivationRange;

    //["TRACE | Collected Profiles to be spawned %1",_profilesToSpawnQueue] call ALiVE_fnc_Dump;

    // if all spawn sources have been checked
    // populate despawn list with active profiles
    // that are not in spawn range list

    if (_spawnSources isEqualTo []) then {
        // Only a fully scanned iteration may invalidate older queue entries.
        _completedSpawnIteration = _currentSpawnIteration;
        _profileSpawnQueueState set ["completedIteration", _completedSpawnIteration];

        // Do not duplicate candidates from an older despawn iteration.
        if (_profilesToDespawnQueue isEqualTo []) then {
            private _activeProfiles = [MOD(profileHandler),"profilesActive"] call ALiVE_fnc_hashGet;

            {
                private _lastInRangeIteration = _profileInRangeIterations get _x;

                if (
                    isNil "_lastInRangeIteration" ||
                    {_lastInRangeIteration < _currentSpawnIteration}
                ) then {
                    _profilesToDespawnQueue pushBack [
                        _x,
                        _currentSpawnIteration
                    ];
                };
            } forEach _activeProfiles;
        };

        //["TRACE | Collected Profiles to be despawned %1",_profilesToDespawnQueue] call ALiVE_fnc_Dump;
    };
};

///////////////////////////////////////
//          Despawn Profiles
///////////////////////////////////////

if !(_profilesToDespawnQueue isEqualTo []) then {
    private _despawnEntry = _profilesToDespawnQueue select 0;
    _despawnEntry params ["_profileID","_despawnIteration"];

    // Give one complete newer iteration the opportunity to cancel this entry.
    if (_completedSpawnIteration > _despawnIteration) then {
        _profilesToDespawnQueue deleteAt 0;

        private _lastInRangeIteration = _profileInRangeIterations get _profileID;
        if (
            isNil "_lastInRangeIteration" ||
            {_lastInRangeIteration <= _despawnIteration}
        ) then {
            private _profile = [MOD(profileHandler),"getProfile",_profileID] call ALiVE_fnc_profileHandler;

            if (!isNil "_profile") then {
                private _leader = _profile select 2 select 10;

                // if unit is in the air, prevent despawn
                if ((getPos _leader) select 2 < 3) then {
                    if ((_profile select 2 select 5) == "entity") then {
                        [_profile,"despawn"] call ALiVE_fnc_profileEntity;
                    } else {
                        private _vehicleAssignments = [_profile,"vehicleAssignments"] call ALiVE_fnc_hashGet;

                        if (isNil "_vehicleAssignments" || {(_vehicleAssignments select 1) isEqualTo []}) then {
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

private _spawnQueueChecksRemaining = 10;
private _checkingStaleQueueHead = true;

while {
    _spawnQueueChecksRemaining > 0 &&
    {_profilesToSpawnQueue isNotEqualTo []} &&
    {_checkingStaleQueueHead}
} do {
    private _profileID = _profilesToSpawnQueue select 0;
    private _lastSeenIteration = _profilesToSpawnIterations get _profileID;

    private _stale = isNil "_lastSeenIteration" || {_lastSeenIteration < _completedSpawnIteration};

    if (_stale) then {
        _profilesToSpawnQueue deleteAt 0;
        _profilesToSpawnIterations deleteAt _profileID;
        _spawnQueueChecksRemaining = _spawnQueueChecksRemaining - 1;
    } else {
        _checkingStaleQueueHead = false;
    };
};

///////////////////////////////////////
//          Spawn Profiles
///////////////////////////////////////

private _lastProfileSpawnedTime = [MOD(profileSystem),"profileLastSpawnTime"] call ALiVE_fnc_hashGet;

if (
    _profilesToSpawnQueue isNotEqualTo [] &&
    {time - _lastProfileSpawnedTime > ALiVE_smoothSpawn}
) then {
    private _profileToSpawn = nil;

    // Full profile validation is only performed when spawning is permitted.
    // Continue past invalid entries without exceeding the per-frame budget.
    while {
        _spawnQueueChecksRemaining > 0 &&
        {_profilesToSpawnQueue isNotEqualTo []} &&
        {isNil "_profileToSpawn"}
    } do {
        private _profileID = _profilesToSpawnQueue select 0;
        private _lastSeenIteration = _profilesToSpawnIterations get _profileID;
        private _stale = isNil "_lastSeenIteration" || {_lastSeenIteration < _completedSpawnIteration};

        private _profile = if (_stale) then {
            nil
        } else {
            [MOD(profileHandler),"getProfile",_profileID] call ALiVE_fnc_profileHandler
        };

        private _invalid = _stale ||
            {isNil "_profile"} ||
            {_profile select 2 select 1} ||
            {[_profile,"locked",false] call ALiVE_fnc_hashGet};

        if (_invalid) then {
            _profilesToSpawnQueue deleteAt 0;
            _profilesToSpawnIterations deleteAt _profileID;
            _spawnQueueChecksRemaining = _spawnQueueChecksRemaining - 1;
        } else {
            _profileToSpawn = _profile;
        };
    };

    if (!isNil "_profileToSpawn") then {
        private _profileID = _profilesToSpawnQueue deleteAt 0;
        _profilesToSpawnIterations deleteAt _profileID;
        private _profile = _profileToSpawn;

        private _activeLimiter = [MOD(profileSystem),"activeLimiter"] call ALiVE_fnc_profileSystem;
        private _activeEntityCount = count ([MOD(profileHandler),"getActiveEntities"] call ALiVE_fnc_profileHandler);

        if (_activeEntityCount < _activeLimiter) then {
            if ((_profile select 2 select 5) == "entity") then {
                [_profile,"spawn"] spawn ALiVE_fnc_profileEntity;
            } else {
                private _vehicleAssignments = [_profile,"vehicleAssignments"] call ALiVE_fnc_HashGet;

                if (isNil "_vehicleAssignments" || {(_vehicleAssignments select 1) isEqualTo []}) then {
                    [_profile,"spawn"] spawn ALiVE_fnc_profileVehicle;
                };
            };

            [MOD(profileSystem),"profileLastSpawnTime", time] call ALiVE_fnc_hashSet;
        } else {
            // we've breached the active limiter
            // unregister profile if entity and inactive

            if (!(_profile select 2 select 1) && {(_profile select 2 select 5) == "entity"}) then {
                {
                    private _vehicleProfile = [MOD(profileHandler),"getProfile", _x] call ALiVE_fnc_profileHandler;

                    if (!isnil "_vehicleProfile") then {
                        [MOD(profileHandler),"unregisterProfile", _vehicleProfile] call ALiVE_fnc_profileHandler;
                    };
                } foreach (_profile select 2 select 8); // "vehiclesInCommandOf"

                [MOD(profileHandler),"unregisterProfile", _profile] call ALiVE_fnc_profileHandler;
            };
        };
    };
};
