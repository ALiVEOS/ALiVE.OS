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

private ["_sectors","_array","_err","_sector","_result","_centerPosition","_id","_bounds","_dimensions","_radius","_precision","_sources","_bestPlaces",
"_forestExpression","_exposedHillsExpression","_meadowExpression","_exposedTreesExpression","_housesExpression","_seaExpression",
"_selectedForestPlaces","_selectedHillsPlaces","_selectedMeadowsPlaces","_selectedTreesPlaces","_selectedHousesPlaces","_selectedSeaPlaces",
"_forestPositions","_hillsPositions","_meadowsPositions","_treesPositions","_housesPositions","_seaPositions","_pos","_cost"];

_sectors = _this select 0;
_sources = if(count _this > 1) then {_this select 1} else {10};
_precision = if(count _this > 2) then {_this select 2} else {20};
_err = format["sector analysis terrain requires an array of sectors - %1",_sectors];
ASSERT_TRUE(typeName _sectors == "ARRAY",_err);

{
	_sector = _x;

	_centerPosition = [_sector, "center"] call ALIVE_fnc_sector;
	_id = [_sector, "id"] call ALIVE_fnc_sector;
	_bounds = [_sector, "bounds"] call ALIVE_fnc_sector;
	_dimensions = [_sector, "dimensions"] call ALIVE_fnc_sector;
	
	_radius = _dimensions select 0;
	
	_bestPlaces = [] call ALIVE_fnc_hashCreate;
	
	_forestExpression = "(1 + forest + trees) * (1 - sea) * (1 - houses)";
	_exposedHillsExpression = "(1 + hills) * (1 - forest) * (1 - sea)";
	/*
	_meadowExpression = "(1 + meadow) * (1 - forest) * (1 - sea) * (1 - hills)";
	_exposedTreesExpression = "(1 + trees) * (1 - forest) * (1 - sea)";
	_housesExpression = "(1 + houses) * (1 - forest) * (1 - sea) * (1 - meadow)";
	_seaExpression = "(1 + sea) * (1 - hills) * (1 - meadow)";
	*/
	
	_selectedForestPlaces = selectBestPlaces [_centerPosition,_radius,_forestExpression,_precision,_sources];	
	_selectedHillsPlaces = selectBestPlaces [_centerPosition,_radius,_exposedHillsExpression,_precision,_sources];	
	/*
	_selectedMeadowsPlaces = selectBestPlaces [_centerPosition,_radius,_meadowExpression,_precision,_sources];	
	_selectedTreesPlaces = selectBestPlaces [_centerPosition,_radius,_exposedTreesExpression,_precision,_sources];	
	_selectedHousesPlaces = selectBestPlaces [_centerPosition,_radius,_housesExpression,_precision,_sources];
	_selectedSeaPlaces = selectBestPlaces [_centerPosition,_radius,_seaExpression,_precision,_sources];	
	*/
	
	/*
	["S: %1 FORREST: %2",_id,_selectedForestPlaces] call ALIVE_fnc_dump;
	["S: %1 HILLS: %2",_id,_selectedHillsPlaces] call ALIVE_fnc_dump;
	["S: %1 MEADOWS: %2",_id,_selectedMeadowsPlaces] call ALIVE_fnc_dump;
	["S: %1 TREES: %2",_id,_selectedTreesPlaces] call ALIVE_fnc_dump;
	["S: %1 HOUSES: %2",_id,_selectedHousesPlaces] call ALIVE_fnc_dump;
	["S: %1 SEA: %2",_id,_selectedSeaPlaces] call ALIVE_fnc_dump;
	*/
	
	_forestPositions = [];
	_hillsPositions = [];
	/*
	_meadowsPositions = [];
	_treesPositions = [];
	_housesPositions = [];
	_seaPositions = [];
	*/
		
	{
		_pos = _x select 0;
		_cost = _x select 1;
		if(_cost > 2.3) then {
			_forestPositions set [count _forestPositions, _pos];
		};
		
	} forEach _selectedForestPlaces;	
	
	{
		_pos = _x select 0;
		_cost = _x select 1;
		if(_cost > 1.2) then {
			_hillsPositions set [count _hillsPositions, _pos];
		};
		
	} forEach _selectedHillsPlaces;
		
	/*
	{
		_pos = _x select 0;
		_cost = _x select 1;
		if(_cost > 1.6) then {
			_meadowsPositions set [count _meadowsPositions, _pos];
		};
		
	} forEach _selectedMeadowsPlaces;

	{
		_pos = _x select 0;
		_cost = _x select 1;
		if(_cost > 1.2) then {
			_treesPositions set [count _treesPositions, _pos];
		};
		
	} forEach _selectedTreesPlaces;	
	
	{
		_pos = _x select 0;
		_cost = _x select 1;
		if(_cost >= 2) then {
			_housesPositions set [count _housesPositions, _pos];
		};
		
	} forEach _selectedHousesPlaces;
	
	{
		_pos = _x select 0;
		_cost = _x select 1;
		if(_cost >= 2) then {
			_seaPositions set [count _seaPositions, _pos];
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