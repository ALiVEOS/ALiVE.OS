#include <\x\alive\addons\amb_civ_command\script_component.hpp>
SCRIPT(cc_sleep);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_cc_sleep

Description:
Sleep command for agents

Parameters:
Profile - profile
Args - array

Returns:

Examples:
(begin example)
//
_result = [_agent, []] call ALIVE_fnc_cc_sleep;
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

	    private ["_minTimeout","_maxTimeout","_homePosition","_timeout","_timer"];
	
		// DEBUG -------------------------------------------------------------------------------------
		if(_debug) then {
			["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
		};
		// DEBUG -------------------------------------------------------------------------------------

		_agent setVariable ["ALIVE_agentBusy", true, false];

        _minTimeout = _args select 0;
		_maxTimeout = _args select 1;

        _homePosition = _agentData select 2 select 10;

        [_agent] call ALIVE_fnc_agentSelectSpeedMode;
        [_agent, _homePosition] call ALiVE_fnc_doMoveRemote;

        _timeout = _minTimeout + floor(random _maxTimeout);
        _timer = 0;

        _nextState = "travel";
        _nextStateArgs = [_timeout, _timer];

        [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
	};
	case "travel":{
        private ["_dayState","_music","_light"];

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        if(_agent call ALiVE_fnc_unitReadyRemote) then {

            _dayState = ALIVE_currentEnvironment select 0;

            if(_dayState == "EVENING" || _dayState == "NIGHT") then {

                if(_agent getVariable ["ALIVE_agentHouseMusicOn",false]) then {
                    _music = _agent getVariable "ALIVE_agentHouseMusic";
                    deleteVehicle _music;
                    _agent setVariable ["ALIVE_agentHouseMusic", objNull, false];
                    _agent setVariable ["ALIVE_agentHouseMusicOn", true, false];
                };
            };

            if(_dayState == "EVENING" || _dayState == "NIGHT") then {

                if(_agent getVariable ["ALIVE_agentHouseLightOn",false]) then {
                    _light = _agent getVariable "ALIVE_agentHouseLight";
                    deleteVehicle _light;
                    _agent setVariable ["ALIVE_agentHouseLight", objNull, false];
                    _agent setVariable ["ALIVE_agentHouseLightOn", false, false];
                };
            };

            _agent playMove "AinjPpneMstpSnonWnonDnon_injuredHealed";

            _nextState = "sleep";
            _nextStateArgs = _args;

            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        };
	};
	case "sleep":{

        private ["_timeout","_timer"];

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        _timeout = _args select 0;
        _timer = _args select 1;

        if(_timer > _timeout || (ALIVE_currentEnvironment select 0 == "DAY")) then
        {
            _agent playMove "";
            _nextState = "done";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        }else{
            _timer = _timer + 1;

            _nextStateArgs = [_timeout, _timer];

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