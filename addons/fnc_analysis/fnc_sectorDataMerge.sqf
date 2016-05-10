#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorDataMerge);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorDataMerge

Description:
Merge sector data from passed sectors

Parameters:
Array - Sectors array

Returns:
Merged Sector Data Hash

Examples:
(begin example)
// sort elevation data
_mergedData = [_sectors] call ALIVE_fnc_sectorDataMerge;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_sectors","_err","_sectorData","_key","_args","_data","_sortedData"];
	
_sectors = _this;

_err = format["sector data merge requires an array of sectors - %1",_sectors];
ASSERT_TRUE(typeName _sectors == "ARRAY",_err);

private ["_elevationSamples","_elevationSamplesLand","_elevationSamplesSea","_elevation","_terrainSamples","_terrain","_landTerrain","_shoreTerrain","_seaTerrain",
"_forestPlaces","_hillPlaces","_meadowPlaces","_treePlaces","_housePlaces","_seaPlaces","_flatEmptySamples","_roadSamples",
"_crossroadSamples","_terminusSamples","_bestPlaces","_roads","_terrainSamples","_sector","_sectorSectorData","_sectorElevationSamples",
"_sectorTerrainSamples","_sectorLand","_sectorShore","_sectorSea","_sectorFlatEmptySamples","_sectorRoadSamples","_sectorRoad",
"_sectorCrossroad","_sectorTerminus","_sectorBestPlaces","_sectorForestPlaces","_sectorHillPlaces","_sectorMeadowPlaces",
"_sectorTreePlaces","_sectorHousePlaces","_sectorSeaPlaces","_entitiesBySide","_eastEntities","_westEntities","_civEntities",
"_guerEntities","_sectorEntitiesBySide","_sectorEastEntities","_sectorWestEntities","_sectorCivEntities","_sectorGuerEntities",
"_consolidatedClusters","_airClusters","_heliClusters","_sectorMilClusters","_sectorConsolidatedClusters","_sectorAirClusters",
"_sectorHeliClusters","_consolidatedCivClusters","_powerClusters","_commsClusters","_marineClusters","_railClusters","_fuelClusters",
"_constructionClusters","_settlementClusters","_sectorCivClusters","_sectorConsolidatedCivClusters","_sectorConsolidatedCivClusters",
"_sectorPowerClusters","_sectorCommsClusters","_sectorMarineClusters","_sectorFuelClusters","_sectorRailClusters","_sectorConstructionClusters",
"_sectorSettlementClusters","_sectorElevationSamplesLand","_sectorElevationSamplesSea","_sectorRoads","_clustersMil","_clustersCiv","_mergedData"];

_elevationSamples = [];
_elevationSamplesLand = [];
_elevationSamplesSea = [];
_elevation = 0;
_terrain = "";
_landTerrain = [];
_shoreTerrain = [];
_seaTerrain = [];
_forestPlaces = [];
_hillPlaces = [];
_consolidatedClusters = [];
_airClusters = [];
_heliClusters = [];
_consolidatedCivClusters = [];
_powerClusters = [];
_commsClusters = [];
_marineClusters = [];
_railClusters = [];
_fuelClusters = [];
_constructionClusters = [];
_settlementClusters = [];
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
_eastEntities = [];
_westEntities = [];
_civEntities = [];
_guerEntities = [];

{
	private [];
	
	_sector = _x;
	_sectorData = [_sector, "data"] call ALIVE_fnc_sector;
	
	_sectorElevationSamplesLand = [_sectorData, "elevationSamplesLand"] call ALIVE_fnc_hashGet;
	_sectorElevationSamplesSea = [_sectorData, "elevationSamplesSea"] call ALIVE_fnc_hashGet;
	_sectorTerrainSamples = [_sectorData, "terrainSamples"] call ALIVE_fnc_hashGet;
	_sectorFlatEmptySamples = [_sectorData, "flatEmpty"] call ALIVE_fnc_hashGet;
	_sectorRoads = [_sectorData, "roads"] call ALIVE_fnc_hashGet;
	_sectorBestPlaces = [_sectorData, "bestPlaces"] call ALIVE_fnc_hashGet;
	_sectorMilClusters = [_sectorData, "clustersMil"] call ALIVE_fnc_hashGet;
	_sectorCivClusters = [_sectorData, "clustersCiv"] call ALIVE_fnc_hashGet;
		
	_elevationSamplesLand = _elevationSamplesLand + _sectorElevationSamplesLand;
	_elevationSamplesSea = _elevationSamplesSea + _sectorElevationSamplesSea;
	
	_sectorLand = [_sectorTerrainSamples, "land"] call ALIVE_fnc_hashGet;
	_sectorShore = [_sectorTerrainSamples, "shore"] call ALIVE_fnc_hashGet;
	_sectorSea = [_sectorTerrainSamples, "sea"] call ALIVE_fnc_hashGet;
	
	_landTerrain = _landTerrain + _sectorLand;
	_shoreTerrain = _shoreTerrain + _sectorShore;
	_seaTerrain = _seaTerrain + _sectorSea;
	
	if(count (_sectorFlatEmptySamples select 0) > 0) then {
		_flatEmptySamples = _flatEmptySamples + _sectorFlatEmptySamples;
	};
	
	_sectorRoad = [_sectorRoads, "road"] call ALIVE_fnc_hashGet;
	_sectorCrossroad = [_sectorRoads, "crossroad"] call ALIVE_fnc_hashGet;
	_sectorTerminus = [_sectorRoads, "terminus"] call ALIVE_fnc_hashGet;
	
	_roadSamples = _roadSamples + _sectorRoad;
	_crossroadSamples = _crossroadSamples + _sectorCrossroad;
	_terminusSamples = _terminusSamples + _sectorTerminus;
	
	_sectorForestPlaces = [_sectorBestPlaces, "forest"] call ALIVE_fnc_hashGet;
	_sectorHillPlaces = [_sectorBestPlaces, "exposedHills"] call ALIVE_fnc_hashGet;
	/*
	_sectorMeadowPlaces = [_sectorBestPlaces, "meadow"] call ALIVE_fnc_hashGet;
	_sectorTreePlaces = [_sectorBestPlaces, "exposedTrees"] call ALIVE_fnc_hashGet;
	_sectorHousePlaces = [_sectorBestPlaces, "houses"] call ALIVE_fnc_hashGet;
	_sectorSeaPlaces = [_sectorBestPlaces, "sea"] call ALIVE_fnc_hashGet;
	*/
	
	_forestPlaces = _forestPlaces + _sectorForestPlaces;
	_hillPlaces = _hillPlaces + _sectorHillPlaces;
	/*
	_meadowPlaces = _meadowPlaces + _sectorMeadowPlaces;
	_treePlaces = _treePlaces + _sectorTreePlaces;
	_housePlaces = _housePlaces + _sectorHousePlaces;
	_seaPlaces = _seaPlaces + _sectorSeaPlaces;
	*/
	
	_sectorConsolidatedClusters = [_sectorMilClusters, "consolidated"] call ALIVE_fnc_hashGet;
	_sectorAirClusters = [_sectorMilClusters, "air"] call ALIVE_fnc_hashGet;
	_sectorHeliClusters = [_sectorMilClusters, "heli"] call ALIVE_fnc_hashGet;
	
	_consolidatedClusters = _consolidatedClusters + _sectorConsolidatedClusters;
	_airClusters = _airClusters + _sectorAirClusters;
	_heliClusters = _heliClusters + _sectorHeliClusters;
	
	_sectorConsolidatedCivClusters = [_sectorCivClusters, "consolidated"] call ALIVE_fnc_hashGet;
	_sectorPowerClusters = [_sectorCivClusters, "power"] call ALIVE_fnc_hashGet;
	_sectorCommsClusters = [_sectorCivClusters, "comms"] call ALIVE_fnc_hashGet;
	_sectorMarineClusters = [_sectorCivClusters, "marine"] call ALIVE_fnc_hashGet;
	_sectorFuelClusters = [_sectorCivClusters, "fuel"] call ALIVE_fnc_hashGet;
	_sectorRailClusters = [_sectorCivClusters, "rail"] call ALIVE_fnc_hashGet;
	_sectorConstructionClusters = [_sectorCivClusters, "construction"] call ALIVE_fnc_hashGet;
	_sectorSettlementClusters = [_sectorCivClusters, "settlement"] call ALIVE_fnc_hashGet;
	
	_consolidatedCivClusters = _consolidatedCivClusters + _sectorConsolidatedCivClusters;
	_powerClusters = _powerClusters + _sectorPowerClusters;
	_commsClusters = _commsClusters + _sectorCommsClusters;
	_marineClusters = _marineClusters + _sectorMarineClusters;
	_railClusters = _railClusters + _sectorRailClusters;
	_fuelClusters = _fuelClusters + _sectorFuelClusters;
	_constructionClusters = _constructionClusters + _sectorConstructionClusters;
	_settlementClusters = _settlementClusters + _sectorSettlementClusters;
	
	if("entitiesBySide" in (_sectorData select 1)) then {
		_sectorEntitiesBySide = [_sectorData, "entitiesBySide"] call ALIVE_fnc_hashGet;
		_sectorEastEntities = [_sectorEntitiesBySide, "EAST"] call ALIVE_fnc_hashGet;
		_sectorWestEntities = [_sectorEntitiesBySide, "WEST"] call ALIVE_fnc_hashGet;
		_sectorCivEntities = [_sectorEntitiesBySide, "CIV"] call ALIVE_fnc_hashGet;
		_sectorGuerEntities = [_sectorEntitiesBySide, "GUER"] call ALIVE_fnc_hashGet;
		
		_eastEntities = _eastEntities + _sectorEastEntities;
		_westEntities = _westEntities + _sectorWestEntities;
		_civEntities = _civEntities + _sectorCivEntities;
		_guerEntities = _guerEntities + _sectorGuerEntities;
	};
	
} forEach _sectors;


// calculate average elevation for the sector
_elevationSamples = _elevationSamplesLand + _elevationSamplesSea;
{
	_elevation = _elevation + (_x select 1);
} forEach _elevationSamples;

_elevation = _elevation / ((count _elevationSamples)-1);

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


// store all data
		
_entitiesBySide = [] call ALIVE_fnc_hashCreate;
[_entitiesBySide,"EAST",_eastEntities] call ALIVE_fnc_hashSet;
[_entitiesBySide,"WEST",_westEntities] call ALIVE_fnc_hashSet;
[_entitiesBySide,"CIV",_civEntities] call ALIVE_fnc_hashSet;
[_entitiesBySide,"GUER",_guerEntities] call ALIVE_fnc_hashSet;

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

_clustersMil = [] call ALIVE_fnc_hashCreate;
[_clustersMil,"consolidated",_consolidatedClusters] call ALIVE_fnc_hashSet;
[_clustersMil,"air",_airClusters] call ALIVE_fnc_hashSet;
[_clustersMil,"heli",_heliClusters] call ALIVE_fnc_hashSet;

_clustersCiv = [] call ALIVE_fnc_hashCreate;
[_clustersCiv,"consolidated",_consolidatedCivClusters] call ALIVE_fnc_hashSet;
[_clustersCiv, "power", _powerClusters] call ALIVE_fnc_hashSet;
[_clustersCiv, "comms", _commsClusters] call ALIVE_fnc_hashSet;
[_clustersCiv, "marine", _marineClusters] call ALIVE_fnc_hashSet;
[_clustersCiv, "rail", _railClusters] call ALIVE_fnc_hashSet;
[_clustersCiv, "fuel", _fuelClusters] call ALIVE_fnc_hashSet;
[_clustersCiv, "construction", _constructionClusters] call ALIVE_fnc_hashSet;
[_clustersCiv, "settlement", _settlementClusters] call ALIVE_fnc_hashSet;

_mergedData = [] call ALIVE_fnc_hashCreate;
[_mergedData, "elevationSamplesLand",_elevationSamplesLand] call ALIVE_fnc_hashSet;
[_mergedData, "elevationSamplesSea",_elevationSamplesSea] call ALIVE_fnc_hashSet;
[_mergedData, "elevation",_elevation] call ALIVE_fnc_hashSet;
[_mergedData, "terrainSamples",_terrainSamples] call ALIVE_fnc_hashSet;
[_mergedData, "terrain",_terrain] call ALIVE_fnc_hashSet;
[_mergedData, "flatEmpty",_flatEmptySamples] call ALIVE_fnc_hashSet;
[_mergedData, "roads",_roads] call ALIVE_fnc_hashSet;
[_mergedData, "bestPlaces",_bestPlaces] call ALIVE_fnc_hashSet;
[_mergedData, "clustersMil",_clustersMil] call ALIVE_fnc_hashSet;
[_mergedData, "clustersCiv",_clustersCiv] call ALIVE_fnc_hashSet;
[_mergedData, "entitiesBySide",_entitiesBySide] call ALIVE_fnc_hashSet;	

_mergedData