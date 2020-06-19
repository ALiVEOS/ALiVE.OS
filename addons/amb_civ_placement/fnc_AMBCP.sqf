//#define DEBUG_MODE_FULL
#include "\x\alive\addons\amb_civ_placement\script_component.hpp"
SCRIPT(AMBCP);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_AMBCP
Description:
Civitary objectives

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

See Also:
- <ALIVE_fnc_CPInit>

Author:
Wolffy
ARJay
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_AMBCP
#define MTEMPLATE "ALiVE_AMBCP_%1"
#define DEFAULT_SIZE "100"
#define DEFAULT_OBJECTIVES []
#define DEFAULT_TAOR []
#define DEFAULT_BLACKLIST []
#define DEFAULT_SIZE_FILTER "160"
#define DEFAULT_PRIORITY_FILTER "0"
#define DEFAULT_FACTION QUOTE(CIV_F)
#define DEFAULT_AMBIENT_VEHICLE_AMOUNT "0.1"
#define DEFAULT_PLACEMENT_MULTIPLIER "0.5"

private ["_result"];

TRACE_1("AMBCP - input",_this);

params [
    ["_logic", objNull, [objNull]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
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

        if (_args isEqualType true) then {
            _logic setVariable ["debug", _args];
        } else {
            _args = _logic getVariable ["debug", false];
        };
        if (_args isEqualType "") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["debug", _args];
        };
        ASSERT_TRUE(_args isEqualType true,str _args);

        _result = _args;

    };
    case "state": {

        private _simple_operations = ["targets", "size","type","faction"];

        if !(_args isEqualType []) then {
            private _state = [] call CBA_fnc_hashCreate;

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

    // Determine force faction
    case "faction": {

        _result = [_logic,_operation,_args,DEFAULT_FACTION,[] call ALiVE_fnc_configGetFactions] call ALIVE_fnc_OOsimpleOperation;

    };

    // Return TAOR marker
    case "taor": {

        if(_args isEqualType "") then {
            _args = [_args, " ", ""] call CBA_fnc_replace;
            _args = [_args, ","] call CBA_fnc_split;

            if(count _args > 0) then {
                _logic setVariable [_operation, _args];
            };
        };

        if (_args isEqualType []) then {
            _logic setVariable [_operation, _args];
        };

        _result = _logic getVariable [_operation, DEFAULT_TAOR];

    };

    // Return the Blacklist marker
    case "blacklist": {

        if(_args isEqualType "") then {
            _args = [_args, " ", ""] call CBA_fnc_replace;
            _args = [_args, ","] call CBA_fnc_split;

            if(count _args > 0) then {
                _logic setVariable [_operation, _args];
            };
        };

        if (_args isEqualType []) then {
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

    // Return the Placement Multiplier
    case "placementMultiplier": {
        _result = [_logic,_operation,_args,DEFAULT_PLACEMENT_MULTIPLIER] call ALIVE_fnc_OOsimpleOperation;
    };

    // Return the Ambient Vehicle Amount
    case "ambientVehicleAmount": {
        _result = [_logic,_operation,_args,DEFAULT_AMBIENT_VEHICLE_AMOUNT] call ALIVE_fnc_OOsimpleOperation;
    };

    // Ambient vehicle faction
    case "ambientVehicleFaction": {
        _result = [_logic,_operation,_args,DEFAULT_FACTION,[] call ALiVE_fnc_configGetFactions] call ALIVE_fnc_OOsimpleOperation;
    };

    // Return the objectives as an array of clusters
    case "objectives": {
        _result = [_logic,_operation,_args,DEFAULT_OBJECTIVES] call ALIVE_fnc_OOsimpleOperation;
    };

    // Return the HQ objectives as an array of clusters
    case "objectivesHQ": {
        _result = [_logic,_operation,_args,DEFAULT_OBJECTIVES] call ALIVE_fnc_OOsimpleOperation;
    };

    // Return the Power objectives as an array of clusters
    case "objectivesPower": {
        _result = [_logic,_operation,_args,DEFAULT_OBJECTIVES] call ALIVE_fnc_OOsimpleOperation;
    };

    // Return the Comms objectives as an array of clusters
    case "objectivesComms": {
        _result = [_logic,_operation,_args,DEFAULT_OBJECTIVES] call ALIVE_fnc_OOsimpleOperation;
    };

    // Return the MARINE objectives as an array of clusters
    case "objectivesMarine": {
        _result = [_logic,_operation,_args,DEFAULT_OBJECTIVES] call ALIVE_fnc_OOsimpleOperation;
    };

    // Return the RAIL objectives as an array of clusters
    case "objectivesRail": {
        _result = [_logic,_operation,_args,DEFAULT_OBJECTIVES] call ALIVE_fnc_OOsimpleOperation;
    };

    // Return the FUEL objectives as an array of clusters
    case "objectivesFuel": {
        _result = [_logic,_operation,_args,DEFAULT_OBJECTIVES] call ALIVE_fnc_OOsimpleOperation;
    };

    // Return the CONSTRUCTION objectives as an array of clusters
    case "objectivesConstruction": {
        _result = [_logic,_operation,_args,DEFAULT_OBJECTIVES] call ALIVE_fnc_OOsimpleOperation;
    };

    // Return the SETTLEMENT objectives as an array of clusters
    case "objectivesSettlement": {
        _result = [_logic,_operation,_args,DEFAULT_OBJECTIVES] call ALIVE_fnc_OOsimpleOperation;
    };

    // Main process
    case "init": {

        if (isServer) then {

            // if server, initialise module game logic

            TRACE_1("Module init",_logic);

            // First placed module will be chosen as master
            if (isnil QUOTE(ADDON)) then {
                ADDON = _logic;

                PublicVariable QUOTE(ADDON);
            };

            _logic setVariable ["super", SUPERCLASS];
            _logic setVariable ["class", MAINCLASS];
            _logic setVariable ["moduleType", "ALIVE_AMBCP"];
            _logic setVariable ["startupComplete", false];
            TRACE_1("After module init",_logic);

            [_logic, "taor", _logic getVariable ["taor", DEFAULT_TAOR]] call MAINCLASS;
            [_logic, "blacklist", _logic getVariable ["blacklist", DEFAULT_TAOR]] call MAINCLASS;

            if !([QMOD(sys_profile)] call ALiVE_fnc_isModuleAvailable) exitwith {
                ["Profile System module not placed! Exiting..."] call ALiVE_fnc_DumpR;
                _logic setVariable ["startupComplete", true];
            };

            if !([QMOD(amb_civ_population)] call ALiVE_fnc_isModuleAvailable) exitwith {
                ["Civilian Population System module not placed! Exiting..."] call ALiVE_fnc_DumpR;
                _logic setVariable ["startupComplete", true];
            };

            [_logic,"start"] call MAINCLASS;
        } else {

            waituntil {!isnil QUOTE(ADDON)};

            [_logic, "taor", _logic getVariable ["taor", DEFAULT_TAOR]] call MAINCLASS;
            [_logic, "blacklist", _logic getVariable ["blacklist", DEFAULT_TAOR]] call MAINCLASS;
            {_x setMarkerAlpha 0} foreach (_logic getVariable ["taor", DEFAULT_TAOR]);
            {_x setMarkerAlpha 0} foreach (_logic getVariable ["blacklist", DEFAULT_TAOR]);
        };

    };

    case "start": {

        if (isServer) then {

            private _debug = [_logic, "debug"] call MAINCLASS;

            if(_debug) then {
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                ["ALIVE AMBCP - Startup"] call ALIVE_fnc_dump;
                [true] call ALIVE_fnc_timer;
            };

            waituntil {!(isnil "ALiVE_ProfileHandler") && {[ALiVE_ProfileSystem,"startupComplete",false] call ALIVE_fnc_hashGet}};
            waituntil {!(isnil "ALIVE_clusterHandler")};

            if(isNil "ALIVE_clustersCiv" && isNil "ALIVE_loadedCivClusters") then {
                private _worldName = toLower(worldName);
                private _file = format["x\alive\addons\civ_placement\clusters\clusters.%1_civ.sqf", _worldName];
                call compile preprocessFileLineNumbers _file;
                ALIVE_loadedCIVClusters = true;
            };
            waituntil {!(isnil "ALIVE_loadedCIVClusters") && {ALIVE_loadedCIVClusters}};

            if (isnil "ALIVE_clustersCivSettlement") exitwith {
                ["ALIVE AMBCP - Exiting because of lack of civilian settlements..."] call ALIVE_fnc_dump;
                _logic setVariable ["startupComplete", true];
            };

            //Only spawn warning on version mismatch since map index changes were reduced
            //uncomment //_error = true; below for exit
            private _error = false;
            if!(isNil "ALIVE_clusterBuild") then {
                private _clusterVersion = ALIVE_clusterBuild select 2;
                private _clusterBuild = ALIVE_clusterBuild select 3;
                private _clusterType = ALIVE_clusterBuild select 4;
                private _version = productVersion select 2;
                private _build = productVersion select 3;

                if!(_clusterType == 'Stable') then {
                    private _message = "Warning ALiVE requires the STABLE game build";
                    [_message] call ALIVE_fnc_dump;
                    //_error = true;
                };

                if(!(_clusterVersion == _version) || !(_clusterBuild == _build)) then {
                    private _message = format["Warning: This version of ALiVE is build for A3 version: %1.%2. The server is running version: %3.%4. Please contact your server administrator and update to the latest ALiVE release version.",_clusterVersion, _clusterBuild, _version, _build];
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
                private _taor = [_logic, "taor"] call MAINCLASS;
                private _blacklist = [_logic, "blacklist"] call MAINCLASS;
                private _sizeFilter = parseNumber([_logic, "sizeFilter"] call MAINCLASS);
                private _priorityFilter = parseNumber([_logic, "priorityFilter"] call MAINCLASS);

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

                private _clusters = DEFAULT_OBJECTIVES;


                if(!(worldName == "Altis") && _sizeFilter == 160) then {
                    _sizeFilter = 0;
                };

                if !(isnil "ALIVE_clustersCivSettlement") then {

                     _clusters = ALIVE_clustersCivSettlement select 2;
                     _clusters = [_clusters,_sizeFilter,_priorityFilter] call ALIVE_fnc_copyClusters;
                     _clusters = [_clusters, _taor] call ALIVE_fnc_clustersInsideMarker;
                     _clusters = [_clusters, _blacklist] call ALIVE_fnc_clustersOutsideMarker;
                     {
                          [_x, "debug", [_logic, "debug"] call MAINCLASS] call ALIVE_fnc_cluster;
                     } forEach _clusters;
                     [_logic, "objectives", _clusters] call MAINCLASS;
                };

                /*
                _clusters = ALIVE_clustersCiv select 2;
                _clusters = [_clusters,_sizeFilter,_priorityFilter] call ALIVE_fnc_copyClusters;
                _clusters = [_clusters, _taor] call ALIVE_fnc_clustersInsideMarker;
                _clusters = [_clusters, _blacklist] call ALIVE_fnc_clustersOutsideMarker;
                {
                    [_x, "debug", [_logic, "debug"] call MAINCLASS] call ALIVE_fnc_cluster;
                } forEach _clusters;
                [_logic, "objectives", _clusters] call MAINCLASS;


                if !(isnil "ALIVE_clustersCivSettlement") then {
                     _clusters = ALIVE_clustersCivSettlement select 2;
                     _clusters = [_clusters,_sizeFilter,_priorityFilter] call ALIVE_fnc_copyClusters;
                     _clusters = [_clusters, _taor] call ALIVE_fnc_clustersInsideMarker;
                     _clusters = [_clusters, _blacklist] call ALIVE_fnc_clustersOutsideMarker;
                     {
                          [_x, "debug", [_logic, "debug"] call MAINCLASS] call ALIVE_fnc_cluster;
                     } forEach _clusters;
                     [_logic, "objectivesSettlement", _clusters] call MAINCLASS;
                };


                if !(isnil "ALIVE_clustersCivHQ") then {
                    if(_sizeFilter == 160) then {
                        _sizeFilter = 0;
                    };
                    _clusters = ALIVE_clustersCivHQ select 2;
                    _clusters = [_clusters,_sizeFilter,_priorityFilter] call ALIVE_fnc_copyClusters;
                    _clusters = [_clusters, _taor] call ALIVE_fnc_clustersInsideMarker;
                    _clusters = [_clusters, _blacklist] call ALIVE_fnc_clustersOutsideMarker;
                    {
                        [_x, "debug", [_logic, "debug"] call MAINCLASS] call ALIVE_fnc_cluster;
                    } forEach _clusters;
                    [_logic, "objectivesHQ", _clusters] call MAINCLASS;
                };


                if !(isnil "ALIVE_clustersCivPower") then {
                    if(_sizeFilter == 160) then {
                        _sizeFilter = 0;
                    };
                    _clusters = ALIVE_clustersCivPower select 2;
                    _clusters = [_clusters,_sizeFilter,_priorityFilter] call ALIVE_fnc_copyClusters;
                    _clusters = [_clusters, _taor] call ALIVE_fnc_clustersInsideMarker;
                    _clusters = [_clusters, _blacklist] call ALIVE_fnc_clustersOutsideMarker;
                    {
                        [_x, "debug", [_logic, "debug"] call MAINCLASS] call ALIVE_fnc_cluster;
                    } forEach _clusters;
                    [_logic, "objectivesPower", _clusters] call MAINCLASS;
                };


                if !(isnil "ALIVE_clustersCivComms") then {
                    if(_sizeFilter == 160) then {
                        _sizeFilter = 0;
                    };
                    _clusters = ALIVE_clustersCivComms select 2;
                    _clusters = [_clusters,_sizeFilter,_priorityFilter] call ALIVE_fnc_copyClusters;
                    _clusters = [_clusters, _taor] call ALIVE_fnc_clustersInsideMarker;
                    _clusters = [_clusters, _blacklist] call ALIVE_fnc_clustersOutsideMarker;
                    {
                        [_x, "debug", [_logic, "debug"] call MAINCLASS] call ALIVE_fnc_cluster;
                    } forEach _clusters;
                    [_logic, "objectivesComms", _clusters] call MAINCLASS;
                };


                if !(isnil "ALIVE_clustersCivMarine") then {
                    if(_sizeFilter == 160) then {
                        _sizeFilter = 0;
                    };
                    _clusters = ALIVE_clustersCivMarine select 2;
                    _clusters = [_clusters,_sizeFilter,_priorityFilter] call ALIVE_fnc_copyClusters;
                    _clusters = [_clusters, _taor] call ALIVE_fnc_clustersInsideMarker;
                    _clusters = [_clusters, _blacklist] call ALIVE_fnc_clustersOutsideMarker;
                    {
                        [_x, "debug", [_logic, "debug"] call MAINCLASS] call ALIVE_fnc_cluster;
                    } forEach _clusters;
                    [_logic, "objectivesMarine", _clusters] call MAINCLASS;
                };


                if !(isnil "ALIVE_clustersCivRail") then {
                    if(_sizeFilter == 160) then {
                        _sizeFilter = 0;
                    };
                    _clusters = ALIVE_clustersCivRail select 2;
                    _clusters = [_clusters,_sizeFilter,_priorityFilter] call ALIVE_fnc_copyClusters;
                    _clusters = [_clusters, _taor] call ALIVE_fnc_clustersInsideMarker;
                    _clusters = [_clusters, _blacklist] call ALIVE_fnc_clustersOutsideMarker;
                    {
                        [_x, "debug", [_logic, "debug"] call MAINCLASS] call ALIVE_fnc_cluster;
                    } forEach _clusters;
                    [_logic, "objectivesRail", _clusters] call MAINCLASS;
                };


                if !(isnil "ALIVE_clustersCivFuel") then {
                    if(_sizeFilter == 160) then {
                        _sizeFilter = 0;
                    };
                    _clusters = ALIVE_clustersCivFuel select 2;
                    _clusters = [_clusters,_sizeFilter,_priorityFilter] call ALIVE_fnc_copyClusters;
                    _clusters = [_clusters, _taor] call ALIVE_fnc_clustersInsideMarker;
                    _clusters = [_clusters, _blacklist] call ALIVE_fnc_clustersOutsideMarker;
                    {
                        [_x, "debug", [_logic, "debug"] call MAINCLASS] call ALIVE_fnc_cluster;
                    } forEach _clusters;
                    [_logic, "objectivesFuel", _clusters] call MAINCLASS;
                };


                if !(isnil "ALIVE_clustersCivConstruction") then {
                    if(_sizeFilter == 160) then {
                        _sizeFilter = 0;
                    };
                    _clusters = ALIVE_clustersCivConstruction select 2;
                    _clusters = [_clusters,_sizeFilter,_priorityFilter] call ALIVE_fnc_copyClusters;
                    _clusters = [_clusters, _taor] call ALIVE_fnc_clustersInsideMarker;
                    _clusters = [_clusters, _blacklist] call ALIVE_fnc_clustersOutsideMarker;
                    {
                        [_x, "debug", [_logic, "debug"] call MAINCLASS] call ALIVE_fnc_cluster;
                    } forEach _clusters;
                    [_logic, "objectivesConstruction", _clusters] call MAINCLASS;
                };
                */


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["ALIVE AMBCP - Startup completed"] call ALIVE_fnc_dump;
                    ["ALIVE AMBCP - Count clusters %1",count _clusters] call ALIVE_fnc_dump;
                    [] call ALIVE_fnc_timer;
                };
                // DEBUG -------------------------------------------------------------------------------------


                _clusters = [_logic, "objectives"] call MAINCLASS;

                if(count _clusters > 0) then {
                    // start registration
                    [_logic, "registration"] call MAINCLASS;
                }else{
                    ["ALIVE AMBCP - Warning no locations found for placement, you need to include civilian locations within the TAOR marker: %1", _taor] call ALIVE_fnc_dumpR;

                    // set module as started
                    _logic setVariable ["startupComplete", true];
                };

            }else{
                // errors
                _logic setVariable ["startupComplete", true];
            };
        };

    };

    // Registration
    case "registration": {

        if (isServer) then {

            private _debug = [_logic, "debug"] call MAINCLASS;


            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                ["ALIVE AMBCP - Registration"] call ALIVE_fnc_dump;
                [true] call ALIVE_fnc_timer;
            };
            // DEBUG -------------------------------------------------------------------------------------

            private _clusters = [_logic, "objectives"] call MAINCLASS;

            /*
            private _clusters = [_logic, "objectives"] call MAINCLASS;
            private _clustersSettlement = [_logic, "objectivesSettlement", _clusters] call MAINCLASS;
            private _clustersHQ = [_logic, "objectivesHQ", _clusters] call MAINCLASS;
            private _clustersPower = [_logic, "objectivesPower", _clusters] call MAINCLASS;
            private _clustersComms = [_logic, "objectivesComms", _clusters] call MAINCLASS;
            private _clustersMarine = [_logic, "objectivesMarine", _clusters] call MAINCLASS;
            private _clustersRail = [_logic, "objectivesRail", _clusters] call MAINCLASS;
            private _clustersFuel = [_logic, "objectivesFuel", _clusters] call MAINCLASS;
            private _clustersConstruction = [_logic, "objectivesConstruction", _clusters] call MAINCLASS;
            */



            if(count _clusters > 0) then {
                {
                    [ALIVE_clusterHandler, "registerCluster", _x] call ALIVE_fnc_clusterHandler;
                } forEach _clusters;
            };

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                [ALIVE_clusterHandler, "debug", true] call ALIVE_fnc_clusterHandler;
            };

            // start placement
            [_logic, "placement"] call MAINCLASS;

        };

    };

    // Placement
    case "placement": {

        if (isServer) then {

            private _debug = [_logic, "debug"] call MAINCLASS;

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                ["ALIVE AMBCP - Placement"] call ALIVE_fnc_dump;
                [true] call ALIVE_fnc_timer;
            };
            // DEBUG -------------------------------------------------------------------------------------


            //waituntil {sleep 5; (!(isnil {([_logic, "objectives"] call MAINCLASS)}) && {count ([_logic, "objectives"] call MAINCLASS) > 0})};

            private _clusters = [_logic, "objectives"] call MAINCLASS;

            /*
            _clusters = [_logic, "objectives"] call MAINCLASS;
            _clustersSettlement = [_logic, "objectivesSettlement", _clusters] call MAINCLASS;
            _clustersHQ = [_logic, "objectivesHQ", _clusters] call MAINCLASS;
            _clustersPower = [_logic, "objectivesPower", _clusters] call MAINCLASS;
            _clustersComms = [_logic, "objectivesComms", _clusters] call MAINCLASS;
            _clustersMarine = [_logic, "objectivesMarine", _clusters] call MAINCLASS;
            _clustersRail = [_logic, "objectivesRail", _clusters] call MAINCLASS;
            _clustersFuel = [_logic, "objectivesFuel", _clusters] call MAINCLASS;
            _clustersConstruction = [_logic, "objectivesConstruction", _clusters] call MAINCLASS;
            */

            private _faction = [_logic, "faction"] call MAINCLASS;
            private _placementMultiplier = parseNumber([_logic, "placementMultiplier"] call MAINCLASS);
            private _ambientVehicleAmount = parseNumber([_logic, "ambientVehicleAmount"] call MAINCLASS);
            private _ambientVehicleFaction = [_logic, "ambientVehicleFaction"] call MAINCLASS;

            private _factionConfig = _faction call ALiVE_fnc_configGetFactionClass;
            private _factionSideNumber = getNumber(_factionConfig >> "side");
            private _side = _factionSideNumber call ALIVE_fnc_sideNumberToText;
            private _sideObject = [_side] call ALIVE_fnc_sideTextToObject;

            // get current environment settings
            private _env = call ALIVE_fnc_getEnvironment;

            // get current global civilian population posture
            [] call ALIVE_fnc_getGlobalPosture;


            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["ALIVE AMBCP [%1] SideNum: %2 Side: %3 Faction: %4",_faction,_factionSideNumber,_side,_faction] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            // Load static data
            call ALiVE_fnc_staticDataHandler;

            // Place ambient vehicles

            private ["_vehicleClass"];

            private _countLandUnits = 0;

            if(_ambientVehicleAmount > 0) then {

                private _carClasses = [0,_ambientVehicleFaction,"Car"] call ALiVE_fnc_findVehicleType;
                private _landClasses = _carClasses - ALiVE_PLACEMENT_VEHICLEBLACKLIST;

                private _supportClasses = [ALIVE_factionDefaultSupports,_ambientVehicleFaction,[]] call ALIVE_fnc_hashGet;

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
                        private _supportCount = 0;
                        private _supportMax = 0;

                        private _clusterID = [_x, "clusterID"] call ALIVE_fnc_hashGet;
                        private _nodes = [_x, "nodes"] call ALIVE_fnc_hashGet;

                        //["NODES: %1",_nodes] call ALIVE_fnc_dump;

                        private _buildings = [_nodes, ALIVE_civilianPopulationBuildingTypes] call ALIVE_fnc_findBuildingsInClusterNodes;

                        //["BUILDINGS: %1",_buildings] call ALIVE_fnc_dump;

                        private _countBuildings = count _buildings;
                        private _parkingChance = 0.25 * _ambientVehicleAmount;
                        _supportMax = 3 * _parkingChance;

                        //["COUNT BUILDINGS: %1",_countBuildings] call ALIVE_fnc_dump;
                        //["CHANCE: %1",_parkingChance] call ALIVE_fnc_dump;

                        /*if(_countBuildings > 50) then {
                            _supportMax = 3;
                            _parkingChance = 0.1 * _ambientVehicleAmount;
                        };

                        if(_countBuildings > 40 && _countBuildings < 50) then {
                            _supportMax = 2;
                            _parkingChance = 0.2 * _ambientVehicleAmount;
                        };

                        if(_countBuildings > 30 && _countBuildings < 41) then {
                            _supportMax = 2;
                            _parkingChance = 0.3 * _ambientVehicleAmount;
                        };

                        if(_countBuildings > 20 && _countBuildings < 31) then {
                            _supportMax = 1;
                            _parkingChance = 0.4 * _ambientVehicleAmount;
                        };

                        if(_countBuildings > 10 && _countBuildings < 21) then {
                            _supportMax = 1;
                            _parkingChance = 0.5 * _ambientVehicleAmount;
                        };

                        if(_countBuildings > 0 && _countBuildings < 11) then {
                            _supportMax = 0;
                            _parkingChance = 0.6 * _ambientVehicleAmount;
                        };
                        */
                        //["SUPPORT MAX: %1",_supportMax] call ALIVE_fnc_dump;
                        //["CHANCE: %1",_parkingChance] call ALIVE_fnc_dump;

                        private _usedPositions = [];

                        {
                            if(random 1 < _parkingChance) then {

                                private _building = _x;

                                //["SUPPORT CLASSES: %1",_supportClasses] call ALIVE_fnc_dump;
                                //["LAND CLASSES: %1",_landClasses] call ALIVE_fnc_dump;

                                private _supportPlacement = false;
                                if(_supportCount < _supportMax) then {
                                    _supportPlacement = true;
                                    _vehicleClass = selectRandom _supportClasses;
                                }else{
                                    _vehicleClass = selectRandom _landClasses;
                                };

                                //["SUPPORT PLACEMENT: %1",_supportPlacement] call ALIVE_fnc_dump;
                                //["VEHICLE CLASS: %1",_vehicleClass] call ALIVE_fnc_dump;

                                private _parkingPosition = [_vehicleClass,_building,false] call ALIVE_fnc_getParkingPosition;

                                if (!isnil "_parkingPosition" && {count _parkingPosition == 2} && {{(_parkingPosition select 0) distance (_x select 0) < 10} count _usedPositions == 0}) then {

                                    [_vehicleClass,_side,_faction,_parkingPosition select 0,_parkingPosition select 1,false,_faction,_clusterID,_parkingPosition select 0] call ALIVE_fnc_createCivilianVehicle;

                                    _countLandUnits = _countLandUnits + 1;

                                    _usedPositions pushback _parkingPosition;

                                    if(_supportPlacement) then {
                                        _supportCount = _supportCount + 1;
                                    };
                                };
                            };

                        } forEach _buildings;

                    } forEach _clusters;
                };
            };

            // Place ambient civilians

            // avoid error that stems from BIS population module CIV_F unit classes
            // https://github.com/ALiVEOS/ALiVE.OS/issues/522
            private _minScope = 1;
            if (_faction == "CIV_F") then {_minScope = 2};

            private _civClasses = [0,_faction,"Man",false,_minScope] call ALiVE_fnc_findVehicleType;

            private _countCivilianUnits = 0;

            //["CIV Classes: %1",_civClasses] call ALIVE_fnc_dump;

            _civClasses = _civClasses - ALIVE_PLACEMENT_UNITBLACKLIST;

            //["CIV Classes: %1",_civClasses] call ALIVE_fnc_dump;

            if(count _civClasses > 0) then {

                {
                    private _clusterID = [_x, "clusterID"] call ALIVE_fnc_hashGet;
                    private _nodes = [_x, "nodes"] call ALIVE_fnc_hashGet;
                    private _ambientCivilianRoles = [ALIVE_civilianPopulationSystem, "ambientCivilianRoles",[]] call ALiVE_fnc_HashGet;

                    //["NODES: %1",_nodes] call ALIVE_fnc_dump;

                    private _buildings = [_nodes, ALIVE_civilianPopulationBuildingTypes] call ALIVE_fnc_findBuildingsInClusterNodes;

                    //["BUILDINGS: %1",_buildings] call ALIVE_fnc_dump;

                    private _countBuildings = count _buildings;

                    private _spawnChance = 0.25 * _placementMultiplier;

                    /*
                    From: https://github.com/ALiVEOS/ALiVE.OS/issues/205
                    if(_countBuildings > 50) then {
                        _spawnChance = 0.1 * _placementMultiplier;
                    };

                    if(_countBuildings > 40 && _countBuildings < 50) then {
                        _spawnChance = 0.2 * _placementMultiplier;
                    };

                    if(_countBuildings > 30 && _countBuildings < 41) then {
                        _spawnChance = 0.3 * _placementMultiplier;
                    };

                    if(_countBuildings > 20 && _countBuildings < 31) then {
                        _spawnChance = 0.5 * _placementMultiplier;
                    };

                    if(_countBuildings > 10 && _countBuildings < 21) then {
                        _spawnChance = 0.7 * _placementMultiplier;
                    };

                    if(_countBuildings > 0 && _countBuildings < 11) then {
                        _spawnChance = 0.8 * _placementMultiplier;
                    };
                    */
                    {

                        if(random 1 < _spawnChance) then {

                            private _building = _x;

                            private _unitClass = selectRandom _civClasses;
                            private _agentID = format["agent_%1",[ALIVE_agentHandler, "getNextInsertID"] call ALIVE_fnc_agentHandler];

                            private _buildingPositions = [getPosATL _building,15] call ALIVE_fnc_findIndoorHousePositions;
                            private _buildingPosition = if (count _buildingPositions > 0) then {selectRandom _buildingPositions} else {getPosATL _building};

                            private _agent = [nil, "create"] call ALIVE_fnc_civilianAgent;
                            [_agent, "init"] call ALIVE_fnc_civilianAgent;
                            [_agent, "agentID", _agentID] call ALIVE_fnc_civilianAgent;
                            [_agent, "agentClass", _unitClass] call ALIVE_fnc_civilianAgent;
                            [_agent, "position", _buildingPosition] call ALIVE_fnc_civilianAgent;
                            [_agent, "side", _side] call ALIVE_fnc_civilianAgent;
                            [_agent, "faction", _faction] call ALIVE_fnc_civilianAgent;
                            [_agent, "homeCluster", _clusterID] call ALIVE_fnc_civilianAgent;
                            [_agent, "homePosition", _buildingPosition] call ALIVE_fnc_civilianAgent;

                            if (count _ambientCivilianRoles > 0 && {random 1 > 0.5}) then {
                                private _role = selectRandom _ambientCivilianRoles;
                                //private _roles = _ambientCivilianRoles - [_role];

                                [_agent, _role, true] call ALIVE_fnc_HashSet;
                            };

                            [_agent] call ALIVE_fnc_selectCivilianCommand;

                            [ALIVE_agentHandler, "registerAgent", _agent] call ALIVE_fnc_agentHandler;

                            _countCivilianUnits = _countCivilianUnits + 1;
                        };

                    } forEach _buildings;

                } forEach _clusters;
            };

            ["ALIVE AMBCP [%1] - Ambient land vehicles placed: %2",_faction,_countLandUnits] call ALIVE_fnc_dump;
            ["ALIVE AMBCP [%1] - Ambient civilian units placed: %2",_faction,_countCivilianUnits] call ALIVE_fnc_dump;

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["ALIVE AMBCP - Placement completed"] call ALIVE_fnc_dump;
                [] call ALIVE_fnc_timer;
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------

            // set module as started
            _logic setVariable ["startupComplete", true];

        };

    };

};

TRACE_1("AMBCP - output",_result);

_result;