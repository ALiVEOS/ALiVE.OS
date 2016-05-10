// ----------------------------------------------------------------------------

#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(test_command);

//execVM "\x\alive\addons\mil_command\tests\test_commandRouter.sqf"

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_state","_result2","_m","_markers","_worldMarkers"];

LOG("Testing Command Router Object");

ASSERT_DEFINED("ALIVE_fnc_sector","");

#define STAT(msg) sleep 3; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define DEBUGON STAT("Setup debug parameters"); \
_result = [_logic, "debug", true] call ALIVE_fnc_sector; \
_err = "enabled debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(_result, _err);

#define DEBUGOFF STAT("Disable debug"); \
_result = [_logic, "debug", false] call ALIVE_fnc_sector; \
_err = "disable debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(!_result, _err);

#define TIMERSTART \
_timeStart = diag_tickTime; \
diag_log "Timer Start";

#define TIMEREND \
_timeEnd = diag_tickTime - _timeStart; \
diag_log format["Timer End %1",_timeEnd];

//========================================


_profile = [ALIVE_profileHandler, "getProfile", "entity_0"] call ALIVE_fnc_profileHandler;

//[_profile, "addActiveCommand", ["testCommand","fsm",["param1","param2"]]] call ALIVE_fnc_profileEntity;
//[_profile, "addActiveCommand", ["ALIVE_fnc_testCommand","spawn",["param1","param2"]]] call ALIVE_fnc_profileEntity;
[_profile, "addActiveCommand", ["ALIVE_fnc_testManagedCommand","managed",["param1","param2"]]] call ALIVE_fnc_profileEntity;

STAT("De-Spawn");
[_profile, "despawn"] call ALIVE_fnc_profileEntity;

sleep 10;

STAT("De-Spawn");
[_profile, "despawn"] call ALIVE_fnc_profileEntity;

nil;