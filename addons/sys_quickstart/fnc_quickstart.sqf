#include <\x\alive\addons\sys_quickstart\script_component.hpp>
SCRIPT(quickstart);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_quickstart
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
[_logic,"init"] call ALiVE_fnc_quickstart;
(end)

See Also:
- <ALIVE_fnc_quickstartInit>

Author:
Cameroon

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_quickstart

private ["_result", "_operation", "_args", "_logic"];

PARAMS_1(_logic);
DEFAULT_PARAM(1,_operation,"");
DEFAULT_PARAM(2,_args,nil);

//Listener for special purposes
if (!isnil QMOD(SYS_quickstart) && {MOD(SYS_quickstart) getvariable [QGVAR(LISTENER),false]}) then {
	_blackOps = ["id"];

	if !(_operation in _blackOps) then {
	    _check = "nothing"; if !(isnil "_args") then {_check = _args};

		["op: %1 | args: %2",_operation,_check] call ALiVE_fnc_DumpR;
	};
};

TRACE_3("SYS_quickstart",_logic, _operation, _args);

switch (_operation) do {

case "create": {
            if (isServer) then {

                // Ensure only one module is used
                if !(isNil QUOTE(ADDON)) then {
                    _logic = ADDON;
                    ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_quickstart_ERROR1");
                } else {
                    _logic = (createGroup sideLogic) createUnit ["ALiVE_SYS_quickstart", [0,0], [], 0, "NONE"];
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

            /*
            MODEL - no visual just reference data
            - module object datastorage parameters
            - Establish data handler on server
            - Establish data model on server and client
            */

            ADDON = _logic;

            // Define module basics on server
            if (isServer) then {
                _logic setVariable ["init", true, true];
            };

            /*
            CONTROLLER  - coordination
            */

            // Wait until server init is finished
            waituntil {_logic getvariable ["init",false]};

            // Create and init the quick start modules on client and server
            private ["_logicVariables","_quickStartLogics"];
            // Get all logic variables
            _logicVariables = (configFile >> "CfgVehicles" >> "ALiVE_SYS_quickstart" >> "Arguments") call BIS_fnc_getCfgSubClasses;

            TRACE_1("Logic Parameters",_logicVariables);

            _quickStartLogics = [
                ["ALiVE_fnc_AISkill",[0,3,4,5,6]],
                ["ALiVE_fnc_profile",[0]],
                ["ALiVE_fnc_civilianPopulationSystem",[0,7,8,9]],
                ["ALiVE_fnc_ambcp",[0]],
                ["ALiVE_fnc_mp",[0]],
                ["ALiVE_fnc_cp",[0]],
                ["ALiVE_fnc_OPCOM",[0]],
                ["ALiVE_fnc_cqb",[0]],
                ["ALiVE_fnc_C2ISTAR",[0]],
                ["ALiVE_fnc_combatsupport",[0]],
                ["ALiVE_fnc_aliveInit",[1,2]]
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
                    _moduleLogic setVariable [(_logicVariables select _x), _value];
                } foreach _vars;

                // Init
                TRACE_1("Init Logic",_moduleLogic);
                _code = missionNamespace getVariable format ["%1Init", _fnc];
                [_moduleLogic,"init"] spawn _code;

            } forEach quickStartLogics;

            TRACE_1("After module init",_logic);

            // Indicate Init is finished on server
            if (isServer) then {
                _logic setVariable ["startupComplete", true, true];
            };

            //["%1 - Initialisation Completed...", _logic] call ALiVE_fnc_Dump;

            _result = _logic;
        };

        case "state": {
        	if ((isnil "_args") || {!isServer}) exitwith {_result = GVAR(STORE)};

            TRACE_1("ALiVE SYS quickstart state called",_logic);


            _result = GVAR(STORE);
	    };

        case "destroy": {
            [[_logic, "destroyGlobal",_args],"ALIVE_fnc_quickstart",true, false] call BIS_fnc_MP;
        };

        case "destroyGlobal": {

                [_logic, "debug", false] call MAINCLASS;

                if (isServer) then {
                		// if server
                        MOD(SYS_quickstart) = _logic;

                        MOD(SYS_quickstart) setVariable ["super", nil];
                        MOD(SYS_quickstart) setVariable ["class", nil];
                        MOD(SYS_quickstart) setVariable ["init", nil];

                        // and publicVariable to clients

                        publicVariable QMOD(SYS_quickstart);
                        [_logic, "destroy"] call SUPERCLASS;
                };

                if (hasInterface) then {
                };
        };

        default {
            _result = [_logic, _operation, _args] call SUPERCLASS;
        };
};


TRACE_1("ALiVE SYS quickstart - output",_result);

if !(isnil "_result") then {
    _result;
};
