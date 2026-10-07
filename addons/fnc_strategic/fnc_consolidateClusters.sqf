//#define DEBUG_MODE_FULL
#include "\x\alive\addons\fnc_strategic\script_component.hpp"
SCRIPT(consolidateClusters);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_consolidateClusters

Description:
Consolidate clusters using an x_lib spatial grid with 700 m cells. Candidate
order, priority, strict distance checks, node order and master-array aliasing
match the original pass. Reindex merged centers and query remaining ordinals
again; do not revisit candidates already passed. Input nodes must be stationary.

Parameters:
Array - Master clusters
Array - Additional clusters (optional)
HashMap - Optional output metrics

Returns:
Array - Surviving clusters, in original order

Author:
Wolffy.au
Jman
---------------------------------------------------------------------------- */

params [
    ["_master", [], [[]]],
    ["_redundant", [], [[]]],
    ["_metrics", createHashMap]
];
private _instrument = count _this > 2;
private _started = diag_tickTime;
PROFILE_SCOPE(CONSOLIDATE, "ALiVE_fnc_consolidateClusters: spatial")
private _result = _master;
{
    if !(_x in _result) then {_result pushBack _x;};
} forEach _redundant;
["Consolidating %1 targets", count _master] call ALIVE_fnc_dump;

// Push references individually: unary + would deep-copy the cluster hashes.
private _slots = [];
private _liveIDs = [];
private _entries = [];
private _aliases = [];
private _centers = [];
private _minX = 0;
private _minY = 0;
private _maxX = 0;
private _maxY = 0;
private _includePosition = {
    _minX = _minX min (_this select 0);
    _minY = _minY min (_this select 1);
    _maxX = _maxX max (_this select 0);
    _maxY = _maxY max (_this select 1);
};
private _distanceChecks = 0;
private _queries = 0;
private _candidateEntries = 0;
private _merges = 0;
private _indexMoves = 0;

PROFILE_SCOPE(INDEX, "ALiVE_fnc_consolidateClusters: build grid")
{
    _slots pushBack _x;
    _liveIDs pushBack (if (_x isEqualTo -1) then {-1} else {_forEachIndex});
    _entries pushBack [];
    _aliases pushBack [];
    private _center = [];
    if !(_x isEqualTo -1) then {
        _center = [_x, "center"] call ALIVE_fnc_cluster;
        if (count _center > 0) then {_center call _includePosition;};
        // Bounding-box centers and water-snapped centers can move beyond the
        // initial center range. Every merged node is drawn from this input.
        {getPosATL _x call _includePosition;} forEach ([_x, "nodes", []] call ALIVE_fnc_hashGet);
    };
    _centers pushBack _center;
} forEach _result;
private _cellSize = MAX_CLUSTER_SIZE;
private _origin = [floor (_minX / _cellSize) * _cellSize, floor (_minY / _cellSize) * _cellSize];
private _gridSize = ((_maxX - (_origin select 0)) max (_maxY - (_origin select 1))) + _cellSize;
private _grid = [nil, "create", [_origin, _gridSize, _cellSize]] call ALiVE_fnc_spacialGrid;
{
    private _id = _forEachIndex;
    if (count _x > 0) then {
        private _bucket = _grid call ["coordsToSector", _grid call ["posToCoords", _x]];
        private _alias = _bucket findIf {(_slots select (_x select 1)) isEqualRef (_slots select _id)};
        private _group = if (_alias == -1) then {[]} else {_aliases select ((_bucket select _alias) select 1)};
        _group pushBack _id;
        _aliases set [_id, _group];
        private _entry = [_x, _id];
        _entries set [_id, _entry];
        _grid call ["insert", [_entry]];
    };
} forEach _centers;
PROFILE_SCOPE_END(INDEX)
private _indexSeconds = diag_tickTime - _started;

PROFILE_SCOPE(MERGES, "ALiVE_fnc_consolidateClusters: merge pass")
{
    private _out = _x;
    private _outID = _forEachIndex;
    private _cursor = -1;
    private _refresh = !(_out isEqualTo -1) && {count _result > 0};
    // Every refresh absorbs a later slot. Bound retries by the slot count
    // without the engine's 10,000-iteration unscheduled while-loop limit.
    for "_mergePass" from 0 to (count _slots) do {
        if (!_refresh) exitWith {};
        _refresh = false;
        private _outCenter = [_out, "center"] call ALIVE_fnc_cluster;
        if (count _outCenter > 0) then {
            private _candidates = _grid call ["findInRange", [_outCenter, MAX_CLUSTER_SIZE, true, true, false]];
            if (_instrument) then {
                _queries = _queries + 1;
                _candidateEntries = _candidateEntries + count _candidates;
            };
            _candidates = _candidates select {_x > _cursor};
            _candidates sort true;
            {
                private _id = _x;
                _cursor = _id;
                private _other = _slots select _id;
                if !(_out isEqualRef _other) then {
                    private _otherCenter = [_other, "center"] call ALIVE_fnc_cluster;
                    if (count _otherCenter > 0) then {
                        private _max = (([_other, "size"] call ALIVE_fnc_cluster) + ([_out, "size"] call ALIVE_fnc_cluster)) max MIN_CLUSTER_SIZE min MAX_CLUSTER_SIZE;
                        private _outPriority = [_out, "priority"] call ALIVE_fnc_cluster;
                        private _otherPriority = [_other, "priority"] call ALIVE_fnc_cluster;
                        if (_instrument) then {_distanceChecks = _distanceChecks + 1;};
                        if ((_otherCenter distance _outCenter) < _max && {_outPriority >= _otherPriority}) then {
                            private _nodesOut = [_out, "nodes"] call ALIVE_fnc_cluster;
                            private _nodesOther = [_other, "nodes"] call ALIVE_fnc_cluster;
                            {
                                if !(_x in _nodesOut) then {_nodesOut pushBack _x;};
                            } forEach _nodesOther;
                            [_out, "nodes", _nodesOut] call ALIVE_fnc_cluster;

                            // Destroy empties all aliases of the absorbed hash, but
                            // the original removes only the selected result slot.
                            {
                                private _entry = _entries select _x;
                                if (count _entry > 0) then {_grid call ["remove", _entry];};
                                _entries set [_x, []];
                            } forEach (_aliases select _id);
                            [_other, "destroy"] call ALIVE_fnc_cluster;
                            private _resultIndex = _liveIDs find _id;
                            _result set [_resultIndex, -1];
                            _liveIDs set [_resultIndex, -1];
                            if (_instrument) then {_merges = _merges + 1;};

                            private _newCenter = [_out, "center"] call ALIVE_fnc_cluster;
                            {
                                private _entry = _entries select _x;
                                if (count _newCenter > 0) then {
                                    _grid call ["move", [_entry select 0, _newCenter, _x]];
                                    _entries set [_x, [_newCenter, _x]];
                                    if (_instrument) then {_indexMoves = _indexMoves + 1;};
                                } else {
                                    _grid call ["remove", _entry];
                                    _entries set [_x, []];
                                };
                            } forEach (_aliases select _outID);
                            _refresh = true;
                        };
                    };
                };
                if (_refresh) exitWith {};
            } forEach _candidates;
        };
    };
    // Preserve the original first-pass master mutation and compaction points.
    _result = _result - [-1];
    _liveIDs = _liveIDs - [-1];
} forEach _master;
PROFILE_SCOPE_END(MERGES)

if (_instrument) then {
    _metrics set ["inputClusters", count _slots];
    _metrics set ["outputClusters", count _result];
    _metrics set ["cellSize", _cellSize];
    _metrics set ["distanceChecks", _distanceChecks];
    _metrics set ["queries", _queries];
    _metrics set ["candidateEntries", _candidateEntries];
    _metrics set ["merges", _merges];
    _metrics set ["indexMoves", _indexMoves];
    _metrics set ["indexSeconds", _indexSeconds];
    _metrics set ["totalSeconds", diag_tickTime - _started];
};
["Targets Consolidated"] call ALIVE_fnc_dump;
PROFILE_SCOPE_END(CONSOLIDATE)
_result
