// ----------------------------------------------------------------------------

#include <\x\alive\addons\mil_opcom\script_component.hpp>
SCRIPT(test_loadOPCOMobjectives);

//execVM "\x\alive\addons\mil_opcom\tests\test_loadOPCOMobjectives.sqf"

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_state","_result2"];

LOG("Testing Load OPCOM objectives");

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

private ["_resultset"];

if !(isServer) exitwith {};

_resultset = [];

[["ALiVE_LOADINGSCREEN_DATA"],"BIS_fnc_startLoadingScreen",true,false] call BIS_fnc_MP;
[true] call ALiVE_fnc_timer;
	{
		_resultset set [count _resultset,[([_x,"loadData"] call ALIVE_fnc_OPCOM)]];
	} foreach OPCOM_INSTANCES;
[] call ALiVE_fnc_timer;
{["ALiVE OPCOM LOAD DATA RESULT: %1",_x] call ALiVE_fnc_Dump} foreach _resultset;

[["ALiVE_LOADINGSCREEN_DATA"],"BIS_fnc_endLoadingScreen",true,false] call BIS_fnc_MP;

/*
//Load all including Profiles
[] spawn {
	sleep 1;
    
	["Loading Profiles..."] call ALiVE_fnc_DumpMPH;
	_handle = execVM "\x\alive\addons\sys_profile\tests\test_loadProfilePersistence.sqf";
	waituntil {scriptdone _handle};
	["Profiles loading finished..."] call ALiVE_fnc_DumpMPH;
	
	sleep 1;
	["Loading OPCOM..."] call ALiVE_fnc_DumpMPH;
	_handle = execVM "\x\alive\addons\mil_OPCOM\tests\test_loadOPCOMobjectives.sqf";
	waituntil {scriptdone _handle};
	["OPCOM loading finished..."] call ALiVE_fnc_DumpMPH;
};
*/
