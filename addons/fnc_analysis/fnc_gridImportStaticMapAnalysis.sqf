#include "\x\alive\addons\fnc_analysis\script_component.hpp"
SCRIPT(gridImportStaticMapAnalysis);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_gridImportStaticMapAnalysis

Description:
Import static map analysis data structures to a grid

Parameters:
Grid - the grid to run the map analysis on
String - world static analysis file to import

Returns:
...

Examples:
(begin example)
// import stratis static map analysis to the passed grid
_result = [_grid,"Stratis"] call ALIVE_fnc_gridImportStaticMapAnalysis;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_grid","_worldName","_sectors","_staticMapAnalysis","_sector","_sectorID","_file"];

_grid = _this select 0;

_sectors = [_grid, "sectors"] call ALIVE_fnc_sectorGrid;

_worldName = [worldName] call CBA_fnc_capitalize;

if(isNil "ALIVE_gridData") then {
    _worldName = toLower(worldName);
    _file = format["x\alive\addons\fnc_analysis\data\data.%1.sqf", _worldName];
    call compile preprocessFileLineNumbers _file;
};

if (isNil "ALIVE_gridData") exitWith {
    // Create dummy sector data
    {
        private _sector = _x;
        private _sectorID = [_sector, "id"] call ALIVE_fnc_sector;

        private _sectorData = [] call ALIVE_fnc_hashCreate;
        [_sectorData,"elevationSamplesLand",[]] call ALIVE_fnc_hashSet;
        [_sectorData,"elevationSamplesSea",[]] call ALIVE_fnc_hashSet;
        [_sectorData,"elevation",0] call ALIVE_fnc_hashSet;
        [_sectorData,"flatEmpty",[]] call ALIVE_fnc_hashSet;
        [_sectorData,"terrain","NONE"] call ALIVE_fnc_hashSet;
        private _terrainSamples = [] call ALIVE_fnc_hashCreate;
        [_terrainSamples,"land",[]] call ALIVE_fnc_hashSet;
        [_terrainSamples,"sea",[]] call ALIVE_fnc_hashSet;
        [_terrainSamples,"shore",[]] call ALIVE_fnc_hashSet;
        [_sectorData,"terrainSamples",_terrainSamples] call ALIVE_fnc_hashSet;
        private _bestPlaces = [] call ALIVE_fnc_hashCreate;
        [_bestPlaces,"forest",[]] call ALIVE_fnc_hashSet;
        [_bestPlaces,"exposedHills",[]] call ALIVE_fnc_hashSet;
        [_sectorData,"bestPlaces",_bestPlaces] call ALIVE_fnc_hashSet;
        private _roads = [] call ALIVE_fnc_hashCreate;
        [_roads,"road",[]] call ALIVE_fnc_hashSet;
        [_roads,"crossroad",[]] call ALIVE_fnc_hashSet;
        [_roads,"terminus",[]] call ALIVE_fnc_hashSet;
        [_sectorData,"roads",_roads] call ALIVE_fnc_hashSet;

        [_sector, "data", _sectorData] call ALIVE_fnc_hashSet;
    } forEach _sectors;
};

{
    _sector = _x;
    _sectorID = [_sector, "id"] call ALIVE_fnc_sector;
    [_sector, "data", [ALIVE_gridData, _sectorID] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;

} forEach _sectors;
