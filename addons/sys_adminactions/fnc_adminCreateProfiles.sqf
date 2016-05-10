#include <\x\alive\addons\sys_adminactions\script_component.hpp>
SCRIPT(adminCreateProfiles);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_adminCreateProfiles

Description:
Create profiles of non profiled units

Examples:
(begin example)
// get vehicle type 
_result = [] call ALIVE_fnc_adminCreateProfiles;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_m","_markers","_delay"];

if(isServer) then {
    [] call ALIVE_fnc_createProfilesFromUnitsRuntime;
}else{
    ["server","Subject",[[1],{[] call ALIVE_fnc_createProfilesFromUnitsRuntime;}]] call ALiVE_fnc_BUS;
};