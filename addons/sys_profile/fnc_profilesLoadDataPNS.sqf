#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profilesLoadDataPNS);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profilesLoadDataPNS

Description:
Load profile system persistence state from ProfileNameSpace

Parameters:
STRING - Id from former stored data

Returns:

Examples:
(begin example)
// save profile data
_result = "ALiVE_SYS_PROFILE" call ALIVE_fnc_profilesLoadDataPNS;
(end)

See Also:
ALIVE_fnc_profilesLoadData

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_result","_profiles"];

if !(isServer) exitwith {};

if (isServer) then {
        _profiles = QMOD(SYS_PROFILE) call ALiVE_fnc_ProfileNameSpaceLoad;

        if (!(isnil "_profiles") && {typename _profiles == "ARRAY"} && {count _profiles > 0} && {count (_profiles select 2) > 0}) then {

            [ALIVE_profileHandler,"reset"] call ALIVE_fnc_profileHandler;

            //_profiles call ALIVE_fnc_inspectHash;

            [ALIVE_profileHandler,"importProfileData",_profiles] call ALIVE_fnc_profileHandler;
		} else {
            ALIVE_loadProfilesPersistent = false;
        };
} else {
    ALIVE_loadProfilesPersistent = false;
};