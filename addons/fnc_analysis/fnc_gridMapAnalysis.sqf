#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(gridMapAnalysis);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_gridMapAnalysis

Description:
Perform analysis of terrain for a grid

Parameters:
Grid - the grid to run the map analysis on
Bool - export - exports the results of the analysis to the clipboard once completed
Bool - debug - debug mode

Returns:
...

Examples:
(begin example)
// analyse
_result = [_grid] call ALIVE_fnc_gridMapAnalysis;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_grid","_export","_debug","_sectors","_exportString","_subGridRoads","_sector","_sectorData","_sectorID","_subGrid","_subGridSectors"];

_grid = _this select 0;
_sectors = _this select 1;
_export = if(count _this > 2) then {_this select 2} else {false};
_debug = if(count _this > 3) then {_this select 3} else {false};

// reset existing analysis data
if(count _sectors == 0) then {
	_sectors = [_grid, "sectors"] call ALIVE_fnc_sectorGrid;
};

if(_export) then {
	_exportString = 'ALIVE_gridData = [] call ALIVE_fnc_hashCreate;';
};

// DEBUG -------------------------------------------------------------------------------------
if(_debug) then {
	["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
	["ALIVE Starting Map Analysis"] call ALIVE_fnc_dump;
};
// DEBUG -------------------------------------------------------------------------------------

{
	_sector = _x;
	_sectorData = [_sector, "data"] call ALIVE_fnc_sector;
	_sectorID = [_sector, "id"] call ALIVE_fnc_sector;
	
	[_sector, "debug", true] call ALIVE_fnc_sector;
	
	// DEBUG -------------------------------------------------------------------------------------
	if(_debug) then {
		["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
		["Map Analysis sector [%1] creating sub dividing grid",_sectorID] call ALIVE_fnc_dump;
		[true] call ALIVE_fnc_timer;
	};
	// DEBUG -------------------------------------------------------------------------------------
	
	_subGrid = [_sector,10,format["Grid_%1",_forEachIndex]] call ALIVE_fnc_sectorSubGrid;
	_subGridSectors = [_subGrid, "sectors"] call ALIVE_fnc_sectorGrid;
	
	// DEBUG -------------------------------------------------------------------------------------
	if(_debug) then {		
		["sub dividing grid created"] call ALIVE_fnc_dump;
		[] call ALIVE_fnc_timer;
		["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
		["start terrain analysis"] call ALIVE_fnc_dump;
		[true] call ALIVE_fnc_timer;
	};
	// DEBUG -------------------------------------------------------------------------------------
		
	[_subGridSectors] call ALIVE_fnc_sectorAnalysisTerrain;
	
	// DEBUG -------------------------------------------------------------------------------------
	if(_debug) then {
		["terrain analysis completed"] call ALIVE_fnc_dump;
		[] call ALIVE_fnc_timer;
		["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
		["start elevation analysis"] call ALIVE_fnc_dump;
		[true] call ALIVE_fnc_timer;
	};
	// DEBUG -------------------------------------------------------------------------------------
	
	[_subGridSectors] call ALIVE_fnc_sectorAnalysisElevation;
	
	// copy all sub grid sector data into this parent sector data
	
	private ["_elevationSamples","_elevationSamplesLand","_elevationSamplesSea","_elevation","_terrainSamples","_terrain","_landTerrain","_shoreTerrain","_seaTerrain",
	"_forestPlaces","_hillPlaces","_meadowPlaces","_treePlaces","_housePlaces","_seaPlaces",
	"_flatEmptySamples","_roadSamples","_crossroadSamples","_terminusSamples","_bestPlaces","_roads","_terrainSamples","_currentElevation"];
	
	_elevationSamplesLand = [];

	_elevation = 0;
	_elevationSamples = [];
	_terrain = "";
	_landTerrain = [];
	_shoreTerrain = [];
	_seaTerrain = [];
	_forestPlaces = [];
	_hillPlaces = [];
	/*
	_meadowPlaces = [];
	_treePlaces = [];
	_housePlaces = [];
	_seaPlaces = [];
	*/
	_flatEmptySamples = [];
	_roadSamples = [];
	_crossroadSamples = [];
	_terminusSamples = [];	
	
	{
		private ["_subGridSector","_subGridSectorData","_subGridElevationSamples","_subGridTerrainSamples","_subGridLand","_subGridShore","_subGridSea"];
		
		_subGridSector = _x;
		_subGridSectorData = [_subGridSector, "data"] call ALIVE_fnc_sector;
		_subGridElevationSamples = [_subGridSectorData, "elevationSamples"] call ALIVE_fnc_hashGet;
		_subGridTerrainSamples = [_subGridSectorData, "terrainSamples"] call ALIVE_fnc_hashGet;
		
		_subGridLand = [_subGridTerrainSamples, "land"] call ALIVE_fnc_hashGet;
		_subGridShore = [_subGridTerrainSamples, "shore"] call ALIVE_fnc_hashGet;
		_subGridSea = [_subGridTerrainSamples, "sea"] call ALIVE_fnc_hashGet;
		
		_landTerrain = _landTerrain + _subGridLand;
		_shoreTerrain = _shoreTerrain + _subGridShore;
		_seaTerrain = _seaTerrain + _subGridSea;
		
		_elevationSamples = _elevationSamples + _subGridElevationSamples;
		
	} forEach _subGridSectors;
	
	_elevationSamplesLand = [];
	_elevationSamplesSea = [];
	
	// calculate average elevation for the sector
	{
		_currentElevation = _x select 1;
		_elevation = _elevation + _currentElevation;
		if(_currentElevation >= 0) then {
			_elevationSamplesLand set [count _elevationSamplesLand, _x];
		}else{
			_elevationSamplesSea set [count _elevationSamplesSea, _x];
		};
	} forEach _elevationSamples;
	
	_elevation = _elevation / ((count _elevationSamples)-1);
	
	["L: %1",_landTerrain] call ALIVE_fnc_dump;
	["S: %1",_shoreTerrain] call ALIVE_fnc_dump;
	["SEA: %1",_seaTerrain] call ALIVE_fnc_dump;
	
	// determine terrain type
	if((count _landTerrain == 0) && (count _shoreTerrain == 0) && (count _seaTerrain > 0)) then {
		_terrain = "SEA";
	};
	
	if((count _shoreTerrain > 0) && (count _seaTerrain > 0)) then {
		_terrain = "SHORE";
	};
	
	if((count _landTerrain > 0) && (count _shoreTerrain == 0) && (count _seaTerrain == 0)) then {
		_terrain = "LAND";
	};	
	
	if((count _landTerrain > 0) && (count _shoreTerrain > 0) && (count _seaTerrain == 0)) then {
		_terrain = "LAND";
	};
	
	if(_terrain == "SHORE" || _terrain == "LAND") then {
		
		// DEBUG -------------------------------------------------------------------------------------
		if(_debug) then {
			["elevation analysis completed"] call ALIVE_fnc_dump;
			[] call ALIVE_fnc_timer;
			["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
			["start best places analysis"] call ALIVE_fnc_dump;
			[true] call ALIVE_fnc_timer;
		};
		// DEBUG -------------------------------------------------------------------------------------
		
		[_subGridSectors,2] call ALIVE_fnc_sectorAnalysisBestPlaces;
		
		// DEBUG -------------------------------------------------------------------------------------
		if(_debug) then {
			["best places analysis completed"] call ALIVE_fnc_dump;
			[] call ALIVE_fnc_timer;
			["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
			["start flat empty analysis"] call ALIVE_fnc_dump;
			[true] call ALIVE_fnc_timer;
		};
		// DEBUG -------------------------------------------------------------------------------------
		
		[_subGridSectors] call ALIVE_fnc_sectorAnalysisFlatEmpty;
		
		// DEBUG -------------------------------------------------------------------------------------
		if(_debug) then {
			["flat empty analysis completed"] call ALIVE_fnc_dump;
			[] call ALIVE_fnc_timer;
			["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
			["start road analysis"] call ALIVE_fnc_dump;
			[true] call ALIVE_fnc_timer;
		};
		// DEBUG -------------------------------------------------------------------------------------
		
		[_subGridSectors] call ALIVE_fnc_sectorAnalysisRoads;
		
		// DEBUG -------------------------------------------------------------------------------------
		if(_debug) then {
			["road analysis completed"] call ALIVE_fnc_dump;
			[] call ALIVE_fnc_timer;
			["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
			["start compilation of sub sector data into parent sector"] call ALIVE_fnc_dump;
			[true] call ALIVE_fnc_timer;
		};
		// DEBUG -------------------------------------------------------------------------------------
		
		// copy all sub grid sector data into this parent sector data
		{
			private ["_subGridSector","_subGridSectorData","_subGridFlatEmptySamples","_subGridRoadSamples","_subGridRoad","_subGridCrossroad","_subGridTerminus",
			"_subGridBestPlaces","_subGridForestPlaces","_subGridHillPlaces","_subGridMeadowPlaces","_subGridTreePlaces","_subGridHousePlaces","_subGridSeaPlaces","_countIsWater"];
			
			_subGridSector = _x;
			_subGridSectorData = [_subGridSector, "data"] call ALIVE_fnc_sector;
			_subGridFlatEmptySamples = [_subGridSectorData, "flatEmpty"] call ALIVE_fnc_hashGet;
			_subGridRoads = [_subGridSectorData, "roads"] call ALIVE_fnc_hashGet;
			_subGridBestPlaces = [_subGridSectorData, "bestPlaces"] call ALIVE_fnc_hashGet;
			
			_subGridForestPlaces = [_subGridBestPlaces, "forest"] call ALIVE_fnc_hashGet;
			_subGridHillPlaces = [_subGridBestPlaces, "exposedHills"] call ALIVE_fnc_hashGet;
			/*
			_subGridMeadowPlaces = [_subGridBestPlaces, "meadow"] call ALIVE_fnc_hashGet;
			_subGridTreePlaces = [_subGridBestPlaces, "exposedTrees"] call ALIVE_fnc_hashGet;
			_subGridHousePlaces = [_subGridBestPlaces, "houses"] call ALIVE_fnc_hashGet;
			_subGridSeaPlaces = [_subGridBestPlaces, "sea"] call ALIVE_fnc_hashGet;
			*/
			
			_subGridRoad = [_subGridRoads, "road"] call ALIVE_fnc_hashGet;
			_subGridCrossroad = [_subGridRoads, "crossroad"] call ALIVE_fnc_hashGet;
			_subGridTerminus = [_subGridRoads, "terminus"] call ALIVE_fnc_hashGet;
			
			_forestPlaces = _forestPlaces + _subGridForestPlaces;
			_hillPlaces = _hillPlaces + _subGridHillPlaces;
			/*
			_meadowPlaces = _meadowPlaces + _subGridMeadowPlaces;
			_treePlaces = _treePlaces + _subGridTreePlaces;
			_housePlaces = _housePlaces + _subGridHousePlaces;
			_seaPlaces = _seaPlaces + _subGridSeaPlaces;
			*/
			
			_roadSamples = _roadSamples + _subGridRoad;
			_crossroadSamples = _crossroadSamples + _subGridCrossroad;
			_terminusSamples = _terminusSamples + _subGridTerminus;
			
			if(count (_subGridFlatEmptySamples select 0) > 0) then {
				_flatEmptySamples = _flatEmptySamples + _subGridFlatEmptySamples;
			};
			
		} forEach _subGridSectors;
		
	};	
	
	// store all data
	
	_terrainSamples = [] call ALIVE_fnc_hashCreate;
	[_terrainSamples,"land",_landTerrain] call ALIVE_fnc_hashSet;
	[_terrainSamples,"sea",_seaTerrain] call ALIVE_fnc_hashSet;
	[_terrainSamples,"shore",_shoreTerrain] call ALIVE_fnc_hashSet;
	
	_bestPlaces = [] call ALIVE_fnc_hashCreate;
	[_bestPlaces,"forest",_forestPlaces] call ALIVE_fnc_hashSet;
	[_bestPlaces,"exposedHills",_hillPlaces] call ALIVE_fnc_hashSet;
	/*
	[_bestPlaces,"meadow",_meadowPlaces] call ALIVE_fnc_hashSet;
	[_bestPlaces,"exposedTrees",_treePlaces] call ALIVE_fnc_hashSet;
	[_bestPlaces,"houses",_housePlaces] call ALIVE_fnc_hashSet;
	[_bestPlaces,"sea",_seaPlaces] call ALIVE_fnc_hashSet;
	*/
	
	_roads = [] call ALIVE_fnc_hashCreate;
	[_roads,"road",_roadSamples] call ALIVE_fnc_hashSet;
	[_roads,"crossroad",_crossroadSamples] call ALIVE_fnc_hashSet;
	[_roads,"terminus",_terminusSamples] call ALIVE_fnc_hashSet;
	
	[_sectorData, "elevationSamplesLand",_elevationSamplesLand] call ALIVE_fnc_hashSet;
	[_sectorData, "elevationSamplesSea",_elevationSamplesSea] call ALIVE_fnc_hashSet;
	[_sectorData, "elevation",_elevation] call ALIVE_fnc_hashSet;
	[_sectorData, "terrainSamples",_terrainSamples] call ALIVE_fnc_hashSet;
	[_sectorData, "terrain",_terrain] call ALIVE_fnc_hashSet;
	[_sectorData, "flatEmpty",_flatEmptySamples] call ALIVE_fnc_hashSet;
	[_sectorData, "roads",_roads] call ALIVE_fnc_hashSet;
	[_sectorData, "bestPlaces",_bestPlaces] call ALIVE_fnc_hashSet;	
	
	[_sector, "data", _sectorData] call ALIVE_fnc_hashSet;
	
	
	if(_export) then {
		_exportString = _exportString + '_sectorData = [] call ALIVE_fnc_hashCreate;';
		
		_exportString = _exportString + format['[_sectorData,"elevationSamplesLand",%1] call ALIVE_fnc_hashSet;',_elevationSamplesLand];
		_exportString = _exportString + format['[_sectorData,"elevationSamplesSea",%1] call ALIVE_fnc_hashSet;',_elevationSamplesSea];
		_exportString = _exportString + format['[_sectorData,"elevation",%1] call ALIVE_fnc_hashSet;',_elevation];
		
		_exportString = _exportString + format['[_sectorData,"flatEmpty",%1] call ALIVE_fnc_hashSet;',_flatEmptySamples];
		
		_exportString = _exportString + format['[_sectorData,"terrain","%1"] call ALIVE_fnc_hashSet;',_terrain];
		
		_exportString = _exportString + '_terrainSamples = [] call ALIVE_fnc_hashCreate;';		
		_exportString = _exportString + format['[_terrainSamples,"land",%1] call ALIVE_fnc_hashSet;',_landTerrain];
		_exportString = _exportString + format['[_terrainSamples,"sea",%1] call ALIVE_fnc_hashSet;',_seaTerrain];
		_exportString = _exportString + format['[_terrainSamples,"shore",%1] call ALIVE_fnc_hashSet;',_shoreTerrain];
		_exportString = _exportString + format['[_sectorData,"terrainSamples",_terrainSamples] call ALIVE_fnc_hashSet;'];
		
		_exportString = _exportString + '_bestPlaces = [] call ALIVE_fnc_hashCreate;';		
		_exportString = _exportString + format['[_bestPlaces,"forest",%1] call ALIVE_fnc_hashSet;',_forestPlaces];
		_exportString = _exportString + format['[_bestPlaces,"exposedHills",%1] call ALIVE_fnc_hashSet;',_hillPlaces];
		/*
		_exportString = _exportString + format['[_bestPlaces,"meadow",%1] call ALIVE_fnc_hashSet;',_meadowPlaces];
		_exportString = _exportString + format['[_bestPlaces,"exposedTrees",%1] call ALIVE_fnc_hashSet;',_treePlaces];
		_exportString = _exportString + format['[_bestPlaces,"houses",%1] call ALIVE_fnc_hashSet;',_housePlaces];
		_exportString = _exportString + format['[_bestPlaces,"sea",%1] call ALIVE_fnc_hashSet;',_seaPlaces];
		*/
		_exportString = _exportString + format['[_sectorData,"bestPlaces",_bestPlaces] call ALIVE_fnc_hashSet;'];
		
		_exportString = _exportString + '_roads = [] call ALIVE_fnc_hashCreate;';
		_exportString = _exportString + str(formatText['[_roads,"road",%1] call ALIVE_fnc_hashSet;',_roadSamples]);
		_exportString = _exportString + format['[_roads,"crossroad",%1] call ALIVE_fnc_hashSet;',_crossroadSamples];
		_exportString = _exportString + format['[_roads,"terminus",%1] call ALIVE_fnc_hashSet;',_terminusSamples];
		_exportString = _exportString + format['[_sectorData,"roads",_roads] call ALIVE_fnc_hashSet;'];		
		
		_exportString = _exportString + format['[ALIVE_gridData, "%1", _sectorData] call ALIVE_fnc_hashSet;',_sectorID];
	};
	
	// DEBUG -------------------------------------------------------------------------------------
	if(_debug) then {
		["compilation of sub sector data into parent sector completed"] call ALIVE_fnc_dump;
		_sectorData call ALIVE_fnc_inspectHash;
		[] call ALIVE_fnc_timer;
		["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
	};
	// DEBUG -------------------------------------------------------------------------------------
	
	[_subGrid, "destroy"] call ALIVE_fnc_sectorGrid;
	
	[_sector, "debug", false] call ALIVE_fnc_sector;
	
	
} forEach _sectors;


if(_export) then {
	copyToClipboard _exportString;
	["Grid map analysis complete, results have been copied to the clipboard"] call ALIVE_fnc_dump;
};