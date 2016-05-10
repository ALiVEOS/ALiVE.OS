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

        private ["_position","_minTimeout","_maxTimeout","_timeout","_timer","_pos"];

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        //_position = getPosASL _agent findEmptyPosition[10, 100, "O_Ka60_F"];
        _pos = getposATL _agent;
        _position = [_pos,0,10,1,0,10,0,[],[_pos]] call BIS_fnc_findSafePos;

        _minTimeout = _args select 0;
        _maxTimeout = _args select 1;

        [_agent] call ALIVE_fnc_agentSelectSpeedMode;
        [_agent, _position] call ALiVE_fnc_doMoveRemote;

        _timeout = _minTimeout + floor(random _maxTimeout);
        _timer = 0;

        _nextState = "travel";
        _nextStateArgs = [_timeout, _timer];

        [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
    };
	case "travel":{

	    private ["_agents","_partners","_partner","_partnerAgent"];

		// DEBUG -------------------------------------------------------------------------------------
		if(_debug) then {
			["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
		};
		// DEBUG -------------------------------------------------------------------------------------

		if(_agent call ALiVE_fnc_unitReadyRemote) then {

            _agent setVariable ["ALIVE_agentBusy", true, false];

            _agents = [ALIVE_agentHandler, "getActive"] call ALIVE_fnc_agentHandler;
            _agents = _agents select 2;

            if(count _agents > 0) then {
                _partners = [];

                {
                    _partner = _agents call BIS_fnc_selectRandom;
                    _partnerAgent = _partner select 2 select 5;

                    if!(_partnerAgent getVariable ["ALIVE_agentGatheringRequested",false]) then {
                        _partnerAgent setVariable ["ALIVE_agentGatheringComplete", false, false];
                        _partnerAgent setVariable ["ALIVE_agentGatheringRequested", true, false];
                        _partnerAgent setVariable ["ALIVE_agentGatheringTarget", _agent, false];

                        _partners set [count _partners, _partnerAgent];
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

	    private ["_timeout","_timer","_partners"];

	    // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        _timeout = _args select 0;
        _timer = _args select 1;
        _partners =  _args select 2;

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