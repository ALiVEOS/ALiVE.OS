#include "\x\alive\addons\fnc_strategic\script_component.hpp"
SCRIPT(findClusters);

#undef DEBUG_MODE_FULL

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_findClusters

Description:
Returns a list of logics representing clusters of objects

Parameters:
Array - A list of objects to identify clusters

Returns:
Array - List of cluster logics from the objects specified

Examples:
(begin example)
// identify clusters of objects
_clusters = [_obj_array] call ALIVE_fnc_findClusters;
(end)

See Also:
- <ALIVE_fnc_cluster>
- <ALIVE_fnc_findClusterCenter>

Author:
Wolffy.au
Jman
---------------------------------------------------------------------------- */

private ["_obj_array","_err","_clusters","_points","_cluster","_first","_nodes"];

PARAMS_1(_obj_array);
DEFAULT_PARAM(1,_maxdist,MIN_CLUSTER_SIZE);

_err = "objects provided not valid";
ASSERT_DEFINED("_obj_array", _err);
ASSERT_OP(typeName _obj_array, == ,"ARRAY", _err);

// A cluster is a chain: from the first unclustered object, step to the nearest unclustered object within
// _maxdist, and again from there, until nothing is that close. Each step used to scan every unclustered
// object left and rebuild the list without the one taken, so the cost grew with the square of the count:
// the 60192 houses of a 40 km terrain had not finished after 30 minutes. The unclustered objects now sit
// in squares a little over _maxdist wide, so a step only reads the 3x3 squares around it, where anything
// nearer than _maxdist has to be. The chains are the same ones: the same distance test, ties going to the
// object earliest in the list as the full scan's strict comparison did, and an object listed twice taken
// as one, as the list subtraction did.

_points =+ _obj_array;
_clusters = [];

private _count = count _points;
// the margin keeps the 3x3 search a superset however an object's position and its distance differ
private _cell = (_maxdist max 1) + 10;
private _grid = createHashMap;          // [column, row] -> indices of the unclustered objects in that square
private _cellOf = [];                   // index -> its square
private _left = [];                     // index -> not yet clustered

{
    private _pos = getPosATL _x;
    private _key = [floor ((_pos select 0) / _cell), floor ((_pos select 1) / _cell)];
    _cellOf pushBack _key;
    _left pushBack true;
    (_grid getOrDefault [_key, [], true]) pushBack _forEachIndex;
} forEach _points;

// takes an object out of the unclustered set, with any other entry for the same object
private _fnc_take = {
    params ["_index"];
    private _object = _points select _index;
    private _square = _grid get (_cellOf select _index);
    for "_k" from (count _square - 1) to 0 step -1 do {
        private _other = _square select _k;
        if ((_points select _other) isEqualTo _object) then {
            _square deleteAt _k;
            _left set [_other, false];
        };
    };
};

// for loops rather than while: unscheduled, a while loop stops after 10000 rounds, and a big list has more
// objects than that to step over or to chain
for "_next" from 0 to (_count - 1) do {
    if !(_left select _next) then { continue };

    _cluster = [nil, "create"] call ALIVE_fnc_cluster;
    _clusters pushback _cluster;
    _first = _points select _next;
    _nodes = [_first];
    [_next] call _fnc_take;
    private _at = _next;

    for "_step" from 1 to _count do {
        private _best = -1;
        private _bestDistance = 999999;
        private _square = _cellOf select _at;
        for "_dx" from -1 to 1 do {
            for "_dy" from -1 to 1 do {
                {
                    private _distance = _first distance (_points select _x);
                    if (_distance < _maxdist && {_distance < _bestDistance || {_distance == _bestDistance && {_x < _best}}}) then {
                        _bestDistance = _distance;
                        _best = _x;
                    };
                } forEach (_grid getOrDefault [[(_square select 0) + _dx, (_square select 1) + _dy], []]);
            };
        };
        if (_best < 0) exitWith {};

        _first = _points select _best;
        _nodes pushback _first;
        [_best] call _fnc_take;
        _at = _best;
    };

    [_cluster, "nodes", _nodes] call ALIVE_fnc_cluster;
};

_clusters;
