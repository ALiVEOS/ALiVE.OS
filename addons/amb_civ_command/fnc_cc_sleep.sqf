#include "\x\alive\addons\amb_civ_command\script_component.hpp"
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
Jman
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

        [_agent] call ALIVE_fnc_agentSelectSpeedMode;
        [_agent, _homePosition] call ALiVE_fnc_doMoveRemote;

        private _timeout = _minTimeout + floor(random _maxTimeout);
        private _timer = 0;

        _nextState = "travel";
        _nextStateArgs = [_timeout, _timer];

        [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;

    };

    case "travel":{

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

            // Only under a roof. A house with no indoor positions gives its exit as the home, and a
            // civilian who can't get in stops at the door: lying down there left civilians asleep on
            // their front steps (A. Ares on Discord, 15 Oct, Weferlinger and Altis). Outside, he just
            // finishes and goes on to something else.
            private _eye = eyePos _agent;
            private _over = lineIntersectsSurfaces [_eye, _eye vectorAdd [0, 0, 15], _agent, objNull, true, 1, "GEOM", "NONE"];
            // and only at night: in the evening he goes home but doesn't lie down
            if (_dayState == "NIGHT" && {_over isNotEqualTo []} && {((_over select 0) select 2) isKindOf "House"}) then {
                _agent playMove "AinjPpneMstpSnonWnonDnon_injuredHealed";
                _nextState = "sleep";
                _nextStateArgs = _args;
            } else {
                _nextState = "done";
                _nextStateArgs = [];
            };

            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        };

    };

    case "sleep":{

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["Managed Script Command - [%1] state: %2",_agentID,_state] call ALiVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        _args params ["_timeout","_timer"];

        // awake again once night is over
        if(_timer > _timeout || ((call ALIVE_fnc_getEnvironment) select 0 != "NIGHT")) then
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
            ["Managed Script Command - [%1] state: %2",_agentID,_state] call ALiVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        _agent setVariable ["ALIVE_agentBusy", false, false];

        _nextState = "complete";
        _nextStateArgs = [];

        [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;

    };

};