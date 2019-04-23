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

	[_unit, _anim] call ALIVE_fnc_switchMove;

};

if (_distance < 25) then {

	// Hostility will increase towards firer faction

	[position _unit,[str(side _firer)], -1] call ALiVE_fnc_updateSectorHostility;

};

if (isnil "_agent" || {!isServer}) exitwith {};

if (_distance < 50) then {
	// Stop current command & set them to flee
	[_agent, "setActiveCommand", ["ALIVE_fnc_cc_flee", "managed", [120,360]]] call ALIVE_fnc_civilianAgent;
};
