#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profilesSaveDataPNS);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profilesSaveDataPNS

Description:
Save profile system persistence state to ProfileNameSpace

Parameters:

Returns:
Boolean

Examples:
(begin example)
// save profile data
_result = call ALIVE_fnc_profilesSaveDataPNS;
(end)

See Also:
ALIVE_fnc_profilesLoadData

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_result"];

if !(isServer) exitwith {};

_result = [false,[]];
    
//Experimental - save to ProfileNameSpace
_exportProfiles = [ALiVE_profileHandler, "exportProfileData"] call ALiVE_fnc_ProfileHandler;
_result = [QMOD(SYS_PROFILE),_exportProfiles] call ALiVE_fnc_ProfileNameSpaceSave;

_result = [_result,["SUCCESS"]];

_result