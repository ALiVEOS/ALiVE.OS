#include <\x\alive\addons\fnc_strategic\script_component.hpp>
SCRIPT(findClusterCenter);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_findClusterCenter

Description:
Return the centre position of an object cluster

Parameters:
Array - A list of objects to identify clusters

Returns:
Array - Average central position of the cluster

Examples:
(begin example)
// identify clusters of objects
_center = [_obj_array] call ALIVE_fnc_findClusterCenter;
(end)

See Also:
- <ALIVE_fnc_getNearestObjectInArray>
- <ALIVE_fnc_findClusters>

Author:
Wolffy.au
---------------------------------------------------------------------------- */

private ["_nodes","_err","_xmin","_ymin","_xmax","_ymax","_result"];
_nodes = _this param [0, [], [[]]];
_err = format["cluster nodes array not valid - %1",_nodes];
ASSERT_DEFINED("_nodes",_err);
ASSERT_TRUE(typeName _nodes == "ARRAY",_err);

_result = [];
_xmin = 9999999;
_ymin = 9999999;
_xmax = 0;
_ymax = 0;
{
	private["_xp","_yp"];
	_xp = ((getPosATL _x) select 0);
	_yp = ((getPosATL _x) select 1);
	if(_xmin > _xp) then {_xmin = _xp;};
	if(_ymin > _yp) then {_ymin = _yp;};
	if(_xmax < _xp) then {_xmax = _xp;};
	if(_ymax < _yp) then {_ymax = _yp;};
} forEach _nodes;

_result = [_xmin + ((_xmax - _xmin) / 2), _ymin + ((_ymax - _ymin) / 2)];

_result;
