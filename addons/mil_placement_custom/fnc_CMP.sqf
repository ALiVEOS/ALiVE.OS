//#define DEBUG_MPDE_FULL
#include <\x\alive\addons\mil_placement_custom\script_component.hpp>
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

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_CMP
#define MTEMPLATE "ALiVE_CMP_%1"
#define DEFAULT_FACTION QUOTE(OPF_F)
#define DEFAULT_SIZE "50"
#define DEFAULT_PRIORITY "50"
#define DEFAULT_NO_TEXT "0"
#define DEFAULT_COMPOSITION false
#define DEFAULT_OBJECTIVES []
#define DEFAULT_READINESS_LEVEL "1"
#define DEFAULT_AMBIENT_VEHICLE_AMOUNT "0.2"
#define DEFAULT_HQ_BUILDING objNull
#define DEFAULT_HQ_CLUSTER []

private ["_logic","_operation","_args","_result"];

TRACE_1("CMP - input",_this);

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
		_result = [_logic,_operation,_args,DEFAULT_FACTION,[] call BIS_fnc_getFactions] call ALIVE_fnc_OOsimpleOperation;
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

        _result = _args;
    };
    case "objectives": {
        _result = [_logic,_operation,_args,DEFAULT_OBJECTIVES] call ALIVE_fnc_OOsimpleOperation;
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

			private ["_debug"];

			_debug = [_logic, "debug"] call MAINCLASS;

			// DEBUG -------------------------------------------------------------------------------------
			if(_debug) then {
				["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
				["ALIVE CMP - Startup"] call ALIVE_fnc_dump;
				[true] call ALIVE_fnc_timer;
			};
			// DEBUG -------------------------------------------------------------------------------------

            // instantiate static vehicle position data
            if(isNil "ALIVE_groupConfig") then {
                [] call ALIVE_fnc_groupGenerateConfigData;
            };

            [_logic, "placement"] call MAINCLASS;
        };
	};
	// Placement
	case "placement": {
        if (isServer) then {

			private ["_debug","_countInfantry","_countMotorized","_countMechanized","_countArmored","_countSpecOps",
			"_faction","_factionConfig","_factionSideNumber","_side","_countProfiles","_file","_size","_priority",
			"_position","_moduleObject","_module","_objectiveName","_objective","_guardGroup","_guards","_composition"];

			_debug = [_logic, "debug"] call MAINCLASS;

			// DEBUG -------------------------------------------------------------------------------------
			if(_debug) then {
				["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
				["ALIVE CMP - Placement"] call ALIVE_fnc_dump;
				[true] call ALIVE_fnc_timer;
			};
			// DEBUG -------------------------------------------------------------------------------------

			_countInfantry = [_logic, "customInfantryCount"] call MAINCLASS;
            _countInfantry = parseNumber _countInfantry;

            _countMotorized = [_logic, "customMotorisedCount"] call MAINCLASS;
            _countMotorized = parseNumber _countMotorized;

            _countMechanized = [_logic, "customMechanisedCount"] call MAINCLASS;
            _countMechanized = parseNumber _countMechanized;

            _countArmored = [_logic, "customArmourCount"] call MAINCLASS;
            _countArmored = parseNumber _countArmored;

            _countSpecOps = [_logic, "customSpecOpsCount"] call MAINCLASS;
            _countSpecOps = parseNumber _countSpecOps;

			_faction = [_logic, "faction"] call MAINCLASS;
			_size = [_logic, "size"] call MAINCLASS;

			if(typeName _size == "STRING") then {
                _size = parseNumber _size;
            };

			_priority = [_logic, "priority"] call MAINCLASS;

			if(typeName _priority == "STRING") then {
                _priority = parseNumber _priority;
            };

            _composition = [_logic, "composition"] call MAINCLASS;
			_ambientVehicleAmount = parseNumber([_logic, "ambientVehicleAmount"] call MAINCLASS);
			_createHQ = [_logic, "createHQ"] call MAINCLASS;
			_placeHelis = [_logic, "placeHelis"] call MAINCLASS;
			_placeSupplies = [_logic, "placeSupplies"] call MAINCLASS;
			_factionConfig = (configFile >> "CfgFactionClasses" >> _faction);
			_factionSideNumber = getNumber(_factionConfig >> "side");
			_side = _factionSideNumber call ALIVE_fnc_sideNumberToText;
			_countProfiles = 0;
			_position = position _logic;

            // Spawn the composition

			if (typeName _composition == "STRING" && _composition != "false") then {

			    private ["_bisCompositions","_configPath"];

			    _bisCompositions = ["OutpostA","OutpostB","OutpostC","OutpostD","OutpostE","OutpostF"];

			    if(_composition in _bisCompositions) then {

                    _configPath = configFile >> "CfgGroups" >> "Empty" >> "Military" >> "Outposts";
                    _composition = _configPath >> _composition;
                     [_composition, _position, direction _logic] call ALIVE_fnc_spawnComposition;

			    }else{

                    _composition = [_composition] call ALIVE_fnc_findComposition;

                    if(count _composition > 0) then {
                        [_composition, _position, direction _logic] call ALIVE_fnc_spawnComposition;
                    };

			    };

			};


			// DEBUG -------------------------------------------------------------------------------------
			if(_debug) then {
			    ["ALIVE CMP [%1] - Size: %1 Priority: %2",_size,_priority] call ALIVE_fnc_dump;
				["ALIVE CMP [%1] - SideNum: %1 Side: %2 Faction: %3 Composition: %4",_factionSideNumber,_side,_faction,_composition] call ALIVE_fnc_dump;
			};
			// DEBUG -------------------------------------------------------------------------------------


			// Load static data

			if(isNil "ALiVE_STATIC_DATA_LOADED") then {
				_file = "\x\alive\addons\main\static\staticData.sqf";
				call compile preprocessFileLineNumbers _file;
			};

			// assign the objective to OPCOMS
			/*

            for "_i" from 0 to ((count synchronizedObjects _logic)-1) do {
                _moduleObject = (synchronizedObjects _logic) select _i;

                waituntil {_module = _moduleObject getVariable "handler"; !(isnil "_module")};
                _module = _moduleObject getVariable "handler";

                _objectiveName = format["CUSTOM_%1",floor((_position select 0) + (_position select 1))];
                _objective = [_objectiveName, _position, _size, "MIL", _priority];

                [_module,"addObjective",_objective] call ALiVE_fnc_OPCOM;
            };
            */

            private ["_clusters","_cluster"];

            _clusters = [];

            _objectiveName = format["CUSTOM_%1",floor((_position select 0) + (_position select 1))];

            _cluster = [nil, "create"] call ALIVE_fnc_cluster;
			[_cluster,"nodes",nearestObjects [_position,["static"],_size]] call ALIVE_fnc_hashSet;
            [_cluster,"clusterID",_objectiveName] call ALIVE_fnc_hashSet;
            [_cluster,"center",_position] call ALIVE_fnc_hashSet;
            [_cluster,"size",_size] call ALIVE_fnc_hashSet;
            [_cluster,"type","MIL"] call ALIVE_fnc_hashSet;
            [_cluster,"priority",_priority] call ALIVE_fnc_hashSet;

            _clusters set [0,_cluster];

            [_logic, "objectives", _clusters] call MAINCLASS;


            if(ALIVE_loadProfilesPersistent) exitWith {

                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then { ["ALIVE CMP - Profiles are persistent, no creation of profiles"] call ALIVE_fnc_dump; };
                // DEBUG -------------------------------------------------------------------------------------

                // set module as started
                _logic setVariable ["startupComplete", true];

            };


			// Spawn the main force

			private ["_groups","_motorizedGroups","_infantryGroups","_group","_totalCount","_position",
			"_groupCount","_profiles"];

			// DEBUG -------------------------------------------------------------------------------------
			if(_debug) then {
				["ALIVE CMP [%1] - Force creation ",_faction] call ALIVE_fnc_dump;
				["ALIVE CMP Count Armor: %1",_countArmored] call ALIVE_fnc_dump;
				["ALIVE CMP Count Mech: %1",_countMechanized] call ALIVE_fnc_dump;
				["ALIVE CMP Count Motor: %1",_countMotorized] call ALIVE_fnc_dump;
				["ALIVE CMP Count Infantry: %1",_countInfantry] call ALIVE_fnc_dump;
				["ALIVE CMP Count Spec Ops: %1",_countSpecOps] call ALIVE_fnc_dump;
			};
			// DEBUG -------------------------------------------------------------------------------------


			// Assign groups
			_groups = [];

			for "_i" from 0 to _countArmored -1 do {
				_group = ["Armored",_faction] call ALIVE_fnc_configGetRandomGroup;
				if!(_group == "FALSE") then {
					_groups set [count _groups, _group];
				};
			};

			for "_i" from 0 to _countMechanized -1 do {
				_group = ["Mechanized",_faction] call ALIVE_fnc_configGetRandomGroup;
				if!(_group == "FALSE") then {
					_groups set [count _groups, _group];
				}
			};

			if(_countMotorized > 0) then {

                _motorizedGroups = [];

                for "_i" from 0 to _countMotorized -1 do {
                    _group = ["Motorized",_faction] call ALIVE_fnc_configGetRandomGroup;
                    if!(_group == "FALSE") then {
                        _motorizedGroups set [count _motorizedGroups, _group];
                    };
                };

                if(count _motorizedGroups == 0) then {
                    for "_i" from 0 to _countMotorized -1 do {
                        _group = ["Motorized_MTP",_faction] call ALIVE_fnc_configGetRandomGroup;
                        if!(_group == "FALSE") then {
                            _motorizedGroups set [count _motorizedGroups, _group];
                        };
                    };
                };

                _groups = _groups + _motorizedGroups;
            };

			_infantryGroups = [];
			for "_i" from 0 to _countInfantry -1 do {
				_group = ["Infantry",_faction] call ALIVE_fnc_configGetRandomGroup;
				if!(_group == "FALSE") then {
					_infantryGroups set [count _infantryGroups, _group];
				}
			};

			for "_i" from 0 to _countSpecOps -1 do {
                _group = ["SpecOps",_faction] call ALIVE_fnc_configGetRandomGroup;
                if!(_group == "FALSE") then {
                    _infantryGroups set [count _infantryGroups, _group];
                };
            };

			_groups = _groups + _infantryGroups;
			_groups = _groups - ALiVE_PLACEMENT_GROUPBLACKLIST;
			_infantryGroups = _infantryGroups - ALiVE_PLACEMENT_GROUPBLACKLIST;

			// DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["ALIVE CMP [%1] - Groups ",_groups] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


			// Position and create groups
			_groupCount = count _groups;
			_totalCount = 0;

			if(_groupCount > 0) then {

                //Guards
			    if(count _infantryGroups > 0) then {
                    _guardGroup = _infantryGroups call BIS_fnc_selectRandom;
                    _guards = [_guardGroup, _position, random(360), true, _faction] call ALIVE_fnc_createProfilesFromGroupConfig;

                    //ARJay, here we could place the default patrols/garrisons instead of the static garrisson if you like to (same is in CIV MP)
                    {
                        if (([_x,"type"] call ALiVE_fnc_HashGet) == "entity") then {
                            [_x, "setActiveCommand", ["ALIVE_fnc_garrison","spawn",[200,"true",[0,0,0]]]] call ALIVE_fnc_profileEntity;
                        };
                    } foreach _guards;
                };

                //Main troops
                
	            _readiness = parseNumber([_logic, "readinessLevel"] call MAINCLASS);
	            _readiness = (1 - _readiness) * _groupCount;

                for "_i" from 0 to _groupCount -1 do {
                    private ["_profiles","_command","_radius","_position","_garrisonPos"];

                    if (_totalCount < _readiness ) then {
                        _command = "ALIVE_fnc_garrison";
                        _garrisonPos = [position _logic, 50] call CBA_fnc_RandPos;
                        _radius = [200,"true",[0,0,0]];
                    } else {
                        _command = "ALIVE_fnc_ambientMovement";
                        _radius = [200,"SAFE",[0,0,0]];
                    };

                    _group = _groups select _i;

                    if (isnil "_garrisonPos") then {
                        _position = [position _logic, random(500), random(360)] call BIS_fnc_relPos;
                    } else {
                        _position = [_garrisonPos, 50] call CBA_fnc_RandPos;
                    };

                    if!(surfaceIsWater _position) then {

                        _profiles = [_group, _position, random(360), false, _faction] call ALIVE_fnc_createProfilesFromGroupConfig;

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
				["ALIVE CMP - Total profiles created: %1",_countProfiles] call ALIVE_fnc_dump;
				["ALIVE CMP - Placement completed"] call ALIVE_fnc_dump;
				[] call ALIVE_fnc_timer;
				["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
			};
			// DEBUG -------------------------------------------------------------------------------------

			// Create HQ

			private ["_modulePosition","_sortedData","_closestHQCluster","_hqBuilding"];

			if(_createHQ) then {

			    _modulePosition = position _logic;

                _nodes = [_cluster, "nodes"] call ALIVE_fnc_hashGet;

                _buildings = [_nodes, ALIVE_militaryHQBuildingTypes] call ALIVE_fnc_findBuildingsInClusterNodes;

                _buildings = [_buildings,[_modulePosition],{_Input0 distance _x},"ASCENDING",{[_x] call ALIVE_fnc_isHouseEnterable}] call ALiVE_fnc_SortBy;

                if (count _buildings == 0) then {_buildings = [_modulePosition, _size, ALIVE_militaryBuildingTypes + ALIVE_militaryHQBuildingTypes] call ALIVE_fnc_findNearObjectsByType};
                
                if (count _buildings > 0) then {
                    
                    _hqBuilding = _buildings select 0;


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
                    ["ALIVE CMP - Warning no HQ locations found"] call ALIVE_fnc_dump;
                };

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

						_nodes = [_cluster, "nodes"] call ALIVE_fnc_hashGet;

						_buildings = [_nodes, ALIVE_militarySupplyBuildingTypes] call ALIVE_fnc_findBuildingsInClusterNodes;

						//["BUILDINGS: %1",_buildings] call ALIVE_fnc_dump;

						//[_x, "debug", true] call ALIVE_fnc_cluster;
						{
							_position = position _x;
							_direction = direction _x;
							_vehicleClass = _supplyClasses call BIS_fnc_selectRandom;
							if(random 1 > 0.3) then {
								_box = createVehicle [_vehicleClass, _position, [], 0, "NONE"];
								_countSupplies = _countSupplies + 1;
							};
						} forEach _buildings;

				};
			};

			// DEBUG -------------------------------------------------------------------------------------
			if(_debug) then {
				["ALIVE CMP [%1] - Supplies placed: %2",_faction,_countSupplies] call ALIVE_fnc_dump;
			};
			// DEBUG -------------------------------------------------------------------------------------


			// Spawn helicopters on pads

			private ["_countCrewedHelis","_countUncrewedHelis","_helipad"];
			_countCrewedHelis = 0;
			_countUncrewedHelis = 0;

			if(_placeHelis) then {

				_heliClasses = [0,_faction,"Helicopter"] call ALiVE_fnc_findVehicleType;
				_heliClasses = _heliClasses - ALiVE_PLACEMENT_VEHICLEBLACKLIST;

				if(count _heliClasses > 0) then {

					    _nodes = [_cluster, "nodes"] call ALIVE_fnc_hashGet;

						//[_x, "debug", true] call ALIVE_fnc_cluster;
						{
							if (typeOf _x in ALIVE_militaryHeliBuildingTypes || typeOf _x in ALIVE_civilianHeliBuildingTypes || typeOf _x in ["Land_HelipadSquare_F","Land_HelipadCircle_F"]) then {
								_position = position _x;
								_direction = direction _x;
								_vehicleClass = _heliClasses call BIS_fnc_selectRandom;
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
				["ALIVE CMP [%1] - Heli units placed: crewed:%2 uncrewed:%3",_faction,_countCrewedHelis,_countUncrewedHelis] call ALIVE_fnc_dump;
			};
			// DEBUG -------------------------------------------------------------------------------------

			// Spawn ambient vehicles

			private ["_countLandUnits","_carClasses","_armorClasses","_landClasses","_supportCount","_supportMax","_supportClasses","_types",
			"_countBuildings","_parkingChance","_usedPositions","_building","_parkingPosition","_positionOK","_supportPlacement","_vehicleClass"];

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


						_supportCount = 0;
						_supportMax = 0;

						_nodes = [_cluster, "nodes"] call ALIVE_fnc_hashGet;

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
							_parkingChance = 0.8 * _ambientVehicleAmount;
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
									_vehicleClass = _supportClasses call BIS_fnc_selectRandom;
								}else{
									_vehicleClass = _landClasses call BIS_fnc_selectRandom;
								};

                                //["SUPPORT PLACEMENT: %1",_supportPlacement] call ALIVE_fnc_dump;
                                //["VEHICLE CLASS: %1",_vehicleClass] call ALIVE_fnc_dump;

								_parkingPosition = [_vehicleClass,_building] call ALIVE_fnc_getParkingPosition;
								_positionOK = true;

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

									_usedPositions set [count _usedPositions, _parkingPosition];

									if(_supportPlacement) then {
										_supportCount = _supportCount + 1;
									};
								};
							};

						} forEach _buildings;


				};
			};


			// DEBUG -------------------------------------------------------------------------------------
			if(_debug) then {
				["ALIVE CMP [%1] - Ambient land units placed: %2",_faction,_countLandUnits] call ALIVE_fnc_dump;
			};
			// DEBUG -------------------------------------------------------------------------------------

			// set module as started
            _logic setVariable ["startupComplete", true];

		};
	};
};

TRACE_1("CMP - output",_result);
_result;
