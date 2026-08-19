#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileActivatorAirCombat);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_profileActivatorAirCombat

Description:
Optional air-combat profile activator. It incrementally scans operational
aircraft and anti-air vehicles globally, and ordinary vehicles around
airborne player aircraft.

Parameters:
HashMap - Activator instance, or nil for create
String - Operation
Any - Operation arguments

Returns:
Any

Author:
SpyderBlack723
---------------------------------------------------------------------------- */

#define MAINCLASS ALiVE_fnc_profileActivatorAirCombat

#define AIR_COMBAT_SCAN_BATCH_SIZE 16
#define AIR_COMBAT_AIRBORNE_ALTITUDE 3
#define AIR_COMBAT_VEHICLES_SCAN_BATCH_SIZE 16
#define AIR_COMBAT_VEHICLES_AIRBORNE_ALTITUDE 3
#define AIR_COMBAT_VEHICLES_DEFAULT_PLANE_RADIUS 7000
#define AIR_COMBAT_VEHICLES_DEFAULT_HELICOPTER_RADIUS 5000
#define AIR_COMBAT_VEHICLES_QUERY_FACTOR 1.2
#define AIR_COMBAT_VEHICLES_LAND_OBJECT_TYPES ["Car","Tank","Armored","Truck","StaticWeapon","Vehicle"]
#define AIR_COMBAT_VEHICLES_AIR_OBJECT_TYPES ["Plane","Helicopter"]
#define AIR_COMBAT_VEHICLES_OBJECT_TYPES ["Car","Tank","Armored","Truck","StaticWeapon","Vehicle","Plane","Helicopter"]


params [
    "_logic",
    ["_operation", ""],
    ["_args", []]
];
private _result = nil;

switch (_operation) do {
    case "create": {
        _args params [
            ["_planeVehicleRadius", AIR_COMBAT_VEHICLES_DEFAULT_PLANE_RADIUS],
            ["_helicopterVehicleRadius", AIR_COMBAT_VEHICLES_DEFAULT_HELICOPTER_RADIUS]
        ];

        _result = createHashMapFromArray [
            ["id", "airCombat"],
            ["implementation", MAINCLASS],
            ["iteration", 0],
            ["iterationActive", false],
            ["scanPhase", 0],
            ["candidateIDs", []],
            ["candidateIDIndex", 0],
            ["aaaClassCache", createHashMap],
            ["planeVehicleRadius", _planeVehicleRadius max 0],
            ["helicopterVehicleRadius", _helicopterVehicleRadius max 0],
            ["vehicleIterationActive", false],
            ["rangeSources", []],
            ["rangeSourceIndex", 0],
            ["rangeProfiles", []],
            ["rangeProfileIndex", 0],
            ["rangeProfilesReady", false],
            ["rangeSeenProfileIDs", createHashMap],
            ["cargoClaimQueue", []],
            ["vehiclePublishedClaims", []],
            ["vehiclePendingClaims", []],
            ["claims", []]
        ];
    };

    case "tick": {
        private _profileHandler = MOD(profileHandler);
        private _scanPhase = _logic get "scanPhase";
        private _candidateIDs = _logic get "candidateIDs";
        private _candidateIDIndex = _logic get "candidateIDIndex";
        private _claims = _logic get "claims";
        private _aaaClassCache = _logic get "aaaClassCache";
        private _vehicleIterationActive = _logic get "vehicleIterationActive";
        private _rangeSources = _logic get "rangeSources";
        private _rangeSourceIndex = _logic get "rangeSourceIndex";
        private _rangeProfiles = _logic get "rangeProfiles";
        private _rangeProfileIndex = _logic get "rangeProfileIndex";
        private _rangeProfilesReady = _logic get "rangeProfilesReady";
        private _rangeSeenProfileIDs = _logic get "rangeSeenProfileIDs";
        private _cargoClaimQueue = _logic get "cargoClaimQueue";
        private _vehiclePublishedClaims = _logic get "vehiclePublishedClaims";
        private _vehiclePendingClaims = _logic get "vehiclePendingClaims";

        _claims resize 0;

        private _iteration = _logic get "iteration";

        if !(_logic get "iterationActive") then {
            _iteration = _iteration + 1;
            _logic set ["iteration",_iteration];
            _scanPhase = 0;
            _candidateIDs = [];
            _candidateIDIndex = 0;
            _logic set ["iterationActive",true];
        };

        private _workRemaining = AIR_COMBAT_SCAN_BATCH_SIZE;
        while {_workRemaining > 0} do {
            private _didWork = false;

            switch (_scanPhase) do {
                // get air profiles
                case 0: {
                    private _profilesByVehicleType = [MOD(profileHandler),"profilesByVehicleType"] call ALIVE_fnc_hashGet;

                    private _planeIDs = [_profilesByVehicleType,"Plane", []] call ALiVE_fnc_hashGet;
                    private _helicopterIDs = [_profilesByVehicleType,"Helicopter", []] call ALiVE_fnc_hashGet;

                    _candidateIDs = +_planeIDs;
                    _candidateIDs append (+_helicopterIDs);

                    _candidateIDIndex = 0;
                    _scanPhase = 1;
                    _didWork = true;
                };

                // get vehicle profiles
                // will be checked for AAA profiles
                case 2: {
                    private _profilesByType = [MOD(profileHandler),"profilesByType"] call ALIVE_fnc_hashGet;
                    private _profileIDs = [_profilesByType,"vehicle", []] call ALIVE_fnc_hashGet;

                    _candidateIDs = +_profileIDs;

                    _candidateIDIndex = 0;
                    _scanPhase = 3;
                    _didWork = true;
                };

                case 1;
                case 3: {
                    if (_candidateIDIndex < count _candidateIDs) then {
                        private _profileID = _candidateIDs select _candidateIDIndex;
                        _candidateIDIndex = _candidateIDIndex + 1;

                        private _profile = [_profileHandler,"getProfile", _profileID] call ALiVE_fnc_profileHandler;

                        if (!isNil "_profile") then {
                            private _profileData = _profile select 2;

                            if ((_profileData select 5) isEqualTo "vehicle") then {
                                private _active = _profileData select 1;
                                private _vehicle = _profileData select 10;

                                private _eligible = false;

                                if (_scanPhase == 1) then {
                                    private _engineOn = _profileData select 15;
                                    private _canMove = _profileData select 17;
                                    private _position = _profileData select 2;
                                    private _airborne = false;

                                    if (_engineOn && {_canMove} && {count _position > 2}) then {
                                        _airborne = (_position select 2) >= AIR_COMBAT_AIRBORNE_ALTITUDE;
                                    };

                                    _eligible = _airborne && { !_active || {alive _vehicle} };
                                } else {
                                    private _objectType = _profileData select 6;

                                    if !((toLower _objectType) in ["plane","helicopter"]) then {
                                        private _vehicleClass = _profileData select 11;

                                        private _isAntiAirCapable = _aaaClassCache get _vehicleClass;

                                        if (isNil "_isAntiAirCapable") then {
                                            _isAntiAirCapable = [_vehicleClass] call ALiVE_fnc_isAntiAirCapable;
                                            _aaaClassCache set [_vehicleClass, _isAntiAirCapable];
                                        };

                                        if (_isAntiAirCapable) then {
                                            private _canFire = _profileData select 18;
                                            _eligible = _canFire isEqualType true && {_canFire} && {!_active || {alive _vehicle && {canFire _vehicle}}};
                                        };
                                    };
                                };

                                if (_eligible) then {
                                    private _entitiesInCommandOf = _profileData select 8;

                                    if (_entitiesInCommandOf isEqualType []) then {
                                        {
                                            private _entityProfileID = _x;
                                            private _entityProfile = [_profileHandler,"getProfile", _entityProfileID] call ALiVE_fnc_profileHandler;

                                            if (!isNil "_entityProfile") then {
                                                private _entityProfileData = _entityProfile select 2;

                                                if (
                                                    (_entityProfileData select 5) isEqualTo "entity" &&
                                                    {!(_entityProfileData select 30)} // isPlayer
                                                ) then {
                                                    _claims pushBackUnique _entityProfileID;
                                                };
                                            };
                                        } forEach _entitiesInCommandOf;
                                    };
                                };

                                if (_eligible) then {
                                    _claims pushBackUnique _profileID;
                                };
                            };
                        };

                        if (_candidateIDIndex >= count _candidateIDs) then {
                            _candidateIDs resize 0;
                            _candidateIDIndex = 0;
                            _scanPhase = if (_scanPhase == 1) then {2} else {4};
                        };
                        _didWork = true;
                    } else {
                        _candidateIDs resize 0;
                        _candidateIDIndex = 0;
                        _scanPhase = if (_scanPhase == 1) then {2} else {4};
                        _didWork = true;
                    };
                };

                default {};
            };

            _workRemaining = _workRemaining - 1;

            if (!_didWork) exitWith {};
        };

        private _complete = _scanPhase >= 4;

        _logic set ["scanPhase", _scanPhase];
        _logic set ["candidateIDs", _candidateIDs];
        _logic set ["candidateIDIndex", _candidateIDIndex];

        if (_complete) then {
            _logic set ["iterationActive", false];
        };

        if (!_vehicleIterationActive) then {
            _vehiclePendingClaims resize 0;

            _rangeSources resize 0;
            _rangeSourceIndex = 0;
            _rangeProfiles resize 0;
            _rangeProfileIndex = 0;
            _rangeProfilesReady = false;
            _rangeSeenProfileIDs = createHashMap;
            _cargoClaimQueue resize 0;

            private _sourceVehicles = [];
            private _players = allPlayers;
            private _playerIndex = 0;

            while {_playerIndex < count _players} do {
                private _player = _players select _playerIndex;
                private _vehicle = objNull;

                if (!isNull _player && {alive _player}) then {
                    _vehicle = vehicle _player;
                };

                if (!isNull _vehicle && {alive _vehicle}) then {
                    private _radius = 0;

                    if (_vehicle isKindOf "Plane") then {
                        _radius = _logic get "planeVehicleRadius";
                    } else {
                        if (_vehicle isKindOf "Helicopter") then {
                            _radius = _logic get "helicopterVehicleRadius";
                        };
                    };

                    if (_radius > 0 && {_sourceVehicles find _vehicle < 0}) then {
                        _sourceVehicles pushBack _vehicle;
                        private _position = getPosATL _vehicle;

                        if ((_position select 2) >= AIR_COMBAT_VEHICLES_AIRBORNE_ALTITUDE) then {
                            _rangeSources pushBack [_position, _radius];
                        };
                    };
                };

                _playerIndex = _playerIndex + 1;
            };

            _vehicleIterationActive = true;
        };

        private _vehicleWorkRemaining = AIR_COMBAT_VEHICLES_SCAN_BATCH_SIZE;
        while {_vehicleWorkRemaining > 0} do {
            private _didVehicleWork = false;

            if (_cargoClaimQueue isNotEqualTo []) then {
                private _cargoProfileID = _cargoClaimQueue deleteAt 0;
                private _cargoProfile = [_profileHandler,"getProfile",_cargoProfileID] call ALiVE_fnc_profileHandler;

                if (!isNil "_cargoProfile") then {
                    private _cargoProfileData = _cargoProfile select 2;

                    if (
                        (_cargoProfileData select 5) isEqualTo "entity" &&
                        {!(_cargoProfileData select 30)}
                    ) then {
                        _vehiclePendingClaims pushBackUnique _cargoProfileID;
                    };
                };

                _didVehicleWork = true;
            } else {
                if (_rangeProfilesReady) then {
                    if (_rangeProfileIndex < count _rangeProfiles) then {
                        private _nearProfile = _rangeProfiles select _rangeProfileIndex;
                        _rangeProfileIndex = _rangeProfileIndex + 1;
                        private _rangeProfileID = (_nearProfile select 2) select 4;
                        private _rangeSeenState = _rangeSeenProfileIDs getOrDefault [_rangeProfileID, 0];

                        if (_rangeSeenState == 0) then {
                            private _rangeState = 2;
                            private _profile = [_profileHandler,"getProfile",_rangeProfileID] call ALiVE_fnc_profileHandler;

                            if (!isNil "_profile") then {
                                private _profileData = _profile select 2;

                                if ((_profileData select 5) isEqualTo "vehicle") then {
                                    private _objectType = _profileData select 6;
                                    private _isLandVehicle = _objectType in AIR_COMBAT_VEHICLES_LAND_OBJECT_TYPES;
                                    private _isAirVehicle = _objectType in AIR_COMBAT_VEHICLES_AIR_OBJECT_TYPES;

                                    if (_isLandVehicle || {_isAirVehicle}) then {
                                        private _active = _profileData select 1;
                                        private _profilePosition = _profileData select 2;
                                        private _profileVehicle = _profileData select 10;

                                        if (_active && {!isNull _profileVehicle} && {alive _profileVehicle}) then {
                                            _profilePosition = getPosATL _profileVehicle;
                                        };

                                        private _eligible = _isLandVehicle || {
                                            _isAirVehicle && {(_profilePosition select 2) < AIR_COMBAT_VEHICLES_AIRBORNE_ALTITUDE}
                                        };

                                        if (_eligible && {_isLandVehicle}) then {
                                            private _vehicleClass = _profileData select 11;
                                            private _isAntiAirCapable = _aaaClassCache get _vehicleClass;

                                            if (isNil "_isAntiAirCapable") then {
                                                _isAntiAirCapable = [_vehicleClass] call ALiVE_fnc_isAntiAirCapable;
                                                _aaaClassCache set [_vehicleClass, _isAntiAirCapable];
                                            };

                                            _eligible = !_isAntiAirCapable;
                                        };

                                        if (_eligible) then {
                                            private _source = _rangeSources select _rangeSourceIndex;
                                            private _sourceRadius = _source select 1;
                                            private _distance = (_source select 0) distance2D _profilePosition;
                                            private _inRange = if (_active) then {
                                                _distance <= (_sourceRadius * AIR_COMBAT_VEHICLES_QUERY_FACTOR)
                                            } else {
                                                _distance <= _sourceRadius
                                            };

                                            if (_inRange) then {
                                                {
                                                    private _entityProfileID = _x;
                                                    private _entityProfile = [_profileHandler,"getProfile",_entityProfileID] call ALiVE_fnc_profileHandler;

                                                    if (!isNil "_entityProfile") then {
                                                        private _entityProfileData = _entityProfile select 2;

                                                        if (
                                                            (_entityProfileData select 5) isEqualTo "entity" &&
                                                            {!(_entityProfileData select 30)}
                                                        ) then {
                                                            _vehiclePendingClaims pushBackUnique _entityProfileID;
                                                        };
                                                    };
                                                } forEach (_profileData select 8);

                                                _vehiclePendingClaims pushBackUnique _rangeProfileID;
                                                _cargoClaimQueue append (_profileData select 9);
                                                _rangeState = 1;
                                            } else {
                                                // Leave it available for an overlapping source.
                                                _rangeState = 0;
                                            };
                                        };
                                    };
                                };
                            };

                            _rangeSeenProfileIDs set [_rangeProfileID, _rangeState];
                        };

                        _didVehicleWork = true;
                    } else {
                        _rangeProfiles resize 0;
                        _rangeProfileIndex = 0;
                        _rangeProfilesReady = false;
                        _rangeSourceIndex = _rangeSourceIndex + 1;
                        _didVehicleWork = true;
                    };
                } else {
                    if (_rangeSourceIndex < count _rangeSources) then {
                        private _source = _rangeSources select _rangeSourceIndex;
                        private _nearProfiles = [
                            _source select 0,
                            (_source select 1) * AIR_COMBAT_VEHICLES_QUERY_FACTOR,
                            ["all","vehicle",AIR_COMBAT_VEHICLES_OBJECT_TYPES],
                            true
                        ] call ALiVE_fnc_getNearProfiles;

                        _rangeProfiles = +_nearProfiles;
                        _rangeProfileIndex = 0;
                        _rangeProfilesReady = true;
                        _didVehicleWork = true;
                    };
                };
            };

            _vehicleWorkRemaining = _vehicleWorkRemaining - 1;
            if (!_didVehicleWork) exitWith {};
        };

        private _vehicleComplete = (
            _cargoClaimQueue isEqualTo [] &&
            {!_rangeProfilesReady} &&
            {_rangeSourceIndex >= count _rangeSources}
        );

        if (_vehicleComplete) then {
            _vehiclePublishedClaims = +_vehiclePendingClaims;
            _vehicleIterationActive = false;
        };

        {
            _claims pushBackUnique _x;
        } forEach _vehiclePublishedClaims;
        {
            _claims pushBackUnique _x;
        } forEach _vehiclePendingClaims;

        _logic set ["vehicleIterationActive", _vehicleIterationActive];
        _logic set ["rangeSources", _rangeSources];
        _logic set ["rangeSourceIndex", _rangeSourceIndex];
        _logic set ["rangeProfiles", _rangeProfiles];
        _logic set ["rangeProfileIndex", _rangeProfileIndex];
        _logic set ["rangeProfilesReady", _rangeProfilesReady];
        _logic set ["rangeSeenProfileIDs", _rangeSeenProfileIDs];
        _logic set ["cargoClaimQueue", _cargoClaimQueue];
        _logic set ["vehiclePublishedClaims", _vehiclePublishedClaims];
        _logic set ["vehiclePendingClaims", _vehiclePendingClaims];

        _result = [
            _logic get "id",
            _iteration,
            _complete,
            _claims,
            _complete
        ];
    };

    case "reset": {
        (_logic get "candidateIDs") resize 0;
        (_logic get "claims") resize 0;
        (_logic get "rangeSources") resize 0;
        (_logic get "rangeProfiles") resize 0;
        (_logic get "cargoClaimQueue") resize 0;
        (_logic get "vehiclePublishedClaims") resize 0;
        (_logic get "vehiclePendingClaims") resize 0;
        _logic set ["iterationActive",false];
        _logic set ["vehicleIterationActive",false];
        _logic set ["scanPhase",0];
        _logic set ["candidateIDIndex",0];
        _logic set ["rangeSourceIndex",0];
        _logic set ["rangeProfileIndex",0];
        _logic set ["rangeProfilesReady",false];
        _logic set ["rangeSeenProfileIDs",createHashMap];
        _logic set ["iteration",0];
        _result = true;
    };

    case "destroy": {
        [_logic,"reset"] call MAINCLASS;
        _result = true;
    };
};

[nil, _result] select (!isNil "_result")
