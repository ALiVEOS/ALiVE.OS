#include "\x\alive\addons\fnc_strategic\script_component.hpp"
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
Jman
---------------------------------------------------------------------------- */

private ["_nodes","_err","_xmin","_ymin","_xmax","_ymax","_result"];
_nodes = _this param [0, [], [[]]];
_err = format["cluster nodes array not valid - %1",_nodes];
ASSERT_DEFINED("_nodes",_err);
ASSERT_TRUE(typeName _nodes == "ARRAY",_err);

// Empty-nodes guard. Without this, the bounding-box init below
// resolves to [4999999.5, 4999999.5] -- midpoint between
// _xmin = 9999999 (never decremented) and _xmax = 0 (never
// bumped). That's a ~5000 km off-map position downstream
// consumers (mil_c2istar task generation, mil_placement
// spawn-anchor selection) would treat as a real cluster centre.
// Empty input = no cluster centre = return [].
if (count _nodes == 0) exitWith {[]};

// _xmax / _ymax initialised to a very negative number rather
// than 0 so the "update if larger" check correctly tracks the
// maximum even when all node positions are negative. The prior
// _xmax = 0 init silently produced midpoints between
// real-negative _xmin and zero-stuck _xmax, which manifested
// as cluster centres like [-2620.79, 3456.32] on Chernarus
// (Rujasu's 2026-05-19 report -- VIPEscort destination marker
// landed 2.6 km west of the map's origin, deep ocean). The
// Hearts-and-Minds task picker (taskGetCivilianCluster) selects
// the furthest cluster for "Long" task types, and off-map
// distance always sorts top of an ascending distance list -- so
// the corrupt centroid always won selection.
_result = [];
_xmin =  9999999;
_ymin =  9999999;
_xmax = -9999999;
_ymax = -9999999;
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

// Water-snap fallback. Bounding-box midpoint can land in water when
// the cluster's nodes span a bay or peninsula neck (one settlement
// north of the bay, another south - the midpoint sits on the water
// between them). Downstream consumers (mil_placement guard
// placement, cluster-anchored task spawns) treat _result as a
// land-side reference and break when it's underwater. Snap to the
// nearest node - nodes are static objects (buildings) so they're
// land-guaranteed.
if ((count _nodes > 0) && {surfaceIsWater _result}) then {
    private _nearest = _nodes select 0;
    private _nearestDist = (getPosATL _nearest) distance2D _result;
    {
        private _d = (getPosATL _x) distance2D _result;
        if (_d < _nearestDist) then {
            _nearest = _x;
            _nearestDist = _d;
        };
    } forEach _nodes;
    private _np = getPosATL _nearest;
    _result = [_np select 0, _np select 1];
};

_result;
