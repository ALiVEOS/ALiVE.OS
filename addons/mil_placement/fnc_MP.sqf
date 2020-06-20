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
[_logic, "faction", "OPF_F"] call ALiVE_fnc_MP;

See Also:
- <ALIVE_fnc_MPInit>

Author:
Wolffy
ARJay
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_MP
#define MTEMPLATE "ALiVE_MP_%1"
#define DEFAULT_SIZE "100"
#define DEFAULT_TYPE QUOTE(RANDOM)
#define DEFAULT_FACTION QUOTE(OPF_F)
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
#define DEFAULT_AMBIENT_GUARD_AMOUNT "1"
#define DEFAULT_HQ_BUILDING objNull
#define DEFAULT_HQ_CLUSTER []
#define DEFAULT_NO_TEXT ""
#define DEFAULT_READINESS_LEVEL "1"
#define DEFAULT_RANDOMCAMPS "0"

private ["_logic","_operation","_args","_result"];

TRACE_1("MP - input",_this);

_logic = [_this, 0, objNull, [objNull]] call BIS_fnc_param;
_operation = [_this, 1, "", [""]] call BIS_fnc_param;
_args = [_this, 2, objNull, [objNull,[],"",0,true,false]] call BIS_fnc_param;
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
    };
    // Return the Ambient Vehicle Amount
    case "ambientVehicleAmount": {
        _result = [_logic,_operation,_args,DEFAULT_AMBIENT_VEHICLE_AMOUNT] call ALIVE_fnc_OOsimpleOperation;
    };
    case "guardProbability": {
        _result = [_logic,_operation,_args,DEFAULT_AMBIENT_GUARD_AMOUNT] call ALIVE_fnc_OOsimpleOperation;
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

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                ["ALIVE MP - Startup"] call ALIVE_fnc_dump;
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
                    ["ALIVE MP - Startup completed"] call ALIVE_fnc_dump;
                    ["ALIVE MP - Count clusters %1",count _clusters] call ALIVE_fnc_dump;
                    ["ALIVE MP - Count land clusters %1",count _landClusters] call ALIVE_fnc_dump;
                    ["ALIVE MP - Count air clusters %1",count _airClusters] call ALIVE_fnc_dump;
                    ["ALIVE MP - Count heli clusters %1",count _heliClusters] call ALIVE_fnc_dump;
                    [] call ALIVE_fnc_timer;
                };
                // DEBUG -------------------------------------------------------------------------------------

                if(_placement) then {

                    if(count _clusters > 0) then {
                        // start placement
                        [_logic, "placement"] call MAINCLASS;
                    }else{
                        ["ALIVE MP [%1] - Warning no locations found for placement, you need to include military locations within the TAOR marker: %2",_faction, _taor] call ALIVE_fnc_dumpR;

                        // set module as started
                        _logic setVariable ["startupComplete", true];
                    };

                }else{

                    // DEBUG -------------------------------------------------------------------------------------
                    if(_debug) then { ["ALIVE MP - Objectives Only"] call ALIVE_fnc_dump; };
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
                ["ALIVE MP - Placement"] call ALIVE_fnc_dump;
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

            private _guardProbability = parseNumber([_logic, "guardProbability"] call MAINCLASS);

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
                ["ALIVE MP [%1] - Size: %2 Type: %3 SideNum: %4 Side: %5 Faction: %6",_faction,_size,_type,_factionSideNumber,_side,_faction] call ALIVE_fnc_dump;
                ["ALIVE MP [%1] - Ambient Vehicles: %2 Create HQ: %3 Create Field HQ: %4 Place Helis: %5 Place Supplies: %6",_faction,_ambientVehicleAmount,_createHQ,_createFieldHQ,_placeHelis,_placeSupplies] call ALIVE_fnc_dump;
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
	                                [_x, "setActiveCommand", ["ALIVE_fnc_garrison","spawn",[50,"false",[0,0,0]]]] call ALIVE_fnc_profileEntity;
	                            };
	                        } foreach _profiles;
                         };

                        [_logic, "HQBuilding", _hqBuilding] call MAINCLASS;

                        ["ALIVE MP - HQ building selected: %1",[_logic, "HQBuilding"] call MAINCLASS] call ALIVE_fnc_dump;
                    } else {
                        ["ALIVE MP - Warning no HQ locations found"] call ALIVE_fnc_dump;
                    }
                } else {
                    ["ALIVE MP - Warning no HQ locations found"] call ALIVE_fnc_dump;
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
                                [_x, "setActiveCommand", ["ALIVE_fnc_garrison","spawn",[50,"false",[0,0,0]]]] call ALIVE_fnc_profileEntity;
                            };
                        } foreach _profiles;
                    };

                    // DEBUG -------------------------------------------------------------------------------------
                    if(_debug) then {
                        [_flatPos, 4] call ALIVE_fnc_placeDebugMarker;

                        ["ALIVE MP - Field HQ created: %1 - %2", configName _HQ, [_logic, "FieldHQBuilding"] call MAINCLASS] call ALIVE_fnc_dump;
                    };
                    // DEBUG -------------------------------------------------------------------------------------
                } else {
                    ["ALIVE MP - Warning no Field HQ locations found"] call ALIVE_fnc_dump;
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
                _supplyClasses = [ALIVE_factionDefaultSupplies,_faction,[]] call ALIVE_fnc_hashGet;

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
                ["ALIVE MP [%1] - Supplies placed: %2",_faction,_countSupplies] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            if(ALIVE_loadProfilesPersistent) exitWith {

                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then { ["ALIVE MP - Profiles are persistent, no creation of profiles"] call ALIVE_fnc_dump; };
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
                            // Check node does not have a helicopter placed already
                            private _nearbyObj = nearestObjects [position _x, ["Helicopter"], 20];
                            private _nearbyProfiles = [position _x, 20, [_side,"vehicle","Helicopter"]] call ALIVE_fnc_getNearProfiles;
                            if (count _nearbyObj == 0 && count _nearbyProfiles == 0) then {

                                if (_x isKindOf "HeliH") then {
                                    _position = position _x;
                                    _direction = direction _x;
                                } else {
                                    _helipad = nearestObject [position _x, "HeliH"];

                                    if !(isnull _helipad) then {
                                        //Helipad can be detected
    		                            _position = position _helipad;
    	                                _direction = direction _helipad;
                                    } else {
                                        // Helipad is a built in object or misses config parents
                                        _position = position _x;
                                        _direction = direction _x;

                                        //_helipad = createVehicle ["Land_HelipadEmpty_F", _position, [], 0, "CAN_COLLIDE"];
                                        //_helipad setdir _direction;
                                    };
                                };

                                _vehicleClass = (selectRandom _heliClasses);

                                if !(_position isEqualTo [0,0,0]) then {

    	                            if(random 1 > 0.8) then {
    	                                [_vehicleClass,_side,_faction,_position,_direction,false,_faction] call ALIVE_fnc_createProfileVehicle;

    	                                _countProfiles = _countProfiles + 1;
    	                                _countUncrewedHelis =_countUncrewedHelis + 1;
    	                            }else{
    	                                [_vehicleClass,_side,_faction,"CAPTAIN",_position,_direction,false,_faction] call ALIVE_fnc_createProfilesCrewedVehicle;

    	                                _countProfiles = _countProfiles + 2;
    	                                _countCrewedHelis = _countCrewedHelis + 1;
    	                            };
                                };
                            };
                        } forEach _nodes;
                    } forEach _heliClusters;
                };
            };

            // TODO if placehelis is true, but no helis placed - create heliports

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["ALIVE MP [%1] - Heli units placed: crewed:%2 uncrewed:%3",_faction,_countCrewedHelis,_countUncrewedHelis] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            // Spawn air units in hangars

            private ["_countCrewedAir","_countUncrewedAir"];
            _countCrewedAir = 0;
            _countUncrewedAir = 0;

            if(_placeHelis) then {

                _airClasses = [0,_faction,"Plane"] call ALiVE_fnc_findVehicleType;
                _airClasses = _airClasses - ALiVE_PLACEMENT_VEHICLEBLACKLIST;

                if(count _airClasses == 0) then {
                    _airClasses = _airClasses + _heliClasses;
                };

                if(count _airClasses > 0) then {

                    {
                        _nodes = [_x, "nodes"] call ALIVE_fnc_hashGet;

                        _buildings = [_nodes, ALIVE_airBuildingTypes] call ALIVE_fnc_findBuildingsInClusterNodes;

                        //[_x, "debug", true] call ALIVE_fnc_cluster;
                        {
                            if(random 1 > 0.3) then {

                                // Choose an aircraft
                                _vehicleClass = (selectRandom _airClasses);
                                private _position = position _x;

                                // Check aircraft can fit in hangar
                                private _large = false;
                                private _hangarSize = _x call BIS_fnc_boundingBoxDimensions;
                                private _aircraftSize = sizeOf _vehicleClass;
                                if (_aircraftSize > 0) then {
                                    _large = (_hangarSize select 0 < _aircraftSize) || (_hangarSize select 1 < _aircraftSize);
                                } else {
                                    private _tmpVehicle = _vehicleClass createVehicle [0,0,5000];
                                    _aircraftSize = sizeOf _vehicleClass;
                                    deleteVehicle _tmpVehicle;
                                    _large = (_hangarSize select 0 < _aircraftSize) || (_hangarSize select 1 < _aircraftSize);
                                };

                                if (!_large && {_aircraftSize > 39}) then {
                                    _large = true;
                                };

                                // Find safe place to put aircraft
                                private ["_pavement","_runway"];
                                if ( ([tolower(typeOf _x), "hangar"] call CBA_fnc_find != -1) && !_large) then {
                                    _direction = direction _x;
                                } else { // find a taxiway
                                    _runway = [];
                                    {
                                        if (([str(_x),"taxiway"] call CBA_fnc_find != -1 && typeof _x == "")) then {
                                            _runway pushback _x;
                                        };
                                    } foreach (nearestObjects [position _x, [], 100]);
                                    if (count _runway > 0) then {
                                        // diag_log format["Cannot find hangar, choosing safe taxiway from: %1", _runway];

                                        _pavement = selectRandom _runway;
                                        _position = [_pavement, 0, _aircraftSize * 3, _aircraftSize * 1.2, 0, 0.065, 0, [], [position _pavement, position _pavement]] call BIS_fnc_findSafePos;

                                        _direction = direction _pavement;
                                    } else {
                                        // Find safe place near by
                                        // diag_log format["Cannot find hangar or taxiway, looking for safe place to put aircraft %1", _x];
                                        _position = [position _x, 25, 200, _aircraftSize, 0, 0.2, 0] call BIS_fnc_findSafePos;
                                        _direction = direction _x;
                                    };
                                };

                                // Check node does not have a planes placed already
                                private _nearbyObj = nearestObjects [_position, ["Plane"], _aircraftSize];
                                private _nearbyProfiles = [_position, _aircraftSize, [_side,"vehicle","Plane"]] call ALIVE_fnc_getNearProfiles;
                                if (count _nearbyObj == 0 && count _nearbyProfiles == 0) then {
                                    // Place Aircraft

                                    //if (random 1 > 1) then {
                                        [_vehicleClass,_side,_faction,_position,_direction,false,_faction] call ALIVE_fnc_createProfileVehicle;
                                        _countProfiles = _countProfiles + 1;
                                        _countUncrewedAir =_countUncrewedAir + 1;
                                    /*} else {
                                        [_vehicleClass,_side,_faction,"CAPTAIN",_position,_direction,false,_faction,false,true] call ALIVE_fnc_createProfilesCrewedVehicle;
                                        _countProfiles = _countProfiles + 2;
                                        _countCrewedAir = _countCrewedAir + 1;
                                    };*/
                                };
                            };

                        } forEach _buildings;
                    } forEach _airClusters;
                };
            };


            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["ALIVE MP [%1] - Air units placed: crewed:%2 uncrewed:%3",_faction,_countCrewedAir,_countUncrewedAir] call ALIVE_fnc_dump;
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

                _supportClasses = [ALIVE_factionDefaultSupports,_faction,[]] call ALIVE_fnc_hashGet;

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

                                _parkingPosition = [_vehicleClass,_building] call ALIVE_fnc_getParkingPosition;

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
                ["ALIVE MP [%1] - Ambient land units placed: %2",_faction,_countLandUnits] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            // Spawn the main force

            private ["_countArmored","_countMechanized","_countMotorized","_countInfantry",
            "_countAir","_countSpecOps","_groups","_motorizedGroups","_infantryGroups","_group","_groupPerCluster","_totalCount","_center","_size","_position",
            "_groupCount","_clusterCount"];

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["ALIVE MP [%1] - Size: %2",_faction,_size] call ALIVE_fnc_dump;
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
                ["ALIVE MP [%1] - TYPE: %2", _faction, _type] call ALiVE_fnc_dump;
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


            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["ALIVE MP [%1] - Main force creation ",_faction] call ALIVE_fnc_dump;
                ["Count Armor: %1",_countArmored] call ALIVE_fnc_dump;
                ["Count Mech: %1",_countMechanized] call ALIVE_fnc_dump;
                ["Count Motor: %1",_countMotorized] call ALIVE_fnc_dump;
                ["Count Air: %1",_countAir] call ALIVE_fnc_dump;
                ["Count Infantry: %1",_countInfantry] call ALIVE_fnc_dump;
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

            _groups = _groups + _infantryGroups;

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

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["ALIVE MP [%1] - Groups ",_groups] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            // Position and create groups
            _groupCount = count _groups;
            _clusterCount = count _clusters;
            _groupPerCluster = floor(_groupCount / _clusterCount);
            _totalCount = 0;

            if(_groupCount > 0) then {
                _readiness = parseNumber([_logic, "readinessLevel"] call MAINCLASS);
                _readiness = (1 - _readiness) * _groupCount;

                {
                    private ["_guardGroup","_guards","_center","_size","_profiles"];

                    _center = [_x, "center"] call ALIVE_fnc_hashGet;
                    _size = [_x, "size"] call ALIVE_fnc_hashGet;

                    //Default guards (place always)
                    if(count _infantryGroups > 0 && random(1) < _guardProbability) then {

                        _guardGroup = (selectRandom _infantryGroups);
                        _guards = [_guardGroup, _center, random(360), true, _faction] call ALIVE_fnc_createProfilesFromGroupConfig;
                        // ["ALIVE MP [%2] - Placing Guards - %1",_guardGroup, _guardProbability] call ALIVE_fnc_dump;
                        //ARJay, here we could place the default patrols/garrisons instead of the static garrisson if you like to (same is in CIV MP)
                        {
                            if (([_x,"type"] call ALiVE_fnc_HashGet) == "entity") then {
                                [_x, "setActiveCommand", ["ALIVE_fnc_garrison","spawn",[200,"true",[0,0,0]]]] call ALIVE_fnc_profileEntity;
                            };
                        } foreach _guards;
                    };

                    //Add profiles
                    if(_totalCount < _groupCount) then {

                        //If there are several profiles per cluster place several profiles
                        if(_groupPerCluster > 0) then {

                            for "_i" from 0 to _groupPerCluster -1 do {
                                private ["_command","_radius","_position","_garrisonPos"];

                                _group = _groups select _totalCount;

                                if (_totalCount < _readiness ) then {
                                    _command = "ALIVE_fnc_garrison";
                                    _garrisonPos = [_center, 50] call CBA_fnc_RandPos;
                                    _radius = [200,"true",[0,0,0]];
                                } else {
                                    _command = "ALIVE_fnc_ambientMovement";
                                    _radius = [200,"SAFE",[0,0,0]];
                                };

                                if (isnil "_garrisonPos") then {
                                    _position = (_center getPos [((_size / 2) + (random 500)), (random 360)]);
                                } else {
                                    _position = [_garrisonPos, 50] call CBA_fnc_RandPos;
                                };

                                if!(surfaceIsWater _position) then {
                                    _profiles = [_group, _position, random(360), true, _faction] call ALIVE_fnc_createProfilesFromGroupConfig;

                                    //ARJay, here we could place the default "Chill around campfire situation" instead of the static garrisson if you like to
                                    {
                                        if (([_x,"type"] call ALiVE_fnc_HashGet) == "entity") then {
                                            [_x, "setActiveCommand", [_command,"spawn",_radius]] call ALIVE_fnc_profileEntity;
                                        };
                                    } foreach _profiles;

                                    _countProfiles = _countProfiles + count _profiles;
                                    _totalCount = _totalCount + 1;
                                };
                            };

                        //If there is only one to be placed, then place only one
                        }else{
                            private ["_command","_radius","_position","_garrisonPos"];

                            _group = _groups select _totalCount;

                            if (_totalCount < _readiness ) then {
                                _command = "ALIVE_fnc_garrison";
                                _garrisonPos = [_center, 50] call CBA_fnc_RandPos;
                                _radius = [200,"true",[0,0,0]];
                            } else {
                                _command = "ALIVE_fnc_ambientMovement";
                                _radius = [200,"SAFE",[0,0,0]];
                            };

                            if (isnil "_garrisonPos") then {
                                _position = (_center getPos [(_size + (random 500)), (random 360)]);
                            } else {
                                _position = [_garrisonPos, 50] call CBA_fnc_RandPos;
                            };

                            if!(surfaceIsWater _position) then {
                                _profiles = [_group, _position, random(360), true, _faction] call ALIVE_fnc_createProfilesFromGroupConfig;

                                //ARJay, here we could place the default "Chill around campfire situation" instead of the static garrisson if you like to
                                {
                                    if (([_x,"type"] call ALiVE_fnc_HashGet) == "entity") then {
                                        [_x, "setActiveCommand", [_command,"spawn",_radius]] call ALIVE_fnc_profileEntity;
                                    };
                                } foreach _profiles;

                                _countProfiles = _countProfiles + count _profiles;
                                _totalCount = _totalCount + 1;
                            };
                        };
                    };
                } forEach _clusters;

            }else{
                ["ALIVE MP - Warning no usable groups found to use, the faction (%1) may be faulty.", _faction] call ALIVE_fnc_dumpR;
            };

            ["ALIVE MP %2 - Total profiles created: %1",_countProfiles, _faction] call ALIVE_fnc_dump;

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                //["ALIVE MP - Total profiles created: %1",_countProfiles] call ALIVE_fnc_dump;
                ["ALIVE MP - Placement completed"] call ALIVE_fnc_dump;
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
