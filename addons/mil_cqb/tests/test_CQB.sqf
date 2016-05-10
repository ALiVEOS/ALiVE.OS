// ----------------------------------------------------------------------------
#include <\x\alive\addons\mil_cqb\script_component.hpp>
SCRIPT(test_CQB);
// ----------------------------------------------------------------------------

if !(isnil QGVAR(TEST_CQB)) exitwith {};

GVAR(TEST_CQB) = true; 

#define MAINCLASS ALiVE_fnc_CQB

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

LOG("Testing CQB");

TIMERSTART

STAT("Creating CQB instance");
_logic = [nil,"create"] call ALiVE_fnc_CQB;
_err = "Creation of class failed";
ASSERT_TRUE(typeName _logic == "OBJECT", _err);

STAT("Sleeping before destroy");
sleep 10;

STAT("Destroying CQB instance");
_result = [_logic, "destroy"] call MAINCLASS;
_err = "Destruction of class failed";
ASSERT_TRUE(isnil QMOD(CQB), _err);

TIMEREND

GVAR(TEST_CQB) = nil;