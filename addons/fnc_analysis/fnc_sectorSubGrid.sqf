#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorSubGrid);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorSubGrid

Description:
Creates a sub dividing grid within a passed sector

Parameters:
Sector - the sector to sub divide
Scalar - number of sector rows
String - the grid ID name

Returns:
Grid

Examples:
(begin example)
// create a grid within a passed sector
_grid = [_sector,10,"mySubGrid"] call ALIVE_fnc_sectorSubGrid;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_sector","_sectors","_gridID","_err","_centerPosition","_id","_bounds","_dimensions","_gridPosition","_gridWidth","_sectorWidth","_grid"];

_sector = _this select 0;
_sectors = _this select 1;
_gridID = _this select 2;
_err = format["sector analysis terrain requires a of sector - %1",_sector];
ASSERT_TRUE(typeName _sector == "ARRAY",_err);

_centerPosition = [_sector, "center"] call ALIVE_fnc_sector;
_id = [_sector, "id"] call ALIVE_fnc_sector;
_bounds = [_sector, "bounds"] call ALIVE_fnc_sector;
_dimensions = [_sector, "dimensions"] call ALIVE_fnc_sector;

_gridPosition = _bounds select 0;
_gridWidth = (_dimensions select 0) * 2;
_sectorWidth = _gridWidth / _sectors;

_grid = [nil, "create"] call ALIVE_fnc_sectorGrid;
[_grid, "init"] call ALIVE_fnc_sectorGrid;
[_grid, "id",_gridID] call ALIVE_fnc_sectorGrid;
[_grid, "gridPosition", [_gridPosition select 0, _gridPosition select 1]] call ALIVE_fnc_sectorGrid;
[_grid, "gridSize", _gridWidth] call ALIVE_fnc_sectorGrid;
[_grid, "sectorDimensions", [_sectorWidth,_sectorWidth]] call ALIVE_fnc_sectorGrid;
[_grid, "createGrid"] call ALIVE_fnc_sectorGrid;

_grid