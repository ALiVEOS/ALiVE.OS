#include "\x\alive\addons\amb_civ_command\script_component.hpp"
SCRIPT(cc_observe);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_cc_observe

Description:
Observe command for civilians

Parameters:
Profile - profile
Args - array

Returns:

Examples:
(begin example)
//
_result = [_agent, []] call ALIVE_fnc_cc_observe;
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

        _args params ["_minTimeout","_maxTimeout"];

        private _target = [getPosASL _agent, 50] call ALIVE_fnc_getRandomManOrPlayerNear;

        if(count _target > 0) then {
            _target = _target select 0;
            [_agent] call ALIVE_fnc_agentSelectSpeedMode;
            private _position = (getPosASL _target) getPos [1+(random 5), random 360];
            [_agent, _position] call ALiVE_fnc_doMoveRemote;

            private _timeout = _minTimeout + floor(random _maxTimeout);
            private _timer = 0;

            _nextState = "travel";
            _nextStateArgs = [_target, _timeout, _timer];

            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        }else{
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

        if(_agent call ALiVE_fnc_unitReadyRemote) then {

            if!(isNil "_target") then {
                _agent doWatch _target;
            };

            if(random 1 < 0.3) then {
                [_agent,"InBaseMoves_HandsBehindBack1"] call ALIVE_fnc_switchMove;
            };

            _nextState = "wait";
            _nextStateArgs = _args;

            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        };

    };

    case "wait":{

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        _args params ["_target","_timeout","_timer"];

        if(_timer > _timeout) then
        {
            _agent playMove "";
            _nextState = "done";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        }else{
            if(_agent call ALiVE_fnc_unitReadyRemote) then {
                if(_agent distance _target > 7) then {
                    [_agent] call ALIVE_fnc_agentSelectSpeedMode;
                    private _position = (getPosASL _target) getPos [1+(random 5), random 360];
                    [_agent, _position] call ALiVE_fnc_doMoveRemote;
                }
            };
            _timer = _timer + 1;

            _nextStateArgs = [_target, _timeout, _timer];

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