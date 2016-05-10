//#define DEBUG_MODE_FULL
#include <\x\alive\addons\sys_GC\script_component.hpp>
SCRIPT(GC);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_GC
Description:
Garbage Collector

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enable, disable or refresh
init
start

Examples:
(begin example)
// create OPCOM objectives of SEP (ingame object for now) objectives and distance
[_logic, "start"] call ALIVE_fnc_GC;
(end)

See Also:

Author:
BIS
Highhead

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_GC

private ["_logic","_operation","_args","_result"];

TRACE_1("GC - input",_this);

_logic = [_this, 0, objNull, [objNull,[]]] call BIS_fnc_param;
_operation = [_this, 1, "", [""]] call BIS_fnc_param;
_args = [_this, 2, objNull,[objNull,grpNull,[],"",0,true,false]] call BIS_fnc_param;
_result = nil;

#define MTEMPLATE "ALiVE_GC_%1"

switch(_operation) do {

    	case "create": {
            if (isServer) then {

	            // Ensure only one module is used
	            if !(isNil QMOD(SYS_GC)) then {
                	_logic = MOD(SYS_GC);
                    ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_GC_ERROR1");
	            } else {
	        		_logic = (createGroup sideLogic) createUnit [QMOD(SYS_GC), [0,0], [], 0, "NONE"];
                    MOD(SYS_GC) = _logic;
                };

                //Push to clients
	            PublicVariable QMOD(SYS_GC);
            };

            TRACE_1("Waiting for object to be ready",true);

            waituntil {!isnil QMOD(SYS_GC)};

            TRACE_1("Creating class on all localities",true);

			// initialise module game logic on all localities
			MOD(SYS_GC) setVariable ["super", QUOTE(SUPERCLASS)];
			MOD(SYS_GC) setVariable ["class", QUOTE(MAINCLASS)];

            _result = MOD(SYS_GC);
        };
        // Main process
		case "init": {
			if (isServer) then {
				// if server, initialise module game logic
				_logic setVariable ["super", SUPERCLASS];
				_logic setVariable ["class", MAINCLASS];

                //Registering disabled for now
				_logic setVariable ["moduleType", "ALIVE_GC"];
				_logic setVariable ["startupComplete", false];
				TRACE_1("After module init",_logic);

                //Start GC
                [_logic,"start"] call MAINCLASS;

			};
            _logic setVariable ["bis_fnc_initModules_activate",true];
		};
		case "start": {
                /*
                MODEL - no visual just reference data
                - nodes
                - center
                - size
                */

                if (isServer) then {
                    //identify Garbage Collector
                    ALiVE_GC = _logic;
                    //transmit to clients
                    Publicvariable "ALiVE_GC";

                    //Delay for ALiVE require init to be able to set variables
                    sleep 2;

					//Retrieve module-object variables
                    _logic setvariable ["ALiVE_GC_INDIVIDUALTYPES",([_logic,"convert",(_logic getvariable ["ALiVE_GC_INDIVIDUALTYPES",[]])] call ALiVE_fnc_GC),true];
                    _debug = _logic getvariable ["debug","false"];
                    _interval = _logic getvariable ["ALiVE_GC_INTERVAL","300"];

                    switch (typeName _debug) do {
                        case ("STRING") : {_debug = call compile _debug};
                        case ("BOOL") : {};
                    };

                    switch (typeName _interval) do {
                        case ("STRING") : {_interval = call compile _interval};
                        case ("BOOL") : {};
                    };

                    _logic setvariable ["debug",_debug,true];
					_logic setVariable ["auto", true];

                    /*
                	CONTROLLER  - coordination
                	*/

                    if (_interval < 1) exitwith {
						// DEBUG -------------------------------------------------------------------------------------
							if(_debug) then {
								["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
								["ALiVE Garbage Collector turned off..."] call ALIVE_fnc_dumpR;
							};
						// DEBUG -------------------------------------------------------------------------------------
                    };

					// DEBUG -------------------------------------------------------------------------------------
						if(_debug) then {
							["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
							["ALIVE Garbage Collector starting..."] call ALIVE_fnc_dumpR;
						};
					// DEBUG -------------------------------------------------------------------------------------

                    _fsm = _logic execfsm "\x\alive\addons\sys_GC\garbagecollector.fsm";
                    _logic setVariable ["ALiVE_GC_FSM", _fsm];

                    // set module as startup complete
                    _logic setVariable ["startupComplete",true];

				};

                /*
                VIEW - purely visual
                */
        };
        case "destroy": {

        	MOD(SYS_GC) = _logic;

            //Delete class
            if (isServer) then {

                _logic setVariable ["super", nil];
                _logic setVariable ["class", nil];
                _logic setVariable ["init", nil];

                _fsm = _logic getVariable "ALiVE_GC_FSM";
                _fsm setFSMVariable ["_exitFSM", true];

                ALiVE_SYS_GC = nil;
                ALiVE_GC = nil;

                // and publicVariable to clients
                publicVariable "ALiVE_SYS_GC";
                publicVariable "ALiVE_GC";

                deleteVehicle _logic;
                deleteGroup (group _logic);
            };
        };

        case "convert": {
	    	if !(isNil "_args") then {
				if(typeName _args == "STRING") then {
		            if !(_args == "") then {
						_args = [_args, " ", ""] call CBA_fnc_replace;
	                    _args = [_args, "[", ""] call CBA_fnc_replace;
	                    _args = [_args, "]", ""] call CBA_fnc_replace;
	                    _args = [_args, """", ""] call CBA_fnc_replace;
						_args = [_args, ","] call CBA_fnc_split;

						if !(count _args > 0) then {
							_args = [];
		            	};
                    } else {
                        _args = [];
                    };
                };
            };
            _result = _args;
		};

        case "collect": {
        private ["_queue"];

	        _individual = _logic getvariable ["ALiVE_GC_INDIVIDUALTYPES",[]];
            _debug = _logic getvariable ["debug",false];
            _queue = _logic getVariable ["queue",[]];
            _dead = +allDead;

            _time = time;
            _ObjectsToTrash = _dead - _queue;

            // DEBUG -------------------------------------------------------------------------------------
				if(_debug) then {
					["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
					["ALIVE Garbage Collector started collecting at %1...",_time] call ALIVE_fnc_dumpR;
				};
			// DEBUG -------------------------------------------------------------------------------------

			{
                if (!(_x in synchronizedObjects _logic) && {!(_x getvariable [QGVAR(IGNORE),false])}) then {
                	[_logic,"trashIt",_x] call ALiVE_fnc_GC;
                    sleep 0.03;
                };
			} forEach _ObjectsToTrash;

			{
				if ((count units _x == 0) && {!(_x in _queue)}) then {
                    [_logic,"trashIt",_x] call ALiVE_fnc_GC;
                    sleep 0.03;
				};
			} foreach allGroups;

			if ((count _individual) > 0) then {
			    _amo = (allmissionObjects ""); _amo = +_amo;
				{
					if (((typeof _x) in _individual) && {!(_x in _queue)}) then {
                        [_logic,"trashIt",_x] call ALiVE_fnc_GC;
                        sleep 0.03;
					};
				} foreach _amo;
			};

            // DEBUG -------------------------------------------------------------------------------------
				if(_debug) then {
					["ALIVE Garbage Collector collection finished at %1! Time taken %2...",_time,(time - _time)] call ALIVE_fnc_dumpR;
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
				};
			// DEBUG -------------------------------------------------------------------------------------
        };

        case "trashIt": {
	        if (isNil "_args") exitWith {debugLog "Log: [trashIt] There should be 1 mandatory parameter!"; false};

			private ["_object", "_queue", "_timeToDie"];
			_object = _args;
            _debug = _logic getvariable ["debug",false];
			_queue = _logic getVariable ["queue",[]];

            if ((isnil "_object") || {isnull _object}) exitwith {};

			switch (typeName _object) do
			{
				case (typeName objNull):
				{
					if (alive _object) then
					{
						_timeToDie = time + 30;
					}
					else
					{
						_timeToDie = time + 60;
					};
				};

				case (typeName grpNull):
				{
					_timeToDie = time + 60;
				};

				default
				{
					_timeToDie = time;
				};
			};
            // DEBUG -------------------------------------------------------------------------------------
				if(_debug) then {
					["ALIVE GC trashed %1! Time to die %2...",_object,_timeToDie] call ALIVE_fnc_dumpR;
				};
			// DEBUG -------------------------------------------------------------------------------------

            _object setvariable ["timeToDie",_timeToDie];
			_queue set [count _queue,_object];

			_logic setVariable ["queue", _queue];
        };

        case "process": {
            if (isnil "_args") then {_args = false};

            _instant = _args;
			_queue = _logic getVariable ["queue",[]];
            _debug = _logic getvariable ["debug",false];
            _timeCheck = time;

            // DEBUG -------------------------------------------------------------------------------------
				if(_debug) then {
					["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
					["ALIVE Garbage Collector deletion started at %1 for %2 objects...",_timeCheck,(count _queue)] call ALIVE_fnc_dumpR;
				};
			// DEBUG -------------------------------------------------------------------------------------

			{
				private ["_object", "_time"];

				_object = _x;

                if (!(isnil "_object") && {!(isnull _object)}) then {

                    _time = _object getvariable ["timeToDie",0];

					//Check the object was in the queue for at least the assigned time (expiry date).
	                //If instant parameter is set to true, then it will be directly deleted
					if ((_time <= time) || {_instant}) then {

						switch (typeName _object) do {
							case (typeName objNull):
							{
								//Player and his squadmates cannot be too close.
								//ToDo: use 'cameraOn' as well?
								if ((({(_x distance _object) <= 1700} count ([] call BIS_fnc_listPlayers)) == 0) || {_instant}) then
								{
									deleteVehicle _object;
	                                _queue set [_foreachIndex, -1];
								};
							};

							case (typeName grpNull):
							{
								//Make sure the group is empty.
								if (({alive _x} count (units _object)) == 0) then
								{
									_object call ALiVE_fnc_DeleteGroupRemote;
	                                _queue set [_foreachIndex, -1];
								};
							};

							default {};
						};
					};
                } else {
                	_queue set [_foreachIndex, -1];
                };
			} forEach _queue;

            _queue = _queue - [-1];
            _logic setVariable ["queue", _queue];

    		// DEBUG -------------------------------------------------------------------------------------
				if(_debug) then {
					["ALIVE Garbage Collector deletion processed at %1! Time taken: %2! Objects left in queue: %3",_timeCheck,(time - _timeCheck),(count _queue)] call ALIVE_fnc_dumpR;
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
				};
			// DEBUG -------------------------------------------------------------------------------------
        };
        case "debug": {
                if(typeName _args != "BOOL") then {
						_args = [_logic,"debug"] call ALIVE_fnc_hashGet;
                } else {
						[_logic,"debug",_args] call ALIVE_fnc_hashSet;
                };
                ASSERT_TRUE(typeName _args == "BOOL",str _args);

                _result = _args;
        };

		case "state": {
				private["_state"];

				if(typeName _args != "ARRAY") then {

						// Save state

                        _state = [] call ALIVE_fnc_hashCreate;

						// BaseClassHash CHANGE
						// loop the class hash and set vars on the state hash
						{
							if(!(_x == "super") && !(_x == "class")) then {
								[_state,_x,[_logic,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
							};
						} forEach (_logic select 1);

                        _result = _state;

                } else {
						ASSERT_TRUE(typeName _args == "ARRAY",str typeName _args);

                        // Restore state

						// BaseClassHash CHANGE
						// loop the passed hash and set vars on the class hash
                        {
							[_logic,_x,[_args,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
						} forEach (_args select 1);
                };
        };
        default {
                _result = [_logic, _operation, _args] call SUPERCLASS;
        };
};
TRACE_1("GC - output",_result);
if !(isnil "_result") then {_result} else {nil};