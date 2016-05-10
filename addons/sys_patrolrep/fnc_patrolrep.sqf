#include <\x\alive\addons\sys_patrolrep\script_component.hpp>
SCRIPT(patrolrep);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_patrolrep
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
state - returns the state of the patrolrep STORE?
destroy - destroys the game logic
destroyGlobal - destroys the game logic globally

onpatrolrep - checks to see if a patrolrep exists at a specified position
isAuthorized - checks to see if a player may add, edit or delete a patrolrep
getpatrolrep - returns extended patrolrep information
loadpatrolreps - loads patrolreps from the database
savepatrolreps - saves patrolreps to the database
restorepatrolreps - restores the patrolreps loaded to the map
openDialog - opens the advanced patrolrep user interface
addpatrolrep - adds a patrolrep to the store
removepatrolrep - removes a patrolrep from the store
createpatrolrep - creates a patrolrep on the client machine
updatepatrolrep - updates a patrolrep
deletepatrolrep - deletes a patrolrep
deleteAllpatrolreps - deletes all patrolreps on the map (Admin Only)

Examples:
(begin example)
// Create instance by placing editor module
[_logic,"init"] call ALiVE_fnc_patrolrep;
(end)

See Also:
- <ALIVE_fnc_patrolrepInit>

Author:
Tupolov

In memory of Peanut

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_patrolrep

private ["_result", "_operation", "_args", "_logic"];

PARAMS_1(_logic);
DEFAULT_PARAM(1,_operation,"");
DEFAULT_PARAM(2,_args,nil);

TRACE_3("SYS_patrolrep",_logic, _operation, _args);

switch (_operation) do {

    	case "create": {
            if (isServer) then {

	            // Ensure only one module is used
	            if !(isNil QMOD(SYS_patrolrep)) then {
                	_logic = MOD(SYS_patrolrep);
                    ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_patrolrep_ERROR1");
	            } else {
	        		_logic = (createGroup sideLogic) createUnit ["ALiVE_SYS_patrolrep", [0,0], [], 0, "NONE"];
                    MOD(SYS_patrolrep) = _logic;
                };

                //Push to clients
	            PublicVariable QMOD(SYS_patrolrep);
            };

            TRACE_1("Waiting for object to be ready",true);

            waituntil {!isnil QMOD(SYS_patrolrep)};

            TRACE_1("Creating class on all localities",true);

			// initialise module game logic on all localities
			MOD(SYS_patrolrep) setVariable ["super", QUOTE(SUPERCLASS)];
			MOD(SYS_patrolrep) setVariable ["class", QUOTE(MAINCLASS)];

            _result = MOD(SYS_patrolrep);
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
                if (["AliVE_SYS_patrolrepPARAMS"] call ALiVE_fnc_isModuleavailable) then {
                    waituntil {!isnil {MOD(SYS_patrolrep) getvariable "DEBUG"}};
                };

                // Create store initially on server
                GVAR(STORE) = [] call ALIVE_fnc_hashCreate;

                // Reset states with provided data;
                if !(_logic getvariable ["DISABLEPERSISTENCE",false]) then {
                    if (isDedicated && {[QMOD(SYS_DATA)] call ALiVE_fnc_isModuleAvailable}) then {
                        waituntil {!isnil QMOD(SYS_DATA) && {MOD(SYS_DATA) getvariable ["startupComplete",false]}};
                    };

                    ["DATA: Loading patrol report data."] call ALIVE_fnc_dump;
                    _state = [_logic, "loadpatrolreps"] call ALIVE_fnc_patrolrep;

                    if !(typeName _state == "BOOL") then {
                        GVAR(STORE) = _state;
                    } else {
                        LOG("No patrolreps loaded...");
                    };

                };

                GVAR(STORE) call ALIVE_fnc_inspectHash;

            	[_logic,"state",GVAR(STORE)] call ALiVE_fnc_patrolrep;

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
                    QGVAR(STORE) addPublicVariableEventHandler {
                        // Restore Markers on map for JIP
                        [ADDON, "restorepatrolreps", [GVAR(STORE)]] call ALiVE_fnc_patrolrep;
                    };
                } else {
                      // Restore Markers on map based on initial store
                    [_logic, "restorepatrolreps", [GVAR(STORE)]] call ALiVE_fnc_patrolrep;
                };
                 TRACE_1("Initial STORE", GVAR(STORE));

                waitUntil {
                    sleep 1;
                    ((str side player) != "UNKNOWN")
                };

                GVAR(spos) = position player;
                GVAR(sdate) = date;
            };


            TRACE_1("After module init",_logic);

            // Indicate Init is finished on server
            if (isServer) then {
                _logic setVariable ["startupComplete", true, true];
            };

            //["%1 - Initialisation Completed...",MOD(SYS_patrolrep)] call ALiVE_fnc_Dump;
            _logic setVariable ["bis_fnc_initModules_activate",true];
            _result = MOD(SYS_patrolrep);
        };


       case "state": {

            TRACE_1("ALiVE SYS patrolrep state called",_logic);

            if ((isnil "_args") || {!isServer}) exitwith {
                _result = GVAR(STORE)
            };

            // State is being set - restore patrolreps

            _result = GVAR(STORE);
        };

        case "isAuthorized": {
            private "_patrolrep";
            _patrolrep = _args select 0;

            if (typeName _patrolrep == "BOOL") then {
                _result = isPlayer player;
            } else {
                // If player owns patrolrep, or player is admin or player is higher rank than owner
                _result = true;
            };
        };


        case "loadpatrolreps": {
            // Get patrolreps from DB
            _result = call ALIVE_fnc_patrolrepLoadData;
        };

        case "restorepatrolreps": {
            // Create patrolreps from the store locally (run on clients only)
            private ["_restorepatrolreps","_hash","_i"];

            _hash = _args select 0;


            _restorepatrolreps = {
                private "_locality";
                LOG(str _this);
                _locality = [_value, QGVAR(locality),"SIDE"] call ALIVE_fnc_hashGet;
                switch _locality do {
                    case "SIDE": {
                        if ( str(side (group player)) == [_value, QGVAR(localityValue), ""] call ALiVE_fnc_hashGet) then {
                            [MOD(SYS_patrolrep), "createpatrolrep", [_key,_value]] call ALIVE_fnc_patrolrep;
                        };
                    };
                    case "GROUP": {
                        if (str(group player) == [_value, QGVAR(localityValue),""] call ALiVE_fnc_hashGet) then {
                            [MOD(SYS_patrolrep), "createpatrolrep", [_key,_value]] call ALIVE_fnc_patrolrep;
                        };
                    };
                    case "FACTION": {
                        [MOD(SYS_patrolrep), "createpatrolrep", [_key,_value,  [_value, QGVAR(localityValue)] call ALiVE_fnc_hashGet]] call ALIVE_fnc_patrolrep;
                    };
                    case "LOCAL": {
                        if ( (getPlayerUID player) == [_value, QGVAR(player), ""] call ALiVE_fnc_hashGet) then {
                            [MOD(SYS_patrolrep), "createpatrolrep", [_key,_value]] call ALIVE_fnc_patrolrep;
                        };
                    };
                    case default {
                        [MOD(SYS_patrolrep), "createpatrolrep", [_key,_value]] call ALIVE_fnc_patrolrep;
                    };
                };

            };

            [_hash, _restorepatrolreps] call CBA_fnc_hashEachPair;

            _result = true;

        };

        case "createpatrolrep": {
            // Handles creating a patrolrep on the map
            // Accepts a hash as input (either from loading or from UI)
            private ["_patrolrepName","_patrolrepHash","_check"];
            _patrolrepName = _args select 0;
            _patrolrepHash = _args select 1;
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
                        _patrolrepName,
                        [_patrolrepHash, QGVAR(callsign)] call ALIVE_fnc_hashGet,
                        [_patrolrepHash, QGVAR(DTG)] call ALIVE_fnc_hashGet,
                        [_patrolrepHash, QGVAR(sdateTime)] call ALIVE_fnc_hashGet,
                        [_patrolrepHash, QGVAR(edateTime)] call ALIVE_fnc_hashGet,
                        [_patrolrepHash, QGVAR(sloc)] call ALIVE_fnc_hashGet,
                        [_patrolrepHash, QGVAR(eloc)] call ALIVE_fnc_hashGet,
                        [_patrolrepHash, QGVAR(patcomp)] call ALIVE_fnc_hashGet,
                        [_patrolrepHash, QGVAR(task)] call ALIVE_fnc_hashGet,
                        [_patrolrepHash, QGVAR(enbda)] call ALIVE_fnc_hashGet,
                        [_patrolrepHash, QGVAR(results)] call ALIVE_fnc_hashGet,
                        [_patrolrepHash, QGVAR(cs)] call ALIVE_fnc_hashGet,
                        [_patrolrepHash, QGVAR(ammo)] call ALIVE_fnc_hashGet,
                        [_patrolrepHash, QGVAR(cas)] call ALIVE_fnc_hashGet,
                        [_patrolrepHash, QGVAR(veh)] call ALIVE_fnc_hashGet,
                        [_patrolrepHash, QGVAR(spotreps)] call ALIVE_fnc_hashGet,
                        [_patrolrepHash, QGVAR(sitreps)] call ALIVE_fnc_hashGet,
                        [_patrolrepHash, QGVAR(group)] call ALIVE_fnc_hashGet,
                        [_patrolrepHash, QGVAR(spos)] call ALIVE_fnc_hashGet,
                        [_patrolrepHash, QGVAR(epos)] call ALIVE_fnc_hashGet
                    ] call ALIVE_fnc_patrolrepCreateDiaryRecord;

                    _result = true;
                };
            };

        };

        case "addpatrolrep": {
        	// Adds a patrolrep to the store on the server and creates patrolreps on necessary clients
            // Expects a patrolrepname and hash as input.

            private ["_patrolrepName","_patrolrepHash","_patrolrep"];
            _patrolrepName = _args select 0;
            _patrolrepHash = _args select 1;

            // Add patrolrep to patrolrep store on all localities
            [[_logic, "addpatrolrepToStore", [_patrolrepName, _patrolrepHash]], "ALIVE_fnc_patrolrep",true,false,true] call BIS_fnc_MP;


            // Create patrolrep

            switch ([_patrolrepHash, QGVAR(locality), "SIDE"] call ALIVE_fnc_hashGet) do {
                case "GLOBAL": {
                    [[_logic,"createpatrolrep",[_patrolrepName,_patrolrepHash]], "ALIVE_fnc_patrolrep", nil, false, true] call BIS_fnc_MP;
                };
                case "SIDE": {
                    [[_logic,"createpatrolrep",[_patrolrepName,_patrolrepHash]], "ALIVE_fnc_patrolrep", side (group player), false, true] call BIS_fnc_MP;
                };
                case "GROUP": {
                    [[_logic,"createpatrolrep",[_patrolrepName,_patrolrepHash]], "ALIVE_fnc_patrolrep", group player, false, true] call BIS_fnc_MP;
                };
                case "FACTION": {
                    [[_logic,"createpatrolrep",[_patrolrepName,_patrolrepHash, faction player]], "ALIVE_fnc_patrolrep", nil, false, true] call BIS_fnc_MP;
                };
                case "LOCAL": {
                    [_logic,"createpatrolrep",[_patrolrepName,_patrolrepHash]] call ALIVE_fnc_patrolrep;
                };
            };
            _result = _patrolrepName;
        };

        case "addpatrolrepToStore": {
             private ["_patrolrepName","_patrolrepHash"];
            _patrolrepName = _args select 0;
            _patrolrepHash = _args select 1;

            if (isDedicated) then {
                _patrolrepHash = [_patrolrepHash] call ALIVE_fnc_hashAddWarRoomData;
            };

            [GVAR(STORE), _patrolrepName, _patrolrepHash] call ALIVE_fnc_hashSet;

            _result = GVAR(STORE);
        };


        case "removepatrolrep": {
            // Removes a patrolrep from the store
            private ["_patrolrepName","_patrolrepHash","_patrolrep"];
            _patrolrepName = _args select 0;

            _patrolrepHash = [GVAR(STORE),_patrolrepName] call ALIVE_fnc_hashGet;

            _result = false;

            // Delete patrolrep
            switch ([_patrolrepHash, QGVAR(locality), "SIDE"] call ALIVE_fnc_hashGet) do {
                case "SIDE": {
                    [[_logic,"deletepatrolrep",[_patrolrepName]], "ALIVE_fnc_patrolrep", side (group player), false, true] call BIS_fnc_MP;
                };
                case "GROUP": {
                    [[_logic,"deletepatrolrep",[_patrolrepName]], "ALIVE_fnc_patrolrep", group player, false, true] call BIS_fnc_MP;
                };
                case "FACTION": {
                   [[_logic,"deletepatrolrep",[_patrolrepName, faction player]], "ALIVE_fnc_patrolrep", true, false, true] call BIS_fnc_MP;
                };
                case "LOCAL": {
                    [_logic,"deletepatrolrep",[_patrolrepName]] call ALIVE_fnc_patrolrep;
                };
                case default {
                    [[_logic,"deletepatrolrep",[_patrolrepName]], "ALIVE_fnc_patrolrep", true, false, true] call BIS_fnc_MP;
                };
            };

            // Remove patrolrep from store on all localities
            [[_logic, "deletepatrolrepFromStore", [_patrolrepName, _patrolrepHash]], "ALIVE_fnc_patrolrep",true,false,true] call BIS_fnc_MP;


            _result = GVAR(STORE);

        };

        case "deletepatrolrep": {
            // Handles deleting a patrolrep on the map
            // Expects a patrolrepname as input
            private ["_patrolrepName","_check"];
            _patrolrepName = _args select 0;

            LOG(str _this);
            _check = false;

            if (hasInterface) then {

                if (count _args > 1) then {
                    if (faction player == (_args select 1)) then {_check = true};
                } else {
                    _check = true;
                };

                if (_check) then {
                    LOG("Deleting patrolrep...");
                    LOG(_patrolrepName);
     //             BIS Y U NO COMMAND TO DELETE DIARY ENTRIES?
                };
            };

            _result = _check;
        };

        case "deletepatrolrepFromStore": {
             private ["_patrolrepName"];
            _patrolrepName = _args select 0;
            _patrolrepHash = _args select 1;

            If (isDedicated) then {
                private "_response";
                _response = [_patrolrepName, _patrolrepHash] call ALIVE_fnc_patrolrepDeleteData;
                TRACE_1("Delete patrolrep", _response);
            };

            [GVAR(STORE), _patrolrepName] call ALIVE_fnc_hashRem;

            _result = GVAR(STORE);
        };

        case "deleteAllpatrolreps": {
            // Delete all patrolreps on the map
        };

        case "destroy": {
            [[_logic, "destroyGlobal",_args],"ALIVE_fnc_patrolrep",true, false] call BIS_fnc_MP;
        };

        case "destroyGlobal": {

                [_logic, "debug", false] call MAINCLASS;

                if (isServer) then {
                		// if server
                        MOD(SYS_patrolrep) = _logic;

                        MOD(SYS_patrolrep) setVariable ["super", nil];
                        MOD(SYS_patrolrep) setVariable ["class", nil];
                        MOD(SYS_patrolrep) setVariable ["init", nil];

                        // and publicVariable to clients

                        publicVariable QMOD(SYS_patrolrep);
                        [_logic, "destroy"] call SUPERCLASS;
                };

                if (hasInterface) then {
                };
        };

        default {
            _result = [_logic, _operation, _args] call SUPERCLASS;
        };
};


TRACE_1("ALiVE SYS patrolrep - output",_result);

if !(isnil "_result") then {
    _result;
};
