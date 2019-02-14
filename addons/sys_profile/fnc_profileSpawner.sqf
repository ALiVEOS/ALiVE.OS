#include "\x\ALiVE\addons\sys_profile\script_component.hpp"
SCRIPT(profileSpawner);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_profileSpawner

Description:
Spawns and despawns from profiles based on player distance

Notes:
    - Loops through spawn sources, one per frame
    - Profiles are spawned as they are found, one per frame
    - Profiles are despawned after all spawn sources have been looped through
        - This prevents profiles that are outside of one spawn sources range, but inside another's from despawning

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
SpyderBlack723
---------------------------------------------------------------------------- */

if (ALiVE_gamePaused) exitwith {};

_this = _this select 0;

private _spawnRadius = _this select 0;
private _spawnRadiusHeli = _this select 1;
private _spawnRadiusPlane = _this select 2;
private _activeLimiter = _this select 3;
private _uavSpawnRadius = _spawnRadius + 800;

private _profilesToSpawnQueue = [MOD(profileSystem),"profilesToSpawn"] call ALiVE_fnc_hashGet;
private _profilesToDespawnQueue = [MOD(profileSystem),"profilesToDespawn"] call ALiVE_fnc_hashGet;

if ([MOD(profileSystem),"paused"] call ALiVE_fnc_hashGet) exitwith {
    _profilesToSpawnQueue resize 0;
    _profilesToDespawnQueue resize 0;
};

///////////////////////////////////////
// Sort Profiles Set To Spawn/Despawn
///////////////////////////////////////

private _spawnSources = [MOD(profileSystem),"profileSpawnSources"] call ALiVE_fnc_hashGet;

if (_spawnSources isEqualTo []) then {

    // all spawn sources have been checked
    // despawn all profiles outside of range

    if !(_profilesToDespawnQueue isEqualTo []) then {
        private _profileID = _profilesToDespawnQueue select 0;
        _profilesToDespawnQueue deleteat 0;

        private _profile = [MOD(profileHandler),"getProfile", _profileID] call ALiVE_fnc_profileHandler;

        if (!isnil "_profile") then {
            private _leader = _profile select 2 select 10;

            // if unit is in the air, prevent despawn
            if ((getpos _leader) select 2 < 3) then {
                if ((_profile select 2 select 5) == "entity") then {
                    [_profile,"despawn"] call ALiVE_fnc_profileEntity;
                } else {
                    [_profile,"despawn"] call ALiVE_fnc_profileVehicle;
                };
            };
        };
    } else {
        // all profiles have been despawned
        // repopulate spawn sources

        [MOD(profileSystem),"profilesInSpawnRange", []] call ALiVE_fnc_hashSet;

        private _spawnSourcesUnfiltered = allPlayers + (allUnitsUAV select {isUavConnected _x}) + allCurators + ALiVE_SpawnSources;

        // avoid unnecessary work
        // delete spawn sources that are in close proximity
        // ie. treat squads/nearby units as a single spawn source

        while {!(_spawnSourcesUnfiltered isEqualTo [])} do {
            private _spawnSource = _spawnSourcesUnfiltered deleteat 0;
            _spawnSources pushback _spawnSource;

            _spawnSourcesUnfiltered = _spawnSourcesUnfiltered select {_x distance _spawnSource > 30};
        };
    };
} else {

    // find entities to spawn

    _spawnSource = _spawnSources select 0;
    _spawnSources deleteat 0;

    private _center = getpos _spawnSource;
    private _radius = _spawnRadius;

    // figure out what radius to use
    // based on source unit type

    if (vehicle _spawnSource iskindof "Helicopter") then {_radius = _spawnRadiusHeli};
    if (vehicle _spawnSource iskindof "Plane") then {_radius = _spawnRadiusPlane};
    if (unitIsUAV _spawnSource) then {_radius = _uavSpawnRadius};

    private _profilesInDeactivationRange = [_center,_radius * 1.2, ["all","all"], true] call ALiVE_fnc_getNearProfiles;
    private _profilesInSpawnRange = [MOD(profileSystem),"profilesInSpawnRange"] call ALiVE_fnc_hashGet;

    {
        // don't spawn or despawn player profiles
        if (!([_x,"isPlayer", false] call ALiVE_fnc_hashGet)) then {
            if (!(_x select 2 select 1)) then {
                if ((_x select 2 select 2) distance _center <= _radius) then {
                    _profilesToSpawnQueue pushbackunique (_x select 2 select 4);
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

                // mark profile as safe from despawn
                _profilesInSpawnRange pushbackunique (_x select 2 select 4);
            };
        };
    } foreach _profilesInDeactivationRange;

    // if all spawn sources have been checked
    // populate despawn list with active profiles
    // that are not in spawn range list

    if (_spawnSources isEqualTo []) then {
        // find entities to despawn
        // select ID's from activeProfiles
        // that are outside despawn range

        private _activeProfiles = [MOD(profileHandler),"profilesActive"] call ALiVE_fnc_hashGet;

        {
            if !(_x in _profilesInSpawnRange) then {
                _profilesToDespawnQueue pushback _x;
            };
        } foreach _activeProfiles;
    };
};


///////////////////////////////////////
//          Spawn Profiles
///////////////////////////////////////

private _lastProfileSpawnedTime = [MOD(profileSystem),"profileLastSpawnTime"] call ALiVE_fnc_hashGet;

if (!(_profilesToSpawnQueue isEqualTo []) && {time - _lastProfileSpawnedTime > ALiVE_smoothSpawn}) then {
    private _profileID = _profilesToSpawnQueue select 0;
    private _profile = [MOD(profileHandler),"getProfile", _profileID] call ALiVE_fnc_profileHandler;

    if (isnil "_profile" || {_profile select 2 select 1} || {[_profile,"locked", false] call ALiVE_fnc_HashGet}) then {
        // profile no longer exists, is active, or is locked
        // remove from queue

        _profilesToSpawnQueue deleteat 0;
    } else {
        private _activeEntityCount = count ([MOD(profileHandler),"getActiveEntities"] call ALiVE_fnc_profileHandler);

        if (_activeEntityCount < _activeLimiter) then {
            if ((_profile select 2 select 5) == "entity") then {
                [_profile,"spawn"] spawn ALiVE_fnc_profileEntity;
            } else {
                [_profile,"spawn"] spawn ALiVE_fnc_profileVehicle;
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