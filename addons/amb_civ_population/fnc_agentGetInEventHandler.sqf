#include <\x\alive\addons\amb_civ_population\script_component.hpp>
SCRIPT(agentGetInEventHandler);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_agentGetInEventHandler

Description:
Killed event handler for agent units

Parameters:

Returns:

Examples:
(begin example)
_eventID = _agent addEventHandler["getIn", ALIVE_fnc_agentGetInEventHandler];
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private _unit = _this select 0;
private _getInUnit = _this select 2;

if(isPlayer _getInUnit) then {

    private _agentID = _unit getVariable "agentID";
    private _agent = [ALIVE_agentHandler, "getAgent", _agentID] call ALIVE_fnc_agentHandler;

    if (isnil "_agent") exitwith {};

    [ALIVE_agentHandler, "unregisterAgent", _agent] call ALIVE_fnc_agentHandler;

};