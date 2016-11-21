#include <\x\alive\addons\amb_civ_command\script_component.hpp>
SCRIPT(cc_getWeapons);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_cc_getWeapons

Description:
Get weapons from depot

Parameters:
Profile - profile
Args - array

Returns:

Examples:
(begin example)
//
_result = [_agent, [_depot,_destination]] call ALIVE_fnc_cc_getWeapons;
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
    case "init": {

        // DEBUG -------------------------------------------------------------------------------------
        if (_debug) then {
            ["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        _agent setVariable ["ALIVE_agentBusy", true, false];

        private _agentClusterID = _agentData select 2 select 9;
        private _agentCluster = [ALIVE_clusterHandler,"getCluster",_agentClusterID] call ALIVE_fnc_clusterHandler;

        private _position = _args select 0;

        //_target = [getPosASL _agent, 600, _targetSide] call ALIVE_fnc_getSideManOrPlayerNear;

        if !(isnil "_position") then {
            [_agent, _position] call ALiVE_fnc_doMoveRemote;

            _position = selectRandom ([_position,10] call ALIVE_fnc_findIndoorHousePositions);

            _nextStateArgs = _args;
            _nextState = "move";

            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        } else {
            _nextState = "done";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        };
    };

    case "move": {

        // DEBUG -------------------------------------------------------------------------------------
        if (_debug) then {
            ["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        private _position = _args select 0;

        if !(isNil "_position") then {

            _agent setSpeedMode "LIMITED";
            _agent setBehaviour "CARELESS";

            private _handle = [_agent, _position] spawn {

                private ["_agent","_position"];

                _agent = _this select 0;
                _position = _this select 1;

                sleep 60 + (random 120);

                waituntil {
                    [_agent,_position] call ALiVE_fnc_doMoveRemote;

                    sleep 10;

                    _agent call ALiVE_fnc_unitReadyRemote || {!(alive _agent)}
                };

                if (alive _agent) then {
                    _agent setVariable ["ALIVE_Insurgent", true, false];
                    _agent addVest "V_ALiVE_Suicide_Vest";
                    _agent addMagazines ["DemoCharge_Remote_Mag", 2];
                };

                sleep 30;
            };

            _nextStateArgs = _args + [_handle];

            _nextState = "travel";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        } else {
            _nextState = "done";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        };
    };

    case "travel": {

        // DEBUG -------------------------------------------------------------------------------------
        if (_debug) then {
            ["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        private _position = _args select 0;
        private _handle = _args select 1;

        _nextStateArgs = _args;

        if !(alive _agent) exitwith {
                terminate _handle;

                _nextState = "done";
                [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        };

        if (scriptDone _handle) then {
            _nextState = "done";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        };
    };

    case "done": {

        // DEBUG -------------------------------------------------------------------------------------
        if (_debug) then {
            ["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        if (alive _agent) then {
            _agent setCombatMode "WHITE";
            _agent setBehaviour "SAFE";
            _agent setSkill 0.1;

            private _homePosition = _agentData select 2 select 10;
            private _positions = [_homePosition,15] call ALIVE_fnc_findIndoorHousePositions;

            if (count _positions > 0) then {
                private _position = _positions call BIS_fnc_arrayPop;
                [_agent] call ALIVE_fnc_agentSelectSpeedMode;

                [_agent, _position] call ALiVE_fnc_doMoveRemote;
            };

            _agent setVariable ["ALIVE_agentBusy", false, false];
        };

        _nextState = "complete";
        _nextStateArgs = [];

        [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
    };
};