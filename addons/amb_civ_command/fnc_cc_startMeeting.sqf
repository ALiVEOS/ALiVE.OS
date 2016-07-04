#include <\x\alive\addons\amb_civ_command\script_component.hpp>
SCRIPT(cc_startMeeting);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_cc_startMeeting

Description:
Start meeting command for civilians

Parameters:
Profile - profile
Args - array

Returns:

Examples:
(begin example)
//
_result = [_agent, []] call ALIVE_fnc_cc_startMeeting;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_agentData","_commandState","_commandName","_args","_state","_debug","_agentID","_agent","_nextState","_nextStateArgs"];

_agentData = _this select 0;
_commandState = _this select 1;
_commandName = _this select 2;
_args = _this select 3;
_state = _this select 4;
_debug = _this select 5;

_agentID = _agentData select 2 select 3;
_agent = _agentData select 2 select 5;

_nextState = _state;
_nextStateArgs = [];


// DEBUG -------------------------------------------------------------------------------------
if(_debug) then {
    ["ALiVE Managed Script Command - [%1] called args: %2",_agentID,_args] call ALIVE_fnc_dump;
};
// DEBUG -------------------------------------------------------------------------------------

switch (_state) do {
    case "init":{

        private ["_agents","_partner","_partnerAgent"];

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        _agent setVariable ["ALIVE_agentBusy", true, false];

        _agents = [ALIVE_agentHandler, "getActive"] call ALIVE_fnc_agentHandler;
        _agents = _agents select 2;

        if(count _agents > 0) then {
            _partner = selectRandom _agents;
            _partnerAgent = _partner select 2 select 5;

            if!(_partnerAgent getVariable ["ALIVE_agentMeetingRequested",false]) then {
                _partnerAgent setVariable ["ALIVE_agentMeetingRequested", true, false];
                _partnerAgent setVariable ["ALIVE_agentMeetingTarget", _agent, false];

                _nextState = "wait";
                [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
            }else{
                _nextState = "done";
                [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
            };
        }else{
            _nextState = "done";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        };
    };
    case "wait":{

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        if(_agent getVariable ["ALIVE_agentMeetingComplete",false]) then {
            _agent playMove "";
            _nextState = "done";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        };
    };
    case "done":{

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        _agent setVariable ["ALIVE_agentBusy", false, false];

        _nextState = "complete";
        _nextStateArgs = [];

        [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
    };
};