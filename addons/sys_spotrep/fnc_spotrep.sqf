#include <\x\alive\addons\sys_spotrep\script_component.hpp>
SCRIPT(spotrep);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_spotrep
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
state - returns the state of the spotrep STORE?
destroy - destroys the game logic
destroyGlobal - destroys the game logic globally

onspotrep - checks to see if a spotrep exists at a specified position
isAuthorized - checks to see if a player may add, edit or delete a spotrep
getspotrep - returns extended spotrep information
loadspotreps - loads spotreps from the database
savespotreps - saves spotreps to the database
restorespotreps - restores the spotreps loaded to the map
openDialog - opens the advanced spotrep user interface
addspotrep - adds a spotrep to the store
removespotrep - removes a spotrep from the store
createspotrep - creates a spotrep on the client machine
updatespotrep - updates a spotrep
deletespotrep - deletes a spotrep
deleteAllspotreps - deletes all spotreps on the map (Admin Only)

Examples:
(begin example)
// Create instance by placing editor module
[_logic,"init"] call ALiVE_fnc_spotrep;
(end)

See Also:
- <ALIVE_fnc_spotrepInit>

Author:
Tupolov

In memory of Peanut

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_spotrep

private ["_result", "_operation", "_args", "_logic"];

PARAMS_1(_logic);
DEFAULT_PARAM(1,_operation,"");
DEFAULT_PARAM(2,_args,nil);

TRACE_3("SYS_spotrep",_logic, _operation, _args);

switch (_operation) do {

    	case "create": {
            if (isServer) then {

	            // Ensure only one module is used
	            if !(isNil QMOD(SYS_spotrep)) then {
                	_logic = MOD(SYS_spotrep);
                    ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_spotrep_ERROR1");
	            } else {
	        		_logic = (createGroup sideLogic) createUnit ["ALiVE_SYS_spotrep", [0,0], [], 0, "NONE"];
                    MOD(SYS_spotrep) = _logic;
                };

                //Push to clients
	            PublicVariable QMOD(SYS_spotrep);
            };

            TRACE_1("Waiting for object to be ready",true);

            waituntil {!isnil QMOD(SYS_spotrep)};

            TRACE_1("Creating class on all localities",true);

			// initialise module game logic on all localities
			MOD(SYS_spotrep) setVariable ["super", QUOTE(SUPERCLASS)];
			MOD(SYS_spotrep) setVariable ["class", QUOTE(MAINCLASS)];

            _result = MOD(SYS_spotrep);
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
                if (["AliVE_SYS_spotrepPARAMS"] call ALiVE_fnc_isModuleavailable) then {
                    waituntil {!isnil {MOD(SYS_spotrep) getvariable "DEBUG"}};
                };

                // Create store initially on server
                GVAR(STORE) = [] call ALIVE_fnc_hashCreate;

                // Reset states with provided data;
                if !(_logic getvariable ["DISABLEPERSISTENCE",false]) then {
                    if (isDedicated && {[QMOD(SYS_DATA)] call ALiVE_fnc_isModuleAvailable}) then {
                        waituntil {!isnil QMOD(SYS_DATA) && {MOD(SYS_DATA) getvariable ["startupComplete",false]}};
                    };

                    ["DATA: Loading spot report data."] call ALIVE_fnc_dump;
                    _state = [_logic, "loadspotreps"] call ALIVE_fnc_spotrep;

                    if !(typeName _state == "BOOL") then {
                        GVAR(STORE) = _state;
                    } else {
                        LOG("No spotreps loaded...");
                    };

                };

                GVAR(STORE) call ALIVE_fnc_inspectHash;

            	[_logic,"state",GVAR(STORE)] call ALiVE_fnc_spotrep;

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
                        [ADDON, "restorespotreps", [GVAR(STORE)]] call ALiVE_fnc_spotrep;
                    };
                } else {
                      // Restore Markers on map based on initial store
                    [_logic, "restorespotreps", [GVAR(STORE)]] call ALiVE_fnc_spotrep;
                };
                 TRACE_1("Initial STORE", GVAR(STORE));

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

            //["%1 - Initialisation Completed...",MOD(SYS_spotrep)] call ALiVE_fnc_Dump;
            _logic setVariable ["bis_fnc_initModules_activate",true];
            _result = MOD(SYS_spotrep);
        };


       case "state": {

            TRACE_1("ALiVE SYS spotrep state called",_logic);

            if ((isnil "_args") || {!isServer}) exitwith {
                _result = GVAR(STORE)
            };

            // State is being set - restore spotreps

            _result = GVAR(STORE);
        };

        case "isAuthorized": {
            private "_spotrep";
            _spotrep = _args select 0;

            if (typeName _spotrep == "BOOL") then {
                _result = isPlayer player;
            } else {
                // If player owns spotrep, or player is admin or player is higher rank than owner
                _result = true;
            };
        };


        case "loadspotreps": {
            // Get spotreps from DB
            _result = call ALIVE_fnc_spotrepLoadData;
        };

        case "restorespotreps": {
            // Create spotreps from the store locally (run on clients only)
            private ["_restorespotreps","_hash","_i"];

            _hash = _args select 0;


            _restorespotreps = {
                private "_locality";
                LOG(str _this);
                _locality = [_value, QGVAR(locality),"SIDE"] call ALIVE_fnc_hashGet;
                switch _locality do {
                    case "SIDE": {
                        if ( str(side (group player)) == [_value, QGVAR(localityValue), ""] call ALiVE_fnc_hashGet) then {
                            [MOD(SYS_spotrep), "createspotrep", [_key,_value]] call ALIVE_fnc_spotrep;
                        };
                    };
                    case "GROUP": {
                        if (str(group player) == [_value, QGVAR(localityValue),""] call ALiVE_fnc_hashGet) then {
                            [MOD(SYS_spotrep), "createspotrep", [_key,_value]] call ALIVE_fnc_spotrep;
                        };
                    };
                    case "FACTION": {
                        [MOD(SYS_spotrep), "createspotrep", [_key,_value,  [_value, QGVAR(localityValue)] call ALiVE_fnc_hashGet]] call ALIVE_fnc_spotrep;
                    };
                    case "LOCAL": {
                        if ( (getPlayerUID player) == [_value, QGVAR(player), ""] call ALiVE_fnc_hashGet) then {
                            [MOD(SYS_spotrep), "createspotrep", [_key,_value]] call ALIVE_fnc_spotrep;
                        };
                    };
                    case default {
                        [MOD(SYS_spotrep), "createspotrep", [_key,_value]] call ALIVE_fnc_spotrep;
                    };
                };

            };

            [_hash, _restorespotreps] call CBA_fnc_hashEachPair;

            _result = true;

        };

        case "createspotrep": {
            // Handles creating a spotrep on the map
            // Accepts a hash as input (either from loading or from UI)
            private ["_spotrepName","_spotrepHash","_check"];
            _spotrepName = _args select 0;
            _spotrepHash = _args select 1;
            _check = false;
            _result = false;

            LOG(str QGVAR(callsign));

            if (hasInterface) then {

                if (count _args > 2) then {
                    if (faction player == (_args select 2)) then {_check = true};
                } else {
                    _check = true;
                };

                if (_check) then {
                    [
                        _spotrepName,
                        [_spotrepHash, QGVAR(callsign)] call ALIVE_fnc_hashGet,
                        [_spotrepHash, QGVAR(DTG)] call ALIVE_fnc_hashGet,
                        [_spotrepHash, QGVAR(dateTime)] call ALIVE_fnc_hashGet,
                        [_spotrepHash, QGVAR(loc)] call ALIVE_fnc_hashGet,
                        [_spotrepHash, QGVAR(faction)] call ALIVE_fnc_hashGet,
                        [_spotrepHash, QGVAR(size)] call ALIVE_fnc_hashGet,
                        [_spotrepHash, QGVAR(type)] call ALIVE_fnc_hashGet,
                        [_spotrepHash, QGVAR(activity)] call ALIVE_fnc_hashGet,
                        [_spotrepHash, QGVAR(factivity)] call ALIVE_fnc_hashGet,
                        [_spotrepHash, QGVAR(remarks),"NONE"] call ALIVE_fnc_hashGet,
                        [_spotrepHash, QGVAR(markername),"NONE"] call ALIVE_fnc_hashGet
                    ] call ALIVE_fnc_spotrepCreateDiaryRecord;

                    _result = true;
                };
            };

        };

        case "addspotrep": {
        	// Adds a spotrep to the store on the server and creates spotreps on necessary clients
            // Expects a spotrepname and hash as input.

            private ["_spotrepName","_spotrepHash","_spotrep"];
            _spotrepName = _args select 0;
            _spotrepHash = _args select 1;

            // Add spotrep to spotrep store on all localities
            [[_logic, "addspotrepToStore", [_spotrepName, _spotrepHash]], "ALIVE_fnc_spotrep",true,false,true] call BIS_fnc_MP;


            // Create spotrep

            switch ([_spotrepHash, QGVAR(locality), "SIDE"] call ALIVE_fnc_hashGet) do {
                case "GLOBAL": {
                    [[_logic,"createspotrep",[_spotrepName,_spotrepHash]], "ALIVE_fnc_spotrep", nil, false, true] call BIS_fnc_MP;
                };
                case "SIDE": {
                    [[_logic,"createspotrep",[_spotrepName,_spotrepHash]], "ALIVE_fnc_spotrep", side (group player), false, true] call BIS_fnc_MP;
                };
                case "GROUP": {
                    [[_logic,"createspotrep",[_spotrepName,_spotrepHash]], "ALIVE_fnc_spotrep", group player, false, true] call BIS_fnc_MP;
                };
                case "FACTION": {
                    [[_logic,"createspotrep",[_spotrepName,_spotrepHash, faction player]], "ALIVE_fnc_spotrep", nil, false, true] call BIS_fnc_MP;
                };
                case "LOCAL": {
                    [_logic,"createspotrep",[_spotrepName,_spotrepHash]] call ALIVE_fnc_spotrep;
                };
            };
            _result = _spotrepName;
        };

        case "addspotrepToStore": {
             private ["_spotrepName","_spotrepHash"];
            _spotrepName = _args select 0;
            _spotrepHash = _args select 1;

            if (isDedicated) then {
                _spotrepHash = [_spotrepHash] call ALIVE_fnc_hashAddWarRoomData;
            };

            [GVAR(STORE), _spotrepName, _spotrepHash] call ALIVE_fnc_hashSet;

            _result = GVAR(STORE);
        };


        case "removespotrep": {
            // Removes a spotrep from the store
            private ["_spotrepName","_spotrepHash","_spotrep"];
            _spotrepName = _args select 0;

            _spotrepHash = [GVAR(STORE),_spotrepName] call ALIVE_fnc_hashGet;

            _result = false;

            // Delete spotrep
            switch ([_spotrepHash, QGVAR(locality), "SIDE"] call ALIVE_fnc_hashGet) do {
                case "SIDE": {
                    [[_logic,"deletespotrep",[_spotrepName]], "ALIVE_fnc_spotrep", side (group player), false, true] call BIS_fnc_MP;
                };
                case "GROUP": {
                    [[_logic,"deletespotrep",[_spotrepName]], "ALIVE_fnc_spotrep", group player, false, true] call BIS_fnc_MP;
                };
                case "FACTION": {
                   [[_logic,"deletespotrep",[_spotrepName, faction player]], "ALIVE_fnc_spotrep", true, false, true] call BIS_fnc_MP;
                };
                case "LOCAL": {
                    [_logic,"deletespotrep",[_spotrepName]] call ALIVE_fnc_spotrep;
                };
                case default {
                    [[_logic,"deletespotrep",[_spotrepName]], "ALIVE_fnc_spotrep", true, false, true] call BIS_fnc_MP;
                };
            };

            // Remove spotrep from store on all localities
            [[_logic, "deletespotrepFromStore", [_spotrepName, _spotrepHash]], "ALIVE_fnc_spotrep",true,false,true] call BIS_fnc_MP;


            _result = GVAR(STORE);

        };

        case "deletespotrep": {
            // Handles deleting a spotrep on the map
            // Expects a spotrepname as input
            private ["_spotrepName","_check"];
            _spotrepName = _args select 0;

            LOG(str _this);
            _check = false;

            if (hasInterface) then {

                if (count _args > 1) then {
                    if (faction player == (_args select 1)) then {_check = true};
                } else {
                    _check = true;
                };

                if (_check) then {
                    LOG("Deleting spotrep...");
                    LOG(_spotrepName);
     //             BIS Y U NO COMMAND TO DELETE DIARY ENTRIES?
                };
            };

            _result = _check;
        };

        case "deletespotrepFromStore": {
             private ["_spotrepName"];
            _spotrepName = _args select 0;
            _spotrepHash = _args select 1;

            If (isDedicated) then {
                private "_response";
                _response = [_spotrepName, _spotrepHash] call ALIVE_fnc_spotrepDeleteData;
                TRACE_1("Delete spotrep", _response);
            };

            [GVAR(STORE), _spotrepName] call ALIVE_fnc_hashRem;

            _result = GVAR(STORE);
        };

        case "deleteAllspotreps": {
            // Delete all spotreps on the map
        };

        case "destroy": {
            [[_logic, "destroyGlobal",_args],"ALIVE_fnc_spotrep",true, false] call BIS_fnc_MP;
        };

        case "destroyGlobal": {

                [_logic, "debug", false] call MAINCLASS;

                if (isServer) then {
                		// if server
                        MOD(SYS_spotrep) = _logic;

                        MOD(SYS_spotrep) setVariable ["super", nil];
                        MOD(SYS_spotrep) setVariable ["class", nil];
                        MOD(SYS_spotrep) setVariable ["init", nil];

                        // and publicVariable to clients

                        publicVariable QMOD(SYS_spotrep);
                        [_logic, "destroy"] call SUPERCLASS;
                };

                if (hasInterface) then {
                };
        };

        default {
            _result = [_logic, _operation, _args] call SUPERCLASS;
        };
};


TRACE_1("ALiVE SYS spotrep - output",_result);

if !(isnil "_result") then {
    _result;
};
