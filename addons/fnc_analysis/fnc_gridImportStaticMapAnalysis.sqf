#include <\x\alive\addons\fnc_analysis\script_component.hpp>
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

{
	_sector = _x;
	_sectorID = [_sector, "id"] call ALIVE_fnc_sector;
	[_sector, "data", [ALIVE_gridData, _sectorID] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;

} forEach _sectors;