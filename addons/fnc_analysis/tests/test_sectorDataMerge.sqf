// ----------------------------------------------------------------------------

#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(test_sectorDataMerge);

//execVM "\x\alive\addons\fnc_analysis\tests\test_sectorDataMerge.sqf"

// ----------------------------------------------------------------------------

private ["_createMarker","_result","_err","_grid","_timeStart","_timeEnd","_plotter","_allSectors","_playerSector","_playerSectorID","_playerSectorData"];

LOG("Testing Sector Data Sorting");

ASSERT_DEFINED("ALIVE_fnc_sectorGrid","");

#define STAT(msg) sleep 3; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define G_DEBUGON STAT("Setup debug parameters"); \
_result = [ALIVE_sectorGrid, "debug", true] call ALIVE_fnc_sectorGrid; \
_err = "enabled debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(_result, _err);

#define G_DEBUGOFF STAT("Disable debug"); \
_result = [ALIVE_sectorGrid, "debug", false] call ALIVE_fnc_sectorGrid; \
_err = "disable debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(!_result, _err);

#define P_DEBUGON STAT("Setup debug parameters"); \
_result = [ALIVE_profileHandler, "debug", true] call ALIVE_fnc_profileHandler; \
_err = "enabled debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(_result, _err);

#define P_DEBUGOFF STAT("Disable debug"); \
_result = [ALIVE_profileHandler, "debug", false] call ALIVE_fnc_profileHandler; \
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


// Setup Grid ------------------------------------------------------------------------------


STAT("Create SectorGrid instance");
TIMERSTART
ALIVE_sectorGrid = [nil, "create"] call ALIVE_fnc_sectorGrid;
[ALIVE_sectorGrid, "init"] call ALIVE_fnc_sectorGrid;
TIMEREND


STAT("Create Grid");
TIMERSTART
_result = [ALIVE_sectorGrid, "createGrid"] call ALIVE_fnc_sectorGrid;
TIMEREND


STAT("Create Sector Plotter");
TIMERSTART
_plotter = [nil, "create"] call ALIVE_fnc_plotSectors;
[_plotter, "init"] call ALIVE_fnc_plotSectors;
TIMEREND


G_DEBUGON


_allSectors = [ALIVE_sectorGrid, "sectors"] call ALIVE_fnc_sectorGrid;
diag_log format["Sectors created: %1",count _allSectors];


TIMERSTART
STAT("Start import static terrain analysis");
[ALIVE_sectorGrid, "Stratis"] call ALIVE_fnc_gridImportStaticMapAnalysis;
TIMEREND


// Merge Test -----------------------------------------------------------------------------


TIMERSTART
STAT("Start sector data merge");
_mergedData = _allSectors call ALIVE_fnc_sectorDataMerge;
TIMEREND


_mergedData call ALIVE_fnc_inspectHash;


// Cleanup --------------------------------------------------------------------------------


STAT("Sleeping before destroy");
sleep 30;


STAT("Destroy plotter instance");
[_plotter, "destroy"] call ALIVE_fnc_plotSectors;


STAT("Destroy grid instance");
[ALIVE_sectorGrid, "destroy"] call ALIVE_fnc_sectorGrid;

nil;