// ----------------------------------------------------------------------------
#include <\x\alive\addons\mil_opcom\script_component.hpp>
SCRIPT(test_OPCOM);
// ----------------------------------------------------------------------------

if !(isnil QGVAR(TEST_OPCOM)) exitwith {};

GVAR(TEST_OPCOM) = true; 

#define MAINCLASS ALiVE_fnc_OPCOM

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

LOG("Testing OPCOM");

TIMERSTART

STAT("Creating Virtual AI System...");

//Profile System
private ["_logic"];
_logic = (createGroup sideLogic) createUnit ["ALiVE_sys_profile", [0,0], [], 0, "NONE"];
_logic setVariable ["debug","true"];
_logic setVariable ["spawnRadius","1500"];
_profiles = _logic;
waituntil {!isnil "ALIVE_profileSystem"};


STAT("Creating Military Placement instance");

//Military Placement
private ["_logic"];
_logic = (createGroup sideLogic) createUnit ["ALiVE_mil_placement", [2000,2000], [], 0, "NONE"];
_logic setVariable ["faction","BLU_F"];
_logic setVariable ["debug","true"];
_MP = _logic;
waituntil {_logic getVariable ["startupComplete", false]};

STAT("Creating Military AI Commander instance");

//OPCOM
private ["_logic"];
_logic = [nil,"create"] call MAINCLASS;
_logic setvariable ["faction1","BLU_F"];
_logic setvariable ["debug","true"];
_logic synchronizeObjectsAdd [_MP];

_cond = typeof _logic == QUOTE(ADDON);
_err = "Creation of OPCOM failed";
if !(_cond) then {STAT(_err)};
ASSERT_TRUE(_cond, _err);

sleep 2;

STAT("Destroying Military AI Commander instance");
_instances = count OPCOM_instances;
_result = [_logic, "destroy"] call MAINCLASS;
_err = "Destruction of Military AI Commander failed";
if !(_instances - (count OPCOM_instances) == 1) then {STAT(_err)};
ASSERT_TRUE(_instances - (count OPCOM_instances) == 1, _err);

STAT("Waiting for FSM to end");
sleep 20;

STAT("Cleaning up MP");
_result = [_MP, "destroy"] call ALiVE_fnc_MP;
_err = "Destruction of Military Placement instance failed";
if !(isnull _MP) then {STAT(_err)};
ASSERT_TRUE(isnull _MP, _err);

sleep 2;

STAT("Destroying Virtual AI System");
_result = [ALIVE_profileSystem, "destroy"] call ALIVE_fnc_profileSystem;
_err = "Destruction of Virtual AI System failed";
if (count (ALiVE_ProfileSystem select 1) > 0) then {STAT(_err)};
ASSERT_TRUE(count (ALiVE_ProfileSystem select 1) == 0, _err);

TIMEREND

GVAR(TEST_OPCOM) = nil;