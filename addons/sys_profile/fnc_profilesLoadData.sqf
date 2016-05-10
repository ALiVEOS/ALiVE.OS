#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profilesLoadData);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profilesLoadData

Description:
Load profile system persistence state via sys_data

Parameters:

Returns:

Examples:
(begin example)
// save profile data
_result = call ALIVE_fnc_profilesLoadData;
(end)

See Also:
ALIVE_fnc_profilesLoadData

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_result","_profiles"];

if !(isServer) exitwith {};

_result = false;

if(ALIVE_loadProfilesPersistent) then {

    if (isDedicated) then {

        if (!isNil "ALIVE_sys_data" && {!ALIVE_sys_data_DISABLED}) then {

            if(ALiVE_SYS_DATA_DEBUG_ON) then {
                [true, "ALiVE Profile System persistence load data started", "psper"] call ALIVE_fnc_timer;
            };

            /*
            [["ALiVE_LOADINGSCREEN"],"BIS_fnc_startLoadingScreen",true,false] call BIS_fnc_MP;
            */

            //["ALIVE_SYS_PROFILE","ALIVE_MIL_OPCOM","ALIVE_AMB_CIV_POPULATION","ALIVE_MIL_LOGISTICS","ALIVE_SYS_AISKILL"] call ALiVE_fnc_pauseModule;

            if(isNil "ALiVE_sysProfileLastLoadTime" || {time - ALiVE_sysProfileLastLoadTime > 300}) then {

                ALiVE_sysProfileLastLoadTime = time;

                _profiles = [ALIVE_profileHandler,"loadProfileData"] call ALIVE_fnc_profileHandler;

                if (!(isnil "_profiles") && {typename _profiles == "ARRAY"} && {count _profiles > 0} && {count (_profiles select 2) > 0}) then {

                    ALiVE_sysProfileLastLoadTime = time;

                    [ALIVE_profileHandler,"reset"] call ALIVE_fnc_profileHandler;

                    //_profiles call ALIVE_fnc_inspectHash;

                    [ALIVE_profileHandler,"importProfileData",_profiles] call ALIVE_fnc_profileHandler;

                }else{

                    if(ALiVE_SYS_DATA_DEBUG_ON) then {
                        ["ALiVE LOAD PROFILE DATA No data loaded setting persistence false"] call ALIVE_fnc_dump;
                    };

                    ALIVE_loadProfilesPersistent = false;

                };

            }else{

                if(ALiVE_SYS_DATA_DEBUG_ON) then {
                    ["ALiVE SAVE PROFILE DATA Please wait at least 5 minutes before saving again!"] call ALIVE_fnc_dump;
                };

            };

            //["ALIVE_SYS_PROFILE","ALIVE_MIL_OPCOM","ALIVE_AMB_CIV_POPULATION","ALIVE_MIL_LOGISTICS","ALIVE_SYS_AISKILL"] call ALiVE_fnc_unPauseModule;

            /*
            [["ALiVE_LOADINGSCREEN"],"BIS_fnc_endLoadingScreen",true,false] call BIS_fnc_MP;
            */

            if(ALiVE_SYS_DATA_DEBUG_ON) then {
                [false, "ALiVE Profile System persistence load data complete","psper"] call ALIVE_fnc_timer;
            };
        }else{

            if(ALiVE_SYS_DATA_DEBUG_ON) then {
                ["ALiVE LOAD PROFILE DATA SYS DATA DOES NOT EXIST"] call ALIVE_fnc_dumpMPH;
            };

            ALIVE_loadProfilesPersistent = false;

        };
    }else{

        if(ALiVE_SYS_DATA_DEBUG_ON) then {
            ["ALiVE LOAD PROFILE DATA Not run on dedicated server exiting"] call ALIVE_fnc_dump;
        };

        ALIVE_loadProfilesPersistent = false;
    };
};

_result