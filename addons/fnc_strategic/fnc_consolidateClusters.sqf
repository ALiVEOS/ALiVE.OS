//#define DEBUG_MODE_FULL
#include "\x\alive\addons\fnc_strategic\script_component.hpp"
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
Jman
Peer Review:
nil
---------------------------------------------------------------------------- */

private ["_result","_nodes_out","_nodes_x"];

TRACE_1("consolidateClusters - input",_this);

params [
    ["_master", [], [[]]],
    ["_redundant", [], [[]]]
];

_result = _master;

{
    if !(_x in _result) then {
        _result pushback _x;
    };
} foreach _redundant;

["Consolidating %1 targets", count _master] call ALIVE_fnc_dump;

// Each cluster in turn absorbs every other cluster whose centre is close enough and whose priority is no
// higher, taking them in list order and with its own centre and size as they stand after each merge. That
// used to compare every cluster with every other, through six calls into ALIVE_fnc_cluster a pair: 682
// clusters took 43 seconds, Altis's 1523 settlements about 80 minutes, and a terrain several times bigger
// never finished. The same merges now come out in the same order, from two changes:
// - each cluster's centre, size and priority is read once and kept true as clusters merge: a merge
//   recomputes the absorbing cluster's centre and size, as the cluster itself would on its next read, and a
//   destroyed cluster has none, as its emptied hash has none
// - two clusters only merge closer than MAX_CLUSTER_SIZE, so the ones a cluster can absorb are all filed in
//   the nine squares of a grid that size around its centre. They're taken in list order and gathered again
//   from its new square after each merge: a cluster outside those squares when its turn comes is too far
//   away to merge, as it was when it was compared anyway
private _cacheCenter = [];
private _cacheSize = [];
private _cachePriority = [];
{
    if (_x isEqualTo -1) then {
        _cacheCenter pushBack []; _cacheSize pushBack 0; _cachePriority pushBack 0;
    } else {
        _cacheCenter pushBack ([_x, "center"] call ALiVE_fnc_cluster);
        _cacheSize pushBack ([_x, "size"] call ALIVE_fnc_cluster);
        _cachePriority pushBack ([_x, "priority"] call ALiVE_fnc_cluster);
    };
} forEach _master;

private _cell = MAX_CLUSTER_SIZE + 10;
private _grid = createHashMap;
private _filed = [];        // the square each cluster is filed under; [] while it has no centre or has gone
private _fnc_file = {
    params ["_i"];
    private _c = _cacheCenter select _i;
    if (count _c == 0) exitWith { _filed set [_i, []] };
    private _key = [floor ((_c select 0) / _cell), floor ((_c select 1) / _cell)];
    (_grid getOrDefault [_key, [], true]) pushBack _i;
    _filed set [_i, _key];
};
private _fnc_unfile = {
    params ["_i"];
    private _key = _filed select _i;
    if (count _key > 0) then {
        private _square = _grid get _key;
        private _at = _square find _i;
        if (_at >= 0) then { _square deleteAt _at };
    };
    _filed set [_i, []];
};
// the clusters filed in the nine squares around cluster _i, after list place _after, in list order
private _fnc_near = {
    params ["_i", "_after"];
    private _key = _filed select _i;
    private _near = [];
    if (count _key > 0) then {
        for "_dx" from -1 to 1 do {
            for "_dy" from -1 to 1 do {
                {
                    if (_x > _after && {_x != _i}) then { _near pushBack _x };
                } forEach (_grid getOrDefault [[(_key select 0) + _dx, (_key select 1) + _dy], []]);
            };
        };
        _near sort true;
    };
    _near
};
private _dead = [];
{
    _dead pushBack (_x isEqualTo -1);
    _filed pushBack [];
    [_forEachIndex] call _fnc_file;
} forEach _master;

// iterate through master list of clusters
{
    private _out = _x;
    private _outAt = _forEachIndex;
    // a cluster that has been absorbed absorbs nothing itself
    if !(_dead select _outAt) then {
        private _near = [_outAt, -1] call _fnc_near;
        private _n = 0;
        while {_n < count _near} do {
            private _xAt = _near select _n;
            _n = _n + 1;
            private _other = _master select _xAt;
            // the self-pair is a reference match rather than merely a value one, as it always was
            if (!(_dead select _xAt) && {!(_out isEqualRef _other)}) then {
                private _out_center = _cacheCenter select _outAt;
                private _x_center = _cacheCenter select _xAt;
                // valid cluster centers
                if (count _out_center != 0 && {count _x_center != 0}) then {
                    private _max = ((_cacheSize select _xAt) + (_cacheSize select _outAt)) max MIN_CLUSTER_SIZE min MAX_CLUSTER_SIZE;
                    // if cluster is within master cluster and of a lower priority
                    if ((_x_center distance _out_center) < _max && {(_cachePriority select _outAt) >= (_cachePriority select _xAt)}) then {
                        // select nodes of both clusters
                        _nodes_out = ([_out, "nodes"] call ALIVE_fnc_cluster);
                        _nodes_x = ([_other, "nodes"] call ALIVE_fnc_cluster);

                        // combine them and ensure that old nodes are only added if the master doesnt have them already
                        {
                            if !(_x in _nodes_out) then {
                                _nodes_out pushback _x;
                            };
                        } foreach _nodes_x;

                        // set the new nodes
                        [_out, "nodes", _nodes_out] call ALIVE_fnc_cluster;

                        // and remove cluster from list
                        [_other, "destroy"] call ALIVE_fnc_cluster;
                        _dead set [_xAt, true];
                        // the first cluster's pass has always worked on the master list itself
                        if (_outAt == 0) then { _master set [_xAt, -1] };

                        _cacheCenter set [_outAt, [_out, "center"] call ALiVE_fnc_cluster];
                        _cacheSize set [_outAt, [_out, "size"] call ALIVE_fnc_cluster];
                        _cacheCenter set [_xAt, []];
                        [_xAt] call _fnc_unfile;
                        [_outAt] call _fnc_unfile;
                        [_outAt] call _fnc_file;
                        // its centre has moved: what it can reach now, from the next place in the list
                        _near = [_outAt, _xAt] call _fnc_near;
                        _n = 0;
                    };
                };
            };
        };
    };
} forEach _master;

_result = [];
{
    if !(_dead select _forEachIndex) then { _result pushBack _x };
} forEach _master;

["Targets Consolidated"] call ALIVE_fnc_dump;

// return master list
TRACE_1("consolidateClusters - output",_result);
_result;
