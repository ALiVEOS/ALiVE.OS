#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(createTraceGrid);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_createTraceGrid
Description:
Marks all grid-sectors with buildings within the given radius of a position. Use on server with ALiVE_fnc_updateTraceGrid.

Parameters:
array - position
number - radius

Returns:
array - grid

Examples:
(begin example)
            [
				getpos player,
                500
            ] call ALIVE_fnc_createTraceGrid;
(end)

See Also:
- <ALIVE_fnc_updateTraceGrid>

Author:
Highhead

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_pos","_radius","_grid","_fill"];

_pos = _this select 0;
_radius = _this select 1;
_fill = if (count _this > 2) then {_this select 2} else {"Solid"};

//Create store (TBD: persist to DB via MIL_C2ISTAR)
if (isnil QGVAR(TRACEGRID_STORE)) then {GVAR(TRACEGRID_STORE) = [] call ALiVE_fnc_HashCreate};

_grid = [];

{
    private ["_gridPos","_markerID"];

    _gridPos = (getposATL _x) call ALiVE_fnc_GridPos;
    _markerID = format["ALiVE_TraceGrid_%1%2",_gridpos select 0,_gridPos select 1];

    if !(_markerID in _grid) then {
        [_markerID,_gridPos,"RECTANGLE", [50,50], "COLORRED", "", "EMPTY", _fill, 0, 0.5] call ALIVE_fnc_createMarkerGlobal;
        _grid pushBack _markerID;
    };
} foreach ([_pos,_radius] call ALiVE_fnc_getEnterableHouses);

_grid