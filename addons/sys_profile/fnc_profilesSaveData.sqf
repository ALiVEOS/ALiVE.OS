#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profilesSaveData);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profilesSaveData

Description:
Save profile system persistence state via sys_data

Parameters:

Returns:
Boolean

Examples:
(begin example)
// save profile data
_result = call ALIVE_fnc_profilesSaveData;
(end)

See Also:
ALIVE_fnc_profilesLoadData

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_result"];

if !(isServer) exitwith {};

_result = [false,[]];

if(ALIVE_saveProfilesPersistent) then {

    if (isDedicated) then {

        if (!isNil "ALIVE_sys_data" && {!ALIVE_sys_data_DISABLED}) then {

            if(ALiVE_SYS_DATA_DEBUG_ON) then {
                [true, "ALiVE SYS PROFILE - Saving data", "psper"] call ALIVE_fnc_timer;
            };

            if(isNil "ALiVE_sysProfileLastSaveTime" || {time - ALiVE_sysProfileLastSaveTime > 300}) then {

                ALiVE_sysProfileLastSaveTime = time;

                _result = [ALIVE_profileHandler,"saveProfileData"] call ALIVE_fnc_profileHandler;

            }else{

                if(ALiVE_SYS_DATA_DEBUG_ON) then {
                    ["ALiVE SAVE PROFILE DATA Please wait at least 5 minutes before saving again!"] call ALIVE_fnc_dumpMPH;
                };

            };

            if(ALiVE_SYS_DATA_DEBUG_ON) then {
                [false, "ALiVE SYS PROFILE - Save data complete","psper"] call ALIVE_fnc_timer;
            };

        };
    };
};

_result