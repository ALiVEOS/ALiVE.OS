//#define DEBUG_MODE_FULL
#include <\x\alive\addons\sys_xstream\script_component.hpp>

SCRIPT(xStream);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_xStream
Description:
Provides a camera system for twitch streamers, also provides a live map functionality

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Nil - init - Intiate instance
Nil - destroy - Destroy instance
Boolean - debug - Debug enabled
Nil - register
Nil - start
Bool - enableTwitch
Bool - enableLiveMap
Bool - enableCamera
String - acreChannel
Bool  - cameraShake
Bool  - satellite
Bool  - vehicle
Bool  - aerial
Bool  - thirdPerson
Bool  - cameraManOnly
String or Array - clientID

Examples:
[_logic, "debug", true] call ALiVE_fnc_xStream;

See Also:
- <ALIVE_fnc_xStreamInit>

Author:
Tupolov

Peer Reviewed:

---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_xStream
#define MTEMPLATE "ALiVE_XSTREAM_%1"


private ["_logic","_operation","_args","_result","_debug","_enableTwitch","_enableCamera","_enableLiveMap"];

TRACE_1("XSTREAM - input",_this);

_logic = [_this, 0, objNull, [objNull]] call BIS_fnc_param;
_operation = [_this, 1, "", [""]] call BIS_fnc_param;
_args = [_this, 2, objNull, [objNull,[],"",0,true,false]] call BIS_fnc_param;
_result = true;

switch(_operation) do {
	default {
		_result = [_logic, _operation, _args] call SUPERCLASS;
	};
	case "destroy": {
		[_logic, "debug", false] call MAINCLASS;
		if (isServer) then {
			// if server
			_logic setVariable ["super", nil];
			_logic setVariable ["class", nil];

			[_logic, "destroy"] call SUPERCLASS;
		};
	};
	case "debug": {
		// FIXME - my preference would be to use a swtich statement here
		// rather than multiple if statements
		if (typeName _args == "BOOL") then {
			_logic setVariable ["debug", _args];
		} else {
			_args = _logic getVariable ["debug", false];
		};
		// FIXME - what is the requirement for STRING input also?
		// Check "typeName" in https://community.bistudio.com/wiki/Arma_3_Module_Framework
		if (typeName _args == "STRING") then {
			if(_args == "true") then {_args = true;} else {_args = false;};
			_logic setVariable ["debug", _args];
		};
		ASSERT_TRUE(typeName _args == "BOOL",str _args);

		_result = _args;
	};
	// Main process
	case "init": {

        //Only one init per instance is allowed
    	if !(isnil {_logic getVariable "initGlobal"}) exitwith {["ALiVE SYS XSTREAM - Only one init process per instance allowed! Exiting..."] call ALiVE_fnc_Dump};

    	//Start init
    	_logic setVariable ["initGlobal", false];

		if (isServer) then {
			// if server, initialise module game logic
			_logic setVariable ["super", SUPERCLASS];
			_logic setVariable ["class", MAINCLASS];
			_logic setVariable ["moduleType", "ALIVE_xStream"];

			// FIXME - can you change startupComplete to initialising
			// and set to true, then set to nil once completed?
			_logic setVariable ["startupComplete", false];

			// Get list of player names that can launch camera
			[_logic, "clientID", _logic getVariable ["clientID", []]] call MAINCLASS;


			// Broadcast logic to clients?
			MOD(sys_xstream) = _logic;
			publicVariable QMOD(sys_xstream);

			// FIXME - potentially move this below the last command to signify
			// init has completed
			TRACE_1("After module init",_logic);

			[_logic, "register"] call MAINCLASS;

			_logic setVariable ["init",true,true];
		};
		 /*
        VIEW - purely visual
        - initialise menu
        - frequent check to modify menu and display status (ALIVE_fnc_xstreamMenuDef)
        */

        TRACE_2("Adding menu",isDedicated,isHC);

        if (!isDedicated && !isHC) then {
                // Initialise interaction key if undefined
                if(isNil "SELF_INTERACTION_KEY") then {SELF_INTERACTION_KEY = [221,[false,false,false]];};

                // if ACE spectator enabled, seto to allow exit
                if(!isNil "ace_fnc_startSpectator") then {ace_sys_spectator_can_exit_spectator = true;};

                TRACE_3("Menu pre-req",SELF_INTERACTION_KEY,ace_fnc_startSpectator,DEFAULT_MAPCLICK);

                // initialise main menu
                [
                        "player",
                        [((["ALiVE", "openMenu"] call cba_fnc_getKeybind) select 5) select 0],
                        -9500,
                        [
                                "call ALIVE_fnc_xstreamMenuDef",
                                "main"
                        ]
                ] call ALiVE_fnc_flexiMenu_Add;
        };

        /*
        CONTROLLER  - coordination
        */

		if(!isDedicated && !isHC) then {
			// Flag to note if camera has been started
			GVAR(cameraStarted) = false;

		};
	};
	case "register": {
		private["_registration","_moduleType"];

		_moduleType = _logic getVariable "moduleType";
		_registration = [_logic, _moduleType, []];

		if(isNil "ALIVE_registry") then {
			ALIVE_registry = [nil, "create"] call ALIVE_fnc_registry;
			[ALIVE_registry, "init"] call ALIVE_fnc_registry;
		};

		[ALIVE_registry, "register", _registration] call ALIVE_fnc_registry;
	};
	case "clientID": {

		if(typeName _args == "STRING") then {
			_args = [_args, " ", ""] call CBA_fnc_replace;
			_args = [_args, ","] call CBA_fnc_split;
			if(count _args > 0) then {
				_logic setVariable [_operation, _args];
			};
		};
		if(typeName _args == "ARRAY") then {
			_logic setVariable [_operation, _args];
		};
		_result = _logic getVariable [_operation, []];
	};
	case "enableTwitch": {
		_result = [_logic,_operation,_args,true] call ALIVE_fnc_OOsimpleOperation;
	};
	case "enableLiveMap": {
		_result = [_logic,_operation,_args,true] call ALIVE_fnc_OOsimpleOperation;
	};
	case "enableCamera": {
		_result = [_logic,_operation,_args,true] call ALIVE_fnc_OOsimpleOperation;
	};
	case "acreChannel": {
		_result = [_logic,_operation,_args,true] call ALIVE_fnc_OOsimpleOperation;
	};
	case "cameraShake": {
		_result = [_logic,_operation,_args,true] call ALIVE_fnc_OOsimpleOperation;
	};
	case "satellite": {
		_result = [_logic,_operation,_args,true] call ALIVE_fnc_OOsimpleOperation;
	};
	case "vehicle": {
		_result = [_logic,_operation,_args,true] call ALIVE_fnc_OOsimpleOperation;
	};
	case "aerial": {
		_result = [_logic,_operation,_args,true] call ALIVE_fnc_OOsimpleOperation;
	};
	case "thirdPerson": {
		_result = [_logic,_operation,_args,true] call ALIVE_fnc_OOsimpleOperation;
	};
	case "cameraManOnly": {
		_result = [_logic,_operation,_args,false] call ALIVE_fnc_OOsimpleOperation;
	};

	/* As a component, I would expect that the spawn process can be started and
	* stopped as required. Personally, I would create an "active"(bool)
	* operation to stop and start the process. I would check for a getVariable
	* at the end of every waitUntil, which can be set remote by a call to
	* active(false).
	*/
	// Main process
	case "start": {
		if (isServer) then {
			_debug = [_logic, "debug"] call MAINCLASS;

			_enableTwitch = [_logic, "enableTwitch"] call MAINCLASS;
			_enableCamera = [_logic, "enableCamera"] call MAINCLASS;
			_enableLiveMap = [_logic, "enableLiveMap"] call MAINCLASS;

			// DEBUG -------------------------------------------------------------------------------------
			if(_debug) then {
				["xStream: Twitch:%1 LiveMap:%2 Camera:%3",_enableTwitch, _enableLiveMap, _enableCamera] call ALIVE_fnc_dump;
			};
			// DEBUG -------------------------------------------------------------------------------------



			_logic setVariable ["startupComplete", true];
		};
	};
	case "startCamera": {
		if !(isDedicated && isHC) then {

			GVAR(cameraStarted) = true;

			[_logic] spawn ALiVE_fnc_camera;

			player setCaptive true;
			player allowDammage false;

		};
	};
	case "stopCamera": {
		if !(isDedicated && isHC) then {

			GVAR(cameraStarted) = false;

			player setCaptive false;
			player allowDammage true;

		};
	};
};

TRACE_1("XSTREAM - output",_result);
_result;
