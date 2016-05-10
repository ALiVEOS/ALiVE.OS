// ----------------------------------------------------------------------------

#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(test_saveProfilePersistance);

//execVM "\x\alive\addons\sys_profile\tests\test_saveProfilePersistence.sqf"

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_state","_result2"];

LOG("Testing Save Profile Persistance");

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

[["ALiVE_LOADINGSCREEN"],"BIS_fnc_startLoadingScreen"] call BIS_fnc_MP;
["ALiVE_LOADINGSCREEN"] call BIS_fnc_startLoadingScreen;

[ALIVE_profileHandler,"saveProfileData"] call ALIVE_fnc_profileHandler;

[["ALiVE_LOADINGSCREEN"],"BIS_fnc_endLoadingScreen"] call BIS_fnc_MP;
["ALiVE_LOADINGSCREEN"] call BIS_fnc_endLoadingScreen;


//[ALIVE_profileHandler,"exportProfileData"] call ALIVE_fnc_profileHandler;