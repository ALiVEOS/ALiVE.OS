//#define DEBUG_MODE_FULL
#include <\x\alive\addons\fnc_strategic\script_component.hpp>
SCRIPT(auto_staticClusterOutput);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_auto_staticClusterOutput
Description:
Return string version of a cluster array suitable for storage in flat file

Parameters:
Array - A list of clusters
String - Output array name

Returns:
String - String version of the clusters

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


private ["_result","_state","_nodes"];

params [
    ["_clusters", [], [[]]],
    ["_arrayName", "", [""]],
    ["_count", 0, [0]],
    ["_type", "", [""]]
];

// diag_log str(_this);

_result = true;

"ALiVEClient" callExtension format['clusterData~%1|%2|%3 = [] call ALIVE_fnc_hashCreate;',worldName,_type,_arrayName];
{

	_state = [_x, "state"] call ALIVE_fnc_cluster;
	_nodes = [_state, "nodes"] call ALIVE_fnc_hashGet;

	if(count _nodes > 0) then {

		"ALiVEClient" callExtension format['clusterData~%1|%2|_cluster = [nil, "create"] call ALIVE_fnc_cluster;',worldName,_type];

		"ALiVEClient" callExtension format['clusterData~%1|%2|_nodes = [];',worldName,_type];
		{
			if!(isNil "_x") then {
				"ALiVEClient" callExtension format['clusterData~%1|%2|_nodes set [count _nodes, %3];',worldName,_type,_x];
			};
		} forEach _nodes;
		"ALiVEClient" callExtension format['clusterData~%1|%2|[_cluster,"nodes",_nodes] call ALIVE_fnc_hashSet;',worldName,_type];
		"ALiVEClient" callExtension format['clusterData~%1|%2|[_cluster, "state", _cluster] call ALIVE_fnc_cluster;',worldName,_type];

		"ALiVEClient" callExtension format['clusterData~%1|%2|[_cluster,"clusterID","c_%3"] call ALIVE_fnc_hashSet;',worldName,_type,_count];
		"ALiVEClient" callExtension format['clusterData~%1|%2|[_cluster,"center",%3] call ALIVE_fnc_hashSet;',worldName,_type,[_x,"center"] call ALIVE_fnc_hashGet];
		"ALiVEClient" callExtension format['clusterData~%1|%2|[_cluster,"size",%3] call ALIVE_fnc_hashSet;',worldName,_type,[_x,"size"] call ALIVE_fnc_hashGet];
		"ALiVEClient" callExtension format['clusterData~%1|%2|[_cluster,"type","%3"] call ALIVE_fnc_hashSet;',worldName,_type,[_x,"type"] call ALIVE_fnc_hashGet];
		"ALiVEClient" callExtension format['clusterData~%1|%2|[_cluster,"priority",%3] call ALIVE_fnc_hashSet;',worldName,_type,[_x,"priority"] call ALIVE_fnc_hashGet];
		"ALiVEClient" callExtension format['clusterData~%1|%2|[_cluster,"debugColor","%3"] call ALIVE_fnc_hashSet;',worldName,_type,[_x,"debugColor"] call ALIVE_fnc_hashGet];

		"ALiVEClient" callExtension format['clusterData~%1|%2|[%3,"c_%4",_cluster] call ALIVE_fnc_hashSet;',worldName,_type,_arrayName,_count];

		_count = _count + 1;
	};
} forEach _clusters;

_result