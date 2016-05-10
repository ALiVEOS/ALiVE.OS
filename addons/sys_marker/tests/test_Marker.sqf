// ----------------------------------------------------------------------------
#include <\x\alive\addons\sys_marker\script_component.hpp>
SCRIPT(test_Marker);
// ----------------------------------------------------------------------------

if !(isnil QGVAR(TEST_Marker)) exitwith {};

GVAR(TEST_Marker) = true; 

#define MAINCLASS ALiVE_fnc_Marker

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

LOG("Testing ALiVE markers");

TIMERSTART

STAT("Creating marker system instance...");

//Marker
private ["_logic"];
_logic = [nil,"create"] call MAINCLASS;
_logic setvariable ["debug","true"];
_err = "Creation of marker instance failed";
if !(_cond) then {STAT(_err)};
ASSERT_TRUE(typeof _logic == QUOTE(ADDON), _err);

STAT("Sleeping before destroy");
sleep 5;

STAT("Destroying marker system instance");
_result = [_logic, "destroy"] call MAINCLASS;
_err = "Destruction of marker system instance failed";
if !(true) then {STAT(_err)};
ASSERT_TRUE(true, _err);

TIMEREND

GVAR(TEST_MARKER) = nil;