// ----------------------------------------------------------------------------

#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(auto_runMapAnalysis);

//execVM "\x\alive\addons\fnc_analysis\tests\auto_runMapAnalysis.sqf"

// ----------------------------------------------------------------------------

private ["_result","_err","_grid","_timeStart","_timeEnd","_plotter","_allSectors","_filetest","_FSMtest"];

LOG("Testing Map Analysis");

ASSERT_DEFINED("ALIVE_fnc_sectorGrid","");

#define STAT(msg) sleep 3; \
diag_log ["TEST("+str player+": "+msg]; \
// titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
// titleText [msg,"PLAIN"]

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
diag_log format["Timer End %1",_timeEnd];

//========================================

_filetest = format["@ALiVE\indexing\%1\x\alive\addons\main\static\%1_staticData.sqf", worldName];

diag_log format["COMPILING STATIC DATA %1", _filetest];

call compile preprocessFileLineNumbers _filetest;

diag_log format["COMPILED STATIC DATA - Civ Construction: %1", ALIVE_civilianConstructionBuildingTypes];

diag_log format["RUNNING AUTO GRID MAP ANALYSIS SQF NOW... %1", time];

_FSMtest = [] execFSM "\x\alive\addons\fnc_analysis\auto_gridMapAnalysis.fsm";


nil;