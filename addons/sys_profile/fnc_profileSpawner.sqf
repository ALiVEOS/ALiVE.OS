#include <\x\ALiVE\addons\sys_profile\script_component.hpp>
SCRIPT(profileSpawner);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_profileSpawner

Description:
Spawns and despawns from profiles based on player distance

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
SpyderBlack723
---------------------------------------------------------------------------- */

_this = _this select 0;

private _spawnRadius = _this select 0;
private _spawnRadiusHeli = _this select 1;
private _spawnRadiusPlane = _this select 2;
private _activeLimiter = _this select 3;

private _uavSpawnRadius = _spawnRadius + 800;

private _activeProfiles = [ALiVE_profileHandler,"profilesActive"] call ALiVE_fnc_hashGet;
private _inactiveProfiles = [ALiVE_profileHandler,"profilesInActive"] call ALiVE_fnc_hashGet;

private _profilesToSpawnQueue = [ALiVE_profileSystem,"profilesToSpawn"] call ALiVE_fnc_hashGet;
private _profilesToDespawnQueue = [ALiVE_profileSystem,"profilesToDespawn"] call ALiVE_fnc_hashGet;
private _lastProfileSpawnedTime = [ALiVE_profileSystem,"profileLastSpawnTime"] call ALiVE_fnc_hashGet;

///////////////////////////////////////
//     Spawn/Despawn Profiles
///////////////////////////////////////

private _activeEntityCount = count ([ALiVE_profileHandler,"getActiveEntities"] call ALiVE_fnc_profileHandler);

if !(_profilesToSpawnQueue isEqualTo [] && {time - _lastProfileSpawnedTime > ALiVE_smoothSpawn}) then {
    private _profileID = _profilesToSpawnQueue select 0;

    private _profile = [ALiVE_profileHandler,"getProfile", _profileID] call ALiVE_fnc_profileHandler;

    if (isnil "_profile" || {_profile select 2 select 1} || {[_profile,"locked", false] call ALiVE_fnc_HashGet}) then {
        // profile no longer exists, is active, or is locked
        // remove from queue

        _profilesToSpawnQueue deleteat 0;
    } else {
        if (_activeEntityCount < _activeLimiter) then {
            if ((_profile select 2 select 5) == "entity") then {
                [_profile,"spawn"] spawn ALiVE_fnc_profileEntity;
            } else {
                [_profile,"spawn"] spawn ALiVE_fnc_profileVehicle;
            };

            [ALiVE_profileSystem,"profileLastSpawnTime", time] call ALiVE_fnc_hashSet;

            _activeProfiles pushback _profileID;
            _inactiveProfiles deleteat (_inactiveProfiles find _profileID);
        } else {
            // we've breached the active limiter
            // unregister profile if entity and inactive

            if (!(_profile select 2 select 1) && {(_profile select 2 select 5) == "entity"}) then {
                {
                    private _vehicleProfile = [ALiVE_profileHandler,"getProfile", _x] call ALiVE_fnc_profileHandler;

                    if (!isnil "_vehicleProfile") then {
                        [ALiVE_profileHandler,"unregisterProfile", _vehicleProfile] call ALiVE_fnc_profileHandler;
                    };
                } foreach (_profile select 2 select 8); // "vehiclesInCommandOf"

                [ALiVE_profileHandler,"unregisterProfile", _profile] call ALiVE_fnc_profileHandler;
            };
        };
    };
};

if !(_profilesToDespawnQueue isEqualTo []) then {
    private _profileID = _profilesToDespawnQueue select 0;
    _profilesToDespawnQueue deleteat 0;

    private _profile = [ALiVE_profileHandler,"getProfile", _profileID] call ALiVE_fnc_profileHandler;

    if (!isnil "_profile") then {
        private _leader = _profile select 2 select 10;

        // if unit is in the air, prevent despawn
        if ((getpos _leader) select 2 < 3) then {
            if ((_profile select 2 select 5) == "entity") then {
                [_profile,"despawn"] call ALiVE_fnc_profileEntity;
            } else {
                [_profile,"despawn"] call ALiVE_fnc_profileVehicle;
            };

            _inactiveProfiles pushback _profileID;
            _activeProfiles deleteat (_activeProfiles find _profileID);
        };
    };
};

///////////////////////////////////////
// Sort Profiles Set To Spawn/Despawn
///////////////////////////////////////

private _spawnSources = [ALiVE_profileSystem,"profileSpawnSources"] call ALiVE_fnc_hashGet;
if (_spawnSources isEqualTo []) then {
    _spawnSources append allPlayers;
    _spawnSources append (allUnitsUAV select {isUavConnected _x});
};

private _inNonDespawnRange = [];

// find entities to spawn

if !(_spawnSources isEqualTo []) then {
    _spawnSource = _spawnSources select 0;
    _spawnSources deleteat 0;

    private _center = getpos _spawnSource;
    private _radius = _spawnRadius;

    // figure out what radius to use
    // based on source unit type

    switch ((typeof _spawnSource) call ALiVE_fnc_vehicleGetKindOf) do {
        case "Helicopter": {_radius = _spawnRadiusHeli};
        case "Plane": {_radius = _spawnRadiusPlane};
        default {
            if (unitIsUAV _spawnSource) then {_radius = _uavSpawnRadius};
        };
    };

    private _profilesInDeactivationRange = [_center,_radius * 1.2, ["all","all"]] call ALiVE_fnc_getNearProfiles;

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
                _inNonDespawnRange pushbackunique (_x select 2 select 4);
            };
        };
    } foreach _profilesInDeactivationRange;
};

// find entities to despawn
// select ID's from activeProfiles
// that are outside despawn range

{
    if !(_x in _inNonDespawnRange) then {
        _profilesToDespawnQueue pushbackunique _x;
    };
} foreach _activeProfiles;

//hint format ["Spawning: %1 \n\nDespawning: %2\n\ninNonDespawnRange: %3", _profilesToSpawnQueue, _profilesToDespawnQueue, _inNonDespawnRange];