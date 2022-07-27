// ----------------------------------------------------------------------------

#include "\x\alive\addons\fnc_analysis\script_component.hpp"
SCRIPT(test_elevationAnalysis);

//execVM "\x\alive\addons\fnc_analysis\tests\test_elevationAnalysis.sqf"

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_timeStart","_timeEnd","_bounds","_grid","_plotter","_sector","_allSectors","_landSectors"];

LOG("Testing Elevation Analysis Object");

ASSERT_DEFINED("ALIVE_fnc_sectorGrid","");
ASSERT_DEFINED("ALIVE_fnc_sectorAnalysisElevation","");

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


STAT("Create SectorGrid instance");
TIMERSTART
_grid = [nil, "create"] call ALIVE_fnc_sectorGrid;
[_grid, "init"] call ALIVE_fnc_sectorGrid;
TIMEREND


STAT("Create Grid");
TIMERSTART
_result = [_grid, "createGrid"] call ALIVE_fnc_sectorGrid;
TIMEREND


_allSectors = [_grid, "sectors"] call ALIVE_fnc_sectorGrid;
["Sectors created: %1",count _allSectors] call ALiVE_fnc_dump;


STAT("Create Sector Plotter");
TIMERSTART
_plotter = [nil, "create"] call ALIVE_fnc_plotSectors;
[_plotter, "init"] call ALIVE_fnc_plotSectors;
TIMEREND


STAT("Run Terrain Analysis");
TIMERSTART
_result = [_allSectors] call ALIVE_fnc_sectorAnalysisTerrain;
TIMEREND


STAT("Run Elevation Analysis");
TIMERSTART
_result = [_allSectors] call ALIVE_fnc_sectorAnalysisElevation;
TIMEREND


STAT("Plot elevation analysis for all sectors");
TIMERSTART
[_plotter, "plot", [_allSectors, "elevation"]] call ALIVE_fnc_plotSectors;
TIMEREND


STAT("Sleeping before destroy");
sleep 10;


STAT("Clear plot instances");
[_plotter, "clear"] call ALIVE_fnc_plotSectors;


STAT("Filter elevation analysis for range between 100 and 200");
TIMERSTART
_highSectors = [_allSectors, 100, 200] call ALIVE_fnc_sectorFilterElevation;
TIMEREND


STAT("Sort filtered sectors by distance to player");
TIMERSTART
_sortedHighSectors = [_highSectors, getPos player] call ALIVE_fnc_sectorSortDistance;
TIMEREND


STAT("Plot elevation analysis for filtered and sorted sectors");
TIMERSTART
[_plotter, "plot", [_sortedHighSectors, "elevation"]] call ALIVE_fnc_plotSectors;
TIMEREND


STAT("Sleeping before destroy");
sleep 10;


STAT("Destroy plotter instance");
[_plotter, "destroy"] call ALIVE_fnc_plotSectors;


STAT("Destroy grid instance");
[_grid, "destroy"] call ALIVE_fnc_sectorGrid;

nil;