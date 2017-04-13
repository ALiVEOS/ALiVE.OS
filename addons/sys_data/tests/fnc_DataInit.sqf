#include <\x\alive\addons\sys_data\script_component.hpp>
SCRIPT(DataInit);

#define AAR_DEFAULT_SAMPLE_RATE 5
#define AAR_DEFAULT_SAVE_INTERVAL 120
#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_Data

// Sets up a system for data (separate from the fnc_data module = datahandler)

LOG(MSG_INIT);
private ["_response","_dictionaryName","_logic","_config","_moduleID","_mode"];

PARAMS_2(_logic,_mode);

// Confirm init function available
ASSERT_DEFINED("ALIVE_fnc_Data","Main function missing");

//Only one init per instance is allowed
if (!isnil QUOTE(ADDON) && isServer) exitwith {["ALiVE SYS DATA - Only one init process per instance allowed! Exiting..."] call ALiVE_fnc_Dump};

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

TRACE_2("SYS_DATA",isServer, _logic);

_moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

if (_logic getvariable ["debug", "false"] == "true") then {
    ALiVE_SYS_DATA_DEBUG_ON = true;
}else{
    ALiVE_SYS_DATA_DEBUG_ON = false;
};

if (isServer) then {

    // Setup OPC and OPD events
    //[QGVAR(OPD), "OnPlayerDisconnected","ALIVE_fnc_data_OnPlayerDisconnected"] call BIS_fnc_addStackedEventHandler;

	MOD(sys_data) = _logic;

    //Set Data logic defaults
    GVAR(DISABLED) = false;
    publicVariable QGVAR(DISABLED);   

    GVAR(databaseName) = "arma3live";
    GVAR(source) = MOD(sys_data) getVariable ["source","CouchDB"];
    
    switch GVAR(source) do {
        
        case "pns" : {

            GVAR(GROUP_ID) = "ALiVE";
            GVAR(datahandler) = [nil, "create"] call ALIVE_fnc_Data;
            GVAR(DictionaryRevs) = [];
            MOD(DataDictionary) = [] call ALiVE_fnc_HashCreate;
            GVAR(dictionaryLoaded) = true;

	        MOD(sys_data) setvariable ["disableStats", "true",true];
	        ALIVE_sys_statistics_ENABLED = false;
	        publicVariable "ALIVE_sys_statistics_ENABLED";

		    ALIVE_sys_statistics_EventLevel = 5;
		    MOD(sys_data) setVariable ["EventLevel", ALIVE_sys_statistics_EventLevel, true];
            publicVariable "ALIVE_sys_statistics_EventLevel";

            MOD(sys_data) setvariable ["disablePerf", "true",true];
            ALIVE_sys_perf_ENABLED = false;
            publicVariable "ALIVE_sys_perf_ENABLED";         

            MOD(sys_data) setvariable ["disableAAR", "true",true];
            ALIVE_sys_AAR_ENABLED = false; 
            publicVariable "ALIVE_sys_AAR_ENABLED";                                                 
        };
        
        case "CouchDB" : {
    		
		    if (!isDedicated) exitWith {
		        ["SYS DATA COUCHDB NOT RUN ON DEDICATED SERVER, DISABLING DATA MODULE"] call ALIVE_fnc_logger;
                
		        GVAR(DISABLED) = true;
		        publicVariable QGVAR(DISABLED);
		        
	            MOD(sys_data) setvariable ["disableStats", "true"];
		        ALIVE_sys_statistics_ENABLED = false;
		        publicVariable "ALIVE_sys_statistics_ENABLED";
		        
	            MOD(sys_data) setvariable ["disablePerf", "true"];
		        ALIVE_sys_perf_ENABLED = false;
		        publicVariable "ALIVE_sys_perf_ENABLED";
                
                MOD(sys_data) = nil;
		    };

		    //Set Data logic defaults
		    GVAR(DISABLED) = false;
		    publicVariable QGVAR(DISABLED);                

		    private _initmsg = [_logic getVariable ["disablePerfMon","true"]] call ALIVE_fnc_startALiVEPlugIn;
		
		    ["ALIVE_SYS_DATA START PLUGIN: %1", _initmsg] call ALIVE_fnc_dump;
		
		    private _serverIP = [] call ALIVE_fnc_getServerIP;
		    // If the host IP web service is down, just use the serverName
		    if (_serverIP != "SYS_DATA_ERROR" && typeName _initmsg == "STRING" && {_initmsg == "YOU ARE NOT AUTHORIZED"}) then {
		        ["YOUR SERVER EXTERNAL IP ADDRESS AS SEEN BY WAR ROOM: %1 (Ensure it matches with your War Room server entry if you have any issues)",_serverIP] call ALiVE_fnc_dump;
		    };
		
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
		    if (typeName _config == "STRING" || (typeName _initmsg == "STRING" && {_initmsg == "YOU ARE NOT AUTHORIZED"})) exitWith {
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
		            //            MOD(sys_data) setvariable ["disablePerf", "false"];
		            //            ALIVE_sys_perf_ENABLED = true;
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
		    } else {
		        ALIVE_sys_statistics_ENABLED = if (_logic getvariable ["disableStats","false"] == "false") then {true} else {false};
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
		        GVAR(DictionaryRevs) pushback ([ALIVE_DataDictionary, "_rev"] call CBA_fnc_hashGet);
		
		        // Try loading more dictionary entries
		        private ["_i","_newresponse","_addResponse"];
		        _i = 1;
		        while {_dictionaryName = format["dictionary_%1_%2_%3", GVAR(GROUP_ID), missionName, _i]; _newresponse = [GVAR(datahandler), "read", ["sys_data", [], _dictionaryName]] call ALIVE_fnc_Data; typeName _newresponse != "STRING"} do {
		
		            _addResponse = {
		                [ALIVE_DataDictionary, _key, _value] call CBA_fnc_hashSet;
		            };
		
		            [_newresponse, _addResponse] call CBA_fnc_hashEachPair;
		            GVAR(DictionaryRevs) pushback ([_newresponse, "_rev"] call CBA_fnc_hashGet);
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
		        //    {
		        //        ["ALiVE SYS_DATA - ASYNC QUEUE %2: %1", _x, _forEachIndex] call ALIVE_fnc_dump;
		        //    } foreach GVAR(ASYNC_QUEUE);
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
        };                
    };
    
    if (GVAR(DISABLED)) exitwith {};                          
                        		
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
	
    // Handle compositions persistence
    MOD(PCOMPOSITIONS) = [] call CBA_fnc_hashCreate;
    if (GVAR(dictionaryLoaded) && (MOD(sys_data) getVariable ["saveCompositions","false"] == "true")) then {
        private ["_missionName","_response"];
        // Read in compositions for mission
        ["DATA: Loading mission compositions data."] call ALIVE_fnc_dump;
        _missionName = format["%1_%2_COMPOSITIONS", GVAR(GROUP_ID), missionName];
        _response = [GVAR(datahandler), "read", ["sys_data", [], _missionName]] call ALIVE_fnc_Data;
        if ( typeName _response != "STRING") then {
            MOD(PCOMPOSITIONS) = _response;

            if(ALiVE_SYS_DATA_DEBUG_ON) then {
                ["ALiVE SYS_DATA - MISSION COMPOSITION DATA LOADED: %1",_response] call ALIVE_fnc_dump;
            };

            // Update CIV PLACEMENT Module so that roadblocks are not duplicated
            ALIVE_CIV_PLACEMENT_ROADBLOCK_LOCATIONS = [MOD(PCOMPOSITIONS),"roadblock_locs",[]] call ALiVE_fnc_hashGet;
            ALIVE_CIV_PLACEMENT_ROADBLOCKS = [MOD(PCOMPOSITIONS),"comp_roadblocks",[]] call ALiVE_fnc_hashGet; // Should be in 1.2.9

            // Get all spawned composition data
            private _compositions = [MOD(PCOMPOSITIONS),"compositions",[[],[]]] call ALiVE_fnc_hashGet;
            // Spawn all compositions
            {
                private _entry = (_compositions select 1) select _forEachIndex;
                [_entry select 0, _x, _entry select 1, _entry select 2] call ALiVE_fnc_spawnComposition;
            } foreach (_compositions select 0);

            MOD(COMPOSITIONS_LOADED) = true;

        } else {

            if(ALiVE_SYS_DATA_DEBUG_ON) then {
                ["ALiVE SYS_DATA - NO MISSION COMPOSITION DATA AVAILABLE: %1",_response] call ALIVE_fnc_dump;
            };

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
    if (MOD(sys_data) getvariable ["disableAAR", "false"] == "false" && ALIVE_sys_AAR_ENABLED) then {

        ["DATA: Starting AAR system."] call ALIVE_fnc_dump;

        [] spawn {
            // Thread running on server to report state/pos of every playable unit and group every x seconds
            // Setup data handler
            GVAR(aar_datahandler) = [nil, "create"] call ALIVE_fnc_Data;
           [GVAR(aar_datahandler),"storeType",false] call ALIVE_fnc_Data;

            GVAR(operation) = getText (missionConfigFile >> "OnLoadName");

            if (GVAR(operation) == "") then {
                    GVAR(operation) = missionName;
            };

            private _aar = [] call ALIVE_fnc_hashCreate;

            waitUntil {sleep 61; count playableUnits > 0};

            private _lastSave = diag_tickTime;
            private _missionName = [GVAR(operation), "%20","-"] call CBA_fnc_replace;
            _missionName = format["%1_%2", GVAR(GROUP_ID), _missionName];

            while {MOD(sys_data) getVariable ["disableAAR","false"] == "false"} do {

                private _allPlayers = [];
                {
                    if (isPlayer _x) then
                    {
                        _allPlayers pushBack _x;
                    };
                } forEach playableUnits;
                if (count _allPlayers > 0) then {

                    // Set up hash of unit positions
                    private _aarRecord = [] call ALIVE_fnc_hashCreate;
                    private _aarArray = [];
                    private _aarvehArray = [];
                    private _minutes = "";
                    private _hours = "";

                    [_aarRecord, "Group", GVAR(GROUP_ID)] call ALIVE_fnc_hashSet;
                    [_aarRecord, "Operation", GVAR(operation)] call ALIVE_fnc_hashSet;
                    [_aarRecord, "Map", worldName] call ALIVE_fnc_hashSet;

                    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    // Handle infantry
                    private _aarDocID = [] call ALIVE_fnc_realTimeToDTG;
                    // Get local time and format please.
                    private _currenttime = date;

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

                    private _gametime = format["%1%2", _hours, _minutes];
                    private _realTime = [] call ALIVE_fnc_getServerTime;
                    private _missionTime = round time;

                    [_aarRecord, "gameTime", _gametime] call ALIVE_fnc_hashSet;
                    [_aarRecord, "realTime", _realTime] call ALIVE_fnc_hashSet;
                    [_aarRecord, "missionTime", _missionTime] call ALIVE_fnc_hashSet;

                    [_aarRecord, "AAR_type", "positions_infantry"] call ALIVE_fnc_hashSet;

                    TRACE_1("SYS_DATA AAR", allUnits);
                    {
                        private _unit = _x;
                        if ((vehicle _unit == _unit) && alive _unit && (typeof _unit != "Logic") && (side _unit != civilian)) then {
                            TRACE_1("SYS_DATA AAR", _unit);
                            private _unitHash = [] call ALIVE_fnc_hashCreate;

                            [_unitHash, "AAR_unit", _unit] call ALIVE_fnc_hashSet;
                            [_unitHash, "AAR_name", name _unit] call ALIVE_fnc_hashSet;
                            [_unitHash, "AAR_pos", getpos _unit] call ALIVE_fnc_hashSet;
                            [_unitHash, "AAR_weapon", primaryWeapon _unit] call ALIVE_fnc_hashSet;
                            [_unitHash, "AAR_dir", ceil(getdir _unit)] call ALIVE_fnc_hashSet;
                            [_unitHash, "AAR_config", typeof _unit] call ALIVE_fnc_hashSet;
                            [_unitHash, "AAR_class", getText (configFile >> "cfgVehicles" >> (typeof _unit) >> "displayName")] call ALIVE_fnc_hashSet;
                            [_unitHash, "AAR_damage", damage _unit] call ALIVE_fnc_hashSet;
                            [_unitHash, "AAR_side", side (group _unit)] call ALIVE_fnc_hashSet;
                            [_unitHash, "AAR_fac", getText (((faction _unit) call ALiVE_fnc_configGetFactionClass) >> "displayName")] call ALIVE_fnc_hashSet;
                            [_unitHash, "AAR_ico", (getText (configFile >> "CfgVehicles" >> (typeOf _unit) >> "icon")) splitString "\" joinString ""] call ALiVE_fnc_hashSet;
                            [_unitHash, "AAR_isLeader", _unit == leader (group _unit)] call ALIVE_fnc_hashSet;
                            [_unitHash, "AAR_isPlayer", isPlayer _unit] call ALIVE_fnc_hashSet;
                            [_unitHash, "AAR_group", str (group _unit)] call ALIVE_fnc_hashSet;
                            [_unitHash, "AAR_groupid", groupID group _unit] call ALIVE_fnc_hashSet;

                            if (isPlayer _unit) then {
                                [_unitHash, "AAR_playerUID", getPlayerUID _unit] call ALIVE_fnc_hashSet;
                            };

                            _aarArray pushback _unitHash;

                        };
                    } forEach allUnits;

                    [_aarRecord, "value", _aarArray] call ALIVE_fnc_hashSet;

                    // Send the inf data to DB
                    private _keyName = format["%1_%2_i",_aarDocID,_missionTime];

                    // store in aar hash
                    [_aar,_keyName,_aarRecord] call ALiVE_fnc_hashSet;

                    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    // Handle vehicles
                    _aarDocID = [] call ALIVE_fnc_realTimeToDTG;

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
                    _missionTime = round time;

                    private _aarVRecord = [] call ALIVE_fnc_hashCreate;
                    [_aarVRecord, "Group", GVAR(GROUP_ID)] call ALIVE_fnc_hashSet;
                    [_aarVRecord, "Operation", GVAR(operation)] call ALIVE_fnc_hashSet;
                    [_aarVRecord, "Map", worldName] call ALIVE_fnc_hashSet;
                    [_aarVRecord, "gameTime", _gametime] call ALIVE_fnc_hashSet;
                    [_aarVRecord, "realTime", _realTime] call ALIVE_fnc_hashSet;
                    [_aarVRecord, "missionTime", _missionTime] call ALIVE_fnc_hashSet;
                    [_aarVRecord, "AAR_type", "positions_vehicles"] call ALIVE_fnc_hashSet;

                    {
                        private _veh = vehicle _x;
                        if ((typeof _veh != "Logic") && (side _veh != civilian) && (count crew _veh > 0)) then {
                            TRACE_1("SYS_DATA AAR", _veh);
                            private _vehHash = [] call ALIVE_fnc_hashCreate;

                            [_vehHash, "AAR_unit", _veh] call ALIVE_fnc_hashSet;
                            [_vehHash, "AAR_pos", getpos _veh] call ALIVE_fnc_hashSet;
                            [_vehHash, "AAR_dir", ceil(getdir _veh)] call ALIVE_fnc_hashSet;
                            [_vehHash, "AAR_config", typeof _veh] call ALIVE_fnc_hashSet;
                            [_vehHash, "AAR_class", getText (configFile >> "cfgVehicles" >> (typeof _veh) >> "displayName")] call ALIVE_fnc_hashSet;
                            [_vehHash, "AAR_damage", damage _veh] call ALIVE_fnc_hashSet;
                            [_vehHash, "AAR_side", side (group _veh)] call ALIVE_fnc_hashSet;
                            [_vehHash, "AAR_fac", getText (((faction _veh) call ALiVE_fnc_configGetFactionClass) >> "displayName")] call ALIVE_fnc_hashSet;
                            [_vehHash, "AAR_group", str (group _veh)] call ALIVE_fnc_hashSet;
                            [_vehHash, "AAR_groupid", groupID group _veh] call ALIVE_fnc_hashSet;

                            if (isPlayer _veh) then {
                                [_vehHash, "AAR_playerUID", getPlayerUID _veh] call ALIVE_fnc_hashSet;
                            };

                            private _vehicleCrew = (
                                _veh call {
                                    private _crew = [];
                                    {
                                        if(isPlayer _x) then {
                                            if(_this getCargoIndex _x == -1) then {
                                                _crew pushBack getPlayerUID _x;
                                            };
                                        };
                                    } forEach crew _this;
                                    _crew
                                }
                            );

                            private _vehicleCargo = (
                                _veh call {
                                    private _cargo = [];
                                    {
                                        if(isPlayer _x) then {
                                            if(_this getCargoIndex _x >= 0) then {
                                                _cargo pushBack getPlayerUID _x;
                                            };
                                        };
                                    } forEach crew _this;
                                    _cargo
                                }
                            );

                            private _vehicleIcon = (
                                        _veh call {

                                            if (_this isKindOf "Heli_Attack_01_base_F" || _this isKindOf "Heli_Attack_02_base_F" || _this isKindOf "Heli_Attack_03_base_F") exitWith { "iconHelicopterAttack" };
                                            if (_this isKindOf "Heli_Transport_01_base_F" || _this isKindOf "Heli_Transport_02_base_F" || _this isKindOf "Heli_Transport_03_base_F") exitWith { "iconHelicopterTransport" };
                                            if (_this isKindOf "Plane_CAS_01_base_F") exitWith { "iconPlaneAttack" };
                                            if (_this isKindOf "Plane_CAS_02_base_F") exitWith { "iconPlaneAttack" };
                                            if (_this isKindOf "Plane_CAS_03_base_F") exitWith { "iconPlaneAttack" };
                                            if (_this isKindOf "APC_Tracked_03_base_F") exitWith { "iconAPC" };
                                            if (_this isKindOf "APC_Tracked_02_base_F") exitWith { "iconAPC" };
                                            if (_this isKindOf "APC_Tracked_01_base_F") exitWith { "iconAPC" };
                                            if (_this isKindOf "Truck_01_base_F") exitWith { "iconTruck" };
                                            if (_this isKindOf "Truck_02_base_F") exitWith { "iconTruck" };
                                            if (_this isKindOf "Truck_03_base_F") exitWith { "iconTruck" };
                                            if (_this isKindOf "MRAP_01_base_F") exitWith { "iconMRAP" };
                                            if (_this isKindOf "MRAP_02_base_F") exitWith { "iconMRAP" };
                                            if (_this isKindOf "MRAP_03_base_F") exitWith { "iconMRAP" };
                                            if (_this isKindOf "MBT_01_arty_base_F") exitWith { "iconTankArtillery" };
                                            if (_this isKindOf "MBT_02_arty_base_F") exitWith { "iconTankArtillery" };
                                            if (_this isKindOf "MBT_03_arty_base_F") exitWith { "iconTankArtillery" };
                                            if (_this isKindOf "MBT_01_base_F") exitWith { "iconTank" };
                                            if (_this isKindOf "MBT_02_base_F") exitWith { "iconTank" };
                                            if (_this isKindOf "MBT_03_base_F") exitWith { "iconTank" };
                                            if (_this isKindOf "StaticCannon") exitWith { "iconStaticCannon" };
                                            if (_this isKindOf "StaticAAWeapon") exitWith { "iconStaticAA" };
                                            if (_this isKindOf "StaticATWeapon") exitWith { "iconStaticAT" };
                                            if (_this isKindOf "StaticMGWeapon") exitWith { "iconStaticMG" };
                                            if (_this isKindOf "StaticWeapon") exitWith { "iconStaticWeapon" };
                                            if (_this isKindOf "StaticGrenadeLauncher") exitWith { "iconStaticGL" };

                                            if (_this isKindOf "Steerable_Parachute_F" || _this isKindOf "NonSteerable_Parachute_F") exitWith { "iconParachute" };
                                            if (_this isKindOf "Boat_F") exitWith { "iconBoat" };
                                            if (_this isKindOf "Truck_F") exitWith { "iconTruck" };
                                            if (_this isKindOf "Tank" || _this isKindOf "Tank_F") exitWith { "iconTank" };
                                            if (_this isKindOf "Car" || _this isKindOf "Car_F") exitWith { "iconCar" };
                                            if (_this isKindOf "Helicopter_Base_F") exitWith { "iconHelicopter" };
                                            if (_this isKindOf "Plane_Base_F" || _this isKindOf "Plane") exitWith { "iconPlane" };

                                            //diag_log format["unknown vehicle type: %1", typeOf _this];
                                            "iconUnknown";
                                        }
                            );
                            [_vehHash, "AAR_ico", _vehicleIcon] call ALIVE_fnc_hashSet;
                            [_vehHash, "AAR_crew", _vehicleCrew] call ALIVE_fnc_hashSet;
                            [_vehHash, "AAR_cargo", _vehicleCargo] call ALIVE_fnc_hashSet;

                            _aarvehArray pushback _vehHash;

                        };
                    } forEach vehicles;

                    [_aarVRecord, "value", _aarvehArray] call ALIVE_fnc_hashSet;

                    // Send the inf data to DB
                    _keyName = format["%1_%2_v",_aarDocID,_missionTime];

                    // store in aar hash
                    [_aar,_keyName,_aarVRecord] call ALiVE_fnc_hashSet;

                    // Check to see if it's time to write to the DB
                    if (diag_tickTime > (_lastSave + AAR_DEFAULT_SAVE_INTERVAL))  then {
                        // async write
                        _result = [GVAR(aar_datahandler), "bulkWrite", ["sys_aar", _aar, true, _missionName]] call ALIVE_fnc_Data;
                        TRACE_1("SYS_AAR",_result);

                        // reset data
                        _aar = [] call ALIVE_fnc_hashCreate;
                        _lastSave = diag_tickTime;
                    };

                };

                sleep AAR_DEFAULT_SAMPLE_RATE;

            };
            diag_log "AAR system stopped";
        };
    };
};

if (isServer && {!isnil QMOD(SYS_DATA)}) then {
    MOD(sys_data) setvariable ["startupComplete",true,true];
};

TRACE_2("SYS_DATA STAT VAR", MOD(sys_data) getVariable "disableStats", ALIVE_sys_statistics_ENABLED);
// Kickoff the stats module
if (_logic getvariable ["disableStats","false"] == "false") then {
    ["DATA: Starting stats system."] call ALIVE_fnc_dump;
    [_logic] call ALIVE_fnc_statisticsInit;
};



[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;
