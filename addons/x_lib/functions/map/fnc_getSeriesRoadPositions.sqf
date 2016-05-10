#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(ALIVE_fnc_getSeriesRoadPositions);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getSeriesRoadPositions

Description:
Get a list of road positions in series

Parameters:
Array - Position
Number - Radius to search
Number - Required positions

Returns:
Array - A list of building positions

Examples:
(begin example)
// find nearby houses
_roads = [_position,50,10] call ALIVE_fnc_getSeriesRoadPositions;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_position","_radius","_positionCount","_road","_series","_iterationCount","_findRecurse","_connectedRoads","_positions","_debug"];

/*
_position = [position player] call ALIVE_fnc_getClosestRoad;
_roads = [_position,200,10,true] call ALIVE_fnc_getSeriesRoadPositions;
*/

_position = _this select 0;
_radius = _this select 1;
_positionCount = _this select 2;
_debug = if(count _this > 3) then {_this select 3} else {false};

_road = _position nearRoads _radius;
_series = [];
_iterationCount = 0;

scopeName "main";

if(count _road > 1) then
{

    _road = _road select 0;

    _findRecurse = {

    	_iterationCount = _iterationCount + 1;

    	_road = _this select 0;
    	_series = _this select 1;

    	if!(_road in _series) then {
    	    _series pushback _road;
    	};

    	if(count _series == _positionCount || _iterationCount == _positionCount) then {
    	    breakTo "main";
    	};

    	_connectedRoads = roadsConnectedTo _road;

    	{
    	    [_x,_series] call _findRecurse;
    	} forEach _connectedRoads;

    };

    [_road,_series] call _findRecurse;
};

_positions = [];
{
    _positions pushback (position _x);
} forEach _series;

if(_debug) then {
    {
        [_x] call ALIVE_fnc_spawnDebugMarker;
    } forEach _positions;
};

_positions