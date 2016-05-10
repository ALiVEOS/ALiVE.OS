// ----------------------------------------------------------------------------

#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(test_analysisData);

//execVM "\x\alive\addons\fnc_analysis\tests\test_analysisData.sqf"

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_timeStart","_timeEnd","_bounds","_grid","_plotter","_sector","_surroundingSectors","_allSectors","_landSectors"];

LOG("Testing Analysis Data");

ASSERT_DEFINED("ALIVE_fnc_sectorGrid","");
ASSERT_DEFINED("ALIVE_fnc_sectorAnalysisUnits","");
ASSERT_DEFINED("ALIVE_fnc_sectorAnalysisTerrain","");
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
diag_log format["Timer End %1",_timeEnd];

//========================================

STAT("Create Profile Handler");
ALIVE_profileHandler = [nil, "create"] call ALIVE_fnc_profileHandler;
[ALIVE_profileHandler, "init"] call ALIVE_fnc_profileHandler;


STAT("Create profiles from editor placed units");
[true] call ALIVE_fnc_createProfilesFromUnits;


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


STAT("Get Surrounding Sectors");
_surroundingSectors = [_grid, "surroundingSectors", getPos player] call ALIVE_fnc_sectorGrid;
_err = "set surroundingSectors";
ASSERT_TRUE(typeName _surroundingSectors == "ARRAY", _err);


{
	if!(count _x == 0) then
	{
		[_x, "debug", false] call ALIVE_fnc_sector;
	}
	
} forEach _surroundingSectors;


_allSectors = [_grid, "sectors"] call ALIVE_fnc_sectorGrid;
diag_log format["Sectors created: %1",count _allSectors];


STAT("Run Profile Analysis");
TIMERSTART
_result = [_grid] call ALIVE_fnc_gridAnalysisProfiles;
TIMEREND


STAT("Run Terrain Analysis");
TIMERSTART
_result = [_surroundingSectors] call ALIVE_fnc_sectorAnalysisTerrain;
TIMEREND


STAT("Run Elevation Analysis");
TIMERSTART
_result = [_surroundingSectors] call ALIVE_fnc_sectorAnalysisElevation;
TIMEREND


STAT("Run Unit Analysis");
TIMERSTART
_result = [_surroundingSectors] call ALIVE_fnc_sectorAnalysisUnits;
TIMEREND


STAT("Run Best Places Analysis");
TIMERSTART
_result = [_surroundingSectors] call ALIVE_fnc_sectorAnalysisBestPlaces;
TIMEREND


STAT("Output sector data");
{
	_sector = _x;
	_sectorData = [_sector, "data"] call ALIVE_fnc_sector;
	_id = [_sector, "id"] call ALIVE_fnc_sector;
	diag_log format["Sector: %1",_id];
	_sectorData call ALIVE_fnc_inspectHash;
} forEach _surroundingSectors;


STAT("Sleeping before destroy");
sleep 10;


STAT("Destroy grid instance");
[_grid, "destroy"] call ALIVE_fnc_sectorGrid;

nil;