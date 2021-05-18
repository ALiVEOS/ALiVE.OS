#include "\x\alive\addons\amb_civ_population\script_component.hpp"
SCRIPT(crowdFiredNearEventHandler);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_crowdFiredNearEventHandler

Description:
FiredNear event handler for crowd units

Parameters:

Returns:

Examples:
(begin example)
_eventID = _agent addEventHandler["FiredNear", ALIVE_fnc_crowdFiredNearEventHandler];
(end)

See Also:

Author:
Tupolov
---------------------------------------------------------------------------- */

params ["_unit", "_firer", "_distance"];

if (side group _firer == civilian) exitWith {};

// Set the crowd system to stop spawning due to combat in the area
private _crowdActivatorFSM = [ALIVE_civilianPopulationSystem, "crowd_FSM"] call ALiVE_fnc_HashGet;
_crowdActivatorFSM setFSMVariable ["_noCombat",(time + 60)];

// Let them run
_unit forceWalk false;

// Play panic animation
private _anim = "ApanPercMstpSnonWnonDnon_ApanPknlMstpSnonWnonDnon";

if (random 1 > 0.4 && !(_unit getVariable ["ALiVE_Crowd_Fleeing", false]) && alive _unit) then {
	[_unit, _anim] call ALIVE_fnc_switchMove;
} else {
	if (!(_unit getVariable ["ALiVE_Crowd_Fleeing", false]) && alive _unit) then {[_unit, ""] call ALIVE_fnc_switchMove;};
};

// Play panic noise
if (random 1 > 0.85 && !(_unit getVariable ["ALiVE_Crowd_Fleeing", false])) then {
	private _panicNoise = selectRandom ALiVE_CivPop_PanicNoises;
	if (isMultiplayer) then {
		[_unit, _panicNoise] remoteExec ["say3D"];
	} else {
		_unit say3D _panicNoise;
	};
};

if (_distance < 15 && !(_unit getVariable ["alreadyPissedOff", false])) then {

	// Hostility will increase towards firer faction
	[position _unit,[str(side group _firer)], +0.5] call ALiVE_fnc_updateSectorHostility;

	// They can only be angry once
	_unit setVariable ["alreadyPissedOff", true, false];
};

if (isnil "_unit" || {!isServer}) exitwith {};

if !(_unit getVariable ["ALiVE_Crowd_Fleeing", false]) then {

	// Stop current command
	doStop _unit;

	// Get them to run
	_unit setSpeedMode "FULL";

	// Choose somewhere to run to inside
	private _pos = [position _unit, 50] call ALIVE_fnc_findIndoorHousePositions;

	if (count _pos == 0) then {
		_pos = [position _unit,60,["House"]] call ALIVE_fnc_findNearHousePositions;
	};

	if (count _pos > 0) then {
		_pos = selectRandom _pos;
	} else {
		_pos = _unit getPos [100, random 360];
	};


	[_unit,_pos] call ALiVE_fnc_doMoveRemote;
	_unit moveTo _pos;

	_unit setVariable ["ALiVE_Crowd_Fleeing", true, false];
	_unit setVariable ["ALiVE_Crowd_Busy", (time + 60), false];
	_unit setVariable ["ALIVE_CIV_ACTION", "Fleeing", false];
};
