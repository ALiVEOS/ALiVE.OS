#include "\x\alive\addons\sys_pathfinding\script_component.hpp"

// Sparse, request-local naval graph. The global land grid is never refined.
// Keep one coarse graph; defer local refinement at blocked connections.
// Every phase yields through the existing pathfinder queue and frame budget.
params [["_state", nil], "_operation", ["_args", []]];
private _result = false;
switch (_operation) do {
    case "create": {
        private _createdAt = diag_tickTime;
        _args params ["_start", "_goal", ["_options", createHashMap], ["_geometry", []]];
        private _option = {
            params ["_key", "_default"];
            if (_key in _options) then {_options get _key} else {_default}
        };
        private _spacing = (["spacing", missionNamespace getVariable ["ALiVE_pathfinding_navalSpacing", 5]] call _option) max 2.5 min 25;
        private _depth = (["depth", missionNamespace getVariable ["ALiVE_pathfinding_navalDepth", 1]] call _option) max 0.1;
        private _clearance = (["clearance", missionNamespace getVariable ["ALiVE_pathfinding_navalClearance", 2.5]] call _option) max 0;
        private _seaLevel = ["seaLevel", missionNamespace getVariable ["ALiVE_pathfinding_seaLevel", 0]] call _option;
        private _startPoint = [_start select 0, _start select 1, 0];
        private _goalPoint = [_goal select 0, _goal select 1, 0];
        private _settings = [_seaLevel, _depth, _clearance];
        private _pointCache = createHashMap;
        private _startValid = [_startPoint, _startPoint, _settings, _geometry, _pointCache] call ALiVE_fnc_pathfinderNavalSegment;
        private _goalValid = [_goalPoint, _goalPoint, _settings, _geometry, _pointCache] call ALiVE_fnc_pathfinderNavalSegment;
        // All resolutions share integer keys on the finest lattice. Coarser
        // neighbours snap to canonical anchors, avoiding translated fine grids.
        private _steps = [];
        {_steps pushBackUnique ((round (_x / _spacing)) max 1)} forEach [25,10,_spacing];
        private _maxNodes = ["maxNodes", 12000] call _option;
        private _frontier = [];
        [_frontier, _startPoint distance2D _goalPoint, [[0,0],_startPoint,0], 0] call ALiVE_fnc_pathfinderPriorityAdd;
        _result = createHashMapFromArray [
            ["phase", ["search", "direct"] select _goalValid],
            ["start", _startPoint], ["goal", _goalPoint], ["goalValid", _goalValid],
            ["settings", _settings], ["geometry", _geometry], ["pointCache", _pointCache],
            ["steps", _steps], ["fineSpacing", _spacing], ["spacing", (_steps select 0) * _spacing],
            ["coarseOnly", true], ["deferred", []], ["nodeLevels", createHashMapFromArray [[[0,0],0]]],
            ["frontier", _frontier], ["costs", createHashMapFromArray [[[0,0],0]]],
            ["points", createHashMapFromArray [[[0,0],_startPoint]]], ["span", 200],
            ["bounds", if ("bounds" in _options) then {_options get "bounds"} else {worldSize}],
            ["maxNodes", _maxNodes],
            ["coarseLimit", 512 min ((floor (_maxNodes / 4)) max 1)],
            ["shoreRadius", ["shoreRadius", 100] call _option],
            ["createdAt", _createdAt], ["workMs", 0],
            ["parents", createHashMap], ["closed", createHashMap], ["edges", createHashMap],
            ["expanded", 0], ["best", [_startPoint distance2D _goalPoint, [0,0]]],
            ["cursor", [0,0]], ["raw", []],
            ["directPoint", _startPoint], ["directPath", []],
            ["path", []], ["index", 1], ["accepted", 0],
            ["status", "pending"], ["result", []]
        ];
        if (!_startValid) then {
            _result set ["phase", "done"];
            _result set ["status", "blocked"];
            _result set ["result", [_startPoint]];
        };
        _result set ["workMs", 1000 * (diag_tickTime - _createdAt)];
    };

    case "step": {
        private _began = diag_tickTime;
        private _budget = (missionNamespace getVariable ["ALiVE_pathfinding_navalBudgetMs", 2]) max 0;
        private _work = 0;
        private _settings = _state get "settings";
        private _geometry = _state get "geometry";
        private _pointCache = _state get "pointCache";
        private _goal = _state get "goal";
        private _start = _state get "start";
        private _span = _state get "span";
        private _finishSearch = {
            params ["_key", "_status", ["_tail", []]];
            _state set ["cursor", _key];
            _state set ["status", _status];
            _state set ["raw", _tail];
            _state set ["phase", "reconstruct"];
        };
        while {
            (_state get "phase") != "done" && {_work < 8}
            && {_work == 0 || {_budget <= 0} || {1000 * (diag_tickTime - _began) < _budget}}
        } do {
            _work = _work + 1;
            switch (_state get "phase") do {
                case "direct": {
                    private _from = _state get "directPoint";
                    private _remaining = _from distance2D _goal;
                    private _to = if (_remaining <= _span) then {+_goal} else {
                        [(_from select 0) + ((_goal select 0) - (_from select 0)) * _span / _remaining,
                         (_from select 1) + ((_goal select 1) - (_from select 1)) * _span / _remaining, 0]
                    };
                    if ([_from, _to, _settings, _geometry, _pointCache] call ALiVE_fnc_pathfinderNavalSegment) then {
                        (_state get "directPath") pushBack _to;
                        _state set ["directPoint", _to];
                        if (_remaining <= _span) then {
                            _state set ["result", _state get "directPath"];
                            _state set ["status", "complete"];
                            _state set ["phase", "done"];
                        };
                    } else {
                        _state set ["phase", "search"];
                        _state set ["directPath", []];
                    };
                };

                case "search": {
                    private _frontier = _state get "frontier";
                    private _deferred = _state get "deferred";
                    private _costs = _state get "costs";
                    private _coarseOnly = _state get "coarseOnly";
                    if (_coarseOnly && {count _frontier == 0 || {(_state get "expanded") >= (_state get "coarseLimit")}}) then {
                        _coarseOnly = false;
                        _state set ["coarseOnly", false];
                    };
                    // Refinement work shares costs and parents with the existing
                    // graph. There is no restart or loss of coarse connectivity.
                    private _queue = _frontier;
                    if (!_coarseOnly && {count _deferred > 0} && {count _frontier == 0 || {((_deferred select 0) select 0) < ((_frontier select 0) select 0)}}) then {
                        _queue = _deferred;
                    };
                    private _current = [_queue, _costs] call ALiVE_fnc_pathfinderPriorityPullFresh;
                    if ((_state get "expanded") >= (_state get "maxNodes")
                        || {isNil "_current" && {count _frontier == 0} && {count _deferred == 0}}) exitWith {
                        [(_state get "best") select 1, "partial"] call _finishSearch;
                    };
                    // A stale heap can drain while the other frontier still has work.
                    if (isNil "_current") exitWith {};
                    _current params ["_key", "_position", "_level"];
                    private _closed = _state get "closed";
                    private _closedKey = [_key,_level];
                    private _cost = _costs get _key;
                    private _expandedCost = if (_closedKey in _closed) then {_closed get _closedKey} else {1e15};
                    if (_cost >= _expandedCost) exitWith {};
                    _closed set [_closedKey, _cost];
                    _state set ["expanded", (_state get "expanded") + 1];
                    private _distance = _position distance2D _goal;
                    if (_distance < ((_state get "best") select 0)) then {
                        _state set ["best", [_distance, _key]];
                    };
                    private _goalValid = _state get "goalValid";
                    private _reached = if (_goalValid) then {
                        _distance <= _span && {[_position, _goal, _settings, _geometry, _pointCache] call ALiVE_fnc_pathfinderNavalSegment}
                    } else {
                        _distance <= (_state get "shoreRadius")
                    };
                    if (_reached) exitWith {
                        [_key, ["shore","complete"] select _goalValid, [[],[+_goal]] select _goalValid] call _finishSearch;
                    };
                    private _spacing = _state get "fineSpacing";
                    private _steps = _state get "steps";
                    private _nodeLevels = _state get "nodeLevels";
                    private _bounds = _state get "bounds";
                    private _edges = _state get "edges";
                    private _parents = _state get "parents";
                    private _points = _state get "points";
                    private _offsets = [[-1,-1],[0,-1],[1,-1],[-1,0],[1,0],[-1,1],[0,1],[1,1]];
                    private _tryNode = {
                        params ["_nextKey"];
                        if (_nextKey isEqualTo _key) exitWith {false};
                        private _next = [(_start select 0) + (_nextKey select 0) * _spacing, (_start select 1) + (_nextKey select 1) * _spacing, 0];
                        if ((_next select 0) < 0 || {(_next select 1) < 0} || {(_next select 0) >= _bounds} || {(_next select 1) >= _bounds}) exitWith {false};
                        private _edgeKey = [_position, _next];
                        private _valid = false;
                        if (_edgeKey in _edges) then {
                            _valid = _edges get _edgeKey;
                        } else {
                            _valid = [_position, _next, _settings, _geometry, _pointCache] call ALiVE_fnc_pathfinderNavalSegment;
                            _edges set [_edgeKey, _valid];
                            _edges set [[_next, _position], _valid];
                        };
                        if (!_valid) exitWith {false};
                        private _newCost = _cost + (_position distance2D _next);
                        private _oldCost = if (_nextKey in _costs) then {_costs get _nextKey} else {1e15};
                        if (_newCost < _oldCost) then {
                            _costs set [_nextKey, _newCost];
                            _parents set [_nextKey, _key];
                            _points set [_nextKey, _next];
                            // Requested refinement must not leak into the
                            // initial coarse pass when a cost improves.
                            private _nextLevel = if (!_coarseOnly && {_nextKey in _nodeLevels}) then {_nodeLevels get _nextKey} else {0};
                            [_frontier, _newCost + 1.15 * (_next distance2D _goal), [_nextKey,_next,_nextLevel], _newCost] call ALiVE_fnc_pathfinderPriorityAdd;
                        };
                        true
                    };
                    private _tryJump = {
                        params ["_step"];
                        // Unreached endpoints are distinct, so distance is positive.
                        private _fraction = ((_span - _step * _spacing) min _distance) / _distance;
                        private _jump = [(_position select 0) + ((_goal select 0) - (_position select 0)) * _fraction,
                                         (_position select 1) + ((_goal select 1) - (_position select 1)) * _fraction];
                        [[round (((_jump select 0) - (_start select 0)) / (_spacing * _step)) * _step,
                          round (((_jump select 1) - (_start select 1)) / (_spacing * _step)) * _step]] call _tryNode;
                    };
                    [_steps select _level] call _tryJump;
                    private _coarseStep = _steps select 0;
                    private _stride = ((round (50 / (_spacing * _coarseStep))) max 1) * _coarseStep;
                    private _coarseAnchor = [round ((_key select 0) / _coarseStep) * _coarseStep, round ((_key select 1) / _coarseStep) * _coarseStep];
                    {
                        [[(_coarseAnchor select 0) + (_x select 0) * _stride, (_coarseAnchor select 1) + (_x select 1) * _stride]] call _tryNode;
                    } forEach _offsets;
                    private _validConnections = 0;
                    private _tried = 0;
                    private _resolved = _level;
                    for "_candidateLevel" from 0 to (count _steps - 1) do {
                        if (_candidateLevel > _level && {_coarseOnly || {_validConnections > 2}}) exitWith {};
                        private _localStep = _steps select _candidateLevel;
                        _closed set [[_key,_candidateLevel],_cost];
                        if (_candidateLevel > 0 && {_candidateLevel != _level}) then {
                            [_localStep] call _tryJump;
                        };
                        private _anchor = [round ((_key select 0) / _localStep) * _localStep, round ((_key select 1) / _localStep) * _localStep];
                        _validConnections = 0;
                        _tried = 0;
                        _resolved = _candidateLevel;
                        {
                            private _nextKey = [(_anchor select 0) + (_x select 0) * _localStep, (_anchor select 1) + (_x select 1) * _localStep];
                            if !(_nextKey isEqualTo _key) then {
                                _tried = _tried + 1;
                                if ([_nextKey] call _tryNode) then {_validConnections = _validConnections + 1};
                            };
                        } forEach ([[0,0]] + _offsets);
                    };
                    _state set ["spacing", (_state get "spacing") min ((_steps select _resolved) * _spacing)];
                    private _knownLevel = if (_key in _nodeLevels) then {_nodeLevels get _key} else {0};
                    _nodeLevels set [_key, _knownLevel max _resolved];
                    private _canonical = ((_key select 0) mod _coarseStep) == 0 && {((_key select 1) mod _coarseStep) == 0};
                    // Fine nodes with usable coarse neighbours rejoin
                    // that graph instead of growing translated shore grids.
                    if (_resolved < (count _steps - 1) && {_validConnections < _tried} && {_knownLevel <= _resolved}
                        && {_resolved > 0 || {_validConnections <= 2} || {_canonical}}) then {
                        _nodeLevels set [_key, _resolved + 1];
                        // A narrow continuation refines immediately. A
                        // bank beside usable coarse connections waits,
                        // avoiding fine-node flooding of wide water.
                        private _penalty = [0,5 * _span * (_resolved + 1)] select (_validConnections > 2);
                        private _refinementQueue = [_frontier,_deferred] select _coarseOnly;
                        [_refinementQueue, _cost + 1.15 * _distance + _penalty,
                            [_key,_position,_resolved + 1], _cost] call ALiVE_fnc_pathfinderPriorityAdd;
                    };
                };

                case "reconstruct": {
                    private _cursor = _state get "cursor";
                    (_state get "raw") pushBack ((_state get "points") get _cursor);
                    if (_cursor isEqualTo [0,0]) then {
                        reverse (_state get "raw");
                        _state set ["path", [+_start]];
                        _state set ["phase", "smooth"];
                    } else {
                        _state set ["cursor", (_state get "parents") get _cursor];
                    };
                };

                case "smooth": {
                    private _raw = _state get "raw";
                    private _path = _state get "path";
                    private _index = _state get "index";
                    private _accepted = _state get "accepted";
                    private _anchor = _path select (count _path - 1);
                    if (_index >= count _raw) then {
                        if (_accepted > 0) then {_path pushBack (_raw select _accepted)};
                        if (count _path > 1) then {_path deleteAt 0};
                        _state set ["result", _path];
                        _state set ["phase", "done"];
                    } else {
                        private _next = _raw select _index;
                        if ((_anchor distance2D _next) <= _span && {[_anchor, _next, _settings, _geometry, _pointCache] call ALiVE_fnc_pathfinderNavalSegment}) then {
                            _state set ["accepted", _index];
                            _state set ["index", _index + 1];
                        } else {
                            if (_accepted > 0 && {!((_raw select _accepted) isEqualTo _anchor)}) then {
                                _path pushBack (_raw select _accepted);
                                _state set ["index", _accepted + 1];
                                _state set ["accepted", 0];
                            } else {
                                // An invalid adjacent edge must never become a shortcut.
                                if (count _path > 1) then {_path deleteAt 0};
                                _state set ["result", _path];
                                _state set ["status", "partial"];
                                _state set ["phase", "done"];
                            };
                        };
                    };
                };
            };
        };
        _state set ["workMs", (_state get "workMs") + 1000 * (diag_tickTime - _began)];
        _result = (_state get "phase") == "done";
    };
};
_result
