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

params ["_agentData","_commandState","_commandName","_args","_state","_debug"];

private _agentID = _agentData select 2 select 3;
private _agent = _agentData select 2 select 5;

private _nextState = _state;
private _nextStateArgs = [];


// DEBUG -------------------------------------------------------------------------------------
if(_debug) then {
    ["ALiVE Managed Script Command - [%1] called args: %2",_agentID,_args] call ALIVE_fnc_dump;
};
// DEBUG -------------------------------------------------------------------------------------

switch (_state) do {

    case "init":{

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        _agent setVariable ["ALIVE_agentBusy", true, false];

        private _agents = [ALIVE_agentHandler, "getActive"] call ALIVE_fnc_agentHandler;
        _agents = _agents select 2;

        if(count _agents > 0) then {
            private _partner = selectRandom _agents;
            private _partnerAgent = _partner select 2 select 5;

            if(!(_partnerAgent getVariable ["ALIVE_agentMeetingRequested",false]) && {!(_partnerAgent getVariable ["ALIVE_agentGatheringRequested",false])}) then {
                _partnerAgent setVariable ["ALIVE_agentMeetingTarget", _agent, false];
                _partnerAgent setVariable ["ALIVE_agentMeetingRequested", true, false];

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
            _agent setVariable ["ALIVE_agentMeetingComplete", nil, false];
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