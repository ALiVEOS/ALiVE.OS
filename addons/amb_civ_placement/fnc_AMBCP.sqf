//#define DEBUG_MODE_FULL
#include "\x\alive\addons\amb_civ_placement\script_component.hpp"
SCRIPT(AMBCP);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_AMBCP
Description:
Civilian objectives

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
Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_AMBCP
#define MTEMPLATE "ALiVE_AMBCP_%1"
#define DEFAULT_SIZE "100"
#define DEFAULT_OBJECTIVES []
#define DEFAULT_TAOR []
#define DEFAULT_BLACKLIST []
#define DEFAULT_SIZE_FILTER "250"
#define DEFAULT_PRIORITY_FILTER "0"
#define DEFAULT_FACTION QUOTE(CIV_F)
#define DEFAULT_AMBIENT_VEHICLE_AMOUNT "0.2"
#define DEFAULT_AMBIENT_ANIMAL_AMOUNT "0"
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

        // State save / restore list. Original hardcoded list only covered
        // four keys (targets / size / type / faction), so every other Eden
        // attribute silently reverted to its runtime default on persistence
        // restore. Expanded to include all ten module attributes alongside
        // the original three runtime-state keys; any legacy persisted state
        // files that only contain the four original keys still round-trip
        // correctly because the hashGet default returns nil for missing
        // entries and the case handlers treat nil as "keep current".
        private _simple_operations = [
            // Runtime state (original entries, retained)
            "targets", "size", "type",
            // Eden attributes (persistence gap fix)
            "debug",
            "taor",
            "blacklist",
            "sizeFilter",
            "priorityFilter",
            "faction",
            "placementMultiplier",
            "ambientVehicleAmount",
            "ambientVehicleFaction",
            "ambientAnimalAmount",
            "customPoultryClasses",
            "customPoultryClassesManual",
            "customHerdClasses",
            "customHerdClassesManual",
            "initialdamage"
        ];

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

    // Return the Ambient Animal Amount
    case "ambientAnimalAmount": {
        _result = [_logic,_operation,_args,DEFAULT_AMBIENT_ANIMAL_AMOUNT] call ALIVE_fnc_OOsimpleOperation;
    };


    // Ambient vehicle Initial Damage
    case "initialdamage": {
        if (_args isEqualType true) then {
            _logic setVariable ["initialdamage", _args];
        } else {
            _args = _logic getVariable ["initialdamage", false];
        };
        if (_args isEqualType "") then {
            if(_args == "true") then {_args = true;} else {_args = false;};
            _logic setVariable ["initialdamage", _args];
        };
        ASSERT_TRUE(_args isEqualType true,str _args);

        _result = _args;
    };


    // Return the objectives as an array of clusters
    case "objectives": {
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
            [_logic, "blacklist", _logic getVariable ["blacklist", DEFAULT_BLACKLIST]] call MAINCLASS;

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
            [_logic, "blacklist", _logic getVariable ["blacklist", DEFAULT_BLACKLIST]] call MAINCLASS;
            {_x setMarkerAlpha 0} foreach (_logic getVariable ["taor", DEFAULT_TAOR]);
            {_x setMarkerAlpha 0} foreach (_logic getVariable ["blacklist", DEFAULT_BLACKLIST]);
        };

    };

    case "start": {

        if (isServer) then {

            private _debug = [_logic, "debug"] call MAINCLASS;

            if(_debug) then {
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                ["AMBCP - Startup"] call ALiVE_fnc_dump;
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
                ["AMBCP - Exiting because of lack of civilian settlements..."] call ALiVE_fnc_dump;
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
            };

            if!(_error) then {
                private _taor = [_logic, "taor"] call MAINCLASS;
                private _blacklist = [_logic, "blacklist"] call MAINCLASS;
                private _sizeFilter = parseNumber([_logic, "sizeFilter"] call MAINCLASS);
                private _priorityFilter = parseNumber([_logic, "priorityFilter"] call MAINCLASS);

                // drop any TAOR / blacklist markers that no longer exist
                // (mission save may have outlived a marker the author removed)
                _taor = _taor select { _x call ALIVE_fnc_markerExists };
                _blacklist = _blacklist select { _x call ALIVE_fnc_markerExists };

                private _clusters = DEFAULT_OBJECTIVES;

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

                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["AMBCP - Startup completed"] call ALiVE_fnc_dump;
                    ["AMBCP - Count clusters %1",count _clusters] call ALiVE_fnc_dump;
                    [] call ALIVE_fnc_timer;
                };
                // DEBUG -------------------------------------------------------------------------------------


                _clusters = [_logic, "objectives"] call MAINCLASS;

                if(count _clusters > 0) then {
                    // start registration
                    [_logic, "registration"] call MAINCLASS;
                }else{
                    ["AMBCP - Warning no locations found for placement, you need to include civilian locations within the TAOR marker: %1", _taor] call ALiVE_fnc_dumpR;

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
                ["AMBCP - Registration"] call ALiVE_fnc_dump;
                [true] call ALIVE_fnc_timer;
            };
            // DEBUG -------------------------------------------------------------------------------------

            private _clusters = [_logic, "objectives"] call MAINCLASS;

            if(count _clusters > 0) then {
                {
                    [ALIVE_clusterHandler, "registerCluster", _x] call ALIVE_fnc_clusterHandler;
                } forEach _clusters;
            };

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                [ALIVE_clusterHandler, "debug", true] call ALIVE_fnc_clusterHandler;
            };

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["AMBCP - Registration Completed"] call ALiVE_fnc_dump;
                [] call ALIVE_fnc_timer;
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------

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
                ["AMBCP - Placement"] call ALiVE_fnc_dump;
                [true] call ALIVE_fnc_timer;
            };
            // DEBUG -------------------------------------------------------------------------------------


            //waituntil {sleep 5; (!(isnil {([_logic, "objectives"] call MAINCLASS)}) && {count ([_logic, "objectives"] call MAINCLASS) > 0})};

            private _clusters = [_logic, "objectives"] call MAINCLASS;

            private _faction = [_logic, "faction"] call MAINCLASS;
            private _placementMultiplier = parseNumber([_logic, "placementMultiplier"] call MAINCLASS);
            private _ambientVehicleAmount = parseNumber([_logic, "ambientVehicleAmount"] call MAINCLASS);
            private _ambientVehicleFaction = [_logic, "ambientVehicleFaction"] call MAINCLASS;
            private _ambientAnimalAmount = parseNumber([_logic, "ambientAnimalAmount"] call MAINCLASS);
            private _factionConfig = _faction call ALiVE_fnc_configGetFactionClass;
            private _factionSideNumber = getNumber(_factionConfig >> "side");
            private _side = _factionSideNumber call ALIVE_fnc_sideNumberToText;
            private _sideObject = [_side] call ALIVE_fnc_sideTextToObject;

            private _initialdamage = [_logic, "initialdamage"] call MAINCLASS;

            // side-effect call: primes the civilian-population global posture
            [] call ALIVE_fnc_getGlobalPosture;


            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["AMBCP [%1] SideNum: %2 Side: %3 Faction: %4",_faction,_factionSideNumber,_side,_faction] call ALiVE_fnc_dump;
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

                                private _parkingPosition = [_vehicleClass,_building,[],false] call ALIVE_fnc_getParkingPosition;

                                if (!isnil "_parkingPosition" && {count _parkingPosition == 2} && {{(_parkingPosition select 0) distance (_x select 0) < 10} count _usedPositions == 0}) then {

                                    [_vehicleClass,_side,_faction,_parkingPosition select 0,_parkingPosition select 1,false,_faction,_clusterID,_parkingPosition select 0,_initialdamage] call ALIVE_fnc_createCivilianVehicle;

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

            // Place ambient animals.
            //
            // Two species pools placed differently to match real-world
            // animal husbandry:
            //   - Poultry (Hen, Cock): in town - spawn near civilian
            //     buildings inside the cluster footprint. Backyard
            //     chickens are realistic in any built-up area.
            //   - Herd animals (Goat, Sheep): in fields - spawn
            //     OUTSIDE the cluster footprint, away from buildings,
            //     in open countryside near where farms would live.
            // Resolves #488. Default amount is NONE (opt-in).
            //
            // Density at each amount level:
            //   LOW    (0.2): poultry 2 % per civ building; 0-1 herd / cluster.
            //   MEDIUM (0.6): poultry 6 %;                  1-2 herds / cluster.
            //   HIGH   (1.0): poultry 10 %;                 2-4 herds / cluster.
            // Each group is homogeneous (one species per group;
            // real-world flocks aren't mixed-species). Animals don't
            // register with the cluster handler or the agent system -
            // they're decorative ambient life.
            if (_ambientAnimalAmount > 0) then {
                // Resolve the poultry / herd pools from the per-attribute
                // multi-select listboxes plus the manual-override edit
                // fields. Multi-select is the registry-driven path
                // (CfgALiVEAmbientAnimals); manual is for classnames the
                // mission-maker knows about that aren't in the registry.
                // Final pool = union of (multi-select selection) +
                // (manual override, parsed as SQF array literal or CSV).
                private _fnc_resolvePool = {
                    params ["_logicVar", "_manualVar", "_vanillaFallback"];
                    private _multiRaw = _logic getVariable [_logicVar, ""];
                    private _manualRaw = _logic getVariable [_manualVar, ""];
                    private _pool = [];

                    // Parse multi-select. Same forms accepted by the load
                    // handler: SQF array literal, CSV, or single name.
                    if (_multiRaw isEqualType "" && {_multiRaw != ""}) then {
                        if ((_multiRaw select [0,1]) == "[") then {
                            private _parsed = parseSimpleArray _multiRaw;
                            if (typeName _parsed == "ARRAY") then {
                                { if (typeName _x == "STRING" && {_x != ""}) then { _pool pushBackUnique _x } } forEach _parsed;
                            };
                        } else {
                            {
                                private _p = _x;
                                while {count _p > 0 && {(_p select [0, 1]) == " "}} do { _p = _p select [1] };
                                while {count _p > 0 && {(_p select [count _p - 1, 1]) == " "}} do { _p = _p select [0, count _p - 1] };
                                if (_p != "") then { _pool pushBackUnique _p };
                            } forEach ([_multiRaw, ","] call CBA_fnc_split);
                        };
                    };

                    // Append manual-override entries (CSV).
                    if (_manualRaw isEqualType "" && {_manualRaw != ""}) then {
                        {
                            private _p = _x;
                            while {count _p > 0 && {(_p select [0, 1]) == " "}} do { _p = _p select [1] };
                            while {count _p > 0 && {(_p select [count _p - 1, 1]) == " "}} do { _p = _p select [0, count _p - 1] };
                            if (_p != "") then { _pool pushBackUnique _p };
                        } forEach ([_manualRaw, ","] call CBA_fnc_split);
                    };

                    // Vanilla fallback if the user emptied both fields.
                    // Mission-maker can disable this category by setting
                    // ambientAnimalAmount to NONE; deselecting all classes
                    // in the listbox + leaving manual blank otherwise
                    // falls back to the canonical pool so the feature
                    // doesn't silently no-op.
                    if (count _pool == 0) then {
                        _pool = _vanillaFallback;
                    };

                    // Filter to classes actually present in CfgVehicles.
                    _pool select { isClass (configFile >> "CfgVehicles" >> _x) }
                };

                private _poultryPool = ["customPoultryClasses", "customPoultryClassesManual", ["Hen_random_F", "Cock_random_F"]] call _fnc_resolvePool;
                private _herdPool    = ["customHerdClasses",    "customHerdClassesManual",    ["Goat_random_F", "Sheep_random_F"]] call _fnc_resolvePool;

                private _countPoultry = 0;
                private _countHerd = 0;

                // Mission-scope registry. Each entry:
                //   [pos, class, groupSize, units, kind]
                // Spawning is deferred to a player-proximity handler
                // attached at the bottom of this block - keeping
                // hundreds of always-on animal units across the map
                // costs the server ~40 server FPS.
                if (isNil "ALiVE_AMBCP_animalRegistry") then {
                    ALiVE_AMBCP_animalRegistry = [];
                };

                // ---- Poultry near civilian buildings ----
                if (count _poultryPool > 0) then {
                    private _poultryChance = 0.10 * _ambientAnimalAmount;
                    {
                        private _nodes = [_x, "nodes"] call ALIVE_fnc_hashGet;
                        private _buildings = [_nodes, ALIVE_civilianPopulationBuildingTypes] call ALIVE_fnc_findBuildingsInClusterNodes;
                        {
                            if (random 1 < _poultryChance) then {
                                private _basePos = _x getRelPos [3 + random 8, random 360];
                                private _animalClass = selectRandom _poultryPool;
                                private _groupSize = 1 + floor (random 4);
                                ALiVE_AMBCP_animalRegistry pushBack [_basePos, _animalClass, _groupSize, [], "poultry"];
                                _countPoultry = _countPoultry + _groupSize;
                            };
                        } forEach _buildings;
                    } forEach _clusters;
                };

                // ---- Herd animals in fields outside the cluster ----
                // Spawn anywhere outside the cluster footprint (town,
                // military site, industrial area) - the geometric
                // "outside cluster_size" check is sufficient because
                // a cluster's `size` IS the radius the placer treats
                // as that location's built-up area. Fields, hill
                // sides, open country: all valid. The only per-
                // position filter is surfaceIsWater (don't spawn
                // sheep in the sea). No building-proximity filter -
                // a stray fence or shed in open country is fine.
                if (count _herdPool > 0) then {
                    private _herdsTried = 0;
                    private _herdsPlaced = 0;
                    {
                        private _center = [_x, "center"] call ALIVE_fnc_hashGet;
                        private _clusterSize = [_x, "size"] call ALIVE_fnc_hashGet;
                        if (isNil "_clusterSize" || {_clusterSize isEqualType ""}) then { _clusterSize = 200 };

                        // Per-cluster herd count = base + random bonus,
                        // both scaled by the amount setting. The base
                        // guarantees a minimum density at any non-zero
                        // setting (so HIGH feels like "many"); the
                        // bonus adds spread.
                        //   LOW    (0.2): base 1 + 0       = 1 / cluster
                        //   MEDIUM (0.6): base 2 + 0..2    = 2-4 / cluster
                        //   HIGH   (1.0): base 3 + 0..4    = 3-7 / cluster
                        private _herdBase = ceil (_ambientAnimalAmount * 3);
                        private _herdBonus = floor (random (_ambientAnimalAmount * 5));
                        private _herdCount = _herdBase + _herdBonus;

                        for "_h" from 1 to _herdCount do {
                            _herdsTried = _herdsTried + 1;

                            // Spawn radius: cluster_size + 50 to
                            // cluster_size + 350. Wider band than
                            // before so terrain that has a long
                            // approach (ridge / valley) gets at least
                            // some open ground in the sample range.
                            // 10 attempts to dodge water; first one
                            // usually wins on land terrains.
                            private _herdPos = [];
                            for "_a" from 1 to 10 do {
                                private _candidate = _center getPos [_clusterSize + 50 + random 300, random 360];
                                if !(surfaceIsWater _candidate) exitWith {
                                    _herdPos = _candidate;
                                };
                            };

                            if !(_herdPos isEqualTo []) then {
                                private _animalClass = selectRandom _herdPool;
                                // Herds bigger than poultry groups -
                                // sheep flocks of 2-5 read more
                                // naturally than 1-2 lone goats.
                                private _groupSize = 2 + floor (random 4);
                                ALiVE_AMBCP_animalRegistry pushBack [_herdPos, _animalClass, _groupSize, [], "herd"];
                                _countHerd = _countHerd + _groupSize;
                                _herdsPlaced = _herdsPlaced + 1;

                                // Debug map marker at each herd spawn so the
                                // mission-maker can find them via the Eden /
                                // mission map. Server-created markers are
                                // global. Markers stay around for the
                                // session - cheap visualisation aid that's
                                // only created when module debug is on.
                                if (_debug) then {
                                    private _markerName = format ["ALIVE_AMBCP_herd_%1_%2", floor diag_tickTime * 1000, _herdsPlaced];
                                    createMarker [_markerName, _herdPos];
                                    _markerName setMarkerType "mil_triangle";
                                    _markerName setMarkerColor "ColorCIV";
                                    _markerName setMarkerText format ["%1x %2", _groupSize, _animalClass];
                                };
                            };
                        };
                    } forEach _clusters;

                    if (_debug) then {
                        ["AMBCP - Herds: tried %1 placed %2 across %3 clusters", _herdsTried, _herdsPlaced, count _clusters] call ALiVE_fnc_dump;
                    };
                };

                // Player-proximity spawn / despawn handler. Walks the
                // registry every 30 s. For each entry:
                //   - any player within 1500 m AND empty -> spawn
                //   - no player within 2000 m AND populated -> delete
                // The 500 m hysteresis avoids flicker at the boundary.
                // Server-only; clients see the spawned units via the
                // engine's normal network replication.
                //
                // Guard prevents the handler from being attached
                // twice if the start case fires more than once
                // (mission load, debug re-init, etc).
                if (isNil "ALiVE_AMBCP_animalHandlerAttached") then {
                    ALiVE_AMBCP_animalHandlerAttached = true;

                    ALiVE_AMBCP_fnc_animalUpdate = {
                        {
                            _x params ["_pos", "_class", "_count", "_units", "_kind"];
                            private _activate   = (allPlayers findIf { alive _x && {(_x distance _pos) < 1500} }) >= 0;
                            private _deactivate = (allPlayers findIf { alive _x && {(_x distance _pos) < 2000} }) <  0;

                            if (_activate && {count _units == 0}) then {
                                // createAgent is lighter than createUnit:
                                // no group attachment, no group AI tick.
                                // Animals (Animal_Base_F subclasses) are
                                // CAManBase-ancestor types so createAgent
                                // works on them.
                                private _spread = if (_kind == "herd") then { 12 } else { 4 };
                                private _half = _spread / 2;
                                private _newUnits = [];
                                for "_i" from 1 to _count do {
                                    private _offset = _pos vectorAdd [(random _spread) - _half, (random _spread) - _half, 0];
                                    _newUnits pushBack (createAgent [_class, _offset, [], 0, "CAN_COLLIDE"]);
                                };
                                _x set [3, _newUnits];
                            };

                            if (_deactivate && {count _units > 0}) then {
                                { deleteVehicle _x } forEach _units;
                                _x set [3, []];
                            };
                        } forEach ALiVE_AMBCP_animalRegistry;
                    };

                    [] call ALiVE_AMBCP_fnc_animalUpdate;
                    [ALiVE_AMBCP_fnc_animalUpdate, 30] call CBA_fnc_addPerFrameHandler;
                };

                if (_debug) then {
                    ["AMBCP - Placed %1 ambient animals (poultry: %2, herds: %3, amount: %4)", _countPoultry + _countHerd, _countPoultry, _countHerd, _ambientAnimalAmount] call ALiVE_fnc_dump;
                };
            };

            // Place ambient civilians

            // Scope bump for known civilian factions whose generic Man units
            // have scope = 1 (BI internal) but need to appear in the spawn
            // class list. Kept as defensive guard even though the original
            // trigger (issue #522, BI population module CIV_F side 7) was
            // resolved engine-side.
            private _minScope = 1;
            if (_faction == "CIV_F" || _faction == "C_VIET" || _faction == "SPE_CIV") then {_minScope = 2};

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

                            // Add persistent name to civ. Defensive path:
                            // genericNames may be defined as either text (class
                            // name pointing to CfgWorlds >> GenericNames) or as
                            // an array (some third-party unit configs); handle
                            // both. Also guard against missing GenericNames
                            // sub-config or empty FirstNames / LastNames lists
                            // so non-conforming factions don't silently assign
                            // empty names.
                            private _genNamesProperty = configFile >> "CfgVehicles" >> _unitClass >> "genericNames";
                            private _genName = "";
                            if (isText _genNamesProperty) then {
                                _genName = getText _genNamesProperty;
                            };
                            if (isArray _genNamesProperty) then {
                                _genName = (getArray _genNamesProperty) param [0, ""];
                            };

                            private _firstName = "";
                            private _lastName = "";
                            private _genNamesCfg = configFile >> "CfgWorlds" >> "GenericNames" >> _genName;
                            if (isClass _genNamesCfg) then {
                                private _firstNamesCfg = _genNamesCfg >> "FirstNames";
                                private _lastNamesCfg = _genNamesCfg >> "LastNames";
                                if (count _firstNamesCfg > 0) then {
                                    _firstName = getText (_firstNamesCfg select floor random count _firstNamesCfg);
                                };
                                if (count _lastNamesCfg > 0) then {
                                    _lastName = getText (_lastNamesCfg select floor random count _lastNamesCfg);
                                };
                            };

                            [_agent, "firstName", _firstName] call ALIVE_fnc_civilianAgent;
                            [_agent, "lastName", _lastName] call ALIVE_fnc_civilianAgent;

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

            ["AMBCP [%1] - Ambient land vehicles placed: %2",_faction,_countLandUnits] call ALiVE_fnc_dump;
            ["AMBCP [%1] - Ambient civilian units placed: %2",_faction,_countCivilianUnits] call ALiVE_fnc_dump;

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["AMBCP - Placement completed"] call ALiVE_fnc_dump;
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