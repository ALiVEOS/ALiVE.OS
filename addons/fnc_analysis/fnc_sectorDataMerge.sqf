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

private _sectors = _this;

private _err = format["sector data merge requires an array of sectors - %1",_sectors];
ASSERT_TRUE(_sectors isEqualTo [], _err);

private _elevationSamples = [];
private _elevationSamplesLand = [];
private _elevationSamplesSea = [];
private _elevation = 0;
private _terrain = "";
private _landTerrain = [];
private _shoreTerrain = [];
private _seaTerrain = [];
private _forestPlaces = [];
private _hillPlaces = [];
private _consolidatedClusters = [];
private _airClusters = [];
private _heliClusters = [];
private _consolidatedCivClusters = [];
private _powerClusters = [];
private _commsClusters = [];
private _marineClusters = [];
private _railClusters = [];
private _fuelClusters = [];
private _constructionClusters = [];
private _settlementClusters = [];

/*
_meadowPlaces = [];
_treePlaces = [];
_housePlaces = [];
_seaPlaces = [];
*/

private _flatEmptySamples = [];
private _roadSamples = [];
private _crossroadSamples = [];
private _terminusSamples = [];
private _eastEntities = [];
private _westEntities = [];
private _civEntities = [];
private _guerEntities = [];

{
    private _sector = _x;
    private _sectorData = [_sector, "data"] call ALIVE_fnc_sector;

    private _sectorElevationSamplesLand = [_sectorData, "elevationSamplesLand"] call ALIVE_fnc_hashGet;
    private _sectorElevationSamplesSea = [_sectorData, "elevationSamplesSea"] call ALIVE_fnc_hashGet;
    private _sectorTerrainSamples = [_sectorData, "terrainSamples"] call ALIVE_fnc_hashGet;
    private _sectorFlatEmptySamples = [_sectorData, "flatEmpty"] call ALIVE_fnc_hashGet;
    private _sectorRoads = [_sectorData, "roads"] call ALIVE_fnc_hashGet;
    private _sectorBestPlaces = [_sectorData, "bestPlaces"] call ALIVE_fnc_hashGet;
    private _sectorMilClusters = [_sectorData, "clustersMil"] call ALIVE_fnc_hashGet;
    private _sectorCivClusters = [_sectorData, "clustersCiv"] call ALIVE_fnc_hashGet;

    _elevationSamplesLand append _sectorElevationSamplesLand;
    _elevationSamplesSea append _sectorElevationSamplesSea;

    private _sectorLand = [_sectorTerrainSamples, "land"] call ALIVE_fnc_hashGet;
    private _sectorShore = [_sectorTerrainSamples, "shore"] call ALIVE_fnc_hashGet;
    private _sectorSea = [_sectorTerrainSamples, "sea"] call ALIVE_fnc_hashGet;

    _landTerrain append _sectorLand;
    _shoreTerrain append _sectorShore;
    _seaTerrain append _sectorSea;

    if(count (_sectorFlatEmptySamples select 0) > 0) then {
        _flatEmptySamples append _sectorFlatEmptySamples;
    };

    private _sectorRoad = [_sectorRoads, "road"] call ALIVE_fnc_hashGet;
    private _sectorCrossroad = [_sectorRoads, "crossroad"] call ALIVE_fnc_hashGet;
    private _sectorTerminus = [_sectorRoads, "terminus"] call ALIVE_fnc_hashGet;

    _roadSamples append _sectorRoad;
    _crossroadSamples append _sectorCrossroad;
    _terminusSamples append _sectorTerminus;

    private _sectorForestPlaces = [_sectorBestPlaces, "forest"] call ALIVE_fnc_hashGet;
    private _sectorHillPlaces = [_sectorBestPlaces, "exposedHills"] call ALIVE_fnc_hashGet;

    /*
    private _sectorMeadowPlaces = [_sectorBestPlaces, "meadow"] call ALIVE_fnc_hashGet;
    private _sectorTreePlaces = [_sectorBestPlaces, "exposedTrees"] call ALIVE_fnc_hashGet;
    private _sectorHousePlaces = [_sectorBestPlaces, "houses"] call ALIVE_fnc_hashGet;
    private _sectorSeaPlaces = [_sectorBestPlaces, "sea"] call ALIVE_fnc_hashGet;
    */

    _forestPlaces append _sectorForestPlaces;
    _hillPlaces append _sectorHillPlaces;

    /*
    private _meadowPlaces = _meadowPlaces + _sectorMeadowPlaces;
    private _treePlaces = _treePlaces + _sectorTreePlaces;
    private _housePlaces = _housePlaces + _sectorHousePlaces;
    private _seaPlaces = _seaPlaces + _sectorSeaPlaces;
    */

    private _sectorConsolidatedClusters = [_sectorMilClusters, "consolidated"] call ALIVE_fnc_hashGet;
    private _sectorAirClusters = [_sectorMilClusters, "air"] call ALIVE_fnc_hashGet;
    private _sectorHeliClusters = [_sectorMilClusters, "heli"] call ALIVE_fnc_hashGet;

    _consolidatedClusters append _sectorConsolidatedClusters;
    _airClusters append _sectorAirClusters;
    _heliClusters append _sectorHeliClusters;

    private _sectorConsolidatedCivClusters = [_sectorCivClusters, "consolidated"] call ALIVE_fnc_hashGet;
    private _sectorPowerClusters = [_sectorCivClusters, "power"] call ALIVE_fnc_hashGet;
    private _sectorCommsClusters = [_sectorCivClusters, "comms"] call ALIVE_fnc_hashGet;
    private _sectorMarineClusters = [_sectorCivClusters, "marine"] call ALIVE_fnc_hashGet;
    private _sectorFuelClusters = [_sectorCivClusters, "fuel"] call ALIVE_fnc_hashGet;
    private _sectorRailClusters = [_sectorCivClusters, "rail"] call ALIVE_fnc_hashGet;
    private _sectorConstructionClusters = [_sectorCivClusters, "construction"] call ALIVE_fnc_hashGet;
    private _sectorSettlementClusters = [_sectorCivClusters, "settlement"] call ALIVE_fnc_hashGet;

    _consolidatedCivClusters append _sectorConsolidatedCivClusters;
    _powerClusters append _sectorPowerClusters;
    _commsClusters append _sectorCommsClusters;
    _marineClusters append _sectorMarineClusters;
    _railClusters append _sectorRailClusters;
    _fuelClusters append _sectorFuelClusters;
    _constructionClusters append _sectorConstructionClusters;
    _settlementClusters append _sectorSettlementClusters;

    if("entitiesBySide" in (_sectorData select 1)) then {
        private _sectorEntitiesBySide = [_sectorData, "entitiesBySide"] call ALIVE_fnc_hashGet;
        private _sectorEastEntities = [_sectorEntitiesBySide, "EAST"] call ALIVE_fnc_hashGet;
        private _sectorWestEntities = [_sectorEntitiesBySide, "WEST"] call ALIVE_fnc_hashGet;
        private _sectorCivEntities = [_sectorEntitiesBySide, "CIV"] call ALIVE_fnc_hashGet;
        private _sectorGuerEntities = [_sectorEntitiesBySide, "GUER"] call ALIVE_fnc_hashGet;

        _eastEntities append _sectorEastEntities;
        _westEntities append _sectorWestEntities;
        _civEntities append _sectorCivEntities;
        _guerEntities append _sectorGuerEntities;
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

private _entitiesBySide = [] call ALIVE_fnc_hashCreate;
[_entitiesBySide,"EAST",_eastEntities] call ALIVE_fnc_hashSet;
[_entitiesBySide,"WEST",_westEntities] call ALIVE_fnc_hashSet;
[_entitiesBySide,"CIV",_civEntities] call ALIVE_fnc_hashSet;
[_entitiesBySide,"GUER",_guerEntities] call ALIVE_fnc_hashSet;

private _terrainSamples = [] call ALIVE_fnc_hashCreate;
[_terrainSamples,"land",_landTerrain] call ALIVE_fnc_hashSet;
[_terrainSamples,"sea",_seaTerrain] call ALIVE_fnc_hashSet;
[_terrainSamples,"shore",_shoreTerrain] call ALIVE_fnc_hashSet;

private _bestPlaces = [] call ALIVE_fnc_hashCreate;
[_bestPlaces,"forest",_forestPlaces] call ALIVE_fnc_hashSet;
[_bestPlaces,"exposedHills",_hillPlaces] call ALIVE_fnc_hashSet;

/*
[_bestPlaces,"meadow",_meadowPlaces] call ALIVE_fnc_hashSet;
[_bestPlaces,"exposedTrees",_treePlaces] call ALIVE_fnc_hashSet;
[_bestPlaces,"houses",_housePlaces] call ALIVE_fnc_hashSet;
[_bestPlaces,"sea",_seaPlaces] call ALIVE_fnc_hashSet;
*/

private _roads = [] call ALIVE_fnc_hashCreate;
[_roads,"road",_roadSamples] call ALIVE_fnc_hashSet;
[_roads,"crossroad",_crossroadSamples] call ALIVE_fnc_hashSet;
[_roads,"terminus",_terminusSamples] call ALIVE_fnc_hashSet;

private _clustersMil = [] call ALIVE_fnc_hashCreate;
[_clustersMil,"consolidated",_consolidatedClusters] call ALIVE_fnc_hashSet;
[_clustersMil,"air",_airClusters] call ALIVE_fnc_hashSet;
[_clustersMil,"heli",_heliClusters] call ALIVE_fnc_hashSet;

private _clustersCiv = [] call ALIVE_fnc_hashCreate;
[_clustersCiv,"consolidated",_consolidatedCivClusters] call ALIVE_fnc_hashSet;
[_clustersCiv, "power", _powerClusters] call ALIVE_fnc_hashSet;
[_clustersCiv, "comms", _commsClusters] call ALIVE_fnc_hashSet;
[_clustersCiv, "marine", _marineClusters] call ALIVE_fnc_hashSet;
[_clustersCiv, "rail", _railClusters] call ALIVE_fnc_hashSet;
[_clustersCiv, "fuel", _fuelClusters] call ALIVE_fnc_hashSet;
[_clustersCiv, "construction", _constructionClusters] call ALIVE_fnc_hashSet;
[_clustersCiv, "settlement", _settlementClusters] call ALIVE_fnc_hashSet;

private _mergedData = [] call ALIVE_fnc_hashCreate;
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