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
// Reserve-pool defaults - mirror mil_placement (canonical source).
#define DEFAULT_ACTIVE_PATROL_PERCENT "0.75"
#define DEFAULT_RESERVE_ACTIVATION_THRESHOLD "0.5"
#define DEFAULT_RESERVE_ACTIVATION_COOLDOWN "30"
#define DEFAULT_RESERVE_ENGAGEMENT_MULTIPLIER "3"
#define DEFAULT_RESERVE_LOCK_CLEARED_BUILDINGS "1"
#define DEFAULT_RESERVE_EMPTY_VEHICLE_LOCKED "1"
#define DEFAULT_RESERVE_ORPHAN_CREW_BEHAVIOUR "SpawnAsInfantry"

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
        private _simpleOperations = ["targets", "objectiveSize", "size", "type", "faction", "factions", "priority", "asymmetricInstallationCountOverrides"];

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
    case "factions": {
        _result = [_logic, _operation, _args, "[]"] call ALIVE_fnc_OOsimpleOperation;
    };
    // #875 - objective scenery objects: AA-style triplet.
    case "objectiveObjects": {
        _result = [_logic, _operation, _args, ""] call ALIVE_fnc_OOsimpleOperation;
    };
    case "objectiveObjectsCount": {
        _result = [_logic, _operation, _args, "0"] call ALIVE_fnc_OOsimpleOperation;
    };
    case "objectiveObjectsBehaviour": {
        _result = [_logic, _operation, _args, "dispersed"] call ALIVE_fnc_OOsimpleOperation;
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
    case "garrisonPatrolBehaviour": {
        _result = [_logic, _operation, _args, "SAFE"] call ALIVE_fnc_OOsimpleOperation;
    };
    case "garrisonPatrolSpeed": {
        _result = [_logic, _operation, _args, "LIMITED"] call ALIVE_fnc_OOsimpleOperation;
    };
    case "readinessLevel": {
        _result = [_logic, _operation, _args, DEFAULT_READINESS_LEVEL] call ALIVE_fnc_OOsimpleOperation;
    };
    case "activePatrolPercent": {
        _result = [_logic, _operation, _args, DEFAULT_ACTIVE_PATROL_PERCENT] call ALIVE_fnc_OOsimpleOperation;
    };
    case "reserveActivationThreshold": {
        _result = [_logic, _operation, _args, DEFAULT_RESERVE_ACTIVATION_THRESHOLD] call ALIVE_fnc_OOsimpleOperation;
    };
    case "reserveActivationCooldown": {
        _result = [_logic, _operation, _args, DEFAULT_RESERVE_ACTIVATION_COOLDOWN] call ALIVE_fnc_OOsimpleOperation;
    };
    case "reserveEngagementMultiplier": {
        _result = [_logic, _operation, _args, DEFAULT_RESERVE_ENGAGEMENT_MULTIPLIER] call ALIVE_fnc_OOsimpleOperation;
    };
    case "reserveLockClearedBuildings": {
        _result = [_logic, _operation, _args, DEFAULT_RESERVE_LOCK_CLEARED_BUILDINGS] call ALIVE_fnc_OOsimpleOperation;
    };
    case "reserveEmptyVehicleLocked": {
        _result = [_logic, _operation, _args, DEFAULT_RESERVE_EMPTY_VEHICLE_LOCKED] call ALIVE_fnc_OOsimpleOperation;
    };
    case "reserveOrphanCrewBehaviour": {
        _result = [_logic, _operation, _args, DEFAULT_RESERVE_ORPHAN_CREW_BEHAVIOUR] call ALIVE_fnc_OOsimpleOperation;
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
    case "roadblockCompositions": {
        _result = [_logic, _operation, _args, ""] call ALIVE_fnc_OOsimpleOperation;
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
            // ColorRed marks user-placed custom civilian objectives
            // distinct from the auto-gen civ palette (HQ=Black,
            // Power=Yellow, Comms=White, Marine=Blue, Rail=Khaki,
            // Fuel=Orange, Construction=Pink, Settlement=Green). The
            // shared cluster-marker renderer in fnc_strategic/fnc_cluster.sqf
            // reads this colour, maps it to the "Custom" sub-type label
            // and prepends it so the map shows "Custom: <id>|CIV|<pri>|<size>".
            [_cluster, "debugColor", "ColorRed"] call ALIVE_fnc_hashSet;
            [_cluster, "debug", _debug] call ALIVE_fnc_cluster;

            [_logic, "objectives", [_cluster]] call MAINCLASS;
            [_logic, "objectivesMarine", if (_placeSeaPatrols > 0) then {[_cluster]} else {[]}] call MAINCLASS;
            [ALIVE_clustersCivCustom, _objectiveName, _cluster] call ALIVE_fnc_hashSet;

            if (_debug) then {
                ["CPC created custom civilian objective %1", _objectiveName] call ALiVE_fnc_dump;
                // Outline circle showing the configured Objective Size
                // radius. Mirrors the mil_ied debug-marker pattern -
                // Ellipse shape with Border brush so the area is
                // visible without obscuring map detail. ColorRed
                // matches the cluster's debugColor for visual
                // continuity with the cluster's anchor marker.
                private _circleName = format ["alive_cpc_objsize_%1", _objectiveName];
                [_circleName, _position, "Ellipse", [_objectiveSize, _objectiveSize], "TEXT:", format ["Objective Size (%1m)", _objectiveSize], "COLOR:", "ColorRed", "BRUSH:", "Border", "GLOBAL"] call CBA_fnc_createMarker;
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
                        // Picker pool threaded into each createRoadblock call -
                        // see civ_placement/fnc_CP.sqf for the pattern.
                        private _roadblockComps = [_logic, "roadblockCompositions"] call MAINCLASS;
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

                                        private _roadblockResult = [_position, _size + 150, ceil(_roadBlocks / 30), _debug, _roadblockComps] call ALiVE_fnc_createRoadblock;
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

            private _fnc_parseFactions = {
                params ["_value"];
                private _parsed = [];
                if (_value isEqualType []) then {
                    {
                        if (_x isEqualType "" && {_x != ""} && {_x != "NONE"} && {!(_x in _parsed)}) then {
                            _parsed pushBack _x;
                        };
                    } forEach _value;
                    _parsed
                } else {
                    if !(_value isEqualType "") exitWith { [] };
                    if (_value == "") exitWith { [] };
                    private _s = _value;
                    _s = [_s, " ", ""] call CBA_fnc_replace;
                    _s = [_s, "[", ""] call CBA_fnc_replace;
                    _s = [_s, "]", ""] call CBA_fnc_replace;
                    _s = [_s, """", ""] call CBA_fnc_replace;
                    {
                        if (_x != "" && {_x != "NONE"} && {!(_x in _parsed)}) then {
                            _parsed pushBack _x;
                        };
                    } forEach ([_s, ","] call CBA_fnc_split);
                    _parsed
                };
            };

            private _fnc_getOpcomFactions = {
                params ["_opcom"];
                private _opcomFactions = [_opcom getVariable ["factions", ""]] call _fnc_parseFactions;
                {
                    if !(_x in _opcomFactions) then { _opcomFactions pushBack _x };
                } forEach ([_opcom getVariable ["factionsManual", ""]] call _fnc_parseFactions);

                if (count _opcomFactions == 0) then {
                    {
                        private _legacyFaction = _opcom getVariable [_x, ""];
                        if (_legacyFaction != "" && {_legacyFaction != "NONE"} && {!(_legacyFaction in _opcomFactions)}) then {
                            _opcomFactions pushBack _legacyFaction;
                        };
                    } forEach ["faction1", "faction2", "faction3", "faction4"];
                };
                if (count _opcomFactions == 0) then { _opcomFactions pushBack DEFAULT_FACTION };

                _opcomFactions
            };

            private _type = [_logic, "type"] call MAINCLASS;
            private _factions = [_logic getVariable ["factions", ""]] call _fnc_parseFactions;
            // Read the raw hidden legacy value. MAINCLASS applies DEFAULT_FACTION
            // and would make a new empty multi-select look like saved BLU_F.
            private _legacyFactions = [_logic getVariable ["faction", ""]] call _fnc_parseFactions;

            if (count _factions == 0) then {
                _factions = +_legacyFactions;
            };

            if (count _factions == 0) then {
                {
                    if ((typeOf _x) isEqualTo "ALiVE_mil_OPCOM") then {
                        {
                            if !(_x in _factions) then { _factions pushBack _x };
                        } forEach ([_x] call _fnc_getOpcomFactions);
                    };
                } forEach (synchronizedObjects _logic);
            };

            if (count _factions == 0) then { _factions = [DEFAULT_FACTION] };

            private _faction = _factions select 0;
            private _size = parseNumber ([_logic, "size"] call MAINCLASS);
            private _roadBlocks = parseNumber ([_logic, "roadBlocks"] call MAINCLASS);

            private _factionConfig = _faction call ALiVE_fnc_configGetFactionClass;
            private _factionSideNumber = getNumber(_factionConfig >> "side");
            private _side = _factionSideNumber call ALIVE_fnc_sideNumberToText;
            private _countProfiles = 0;

            if (_debug) then {
                ["CPC [%1] - Force Size: %2 Type: %3 SideNum: %4 Side: %5 Factions: %6", _faction, _size, _type, _factionSideNumber, _side, _factions] call ALiVE_fnc_dump;
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

            private _fnc_pickGroupForCategory = {
                params ["_category", "_slotIndex"];
                private _entry = ["FALSE", ""];
                private _factionCount = count _factions;
                if (_factionCount == 0) exitWith { _entry };
                private _start = _slotIndex mod _factionCount;
                for "_attempt" from 0 to (_factionCount - 1) do {
                    private _candidateFaction = _factions select ((_start + _attempt) mod _factionCount);
                    private _candidateGroup = [_category, _candidateFaction] call ALIVE_fnc_configGetRandomGroup;
                    if !(_candidateGroup == "FALSE") exitWith {
                        _entry = [_candidateGroup, _candidateFaction];
                    };
                };
                _entry
            };

            private _groups = [];
            for "_i" from 0 to _countArmored - 1 do {
                private _entry = ["Armored", _i] call _fnc_pickGroupForCategory;
                if !((_entry select 0) == "FALSE") then {_groups pushBack _entry;};
            };
            for "_i" from 0 to _countMechanized - 1 do {
                private _entry = ["Mechanized", _i] call _fnc_pickGroupForCategory;
                if !((_entry select 0) == "FALSE") then {_groups pushBack _entry;};
            };

            if (_countMotorized > 0) then {
                private _motorizedGroups = [];
                for "_i" from 0 to _countMotorized - 1 do {
                    private _entry = ["Motorized", _i] call _fnc_pickGroupForCategory;
                    if ((_entry select 0) == "FALSE") then {
                        _entry = ["Motorized_MTP", _i] call _fnc_pickGroupForCategory;
                    };
                    if !((_entry select 0) == "FALSE") then {_motorizedGroups pushBack _entry;};
                };
                _groups append _motorizedGroups;
            };

            // Track infantry boundary for the reserve-pool dispatcher.
            private _infantryGroupStart = count _groups;

            private _infantryGroups = [];
            for "_i" from 0 to _countInfantry - 1 do {
                private _entry = ["Infantry", _i] call _fnc_pickGroupForCategory;
                if !((_entry select 0) == "FALSE") then {_infantryGroups pushBack _entry;};
            };
            _groups append _infantryGroups;
            private _infantryGroupEnd = count _groups;

            for "_i" from 0 to _countAir - 1 do {
                private _entry = ["Air", _i] call _fnc_pickGroupForCategory;
                if !((_entry select 0) == "FALSE") then {_groups pushBack _entry;};
            };
            for "_i" from 0 to _countSpecOps - 1 do {
                private _entry = ["SpecOps", _i] call _fnc_pickGroupForCategory;
                if !((_entry select 0) == "FALSE") then {_groups pushBack _entry;};
            };

            _groups = _groups select {!((_x select 0) in ALiVE_PLACEMENT_GROUPBLACKLIST)};
            _infantryGroups = _infantryGroups select {!((_x select 0) in ALiVE_PLACEMENT_GROUPBLACKLIST)};
            // Recompute boundary post-blacklist.
            if (count _infantryGroups > 0) then {
                _infantryGroupStart = _groups find (_infantryGroups select 0);
                if (_infantryGroupStart < 0) then { _infantryGroupStart = 0 };
                _infantryGroupEnd = _infantryGroupStart + (count _infantryGroups);
            } else {
                _infantryGroupStart = 0;
                _infantryGroupEnd = 0;
            };

            if (_debug) then {
                ["CPC [%1] - Groups %2", _faction, _groups] call ALiVE_fnc_dump;
            };

            private _groupCount = count _groups;
            private _clusterCount = count _clusters;
            private _groupPerCluster = if (_clusterCount > 0) then {floor(_groupCount / _clusterCount)} else {0};
            private _totalCount = 0;

            // Reserve-pool placement model. Mirrors mil_placement.
            private _readiness = parseNumber ([_logic, "readinessLevel"] call MAINCLASS);
            private _activePatrolPercent = parseNumber ([_logic, "activePatrolPercent"] call MAINCLASS);
            private _vehicleEmptyLocked = (parseNumber ([_logic, "reserveEmptyVehicleLocked"] call MAINCLASS)) > 0;

            private _vehicleGroupCount = _infantryGroupStart;
            private _vehicleActiveCount = round (_vehicleGroupCount * _readiness);
            private _infantryGroupCount = _infantryGroupEnd - _infantryGroupStart;
            private _infantryActiveCount = round (_infantryGroupCount * _readiness);
            private _garrisonCount = round (_infantryActiveCount * (1 - _activePatrolPercent));
            private _activePlacedCount = 0;
            private _infantryActivePlacedCount = 0;
            private _vehicleActivePlacedCount = 0;

            // Helpers (extract vehicle class + cluster-aware parking lookup).
            private _fnc_getGroupVehicleClass = {
                params ["_groupClass", "_groupFaction"];
                private _config = [_groupFaction, _groupClass] call ALIVE_fnc_configGetGroup;
                if (count _config == 0) exitWith { "" };
                private _result = "";
                for "_i" from 0 to (count _config - 1) do {
                    if (_result != "") exitWith {};
                    private _entry = _config select _i;
                    if (isClass _entry) then {
                        private _veh = getText (_entry >> "vehicle");
                        if (_veh isKindOf "LandVehicle") then { _result = _veh };
                    };
                };
                _result
            };
            private _fnc_findVehicleParkingPos = {
                params ["_vehicleClass", "_clusterCenter", "_clusterSize"];
                if (_vehicleClass == "") exitWith {
                    [_clusterCenter getPos [(random (_clusterSize / 2)) + 30, random 360], random 360]
                };
                private _fnc_isFlatEnough = {
                    params ["_pos"];
                    private _flat = _pos isFlatEmpty [-1, -1, 0.4, 5, 0, false, objNull];
                    count _flat >= 2
                };
                private _searchRadius = (_clusterSize + 100) max 200;
                private _seedPos = _clusterCenter getPos [(random (_clusterSize / 2)) + 30, random 360];
                private _seedDir = random 360;
                private _result = [_vehicleClass, _seedPos, _searchRadius, "road", _seedDir] call ALiVE_fnc_findVehicleSpawnPosition;
                if (count _result >= 2 && {[_result select 0] call _fnc_isFlatEnough}) exitWith { _result };
                _result = [_vehicleClass, _seedPos, _searchRadius, "auto", _seedDir] call ALiVE_fnc_findVehicleSpawnPosition;
                if (count _result >= 2 && {[_result select 0] call _fnc_isFlatEnough}) exitWith { _result };
                if ([_seedPos] call _fnc_isFlatEnough) exitWith { [_seedPos, _seedDir] };
                _result = [_vehicleClass, _clusterCenter, _clusterSize * 3, "auto", _seedDir] call ALiVE_fnc_findVehicleSpawnPosition;
                if (count _result >= 2 && {[_result select 0] call _fnc_isFlatEnough}) exitWith { _result };
                [_clusterCenter getPos [50, random 360], _seedDir]
            };

            if (isNil QGVAR(ROADBLOCK_LOCATIONS)) then {
                GVAR(ROADBLOCK_LOCATIONS) = [];
            };

            private _countSeaPatrols = 0;
            private _placeSeaPatrols = [_logic, "placeSeaPatrols"] call MAINCLASS;
            if (_placeSeaPatrols > 0) then {
                private _marineClusters = [_logic, "objectivesMarine"] call MAINCLASS;
                {
                    private _seaEntry = ["Naval", _forEachIndex] call _fnc_pickGroupForCategory;
                    _seaEntry params ["_seaPatrolGroup", "_seaPatrolFaction"];
                    if !(_seaPatrolGroup == "FALSE") then {
                        private _center = [_x, "center"] call ALIVE_fnc_hashGet;
                        private _pos = [_center, true] call ALiVE_fnc_getClosestSea;
                        if (surfaceIsWater _pos) then {
                            if ((random 1) < _placeSeaPatrols) then {
                                private _seaPatrol = [_seaPatrolGroup, _pos, random 360, true, _seaPatrolFaction, true, false, "STEALTH", _onEachSpawn, _onEachSpawnOnce] call ALIVE_fnc_createProfilesFromGroupConfig;
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
                    ["CPC [%1] - Created %2 Sea Patrols", _factions, _countSeaPatrols] call ALiVE_fnc_dump;
                };
            };

            {
                private _center = [_x, "center"] call ALIVE_fnc_hashGet;
                private _clusterSize = [_x, "size"] call ALIVE_fnc_hashGet;
                private _guardRadius = parseNumber ([_logic, "guardRadius"] call MAINCLASS);
                private _guardPatrolPercentage = parseNumber ([_logic, "guardPatrolPercentage"] call MAINCLASS);
                private _garrisonPatrolBehaviour = toUpper ([_logic, "garrisonPatrolBehaviour"] call MAINCLASS);
                private _garrisonPatrolSpeed = toUpper ([_logic, "garrisonPatrolSpeed"] call MAINCLASS);
                private _guardDistance = _clusterSize;
                private _cluster = _x;

                // Per-cluster reserve metadata. Mirrors mil_placement.
                [_x, "reservePool", []] call ALiVE_fnc_hashSet;
                [_x, "reserveActiveAtSpawn", 0] call ALiVE_fnc_hashSet;
                [_x, "activeProfileIDs", []] call ALiVE_fnc_hashSet;
                [_x, "lastReserveWake", -999] call ALiVE_fnc_hashSet;
                [_x, "reserveModule", _logic] call ALiVE_fnc_hashSet;
                [_x, "reserveModuleClass", MAINCLASS] call ALiVE_fnc_hashSet;

                if (count _infantryGroups > 0 && {_guardProbabilityCount > 0}) then {
                    for "_i" from 0 to _guardProbabilityCount - 1 do {
                        private _guardEntry = selectRandom _infantryGroups;
                        _guardEntry params ["_guardGroup", "_guardFaction"];
                        // Water-aware random pick - up to 10 retries before
                        // falling back to _center.
                        private _guardPos = _center;
                        for "_try" from 1 to 10 do {
                            private _candidate = [_center, _guardDistance] call CBA_fnc_RandPos;
                            if (!surfaceIsWater _candidate) exitWith { _guardPos = _candidate };
                        };
                        private _guards = [_guardGroup, _guardPos, random 360, true, _guardFaction, false, false, "STEALTH", _onEachSpawn, _onEachSpawnOnce] call ALIVE_fnc_createProfilesFromGroupConfig;
                        {
                            if (([_x, "type"] call ALiVE_fnc_HashGet) == "entity") then {
                                [_x, "setActiveCommand", ["ALIVE_fnc_garrison", "spawn", [_guardRadius, "true", [0,0,0], "", _guardProbabilityCount, _guardPatrolPercentage, _garrisonPatrolBehaviour, _garrisonPatrolSpeed]]] call ALIVE_fnc_profileEntity;
                            };
                        } forEach _guards;
                        _countProfiles = _countProfiles + count _guards;
                    };
                };

                private _fnc_placeGroupCPC = {
                    params ["_groupEntry", "_isVehicle", "_isInfantry"];
                    _groupEntry params ["_group", "_groupFaction"];
                    private _command = "";
                    private _radius = [];
                    private _position = [];
                    private _garrisonPos = nil;

                    private _vehicleReserveClass = "";
                    if (_isVehicle && {_vehicleActivePlacedCount >= _vehicleActiveCount}) then {
                        _vehicleReserveClass = [_group, _groupFaction] call _fnc_getGroupVehicleClass;
                    };
                    private _isVehicleReserve = _vehicleReserveClass != "";
                    private _isInfantryReserve = _isInfantry && {_infantryActivePlacedCount >= _infantryActiveCount};
                    private _isReserve = _isVehicleReserve || _isInfantryReserve;

                    if (_isReserve) then {
                        private _reservePool = [_cluster, "reservePool"] call ALiVE_fnc_hashGet;
                        if (_isVehicleReserve) then {
                            private _t0 = diag_tickTime;
                            private _parking = [_vehicleReserveClass, _center, _clusterSize] call _fnc_findVehicleParkingPos;
                            private _vehiclePos = _parking select 0;
                            private _vehicleDir = _parking select 1;
                            if (surfaceIsWater _vehiclePos) then {
                                _vehiclePos = _center getPos [50, random 360];
                            };
                            if ((!isNil "ALiVE_civ_placement_custom_debug" && {ALiVE_civ_placement_custom_debug})
                                && {!isNil "ALiVE_vehicleSpawn_debug" && {ALiVE_vehicleSpawn_debug}}) then {
                                ["[ALiVE Reserve DEBUG] CPC-VEHICLE-RESERVE faction=%1 totalCount=%2 group=%3 class=%4 pos=%5 elapsed=%6ms", _groupFaction, _totalCount, _group, _vehicleReserveClass, _vehiclePos, round ((diag_tickTime - _t0) * 1000)] call ALiVE_fnc_dump;
                            };

                            private _groupFactionConfig = _groupFaction call ALiVE_fnc_configGetFactionClass;
                            private _groupFactionSideNumber = getNumber(_groupFactionConfig >> "side");
                            private _groupSide = _groupFactionSideNumber call ALIVE_fnc_sideNumberToText;
                            private _emptyProfiles = [_vehicleReserveClass, _groupSide, _groupFaction, _vehiclePos, _vehicleDir, false, _groupFaction] call ALIVE_fnc_createProfilesUnCrewedVehicle;
                            private _profileEntity = _emptyProfiles select 0;
                            private _profileVehicle = _emptyProfiles select 1;
                            [_profileEntity, "objectType", _group] call ALIVE_fnc_profileEntity;
                            [_profileEntity, "aiBehaviour", "STEALTH"] call ALIVE_fnc_profileEntity;
                            [_profileEntity, "onEachSpawn", _onEachSpawn] call ALIVE_fnc_profileEntity;
                            [_profileEntity, "onEachSpawnOnce", _onEachSpawnOnce] call ALIVE_fnc_profileEntity;
                            [_profileEntity, "busy", true] call ALIVE_fnc_profileEntity;
                            [_profileVehicle, "busy", true] call ALIVE_fnc_profileVehicle;
                            [_profileEntity, "homeCluster", _cluster] call ALiVE_fnc_HashSet;
                            [_profileVehicle, "ALiVE_reserveLocked", _vehicleEmptyLocked] call ALiVE_fnc_HashSet;
                            private _vehicleProfileID = [_profileVehicle, "profileID"] call ALiVE_fnc_hashGet;
                            private _entityProfileID = [_profileEntity, "profileID"] call ALiVE_fnc_hashGet;
                            _reservePool pushBack ["VEHICLE", _group, _vehicleProfileID, _entityProfileID, _groupFaction, _onEachSpawn, _onEachSpawnOnce];
                            _countProfiles = _countProfiles + 2;
                        } else {
                            _reservePool pushBack ["INFANTRY", _group, _groupFaction, _onEachSpawn, _onEachSpawnOnce];
                        };
                        [_cluster, "reservePool", _reservePool] call ALiVE_fnc_hashSet;
                        _totalCount = _totalCount + 1;
                    } else {
                        private _activeDir = random 360;
                        private _activeT0 = diag_tickTime;
                        private _activeVehClass = "";
                        if (_isVehicle) then {
                            _command = "ALIVE_fnc_ambientMovement";
                            _radius = [_guardRadius, "SAFE", [0,0,0]];
                            _activeVehClass = [_group, _groupFaction] call _fnc_getGroupVehicleClass;
                            if (_activeVehClass != "") then {
                                private _parking = [_activeVehClass, _center, _clusterSize] call _fnc_findVehicleParkingPos;
                                _position = _parking select 0;
                                _activeDir = _parking select 1;
                            };
                        } else {
                            if (_isInfantry && {_infantryActivePlacedCount < _garrisonCount}) then {
                                _command = "ALIVE_fnc_garrison";
                                _garrisonPos = [_center, 50] call CBA_fnc_RandPos;
                                _radius = [_guardRadius, "true", [0,0,0], "", _guardProbabilityCount, _guardPatrolPercentage, _garrisonPatrolBehaviour, _garrisonPatrolSpeed];
                            } else {
                                _command = "ALIVE_fnc_ambientMovement";
                                _radius = [_guardRadius, "SAFE", [0,0,0]];
                            };
                        };

                        if (count _position == 0) then {
                            if (isNil "_garrisonPos") then {
                                _position = _center getPos [((_clusterSize / 2) + (random 500)), random 360];
                            } else {
                                _position = [_garrisonPos, 50] call CBA_fnc_RandPos;
                            };
                        };

                        if !(surfaceIsWater _position) then {
                            private _profiles = [_group, _position, _activeDir, true, _groupFaction, false, false, "STEALTH", _onEachSpawn, _onEachSpawnOnce] call ALIVE_fnc_createProfilesFromGroupConfig;

                            if (_isVehicle
                                && {!isNil "ALiVE_civ_placement_custom_debug" && {ALiVE_civ_placement_custom_debug}}
                                && {!isNil "ALiVE_vehicleSpawn_debug" && {ALiVE_vehicleSpawn_debug}}) then {
                                ["[ALiVE Reserve DEBUG] CPC-VEHICLE-ACTIVE faction=%1 totalCount=%2 group=%3 class=%4 pos=%5 elapsed=%6ms", _groupFaction, _totalCount, _group, _activeVehClass, _position, round ((diag_tickTime - _activeT0) * 1000)] call ALiVE_fnc_dump;
                            };

                            {
                                if (([_x, "type"] call ALiVE_fnc_HashGet) == "entity") then {
                                    [_x, "setActiveCommand", [_command, "spawn", _radius]] call ALIVE_fnc_profileEntity;
                                    [_x, "homeCluster", _cluster] call ALiVE_fnc_HashSet;
                                    private _profileID = [_x, "profileID"] call ALiVE_fnc_HashGet;
                                    private _activeIDs = [_cluster, "activeProfileIDs"] call ALiVE_fnc_HashGet;
                                    _activeIDs pushBack _profileID;
                                    [_cluster, "activeProfileIDs", _activeIDs] call ALiVE_fnc_HashSet;
                                };
                                if (([_x, "type"] call ALiVE_fnc_HashGet) == "vehicle") then {
                                    [_x, "ALiVE_reserveLocked", _vehicleEmptyLocked] call ALiVE_fnc_HashSet;
                                };
                            } forEach _profiles;

                            _countProfiles = _countProfiles + count _profiles;
                            _totalCount = _totalCount + 1;
                            _activePlacedCount = _activePlacedCount + 1;
                            if (_isInfantry) then { _infantryActivePlacedCount = _infantryActivePlacedCount + 1 };
                            if (_isVehicle) then { _vehicleActivePlacedCount = _vehicleActivePlacedCount + 1 };

                            private _spawned = [_cluster, "reserveActiveAtSpawn"] call ALiVE_fnc_hashGet;
                            [_cluster, "reserveActiveAtSpawn", _spawned + 1] call ALiVE_fnc_hashSet;
                        };
                    };
                };

                if (_totalCount < _groupCount) then {
                    if (_groupPerCluster > 0) then {
                        for "_i" from 0 to _groupPerCluster - 1 do {
                            private _group = _groups select _totalCount;
                            private _isVehicle = (_totalCount < _infantryGroupStart);
                            private _isInfantry = (_totalCount >= _infantryGroupStart) && (_totalCount < _infantryGroupEnd);
                            [_group, _isVehicle, _isInfantry] call _fnc_placeGroupCPC;
                        };
                    } else {
                        private _group = _groups select _totalCount;
                        private _isVehicle = (_totalCount < _infantryGroupStart);
                        private _isInfantry = (_totalCount >= _infantryGroupStart) && (_totalCount < _infantryGroupEnd);
                        [_group, _isVehicle, _isInfantry] call _fnc_placeGroupCPC;
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

                    // Debug-mode preview marker - see comment in
                    // civ_placement/fnc_CP.sqf where the same pattern lands.
                    // Cluster-centre brown mil_box at queue time; the actual
                    // spawned roadblock gets its own brown mil_dot at the
                    // snapped road position via fnc_createRoadblock.
                    if (_debug) then {
                        // Deterministic marker name - see CP's matching call.
                        private _qName = format ["ALiVE_RB_Q_%1_%2", floor (_center select 0), floor (_center select 1)];
                        [_center, 2, format ["RoadBlock Q (%1m)", _clusterSize], "ColorBrown", "placement.cp.roadblock_q", _qName] call ALIVE_fnc_placeDebugMarker;
                    };
                };
            } forEach _clusters;

            // Activation watcher PFH (5 s tick).
            private _totalReserves = 0;
            { _totalReserves = _totalReserves + count ([_x, "reservePool", []] call ALiVE_fnc_hashGet) } forEach _clusters;
            if (_totalReserves > 0) then {
                [{
                    params ["_args", "_handle"];
                    _args params ["_watchClusters", "_watchLogic"];
                    if (isNull _watchLogic) exitWith {
                        [_handle] call CBA_fnc_removePerFrameHandler;
                    };
                    {
                        [_x, _watchLogic] call ALIVE_fnc_activateReserve;
                    } forEach _watchClusters;
                }, 5, [_clusters, _logic]] call CBA_fnc_addPerFrameHandler;
            };

            if (_debug) then {
                ["CPC %2 - Total profiles created: %1", _countProfiles, _factions] call ALiVE_fnc_dump;
                ["CPC - Placement completed"] call ALiVE_fnc_dump;
                [] call ALIVE_fnc_timer;
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            };

            // #875 - objective scenery objects (AA-style triplet).
            private _objSizeRadius_CPC = if (!isNil "_objectiveSize" && {_objectiveSize > 0}) then { _objectiveSize } else { 150 };
            private _objCountStr_CPC = [_logic, "objectiveObjectsCount"] call MAINCLASS;
            private _objCount_CPC = if (typeName _objCountStr_CPC == "STRING" && {_objCountStr_CPC != ""}) then { parseNumber _objCountStr_CPC } else { 0 };
            private _objBehaviour_CPC = [_logic, "objectiveObjectsBehaviour"] call MAINCLASS;
            private _countObjectiveObjects_CPC = [_logic, _position, _objSizeRadius_CPC, _objCount_CPC, _objBehaviour_CPC, _debug] call ALiVE_fnc_spawnObjectiveObjects;
            if (_debug) then {
                ["CPC - Objective objects placed: %1 of %2 (radius=%3 behaviour=%4)",
                    _countObjectiveObjects_CPC, _objCount_CPC, _objSizeRadius_CPC, _objBehaviour_CPC] call ALiVE_fnc_dump;
            };

            _logic setVariable ["startupComplete", true];
        };
    };
};

TRACE_1("CPC - output", _result);
_result;
