//#define DEBUG_MPDE_FULL
#include "\x\alive\addons\mil_placement_spe\script_component.hpp"
SCRIPT(SPEMP);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_SPEMP
Description:
SPE Military objectives

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
[_logic, "faction", "OPF_F"] call ALiVE_fnc_SPEMP;

See Also:
- <ALIVE_fnc_SPEMPInit>

Author:
ARJay
---------------------------------------------------------------------------- */

#define SUPERCLASS                      ALIVE_fnc_baseClass
#define MAINCLASS                       ALIVE_fnc_SPEMP
#define MTEMPLATE                       "ALiVE_SPEMP_%1"
#define DEFAULT_FACTION                 QUOTE(SPE_US_ARMY)
#define DEFAULT_SIZE                    "50"
#define DEFAULT_PRIORITY                "50"
#define DEFAULT_NO_TEXT                 "0"
#define DEFAULT_OBJECTIVES              []
#define DEFAULT_BEHAVIOUR_TYPE          QUOTE(STEALTH)

TRACE_1("SPEMP - input",_this);

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

    case "speInfantryClass": {
        _result = [_logic,_operation,_args,DEFAULT_NO_TEXT] call ALIVE_fnc_OOsimpleOperation;
    };
    
    case "speInfantryBehaviour": {
        _result = [_logic,_operation,_args,DEFAULT_BEHAVIOUR_TYPE,["AWARE","COMBAT","STEALTH","SAFE","CARELESS"]] call ALIVE_fnc_OOsimpleOperation;
    };
        
    case "speVehicleClass": {
        _result = [_logic,_operation,_args,DEFAULT_NO_TEXT] call ALIVE_fnc_OOsimpleOperation;
    };

    case "faction": {
        _result = [_logic,_operation,_args,DEFAULT_FACTION,[] call ALiVE_fnc_configGetFactions] call ALIVE_fnc_OOsimpleOperation;
    };

    case "size": {
        _result = [_logic,_operation,_args,DEFAULT_SIZE] call ALIVE_fnc_OOsimpleOperation;
    };

    case "priority": {
        _result = [_logic,_operation,_args,DEFAULT_PRIORITY] call ALIVE_fnc_OOsimpleOperation;
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
            _logic setVariable ["moduleType", "ALIVE_SPEMP"];
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
                ["SPEMP - Startup"] call ALiVE_fnc_dump;
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

            // all SPEMP modules execute at the same time
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
                ["SPEMP - Placement"] call ALiVE_fnc_dump;
                [true] call ALIVE_fnc_timer;
            };
            // DEBUG -------------------------------------------------------------------------------------

            private _infantryClass = [_logic, "speInfantryClass"] call MAINCLASS;
            private _aiBehaviour = [_logic, "speInfantryBehaviour"] call MAINCLASS;
            private _vehicleClass = [_logic, "speVehicleClass"] call MAINCLASS;
            private _faction = [_logic, "faction"] call MAINCLASS;
            private _size = [_logic, "size"] call MAINCLASS;

            if(typeName _size == "STRING") then {
                _size = parseNumber _size;
            };

            private _priority = [_logic, "priority"] call MAINCLASS;

            if(typeName _priority == "STRING") then {
                _priority = parseNumber _priority;
            };

            private _factionConfig = _faction call ALiVE_fnc_configGetFactionClass;
            private _factionSideNumber = getNumber(_factionConfig >> "side");
            private _side = _factionSideNumber call ALIVE_fnc_sideNumberToText;
						private _sideObject = [_side] call ALIVE_fnc_sideTextToObject;
            private _countProfiles = 0;
            private _position = position _logic;
            private _direction =  getDir _logic;
            private _allowPlayerTasking = [_logic, "allowPlayerTasking"] call MAINCLASS;

            // Load static data
            call ALiVE_fnc_staticDataHandler;

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["SPEMP [%1] - Size: %1 Priority: %2",_size,_priority] call ALiVE_fnc_dump;
                ["SPEMP [%1] - SideNum: %1 Side: %2 Faction: %3",_factionSideNumber,_side,_faction] call ALiVE_fnc_dump;
                ["SPEMP Allow player tasking: %1", _allowPlayerTasking] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            // assign the objective to OPCOMS
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
                if(_debug) then { ["SPEMP - Profiles are persistent, no creation of profiles"] call ALiVE_fnc_dump; };
                // DEBUG -------------------------------------------------------------------------------------

                // set module as started
                _logic setVariable ["startupComplete", true];

            };



				  // Spawn vehicle START
           if (_vehicleClass != "") then {
           	
	            // DEBUG -------------------------------------------------------------------------------------
	            if(_debug) then {
	            	  ["SPEMP [%1] - Force creation ",_faction] call ALiVE_fnc_dump;
                  ["SPEMP Vehicle Class: %1", _vehicleClass] call ALiVE_fnc_dump;
	            	  ["SPEMP - Module Position: %1, Module Direction: %2", _position, _direction] call ALiVE_fnc_dump;
	            };
	            // DEBUG -------------------------------------------------------------------------------------
	            
 								private _countCrewed = 0;
 								// _position set [2, _direction];
	     					_profiledCrewed = [_vehicleClass, _side, _faction, "CAPTAIN", _position, _direction,true,"",false,false,[],[],true] call ALIVE_fnc_createProfilesCrewedVehicle;
	              _countCrewed = _countCrewed +1; 
                _countProfiles = _countCrewed;
                       
					     // DEBUG -------------------------------------------------------------------------------------
					     if(_debug) then {
					       ["SPEMP - Vehicle %1 created with crew at position: %2",  _vehicleClass, _position] call ALiVE_fnc_dump;
					       ["SPEMP - Total Crewed Profiles Created: %1", _countCrewed] call ALiVE_fnc_dump;
					     };
					     // DEBUG -------------------------------------------------------------------------------------
	         };
					// Spawn vehicle END
								

          // Spawn the Infantry
					if (_vehicleClass == "") then {
            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["SPEMP [%1] - Force creation ", _faction] call ALiVE_fnc_dump;
                ["SPEMP Infantry Class: %1", _infantryClass] call ALiVE_fnc_dump;
                ["SPEMP Infantry Class typeName: %1", typeName _infantryClass] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            // Assign groups
            private _groups = [];
            private _infantryGroups = [];

  					 if (_infantryClass != "") then {
  					 	
  					    private _group = [_faction, _infantryClass] call ALIVE_fnc_configGetGroup;
		            // DEBUG -------------------------------------------------------------------------------------
		            if(_debug) then {
		                ["SPEMP Got Defined Infantry Group: %1", _group] call ALiVE_fnc_dump;
		                ["SPEMP Group Name: %1", configName _group] call ALiVE_fnc_dump;
		            };
		            // DEBUG ------------------------------------------------------------------------------------- 	
	             if(count _group > 0) then {
	                _infantryGroups pushback configName _group;
	             };
  					 } else {
  					    private _group = ["Infantry",_faction] call ALIVE_fnc_configGetRandomGroup;
		            // DEBUG -------------------------------------------------------------------------------------
		            if(_debug) then {
		                ["SPEMP Got Random Infantry Group: %1",_group] call ALiVE_fnc_dump;

		            };
		            // DEBUG ------------------------------------------------------------------------------------- 	
	             if!(_group == "FALSE") then {
	                _infantryGroups pushback _group;
	             };
  					 };
  					
            _groups append _infantryGroups;

            _infantryGroups = _infantryGroups - ALiVE_PLACEMENT_GROUPBLACKLIST;
            _groups = _groups - ALiVE_PLACEMENT_GROUPBLACKLIST;

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["SPEMP [%1] - Groups ",_groups] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            // Position and create groups
            private _groupCount = count _groups;
            private _totalCount = 0;

            if(_groupCount > 0) then {
            	
                for "_i" from 0 to (_groupCount - 1) do {

                    private ["_command","_radius"];

                    // infantry
                    if (_i == 0 && {count _infantryGroups > 0}) then {

	                    private _group = _groups select _i;
	                    private _guards = [_group, _position, _direction, true, _faction, false, true, _aiBehaviour] call ALIVE_fnc_createProfilesFromGroupConfig;

	                   // Spawn static virtual group and get them to defend
	                    {
	                        if (([_x,"type"] call ALiVE_fnc_HashGet) == "entity") then {
	                            [_x, "setActiveCommand", ["ALIVE_fnc_garrison","spawn",[10,"false",[0,0,0]]]] call ALIVE_fnc_profileEntity;
	                            [_x,"busy",true] call ALIVE_fnc_hashSet;
	                        };
	                    } forEach _guards;
	                    
                        _countProfiles = _countProfiles + count _guards;
                        _totalCount = _totalCount + 1; 
                    };
                };
            };
          };
          
            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["SPEMP - Total Infantry Profiles Created: %1",_countProfiles] call ALiVE_fnc_dump;
                ["SPEMP - Placement Completed"] call ALiVE_fnc_dump;
                [] call ALIVE_fnc_timer;
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------

            // set module as started
            _logic setVariable ["startupComplete", true];

        };

    };

};

TRACE_1("SPEMP - output",_result);

_result;
