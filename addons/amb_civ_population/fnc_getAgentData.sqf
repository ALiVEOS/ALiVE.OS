#include <\x\alive\addons\amb_civ_population\script_component.hpp>
SCRIPT(getAgentData);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getAgentData

Description:
Get agent data from an agent object

Parameters:

Returns:
Array - empty if none found, 1 unit within if found

Examples:
(begin example)
//
_result = [] call ALIVE_fnc_getAgentData;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_agent","_agentID","_agentData","_agentProfile","_clusterID","_cluster"];

_agent = _this select 0;

_agentID = _agent getVariable ["agentID", ""];

_agentData = [];

if(_agentID != "") then {
    _agentProfile = [ALIVE_agentHandler, "getAgent", _agentID] call ALIVE_fnc_agentHandler;

    _clusterID = _agentProfile select 2 select 9;
    _cluster = [ALIVE_clusterHandler, "getCluster", _clusterID] call ALIVE_fnc_clusterHandler;

    _agentData set [0, _agentProfile select 2 select 12]; // agent posture
    _agentData set [1, _agentProfile select 2 select 10]; // home position
    _agentData set [2, _cluster select 2 select 2]; // home town center position
    _agentData set [3, _cluster select 2 select 3]; // home town radius
    _agentData set [4, _cluster select 2 select 9]; // home town posture

};

//["RESULT: %1",_agentData] call ALIVE_fnc_dump;

_agentData