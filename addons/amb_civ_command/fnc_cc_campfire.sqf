#include "\x\alive\addons\amb_civ_command\script_component.hpp"
SCRIPT(cc_campfire);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_cc_campfire

Description:
Campfire command for civilians

Parameters:
Profile - profile
Args - array

Returns:

Examples:
(begin example)
//
_result = [_agent, []] call ALIVE_fnc_cc_campfire;
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

        private _pos = getposATL _agent;
        private _position = [_pos,0,10,1,0,10,0,[],[_pos]] call BIS_fnc_findSafePos;

        if(count _position > 0) then {
            [_agent] call ALIVE_fnc_agentSelectSpeedMode;
            [_agent, _position] call ALiVE_fnc_doMoveRemote;

            private _timeout = _minTimeout + floor(random _maxTimeout);
            private _timer = 0;

            _nextState = "travel";
            _nextStateArgs = [_timeout, _timer];

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

        private _positions = _args select 0;

        if(_agent call ALiVE_fnc_unitReadyRemote) then {

            // Spawn the fire ~2m in front of the civilian, not at their
            // exact position. The SITDOWN animation below keeps the
            // civilian standing/sitting where they are - if the fire is
            // at their feet, they end up inside its damage radius and
            // burn to death over the 60-300s wait. Reported as #906
            // (UnRealxInferno, 2026-05-26) - civilians self-immolating
            // at night-spawned (invisible-looking) campfires.
            private _agentPos = position _agent;
            private _agentDir = direction _agent;
            // One fire per gathering, not one per civilian: a fire another civilian already has going
            // within 30 m is joined rather than a new one lit beside it, so a town in the evening has a
            // few fires instead of one outside every house (A. Ares on Discord, 15 Oct). A joined fire
            // is not this civilian's to put out.
            private _near = (nearestObjects [_agentPos, ["FirePlace_burning_F"], 30]) select { _x getVariable ["ALiVE_civFire", false] };
            private _fire = objNull;
            if (_near isNotEqualTo []) then {
                private _shared = _near select 0;
                _agent setDir (_agent getDir _shared);
                _agent lookAt _shared;
            } else {
                private _firePos = _agentPos vectorAdd [sin(_agentDir) * 2, cos(_agentDir) * 2, 0];
                _fire = "FirePlace_burning_F" createVehicle _firePos;
                _fire setVariable ["ALiVE_civFire", true];
                // put out with the civilian if he is despawned before he gets up, rather than left burning
                _agent setVariable ["ALiVE_civFireLit", _fire];
                if !(_agent getVariable ["ALiVE_civFireEH", false]) then {
                    _agent setVariable ["ALiVE_civFireEH", true];
                    _agent addEventHandler ["Deleted", { deleteVehicle ((_this select 0) getVariable ["ALiVE_civFireLit", objNull]) }];
                };
                _agent lookAt _fire;
            };

            _agent action ["SITDOWN",_agent];

            _nextState = "wait";
            _nextStateArgs = _args + [_fire];

            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        };

    };

    case "wait":{

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["Managed Script Command - [%1] state: %2",_agentID,_state] call ALiVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        _args params ["_timeout","_timer","_fire"];

        if(_timer > _timeout) then
        {
            _agent playMove "";
            deleteVehicle _fire;
            _agent setVariable ["ALiVE_civFireLit", nil];
            _nextState = "done";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        }else{
            _timer = _timer + 1;

            _nextStateArgs = [_timeout, _timer, _fire];

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