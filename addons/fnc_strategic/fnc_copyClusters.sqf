//#define DEBUG_MODE_FULL
#include <\x\alive\addons\fnc_strategic\script_component.hpp>
SCRIPT(copyClusters);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_copyClusters
Description:
Duplicate an array of clusters

Parameters:
Array - Array of clusters

Returns:
Array - array of duplicated clusters

Examples:
(begin example)
_clusters = [_clusters] call ALIVE_fnc_copyClusters;
(end)

See Also:

Author:
Wolffy
ARJay
Peer Reviewed:
nil
---------------------------------------------------------------------------- */


private ["_clustersCopy","_priority","_size","_nodes","_newNodes","_cluster"];

params [
    ["_clusters", [], [[]]],
    ["_sizeFilter", 0, [0]],
    ["_priorityFilter", 0, [0]]
];

_clustersCopy = [];

{
    _priority = [_x,"priority"] call ALIVE_fnc_hashGet;
    _size = [_x,"size"] call ALIVE_fnc_hashGet;

    if((_size >= _sizeFilter) && (_priority >= _priorityFilter)) then {
        _cluster = [nil, "create"] call ALIVE_fnc_cluster;

        _nodes = [_x,"nodes"] call ALIVE_fnc_hashGet;
        _newNodes = [];
        {
            _newNodes set [count _newNodes, _x];
        } forEach _nodes;

        [_cluster,"nodes",_newNodes] call ALIVE_fnc_hashSet;

        [_cluster,"clusterID",[_x,"clusterID"] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
        [_cluster,"center",[_x,"center"] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
        [_cluster,"size",_size] call ALIVE_fnc_hashSet;
        [_cluster,"type",[_x,"type"] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
        [_cluster,"priority",_priority] call ALIVE_fnc_hashSet;
        [_cluster,"debugColor",[_x,"debugColor"] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
        _clustersCopy set [count _clustersCopy, _cluster];
    };
} forEach _clusters;

_clustersCopy