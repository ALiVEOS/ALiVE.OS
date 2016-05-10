// ----------------------------------------------------------------------------

#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(test_mapAnalysis);

//execVM "\x\alive\addons\fnc_analysis\tests\test_sectorMapAnalysis.sqf"

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


DEBUGON


STAT("Create Sector Plotter");
TIMERSTART
_plotter = [nil, "create"] call ALIVE_fnc_plotSectors;
[_plotter, "init"] call ALIVE_fnc_plotSectors;
TIMEREND


_allSectors = [_grid, "sectors"] call ALIVE_fnc_sectorGrid;
diag_log format["Sectors created: %1",count _allSectors];


DEBUGOFF

_sectors = [];
_sectors set [count _sectors,[_grid,"gridIndexToSector",[13,15]] call ALIVE_fnc_sectorGrid];
_sectors set [count _sectors,[_grid,"gridIndexToSector",[20,14]] call ALIVE_fnc_sectorGrid];
_sectors set [count _sectors,[_grid,"gridIndexToSector",[21,14]] call ALIVE_fnc_sectorGrid];
_sectors set [count _sectors,[_grid,"gridIndexToSector",[20,15]] call ALIVE_fnc_sectorGrid];
_sectors set [count _sectors,[_grid,"gridIndexToSector",[21,15]] call ALIVE_fnc_sectorGrid];
_sectors set [count _sectors,[_grid,"gridIndexToSector",[4,15]] call ALIVE_fnc_sectorGrid];
_sectors set [count _sectors,[_grid,"gridIndexToSector",[4,17]] call ALIVE_fnc_sectorGrid];
_sectors set [count _sectors,[_grid,"gridIndexToSector",[16,19]] call ALIVE_fnc_sectorGrid];
_sectors set [count _sectors,[_grid,"gridIndexToSector",[21,19]] call ALIVE_fnc_sectorGrid];
_sectors set [count _sectors,[_grid,"gridIndexToSector",[22,20]] call ALIVE_fnc_sectorGrid];
_sectors set [count _sectors,[_grid,"gridIndexToSector",[16,10]] call ALIVE_fnc_sectorGrid];


STAT("Start static terrain analysis");
[_grid, _sectors, true, true] call ALIVE_fnc_gridMapAnalysis;


DEBUGON


//[_plotter, "plot", [_allSectors, "elevationLand"]] call ALIVE_fnc_plotSectors;
//[_plotter, "plot", [_allSectors, "elevationSea"]] call ALIVE_fnc_plotSectors;
//[_plotter, "plot", [_allSectors, "terrain"]] call ALIVE_fnc_plotSectors;
//[_plotter, "plot", [_allSectors, "bestPlaces"]] call ALIVE_fnc_plotSectors;
//[_plotter, "plot", [_allSectors, "flatEmpty"]] call ALIVE_fnc_plotSectors;
//[_plotter, "plot", [_allSectors, "terrainSamples"]] call ALIVE_fnc_plotSectors;

/*
{
	_sectorData = [_x,"data"] call ALIVE_fnc_hashGet;
	_flatEmptyData = [_sectorData,"flatEmpty"] call ALIVE_fnc_hashGet;
	
	{
		_vehicle = "B_APC_Tracked_01_rcws_F" createVehicle _x;
		_vehicle setPos _x;
	} forEach _flatEmptyData;

} forEach _allSectors;
*/


STAT("Sleeping before destroy");
sleep 60;


STAT("Destroy plotter instance");
[_plotter, "destroy"] call ALIVE_fnc_plotSectors;


STAT("Destroy grid instance");
[_grid, "destroy"] call ALIVE_fnc_sectorGrid;

nil;