//#define DEBUG_MPDE_FULL
#include "\x\alive\addons\mil_placement\script_component.hpp"
SCRIPT(MP);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_MP
Description:
Military objectives

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Nil - init - Intiate instance
Nil - destroy - Destroy instance
Boolean - debug - Debug enabled
Array - state - Save and restore module state
Array - faction - Faction associated with module

Examples:
[_logic, "faction", "BLU_F"] call ALiVE_fnc_MP;

See Also:
- <ALIVE_fnc_MPInit>

Author:
Wolffy
ARJay
Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_MP
#define MTEMPLATE "ALiVE_MP_%1"
#define DEFAULT_SIZE "100"
#define DEFAULT_TYPE QUOTE(RANDOM)
#define DEFAULT_FACTION QUOTE(BLU_F)
#define DEFAULT_TAOR []
#define DEFAULT_BLACKLIST []
#define DEFAULT_WITH_PLACEMENT true
#define DEFAULT_OBJECTIVES []
#define DEFAULT_OBJECTIVES_HQ []
#define DEFAULT_OBJECTIVES_LAND []
#define DEFAULT_OBJECTIVES_AIR []
#define DEFAULT_OBJECTIVES_HELI []
#define DEFAULT_OBJECTIVES_VEHICLE []
#define DEFAULT_SIZE_FILTER "0"
#define DEFAULT_PRIORITY_FILTER "0"
#define DEFAULT_AMBIENT_VEHICLE_AMOUNT "0.2"
#define DEFAULT_AMBIENT_GUARD_AMOUNT "0.2"
#define DEFAULT_AMBIENT_GUARD_RADIUS "200"
#define DEFAULT_AMBIENT_GUARD_PATROL_PERCENT "50"
#define DEFAULT_HQ_BUILDING objNull
#define DEFAULT_HQ_CLUSTER []
#define DEFAULT_NO_TEXT ""
#define DEFAULT_READINESS_LEVEL "1"
#define DEFAULT_ACTIVE_PATROL_PERCENT "0.75"
#define DEFAULT_RESERVE_ACTIVATION_THRESHOLD "0.5"
#define DEFAULT_RESERVE_ACTIVATION_COOLDOWN "30"
#define DEFAULT_RESERVE_ENGAGEMENT_MULTIPLIER "3"
#define DEFAULT_RESERVE_LOCK_CLEARED_BUILDINGS "1"
#define DEFAULT_RESERVE_EMPTY_VEHICLE_LOCKED "1"
#define DEFAULT_RESERVE_ORPHAN_CREW_BEHAVIOUR "SpawnAsInfantry"
#define DEFAULT_RANDOMCAMPS "0"

private ["_logic","_operation","_args","_result"];

TRACE_1("MP - input",_this);

_logic = _this param [0, objNull, [objNull]];
_operation = _this param [1, "", [""]];
_args = _this param [2, objNull, [objNull,[],"",0,true,false]];
_result = true;

switch(_operation) do {
    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
    case "destroy": {
        [_logic, "debug", false] call MAINCLASS;
        if (isServer) then {
            // if server
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
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["debug", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "state": {
        private["_state","_data","_nodes","_simple_operations"];
        _simple_operations = ["targets", "size","type","faction"];

        if(typeName _args != "ARRAY") then {
            _state = [] call CBA_fnc_hashCreate;
            // Save state
            {
                [_state, _x, _logic getVariable _x] call ALIVE_fnc_hashSet;
            } forEach _simple_operations;

            if ([_logic, "debug"] call MAINCLASS) then {
                diag_log PFORMAT_2(QUOTE(MAINCLASS), _operation,_state);
            };
            _result = _state;
        } else {
            ASSERT_TRUE([_args] call ALIVE_fnc_isHash,str _args);

            // Restore state
            {
                [_logic, _x, [_args, _x] call ALIVE_fnc_hashGet] call MAINCLASS;
            } forEach _simple_operations;
        };
    };
    // Determine size of enemy force - valid values are: BN, CY and PL
    case "size": {
        _result = [_logic,_operation,_args,DEFAULT_SIZE] call ALIVE_fnc_OOsimpleOperation;
    };
    // Determine type of enemy force - valid values are: "Random","Armored","Mechanized","Motorized","Infantry","Air
    case "type": {
        _result = [_logic,_operation,_args,DEFAULT_TYPE,["Random","Armored","Mechanized","Motorized","Infantry"]] call ALIVE_fnc_OOsimpleOperation;
        if(_result == "Random") then {
            // Randomly pick an type
            _result = (selectRandom ["Armored","Mechanized","Motorized","Infantry"]);
            _logic setVariable ["type", _result];
        };
    };
    case "customInfantryCount": {
        _result = [_logic,_operation,_args,DEFAULT_NO_TEXT] call ALIVE_fnc_OOsimpleOperation;
    };
    case "customMotorisedCount": {
        _result = [_logic,_operation,_args,DEFAULT_NO_TEXT] call ALIVE_fnc_OOsimpleOperation;
    };
    case "customMechanisedCount": {
        _result = [_logic,_operation,_args,DEFAULT_NO_TEXT] call ALIVE_fnc_OOsimpleOperation;
    };
    case "customArmourCount": {
        _result = [_logic,_operation,_args,DEFAULT_NO_TEXT] call ALIVE_fnc_OOsimpleOperation;
    };
    case "customSpecOpsCount": {
        _result = [_logic,_operation,_args,DEFAULT_NO_TEXT] call ALIVE_fnc_OOsimpleOperation;
    };
    // Determine force faction
    case "faction": {
        _result = [_logic,_operation,_args,DEFAULT_FACTION,[] call ALiVE_fnc_configGetFactions] call ALIVE_fnc_OOsimpleOperation;

        if !(_args isEqualType "") then {
            private _compiledFaction = [_logic] call ALiVE_fnc_factionCompilerResolveForModule;
            if !(_compiledFaction isEqualTo "") then {
                _result = _compiledFaction;
            };
        };
    };
    // Return the Ambient Vehicle Amount
    case "ambientVehicleAmount": {
        _result = [_logic,_operation,_args,DEFAULT_AMBIENT_VEHICLE_AMOUNT] call ALIVE_fnc_OOsimpleOperation;
    };
    case "guardProbability": {
        _result = [_logic,_operation,_args,DEFAULT_AMBIENT_GUARD_AMOUNT] call ALIVE_fnc_OOsimpleOperation;
    };
    case "guardRadius": {
        _result = [_logic,_operation,_args,DEFAULT_AMBIENT_GUARD_RADIUS] call ALIVE_fnc_OOsimpleOperation;
    };
    case "guardPatrolPercentage": {
        _result = [_logic,_operation,_args,DEFAULT_AMBIENT_GUARD_PATROL_PERCENT] call ALIVE_fnc_OOsimpleOperation;
    };
    case "onEachSpawn": {
        _result = [_logic, _operation, _args, ""] call ALIVE_fnc_OOsimpleOperation;
    };
    case "onEachSpawnOnce": {
        _result = [_logic, _operation, _args, true] call ALIVE_fnc_OOsimpleOperation;
    };

    

    case "createHQ": {
            if (typeName _args == "BOOL") then {
                _logic setVariable ["createHQ", _args];
            } else {
                _args = _logic getVariable ["createHQ", false];
            };
            if (typeName _args == "STRING") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["createHQ", _args];
            };
            ASSERT_TRUE(typeName _args == "BOOL",str _args);

            _result = _args;
    };
    case "createFieldHQ": {
            if (typeName _args == "BOOL") then {
                _logic setVariable ["createFieldHQ", _args];
            } else {
                _args = _logic getVariable ["createFieldHQ", false];
            };
            if (typeName _args == "STRING") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["createFieldHQ", _args];
            };
            ASSERT_TRUE(typeName _args == "BOOL",str _args);

            _result = _args;
    };
    case "placeHelis": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["placeHelis", _args];
        } else {
            _args = _logic getVariable ["placeHelis", false];
        };
        if (typeName _args == "STRING") then {
            if(_args == "true") then {_args = true;} else {_args = false;};
            _logic setVariable ["placeHelis", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "placeSupplies": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["placeSupplies", _args];
        } else {
            _args = _logic getVariable ["placeSupplies", false];
        };
        if (typeName _args == "STRING") then {
            if(_args == "true") then {_args = true;} else {_args = false;};
            _logic setVariable ["placeSupplies", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    // Return TAOR marker
    case "taor": {
        if(typeName _args == "STRING") then {
            _args = [_args, " ", ""] call CBA_fnc_replace;
            _args = [_args, ","] call CBA_fnc_split;
            if(count _args > 0) then {
                _logic setVariable [_operation, _args];
            };
        };
        if(typeName _args == "ARRAY") then {
            _logic setVariable [_operation, _args];
        };
        _result = _logic getVariable [_operation, DEFAULT_TAOR];
    };
    // Return the Blacklist marker
    case "blacklist": {
        if(typeName _args == "STRING") then {
            _args = [_args, " ", ""] call CBA_fnc_replace;
            _args = [_args, ","] call CBA_fnc_split;
            if(count _args > 0) then {
                _logic setVariable [_operation, _args];
            };
        };
        if(typeName _args == "ARRAY") then {
            _logic setVariable [_operation, _args];
        };
        _result = _logic getVariable [_operation, DEFAULT_BLACKLIST];
    };
    // Return the Size filter
    case "sizeFilter": {
        _result = [_logic,_operation,_args,DEFAULT_SIZE_FILTER] call ALIVE_fnc_OOsimpleOperation;
    };
    // Return the Priority filter
    case "priorityFilter": {
        _result = [_logic,_operation,_args,DEFAULT_PRIORITY_FILTER] call ALIVE_fnc_OOsimpleOperation;
    };
    // Return the Readiness Level
    case "readinessLevel": {
        _result = [_logic,_operation,_args,DEFAULT_READINESS_LEVEL] call ALIVE_fnc_OOsimpleOperation;
    };
    // Return the Active Patrol Percent (fraction of active units that patrol vs garrison)
    case "activePatrolPercent": {
        _result = [_logic,_operation,_args,DEFAULT_ACTIVE_PATROL_PERCENT] call ALIVE_fnc_OOsimpleOperation;
    };
    // Return the Reserve Activation Threshold (active-force fraction at which reserves wake)
    case "reserveActivationThreshold": {
        _result = [_logic,_operation,_args,DEFAULT_RESERVE_ACTIVATION_THRESHOLD] call ALIVE_fnc_OOsimpleOperation;
    };
    // Return the Reserve Activation Cooldown (seconds between reserve wake-ups)
    case "reserveActivationCooldown": {
        _result = [_logic,_operation,_args,DEFAULT_RESERVE_ACTIVATION_COOLDOWN] call ALIVE_fnc_OOsimpleOperation;
    };
    // Return the Reserve Engagement Multiplier (cluster_size * multiplier
    // = engagement radius for player-presence gate)
    case "reserveEngagementMultiplier": {
        _result = [_logic,_operation,_args,DEFAULT_RESERVE_ENGAGEMENT_MULTIPLIER] call ALIVE_fnc_OOsimpleOperation;
    };
    // Return whether buildings within the proximity gate are permanently
    // disqualified once the spawn picker has touched them ("1"/"0")
    case "reserveLockClearedBuildings": {
        _result = [_logic,_operation,_args,DEFAULT_RESERVE_LOCK_CLEARED_BUILDINGS] call ALIVE_fnc_OOsimpleOperation;
    };
    // Return whether empty reserve vehicles are locked until activation ("1"/"0")
    case "reserveEmptyVehicleLocked": {
        _result = [_logic,_operation,_args,DEFAULT_RESERVE_EMPTY_VEHICLE_LOCKED] call ALIVE_fnc_OOsimpleOperation;
    };
    // Return how to handle reserve crews whose linked vehicle was destroyed
    // ("SpawnAsInfantry" / "Drop")
    case "reserveOrphanCrewBehaviour": {
        _result = [_logic,_operation,_args,DEFAULT_RESERVE_ORPHAN_CREW_BEHAVIOUR] call ALIVE_fnc_OOsimpleOperation;
    };
    // Return the random camps
    case "randomCamps": {
        _result = [_logic,_operation,_args,DEFAULT_RANDOMCAMPS] call ALIVE_fnc_OOsimpleOperation;
    };

    // Return placement setting
    case "withPlacement": {
        if (isnil "_args" || {isnull _args}) then {
            _args = _logic getvariable ["withPlacement",DEFAULT_WITH_PLACEMENT];
        };

        if (isnil "_args") exitwith {_result = DEFAULT_WITH_PLACEMENT};

        if (_args isEqualType "") then {_args = (_args == "true")};
        if (_args isEqualTo true) then {_args = _args};

        _result = [_logic,_operation,_args,DEFAULT_WITH_PLACEMENT] call ALIVE_fnc_OOsimpleOperation;
    };

    // Return the objectives as an array of clusters
    case "objectives": {
        _result = [_logic,_operation,_args,DEFAULT_OBJECTIVES] call ALIVE_fnc_OOsimpleOperation;
    };
    // Return the land objectives as an array of clusters
    case "objectivesLand": {
        _result = [_logic,_operation,_args,DEFAULT_OBJECTIVES] call ALIVE_fnc_OOsimpleOperation;
    };
    // Return the HQ objectives as an array of clusters
    case "objectivesHQ": {
        _result = [_logic,_operation,_args,DEFAULT_OBJECTIVES_HQ] call ALIVE_fnc_OOsimpleOperation;
    };
    // Return the AIR objectives as an array of clusters
    case "objectivesAir": {
        _result = [_logic,_operation,_args,DEFAULT_OBJECTIVES_AIR] call ALIVE_fnc_OOsimpleOperation;
    };
    // Return the Heli objectives as an array of clusters
    case "objectivesHeli": {
        _result = [_logic,_operation,_args,DEFAULT_OBJECTIVES_HELI] call ALIVE_fnc_OOsimpleOperation;
    };
    // Return the Vehicle objectives as an array of clusters
    case "objectivesVehicle": {
        _result = [_logic,_operation,_args,DEFAULT_OBJECTIVES_VEHICLE] call ALIVE_fnc_OOsimpleOperation;
    };
    // Return the HQ Building
    case "HQBuilding": {
        _result = [_logic,_operation,_args,DEFAULT_HQ_BUILDING] call ALIVE_fnc_OOsimpleOperation;
    };
    // Return the Field HQ Building
    case "FieldHQBuilding": {
        _result = [_logic,_operation,_args,DEFAULT_HQ_BUILDING] call ALIVE_fnc_OOsimpleOperation;
    };
    // Return the HQ Cluster
    case "HQCluster": {
        _result = [_logic,_operation,_args,DEFAULT_HQ_CLUSTER] call ALIVE_fnc_OOsimpleOperation;
    };
    // Main process
    case "init": {
        if (isServer) then {
            // if server, initialise module game logic
            _logic setVariable ["super", SUPERCLASS];
            _logic setVariable ["class", MAINCLASS];
            _logic setVariable ["moduleType", "ALIVE_MP"];
            _logic setVariable ["startupComplete", false];
            TRACE_1("After module init",_logic);

            [_logic, "taor", _logic getVariable ["taor", DEFAULT_TAOR]] call MAINCLASS;
            [_logic, "blacklist", _logic getVariable ["blacklist", DEFAULT_TAOR]] call MAINCLASS;

            if !(["ALiVE_sys_profile"] call ALiVE_fnc_isModuleAvailable) exitwith {
                ["Profile System module not placed! Exiting..."] call ALiVE_fnc_DumpR;
                _logic setVariable ["startupComplete", true];
            };

            waituntil {!(isnil "ALiVE_ProfileHandler") && {[ALiVE_ProfileSystem,"startupComplete",false] call ALIVE_fnc_hashGet}};

            [_logic,"start"] call MAINCLASS;

        } else {
            [_logic, "taor", _logic getVariable ["taor", DEFAULT_TAOR]] call MAINCLASS;
            [_logic, "blacklist", _logic getVariable ["blacklist", DEFAULT_TAOR]] call MAINCLASS;
            {_x setMarkerAlpha 0} foreach (_logic getVariable ["taor", DEFAULT_TAOR]);
            {_x setMarkerAlpha 0} foreach (_logic getVariable ["blacklist", DEFAULT_TAOR]);
        };
    };
    case "start": {
        if (isServer) then {

            private ["_debug","_placement","_worldName","_file","_clusters","_cluster","_taor","_taorClusters","_blacklist",
            "_sizeFilter","_priorityFilter","_blacklistClusters","_center","_error","_faction"];

            _debug = [_logic, "debug"] call MAINCLASS;
            _faction = [_logic, "faction"] call MAINCLASS;
            private _onEachSpawn = [_logic, "onEachSpawn"] call MAINCLASS;
            private _onEachSpawnOnce = [_logic, "onEachSpawnOnce"] call MAINCLASS;

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                ["MP - Startup"] call ALiVE_fnc_dump;
                [true] call ALIVE_fnc_timer;
            };
            // DEBUG -------------------------------------------------------------------------------------

            if(isNil "ALIVE_clustersMil" && isNil "ALIVE_loadedMilClusters") then {
                _worldName = toLower(worldName);
                _file = format["x\alive\addons\mil_placement\clusters\clusters.%1_mil.sqf", _worldName];
                call compile preprocessFileLineNumbers _file;
                ALIVE_loadedMilClusters = true;
            };
            waituntil {!(isnil "ALIVE_loadedMilClusters") && {ALIVE_loadedMilClusters}};
            waituntil {!(isnil "ALIVE_profileSystemInit")};

            // all MP modules execute at the same time
            // ALIVE_groupConfig is created, but not 100% filled
            // before the rest of the modules start creating their profiles

            // instantiate static vehicle position data
            if(isNil "ALIVE_groupConfig") then {
                [] call ALIVE_fnc_groupGenerateConfigData;
            };

            waitUntil {!isnil "ALiVE_GROUP_CONFIG_DATA_GENERATED"};

            //Only spawn warning on version mismatch since map index changes were reduced
            //uncomment //_error = true; below for exit
            _error = false;
            if !(isNil "ALIVE_clusterBuild") then {
                private ["_clusterVersion","_clusterBuild","_clusterType","_version","_build","_message"];

                _clusterVersion = ALIVE_clusterBuild select 2;
                _clusterBuild = ALIVE_clusterBuild select 3;
                _clusterType = ALIVE_clusterBuild select 4;
                _version = productVersion select 2;
                _build = productVersion select 3;

                if!(_clusterType == 'Stable') then {
                    _message = "Warning ALiVE requires the STABLE game build";
                    [_message] call ALIVE_fnc_dump;
                    //_error = true;
                };

                if(!(_clusterVersion == _version) || !(_clusterBuild == _build)) then {
                    _message = format["Warning: This version of ALiVE is build for A3 version: %1.%2. The server is running version: %3.%4. Please contact your server administrator and update to the latest ALiVE release version.",_clusterVersion, _clusterBuild, _version, _build];
                    [_message] call ALIVE_fnc_dump;
                    //_error = true;
                };

                /*
                if (!(isnil "_message") && {isnil QGVAR(CLUSTERWARNING_DISPLAYED)}) then {
                    GVAR(CLUSTERWARNING_DISPLAYED) = true;
                    [[_message],"BIS_fnc_guiMessage",nil,true] spawn BIS_fnc_MP;
                };
                */
            };

            if!(_error) then {
                _placement = [_logic, "withPlacement"] call MAINCLASS;
                _taor = [_logic, "taor"] call MAINCLASS;
                _blacklist = [_logic, "blacklist"] call MAINCLASS;
                _sizeFilter = parseNumber([_logic, "sizeFilter"] call MAINCLASS);
                _priorityFilter = parseNumber([_logic, "priorityFilter"] call MAINCLASS);
                _randomCampsMil = parseNumber([_logic, "randomCamps"] call MAINCLASS);

                // check markers for existance
                private ["_marker","_counter"];

                if(count _taor > 0) then {
                    _counter = 0;
                    {
                        _marker =_x;
                        if!(_marker call ALIVE_fnc_markerExists) then {
                            _taor = _taor - [_taor select _counter];
                        }else{
                            _counter = _counter + 1;
                        };
                    } forEach _taor;
                };

                if(count _blacklist > 0) then {
                    _counter = 0;
                    {
                        _marker =_x;
                        if!(_marker call ALIVE_fnc_markerExists) then {
                            _blacklist = _blacklist - [_blacklist select _counter];
                        }else{
                            _counter = _counter + 1;
                        };
                    } forEach _blacklist;
                };

                private ["_HQClusters","_landClusters","_airClusters","_heliClusters","_vehicleClusters"];

                _clusters = ALIVE_clustersMil select 2;

                _HQClusters = DEFAULT_OBJECTIVES_HQ;
                _airClusters = DEFAULT_OBJECTIVES_AIR;
                _heliClusters = DEFAULT_OBJECTIVES_HELI;
                _landClusters = DEFAULT_OBJECTIVES_LAND;

                if (_randomCampsMil > 0) then {
                     if (isnil "ALIVE_clustersMilLand") then {
                        ALIVE_clustersMilLand = "loading";

                        _data = [] call ALiVE_fnc_HashCreate;
                        _clustersX = +_clusters;

                        _sectors = [ALIVE_sectorGrid, "sectors"] call ALIVE_fnc_sectorGrid;
                        {
                            private ["_sector","_sectorData","_flatEmpty","_id","_cluster"];

                            _sector = _x;
                            _sectorData = [_sector, "data",["",[],[],nil]] call ALIVE_fnc_hashGet;

                            _flatEmpty = [_sectorData,"flatEmpty",[]] call ALIVE_fnc_hashGet;

                            if (count _flatEmpty > 0) then {
                                private ["_pos"];

                                _pos = _flatEmpty select 0;

                                if ({([_x,"center",[0,0,0]] call ALiVE_fnc_HashGet) distance _pos < _randomCampsMil} count _clustersX > 0) exitwith {};

                                 _pos = [_pos,500] call ALiVE_fnc_findFlatArea;
                                 _id = format["c_%1",str(floor(_pos select 0)) + str(floor(_pos select 0))];

                                _cluster = [nil, "create"] call ALIVE_fnc_cluster;
                                [_cluster,"nodes",nearestObjects [_pos,["static"],50]] call ALIVE_fnc_hashSet;
                                [_cluster,"clusterID",_id] call ALIVE_fnc_hashSet;
                                [_cluster,"center",_pos] call ALIVE_fnc_hashSet;
                                [_cluster,"size",100] call ALIVE_fnc_hashSet;
                                [_cluster,"type","MIL"] call ALIVE_fnc_hashSet;
                                [_cluster,"priority",100] call ALIVE_fnc_hashSet;

                                [_data,_id,_cluster] call ALiVE_fnc_HashSet;
                                _clustersX pushback _cluster;

                                //_cluster call ALiVE_fnc_InspectHash;
                            };

                            ALIVE_clustersMilLand = _data;

                        } foreach _sectors;
                    } else {
                        waituntil {typeName ALIVE_clustersMilLand == "ARRAY"};
                    };

                    _landClusters = ALIVE_clustersMilLand select 2;
                    _landClusters = [_landClusters, _taor] call ALIVE_fnc_clustersInsideMarker;
                    _landClusters = [_landClusters, _blacklist] call ALIVE_fnc_clustersOutsideMarker;
                };

                _clusters = [_clusters,_sizeFilter,_priorityFilter] call ALIVE_fnc_copyClusters;
                // cull clusters outside of TAOR marker if defined
                _clusters = [_clusters, _taor] call ALIVE_fnc_clustersInsideMarker;
                // cull clusters inside of Blacklist marker if defined
                _clusters = [_clusters, _blacklist] call ALIVE_fnc_clustersOutsideMarker;
                ///*
                // switch on debug for all clusters if debug on
                {
                    [_x, "debug", [_logic, "debug"] call MAINCLASS] call ALIVE_fnc_cluster;
                } forEach (_clusters + _landClusters);
                //*/

                // store the clusters on the logic
                [_logic, "objectives", _clusters + _landclusters] call MAINCLASS;


                //Move on to special objectives
                if !(isnil "ALIVE_clustersMilHQ") then {
                    _HQClusters = ALIVE_clustersMilHQ select 2;
                    _HQClusters = [_HQClusters,_sizeFilter,_priorityFilter] call ALIVE_fnc_copyClusters;
                    _HQClusters = [_HQClusters, _taor] call ALIVE_fnc_clustersInsideMarker;
                    _HQClusters = [_HQClusters, _blacklist] call ALIVE_fnc_clustersOutsideMarker;
                    /*
                    {
                        [_x, "debug", [_logic, "debug"] call MAINCLASS] call ALIVE_fnc_cluster;
                    } forEach _HQClusters;
                    */
                };

                if !(isnil "ALIVE_clustersMilAir") then {
                    _airClusters = ALIVE_clustersMilAir select 2;
                    _airClusters = [_airClusters,_sizeFilter,_priorityFilter] call ALIVE_fnc_copyClusters;
                    _airClusters = [_airClusters, _taor] call ALIVE_fnc_clustersInsideMarker;
                    _airClusters = [_airClusters, _blacklist] call ALIVE_fnc_clustersOutsideMarker;
                    /*
                    {
                        [_x, "debug", [_logic, "debug"] call MAINCLASS] call ALIVE_fnc_cluster;
                    } forEach _airClusters;
                    */
                };

                if !(isnil "ALIVE_clustersMilHeli") then {
                    _heliClusters = ALIVE_clustersMilHeli select 2;
                    _heliClusters = [_heliClusters,_sizeFilter,_priorityFilter] call ALIVE_fnc_copyClusters;
                    _heliClusters = [_heliClusters, _taor] call ALIVE_fnc_clustersInsideMarker;
                    _heliClusters = [_heliClusters, _blacklist] call ALIVE_fnc_clustersOutsideMarker;
                    /*
                    {
                        [_x, "debug", [_logic, "debug"] call MAINCLASS] call ALIVE_fnc_cluster;
                    } forEach _heliClusters;
                    */
                };

                [_logic, "objectivesLand", _landClusters] call MAINCLASS;
                [_logic, "objectivesHQ", _HQClusters] call MAINCLASS;
                [_logic, "objectivesAir", _airClusters] call MAINCLASS;
                [_logic, "objectivesHeli", _heliClusters] call MAINCLASS;

                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["MP %1 - Startup completed", _faction] call ALiVE_fnc_dump;
                    ["MP %2 - Count clusters %1",count _clusters, _faction] call ALiVE_fnc_dump;
                    ["MP %2 - Count HQ clusters %1",count _HQClusters, _faction] call ALiVE_fnc_dump;
                    ["MP %2 - Count land clusters %1",count _landClusters, _faction] call ALiVE_fnc_dump;
                    ["MP %2 - Count air clusters %1",count _airClusters, _faction] call ALiVE_fnc_dump;
                    ["MP %2 - Count heli clusters %1",count _heliClusters, _faction] call ALiVE_fnc_dump;
                    [] call ALIVE_fnc_timer;
                };
                // DEBUG -------------------------------------------------------------------------------------

                if(_placement) then {

                    if(count _clusters > 0) then {
                        // start placement
                        [_logic, "placement"] call MAINCLASS;
                    }else{
                        ["MP [%1] - Warning no locations found for placement, you need to include military locations within the TAOR marker: %2",_faction, _taor] call ALiVE_fnc_dumpR;

                        // set module as started
                        _logic setVariable ["startupComplete", true];
                    };

                }else{

                    // DEBUG -------------------------------------------------------------------------------------
                    if(_debug) then { ["MP - Objectives Only"] call ALiVE_fnc_dump; };
                    // DEBUG -------------------------------------------------------------------------------------

                    // set module as started
                    _logic setVariable ["startupComplete", true];

                };
            }else{
                // errors
                _logic setVariable ["startupComplete", true];
            };
        };
    };
    // Placement
    case "placement": {
        if (isServer) then {

            private ["_debug","_clusters","_cluster","_HQClusters","_airClusters","_heliClusters","_vehicleClusters",
            "_countHQClusters","_countAirClusters","_countHeliClusters","_size","_type","_faction","_ambientVehicleAmount",
            "_placeHelis","_placeSupplies","_factionConfig","_factionSideNumber","_side","_countProfiles","_vehicleClass",
            "_position","_direction","_unitBlackist","_vehicleBlacklist","_groupBlacklist","_heliClasses","_nodes",
            "_airClasses","_node","_buildings","_customInfantryCount","_customMotorisedCount","_customMechanisedCount",
            "_customArmourCount","_customSpecOpsCount","_countVehicleClusters","_createHQ","_createFieldHQ","_file"];


            _debug = [_logic, "debug"] call MAINCLASS;

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                ["MP - Placement"] call ALiVE_fnc_dump;
                [true] call ALIVE_fnc_timer;
            };
            // DEBUG -------------------------------------------------------------------------------------


            //waituntil {sleep 5; (!(isnil {([_logic, "objectives"] call MAINCLASS)}) && {count ([_logic, "objectives"] call MAINCLASS) > 0})};

            _clusters = [_logic, "objectives"] call MAINCLASS;
            _LandClusters = [_logic, "objectivesLand"] call MAINCLASS;
            _HQClusters = [_logic, "objectivesHQ"] call MAINCLASS;
            _airClusters = [_logic, "objectivesAir"] call MAINCLASS;
            _heliClusters = [_logic, "objectivesHeli"] call MAINCLASS;
            _vehicleClusters = [_logic, "objectivesVehicle"] call MAINCLASS;



            _customInfantryCount = [_logic, "customInfantryCount"] call MAINCLASS;

            if(_customInfantryCount == "") then {
                _customInfantryCount = 666;
            }else{
                _customInfantryCount = parseNumber _customInfantryCount;
            };
            
            _customMotorisedCount = [_logic, "customMotorisedCount"] call MAINCLASS;

            if(_customMotorisedCount == "") then {
                _customMotorisedCount = 666;
            }else{
                _customMotorisedCount = parseNumber _customMotorisedCount;
            };

            _customMechanisedCount = [_logic, "customMechanisedCount"] call MAINCLASS;

            if(_customMechanisedCount == "") then {
                _customMechanisedCount = 666;
            }else{
                _customMechanisedCount = parseNumber _customMechanisedCount;
            };

            _customArmourCount = [_logic, "customArmourCount"] call MAINCLASS;

            if(_customArmourCount == "") then {
                _customArmourCount = 666;
            }else{
                _customArmourCount = parseNumber _customArmourCount;
            };

            _customSpecOpsCount = [_logic, "customSpecOpsCount"] call MAINCLASS;

            if(_customSpecOpsCount == "") then {
                _customSpecOpsCount = 666;
            }else{
                _customSpecOpsCount = parseNumber _customSpecOpsCount;
            };

            _countHQClusters = count _HQClusters;
            _countAirClusters = count _airClusters;
            _countHeliClusters = count _heliClusters;
            _countVehicleClusters = count _vehicleClusters;

            _size = parseNumber([_logic, "size"] call MAINCLASS);
            _type = [_logic, "type"] call MAINCLASS;
            _faction = [_logic, "faction"] call MAINCLASS;
            _ambientVehicleAmount = parseNumber([_logic, "ambientVehicleAmount"] call MAINCLASS);
            _createHQ = [_logic, "createHQ"] call MAINCLASS;
            _createFieldHQ = [_logic, "createFieldHQ"] call MAINCLASS;

            _placeHelis = [_logic, "placeHelis"] call MAINCLASS;
            _placeSupplies = [_logic, "placeSupplies"] call MAINCLASS;

            _factionConfig = _faction call ALiVE_fnc_configGetFactionClass;
            _factionSideNumber = getNumber(_factionConfig >> "side");
            _side = _factionSideNumber call ALIVE_fnc_sideNumberToText;
            _countProfiles = 0;


            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["MP [%1] - Size: %2 Type: %3 SideNum: %4 Side: %5 Faction: %6",_faction,_size,_type,_factionSideNumber,_side,_faction] call ALiVE_fnc_dump;
                ["MP [%1] - Ambient Vehicles: %2 Create HQ: %3 Create Field HQ: %4 Place Helis: %5 Place Supplies: %6",_faction,_ambientVehicleAmount,_createHQ,_createFieldHQ,_placeHelis,_placeSupplies] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            // Load static data
            call ALiVE_fnc_staticDataHandler;

            // Create HQs

            private ["_modulePosition","_sortedData","_closestHQCluster","_hqBuilding"];

            if(_createHQ) then {

                _modulePosition = position _logic;

                if(_countHQClusters > 0) then {

                    if(_countHQClusters > 1) then {
                        _sortedData = [_HQClusters,[],{_modulePosition distance ([_x, "center"] call ALIVE_fnc_hashGet)},"ASCEND"] call ALiVE_fnc_SortBy;
                        _closestHQCluster = _sortedData select 0;
                    }else{
                        _closestHQCluster = _HQClusters select 0;
                    };

                    _nodes = [_closestHQCluster, "nodes"] call ALIVE_fnc_hashGet;

                    _buildings = [_nodes, ALIVE_militaryHQBuildingTypes] call ALIVE_fnc_findBuildingsInClusterNodes;

                    _buildings = [_buildings,[_modulePosition],{_Input0 distance _x},"ASCENDING",{[_x] call ALIVE_fnc_isHouseEnterable}] call ALiVE_fnc_SortBy;

                    if(count _buildings > 0) then {
                        _hqBuilding = _buildings select 0;


                        // DEBUG -------------------------------------------------------------------------------------
                        if(_debug) then {
                            [position _hqBuilding, 4] call ALIVE_fnc_placeDebugMarker;
                        };
                        // DEBUG -------------------------------------------------------------------------------------


                        {
                            _nodes = [_x, "nodes"] call ALIVE_fnc_hashGet;

                            if(_hqBuilding in _nodes) then {
                                [_x, "priority",1000] call ALIVE_fnc_hashSet;
                                [_logic, "HQCluster", _x] call MAINCLASS;
                            };
                        } forEach _clusters;

                        if !(ALIVE_loadProfilesPersistent) then {
	                        _group = ["Infantry",_faction] call ALIVE_fnc_configGetRandomGroup;
	                        _profiles = [_group, position _hqBuilding, random 360, true, _faction] call ALIVE_fnc_createProfilesFromGroupConfig;

	                        {
	                            if (([_x,"type"] call ALiVE_fnc_HashGet) == "entity") then {
	                               [_x, "setActiveCommand", ["ALIVE_fnc_garrison","spawn",[30,"false",[0,0,0],"",1, 1]]] call ALIVE_fnc_profileEntity;
	                            };
	                        } foreach _profiles;
                         };

                        [_logic, "HQBuilding", _hqBuilding] call MAINCLASS;

                        ["MP - HQ building selected: %1",[_logic, "HQBuilding"] call MAINCLASS] call ALiVE_fnc_dump;
                    } else {
                        ["MP - Warning no HQ locations found"] call ALiVE_fnc_dump;
                    }
                } else {
                    ["MP - Warning no HQ locations found"] call ALiVE_fnc_dump;
                };
            };

            if(_createFieldHQ) then {

                _modulePosition = position _logic;

                if(_countHQClusters > 0) then {
                    private ["_compType","_HQ"];
                    if(_countHQClusters > 1) then {
                        _sortedData = [_HQClusters,[],{_modulePosition distance ([_x, "center"] call ALIVE_fnc_hashGet)},"ASCEND"] call ALiVE_fnc_SortBy;
                        _closestHQCluster = _sortedData select 0;
                    }else{
                        _closestHQCluster = _HQClusters select 0;
                    };

                    _pos = [_closestHQCluster,"center"] call ALiVE_fnc_HashGet;
                    _size = [_closestHQCluster,"size",300] call ALiVE_fnc_HashGet;

                    _flatPos = [_pos,_size] call ALiVE_fnc_findFlatArea;

                    if (isNil QMOD(COMPOSITIONS_LOADED)) then {

                        // Get a composition
                        _compType = "Military";
                        If (_faction call ALiVE_fnc_factionSide == RESISTANCE) then {
                            _compType = "Guerrilla";
                        };
                        _HQ = (selectRandom ([_compType, ["FieldHQ"], ["Medium"], _faction] call ALiVE_fnc_getCompositions));

                        if (isNil "_HQ") then {
                            _HQ = (selectRandom ([_compType, ["HQ","FieldHQ"], ["Medium","Small"], _faction] call ALiVE_fnc_getCompositions));
                        };

                        _nearRoads = _flatpos nearRoads 1000;
                        _direction = if (count _nearRoads > 0) then {direction (_nearRoads select 0)} else {random 360};

                        [_HQ, _flatPos, _direction, _faction] call ALiVE_fnc_spawnComposition;
                    };

                    [_logic, "FieldHQBuilding", nearestObject [_flatPos, "building"]] call MAINCLASS;

                    if !(ALIVE_loadProfilesPersistent) then {
                        _group = ["Infantry",_faction] call ALIVE_fnc_configGetRandomGroup;
                        _profiles = [_group, _flatPos, random 360, true, _faction] call ALIVE_fnc_createProfilesFromGroupConfig;

                        {
                            if (([_x,"type"] call ALiVE_fnc_HashGet) == "entity") then {
                                [_x, "setActiveCommand", ["ALIVE_fnc_garrison","spawn",[30,"false",[0,0,0],"",1, 1]]] call ALIVE_fnc_profileEntity;
                            };
                        } foreach _profiles;
                    };

                    // DEBUG -------------------------------------------------------------------------------------
                    if(_debug) then {
                        [_flatPos, 4] call ALIVE_fnc_placeDebugMarker;
                        if !(isNil "_HQ") then {
                          ["MP - Field HQ created: %1 - %2", configName _HQ, [_logic, "FieldHQBuilding"] call MAINCLASS] call ALiVE_fnc_dump;
                        };
                    };
                    // DEBUG -------------------------------------------------------------------------------------
                } else {
                    ["MP - Warning no Field HQ locations found"] call ALiVE_fnc_dump;
                };
            };

            if (count _landClusters > 0) then {
                {
                    private ["_compType","_composition","_pos"];
                    _pos = [_x,"center"] call ALiVE_fnc_HashGet;

                    _flatPos = [_pos,500] call ALiVE_fnc_findFlatArea;

                    if (isNil QMOD(COMPOSITIONS_LOADED)) then {
                        // Get a composition
                        _compType = "Military";
                        If (_faction call ALiVE_fnc_factionSide == RESISTANCE) then {
                            _compType = "Guerrilla";
                        };

                        _composition = (selectRandom ([_compType, ["Camps","Outposts"], ["Medium"], _faction] call ALiVE_fnc_getCompositions));

                        if (isNil "_composition") then {
                            _composition = (selectRandom ([_compType, ["Camps","Outposts"], ["Medium","Small"], _faction] call ALiVE_fnc_getCompositions));
                        };

                        if(count _composition > 0) then {
                            [_composition, _pos, random 360, _faction] call ALIVE_fnc_spawnComposition;
                        };
                    };

                    [_x,"nodes",nearestObjects [_pos,["static"],50]] call ALIVE_fnc_hashSet;

                } foreach _landClusters;
            };

            // Spawn supplies in objectives

            private ["_countSupplies","_supplyClasses","_box"];
            _countSupplies = 0;

            if(_placeSupplies) then {

                // attempt to get supplies by faction
                private _staticFaction = [_faction] call ALiVE_fnc_factionCompilerGetConfigFaction;
                _supplyClasses = [ALIVE_factionDefaultSupplies,_staticFaction,[]] call ALIVE_fnc_hashGet;

                //["SUPPLY CLASSES: %1",_supplyClasses] call ALIVE_fnc_dump;

                // if no supplies found for the faction use side supplies
                if(count _supplyClasses == 0) then {
                    _supplyClasses = [ALIVE_sideDefaultSupplies,_side] call ALIVE_fnc_hashGet;
                };

                _supplyClasses = _supplyClasses - ALiVE_PLACEMENT_VEHICLEBLACKLIST;

                if(count _supplyClasses > 0) then {
                    {
                        _nodes = [_x, "nodes"] call ALIVE_fnc_hashGet;

                        _buildings = [_nodes, ALIVE_militarySupplyBuildingTypes] call ALIVE_fnc_findBuildingsInClusterNodes;

                        //["BUILDINGS: %1",_buildings] call ALIVE_fnc_dump;

                        //[_x, "debug", true] call ALIVE_fnc_cluster;
                        {
                            private _buildingPositions = [_x] call BIS_fnc_buildingPositions;

                            if (count _buildingPositions > 0) then {
                                _position = (selectRandom _buildingPositions);
                            } else {
                                _position = position _x;
                            };

                            _direction = direction _x;
                            _vehicleClass = (selectRandom _supplyClasses);

                            if(random 1 > 0.6) then {

                                _box = createVehicle [_vehicleClass, _position, [], 0, "NONE"];
                                _countSupplies = _countSupplies + 1;
                            };
                        } forEach _buildings;
                    } forEach _clusters;
                };
            };

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["MP [%1] - Supplies placed: %2",_faction,_countSupplies] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            if(ALIVE_loadProfilesPersistent) exitWith {

                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then { ["MP - Profiles are persistent, no creation of profiles"] call ALiVE_fnc_dump; };
                // DEBUG -------------------------------------------------------------------------------------

                // set module as started
                _logic setVariable ["startupComplete", true];

            };

            // Spawn helicopters on pads
            private ["_countCrewedHelis","_countUncrewedHelis"];
            _countCrewedHelis = 0;
            _countUncrewedHelis = 0;

            if(_placeHelis) then {

                _heliClasses = [0,_faction,"Helicopter"] call ALiVE_fnc_findVehicleType;
                _heliClasses = _heliClasses - ALiVE_PLACEMENT_VEHICLEBLACKLIST;

                if(count _heliClasses > 0) then {

                    {
                        private _nodes = [_x, "nodes",[]] call ALIVE_fnc_hashGet;

                        //[_x, "debug", true] call ALIVE_fnc_cluster;
                        {
                            // Validator finds a clear helipad (or hangar /
                            // apron / field if no helipad fits) within 200 m
                            // of the cluster node. The session registry
                            // replaces the per-cluster 20 m proximity check;
                            // the obstacle-table sweep covers map-maker-
                            // placed HeliH markers in cluttered camps that
                            // were the explode-on-spawn source. Returns []
                            // if every candidate failed - skip this node.
                            _vehicleClass = (selectRandom _heliClasses);
                            private _airResult = [_vehicleClass, position _x, 200, "auto"] call ALiVE_fnc_findAirSpawnPosition;
                            if (count _airResult >= 2) then {
                                _position = _airResult select 0;
                                _direction = _airResult select 1;

                                // Crewed helis only make sense as a pool for mil_ato to
                                // task (CAS / transport / scout). Without mil_ato in the
                                // mission, the crew sit idle on the helipad burning AI
                                // forever - waste of slots. Gate the crewed branch on
                                // mil_ato module presence: if not placed in Eden, force
                                // 100% uncrewed. If placed, fall back to the 20% chance.
                                private _atoActive = count (allMissionObjects "ALiVE_mil_ato") > 0;
                                private _diceRoll = random 1;
                                private _crewed = _atoActive && {_diceRoll <= 0.2};
                                if (!isNil "ALiVE_vehicleSpawn_debug" && {ALiVE_vehicleSpawn_debug}) then {
                                    diag_log format ["[ALiVE VehSpawn DEBUG] HELI-PLACEMENT module=mil_placement faction=%1 class=%2 pos=%3 atoActive=%4 dice=%5 threshold=0.2 result=%6",
                                        _faction, _vehicleClass, _position, _atoActive, _diceRoll,
                                        if (_crewed) then {"CREWED"} else {"UNCREWED"}];
                                };

                                if !(_crewed) then {
                                    [_vehicleClass,_side,_faction,_position,_direction,false,_faction] call ALIVE_fnc_createProfileVehicle;
                                    _countProfiles = _countProfiles + 1;
                                    _countUncrewedHelis = _countUncrewedHelis + 1;
                                } else {
                                    [_vehicleClass,_side,_faction,"CAPTAIN",_position,_direction,false,_faction] call ALIVE_fnc_createProfilesCrewedVehicle;
                                    _countProfiles = _countProfiles + 2;
                                    _countCrewedHelis = _countCrewedHelis + 1;
                                };
                            };
                        } forEach _nodes;
                    } forEach _heliClusters;
                };
            };

            // TODO if placehelis is true, but no helis placed - create heliports

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["MP [%1] - Heli units placed: crewed:%2 uncrewed:%3",_faction,_countCrewedHelis,_countUncrewedHelis] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            // Spawn air units in hangars

            private ["_countCrewedAir","_countUncrewedAir"];
            _countCrewedAir = 0;
            _countUncrewedAir = 0;

            if(_placeHelis) then {

                _airClasses = [0,_faction,"Plane"] call ALiVE_fnc_findVehicleType;
                _airClasses = _airClasses - ALiVE_PLACEMENT_VEHICLEBLACKLIST;

                // Hangar placement is for FIXED-WING aircraft only. The
                // pre-existing fallback `_airClasses = _airClasses +
                // _heliClasses` produced helis sitting inside hangars when
                // a faction had no plane classes - undesirable visually
                // (helis are meant for the helipad path at line 970) and
                // a frequent source of clipping. If the faction has no
                // planes, leave the hangar empty.

                if(count _airClasses > 0) then {

                    {
                        _nodes = [_x, "nodes"] call ALIVE_fnc_hashGet;

                        _buildings = [_nodes, ALIVE_airBuildingTypes] call ALIVE_fnc_findBuildingsInClusterNodes;

                        //[_x, "debug", true] call ALIVE_fnc_cluster;
                        {
                            if(random 1 > 0.3) then {
                                _vehicleClass = (selectRandom _airClasses);

                                // Validator handles bbox fit, door
                                // verification, auto-orient, apron
                                // fallback, runway/taxiway exclusion,
                                // and the session registry. The legacy
                                // hand-rolled hangar / taxiway / safe-
                                // pos branches collapse into one call.
                                // The ALIVE_problematicHangarBuildings
                                // override list is preserved as the
                                // raycast-uncertain fallback inside
                                // the validator. Returns [] when no
                                // safe spot exists - skip this building.
                                private _airResult = [_vehicleClass, position _x, 100, "auto"] call ALiVE_fnc_findAirSpawnPosition;
                                if (count _airResult >= 2) then {
                                    _position = _airResult select 0;
                                    _direction = _airResult select 1;

                                    // Diagnostic. Hangar-path air units are always
                                    // uncrewed (createProfileVehicle, no Crewed
                                    // variant), but logging the placement gives
                                    // visibility into faction / class / hangar
                                    // positions for debugging.
                                    if (!isNil "ALiVE_vehicleSpawn_debug" && {ALiVE_vehicleSpawn_debug}) then {
                                        diag_log format ["[ALiVE VehSpawn DEBUG] HELI-PLACEMENT module=mil_placement source=hangar faction=%1 class=%2 pos=%3 result=UNCREWED",
                                            _faction, _vehicleClass, _position];
                                    };

                                    [_vehicleClass,_side,_faction,_position,_direction,false,_faction] call ALIVE_fnc_createProfileVehicle;
                                    _countProfiles = _countProfiles + 1;
                                    _countUncrewedAir = _countUncrewedAir + 1;
                                };
                            };

                        } forEach _buildings;
                    } forEach _airClusters;
                };
            };


            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["MP [%1] - Air units placed: crewed:%2 uncrewed:%3",_faction,_countCrewedAir,_countUncrewedAir] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            // Spawn ambient vehicles

            private ["_countLandUnits","_carClasses","_armorClasses","_landClasses","_supportCount","_supportMax","_supportClasses","_types",
            "_countBuildings","_parkingChance","_usedPositions","_building","_parkingPosition","_positionOK","_supportPlacement"];

            _countLandUnits = 0;

            if(_ambientVehicleAmount > 0) then {

                _carClasses = [0,_faction,"Car"] call ALiVE_fnc_findVehicleType;
                _armorClasses = [0,_faction,"Tank"] call ALiVE_fnc_findVehicleType;
                _landClasses = _carClasses + _armorClasses;
                _landClasses = _landClasses - ALiVE_PLACEMENT_VEHICLEBLACKLIST;

                private _staticFaction = [_faction] call ALiVE_fnc_factionCompilerGetConfigFaction;
                _supportClasses = [ALIVE_factionDefaultSupports,_staticFaction,[]] call ALIVE_fnc_hashGet;

                //["SUPPORT CLASSES: %1",_supportClasses] call ALIVE_fnc_dump;

                // if no supports found for the faction use side supplies
                if(count _supportClasses == 0) then {
                    _supportClasses = [ALIVE_sideDefaultSupports,_side] call ALIVE_fnc_hashGet;
                };

                if(count _landClasses == 0) then {
                    _landClasses = _landClasses + _supportClasses;
                }else{
                    _landClasses = _landClasses - _supportClasses;
                };

                //["LAND CLASSES: %1",_landClasses] call ALIVE_fnc_dump;

                if(count _landClasses > 0) then {

                    {

                        _supportCount = 0;
                        _supportMax = 0;

                        _nodes = [_x, "nodes"] call ALIVE_fnc_hashGet;

                        _buildings = [_nodes, ALIVE_militaryParkingBuildingTypes] call ALIVE_fnc_findBuildingsInClusterNodes;

                        //["BUILDINGS: %1",_buildings] call ALIVE_fnc_dump;

                        _countBuildings = count _buildings;
                        _parkingChance = 0.1 * _ambientVehicleAmount;

                        //["COUNT BUILDINGS: %1",_countBuildings] call ALIVE_fnc_dump;
                        //["CHANCE: %1",_parkingChance] call ALIVE_fnc_dump;

                        if(_countBuildings > 50) then {
                            _supportMax = 5;
                            _parkingChance = 0.1 * _ambientVehicleAmount;
                        };

                        if(_countBuildings > 40 && _countBuildings < 50) then {
                            _supportMax = 5;
                            _parkingChance = 0.2 * _ambientVehicleAmount;
                        };

                        if(_countBuildings > 30 && _countBuildings < 41) then {
                            _supportMax = 5;
                            _parkingChance = 0.3 * _ambientVehicleAmount;
                        };

                        if(_countBuildings > 20 && _countBuildings < 31) then {
                            _supportMax = 3;
                            _parkingChance = 0.4 * _ambientVehicleAmount;
                        };

                        if(_countBuildings > 10 && _countBuildings < 21) then {
                            _supportMax = 2;
                            _parkingChance = 0.6 * _ambientVehicleAmount;
                        };

                        if(_countBuildings > 0 && _countBuildings < 11) then {
                            _supportMax = 1;
                            _parkingChance = 0.7 * _ambientVehicleAmount;
                        };

                        //["SUPPORT MAX: %1",_supportMax] call ALIVE_fnc_dump;
                        //["CHANCE: %1",_parkingChance] call ALIVE_fnc_dump;

                        _usedPositions = [];

                        {
                            if(random 1 < _parkingChance) then {

                                _building = _x;

                                _supportPlacement = false;
                                if(_supportCount <= _supportMax) then {
                                    _supportPlacement = true;
                                    _vehicleClass = (selectRandom _supportClasses);
                                }else{
                                    _vehicleClass = (selectRandom _landClasses);
                                };

                                //["SUPPORT PLACEMENT: %1",_supportPlacement] call ALIVE_fnc_dump;
                                //["VEHICLE CLASS: %1",_vehicleClass] call ALIVE_fnc_dump;

                                _parkingPosition = [_vehicleClass,_building,[]] call ALIVE_fnc_getParkingPosition;

                                if (count _parkingPosition == 2) then {

                                    private _positionOK = true;

                                    {
                                        _position = _x select 0;
                                        if((_parkingPosition select 0) distance _position < 10) then {
                                            _positionOK = false;
                                        };
                                    } forEach _usedPositions;

                                    //["POS OK: %1",_positionOK] call ALIVE_fnc_dump;

                                    if(_positionOK) then {
                                        // The trailing `,[],true` previously here passed `true`
                                        // as the 9th positional arg, which maps to `_isSPE` per
                                        // ALiVE_fnc_createProfileVehicle's params block. That
                                        // flagged every ambient mil vehicle as SPE and skipped
                                        // the unified spawn-position validator at activation
                                        // time (fnc_profileVehicle.sqf:549 gates the validator
                                        // call behind `if !(_isSPE)`). On non-SPE maps that
                                        // meant ambient mil vehicles materialised at the raw
                                        // parking position with no bbox-aware footprint check
                                        // and no settle window - causing spawn-clip explosions
                                        // at military bases. Drop the trailing args so _cargo
                                        // and _isSPE fall back to their defaults ([] and false)
                                        // and the validator engages on activation. Same fix
                                        // applied to mil_placement_custom/fnc_CMP.sqf:939.
                                        [_vehicleClass,_side,_faction,_parkingPosition select 0,_parkingPosition select 1,false,_faction] call ALIVE_fnc_createProfileVehicle;

                                        _countLandUnits = _countLandUnits + 1;

                                        _usedPositions pushback _parkingPosition;

                                        if(_supportPlacement) then {
                                            _supportCount = _supportCount + 1;
                                        };
                                    };
                                };
                            };

                        } forEach _buildings;

                    } forEach _clusters;
                };
            };


            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["MP [%1] - Ambient land units placed: %2",_faction,_countLandUnits] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            // Spawn the main force

            private ["_countArmored","_countMechanized","_countMotorized","_countInfantry",
            "_countAir","_countSpecOps","_groups","_motorizedGroups","_infantryGroups","_group","_groupPerCluster","_totalCount","_center","_size","_position",
            "_groupCount","_clusterCount"];

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["MP [%1] - Size: %2",_faction,_size] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------

            _countArmored = 0;
            _countMechanized = 0;
            _countMotorized = 0;
            _countInfantry = 0;
            _countAir = 0;
            _countSpecOps = 0;



            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["MP [%1] - TYPE: %2", _faction, _type] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------
            // Force Composition
            switch(_type) do {
                case "Armored": {
                    _countArmored = floor((_size / 20) * 0.5);
                    _countMechanized = floor((_size / 12) * random(0.2));
                    _countMotorized = floor((_size / 12) * random(0.2));
                    _countInfantry = floor((_size / 10) * 0.5);
                    _countAir = floor((_size / 30) * random(0.1));
                    _countSpecOps = floor((_size / 25) * 0.5);
                };
                case "Mechanized": {
                    _countMechanized = floor((_size / 12) * 0.5);
                    _countArmored = floor((_size / 20) * random(0.2));
                    _countMotorized = floor((_size / 12) * random(0.2));
                    _countInfantry = floor((_size / 10) * 0.5);
                    _countAir = floor((_size / 30) * random(0.1));
                    _countSpecOps = floor((_size / 25) * 0.5);
                };
                case "Motorized": {
                    _countMotorized = floor((_size / 12) * 0.5);
                    _countMechanized = floor((_size / 12) * random(0.2));
                    _countArmored = floor((_size / 20) * random(0.2));
                    _countInfantry = floor((_size / 10) * 0.5);
                    _countAir = floor((_size / 30) * random(0.1));
                    _countSpecOps = floor((_size / 25) * 0.5);
                };
                case "Infantry": {
                    _countInfantry = floor((_size / 10) * 0.8);
                    _countMotorized = floor((_size / 12) * random(0.2));
                    _countMechanized = floor((_size / 12) * random(0.2));
                    _countArmored = floor((_size / 20) * random(0.2));
                    _countAir = floor((_size / 30) * random(0.1));
                    _countSpecOps = floor((_size / 25) * 0.5);
                };
                case "Air": {
                    _countAir = floor((_size / 30) * 0.5);
                    _countInfantry = floor((_size / 10) * 0.5);
                    _countMotorized = floor((_size / 12) * random(0.2));
                    _countMechanized = floor((_size / 12) * random(0.2));
                    _countArmored = floor((_size / 20) * random(0.2));
                    _countSpecOps = floor((_size / 25) * 0.5);
                };
                case "Specops": {
                    _countAir = floor((_size / 30) * 0.5);
                    _countInfantry = floor((_size / 10) * 0.5);
                    _countMotorized = floor((_size / 12) * random(0.2));
                    _countMechanized = floor((_size / 12) * random(0.2));
                    _countArmored = floor((_size / 20) * random(0.2));
                    _countSpecOps = floor((_size / 10) * 0.5);
                };
            };

            if!(_customInfantryCount == 666) then {
                _countInfantry = _customInfantryCount; 
            };

            if!(_customMotorisedCount == 666) then {
                _countMotorized = _customMotorisedCount;
            };

            if!(_customMechanisedCount == 666) then {
                _countMechanized = _customMechanisedCount;
            };

            if!(_customArmourCount == 666) then {
                _countArmored = _customArmourCount;
            };

            if!(_customSpecOpsCount == 666) then {
                _countSpecOps = _customSpecOpsCount;
            };



          
            private _guardProbabilityCount = [_countInfantry,[_logic, "guardProbability"] call MAINCLASS] call ALIVE_fnc_infantryGuardProbabilityCount;
            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
	            ["MP [%1] - Garrison _guardProbabilityCount: %2", _faction, _guardProbabilityCount] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------
            
            if (_guardProbabilityCount > 0) then {
              _countInfantry = _countInfantry - _guardProbabilityCount;
            };

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["MP [%1] - Main force creation ",_faction] call ALiVE_fnc_dump;
                ["Count Armor: %1",_countArmored] call ALIVE_fnc_dump;
                ["Count Mech: %1",_countMechanized] call ALIVE_fnc_dump;
                ["Count Motor: %1",_countMotorized] call ALIVE_fnc_dump;
                ["Count Air: %1",_countAir] call ALIVE_fnc_dump;
                ["Count Infantry: %1",_countInfantry] call ALIVE_fnc_dump;
                ["Count Garrison Infantry: %1",_guardProbabilityCount] call ALIVE_fnc_dump;
                ["Count Spec Ops: %1",_countSpecOps] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            // Assign groups
            _groups = [];

            for "_i" from 0 to _countArmored -1 do {
                _group = ["Armored",_faction] call ALIVE_fnc_configGetRandomGroup;
                if!(_group == "FALSE") then {
                    _groups pushback _group;
                };
            };

            for "_i" from 0 to _countMechanized -1 do {
                _group = ["Mechanized",_faction] call ALIVE_fnc_configGetRandomGroup;
                if!(_group == "FALSE") then {
                    _groups pushback _group;
                }
            };

            if(_countMotorized > 0) then {

                _motorizedGroups = [];

                for "_i" from 0 to _countMotorized -1 do {
                    _group = ["Motorized",_faction] call ALIVE_fnc_configGetRandomGroup;
                    if!(_group == "FALSE") then {
                        _motorizedGroups pushback _group;
                    };
                };

                if(count _motorizedGroups == 0) then {
                    for "_i" from 0 to _countMotorized -1 do {
                        _group = ["Motorized_MTP",_faction] call ALIVE_fnc_configGetRandomGroup;
                        if!(_group == "FALSE") then {
                            _motorizedGroups pushback _group;
                        };
                    };
                };

                _groups = _groups + _motorizedGroups;
            };

            _infantryGroups = [];
            for "_i" from 0 to _countInfantry -1 do {
                _group = ["Infantry",_faction] call ALIVE_fnc_configGetRandomGroup;
                if!(_group == "FALSE") then {
                    _infantryGroups pushback _group;
                }
            };

            for "_i" from 0 to _countSpecOps -1 do {
                _group = ["SpecOps",_faction] call ALIVE_fnc_configGetRandomGroup;
                if!(_group == "FALSE") then {
                    _infantryGroups pushback _group;
                };
            };

            // Capture the infantry index range BEFORE the air block extends
            // _groups further. Used downstream by the reserve-pool logic to
            // restrict reservable groups to infantry / specops only -
            // vehicle and air groups always activate at mission start
            // regardless of Readiness, since the activation path spawns
            // groups near buildings and that's only sensible for foot
            // soldiers. Indices reflect ACTUAL placements: configGetRandomGroup
            // may return "FALSE" for missing categories, so post-blacklist
            // counts can be less than the requested counts.
            private _infantryGroupStart = count _groups;
            _groups = _groups + _infantryGroups;
            private _infantryGroupEnd = count _groups;

            if (_placeHelis) then {
                for "_i" from 0 to _countAir -1 do {
                    _group = ["Air",_faction] call ALIVE_fnc_configGetRandomGroup;
                    if!(_group == "FALSE") then {
                        _groups pushback _group;
                    };
                };
            };

            _groups = _groups - ALiVE_PLACEMENT_GROUPBLACKLIST;
            _infantryGroups = _infantryGroups - ALiVE_PLACEMENT_GROUPBLACKLIST;
            // Blacklist subtraction can shift indices. Recompute the
            // infantry boundary by re-finding the start position. The
            // first infantry group's config name is the marker.
            if (count _infantryGroups > 0) then {
                _infantryGroupStart = _groups find (_infantryGroups select 0);
                if (_infantryGroupStart < 0) then { _infantryGroupStart = 0 };
                _infantryGroupEnd = _infantryGroupStart + (count _infantryGroups);
            } else {
                _infantryGroupStart = 0;
                _infantryGroupEnd = 0;
            };

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["MP [%1] - Groups ",_groups] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            // Position and create groups
            _groupCount = count _groups;
            _clusterCount = count _clusters;
            _groupPerCluster = floor(_groupCount / _clusterCount);
            _totalCount = 0;

            if(_groupCount > 0) then {
                // Reserve-pool placement model (v2). `Readiness` controls
                // what fraction of the configured force - both infantry
                // AND vehicle groups - activates at mission start. The
                // remainder stays in per-cluster reserve pools and wakes
                // when active losses cross the activation threshold (see
                // fnc_activateReserve).
                //
                // Reserve modes:
                //   Infantry reserve: group config held in pool; on
                //     activation, the group is spawned at a candidate
                //     building.
                //   Vehicle reserve: vehicle profile is created EMPTY
                //     at the parking position via createProfilesUnCrewedVehicle
                //     (so the world looks fully kitted out from start);
                //     the crew config is held in the pool. On activation,
                //     crew is added to the existing empty entity profile
                //     and a despawn / spawn cycle materialises the men
                //     inside the parked vehicle.
                //
                // Air groups always activate at mission start regardless
                // of Readiness - the air placement path uses the air
                // spawn validator and isn't covered by this reserve model.
                //
                // `activePatrolPercent` splits the ACTIVE force between
                // patrolling (ambientMovement) and garrisoning buildings
                // (garrison command).
                private _readinessLevel = parseNumber([_logic, "readinessLevel"] call MAINCLASS);
                private _activePatrolPercent = parseNumber([_logic, "activePatrolPercent"] call MAINCLASS);
                private _vehicleEmptyLocked = (parseNumber([_logic, "reserveEmptyVehicleLocked"] call MAINCLASS)) > 0;
                // Vehicle / infantry boundary. Groups [0, _infantryGroupStart)
                // are vehicles (armoured / mechanised / motorised);
                // [_infantryGroupStart, _infantryGroupEnd) are infantry +
                // specops; [_infantryGroupEnd, _) are air.
                private _vehicleGroupCount = _infantryGroupStart;
                private _vehicleActiveCount = round (_vehicleGroupCount * _readinessLevel);
                private _infantryGroupCount = _infantryGroupEnd - _infantryGroupStart;
                private _infantryActiveCount = round (_infantryGroupCount * _readinessLevel);
                // Total active = all groups minus reserves (vehicle + infantry).
                // Air groups are always active.
                private _activeCount = _groupCount
                    - (_vehicleGroupCount - _vehicleActiveCount)
                    - (_infantryGroupCount - _infantryActiveCount);
                // Garrison budget applies to INFANTRY only - vehicle groups
                // always go to ambientMovement (the garrison command is a
                // building-occupation pattern that doesn't translate to
                // crewed trucks). Compute against infantry active count so
                // _activePatrolPercent scales the infantry-in-buildings vs
                // infantry-on-patrol split, leaving vehicles to always
                // patrol roads regardless of the percentage.
                private _garrisonCount = round (_infantryActiveCount * (1 - _activePatrolPercent));
                // Per-iteration trackers. _totalCount is the global index
                // into _groups; these are decision counters for the
                // garrison-split + reserve-cutoff thresholds.
                private _activePlacedCount = 0;
                private _infantryActivePlacedCount = 0;
                private _vehicleActivePlacedCount = 0;

                // Helper: extract the first LandVehicle classname from a
                // CfgGroups class. Used to identify which vehicle to park
                // empty when a vehicle group goes into reserve. Returns
                // "" if the group has no LandVehicle entry - that group
                // then falls through to active placement.
                //
                // Filter rationale: only true LandVehicles (Car / Truck /
                // Tank / APC / wheeled-AA-mount) are reservable. Static
                // weapons (mortars, ground-mounted AA, radars like the
                // P-37 "Bar Lock") and StaticWeapon-derived classes are
                // EXCLUDED - empty parked radars look wrong and aren't
                // what mission-makers want from a "vehicle reserve"
                // mechanic. They always activate at mission start
                // through the existing flow.
                private _fnc_getGroupVehicleClass = {
                    params ["_groupClass", "_groupFaction"];
                    private _config = [_groupFaction, _groupClass] call ALIVE_fnc_configGetGroup;
                    if (count _config == 0) exitWith { "" };
                    private _result = "";
                    for "_i" from 0 to (count _config - 1) do {
                        if (_result != "") exitWith {};
                        private _entry = _config select _i;
                        if (isClass _entry) then {
                            private _vehicle = getText (_entry >> "vehicle");
                            if (_vehicle isKindOf "LandVehicle") then {
                                _result = _vehicle;
                            };
                        };
                    };
                    _result
                };

                // Helper: cluster-aware parking-position lookup. The
                // unified validator's default 100 m radius is correct
                // for amb_civ_population (parking-spot semantics) but
                // tight against mil_placement clusters that can be
                // 150-500 m+ wide. With a tight radius, vehicles in
                // forested clusters fall through to random terrain
                // and AI drivers get stuck navigating trees.
                //
                // Cascade:
                //   1. Validator at cluster-aware radius (size + 100,
                //      min 200) seeded from a random pick inside the
                //      cluster, pref="road" - Stage 1 centre + Stage 2
                //      road graph. Roadside hit is the desired outcome.
                //   2. Same radius, pref="auto" - lets Stage 3 field
                //      heuristic find a flat clearing on heavily
                //      forested maps where no road is in reach.
                //   3. isFlatEmpty on the seed - if it's a stable
                //      flat patch, use it.
                //   4. Wide-radius retry - validator with cluster_size
                //      * 3 radius from cluster centre, pref="auto".
                //      Catches cases like Stratis's Air Station Mike-
                //      26 where the cluster sits in an airport zone
                //      and the access roads are hundreds of metres
                //      from where stages 1-3 sampled. The validator's
                //      bounded chain walk handles the wider radius
                //      without runaway cost.
                //   5. Truly last resort - 50 m offset from cluster
                //      centre. Mirrors the legacy fallback so we
                //      never block placement of a group; AI may still
                //      get stuck but mission init succeeds.
                //
                // Returns [pos, dir]. Always succeeds (last resort).
                private _fnc_findVehicleParkingPos = {
                    params ["_vehicleClass", "_clusterCenter", "_clusterSize"];
                    if (_vehicleClass == "") exitWith {
                        [_clusterCenter getPos [(random (_clusterSize / 2)) + 30, random 360], random 360]
                    };

                    // Gradient acceptance check applied to validator
                    // results before we accept them. The validator's
                    // Stage 1 (centre) only checks obstacles, NOT
                    // gradient - a sloped forest clearing passes the
                    // footprint check but parks the vehicle at a
                    // physics-unfriendly angle (rolls / sinks). A
                    // 0.4 m max-delta over 5 m radius is roughly
                    // ~5 deg - generous enough that legitimate gentle
                    // slopes pass, strict enough to reject hillsides.
                    private _fnc_isFlatEnough = {
                        params ["_pos"];
                        private _flat = _pos isFlatEmpty [-1, -1, 0.4, 5, 0, false, objNull];
                        count _flat >= 2
                    };

                    private _searchRadius = (_clusterSize + 100) max 200;
                    private _seedPos = _clusterCenter getPos [(random (_clusterSize / 2)) + 30, random 360];
                    private _seedDir = random 360;

                    // Stage A: validator pref="road". Validator's Stage
                    // 1 (centre check) only checks obstacles, not
                    // gradient - a sloped forest clearing can pass.
                    // Gradient-check the result; if the seed-pos
                    // accept is on a slope, fall through to the
                    // road/field stages which prefer flat ground.
                    private _result = [_vehicleClass, _seedPos, _searchRadius, "road", _seedDir] call ALiVE_fnc_findVehicleSpawnPosition;
                    if (count _result >= 2 && {[_result select 0] call _fnc_isFlatEnough}) exitWith { _result };

                    // Stage B: validator pref="auto" - Stage 3 field
                    // heuristic. Stage 3 already gradient-checks; but
                    // if Stage 1 accepted first (sloped seed) we'd
                    // skip Stage 3 internally, so re-check here too.
                    _result = [_vehicleClass, _seedPos, _searchRadius, "auto", _seedDir] call ALiVE_fnc_findVehicleSpawnPosition;
                    if (count _result >= 2 && {[_result select 0] call _fnc_isFlatEnough}) exitWith { _result };

                    // Stage C: flat seed. Only accept if the seed
                    // itself is gradient-clear (catches the case where
                    // the seed happened to land on grass clear of
                    // trees AND on flat ground).
                    if ([_seedPos] call _fnc_isFlatEnough) exitWith { [_seedPos, _seedDir] };

                    // Stage D: wide-radius retry from cluster centre.
                    // _maxDistance gates Stage 2's nearRoads seed and
                    // Stage 3's getPos sample radius - tripling
                    // cluster_size pulls in road segments and
                    // clearings well beyond the immediate pre-pick
                    // area. Useful when the cluster sits in airport-
                    // like terrain where stages A-C all fail.
                    _result = [_vehicleClass, _clusterCenter, _clusterSize * 3, "auto", _seedDir] call ALiVE_fnc_findVehicleSpawnPosition;
                    if (count _result >= 2 && {[_result select 0] call _fnc_isFlatEnough}) exitWith { _result };

                    // Stage E: truly last resort. 50 m offset from
                    // cluster centre. Mirrors the legacy fallback so
                    // we never block placement; AI may still get
                    // stuck but mission init succeeds.
                    [_clusterCenter getPos [50, random 360], _seedDir]
                };

                {
                    private ["_guardGroup","_guards","_center","_size","_profiles"];

                    // Capture the cluster ref - inner profile foreaches
                    // shadow the outer _x with their own _x (the profile),
                    // so we need the cluster reference under a stable name
                    // for tagging profiles back to it.
                    private _cluster = _x;

                    _center = [_x, "center"] call ALIVE_fnc_hashGet;
                    _size = [_x, "size"] call ALIVE_fnc_hashGet;

                    // Per-cluster reserve metadata. Initialised here even
                    // if reservePool ends up empty for this cluster -
                    // makes the PFH safe to iterate every cluster
                    // unconditionally.
                    //   reservePool         - [[_group,_faction,_onSpawn,_onSpawnOnce], ...]
                    //                         pending group configs awaiting activation
                    //   reserveActiveAtSpawn- count of active entity profiles created
                    //                         at mission start (for threshold check)
                    //   activeProfileIDs    - [profileID, ...] still-alive profile IDs
                    //                         tracked by the activation PFH; profiles
                    //                         get removed from the pool when killed,
                    //                         not when virtualised
                    //   lastReserveWake     - serverTime of last successful reserve
                    //                         activation (cooldown gate)
                    //   reserveModule       - back-ref to the placement module logic
                    //                         so the PFH can read live attribute values
                    //   reserveModuleClass  - MAINCLASS function ref (e.g. ALIVE_fnc_MP)
                    //                         so the shared activateReserve in addons/main
                    //                         can dispatch attribute reads to this module
                    [_x, "reservePool", []] call ALiVE_fnc_hashSet;
                    [_x, "reserveActiveAtSpawn", 0] call ALiVE_fnc_hashSet;
                    [_x, "activeProfileIDs", []] call ALiVE_fnc_hashSet;
                    [_x, "lastReserveWake", -999] call ALiVE_fnc_hashSet;
                    [_x, "reserveModule", _logic] call ALiVE_fnc_hashSet;
                    [_x, "reserveModuleClass", MAINCLASS] call ALiVE_fnc_hashSet;
                    

                    // DEBUG -------------------------------------------------------------------------------------
                    if(_debug) then {
                      ["MP [%1] - Garrison _guardProbabilityCount: %2", _faction, _guardProbabilityCount] call ALiVE_fnc_dump;           
                    };
                    // DEBUG -------------------------------------------------------------------------------------
            
                    private _guardRadius = parseNumber([_logic, "guardRadius"] call MAINCLASS);
                    private _guardPatrolPercentage = parseNumber([_logic, "guardPatrolPercentage"] call MAINCLASS);
                		private _guardDistance = _size; 
                        
                    if(count _infantryGroups > 0 && _guardProbabilityCount > 0) then {
                     for "_i" from 0 to _guardProbabilityCount -1 do {
                     	
                        _guardGroup = (selectRandom _infantryGroups);
                        _guards = [_guardGroup, [_center, _guardDistance] call CBA_fnc_RandPos, random(360), true, _faction, false, false, "STEALTH", _onEachSpawn, _onEachSpawnOnce] call ALIVE_fnc_createProfilesFromGroupConfig;
                        
                        // DEBUG -------------------------------------------------------------------------------------
                        if(_debug) then {
                          ["MP [%1] - Placing Garrison Guards - %2", _faction, _guardGroup] call ALiVE_fnc_dump;
                        };
                        // DEBUG -------------------------------------------------------------------------------------
                    
                        // Garrison & Patrols instead of the static garrison.
                        {
                            if (([_x,"type"] call ALiVE_fnc_HashGet) == "entity") then {
                              [_x, "setActiveCommand", ["ALIVE_fnc_garrison","spawn",[_guardRadius,"true",[0,0,0],"",_guardProbabilityCount, _guardPatrolPercentage]]] call ALIVE_fnc_profileEntity;
                            };
                        } forEach _guards;
                        _countProfiles = _countProfiles + count _guards;
                     };
                    };

                    // Add profiles
                    if(_totalCount < _groupCount) then {

                        // If there are several profiles per cluster place several profiles
                        if(_groupPerCluster > 0) then {

                            for "_i" from 0 to _groupPerCluster -1 do {
                                private ["_command","_radius","_position","_garrisonPos"];

                                _group = _groups select _totalCount;

                                private _isVehicle = (_totalCount < _infantryGroupStart);
                                private _isInfantry = (_totalCount >= _infantryGroupStart) && (_totalCount < _infantryGroupEnd);
                                // Try to extract vehicle class only when this
                                // group is past the vehicle-active quota. If
                                // extraction succeeds we route to vehicle
                                // reserve; otherwise the group falls through
                                // to active placement.
                                private _vehicleReserveClass = "";
                                if (_isVehicle && {_vehicleActivePlacedCount >= _vehicleActiveCount}) then {
                                    _vehicleReserveClass = [_group, _faction] call _fnc_getGroupVehicleClass;
                                };
                                private _isVehicleReserve = _vehicleReserveClass != "";
                                private _isInfantryReserve = _isInfantry && {_infantryActivePlacedCount >= _infantryActiveCount};
                                private _isReserve = _isVehicleReserve || _isInfantryReserve;

                                if (_isReserve) then {
                                    private _reservePool = [_x, "reservePool"] call ALiVE_fnc_hashGet;
                                    if (_isVehicleReserve) then {
                                        // VEHICLE RESERVE - create empty vehicle
                                        // profile + matching empty entity profile
                                        // at a parking position near the cluster.
                                        // Crew config (the original group class)
                                        // gets held in the pool and added to the
                                        // entity at activation time.
                                        // Cluster-aware parking lookup via the
                                        // helper above - road > field > flat >
                                        // random fallback chain.
                                        private _t0 = diag_tickTime;
                                        private _parking = [_vehicleReserveClass, _center, _size] call _fnc_findVehicleParkingPos;
                                        private _vehiclePos = _parking select 0;
                                        private _vehicleDir = _parking select 1;
                                        if (surfaceIsWater _vehiclePos) then {
                                            _vehiclePos = _center getPos [50, random 360];
                                        };
                                        // Always logged - placement-time only fires
                                        // briefly during INIT and the volume is bounded
                                        // by group count. Lets diagnostics survive
                                        // missions where the debug flag isn't set
                                        // before module dispatch (init.sqf timing on
                                        // some MP setups runs after ALiVE postInit).
                                        diag_log format ["[ALiVE Reserve DEBUG] M-VEHICLE-RESERVE faction=%1 totalCount=%2 group=%3 class=%4 pos=%5 elapsed=%6ms", _faction, _totalCount, _group, _vehicleReserveClass, _vehiclePos, round ((diag_tickTime - _t0) * 1000)];
                                        private _emptyProfiles = [_vehicleReserveClass, _side, _faction, _vehiclePos, _vehicleDir, false, _faction] call ALIVE_fnc_createProfilesUnCrewedVehicle;
                                        private _profileEntity = _emptyProfiles select 0;
                                        private _profileVehicle = _emptyProfiles select 1;
                                        // Patch entity metadata to match what
                                        // createProfilesFromGroupConfig would
                                        // have set, so OPCOM / mil_intel /
                                        // damage-output classify correctly
                                        // once activation flips busy off.
                                        [_profileEntity, "objectType", _group] call ALIVE_fnc_profileEntity;
                                        [_profileEntity, "aiBehaviour", "STEALTH"] call ALIVE_fnc_profileEntity;
                                        [_profileEntity, "onEachSpawn", _onEachSpawn] call ALIVE_fnc_profileEntity;
                                        [_profileEntity, "onEachSpawnOnce", _onEachSpawnOnce] call ALIVE_fnc_profileEntity;
                                        // OPCOM exclusion - cleared on activation.
                                        [_profileEntity, "busy", true] call ALIVE_fnc_profileEntity;
                                        [_profileVehicle, "busy", true] call ALIVE_fnc_profileVehicle;
                                        // Cluster home + lock-preference flag
                                        // (read at activation to decide whether
                                        // to lock the materialised vehicle).
                                        [_profileEntity, "homeCluster", _cluster] call ALiVE_fnc_HashSet;
                                        [_profileVehicle, "ALiVE_reserveLocked", _vehicleEmptyLocked] call ALiVE_fnc_HashSet;
                                        // Pool entry shape: type discriminator
                                        // at index 0 lets activation dispatch
                                        // on group identity. Store profile IDs
                                        // (strings) not profile array references
                                        // - the entity has homeCluster=_cluster
                                        // and the cluster has reservePool, so
                                        // pushing the array reference would
                                        // form a cycle (Recursive array error).
                                        private _vehicleProfileID = [_profileVehicle, "profileID"] call ALiVE_fnc_hashGet;
                                        private _entityProfileID = [_profileEntity, "profileID"] call ALiVE_fnc_hashGet;
                                        _reservePool pushBack ["VEHICLE", _group, _vehicleProfileID, _entityProfileID, _faction, _onEachSpawn, _onEachSpawnOnce];
                                        _countProfiles = _countProfiles + 2;
                                    } else {
                                        // INFANTRY RESERVE - hold the group config
                                        // for activation. No profile created yet.
                                        _reservePool pushBack ["INFANTRY", _group, _faction, _onEachSpawn, _onEachSpawnOnce];
                                    };
                                    [_x, "reservePool", _reservePool] call ALiVE_fnc_hashSet;
                                    _totalCount = _totalCount + 1;
                                } else {
                                    // Vehicle groups always patrol (ambientMovement
                                    // takes them onto the road network); only
                                    // infantry groups participate in the garrison
                                    // budget. _garrisonCount is sized against
                                    // infantry active count so the patrol
                                    // percentage is the infantry-on-patrol fraction.
                                    if (_isVehicle) then {
                                        _command = "ALIVE_fnc_ambientMovement";
                                        _radius = [_guardRadius,"SAFE",[0,0,0]];
                                    } else {
                                        if (_infantryActivePlacedCount < _garrisonCount) then {
                                            _command = "ALIVE_fnc_garrison";
                                            _garrisonPos = [_center, 50] call CBA_fnc_RandPos;
                                            _radius = [_guardRadius,"true",[0,0,0],"",_guardProbabilityCount, _guardPatrolPercentage];
                                        } else {
                                            _command = "ALIVE_fnc_ambientMovement";
                                            _radius = [_guardRadius,"SAFE",[0,0,0]];

                                            // DEBUG -------------------------------------------------------------------------------------
                                            if(_debug) then {
                                                ["MP %2 - No more empty buildings (MP-01), lets patrol! calling ALIVE_fnc_ambientMovement, _guardRadius: %1", _guardRadius, _faction] call ALiVE_fnc_dump;
                                            };
                                            // DEBUG -------------------------------------------------------------------------------------
                                        };
                                    };

                                    if (isnil "_garrisonPos") then {
                                        _position = (_center getPos [((_size / 2) + (random 500)), (random 360)]);
                                    } else {
                                        _position = [_garrisonPos, 50] call CBA_fnc_RandPos;
                                    };
                                    // For vehicle groups, route to a road-
                                    // validated parking spot via the cluster-
                                    // aware helper. Infantry keeps the random-
                                    // in-cluster pos (forest is fine for foot
                                    // troops; AI navigation handles trees).
                                    private _activeDir = random 360;
                                    private _activeT0 = diag_tickTime;
                                    private _activeVehClass = "";
                                    if (_isVehicle) then {
                                        _activeVehClass = [_group, _faction] call _fnc_getGroupVehicleClass;
                                        if (_activeVehClass != "") then {
                                            private _parking = [_activeVehClass, _center, _size] call _fnc_findVehicleParkingPos;
                                            _position = _parking select 0;
                                            _activeDir = _parking select 1;
                                        };
                                    };

                                    if!(surfaceIsWater _position) then {
                                        _profiles = [_group, _position, _activeDir, true, _faction, false, false, "STEALTH", _onEachSpawn, _onEachSpawnOnce] call ALIVE_fnc_createProfilesFromGroupConfig;

                                        if (_isVehicle) then {
                                            diag_log format ["[ALiVE Reserve DEBUG] M-VEHICLE-ACTIVE faction=%1 totalCount=%2 group=%3 class=%4 pos=%5 elapsed=%6ms", _faction, _totalCount, _group, _activeVehClass, _position, round ((diag_tickTime - _activeT0) * 1000)];
                                        };

                                        // Garrison & Patrols instead of the static garrison.
                                        {
                                            if (([_x,"type"] call ALiVE_fnc_HashGet) == "entity") then {
                                                [_x, "setActiveCommand", [_command,"spawn",_radius]] call ALIVE_fnc_profileEntity;
                                                // Tag profile with home cluster + register in
                                                // cluster's active list so the activation PFH
                                                // can detect attrition. Profile-killed events
                                                // remove the profile from ALiVE_profileHandler
                                                // so the alive-count check picks it up.
                                                [_x, "homeCluster", _cluster] call ALiVE_fnc_HashSet;
                                                private _profileID = [_x, "profileID"] call ALiVE_fnc_HashGet;
                                                private _activeIDs = [_cluster, "activeProfileIDs"] call ALiVE_fnc_HashGet;
                                                _activeIDs pushBack _profileID;
                                                [_cluster, "activeProfileIDs", _activeIDs] call ALiVE_fnc_HashSet;
                                            };
                                            // Tag every vehicle profile with the lock
                                            // flag too, so the spawn-time gate in
                                            // profileVehicle locks any empty m_11
                                            // vehicle (active + reserve). Crew AI
                                            // mounts with moveInDriver/moveInGunner
                                            // which bypasses lock 2; players can't
                                            // hop in commandeer-style.
                                            if (([_x,"type"] call ALiVE_fnc_HashGet) == "vehicle") then {
                                                [_x, "ALiVE_reserveLocked", _vehicleEmptyLocked] call ALiVE_fnc_HashSet;
                                            };
                                        } foreach _profiles;

                                        _countProfiles = _countProfiles + count _profiles;
                                        _totalCount = _totalCount + 1;
                                        _activePlacedCount = _activePlacedCount + 1;
                                        if (_isInfantry) then { _infantryActivePlacedCount = _infantryActivePlacedCount + 1 };
                                        if (_isVehicle) then { _vehicleActivePlacedCount = _vehicleActivePlacedCount + 1 };

                                        // Track active count per cluster for
                                        // the reserve activation threshold.
                                        private _spawned = [_x, "reserveActiveAtSpawn"] call ALiVE_fnc_hashGet;
                                        [_x, "reserveActiveAtSpawn", _spawned + 1] call ALiVE_fnc_hashSet;
                                    };
                                };
                            };

                        // If there is only one to be placed, then place only one
                        } else {
                            private ["_command","_radius","_position","_garrisonPos"];

                            _group = _groups select _totalCount;

                            private _isVehicle = (_totalCount < _infantryGroupStart);
                            private _isInfantry = (_totalCount >= _infantryGroupStart) && (_totalCount < _infantryGroupEnd);
                            private _vehicleReserveClass = "";
                            if (_isVehicle && {_vehicleActivePlacedCount >= _vehicleActiveCount}) then {
                                _vehicleReserveClass = [_group, _faction] call _fnc_getGroupVehicleClass;
                            };
                            private _isVehicleReserve = _vehicleReserveClass != "";
                            private _isInfantryReserve = _isInfantry && {_infantryActivePlacedCount >= _infantryActiveCount};
                            private _isReserve = _isVehicleReserve || _isInfantryReserve;

                            if (_isReserve) then {
                                private _reservePool = [_x, "reservePool"] call ALiVE_fnc_hashGet;
                                if (_isVehicleReserve) then {
                                    // Cluster-aware parking lookup - matches
                                    // the multi-group branch above.
                                    private _t0 = diag_tickTime;
                                    private _parking = [_vehicleReserveClass, _center, _size] call _fnc_findVehicleParkingPos;
                                    private _vehiclePos = _parking select 0;
                                    private _vehicleDir = _parking select 1;
                                    if (surfaceIsWater _vehiclePos) then {
                                        _vehiclePos = _center getPos [50, random 360];
                                    };
                                    diag_log format ["[ALiVE Reserve DEBUG] S-VEHICLE-RESERVE faction=%1 totalCount=%2 group=%3 class=%4 pos=%5 elapsed=%6ms", _faction, _totalCount, _group, _vehicleReserveClass, _vehiclePos, round ((diag_tickTime - _t0) * 1000)];
                                    private _emptyProfiles = [_vehicleReserveClass, _side, _faction, _vehiclePos, _vehicleDir, false, _faction] call ALIVE_fnc_createProfilesUnCrewedVehicle;
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
                                    // Profile IDs (strings), not refs - see
                                    // multi-group branch above for the
                                    // recursive-array cycle rationale.
                                    private _vehicleProfileID = [_profileVehicle, "profileID"] call ALiVE_fnc_hashGet;
                                    private _entityProfileID = [_profileEntity, "profileID"] call ALiVE_fnc_hashGet;
                                    _reservePool pushBack ["VEHICLE", _group, _vehicleProfileID, _entityProfileID, _faction, _onEachSpawn, _onEachSpawnOnce];
                                    _countProfiles = _countProfiles + 2;
                                } else {
                                    _reservePool pushBack ["INFANTRY", _group, _faction, _onEachSpawn, _onEachSpawnOnce];
                                };
                                [_x, "reservePool", _reservePool] call ALiVE_fnc_hashSet;
                                _totalCount = _totalCount + 1;
                            } else {
                                // Vehicle groups always patrol; only infantry
                                // groups use the garrison fork (matches the
                                // multi-group branch above).
                                if (_isVehicle) then {
                                    _command = "ALIVE_fnc_ambientMovement";
                                    _radius = [_guardRadius,"SAFE",[0,0,0]];
                                } else {
                                    if (_infantryActivePlacedCount < _garrisonCount) then {
                                        _command = "ALIVE_fnc_garrison";
                                        _garrisonPos = [_center, 50] call CBA_fnc_RandPos;
                                        _radius = [_guardRadius,"true",[0,0,0],"",_guardProbabilityCount, _guardPatrolPercentage];
                                    } else {
                                        _command = "ALIVE_fnc_ambientMovement";
                                        _radius = [_guardRadius,"SAFE",[0,0,0]];

                                        // DEBUG -------------------------------------------------------------------------------------
                                        if(_debug) then {
                                            ["MP %2 - No more empty buildings (MP-02), lets patrol! calling ALIVE_fnc_ambientMovement, _guardRadius: %1", _guardRadius, _faction] call ALiVE_fnc_dump;
                                        };
                                        // DEBUG -------------------------------------------------------------------------------------
                                    };
                                };

                                if (isnil "_garrisonPos") then {
                                    _position = (_center getPos [(_size + (random 500)), (random 360)]);
                                } else {
                                    _position = [_garrisonPos, 50] call CBA_fnc_RandPos;
                                };
                                // Vehicle group - route to a road-validated
                                // parking spot. Matches the multi-group branch.
                                private _activeDir = random 360;
                                private _activeT0 = diag_tickTime;
                                private _activeVehClass = "";
                                if (_isVehicle) then {
                                    _activeVehClass = [_group, _faction] call _fnc_getGroupVehicleClass;
                                    if (_activeVehClass != "") then {
                                        private _parking = [_activeVehClass, _center, _size] call _fnc_findVehicleParkingPos;
                                        _position = _parking select 0;
                                        _activeDir = _parking select 1;
                                    };
                                };

                                if!(surfaceIsWater _position) then {
                                    _profiles = [_group, _position, _activeDir, true, _faction, false, false, "STEALTH", _onEachSpawn, _onEachSpawnOnce] call ALIVE_fnc_createProfilesFromGroupConfig;

                                    if (_isVehicle) then {
                                        diag_log format ["[ALiVE Reserve DEBUG] S-VEHICLE-ACTIVE faction=%1 totalCount=%2 group=%3 class=%4 pos=%5 elapsed=%6ms", _faction, _totalCount, _group, _activeVehClass, _position, round ((diag_tickTime - _activeT0) * 1000)];
                                    };

                                    // Garrison & Patrols instead of the static garrison.
                                    {
                                        if (([_x,"type"] call ALiVE_fnc_HashGet) == "entity") then {
                                            [_x, "setActiveCommand", [_command,"spawn",_radius]] call ALIVE_fnc_profileEntity;
                                            // Tag + register on cluster (matches the
                                            // multi-group branch above).
                                            [_x, "homeCluster", _cluster] call ALiVE_fnc_HashSet;
                                            private _profileID = [_x, "profileID"] call ALiVE_fnc_HashGet;
                                            private _activeIDs = [_cluster, "activeProfileIDs"] call ALiVE_fnc_HashGet;
                                            _activeIDs pushBack _profileID;
                                            [_cluster, "activeProfileIDs", _activeIDs] call ALiVE_fnc_HashSet;
                                        };
                                        // Tag vehicle profiles with the lock flag
                                        // (matches the multi-group branch above).
                                        if (([_x,"type"] call ALiVE_fnc_HashGet) == "vehicle") then {
                                            [_x, "ALiVE_reserveLocked", _vehicleEmptyLocked] call ALiVE_fnc_HashSet;
                                        };
                                    } foreach _profiles;

                                    _countProfiles = _countProfiles + count _profiles;
                                    _totalCount = _totalCount + 1;
                                    _activePlacedCount = _activePlacedCount + 1;
                                    if (_isInfantry) then { _infantryActivePlacedCount = _infantryActivePlacedCount + 1 };
                                    if (_isVehicle) then { _vehicleActivePlacedCount = _vehicleActivePlacedCount + 1 };

                                    // Track active count per cluster for
                                    // the reserve activation threshold.
                                    private _spawned = [_x, "reserveActiveAtSpawn"] call ALiVE_fnc_hashGet;
                                    [_x, "reserveActiveAtSpawn", _spawned + 1] call ALiVE_fnc_hashSet;
                                };
                            };
                        };
                    };
                } forEach _clusters;

                // Start the reserve-activation watcher. Iterates every
                // cluster every 5 s; each call to fnc_activateReserve
                // checks its own threshold + cooldown + player-presence
                // gates and decides whether to wake one reserve. PFH
                // self-terminates if the module logic becomes null
                // (e.g. mission load context teardown).
                private _totalReserves = 0;
                private _clustersWithReserves = 0;
                private _totalVehicleReserves = 0;
                private _totalInfantryReserves = 0;
                {
                    private _pool = [_x, "reservePool", []] call ALiVE_fnc_hashGet;
                    private _poolCount = count _pool;
                    if (_poolCount > 0) then {
                        _totalReserves = _totalReserves + _poolCount;
                        _clustersWithReserves = _clustersWithReserves + 1;
                        // Count by type for diagnostic visibility.
                        {
                            private _entryType = if (count _x > 0 && {(_x select 0) isEqualType ""}) then {
                                _x select 0
                            } else { "INFANTRY" };
                            if (_entryType == "VEHICLE") then {
                                _totalVehicleReserves = _totalVehicleReserves + 1;
                            } else {
                                _totalInfantryReserves = _totalInfantryReserves + 1;
                            };
                        } forEach _pool;
                    };
                } forEach _clusters;
                private _hasReserves = _totalReserves > 0;

                if (!isNil "ALiVE_vehicleSpawn_debug" && {ALiVE_vehicleSpawn_debug}) then {
                    diag_log format ["[ALiVE Reserve DEBUG] PLACEMENT-SUMMARY faction=%1 totalClusters=%2 clustersWithReserves=%3 totalReserves=%4 (vehicle=%5 infantry=%6) readinessLevel=%7 activePatrolPercent=%8 infantryRange=[%9..%10) totalGroups=%11 PFH=%12",
                        _faction, count _clusters, _clustersWithReserves, _totalReserves,
                        _totalVehicleReserves, _totalInfantryReserves,
                        _readinessLevel, _activePatrolPercent,
                        _infantryGroupStart, _infantryGroupEnd, _groupCount,
                        if (_hasReserves) then {"started"} else {"skipped"}];
                };

                if (_hasReserves) then {
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

            } else {
                // Differentiate "specialised faction with categories outside
                // mil_placement's lookup" from "actually faulty faction".
                // sys_factioncompiler synthesises specialised factions like
                // BLUFOR_AIR / OPFOR_AIR / IND_AIR that hold Air groups only;
                // they're working as designed but the four-category sweep
                // above (Motorized_MTP / Infantry / SpecOps / Air-when-
                // placeHelis) returns empty when _placeHelis is false on the
                // calling placement instance. Log informationally rather
                // than warn-with-may-be-faulty so the RPT signal stays
                // meaningful for genuinely-faulty factions.
                private _hasAir = !((["Air", _faction] call ALIVE_fnc_configGetRandomGroup) isEqualTo "FALSE");
                if (_hasAir) then {
                    ["MP - faction (%1) has Air groups only; skipping placement (placeHelis disabled or no Air slots requested for this placement instance).", _faction] call ALiVE_fnc_dump;
                } else {
                    ["MP - Warning no usable groups found to use, the faction (%1) may be faulty.", _faction] call ALiVE_fnc_dumpR;
                };
            };

            ["MP %2 - Total profiles created: %1",_countProfiles, _faction] call ALiVE_fnc_dump;

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                //["MP - Total profiles created: %1",_countProfiles] call ALiVE_fnc_dump;
                ["MP - Placement completed"] call ALiVE_fnc_dump;
                [] call ALIVE_fnc_timer;
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------

            // set module as started
            _logic setVariable ["startupComplete", true];

        };
    };
};

TRACE_1("MP - output",_result);
_result;
