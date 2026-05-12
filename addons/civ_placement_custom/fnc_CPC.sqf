//#define DEBUG_MODE_FULL
#include "\x\alive\addons\civ_placement_custom\script_component.hpp"
SCRIPT(CPC);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_CPC
Description:
Custom civilian objectives that mirror civ_placement behaviour on a hand-placed
objective instead of indexed civilian clusters.

Author:
Javen
Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_CPC
#define DEFAULT_FORCE_SIZE "100"
#define DEFAULT_OBJECTIVE_SIZE "200"
#define DEFAULT_WITH_PLACEMENT true
#define DEFAULT_OBJECTIVES []
#define DEFAULT_OBJECTIVES_MARINE []
#define DEFAULT_TYPE "Random"
#define DEFAULT_FACTION QUOTE(BLU_F)
#define DEFAULT_NO_TEXT ""
#define DEFAULT_READINESS_LEVEL "1"
#define DEFAULT_RB "10"
#define DEFAULT_SEAPATROL_CHANCE 0
#define DEFAULT_PRIORITY "50"
#define DEFAULT_AMBIENT_GUARD_AMOUNT "0.2"
#define DEFAULT_AMBIENT_GUARD_RADIUS "200"
#define DEFAULT_AMBIENT_GUARD_PATROL_PERCENT "50"

TRACE_1("CPC - input",_this);

params [
    ["_logic", objNull, [objNull]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

private _result = true;

switch (_operation) do {
    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
    case "destroy": {
        [_logic, "debug", false] call MAINCLASS;

        if (isServer) then {
            _logic setVariable ["super", nil];
            _logic setVariable ["class", nil];
            [_logic, "destroy"] call SUPERCLASS;
        };
    };
    case "debug": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["debug", _args];
        } else {
            _args = _logic getVariable ["debug", false];
        };

        if (typeName _args == "STRING") then {
            _args = (_args == "true");
            _logic setVariable ["debug", _args];
        };

        ASSERT_TRUE(typeName _args == "BOOL", str _args);
        _result = _args;
    };
    case "state": {
        private _simpleOperations = ["targets", "objectiveSize", "size", "type", "faction", "priority", "asymmetricInstallationCountOverrides"];

        if (typeName _args != "ARRAY") then {
            private _state = [] call CBA_fnc_hashCreate;
            {
                [_state, _x, _logic getVariable _x] call ALIVE_fnc_hashSet;
            } forEach _simpleOperations;

            if ([_logic, "debug"] call MAINCLASS) then {
                diag_log PFORMAT_2(QUOTE(MAINCLASS), _operation, _state);
            };

            _result = _state;
        } else {
            ASSERT_TRUE([_args] call ALIVE_fnc_isHash, str _args);

            {
                [_logic, _x, [_args, _x] call ALIVE_fnc_hashGet] call MAINCLASS;
            } forEach _simpleOperations;
        };
    };
    case "objectiveSize": {
        _result = [_logic, _operation, _args, DEFAULT_OBJECTIVE_SIZE] call ALIVE_fnc_OOsimpleOperation;
    };
    case "priority": {
        _result = [_logic, _operation, _args, DEFAULT_PRIORITY] call ALIVE_fnc_OOsimpleOperation;
    };
    case "size": {
        _result = [_logic, _operation, _args, DEFAULT_FORCE_SIZE] call ALIVE_fnc_OOsimpleOperation;
    };
    case "type": {
        _result = [_logic, _operation, _args, DEFAULT_TYPE, ["Random","Armored","Mechanized","Motorized","Infantry","Air","Specops"]] call ALIVE_fnc_OOsimpleOperation;

        if (_result == "Random") then {
            _result = selectRandom ["Armored","Mechanized","Motorized","Infantry","Air"];
            _logic setVariable ["type", _result];
        };
    };
    case "placeSeaPatrols": {
        if (typeName _args == "SCALAR") then {
            _logic setVariable ["placeSeaPatrols", _args];
        } else {
            _args = _logic getVariable ["placeSeaPatrols", DEFAULT_SEAPATROL_CHANCE];
        };

        if (typeName _args == "STRING") then {
            _args = parseNumber _args;
            _logic setVariable ["placeSeaPatrols", _args];
        };

        ASSERT_TRUE(typeName _args == "SCALAR", str _args);
        _result = _args;
    };
    case "customInfantryCount": {
        _result = [_logic, _operation, _args, DEFAULT_NO_TEXT] call ALIVE_fnc_OOsimpleOperation;
    };
    case "customMotorisedCount": {
        _result = [_logic, _operation, _args, DEFAULT_NO_TEXT] call ALIVE_fnc_OOsimpleOperation;
    };
    case "customMechanisedCount": {
        _result = [_logic, _operation, _args, DEFAULT_NO_TEXT] call ALIVE_fnc_OOsimpleOperation;
    };
    case "customArmourCount": {
        _result = [_logic, _operation, _args, DEFAULT_NO_TEXT] call ALIVE_fnc_OOsimpleOperation;
    };
    case "customSpecOpsCount": {
        _result = [_logic, _operation, _args, DEFAULT_NO_TEXT] call ALIVE_fnc_OOsimpleOperation;
    };
    case "asymmetricInstallationCountOverrides": {
        _result = [_logic, _operation, _args, DEFAULT_NO_TEXT] call ALIVE_fnc_OOsimpleOperation;
    };
    case "onEachSpawn": {
        _result = [_logic, _operation, _args, ""] call ALIVE_fnc_OOsimpleOperation;
    };
    case "onEachSpawnOnce": {
        _result = [_logic, _operation, _args, true] call ALIVE_fnc_OOsimpleOperation;
    };

    case "faction": {
        _result = [_logic, _operation, _args, DEFAULT_FACTION, [] call ALiVE_fnc_configGetFactions] call ALIVE_fnc_OOsimpleOperation;

        if !(_args isEqualType "") then {
            private _compiledFaction = [_logic] call ALiVE_fnc_factionCompilerResolveForModule;
            if !(_compiledFaction isEqualTo "") then {
                _result = _compiledFaction;
            };
        };
    };
    case "guardProbability": {
        _result = [_logic, _operation, _args, DEFAULT_AMBIENT_GUARD_AMOUNT] call ALIVE_fnc_OOsimpleOperation;
    };
    case "guardRadius": {
        _result = [_logic, _operation, _args, DEFAULT_AMBIENT_GUARD_RADIUS] call ALIVE_fnc_OOsimpleOperation;
    };
    case "guardPatrolPercentage": {
        _result = [_logic, _operation, _args, DEFAULT_AMBIENT_GUARD_PATROL_PERCENT] call ALIVE_fnc_OOsimpleOperation;
    };
    case "readinessLevel": {
        _result = [_logic, _operation, _args, DEFAULT_READINESS_LEVEL] call ALIVE_fnc_OOsimpleOperation;
    };
    case "withPlacement": {
        if (isNil "_args" || {isNull _args}) then {
            _args = _logic getVariable ["withPlacement", DEFAULT_WITH_PLACEMENT];
        };

        if (isNil "_args") exitWith {_result = DEFAULT_WITH_PLACEMENT};
        if (_args isEqualType "") then {_args = (_args == "true")};

        _result = [_logic, _operation, _args, DEFAULT_WITH_PLACEMENT] call ALIVE_fnc_OOsimpleOperation;
    };
    case "objectives": {
        _result = [_logic, _operation, _args, DEFAULT_OBJECTIVES] call ALIVE_fnc_OOsimpleOperation;
    };
    case "objectivesMarine": {
        _result = [_logic, _operation, _args, DEFAULT_OBJECTIVES_MARINE] call ALIVE_fnc_OOsimpleOperation;
    };
    case "roadblocks": {
        _result = [_logic, "roadBlocks", _args] call MAINCLASS;
    };
    case "roadBlocks": {
        _result = [_logic, _operation, _args, DEFAULT_RB] call ALIVE_fnc_OOsimpleOperation;
    };
    case "init": {
        if (isServer) then {
            _logic setVariable ["super", SUPERCLASS];
            _logic setVariable ["class", MAINCLASS];
            _logic setVariable ["moduleType", "ALIVE_CPC"];
            _logic setVariable ["startupComplete", false];

            TRACE_1("After module init", _logic);

            if !( ["ALiVE_sys_profile"] call ALiVE_fnc_isModuleAvailable ) exitWith {
                ["Profile System module not placed! Exiting..."] call ALiVE_fnc_DumpR;
                _logic setVariable ["startupComplete", true];
            };

            waitUntil {!(isNil "ALiVE_ProfileHandler") && {[ALiVE_ProfileSystem, "startupComplete", false] call ALIVE_fnc_hashGet}};
            [_logic, "start"] call MAINCLASS;
        };
    };
    case "start": {
        if (isServer) then {
            private _debug = [_logic, "debug"] call MAINCLASS;
            private _withPlacement = [_logic, "withPlacement"] call MAINCLASS;
            private _objectiveSize = parseNumber ([_logic, "objectiveSize"] call MAINCLASS);
            private _priority = parseNumber ([_logic, "priority"] call MAINCLASS);
            private _placeSeaPatrols = [_logic, "placeSeaPatrols"] call MAINCLASS;
            private _position = position _logic;
            private _objectiveName = format["CUSTOM_CIV_%1", floor((_position select 0) + (_position select 1))];

            if (_debug) then {
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                ["CPC - Startup"] call ALiVE_fnc_dump;
                [true] call ALIVE_fnc_timer;
            };

            if (isNil "ALIVE_clustersCivCustom") then {
                ALIVE_clustersCivCustom = [] call ALIVE_fnc_hashCreate;
            };

            if (isNil "ALIVE_groupConfig") then {
                [] call ALIVE_fnc_groupGenerateConfigData;
            };

            waitUntil {!isNil "ALiVE_GROUP_CONFIG_DATA_GENERATED"};

            private _cluster = [nil, "create"] call ALIVE_fnc_cluster;
            [_cluster, "nodes", (nearestObjects [_position, ["static"], _objectiveSize])] call ALIVE_fnc_hashSet;
            [_cluster, "clusterID", _objectiveName] call ALIVE_fnc_hashSet;
            [_cluster, "center", _position] call ALIVE_fnc_hashSet;
            [_cluster, "size", _objectiveSize] call ALIVE_fnc_hashSet;
            [_cluster, "type", "CIV"] call ALIVE_fnc_hashSet;
            [_cluster, "priority", _priority] call ALIVE_fnc_hashSet;
            [_cluster, "debug", _debug] call ALIVE_fnc_cluster;

            [_logic, "objectives", [_cluster]] call MAINCLASS;
            [_logic, "objectivesMarine", if (_placeSeaPatrols > 0) then {[_cluster]} else {[]}] call MAINCLASS;
            [ALIVE_clustersCivCustom, _objectiveName, _cluster] call ALIVE_fnc_hashSet;

            if (_debug) then {
                ["CPC created custom civilian objective %1", _objectiveName] call ALiVE_fnc_dump;
            };

            if (_withPlacement) then {
                if (isNil QGVAR(ROADBLOCK_LOCATIONS)) then {
                    GVAR(ROADBLOCK_LOCATIONS) = [];
                };

                private _roadBlocks = parseNumber([_logic, "roadBlocks"] call MAINCLASS);

                if !(ALIVE_loadProfilesPersistent) then {
                    [_logic, "placement"] call MAINCLASS;
                } else {
                    if (_roadBlocks > 0) then {
                        private _restoredRoadblocks = 0;
                        private _savedRoadblockLocations = if (isNil "ALIVE_CIV_PLACEMENT_ROADBLOCK_LOCATIONS") then {[]} else {+ALIVE_CIV_PLACEMENT_ROADBLOCK_LOCATIONS};

                        {
                            private _center = [_x, "center"] call ALIVE_fnc_hashGet;
                            private _clusterSize = [_x, "size"] call ALIVE_fnc_hashGet;
                            private _roadblockLocation = [_center, _clusterSize];

                            if ((_savedRoadblockLocations findIf {_x isEqualTo _roadblockLocation}) >= 0 && {(GVAR(ROADBLOCK_LOCATIONS) findIf {_x isEqualTo _roadblockLocation}) < 0}) then {
                                GVAR(ROADBLOCK_LOCATIONS) pushBack _roadblockLocation;
                                _restoredRoadblocks = _restoredRoadblocks + 1;
                            };
                        } forEach ([_logic, "objectives"] call MAINCLASS);

                        if (_debug) then {
                            ["CPC - Restored %1 deferred roadblock locations for persistent load", _restoredRoadblocks] call ALiVE_fnc_dump;
                        };
                    };

                    if (_debug) then { ["CPC - Profiles are persistent, no creation of profiles"] call ALiVE_fnc_dump; };
                    _logic setVariable ["startupComplete", true];
                };

                if (_roadBlocks > 0) then {
                    [_logic] spawn {
                        params ["_logic"];

                        private _roadBlocks = parseNumber([_logic, "roadBlocks"] call MAINCLASS);
                        private _debug = [_logic, "debug"] call MAINCLASS;
                        private _maxRoadblockSpawnAttempts = 10;
                        private _lastRoadblockDebug = -30;

                        while {count GVAR(ROADBLOCK_LOCATIONS) > 0} do {
                            private _timer = time;
                            private _spawnChecks = 0;

                            {
                                if (_x isEqualType []) then {
                                    private _position = _x select 0;
                                    private _size = _x select 1;
                                    private _spawn = false;

                                    if ([_position, ALIVE_spawnRadius, ALIVE_spawnRadiusJet, ALIVE_spawnRadiusHeli] call ALiVE_fnc_anyPlayersInRangeIncludeAir) then {
                                        _spawn = true;
                                    } else {
                                        if ([_position, ALIVE_spawnRadiusJet] call ALiVE_fnc_anyAutonomousInRange > 0) then {
                                            _spawn = true;
                                        };
                                    };

                                    if (_spawn) then {
                                        _spawnChecks = _spawnChecks + 1;

                                        private _roadblockResult = [_position, _size + 150, ceil(_roadBlocks / 30), _debug] call ALiVE_fnc_createRoadblock;
                                        private _roadblockLocation = [_position, _size];

                                        if (count _roadblockResult > 0) then {
                                            GVAR(ROADBLOCK_LOCATIONS) set [_forEachIndex, -1];
                                            if !(isNil "ALIVE_CIV_PLACEMENT_ROADBLOCK_LOCATIONS") then {
                                                ALIVE_CIV_PLACEMENT_ROADBLOCK_LOCATIONS = ALIVE_CIV_PLACEMENT_ROADBLOCK_LOCATIONS select {!(_x isEqualTo _roadblockLocation)};
                                            };
                                        } else {
                                            private _attempts = if (count _x > 2) then {_x select 2} else {0};
                                            _attempts = _attempts + 1;

                                            if (_attempts >= _maxRoadblockSpawnAttempts) then {
                                                GVAR(ROADBLOCK_LOCATIONS) set [_forEachIndex, -1];
                                                if !(isNil "ALIVE_CIV_PLACEMENT_ROADBLOCK_LOCATIONS") then {
                                                    ALIVE_CIV_PLACEMENT_ROADBLOCK_LOCATIONS = ALIVE_CIV_PLACEMENT_ROADBLOCK_LOCATIONS select {!(_x isEqualTo _roadblockLocation)};
                                                };

                                                if (_debug) then {
                                                    ["Roadblock at %1 failed to spawn after %2 attempts; removing from queue", _position, _attempts] call ALiVE_fnc_dump;
                                                };
                                            } else {
                                                GVAR(ROADBLOCK_LOCATIONS) set [_forEachIndex, [_position, _size, _attempts]];
                                            };
                                        };
                                    };
                                };
                            } forEach GVAR(ROADBLOCK_LOCATIONS);

                            GVAR(ROADBLOCK_LOCATIONS) = GVAR(ROADBLOCK_LOCATIONS) - [-1];

                            if (_debug && {(_spawnChecks > 0) || {time - _lastRoadblockDebug > 30}}) then {
                                ["Roadblock iteration time: %1 secs for %2 entries...", time - _timer, count GVAR(ROADBLOCK_LOCATIONS)] call ALiVE_fnc_dump;
                                _lastRoadblockDebug = time;
                            };

                            sleep 1;
                        };
                    };
                };
            } else {
                if (_debug) then { ["CPC - Objectives Only"] call ALiVE_fnc_dump; };
                _logic setVariable ["startupComplete", true];
            };
        };
    };
    case "placement": {
        if (isServer) then {
            private _debug = [_logic, "debug"] call MAINCLASS;

            if (_debug) then {
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                ["CPC - Placement"] call ALiVE_fnc_dump;
                [true] call ALIVE_fnc_timer;
            };

            private _onEachSpawn = [_logic, "onEachSpawn"] call MAINCLASS;
            private _onEachSpawnOnce = [_logic, "onEachSpawnOnce"] call MAINCLASS;

            private _clusters = [_logic, "objectives"] call MAINCLASS;
            private _guardProbability = parseNumber ([_logic, "guardProbability"] call MAINCLASS);

            private _customInfantryCount = [_logic, "customInfantryCount"] call MAINCLASS;
            if (_customInfantryCount == "") then {_customInfantryCount = 666} else {_customInfantryCount = parseNumber _customInfantryCount;};

            private _customMotorisedCount = [_logic, "customMotorisedCount"] call MAINCLASS;
            if (_customMotorisedCount == "") then {_customMotorisedCount = 666} else {_customMotorisedCount = parseNumber _customMotorisedCount;};

            private _customMechanisedCount = [_logic, "customMechanisedCount"] call MAINCLASS;
            if (_customMechanisedCount == "") then {_customMechanisedCount = 666} else {_customMechanisedCount = parseNumber _customMechanisedCount;};

            private _customArmourCount = [_logic, "customArmourCount"] call MAINCLASS;
            if (_customArmourCount == "") then {_customArmourCount = 666} else {_customArmourCount = parseNumber _customArmourCount;};

            private _customSpecOpsCount = [_logic, "customSpecOpsCount"] call MAINCLASS;
            if (_customSpecOpsCount == "") then {_customSpecOpsCount = 666} else {_customSpecOpsCount = parseNumber _customSpecOpsCount;};

            private _type = [_logic, "type"] call MAINCLASS;
            private _faction = [_logic, "faction"] call MAINCLASS;
            private _size = parseNumber ([_logic, "size"] call MAINCLASS);
            private _roadBlocks = parseNumber ([_logic, "roadBlocks"] call MAINCLASS);

            private _factionConfig = _faction call ALiVE_fnc_configGetFactionClass;
            private _factionSideNumber = getNumber(_factionConfig >> "side");
            private _side = _factionSideNumber call ALIVE_fnc_sideNumberToText;
            private _countProfiles = 0;

            if (_debug) then {
                ["CPC [%1] - Force Size: %2 Type: %3 SideNum: %4 Side: %5 Faction: %6", _faction, _size, _type, _factionSideNumber, _side, _faction] call ALiVE_fnc_dump;
            };

            call ALiVE_fnc_staticDataHandler;

            private _countArmored = 0;
            private _countMechanized = 0;
            private _countMotorized = 0;
            private _countInfantry = 0;
            private _countAir = 0;
            private _countSpecOps = 0;

            switch (_type) do {
                case "Armored": {
                    _countArmored = floor((_size / 20) * 0.5);
                    _countMechanized = floor((_size / 12) * random 0.2);
                    _countMotorized = floor((_size / 12) * random 0.2);
                    _countInfantry = floor((_size / 10) * 0.5);
                    _countAir = floor((_size / 30) * random 0.1);
                    _countSpecOps = floor((_size / 25) * 0.5);
                };
                case "Mechanized": {
                    _countMechanized = floor((_size / 12) * 0.5);
                    _countArmored = floor((_size / 20) * random 0.2);
                    _countMotorized = floor((_size / 12) * random 0.2);
                    _countInfantry = floor((_size / 10) * 0.5);
                    _countAir = floor((_size / 30) * random 0.1);
                    _countSpecOps = floor((_size / 25) * 0.5);
                };
                case "Motorized": {
                    _countMotorized = floor((_size / 12) * 0.5);
                    _countMechanized = floor((_size / 12) * random 0.2);
                    _countArmored = floor((_size / 20) * random 0.2);
                    _countInfantry = floor((_size / 10) * 0.5);
                    _countAir = floor((_size / 30) * random 0.1);
                    _countSpecOps = floor((_size / 25) * 0.5);
                };
                case "Infantry": {
                    _countInfantry = floor((_size / 10) * 0.8);
                    _countMotorized = floor((_size / 12) * random 0.2);
                    _countMechanized = floor((_size / 12) * random 0.2);
                    _countArmored = floor((_size / 20) * random 0.2);
                    _countAir = floor((_size / 30) * random 0.1);
                    _countSpecOps = floor((_size / 25) * 0.5);
                };
                case "Air": {
                    _countAir = floor((_size / 30) * 0.5);
                    _countInfantry = floor((_size / 10) * 0.5);
                    _countMotorized = floor((_size / 12) * random 0.2);
                    _countMechanized = floor((_size / 12) * random 0.2);
                    _countArmored = floor((_size / 20) * random 0.2);
                    _countSpecOps = floor((_size / 25) * 0.5);
                };
                case "Specops": {
                    _countAir = floor((_size / 30) * 0.5);
                    _countInfantry = floor((_size / 10) * 0.5);
                    _countMotorized = floor((_size / 12) * random 0.2);
                    _countMechanized = floor((_size / 12) * random 0.2);
                    _countArmored = floor((_size / 20) * random 0.2);
                    _countSpecOps = floor((_size / 10) * 0.5);
                };
            };

            if !(_customInfantryCount == 666) then {_countInfantry = _customInfantryCount;};
            if !(_customMotorisedCount == 666) then {_countMotorized = _customMotorisedCount;};
            if !(_customMechanisedCount == 666) then {_countMechanized = _customMechanisedCount;};
            if !(_customArmourCount == 666) then {_countArmored = _customArmourCount;};
            if !(_customSpecOpsCount == 666) then {_countSpecOps = _customSpecOpsCount;};

            private _guardProbabilityCount = [_countInfantry, [_logic, "guardProbability"] call MAINCLASS] call ALIVE_fnc_infantryGuardProbabilityCount;
            if (_guardProbabilityCount > 0) then {
                _countInfantry = _countInfantry - _guardProbabilityCount;
            };

            if (_debug) then {
                ["CPC [%1] - Main force creation", _faction] call ALiVE_fnc_dump;
                ["Count Armor: %1", _countArmored] call ALIVE_fnc_dump;
                ["Count Mech: %1", _countMechanized] call ALIVE_fnc_dump;
                ["Count Motor: %1", _countMotorized] call ALIVE_fnc_dump;
                ["Count Air: %1", _countAir] call ALIVE_fnc_dump;
                ["Count Infantry: %1", _countInfantry] call ALIVE_fnc_dump;
                ["Count Garrison Infantry: %1", _guardProbabilityCount] call ALIVE_fnc_dump;
                ["Count Spec Ops: %1", _countSpecOps] call ALIVE_fnc_dump;
            };

            private _groups = [];
            for "_i" from 0 to _countArmored - 1 do {
                private _group = ["Armored", _faction] call ALIVE_fnc_configGetRandomGroup;
                if !(_group == "FALSE") then {_groups pushBack _group;};
            };
            for "_i" from 0 to _countMechanized - 1 do {
                private _group = ["Mechanized", _faction] call ALIVE_fnc_configGetRandomGroup;
                if !(_group == "FALSE") then {_groups pushBack _group;};
            };

            if (_countMotorized > 0) then {
                private _motorizedGroups = [];
                for "_i" from 0 to _countMotorized - 1 do {
                    private _group = ["Motorized", _faction] call ALIVE_fnc_configGetRandomGroup;
                    if !(_group == "FALSE") then {_motorizedGroups pushBack _group;};
                };
                if (count _motorizedGroups == 0) then {
                    for "_i" from 0 to _countMotorized - 1 do {
                        private _group = ["Motorized_MTP", _faction] call ALIVE_fnc_configGetRandomGroup;
                        if !(_group == "FALSE") then {_motorizedGroups pushBack _group;};
                    };
                };
                _groups append _motorizedGroups;
            };

            private _infantryGroups = [];
            for "_i" from 0 to _countInfantry - 1 do {
                private _group = ["Infantry", _faction] call ALIVE_fnc_configGetRandomGroup;
                if !(_group == "FALSE") then {_infantryGroups pushBack _group;};
            };
            _groups append _infantryGroups;

            for "_i" from 0 to _countAir - 1 do {
                private _group = ["Air", _faction] call ALIVE_fnc_configGetRandomGroup;
                if !(_group == "FALSE") then {_groups pushBack _group;};
            };
            for "_i" from 0 to _countSpecOps - 1 do {
                private _group = ["SpecOps", _faction] call ALIVE_fnc_configGetRandomGroup;
                if !(_group == "FALSE") then {_groups pushBack _group;};
            };

            _groups = _groups - ALiVE_PLACEMENT_GROUPBLACKLIST;
            _infantryGroups = _infantryGroups - ALiVE_PLACEMENT_GROUPBLACKLIST;

            if (_debug) then {
                ["CPC [%1] - Groups %2", _faction, _groups] call ALiVE_fnc_dump;
            };

            private _groupCount = count _groups;
            private _clusterCount = count _clusters;
            private _groupPerCluster = if (_clusterCount > 0) then {floor(_groupCount / _clusterCount)} else {0};
            private _totalCount = 0;
            private _readiness = parseNumber ([_logic, "readinessLevel"] call MAINCLASS);
            _readiness = (1 - _readiness) * _groupCount;

            if (isNil QGVAR(ROADBLOCK_LOCATIONS)) then {
                GVAR(ROADBLOCK_LOCATIONS) = [];
            };

            private _countSeaPatrols = 0;
            private _placeSeaPatrols = [_logic, "placeSeaPatrols"] call MAINCLASS;
            if (_placeSeaPatrols > 0) then {
                private _marineClusters = [_logic, "objectivesMarine"] call MAINCLASS;
                {
                    private _seaPatrolGroup = ["Naval", _faction] call ALIVE_fnc_configGetRandomGroup;
                    if !(_seaPatrolGroup == "FALSE") then {
                        private _center = [_x, "center"] call ALIVE_fnc_hashGet;
                        private _pos = [_center, true] call ALiVE_fnc_getClosestSea;
                        if (surfaceIsWater _pos) then {
                            if ((random 1) < _placeSeaPatrols) then {
                                private _seaPatrol = [_seaPatrolGroup, _pos, random 360, true, _faction, true, false, "STEALTH", _onEachSpawn, _onEachSpawnOnce] call ALIVE_fnc_createProfilesFromGroupConfig;
                                {
                                    if (([_x, "type"] call ALiVE_fnc_HashGet) == "entity") then {
                                        [_x, "setActiveCommand", ["ALIVE_fnc_SeaPatrol", "spawn", [1000, "AWARE", _center]]] call ALIVE_fnc_profileEntity;
                                        _countSeaPatrols = _countSeaPatrols + 1;
                                    };
                                } forEach _seaPatrol;
                            };
                        };
                    };
                } forEach _marineClusters;

                if (_debug) then {
                    ["CPC [%1] - Created %2 Sea Patrols", _faction, _countSeaPatrols] call ALiVE_fnc_dump;
                };
            };

            {
                private _center = [_x, "center"] call ALIVE_fnc_hashGet;
                private _clusterSize = [_x, "size"] call ALIVE_fnc_hashGet;
                private _guardRadius = parseNumber ([_logic, "guardRadius"] call MAINCLASS);
                private _guardPatrolPercentage = parseNumber ([_logic, "guardPatrolPercentage"] call MAINCLASS);
                private _guardDistance = _clusterSize;

                if (count _infantryGroups > 0 && {_guardProbabilityCount > 0}) then {
                    for "_i" from 0 to _guardProbabilityCount - 1 do {
                        private _guardGroup = selectRandom _infantryGroups;
                        private _guards = [_guardGroup, [_center, _guardDistance] call CBA_fnc_RandPos, random 360, true, _faction, false, false, "STEALTH", _onEachSpawn, _onEachSpawnOnce] call ALIVE_fnc_createProfilesFromGroupConfig;
                        {
                            if (([_x, "type"] call ALiVE_fnc_HashGet) == "entity") then {
                                [_x, "setActiveCommand", ["ALIVE_fnc_garrison", "spawn", [_guardRadius, "true", [0,0,0], "", _guardProbabilityCount, _guardPatrolPercentage]]] call ALIVE_fnc_profileEntity;
                            };
                        } forEach _guards;
                        _countProfiles = _countProfiles + count _guards;
                    };
                };

                if (_totalCount < _groupCount) then {
                    if (_groupPerCluster > 0) then {
                        for "_i" from 0 to _groupPerCluster - 1 do {
                            private _group = _groups select _totalCount;
                            private _command = "";
                            private _radius = [];
                            private _position = [];
                            private _garrisonPos = nil;

                            if (_totalCount < _readiness) then {
                                _command = "ALIVE_fnc_garrison";
                                _garrisonPos = [_center, 50] call CBA_fnc_RandPos;
                                _radius = [_guardRadius, "true", [0,0,0], "", _guardProbabilityCount, _guardPatrolPercentage];
                            } else {
                                _command = "ALIVE_fnc_ambientMovement";
                                _radius = [_guardRadius, "SAFE", [0,0,0]];
                            };

                            if (isNil "_garrisonPos") then {
                                _position = _center getPos [((_clusterSize / 2) + (random 500)), random 360];
                            } else {
                                _position = [_garrisonPos, 50] call CBA_fnc_RandPos;
                            };

                            if !(surfaceIsWater _position) then {
                                private _profiles = [_group, _position, random 360, true, _faction, false, false, "STEALTH", _onEachSpawn, _onEachSpawnOnce] call ALIVE_fnc_createProfilesFromGroupConfig;
                                {
                                    if (([_x, "type"] call ALiVE_fnc_HashGet) == "entity") then {
                                        [_x, "setActiveCommand", [_command, "spawn", _radius]] call ALIVE_fnc_profileEntity;
                                    };
                                } forEach _profiles;
                                _countProfiles = _countProfiles + count _profiles;
                                _totalCount = _totalCount + 1;
                            };
                        };
                    } else {
                        private _group = _groups select _totalCount;
                        private _command = "";
                        private _radius = [];
                        private _position = [];
                        private _garrisonPos = nil;

                        if (_totalCount < _readiness) then {
                            _command = "ALIVE_fnc_garrison";
                            _garrisonPos = [_center, 50] call CBA_fnc_RandPos;
                            _radius = [_guardRadius, "true", [0,0,0], "", _guardProbabilityCount, _guardPatrolPercentage];
                        } else {
                            _command = "ALIVE_fnc_ambientMovement";
                            _radius = [_guardRadius, "SAFE", [0,0,0]];
                        };

                        if (isNil "_garrisonPos") then {
                            _position = _center getPos [(_clusterSize + (random 500)), random 360];
                        } else {
                            _position = [_garrisonPos, 50] call CBA_fnc_RandPos;
                        };

                        if !(surfaceIsWater _position) then {
                            private _profiles = [_group, _position, random 360, true, _faction, false, false, "STEALTH", _onEachSpawn, _onEachSpawnOnce] call ALIVE_fnc_createProfilesFromGroupConfig;
                            {
                                if (([_x, "type"] call ALiVE_fnc_HashGet) == "entity") then {
                                    [_x, "setActiveCommand", [_command, "spawn", _radius]] call ALIVE_fnc_profileEntity;
                                };
                            } forEach _profiles;
                            _countProfiles = _countProfiles + count _profiles;
                            _totalCount = _totalCount + 1;
                        };
                    };
                };

                if (!isNil "ALIVE_fnc_createRoadblock" && isNil QGVAR(COMPOSITIONS_LOADED) && {random 100 < _roadBlocks}) then {
                    private _roadblockLocation = [_center, _clusterSize];
                    GVAR(ROADBLOCK_LOCATIONS) pushBack _roadblockLocation;

                    if (isNil "ALIVE_CIV_PLACEMENT_ROADBLOCK_LOCATIONS") then {
                        ALIVE_CIV_PLACEMENT_ROADBLOCK_LOCATIONS = [];
                    };

                    if ((ALIVE_CIV_PLACEMENT_ROADBLOCK_LOCATIONS findIf {_x isEqualTo _roadblockLocation}) < 0) then {
                        ALIVE_CIV_PLACEMENT_ROADBLOCK_LOCATIONS pushBack _roadblockLocation;
                    };
                };
            } forEach _clusters;

            if (_debug) then {
                ["CPC %2 - Total profiles created: %1", _countProfiles, _faction] call ALiVE_fnc_dump;
                ["CPC - Placement completed"] call ALiVE_fnc_dump;
                [] call ALIVE_fnc_timer;
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            };

            _logic setVariable ["startupComplete", true];
        };
    };
};

TRACE_1("CPC - output", _result);
_result;
