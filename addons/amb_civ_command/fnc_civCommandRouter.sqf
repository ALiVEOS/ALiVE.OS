#include <\x\alive\addons\amb_civ_command\script_component.hpp>
SCRIPT(civCommandRouter);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
Description:
Command router for agent command system

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
_logic = [nil, "create"] call ALIVE_fnc_civCommandRouter;

(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_civCommandRouter

private ["_logic","_operation","_args","_result"];

TRACE_1("commandRouter - input",_this);

_logic = [_this, 0, objNull, [objNull,[]]] call BIS_fnc_param;
_operation = [_this, 1, "", [""]] call BIS_fnc_param;
_args = [_this, 2, objNull, [objNull,[],"",0,true,false]] call BIS_fnc_param;
_result = true;

#define MTEMPLATE "ALiVE_CIV_COMMAND_ROUTER_%1"

switch(_operation) do {
    case "init": {
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

            private ["_agent","_commands","_agentID","_activeCommand","_commandName",
            "_commandType","_commandArgs","_debug","_commandState","_handle","_isManaging"];

            _agent = _args select 0;
            _commands = _args select 1;

            _agentID = _agent select 2 select 3; //[_agent,"agentID"] call ALIVE_fnc_hashGet;

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
                ["ALiVE Civ Command Router - Activate Command [%1] %2",_agentID,_activeCommand] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------

            // handle various command types
            switch(_commandType) do {
                case "fsm": {
                    // exec the command FSM and store the handle on the internal command states hash
                    _handle = [_agent, _commandArgs, true] execFSM format["\x\alive\addons\amb_civ_command\%1.fsm",_commandName];
                    [_commandState, _agentID, [_handle, _activeCommand]] call ALIVE_fnc_hashSet;
                };
                case "spawn": {
                    // spawn the command script and store the handle on the internal command states hash
                    _handle = [_agent, _commandArgs, true] spawn (call compile _commandName);
                    [_commandState, _agentID, [_handle, _activeCommand]] call ALIVE_fnc_hashSet;
                };
                case "managed": {
                    // add the managed command to the internal command states hash
                    [_commandState, _agentID, [_agent, _activeCommand]] call ALIVE_fnc_hashSet;

                    // if the managed commands loop is not running start it
                    _isManaging = _logic select 2 select 2;
                    if!(_isManaging) then {
                        [_logic,"startManagement"] call MAINCLASS;
                    };
                };
            };

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["ALiVE Civ Command Router - Current Command State:"] call ALIVE_fnc_dump;
                _commandState call ALIVE_fnc_inspectHash;
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------
        };
    };
    case "deactivate": {
        if(typeName _args == "ARRAY") then {

            private ["_agent","_agentID","_debug","_commandState","_activeCommandState",
            "_handle","_activeCommand","_commandName","_commandType","_commandArgs","_isManaging"];

            _agent = _args;

            _agentID = _agent select 2 select 3; //[_logic,"agentID"] call ALIVE_fnc_hashGet;

            _debug = _logic select 2 select 0;
            _commandState = _logic select 2 select 1;

            // does the profile have currently active commands
            if(_agentID in (_commandState select 1)) then {
                _activeCommandState = [_commandState, _agentID] call ALIVE_fnc_hashGet;

                // get the active command vars
                _handle = _activeCommandState select 0;
                _activeCommand = _activeCommandState select 1;
                _commandName = _activeCommand select 0;
                _commandType = _activeCommand select 1;
                _commandArgs = _activeCommand select 2;

                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                    ["ALiVE Civ Command Router - De-activate Command [%1] %2",_agentID,_activeCommand] call ALIVE_fnc_dump;
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
                [_commandState, _agentID] call ALIVE_fnc_hashRem;

                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["ALiVE Civ Command Router - Current Command State:"] call ALIVE_fnc_dump;
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

        private ["_debug","_commandState","_handle","_env"];

        _debug = _logic select 2 select 0;
        _commandState = _logic select 2 select 1;

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            ["ALiVE Command Router - Command Manager Started"] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        _env = call ALIVE_fnc_getEnvironment;

        // spawn the manager thread
        _handle = [_logic, _debug, _commandState] spawn {

            private ["_debug","_commandState","_activeCommand","_agent","_agentID","_commandType","_commandName","_commandArgs","_iterationCount","_nextState","_nextStateArgs"];

            _logic = _this select 0;
            _debug = _this select 1;
            _commandState = _this select 2;
            _iterationCount = 0;

            // start the manager loop
            waituntil {

                if!([_logic, "pause"] call MAINCLASS) then {

                    // get current environment settings
                    _env = call ALIVE_fnc_getEnvironment;

                    // get current global civilian population posture
                    [] call ALIVE_fnc_getGlobalPosture;


                    // for each of the internal commands
                    {
                        _activeCommand = _x;

                        _agent = _activeCommand select 0;
                        _agentID = _agent select 2 select 3; //[_logic,"agentID"] call ALIVE_fnc_hashGet;

                        // DEBUG -------------------------------------------------------------------------------------
                        if(_debug) then {
                            [_agent, "debug", false] call ALIVE_fnc_civilianAgent;
                            [_agent, "position", position (_agent select 2 select 5)] call ALIVE_fnc_civilianAgent;
                            [_agent, "debug", true] call ALIVE_fnc_civilianAgent;
                        };
                        // DEBUG -------------------------------------------------------------------------------------

                        _activeCommand = _activeCommand select 1;
                        _commandType = _activeCommand select 1;

                        /*
                        ["ALiVE Command Router - Active Command: %1",_commandType] call ALIVE_fnc_dump;
                        _activeCommand call ALIVE_fnc_inspectArray;
                        */

                        // if we are a managed command
                        if(_commandType == "managed") then {
                            _commandName = _activeCommand select 0;
                            _commandArgs = _activeCommand select 2;

                            // DEBUG -------------------------------------------------------------------------------------
                            if(_debug) then {
                                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                                ["ALiVE Civ Command Router - Manage Command [%1] %2",_agentID,_activeCommand] call ALIVE_fnc_dump;
                            };
                            // DEBUG -------------------------------------------------------------------------------------

                            // command state set, continue with the command
                            if(count _activeCommand > 3) then {
                                _nextState = _activeCommand select 3;
                                _nextStateArgs = _activeCommand select 4;

                                /*
                                ["ALiVE Command Router - Next State: %1",_nextState] call ALIVE_fnc_dump;
                                ["ALiVE Command Router - Next State Args: %1",_nextStateArgs] call ALIVE_fnc_dump;
                                */

                                // if the managed command has not completed
                                if!(_nextState == "complete") then {

                                    //["ALiVE Command Router - Managed command not completed: %1",_commandName] call ALIVE_fnc_dump;

                                    [_agent, _commandState, _commandName, _nextStateArgs, _nextState, _debug] call (call compile _commandName);
                                }else{

                                    /*
                                    ["ALiVE Command Router - Managed command completed: %1",_commandName] call ALIVE_fnc_dump;
                                    ["ALiVE Command Router - Selecting a new command"] call ALIVE_fnc_dump;
                                    */

                                    [_logic,"deactivate",_agent] call MAINCLASS;

                                    // pick a new command to activate
                                    [_agent, _debug] call ALIVE_fnc_selectCivilianCommand;
                                };
                            } else {
                                // no current command state set, must have just been activated
                                [_agent, _commandState, _commandName, _commandArgs, "init", _debug] call (call compile _commandName);
                            };
                        };

                        sleep 0.2;

                    } forEach (_commandState select 2);

                };

                sleep 5;

                false
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
            ["ALiVE Civ Command Router - Command Manager Stopped"] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------
    };
    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};
TRACE_1("civCommandRouter - output",_result);
_result;