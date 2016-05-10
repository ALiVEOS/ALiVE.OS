#include <\x\alive\addons\amb_civ_command\script_component.hpp>
SCRIPT(cc_joinMeeting);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_cc_joinMeeting

Description:
Start meeting command for civilians

Parameters:
Profile - profile
Args - array

Returns:

Examples:
(begin example)
//
_result = [_agent, []] call ALIVE_fnc_cc_joinMeeting;
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

	    private ["_minTimeout","_maxTimeout","_position","_timeout","_timer","_target"];

		// DEBUG -------------------------------------------------------------------------------------
		if(_debug) then {
			["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
		};
		// DEBUG -------------------------------------------------------------------------------------

		_minTimeout = _args select 0;
        _maxTimeout = _args select 1;

		_agent setVariable ["ALIVE_agentBusy", true, false];

        _target = _agent getVariable "ALIVE_agentMeetingTarget";

        if(isNil "_target") then {
            _nextState = "done";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        }else{
            _position = getPosASL _target;
            [_agent] call ALIVE_fnc_agentSelectSpeedMode;
            [_agent, _position] call ALiVE_fnc_doMoveRemote;

            _timeout = _minTimeout + floor(random _maxTimeout);
            _timer = 0;

            _nextState = "travel";
            _nextStateArgs = [_target, _timeout, _timer];

            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        };
	};
	case "travel":{
        private ["_target","_fire"];

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        _target = _args select 0;

        if(_agent call ALiVE_fnc_unitReadyRemote) then {

            _agent lookAt _target;
            _target lookAt _agent;

            if!(_agent distance _target > 10) then {
                if(random 1 < 0.5) then {
                    [_agent,"acts_PointingLeftUnarmed"] call ALIVE_fnc_switchMove;
                    [_target,"acts_StandingSpeakingUnarmed"] call ALIVE_fnc_switchMove;
                }else{
                    [_agent,"acts_StandingSpeakingUnarmed"] call ALIVE_fnc_switchMove;
                    [_target,"acts_PointingLeftUnarmed"] call ALIVE_fnc_switchMove;
                };
            };

            _nextState = "wait";
            _nextStateArgs = _args;

            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        };
	};
	case "wait":{

        private ["_timeout","_timer","_target"];

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        _target =  _args select 0;
        _timeout = _args select 1;
        _timer = _args select 2;

        if(isNil "_target") then {
            _nextState = "done";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        }else{
            if(_timer > _timeout) then
            {
                _agent playMove "";
                _target setVariable ["ALIVE_agentMeetingComplete", true, false];
                _agent setVariable ["ALIVE_agentMeetingTarget", objNull, false];

                _nextState = "done";
                [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
            }else{
                _timer = _timer + 1;
                _nextStateArgs = [_target, _timeout, _timer];
                [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
            };
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