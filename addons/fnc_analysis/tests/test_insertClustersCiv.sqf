// ----------------------------------------------------------------------------

#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(test_unitAnalysis);

//execVM "\x\alive\addons\fnc_analysis\tests\test_insertClustersCiv.sqf"

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


DEBUGON


_allSectors = [_grid, "sectors"] call ALIVE_fnc_sectorGrid;
diag_log format["Sectors created: %1",count _allSectors];


TIMERSTART
STAT("Start import static map analysis");
[_grid, "Stratis"] call ALIVE_fnc_gridImportStaticMapAnalysis;
TIMEREND

_exportString = '';

{
	_sector = _x;
	
	STAT("Analyse Civ Clusters");
	TIMERSTART
	[[_sector]] call ALIVE_fnc_sectorAnalysisClustersCiv;
	TIMEREND
	
	_sectorData = [_sector, "data"] call ALIVE_fnc_sector;
	_sectorID = [_sector, "id"] call ALIVE_fnc_sector;
	
	_elevationSamplesLand = [_sectorData, "elevationSamplesLand"] call ALIVE_fnc_hashGet;
	_elevationSamplesSea = [_sectorData, "elevationSamplesSea"] call ALIVE_fnc_hashGet;
	
	_el = 0;
	_fe = [];
	_t = "";
	_l = [];
	_s = [];
	_sh = [];
	_f = [];
	_eh = [];
	_r = [];
	_c = [];
	_te = [];	
	
	//if("elevation" in _sectorData select 1) then {
		_el = [_sectorData, "elevation"] call ALIVE_fnc_hashGet;
	//};
	
	//if("flatEmpty" in _sectorData select 1) then {
		_fe = [_sectorData, "flatEmpty"] call ALIVE_fnc_hashGet;
	//};
	
	//if("terrain" in _sectorData select 1) then {
		_t = [_sectorData, "terrain"] call ALIVE_fnc_hashGet;
	//};
	
	//if("terrainSamples" in _sectorData select 1) then {
		_ts = [_sectorData, "terrainSamples"] call ALIVE_fnc_hashGet;
		_l = [_ts, "land"] call ALIVE_fnc_hashGet;
		_s = [_ts, "sea"] call ALIVE_fnc_hashGet;
		_sh = [_ts, "shore"] call ALIVE_fnc_hashGet;
	//};
	
	//if("bestPlaces" in _sectorData select 1) then {
		_bp = [_sectorData, "bestPlaces"] call ALIVE_fnc_hashGet;
		_f = [_bp, "forest"] call ALIVE_fnc_hashGet;	
		_eh = [_bp, "exposedHills"] call ALIVE_fnc_hashGet;
	//};
	
	//if("roads" in _sectorData select 1) then {
		_ro = [_sectorData, "roads"] call ALIVE_fnc_hashGet;
		_r = [_ro, "road"] call ALIVE_fnc_hashGet;
		_c = [_ro, "crossroad"] call ALIVE_fnc_hashGet;
		_te = [_ro, "terminus"] call ALIVE_fnc_hashGet;
	//};
		
	_sectorMilClusters = [_sectorData, "clustersMil"] call ALIVE_fnc_hashGet;
	_consolidatedClusters = [_sectorMilClusters, "consolidated"] call ALIVE_fnc_hashGet;
	_airClusters = [_sectorMilClusters, "air"] call ALIVE_fnc_hashGet;
	_heliClusters = [_sectorMilClusters, "heli"] call ALIVE_fnc_hashGet;
	
	_sectorCivClusters = [_sectorData, "clustersCiv"] call ALIVE_fnc_hashGet;
	_consolidatedCivClusters = [_sectorCivClusters, "consolidated"] call ALIVE_fnc_hashGet;
	_powerClusters = [_sectorCivClusters, "power"] call ALIVE_fnc_hashGet;
	_commsClusters = [_sectorCivClusters, "comms"] call ALIVE_fnc_hashGet;
	_marineClusters = [_sectorCivClusters, "marine"] call ALIVE_fnc_hashGet;
	_fuelClusters = [_sectorCivClusters, "fuel"] call ALIVE_fnc_hashGet;
	_railClusters = [_sectorCivClusters, "rail"] call ALIVE_fnc_hashGet;
	_constructionClusters = [_sectorCivClusters, "construction"] call ALIVE_fnc_hashGet;
	_settlementClusters = [_sectorCivClusters, "settlement"] call ALIVE_fnc_hashGet;
	
	["Sector: %1",_sectorID] call ALIVE_fnc_dump;
	
	_exportString = _exportString + '_sectorData = [] call ALIVE_fnc_hashCreate;';
		
	_exportString = _exportString + format['[_sectorData,"elevationSamplesLand",%1] call ALIVE_fnc_hashSet;',_elevationSamplesLand];
	_exportString = _exportString + format['[_sectorData,"elevationSamplesSea",%1] call ALIVE_fnc_hashSet;',_elevationSamplesSea];
	_exportString = _exportString + format['[_sectorData,"elevation",%1] call ALIVE_fnc_hashSet;',_el];	
	_exportString = _exportString + format['[_sectorData,"flatEmpty",%1] call ALIVE_fnc_hashSet;',_fe];	
	_exportString = _exportString + format['[_sectorData,"terrain","%1"] call ALIVE_fnc_hashSet;',_t];
	
	_exportString = _exportString + '_terrainSamples = [] call ALIVE_fnc_hashCreate;';		
	_exportString = _exportString + format['[_terrainSamples,"land",%1] call ALIVE_fnc_hashSet;',_l];
	_exportString = _exportString + format['[_terrainSamples,"sea",%1] call ALIVE_fnc_hashSet;',_s];
	_exportString = _exportString + format['[_terrainSamples,"shore",%1] call ALIVE_fnc_hashSet;',_sh];
	_exportString = _exportString + format['[_sectorData,"terrainSamples",_terrainSamples] call ALIVE_fnc_hashSet;'];
	
	_exportString = _exportString + '_bestPlaces = [] call ALIVE_fnc_hashCreate;';		
	_exportString = _exportString + format['[_bestPlaces,"forest",%1] call ALIVE_fnc_hashSet;',_f];
	_exportString = _exportString + format['[_bestPlaces,"exposedHills",%1] call ALIVE_fnc_hashSet;',_eh];
	/*
	_exportString = _exportString + format['[_bestPlaces,"meadow",%1] call ALIVE_fnc_hashSet;',_meadowPlaces];
	_exportString = _exportString + format['[_bestPlaces,"exposedTrees",%1] call ALIVE_fnc_hashSet;',_treePlaces];
	_exportString = _exportString + format['[_bestPlaces,"houses",%1] call ALIVE_fnc_hashSet;',_housePlaces];
	_exportString = _exportString + format['[_bestPlaces,"sea",%1] call ALIVE_fnc_hashSet;',_seaPlaces];
	*/
	_exportString = _exportString + format['[_sectorData,"bestPlaces",_bestPlaces] call ALIVE_fnc_hashSet;'];
	
	_exportString = _exportString + '_roads = [] call ALIVE_fnc_hashCreate;';
	_exportString = _exportString + format['[_roads,"road",%1] call ALIVE_fnc_hashSet;',_r];
	_exportString = _exportString + format['[_roads,"crossroad",%1] call ALIVE_fnc_hashSet;',_c];
	_exportString = _exportString + format['[_roads,"terminus",%1] call ALIVE_fnc_hashSet;',_te];
	_exportString = _exportString + format['[_sectorData,"roads",_roads] call ALIVE_fnc_hashSet;'];		
	
	_exportString = _exportString + '_clustersMil = [] call ALIVE_fnc_hashCreate;';
	_exportString = _exportString + format['[_clustersMil,"consolidated",%1] call ALIVE_fnc_hashSet;',_consolidatedClusters];
	_exportString = _exportString + format['[_clustersMil,"air",%1] call ALIVE_fnc_hashSet;',_airClusters];
	_exportString = _exportString + format['[_clustersMil,"heli",%1] call ALIVE_fnc_hashSet;',_heliClusters];
	_exportString = _exportString + format['[_sectorData,"clustersMil",_clustersMil] call ALIVE_fnc_hashSet;'];
	
	_exportString = _exportString + '_clustersCiv = [] call ALIVE_fnc_hashCreate;';
	_exportString = _exportString + format['[_clustersCiv,"consolidated",%1] call ALIVE_fnc_hashSet;',_consolidatedCivClusters];
	_exportString = _exportString + format['[_clustersCiv,"power",%1] call ALIVE_fnc_hashSet;',_powerClusters];
	_exportString = _exportString + format['[_clustersCiv,"comms",%1] call ALIVE_fnc_hashSet;',_commsClusters];
	_exportString = _exportString + format['[_clustersCiv,"marine",%1] call ALIVE_fnc_hashSet;',_marineClusters];
	_exportString = _exportString + format['[_clustersCiv,"fuel",%1] call ALIVE_fnc_hashSet;',_fuelClusters];
	_exportString = _exportString + format['[_clustersCiv,"rail",%1] call ALIVE_fnc_hashSet;',_railClusters];
	_exportString = _exportString + format['[_clustersCiv,"construction",%1] call ALIVE_fnc_hashSet;',_constructionClusters];
	_exportString = _exportString + format['[_clustersCiv,"settlement",%1] call ALIVE_fnc_hashSet;',_settlementClusters];
	_exportString = _exportString + format['[_sectorData,"clustersCiv",_clustersCiv] call ALIVE_fnc_hashSet;'];
	
	_exportString = _exportString + format['[ALIVE_gridData, "%1", _sectorData] call ALIVE_fnc_hashSet;',_sectorID];
	
	
	
} forEach _allSectors;

copyToClipboard _exportString;
["Adjustment complete, results have been copied to the clipboard"] call ALIVE_fnc_dump;


nil;