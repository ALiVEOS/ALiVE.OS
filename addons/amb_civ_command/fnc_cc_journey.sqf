#include <\x\alive\addons\amb_civ_command\script_component.hpp>
SCRIPT(cc_journey);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_cc_journey

Description:
Drive to location command for civilians

Parameters:
Profile - profile
Args - array

Returns:

Examples:
(begin example)
//
_result = [_agent, []] call ALIVE_fnc_cc_journey;
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

	    private ["_sectors","_sector","_center","_destination","_activeAgents","_activeVehicles","_vehicle","_type"];

		// DEBUG -------------------------------------------------------------------------------------
		if(_debug) then {
			["ALiVE Managed Script Command - [%1] state: %2",_agentID,_state] call ALIVE_fnc_dump;
		};
		// DEBUG -------------------------------------------------------------------------------------

		_agent setVariable ["ALIVE_agentBusy", true, false];

        _sectors = [ALIVE_sectorGrid, "surroundingSectors", getPos _agent] call ALIVE_fnc_sectorGrid;
        _sectors = [_sectors, "SEA"] call ALIVE_fnc_sectorFilterTerrain;
        _sector = _sectors call BIS_fnc_selectRandom;
        _center = [_sector,"center"] call ALIVE_fnc_sector;
        _destination = [_center] call ALIVE_fnc_getClosestRoad;
        _activeAgents = [ALIVE_agentHandler, "getActive"] call ALIVE_fnc_agentHandler;
        _activeVehicles = [];

        {
            _type = _x select 2 select 4;
            if(_type == "vehicle") then {
                _vehicle = _x;
                if!((_vehicle select 2 select 5) getVariable ["ALIVE_vehicleInUse", false]) then {
                    _activeVehicles set [count _activeVehicles, _x];
                };
            };
        } forEach (_activeAgents select 2);

        if(count _activeVehicles > 0) then {

            _vehicle = _activeVehicles call BIS_fnc_selectRandom;
            _vehicle = _vehicle select 2 select 5;

            if!(isNull _vehicle) then {
                _nextStateArgs = [_vehicle, _destination];
                _nextState = "init";
                _commandName = "ALIVE_fnc_cc_driveTo";
                [_commandState, _agentID, [_agentData, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
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