#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(auto_gridMapAnalysis);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_auto_gridMapAnalysis

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
_result = [_grid] call ALIVE_fnc_auto_gridMapAnalysis;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

params [
    "_grid",
    "_sectors",
    ["_export", false],
    ["_debug", false]
];

// reset existing analysis data
if(count _sectors == 0) then {
    _sectors = [_grid, "sectors"] call ALIVE_fnc_sectorGrid;
};

if(_export) then {
    "ALiVEClient" callExtension format["indexData~%1|ALIVE_gridData = [] call ALIVE_fnc_hashCreate;",worldName];
};

// DEBUG -------------------------------------------------------------------------------------
if(_debug) then {
    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
    ["ALIVE Starting Map Analysis"] call ALIVE_fnc_dump;
};
// DEBUG -------------------------------------------------------------------------------------

{
    private _sector = _x;
    private _sectorData = [_sector, "data"] call ALIVE_fnc_sector;
    private _sectorID = [_sector, "id"] call ALIVE_fnc_sector;

    [_sector, "debug", true] call ALIVE_fnc_sector;

    // DEBUG -------------------------------------------------------------------------------------
    if(_debug) then {
        ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
        ["Map Analysis sector [%1] creating sub dividing grid",_sectorID] call ALIVE_fnc_dump;
        [true] call ALIVE_fnc_timer;
    };
    // DEBUG -------------------------------------------------------------------------------------

    private _subGrid = [_sector,10,format["Grid_%1",_forEachIndex]] call ALIVE_fnc_sectorSubGrid;
    private _subGridSectors = [_subGrid, "sectors"] call ALIVE_fnc_sectorGrid;

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

    private _elevation = 0;
    private _elevationSamples = [];
    private _terrain = "";
    private _landTerrain = [];
    private _shoreTerrain = [];
    private _seaTerrain = [];
    private _forestPlaces = [];
    private _hillPlaces = [];
    /*
    private _meadowPlaces = [];
    private _treePlaces = [];
    private _housePlaces = [];
    private _seaPlaces = [];
    */
    private _flatEmptySamples = [];
    private _roadSamples = [];
    private _crossroadSamples = [];
    private _terminusSamples = [];

    {
        private _subGridSector = _x;
        private _subGridSectorData = [_subGridSector, "data"] call ALIVE_fnc_sector;
        private _subGridElevationSamples = [_subGridSectorData, "elevationSamples"] call ALIVE_fnc_hashGet;
        private _subGridTerrainSamples = [_subGridSectorData, "terrainSamples"] call ALIVE_fnc_hashGet;

        private _subGridLand = [_subGridTerrainSamples, "land"] call ALIVE_fnc_hashGet;
        private _subGridShore = [_subGridTerrainSamples, "shore"] call ALIVE_fnc_hashGet;
        private _subGridSea = [_subGridTerrainSamples, "sea"] call ALIVE_fnc_hashGet;

        _landTerrain append _subGridLand;
        _shoreTerrain append _subGridShore;
        _seaTerrain append _subGridSea;

        _elevationSamples append _subGridElevationSamples;
    } forEach _subGridSectors;

    private _elevationSamplesLand = [];
    private _elevationSamplesSea = [];

    // calculate average elevation for the sector
    {
        private _currentElevation = _x select 1;
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
            private _subGridSector = _x;
            private _subGridSectorData = [_subGridSector, "data"] call ALIVE_fnc_sector;
            private _subGridFlatEmptySamples = [_subGridSectorData, "flatEmpty"] call ALIVE_fnc_hashGet;
            private _subGridRoads = [_subGridSectorData, "roads"] call ALIVE_fnc_hashGet;
            private _subGridBestPlaces = [_subGridSectorData, "bestPlaces"] call ALIVE_fnc_hashGet;

            private _subGridForestPlaces = [_subGridBestPlaces, "forest"] call ALIVE_fnc_hashGet;
            private _subGridHillPlaces = [_subGridBestPlaces, "exposedHills"] call ALIVE_fnc_hashGet;
            /*
            private _subGridMeadowPlaces = [_subGridBestPlaces, "meadow"] call ALIVE_fnc_hashGet;
            private _subGridTreePlaces = [_subGridBestPlaces, "exposedTrees"] call ALIVE_fnc_hashGet;
            private _subGridHousePlaces = [_subGridBestPlaces, "houses"] call ALIVE_fnc_hashGet;
            private _subGridSeaPlaces = [_subGridBestPlaces, "sea"] call ALIVE_fnc_hashGet;
            */

            private _subGridRoad = [_subGridRoads, "road"] call ALIVE_fnc_hashGet;
            private _subGridCrossroad = [_subGridRoads, "crossroad"] call ALIVE_fnc_hashGet;
            private _subGridTerminus = [_subGridRoads, "terminus"] call ALIVE_fnc_hashGet;

            private _forestPlaces = _forestPlaces + _subGridForestPlaces;
            private _hillPlaces = _hillPlaces + _subGridHillPlaces;
            /*
            private _meadowPlaces = _meadowPlaces + _subGridMeadowPlaces;
            private _treePlaces = _treePlaces + _subGridTreePlaces;
            private _housePlaces = _housePlaces + _subGridHousePlaces;
            private _seaPlaces = _seaPlaces + _subGridSeaPlaces;
            */

            _roadSamples append _subGridRoad;
            _crossroadSamples append _subGridCrossroad;
            _terminusSamples append _subGridTerminus;

            if(count (_subGridFlatEmptySamples select 0) > 0) then {
                _flatEmptySamples append _subGridFlatEmptySamples;
            };

        } forEach _subGridSectors;

    };

    // store all data

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
        "ALiVEClient" callExtension format["indexData~%1|_sectorData = [] call ALIVE_fnc_hashCreate;",worldName];

        "ALiVEClient" callExtension format['indexData~%1|[_sectorData,"elevationSamplesLand",%2] call ALIVE_fnc_hashSet;',worldName,_elevationSamplesLand];
        "ALiVEClient" callExtension format['indexData~%1|[_sectorData,"elevationSamplesSea",%2] call ALIVE_fnc_hashSet;',worldName,_elevationSamplesSea];
        "ALiVEClient" callExtension format['indexData~%1|[_sectorData,"elevation",%2] call ALIVE_fnc_hashSet;',worldName,_elevation];
        "ALiVEClient" callExtension format['indexData~%1|[_sectorData,"flatEmpty",%2] call ALIVE_fnc_hashSet;',worldName,_flatEmptySamples];
        "ALiVEClient" callExtension format['indexData~%1|[_sectorData,"terrain","%2"] call ALIVE_fnc_hashSet;',worldName,_terrain];

        "ALiVEClient" callExtension format['indexData~%1|_terrainSamples = [] call ALIVE_fnc_hashCreate;',worldName];
        "ALiVEClient" callExtension format['indexData~%1|[_terrainSamples,"land",%2] call ALIVE_fnc_hashSet;',worldName,_landTerrain];
        "ALiVEClient" callExtension format['indexData~%1|[_terrainSamples,"sea",%2] call ALIVE_fnc_hashSet;',worldName,_seaTerrain];
        "ALiVEClient" callExtension format['indexData~%1|[_terrainSamples,"shore",%2] call ALIVE_fnc_hashSet;',worldName,_shoreTerrain];
        "ALiVEClient" callExtension format['indexData~%1|[_sectorData,"terrainSamples",_terrainSamples] call ALIVE_fnc_hashSet;',worldName];

        "ALiVEClient" callExtension format['indexData~%1|_bestPlaces = [] call ALIVE_fnc_hashCreate;',worldName];
        "ALiVEClient" callExtension  format['indexData~%1|[_bestPlaces,"forest",%2] call ALIVE_fnc_hashSet;',worldName,_forestPlaces];
        "ALiVEClient" callExtension  format['indexData~%1|[_bestPlaces,"exposedHills",%2] call ALIVE_fnc_hashSet;',worldName,_hillPlaces];
        /*
        "ALiVEClient" callExtension  format['indexData~%1|[_bestPlaces,"meadow",%2] call ALIVE_fnc_hashSet;',worldName,_meadowPlaces];
        "ALiVEClient" callExtension  format['indexData~%1|[_bestPlaces,"exposedTrees",%2] call ALIVE_fnc_hashSet;',worldName,_treePlaces];
        "ALiVEClient" callExtension  format['indexData~%1|[_bestPlaces,"houses",%2] call ALIVE_fnc_hashSet;',worldName,_housePlaces];
        "ALiVEClient" callExtension  format['indexData~%1|[_bestPlaces,"sea",%2] call ALIVE_fnc_hashSet;',worldName,_seaPlaces];
        */
        "ALiVEClient" callExtension format['indexData~%1|[_sectorData,"bestPlaces",_bestPlaces] call ALIVE_fnc_hashSet;',worldName];

        "ALiVEClient" callExtension  format['indexData~%1|_roads = [] call ALIVE_fnc_hashCreate;',worldName];
        "ALiVEClient" callExtension  str(formatText['indexData~%1|[_roads,"road",%2] call ALIVE_fnc_hashSet;',worldName,_roadSamples]);
        "ALiVEClient" callExtension  format['indexData~%1|[_roads,"crossroad",%2] call ALIVE_fnc_hashSet;',worldName,_crossroadSamples];
        "ALiVEClient" callExtension  format['indexData~%1|[_roads,"terminus",%2] call ALIVE_fnc_hashSet;',worldName,_terminusSamples];
        "ALiVEClient" callExtension  format['indexData~%1|[_sectorData,"roads",_roads] call ALIVE_fnc_hashSet;',worldName];

        "ALiVEClient" callExtension  format['indexData~%1|[ALIVE_gridData, "%2", _sectorData] call ALIVE_fnc_hashSet;',worldName,_sectorID];
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
