//#define DEBUG_MODE_FULL
#include <\x\alive\addons\fnc_strategic\script_component.hpp>
SCRIPT(consolidateClusters);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_consolidateClusters

Description:
Returns a consolidated list of logics representing clusters of objects

Parameters:
Array - A master list of objects to identify clusters
Array - A list of clusters possibly over-lapping master entries (optional)

Returns:
Array - Returns the master list

Examples:
(begin example)
// identify redundant clusters after a merge
_clusters = [_master_list, _redundant_list] call ALIVE_fnc_consolidateClusters;
_new_master = _clusters;
(end)

See Also:
- <ALIVE_fnc_findClusterCenter>
- <ALIVE_fnc_findClusters>

Author:
Wolffy.au
Peer Review:
nil
---------------------------------------------------------------------------- */

private ["_err","_result","_nodes_out","_nodes_x"];

TRACE_1("consolidateClusters - input",_this);

params [
    ["_master", [], [[]]],
    ["_redundant", [], [[]]]
];

_err = "objects provided not valid";
ASSERT_DEFINED("_master", _err);
ASSERT_DEFINED("_redundant", _err);
ASSERT_OP(typeName _master, == ,"ARRAY", _err);
ASSERT_OP(typeName _redundant, == ,"ARRAY", _err);
ASSERT_OP(count _master,>,0,_err);
_result = _master;

{
	if !(_x in _result) then {
		_result set [count _result, _x];
	};
} foreach _redundant;

["Consolidating %1 targets", count _master] call ALIVE_fnc_dump;

// iterate through master list of clusters
{
	private["_out","_max","_dist"];
	_out = _x;
	// for each redundant cluster
	{
		// if duplicate of master list - remove
		// if already nullified -1 - remove
		if(str _out != "-1" && str _x != "-1" && str _out != str _x) then {
			// check for cluster within master cluster
			private ["_out_nodes","_nodes","_out_center","_x_center","_out_prio","_x_prio"];
			_out_center = [_out, "center"] call ALiVE_fnc_cluster;
			_x_center = [_x, "center"] call ALiVE_fnc_cluster;
			// valid cluster centers
			if(count _out_center != 0 && count _x_center != 0) then {
				_max = (([_x, "size"] call ALIVE_fnc_cluster) + ([_out, "size"] call ALIVE_fnc_cluster)) max MIN_CLUSTER_SIZE min MAX_CLUSTER_SIZE;
				// if cluster is within master cluster and of a lower priority
				_out_prio = [_out, "priority"] call ALiVE_fnc_cluster;
				_x_prio = [_x, "priority"] call ALiVE_fnc_cluster;
				if((_x_center distance _out_center) < _max && _out_prio >= _x_prio) then {
					// select nodes of both clusters
					_nodes_out = ([_out, "nodes"] call ALIVE_fnc_cluster);
					_nodes_x = ([_x, "nodes"] call ALIVE_fnc_cluster);

					// combine them and ensure that old nodes are only added if the master doesnt have them already
					{
						if !(_x in _nodes_out) then {
							_nodes_out set [count _nodes_out, _x];
						};
					} foreach _nodes_x;

					// set the new nodes
					[_out, "nodes", _nodes_out] call ALIVE_fnc_cluster;
					
					// and remove cluster from list
					[_x, "destroy"] call ALIVE_fnc_cluster;
					_result set [_forEachIndex, -1];
				};
			};
		};
	} forEach _result;
	_result = _result - [-1];
} forEach _master;

["Targets Consolidated"] call ALIVE_fnc_dump;

// return master list
TRACE_1("consolidateClusters - output",_result);
_result;