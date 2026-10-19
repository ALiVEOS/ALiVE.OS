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
        // how strongly the search heads for the goal: 1 is shortest-route A*, higher reaches round a long detour with
        // far fewer nodes for a slightly longer route (F514)
        private _weight = (["weight", missionNamespace getVariable ["ALiVE_pathfinding_navalWeight", 1.15]] call _option) max 1;
        // A goal on land ends at the shore: the search stops within shoreRadius of it. A goal further inland than
        // that could never be reached and would run to the node cap (F517), so the radius grows to the nearest
        // water below the keel line, found on rings every 25 m out to 2 km, plus 50 m.
        private _shoreRadius = ["shoreRadius", 100] call _option;
        if (!_goalValid && {!("shoreRadius" in _options)}) then {
            private _height = _geometry param [0, {getTerrainHeightASL _this}];
            private _keel = _seaLevel - _depth;
            private _near = -1;
            for "_r" from 25 to 2000 step 25 do {
                if (_near < 0) then {
                    for "_b" from 0 to 345 step 15 do {
                        if (_near < 0 && {([(_goalPoint select 0) + _r * sin _b, (_goalPoint select 1) + _r * cos _b] call _height) < _keel}) then {_near = _r};
                    };
                };
            };
            if (_near > 0) then {_shoreRadius = _shoreRadius max (_near + 50)};
        };
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
            ["maxNodes", _maxNodes], ["weight", _weight],
            // F514: a long request that needs a search (its straight line fails, or its goal is not open water)
            // finds its way on a coarse water grid first, then the fine search runs leg by leg along that
            // corridor (a request made for one leg never does this again)
            ["corridor", (["corridor", missionNamespace getVariable ["ALiVE_pathfinding_navalCorridor", true]] call _option)
                && {(_startPoint distance2D _goalPoint) > (["corridorMin", 1500] call _option)}],
            ["corridorCell", (["corridorCell", 250] call _option) max 50], ["legLength", (["legLength", 1000] call _option) max 250],
            ["corridorNodes", (["corridorNodes", 6000] call _option) max 100],
            ["options", _options],
            ["coarseLimit", 512 min ((floor (_maxNodes / 4)) max 1)],
            ["shoreRadius", _shoreRadius],
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
                    if (_state get "corridor") exitWith {
                        _state set ["corridor", false];
                        private _cell = _state get "corridorCell";
                        private _startCell = [floor ((_start select 0) / _cell), floor ((_start select 1) / _cell)];
                        private _goalCell = [floor ((_goal select 0) / _cell), floor ((_goal select 1) / _cell)];
                        private _heap = [];
                        [_heap, _start distance2D _goal, [_startCell, +_start], 0] call ALiVE_fnc_pathfinderPriorityAdd;
                        _state set ["coarse", createHashMapFromArray [
                            ["heap", _heap], ["costs", createHashMapFromArray [[_startCell, 0]]], ["parents", createHashMap],
                            ["points", createHashMapFromArray [[_startCell, +_start], [_goalCell, +_goal]]], ["closed", createHashMap],
                            ["water", createHashMap], ["steps", createHashMap], ["startCell", _startCell], ["goalCell", _goalCell], ["expanded", 0]
                        ]];
                        _state set ["phase", "coarse"];
                    };
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
                    private _weight = _state get "weight";
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
                            [_frontier, _newCost + _weight * (_next distance2D _goal), [_nextKey,_next,_nextLevel], _newCost] call ALiVE_fnc_pathfinderPriorityAdd;
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
                        [_refinementQueue, _cost + _weight * _distance + _penalty,
                            [_key,_position,_resolved + 1], _cost] call ALiVE_fnc_pathfinderPriorityAdd;
                    };
                };

                // A* on a coarse grid of water cells: a cell counts as water where the ground at its centre lies below
                // the keel line, a step between cells where the ground sampled every 25 m along it does. Cheap height
                // reads only, no rays, so a long detour costs a few thousand light nodes instead of the fine search's
                // 12,000 heavy ones. The fine search still checks every leg properly.
                case "coarse": {
                    private _c = _state get "coarse";
                    private _cell = _state get "corridorCell";
                    // a metre deeper than the fine search's keel line, so the corridor keeps off water it can barely pass
                    private _z = (_settings select 0) - (_settings select 1) - 1;
                    private _heap = _c get "heap";
                    private _costs = _c get "costs";
                    private _parents = _c get "parents";
                    private _points = _c get "points";
                    private _closed = _c get "closed";
                    private _water = _c get "water";
                    private _goalCell = _c get "goalCell";
                    private _bounds = _state get "bounds";
                    private _height = _geometry param [0, {getTerrainHeightASL _this}];
                    private _wet = {
                        params ["_a", "_b"];
                        private _len = _a distance2D _b;
                        private _n = (ceil (_len / 25)) max 1;
                        private _ok = true;
                        for "_i" from 1 to (_n - 1) do {
                            private _f = _i / _n;
                            if (([(_a select 0) + ((_b select 0) - (_a select 0)) * _f, (_a select 1) + ((_b select 1) - (_a select 1)) * _f] call _height) >= _z) exitWith {_ok = false};
                        };
                        _ok
                    };
                    private _began2 = diag_tickTime;
                    private _found = false;
                    private _failed = false;
                    while {!_found && {!_failed} && {1000 * (diag_tickTime - _began2) < (_budget max 1)}} do {
                        private _cur = [_heap, _costs] call ALiVE_fnc_pathfinderPriorityPullFresh;
                        if (isNil "_cur" || {(_c get "expanded") >= (_state get "corridorNodes")}) exitWith {_failed = true};
                        _cur params ["_key", "_pos"];
                        if (!(_key in _closed)) then {
                            _closed set [_key, true];
                            _c set ["expanded", (_c get "expanded") + 1];
                            // a goal on land ends at the first water cell beside it, as the fine search's shore ending does
                            if (_key isEqualTo _goalCell || {!(_state get "goalValid") && {(_pos distance2D _goal) <= 1.5 * _cell}}) then {_found = true; _c set ["endCell", _key]} else {
                                private _g = _costs get _key;
                                {
                                    private _nk = [(_key select 0) + (_x select 0), (_key select 1) + (_x select 1)];
                                    if !(_nk in _closed) then {
                                        private _np = if (_nk in _points) then {_points get _nk} else {[((_nk select 0) + 0.5) * _cell, ((_nk select 1) + 0.5) * _cell, 0]};
                                        if ((_np select 0) >= 0 && {(_np select 1) >= 0} && {(_np select 0) < _bounds} && {(_np select 1) < _bounds}) then {
                                            private _isWater = if (_nk in _water) then {_water get _nk} else {
                                                private _w = (_nk isEqualTo _goalCell) || {(_np call _height) < _z};
                                                _water set [_nk, _w]; _w
                                            };
                                            private _stepKey = [_key, _nk];
                                            private _isWet = _isWater && {
                                                private _steps = _c get "steps";
                                                if (_stepKey in _steps) then {_steps get _stepKey} else {
                                                    private _w = [_pos, _np] call _wet;
                                                    _steps set [_stepKey, _w]; _steps set [[_nk, _key], _w]; _w
                                                }
                                            };
                                            if (_isWet) then {
                                                private _ng = _g + (_pos distance2D _np);
                                                private _old = if (_nk in _costs) then {_costs get _nk} else {1e15};
                                                if (_ng < _old) then {
                                                    _costs set [_nk, _ng];
                                                    _parents set [_nk, _key];
                                                    _points set [_nk, _np];
                                                    [_heap, _ng + (_np distance2D _goal), [_nk, _np], _ng] call ALiVE_fnc_pathfinderPriorityAdd;
                                                };
                                            };
                                        };
                                    };
                                } forEach [[-1,-1],[0,-1],[1,-1],[-1,0],[1,0],[-1,1],[0,1],[1,1]];
                            };
                        };
                    };
                    if (_failed) exitWith {
                        // no corridor: the fine search as it always was, with its whole node budget (the coarse nodes
                        // are kept apart, or they would count against it)
                        _state set ["coarseExpanded", _c get "expanded"];
                        _state deleteAt "coarse";
                        _state set ["phase", "search"];
                    };
                    if (_found) then {
                        // the corridor's cells, start to goal, and a waypoint every legLength along it
                        private _cells = [];
                        private _k = _c get "endCell";
                        while {!isNil "_k"} do {
                            _cells pushBack (_points get _k);
                            _k = _parents get _k;
                        };
                        reverse _cells;
                        private _every = (round ((_state get "legLength") / _cell)) max 1;
                        private _legs = [];
                        for "_i" from _every to (count _cells - 2) step _every do {_legs pushBack (_cells select _i)};
                        _legs pushBack +_goal;
                        _state set ["expanded", (_state get "expanded") + (_c get "expanded")];
                        _state deleteAt "coarse";
                        _state set ["legs", _legs];
                        _state set ["legIndex", 0];
                        _state set ["legFrom", +_start];
                        _state set ["legPath", []];
                        _state set ["phase", "legs"];
                    };
                };

                // The fine search, one leg at a time: each leg is a request of its own, from the end of the last
                // leg to the next corridor waypoint, so it is short and nearly straight.
                case "legs": {
                    private _sub = _state getOrDefault ["sub", nil];
                    if (isNil "_sub") then {
                        private _opts = +(_state get "options");
                        _opts set ["corridor", false];
                        _opts set ["maxNodes", _state get "maxNodes"];
                        _sub = [nil, "create", [_state get "legFrom", (_state get "legs") select (_state get "legIndex"), _opts, _geometry]] call ALiVE_fnc_pathfinderNaval;
                        _state set ["sub", _sub];
                    };
                    if ([_sub, "step"] call ALiVE_fnc_pathfinderNaval) then {
                        _state deleteAt "sub";
                        private _status = _sub get "status";
                        private _r = _sub get "result";
                        _state set ["expanded", (_state get "expanded") + (_sub get "expanded")];
                        _state set ["spacing", (_state get "spacing") min (_sub get "spacing")];
                        private _ok = _status in ["complete", "shore"];
                        // a leg the fine search can't follow (a gap the coarse grid saw as water) gets one plain search
                        // from where the route stands to the real goal, as the request would have had without a corridor
                        // (not when that leg was already the one to the goal: the same search again finds nothing new)
                        if (!_ok && {!(_state getOrDefault ["legFallback", false])} && {(_state get "legIndex") < (count (_state get "legs") - 1)}) exitWith {
                            _state set ["legFallback", true];
                            _state set ["legs", [+_goal]];
                            _state set ["legIndex", 0];
                        };
                        // a leg's points start after its own start, so the joins carry no duplicates
                        if (count _r > 0 && {_ok || {!((_r select (count _r - 1)) isEqualTo (_state get "legFrom"))}}) then {
                            (_state get "legPath") append _r;
                        };
                        private _last = (_state get "legIndex") >= (count (_state get "legs") - 1);
                        if (!_ok || {_last}) then {
                            if ((_state get "legPath") isEqualTo []) then {(_state get "legPath") pushBack +(_state get "legFrom")};
                            _state set ["result", _state get "legPath"];
                            _state set ["status", [_status, "partial"] select !_ok];
                            _state set ["phase", "done"];
                        } else {
                            if (count _r > 0) then {_state set ["legFrom", +(_r select (count _r - 1))]};
                            _state set ["legIndex", (_state get "legIndex") + 1];
                        };
                    };
                    // a leg uses the frame's budget itself
                    _work = 8;
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
