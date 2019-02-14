#include "\x\alive\addons\amb_civ_command\script_component.hpp"
SCRIPT(cc_randomMovement);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_cc_rqndomMovement

Description:
Random movement command for civilians

Parameters:
Profile - profile
Args - array

Returns:

Examples:
(begin example)
//
_result = [_agent, []] call ALIVE_fnc_cc_randomMovement;
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

        private _maxDistance = _args select 0;

        private _homePosition = _agentData select 2 select 10;
        private _agentPosition = getPosASL _agent;

        private ["_startPosition"];

        if(_agentPosition distance _homePosition > 100) then {
            _startPosition = _homePosition;
        }else{
            _startPosition = _agentPosition;
        };

        private _positions = [];

        for "_i" from 0 to (5) do
        {
            private _distance = random _maxDistance;
            private _position = [_startPosition, _distance] call ALIVE_fnc_getRandomPositionLand;
            _positions pushback _position;
        };

        private _position = _positions call BIS_fnc_arrayPop;
        [_agent] call ALIVE_fnc_agentSelectSpeedMode;
        [_agent, _position] call ALiVE_fnc_doMoveRemote;

        _nextState = "walk";
        _nextStateArgs = [_positions];

        [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;

    };

    case "walk":{

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        private _positions = _args select 0;

        if(count _positions == 0) then
        {
            _nextState = "done";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        }
        else
        {
            if(_agent call ALiVE_fnc_unitReadyRemote) then
            {
                private _position = _positions call BIS_fnc_arrayPop;
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