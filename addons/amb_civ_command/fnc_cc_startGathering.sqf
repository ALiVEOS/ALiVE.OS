#include <\x\alive\addons\amb_civ_command\script_component.hpp>
SCRIPT(cc_startGathering);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_cc_startGathering

Description:
Start gathering command for civilians

Parameters:
Profile - profile
Args - array

Returns:

Examples:
(begin example)
//
_result = [_agent, []] call ALIVE_fnc_cc_startGathering;
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

        //_position = getPosASL _agent findEmptyPosition[10, 100, "O_Ka60_F"];
        private _pos = getposATL _agent;
        private _position = [_pos,0,10,1,0,10,0,[],[_pos]] call BIS_fnc_findSafePos;

        _args params ["_minTimeout","_maxTimeout"];

        [_agent] call ALIVE_fnc_agentSelectSpeedMode;
        [_agent, _position] call ALiVE_fnc_doMoveRemote;

        private _timeout = _minTimeout + floor(random _maxTimeout);
        private _timer = 0;

        _nextState = "travel";
        _nextStateArgs = [_timeout, _timer];

        [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;

    };

    case "travel":{

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        if(_agent call ALiVE_fnc_unitReadyRemote) then {

            _agent setVariable ["ALIVE_agentBusy", true, false];

            private _agents = [ALIVE_agentHandler, "getActive"] call ALIVE_fnc_agentHandler;
            _agents = _agents select 2;

            if(count _agents > 0) then {
                private _partners = [];

                {
                    private _partner = selectRandom _agents;
                    private _partnerAgent = _partner select 2 select 5;

                    if(!(_partnerAgent getVariable ["ALIVE_agentGatheringRequested",false]) && {!(_partnerAgent getVariable ["ALIVE_agentMeetingRequested",false])}) then {
                        _partnerAgent setVariable ["ALIVE_agentGatheringComplete", false, false];
                        _partnerAgent setVariable ["ALIVE_agentGatheringRequested", true, false];
                        _partnerAgent setVariable ["ALIVE_agentGatheringTarget", _agent, false];

                        _partners pushback _partnerAgent;
                    };
                } forEach _agents;

                _nextState = "wait";
                _nextStateArgs = _args + [_partners];
                [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
            }else{
                _nextState = "done";
                [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
            };
        };

    };

    case "wait":{

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        _args params ["_timeout","_timer","_partners"];

        if(_timer > _timeout) then
        {
            {
                _x setVariable ["ALIVE_agentGatheringRequested", false, false];
                _x setVariable ["ALIVE_agentGatheringComplete", true, false];
                _x setVariable ["ALIVE_agentGatheringTarget", objNull, false];
            } forEach _partners;

            _agent setVariable ["ALIVE_agentGatheringRequested", false, false];
            _agent setVariable ["ALIVE_agentGatheringComplete", true, false];
            _agent setVariable ["ALIVE_agentGatheringTarget", objNull, false];

            _nextState = "done";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        }else{
            _timer = _timer + 1;

            _nextStateArgs = [_timeout, _timer, _partners];

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
