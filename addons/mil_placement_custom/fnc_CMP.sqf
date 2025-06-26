//#define DEBUG_MPDE_FULL
#include "\x\alive\addons\mil_placement_custom\script_component.hpp"
SCRIPT(CMP);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_CMP
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
[_logic, "faction", "OPF_F"] call ALiVE_fnc_CMP;

See Also:
- <ALIVE_fnc_CMPInit>

Author:
ARJay
---------------------------------------------------------------------------- */

#define SUPERCLASS                      ALIVE_fnc_baseClass
#define MAINCLASS                       ALIVE_fnc_CMP
#define MTEMPLATE                       "ALiVE_CMP_%1"
#define DEFAULT_FACTION                 QUOTE(OPF_F)
#define DEFAULT_SIZE                    "50"
#define DEFAULT_PRIORITY                "50"
#define DEFAULT_NO_TEXT                 "0"
#define DEFAULT_COMPOSITION             false
#define DEFAULT_OBJECTIVES              []
#define DEFAULT_READINESS_LEVEL         "1"
#define DEFAULT_AMBIENT_VEHICLE_AMOUNT  "0.2"
#define DEFAULT_HQ_BUILDING             objNull
#define DEFAULT_HQ_CLUSTER              []
#define DEFAULT_AMBIENT_GUARD_AMOUNT "0.2"
#define DEFAULT_AMBIENT_GUARD_RADIUS "200"
#define DEFAULT_AMBIENT_GUARD_PATROL_PERCENT "50"

TRACE_1("CMP - input",_this);

params [
    ["_logic", objNull, [objNull]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

private _result = true;

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

    case "faction": {
        _result = [_logic,_operation,_args,DEFAULT_FACTION,[] call ALiVE_fnc_configGetFactions] call ALIVE_fnc_OOsimpleOperation;
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

    case "size": {
        _result = [_logic,_operation,_args,DEFAULT_SIZE] call ALIVE_fnc_OOsimpleOperation;
    };

    case "priority": {
        _result = [_logic,_operation,_args,DEFAULT_PRIORITY] call ALIVE_fnc_OOsimpleOperation;
    };

    case "readinessLevel": {
        _result = [_logic,_operation,_args,DEFAULT_READINESS_LEVEL] call ALIVE_fnc_OOsimpleOperation;
    };

    // Return the Ambient Vehicle Amount
    case "ambientVehicleAmount": {
        _result = [_logic,_operation,_args,DEFAULT_AMBIENT_VEHICLE_AMOUNT] call ALIVE_fnc_OOsimpleOperation;
    };

    // Return the HQ Building
    case "HQBuilding": {
        _result = [_logic,_operation,_args,DEFAULT_HQ_BUILDING] call ALIVE_fnc_OOsimpleOperation;
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

    case "composition": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["composition", _args];
        } else {
            _args = _logic getVariable ["composition", false];
        };
        if (typeName _args == "STRING") then {
                _logic setVariable ["composition", _args];
        };

        // Catch a bug that was introduced by the conversion of the
        // "composition" module field from dropdown to text field
        if (_args == "false") then {
            _logic setVariable ["composition", ""];
            _args = "";
        };

        _result = _args;
    };

    case "objectives": {
        _result = [_logic,_operation,_args,DEFAULT_OBJECTIVES] call ALIVE_fnc_OOsimpleOperation;
    };

    case "allowPlayerTasking": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["allowPlayerTasking", _args];
        } else {
            _args = _logic getVariable ["allowPlayerTasking", true];
        };

        if (typeName _args == "STRING") then {
            if (_args == "true") then {
                _args = true;
            }
            else {
                _args = false;
            };

            _logic setVariable ["allowPlayerTasking", _args];
        };

        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };

    // Main process
    case "init": {

        if (isServer) then {
            // if server, initialise module game logic
            _logic setVariable ["super", SUPERCLASS];
            _logic setVariable ["class", MAINCLASS];
            _logic setVariable ["moduleType", "ALIVE_CMP"];
            _logic setVariable ["startupComplete", false];

            TRACE_1("After module init",_logic);

            if !(["ALiVE_sys_profile"] call ALiVE_fnc_isModuleAvailable) exitwith {
                ["Profile System module not placed! Exiting..."] call ALiVE_fnc_DumpR;
                _logic setVariable ["startupComplete", true];
            };

            waituntil {!(isnil "ALiVE_ProfileHandler") && {[ALiVE_ProfileSystem,"startupComplete",false] call ALIVE_fnc_hashGet}};

            [_logic,"start"] call MAINCLASS;
        };

    };

    case "start": {

        if (isServer) then {

            private _debug = [_logic, "debug"] call MAINCLASS;

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                ["CMP - Startup"] call ALiVE_fnc_dump;
                [true] call ALIVE_fnc_timer;
            };
            // DEBUG -------------------------------------------------------------------------------------

            if (isNil "ALIVE_clustersMilCustom") then {
                ALIVE_clustersMilCustom = [] call ALIVE_fnc_hashCreate;
            };

            // instantiate static vehicle position data
            if(isNil "ALIVE_groupConfig") then {
                [] call ALIVE_fnc_groupGenerateConfigData;
            };

            // all CMP modules execute at the same time
            // ALIVE_groupConfig is created, but not 100% filled
            // before the rest of the modules start creating their profiles

            waitUntil {!isnil "ALiVE_GROUP_CONFIG_DATA_GENERATED"};

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
                ["CMP - Placement"] call ALiVE_fnc_dump;
                [true] call ALIVE_fnc_timer;
            };
            // DEBUG -------------------------------------------------------------------------------------

            private _guardProbability = parseNumber([_logic, "guardProbability"] call MAINCLASS);

            private _countInfantry = [_logic, "customInfantryCount"] call MAINCLASS;
            _countInfantry = parseNumber _countInfantry;
            
            private _countMotorized = [_logic, "customMotorisedCount"] call MAINCLASS;
            _countMotorized = parseNumber _countMotorized;

            private _countMechanized = [_logic, "customMechanisedCount"] call MAINCLASS;
            _countMechanized = parseNumber _countMechanized;

            private _countArmored = [_logic, "customArmourCount"] call MAINCLASS;
            _countArmored = parseNumber _countArmored;

            private _countSpecOps = [_logic, "customSpecOpsCount"] call MAINCLASS;
            _countSpecOps = parseNumber _countSpecOps;

            private _faction = [_logic, "faction"] call MAINCLASS;
            private _size = [_logic, "size"] call MAINCLASS;
            
            
            private _guardProbabilityCount = [_countInfantry,[_logic, "guardProbability"] call MAINCLASS] call ALIVE_fnc_infantryGuardProbabilityCount;
            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
	            ["CMP [%1] - Garrison _guardProbabilityCount: %2", _faction, _guardProbabilityCount] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------
            
            if (_guardProbabilityCount > 0) then {
              _countInfantry = _countInfantry - _guardProbabilityCount;
            };  
            

            if(typeName _size == "STRING") then {
                _size = parseNumber _size;
            };

            private _priority = [_logic, "priority"] call MAINCLASS;

            if(typeName _priority == "STRING") then {
                _priority = parseNumber _priority;
            };

            private _composition = [_logic, "composition"] call MAINCLASS;
            private _ambientVehicleAmount = parseNumber([_logic, "ambientVehicleAmount"] call MAINCLASS);
            private _createHQ = [_logic, "createHQ"] call MAINCLASS;
            private _placeHelis = [_logic, "placeHelis"] call MAINCLASS;
            private _placeSupplies = [_logic, "placeSupplies"] call MAINCLASS;
            private _factionConfig = _faction call ALiVE_fnc_configGetFactionClass;
            private _factionSideNumber = getNumber(_factionConfig >> "side");
            private _side = _factionSideNumber call ALIVE_fnc_sideNumberToText;
            private _countProfiles = 0;
            private _position = position _logic;
            private _allowPlayerTasking = [_logic, "allowPlayerTasking"] call MAINCLASS;

            // Load static data
            call ALiVE_fnc_staticDataHandler;

            // Spawn the composition

            if (typeName _composition == "STRING" && _composition != "" && _composition != "false") then {
                if (isNil QMOD(COMPOSITIONS_LOADED)) then {
                    // Get a composition
                    private _compType = "Military";
                    If (_faction call ALiVE_fnc_factionSide == RESISTANCE) then {
                        _compType = "Guerrilla";
                    };

                    private _comp = [_composition, _compType] call ALIVE_fnc_findComposition;

                    if (count _comp > 0) then {
                        [_comp, _position, direction _logic, _faction] call ALIVE_fnc_spawnComposition;
                    } else {
                        private _compDef = ([_compType, [_composition], [], _faction] call ALiVE_fnc_getCompositions);

                        if (count _compDef > 0) then {
                            [(selectRandom _compDef), _position, direction _logic, _faction] call ALIVE_fnc_spawnComposition;
                        } else {
                            ["CMP: Custom composition '%1' not found!", _composition] call ALiVE_fnc_dump;
                        };
                    };
                };
            };


            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["CMP [%1] - Size: %1 Priority: %2",_size,_priority] call ALiVE_fnc_dump;
                ["CMP [%1] - SideNum: %1 Side: %2 Faction: %3 Composition: %4",_factionSideNumber,_side,_faction,_composition] call ALiVE_fnc_dump;
                ["CMP Allow player tasking: %1", _allowPlayerTasking] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            // assign the objective to OPCOMS
            /*

            for "_i" from 0 to ((count synchronizedObjects _logic)-1) do {
                private _moduleObject = (synchronizedObjects _logic) select _i;

                waituntil {_module = _moduleObject getVariable "handler"; !(isnil "_module")};
                _private module = _moduleObject getVariable "handler";

                private _objectiveName = format["CUSTOM_%1",floor((_position select 0) + (_position select 1))];
                private _objective = [_objectiveName, _position, _size, "MIL", _priority];

                [_module,"addObjective",_objective] call ALiVE_fnc_OPCOM;
            };
            */

            private _objectiveName = format["CUSTOM_%1",floor((_position select 0) + (_position select 1))];

            private _cluster = [nil, "create"] call ALIVE_fnc_cluster;
            [_cluster,"nodes", (nearestObjects [_position,["static"],_size])] call ALIVE_fnc_hashSet;
            [_cluster,"clusterID", _objectiveName] call ALIVE_fnc_hashSet;
            [_cluster,"center", _position] call ALIVE_fnc_hashSet;
            [_cluster,"size", _size] call ALIVE_fnc_hashSet;
            [_cluster,"type", "MIL"] call ALIVE_fnc_hashSet;
            [_cluster,"priority", _priority] call ALIVE_fnc_hashSet;
            [_cluster,"allowPlayerTasking", _allowPlayerTasking] call ALIVE_fnc_hashSet;
            [_cluster,"debug", _debug] call ALIVE_fnc_cluster;

            [_logic, "objectives", [_cluster]] call MAINCLASS;

            [ALIVE_clustersMilCustom, _objectiveName, _cluster] call ALIVE_fnc_hashSet;

            if(ALIVE_loadProfilesPersistent) exitWith {

                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then { ["CMP - Profiles are persistent, no creation of profiles"] call ALiVE_fnc_dump; };
                // DEBUG -------------------------------------------------------------------------------------

                // set module as started
                _logic setVariable ["startupComplete", true];

            };


            // Spawn the main force

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["CMP [%1] - Force creation ",_faction] call ALiVE_fnc_dump;
                ["CMP Count Armor: %1",_countArmored] call ALiVE_fnc_dump;
                ["CMP Count Mech: %1",_countMechanized] call ALiVE_fnc_dump;
                ["CMP Count Motor: %1",_countMotorized] call ALiVE_fnc_dump;
                ["CMP Count Infantry: %1",_countInfantry] call ALiVE_fnc_dump;
                ["CMP Count Garrison Infantry: %1",_guardProbabilityCount] call ALIVE_fnc_dump;
                ["CMP Count Spec Ops: %1",_countSpecOps] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            // Assign groups
            private _groups = [];
            private _infantryGroups = [];
            private _motorizedGroups = [];

            for "_i" from 0 to _countInfantry -1 do {
                private _group = ["Infantry",_faction] call ALIVE_fnc_configGetRandomGroup;
                if!(_group == "FALSE") then {
                    _infantryGroups pushback _group;
                };
            };

            for "_i" from 0 to _countSpecOps -1 do {
                private _group = ["SpecOps",_faction] call ALIVE_fnc_configGetRandomGroup;
                if!(_group == "FALSE") then {
                    _infantryGroups pushback _group;
                };
            };

            _groups append _infantryGroups;

            for "_i" from 0 to _countMotorized -1 do {
                private _group = ["Motorized",_faction] call ALIVE_fnc_configGetRandomGroup;
                if!(_group == "FALSE") then {
                    _motorizedGroups pushback _group;
                };
            };

            if(count _motorizedGroups == 0) then {
                for "_i" from 0 to _countMotorized -1 do {
                    private _group = ["Motorized_MTP",_faction] call ALIVE_fnc_configGetRandomGroup;
                    if!(_group == "FALSE") then {
                        _motorizedGroups pushback _group;
                    };
                };
            };

            _groups append _motorizedGroups;

            for "_i" from 0 to _countMechanized -1 do {
                private _group = ["Mechanized",_faction] call ALIVE_fnc_configGetRandomGroup;
                if!(_group == "FALSE") then {
                    _groups pushback _group;
                }
            };

            for "_i" from 0 to _countArmored -1 do {
                private _group = ["Armored",_faction] call ALIVE_fnc_configGetRandomGroup;
                if!(_group == "FALSE") then {
                    _groups pushback _group;
                };
            };

            _infantryGroups = _infantryGroups - ALiVE_PLACEMENT_GROUPBLACKLIST;
            _motorizedGroups = _motorizedGroups - ALiVE_PLACEMENT_GROUPBLACKLIST;
            _groups = _groups - ALiVE_PLACEMENT_GROUPBLACKLIST;

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["CMP [%1] - Groups ",_groups] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
              ["CMP [%1] - Garrison _guardProbabilityCount: %2", _faction, _guardProbabilityCount] call ALiVE_fnc_dump;           
            };
            // DEBUG -------------------------------------------------------------------------------------
                    
            private _guardRadius = parseNumber([_logic, "guardRadius"] call MAINCLASS);
            private _guardPatrolPercentage = parseNumber([_logic, "guardPatrolPercentage"] call MAINCLASS);
            private _guardDistance = parseNumber([_logic, "size"] call MAINCLASS);
                
            // Position and create groups
            private _groupCount = count _groups;
            private _totalCount = 0;

            if(_groupCount > 0) then {
                // Guards
                if (count _infantryGroups > 0 && _guardProbabilityCount > 0) then {
                    for "_i" from 0 to _guardProbabilityCount -1 do {
                        _guardGroup = (selectRandom _infantryGroups);
                        _guards = [_guardGroup, [_position, _guardDistance] call CBA_fnc_RandPos, random(360), true, _faction] call ALIVE_fnc_createProfilesFromGroupConfig;

                        // DEBUG -------------------------------------------------------------------------------------
                        if(_debug) then {
                            ["CMP [%1] - Placing Garrison Guards - %2", _faction, _guardGroup] call ALiVE_fnc_dump;
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

                // Main Force
                private _readiness = parseNumber([_logic, "readinessLevel"] call MAINCLASS);
                _readiness = (1 - _readiness) * _groupCount;

                for "_i" from 0 to (_groupCount - 1) do {

                    private ["_command","_radius"];

                    private _group = _groups select _i;

                    if (_totalCount < _readiness) then {
                        _command = "ALIVE_fnc_garrison";
                        // _radius = [200,"true",[0,0,0]];
                      _radius = [_guardRadius,"true",[0,0,0],"",_guardProbabilityCount, _guardPatrolPercentage];
                      _position = [position _logic, 30] call CBA_fnc_RandPos;
                    } else {
                        _command = "ALIVE_fnc_ambientMovement";
                        // _radius = [200,"SAFE",[0,0,0]];
                        _radius = [_guardRadius,"SAFE",[0,0,0]];
                      _position = [position _logic, random((_radius select 0) + ((_radius select 0)/0.25)), random(360)] call BIS_fnc_relPos;
                      
                      // DEBUG -------------------------------------------------------------------------------------
                      if(_debug) then {
                        ["CMP %2 - No more empty buildings (CMP-01), lets patrol! calling ALIVE_fnc_ambientMovement, _guardRadius: %1", _guardRadius, _faction] call ALiVE_fnc_dump;
                      };
                      // DEBUG -------------------------------------------------------------------------------------
                    };

                    if !(surfaceIsWater _position) then {

                        private _profiles = [_group, _position, random(360), false, _faction] call ALIVE_fnc_createProfilesFromGroupConfig;

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

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["CMP - Total profiles created: %1",_countProfiles] call ALiVE_fnc_dump;
                ["CMP - Placement completed"] call ALiVE_fnc_dump;
                [] call ALIVE_fnc_timer;
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------

            // Create HQ

            if(_createHQ) then {

                private _modulePosition = position _logic;

                private _nodes = [_cluster, "nodes"] call ALIVE_fnc_hashGet;

                private _buildings = [_nodes, ALIVE_militaryHQBuildingTypes] call ALIVE_fnc_findBuildingsInClusterNodes;

                _buildings = [_buildings,[_modulePosition],{_Input0 distance _x},"ASCENDING",{[_x] call ALIVE_fnc_isHouseEnterable}] call ALiVE_fnc_SortBy;

                if (count _buildings == 0) then {_buildings = [_modulePosition, _size, ALIVE_militaryBuildingTypes + ALIVE_militaryHQBuildingTypes] call ALIVE_fnc_findNearObjectsByType};

                if (count _buildings == 0) then {
                    ["CMP - Warning no HQ locations found, spawning composition"] call ALiVE_fnc_dump;

                    if (isNil QMOD(COMPOSITIONS_LOADED)) then {

                        // Get a composition
                        private _compType = "Military";
                        If (_faction call ALiVE_fnc_factionSide == RESISTANCE) then {
                            _compType = "Guerrilla";
                        };
                        private _HQ = (selectRandom ([_compType, ["FieldHQ"], ["Large","Medium"], _faction] call ALiVE_fnc_getCompositions));

                        if (isNil "_HQ") then {
                            _HQ = (selectRandom ([_compType, ["HQ","FieldHQ"], ["Medium","Small"], _faction] call ALiVE_fnc_getCompositions));
                        };

                        [_HQ, _modulePosition, direction _logic, _faction] call ALiVE_fnc_spawnComposition;

                        _buildings = [_modulePosition, _size, ALIVE_militaryBuildingTypes + ALIVE_militaryHQBuildingTypes] call ALIVE_fnc_findNearObjectsByType;
                    };
                };

                if (count _buildings > 0) then {

                    private _hqBuilding = _buildings select 0;


                    // DEBUG -------------------------------------------------------------------------------------
                    if(_debug) then {
                        [position _hqBuilding, 4] call ALIVE_fnc_placeDebugMarker;
                    };
                    // DEBUG -------------------------------------------------------------------------------------

                    if(_hqBuilding in _nodes) then {
                        [_cluster, "priority",1000] call ALIVE_fnc_hashSet;
                    };

                    [_logic, "HQBuilding", _hqBuilding] call MAINCLASS;
                } else {
                    ["CMP - Warning no HQ locations found"] call ALiVE_fnc_dump;
                };

            };

            // Spawn supplies in objectives

            private _countSupplies = 0;

            if(_placeSupplies) then {

                // attempt to get supplies by faction
                private _supplyClasses = [ALIVE_factionDefaultSupplies,_faction,[]] call ALIVE_fnc_hashGet;

                //["SUPPLY CLASSES: %1",_supplyClasses] call ALIVE_fnc_dump;

                // if no supplies found for the faction use side supplies
                if(count _supplyClasses == 0) then {
                    _supplyClasses = [ALIVE_sideDefaultSupplies,_side] call ALIVE_fnc_hashGet;
                };

                _supplyClasses = _supplyClasses - ALiVE_PLACEMENT_VEHICLEBLACKLIST;

                if(count _supplyClasses > 0) then {

                        private _nodes = [_cluster, "nodes"] call ALIVE_fnc_hashGet;

                        private _buildings = [_nodes, ALIVE_militarySupplyBuildingTypes] call ALIVE_fnc_findBuildingsInClusterNodes;

                        //["BUILDINGS: %1",_buildings] call ALIVE_fnc_dump;

                        //[_x, "debug", true] call ALIVE_fnc_cluster;
                        {
                            private _position = position _x;
                            private _direction = direction _x;
                            private _vehicleClass = (selectRandom _supplyClasses);

                            if(random 1 > 0.3) then {
                                private _box = createVehicle [_vehicleClass, _position, [], 0, "NONE"];
                                _countSupplies = _countSupplies + 1;
                            };
                        } forEach _buildings;

                };
            };

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["CMP [%1] - Supplies placed: %2",_faction,_countSupplies] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            // Spawn helicopters on pads

            private _countCrewedHelis = 0;
            private _countUncrewedHelis = 0;

            if(_placeHelis) then {

                private _heliClasses = [0,_faction,"Helicopter"] call ALiVE_fnc_findVehicleType;
                _heliClasses = _heliClasses - ALiVE_PLACEMENT_VEHICLEBLACKLIST;

                if(count _heliClasses > 0) then {

                    private _nodes = [_cluster, "nodes"] call ALIVE_fnc_hashGet;

                    //[_x, "debug", true] call ALIVE_fnc_cluster;
                    {
                        if (typeOf _x in ALIVE_militaryHeliBuildingTypes || typeOf _x in ALIVE_civilianHeliBuildingTypes || typeOf _x in ["Land_HelipadSquare_F","Land_HelipadCircle_F"]) then {
                            private _position = position _x;
                            private _direction = direction _x;
                            private _vehicleClass = (selectRandom _heliClasses);

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
                    } forEach _nodes;

                };
            };


            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["CMP [%1] - Heli units placed: crewed:%2 uncrewed:%3",_faction,_countCrewedHelis,_countUncrewedHelis] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------

            // Spawn ambient vehicles

            private _countLandUnits = 0;

            if(_ambientVehicleAmount > 0) then {

                private _carClasses = [0,_faction,"Car"] call ALiVE_fnc_findVehicleType;
                private _armorClasses = [0,_faction,"Tank"] call ALiVE_fnc_findVehicleType;

                private _landClasses = _carClasses + _armorClasses;
                _landClasses = _landClasses - ALiVE_PLACEMENT_VEHICLEBLACKLIST;

                private _supportClasses = [ALIVE_factionDefaultSupports,_faction,[]] call ALIVE_fnc_hashGet;

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

                    private _supportCount = 0;
                    private _supportMax = 0;

                    private _nodes = [_cluster, "nodes"] call ALIVE_fnc_hashGet;

                    private _buildings = [_nodes, ALIVE_militaryParkingBuildingTypes] call ALIVE_fnc_findBuildingsInClusterNodes;

                    //["BUILDINGS: %1",_buildings] call ALIVE_fnc_dump;

                    private _countBuildings = count _buildings;
                    private _parkingChance = 0.1 * _ambientVehicleAmount;

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
                        _parkingChance = 0.8 * _ambientVehicleAmount;
                    };

                    //["SUPPORT MAX: %1",_supportMax] call ALIVE_fnc_dump;
                    //["CHANCE: %1",_parkingChance] call ALIVE_fnc_dump;

                    private _usedPositions = [];

                    {
                        private ["_vehicleClass"];

                        if(random 1 < _parkingChance) then {

                            private _building = _x;

                            private _supportPlacement = false;

                            if(_supportCount <= _supportMax) then {
                                _supportPlacement = true;
                                _vehicleClass = (selectRandom _supportClasses);
                            }else{
                                _vehicleClass = (selectRandom _landClasses);
                            };

                            //["SUPPORT PLACEMENT: %1",_supportPlacement] call ALIVE_fnc_dump;
                            //["VEHICLE CLASS: %1",_vehicleClass] call ALIVE_fnc_dump;

                            private _parkingPosition = [_vehicleClass,_building,[]] call ALIVE_fnc_getParkingPosition;

                            if (count _parkingPosition == 2) then {

                                private _positionOK = true;

                                {
                                    private _position = _x select 0;
                                    if((_parkingPosition select 0) distance _position < 10) then {
                                        _positionOK = false;
                                    };
                                } forEach _usedPositions;

                                //["POS OK: %1",_positionOK] call ALIVE_fnc_dump;

                                if(_positionOK) then {
                                    [_vehicleClass,_side,_faction,_parkingPosition select 0,_parkingPosition select 1,false,_faction,[],true] call ALIVE_fnc_createProfileVehicle;

                                    _countLandUnits = _countLandUnits + 1;

                                    _usedPositions pushback _parkingPosition;

                                    if(_supportPlacement) then {
                                        _supportCount = _supportCount + 1;
                                    };
                                };

                            };
                        };

                    } forEach _buildings;

                };
            };


            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["CMP [%1] - Ambient land units placed: %2",_faction,_countLandUnits] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------

            // set module as started
            _logic setVariable ["startupComplete", true];

        };

    };

};

TRACE_1("CMP - output",_result);

_result;
