#include <\x\alive\addons\fnc_strategic\script_component.hpp>
SCRIPT(findClusters);

#undef DEBUG_MODE_FULL

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_findClusters

Description:
Returns a list of logics representing clusters of objects

Parameters:
Array - A list of objects to identify clusters

Returns:
Array - List of cluster logics from the objects specified

Examples:
(begin example)
// identify clusters of objects
_clusters = [_obj_array] call ALIVE_fnc_findClusters;
(end)

See Also:
- <ALIVE_fnc_cluster>
- <ALIVE_fnc_findClusterCenter>

Author:
Wolffy.au
---------------------------------------------------------------------------- */

private ["_obj_array","_err","_clusters","_points","_result","_cluster","_first","_nodes"];

PARAMS_1(_obj_array);
DEFAULT_PARAM(1,_maxdist,MIN_CLUSTER_SIZE);

_err = "objects provided not valid";
ASSERT_DEFINED("_obj_array", _err);
ASSERT_OP(typeName _obj_array, == ,"ARRAY", _err);

_points =+ _obj_array;
_clusters = [];
_result = objNull;
while {count _points > 0} do {
	// Create new cluster
    _cluster = [nil, "create"] call ALIVE_fnc_cluster;
    _clusters set [count _clusters, _cluster];
	// Get first unclustered point
    _first = _points select 0;
    _nodes = [_first];

    // Remove first point from unclustered points array
    _points = _points - [_first];
    _result = [_first, _points, _maxdist] call ALIVE_fnc_getNearestObjectInArray;

    while{_result != _first} do {
        _nodes set [count _nodes,_result];
        //if(_result distance _first > _max) then {_max = _result distance _first;};
        _first = _result;
        // Remove first point from unclustered points array
        _points = _points - [_first];
        _result = [_first, _points, _maxdist] call ALIVE_fnc_getNearestObjectInArray;
    };

    [_cluster, "nodes", _nodes] call ALIVE_fnc_cluster;
};

_clusters;
