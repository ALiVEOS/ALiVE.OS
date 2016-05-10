#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profileSystem);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
Description:
Main class for profile system initialisation

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enable, disable or refresh

Examples:
(begin example)
// create the
_logic = [nil, "init"] call ALIVE_fnc_profileSystem;
(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_profileSystem

private ["_result"];

TRACE_1("profileSystem - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
_result = true;

#define MTEMPLATE "ALiVE_PROFILESYSTEM_%1"

switch(_operation) do {
        case "init": {
                if (isServer) then {
                        // if server, initialise module game logic
						[_logic,"super",SUPERCLASS] call ALIVE_fnc_hashSet;
						[_logic,"class",MAINCLASS] call ALIVE_fnc_hashSet;
						[_logic,"moduleType","ALIVE_profileHandler"] call ALIVE_fnc_hashSet;
						[_logic,"startupComplete",false] call ALIVE_fnc_hashSet;
                        //TRACE_1("After module init",_logic);

						[_logic,"debug",false] call ALIVE_fnc_hashSet;
						[_logic,"persistent",false] call ALIVE_fnc_hashSet;
						[_logic,"plotSectors",false] call ALIVE_fnc_hashSet;
						[_logic,"syncMode","ADD"] call ALIVE_fnc_hashSet;
						[_logic,"syncedUnits",[]] call ALIVE_fnc_hashSet;
						[_logic,"spawnRadius",1000] call ALIVE_fnc_hashSet;
						[_logic,"spawnTypeJetRadius",1000] call ALIVE_fnc_hashSet;
						[_logic,"spawnTypeHeliRadius",1000] call ALIVE_fnc_hashSet;
						[_logic,"activeLimiter",30] call ALIVE_fnc_hashSet;
						[_logic,"spawnCycleTime",1] call ALIVE_fnc_hashSet;
						[_logic,"despawnCycleTime",1] call ALIVE_fnc_hashSet;
                        [_logic,"speedModifier",1] call ALIVE_fnc_hashSet;

                };
        };
        case "start": {

				private["_debug","_persistent","_plotSectors","_syncMode","_syncedUnits","_spawnRadius","_spawnTypeJetRadius","_spawnTypeHeliRadius",
				"_activeLimiter","_spawnCycleTime","_despawnCycleTime","_profileSimulatorFSM","_profileSpawnerFSMEast","_profileSpawnerFSMWest",
				"_profileSpawnerFSMGuer","_profileSpawnerFSMCiv","_sectors","_persistent","_file"];

                if (isServer) then {

						_debug = [_logic,"debug",false] call ALIVE_fnc_hashGet;
						_persistent = [_logic,"persistent",false] call ALIVE_fnc_hashGet;
						_plotSectors = [_logic,"plotSectors",false] call ALIVE_fnc_hashGet;
						_syncMode = [_logic,"syncMode","ADD"] call ALIVE_fnc_hashGet;
						_syncedUnits = [_logic,"syncedUnits",[]] call ALIVE_fnc_hashGet;
						_spawnRadius = [_logic,"spawnRadius"] call ALIVE_fnc_hashGet;
                        _spawnTypeJetRadius = [_logic,"spawnTypeJetRadius"] call ALIVE_fnc_hashGet;
                        _spawnTypeHeliRadius = [_logic,"spawnTypeHeliRadius"] call ALIVE_fnc_hashGet;
						_activeLimiter = [_logic,"activeLimiter"] call ALIVE_fnc_hashGet;
						_spawnCycleTime = [_logic,"spawnCycleTime"] call ALIVE_fnc_hashGet;
						_despawnCycleTime = [_logic,"despawnCycleTime"] call ALIVE_fnc_hashGet;

                        // set global profiles persistent var
						ALIVE_loadProfilesPersistent = _persistent;
						ALIVE_saveProfilesPersistent = _persistent;

						// DEBUG -------------------------------------------------------------------------------------
						if(_debug) then {
							["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
							["ALIVE ProfileSystem - Startup"] call ALIVE_fnc_dump;
						};
						// DEBUG -------------------------------------------------------------------------------------

                        // load static data
                        if(isNil "ALiVE_STATIC_DATA_LOADED") then {
                            _file = "\x\alive\addons\main\static\staticData.sqf";
                            call compile preprocessFileLineNumbers _file;
                        };

                        // global server flag
                        ALIVE_profileSystemDataLoaded = true;

						// create the profile handler
						ALIVE_profileHandler = [nil, "create"] call ALIVE_fnc_profileHandler;
						[ALIVE_profileHandler, "init"] call ALIVE_fnc_profileHandler;

						// create sector grid
						ALIVE_sectorGrid = [nil, "create"] call ALIVE_fnc_sectorGrid;
						[ALIVE_sectorGrid, "init"] call ALIVE_fnc_sectorGrid;
						[ALIVE_sectorGrid, "createGrid"] call ALIVE_fnc_sectorGrid;

						// create sector plotter
						ALIVE_sectorPlotter = [nil, "create"] call ALIVE_fnc_plotSectors;
						[ALIVE_sectorPlotter, "init"] call ALIVE_fnc_plotSectors;

						// import static map analysis to the grid
						[ALIVE_sectorGrid] call ALIVE_fnc_gridImportStaticMapAnalysis;

						// create live analysis
						ALIVE_liveAnalysis = [nil, "create"] call ALIVE_fnc_liveAnalysis;
						[ALIVE_liveAnalysis, "init"] call ALIVE_fnc_liveAnalysis;
						[ALIVE_liveAnalysis, "debug", false] call ALIVE_fnc_liveAnalysis;

                        // create battlefield analysis
                        ALIVE_battlefieldAnalysis = [nil, "create"] call ALIVE_fnc_battlefieldAnalysis;
                        [ALIVE_battlefieldAnalysis, "init"] call ALIVE_fnc_battlefieldAnalysis;
                        [ALIVE_battlefieldAnalysis, "debug", false] call ALIVE_fnc_battlefieldAnalysis;

						// create profiles for all players that dont have profiles
                        ["INIT"] call ALIVE_fnc_createProfilesFromPlayers;

						// create profiles for all map units that dont have profiles
						[_syncMode, _syncedUnits, false] call ALIVE_fnc_createProfilesFromUnits;

						// turn on debug again to see the state of the profile handler, and set debug on all a profiles
						[ALIVE_profileHandler, "debug", _debug] call ALIVE_fnc_profileHandler;

						// create array block stepper
						ALIVE_arrayBlockHandler = [nil, "create"] call ALIVE_fnc_arrayBlockHandler;
						[ALIVE_arrayBlockHandler, "init"] call ALIVE_fnc_arrayBlockHandler;

						// create command router
						ALIVE_commandRouter = [nil, "create"] call ALIVE_fnc_commandRouter;
						[ALIVE_commandRouter, "init"] call ALIVE_fnc_commandRouter;
						[ALIVE_commandRouter, "debug", false] call ALIVE_fnc_commandRouter;


						// DEBUG -------------------------------------------------------------------------------------
						if(_debug) then {
							["ALIVE ProfileSystem - Startup completed"] call ALIVE_fnc_dump;
							["ALIVE Sector grid created"] call ALIVE_fnc_dump;
							["ALIVE Profile handler created"] call ALIVE_fnc_dump;
							["ALIVE Map units converted to profiles"] call ALIVE_fnc_dump;
							["ALIVE Simulation controller created"] call ALIVE_fnc_dump;
							["ALIVE Spawn controller created"] call ALIVE_fnc_dump;
							["ALIVE Active Limit: %1", _activeLimiter] call ALIVE_fnc_dump;
							["ALIVE Spawn Radius: %1", _spawnRadius] call ALIVE_fnc_dump;
                            ["ALIVE Spawn in Jet Radius: %1",_spawnTypeJetRadius] call ALIVE_fnc_dump;
                            ["ALIVE Spawn in Heli Radius: %1",_spawnTypeHeliRadius] call ALIVE_fnc_dump;
							["ALIVE Spawn Cycle Time: %1", _spawnCycleTime] call ALIVE_fnc_dump;
							["ALIVE Persistent: %1",_persistent] call ALIVE_fnc_dump;
							["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
						};
						// DEBUG -------------------------------------------------------------------------------------


						// start the profile simulator
						//_profileSimulatorFSM = [_logic] execFSM "\x\alive\addons\sys_profile\profileSimulator_v2.fsm";
						_profileSimulatorFSM = [_logic] execFSM "\x\alive\addons\sys_profile\profileSimulator.fsm";
						[_logic,"simulator_FSM",_profileSimulatorFSM] call ALIVE_fnc_hashSet;

						// start the profile spawners

                        // version 2.1 spawner system
                        _profileSpawnerFSMEast = [_logic,"EAST",_spawnRadius,_spawnTypeJetRadius,_spawnTypeHeliRadius,_spawnCycleTime,_activeLimiter] execFSM "\x\alive\addons\sys_profile\profileSpawner_v2_1.fsm";
                        _profileSpawnerFSMWest = [_logic,"WEST",_spawnRadius,_spawnTypeJetRadius,_spawnTypeHeliRadius,_spawnCycleTime,_activeLimiter] execFSM "\x\alive\addons\sys_profile\profileSpawner_v2_1.fsm";
                        _profileSpawnerFSMGuer = [_logic,"GUER",_spawnRadius,_spawnTypeJetRadius,_spawnTypeHeliRadius,_spawnCycleTime,_activeLimiter] execFSM "\x\alive\addons\sys_profile\profileSpawner_v2_1.fsm";
                        _profileSpawnerFSMCiv = [_logic,"CIV",_spawnRadius,_spawnTypeJetRadius,_spawnTypeHeliRadius,_spawnCycleTime,_activeLimiter] execFSM "\x\alive\addons\sys_profile\profileSpawner_v2_1.fsm";

                        [_logic,"spawner_FSMEast",_profileSpawnerFSMEast] call ALIVE_fnc_hashSet;
                        [_logic,"spawner_FSMWest",_profileSpawnerFSMWest] call ALIVE_fnc_hashSet;
                        [_logic,"spawner_FSMGuer",_profileSpawnerFSMGuer] call ALIVE_fnc_hashSet;
                        [_logic,"spawner_FSMCiv",_profileSpawnerFSMCiv] call ALIVE_fnc_hashSet;

                        // if persistent load data
                        if(ALIVE_loadProfilesPersistent) then {
                            call ALIVE_fnc_profilesLoadData;
                        };

                        // global server flag
                        ALIVE_profileSystemInit = true;

                        // set modules as started
                        [_logic,"startupComplete",true] call ALIVE_fnc_hashSet;

						// register profile entity analysis job on the live analysis
						// analysis job will run every 90 seconds and has no run count limit
						[ALIVE_liveAnalysis, "registerAnalysisJob", [90, 0, "gridProfileEntity", "gridProfileEntity", [_plotSectors]]] call ALIVE_fnc_liveAnalysis;

						// register player analysis job on the live analysis
						// analysis job will run every 10 seconds and has no run count limit
						[ALIVE_liveAnalysis, "registerAnalysisJob", [15, 0, "activeSectors", "activeSectors", [_plotSectors]]] call ALIVE_fnc_liveAnalysis;

						// start analysis jobs
						[ALIVE_liveAnalysis, "start"] call ALIVE_fnc_liveAnalysis;
                };
        };
        case "destroy": {

                private ["_profileSimulatorFSM","_profileSpawnerFSMEast","_profileSpawnerFSMWest","_profileSpawnerFSMGuer","_profileSpawnerFSMCiv"];

                [_logic, "debug", false] call MAINCLASS;
                if (isServer) then {

					_profileSimulatorFSM = [_logic, "simulator_FSM"] call ALiVE_fnc_HashGet;
					_profileSimulatorFSM setFSMVariable ["_destroy",true];

					_profileSpawnerFSMEast = [_logic, "spawner_FSMEast"] call ALiVE_fnc_HashGet;
					_profileSpawnerFSMEast setFSMVariable ["_destroy",true];

					_profileSpawnerFSMWest = [_logic, "spawner_FSMWest"] call ALiVE_fnc_HashGet;
                    _profileSpawnerFSMWest setFSMVariable ["_destroy",true];

                    _profileSpawnerFSMGuer = [_logic, "spawner_FSMGuer"] call ALiVE_fnc_HashGet;
                    _profileSpawnerFSMGuer setFSMVariable ["_destroy",true];

                    _profileSpawnerFSMCiv = [_logic, "spawner_FSMCiv"] call ALiVE_fnc_HashGet;
                    _profileSpawnerFSMCiv setFSMVariable ["_destroy",true];

                    [ALIVE_commandRouter, "pause", true] call ALIVE_fnc_commandRouter;
                    [ALIVE_liveAnalysis, "pause", true] call ALIVE_fnc_liveAnalysis;

                    [ALIVE_commandRouter,"destroy"] call ALiVE_fnc_CommandRouter;
                    [ALIVE_arrayBlockHandler,"destroy"] call ALIVE_fnc_arrayBlockHandler;
                    [ALIVE_battlefieldAnalysis,"destroy"] call ALIVE_fnc_battlefieldAnalysis;
                    [ALIVE_liveAnalysis,"destroy"] call ALIVE_fnc_liveAnalysis;
                    [ALIVE_sectorPlotter,"destroy"] call ALIVE_fnc_plotSectors;
                    [ALIVE_sectorGrid,"destroy"] call ALIVE_fnc_sectorGrid;
                    [ALIVE_profileHandler,"destroy"] call ALIVE_fnc_profileHandler;

                    ALIVE_profileSystemInit = nil; PublicVariable "ALIVE_profileSystemInit";

                    _module = [_logic,"handler",objNull] call ALiVE_fnc_HashGet;
                    _module setVariable ["handler",nil];

                    MOD(SYS_PROFILE) = nil; PublicVariable QMOD(SYS_PROFILE);

                    [_logic, "destroy"] call SUPERCLASS;
                };
        };
        case "pause": {
                if(typeName _args != "BOOL") then {
                        _args = [_logic,"debug"] call ALIVE_fnc_hashGet;
                } else {
                        [_logic,"debug",_args] call ALIVE_fnc_hashSet;
                };
                ASSERT_TRUE(typeName _args == "BOOL",str _args);

                ["ALiVE Pausing state of %1 instance set to %2!",QMOD(ADDON),_args] call ALiVE_fnc_DumpR;

                if(_args) then {

                    _profileSimulatorFSM = [_logic, "simulator_FSM"] call ALiVE_fnc_HashGet;
                    _profileSimulatorFSM setFSMVariable ["_pause",true];

                    _profileSpawnerFSMEast = [_logic, "spawner_FSMEast"] call ALiVE_fnc_HashGet;
                    _profileSpawnerFSMEast setFSMVariable ["_pause",true];

                    _profileSpawnerFSMWest = [_logic, "spawner_FSMWest"] call ALiVE_fnc_HashGet;
                    _profileSpawnerFSMWest setFSMVariable ["_pause",true];

                    _profileSpawnerFSMGuer = [_logic, "spawner_FSMGuer"] call ALiVE_fnc_HashGet;
                    _profileSpawnerFSMGuer setFSMVariable ["_pause",true];

                    _profileSpawnerFSMCiv = [_logic, "spawner_FSMCiv"] call ALiVE_fnc_HashGet;
                    _profileSpawnerFSMCiv setFSMVariable ["_pause",true];

                    [ALIVE_commandRouter, "pause", true] call ALIVE_fnc_commandRouter;
                    [ALIVE_liveAnalysis, "pause", true] call ALIVE_fnc_liveAnalysis;

                }else{

                    _profileSimulatorFSM = [_logic, "simulator_FSM"] call ALiVE_fnc_HashGet;
                    _profileSimulatorFSM setFSMVariable ["_pause",false];

                    _profileSpawnerFSMEast = [_logic, "spawner_FSMEast"] call ALiVE_fnc_HashGet;
                    _profileSpawnerFSMEast setFSMVariable ["_pause",false];

                    _profileSpawnerFSMWest = [_logic, "spawner_FSMWest"] call ALiVE_fnc_HashGet;
                    _profileSpawnerFSMWest setFSMVariable ["_pause",false];

                    _profileSpawnerFSMGuer = [_logic, "spawner_FSMGuer"] call ALiVE_fnc_HashGet;
                    _profileSpawnerFSMGuer setFSMVariable ["_pause",false];

                    _profileSpawnerFSMCiv = [_logic, "spawner_FSMCiv"] call ALiVE_fnc_HashGet;
                    _profileSpawnerFSMCiv setFSMVariable ["_pause",false];

                    [ALIVE_commandRouter, "pause", false] call ALIVE_fnc_commandRouter;
                    [ALIVE_liveAnalysis, "pause", false] call ALIVE_fnc_liveAnalysis;

                };

                _result = _args;
        };
        case "debug": {
				if(typeName _args != "BOOL") then {
						_args = [_logic,"debug"] call ALIVE_fnc_hashGet;
                } else {
						[_logic,"debug",_args] call ALIVE_fnc_hashSet;
                };
                ASSERT_TRUE(typeName _args == "BOOL",str _args);

                _result = _args;
        };
        case "persistent": {
                if(typeName _args != "BOOL") then {
                        _args = [_logic,"persistent"] call ALIVE_fnc_hashGet;
                } else {
                        [_logic,"persistent",_args] call ALIVE_fnc_hashSet;
                };
                ASSERT_TRUE(typeName _args == "BOOL",str _args);

                _result = _args;
        };
		case "plotSectors": {
				if(typeName _args != "BOOL") then {
						_args = [_logic,"plotSectors"] call ALIVE_fnc_hashGet;
                } else {
						[_logic,"plotSectors",_args] call ALIVE_fnc_hashSet;
                };
                ASSERT_TRUE(typeName _args == "BOOL",str _args);

                _result = _args;
        };
		case "spawnRadius": {
				if(typeName _args == "SCALAR") then {
						[_logic,"spawnRadius",_args] call ALIVE_fnc_hashSet;
						ALIVE_spawnRadius = _args;
                };
				_result = [_logic,"spawnRadius"] call ALIVE_fnc_hashGet;
        };
        case "spawnTypeJet": {
                if(typeName _args != "BOOL") then {
                        _args = [_logic,"spawnTypeJet"] call ALIVE_fnc_hashGet;
                } else {
                        [_logic,"spawnTypeJet",_args] call ALIVE_fnc_hashSet;
                };
                ASSERT_TRUE(typeName _args == "BOOL",str _args);

                _result = _args;
        };
        case "spawnTypeJetRadius": {
                if(typeName _args == "SCALAR") then {
                        [_logic,"spawnTypeJetRadius",_args] call ALIVE_fnc_hashSet;
                        ALIVE_spawnRadiusJet = _args;
                };
                _result = [_logic,"spawnTypeJetRadius"] call ALIVE_fnc_hashGet;
        };
        case "spawnTypeHeli": {
                if(typeName _args != "BOOL") then {
                        _args = [_logic,"spawnTypeHeli"] call ALIVE_fnc_hashGet;
                } else {
                        [_logic,"spawnTypeHeli",_args] call ALIVE_fnc_hashSet;
                };
                ASSERT_TRUE(typeName _args == "BOOL",str _args);

                _result = _args;
        };
        case "spawnTypeHeliRadius": {
                if(typeName _args == "SCALAR") then {
                        [_logic,"spawnTypeHeliRadius",_args] call ALIVE_fnc_hashSet;
                        ALIVE_spawnRadiusHeli = _args;
                };
                _result = [_logic,"spawnTypeHeliRadius"] call ALIVE_fnc_hashGet;
        };
        case "activeLimiter": {
                if(typeName _args == "SCALAR") then {
                        [_logic,"activeLimiter",_args] call ALIVE_fnc_hashSet;
                };
                _result = [_logic,"activeLimiter"] call ALIVE_fnc_hashGet;
        };
		case "syncMode": {
				if(typeName _args == "STRING") then {
						[_logic,"syncMode",_args] call ALIVE_fnc_hashSet;
                };
				_result = [_logic,"syncMode"] call ALIVE_fnc_hashGet;
        };
		case "syncedUnits": {
				if(typeName _args == "ARRAY") then {
						[_logic,"syncedUnits",_args] call ALIVE_fnc_hashSet;
                };
				_result = [_logic,"syncedUnits"] call ALIVE_fnc_hashGet;
        };
        case "speedModifier": {
                if(typeName _args == "SCALAR") then {
                        [_logic,"speedModifier",_args] call ALIVE_fnc_hashSet;
                };
                _result = [_logic,"speedModifier"] call ALIVE_fnc_hashGet;
        };
		case "state": {
				private["_state"];

				if(typeName _args != "ARRAY") then {

						// Save state

                        _state = [] call ALIVE_fnc_hashCreate;

						// BaseClassHash CHANGE
						// loop the class hash and set vars on the state hash
						{
							if(!(_x == "super") && !(_x == "class")) then {
								[_state,_x,[_logic,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
							};
						} forEach (_logic select 1);

                        _result = _state;

                } else {
						ASSERT_TRUE(typeName _args == "ARRAY",str typeName _args);

                        // Restore state

						// BaseClassHash CHANGE
						// loop the passed hash and set vars on the class hash
                        {
							[_logic,_x,[_args,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
						} forEach (_args select 1);
                };
        };
        default {
                _result = [_logic, _operation, _args] call SUPERCLASS;
        };
};
TRACE_1("profileSystem - output",_result);
_result;