#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileActivationCoordinator);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileActivationCoordinator

Description:
Owns profile activation claims and the centralized spawn/despawn queues.
Profile activators publish desired-active claims; the profile spawner consumes
the resulting queues.

Parameters:
HashMap - Coordinator instance, or nil for create
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
        private _activators = [];
        private _claimsByActivator = createHashMap;
        private _completedIterations = createHashMap;
        private _claimCounts = createHashMap;

        _result = createHashMapFromArray [
            ["activators", _activators],
            ["activatorByID", createHashMap],
            ["claimsByActivator", _claimsByActivator],
            ["completedIterations", _completedIterations],
            ["claimCounts", _claimCounts],
            [
                "claimState",
                [
                    _activators,
                    _completedIterations,
                    _claimCounts
                ]
            ],
            ["activatorReady", createHashMap],
            ["spawnQueue", []],
            ["spawnQueueMembership", createHashMap],
            ["despawnQueue", []],
            ["lastSpawnTime", 0],
            ["paused", false]
        ];
    };

    case "registerActivator": {
        private _activator = _args;
        private _activatorID = _activator get "id";
        private _implementation = _activator get "implementation";
        private _activatorByID = _logic get "activatorByID";

        if (
            _activatorID isEqualTo "" ||
            {isNil "_implementation"} ||
            {!isNil {_activatorByID get _activatorID}}
        ) exitWith {
            _result = false;
        };

        (_logic get "activators") pushBack _activator;
        _activatorByID set [_activatorID,_activator];
        (_logic get "claimsByActivator") set [_activatorID,createHashMap];
        (_logic get "completedIterations") set [_activatorID,0];
        (_logic get "activatorReady") set [_activatorID,false];

        _result = true;
    };

    case "unregisterActivator": {
        private _activatorID = _args;
        private _activatorByID = _logic get "activatorByID";
        private _activator = _activatorByID get _activatorID;

        if (isNil "_activator") exitWith {
            _result = false;
        };

        private _activators = _logic get "activators";
        private _activatorIndex = _activators find _activator;
        private _claimsByActivator = _logic get "claimsByActivator";
        private _activatorClaims = _claimsByActivator get _activatorID;
        private _claimCounts = _logic get "claimCounts";

        {
            private _claimCount = _claimCounts get _x;

            if (_claimCount <= 1) then {
                _claimCounts deleteAt _x;
            } else {
                _claimCounts set [_x,_claimCount - 1];
            };
        } forEach (keys _activatorClaims);

        if (_activatorIndex >= 0) then {
            _activators deleteAt _activatorIndex;
        };

        _activatorByID deleteAt _activatorID;
        _claimsByActivator deleteAt _activatorID;
        (_logic get "completedIterations") deleteAt _activatorID;
        (_logic get "activatorReady") deleteAt _activatorID;

        _result = true;
    };

    case "applyBatch": {
        _args params [
            "_activatorID",
            "_iteration",
            "_complete",
            "_spawnClaims",
            "_retentionClaims",
            "_collectDespawns"
        ];

        private _claimState = _logic get "claimState";
        private _completedIterations = _claimState select 1;
        private _claimCounts = _claimState select 2;
        private _claimsByActivator = _logic get "claimsByActivator";
        private _activatorClaims = _claimsByActivator get _activatorID;

        if (isNil "_activatorClaims") exitWith {
            _result = false;
        };

        {
            if (isNil {_activatorClaims get _x}) then {
                private _claimCount = _claimCounts get _x;
                _claimCounts set [
                    _x,
                    if (isNil "_claimCount") then {
                        1
                    } else {
                        _claimCount + 1
                    }
                ];
            };

            _activatorClaims set [_x,_iteration];
        } forEach _retentionClaims;

        private _spawnQueue = _logic get "spawnQueue";
        private _spawnQueueMembership = _logic get "spawnQueueMembership";

        {
            if (isNil {_activatorClaims get _x}) then {
                private _claimCount = _claimCounts get _x;
                _claimCounts set [
                    _x,
                    if (isNil "_claimCount") then {
                        1
                    } else {
                        _claimCount + 1
                    }
                ];
            };

            _activatorClaims set [_x,_iteration];

            if (isNil {_spawnQueueMembership get _x}) then {
                _spawnQueue pushBack _x;
                _spawnQueueMembership set [_x,true];
            };
        } forEach _spawnClaims;

        if (_complete) then {
            _completedIterations set [_activatorID,_iteration];

            {
                private _claimIteration = _activatorClaims get _x;

                if (_claimIteration < _iteration) then {
                    _activatorClaims deleteAt _x;

                    private _claimCount = _claimCounts get _x;

                    if (_claimCount <= 1) then {
                        _claimCounts deleteAt _x;
                    } else {
                        _claimCounts set [_x,_claimCount - 1];
                    };
                };
            } forEach (keys _activatorClaims);

            (_logic get "activatorReady") set [_activatorID,true];
        };

        if (
            _complete &&
            {_collectDespawns} &&
            {(_logic get "despawnQueue") isEqualTo []}
        ) then {
            private _allActivatorsReady = true;
            private _readyByActivator = _logic get "activatorReady";

            {
                if !(_readyByActivator get (_x get "id")) exitWith {
                    _allActivatorsReady = false;
                };
            } forEach (_logic get "activators");

            if (_allActivatorsReady) then {
                private _despawnQueue = _logic get "despawnQueue";
                private _iterationSnapshot = createHashMap;

                {
                    private _registeredActivatorID = _x get "id";
                    _iterationSnapshot set [_registeredActivatorID,_completedIterations get _registeredActivatorID];
                } forEach (_logic get "activators");

                private _activeProfiles = [MOD(profileHandler),"profilesActive"] call ALiVE_fnc_hashGet;

                {
                    if (isNil {_claimCounts get _x}) then {
                        _despawnQueue pushBack [_x,_iterationSnapshot];
                    };
                } forEach _activeProfiles;
            };
        };

        _result = true;
    };

    case "hasClaim": {
        _result = !isNil {(_logic get "claimCounts") get _args};
    };

    case "reset": {
        (_logic get "spawnQueue") resize 0;
        (_logic get "despawnQueue") resize 0;
        _logic set ["spawnQueueMembership", createHashMap];
        _logic set ["lastSpawnTime", 0];

        (_logic get "claimState") params [
            "_activators",
            "_completedIterations",
            "_claimCounts"
        ];
        private _claimsByActivator = _logic get "claimsByActivator";
        private _readyByActivator = _logic get "activatorReady";

        {
            _claimCounts deleteAt _x;
        } forEach (keys _claimCounts);

        {
            private _activatorID = _x get "id";
            _claimsByActivator set [_activatorID,createHashMap];
            _completedIterations set [_activatorID,0];
            _readyByActivator set [_activatorID,false];

            [_x,"reset"] call (_x get "implementation");
        } forEach _activators;

        _result = true;
    };

    case "destroy": {
        [_logic,"reset"] call ALiVE_fnc_profileActivationCoordinator;
        (_logic get "activators") resize 0;
        _logic set ["activatorByID", createHashMap];
        _logic set ["claimsByActivator", createHashMap];
        _logic set ["completedIterations", createHashMap];
        _logic set ["claimCounts", createHashMap];
        _logic set ["claimState", []];
        _logic set ["activatorReady", createHashMap];
        _result = true;
    };
};

[nil, _result] select (!isNil "_result")
