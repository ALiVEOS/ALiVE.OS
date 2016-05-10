#include <\x\alive\addons\sys_data\script_component.hpp>
SCRIPT(DataInit);

#define AAR_DEFAULT_SAMPLE_RATE 60
#define AAR_DEFAULT_SAVE_INTERVAL 1
#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_Data

// Sets up a system for data (separate from the fnc_data module = datahandler)

LOG(MSG_INIT);
private ["_response","_dictionaryName","_logic","_config","_moduleID","_mode"];

PARAMS_2(_logic,_mode);

// Confirm init function available
ASSERT_DEFINED("ALIVE_fnc_Data","Main function missing");

//Only one init per instance is allowed
if !(isnil QUOTE(ADDON)) exitwith {["ALiVE SYS DATA - Only one init process per instance allowed! Exiting..."] call ALiVE_fnc_Dump};

// Check to see if module was placed... (might be auto enabled)
if (isnil "_logic") then {
    if (isServer) then {

        // Ensure only one module is used
        if !(isNil QMOD(sys_data)) then {
            _logic = MOD(sys_data);
            ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_DATA_ERROR1");
        } else {
            _logic = (createGroup sideLogic) createUnit ["ALiVE_sys_data", [0,0], [], 0, "NONE"];
            MOD(sys_data) = _logic;
        };

        // If auto enabled allow
        if (_mode == 1) then { // override defaults and disable everything bar perf
        	MOD(sys_data) setVariable ["disableStats","true"];
         	MOD(sys_data) setVariable ["disablePerfMon","false"];
        };

        //Push to clients
        PublicVariable QMOD(sys_data);
    };

    TRACE_1("Waiting for object to be ready",true);

    waituntil {!isnil QMOD(sys_data)};

    TRACE_1("Creating class on all localities",true);

    // initialise module game logic on all localities
    MOD(sys_data) setVariable ["super", QUOTE(SUPERCLASS)];
    MOD(sys_data) setVariable ["class", QUOTE(MAINCLASS)];

    _logic = MOD(sys_data);

};

TRACE_2("SYS_DATA",isDedicated, _logic);

_moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

if (_logic getvariable ["debug", "false"] == "true") then {
	ALiVE_SYS_DATA_DEBUG_ON = true;
}else{
    ALiVE_SYS_DATA_DEBUG_ON = false;
};

if (isDedicated) then {

	// Setup OPC and OPD events
	//[QGVAR(OPD), "OnPlayerDisconnected","ALIVE_fnc_data_OnPlayerDisconnected"] call BIS_fnc_addStackedEventHandler;

	MOD(sys_data) = _logic;

	//Set Data logic defaults
	GVAR(DISABLED) = false;
	publicVariable QGVAR(DISABLED);

	GVAR(databaseName) = "arma3live";
	GVAR(source) = MOD(sys_data) getVariable ["source","CouchDB"];

	_initmsg = [_logic getVariable ["disablePerfMon","true"]] call ALIVE_fnc_startALiVEPlugIn;

	["ALIVE_SYS_DATA START PLUGIN: %1", _initmsg] call ALIVE_fnc_dump;

	GVAR(GROUP_ID) = [] call ALIVE_fnc_getGroupID;

    if(ALiVE_SYS_DATA_DEBUG_ON) then {
        ["ALiVE SYS_DATA - GROUP NAME: %1",GVAR(GROUP_ID)] call ALIVE_fnc_dump;
	};

	// Setup data handler
	GVAR(datahandler) = [nil, "create"] call ALIVE_fnc_Data;

	// Setup Data Dictionary
	ALIVE_DataDictionary = [] call ALIVE_fnc_hashCreate;

	["DATA: Loading ALiVE config from database."] call ALIVE_fnc_dump;

	// Get global config information
	_config = [GVAR(datahandler), "read", ["sys_data", [], "config"]] call ALIVE_fnc_Data;

	if(ALiVE_SYS_DATA_DEBUG_ON) then {
        ["ALiVE SYS_DATA - CONFIG: %1",_config] call ALIVE_fnc_dump;
    };

	// Check that the config loaded ok, if not then stop the data module
	if (typeName _config == "STRING" || (_initmsg select 1 == "ERROR" && _initmsg select 2 != "ALiVE already initialized")) exitWith {
		["CANNOT CONNECT TO DATABASE, DISABLING DATA MODULE"] call ALIVE_fnc_logger;
		GVAR(DISABLED) = true;
		publicVariable QGVAR(DISABLED);
		MOD(sys_data) setvariable ["disableStats", "true"];
		ALIVE_sys_statistics_ENABLED = false;
		publicVariable "ALIVE_sys_statistics_ENABLED";
		MOD(sys_data) setvariable ["disablePerf", "true"];
		ALIVE_sys_perf_ENABLED = false;
		publicVariable "ALIVE_sys_perf_ENABLED";
	};

	// Check to see if the service is off
	if ([_config, "On"] call ALIVE_fnc_hashGet == "false") exitWith {
		["CONNECTED TO DATABASE, BUT SERVICE HAS BEEN TURNED OFF"] call ALIVE_fnc_logger;
		GVAR(DISABLED) = true;
		publicVariable QGVAR(DISABLED);
		MOD(sys_data) setvariable ["disablePerf", "true"];
		ALIVE_sys_perf_ENABLED = false;
		publicVariable "ALIVE_sys_perf_ENABLED";
		MOD(sys_data) setvariable ["disableStats", "true"];
		ALIVE_sys_statistics_ENABLED = false;
		publicVariable "ALIVE_sys_statistics_ENABLED";
	};

	["CONNECTED TO DATABASE OK"] call ALIVE_fnc_logger;

	// Global config overrides module settings
	if ([_config, "PerfData","false"] call ALIVE_fnc_hashGet != "none") then {
		if ([_config, "PerfData","false"] call ALIVE_fnc_hashGet == "true") then {
			["CONNECTED TO DATABASE AND PERFDATA IS ALLOWED"] call ALIVE_fnc_logger;
			//			MOD(sys_data) setvariable ["disablePerf", "false"];
			//			ALIVE_sys_perf_ENABLED = true;
		} else {
			["CONNECTED TO DATABASE, BUT PERFDATA HAS BEEN TURNED OFF"] call ALIVE_fnc_logger;
			MOD(sys_data) setvariable ["disablePerf", "true"];
			ALIVE_sys_perf_ENABLED = false;
			publicVariable "ALIVE_sys_perf_ENABLED";
		};
	};

	if ([_config, "EventData","false"] call ALIVE_fnc_hashGet == "false") then {
		["CONNECTED TO DATABASE, BUT STAT DATA HAS BEEN TURNED OFF"] call ALIVE_fnc_logger;
		ALIVE_sys_statistics_ENABLED = false;
		publicVariable "ALIVE_sys_statistics_ENABLED";
	};

	if ([_config, "AAR","false"] call ALIVE_fnc_hashGet == "false") then {
		["CONNECTED TO DATABASE, BUT AAR HAS BEEN TURNED OFF"] call ALIVE_fnc_logger;
		ALIVE_sys_AAR_ENABLED = false;
	} else {
		ALIVE_sys_AAR_ENABLED = true;
	};

	// Set event level on data module
 	ALIVE_sys_statistics_EventLevel = parseNumber([_config, "EventLevel","5"] call ALIVE_fnc_hashGet);
	// Set stats level
	MOD(sys_data) setVariable ["EventLevel", ALIVE_sys_statistics_EventLevel, true];

	// Load Data Dictionary from central public database
	_dictionaryName = format["dictionary_%1_%2", GVAR(GROUP_ID), missionName];

	GVAR(DictionaryRevs) = [];

	// Try loading dictionary from db
	["DATA: Loading data dictionary %1.", _dictionaryName] call ALIVE_fnc_dump;

	_response = [GVAR(datahandler), "read", ["sys_data", [], _dictionaryName]] call ALIVE_fnc_Data;
	if ( typeName _response != "STRING") then {
		ALIVE_DataDictionary = _response;

		// Capture Dictionary revision information
		GVAR(DictionaryRevs) set [count GVAR(DictionaryRevs), [ALIVE_DataDictionary, "_rev"] call CBA_fnc_hashGet];

		// Try loading more dictionary entries
		private ["_i","_newresponse","_addResponse"];
		_i = 1;
		while {_dictionaryName = format["dictionary_%1_%2_%3", GVAR(GROUP_ID), missionName, _i]; _newresponse = [GVAR(datahandler), "read", ["sys_data", [], _dictionaryName]] call ALIVE_fnc_Data; typeName _newresponse != "STRING"} do {

			_addResponse = {
				[ALIVE_DataDictionary, _key, _value] call CBA_fnc_hashSet;
			};

			[_newresponse, _addResponse] call CBA_fnc_hashEachPair;
			GVAR(DictionaryRevs) set [count GVAR(DictionaryRevs), [_newresponse, "_rev"] call CBA_fnc_hashGet];
			_i = _i + 1;
		};

		GVAR(dictionaryLoaded) = true;

		if(ALiVE_SYS_DATA_DEBUG_ON) then {
            ["ALiVE SYS_DATA - DICTIONARY LOADED: %1",ALIVE_DataDictionary] call ALIVE_fnc_dump;
        };

	} else {
		["DATA: No data dictionary found, might be new mission"] call ALIVE_fnc_dump;
	    if(ALiVE_SYS_DATA_DEBUG_ON) then {
            ["ALiVE SYS_DATA - NO DICTIONARY AVAILABLE: %1",_response] call ALIVE_fnc_dump;
        };

		// Need to cancel loading data if there is no dictionary
		GVAR(dictionaryLoaded) = false;
	};

	if(ALiVE_SYS_DATA_DEBUG_ON) then {
        ["ALiVE SYS_DATA - MISSION: %1 %2 %3",_logic, MOD(sys_data), MOD(sys_data) getVariable "saveDateTime"] call ALIVE_fnc_dump;
    };

	// Handle basic mission persistence - date/time and custom variables
	GVAR(mission_data) = [] call CBA_fnc_hashCreate;
	if (GVAR(dictionaryLoaded) && (MOD(sys_data) getVariable ["saveDateTime","false"] == "true")) then {
		private ["_missionName","_response"];
		// Read in date/time for mission
		["DATA: Loading basic mission data."] call ALIVE_fnc_dump;
		_missionName = format["%1_%2", GVAR(GROUP_ID), missionName];
		_response = [GVAR(datahandler), "read", ["sys_data", [], _missionName]] call ALIVE_fnc_Data;
		if ( typeName _response != "STRING") then {
			GVAR(mission_data) = _response;

			if(ALiVE_SYS_DATA_DEBUG_ON) then {
                ["ALiVE SYS_DATA - MISSION DATA LOADED: %1",_response] call ALIVE_fnc_dump;
            };

			setdate ([GVAR(mission_data), "date", date] call CBA_fnc_hashGet);
		} else {

			if(ALiVE_SYS_DATA_DEBUG_ON) then {
                ["ALiVE SYS_DATA - NO MISSION DATA AVAILABLE: %1",_response] call ALIVE_fnc_dump;
            };

		};
	} else {

	    if(ALiVE_SYS_DATA_DEBUG_ON) then {
            ["ALiVE SYS_DATA - EITHER DATA LOAD FAILED OR MISSION DATA PERSISTENCE TURNED OFF: %1",GVAR(dictionaryLoaded)] call ALIVE_fnc_dump;
        };

	};


	// Spawn a process to handle async writes

	// loop and wait for queue to be updated
	// When queue changes process request, wait for response
	GVAR(ASYNC_QUEUE) = [];
	publicVariable QGVAR(ASYNC_QUEUE);

	// Need to optimise this with PFH
	[] spawn {
		["ALiVE SYS_DATA - ASYNC WRITE LOOP STARTING"] call ALIVE_fnc_dump;
		while {true} do {
			TRACE_1("ASYNC QUEUE COUNT", count GVAR(ASYNC_QUEUE));
		//	{
		//		["ALiVE SYS_DATA - ASYNC QUEUE %2: %1", _x, _forEachIndex] call ALIVE_fnc_dump;
		//	} foreach GVAR(ASYNC_QUEUE);
			{
				private ["_cmd","_response"];
				_cmd = _x;

				//"Arma2Net.Unmanaged" callExtension _cmd;
				"ALiVEPlugIn" callExtension _cmd;

				waitUntil {sleep 0.3; _response = ["SendJSONAsync []"] call ALIVE_fnc_sendToPlugIn; _response != "WAITING"};

				GVAR(ASYNC_QUEUE) deleteAt _forEachIndex;

				TRACE_3("ASYNC WRITE LOOP", _cmd, _response, count GVAR(ASYNC_QUEUE));

				if(ALiVE_SYS_DATA_DEBUG_ON) then {
                	["ALiVE SYS_DATA - ASYNC WRITE LOOP: %1 : %2", _cmd, _response] call ALIVE_fnc_dump;
            	};

				sleep 0.3;

			} foreach GVAR(ASYNC_QUEUE);
			sleep 5;
		};
	};

	TRACE_2("SYS_DATA PERF VAR", MOD(sys_data) getVariable "disablePerf", ALIVE_sys_perf_ENABLED);
	// Start the perf monitoring module
	if (MOD(sys_data) getvariable ["disablePerf", "false"] == "false") then {
		[MOD(sys_data)] call ALIVE_fnc_perfInit;
	} else {
		ALIVE_sys_perf_ENABLED = false;
		ALIVE_sys_perf_DISABLED = true;
	};

	// AAR system - should prob be its own module

	TRACE_2("SYS_DATA AAR VAR", MOD(sys_data) getVariable "disableAAR", ALIVE_sys_AAR_ENABLED);
	// Start the AAR monitoring module
	if (MOD(sys_data) getvariable ["disableAAR", "true"] == "false" && ALIVE_sys_AAR_ENABLED) then {

		["DATA: Starting AAR system."] call ALIVE_fnc_dump;

		[] spawn {
			// Thread running on server to report state/pos of every playable unit and group every 60 seconds
			private ["_tickt","_docId","_missionName","_result"];

			// Setup data handler
			GVAR(aar_datahandler) = [nil, "create"] call ALIVE_fnc_Data;
           [GVAR(aar_datahandler),"storeType",false] call ALIVE_fnc_Data;

			// Set up hash of unit positions for each minute
			GVAR(AAR) = [] call ALIVE_fnc_hashCreate;
			GVAR(AAR_Array) = [];

			GVAR(operation) = getText (missionConfigFile >> "OnLoadName");

			if (GVAR(operation) == "") then {
					GVAR(operation) = missionName;
			};

			_tickt = diag_tickTime;

			waitUntil {sleep 61; count playableUnits > 0};

			while {MOD(sys_data) getVariable "disableAAR" == "false"} do {

				private ["_hash","_dateTime","_currenttime","_minutes","_hours","_gametime","_ttm"];
				_ttm = diag_tickTime;
				TRACE_1("SYS_DATA AAR", _tickt);
				TRACE_1("SYS_DATA AAR", _ttm);

				if ( (count playableUnits > 0) && (_ttm > (_tickt + AAR_DEFAULT_SAMPLE_RATE) ) ) then {

					GVAR(AARdocId) = [] call ALIVE_fnc_realTimeToDTG;

					// Get local time and format please.
					_currenttime = date;

					// Work out time in 4 digits
					if ((_currenttime select 4) < 10) then {
						_minutes = "0" + str(_currenttime select 4);
					} else {
						_minutes = str(_currenttime select 4);
						};
					if ((_currenttime select 3) < 10) then {
						_hours = "0" + str(_currenttime select 3);
					} else {
						_hours = str(_currenttime select 3);
					};

					_gametime = format["%1%2", _hours, _minutes];
					_realTime = [] call ALIVE_fnc_getServerTime;
					TRACE_1("SYS_DATA AAR", allUnits);
					{
						private ["_unit"];
						_unit = vehicle _x;
						if (alive _unit && (isplayer _x || (_unit == leader (group _unit) && (side _unit != civilian)))) then {
							private ["_playerHash"];
							TRACE_1("SYS_DATA AAR", _unit);
							_playerHash = [] call ALIVE_fnc_hashCreate;

							[_playerHash, "AAR_name", name _unit] call ALIVE_fnc_hashSet;
							[_playerHash, "AAR_pos", getpos _unit] call ALIVE_fnc_hashSet;
							[_playerHash, "AAR_weapon", primaryWeapon _unit] call ALIVE_fnc_hashSet;
							[_playerHash, "AAR_dir", ceil(getdir _unit)] call ALIVE_fnc_hashSet;
							[_playerHash, "AAR_config", typeof _unit] call ALIVE_fnc_hashSet;
							[_playerHash, "AAR_class", getText (configFile >> "cfgVehicles" >> (typeof _unit) >> "displayName")] call ALIVE_fnc_hashSet;
							[_playerHash, "AAR_damage", damage _unit] call ALIVE_fnc_hashSet;
							[_playerHash, "AAR_side", side (group _unit)] call ALIVE_fnc_hashSet;
							[_playerHash, "AAR_fac", getText (configFile >> "cfgFactionClasses" >> (faction _unit) >> "displayName")] call ALIVE_fnc_hashSet;
							[_playerHash, "AAR_isLeader", _unit == leader (group _unit)] call ALIVE_fnc_hashSet;
							[_playerHash, "AAR_isPlayer", isPlayer _unit] call ALIVE_fnc_hashSet;
							[_playerHash, "AAR_group", str (group _unit)] call ALIVE_fnc_hashSet;

							if (isPlayer _unit) then {
								[_playerHash, "AAR_playerUID", getPlayerUID _unit] call ALIVE_fnc_hashSet;
							};

							GVAR(AAR_Array) set [count GVAR(AAR_Array), _playerHash];

						};
					} forEach allUnits;

					[GVAR(AAR), "gameTime", _gametime] call ALIVE_fnc_hashSet;
					[GVAR(AAR), "realTime", _realTime] call ALIVE_fnc_hashSet;
					[GVAR(AAR), "Group", GVAR(GROUP_ID)] call ALIVE_fnc_hashSet;
					[GVAR(AAR), "Operation", GVAR(operation)] call ALIVE_fnc_hashSet;
					[GVAR(AAR), "Map", worldName] call ALIVE_fnc_hashSet;
					[GVAR(AAR), "AAR_data", GVAR(AAR_Array)] call ALIVE_fnc_hashSet;

					// Send the data to DB
					_missionName = format["%1_%2_%3", GVAR(GROUP_ID), missionName, GVAR(AARdocId)];

					// async write
					_result = [GVAR(aar_datahandler), "write", ["sys_aar", GVAR(AAR), true, _missionName] ] call ALIVE_fnc_Data;
					TRACE_1("SYS_AAR",_result);

					// Reset
					GVAR(AAR) = [] call ALIVE_fnc_hashCreate;
					GVAR(AAR_Array) resize 0;
					TRACE_1("SYS_AAR",GVAR(AAR_Array));
					_tickt = diag_tickTime;

				};

				sleep AAR_DEFAULT_SAMPLE_RATE;

			};
			Diag_log "AAR system stopped";
		};
	};
};


if (isDedicated && {!isnil QMOD(SYS_DATA)}) then {
	MOD(sys_data) setvariable ["startupComplete",true,true];
};

TRACE_2("SYS_DATA STAT VAR", MOD(sys_data) getVariable "disableStats", ALIVE_sys_statistics_ENABLED);
// Kickoff the stats module
if (_logic getvariable ["disableStats","false"] == "false") then {
	["DATA: Starting stats system."] call ALIVE_fnc_dump;
	[_logic] call ALIVE_fnc_statisticsInit;
};



[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;