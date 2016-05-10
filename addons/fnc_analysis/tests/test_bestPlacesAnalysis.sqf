// ----------------------------------------------------------------------------

#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(test_bestPlacesAnalysis);

//execVM "\x\alive\addons\fnc_analysis\tests\test_bestPlacesAnalysis.sqf"

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_timeStart","_timeEnd","_bounds","_grid","_plotter","_sector","_allSectors","_landSectors","_forestedSectors"];

LOG("Testing Best Places Analysis Object");

ASSERT_DEFINED("ALIVE_fnc_sectorGrid","");
ASSERT_DEFINED("ALIVE_fnc_sectorAnalysisBestPlaces","");

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
diag_log format["Timer End %1",_timeEnd];

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


DEBUGON


_allSectors = [_grid, "sectors"] call ALIVE_fnc_sectorGrid;
diag_log format["Sectors created: %1",count _allSectors];


STAT("Create Sector Plotter");
TIMERSTART
_plotter = [nil, "create"] call ALIVE_fnc_plotSectors;
[_plotter, "init"] call ALIVE_fnc_plotSectors;
TIMEREND


STAT("Run Terrain Analysis");
TIMERSTART
_result = [_allSectors] call ALIVE_fnc_sectorAnalysisTerrain;
TIMEREND


STAT("Filter out sea sectors");
TIMERSTART
_landSectors = [_allSectors, "SEA"] call ALIVE_fnc_sectorFilterTerrain;
TIMEREND


STAT("Run Best Places Analysis");
TIMERSTART
_result = [_landSectors] call ALIVE_fnc_sectorAnalysisBestPlaces;
TIMEREND


STAT("Plot best places analysis for land sectors");
TIMERSTART
[_plotter, "plot", [_landSectors, "bestPlaces"]] call ALIVE_fnc_plotSectors;
TIMEREND


STAT("Sleeping before clear");
sleep 40;


STAT("Clear plot instances");
[_plotter, "clear"] call ALIVE_fnc_plotSectors;


STAT("Filter sectors for only those that are forested");
TIMERSTART
_forestedSectors = [_landSectors, "forest"] call ALIVE_fnc_sectorFilterBestPlaces;
TIMEREND


STAT("Plot best places analysis for forested sectors");
TIMERSTART
[_plotter, "plot", [_forestedSectors, "bestPlaces"]] call ALIVE_fnc_plotSectors;
TIMEREND


STAT("Sleeping before destroy");
sleep 40;


STAT("Clear plot instances");
[_plotter, "clear"] call ALIVE_fnc_plotSectors;


STAT("Destroy plotter instance");
[_plotter, "destroy"] call ALIVE_fnc_plotSectors;


STAT("Destroy grid instance");
[_grid, "destroy"] call ALIVE_fnc_sectorGrid;

nil;