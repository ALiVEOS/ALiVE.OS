#include "\x\alive\addons\amb_civ_command\script_component.hpp"
SCRIPT(cc_suicide);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_cc_suicide

Description:
Suicide Bomber command for civilians

Parameters:
Profile - profile
Args - array

Returns:

Examples:
(begin example)
//
_result = [_agent, []] call ALIVE_fnc_cc_suicide;
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

        private _agentClusterID = _agentData select 2 select 9;
        private _agentCluster = [ALIVE_clusterHandler,"getCluster",_agentClusterID] call ALIVE_fnc_clusterHandler;

        private _target = [_agentCluster,getPosASL _agent, 50] call ALIVE_fnc_getAgentEnemyNear;

        if(count _target > 0) then {

            _target = _target select 0;

            private _homePosition = _agentData select 2 select 10;
            private _positions = [_homePosition,5] call ALIVE_fnc_findIndoorHousePositions;

            if(count _positions > 0) then {
                private _position = _positions call BIS_fnc_arrayPop;
                [_agent] call ALIVE_fnc_agentSelectSpeedMode;
                [_agent, _position] call ALiVE_fnc_doMoveRemote;

                _nextStateArgs = [_target];

                _nextState = "arm";
                [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
            }else{
                _nextState = "done";
                [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
            };
        }else{
            _nextState = "done";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        };

    };

    case "arm":{

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["Managed Script Command - [%1] state: %2",_agentID,_state] call ALiVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        if(_agent call ALiVE_fnc_unitReadyRemote) then {

            private _bomb1 = "DemoCharge_Remote_Ammo" createVehicle [0,0,0];
            private _bomb2 = "DemoCharge_Remote_Ammo" createVehicle  [0,0,0];
            private _bomb3 = "DemoCharge_Remote_Ammo" createVehicle  [0,0,0];

            sleep 0.01;

            _bomb1 attachTo [_agent, [-0.1,0.1,0.15],"Pelvis"];
            _bomb1 setVectorDirAndUp [[0.5,0.5,0],[-0.5,0.5,0]];
            _bomb1 setPosATL (getPosATL _bomb1);

            _bomb2 attachTo [_agent, [0,0.15,0.15],"Pelvis"];
            _bomb2 setVectorDirAndUp [[1,0,0],[0,1,0]];
            _bomb2 setPosATL (getPosATL _bomb2);

            _bomb3 attachTo [_agent, [0.1,0.1,0.15],"Pelvis"];
            _bomb3 setVectorDirAndUp [[0.5,-0.5,0],[0.5,0.5,0]];
            _bomb3 setPosATL (getPosATL _bomb3);

            _agent setVariable ["ALIVE_agentSuicide", true, false];

            _nextStateArgs = _args + [_bomb1, _bomb2, _bomb3];

            _nextState = "target";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        };

    };

    case "target":{

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["Managed Script Command - [%1] state: %2",_agentID,_state] call ALiVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        _args params ["_target","_bomb1","_bomb2","_bomb3"];

        if!(isNil "_target") then {

            _agent setSpeedMode "FULL";

            private _handle = [_agent, _target, _bomb1, _bomb2, _bomb3] spawn {

                params ["_agent","_target","_bomb1","_bomb2","_bomb3"];

                [_agent, getPosASL _target] call ALiVE_fnc_doMoveRemote;

                private _timer = time;

                waituntil {
                    sleep 0.5;

                    if (time - _timer > 15) then {[_agent, getPosASL _target] call ALiVE_fnc_doMoveRemote; _timer = time};

                    private _distance = _agent distance _target;

                    //["SPAWNED SUICIDE distance: %1 alive: %2 condition: %3",_distance, (_agent), ((_distance < 5) || !(_agent))] call ALiVE_fnc_dump;
                    ((_distance < 5) || !(alive _agent))
                };

                [_agent, _target] call ALIVE_fnc_addToEnemyGroup;

                deleteVehicle _bomb1;
                deleteVehicle _bomb2;
                deleteVehicle _bomb3;

                private _diceRoll = random 1;

                if(_diceRoll > 0.2) then {
                    private _object = "HelicopterExploSmall" createVehicle (getPos _agent);
                    _object attachTo [_agent,[-0.02,-0.07,0.042],"rightHand"];
                };
            };

            // this is causing a bug!!
            //[_agent, _target] call ALIVE_fnc_addToEnemyGroup;

            _agent setCombatMode "RED";
            _agent setBehaviour "AWARE";

            _nextStateArgs = _args + [_handle];

            _nextState = "travel";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        }else{
            _nextState = "done";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        };

    };

    case "travel":{

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["Managed Script Command - [%1] state: %2",_agentID,_state] call ALiVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        private _target = _args select 0;
        private _handle = _args select 4;

        _nextStateArgs = _args;

        if(!(isNil "_target") || !(alive _target)) then {
            terminate _handle;
            _nextState = "done";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        };

        if(scriptDone _handle) then {
            _nextState = "done";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        };

    };

    case "done":{

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["Managed Script Command - [%1] state: %2",_agentID,_state] call ALiVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        if(count _args > 1) then {
            private _bomb1 = _args select 1;
            private _bomb2 = _args select 2;
            private _bomb3 = _args select 3;

            if!(isNull _bomb1) then { deleteVehicle _bomb1 };
            if!(isNull _bomb2) then { deleteVehicle _bomb2 };
            if!(isNull _bomb3) then { deleteVehicle _bomb3 };
        };

        _agent setVariable ["ALIVE_agentBusy", false, false];

        if(alive _agent) then {
            _agent setCombatMode "WHITE";
            _agent setBehaviour "SAFE";
            _agent setSkill 0.1;
        };

        _nextState = "complete";
        _nextStateArgs = [];

        [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;

    };

};