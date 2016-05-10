#include <\x\alive\addons\sys_adminactions\script_component.hpp>
SCRIPT(agentSystemDebug);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_agentSystemDebug

Description:
Switch on agent system debug

Examples:
(begin example)
// get vehicle type 
_result = [] call ALIVE_fnc_agentSystemDebug;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_m","_markers","_delay"];

if(isServer) then {
    ["agents"] call ALIVE_fnc_debugHandler;
}else{
    ["server","Subject",[[1],{["agents"] call ALIVE_fnc_debugHandler;}]] call ALiVE_fnc_BUS;
};