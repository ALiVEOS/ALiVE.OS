//#define DEBUG_MODE_FULL
#include <\x\alive\addons\fnc_strategic\script_component.hpp>
SCRIPT(clustersInsideMarker);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_clustersInsideMarker
Description:
Return clusters inside the marker

Parameters:
Array - A list of clusters
Marker - The marker to check

Returns:
Array - A list of clusters within the marker

Examples:
(begin example)
_clusters = [_clusters, _marker] call ALIVE_fnc_clustersInsideMarker;
(end)

See Also:

Author:
ARJay
Peer Reviewed:
nil
---------------------------------------------------------------------------- */


private ["_marker","_markerClusters","_center"];

params [
    ["_clusters", [], [[]]],
    ["_markers", [], [[]]]
];

_markerClusters = [];

if(count _markers > 0) then {
	{
		_marker =_x;
		if(_marker call ALIVE_fnc_markerExists) then {
			_marker setMarkerAlpha 0;
			{
				_center = [_x,"center"] call ALIVE_fnc_hashGet;
				if([_center,_marker] call ALiVE_fnc_inArea) then {
					_markerClusters set [count _markerClusters, _x];
				};
			} forEach _clusters;
		};
	} forEach _markers;
}else{
	_markerClusters = _clusters;
};

_markerClusters