//#define DEBUG_MODE_FULL
#include "\x\alive\addons\fnc_strategic\script_component.hpp"
SCRIPT(auto_staticClusterOutput);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_auto_staticClusterOutput
Description:
Return string version of a cluster array suitable for storage in flat file

Parameters:
Array - A list of clusters
String - Output array name

Returns:
Bool - write/queue success (shared contexts must be flushed by the caller)

Examples:
(begin example)
_clusters = [_clusters, "ALIVE_clusters"] call ALIVE_fnc_staticClusterOutput;
(end)

See Also:

Author:
ARJay

Peer Reviewed:
nil
---------------------------------------------------------------------------- */


private ["_state","_nodes"];

params [
    ["_clusters", [], [[]]],
    ["_arrayName", "", [""]],
    ["_count", 0, [0]],
    ["_type", "", [""]],
    ["_exportWriter", createHashMap, [createHashMap]]
];

// diag_log str(_this);

private _ownsWriter = count _this < 5;

[_exportWriter, format['clusterData~%1|%2|%3 = [] call ALIVE_fnc_hashCreate;',worldName,_type,_arrayName]] call ALIVE_fnc_exportWrite;
{

    _state = [_x, "state"] call ALIVE_fnc_cluster;
    _nodes = [_state, "nodes"] call ALIVE_fnc_hashGet;

    if(count _nodes > 0) then {

        [_exportWriter, format['clusterData~%1|%2|_cluster = [nil, "create"] call ALIVE_fnc_cluster;',worldName,_type]] call ALIVE_fnc_exportWrite;

        [_exportWriter, format['clusterData~%1|%2|_nodes = [];',worldName,_type]] call ALIVE_fnc_exportWrite;
        {
            if!(isNil "_x") then {
                [_exportWriter, format['clusterData~%1|%2|_nodes set [count _nodes, %3];',worldName,_type,_x]] call ALIVE_fnc_exportWrite;
            };
        } forEach _nodes;
        [_exportWriter, format['clusterData~%1|%2|[_cluster,"nodes",_nodes] call ALIVE_fnc_hashSet;',worldName,_type]] call ALIVE_fnc_exportWrite;
        [_exportWriter, format['clusterData~%1|%2|[_cluster, "state", _cluster] call ALIVE_fnc_cluster;',worldName,_type]] call ALIVE_fnc_exportWrite;

        [_exportWriter, format['clusterData~%1|%2|[_cluster,"clusterID","c_%3"] call ALIVE_fnc_hashSet;',worldName,_type,_count]] call ALIVE_fnc_exportWrite;
        // Same accessor requirement as fnc_staticClusterOutput - a merged cluster's
        // center/size are invalidated until read through ALIVE_fnc_cluster.
        [_exportWriter, format['clusterData~%1|%2|[_cluster,"center",%3] call ALIVE_fnc_hashSet;',worldName,_type,[_x,"center"] call ALIVE_fnc_cluster]] call ALIVE_fnc_exportWrite;
        [_exportWriter, format['clusterData~%1|%2|[_cluster,"size",%3] call ALIVE_fnc_hashSet;',worldName,_type,[_x,"size"] call ALIVE_fnc_cluster]] call ALIVE_fnc_exportWrite;
        [_exportWriter, format['clusterData~%1|%2|[_cluster,"type","%3"] call ALIVE_fnc_hashSet;',worldName,_type,[_x,"type"] call ALIVE_fnc_hashGet]] call ALIVE_fnc_exportWrite;
        [_exportWriter, format['clusterData~%1|%2|[_cluster,"priority",%3] call ALIVE_fnc_hashSet;',worldName,_type,[_x,"priority"] call ALIVE_fnc_hashGet]] call ALIVE_fnc_exportWrite;
        [_exportWriter, format['clusterData~%1|%2|[_cluster,"debugColor","%3"] call ALIVE_fnc_hashSet;',worldName,_type,[_x,"debugColor"] call ALIVE_fnc_hashGet]] call ALIVE_fnc_exportWrite;

        [_exportWriter, format['clusterData~%1|%2|[%3,"c_%4",_cluster] call ALIVE_fnc_hashSet;',worldName,_type,_arrayName,_count]] call ALIVE_fnc_exportWrite;

        _count = _count + 1;
    };
} forEach _clusters;

if (_ownsWriter) then {[_exportWriter] call ALIVE_fnc_exportWrite} else {(_exportWriter getOrDefault ["error", ""]) == ""}
