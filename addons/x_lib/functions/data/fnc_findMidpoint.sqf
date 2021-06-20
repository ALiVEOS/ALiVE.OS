#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(findMidpoint);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_findMidpoint

Description:
Finds the center point of an array of positions

Parameters:
    Points - Array of 2D/3D points

Returns:
    Position

Examples:
(begin example)
private _pos1 = getpos player;
private _pos2 = _pos1 getpos [45, 100];
private _pos3 = _pos1 getpos [90, 100];
[_pos1, _pos2, _pos3] call ALiVE_fnc_findMidpoint;
(end)

Author:
SpyderBlack723
---------------------------------------------------------------------------- */

// avoid vectoradd so we can take points of varying dimensions

private _sumX = 0;
private _sumY = 0;
{
    _sumX = _sumX + (_x select 0);
    _sumY = _sumY + (_x select 1);
} foreach _this;

private _pointCount = count _this;

[_sumx / _pointCount, _sumY / _pointCount]