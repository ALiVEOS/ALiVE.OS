// ----------------------------------------------------------------------------

#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(test_loadProfilePersistance);

//execVM "\x\alive\addons\sys_profile\tests\test_loadProfilePersistence.sqf"

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_state","_result2"];

LOG("Testing Load Profile Persistance");

#define STAT(msg) sleep 3; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define TIMERSTART \
_timeStart = diag_tickTime; \
diag_log "Timer Start";

#define TIMEREND \
_timeEnd = diag_tickTime - _timeStart; \
diag_log format["Timer End %1",_timeEnd];

//========================================

["ALIVE_SYS_PROFILE","ALIVE_MIL_OPCOM","ALIVE_AMB_CIV_POPULATION","ALIVE_MIL_LOGISTICS","ALIVE_SYS_AISKILL"] call ALiVE_fnc_pauseModule;


[ALIVE_profileHandler,"reset"] call ALIVE_fnc_profileHandler;

sleep 10;

[["ALiVE_LOADINGSCREEN"],"BIS_fnc_startLoadingScreen"] call BIS_fnc_MP;
["ALiVE_LOADINGSCREEN"] call BIS_fnc_startLoadingScreen;

_profiles = [ALIVE_profileHandler,"loadProfileData"] call ALIVE_fnc_profileHandler;

//_profiles call ALIVE_fnc_inspectHash;

[ALIVE_profileHandler,"importProfileData",_profiles] call ALIVE_fnc_profileHandler;

[["ALiVE_LOADINGSCREEN"],"BIS_fnc_endLoadingScreen"] call BIS_fnc_MP;
["ALiVE_LOADINGSCREEN"] call BIS_fnc_endLoadingScreen;


["ALIVE_SYS_PROFILE","ALIVE_MIL_OPCOM","ALIVE_AMB_CIV_POPULATION","ALIVE_MIL_LOGISTICS","ALIVE_SYS_AISKILL"] call ALiVE_fnc_unPauseModule;