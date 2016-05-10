// ----------------------------------------------------------------------------

#include <\x\alive\addons\main\script_component.hpp>
SCRIPT(test_logic);

// ----------------------------------------------------------------------------

private ["_err","_logic","_amo"];

LOG("Testing BaseClass");

// UNIT TESTS
ASSERT_DEFINED("ALIVE_fnc_baseClass","ALIVE_fnc_baseClass is not defined!");

#define STAT(msg) sleep 1; \
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

_testIterations = 1000;
diag_log format["TEST ITERATIONS: %1", _testIterations];


_logics = [];
STAT("CREATE LOGICS STANDARD");
TIMERSTART
for "_i" from 0 to _testIterations do {	
	_pos = [0, 0, 0];
	_logic = createAgent ["LOGIC", [0,0], [], 0, "NONE"];
	_logics set [count _logics, _logic];
};
TIMEREND

STAT("SLEEP BEFORE DELETE");
SLEEP 20;

STAT("DELETE LOGICS");
TIMERSTART
{
	deleteVehicle _x;
} forEach _logics;
TIMEREND

/*
_logics = [];
STAT("CREATE LOGICS NO SIMULATION");
TIMERSTART
for "_i" from 0 to _testIterations do {	
	_pos = [0, 0, 0];
	_logic = createAgent ["LOGIC", [0,0], [], 0, "NONE"];
	_logic enableSimulation false;
	_logics set [count _logics, _logic];
};
TIMEREND

STAT("SLEEP BEFORE DELETE");
SLEEP 20;

STAT("DELETE LOGICS");
TIMERSTART
{
	deleteVehicle _x;
} forEach _logics;
TIMEREND


_logics = [];
STAT("CREATE LOGICS NO AI");
TIMERSTART
for "_i" from 0 to _testIterations do {	
	_pos = [0, 0, 0];
	_logic = createAgent ["LOGIC", [0,0], [], 0, "NONE"];
	_logic disableAI "TARGET";
	_logic disableAI "AUTOTARGET";
	_logic disableAI "MOVE";
	_logic disableAI "ANIM";
	_logic disableAI "FSM";	
	_logics set [count _logics, _logic];
};
TIMEREND

STAT("SLEEP BEFORE DELETE");
SLEEP 20;

STAT("DELETE LOGICS");
TIMERSTART
{
	deleteVehicle _x;
} forEach _logics;
TIMEREND


_logics = [];
STAT("CREATE LOGICS NO AI NO SIMULATION");
TIMERSTART
for "_i" from 0 to _testIterations do {	
	_pos = [0, 0, 0];
	_logic = createAgent ["LOGIC", [0,0], [], 0, "NONE"];
	_logic enableSimulation false;
	_logic disableAI "TARGET";
	_logic disableAI "AUTOTARGET";
	_logic disableAI "MOVE";
	_logic disableAI "ANIM";
	_logic disableAI "FSM";	
	_logics set [count _logics, _logic];
};
TIMEREND

STAT("SLEEP BEFORE DELETE");
SLEEP 20;

STAT("DELETE LOGICS");
TIMERSTART
{
	deleteVehicle _x;
} forEach _logics;
TIMEREND


_logics = [];
STAT("CREATE LOGICS NOT VISIBLE");
TIMERSTART
for "_i" from 0 to _testIterations do {	
	_pos = [0, 0, 0];
	_logic = createAgent ["LOGIC", [0,0], [], 0, "NONE"];
	hideObject _logic; 
	_logics set [count _logics, _logic];
};
TIMEREND

STAT("SLEEP BEFORE DELETE");
SLEEP 20;

STAT("DELETE LOGICS");
TIMERSTART
{
	deleteVehicle _x;
} forEach _logics;
TIMEREND
*/

nil;