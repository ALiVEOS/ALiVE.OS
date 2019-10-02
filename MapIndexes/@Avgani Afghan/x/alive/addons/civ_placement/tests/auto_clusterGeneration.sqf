// ----------------------------------------------------------------------------

#include <\x\alive\addons\civ_placement\script_component.hpp>
SCRIPT(auto_clusterGeneration);

//execVM "\x\alive\addons\civ_placement\tests\auto_clusterGeneration.sqf"

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_amo","_state","_result2"];

LOG("Testing Cluster Generation");

#define STAT(msg) sleep 0.5; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define DEBUGON STAT("Setup debug parameters"); \
_result = [_logic, "debug", true] call ALIVE_fnc_MP; \
_err = "enabled debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(_result, _err);

#define DEBUGOFF STAT("Disable debug"); \
_result = [_logic, "debug", false] call ALIVE_fnc_MP; \
_err = "disable debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(!_result, _err);

//========================================


_FSMtest = [] execFSM "\x\alive\addons\civ_placement\auto_civClusterGeneration.fsm";


nil;