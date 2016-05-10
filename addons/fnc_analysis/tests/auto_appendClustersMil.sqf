// ----------------------------------------------------------------------------

#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(auto_appendClustersMil);

//execVM "\x\alive\addons\fnc_analysis\tests\auto_appendClustersMil.sqf"

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

if(isNil "ALIVE_civilianHQBuildingTypes") then {
	_file = format["@ALiVE\indexing\%1\x\alive\addons\main\static\%1_staticData.sqf", worldName];
	call compile preprocessFileLineNumbers _file;
};


// STAT("Create SectorGrid instance");
TIMERSTART
_grid = [nil, "create"] call ALIVE_fnc_sectorGrid;
[_grid, "init"] call ALIVE_fnc_sectorGrid;
TIMEREND


// STAT("Create Grid");
TIMERSTART
_result = [_grid, "createGrid"] call ALIVE_fnc_sectorGrid;
TIMEREND


// STAT("Create Sector Plotter");
TIMERSTART
_plotter = [nil, "create"] call ALIVE_fnc_plotSectors;
[_plotter, "init"] call ALIVE_fnc_plotSectors;
TIMEREND


DEBUGON


private ["_worldName","_file","_exportString","_gridData","_cluster","_clusterCenter","_clusterID","_sectorID","_sectorData","_consolidated"];


if(isNil "ALIVE_clustersMil" && isNil "ALIVE_loadedMilClusters") then {
	_worldName = toLower(worldName);
	_file = format["@ALiVE\indexing\%1\x\alive\addons\mil_placement\clusters\clusters.%1_mil.sqf", _worldName];
	call compile preprocessFileLineNumbers _file;
	ALIVE_loadedMilClusters = true;
};

_gridData = [] call ALIVE_fnc_hashCreate;

{
	_cluster = _x;
	_clusterCenter = [_cluster, "center"] call ALIVE_fnc_hashGet;
	_clusterID = [_cluster, "clusterID"] call ALIVE_fnc_hashGet;
	_sectorID = [_grid, "positionToGridIndex", _clusterCenter] call ALIVE_fnc_sectorGrid;
	_sectorID = format["%1_%2",_sectorID select 0, _sectorID select 1];

	if(_sectorID in (_gridData select 1)) then {
		_sectorData = [_gridData, _sectorID] call ALIVE_fnc_hashGet;
	}else{
		_sectorData = [] call ALIVE_fnc_hashCreate;
		[_sectorData, "consolidated", []] call ALIVE_fnc_hashSet;
		[_sectorData, "air", []] call ALIVE_fnc_hashSet;
		[_sectorData, "heli", []] call ALIVE_fnc_hashSet;
	};

	_consolidated = [_sectorData, "consolidated"] call ALIVE_fnc_hashGet;
	_consolidated set [count _consolidated, [_clusterCenter,_clusterID]];
	[_sectorData, "consolidated", _consolidated] call ALIVE_fnc_hashSet;

	//_sectorData call ALIVE_fnc_inspectHash;

	[_gridData, _sectorID, _sectorData] call ALIVE_fnc_hashSet;


} forEach (ALIVE_clustersMil select 2);


{
	_cluster = _x;
	_clusterCenter = [_cluster, "center"] call ALIVE_fnc_hashGet;
	_clusterID = [_cluster, "clusterID"] call ALIVE_fnc_hashGet;
	_sectorID = [_grid, "positionToGridIndex", _clusterCenter] call ALIVE_fnc_sectorGrid;
	_sectorID = format["%1_%2",_sectorID select 0, _sectorID select 1];

	if(_sectorID in (_gridData select 1)) then {
		_sectorData = [_gridData, _sectorID] call ALIVE_fnc_hashGet;
	}else{
		_sectorData = [] call ALIVE_fnc_hashCreate;
		[_sectorData, "consolidated", []] call ALIVE_fnc_hashSet;
		[_sectorData, "air", []] call ALIVE_fnc_hashSet;
		[_sectorData, "heli", []] call ALIVE_fnc_hashSet;
	};

	_air = [_sectorData, "air"] call ALIVE_fnc_hashGet;
	_air set [count _air, [_clusterCenter,_clusterID]];
	[_sectorData, "air", _air] call ALIVE_fnc_hashSet;

	//_sectorData call ALIVE_fnc_inspectHash;

	[_gridData, _sectorID, _sectorData] call ALIVE_fnc_hashSet;


} forEach (ALIVE_clustersMilAir select 2);


{
	_cluster = _x;
	_clusterCenter = [_cluster, "center"] call ALIVE_fnc_hashGet;
	_clusterID = [_cluster, "clusterID"] call ALIVE_fnc_hashGet;
	_sectorID = [_grid, "positionToGridIndex", _clusterCenter] call ALIVE_fnc_sectorGrid;
	_sectorID = format["%1_%2",_sectorID select 0, _sectorID select 1];

	if(_sectorID in (_gridData select 1)) then {
		_sectorData = [_gridData, _sectorID] call ALIVE_fnc_hashGet;
	}else{
		_sectorData = [] call ALIVE_fnc_hashCreate;
		[_sectorData, "consolidated", []] call ALIVE_fnc_hashSet;
		[_sectorData, "air", []] call ALIVE_fnc_hashSet;
		[_sectorData, "heli", []] call ALIVE_fnc_hashSet;
	};

	_heli = [_sectorData, "heli"] call ALIVE_fnc_hashGet;
	_heli set [count _heli, [_clusterCenter,_clusterID]];
	[_sectorData, "heli", _heli] call ALIVE_fnc_hashSet;

	//_sectorData call ALIVE_fnc_inspectHash;

	[_gridData, _sectorID, _sectorData] call ALIVE_fnc_hashSet;


} forEach (ALIVE_clustersMilHeli select 2);


{
	_sectorID = _x;
	_sectorData = [_gridData,_sectorID] call ALIVE_fnc_hashGet;

	_consolidatedClusters = [_sectorData, "consolidated"] call ALIVE_fnc_hashGet;
	_airClusters = [_sectorData, "air"] call ALIVE_fnc_hashGet;
	_heliClusters = [_sectorData, "heli"] call ALIVE_fnc_hashGet;

	"ALiVEClient" callExtension format['sectorData~%1|%2|_sectorData = [ALIVE_gridData, "%3"] call ALIVE_fnc_hashGet;',worldname,"mil",_sectorID];
	//_exportString = _exportString + '_sectorData = [_sector, "data"] call ALIVE_fnc_sector;';

	"ALiVEClient" callExtension format['sectorData~%1|%2|_clustersMil = [] call ALIVE_fnc_hashCreate;',worldname,"mil"];
	"ALiVEClient" callExtension format['sectorData~%1|%2|[_clustersMil,"consolidated",%3] call ALIVE_fnc_hashSet;',worldname,"mil",_consolidatedClusters];
	"ALiVEClient" callExtension format['sectorData~%1|%2|[_clustersMil,"air",%3] call ALIVE_fnc_hashSet;',worldname,"mil",_airClusters];
	"ALiVEClient" callExtension format['sectorData~%1|%2|[_clustersMil,"heli",%3] call ALIVE_fnc_hashSet;',worldname,"mil",_heliClusters];
	"ALiVEClient" callExtension format['sectorData~%1|%2|[_sectorData,"clustersMil",_clustersMil] call ALIVE_fnc_hashSet;',worldname,"mil"];

	"ALiVEClient" callExtension format['sectorData~%1|%2|[ALIVE_gridData, "%3", _sectorData] call ALIVE_fnc_hashSet;',worldname,"mil",_sectorID];

} forEach (_gridData select 1);

["Adjustment complete, military results have been written to file"] call ALIVE_fnc_dump;

nil;