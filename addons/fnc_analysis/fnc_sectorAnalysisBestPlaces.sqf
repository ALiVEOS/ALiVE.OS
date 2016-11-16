#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorAnalysisBestPlaces);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorAnalysisBestPlaces

Description:
Perform analysis on an array of sectors using the best places command

Parameters:
Array - array of sectors

Returns:
...

Examples:
(begin example)
// add best places data to passed sector objects
_result = [_sectors] call ALIVE_fnc_sectorAnalysisBestPlaces;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

params [
    "_sectors"
    ["_sources", 10],
    ["_precision", 20]
]

private _err = format["sector analysis terrain requires an array of sectors - %1",_sectors];
ASSERT_TRUE(_sectors isEqualType [], _err);

{
    private _sector = _x;

    private _centerPosition = [_sector, "center"] call ALIVE_fnc_sector;
    private _id = [_sector, "id"] call ALIVE_fnc_sector;
    private _bounds = [_sector, "bounds"] call ALIVE_fnc_sector;
    private _dimensions = [_sector, "dimensions"] call ALIVE_fnc_sector;

    private _radius = _dimensions select 0;

    private _bestPlaces = [] call ALIVE_fnc_hashCreate;

    private _forestExpression = "(1 + forest + trees) * (1 - sea) * (1 - houses)";
    private _exposedHillsExpression = "(1 + hills) * (1 - forest) * (1 - sea)";

    /*
    private _meadowExpression = "(1 + meadow) * (1 - forest) * (1 - sea) * (1 - hills)";
    private _exposedTreesExpression = "(1 + trees) * (1 - forest) * (1 - sea)";
    private _housesExpression = "(1 + houses) * (1 - forest) * (1 - sea) * (1 - meadow)";
    private _seaExpression = "(1 + sea) * (1 - hills) * (1 - meadow)";
    */

    private _selectedForestPlaces = selectBestPlaces [_centerPosition,_radius,_forestExpression,_precision,_sources];
    private _selectedHillsPlaces = selectBestPlaces [_centerPosition,_radius,_exposedHillsExpression,_precision,_sources];

    /*
    private _selectedMeadowsPlaces = selectBestPlaces [_centerPosition,_radius,_meadowExpression,_precision,_sources];
    private _selectedTreesPlaces = selectBestPlaces [_centerPosition,_radius,_exposedTreesExpression,_precision,_sources];
    private _selectedHousesPlaces = selectBestPlaces [_centerPosition,_radius,_housesExpression,_precision,_sources];
    private _selectedSeaPlaces = selectBestPlaces [_centerPosition,_radius,_seaExpression,_precision,_sources];
    */

    /*
    ["S: %1 FORREST: %2",_id,_selectedForestPlaces] call ALIVE_fnc_dump;
    ["S: %1 HILLS: %2",_id,_selectedHillsPlaces] call ALIVE_fnc_dump;
    ["S: %1 MEADOWS: %2",_id,_selectedMeadowsPlaces] call ALIVE_fnc_dump;
    ["S: %1 TREES: %2",_id,_selectedTreesPlaces] call ALIVE_fnc_dump;
    ["S: %1 HOUSES: %2",_id,_selectedHousesPlaces] call ALIVE_fnc_dump;
    ["S: %1 SEA: %2",_id,_selectedSeaPlaces] call ALIVE_fnc_dump;
    */

    private _forestPositions = [];
    private _hillsPositions = [];

    /*
    private _meadowsPositions = [];
    private _treesPositions = [];
    private _housesPositions = [];
    private _seaPositions = [];
    */

    {
        private _pos = _x select 0;
        private _cost = _x select 1;

        if(_cost > 2.3) then {
            _forestPositions pushback _pos;
        };
    } forEach _selectedForestPlaces;

    {
        private _pos = _x select 0;
        private _cost = _x select 1;

        if(_cost > 1.2) then {
            _hillsPositions pushback _pos;
        };
    } forEach _selectedHillsPlaces;

    /*
    {
        private _pos = _x select 0;
        private _cost = _x select 1;

        if(_cost > 1.6) then {
            _meadowsPositions pushback _pos;
        };
    } forEach _selectedMeadowsPlaces;

    {
        private _pos = _x select 0;
        private _cost = _x select 1;

        if(_cost > 1.2) then {
            _treesPositions pushback _pos;
        };
    } forEach _selectedTreesPlaces;

    {
        private _pos = _x select 0;
        private _cost = _x select 1;

        if(_cost >= 2) then {
            _housesPositions pushback _pos;
        };
    } forEach _selectedHousesPlaces;

    {
        private _pos = _x select 0;
        private _cost = _x select 1;

        if(_cost >= 2) then {
            _seaPositions pushback _pos;
        };
    } forEach _selectedSeaPlaces;
    */

    [_bestPlaces,"forest",_forestPositions] call ALIVE_fnc_hashSet;
    [_bestPlaces,"exposedHills",_hillsPositions] call ALIVE_fnc_hashSet;

    /*
    [_bestPlaces,"meadow",_meadowsPositions] call ALIVE_fnc_hashSet;
    [_bestPlaces,"exposedTrees",_treesPositions] call ALIVE_fnc_hashSet;
    [_bestPlaces,"houses",_housesPositions] call ALIVE_fnc_hashSet;
    [_bestPlaces,"sea",_seaPositions] call ALIVE_fnc_hashSet;
    */

    // store the result of the analysis on the sector instance
    [_sector, "data", ["bestPlaces",_bestPlaces]] call ALIVE_fnc_sector;
} forEach _sectors;