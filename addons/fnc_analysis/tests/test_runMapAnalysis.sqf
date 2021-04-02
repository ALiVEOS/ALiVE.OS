// ----------------------------------------------------------------------------

#include "\x\alive\addons\fnc_analysis\script_component.hpp"
SCRIPT(test_runMapAnalysis);

//execVM "\x\alive\addons\fnc_analysis\tests\test_runMapAnalysis.sqf"

// ----------------------------------------------------------------------------

private ["_result","_err","_grid","_timeStart","_timeEnd","_plotter","_allSectors"];

LOG("Testing Map Analysis");

ASSERT_DEFINED("ALIVE_fnc_sectorGrid","");

#define STAT(msg) sleep 3; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define DEBUGON STAT("Setup debug parameters"); \
_result = [_grid, "debug", true] call ALIVE_fnc_sectorGrid; \
_err = "enabled debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(_result, _err);

#define DEBUGOFF STAT("Disable debug"); \
_result = [_grid, "debug", false] call ALIVE_fnc_sectorGrid; \
_err = "disable debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(!_result, _err);

#define TIMERSTART \
_timeStart = diag_tickTime; \
diag_log "Timer Start";

#define TIMEREND \
_timeEnd = diag_tickTime - _timeStart; \
["Timer End %1",_timeEnd] call ALiVE_fnc_dump;

//========================================

call ALiVE_fnc_staticDataHandler;

_FSMtest = [] execFSM "\x\alive\addons\fnc_analysis\gridMapAnalysis.fsm";

nil;
