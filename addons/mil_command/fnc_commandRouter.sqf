#include "\x\alive\addons\mil_command\script_component.hpp"
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

TRACE_1("commandRouter - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

private _result = true;

#define MTEMPLATE "ALiVE_COMMAND_ROUTER_%1"

switch(_operation) do {

    case "init": {
        if (isServer) then {
            [_logic,"super"] call ALIVE_fnc_hashRem;
            [_logic,"class"] call ALIVE_fnc_hashRem;
            
            TRACE_1("After module init",_logic);

            [_logic,"debug",false] call ALIVE_fnc_hashSet; // select 2 select 0
            [_logic,"commandState",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet; // select 2 select 1
            [_logic,"isManaging",false] call ALIVE_fnc_hashSet; // select 2 select 2
            [_logic,"managerHandle",scriptNull] call ALIVE_fnc_hashSet; // select 2 select 3
        };
    };

    case "destroy": {
        [_logic, "debug", false] call MAINCLASS;

        if (isServer) then {
            [_logic,"super"] call ALIVE_fnc_hashRem;
            [_logic,"class"] call ALIVE_fnc_hashRem;

            [_logic, "destroy"] call SUPERCLASS;
        };
    };

    case "debug": {
        if !(_args isEqualType true) then {
            _args = [_logic,"debug", false] call ALIVE_fnc_hashGet;
        } else {
            [_logic,"debug", _args] call ALIVE_fnc_hashSet;
        };

        _result = _args;
    };

    case "pause": {
        if !(_args isequaltype true) then {
            _args = [_logic,"pause", false] call ALiVE_fnc_hashGet;
        } else {
            [_logic,"pause", _args] call ALiVE_fnc_hashSet;

            private _debug = [_logic,"debug", false] call ALiVE_fnc_hashGet;
            if (_debug) then {
                ["Pausing state of %1 instance set to %2!",QMOD(ADDON),_args] call ALiVE_fnc_dumpR;
            };
        };

        _result = _args;
    };

    case "activate": {
        if (_args isequaltype []) then {
            _args params ["_profile","_commands"];

            private _profileID = _profile select 2 select 4; //[_profile,"profileID"] call ALIVE_fnc_hashGet;
            private _activeCommand = _commands select 0;

            _activeCommand params ["_commandName","_commandType","_commandArgs"];

            private _debug = _logic select 2 select 0; //[logic,"debug"] call ALIVE_fnc_hashGet;
            private _commandState = _logic select 2 select 1; //[logic,"commandState"] call ALIVE_fnc_hashGet;

            if (_debug) then {
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                ["Command Router - Activate Command [%1] %2", _profileID, _activeCommand] call ALiVE_fnc_dump;
            };

            switch(_commandType) do {
                case "fsm": {
                    private _handle = [_profile, _commandArgs, true] execFSM format ["\x\alive\addons\mil_command\%1.fsm", _commandName];
                    [_commandState, _profileID, [_handle, _activeCommand]] call ALIVE_fnc_hashSet;
                };
                case "spawn": {
                    private _handle = [_profile, _commandArgs, true] spawn (call compile _commandName);
                    [_commandState, _profileID, [_handle, _activeCommand]] call ALIVE_fnc_hashSet;
                };
                case "managed": {
                    [_commandState, _profileID, [_profile, _activeCommand]] call ALIVE_fnc_hashSet;

                    private _isManaging = _logic select 2 select 2;
                    if (!_isManaging) then {
                        [_logic,"startManagement"] call MAINCLASS;
                    };
                };
            };

            if (_debug) then {
                ["Command Router - Current Command State:"] call ALiVE_fnc_dump;
                _commandState call ALIVE_fnc_inspectHash;
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            };
        };
    };

    case "deactivate": {
        if (_args isequaltype []) then {
            private _profile = _args;

            private _profileID = _profile select 2 select 4; //[_logic,"profileID"] call ALIVE_fnc_hashGet;

            private _debug = _logic select 2 select 0;
            private _commandState = _logic select 2 select 1;

            if (_profileID in (_commandState select 1)) then {
                private _activeCommandState = [_commandState, _profileID] call ALIVE_fnc_hashGet;

                // get the active command vars
                _activeCommandState params ["_handle","_activeCommand"];

                _activeCommand params ["_commandName","_commandType","_commandArgs"];

                if(_debug) then {
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                    ["Command Router - De-activate Command [%1] %2", _profileID, _activeCommand] call ALiVE_fnc_dump;
                };

                switch(_commandType) do {
                    case "fsm": {
                        if !(completedFSM _handle) then {
                            _handle setFSMVariable ["_destroy", true];
                        };
                    };
                    case "spawn": {
                        if !(scriptDone _handle) then {
                            terminate _handle;
                        };
                    };
                };

                [_commandState, _profileID] call ALIVE_fnc_hashRem;

                if (_debug) then {
                    ["Command Router - Current Command State:"] call ALiVE_fnc_dump;
                    _commandState call ALIVE_fnc_inspectHash;
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                };

                if (count (_commandState select 1) == 0) then {
                    private _isManaging = _logic select 2 select 2;
                    if (_isManaging) then {
                        [_logic,"stopManagement"] call MAINCLASS;
                    };
                };
            };
        };
    };

    case "startManagement": {
        private _debug = _logic select 2 select 0;
        private _commandState = _logic select 2 select 1;

        if (_debug) then {
            ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            ["Command Router - Command Manager Started"] call ALiVE_fnc_dump;
        };

        private _handle = [_logic, _debug, _commandState] spawn {
            params ["_logic","_debug","_commandState"];

            waituntil {
                if !([_logic, "pause"] call ALiVE_fnc_HashGet) then {

                    {
                        private _activeCommand = _x;

                        private _profile = _activeCommand select 0;
                        if (_profile isequaltype []) then {
                            private _profileID = _profile select 2 select 4; //[_logic,"profileID"] call ALIVE_fnc_hashGet;

                            _activeCommand = _activeCommand select 1;

                            private _commandName = _activeCommand select 0;
                            private _commandArgs = _activeCommand select 2;

                            if (_debug) then {
                                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                                ["Command Router - Manage Command [%1] %2",_profileID,_activeCommand] call ALiVE_fnc_dump;
                            };

                            if (count _activeCommand > 3) then {
                                // command has already been initialized
                                private _nextState = _activeCommand select 3;
                                private _nextStateArgs = _activeCommand select 4;

                                if (_nextState != "complete") then {
                                    [_profile, _commandState, _commandName, _nextStateArgs, _nextState, true] call (call compile _commandName);
                                } else {
                                    [_logic,"deactivate", _profile] call MAINCLASS;
                                };
                            } else {
                                // no current command state set, must have just been activated
                                [_profile, _commandState, _commandName, _commandArgs, "init", true] call (call compile _commandName);
                            };
                        };
                    } forEach (_commandState select 2);

                };

                sleep 5;

                isnil "_logic" || {count (_logic select 1) == 0}
            };
        };

        [_logic,"isManaging",true] call ALIVE_fnc_hashSet;
        [_logic,"managerHandle",_handle] call ALIVE_fnc_hashSet;

    };

    case "stopManagement": {
        private _debug = [_logic,"debug",false] call ALIVE_fnc_hashGet;
        private _handle = [_logic,"managerHandle",scriptNull] call ALIVE_fnc_hashGet;

        if (!isNull _handle) then {
            terminate _handle;
        };

        [_logic,"isManaging", false] call ALIVE_fnc_hashSet;
        [_logic,"managerHandle", scriptNull] call ALIVE_fnc_hashSet;

        if (_debug) then {
            ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            ["Command Router - Command Manager Stopped"] call ALiVE_fnc_dump;
        };
    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};

TRACE_1("commandRouter - output",_result);

_result;