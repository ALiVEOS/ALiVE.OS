#include <\x\alive\addons\mil_command\script_component.hpp>
SCRIPT(commandRouter);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
Description:
Command router for profile command system

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enable, disable or refresh
Boolean - state - Store or restore state of analysis

Examples:
(begin example)
// create the command router
_logic = [nil, "create"] call ALIVE_fnc_commandRouter;

(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_commandRouter

private ["_logic","_operation","_args","_result"];

TRACE_1("commandRouter - input",_this);

_logic = [_this, 0, objNull, [objNull,[]]] call BIS_fnc_param;
_operation = [_this, 1, "", [""]] call BIS_fnc_param;
_args = [_this, 2, objNull, [objNull,[],"",0,true,false]] call BIS_fnc_param;
_result = true;

#define MTEMPLATE "ALiVE_COMMAND_ROUTER_%1"

switch(_operation) do {
        case "init": {                
                /*
                MODEL - no visual just reference data
                - nodes
                - center
                - size
                */
                
                if (isServer) then {
                        // if server, initialise module game logic
						[_logic,"super"] call ALIVE_fnc_hashRem;
						[_logic,"class"] call ALIVE_fnc_hashRem;
                        TRACE_1("After module init",_logic);

						// set defaults
						[_logic,"debug",false] call ALIVE_fnc_hashSet; // select 2 select 0
						[_logic,"commandState",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet; // select 2 select 1
						[_logic,"isManaging",false] call ALIVE_fnc_hashSet; // select 2 select 2
						[_logic,"managerHandle",objNull] call ALIVE_fnc_hashSet; // select 2 select 3
                };
                
                /*
                VIEW - purely visual
                */
                
                /*
                CONTROLLER  - coordination
                */
        };
        case "destroy": {
                
                [_logic, "debug", false] call MAINCLASS;
                if (isServer) then {
                        // if server
						[_logic,"super"] call ALIVE_fnc_hashRem;
						[_logic,"class"] call ALIVE_fnc_hashRem;
                        
                        [_logic, "destroy"] call SUPERCLASS;
                };
                
        };
        case "debug": {
                if(typeName _args != "BOOL") then {
						_args = [_logic,"debug", false] call ALIVE_fnc_hashGet;
                } else {
						[_logic,"debug",_args] call ALIVE_fnc_hashSet;
                };                
                _result = _args;
        };
        case "pause": {
            if(typeName _args != "BOOL") then {
                // if no new value was provided return current setting
                _args = [_logic,"pause",objNull,false] call ALIVE_fnc_OOsimpleOperation;
            } else {
                    // if a new value was provided set groups list
                    ASSERT_TRUE(typeName _args == "BOOL",str typeName _args);

                    private ["_state"];
                    _state = [_logic,"pause",objNull,false] call ALIVE_fnc_OOsimpleOperation;
                    if (_state && _args) exitwith {};

                    //Set value
                    _args = [_logic,"pause",_args,false] call ALIVE_fnc_OOsimpleOperation;
                    ["ALiVE Pausing state of %1 instance set to %2!",QMOD(ADDON),_args] call ALiVE_fnc_DumpR;
            };
            _result = _args;
        };
		case "state": {
				private["_state"];
                
				if(typeName _args != "ARRAY") then {
						
						// Save state
				
                        _state = [] call ALIVE_fnc_hashCreate;
						
						{
							if(!(_x == "super") && !(_x == "class")) then {
								[_state,_x,[_logic,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
							};
						} forEach (_logic select 1);
                       
                        _result = _state;
						
                } else {
						ASSERT_TRUE(typeName _args == "ARRAY",str typeName _args);

                        // Restore state
                        {
							[_logic,_x,[_args,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
						} forEach (_args select 1);
                };
        };
		case "activate": {
				if(typeName _args == "ARRAY") then {
				
					private ["_profile","_commands","_profileID","_activeCommand","_commandName",
					"_commandType","_commandArgs","_debug","_commandState","_handle","_isManaging"];
				
					_profile = _args select 0;
					_commands = _args select 1;
					
					_profileID = _profile select 2 select 4; //[_profile,"profileID"] call ALIVE_fnc_hashGet;
					
					// get the active command vars
					_activeCommand = _commands select 0;
					_commandName = _activeCommand select 0;
					_commandType = _activeCommand select 1;
					_commandArgs = _activeCommand select 2;
					
					_debug = _logic select 2 select 0; //[logic,"debug"] call ALIVE_fnc_hashGet;
					_commandState = _logic select 2 select 1; //[logic,"commandState"] call ALIVE_fnc_hashGet;
					
					// DEBUG -------------------------------------------------------------------------------------
					if(_debug) then {
						["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
						["ALiVE Command Router - Activate Command [%1] %2",_profileID,_activeCommand] call ALIVE_fnc_dump;
					};
					// DEBUG -------------------------------------------------------------------------------------					
					
					// handle various command types
					switch(_commandType) do {
						case "fsm": {
							// exec the command FSM and store the handle on the internal command states hash
							_handle = [_profile, _commandArgs, true] execFSM format["\x\alive\addons\mil_command\%1.fsm",_commandName];
							[_commandState, _profileID, [_handle, _activeCommand]] call ALIVE_fnc_hashSet;
						};
						case "spawn": {
							// spawn the command script and store the handle on the internal command states hash
							_handle = [_profile, _commandArgs, true] spawn (call compile _commandName);
							[_commandState, _profileID, [_handle, _activeCommand]] call ALIVE_fnc_hashSet;
						};
						case "managed": {
							// add the managed command to the internal command states hash
							[_commandState, _profileID, [_profile, _activeCommand]] call ALIVE_fnc_hashSet;
							
							// if the managed commands loop is not running start it
							_isManaging = _logic select 2 select 2;
							if!(_isManaging) then {
								[_logic,"startManagement"] call MAINCLASS;
							};							
						};
					};
					
					// DEBUG -------------------------------------------------------------------------------------
					if(_debug) then {						
						["ALiVE Command Router - Current Command State:"] call ALIVE_fnc_dump;
						_commandState call ALIVE_fnc_inspectHash;
						["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
					};
					// DEBUG -------------------------------------------------------------------------------------					
				};
        };
		case "deactivate": {
				if(typeName _args == "ARRAY") then {
				
					private ["_profile","_profileID","_debug","_commandState","_activeCommandState",
					"_handle","_activeCommand","_commandName","_commandType","_commandArgs","_isManaging"];
				
					_profile = _args;
					
					_profileID = _profile select 2 select 4; //[_logic,"profileID"] call ALIVE_fnc_hashGet;
					
					_debug = _logic select 2 select 0;
					_commandState = _logic select 2 select 1;
					
					// does the profile have currently active commands
					if(_profileID in (_commandState select 1)) then {
						_activeCommandState = [_commandState, _profileID] call ALIVE_fnc_hashGet;
						
						// get the active command vars
						_handle = _activeCommandState select 0;
						_activeCommand = _activeCommandState select 1;
						_commandName = _activeCommand select 0;
						_commandType = _activeCommand select 1;
						_commandArgs = _activeCommand select 2;
						
						// DEBUG -------------------------------------------------------------------------------------
						if(_debug) then {
							["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
							["ALiVE Command Router - De-activate Command [%1] %2",_profileID,_activeCommand] call ALIVE_fnc_dump;
						};
						// DEBUG -------------------------------------------------------------------------------------
						
						// handle various command types
						switch(_commandType) do {
							// destroy the FSM command
							case "fsm": {
								if!(completedFSM _handle) then {
									_handle setFSMVariable ["_destroy",true];
								};
							};
							// destroy the spawned script command
							case "spawn": {
								if!(scriptDone _handle) then {
									terminate _handle;
								};
							};
						};
						
						// clear the profiles command state
						[_commandState, _profileID] call ALIVE_fnc_hashRem;
						
						// DEBUG -------------------------------------------------------------------------------------
						if(_debug) then {							
							["ALiVE Command Router - Current Command State:"] call ALIVE_fnc_dump;
							_commandState call ALIVE_fnc_inspectHash;
							["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
						};
						// DEBUG -------------------------------------------------------------------------------------

						// if there are no active commands shut down the 
						// management loop if it is running
						if(count (_commandState select 1) == 0) then {
							_isManaging = _logic select 2 select 2;
							if(_isManaging) then {
								[_logic,"stopManagement"] call MAINCLASS;
							};
						};					
					};
				};
        };
		case "startManagement": {
		
			private ["_debug","_commandState","_handle"];
		
			_debug = _logic select 2 select 0;
			_commandState = _logic select 2 select 1;
			
			// DEBUG -------------------------------------------------------------------------------------
			if(_debug) then {
				["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
				["ALiVE Command Router - Command Manager Started"] call ALIVE_fnc_dump;
			};
			// DEBUG -------------------------------------------------------------------------------------
			
			// spawn the manager thread
			_handle = [_logic, _debug, _commandState] spawn {
			
				private ["_debug","_commandState","_activeCommand","_profile","_profileID","_commandType","_commandName","_commandArgs","_nextState","_nextStateArgs"];
			
				_logic = _this select 0;
				_debug = _this select 1;
				_commandState = _this select 2;
			
				// start the manager loop
				waituntil {

				    if !([_logic, "pause"] call ALiVE_fnc_HashGet) then {
					
                        // for each of the internal commands
                        {
                            _activeCommand = _x;

                            _profile = _activeCommand select 0;

                            if(typeName _profile == "ARRAY") then {

                                _profileID = _profile select 2 select 4; //[_logic,"profileID"] call ALIVE_fnc_hashGet;

                                _activeCommand = _activeCommand select 1;
                                _commandType = _activeCommand select 1;

                                // if we are a managed command
                                if(_commandType == "managed") then {
                                    _commandName = _activeCommand select 0;
                                    _commandArgs = _activeCommand select 2;

                                    // DEBUG -------------------------------------------------------------------------------------
                                    if(_debug) then {
                                        ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                                        ["ALiVE Command Router - Manage Command [%1] %2",_profileID,_activeCommand] call ALIVE_fnc_dump;
                                    };
                                    // DEBUG -------------------------------------------------------------------------------------

                                    // command state set, continue with the command
                                    if(count _activeCommand > 3) then {
                                        _nextState = _activeCommand select 3;
                                        _nextStateArgs = _activeCommand select 4;

                                        // if the managed command has not completed
                                        if!(_nextState == "complete") then {
                                            [_profile, _commandState, _commandName, _nextStateArgs, _nextState, true] call (call compile _commandName);
                                        }else{
                                            [_logic,"deactivate",_profile] call MAINCLASS;
                                        };
                                    } else {
                                        // no current command state set, must have just been activated
                                        [_profile, _commandState, _commandName, _commandArgs, "init", true] call (call compile _commandName);
                                    };
                                };
                            };
                        } forEach (_commandState select 2);

                    };
					
					sleep 5;
                    
					//Exit if _logic has been destroyed
					isnil "_logic" || {count (_logic select 1) == 0}
				};				
			};
			
			[_logic,"isManaging",true] call ALIVE_fnc_hashSet;
			[_logic,"managerHandle",_handle] call ALIVE_fnc_hashSet;
		
		};
		case "stopManagement": {
		
			private ["_debug","_handle"];
		
			_debug = _logic select 2 select 0;
			_handle = _logic select 2 select 3;
			
			if!(scriptDone _handle) then {
				terminate _handle;
			};
			
			[_logic,"isManaging",false] call ALIVE_fnc_hashSet;
			[_logic,"managerHandle",objNull] call ALIVE_fnc_hashSet;
			
			// DEBUG -------------------------------------------------------------------------------------
			if(_debug) then {
				["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
				["ALiVE Command Router - Command Manager Stopped"] call ALIVE_fnc_dump;
			};
			// DEBUG -------------------------------------------------------------------------------------
		};		
        default {
                _result = [_logic, _operation, _args] call SUPERCLASS;
        };
};
TRACE_1("commandRouter - output",_result);
_result;