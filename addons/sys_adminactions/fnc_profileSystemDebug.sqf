#include <\x\alive\addons\sys_adminactions\script_component.hpp>
SCRIPT(profileSystemDebug);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileSystemDebug

Description:
Switch on profile system debug

Examples:
(begin example)
// get vehicle type 
_result = [] call ALIVE_fnc_profileSystemDebug;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_m","_markers","_delay"];

if(isServer) then {
    ["profiles"] call ALIVE_fnc_debugHandler;
}else{
    ["server","Subject",[[1],{["profiles"] call ALIVE_fnc_debugHandler;}]] call ALiVE_fnc_BUS;
};