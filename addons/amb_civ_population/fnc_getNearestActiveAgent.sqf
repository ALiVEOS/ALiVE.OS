#include "\x\alive\addons\amb_civ_population\script_component.hpp"
SCRIPT(getNearestActiveAgent);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_getNearestActiveAgent

Description:
Find nearest active agent.

Parameters:
Array - position

Returns:
Object - Unit if one found

Examples:
(begin example)
//
_result = [_pos] call ALiVE_fnc_getNearestActiveAgent;
(end)

See Also:

Author:
Tupolov
---------------------------------------------------------------------------- */


params ["_pos"];
private _agentsActive = [ALIVE_agentHandler, "agentsActive"] call ALIVE_fnc_hashGet;
private _result = [];
private _nearAgents = [];
{
     private _agentProfile = [ALIVE_agentHandler, "getAgent", _x] call ALIVE_fnc_agentHandler;
     private _position = _agentProfile select 2 select 2;
     _nearAgents pushback [_agentProfile, _position distance _pos];
} foreach (_agentsActive select 1);

private _sortCode = {
    private _dist = _this select 1;
     _dist
};

if (count (_agentsActive select 1) > 0) then {
    _nearAgents = [_nearAgents, _sortCode] call ALiVE_fnc_shellSort;
    _result = (_nearAgents select 0) select 0;
};
_result
