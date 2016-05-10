//#define DEBUG_MODE_FULL
#include <\x\alive\addons\fnc_strategic\script_component.hpp>
SCRIPT(staticClusterOutput);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_staticClusterOutput
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
    ["_count", 0, [0]]
];

_result = format['%1 = [] call ALIVE_fnc_hashCreate;',_arrayName];
{
	_state = [_x, "state"] call ALIVE_fnc_cluster;
	_nodes = [_state, "nodes"] call ALIVE_fnc_hashGet;
	
	if(count _nodes > 0) then {	
		_result = _result + '_cluster = [nil, "create"] call ALIVE_fnc_cluster;';
		
		_result = _result + '_nodes = [];';
		{
			if!(isNil "_x") then {
				_result = _result + format['_nodes set [count _nodes, %1];',_x];
			};
		} forEach _nodes;
		_result = _result + '[_cluster,"nodes",_nodes] call ALIVE_fnc_hashSet;';
		_result = _result + '[_cluster, "state", _cluster] call ALIVE_fnc_cluster;';		
		
		_result = _result + format['[_cluster,"clusterID","c_%1"] call ALIVE_fnc_hashSet;',_count];
		_result = _result + format['[_cluster,"center",%1] call ALIVE_fnc_hashSet;',[_x,"center"] call ALIVE_fnc_hashGet];
		_result = _result + format['[_cluster,"size",%1] call ALIVE_fnc_hashSet;',[_x,"size"] call ALIVE_fnc_hashGet];
		_result = _result + format['[_cluster,"type","%1"] call ALIVE_fnc_hashSet;',[_x,"type"] call ALIVE_fnc_hashGet];
		_result = _result + format['[_cluster,"priority",%1] call ALIVE_fnc_hashSet;',[_x,"priority"] call ALIVE_fnc_hashGet];
		_result = _result + format['[_cluster,"debugColor","%1"] call ALIVE_fnc_hashSet;',[_x,"debugColor"] call ALIVE_fnc_hashGet];
		
		_result = _result + format['[%1,"c_%2",_cluster] call ALIVE_fnc_hashSet;',_arrayName,_count];
		
		_count = _count + 1;
	};
} forEach _clusters;

_result