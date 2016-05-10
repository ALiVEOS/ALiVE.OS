#include <\x\alive\addons\amb_civ_command\script_component.hpp>
SCRIPT(cc_rogue);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_cc_suicide

Description:
Rogue agent command for civilians

Parameters:
Profile - profile
Args - array

Returns:

Examples:
(begin example)
//
_result = [_agent, []] call ALIVE_fnc_cc_rogue;
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

        private ["_agentClusterID","_agentCluster","_target","_armed","_homePosition","_positions","_position"];

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        _agent setVariable ["ALIVE_agentBusy", true, false];

        _agentClusterID = _agentData select 2 select 9;
        _agentCluster = [ALIVE_clusterHandler,"getCluster",_agentClusterID] call ALIVE_fnc_clusterHandler;

        _target = [_agentCluster,getPosASL _agent, 50] call ALIVE_fnc_getAgentEnemyNear;

        if(count _target > 0) then {

            _target = _target select 0;

            _armed = _agent getVariable ["ALIVE_agentArmed", false];

            if(_armed) then {
                 _nextStateArgs = [_target];

                _nextState = "target";
                [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
            }else{
                _homePosition = _agentData select 2 select 10;
                _positions = [_homePosition,5] call ALIVE_fnc_findIndoorHousePositions;

                if(count _positions > 0) then {
                    _position = _positions call BIS_fnc_arrayPop;
                    [_agent] call ALIVE_fnc_agentSelectSpeedMode;
                    [_agent, _position] call ALiVE_fnc_doMoveRemote;

                    _nextStateArgs = [_target];

                    _nextState = "arm";
                    [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
                }else{
                    _nextState = "done";
                    [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
                };
            };
        }else{
            _nextState = "done";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        };
    };
    case "arm":{

        private ["_faction","_weapons","_weaponGroup","_weapon","_ammo"];

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        if(_agent call ALiVE_fnc_unitReadyRemote) then {

            //arm
            _faction = _agentData select 2 select 7;
            _weapons = [ALIVE_civilianWeapons, _faction,[["hgun_Pistol_heavy_01_F","11Rnd_45ACP_Mag"],["hgun_PDW2000_F","30Rnd_9x21_Mag"],["SMG_02_ARCO_pointg_F","30Rnd_9x21_Mag"],["arifle_TRG21_F","30Rnd_556x45_Stanag"]]] call ALIVE_fnc_hashGet;

            if(count _weapons == 0) then {
                _weapons = [ALIVE_civilianWeapons, "CIV"] call ALIVE_fnc_hashGet;
            };

            if(count _weapons > 0) then {
                _weaponGroup = _weapons call BIS_fnc_selectRandom;
                _weapon = _weaponGroup select 0;
                _ammo = _weaponGroup select 1;

                _agent addWeapon _weapon;
                _agent addMagazine _ammo;
                _agent addMagazine _ammo;

                _agent setVariable ["ALIVE_agentArmed", true, false];

                _nextStateArgs = _args;

                _nextState = "target";
                [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
            }else{
                _nextState = "done";
                [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
            };
        };
    };
	case "target":{

	    private ["_target"];

		// DEBUG -------------------------------------------------------------------------------------
		if(_debug) then {
			["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
		};
		// DEBUG -------------------------------------------------------------------------------------

		_target = _args select 0;

        if!(isNil "_target") then {

            _agent setSkill 0.3 + random 0.5;

            [_agent] call ALIVE_fnc_agentSelectSpeedMode;
            [_agent, getPosASL _target] call ALiVE_fnc_doMoveRemote;

            [_agent, _target] call ALIVE_fnc_addToEnemyGroup;

            _agent setCombatMode "RED";
            _agent setBehaviour "AWARE";

            _nextStateArgs = _args;

            _nextState = "travel";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        }else{
            _nextState = "done";
            [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
        };
	};
	case "travel":{

        private ["_target"];

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
        };
        // DEBUG -------------------------------------------------------------------------------------

        _target = _args select 0;

        if(_agent call ALiVE_fnc_unitReadyRemote) then {

            if((isNil "_target") || !(alive _target)) then {
                _nextState = "done";
                [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
            };

            if(_agent distance _target > 20) then {
                _agent addRating -10000;
                [_agent] call ALIVE_fnc_agentSelectSpeedMode;
                [_agent, getPosASL _target] call ALiVE_fnc_doMoveRemote;
            }else{

                _agent doTarget _target;

                _nextState = "done";
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