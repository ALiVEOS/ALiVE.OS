#include <\x\alive\addons\sys_crewinfo\script_component.hpp>
SCRIPT(crewinfo);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_crewinfo
Description:
Creates the server side object to store settings

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
// Create instance by placing editor module and specifiying name myModule
(end)

See Also:
- <ALIVE_fnc_crewinfoInit>


Author:
Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALiVE_fnc_CrewInfo

private ["_logic","_operation","_args","_result"];

PARAMS_1(_logic);
DEFAULT_PARAM(1,_operation,"");
DEFAULT_PARAM(2,_args,[]);

TRACE_3(QUOTE(ADDON),_logic, _operation, _args);


switch(_operation) do {
        case "create": {
                if (isServer) then {

                    // Ensure only one module is used
                    if !(isNil QUOTE(ADDON)) then {
                        _logic = ADDON;
                        ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_CREWINFO_ERROR1");
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
                if (_logic getVariable ["crewinfo_ui_setting","Left"] == "0") exitWith {["ALiVE SYS CREWINFO - Feature turned off! Exiting..."] call ALiVE_fnc_Dump};

                //Only one init per instance is allowed
                if !(isnil {_logic getVariable "initGlobal"}) exitwith {["ALiVE SYS CREWINFO - Only one init process per instance allowed! Exiting..."] call ALiVE_fnc_Dump};

                //Start init
                _logic setVariable ["initGlobal", false];

                // Server init
                if (isServer) then {

                    //Define logic
                    ADDON = _logic;

                    // if server, initialise module game logic
                    _logic setVariable ["super", SUPERCLASS];
                    _logic setVariable ["class", MAINCLASS];
                    _logic setVariable ["init", true, true];

                    // and publicVariable to clients
                    publicVariable QUOTE(ADDON);

                // Client init
                } else {
                	// any client side logic
                };

                // and wait for game logic to initialise
                waitUntil {!isNil QUOTE(ADDON) && {ADDON getVariable ["init", false]}};

                /*
                VIEW - purely visual
                - initialise
                */

                _logic setVariable ["bis_fnc_initModules_activate",true];

				// Only on player clients
                if (hasInterface) then {
                    
            	    CREWINFO_DEBUG = call compile (_logic getvariable ["debug","false"]);
                  	CREWINFO_UILOC = call compile (_logic getvariable ["crewinfo_ui_setting","1"]);
        	 		
                    Waituntil {!isnil "CREWINFO_DEBUG" && {!isnil "CREWINFO_UILOC"}};

    				// DEBUG -------------------------------------------------------------------------------------
						if(CREWINFO_DEBUG) then {
							["ALIVE Crew Info - Starting..."] call ALIVE_fnc_dump;
							if (CREWINFO_UILOC == 1) then {
								["ALIVE Crew Info - Drawing UI right (%1)", CREWINFO_UILOC] call ALIVE_fnc_dump;
							} else {
								["ALIVE Crew Info - Drawing UI left (%1)", CREWINFO_UILOC] call ALIVE_fnc_dump;
							};
						};
					// DEBUG -------------------------------------------------------------------------------------

   					[] spawn ALIVE_fnc_crewinfoClient;
                };

                _result = ADDON;
        };
        case "destroy": {
                if (isServer) then {
                        // if server
                        _logic setVariable ["super", nil];
                        _logic setVariable ["class", nil];
                        _logic setVariable ["init", nil];
                        // and publicVariable to clients
                        ADDON = _logic;
                        publicVariable QUOTE(ADDON);
                };
        };
        default {
                private["_err"];
                _err = format["%1 does not support %2 operation", _logic, _operation];
                ERROR_WITH_TITLE(str _logic,_err);
        };
};
TRACE_1("ALiVE SYS CREWINFO - output",_result);

if !(isnil "_result") then {
    _result;
};
