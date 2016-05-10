// ----------------------------------------------------------------------------
#include <\x\alive\addons\main\script_component.hpp>
SCRIPT(test_RequireALiVE);
// ----------------------------------------------------------------------------

if !(isnil QGVAR(TEST_RequireALiVE)) exitwith {};

GVAR(TEST_RequireALiVE) = true; 

#define MAINCLASS ALiVE_fnc_ALiVEInit

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_state","_result2"];

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

LOG("Testing ALiVE Require");

TIMERSTART

STAT("Creating Require ALiVE instance...");

//RequireALiVE
private ["_logic","_timeout"];
_err = "Creation of RequireALiVE instance failed, timed out";
_time = time;

[] spawn MAINCLASS;

waituntil {
    _timeout = time - _time > 20;
    
    (
	    !isnil "ALiVE_SYS_LOGISTICS" &&
	    {!isnil "ALiVE_SYS_GC"} &&
	    {!isnil "ALiVE_SYS_MARKER"} &&
        {!isnil "ALiVE_SYS_NEWSFEED"} &&
        {!isnil "ALiVE_SYS_ADMINACTIONS"} &&
        {!isnil "ALiVE_SYS_SPOTREP"} &&
        {!isnil "ALiVE_Require"}
    ) ||
    {_timeout}
};

if (_timeout) then {STAT(_err)};
ASSERT_TRUE(!_timeout, _err);

STAT("Sleeping before destroy");
sleep 5;

STAT("Destroying created module instances");
{
    private ["_logic"];
    
    _logic = _x select 0;
    _fnc = _x select 1;
    _type = typeOf _logic;

    _err = format["Destruction of %1 system instance failed",_type];
	_succ = format["Destruction of %1 system instance completed",_type];
    
    [_logic,"destroy",true] call _fnc;
    
    sleep 3;
    
    ASSERT_TRUE(isnull _logic, _err);
    if (isnull _logic) then {STAT(_succ)};
} foreach [
	[ALiVE_SYS_LOGISTICS, ALiVE_fnc_Logistics],
	[ALiVE_SYS_GC, ALiVE_fnc_GC],
	[ALiVE_SYS_NEWSFEED, ALiVE_fnc_NewsFeed],
	[ALiVE_SYS_ADMINACTIONS, ALiVE_fnc_AdminActions],
	[ALiVE_SYS_SPOTREP, ALiVE_fnc_SpotRep],
	[ALiVE_SYS_MARKER, ALiVE_fnc_Marker]
];

ALiVE_SYS_LOGISTICS = nil;
ALiVE_SYS_GC = nil;
ALiVE_SYS_NEWSFEED = nil;
ALiVE_SYS_ADMINACTIONS = nil;
ALiVE_SYS_SPOTREP = nil;
ALiVE_SYS_MARKER = nil;

STAT("Destroying Event log");
[ALIVE_eventLog, "destroy"] call ALIVE_fnc_eventLog;
ALIVE_eventLog = nil;

STAT("Destroying Require ALiVE instances");
ALiVE_Require setVariable ["init", nil];
ALiVE_Require setVariable ["startupComplete", nil, true];

deletevehicle ALiVE_Require;
deletegroup (group ALiVE_Require);
ALiVE_Require = nil;

TIMEREND

GVAR(TEST_RequireALiVE) = nil;