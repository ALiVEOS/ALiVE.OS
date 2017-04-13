#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(getClosestRoad);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getClosestRoad

Description:
Gets the closest position that is road

Parameters:
Array - Position center point for search
Scalar - Max Radius of search

Returns:
Array - position

Examples:
(begin example)
// get closest road
_position = [getPos player, 500] call ALIVE_fnc_getClosestRoad;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private _position = _this select 0;
private _maxRadius = if (count _this > 1) then {_this select 1} else {5000};

private _radius = 100;
private _inc = 100;
private _roads = [];

while {
    _roads = _position nearroads _radius;
    
    if (canSuspend) then {sleep 0.02};

    count (_roads) == 0 || {_radius > _maxRadius};
} do {
    _radius = _radius + _inc;
};

if (count _roads == 0) exitwith {_position};

private _road = ([_roads,[_position],{_x distance _Input0},"ASCEND"] call ALiVE_fnc_SortBy) select 0;

_result = position _road;

_result