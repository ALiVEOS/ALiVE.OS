#include <\x\alive\addons\mil_command\script_component.hpp>
SCRIPT(testManagedCommand);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_testManagedCommand

Description:
Test Managed Command Script for active profiles

Parameters:
Profile - profile
Args - array

Returns:

Examples:
(begin example)
//
_result = [_profile, []] call ALIVE_fnc_testManagedCommand;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_profile","_commandState","_commandName","_args","_state","_debug","_profileID","_leader","_group","_units","_nextState","_nextStateArgs"];

_profile = _this select 0;
_commandState = _this select 1;
_commandName = _this select 2;
_args = _this select 3;
_state = _this select 4;
_debug = _this select 5;

_profileID = _profile select 2 select 4;
_leader = _profile select 2 select 10;
_group = _profile select 2 select 13;
_units = _profile select 2 select 21;

_nextState = _state;
_nextStateArgs = [];


// DEBUG -------------------------------------------------------------------------------------
//if(_debug) then {
	["ALiVE Managed Script Command - [%1] called args: %2",_profileID,_args] call ALIVE_fnc_dump;
//};
// DEBUG -------------------------------------------------------------------------------------	

switch (_state) do {
	case "init":{
	
		// DEBUG -------------------------------------------------------------------------------------
		//if(_debug) then {
			["ALiVE Managed Script Command - [%1] state: %2",_profileID,_state] call ALIVE_fnc_dump;
		//};
		// DEBUG -------------------------------------------------------------------------------------
		
		_nextState = "stateOne";
		_nextStateArgs = _args + ["param3","param4"];
		
		[_commandState, _profileID, [_profile, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
	};
	case "stateOne":{
	
		// DEBUG -------------------------------------------------------------------------------------
		//if(_debug) then {
			["ALiVE Managed Script Command - [%1] state: %2",_profileID,_state] call ALIVE_fnc_dump;
		//};
		// DEBUG -------------------------------------------------------------------------------------
		
		_nextState = "stateTwo";
		_nextStateArgs = _args + ["param5","param6"];
		
		[_commandState, _profileID, [_profile, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
	};
	case "stateTwo":{
	
		// DEBUG -------------------------------------------------------------------------------------
		//if(_debug) then {
			["ALiVE Managed Script Command - [%1] state: %2",_profileID,_state] call ALIVE_fnc_dump;
		//};
		// DEBUG -------------------------------------------------------------------------------------
		
		_nextState = "complete";
		_nextStateArgs = [];
		
		[_commandState, _profileID, [_profile, [_commandName,"managed",_args,_nextState,_nextStateArgs]]] call ALIVE_fnc_hashSet;
	};
};