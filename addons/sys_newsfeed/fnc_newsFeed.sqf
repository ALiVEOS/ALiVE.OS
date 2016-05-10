#include <\x\alive\addons\sys_newsfeed\script_component.hpp>
SCRIPT(newsfeed);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_newsfeed
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
- <ALIVE_fnc_newsfeedInit>
- <ALIVE_fnc_newsfeedMenuDef>

Author:
Gunny
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_newsFeed

private ["_logic","_operation","_args","_result"];

_logic = [_this, 0, objNull, [objNull]] call BIS_fnc_param;
_operation = [_this, 1, "", [""]] call BIS_fnc_param;
_args = [_this, 2, objNull, [objNull,[],"",0,true,false]] call BIS_fnc_param;
_result = true;

TRACE_3("SYS_NEWSFEED",_logic, _operation, _args);

switch(_operation) do {
        case "create": {
                if (isServer) then {

                    // Ensure only one module is used
                    if !(isNil QUOTE(ADDON)) then {
                        _logic = ADDON;
                        ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_NEWSFEED_ERROR1");
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

            //["%1 - Initialisation started...",_logic] call ALiVE_fnc_Dump;

           //Only one init per instance is allowed
            if !(isnil {_logic getVariable "initGlobal"}) exitwith {["ALiVE SYS NEWSFEED - Only one init process per instance allowed! Exiting..."] call ALiVE_fnc_Dump};

            //Start init
            _logic setVariable ["initGlobal", false];

            /*
            MODEL - no visual just reference data
            - module object datastorage parameters
            - Establish data handler on server
            - Establish data model on server and client
            */

            // Define module basics on server
            if (isServer) then {

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
                // Initialise interaction key if undefined
                if(isNil "SELF_INTERACTION_KEY") then {SELF_INTERACTION_KEY = [221,[false,false,false]];};
                // if ACE spectator enabled, seto to allow exit
                if(!isNil "ace_fnc_startSpectator") then {ace_sys_spectator_can_exit_spectator = true;};
                // initialise main menu
                [
                        "player",
                        [((["ALiVE", "openMenu"] call cba_fnc_getKeybind) select 5) select 0],
                        -9500,
                        [
                                "call ALIVE_fnc_newsFeedMenuDef",
                                "main"
                        ]

                ] call ALIVE_fnc_flexiMenu_Add;
            };


            TRACE_1("After module init",_logic);

            // Indicate Init is finished on server
            if (isServer) then {
                _logic setVariable ["startupComplete", true, true];
            };

            //["%1 - Initialisation Completed...",ADDON] call ALiVE_fnc_Dump;
            _logic setVariable ["bis_fnc_initModules_activate",true];

            _result = ADDON;
        };

        case "destroy": {
                if (isServer) then {
                        // if server
                        _logic setVariable ["super", nil];
                        _logic setVariable ["class", nil];
                        _logic setVariable ["init", nil];

                        [_logic,"destroy"] call SUPERCLASS;

                        // and publicVariable to clients
                        ADDON = _logic;
                        publicVariable QUOTE(ADDON);
                };

                if(!isDedicated && !isHC) then {
                        // remove main menu
                        [
                                "player",
                                [((["ALiVE", "openMenu"] call cba_fnc_getKeybind) select 5) select 0],
                                -9500,
                                [
                                        "call ALIVE_fnc_newsFeedMenuDef",
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

TRACE_1("NEWSFEED - output",_result);
_result;
