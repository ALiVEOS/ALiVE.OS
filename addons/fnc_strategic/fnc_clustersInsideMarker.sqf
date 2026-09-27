//#define DEBUG_MODE_FULL
#include "\x\alive\addons\fnc_strategic\script_component.hpp"
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
Jman
Peer Reviewed:
nil
---------------------------------------------------------------------------- */


private ["_marker","_markerClusters","_center"];

params [
    ["_clusters", [], [[]]],
    ["_markers", [], [[]]]
];

_markerClusters = [];

if (count _markers > 0) then {
    // Cluster by cluster, so an objective inside 2 overlapping markers is taken once. Marker by
    // marker it went in once per marker, and got placed on twice.
    private _live = _markers select { _x call ALIVE_fnc_markerExists };
    { _x setMarkerAlpha 0 } forEach _live;
    {
        _center = [_x,"center"] call ALIVE_fnc_hashGet;
        if ((_live findIf { [_center, _x] call ALiVE_fnc_inArea }) > -1) then {
            _markerClusters pushback _x;
        };
    } forEach _clusters;
}else{
    _markerClusters = _clusters;
};

_markerClusters
