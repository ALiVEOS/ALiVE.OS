#include <\x\alive\addons\amb_civ_command\script_component.hpp>
SCRIPT(cc_housework);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_cc_housework

Description:
Housework command for agents

Parameters:
Profile - profile
Args - array

Returns:

Examples:
(begin example)
//
_result = [_agent, []] call ALIVE_fnc_cc_housework;
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

	    private ["_homePosition","_positions","_position"];
	
		// DEBUG -------------------------------------------------------------------------------------
		if(_debug) then {
			["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
		};
		// DEBUG -------------------------------------------------------------------------------------

		_agent setVariable ["ALIVE_agentBusy", true, false];

        _homePosition = _agentData select 2 select 10;

        _positions = [_homePosition,5] call ALIVE_fnc_findIndoorHousePositions;

        if(count _positions > 0) then {
            _position = _positions call BIS_fnc_arrayPop;
            [_agent] call ALIVE_fnc_agentSelectSpeedMode;
            [_agent, _position] call ALiVE_fnc_doMoveRemote;

            _nextState = "travel";
            _nextStateArgs = [_positions];

            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        }else{
            _nextState = "done";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        };
	};
	case "travel":{
        private ["_positions","_dayState","_homePosition","_building","_music","_light"];

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        _positions = _args select 0;

        if(_agent call ALiVE_fnc_unitReadyRemote) then {

            _dayState = ALIVE_currentEnvironment select 0;

            if(_dayState == "EVENING" || _dayState == "DAY") then {

                _homePosition = _agentData select 2 select 10;

                if([_homePosition, 80] call ALiVE_fnc_anyPlayersInRange > 0) then {
                    if!(_agent getVariable ["ALIVE_agentHouseMusicOn",false]) then {
                        _building = _homePosition nearestObject "House";
                        _music = [_building] call ALIVE_fnc_addAmbientRoomMusic;
                        _agent setVariable ["ALIVE_agentHouseMusic", _music, false];
                        _agent setVariable ["ALIVE_agentHouseMusicOn", true, false];
                    };
                };

            };

            if(_dayState == "EVENING" || _dayState == "NIGHT") then {

                _homePosition = _agentData select 2 select 10;

                if!(_agent getVariable ["ALIVE_agentHouseLightOn",false]) then {
                    _building = _homePosition nearestObject "House";
                    _light = [_building] call ALIVE_fnc_addAmbientRoomLight;
                    _agent setVariable ["ALIVE_agentHouseLight", _light, false];
                    _agent setVariable ["ALIVE_agentHouseLightOn", true, false];
                };
            };

            _nextState = "housework";
            _nextStateArgs = [_positions];

            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        };
	};
	case "housework":{

	    private ["_positions","_position"];
	
		// DEBUG -------------------------------------------------------------------------------------
		if(_debug) then {
			["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
		};
		// DEBUG -------------------------------------------------------------------------------------

		_positions = _args select 0;

        if(count _positions == 0) then
        {
            _nextState = "done";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        }
        else
        {
            if(_agent call ALiVE_fnc_unitReadyRemote) then
            {
                _position = _positions call BIS_fnc_arrayPop;
                [_agent] call ALIVE_fnc_agentSelectSpeedMode;
                [_agent, _position] call ALiVE_fnc_doMoveRemote;

                _nextStateArgs = [_positions];

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