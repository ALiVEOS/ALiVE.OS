#include <\x\alive\addons\sys_sitrep\script_component.hpp>
SCRIPT(sitrep);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sitrep
Description:
Creates the server side object to store settings

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array,String,Number,Boolean - The selected parameters

Returns:
Array, String, Number, Any - The expected return value

Properties:
drawToggle - returns the map drawing toggle state

EventHandlers:
keyDown - handles key press while on map screen
mouseMoving - handles the movement of the mouse while on map screen

Methods:
create - creates the game logic
init - initialises game logic
state - returns the state of the sitrep STORE?
destroy - destroys the game logic
destroyGlobal - destroys the game logic globally

onsitrep - checks to see if a sitrep exists at a specified position
isAuthorized - checks to see if a player may add, edit or delete a sitrep
getsitrep - returns extended sitrep information
loadsitreps - loads sitreps from the database
savesitreps - saves sitreps to the database
restoresitreps - restores the sitreps loaded to the map
openDialog - opens the advanced sitrep user interface
addsitrep - adds a sitrep to the store
removesitrep - removes a sitrep from the store
createsitrep - creates a sitrep on the client machine
updatesitrep - updates a sitrep
deletesitrep - deletes a sitrep
deleteAllsitreps - deletes all sitreps on the map (Admin Only)

Examples:
(begin example)
// Create instance by placing editor module
[_logic,"init"] call ALiVE_fnc_sitrep;
(end)

See Also:
- <ALIVE_fnc_sitrepInit>

Author:
Tupolov

In memory of Peanut

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_sitrep

private ["_result", "_operation", "_args", "_logic"];

PARAMS_1(_logic);
DEFAULT_PARAM(1,_operation,"");
DEFAULT_PARAM(2,_args,nil);

TRACE_3("SYS_sitrep",_logic, _operation, _args);

switch (_operation) do {

    	case "create": {
            if (isServer) then {

	            // Ensure only one module is used
	            if !(isNil QMOD(SYS_sitrep)) then {
                	_logic = MOD(SYS_sitrep);
                    ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_sitrep_ERROR1");
	            } else {
	        		_logic = (createGroup sideLogic) createUnit ["ALiVE_SYS_sitrep", [0,0], [], 0, "NONE"];
                    MOD(SYS_sitrep) = _logic;
                };

                //Push to clients
	            PublicVariable QMOD(SYS_sitrep);
            };

            TRACE_1("Waiting for object to be ready",true);

            waituntil {!isnil QMOD(SYS_sitrep)};

            TRACE_1("Creating class on all localities",true);

			// initialise module game logic on all localities
			MOD(SYS_sitrep) setVariable ["super", QUOTE(SUPERCLASS)];
			MOD(SYS_sitrep) setVariable ["class", QUOTE(MAINCLASS)];

            _result = MOD(SYS_sitrep);
        };

        case "init": {

            //["%1 - Initialisation started...",_logic] call ALiVE_fnc_Dump;

            /*
            MODEL - no visual just reference data
            - module object datastorage parameters
            - Establish data handler on server
            - Establish data model on server and client
            */

            TRACE_1("Creating data store",true);

	        // Create logistics data storage in memory on all localities
	        //GVAR(STORE) = [] call ALIVE_fnc_hashCreate;

            // Define module basics on server
			if (isServer) then {
                _errorMessage = "Please include either the Requires ALiVE module! %1 %2";
                _error1 = ""; _error2 = ""; //defaults
                if(
                    !(["ALiVE_require"] call ALiVE_fnc_isModuleavailable)
                    ) exitwith {
                    [_errorMessage,_error1,_error2] call ALIVE_fnc_dumpR;
                };

				// Wait for disable log module to set module parameters
                if (["AliVE_SYS_sitrepPARAMS"] call ALiVE_fnc_isModuleavailable) then {
                    waituntil {!isnil {MOD(SYS_sitrep) getvariable "DEBUG"}};
                };

                // Create store initially on server
                GVAR(STORE) = [] call ALIVE_fnc_hashCreate;

                // Reset states with provided data;
                if !(_logic getvariable ["DISABLEPERSISTENCE",false]) then {
                    if (isDedicated && {[QMOD(SYS_DATA)] call ALiVE_fnc_isModuleAvailable}) then {
                        waituntil {!isnil QMOD(SYS_DATA) && {MOD(SYS_DATA) getvariable ["startupComplete",false]}};
                    };

                    ["DATA: Loading situation report data."] call ALIVE_fnc_dump;
                    _state = [_logic, "loadsitreps"] call ALIVE_fnc_sitrep;

                    if !(typeName _state == "BOOL") then {
                        GVAR(STORE) = _state;
                    } else {
                        LOG("No sitreps loaded...");
                    };

                };

                GVAR(STORE) call ALIVE_fnc_inspectHash;

            	[_logic,"state",GVAR(STORE)] call ALiVE_fnc_sitrep;

                //Push to clients
                PublicVariable QGVAR(STORE);

                _logic setVariable ["init", true, true];
			};

            /*
            CONTROLLER  - coordination
            */

            // Wait until server init is finished
            waituntil {_logic getvariable ["init",false]};

            TRACE_1("Spawning Server processes",isServer);

            if (isServer) then {
                // Start any server-side processes that are needed
            };

			TRACE_1("Spawning clientside processes",hasInterface);

            if (hasInterface) then {
                // Start any client-side processes that are needed

                 waituntil {!isnil QGVAR(STORE)};

                if (didJIP) then {
                    // If JIP then also restore when STORE is rebroadcast
                    QGVAR(store) addPublicVariableEventHandler {
                        // Restore Markers on map for JIP
                        [ADDON, "restoresitreps", [GVAR(store)]] call ALiVE_fnc_sitrep;
                    };
                } else {
                      // Restore Markers on map based on initial store
                    [_logic, "restoresitreps", [GVAR(store)]] call ALiVE_fnc_sitrep;
                };
                 TRACE_1("Initial STORE", GVAR(store));

                waitUntil {
                    sleep 1;
                    ((str side player) != "UNKNOWN")
                };

            };


            TRACE_1("After module init",_logic);

            // Indicate Init is finished on server
            if (isServer) then {
                _logic setVariable ["startupComplete", true, true];
            };

            //["%1 - Initialisation Completed...",MOD(SYS_sitrep)] call ALiVE_fnc_Dump;
            _logic setVariable ["bis_fnc_initModules_activate",true];

            _result = MOD(SYS_sitrep);
        };


       case "state": {

            TRACE_1("ALiVE SYS sitrep state called",_logic);

            if ((isnil "_args") || {!isServer}) exitwith {
                _result = GVAR(STORE)
            };

            // State is being set - restore sitreps

            _result = GVAR(STORE);
        };

        case "isAuthorized": {
            private "_sitrep";
            _sitrep = _args select 0;

            if (typeName _sitrep == "BOOL") then {
                _result = isPlayer player;
            } else {
                // If player owns sitrep, or player is admin or player is higher rank than owner
                _result = true;
            };
        };


        case "loadsitreps": {
            // Get sitreps from DB
            _result = call ALIVE_fnc_sitrepLoadData;
        };

        case "restoresitreps": {
            // Create sitreps from the store locally (run on clients only)
            private ["_restoresitreps","_hash","_i"];

            _hash = _args select 0;


            _restoresitreps = {
                private "_locality";
                LOG(str _this);
                _locality = [_value, QGVAR(locality),"SIDE"] call ALIVE_fnc_hashGet;
                switch _locality do {
                    case "SIDE": {
                        if ( str(side (group player)) == [_value, QGVAR(localityValue), ""] call ALiVE_fnc_hashGet) then {
                            [MOD(SYS_sitrep), "createsitrep", [_key,_value]] call ALIVE_fnc_sitrep;
                        };
                    };
                    case "GROUP": {
                        if (str(group player) == [_value, QGVAR(localityValue),""] call ALiVE_fnc_hashGet) then {
                            [MOD(SYS_sitrep), "createsitrep", [_key,_value]] call ALIVE_fnc_sitrep;
                        };
                    };
                    case "FACTION": {
                        [MOD(SYS_sitrep), "createsitrep", [_key,_value,  [_value, QGVAR(localityValue)] call ALiVE_fnc_hashGet]] call ALIVE_fnc_sitrep;
                    };
                    case "LOCAL": {
                        if ( (getPlayerUID player) == [_value, QGVAR(player), ""] call ALiVE_fnc_hashGet) then {
                            [MOD(SYS_sitrep), "createsitrep", [_key,_value]] call ALIVE_fnc_sitrep;
                        };
                    };
                    case default {
                        [MOD(SYS_sitrep), "createsitrep", [_key,_value]] call ALIVE_fnc_sitrep;
                    };
                };

            };

            [_hash, _restoresitreps] call CBA_fnc_hashEachPair;

            _result = true;

        };

        case "createsitrep": {
            // Handles creating a sitrep on the map
            // Accepts a hash as input (either from loading or from UI)
            private ["_sitrepName","_sitRepHash","_check"];
            _sitrepName = _args select 0;
            _sitRepHash = _args select 1;
            _check = false;
            _result = false;

            if (hasInterface) then {

                if (count _args > 2) then {
                    if (faction player == (_args select 2)) then {_check = true};
                } else {
                    _check = true;
                };

                if (_check) then {
                    [
                        _sitrepName,
                        [_sitRepHash, QGVAR(callsign)] call ALIVE_fnc_hashGet,
                        [_sitRepHash, QGVAR(DTG)] call ALIVE_fnc_hashGet,
                        [_sitRepHash, QGVAR(dateTime)] call ALIVE_fnc_hashGet,
                        [_sitRepHash, QGVAR(loc)] call ALIVE_fnc_hashGet,
                        [_sitRepHash, QGVAR(ekia)] call ALIVE_fnc_hashGet,
                        [_sitRepHash, QGVAR(en)] call ALIVE_fnc_hashGet,
                        [_sitrepHash, QGVAR(civ)] call ALIVE_fnc_hashGet,
                        [_sitrepHash, QGVAR(fkia)] call ALIVE_fnc_hashGet,
                        [_sitrepHash, QGVAR(fwia)] call ALIVE_fnc_hashGet,
                        [_sitrepHash, QGVAR(ff)] call ALIVE_fnc_hashGet,
                        [_sitrepHash, QGVAR(ammo)] call ALIVE_fnc_hashGet,
                        [_sitrepHash, QGVAR(cas)] call ALIVE_fnc_hashGet,
                        [_sitrepHash, QGVAR(veh)] call ALIVE_fnc_hashGet,
                        [_sitrepHash, QGVAR(cs)] call ALIVE_fnc_hashGet,
                        [_sitrepHash, QGVAR(remarks)] call ALIVE_fnc_hashGet,
                        [_sitrepHash, QGVAR(group)] call ALIVE_fnc_hashGet,
                        [_sitrepHash, QGVAR(pos)] call ALIVE_fnc_hashGet
                    ] call ALIVE_fnc_sitrepCreateDiaryRecord;

                    _result = true;
                };
            };

        };

        case "addsitrep": {
        	// Adds a sitrep to the store on the server and creates sitreps on necessary clients
            // Expects a sitrepname and hash as input.

            private ["_sitrepName","_sitrepHash","_sitrep"];
            _sitrepName = _args select 0;
            _sitrepHash = _args select 1;

            // Add sitrep to sitrep store on all localities
            [[_logic, "addsitrepToStore", [_sitrepName, _sitrepHash]], "ALIVE_fnc_sitrep",true,false,true] call BIS_fnc_MP;


            // Create sitrep

            switch ([_sitrepHash, QGVAR(locality), "SIDE"] call ALIVE_fnc_hashGet) do {
                case "GLOBAL": {
                    [[_logic,"createsitrep",[_sitrepName,_sitrepHash]], "ALIVE_fnc_sitrep", nil, false, true] call BIS_fnc_MP;
                };
                case "SIDE": {
                    [[_logic,"createsitrep",[_sitrepName,_sitrepHash]], "ALIVE_fnc_sitrep", side (group player), false, true] call BIS_fnc_MP;
                };
                case "GROUP": {
                    [[_logic,"createsitrep",[_sitrepName,_sitrepHash]], "ALIVE_fnc_sitrep", group player, false, true] call BIS_fnc_MP;
                };
                case "FACTION": {
                    [[_logic,"createsitrep",[_sitrepName,_sitrepHash, faction player]], "ALIVE_fnc_sitrep", nil, false, true] call BIS_fnc_MP;
                };
                case "LOCAL": {
                    [_logic,"createsitrep",[_sitrepName,_sitrepHash]] call ALIVE_fnc_sitrep;
                };
            };
            _result = _sitrepName;
        };

        case "addsitrepToStore": {
             private ["_sitrepName","_sitrepHash"];
            _sitrepName = _args select 0;
            _sitrepHash = _args select 1;

            if (isDedicated) then {
                _sitrepHash = [_sitrepHash] call ALIVE_fnc_hashAddWarRoomData;
            };

            [GVAR(STORE), _sitrepName, _sitrepHash] call ALIVE_fnc_hashSet;

            _result = GVAR(STORE);
        };


        case "removesitrep": {
            // Removes a sitrep from the store
            private ["_sitrepName","_sitrepHash","_sitrep"];
            _sitrepName = _args select 0;

            _sitrepHash = [GVAR(STORE),_sitrepName] call ALIVE_fnc_hashGet;

            _result = false;

            // Delete sitrep
            switch ([_sitrepHash, QGVAR(locality), "SIDE"] call ALIVE_fnc_hashGet) do {
                case "SIDE": {
                    [[_logic,"deletesitrep",[_sitrepName]], "ALIVE_fnc_sitrep", side (group player), false, true] call BIS_fnc_MP;
                };
                case "GROUP": {
                    [[_logic,"deletesitrep",[_sitrepName]], "ALIVE_fnc_sitrep", group player, false, true] call BIS_fnc_MP;
                };
                case "FACTION": {
                   [[_logic,"deletesitrep",[_sitrepName, faction player]], "ALIVE_fnc_sitrep", true, false, true] call BIS_fnc_MP;
                };
                case "LOCAL": {
                    [_logic,"deletesitrep",[_sitrepName]] call ALIVE_fnc_sitrep;
                };
                case default {
                    [[_logic,"deletesitrep",[_sitrepName]], "ALIVE_fnc_sitrep", true, false, true] call BIS_fnc_MP;
                };
            };

            // Remove sitrep from store on all localities
            [[_logic, "deletesitrepFromStore", [_sitrepName, _sitrepHash]], "ALIVE_fnc_sitrep",true,false,true] call BIS_fnc_MP;


            _result = GVAR(STORE);

        };

        case "deletesitrep": {
            // Handles deleting a sitrep on the map
            // Expects a sitrepname as input
            private ["_sitrepName","_check"];
            _sitrepName = _args select 0;

            LOG(str _this);
            _check = false;

            if (hasInterface) then {

                if (count _args > 1) then {
                    if (faction player == (_args select 1)) then {_check = true};
                } else {
                    _check = true;
                };

                if (_check) then {
                    LOG("Deleting sitrep...");
                    LOG(_sitrepName);
     //             BIS Y U NO COMMAND TO DELETE DIARY ENTRIES?
                };
            };

            _result = _check;
        };

        case "deletesitrepFromStore": {
             private ["_sitrepName"];
            _sitrepName = _args select 0;
            _sitrepHash = _args select 1;

            If (isDedicated) then {
                private "_response";
                _response = [_sitrepName, _sitrepHash] call ALIVE_fnc_sitrepDeleteData;
                TRACE_1("Delete sitrep", _response);
            };

            [GVAR(STORE), _sitrepName] call ALIVE_fnc_hashRem;

            _result = GVAR(STORE);
        };

        case "deleteAllsitreps": {
            // Delete all sitreps on the map
        };

        case "destroy": {
            [[_logic, "destroyGlobal",_args],"ALIVE_fnc_sitrep",true, false] call BIS_fnc_MP;
        };

        case "destroyGlobal": {

                [_logic, "debug", false] call MAINCLASS;

                if (isServer) then {
                		// if server
                        MOD(SYS_sitrep) = _logic;

                        MOD(SYS_sitrep) setVariable ["super", nil];
                        MOD(SYS_sitrep) setVariable ["class", nil];
                        MOD(SYS_sitrep) setVariable ["init", nil];

                        // and publicVariable to clients

                        publicVariable QMOD(SYS_sitrep);
                        [_logic, "destroy"] call SUPERCLASS;
                };

                if (hasInterface) then {
                };
        };

        default {
            _result = [_logic, _operation, _args] call SUPERCLASS;
        };
};


TRACE_1("ALiVE SYS sitrep - output",_result);

if !(isnil "_result") then {
    _result;
};
