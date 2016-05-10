#include <\x\alive\addons\sys_adminactions\script_component.hpp>
SCRIPT(adminActions);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_adminActions
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
Boolean - ghost - Enabled or disable Ghosting function
Boolean - teleport - Enabled or disable Teleporting function
Boolean - mark_units - Enabled or disable marking of units on map
Boolean - console - Enabled or disable Debug console function

The popup menu will change to show status as functions are enabled and disabled.

Note: I was going to add a process that checked if the admin had logged out and
reset their Ghost and Teleport abilities, but this would play havoc with potential
mission mechanics.

Examples:
(begin example)
// Create instance by placing editor module and specifiying name myModule
(end)

See Also:
- <ALIVE_fnc_adminActionsInit>
- <ALIVE_fnc_adminActionsMenuDef>

Author:
Wolffy.au
Jman

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_adminActions

private ["_logic","_operation","_args","_result"];

_logic = [_this, 0, objNull, [objNull]] call BIS_fnc_param;
_operation = [_this, 1, "", [""]] call BIS_fnc_param;
_args = [_this, 2, objNull, [objNull,[],"",0,true,false]] call BIS_fnc_param;
_result = true;

TRACE_3(QUOTE(ADDON),_logic, _operation, _args);

switch(_operation) do {

        case "create": {
                if (isServer) then {

                    // Ensure only one module is used
                    if !(isNil QUOTE(ADDON)) then {
                        _logic = ADDON;
                        ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_ADMINACTIONS_ERROR1");
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
                /*
                MODEL - no visual just reference data
                - server side object only
                - ghosting enabled
                - teleport enabled
                - mark units enabled
                - Debug console enabled
                */

                //["%1 - Initialisation started...",_logic] call ALiVE_fnc_Dump;

               //Only one init per instance is allowed
            	if !(isnil {_logic getVariable "initGlobal"}) exitwith {["ALiVE SYS ADMINACTIONS - Only one init process per instance allowed! Exiting..."] call ALiVE_fnc_Dump};

                //Start init
                _logic setVariable ["initGlobal", false];

                if (isServer) then {
                        _logic setVariable ["init", true, true];
                } else {
                        // any client side logic
                };

                TRACE_2("After module init",ADDON,ADDON getVariable "init");

                // and wait for game logic to initialise
                // TODO merge into lazy evaluation
                waitUntil {!isNil QUOTE(ADDON)};
                waitUntil {_logic getVariable ["init", false]};

                TRACE_1("Spawning Server processes",isServer);

                if (isServer) then {
                        // Do Something
                };

                TRACE_1("Spawning clientside processes",hasInterface);


                /*
                VIEW - purely visual
                - initialise menu
                - frequent check to modify menu and display status (ALIVE_fnc_logisticsmenuDef)
                */

                TRACE_2("Adding menu",hasInterface);

                if(hasInterface) then {
                        // Initialise interaction key if undefined
                        if(isNil "SELF_INTERACTION_KEY") then {SELF_INTERACTION_KEY = [221,[false,false,false]];};

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
                                        "call ALIVE_fnc_adminActionsMenuDef",
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
        };
        case "destroy": {
                if (hasInterface) then {
                        // remove main menu
                        [
                                "player",
                                [((["ALiVE", "openMenu"] call cba_fnc_getKeybind) select 5) select 0],
                                -9500,
                                [
                                        "call ALIVE_fnc_adminActionsMenuDef",
                                        "main"
                                ]
                        ] call ALIVE_fnc_flexiMenu_Remove;
                };

                if (isServer) then {
                        // if server
                        _logic setVariable ["super", nil];
                        _logic setVariable ["class", nil];
                        _logic setVariable ["init", nil];

                        [_logic,"destroy"] call SUPERCLASS;

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

TRACE_1("ALiVE SYS ADMINACTIONS - output",_result);

if !(isnil "_result") then {
    _result;
};

