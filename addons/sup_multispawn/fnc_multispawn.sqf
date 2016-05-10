#include <\x\alive\addons\sup_multispawn\script_component.hpp>
SCRIPT(multispawn);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_multispawn
Description:
XXXXXXXXXX

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enabled
Boolean - enabled - Enabled or disable module

Parameters:
none

The popup menu will change to show status as functions are enabled and disabled.

Examples:
(begin example)
Create instance by placing editor module and specifiying name myModule
(end)

See Also:
- <ALIVE_fnc_multispawnInit>
- <ALIVE_fnc_multispawnMenuDef>

Author:
WobbleyHeadedBob, Highhead

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALiVE_fnc_Multispawn

private ["_logic","_operation","_args","_result"];

PARAMS_1(_logic);
DEFAULT_PARAM(1,_operation,"");
DEFAULT_PARAM(2,_args,[]);

//Listener for special purposes
if (!isnil QMOD(SUP_MULTISPAWN) && {MOD(SUP_MULTISPAWN) getvariable [QGVAR(LISTENER),false]}) then {
	_blackOps = ["selectVehicle"];

	if !(_operation in _blackOps) then {
	    _check = "nothing"; if !(isnil "_args") then {_check = _args};

		["op: %1 | args: %2",_operation,_check] call ALiVE_fnc_DumpR;
	};
};

switch(_operation) do {
        case "create": {
                if (isServer) then {

                    // Ensure only one module is used
                    if !(isNil QUOTE(ADDON)) then {
                        _logic = ADDON;
                        ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_MULTISPAWN_ERROR1");
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
                ADDON setVariable ["super", SUPERCLASS];
                ADDON setVariable ["class", MAINCLASS];

                _result = ADDON;
        };
        case "init": {
                /*
                MODEL - no visual just reference data
                - server side object only
				- enabled/disabled
                */

                // Ensure only one module is used
                if (isServer && !(isNil "ALIVE_SUP_multispawn")) exitWith {
                        ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_multispawn_ERROR1");
                };

                //Only one init per instance is allowed
            	if !(isnil {_logic getVariable "initGlobal"}) exitwith {["ALiVE SUP MULTISPAWN - Only one init process per instance allowed! Exiting..."] call ALiVE_fnc_Dump};

            	//Start init
            	_logic setVariable ["initGlobal", false];

                if (isServer) then {
                        // if server, initialise module game logic
                        _logic setVariable ["super",SUPERCLASS];
                        _logic setVariable ["class",ALIVE_FNC_MULTISPAWN];

                        MOD(SUP_MULTISPAWN) = _logic;

                        GVAR(DEBUG) = call compile (_logic getvariable ["debug","false"]);
                        GVAR(MULTISPAWN_TYPE) = _logic getvariable ["spawntype","forwardspawn"];
                        GVAR(RESPAWN_WITH_GEAR) = call compile (_logic getvariable ["respawnWithGear","true"]);

                        // Create Store
                        GVAR(STORE) = [] call ALIVE_fnc_hashCreate;

                        {
                            _id = _x;

                            if !(getNumber(configfile >> "CfgFactionClasses" >> _id >> "side") > 3) then {

	                            // Create Default RespawnMarkers if not existing
	                            if !(("Respawn_" + str(_id call ALiVE_fnc_factionSide)) call ALIVE_fnc_markerExists) then {createMarker ["Respawn_" + str(_id call ALiVE_fnc_factionSide), getposATL _logic]};

								// Create FactionHash
	                            _factionData = [] call ALIVE_fnc_hashCreate;

                                //Set Defaults
	                            [_factionData,QGVAR(RESPAWNPOSITION), getmarkerPos ("Respawn_" + str(_id call ALiVE_fnc_factionSide))] call ALiVE_fnc_HashSet;
	                            [_factionData,QGVAR(MULTISPAWN_TYPE),_logic getvariable ["spawntype","forwardspawn"]] call ALiVE_fnc_HashSet;
                                [_factionData,QGVAR(RESPAWN_WITH_GEAR),call compile (_logic getvariable ["respawnWithGear","false"])] call ALiVE_fnc_HashSet;
	                            [_factionData,QGVAR(TIMEOUT),call compile (_logic getvariable ["timeout","60"])] call ALiVE_fnc_HashSet;
                                [_factionData,QGVAR(VEHICLETYPE), [MOD(SUP_MULTISPAWN),"selectDefaultVehicle",_id call ALiVE_fnc_factionSide] call ALiVE_fnc_Multispawn] call ALiVE_fnc_HashSet;

                                //Override vehicles from synchronised objects
                                {

                                    _vehicle = vehicle _x;

                                    if (faction _vehicle == _id) then {
                                        switch (GVAR(MULTISPAWN_TYPE)) do {
                                            case ("insertion") : {
                                                // Create / position insertion marker
                                                _m = (format["ALiVE_SUP_MULTISPAWN_INSERTION_%1",_id]);
                                                if !(_m call ALiVE_fnc_markerExists) then {_m = (format["ALiVE_SUP_MULTISPAWN_INSERTION_%1",_id]); createMarker [_m, getposATL _x]} else {_m setmarkerpos (getposASL (vehicle _x))};

					                            [_factionData,QGVAR(PLAYERQUEUE), []] call ALiVE_fnc_HashSet;
					                            [_factionData,QGVAR(INSERTING), false] call ALiVE_fnc_HashSet;
					                            [_factionData,QGVAR(INSERTION_TRANSPORT), nil] call ALiVE_fnc_HashSet;

                                                [_factionData,QGVAR(VEHICLETYPE), typeOf _vehicle] call ALiVE_fnc_HashSet;

                                                {deletevehicle _x} foreach (units group (driver _vehicle)); deletevehicle _vehicle;
                                            };
                                            case ("vehicle") : {
                                                if ((vehicle _x) isKindOf "Car") exitwith {
		                                    		call compile (format["ALiVE_SUP_MULTISPAWN_RESPAWNVEHICLE_%1 = _x",_id]);
		                                    		Publicvariable (format["ALiVE_SUP_MULTISPAWN_RESPAWNVEHICLE_%1",_id]);

                                                    [_factionData,QGVAR(VEHICLETYPE), typeOf (vehicle _x)] call ALiVE_fnc_HashSet;
                                                };
                                            };
                                        };
                                 	};
								} foreach (synchronizedObjects _logic);

                                _factionData call ALiVE_fnc_InspectHash;

	                            [GVAR(STORE),_id,_factionData] call ALiVE_fnc_HashSet;
                            };
                        } foreach ([] call BIS_fnc_getFactions);

                        PublicVariable QGVAR(DEBUG);
                        PublicVariable QGVAR(MULTISPAWN_TYPE);
                        PublicVariable QGVAR(RESPAWN_WITH_GEAR);

                        PublicVariable QMOD(SUP_MULTISPAWN);
                        _logic setVariable ["init",true,true];
                } else {

                };

                // and wait for game logic to initialise
                // TODO merge into lazy evaluation
                waitUntil {!isNil QMOD(SUP_MULTISPAWN) && {MOD(SUP_MULTISPAWN) getVariable ["init",false]}};

                /*
                VIEW - purely visual
                - initialise menu
                - frequent check to modify menu and display status (ALIVE_fnc_multispawnsmenuDef)
                */

                //Initialise locals if client and not HC
                if(hasInterface) then {
                    Waituntil {!isnil QGVAR(MULTISPAWN_TYPE)};

                    private ["_respawn","_respawnFaction","_pos"];

                    waituntil {!isnull player};

                    // Set local respawn positions
                    _respawn = format["Respawn_%1",side player];
                    _respawnFaction = format["ALiVE_SUP_MULTISPAWN_RESPAWN_%1",faction player];
                    _respawnGroup = format["ALiVE_SUP_MULTISPAWN_RESPAWNGROUP_%1",groupID (group player)];

                    if !(_respawn call ALiVE_fnc_markerExists) then {createMarkerLocal [_respawn, getposATL _logic]};

					// Defaults
                    if (_respawnGroup call ALiVE_fnc_markerExists) then {
                        _pos = (getmarkerPos _respawnGroup);

                        ["ALiVE_SUP_MULTISPAWN - Using respawn point %2 at %1!",_pos,_respawnGroup] call ALiVE_fnc_Dump;
                    } else {
                    	if (_respawnFaction call ALiVE_fnc_markerExists) then {
                    		_pos = (getmarkerPos _respawnFaction);

                            ["ALiVE_SUP_MULTISPAWN - Using respawn point %2 at %1!",_pos,_respawnFaction] call ALiVE_fnc_Dump;
                        } else {
                            _pos = getMarkerPos _respawn;

                            ["ALiVE_SUP_MULTISPAWN - Using default respawn point %2 at %1!",_pos,_respawn] call ALiVE_fnc_Dump;
                        };
                    };

                    // Apply Defaults
                    _respawn setmarkerPosLocal _pos;

					// Apply Params
                    switch (GVAR(MULTISPAWN_TYPE)) do {

                        //Nothing
                        case ("none") : {};

                        //Initialise a local "killed"-EH
                        case ("forwardspawn") : {
                        	//Not compatible with revive
                        	if ([QMOD(SYS_REVIVE)] call ALiVE_fnc_isModuleAvailable) exitwith {["ALiVE SUP MULTISPAWN - Revive is enabled, exiting Multispawn!"] call ALiVE_fnc_Dump};

                        	waituntil {!isnull player};

                        	["ALiVE SUP MULTISPAWN - Forward Spawn EH placed at %1...", time] call ALiVE_fnc_Dump;

							player addEventHandler ["KILLED",{
                                if (!isnil "ALiVE_SYS_PLAYER_LOADOUT_DATA" && {GVAR(RESPAWN_WITH_GEAR)}) then {GVAR(PLAYERGEAR) = [objNull, [_this select 0]] call ALiVE_fnc_setGear};
                            }];

                            player addEventHandler ["RESPAWN", {
                                [] spawn {
                                    waituntil {!isnull player};

                                    if (!isNil "ALiVE_SYS_PLAYER_LOADOUT_DATA" && {GVAR(RESPAWN_WITH_GEAR)} && {!isNil QGVAR(PLAYERGEAR)}) then {_hdl = [objNull, [player,GVAR(PLAYERGEAR)]] spawn ALiVE_fnc_getGear};

                                    sleep 3;
                                	titleText ["", "PLAIN"];
                                };


                                [] spawn ALiVE_fnc_ForwardSpawn;
                            }];
                        };

                        case ("insertion") : {

                            waituntil {!isnull player};

                            ["ALiVE SUP MULTISPAWN - Insertion EH placed at %1...", time] call ALiVE_fnc_Dump;

                            player addEventHandler ["KILLED", {
                                if (!isnil "ALiVE_SYS_PLAYER_LOADOUT_DATA" && {GVAR(RESPAWN_WITH_GEAR)}) then {GVAR(PLAYERGEAR) = [objNull, [_this select 0]] call ALiVE_fnc_setGear};

                                [] spawn {
                                    waituntil {playerRespawnTime <= 3};

                                    titleText ["Respawning...", "BLACK OUT", 2];
                                };
                            }];

                            player addEventHandler ["RESPAWN", {
                                [] spawn {
                                    waituntil {!isnull player};

                                    if (!isNil "ALiVE_SYS_PLAYER_LOADOUT_DATA" && {GVAR(RESPAWN_WITH_GEAR)} && {!isNil QGVAR(PLAYERGEAR)}) then {_hdl = [objNull, [player,GVAR(PLAYERGEAR)]] spawn ALiVE_fnc_getGear};

                                    [[ALiVE_SUP_MULTISPAWN,"collect",player], "ALiVE_fnc_MultiSpawn", false, false] call BIS_fnc_MP;

                                    sleep 3;
                                	titleText ["", "PLAIN"];
                                };
                            }];

							//Initial insertion, theoretically conflicts with SYS Player, TBD: make it an option to insert already on first start or only on respawn.
                            //[[ALiVE_SUP_MULTISPAWN,"collect",player], "ALiVE_fnc_MultiSpawn", false, false] call BIS_fnc_MP;
                        };

                        case ("vehicle") : {

                            private ["_respawn","_respawnVehicle"];

                            waituntil {!isnull player};

                            _respawn = format["Respawn_%1",side player];
                            _respawnVehicle = !isnil {call compile (format["ALiVE_SUP_MULTISPAWN_RESPAWNVEHICLE_%1",faction player])};

                            if !(_respawn call ALiVE_fnc_markerExists) then {createMarkerLocal [_respawn, getposATL _logic]};
                            if !(!isnil "_respawnVehicle" && {_respawnVehicle}) exitwith {["ALiVE_SUP_MULTISPAWN - Please place a vehicle with name ALiVE_SUP_MULTISPAWN_RESPAWNVEHICLE_%1... Defaulting to regular respawn point!",faction player] call ALiVE_fnc_DumpR};

							["ALiVE SUP MULTISPAWN - Vehicle EH placed at %1...", time] call ALiVE_fnc_Dump;

							player addEventHandler ["KILLED", {
								if (!isnil "ALiVE_SYS_PLAYER_LOADOUT_DATA" && {GVAR(RESPAWN_WITH_GEAR)}) then {GVAR(PLAYERGEAR) = [objNull, [_this select 0]] call ALiVE_fnc_setGear};

                                [] spawn {
                                    waituntil {playerRespawnTime <= 3};

                                    titleText ["Respawning...", "BLACK OUT", 2];
                                };
                            }];

                            player addEventHandler ["RESPAWN", {
                                [] spawn {
                                    waituntil {!isnull player};

                                    if (!isNil "ALiVE_SYS_PLAYER_LOADOUT_DATA" && {GVAR(RESPAWN_WITH_GEAR)} && {!isNil QGVAR(PLAYERGEAR)}) then {_hdl = [objNull, [player,GVAR(PLAYERGEAR)]] spawn ALiVE_fnc_getGear};

	                                if !(isnil {call compile (format["ALiVE_SUP_MULTISPAWN_RESPAWNVEHICLE_%1",faction player])}) then {
		                                _v = call compile format["ALiVE_SUP_MULTISPAWN_RESPAWNVEHICLE_%1",faction player];

		                                if !(alive _v) exitwith {["ALiVE_SUP_MULTISPAWN - No ALiVE_SUP_MULTISPAWN_RESPAWNVEHICLE_%1 available... Exiting!",faction player] call ALiVE_fnc_Dump};
		                                if ([_v] call ALIVE_fnc_vehicleCountEmptyPositions > 0) then {player moveInCargo _v} else {player setposATL [(getposATL _v), 10] call CBA_fnc_RandPos};
	                                };

                                    sleep 3;
                                	titleText ["", "PLAIN"];
                                };
                            }];
                        };

                        case ("building") : {

                            private ["_respawn","_respawnBuilding"];

                            waituntil {!isnull player};

                            _respawn = format["Respawn_%1",side player];
                            _respawnBuilding = nearestObject [getmarkerpos format["ALiVE_SUP_MULTISPAWN_RESPAWNBUILDING_%1",faction player], "Building"];

                            if !(_respawn call ALiVE_fnc_markerExists) then {createMarkerLocal [_respawn, getposATL _logic]};
                            if !(!isnil "_respawnBuilding" && {alive _respawnBuilding}) exitwith {["ALiVE_SUP_MULTISPAWN - Please place a ALiVE_SUP_MULTISPAWN_RESPAWNBUILDING_%1 marker near a building... Defaulting to regular respawn point!",faction player] call ALiVE_fnc_DumpR};

							["ALiVE SUP MULTISPAWN - Building EH placed at %1...", getposATL _respawnBuilding] call ALiVE_fnc_Dump;

							player addEventHandler ["KILLED", {
                                if (!isnil "ALiVE_SYS_PLAYER_LOADOUT_DATA" && {GVAR(RESPAWN_WITH_GEAR)}) then {GVAR(PLAYERGEAR) = [objNull, [_this select 0]] call ALiVE_fnc_setGear};

                                [] spawn {
                                    waituntil {playerRespawnTime <= 4};

                                    titleText ["Respawning...", "BLACK OUT", 3];
                                };
                            }];

                            player addEventHandler ["RESPAWN", {
                                [] spawn {
                                    waituntil {!isnull player};

                                    if (!isNil "ALiVE_SYS_PLAYER_LOADOUT_DATA" && {GVAR(RESPAWN_WITH_GEAR)} && {!isNil QGVAR(PLAYERGEAR)}) then {_hdl = [objNull, [player,GVAR(PLAYERGEAR)]] spawn ALiVE_fnc_getGear};

	                                _b = nearestObject [getmarkerpos format["ALiVE_SUP_MULTISPAWN_RESPAWNBUILDING_%1",faction player], "Building"];

	                                if (!isNil "_b" && {alive _b}) then {
		                                _p = [_b] call ALIVE_fnc_getMaxBuildingPositions;

		                                if (_p > 0) then {player setpos (_b buildingpos (ceil random _p))} else {player setposATL [(getposATL _b), 20] call CBA_fnc_RandPos};
	                                } else {
	                                    ["ALiVE_SUP_MULTISPAWN - No ALiVE_SUP_MULTISPAWN_RESPAWNBUILDING_%1 available... Exiting!",faction player] call ALiVE_fnc_Dump;
	                                };

                                    sleep 3;
                                	titleText ["", "PLAIN"];
                                };
                            }];
                        };

                        default {};
                    };
                };
        };

        case "selectDefaultVehicle": {
            if (isnil "_args") exitwith {};

            private ["_side"];

            _side = _args;

            {if ((_x call ALiVE_fnc_ClassSide) == _side) then {_result = _x}} foreach ["B_Heli_Transport_01_F","O_Heli_Light_02_F","I_Heli_Transport_02_F"];
        };

        case "convertStringToArray": {
            if !(isnil "_args") then {
				if(typeName _args == "STRING") then {
                    if !(_args == "") then {
						_args = [_args, " ", ""] call CBA_fnc_replace;
                        _args = [_args, "[", ""] call CBA_fnc_replace;
                        _args = [_args, "]", ""] call CBA_fnc_replace;
                        _args = [_args, "'", ""] call CBA_fnc_replace;
                        _args = [_args, """", ""] call CBA_fnc_replace;
						_args = [_args, ","] call CBA_fnc_split;

						if(count _args > 0) then {
							_result = _args;
						};
                    } else {
                        _result = [];
                    };
				} else {
					if(typeName _args == "ARRAY") then {
						_result = _args;
					};
	            };
            };
		};

        case "loader": {
            if !(isServer) exitwith {};

            private ["_player","_transport","_timer"];

            _player = [[_args], 0, objNull, [objNull]] call BIS_fnc_param;
            _factionData = [GVAR(STORE),faction _player] call ALiVE_fnc_HashGet;

            [[_logic,"disablePlayer",_player], "ALiVE_fnc_MultiSpawn", owner _player, false] call BIS_fnc_MP;

            sleep 2;
			waituntil {
                sleep 1;

                _transport = [_factionData,QGVAR(INSERTION_TRANSPORT)] call ALiVE_fnc_HashGet;

                // Player obvject must be existing and alive
                if (!isnil "_player" && {alive _player}) then {

	                // Update every 30 seconds
	                if (isnil "_timer" || {time - _timer > 30}) then {
	                    ALiVE_SUP_MULTISPAWN_TXT_LISTENER = format["Time to liftoff: T %1 minutes!",floor((call compile(format["ALiVE_SUP_MULTISPAWN_COUNTDOWN_%1",faction _player]))/60)];
	                    (owner _player) PublicVariableClient "ALiVE_SUP_MULTISPAWN_TXT_LISTENER";

	                    _timer = time;
	                };
                    !isnil "_transport" && {_player in _transport};
                } else {
                    true;
                };
            };
            sleep 2;

            [[_logic,"enablePlayer",_player], "ALiVE_fnc_MultiSpawn", owner _player, false] call BIS_fnc_MP;
        };

        case "enablePlayer": {
            if !(hasInterface) exitwith {};

            private ["_player"];

            _player = [[_args], 0, objNull, [objNull]] call BIS_fnc_param;

            if !(player == _player) exitwith {};

            _player enableSimulation true; _player hideObject false;
            _player setcaptive false; 1 fadesound 1; // disableUserinput false;

            _player setvariable [QGVAR(LOADER),false,true];
        };

        case "disablePlayer": {
            if !(hasInterface) exitwith {};

            private ["_player","_tgts"];

            _player = [[_args], 0, objNull, [objNull]] call BIS_fnc_param;

            if !(player == _player) exitwith {};

            _player setvariable [QGVAR(LOADER),true,true];

            _player setcaptive true; 1 fadesound 0; // disableUserinput true;
            _player enableSimulation false; _player hideObject true;

            _tgts = []; {if (({isPlayer _x} count (units _x)) == 0) then {_tgts set [count _tgts, leader _x]}} foreach allGroups;

            _loader = [
				_tgts,
				"Preparing insertion vehicle...",
				300,
				300,
				90,
				1,
				[],
				0,
				[[_player],{!((_this select 0) getvariable ["ALiVE_SUP_MULTISPAWN_LOADER",false])}]
			] spawn ALiVE_fnc_establishingShotCustom;
        };

        case "insert": {
            if !(isServer) exitwith {};

            private ["_StartPos","_EndPos","_transport","_TransportType","_side","_queue","_faction"];

            _startPos = [_args, 0, [0,0,100], [[]]] call BIS_fnc_param;
            _endPos = [_args, 1, getMarkerpos "Respawn_West", [[]]] call BIS_fnc_param;
            _faction = [_args, 2, "BLU_F", [""]] call BIS_fnc_param;
            _timeOut = [_args, 3, 30, [-1]] call BIS_fnc_param;
            _time = time;

            if (isnil "_faction") exitwith {["ALiVE_SUP_MULTISPAWN - faction not found when checking queue! Exiting queue..."]};

            //////////////////////////////////////////////
            // Pre Start Checks

            _factionData = [GVAR(STORE),_faction] call ALiVE_fnc_HashGet;
            _TransportType = [_factionData,QGVAR(VEHICLETYPE),"B_Heli_Transport_01_F"] call ALiVE_fnc_HashGet;
            _cargoCount = getNumber(configFile >> "cfgVehicles" >> _TransportType >> "transportSoldier");

            if ([_factionData,QGVAR(INSERTING),false] call ALiVE_fnc_HashGet) exitwith {};
            [_factionData,QGVAR(INSERTING),true] call ALiVE_fnc_HashSet;
            //////////////////////////////////////////////


			//////////////////////////////////////////////
			// Conditions to be true to start insertion

            waituntil {
                sleep 1;

                call compile format["ALiVE_SUP_MULTISPAWN_COUNTDOWN_%1 = (time - _time - _timeOut)",_faction];
                _queue = ([_factionData, QGVAR(PLAYERQUEUE),[]] call ALiVE_fnc_HashGet) - [objNull];

                (
	                (time - _time > _timeOut) // timeout has passed

	                || // or

	                {count _queue >= _cargoCount} // Cargo is full
                )

                && // and

                {isNil {[_factionData, QGVAR(INSERTION_TRANSPORT)] call ALiVE_fnc_HashGet}} // former insertion is finished
			};

            //////////////////////////////////////////////

            //////////////////////////////////////////////
            // Start Insertion
			
            _dataSet = [_startpos, 0, _TransportType, _TransportType call ALiVE_fnc_classSide] call bis_fnc_spawnvehicle;
            
            _transport = _dataSet select 0;
            _units = _dataSet select 1;
            _group = _dataSet select 2;

            {
                [[[_x,_transport], {
                    (_this select 0) moveInCargo (_this select 1);
                }], "BIS_fnc_spawn", owner _x, false, false] call BIS_fnc_MP;
                sleep 1;
            } foreach _queue;
                       
            [_factionData, QGVAR(PLAYERQUEUE), []] call ALiVE_fnc_HashSet;
            [_factionData,QGVAR(INSERTION_TRANSPORT), _transport] call ALiVE_fnc_HashSet;
            _transport setvariable [QGVAR(INSERTION_TRANSPORT),_dataSet];

			_heliPad = "Land_HelipadEmpty_F" createVehicleLocal _EndPos;

            _wp = _group addWaypoint [_EndPos, 0];
            _wp setWaypointType "MOVE";
            _wp setWaypointBehaviour "CARELESS";
            _wp setWaypointSpeed "FULL";
            _wp setWaypointStatements ["true", "
            	(group this) setspeedmode 'LIMITED';
            	if ((vehicle this) iskindof 'Air') then {(vehicle this) land 'land'};
			"];
            //////////////////////////////////////////////


            //////////////////////////////////////////////
            // Conditions for finished insertion
            waituntil {
                sleep 1;

                isNil "_transport" || {!alive _transport} || {!canMove _transport}

                ||

                {
                    ((getpos _transport) select 2) < 1 &&
                    {{_x in _transport} count ([] call BIS_fnc_ListPlayers) == 0}
                }
			};
            //////////////////////////////////////////////


            //////////////////////////////////////////////
            // Finalising

            [_factionData,QGVAR(INSERTING),false] call ALiVE_fnc_HashSet;
            
            private ["_data"];

            if (isNil "_transport" || {!alive _transport} || {!canMove _transport}) then {
                
                _data = +_dataSet;

                (_data select 0) setvariable [QGVAR(INSERTION_TRANSPORT),nil];
                [_factionData,QGVAR(INSERTION_TRANSPORT)] call ALiVE_fnc_HashRem;

                sleep 60;

            	{deleteVehicle _x} foreach (_data select 1);
                (_data select 2) call ALiVE_fnc_DeleteGroupRemote;
                
                deleteVehicle (_data select 0);
            } else {
				_wp = _group addWaypoint [_StartPos, 0];
				_wp setWaypointType "MOVE";
				_wp setWaypointSpeed "FULL";
				_wp setWaypointBehaviour "CARELESS";
                
                _group setCurrentWaypoint _wp;

		        //////////////////////////////////////////////
		        // Conditions for finished insertion
		        waituntil {
		            sleep 1;
		
		            (isNil "_transport" || {!alive _transport} || {!canMove _transport})
		
		            ||
		
		            {_transport distance2D _StartPos < 100}
				};
		        //////////////////////////////////////////////                
                
                _data = +_dataSet;

                (_data select 0) setvariable [QGVAR(INSERTION_TRANSPORT),nil];
                [_factionData,QGVAR(INSERTION_TRANSPORT)] call ALiVE_fnc_HashRem;

            	{deleteVehicle _x} foreach (_data select 1);
                (_data select 2) call ALiVE_fnc_DeleteGroupRemote;
                
                deleteVehicle (_data select 0);
        	};

            deleteVehicle _heliPad;
            //////////////////////////////////////////////
        };

        case "collect": {
            if !(isServer) exitwith {};

            private ["_player","_insertion","_destination","_transport","_timeout"];

            _player = [[_args], 0, objNull, [objNull]] call BIS_fnc_param;

            _factionData = [GVAR(STORE),faction _player] call ALiVE_fnc_HashGet;
            _transport = [_factionData,QGVAR(INSERTION_TRANSPORT)] call ALiVE_fnc_HashGet;
            _inserting = [_factionData,QGVAR(INSERTING),false] call ALiVE_fnc_HashGet;
            _timeout = [_factionData,QGVAR(TIMEOUT),60] call ALiVE_fnc_HashGet;

            if ((format["ALiVE_SUP_MULTISPAWN_INSERTION_%1",faction _player]) call ALiVE_fnc_markerExists) then {_insertion = getMarkerPos (format["ALiVE_SUP_MULTISPAWN_INSERTION_%1",faction _player])} else {_insertion = [1000,1000,100]};
            if ((format["ALiVE_SUP_MULTISPAWN_DESTINATION_%1",faction _player]) call ALiVE_fnc_markerExists) then {_destination = getMarkerPos (format["ALiVE_SUP_MULTISPAWN_DESTINATION_%1",faction _player])} else {_destination = getMarkerPos format["Respawn_%1", (faction _player) call ALiVE_fnc_factionSide]};

			if !(!isnil "_insertion" && {!isnil "_destination"} && {!isnil "_player" && {!isnull _player}} && {!isnil "_timeout"}) exitwith {};

			if (!isnil "_transport" && {_inserting}) then {
                [[[_player,_transport], {(_this select 0) moveInCargo (_this select 1)}], "BIS_fnc_spawn", owner _player, false] call BIS_fnc_MP;
            } else {
                [_factionData,QGVAR(PLAYERQUEUE),([_factionData,QGVAR(PLAYERQUEUE),[]] call ALiVE_fnc_HashGet) + [_player]] call ALiVE_fnc_HashSet;

                [_logic,"loader",_player] spawn ALiVE_fnc_MultiSpawn;
                [_logic,"insert",[_insertion,_destination,faction _player,_timeout]] spawn ALiVE_fnc_MultiSpawn;
            };
        };

        case "destroy": {
                if (isServer) then {
                        // if server
                        _logic setVariable ["super", nil];
                        _logic setVariable ["class", nil];
                        _logic setVariable ["init", nil];
                        // and publicVariable to clients

                        MOD(MULTISPAWN) = _logic;
                        publicVariable QMOD(MULTISPAWN);
                };

                if(!isDedicated && !isHC) then {
                        // remove main menu
                        [
                                "player",
                                [((["ALiVE", "openMenu"] call cba_fnc_getKeybind) select 5) select 0],
                                -9500,
                                [
                                        "call ALIVE_fnc_multispawnMenuDef",
                                        "main"
                                ]
                        ] call CBA_fnc_flexiMenu_Remove;
                };
        };
        default {
                private["_err"];
                _err = format["%1 does not support %2 operation", _logic, _operation];
                ERROR_WITH_TITLE(str _logic,_err);
        };
};

if !(isnil "_result") then {
    if (!isnil QMOD(SUP_MULTISPAWN) && {MOD(SUP_MULTISPAWN) getvariable [QGVAR(LISTENER),false]}) then {
        ["op: %1 | result: %2",_operation,_result] call ALiVE_fnc_DumpR;
    };

    _result;
};