#include "\x\alive\addons\amb_civ_command\script_component.hpp"
SCRIPT(cc_sabotage);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_cc_sabotage

Description:
Sabotages a building

Parameters:
Profile - profile
Args - array

Returns:

Examples:
(begin example)
//
_result = [_agent, [_position]] call ALIVE_fnc_cc_sabotage;
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
        if (_debug) then {
            ["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        _agent setVariable ["ALIVE_agentBusy", true, false];
        _agent setVariable ["ALIVE_Insurgent", true, false];
        _agent addVest "V_ALiVE_Suicide_Vest";
        _agent addMagazines ["DemoCharge_Remote_Mag", 2];

        private _agentClusterID = _agentData select 2 select 9;
        private _agentCluster = [ALIVE_clusterHandler,"getCluster",_agentClusterID] call ALIVE_fnc_clusterHandler;

        private _position = _args select 0;

        //_target = [getPosASL _agent, 600, _targetSide] call ALIVE_fnc_getSideManOrPlayerNear;

        if !(isnil "_position") then {

            _agent setBehaviour "CARELESS";
            _agent setSpeedMode "LIMITED";

            [_agent, _position] call ALiVE_fnc_doMoveRemote;

            _position = selectRandom ([_position,15] call ALIVE_fnc_findIndoorHousePositions);

            _nextStateArgs = _args;
            _nextState = "move";

            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        } else {
            _nextState = "done";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        };

    };

    case "move":{

        // DEBUG -------------------------------------------------------------------------------------
        if (_debug) then {
            ["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        private _position = _args select 0;

        if !(isNil "_position") then {

            private _handle = [_agent, _position] spawn {

                params ["_agent","_position"];

                private _orgPos = getposATL _agent;
                private _bombs = [];

                _agent setBehaviour "CARELESS";
                _agent setSpeedMode "LIMITED";

                waituntil {
                    [_agent, _position] call ALiVE_fnc_doMoveRemote;

                    sleep 15;

                    _agent distance _position < 5 || {!(alive _agent)};
                };

                if (!alive _agent) exitwith {};

                private _positions = [_position,20] call ALIVE_fnc_findIndoorHousePositions;

                sleep 5;

                for "_i" from 1 to 3 do {

                    private _charge = selectRandom _positions;
                    [_agent,_charge] call ALiVE_fnc_doMoveRemote;

                    sleep 20;

                    _agent playActionNow "PutDown";
                    private _c4 = "DemoCharge_Remote_Ammo_Scripted" createVehicle (getposATL _agent);
                    _c4 setposATL (getposATL _agent);
                    _bombs pushBack _c4;
                };

                _agent setSpeedMode "FULL";

                waituntil {
                    [_agent,_orgpos] call ALiVE_fnc_doMoveRemote;

                    sleep 15;

                    !alive _agent || {_agent distance (_bombs select 0) > 50}};

                if (alive _agent) then {{_x setDamage 1} foreach _bombs};
            };
            _nextStateArgs = _args + [_handle];

            _nextState = "travel";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        } else {
            _nextState = "done";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        };

    };

    case "travel":{

        // DEBUG -------------------------------------------------------------------------------------
        if (_debug) then {
            ["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        _args params ["_position","_handle"];

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

    case "done":{

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