#include <\x\alive\addons\sys_player\script_component.hpp>
SCRIPT(player);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_player
Description:
Creates the server side object to store settings

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes that can change:
Boolean - debug - Debug enabled
Boolean - allowReset - Enabled or disable reset function
Boolean - diffClass - Enabled or disable rejoin as different class function
Boolean - storeToDB - Enabled or disable auto save to external database
Boolean - allowManualSave - Enable or disable manual save
integer - autoSaveTime - Interval between database saves
string - key - a unique id to represent the mission on this specific server

The popup menu will change to show status as functions are enabled and disabled.

Examples:
(begin example)
// Create instance by placing editor module and specifiying name myModule
(end)

See Also:
- <ALIVE_fnc_playerInit>
- <ALIVE_fnc_playerMenuDef>

Author:
Tupolov

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_Player

#define DEFAULT_INTERVAL 300

#define DEFAULT_RESET true
#define DEFAULT_DIFFCLASS false
#define DEFAULT_MANUALSAVE true
#define DEFAULT_storeToDB false
#define DEFAULT_autoSaveTime 0

private ["_result", "_operation", "_args", "_logic", "_ops"];

_logic = [_this, 0, objNull, [objNull,[]]] call BIS_fnc_param;
_operation = [_this, 1, "", [""]] call BIS_fnc_param;
_args = [_this, 2, objNull, [objNull,[],"",0,true,false]] call BIS_fnc_param;

TRACE_3(QUOTE(ADDON),_logic, _operation, _args);


_result = true;

switch(_operation) do {
        case "create": {
                if (isServer) then {

                    // Ensure only one module is used
                    if !(isNil QUOTE(ADDON)) then {
                        _logic = ADDON;
                        ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_player_ERROR1");
                    } else {
                        _logic = (createGroup sideLogic) createUnit [QUOTE(ADDON), [0,0], [], 0, "NONE"];
                        ADDON = _logic;
                    };

                    //Push to clients
                    PublicVariable QUOTE(ADDON);
                };

                TRACE_1("Waiting for object to be ready",true);

                waituntil {!isnil QUOTE(ADDON)};

                TRACE_1("Creating class on all localities",true);

                // initialise module game logic on all localities
                ADDON setVariable ["super", QUOTE(SUPERCLASS)];
                ADDON setVariable ["class", QUOTE(MAINCLASS)];


                _result = ADDON;
        };
        case "init": {

                //Only one init per instance is allowed
            	if !(isnil {_logic getVariable "initGlobal"}) exitwith {["ALiVE SYS PLAYER - Only one init process per instance allowed! Exiting..."] call ALiVE_fnc_Dump};

            	//Start init
            	_logic setVariable ["initGlobal", false];

                /*
                MODEL - no visual just reference data
                - module object stores parameters
                - Establish data handler on server
                - Establish data model on server and client
                */

                MOD(sys_player) = _logic;

                // Set Module Parameters as booleans
                MOD(sys_player) setVariable ["enablePlayerPersistence", call compile (_logic getvariable "enablePlayerPersistence")];
                MOD(sys_player) setVariable ["allowReset", call compile (_logic getvariable "allowReset")];
                MOD(sys_player) setVariable ["allowDiffClass", call compile (_logic getvariable "allowDiffClass")];
                MOD(sys_player) setVariable ["allowManualSave", call compile (_logic getvariable "allowManualSave")];
                MOD(sys_player) setVariable ["storeToDB", call compile (_logic getvariable "storeToDB")];
                MOD(sys_player) setVariable ["autoSaveTime", call compile (_logic getvariable "autoSaveTime")];

                MOD(sys_player) setVariable ["saveLoadout", call compile (_logic getvariable "saveLoadout")];
                MOD(sys_player) setVariable ["saveAmmo", call compile (_logic getvariable "saveAmmo")];
                MOD(sys_player) setVariable ["saveHealth", call compile (_logic getvariable "saveHealth")];
                MOD(sys_player) setVariable ["savePosition", call compile (_logic getvariable "savePosition")];
                MOD(sys_player) setVariable ["saveScores", call compile (_logic getvariable "saveScores")];

                MOD(sys_player) setVariable ["saved", false];

               MOD(sys_player) setVariable ["super", QUOTE(SUPERCLASS)];
               MOD(sys_player) setVariable ["class", QUOTE(MAINCLASS)];

               if !(_logic getVariable ["enablePlayerPersistence",true]) exitWith {_logic setVariable ["bis_fnc_initModules_activate",true]; ["ALiVE SYS PLAYER - Feature turned off! Exiting..."] call ALiVE_fnc_Dump};

                // DEFINE PLAYER DATA
                #include <playerData.hpp>

                // Create Player and Gear Store in memory on client and server
                GVAR(player_data) = [] call ALIVE_fnc_hashCreate;
                GVAR(gear_data) = [] call ALIVE_fnc_hashCreate;

                 TRACE_4("SYS_PLAYER1", typename (MOD(sys_player) getvariable "allowReset"), MOD(sys_player) getvariable "allowDiffClass",MOD(sys_player) getvariable "allowManualSave",MOD(sys_player) getvariable "storeToDB" );


             if (isDedicated) then {

                    // Push to clients
                    publicVariable QMOD(sys_player);

                    TRACE_4("SYS_PLAYER2", typename (MOD(sys_player) getvariable "allowReset"), MOD(sys_player) getvariable "allowDiffClass",MOD(sys_player) getvariable "allowManualSave",MOD(sys_player) getvariable "storeToDB" );

                    //Wait for data to init?
                   // WaitUntil{sleep 0.3; !isNil "ALIVE_sys_data"};
                   TRACE_3("SYS_PLAYER LOGIC", MOD(sys_player), ALIVE_sys_data, ALIVE_sys_data_DISABLED);

                    // Check to see if data module has been placed
                    if (!isNil "ALIVE_sys_data") then {
                        // Grab Server ID and Mission ID
                        private ["_serverID","_missionName"];

                        if (ALIVE_sys_data_DISABLED) exitWith {};

                        _serverID = [] call ALIVE_fnc_getServerName;
                        MOD(sys_player) setVariable ["serverID", _serverID];

                        // Setup data handler
                    	GVAR(datahandler) = [nil, "create"] call ALIVE_fnc_Data;
                    	[GVAR(datahandler),"storeType",true] call ALIVE_fnc_Data;

                        _missionName = [missionName, "%20", "-"] call CBA_fnc_replace;

                        // Set key to servername if group tag not available
                        MOD(sys_player) setVariable ["key", ([GVAR(datahandler),"key", [] call ALIVE_fnc_getServerName] call ALIVE_fnc_hashGet) + "_" + _missionName];

                        private ["_res"];
                        // Check that a dictionary is available before loading any player data

                        if (ALIVE_sys_data_dictionaryLoaded) then {
                            // Load Player Data for Mission
                            ["DATA: Loading player data for %1", _missionName] call ALIVE_fnc_dump;
                            _res = [MOD(sys_player), "loadPlayers", [false]] call ALIVE_fnc_player;
                        } else {
                            _res = "DICTIONARY NOT AVAILABLE";
                        };

                        // Check load players returned a hash
                        if ([_res] call ALIVE_fnc_isHash) then {
                            GVAR(player_data) = _res;

                            GVAR(player_data) call ALiVE_fnc_inspectHash;
                        };

                        // Set true that player data has been loaded
                        MOD(sys_player) setVariable ["loaded", true, true];

                        TRACE_1("LOADED PLAYER DATA", _res);

                        TRACE_3("SYS_PLAYER DATA", MOD(sys_player), GVAR(player_data),GVAR(datahandler));

                    };

                    MOD(sys_player) setVariable ["init", true, true];


            } else {
                    if (!isServer && !isHC && (!isNil "ALIVE_sys_data" && {!ALIVE_sys_data_DISABLED})) then {
                        // any client side logic for model
                        TRACE_2("Adding player event handlers",isServer,isHC);

                         // Setup Put/Take EH
                         // This is required to ensure that the vest and uniform items are synched between client and server
                         // sends gear data to the server whenever there is a put/take event
                        if (_logic getvariable "saveLoadout") then {
                            player addEventHandler ["Put", {
                                private ["_gearHash","_unit"];
                                diag_log _this;
                                // Get player gear
                                _gearHash = [MOD(sys_player), "setGear", [player]] call ALIVE_fnc_player;
                                _unit = _this select 0;
                                [[MOD(sys_player), "updateGear", [_unit, _gearHash]], "ALiVE_fnc_player", false, false] call BIS_fnc_MP;

                            }];
                            player addEventHandler ["Take", {
                                private ["_gearHash","_unit"];
                                diag_log _this;
                                _unit = _this select 0;
                                // Get player gear
                                _gearHash = [MOD(sys_player), "setGear", [player]] call ALIVE_fnc_player;
                                [[MOD(sys_player), "updateGear", [_unit, _gearHash]], "ALiVE_fnc_player", false, false] call BIS_fnc_MP;

                            }];
                        };
                    };
            };


            /*
            VIEW - purely visual
            - initialise menu
            - frequent check to modify menu and display status (ALIVE_fnc_playermenuDef)
            */

            TRACE_2("Adding menu",isDedicated,isHC);

            if(!isServer && !isHC) then {
                    // Initialise interaction key if undefined
                    if(isNil "SELF_INTERACTION_KEY") then {SELF_INTERACTION_KEY = [221,[false,false,false]];};

                    // if ACE spectator enabled, seto to allow exit
                    if(!isNil "ace_fnc_startSpectator") then {ace_sys_spectator_can_exit_spectator = true;};

                    TRACE_3("Menu pre-req",SELF_INTERACTION_KEY,ace_fnc_startSpectator,DEFAULT_MAPCLICK);

                    // initialise main menu
                    [
                            "player",
                            [((["ALiVE", "openMenu"] call cba_fnc_getKeybind) select 5) select 0],
                            -9500,
                            [
                                    "call ALIVE_fnc_playerMenuDef",
                                    "main"
                            ]
                    ] call ALiVE_fnc_flexiMenu_Add;
            };

            /*
            CONTROLLER  - coordination
            - frequent check if player is server admin (ALIVE_fnc_playermenuDef)
            - Tell the server that the player is connected
            - Spawn process to regularly save player data to an in memory store
            - Spawn process to regularly save to DB based on auto save time
            - setup event handler to load data on server start (OPC)
            - setup event handler to save data on server exit (OPD)
            - setup event handler to get player data on player connected (OPC)
            - setup event handler to set player data on player disconnected (OPD)
            - setup any event handlers needed on clientside
            */

            TRACE_2("Setting player guid on logic",isDedicated,isHC);
            // For players waituntil the player is valid then let server know.
            if(!isServer && !isHC) then {
                [] spawn {
                    private ["_puid"];
                    TRACE_1("SYS_PLAYER GETTING READY",player);

                    waitUntil { !(isNull player) };
                    sleep 0.2;

                    waitUntil {!isNil QMOD(sys_player)};
                    sleep 0.2;

                    _puid = getplayerUID player;
                    TRACE_1("SYS_PLAYER GUID SET", _puid);

                    MOD(sys_player) setVariable [_puid, true, true];

                    // Save initial start state on client if reset is allowed
                    sleep 20;
                    if (MOD(sys_player) getVariable ["allowReset", DEFAULT_RESET]) then {
                        // Save data on the client
                        private ["_playerHash","_gearHash"];

                        // Save gear on the client and server
                        _gearHash = [MOD(sys_player), "setGear", [player]] call MAINCLASS;
                        [[MOD(sys_player), "updateGear", [player, _gearHash]], "ALiVE_fnc_player", false, false] call BIS_fnc_MP;

                        //[0, {[ALIVE_sys_player,"updateGear", _this] call ALIVE_fnc_player}, [player, _gearHash] ] call CBA_fnc_globalExecute;
                        //["server",QMOD(sys_player),[[player, _gearHash],{[MOD(sys_player),"updateGear", _this] call ALIVE_fnc_player;}]] call ALIVE_fnc_BUS;

                        _playerHash = [MOD(sys_player), [player]] call ALIVE_fnc_setPlayer;
                        // Store playerhash on client
                        player setVariable [QGVAR(player_data), _playerHash];
                        GVAR(resetAvailable) = true;
                    };
                };
            } else {
                TRACE_2("NO SYS_PLAYER or ISDEDICATED/HC", isDedicated, isNil QMOD(sys_player));
            };

            // Set up any checks - autoStorePlayer
            if (isDedicated) then {

                [ALiVE_fnc_autoStorePlayer, DEFAULT_INTERVAL, [DEFAULT_INTERVAL]] call CBA_fnc_addPerFrameHandler;

            };

            // Eventhandlers for other stuff here

            // Setup player eventhandler to handle get player calls
            if(!isServer && !isHC) then {
                ["getPlayer", {[MOD(sys_player),(_this select 1)] call ALIVE_fnc_getPlayer;} ] call CBA_fnc_addLocalEventHandler;
            };

            //TRACE_4("SYS_PLAYER", _logic getvariable "allowReset", _logic getvariable "allowDiffClass",_logic getvariable "allowManualSave",_logic getvariable "storeToDB" );
            TRACE_4("SYS_PLAYER4", typename (MOD(sys_player) getvariable "allowReset"), MOD(sys_player) getvariable "allowDiffClass",MOD(sys_player) getvariable "allowManualSave",MOD(sys_player) getvariable "storeToDB" );

            _logic setVariable ["bis_fnc_initModules_activate",true];

            TRACE_1("After module init",_logic);
            //"Player Persistence - Initialisation Completed" call ALiVE_fnc_logger;
        };

        case "allowReset": {
                _result = [_logic,_operation,_args,DEFAULT_RESET] call ALIVE_fnc_OOsimpleOperation;
		};
        case "allowDiffClass": {
                _result = [_logic,_operation,_args,DEFAULT_DIFFCLASS] call ALIVE_fnc_OOsimpleOperation;
        };
        case "allowManualSave": {
                _result = [_logic,_operation,_args,DEFAULT_MANUALSAVE] call ALIVE_fnc_OOsimpleOperation;
        };
        case "storeToDB": {
                _result = [_logic,_operation,_args,DEFAULT_storeToDB] call ALIVE_fnc_OOsimpleOperation;
        };
        case "autoSaveTime": {
                _result = [_logic,_operation,_args,DEFAULT_autoSaveTime] call ALIVE_fnc_OOsimpleOperation;
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
                // _logic call ?

                if(_args) then {
                	// _logic call ?
                };
                _result = _args;
        };
        case "loadPlayers": {
                    // Load all players from external DB into player store
                    if (_logic getVariable ["storeToDB",DEFAULT_storeToDB]) then {
                        _result = [GVAR(datahandler), "bulkLoad", ["sys_player", _logic getvariable "key", _args select 0]] call ALIVE_fnc_Data;
                        TRACE_1("Loading player data", _result);
                    };
        };
        case "savePlayers": {
                    // Save all players to external DB
                    private ["_ondisconnect","_check"];
                    _ondisconnect = _args select 0;
                    _check = _logic getVariable ["storeToDB", false];
                    TRACE_1("STORE TO DB",_check);
                    if (_check) then {
                        TRACE_1("",GVAR(player_data));
                        _result = [GVAR(datahandler), "bulkSave", ["sys_player", GVAR(player_data), _logic getvariable "key", _ondisconnect]] call ALIVE_fnc_Data;
                    };
        };
        case "getGear": {
                    // Get loadout data from gear store on client and apply to player object on client
                    private ["_gearHash","_unit"];
                    _unit  = _args select 0;

                    // Check that the hash is found
                     if ([GVAR(gear_data), (getPlayerUID _unit)] call CBA_fnc_hashHasKey) then {

                            // Grab player data from memory store
                            _gearHash = [GVAR(gear_data), getPlayerUID _unit] call ALIVE_fnc_hashGet;
                            TRACE_1("GET GEAR", _gearHash);

                            // Execute getGear on local client
                            [_unit, _gearHash] call ALiVE_fnc_getGear;

                            _result = true;
                    } else {
                        TRACE_1("SYS_PLAYER GEAR DATA DOES NOT EXIST",_unit);
                        _result = false;
                    };
        };
        case "setGear": {
                        // Set player data to player store
                        private ["_gearHash","_unit"];
                        _unit  = _args select 0;
                        _gearHash = [_logic, _args] call ALIVE_fnc_setGear;
                        if (isNil QGVAR(gear_data)) then {
                            GVAR(gear_data) = [] call ALIVE_fnc_hashCreate;
                        };
                        [GVAR(gear_data), getplayerUID _unit] call ALIVE_fnc_hashRem;
                        [GVAR(gear_data), getplayerUID _unit, _gearHash] call ALIVE_fnc_hashSet;
                        _result = _gearHash;
        };
        case "updateGear": {
                    // Needed so that changes on client are reflected on server gear store
                     private ["_gearHash","_unit","_tmpHash","_updateGear"];
                    _unit  = _args select 0;
                    _gearHash = _args select 1;
                    // Update GVAR player data
                    if (isNil QGVAR(gear_data)) then {
                        GVAR(gear_data) = [] call ALIVE_fnc_hashCreate;
                    };
                    [GVAR(gear_data), getplayerUID _unit] call ALIVE_fnc_hashRem;
                    [GVAR(gear_data), getplayerUID _unit, _gearHash] call ALIVE_fnc_hashSet;
                    _result = _gearHash;
        };
        case "getPlayer": {
        	       // Get player data from player store and apply to player object on client
                    private ["_playerHash","_unit"];
                    _unit  = _args select 0;
                    _owner = _args select 1;

                    // Check that the hash is found
                     if ([GVAR(player_data), (getPlayerUID _unit)] call CBA_fnc_hashHasKey) then {

                            // Grab player data from memory store
                            _playerHash = [GVAR(player_data), getPlayerUID _unit] call ALIVE_fnc_hashGet;
                            TRACE_1("GET PLAYER", _playerHash);

                            // Execute getplayer on local client using CBA_fnc_remoteLocalEvent
                            [ "getPlayer", [_unit, [_unit, _playerHash]] ] call CBA_fnc_whereLocalEvent;

                            _result = true;
                    } else {
                        TRACE_1("SYS_PLAYER PLAYER DATA DOES NOT EXIST",_unit);
                        _result = false;
                    };
        };
        case "getPlayerSaveTime": {
                    private ["_playerHash","_puid"];
                	// Get the time of the last player save for a specific player
                    _puid = _args select 0;
                    _playerHash = [GVAR(player_data), _puid] call ALIVE_fnc_hashGet;
                    _result =  [_playerHash, "lastSaveTime"] call ALIVE_fnc_hashGet;
        };
        case "setPlayer": {
                        // Set player data to player store
                        private ["_playerHash","_unit"];
                        _unit  = _args select 0;
                        _playerHash = [_logic, _args] call ALIVE_fnc_setPlayer;
                        [GVAR(player_data), getplayerUID _unit] call ALIVE_fnc_hashRem;
                        [GVAR(player_data), getplayerUID _unit, _playerHash] call ALIVE_fnc_hashSet;
                        _result = _playerHash;
        };
        case "checkPlayer": {
        	       // Check to see if the player joining has the same class as the one stored in memory
                private ["_unit","_type","_trigger"];
                _unit = _args select 0;
                _type = _args select 1;
                if (typeOf _unit != _type && _unit == player && !(MOD(sys_player) getVariable ["allowDiffClass",false])) then {
                    cutText [format["You cannot rejoin this server with a different class (expected %1)", getText (configFile>>"cfgVehicles">>_type>>"displayName")] , "PLAIN DOWN"];
                    _unit setVariable [QGVAR(kicked), true, true];
                    _trigger = createtrigger ["emptydetector", [0,0]];
                    _trigger settriggertype "end6";
                    _trigger settriggerstatements ["true","",""];
                };
        };
        case "manualSavePlayer": {
            private ["_playerHash","_unit","_gearHash"];
            _unit  = _args select 0;

            //Update gear
            _gearHash = [MOD(sys_player), "setGear", [_unit]] call MAINCLASS;
            [[MOD(sys_player), "updateGear", [_unit, _gearHash]], "ALiVE_fnc_player", false, false] call BIS_fnc_MP;
            //[0, {[ALIVE_sys_player,"updateGear", _this] call ALIVE_fnc_player}, [_unit, _gearHash] ] call CBA_fnc_globalExecute;
            //["server",QMOD(sys_player),[[player, _gearHash],{[MOD(sys_player),"updateGear", [_this select 0, _this select 1]] call ALIVE_fnc_player;}]] call ALIVE_fnc_BUS;

            // Process a request from a player to save on server
            [[MOD(sys_player), "setPlayer", _args], "ALiVE_fnc_player", false, false] call BIS_fnc_MP;
            //[0, {[ALIVE_sys_player, "setPlayer", _this] call ALIVE_fnc_player}, _args] call CBA_fnc_globalExecute;
            //["server",QMOD(sys_player),[[MOD(sys_player), "setPlayer", _args],{call ALiVE_fnc_player}]] call ALIVE_fnc_BUS;

            // Save data on the client too?
            _playerHash = [_logic, _args] call ALIVE_fnc_setPlayer;

             TRACE_2("MANUAL PLAYER SAVE", _unit, _playerHash);

            // Store playerhash on client
            player setVariable [QGVAR(player_data), _playerHash];
            GVAR(resetAvailable) = true;

            _result = _playerHash;
        };
        case "resetPlayer": {
        	// Return the player state to the previous start state
            private ["_playerHash","_unit","_gearHash"];
            _unit  = _args select 0;

            // Check that the hash is found
             if ([_unit getVariable [QGVAR(player_data),[]]] call ALIVE_fnc_isHash) then {

                    // Grab player data from local player object
                    _playerHash = _unit getVariable QGVAR(player_data);
                    TRACE_2("RESET PLAYER", _unit, _playerHash);

                    // Execute getplayer on local client
                    [_logic, [_unit,  _playerHash]] call ALIVE_fnc_getPlayer;

                    _result = true;
            } else {
                TRACE_3("SYS_PLAYER PLAYER DATA DOES NOT EXIST",_unit);
                _result = false;
            };

        };
        case "destroy": {

                [_logic, "debug", false] call MAINCLASS;

                if (isServer) then {
                		// if server

                                _logic setVariable ["super", nil];
                                _logic setVariable ["class", nil];
                                _logic setVariable ["init", nil];
                                // and publicVariable to clients
                                MOD(sys_player) = _logic;
                                publicVariable QMOD(sys_player);
                                [_logic, "destroy"] call SUPERCLASS;
                };



                if(!isDedicated && !isHC) then {
                        // remove main menu
                        [
                                "player",
                                [SELF_INTERACTION_KEY],
                                [((["ALiVE", "openMenu"] call cba_fnc_getKeybind) select 5) select 0],
                                -9500,
                                [
                                        "call playerMenuDef",
                                        "main"
                                ]
                        ] call ALiVE_fnc_flexiMenu_Remove;
                };
        };
        default {
            _result = [_logic, _operation, _args] call SUPERCLASS;
        };
};
TRACE_1("SYS PLAYER - output",_result);
_result;
