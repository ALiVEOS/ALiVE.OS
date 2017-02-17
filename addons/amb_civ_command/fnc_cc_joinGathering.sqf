#include <\x\alive\addons\amb_civ_command\script_component.hpp>
SCRIPT(cc_joinGathering);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_cc_joinGathering

Description:
Start gathering command for civilians

Parameters:
Profile - profile
Args - array

Returns:

Examples:
(begin example)
//
_result = [_agent, []] call ALIVE_fnc_cc_joinGathering;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

params ["_agentData","_commandState","_commandName","_args","_state","_debug"];

private _agentID = _agentData select 2 select 3;
private _agent = _agentData select 2 select 5;
private _homeposition = _agentData select 2 select 10;

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

        private _target = _agent getVariable ["ALIVE_agentGatheringTarget", objNull];

        if (!isNil "_target" && {!isnull _target}) then {
            private _position = (getPosATL _target) getPos [random 4, random 360];
            [_agent] call ALIVE_fnc_agentSelectSpeedMode;
            [_agent, _position] call ALiVE_fnc_doMoveRemote;

            _nextState = "travel";
            _nextStateArgs = [_target];

            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        }else{
            _agent setVariable ["ALIVE_agentGatheringComplete", true, false];
            _agent setVariable ["ALIVE_agentGatheringRequested", false, false];
            _nextState = "done";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        };

    };

    case "travel":{

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        private _target = _args select 0;

		if (!isNil "_target" && {!isnull _target}) then {

        	if(_agent call ALiVE_fnc_unitReadyRemote) then {
                
                _agent lookAt _target;
                _target lookAt _agent;

                if (_agent distance _target < 5) then {
                    if(random 1 < 0.5) then {
                        [_agent,"acts_PointingLeftUnarmed"] call ALIVE_fnc_switchMove;
                    }else{
                        [_agent,"acts_StandingSpeakingUnarmed"] call ALIVE_fnc_switchMove;
                    };
                };

                _nextState = "wait";
                _nextStateArgs = _args;

                [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
            };
        } else {
                _agent setVariable ["ALIVE_agentGatheringComplete", true, false];
                _agent setVariable ["ALIVE_agentGatheringRequested", false, false];
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

        if(_agent getVariable ["ALIVE_agentGatheringComplete",false]) then {
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

		_agent switchMove "";
        if (_homePosition distance [0,0] > 500) then {[_agent,_homeposition] call ALiVE_fnc_doMoveRemote};
        _agent setVariable ["ALIVE_agentBusy", false, false];
        

        _nextState = "complete";
        _nextStateArgs = [];

        [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;

    };

};