// ----------------------------------------------------------------------------

#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(auto_appendClustersCiv);

//execVM "\x\alive\addons\fnc_analysis\tests\auto_appendClustersCiv.sqf"

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


if(isNil "ALIVE_clustersCiv" && isNil "ALIVE_loadedCivClusters") then {
	_worldName = toLower(worldName);
	_file = format["@ALiVE\indexing\%1\x\alive\addons\civ_placement\clusters\clusters.%1_civ.sqf", _worldName];
	call compile preprocessFileLineNumbers _file;
	ALIVE_loadedCivClusters = true;
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
		[_sectorData, "power", []] call ALIVE_fnc_hashSet;
		[_sectorData, "comms", []] call ALIVE_fnc_hashSet;
		[_sectorData, "marine", []] call ALIVE_fnc_hashSet;
		[_sectorData, "fuel", []] call ALIVE_fnc_hashSet;
		[_sectorData, "rail", []] call ALIVE_fnc_hashSet;
		[_sectorData, "construction", []] call ALIVE_fnc_hashSet;
		[_sectorData, "settlement", []] call ALIVE_fnc_hashSet;
	};

	_consolidated = [_sectorData, "consolidated"] call ALIVE_fnc_hashGet;
	_consolidated set [count _consolidated, [_clusterCenter,_clusterID]];
	[_sectorData, "consolidated", _consolidated] call ALIVE_fnc_hashSet;

	//_sectorData call ALIVE_fnc_inspectHash;

	[_gridData, _sectorID, _sectorData] call ALIVE_fnc_hashSet;


} forEach (ALIVE_clustersCiv select 2);


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
		[_sectorData, "power", []] call ALIVE_fnc_hashSet;
		[_sectorData, "comms", []] call ALIVE_fnc_hashSet;
		[_sectorData, "marine", []] call ALIVE_fnc_hashSet;
		[_sectorData, "fuel", []] call ALIVE_fnc_hashSet;
		[_sectorData, "rail", []] call ALIVE_fnc_hashSet;
		[_sectorData, "construction", []] call ALIVE_fnc_hashSet;
		[_sectorData, "settlement", []] call ALIVE_fnc_hashSet;
	};

	_power = [_sectorData, "power"] call ALIVE_fnc_hashGet;
	_power set [count _power, [_clusterCenter,_clusterID]];
	[_sectorData, "power", _power] call ALIVE_fnc_hashSet;

	//_sectorData call ALIVE_fnc_inspectHash;

	[_gridData, _sectorID, _sectorData] call ALIVE_fnc_hashSet;


} forEach (ALIVE_clustersCivPower select 2);


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
		[_sectorData, "power", []] call ALIVE_fnc_hashSet;
		[_sectorData, "comms", []] call ALIVE_fnc_hashSet;
		[_sectorData, "marine", []] call ALIVE_fnc_hashSet;
		[_sectorData, "fuel", []] call ALIVE_fnc_hashSet;
		[_sectorData, "rail", []] call ALIVE_fnc_hashSet;
		[_sectorData, "construction", []] call ALIVE_fnc_hashSet;
		[_sectorData, "settlement", []] call ALIVE_fnc_hashSet;
	};

	_comms = [_sectorData, "comms"] call ALIVE_fnc_hashGet;
	_comms set [count _comms, [_clusterCenter,_clusterID]];
	[_sectorData, "comms", _comms] call ALIVE_fnc_hashSet;

	//_sectorData call ALIVE_fnc_inspectHash;

	[_gridData, _sectorID, _sectorData] call ALIVE_fnc_hashSet;


} forEach (ALIVE_clustersCivComms select 2);


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
		[_sectorData, "power", []] call ALIVE_fnc_hashSet;
		[_sectorData, "comms", []] call ALIVE_fnc_hashSet;
		[_sectorData, "marine", []] call ALIVE_fnc_hashSet;
		[_sectorData, "fuel", []] call ALIVE_fnc_hashSet;
		[_sectorData, "rail", []] call ALIVE_fnc_hashSet;
		[_sectorData, "construction", []] call ALIVE_fnc_hashSet;
		[_sectorData, "settlement", []] call ALIVE_fnc_hashSet;
	};

	_marine = [_sectorData, "marine"] call ALIVE_fnc_hashGet;
	_marine set [count _marine, [_clusterCenter,_clusterID]];
	[_sectorData, "marine", _marine] call ALIVE_fnc_hashSet;

	//_sectorData call ALIVE_fnc_inspectHash;

	[_gridData, _sectorID, _sectorData] call ALIVE_fnc_hashSet;


} forEach (ALIVE_clustersCivMarine select 2);


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
		[_sectorData, "power", []] call ALIVE_fnc_hashSet;
		[_sectorData, "comms", []] call ALIVE_fnc_hashSet;
		[_sectorData, "marine", []] call ALIVE_fnc_hashSet;
		[_sectorData, "fuel", []] call ALIVE_fnc_hashSet;
		[_sectorData, "rail", []] call ALIVE_fnc_hashSet;
		[_sectorData, "construction", []] call ALIVE_fnc_hashSet;
		[_sectorData, "settlement", []] call ALIVE_fnc_hashSet;
	};

	_fuel = [_sectorData, "fuel"] call ALIVE_fnc_hashGet;
	_fuel set [count _fuel, [_clusterCenter,_clusterID]];
	[_sectorData, "fuel", _fuel] call ALIVE_fnc_hashSet;

	//_sectorData call ALIVE_fnc_inspectHash;

	[_gridData, _sectorID, _sectorData] call ALIVE_fnc_hashSet;


} forEach (ALIVE_clustersCivFuel select 2);


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
		[_sectorData, "power", []] call ALIVE_fnc_hashSet;
		[_sectorData, "comms", []] call ALIVE_fnc_hashSet;
		[_sectorData, "marine", []] call ALIVE_fnc_hashSet;
		[_sectorData, "fuel", []] call ALIVE_fnc_hashSet;
		[_sectorData, "rail", []] call ALIVE_fnc_hashSet;
		[_sectorData, "construction", []] call ALIVE_fnc_hashSet;
		[_sectorData, "settlement", []] call ALIVE_fnc_hashSet;
	};

	_construction = [_sectorData, "construction"] call ALIVE_fnc_hashGet;
	_construction set [count _construction, [_clusterCenter,_clusterID]];
	[_sectorData, "construction", _construction] call ALIVE_fnc_hashSet;

	//_sectorData call ALIVE_fnc_inspectHash;

	[_gridData, _sectorID, _sectorData] call ALIVE_fnc_hashSet;


} forEach (ALIVE_clustersCivConstruction select 2);


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
		[_sectorData, "power", []] call ALIVE_fnc_hashSet;
		[_sectorData, "comms", []] call ALIVE_fnc_hashSet;
		[_sectorData, "marine", []] call ALIVE_fnc_hashSet;
		[_sectorData, "fuel", []] call ALIVE_fnc_hashSet;
		[_sectorData, "rail", []] call ALIVE_fnc_hashSet;
		[_sectorData, "construction", []] call ALIVE_fnc_hashSet;
		[_sectorData, "settlement", []] call ALIVE_fnc_hashSet;
	};

	_settlement = [_sectorData, "settlement"] call ALIVE_fnc_hashGet;
	_settlement set [count _settlement, [_clusterCenter,_clusterID]];
	[_sectorData, "settlement", _settlement] call ALIVE_fnc_hashSet;

	//_sectorData call ALIVE_fnc_inspectHash;

	[_gridData, _sectorID, _sectorData] call ALIVE_fnc_hashSet;


} forEach (ALIVE_clustersCivSettlement select 2);


{
	_sectorID = _x;
	_sectorData = [_gridData,_sectorID] call ALIVE_fnc_hashGet;

	_consolidatedClusters = [_sectorData, "consolidated"] call ALIVE_fnc_hashGet;
	_powerClusters = [_sectorData, "power"] call ALIVE_fnc_hashGet;
	_commsClusters = [_sectorData, "comms"] call ALIVE_fnc_hashGet;
	_marineClusters = [_sectorData, "marine"] call ALIVE_fnc_hashGet;
	_fuelClusters = [_sectorData, "fuel"] call ALIVE_fnc_hashGet;
	_railClusters = [_sectorData, "rail"] call ALIVE_fnc_hashGet;
	_costructionClusters = [_sectorData, "construction"] call ALIVE_fnc_hashGet;
	_settlementClusters = [_sectorData, "settlement"] call ALIVE_fnc_hashGet;

	"ALiVEClient" callExtension format['sectorData~%1|%2|_sectorData = [ALIVE_gridData, "%3"] call ALIVE_fnc_hashGet;',worldname,"civ",_sectorID];
	//_exportString = _exportString + '_sectorData = [_sector, "data"] call ALIVE_fnc_sector;';

	"ALiVEClient" callExtension format['sectorData~%1|%2|_clustersCiv = [] call ALIVE_fnc_hashCreate;',worldname,"civ"];
	"ALiVEClient" callExtension format['sectorData~%1|%2|[_clustersCiv,"consolidated",%3] call ALIVE_fnc_hashSet;',worldname,"civ",_consolidatedClusters];
	"ALiVEClient" callExtension format['sectorData~%1|%2|[_clustersCiv,"power",%3] call ALIVE_fnc_hashSet;',worldname,"civ",_powerClusters];
	"ALiVEClient" callExtension format['sectorData~%1|%2|[_clustersCiv,"comms",%3] call ALIVE_fnc_hashSet;',worldname,"civ",_commsClusters];
	"ALiVEClient" callExtension format['sectorData~%1|%2|[_clustersCiv,"marine",%3] call ALIVE_fnc_hashSet;',worldname,"civ",_marineClusters];
	"ALiVEClient" callExtension format['sectorData~%1|%2|[_clustersCiv,"fuel",%3] call ALIVE_fnc_hashSet;',worldname,"civ",_fuelClusters];
	"ALiVEClient" callExtension format['sectorData~%1|%2|[_clustersCiv,"rail",%3] call ALIVE_fnc_hashSet;',worldname,"civ",_railClusters];
	"ALiVEClient" callExtension format['sectorData~%1|%2|[_clustersCiv,"construction",%3] call ALIVE_fnc_hashSet;',worldname,"civ",_costructionClusters];
	"ALiVEClient" callExtension format['sectorData~%1|%2|[_clustersCiv,"settlement",%3] call ALIVE_fnc_hashSet;',worldname,"civ",_settlementClusters];
	"ALiVEClient" callExtension format['sectorData~%1|%2|[_sectorData,"clustersCiv",_clustersCiv] call ALIVE_fnc_hashSet;',worldname,"civ"];

	"ALiVEClient" callExtension format['sectorData~%1|%2|[ALIVE_gridData, "%3", _sectorData] call ALIVE_fnc_hashSet;',worldname,"civ",_sectorID];

} forEach (_gridData select 1);

["Adjustment complete, civilian results have been written to file"] call ALIVE_fnc_dump;

nil;