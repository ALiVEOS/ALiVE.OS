#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileActivatorPlayerProximity);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_profileActivatorPlayerProximity

Description:
Profile activator that reproduces the traditional player-distance activation
policy. It processes one spawn source per tick and returns a compact claim
batch for the centralized activation coordinator.

Parameters:
HashMap - Activator instance, or nil for create
String - Operation
Any - Operation arguments

Returns:
Any

Author:
SpyderBlack723
---------------------------------------------------------------------------- */

params [
    "_logic",
    ["_operation", ""],
    ["_args", []]
];
private _result = nil;

switch (_operation) do {
    case "create": {
        private _profileSystem = _args param [0, MOD(profileSystem)];

        _result = createHashMapFromArray [
            ["id", "playerProximity"],
            ["implementation",ALiVE_fnc_profileActivatorPlayerProximity],
            ["profileSystem", _profileSystem],
            ["iteration", 0],
            ["spawnSources", []],
            ["spawnClaims", []],
            ["retentionClaims", []]
        ];
    };

    case "tick": {
        private _spawnSources = _logic get "spawnSources";
        private _spawnClaims = _logic get "spawnClaims";
        private _retentionClaims = _logic get "retentionClaims";

        _spawnClaims resize 0;
        _retentionClaims resize 0;

        private _iteration = _logic get "iteration";
        private _complete = false;
        private _collectDespawns = false;

        if (_spawnSources isEqualTo []) then {
            _iteration = _iteration + 1;
            _logic set ["iteration",_iteration];

            private _spawnSourcesUnfiltered =
                allPlayers +
                (allUnitsUAV select {isUavConnected _x}) +
                ALiVE_SpawnSources;

            private _profileSystem = _logic get "profileSystem";
            private _zeusSpawn = [_profileSystem,"zeusSpawn"] call ALiVE_fnc_hashGet;

            if (_zeusSpawn) then {
                _spawnSourcesUnfiltered append allCurators;
            };

            while {!(_spawnSourcesUnfiltered isEqualTo [])} do {
                private _spawnSource = _spawnSourcesUnfiltered deleteAt 0;
                _spawnSources pushBack _spawnSource;

                _spawnSourcesUnfiltered =
                    _spawnSourcesUnfiltered select {
                        _x distance _spawnSource > 30
                    };
            };

            if (_spawnSources isEqualTo []) then {
                _complete = true;
            };
        } else {
            private _spawnSource = _spawnSources deleteAt 0;
            private _center = getPos _spawnSource;
            private _radius = ALIVE_spawnRadius;
            private _spawnSourceVehicle = vehicle _spawnSource;

            if (_spawnSourceVehicle isKindOf "Helicopter") then {
                _radius = ALIVE_spawnRadiusHeli;
            } else {
                if (_spawnSourceVehicle isKindOf "Plane") then {
                    _radius = ALIVE_spawnRadiusJet;
                };
            };

            if (unitIsUAV _spawnSource) then {
                _radius = [
                    ALIVE_spawnRadiusUAV,
                    ALIVE_spawnRadius + 800
                ] select (ALIVE_spawnRadiusUAV == -1);
            };

            private _profilesInDeactivationRange = [_center,_radius * 1.2,["all","all"],true] call ALiVE_fnc_getNearProfiles;

            {
                private _profileData = _x select 2;

                if ((_profileData select 5) != "entity" || {!(_profileData select 30)}) then {
                    if !(_profileData select 1) then {
                        if ((_profileData select 2) distance _center <= _radius) then {
                            private _isShip = false;
                            private _isWater = false;

                            ([_x, ["position","objectType","vehicleAssignments","vehiclesInCommandOf","vehiclesInCargoOf"]] call ALiVE_fnc_hashGetMany) params [
                                "_position",
                                "_objectTypeRaw",
                                "_vehicleAssignments",
                                ["_vehiclesInCommandOf", []],
                                ["_vehiclesInCargoOf", []]
                            ];

                            private _objectType = toLower _objectTypeRaw;

                            if (surfaceIsWater _position) then {
                                _isWater = true;
                            };

                            if (_objectType == "ship") then {
                                _isShip = true;
                            };

                            if (
                                !_isShip && {
                                    !(
                                        (_vehicleAssignments select 1)
                                        isEqualTo []
                                    )
                                }
                            ) then {
                                if (
                                    _objectType find "boat" >= 0 ||
                                    { _objectType find "ship" >= 0 }
                                ) then {
                                    _isWater = false;
                                };
                            };

                            if !(
                                _isWater &&
                                {!_isShip} &&
                                { _vehiclesInCommandOf isEqualTo [] } &&
                                { _vehiclesInCargoOf isEqualTo [] }
                            ) then {
                                _spawnClaims pushBack (_profileData select 4);
                            };
                        };
                    } else {
                        if (
                            isNull (_profileData select 10) &&
                            {(_profileData select 5) == "entity"}
                        ) then {
                            private _leader = leader (_profileData select 13);

                            if (!isNull _leader) then {
                                [_x,"leader",_leader] call ALiVE_fnc_hashSet;
                            };
                        };

                        _retentionClaims pushBack (_profileData select 4);
                    };
                };
            } forEach _profilesInDeactivationRange;

            if (_spawnSources isEqualTo []) then {
                _complete = true;
                _collectDespawns = true;
            };
        };

        _result = [
            _logic get "id",
            _iteration,
            _complete,
            _spawnClaims,
            _retentionClaims,
            _collectDespawns
        ];
    };

    case "reset": {
        (_logic get "spawnSources") resize 0;
        (_logic get "spawnClaims") resize 0;
        (_logic get "retentionClaims") resize 0;
        _logic set ["iteration",0];
        _result = true;
    };

    case "destroy": {
        [_logic,"reset"] call ALiVE_fnc_profileActivatorPlayerProximity;
        _result = true;
    };
};

[nil, _result] select (!isNil "_result")
