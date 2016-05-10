#include <\x\alive\addons\amb_civ_command\script_component.hpp>
SCRIPT(selectCivilianCommand);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_selectCivilianCommand

Description:
Select the initial or next civilian command for an agent

Parameters:
Array - agent

Returns:

Examples:
(begin example)
//
_result = [_agent] call ALIVE_fnc_selectCivilianCommand;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_agentData","_debug","_agent","_dayState","_dayCommand","_eveningCommand","_nightCommand",
"_idleCommand","_commandName","_command","_probability","_timeProbability","_diceRoll","_args",
"_agentCluster","_clusterHostilityLevel","_agentID"];

_agentData = _this select 0;
_debug = if(count _this > 1) then {_this select 1} else {false};

_agent = _agentData select 2 select 5;
_dayState = ALIVE_currentEnvironment select 0;

// set initial fall back commands

_dayCommand = "randomMovement";
_eveningCommand = "housework";
_nightCommand = "sleep";
_idleCommand = "idle";


// setup all possible commands available to agents

if(isNil "ALIVE_civCommands") then {

    ALIVE_civCommands = [] call ALIVE_fnc_hashCreate;

    [ALIVE_civCommands, "idle", ["ALIVE_fnc_cc_idle", "managed", [0.1,0.1,0.1], [10,30]]] call ALIVE_fnc_hashSet;
    [ALIVE_civCommands, "randomMovement", ["ALIVE_fnc_cc_randomMovement", "managed", [0.35,0.01,0.01], [100]]] call ALIVE_fnc_hashSet;
    [ALIVE_civCommands, "journey", ["ALIVE_fnc_cc_journey", "managed", [0.2,0.5,0.2], []]] call ALIVE_fnc_hashSet;
    [ALIVE_civCommands, "housework", ["ALIVE_fnc_cc_housework", "managed", [0.25,0.5,0.2], []]] call ALIVE_fnc_hashSet;
    [ALIVE_civCommands, "sleep", ["ALIVE_fnc_cc_sleep", "managed", [0,0.1,0.9], [300,1000]]] call ALIVE_fnc_hashSet;
    [ALIVE_civCommands, "campfire", ["ALIVE_fnc_cc_campfire", "managed", [0,0.25,0.3], [60,300]]] call ALIVE_fnc_hashSet;
    [ALIVE_civCommands, "observe", ["ALIVE_fnc_cc_observe", "managed", [0.2,0.15,0.2], [30,90]]] call ALIVE_fnc_hashSet;
    [ALIVE_civCommands, "suicide", ["ALIVE_fnc_cc_suicide", "managed", [0.1,0.1,0.1], [30,90]]] call ALIVE_fnc_hashSet;
    [ALIVE_civCommands, "rogue", ["ALIVE_fnc_cc_rogue", "managed", [0.1,0.1,0.1], [30,90]]] call ALIVE_fnc_hashSet;
    [ALIVE_civCommands, "startMeeting", ["ALIVE_fnc_cc_startMeeting", "managed", [0.2,0.1,0.01], []]] call ALIVE_fnc_hashSet;
    [ALIVE_civCommands, "startGathering", ["ALIVE_fnc_cc_startGathering", "managed", [0.1,0.01,0], [30,90]]] call ALIVE_fnc_hashSet;

    // set available commands
    ALIVE_availableCivCommands = ["journey","housework","campfire","observe","suicide","rogue","startMeeting","startGathering"];
};

// if an agent has been requested for a meeting join the meeting initiator

if(_agent getVariable ["ALIVE_agentMeetingRequested",false]) exitWith {
    [_agentData, "setActiveCommand", ["ALIVE_fnc_cc_joinMeeting", "managed",[30,90]]] call ALIVE_fnc_civilianAgent;
};

// if an agent has been requested for a gathering join the gathering initiator

if(_agent getVariable ["ALIVE_agentGatheringRequested",false]) exitWith {
    [_agentData, "setActiveCommand", ["ALIVE_fnc_cc_joinGathering", "managed",[]]] call ALIVE_fnc_civilianAgent;
};

// there are commands available

if(count (ALIVE_civCommands select 1) > 0) then {

    // check global posture adjust command probability accordingly

    _agentCluster = [ALIVE_clusterHandler, "getCluster", _agentData select 2 select 9] call ALIVE_fnc_clusterHandler;
    _clusterHostilityLevel = [_agentCluster, "posture", 0] call ALIVE_fnc_hashGet;
    [_agentData, "posture", _clusterHostilityLevel] call ALIVE_fnc_hashSet;
    _agent setVariable ["posture", _clusterHostilityLevel];

	//_clusterHostilityLevel = 3;
	//["CLUSTER HOSTILITY: %1",_clusterHostilityLevel] call ALIVE_fnc_dumpR;

	if(_clusterHostilityLevel < 10) then {
	    [ALIVE_civCommands, "suicide", ["ALIVE_fnc_cc_suicide", "managed", [0.05,0.05,0.05], [30,90]]] call ALIVE_fnc_hashSet;
        [ALIVE_civCommands, "rogue", ["ALIVE_fnc_cc_rogue", "managed", [0.05,0.05,0.05], [30,90]]] call ALIVE_fnc_hashSet;
        [ALIVE_civCommands, "observe", ["ALIVE_fnc_cc_observe", "managed", [0.1,0.05,0.1], [30,90]]] call ALIVE_fnc_hashSet;
        _dayCommand = "randomMovement";
        _idleCommand = "idle";
        ALIVE_availableCivCommands = ["journey","housework","campfire","observe","suicide","rogue","startMeeting","startGathering"];
	};

	if(_clusterHostilityLevel >= 10 && {_clusterHostilityLevel < 40}) then {
        [ALIVE_civCommands, "suicide", ["ALIVE_fnc_cc_suicide", "managed", [0.1,0.1,0.1], [30,90]]] call ALIVE_fnc_hashSet;
        [ALIVE_civCommands, "rogue", ["ALIVE_fnc_cc_rogue", "managed", [0.2,0.2,0.2], [30,90]]] call ALIVE_fnc_hashSet;
        [ALIVE_civCommands, "observe", ["ALIVE_fnc_cc_observe", "managed", [0.5,0.5,0.5], [30,90]]] call ALIVE_fnc_hashSet;
        _dayCommand = "randomMovement";
        _idleCommand = "idle";
        ALIVE_availableCivCommands = ["journey","housework","campfire","observe","suicide","rogue","startMeeting","startGathering"];
    };

    if(_clusterHostilityLevel >= 40 && {_clusterHostilityLevel < 70}) then {
        [ALIVE_civCommands, "suicide", ["ALIVE_fnc_cc_suicide", "managed", [0.3,0.3,0.3], [30,90]]] call ALIVE_fnc_hashSet;
        [ALIVE_civCommands, "rogue", ["ALIVE_fnc_cc_rogue", "managed", [0.4,0.4,0.4], [30,90]]] call ALIVE_fnc_hashSet;
        [ALIVE_civCommands, "observe", ["ALIVE_fnc_cc_observe", "managed", [0.5,0.5,0.5], [30,90]]] call ALIVE_fnc_hashSet;
        _dayCommand = "randomMovement";
        _idleCommand = "idle";
        ALIVE_availableCivCommands = ["journey","housework","sleep","observe","suicide","rogue","startGathering"];
    };

    if(_clusterHostilityLevel >= 70 && {_clusterHostilityLevel < 100}) then {
        [ALIVE_civCommands, "suicide", ["ALIVE_fnc_cc_suicide", "managed", [0.4,0.4,0.4], [30,90]]] call ALIVE_fnc_hashSet;
        [ALIVE_civCommands, "rogue", ["ALIVE_fnc_cc_rogue", "managed", [0.5,0.5,0.5], [30,90]]] call ALIVE_fnc_hashSet;
        [ALIVE_civCommands, "observe", ["ALIVE_fnc_cc_observe", "managed", [0.7,0.7,0.7], [30,90]]] call ALIVE_fnc_hashSet;
        _dayCommand = "randomMovement";
        _idleCommand = "idle";
        ALIVE_availableCivCommands = ["journey","housework","sleep","observe","suicide","rogue"];
    };

    if(_clusterHostilityLevel >= 100) then {
        [ALIVE_civCommands, "suicide", ["ALIVE_fnc_cc_suicide", "managed", [0.5,0.5,0.5], [30,90]]] call ALIVE_fnc_hashSet;
        [ALIVE_civCommands, "rogue", ["ALIVE_fnc_cc_rogue", "managed", [0.7,0.7,0.7], [30,90]]] call ALIVE_fnc_hashSet;
        [ALIVE_civCommands, "observe", ["ALIVE_fnc_cc_observe", "managed", [0.8,0.8,0.8], [30,90]]] call ALIVE_fnc_hashSet;
        _dayCommand = "randomMovement";
        _idleCommand = "idle";
        ALIVE_availableCivCommands = ["journey","housework","sleep","observe","suicide","rogue"];
    };

    // select a random command
    _commandName = ALIVE_availableCivCommands call BIS_fnc_selectRandom;
    _command = [ALIVE_civCommands, _commandName] call ALIVE_fnc_hashGet;

    // get the probability for the command for the current time of day
    _probability = _command select 2;

    switch(_dayState) do {
        case "DAY": {
            _timeProbability = _probability select 0;
        };
        case "EVENING": {
            _timeProbability = _probability select 1;
        };
        case "NIGHT": {
            _timeProbability = _probability select 2;
        };
    };

    // roll the probability dice

    _diceRoll = random 1;


    // DEBUG -------------------------------------------------------------------------------------
    if(_debug) then {
        _agentID = _agentData select 2 select 3;
        ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
        ["ALIVE Select Civilian Command [%1]", _agentID] call ALIVE_fnc_dump;
        ["ALIVE Select Civilian Command - Time of day: %1", _dayState] call ALIVE_fnc_dump;
        ["ALIVE Select Civilian Command - Dice roll: %1 Current Probability: %2 Command: %3", _diceRoll, _timeProbability, _command select 0] call ALIVE_fnc_dump;
    };
    // DEBUG -------------------------------------------------------------------------------------


    // random command dice roll success run the random command

    if(_diceRoll < _timeProbability) then {
        _args = + _command select 3;
        [_agentData, "setActiveCommand", [_command select 0, _command select 1,_args]] call ALIVE_fnc_civilianAgent;
    }else{

        // random command dice roll failed

        if(random 1 > 0.7) then {

            // secondary dice roll succeeded pick a time appropriate command

            switch(_dayState) do {
                case "DAY": {
                    _command = [ALIVE_civCommands, _dayCommand] call ALIVE_fnc_hashGet;
                };
                case "EVENING": {
                    _command = [ALIVE_civCommands, _eveningCommand] call ALIVE_fnc_hashGet;
                };
                case "NIGHT": {
                    _command = [ALIVE_civCommands, _nightCommand] call ALIVE_fnc_hashGet;
                };
            };
            _args = + _command select 3;
            [_agentData, "setActiveCommand", [_command select 0, _command select 1,_args]] call ALIVE_fnc_civilianAgent;
        }else{

            // secondary dice roll failed fall back to idle state

            _command = [ALIVE_civCommands, _idleCommand] call ALIVE_fnc_hashGet;
            _args = + _command select 3;
            [_agentData, "setActiveCommand", [_command select 0, _command select 1,_args]] call ALIVE_fnc_civilianAgent;
        };
    }
};