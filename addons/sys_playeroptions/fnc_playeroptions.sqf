#include <\x\alive\addons\sys_playeroptions\script_component.hpp>
SCRIPT(playeroptions);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_playeroptions
Description:
Creates the server side object to store settings

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array,String,Number,Boolean - The selected parameters

Returns:
Array, String, Number, Any - The expected return value

Examples:
(begin example)
// Create instance by placing editor module
[_logic,"init"] call ALiVE_fnc_playeroptions;
(end)

See Also:
- <ALIVE_fnc_playeroptionsInit>

Author:
Cameroon

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_playeroptions

private ["_result", "_operation", "_args", "_logic"];

PARAMS_1(_logic);
DEFAULT_PARAM(1,_operation,"");
DEFAULT_PARAM(2,_args,nil);

TRACE_3(QUOTE(ADDON),_logic, _operation, _args);

switch (_operation) do {

    	case "create": {
            if (isServer) then {

	            // Ensure only one module is used
	            if !(isNil QUOTE(ADDON)) then {
                	_logic = ADDON;
                    ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_playeroptions_ERROR1");
	            } else {
	        		_logic = (createGroup sideLogic) createUnit ["ALiVE_SYS_playeroptions", [0,0], [], 0, "NONE"];
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

            ["%1 - Initialisation started...",_logic] call ALiVE_fnc_Dump;

            //Only one init per instance is allowed
            if !(isnil {_logic getVariable "initGlobal"}) exitwith {["ALiVE Player Options - Only one init process per instance allowed! Exiting..."] call ALiVE_fnc_Dump};

            //Start init
            _logic setVariable ["initGlobal", false];

            /*
            MODEL - no visual just reference data
            - module object datastorage parameters
            - Establish data handler on server
            - Establish data model on server and client
            */

            ADDON = _logic;

            // Define module basics on server
			if (isServer) then {
                _errorMessage = "Please include either the Requires ALiVE module or the Profiles module! %1 %2";
                _error1 = ""; _error2 = ""; //defaults
                if(
                    !(["ALiVE_require"] call ALiVE_fnc_isModuleavailable)
                    ) exitwith {
                    [_errorMessage,_error1,_error2] call ALIVE_fnc_dumpR;
                };

                _logic setVariable ["init", true, true];
			};

            /*
            CONTROLLER  - coordination
            */

            // Wait until server init is finished
            waituntil {_logic getvariable ["init",false]};

            // Create and init the player options systems on client and server
            private ["_logicVariables","_playerOptionLogics"];
            // Get all logic variables
            _logicVariables = (configFile >> "CfgVehicles" >> "ALiVE_SYS_playeroptions" >> "Arguments") call BIS_fnc_getCfgSubClasses;

            TRACE_1("Logic Parameters",_logicVariables);

            _playerOptionLogics = [
                    ["ALiVE_fnc_player",[0,7,8,9,10,11,12,13,14,15,16,17]],
                    ["ALiVE_fnc_vdist",[0,2,3,4,5]],
                    ["ALiVE_fnc_crewinfo",[0,19]],
                    ["ALiVE_fnc_playertags",[0,20,21,22,23,24,25,26,27,28,29,30,31,32,33]]
            ];

            {
                private ["_module","_fnc","_vars","_moduleLogic"];
                _fnc = _x select 0;
                _vars = _x select 1;
                _code = missionNamespace getVariable format ["%1", _fnc];
                // Create
                TRACE_1("Create Logic",_x select 0);
                _moduleLogic = [nil,"create"] call _code;
                TRACE_1("Module Created",_moduleLogic);
                // Set
                {
                    _value = _logic getVariable (_logicVariables select _x);
                    TRACE_2("Logic Variable ",(_logicVariables select _x), _value);
                    _moduleLogic setVariable [(_logicVariables select _x), _logic getVariable (_logicVariables select _x)];
                } foreach _vars;

                // Init
                TRACE_1("Init Logic",_moduleLogic);
                _code = missionNamespace getVariable format ["%1Init", _fnc];
                [_moduleLogic,"init"] spawn _code;

            } forEach _playerOptionLogics;

            TRACE_1("After module init",_logic);

            // Indicate Init is finished on server
            if (isServer) then {
                _logic setVariable ["startupComplete", true, true];
            };

            if(!isDedicated && !isHC) then {
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
                                "call ALIVE_fnc_playeroptionsMenuDef",
                                "main"
                        ]
                ] call ALIVE_fnc_flexiMenu_Add;
            };

            ["%1 - Initialisation Completed...", _logic] call ALiVE_fnc_Dump;

            _result = _logic;
        };

        case "destroy": {
            [[_logic, "destroyGlobal",_args],"ALIVE_fnc_playeroptions",true, false] call BIS_fnc_MP;
        };

        case "destroyGlobal": {

                [_logic, "debug", false] call MAINCLASS;

                if (isServer) then {
                		// if server
                        ADDON = _logic;

                        ADDON setVariable ["super", nil];
                        ADDON setVariable ["class", nil];
                        ADDON setVariable ["init", nil];

                        // and publicVariable to clients

                        publicVariable QUOTE(ADDON);
                        [_logic, "destroy"] call SUPERCLASS;
                };

                if (hasInterface) then {
                };
        };

        default {
            _result = [_logic, _operation, _args] call SUPERCLASS;
        };
};


TRACE_1("ALiVE SYS playeroptions - output",_result);

if !(isnil "_result") then {
    _result;
};
