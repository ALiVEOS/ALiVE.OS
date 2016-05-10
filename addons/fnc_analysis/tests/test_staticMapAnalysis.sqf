// ----------------------------------------------------------------------------

#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(test_staticMapAnalysis);

//execVM "\x\alive\addons\fnc_analysis\tests\test_staticMapAnalysis.sqf"

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


STAT("Create Sector Plotter");
TIMERSTART
_plotter = [nil, "create"] call ALIVE_fnc_plotSectors;
[_plotter, "init"] call ALIVE_fnc_plotSectors;
TIMEREND


//DEBUGON


_allSectors = [_grid, "sectors"] call ALIVE_fnc_sectorGrid;
diag_log format["Sectors created: %1",count _allSectors];


TIMERSTART
STAT("Start import static map analysis");
[_grid, "Stratis"] call ALIVE_fnc_gridImportStaticMapAnalysis;
TIMEREND


STAT("Filter out sea sectors");
TIMERSTART
_landSectors = [_allSectors, "SEA"] call ALIVE_fnc_sectorFilterTerrain;
TIMEREND


STAT("Plot mil clusters");
TIMERSTART
[_plotter, "plot", [_landSectors, "clustersMil"]] call ALIVE_fnc_plotSectors;
TIMEREND

STAT("Sleeping before clear plot");
sleep 30;


[_plotter, "clear"] call ALIVE_fnc_plotSectors;


STAT("Plot civ clusters");
TIMERSTART
[_plotter, "plot", [_landSectors, "clustersCiv"]] call ALIVE_fnc_plotSectors;
TIMEREND

STAT("Sleeping before clear plot");
sleep 30;


[_plotter, "clear"] call ALIVE_fnc_plotSectors;


STAT("Plot elevation");
TIMERSTART
[_plotter, "plot", [_allSectors, "elevation"]] call ALIVE_fnc_plotSectors;
TIMEREND


STAT("Sleeping before clear plot");
sleep 30;


[_plotter, "clear"] call ALIVE_fnc_plotSectors;


STAT("Plot terrain");
TIMERSTART
[_plotter, "plot", [_allSectors, "terrain"]] call ALIVE_fnc_plotSectors;
TIMEREND


STAT("Sleeping before clear plot");
sleep 30;


[_plotter, "clear"] call ALIVE_fnc_plotSectors;


STAT("Plot terrain samples");
TIMERSTART
[_plotter, "plot", [_landSectors, "terrainSamples"]] call ALIVE_fnc_plotSectors;
TIMEREND


STAT("Sleeping before clear plot");
sleep 30;


[_plotter, "clear"] call ALIVE_fnc_plotSectors;


STAT("Plot best places");
TIMERSTART
[_plotter, "plot", [_landSectors, "bestPlaces"]] call ALIVE_fnc_plotSectors;
TIMEREND


STAT("Sleeping before clear plot");
sleep 30;


[_plotter, "clear"] call ALIVE_fnc_plotSectors;


STAT("Plot flat empty locations");
TIMERSTART
[_plotter, "plot", [_landSectors, "flatEmpty"]] call ALIVE_fnc_plotSectors;
TIMEREND


STAT("Sleeping before clear plot");
sleep 30;


[_plotter, "clear"] call ALIVE_fnc_plotSectors;


STAT("Plot road locations");
TIMERSTART
[_plotter, "plot", [_landSectors, "roads"]] call ALIVE_fnc_plotSectors;
TIMEREND


STAT("Sleeping before clear plot");
sleep 30;


[_plotter, "clear"] call ALIVE_fnc_plotSectors;


STAT("Sleeping before destroy");
sleep 30;


STAT("Destroy plotter instance");
[_plotter, "destroy"] call ALIVE_fnc_plotSectors;


STAT("Destroy grid instance");
[_grid, "destroy"] call ALIVE_fnc_sectorGrid;

nil;