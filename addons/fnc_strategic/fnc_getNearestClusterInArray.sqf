#include <\x\alive\addons\fnc_strategic\script_component.hpp>
SCRIPT(getNearestClusterInArray);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getNearestClusterInArray

Description:
Returns the nearest cluster to the given cluster from a list of clusters

Parameters:
Cluster - The cluster for comparison
Array - A list of clusters to compare
Number - Maximum distance allowed (optional)

Returns:
Cluster - Nearest cluster

Examples:
(begin example)
_nearest = [_point, _cluster_array] call ALIVE_fnc_getNearestClusterInArray;
(end)

See Also:
- <ALIVE_fnc_getObjectsByType>
- <ALIVE_fnc_chooseInitialCenters>

Author:
Wolffy.au
---------------------------------------------------------------------------- */

private ["_point","_cluster","_minDistance","_maxDistance","_minCluster","_pcenter","_distance","_err"];
PARAMS_2(_point,_cluster);
DEFAULT_PARAM(2,_maxDistance,999999);

_err = "point provided not valid";
ASSERT_DEFINED("_point",_err);
ASSERT_TRUE(typeName _point == "OBJECT", _err);
_err = "array of clusters provided not valid";
ASSERT_DEFINED("_cluster",_err);
ASSERT_TRUE(typeName _cluster == "ARRAY", _err);

_minDistance = 999999;
_minCluster = nil;
_pcenter = [_point, "center"] call ALIVE_fnc_cluster;
{
	_distance = _pcenter distance ([_x, "center"] call ALIVE_fnc_cluster);
	if (!([_pcenter, _x] call BIS_fnc_areEqual) && {_distance < _minDistance} && {_distance < _maxDistance}) then {
		_minDistance = _distance;
		_minCluster = _x;
	};
} forEach _cluster;

if(isNil "_minCluster") then {_minCluster = _point;};
_minCluster;
