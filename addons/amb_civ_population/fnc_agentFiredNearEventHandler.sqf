#include "\x\alive\addons\amb_civ_population\script_component.hpp"
SCRIPT(agentFiredNearEventHandler);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_agentFiredNearEventHandler

Description:
FiredNear event handler for agent units

Parameters:

Returns:

Examples:
(begin example)
_eventID = _agent addEventHandler["FiredNear", ALIVE_fnc_agentFiredNearEventHandler];
(end)

See Also:

Author:
Tupolov
---------------------------------------------------------------------------- */

params ["_unit", "_firer", "_distance"];

private _agentID = _unit getVariable "agentID";
private _agent = [ALIVE_agentHandler, "getAgent", _agentID] call ALIVE_fnc_agentHandler;

if (_distance < 50) then {

	// Play panic animation
	private _anim = "ApanPercMstpSnonWnonDnon_ApanPknlMstpSnonWnonDnon";

	if (random 1 > 0.4 && !(_unit getVariable ["isFleeing", false])) then {
		[_unit, _anim] call ALIVE_fnc_switchMove;
	};

	// Play panic noise
	if (random 1 > 0.3) then {
		private _panicNoise = selectRandom ALiVE_CivPop_PanicNoises;
		if (isMultiplayer) then {
			[_unit, _panicNoise] remoteExec ["say3D"];
		} else {
			_unit say3D _panicNoise;
		};
	};

	// Get them to run
	_unit setSpeedMode "FULL";
};

if (_distance < 25 && !(_unit getVariable ["alreadyPissedOff", false])) then {

	// Hostility will increase towards firer faction
	[position _unit,[str(side _firer)], +2] call ALiVE_fnc_updateSectorHostility;

	// They can only be angry once
	_unit setVariable ["alreadyPissedOff", true, false];
};

if (isnil "_agent" || {!isServer}) exitwith {};

if (_distance < 50 && !(_unit getVariable ["isFleeing", false])) then {
	// Stop current command & set them to flee

	[_agent, "setActiveCommand", ["ALIVE_fnc_cc_flee", "managed", [10,20]]] call ALIVE_fnc_civilianAgent;

	_unit setVariable ["isFleeing", true, false];
};
