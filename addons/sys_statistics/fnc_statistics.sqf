#include <\x\alive\addons\sys_statistics\script_component.hpp>
SCRIPT(statistics);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_statistics
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
Boolean - ghost - Enabled or disable statistics function

The popup menu will change to show status as functions are enabled and disabled.

By default this module will initialize and run. By placing down the Disable Stats module you will remove the feature from your mission.

Examples:
(begin example)
// Will be created without the need for placing a module
// Disable the feature by placing editor module and specifiying name myModule
(end)

See Also:
- <ALIVE_fnc_statisticsInit>
- <ALIVE_fnc_statisticsMenuDef>

Author:
Tupolov

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_statistics

private ["_logic","_operation","_args"];

PARAMS_1(_logic);
DEFAULT_PARAM(1,_operation,"");
DEFAULT_PARAM(2,_args,[]);

switch(_operation) do {
        case "init": {
                /*
                MODEL - no visual just reference data
                - server side object only
                - statistics enabled
                */

                // Ensure only one module is used
                if (isServer && !(isNil _logic)) exitWith {
                        ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_statistics_ERROR1");
                };

                //Only one init per instance is allowed
            	if !(isnil {_logic getVariable "initGlobal"}) exitwith {["ALiVE SYS STATISTICS - Only one init process per instance allowed! Exiting..."] call ALiVE_fnc_Dump};

            	//Start init
            	_logic setVariable ["initGlobal", false];

                if (isServer) then {

                        // if server, initialise module game logic
                        _logic setVariable ["super", SUPERCLASS];
                        _logic setVariable ["class", MAINCLASS];
                        _logic setVariable ["init", true, true];

						// and publicVariable to clients
                        MOD(statistics) = _logic;
                        publicVariable QMOD(statistics);
                } else {
                        // any client side logic
                };

				TRACE_2("After module init",_logic, _logic getVariable "init");

                // and wait for game logic to initialise
                // TODO merge into lazy evaluation
                waitUntil {!isNil _logic};
                waitUntil {_logic getVariable ["init", false]};

                /*
                VIEW - purely visual
                - initialise menu
                - frequent check to modify menu and display status (ALIVE_fnc_adminActoinsmenuDef)
                */

				TRACE_2("Adding menu",isDedicated,isHC);

                if(!isDedicated && !isHC) then {
                        // Initialise interaction key if undefined
/*                        if(isNil "SELF_INTERACTION_KEY") then {SELF_INTERACTION_KEY = [221,[false,false,false]];};

                        // if ACE spectator enabled, seto to allow exit
                        if(!isNil "ace_fnc_startSpectator") then {ace_sys_spectator_can_exit_spectator = true;};

                        // Initialise default map click command if undefined
                        ISNILS(DEFAULT_MAPCLICK,"");

				TRACE_3("Menu pre-req",SELF_INTERACTION_KEY,ace_fnc_startSpectator,DEFAULT_MAPCLICK);

                        // initialise main menu
                        [
                                "player",
                                [((["ALiVE", "openMenu"] call cba_fnc_getKeybind) select 5) select 0],
                                -9500,
                                [
                                        "call ALIVE_fnc_statisticsMenuDef",
                                        "adminActions"
                                ]
                        ] call ALIVE_fnc_flexiMenu_Add; */
                };

                /*
                CONTROLLER  - coordination
                - frequent check if player is server admin (ALIVE_fnc_statisticsmenuDef)
                */
                _logic setVariable ["bis_fnc_initModules_activate",true];
        };
        case "destroy": {
                if (isServer) then {
                        // if server
                        _logic setVariable ["super", nil];
                        _logic setVariable ["class", nil];
                        _logic setVariable ["init", nil];
                        // and publicVariable to clients
                        MOD(statistics) = _logic;
                        publicVariable QMOD(statistics);
                };

                if(!isDedicated && !isHC) then {
                        // remove main menu
                        [
                                "player",
                                [((["ALiVE", "openMenu"] call cba_fnc_getKeybind) select 5) select 0],
                                -9500,
                                [
                                        "call ALIVE_fnc_statisticsMenuDef",
                                        "main"
                                ]
                        ] call ALIVE_fnc_flexiMenu_Remove;
                };
        };
        default {
                private["_err"];
                _err = format["%1 does not support %2 operation", _logic, _operation];
                ERROR_WITH_TITLE(str _logic,_err);
        };
};
