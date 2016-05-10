// ----------------------------------------------------------------------------

#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(test_battlefieldAnalysis);

//execVM "\x\alive\addons\fnc_analysis\tests\test_battlefieldAnalysis.sqf"

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_timeStart","_timeEnd","_bounds","_grid","_plotter","_sector","_allSectors","_landSectors"];

LOG("Testing Unit Analysis Object");

ASSERT_DEFINED("ALIVE_fnc_sectorGrid","");
ASSERT_DEFINED("ALIVE_fnc_sectorAnalysisUnits","");

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

private ["_activeSectors","_casualtySectors"];



STAT("Sleeping before clear plot");
sleep 5;
[ALIVE_sectorPlotter, "clear"] call ALIVE_fnc_plotSectors;
sleep 5;



STAT("Plot casualty sectors");

_casualtySectors = [ALIVE_battlefieldAnalysis, "getCasualtySectors"] call ALIVE_fnc_battlefieldAnalysis;

[ALIVE_sectorPlotter, "plot", [(_casualtySectors select 2), "casualties"]] call ALIVE_fnc_plotSectors;



STAT("Sleeping before clear plot");
sleep 20;
[ALIVE_sectorPlotter, "clear"] call ALIVE_fnc_plotSectors;
sleep 5;



STAT("Plot active sectors");

_activeSectors = [ALIVE_battlefieldAnalysis, "getActiveSectors"] call ALIVE_fnc_battlefieldAnalysis;

[ALIVE_sectorPlotter, "plot", [(_activeSectors select 2), "activeClusters"]] call ALIVE_fnc_plotSectors;







nil;