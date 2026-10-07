#include "\x\alive\addons\fnc_strategic\script_component.hpp"
SCRIPT(findClusters);

#undef DEBUG_MODE_FULL

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_findClusters

Description:
Returns object clusters using the original greedy nearest-neighbor chain.
The x_lib spatial grid narrows candidates; final distances still use object distance.
Input objects must remain stationary for the duration of the call.
Unresolved (null) objects are omitted.

Parameters:
Array - Objects, in seed and nearest-neighbor tie order
Number - Maximum neighbor distance (optional, defaults to 150)

Returns:
Array - Clusters, with the same seed and node order as the linear algorithm

Examples:
_clusters = [_objects] call ALIVE_fnc_findClusters;
Author:
Wolffy.au (original algorithm)
Jman (large-list traversal approach)
---------------------------------------------------------------------------- */

PARAMS_1(_obj_array);
DEFAULT_PARAM(1,_maxdist,MIN_CLUSTER_SIZE);
private _err = "objects provided not valid";
ASSERT_DEFINED("_obj_array", _err);
ASSERT_OP(typeName _obj_array, == ,"ARRAY", _err);

PROFILE_SCOPE(CLUSTERING, "ALiVE_fnc_findClusters: spatial")
private _cellSize = 150;
private _entries = [];
private _rawPoints = [];
private _points = [];
private _active = [];

PROFILE_SCOPE(INDEX, "ALiVE_fnc_findClusters: build x_lib grid")
private _minX = 0;
private _minY = 0;
private _maxX = 0;
private _maxY = 0;
{
    if (!isNull _x) then {
        private _position = getPosWorld _x;
        _rawPoints pushBack [_position, _x];
        _minX = _minX min (_position select 0);
        _minY = _minY min (_position select 1);
        _maxX = _maxX max (_position select 0);
        _maxY = _maxY max (_position select 1);
    };
} forEach _obj_array;
// Align the shared grid with the previous 150 m lattice. A non-positive
// origin also accommodates its existing abs(origin) coordinate convention.
private _origin = [floor (_minX / _cellSize) * _cellSize, floor (_minY / _cellSize) * _cellSize];
private _gridSize = ((_maxX - (_origin select 0)) max (_maxY - (_origin select 1))) + _cellSize;
private _grid = [nil, "create", [_origin, _gridSize, _cellSize]] call ALiVE_fnc_spacialGrid;
{
    _x params ["_position", "_object"];
    private _coords = _grid call ["posToCoords", _position];
    private _bucket = _grid call ["coordsToSector", _coords];
    // Keep first occurrence/order. HashMap cannot use object identity as a key.
    if ((_bucket findIf {(_points select (_x select 1)) isEqualTo _object}) == -1) then {
        private _entry = [_position, count _points];
        _points pushBack _object;
        _entries pushBack _entry;
        _active pushBack true;
        _grid call ["insert", [_entry]];
    };
} forEach _rawPoints;
PROFILE_SCOPE_END(INDEX)

private _clusters = [];
// The old helper starts its minimum at 999999 even for larger max distances.
private _searchRadius = (_maxdist max 0) min 999999;
PROFILE_SCOPE(CHAINS, "ALiVE_fnc_findClusters: build chains")
for "_seed" from 0 to ((count _points) - 1) do {
    if (_active select _seed) then {
        private _cluster = [nil, "create"] call ALIVE_fnc_cluster;
        _clusters pushBack _cluster;
        private _nodes = [];
        private _current = _seed;

        // Each step consumes one point. Bound traversal by the input count:
        // unscheduled while loops are capped at 10,000 iterations by the engine.
        for "_chainStep" from 0 to ((count _points) - 1) do {
            if (_current == -1) exitWith {};
            private _first = _points select _current;
            _nodes pushBack _first;
            _active set [_current, false];
            private _entry = _entries select _current;
            // Remove consumed entries through the shared API. Subsequent range
            // queries only return unconsumed points, including in dense cells.
            _grid call ["remove", _entry];
            private _near = _grid call ["findInRange", [_entry select 0, _searchRadius, true, false, false]];
            private _bestDistance = 999999;
            private _next = -1;
            {
                private _candidate = _x select 1;
                private _distance = _first distance (_points select _candidate);
                // Range queries are broad-phase only. Keep strict engine distance
                // checks and original input ordinals for equal-distance ties.
                if (_distance < _maxdist && {_distance < 999999} && {
                    _distance < _bestDistance || {_distance == _bestDistance && {_candidate < _next}}
                }) then {
                    _bestDistance = _distance;
                    _next = _candidate;
                };
            } forEach _near;
            _current = _next;
        };
        [_cluster, "nodes", _nodes] call ALIVE_fnc_cluster;
    };
};
PROFILE_SCOPE_END(CHAINS)

PROFILE_SCOPE_END(CLUSTERING)
_clusters
