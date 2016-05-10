#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(gridPos);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_gridPos

Description:
Returns the map-grid [0,0] position of given pos.

Parameters:
Array - position

Returns:
Array - map-grid [0,0] position of given pos.

Examples:
(begin example)
// get current mapgrid
_mapGridPos = (getpos player) call ALIVE_fnc_gridPos;
(end)

See Also:
- <ALIVE_fnc_fnc_createGrid>

Author:
Highhead
---------------------------------------------------------------------------- */

private ["_pos","_x","_y"];

_pos = _this;
_x = _pos select 0;
_y = _pos select 1;

_x = _x-(_x % 100);
_y = _y-(_y % 100);

[_x+50,_y+50,0]
