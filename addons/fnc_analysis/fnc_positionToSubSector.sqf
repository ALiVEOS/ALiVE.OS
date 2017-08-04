#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(positionToSubSector);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_positionToSubSector

Description:
Returns a sub sector within the passed sector

Parameters:
Sector - the sector
Scalar - number of rows/columns
Position - the position to convert into a sub sector

Returns:
Sector

Examples:
(begin example)
_subSector = [_sector, 10, getPosATL player] call ALIVE_fnc_positionToSubSector;
(end)

See Also:


Author:
marceldev89
---------------------------------------------------------------------------- */
private _sector = param [0, []];
private _rows = param [1, 10];
private _position = param [2, []];

private _sectorID = [_sector, "id"] call ALiVE_fnc_sector;
private _sectorBounds = [_sector, "bounds"] call ALiVE_fnc_sector;
private _sectorDimensions = [_sector, "dimensions"] call ALiVE_fnc_sector;
private _sectorX = (_sectorBounds select 0) select 0; // Bottom left
private _sectorY = (_sectorBounds select 0) select 1; // Bottom left

private _w = ((_sectorDimensions select 0) * 2) / _rows;
private _h = ((_sectorDimensions select 1) * 2) / _rows;
private _x = floor (((_position select 0) - _sectorX) / _w);
private _y = floor (((_position select 1) - _sectorY) / _h);
private _id = format ["%1_%2_%3", _sectorID, _x, _y];
private _center = [
    _sectorX + (_x * _w) + (_w / 2),
    _sectorY + (_y * _h) + (_h / 2)
];

private _subSector = [nil, "create"] call ALiVE_fnc_sector;
[_subSector, "init"] call ALiVE_fnc_sector;
[_subSector, "gridID", "virtual"] call ALiVE_fnc_sector;
[_subSector, "dimensions", [_w / 2, _h / 2]] call ALiVE_fnc_sector;
[_subSector, "position", _center] call ALiVE_fnc_sector;
[_subSector, "id", _id] call ALiVE_fnc_sector;

_subSector;
