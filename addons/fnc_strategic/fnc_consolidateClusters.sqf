//#define DEBUG_MODE_FULL
#include "\x\alive\addons\fnc_strategic\script_component.hpp"
SCRIPT(consolidateClusters);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_consolidateClusters

Description:
Consolidate clusters using an x_lib spatial grid with 700 m cells. Candidate
order, priority, strict distance checks, node order and master-array aliasing
match the original pass. Reindex merged centers and query remaining ordinals
again; do not revisit candidates already passed. Geometry is cached lazily
and invalidated for every alias when nodes change. Input nodes must be stationary.

Parameters:
Array - Master clusters
Array - Additional clusters (optional)

Returns:
Array - Surviving clusters, in original order

Author:
Wolffy.au
Jman
---------------------------------------------------------------------------- */

params [
    ["_master", [], [[]]],
    ["_redundant", [], [[]]]
];
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
// [] marks an unread scalar. Read lazily to preserve getter side effects and
// share values across aliases of the same hash. Nodes changes invalidate size.
private _sizes = [];
private _priorities = [];
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

PROFILE_SCOPE(INDEX, "ALiVE_fnc_consolidateClusters: build grid")
{
    _slots pushBack _x;
    _liveIDs pushBack (if (_x isEqualTo -1) then {-1} else {_forEachIndex});
    _entries pushBack [];
    _aliases pushBack [];
    _sizes pushBack [];
    _priorities pushBack [];
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
        private _outCenter = _centers select _outID;
        // A destroyed alias is still visited by the original master traversal.
        // Its getter recreates an empty center field; preserve that raw state.
        if (count _outCenter == 0) then {_outCenter = [_out, "center"] call ALIVE_fnc_cluster;};
        if (count _outCenter > 0) then {
            private _candidates = _grid call ["findInRange", [_outCenter, MAX_CLUSTER_SIZE, true, true, false]];
            _candidates = _candidates select {_x > _cursor};
            _candidates sort true;
            {
                private _id = _x;
                _cursor = _id;
                private _other = _slots select _id;
                if !(_out isEqualRef _other) then {
                    private _otherCenter = _centers select _id;
                    if (count _otherCenter > 0) then {
                        private _otherSize = _sizes select _id;
                        if (_otherSize isEqualType []) then {
                            _otherSize = [_other, "size"] call ALIVE_fnc_cluster;
                            {_sizes set [_x, _otherSize];} forEach (_aliases select _id);
                        };
                        private _outSize = _sizes select _outID;
                        if (_outSize isEqualType []) then {
                            _outSize = [_out, "size"] call ALIVE_fnc_cluster;
                            {_sizes set [_x, _outSize];} forEach (_aliases select _outID);
                        };
                        private _max = (_otherSize + _outSize) max MIN_CLUSTER_SIZE min MAX_CLUSTER_SIZE;
                        private _outPriority = _priorities select _outID;
                        if (_outPriority isEqualType []) then {
                            _outPriority = [_out, "priority"] call ALIVE_fnc_cluster;
                            {_priorities set [_x, _outPriority];} forEach (_aliases select _outID);
                        };
                        private _otherPriority = _priorities select _id;
                        if (_otherPriority isEqualType []) then {
                            _otherPriority = [_other, "priority"] call ALIVE_fnc_cluster;
                            {_priorities set [_x, _otherPriority];} forEach (_aliases select _id);
                        };
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
                                _centers set [_x, []];
                                _sizes set [_x, []];
                                _priorities set [_x, []];
                            } forEach (_aliases select _id);
                            [_other, "destroy"] call ALIVE_fnc_cluster;
                            private _resultIndex = _liveIDs find _id;
                            _result set [_resultIndex, -1];
                            _liveIDs set [_resultIndex, -1];

                            private _newCenter = [_out, "center"] call ALIVE_fnc_cluster;
                            {
                                // Preserve the native setter's lazy size state:
                                // do not fill size until another pair needs it.
                                _centers set [_x, _newCenter];
                                _sizes set [_x, []];
                                private _entry = _entries select _x;
                                if (count _newCenter > 0) then {
                                    _grid call ["move", [_entry select 0, _newCenter, _x]];
                                    _entries set [_x, [_newCenter, _x]];
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

["Targets Consolidated"] call ALIVE_fnc_dump;
PROFILE_SCOPE_END(CONSOLIDATE)
_result
