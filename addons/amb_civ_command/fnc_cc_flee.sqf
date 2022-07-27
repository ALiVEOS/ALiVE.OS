#include "\x\alive\addons\amb_civ_command\script_component.hpp"
SCRIPT(cc_flee);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_cc_flee

Description:
Flee command for agents

Parameters:
Profile - profile
Args - array

Returns:

Examples:
(begin example)
//
_result = [_agent, []] call ALIVE_fnc_cc_flee;
(end)

See Also:

Author:
Tupolov
---------------------------------------------------------------------------- */

params ["_agentData","_commandState","_commandName","_args","_state","_debug"];

private _agentID = _agentData select 2 select 3;
private _agent = _agentData select 2 select 5;

private _nextState = _state;
private _nextStateArgs = [];


// DEBUG -------------------------------------------------------------------------------------
if(_debug) then {
    ["Managed Script Command - [%1] called args: %2",_agentID,_args] call ALiVE_fnc_dump;
};
// DEBUG -------------------------------------------------------------------------------------

switch (_state) do {

    case "init":{

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["Managed Script Command - [%1] state: %2",_agentID,_state] call ALiVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        _agent setVariable ["ALIVE_agentBusy", true, false];

        _args params ["_minTimeout","_maxTimeout"];

        private _homePosition = _agentData select 2 select 10;

        [_agent, _homePosition] call ALiVE_fnc_doMoveRemote;

        _agent setSpeedMode "FULL";

        private _timeout = _minTimeout + floor(random _maxTimeout);
        private _timer = 0;

        _nextState = "fleeing";
        _nextStateArgs = [_timeout, _timer];

        [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;

    };

    case "fleeing":{

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["Managed Script Command - [%1] state: %2",_agentID,_state] call ALiVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        if(_agent call ALiVE_fnc_unitReadyRemote) then {

            private _dayState = (call ALIVE_fnc_getEnvironment) select 0;

            if(_dayState == "EVENING" || _dayState == "NIGHT") then {

                if(_agent getVariable ["ALIVE_agentHouseMusicOn",false]) then {
                    private _music = _agent getVariable "ALIVE_agentHouseMusic";
                    deleteVehicle _music;
                    _agent setVariable ["ALIVE_agentHouseMusic", objNull, false];
                    _agent setVariable ["ALIVE_agentHouseMusicOn", true, false];
                };
            };

            if(_dayState == "EVENING" || _dayState == "NIGHT") then {

                if(_agent getVariable ["ALIVE_agentHouseLightOn",false]) then {
                    private _light = _agent getVariable "ALIVE_agentHouseLight";
                    deleteVehicle _light;
                    _agent setVariable ["ALIVE_agentHouseLight", objNull, false];
                    _agent setVariable ["ALIVE_agentHouseLightOn", false, false];
                };
            };

            _agent playMove "ApanPknlMstpSnonWnonDnon_G01";

            _nextState = "cooldown";
            _nextStateArgs = _args;

            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        };

    };

    case "cooldown":{

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["Managed Script Command - [%1] state: %2",_agentID,_state] call ALiVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        _args params ["_timeout","_timer"];

        if(_timer > _timeout) then
        {
            [_agent, ""] call ALIVE_fnc_switchMove;
            _agent setVariable ["isFleeing", false, false];
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
            ["Managed Script Command - [%1] state: %2",_agentID,_state] call ALiVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        _agent setVariable ["ALIVE_agentBusy", false, false];

        _nextState = "complete";
        _nextStateArgs = [];

        [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;

    };

};