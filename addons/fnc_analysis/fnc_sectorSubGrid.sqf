#include "\x\alive\addons\fnc_analysis\script_component.hpp"
SCRIPT(sectorSubGrid);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorSubGrid

Description:
Creates a sub dividing grid within a passed sector

Parameters:
Sector - the sector to sub divide
Scalar - number of sector rows
String - the grid ID name
Array - Optional transient grid returned by this function to reset/reuse
        (server indexing only).
        Its child hashes are overwritten on reuse; callers must not retain
        them between calls. Previously returned position/data arrays remain
        valid. Different subdivision counts or active debug markers rebuild it.

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

// An explicitly supplied transient grid can be reset for indexing. Keep the
// original three-argument constructor and debug lifecycle unchanged.
private _reuse = _this param [3, [], [[]]];
private _count = round (_gridWidth / _sectorWidth);
private _cells = if (count _reuse >= 3) then {[_reuse,"sectors",[]] call ALIVE_fnc_hashGet} else {[]};
private _quiet = count _reuse >= 3 && {count _cells == _count*_count}
    && {([_reuse,"sectorType",""] call ALIVE_fnc_hashGet) == "SECTOR"}
    && {!([_reuse,"debug",false] call ALIVE_fnc_hashGet)}
    && {(_cells findIf {([_x,"debug",false] call ALIVE_fnc_hashGet) || {count ([_x,"debugMarkers",[]] call ALIVE_fnc_hashGet)>0}}) == -1};
if (isServer && {_quiet}) exitWith {
    [_reuse,"id",_gridID] call ALIVE_fnc_hashSet;
    [_reuse,"gridPosition",[_gridPosition select 0,_gridPosition select 1]] call ALIVE_fnc_hashSet;
    [_reuse,"gridSize",_gridWidth] call ALIVE_fnc_hashSet;
    [_reuse,"sectorDimensions",[_sectorWidth,_sectorWidth]] call ALIVE_fnc_hashSet;
    private _originX = _gridPosition select 0;
    private _originY = _gridPosition select 1;
    {
        private _row = _forEachIndex mod _count;
        private _column = floor (_forEachIndex / _count);
        private _position = [_originX+((_row*_sectorWidth)+(_sectorWidth/2)),_originY+((_column*_sectorWidth)+(_sectorWidth/2))];
        // These are private, disposable SECTOR hashes. Replace their key/value
        // arrays together in constructor order, retaining the hash default and
        // both grid arrays' references to the cell. Fresh data and position
        // arrays preserve values already retained by earlier parent sectors.
        _x set [1,["data","gridID","debugColor","dimensions","position","id"]];
        _x set [2,[[] call ALIVE_fnc_hashCreate,_gridID,"ColorBlack",[_sectorWidth/2,_sectorWidth/2],_position,format["%1_%2",_row,_column]]];
    } forEach _cells;
    _reuse
};
// A different cell count or marked grid cannot use the quiet reset path.
if (count _reuse >= 3) then {[_reuse,"destroy"] call ALIVE_fnc_sectorGrid;};

_grid = [nil, "create"] call ALIVE_fnc_sectorGrid;
[_grid, "init"] call ALIVE_fnc_sectorGrid;
[_grid, "id",_gridID] call ALIVE_fnc_sectorGrid;
[_grid, "gridPosition", [_gridPosition select 0, _gridPosition select 1]] call ALIVE_fnc_sectorGrid;
[_grid, "gridSize", _gridWidth] call ALIVE_fnc_sectorGrid;
[_grid, "sectorDimensions", [_sectorWidth,_sectorWidth]] call ALIVE_fnc_sectorGrid;
[_grid, "createGrid"] call ALIVE_fnc_sectorGrid;

_grid