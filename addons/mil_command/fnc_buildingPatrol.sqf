#include <\x\alive\addons\mil_command\script_component.hpp>
SCRIPT(testCommand);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_testCommand

Description:
Test Command Script for active profiles

Parameters:
Profile - profile
Args - array

Returns:

Examples:
(begin example)
//
_result = [_profile, []] call ALIVE_fnc_testCommand;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_profile","_args","_debug","_profileID","_leader","_group","_units","_iteration"];

_profile = _this select 0;	
_args = _this select 1;
_debug = _this select 2;

_profileID = _profile select 2 select 4;
_leader = _profile select 2 select 10;
_group = _profile select 2 select 13;
_units = _profile select 2 select 21;

_iteration = 0;

// DEBUG -------------------------------------------------------------------------------------
//if(_debug) then {
	["ALiVE Spawned Script Command - [%1] called args: %2",_profileID,_args] call ALIVE_fnc_dump;
//};
// DEBUG -------------------------------------------------------------------------------------	

waituntil {
	
	// DEBUG -------------------------------------------------------------------------------------
	//if(_debug) then {
		["ALiVE Spawned Script Command - [%1] iteration: %2",_profileID,_iteration] call ALIVE_fnc_dump;
	//};
	// DEBUG -------------------------------------------------------------------------------------	
	
	_iteration = _iteration + 1;
	
	sleep 5;
	
	false 
};
