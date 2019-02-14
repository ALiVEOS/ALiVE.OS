#include "\x\alive\addons\amb_civ_population\script_component.hpp"
SCRIPT(agentKilledEventHandler);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_agentKilledEventHandler

Description:
Killed event handler for agent units

Parameters:

Returns:

Examples:
(begin example)
_eventID = _agent addEventHandler["Killed", ALIVE_fnc_agentKilledEventHandler];
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

params ["_unit","_killer"];

private _agentID = _unit getVariable "agentID";
private _agent = [ALIVE_agentHandler, "getAgent", _agentID] call ALIVE_fnc_agentHandler;

[_unit,""] call ALIVE_fnc_switchMove;

private _killerSide = str(side (group _killer));

if (isnil "_agent" || {!isServer}) exitwith {};

[_agent, "handleDeath"] call ALIVE_fnc_civilianAgent;

[ALIVE_agentHandler, "unregisterAgent", _agent] call ALIVE_fnc_agentHandler;

// log event

private _position = getPosASL _unit;
private _faction = _agent select 2 select 7;
private _side = _agent select 2 select 8;

private _event = ['AGENT_KILLED', [_position,_faction,_side,_killerSide],"Agent"] call ALIVE_fnc_event;
private _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;