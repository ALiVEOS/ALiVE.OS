#define MAINCLASS alive_fnc_pathfinder

params [
    ["_logic", nil],
    ["_operation", ""],
    ["_args", objNull]
];

private "_result";

////// Internal Functions //////
private _fnc_checkCoastTravelForWater = {

    params ["_sectorAPos","_sectorBPos"];
    private _waterTravel = false;
    private _dist = _sectorAPos distance _sectorBPos;
    private _inc = ceil(_dist / 15);
    private _waterDistance = 0;
    private _seaLevel = missionNamespace getVariable ["ALiVE_pathfinding_seaLevel", 0];
    _a = ((_sectorBPos select 0) - (_sectorAPos select 0))/_inc;
    _b = ((_sectorBPos select 1) - (_sectorAPos select 1))/_inc;

    for "_i" from 0 to _inc do {
        if (getTerrainHeightASL [(_sectorAPos select 0) + (_a*_i),(_sectorAPos select 1) + (_b*_i)] < _seaLevel) then {
            _waterTravel = true;
            // Accumulate the WATER SPAN in metres - each underwater sample covers
            // one step of ~_dist/_inc m (~15 m). (Was "+ _inc", the step COUNT not
            // a length, which made _waterDistance far too small at subsector scale
            // and defeated the "_waterDistance < 100" ford limit - letting land
            // units cross wide open water.)
            _waterDistance = _waterDistance + (_dist / _inc);
        };

        // // _debugMarkers = [_logic , "pathDebugMarkers"] call Alive_fnc_hashGet;
        // _m = createMarker [str str str str str str str  [(_sectorAPos select 0) + (_a*_i),(_sectorAPos select 1) + (_b*_i)], [(_sectorAPos select 0) + (_a*_i),(_sectorAPos select 1) + (_b*_i)]];
        // // _debugMarkers pushback  str str str str str str str [(_sectorAPos select 0) + (_a*_i),(_sectorAPos select 1) + (_b*_i)];
        // _m setMarkerShape "ICON";
        // _m setMarkerType "hd_dot";
        // _m setMarkerSize [0.3,0.3];
        // _m setMarkerAlpha 0.5;
        // _m setMarkerColor "ColorBlue";
    };
    
    [_waterTravel,_waterDistance];
};

private _fnc_getDistanceFromLayer = {
    params ["_path","_firstPos"];

    private _positions = count _path;
    if (_positions == 0) exitwith {0;};
    private _i = 1;
    private _distance = _firstPos distance (_path select 0);
    while {_i < _positions} do {
        _distance = _distance + ((_path select _i-1) distance (_path select _i));
        _i = _i + 1;
    };

    _distance;
};

// CANDIDATE A (#pathfinding-opt): the A* inner loop hits these ops ~40-50x per
// node expansion. As op-string cases, each call paid a MAINCLASS re-entry +
// params parse + switch walk. Hoisted here as file-scope CODE so the L1/L2 loops
// (and setNodeToFrontier) call them directly; the matching op-string cases now
// just delegate here, leaving external callers unchanged. Pure dispatch removal -
// behaviour is identical, so the perf-log nodes/expL*/frontierL* must match the
// pre-A run exactly. (Pass 1: priorityPull / getMovementCost / priorityAdd /
// setNode. heuristic + canTraverseSector follow in pass 2.)
private _fnc_getMovementCost = {
    private _args = _this;
    private "_result";
    _args params ["_currentSector","_goalSector","_size"];
    if (
        ((_currentSector select 0) select 0) != ((_goalSector select 0) select 0) &&
        { ((_currentSector select 0) select 1) != ((_goalSector select 0) select 1) }
    ) then {
        _result = 1.414 * _size;
    } else {
        _result = 1.0 * _size;
    };
    _result
};

private _fnc_priorityAdd = {
    private _args = _this;
    _args params ["_queue","_priority","_item"];
    private _queueSize = count _queue;
    private _i = 0;
    while {_i <= _queueSize - 1 && { _priority > ((_queue select _i) select 0) }} do {
        _i = _i + 1;
    };
    _queue insert [_i, [[_priority, _item]] ];
};

private _fnc_priorityPull = {
    private _queue = _this;
    private "_result";
    if (count _queue > 0) then {
        _result = (_queue deleteat 0) select 1;
    };
    _result
};

private _fnc_setNode = {
    private _args = _this;
    _args params ["_cameFromMap", "_costSoFarMap", "_frontier", "_sector", "_cameFromSector", "_distanceToGoal", "_heuristicParams"];

    private _size = _heuristicParams select 4;
    private _moveCost = ([_cameFromSector,_sector,_size] call _fnc_getMovementCost);
    private _priority = (_heuristicParams call _fnc_heuristic);
    private _newCostSoFar = _moveCost + (_costSoFarMap get (_cameFromSector select 0));
    private _sectorCostSoFar = _costSoFarMap get (_sector select 0);

    if (isnil "_sectorCostSoFar" || { _newCostSoFar < _sectorCostSoFar }) then {
        _costSoFarMap set [_sector select 0, _newCostSoFar];
        [_frontier, _distanceToGoal + _priority + _moveCost, _sector] call _fnc_priorityAdd;
        _cameFromMap set [_sector select 0, _cameFromSector];
    };
};

// CANDIDATE A pass 2: the two big per-node ops, same hoist as pass 1 - the L1/L2
// loops + setNode call these directly instead of via call MAINCLASS. canTraverse
// reuses the sibling _fnc_checkCoastTravelForWater. NOTE: the op-string heuristic /
// canTraverseSector cases below still carry the original bodies for external +
// layer1SeaTravelCheck callers - flagged to collapse to delegates before commit so
// the logic (incl. the water guard) has a single home.
private _fnc_heuristic = {
    private _args = _this;
    private "_result";
    _args params ["_currentSector","_fromSector","_procedure","_basePriority","_sectorDistance",["_isWaterTravel",false]];

    _currentSector params ["_indx", "_pos", "_centerPos", "_type", "_modifiers"];
    _procedure params ["_name","_capabilities","_limits","_weights"];
    _capabilities params ["_canTraverseLand", "_canTraverseTrails", "_canTraverseRoads", "_canTraverseWater", "_canTraverseAir"];
    _limits params ["_maxSlope", "_maxDensity"];
    _weights params ["_roadWeight", "_waterWeight", "_heightWeight", "_densityWeight"];

    if (_canTraverseAir && (_weights isEqualTo [0,0,0,0]) ) exitwith {
        _result = _basePriority;
    };

    private _modpriority = _basePriority;

    private _road = _modifiers select 0;
    _road params  ["_hasRoads","_hasTrails","_hasBridge","_roadModifier"];
    private _water = _modifiers select 1;
    _water params ["_hasWater","_waterModifier"];
    private _height = _modifiers select 2;
    private _densityModifier = _modifiers select 3;

    private _prevHeight = (_fromSector select 4) select 2;

    switch (_type) do {
        case "WATER": {
            _modPriority = _modPriority + (_modPriority * _waterModifier * _waterWeight);
            if (_heightWeight != 0) then {
                _modPriority = _modPriority + (_modPriority * ((_height - _prevHeight)/_sectorDistance) * _heightWeight );
            };
        };

        case "BRIDGE": {
            if (_isWaterTravel) exitwith {_modPriority = _modPriority + (_modPriority * _waterModifier * _waterWeight);};
            if (_canTraverseRoads) then {
                if (_roadWeight != 0) then {
                    _modPriority = _modPriority + (_modPriority * _roadModifier * _roadWeight);
                };
            } else {
                if (_heightWeight != 0) then {
                    _modPriority = _modPriority + (_modPriority * ((_height - _prevHeight)/_sectorDistance) * _heightWeight );
                };
                if (_densityWeight != 0 && _maxDensity !=0) then {
                    _modPriority = _modPriority + (_modPriority * (_densityModifier/_maxDensity) * _densityWeight);
                };
            };
        };

        case "COAST": {
            if (_isWaterTravel) exitwith {_modPriority = _modPriority + (_modPriority * _waterModifier * _waterWeight);};
            if ((_canTraverseRoads && _hasRoads) || (_canTraverseTrails && _hasTrails)) then {
                if (_roadWeight != 0) then {
                    _modPriority = _modPriority + (_modPriority * _roadModifier * _roadWeight);
                };
            } else {
                if (_heightWeight != 0) then {
                    _modPriority = _modPriority + (_modPriority * ((_height - _prevHeight)/_sectorDistance) * _heightWeight );
                };
                if (_densityWeight != 0 && _maxDensity !=0) then {
                    _modPriority = _modPriority + (_modPriority * (_densityModifier/_maxDensity) * _densityWeight);
                };
            };
        };

        case "LAND": {
            if ((_canTraverseRoads && _hasRoads) || (_canTraverseTrails && _hasTrails)) then {
                if (_roadWeight != 0) then {
                    _modPriority = _modPriority + (_modPriority * _roadModifier * _roadWeight);
                };
            } else {
                if (_heightWeight != 0) then {
                    _modPriority = _modPriority + (_modPriority * ((_height - _prevHeight)/_sectorDistance) * _heightWeight );
                };
                if (_densityWeight != 0 && _maxDensity !=0) then {
                    _modPriority = _modPriority + (_modPriority * (_densityModifier/_maxDensity) * _densityWeight);
                };
            };
        };
    };
    _result = _modPriority;
    _result
};

private _fnc_canTraverse = {
    private _args = _this;
    private "_result";
    _args params ["_procedure", "_sectorTo", "_sectorFrom", "_size"];

    _procedure params ["_name","_capabilities","_limits","_weights"];
    _capabilities params ["_canTraverseLand", "_canTraverseTrails", "_canTraverseRoads", "_canTraverseWater", "_canTraverseAir"];
    _limits params ["_maxSlope", "_maxDensity"];
    _weights params ["_roadWeight", "_waterWeight", "_heightWeight", "_densityWeight"];

    _sectorTo params ["_indxTo", "_posTo", "_centerPosTo", "_typeTo", "_modifiersTo"];
    _sectorFrom params ["_indxFrom", "_posFrom", "_centerPosFrom", "_typeFrom", "_modifiersFrom"];
    _modifiersTo params ["_road","_water","_height","_density"];
    _road params ["_hasRoads","_hasTrails","_hasBridge","_roadModifier"];
    _water params ["_hasWater","_waterModifier"];
    _modifiersFrom params ["_prevRoad", "_prevWater", "_prevHeight", "_prevDensity"];
    _prevWater params ["_prevHasWater","_prevWaterModifier"];

    private _canTraverse = false;

    if !(_canTraverseAir) then {

        // First check if Land Unit is attempting to cross a Water Body or Naval unit on water
        private _isWaterCrossing = false;
        private _waterDistance = 0;
        private _isCoastTravel = (_typeTo == "COAST" || _typeFrom == "COAST");
        private _isMovingToFromBridge = (_typeTo == "BRIDGE" || _typeFrom == "BRIDGE") && (_roadWeight < 0);
        private _hasDeepWater = (_waterModifier > 0.4) || (_prevWaterModifier > 0.4);
        // Land Unit Check. The endpoint gate (_isCoastTravel + _hasDeepWater) only
        // fires when a FROM/TO cell is itself coast/water - it misses a dry-land ->
        // dry-land segment that crosses water BETWEEN the cells (a narrow bay/inlet
        // spanned in one step). The lazy midpoint probe catches that: if the segment
        // midpoint is over deep water, run the span check so the <100m ford limit can
        // block it. Short-circuited by the cheap endpoint gate. (#pathfinding-water)
        if (!(_isMovingToFromBridge) && _canTraverseLand && (
                (_isCoastTravel && _hasDeepWater)
                || {(getTerrainHeightASL [((_centerPosFrom select 0)+(_centerPosTo select 0))/2, ((_centerPosFrom select 1)+(_centerPosTo select 1))/2]) < (ALiVE_pathfinding_seaLevel - ALiVE_pathfinding_waterMargin)}
            )) then {
            private _waterData = [_centerPosFrom,_centerPosTo] call _fnc_checkCoastTravelForWater;
            _isWaterCrossing = _waterData select 0;
            _waterDistance = _waterData select 1;
        };
        // Naval Unit check
        if (_canTraverseWater && !_canTraverseLand && _typeTo != "LAND") then {
            _isWaterCrossing = true;
        };

        if (!_isWaterCrossing) then {
            switch (_typeTo) do {
                case "LAND": {
                    if (_canTraverseRoads && _hasRoads) then {_canTraverse = true;};
                    if (_canTraverseTrails && _hasTrails) then {_canTraverse = true;};
                    if (_canTraverseLand && _maxDensity !=0 && (_density < _maxDensity) && ((abs(_height - _prevHeight)/_size) < _maxSlope)) then {
                        _canTraverse = true;
                    };
                };
                case "WATER": {
                    _canTraverse = _canTraverseWater && !(_canTraverseLand);
                };
                case "BRIDGE": {_canTraverse = true;};
                case "COAST": {
                    // A coast sector mixes land + water. Pure-water units (Naval,
                    // !land) cross it on water-capability; LAND units (incl. the
                    // water-capable "Man") must have a road/trail OR be mostly land
                    // (_waterModifier < 0.4). Without the water gate a flat, empty,
                    // mostly-water coast sector wrongly passes the density/slope land
                    // check and infantry walk onto open water.
                    _canTraverse = _canTraverseWater && !(_canTraverseLand);
                    if (_canTraverseRoads && _hasRoads) then {_canTraverse = true;};
                    if (_canTraverseTrails && _hasTrails) then {_canTraverse = true;};
                    if (_canTraverseLand && _waterModifier < 0.4 && _maxDensity !=0 && (_density < _maxDensity) && ((abs(_height - _prevHeight)/_size) < _maxSlope)) then {
                        _canTraverse = true;
                    };
                };
            };
        } else {
            if (_canTraverseLand) then {
                _canTraverse = [(_canTraverseWater && (_waterDistance < 100)),_isWaterCrossing];
            } else {
                _canTraverse = [_canTraverseWater,_isWaterCrossing];
            };
        };
    } else {
        _canTraverse = true;
    };

    // Hard guard (#pathfinding-water): a land unit may never END a step in a cell whose
    // CENTRE is genuinely deep water. This overrides the WATER/COAST switch AND the
    // <100m ford branch above - the loophole that let infantry wade across a bay one
    // sub-100m step at a time. Air is excluded; pure-naval (!_canTraverseLand) still
    // crosses water freely.
    if (!_canTraverseAir && _canTraverseLand && {(getTerrainHeightASL _centerPosTo) < (ALiVE_pathfinding_seaLevel - ALiVE_pathfinding_waterMargin)}) then {
        if (_canTraverse isEqualType []) then { _canTraverse set [0, false]; } else { _canTraverse = false; };
    };

    _result = _canTraverse;
    _result
};
////////////////////////////////

switch (_operation) do {

    case "create": {
        private _pathfindingSizeRaw = [ALIVE_profileSystem,"pathfindingSize"] call ALIVE_fnc_profileSystem;

        // Resolve the configured grid size to a [sectorSize, subSectorSize] pair.
        //
        //   ARRAY            -> a literal [sector, sub] pair. Used as-is (a direct
        //                       init.sqf override).
        //   STRING "[x,y]"    -> a stringified pair from the Eden "Manual:" combo
        //                       entries (Eden saves the combo value as a STRING).
        //                       Parsed back to a pair and used as-is. Covers legacy
        //                       missions that picked a fixed km tier.
        //   STRING token      -> an auto-size token: "auto" / "high" / "med" /
        //                       "low". The grid is sized from the map's own
        //                       worldSize instead of the mission-maker matching a
        //                       km tier by hand. The map is rounded UP to the
        //                       nearest existing tier (10/20/30/40 km) so coverage
        //                       is always guaranteed, and the exact hand-tuned
        //                       sector sizes for that tier are reused - so auto
        //                       reproduces the old manual tiers precisely, with no
        //                       pathing change and no preprocessing regression.
        //                       "auto" == "med" (balanced).
        //
        // Tier table rows are [maxWorldSize, [highPair, medPair, lowPair]] using
        // the same numbers as the sys_profile pathfindingSize Eden combo.
        private _resolvePathfindingSize = {
            params ["_raw"];
            // A valid explicit pair = a 2-element array of positive numbers
            // (init.sqf override). An EMPTY or malformed array (e.g. the hashGet
            // miss default []) must NOT be used literally - it produced a [] grid
            // and cascaded "Undefined _sectorSize" errors through the A* search.
            // Fall through to auto in that case.
            private _validPair = {
                params ["_p"];
                (_p isEqualType []) && {count _p == 2}
                    && {(_p select 0) isEqualType 0} && {(_p select 0) > 0}
                    && {(_p select 1) isEqualType 0} && {(_p select 1) > 0}
            };
            if ([_raw] call _validPair) exitWith { _raw };        // explicit pair
            if (_raw isEqualType "" && {_raw != ""} && {(_raw select [0,1]) == "["}) exitWith {
                private _parsed = parseSimpleArray _raw;          // stringified manual pair "[x,y]"
                if ([_parsed] call _validPair) exitWith { _parsed };
                [250,50]                                          // malformed -> safe 10km-Med
            };
            private _q = if (_raw isEqualType "") then { toLower _raw } else { "auto" };
            private _qIdx = switch (_q) do {
                case "high": { 0 };
                case "low":  { 2 };
                default      { 1 };                               // "auto" / "med" / unknown -> balanced
            };
            private _tiers = [
                [10000, [[200,40],[250,50],[300,60]]],
                [20000, [[400,50],[480,60],[600,75]]],
                [30000, [[640,80],[720,90],[800,100]]],
                [40000, [[800,100],[1000,125],[1200,150]]]
            ];
            // First tier whose extent covers worldSize (round UP). findIf returns
            // -1 when the map is bigger than every tier (>40km) - fall back to the
            // LARGEST tier (last row), never the smallest.
            private _tierIdx = _tiers findIf { worldSize <= (_x select 0) };
            if (_tierIdx < 0) then { _tierIdx = (count _tiers) - 1; };
            ((_tiers select _tierIdx) select 1) select _qIdx
        };
        private _pathfindingSize = [_pathfindingSizeRaw] call _resolvePathfindingSize;

        private _sectorSize = _pathfindingSize select 0;
        private _subSectorSize = _pathfindingSize select 1;
        ["Pathfinding: grid size resolved to %1 (configured: %2, worldSize %3)", _pathfindingSize, _pathfindingSizeRaw, worldSize] call Alive_fnc_Dump;
        // Cache the map's sea level once (getTerrainInfo select 4) for the water
        // tests in grid classification + the A* coast checks. Heightmap-based water
        // detection is reliable at grid-create time; surfaceIsWater only sees inland
        // pond OBJECTS once they're loaded within view distance, so it silently
        // misses distant ponds during the one-time grid classification.
        ALiVE_pathfinding_seaLevel = (getTerrainInfo select 4);
        // Deep-water margin (metres below sea level) past which terrain counts as real
        // sea for the goal-snap + water diagnostics - anything shallower is walkable
        // beach/surf and must NOT be treated as water. isNil-guarded so a console
        // override (e.g. ALiVE_pathfinding_waterMargin = 0.5) survives a mission restart.
        if (isNil "ALiVE_pathfinding_waterMargin") then { ALiVE_pathfinding_waterMargin = 1.0 };
        // DIAG-STRIP: pathfinding-opt counters. Read in the debug console after a run
        // to confirm the candidate-E single-subsector early-out fires and gauge its
        // rate. earlyOuts = jobs short-circuited before the A* setup; jobsRun = jobs
        // that ran the full two-layer search. Reset on each grid create.
        ALiVE_pathfinding_earlyOuts = 0;
        ALiVE_pathfinding_jobsRun = 0;
        private _terrainGrid = [nil,"create", _pathfindingSize] call ALiVE_fnc_pathfindingGrid;

        _logic = [[
            ["terrainGrid", _terrainGrid],
            ["pathfindingProcedures", [] call ALiVE_fnc_hashCreate],
            ["currentJobData", []],
            ["pathJobs", []],
            ["pathDebugMarkers", []],
            ["pathDrawMarkers", []]
        ]] call ALiVE_fnc_hashCreate;

        [_logic,"addPathfindingProcedure", ["default",["Man", [true, true, true, true, false], [0.7, 30], [-0.1, 0.6, -0.1, -0.1]]]] call MAINCLASS;
        [_logic,"addPathfindingProcedure", ["default",["LandRoad", [true, false, true, false, false], [0.5, 2], [-0.5, 0, -0.1, 0.75]]]] call MAINCLASS;
        [_logic,"addPathfindingProcedure", ["default",["LandOffRoad", [true, false, true, false, false], [0.5, 2], [-0.5, 0, 0.1, 0.75]]]] call MAINCLASS;
        [_logic,"addPathfindingProcedure", ["default",["Naval", [false, false, false, true, false], [0, 0], [0, 0, 0, 0]]]] call MAINCLASS;
        [_logic,"addPathfindingProcedure", ["default",["Heli", [true, true, true, true, true], [0, 0], [0, 0, -0.1, 0]]]] call MAINCLASS;
        [_logic,"addPathfindingProcedure", ["default",["Plane", [true, true, true, true, true], [0, 0], [0, 0, 0, 0]]]] call MAINCLASS;

        addMissionEventHandler ["EachFrame", {
            [ALiVE_pathfinder,"onFrame"] call ALiVE_fnc_pathfinder;
        }];

        _result = _logic;

    };

    ////////// DEBUG-DRAW CONTROL //////////
    // Toggle the terrain-grid sector overlay on/off. Sets the global the Eden
    // param / admin menu read, and drives the grid's own enableDebugMarkers op
    // (which builds the coloured sector rectangles, or tears them down).
    // (#pathfinding-draw 2026-06-01)
    case "setDrawGrid": {
        private _enable = if (_args isEqualType true) then { _args } else { false };
        missionNamespace setVariable ["ALiVE_pathfinding_drawGrid", _enable];
        private _terrainGrid = [_logic,"terrainGrid"] call ALiVE_fnc_hashGet;
        if (!isNil "_terrainGrid") then {
            [_terrainGrid, "enableDebugMarkers", [_enable]] call ALiVE_fnc_pathfindingGrid;
        };
        _result = _enable;
    };

    // Toggle the computed-path overlay on/off. Off also clears any path markers
    // already drawn so the map doesn't keep stale routes.
    case "setDrawPaths": {
        private _enable = if (_args isEqualType true) then { _args } else { false };
        missionNamespace setVariable ["ALiVE_pathfinding_drawPaths", _enable];
        if (!_enable) then {
            private _pathMarkers = [_logic, "pathDrawMarkers", []] call ALiVE_fnc_hashGet;
            { deleteMarker _x } forEach _pathMarkers;
            [_logic, "pathDrawMarkers", []] call ALiVE_fnc_hashSet;
        };
        _result = _enable;
    };

    ////////// PROCEDURE FUNCTIONS //////////
    case "addPathfindingProcedure": {

        _args params [["_faction", "default"],"_procedure"];
        
        _procedure params [
            "_name",
            ["_capabilities", [true, true, true, true, true]],
            ["_limits", [0, 0]],
            ["_weights", [0, 0, 0, 0]]
        ];

        ////// FOR REFERENCE ///////
        // _capabilities params ["_canTraverseLand", "_canTraverseTrails", "_canTraverseRoads", "_canTraverseWater", "_canTraverseAir"];
        // _limits params ["_maxSlope", "_maxDensity"];
        // _weights params ["_roadWeight", "_waterWeight", "_heightWeight", "_densityWeight"];

        _allProcedures = [_logic,"pathfindingProcedures"] call ALiVE_fnc_hashGet;
        _factionProcedures = [_allProcedures ,_faction] call Alive_fnc_hashGet;
        if (isNil {_factionProcedures;}) then {_factionProcedures = [] call Alive_fnc_hashCreate;};

        [_factionProcedures, _name, _procedure] call ALiVE_fnc_hashSet;
        [_allProcedures, _faction, _factionProcedures] call ALiVE_fnc_hashSet;

    };

    case "getPathfindingProcedure": {

        _args params [["_procedureName","LandRoad"],["_faction","default"]];

        private _allprocedures = [_logic,"pathfindingProcedures"] call ALiVE_fnc_hashGet;
        private _factionProcedures = [_allProcedures , _faction] call Alive_fnc_hashGet;
        if (isNil {_factionProcedures;}) then {_factionProcedures = [_allProcedures ,"default"] call Alive_fnc_hashGet;};

        _result = [_factionProcedures,_procedureName] call ALiVE_fnc_hashGet;
    };

    ////////// SECTOR ANALYSIS //////////
    // CANDIDATE A: body hoisted to file-scope _fnc_heuristic (called directly by setNode).
    // This op-string case now just delegates so external callers stay correct, with the
    // priority-weighting logic living in one place.
    case "heuristic": { _result = _args call _fnc_heuristic; };

    // CANDIDATE A: body hoisted to file-scope _fnc_canTraverse (called directly by the
    // L1/L2 loops). This op-string case now just delegates so external + layer1SeaTravelCheck
    // callers stay correct, with the water-guard logic living in one place.
    case "canTraverseSector": { _result = _args call _fnc_canTraverse; };

    case "getMovementCost": { _result = _args call _fnc_getMovementCost; };

    case "layer1SeaTravelCheck": {
        _args params [
            ["_startPos",[0,0,0],[[]],[2,3]],
            ["_endPos",[0,0,0],[[]],[2,3]],
            ["_maxIterations", 250, [0]],
            ["_procedure",["genericCanSwimButNoWater", [true, true, true, false, false], [0.7, 0], [-0.5, 0, 0, 0]],[[]],[4]]
        ];

        // ["layer1SeaCheck: args:[ %1 , %2 , %3 , %4",_startPos,_endPos,_maxIterations,_procedure] call Alive_fnc_Dump;

        private _terrainGrid = [_logic,"terrainGrid"] call ALiVE_fnc_hashGet;
        private _sectorSize = [_terrainGrid,"sectorSize"] call ALiVE_fnc_hashGet;
        private _startSector = [_terrainGrid,"positionToSector", _startPos] call ALiVE_fnc_pathfindingGrid;
        private _goalSector = [_terrainGrid,"positionToSector", _endPos] call ALiVE_fnc_pathfindingGrid;

        // Cost / came-from maps use native HashMaps keyed by the sector index
        // array [x,y] directly (Array is a supported HashMap key type, deep-
        // copied on insertion). Replaces the previous CBA namespaces keyed by
        // str(index) - removes the per-node stringify + CBA call overhead in the
        // hot A* loop. (#pathfinding-opt 2026-06-01)
        private _cameFromMapLayer1 = createHashMap;
        private _costSoFarMapLayer1 = createHashMap;
        _costSoFarMapLayer1 set [_startSector select 0, 0];
        private _frontierLayer1 = [[0,_startSector]];
        private _layer1Complete = false;
        private _sectorIterations = 0;

        scopeName "Main";

        call {
            while {!_layer1Complete && _sectorIterations < _maxIterations} do {
                _sectorIterations = _sectorIterations + 1;

                private _currentSector = [nil,"priorityPullLowest", _frontierLayer1] call MAINCLASS;
                _currentSector params ["_indxCS", "_posCS", "_centerPosCS", "_typeCS", "_modifiersCS"];

                if ((_currentSector select 0) isequalto (_goalSector select 0)) exitwith {
                    _layer1Complete = true;
                    breakto "main";
                };

                // determine which neighbor is the best path
                {
                    private _neighSector = _x;

                    _neighSector params ["_indx", "_pos", "_centerPos", "_type", "_modifiers"];
                    private _isWaterTravel = false;
                    private _canTraverse = [nil, "canTraverseSector", [_procedure, _neighSector, _currentSector, _sectorSize]] call MAINCLASS;
                    if (typeName _canTraverse == "ARRAY") then {_isWaterTravel = _canTraverse select 1; _canTraverse = _canTraverse select 0;};
                    if (_canTraverse) then {
                        private _distanceToGoal = _centerPos distance (_goalSector select 2);
                        private _heuristicParams = [_neighSector,_currentSector,_procedure, _distanceToGoal,_sectorSize,_isWaterTravel];
                        [nil,"setNodeToFrontier",[_cameFromMapLayer1, _costSoFarMapLayer1, _frontierLayer1, _neighSector, _currentSector, _distanceToGoal, _heuristicParams]] call MAINCLASS;
                    } else {
                        if (_neighSector isEqualTo _goalSector) exitwith {
                            // Unable to complete path to goal
                            breakTo "Main"
                        };
                    };
                } foreach ([_terrainGrid, "getNeighborSectors", _indxCS] call Alive_fnc_pathfindingGrid);

                if (count _frontierLayer1 == 0) exitwith {breakTo "Main";};
            };
        };

        // ["layer1SeaCheck: results c:%1 , SI:%2 , FL:%3",_layer1Complete,_sectorIterations, count _frontierLayer1] call Alive_fnc_Dump;
        _result = !_layer1Complete;
    };

    ////////// PATHING FUNCTIONS //////////
    case "findOptimalPos": {
        _args params ["_sector", "_sectorSize", "_procedure", ["_nextPos",nil], ["_prevPos",nil]];

        _procedure params ["_name","_capabilities","_limits","_weights"];
        _capabilities params ["_canTraverseLand", "_canTraverseTrails", "_canTraverseRoads", "_canTraverseWater", "_canTraverseAir"];
        _limits params ["_maxSlope", "_maxDensity"];
        _weights params ["_roadWeight", "_waterWeight", "_heightWeight", "_densityWeight"];
        
        _sector params ["_indx", "_pos", "_centerPos", "_type", "_modifiers"];
        _modifiers params ["_road","_water","_height","_density"];
        _road params ["_hasRoads","_hasTrails","_hasBridge","_roadModifier"];
        _water params ["_hasWater","_waterModifier"];
        
        _result = _centerPos;
        
        private _size = _sectorSize/3;
        private _subPositions = [];
        { 
            private _a = (_centerPos select 0) + (_x select 0)*_size;
            private _b = (_centerPos select 1) + (_x select 1)*_size;
            private _newPos = [_a,_b];
            _subPositions pushback _newPos;
        } foreach [[-1,-1],[0,-1],[1,-1],[-1,0],[1,0],[-1,1],[0,1],[1,1]];

        if (_canTraverseWater && !(_canTraverseLand) && (_type != "LAND")) then { 
            {
                if ((getTerrainHeightASL _x) < (getTerrainheightASL _result)) then {_result = _x;};
            } foreach _subPositions;
        };
        if (_canTraverseLand) then {
            if !((isNil "_prevPos") || (isNil "_nextPos")) then {
                {                    
                    private _distR1 = _nextPos distance _result;
                    private _distR2 = _prevPos distance _result;
                    private _distS1 = _nextPos distance _x;
                    private _distS2 = _prevPos distance _x;
                    if (((_distS1+_distS2) < (_distR1+_distR2)) && (getTerrainHeightASL _x >= (missionNamespace getVariable ["ALiVE_pathfinding_seaLevel", 0]))) then {_result = _x;};
                } foreach _subPositions;
            };
            private _useRoads = (_roadWeight < 0);
            private _isWalking = (_canTraverseLand && _canTraverseWater && !(_canTraverseAir));
            if (_useRoads && (_hasRoads || (_isWalking && _hasTrails))) then {                 
                private _searchArray = ["MAIN ROAD","ROAD","TRACK"];
                if (_isWalking) then {_searchArray pushback "TRAIL";};
                private _roads = nearestTerrainObjects [_result, _searchArray, _sectorSize * 0.7, true, true];
                if (count _roads > 0) exitwith {_result = getPosASL (_roads select 0);};
            };
        };
        _result;
    };

    case "getLayerPath": {

        _args params ["_procedure","_startSector","_goalSector","_cameFromMap","_pathLayer", "_sectorSize"];
        _procedure params ["_name","_capabilities","_limits","_weights"];
        _capabilities params ["_canTraverseLand", "_canTraverseTrails", "_canTraverseRoads", "_canTraverseWater", "_canTraverseAir"];
        
        private _end = _startSector select 0;
        
        private _currentSector = _goalSector;

        while { !((_currentSector select 0) isequalto _end) } do {            
            if (isNil "_procedure" || {count _pathLayer < 1}) then {
                _pathLayer pushback (_currentSector select 2);
                _currentSector = _cameFromMap get (_currentSector select 0);
            } else {
                private _nextSector = _cameFromMap get (_currentSector select 0);
                private _nextPos = _nextSector select 2;
                private _prevPos = _pathLayer select ((count _pathLayer)-1); 
                _pathLayer pushback ([nil, "findOptimalPos", [_currentSector, _sectorSize, _procedure, _nextPos, _prevPos]] call MAINCLASS);
                _currentSector = _nextSector;
            };
        };

        // No need for start sector waypoint unless: that is all we have because unit cannot traverse out of it's location
        // Goal Sector is never needed as that is addressed by the final waypoint that started this all
        if (_pathLayer isEqualTo []) then {
            _pathLayer pushback (_startSector select 2);
        };

        reverse _pathLayer;

        //Shrink path for small sector layer
        if (_sectorSize < 200) then {[nil, "consolidatePath", _pathLayer] call MAINCLASS;};

        // _debugMarkers = [_logic , "pathDebugMarkers"] call Alive_fnc_hashGet;
        // {
        //     _m = createMarker [str str str str str str str  _x, _x];
        //     _debugMarkers pushback  str str str str str str str _x;
        //     _m setMarkerShape "ICON";
        //     _m setMarkerType "hd_dot";
        //     _m setMarkerSize [0.6,0.6];
        //     _m setMarkerAlpha 0.3;
        //     _m setMarkerColor "ColorBlue";
        // } foreach _pathLayer;

        _result = true;
    };

    case "consolidatePath": {
        _path = _args;

        if (count _path <= 3) exitwith {};

        private _i = 1;
        while {_i < (count _path - 2);} do {
            private _currDir = (_path select (_i - 1)) getdir (_path select _i);
            private _tempDir = (_path select _i) getdir (_path select (_i + 1));
            if (abs (_tempDir - _currDir) < 15) then { 
                _path deleteAt _i;
            } else {
                _i = _i + 1;
            };
        };
    };

    case "priorityAdd": { _args call _fnc_priorityAdd; };

    case "priorityPullLowest": { _result = _args call _fnc_priorityPull; };

    case "setNodeToFrontier": { _args call _fnc_setNode; };

    ////////// JOB FUNCTIONS //////////
    case "findPath": {

        _args params ["_startPos","_procedure","_waypoint","_previousWaypoint","_callbackArgs","_callback"];
        
        private _pathJobs = [_logic,"pathJobs"] call ALiVE_fnc_hashGet;
        private _newJob = _args;
        
        _pathJobs pushback _newJob;
            // [": findPath args %1 ",str _args] call Alive_fnc_Dump;
        
        if (count _pathJobs == 1) then {
            [_logic,"loadCurrentJobData"] call MAINCLASS;
        };
    };

    case "loadCurrentJobData": {

        private _pathJobs = [_logic,"pathJobs"] call ALiVE_fnc_hashGet;

        // load next job data
        if (count _pathJobs > 0) then {
            private _nextJob = _pathJobs select 0;
            _nextJob params ["_startPos","_procedure","_waypoint","_previousWaypoint","_callbackArgs","_callback"];
            // [": findPath nextJob %1 ",str _nextJob] call Alive_fnc_Dump;

            if !(isNil "_previousWaypoint") then { 
                //update _startPos in the event the waypoint position changed e.g. during prev pathfinding job
                _startPos = [_previousWaypoint, "position"] call Alive_fnc_hashGet;
            };

            private _endPos = [_waypoint,"position"] call ALive_fnc_hashGet;
            
            private _terrainGrid = [_logic,"terrainGrid"] call ALiVE_fnc_hashGet;

            // Goal-snap (#pathfinding-water): a land-capable group must never be routed
            // into open sea. When the goal resolves over water - an objective/waypoint
            // placed offshore (see the route WATER diag) - retarget to the nearest land
            // so the route ends at the shore, not in the sea. Fires only for land
            // procedures with a water goal; a land goal is untouched, and a goal on an
            // island stays as-is (the A* still returns the closest reachable node).
            // getTerrainHeightASL < seaLevel matches the grid's own water classification
            // and is reliable at any range (unlike surfaceIsWater). Ring-search outward
            // in subsector steps for the nearest land point.
            private _canLand = (_procedure select 1) select 0;   // capabilities select 0 = canTraverseLand
            if (_canLand && {(getTerrainHeightASL [_endPos select 0, _endPos select 1]) < (ALiVE_pathfinding_seaLevel - ALiVE_pathfinding_waterMargin)}) then {
                private _step = ([_terrainGrid,"subSectorSize"] call ALiVE_fnc_hashGet) max 25;
                private _origEnd = _endPos;
                private _found = false;
                for "_ring" from 1 to 30 do {
                    if (!_found) then {
                        private _r = _ring * _step;
                        {
                            private _p = [(_origEnd select 0) + _r * cos _x, (_origEnd select 1) + _r * sin _x];
                            if (!_found && {(getTerrainHeightASL _p) >= ALiVE_pathfinding_seaLevel}) then {
                                _endPos = [_p select 0, _p select 1, 0];
                                _found = true;
                            };
                        } forEach [0,45,90,135,180,225,270,315];
                    };
                };
                if (_found) then {
                    // DIAG-STRIP: confirm the snap fired + show before/after.
                    ["Pathfinding goal-snap: water goal %1 -> land %2 (side=%3)", _origEnd, _endPos, _callbackArgs param [2,"?"]] call Alive_fnc_Dump;
                };
            };

            private _startSector = [_terrainGrid,"positionToSector", _startPos] call ALiVE_fnc_pathfindingGrid;
            private _goalSector = [_terrainGrid,"positionToSector", _endPos] call ALiVE_fnc_pathfindingGrid;
            private _startSubSector = [_terrainGrid,"positionToSubSector", _startPos] call ALiVE_fnc_pathfindingGrid;
            private _goalSubSector = [_terrainGrid,"positionToSubSector", _endPos] call ALiVE_fnc_pathfindingGrid;

            // Single-subsector early-out (#pathfinding-opt, candidate E): when start
            // and goal land in the same subsector, the A* only ever yields a 1-node
            // no-op path - the same check onFrame's init already makes (~line 745).
            // Doing it HERE, before the A* setup, skips 4 createHashMaps + the
            // frontier / currentJobData allocation AND a whole onFrame round-trip,
            // for ~59% of requests (measured 257/433). Mirror onFrame's completion:
            // fire the callback with the goal subsector centre, drop the job, load
            // the next (recurses through any further leading no-ops - queue depth is
            // small). Checked here, not in findPath, so the previousWaypoint position
            // re-read above is final - no false early-out from a stale queued start.
            // (Leaves onFrame's line-745 check as a now-redundant safety net.)
            if (_startSubSector isEqualTo _goalSubSector) exitWith {
                ALiVE_pathfinding_earlyOuts = ALiVE_pathfinding_earlyOuts + 1;   // DIAG-STRIP
                [_callbackArgs, [_goalSubSector select 2]] spawn _callback;
                _pathJobs deleteAt 0;
                [_logic,"loadCurrentJobData"] call MAINCLASS;
            };
            ALiVE_pathfinding_jobsRun = ALiVE_pathfinding_jobsRun + 1;   // DIAG-STRIP (full A* job)

            // Setup Layer 1 — native HashMaps keyed by index array (see
            // setNodeToFrontier / layer1SeaTravelCheck note). (#pathfinding-opt)
            private _cameFromMapLayer1 = createHashMap;
            private _costSoFarMapLayer1 = createHashMap;
            private _frontierLayer1 = [[0,_startSector]];
            private _pathLayer1 = [];
            private _closestSector = [(_startSector select 2) distance (_goalSector select 2),_startSector];

            // Setup Layer 2
            private _cameFromMapLayer2 = createHashMap;
            private _costSoFarMapLayer2 = createHashMap;
            private _frontierLayer2 = [[0,_startSubSector]];
            private _pathLayer2 = [];
            private _closestSubSector = [(_startSubSector select 2) distance (_goalSubSector select 2),_startSubSector];
            private _itersSinceClosest = 0;

            // Init Layers
            _costSoFarMapLayer1 set [_startSector select 0, 0];
            _costSoFarMapLayer2 set [_startSubSector select 0, 0];

            private _layer1Data = [_cameFromMapLayer1, _costSoFarMapLayer1, _frontierLayer1, _pathLayer1, _closestSector];
            private _layer2Data = [_cameFromMapLayer2, _costSoFarMapLayer2, _frontierLayer2, _pathLayer2, _closestSubSector, _itersSinceClosest];

            _currentJobData = [false, [false,false,false], _layer1Data, _layer2Data, _startSector, _goalSector, _startSubSector, _goalSubSector];   
            // [": findPath currentJobData %1 ",str _currentJobData] call Alive_fnc_Dump;

            [_logic,"currentJobData", _currentJobData] call ALiVE_fnc_hashSet;
        } else {
            [_logic,"currentJobData", []] call ALiVE_fnc_hashSet;
        };

    };

    case "onFrame": {

        private _pathJobs = [_logic,"pathJobs"] call ALiVE_fnc_hashGet;
        if (count _pathJobs == 0) exitwith {};

        _debugMarkers = [_logic , "pathDebugMarkers"] call Alive_fnc_hashGet;

        private _currentJob = _pathJobs select 0;
        private _currentJobData = [_logic,"currentJobData"] call ALiVE_fnc_hashGet;

        _currentJob params ["_startPos","_procedure","_waypoint","_previousWaypoint","_callbackArgs","_callback"];
        _currentJobData params ["_isActive","_jobDataFlags","_layer1", "_layer2","_startSector", "_goalSector", "_startSubSector", "_goalSubSector"];
        _jobDataFlags params ["_initComplete", "_layer1Complete", "_layer2Complete"];
        _procedure params ["_name","_capabilities","_limits","_weights"];

        // Prevent this from executing the same job twice in the event of a race condition
        if (_isActive) exitwith {};
        _currentJobData set [0,true];

        private _terrainGrid = [_logic,"terrainGrid"] call ALiVE_fnc_hashGet;
        private _sectorSize = [_terrainGrid,"sectorSize"] call Alive_fnc_hashGet;
        private _subSectorSize = [_terrainGrid,"subSectorSize"] call Alive_fnc_hashGet;
        private _jobComplete = false;

        scopename "main";

        call {

            if (!_initComplete) then {

                // check for non-bias procedure
                private _nonBiasProcedure = _procedure isEqualTo [[true,true,true,true,true],[0,0],[0,0,0,0]];
                if (_nonBiasProcedure) then {
                    _result = [_goalSubSector select 2];
                    _jobComplete = true;
                    breakto "main";
                };

                // check for same SubSector
                private _sameSubSector = (_startSubSector isEqualTo _goalSubSector);
                if (_sameSubSector) then {
                    _result = [_goalSubSector select 2];
                    _jobComplete = true;
                    breakto "main";
                };
                _initComplete = true;
                _jobDataFlags set [0,_initComplete];

                // ////////////////////////////////////////////////////
                // _m = createMarker ["startPos", _startSubSector select 2];
                // _debugMarkers pushback "startPos";
                // _m setMarkerShape "ICON";
                // _m setMarkerType "hd_dot";
                // _m setMarkerSize [0.9,0.9];
                // _m setMarkerColor "ColorYellow";
                // ////////////////////////////////////////////////////
                // ////////////////////////////////////////////////////
                // _m = createMarker ["endPos", _goalSubSector select 2];
                // _debugMarkers pushback "endPos";
                // _m setMarkerShape "ICON";
                // _m setMarkerType "hd_dot";
                // _m setMarkerSize [0.9,0.9];
                // _m setMarkerColor "ColorCIV";
                // ////////////////////////////////////////////////////
            };

            ////// LAYER 1 PATHFINDING
            // only check 1 sector per frame
            private _sectorIterations = 0;

            while {!(_layer1Complete) && _sectorIterations < 11} do {
                _sectorIterations = _sectorIterations + 1;
                _layer1 params ["_cameFromMapLayer1", "_costSoFarMapLayer1", "_frontierLayer1", "_pathLayer1", "_closestSector"];

                private _currentSector = _frontierLayer1 call _fnc_priorityPull;
                _currentSector params ["_indxCS", "_posCS", "_centerPosCS", "_typeCS", "_modifiersCS"];

                // ////////////////////////////////////////////////////
                // _m = createMarker [str str str str _centerPosCS, _centerPosCS];
                // _debugMarkers pushback str str str str _centerPosCS;
                // _m setMarkerShape "RECTANGLE";
                // _m setMarkerSize [_sectorSize/2,_sectorSize/2];
                // _m setMarkerAlpha 0.3;
                // _m setMarkerColor "ColorGreen";
                // ////////////////////////////////////////////////////

                if ((_currentSector select 0) isequalto (_goalSector select 0)) exitwith {
                    _layer1Complete = [_logic,"getLayerPath", [_procedure, _startSector, _goalSector ,_cameFromMapLayer1, _pathLayer1, _sectorSize ]] call MAINCLASS;
                    _jobDataFlags set [1,_layer1Complete];
                    breakto "main";
                };

                if ((_centerPosCS distance (_goalSector select 2)) < (_closestSector select 0)) then {
                    _closestSector set [0, _centerPosCS distance (_goalSector select 2)];
                    _closestSector set [1, _currentSector];
                };

                // determine which neighbor is the best path
                {
                    private _neighSector = _x;

                    _neighSector params ["_indx", "_pos", "_centerPos", "_type", "_modifiers"];
                    private _prevHeight = _modifiersCS select 2;
                    private _isWaterTravel = false;
                    private _canTraverse = [_procedure, _neighSector, _currentSector, _sectorSize] call _fnc_canTraverse;
                    if (typeName _canTraverse == "ARRAY") then {_isWaterTravel = _canTraverse select 1; _canTraverse = _canTraverse select 0;};
                    if (_canTraverse) then {
                        private _distanceToGoal = _centerPos distance (_goalSector select 2);
                        private _heuristicParams = [_neighSector,_currentSector,_procedure, _distanceToGoal,_sectorSize,_isWaterTravel];
                        [_cameFromMapLayer1, _costSoFarMapLayer1, _frontierLayer1, _neighSector, _currentSector, _distanceToGoal, _heuristicParams] call _fnc_setNode;
                        if (_distanceToGoal > (_closestSector select 0)*5) exitwith {
                            // Unable to complete path to goal
                            _layer1Complete = [_logic,"getLayerPath", [_procedure, _startSector, (_closestSector select 1),_cameFromMapLayer1, _pathLayer1, _sectorSize ]] call MAINCLASS;
                            _jobDataFlags set [1,_layer1Complete];
                            breakto "main";
                        };
                     } else {
                        if (_neighSector isEqualTo _goalSector) exitwith {
                            // Unable to complete path to goal
                            _layer1Complete = [_logic,"getLayerPath", [_procedure, _startSector, (_closestSector select 1),_cameFromMapLayer1, _pathLayer1, _sectorSize ]] call MAINCLASS;
                            _jobDataFlags set [1,_layer1Complete];
                            breakto "main";
                        };
                     };
                } foreach ([_terrainGrid, "getNeighborSectors", _indxCS] call Alive_fnc_pathfindingGrid);

                if (count _frontierLayer1 == 0) exitwith {
                    // Unable to complete path to goal
                    _layer1Complete = [_logic,"getLayerPath", [_procedure, _startSector, (_closestSector select 1) ,_cameFromMapLayer1, _pathLayer1, _sectorSize ]] call MAINCLASS;
                    _jobDataFlags set [1,_layer1Complete];
                    breakto "main";
                };
            };

            while {(_layer1Complete) && !(_layer2Complete)  && _sectorIterations < 6} do {
                _sectorIterations = _sectorIterations + 1;
                _layer2 params ["_cameFromMapLayer2", "_costSoFarMapLayer2", "_frontierLayer2", "_pathLayer2", "_closestSubSector", "_itersSinceClosest"];
                _layer2 set [5, _itersSinceClosest + 1];
                private _pathLayer1 = _layer1 select 3;
                private _currentSubSector = _frontierLayer2 call _fnc_priorityPull;
                _currentSubSector params ["_indxCS", "_posCS", "_centerPosCS", "_typeCS", "_modifiersCS"];

                ////////////////////////////////////////////////////
                // _m = createMarker [str str str str _centerPosCS, _centerPosCS];
                // _debugMarkers pushback str str str str _centerPosCS;
                // _m setMarkerShape "ICON";
                // _m setMarkerType "hd_dot";
                // _m setMarkerSize [0.5,0.5];
                // _m setMarkerColor "ColorGreen";
                ////////////////////////////////////////////////////

                if ((_currentSubSector select 0) isequalto (_goalSubSector select 0)) exitwith {
                    [_logic,"getLayerPath", [_procedure, _startSubSector, _goalSubSector ,_cameFromMapLayer2, _pathLayer2, _subSectorSize]] call MAINCLASS;
                    _jobDataFlags set [2,true];
                    breakto "main";
                };

                if ((_centerPosCS distance (_goalSubSector select 2)) < (_closestSubSector select 0)) then {
                    _closestSubSector set [0, _centerPosCS distance (_goalSubSector select 2)];
                    _closestSubSector set [1, _currentSubSector];
                    _itersSinceClosest = 0;
                    _layer2 set [5,0];
                };
                
                if ((count _pathLayer1 > 0) && ((_centerPosCS distance (_pathLayer1 select 0)) < _sectorSize)) then {
                    _pathLayer1 deleteat 0;
                };

                // determine which neighbor is the best path
                {
                    private _neighSubSector = _x;
                    if (isNil "_neighSubSector") exitwith {};

                    _neighSubSector params ["_indx", "_pos", "_centerPos", "_type", "_modifiers"];
                    private _prevHeight = _modifiersCS select 2;
                    private _distanceToGoal = _centerPos distance (_goalSubSector select 2);
                    private _isWaterTravel = false;
                    private _canTraverse = [_procedure, _neighSubSector, _currentSubSector, _subSectorSize] call _fnc_canTraverse;
                    if (typeName _canTraverse == "ARRAY") then {_isWaterTravel = _canTraverse select 1; _canTraverse = _canTraverse select 0;};

                    if (_canTraverse) then { 
                        if (count _pathLayer1 > 0) then {_distanceToGoal = [_pathLayer1,_centerPos] call _fnc_getDistanceFromLayer;};
                        private _heuristicParams = [_neighSubSector,_currentSubSector,_procedure,_distanceToGoal,_subSectorSize,_isWaterTravel];
                        [_cameFromMapLayer2, _costSoFarMapLayer2, _frontierLayer2, _neighSubSector, _currentSubSector, _distanceToGoal, _heuristicParams] call _fnc_setNode;
                        if (/*(_distanceToGoal > (_closestSubSector select 0)*4) ||*/ (_itersSinceClosest > 500)) exitwith {
                            // Unable to complete path to goal - spent too much time looking
                            [_logic,"getLayerPath", [_procedure, _startSubSector, (_closestSubSector select 1),_cameFromMapLayer2, _pathLayer2, _subSectorSize ]] call MAINCLASS;
                            if (count _pathLayer2 > 0) then { //set destination as last known good position
                                [_waypoint,"position",_pathLayer2 select (count _pathLayer2 -1)] call ALiVE_fnc_hashSet;
                            };
                            _jobDataFlags set [2,true];
                            breakto "main";
                        };
                     } else {
                        if (_neighSubSector isEqualTo _goalSubSector) exitwith {
                            // Unable to complete path to goal because goal sector untraversable
                            [_logic,"getLayerPath", [_procedure, _startSubSector, (_closestSubSector select 1),_cameFromMapLayer2, _pathLayer2, _subSectorSize ]] call MAINCLASS;
                            if (count _pathLayer2 > 0) then { //set destination as last known good position
                                [_waypoint,"position",_pathLayer2 select (count _pathLayer2 -1)] call ALiVE_fnc_hashSet;
                            };
                            _jobDataFlags set [2,true];
                            breakto "main";
                        };
                     };
                } foreach ([_terrainGrid, "getNeighborSubSectors", _indxCS] call Alive_fnc_pathfindingGrid);

                if (count _frontierLayer2 == 0) exitwith {
                    // Unable to complete path to goal - ran out of sectors to check
                    [_logic,"getLayerPath", [_procedure, _startSubSector, (_closestSubSector select 1), _cameFromMapLayer2, _pathLayer2, _subSectorSize ]] call MAINCLASS;
                    if (count _pathLayer2 > 0) then { //set destination as last known good position
                        [_waypoint,"position",_pathLayer2 select (count _pathLayer2 -1)] call ALiVE_fnc_hashSet;
                    };
                    _jobDataFlags set [2,true];
                    breakto "main";
                };
            };
        };

        if (_layer1Complete && _layer2Complete) then {
            _jobComplete = true;
            _result = _layer2 select 3;
        };

        if (_jobComplete) then {
            if (isNil {_result select 0;}) then {["Error - Undefined value in path: %1 \n%2", _layer2, _result] call Alive_fnc_Dump;};

            // Optional debug draw of the final computed route (gated by the
            // "Draw Paths" toggle - Eden param ALiVE_sys_profile_pathfindingDrawPaths
            // or the live admin-menu toggle, both set the global below). Off by
            // default = zero cost (the flag short-circuits before any marker is
            // made). Each path's markers are tagged with a per-call id so the next
            // draw doesn't collide. (#pathfinding-draw 2026-06-01)
            // Only draw/log actual routes (>= 2 nodes). A 1-node "path" means start
            // and goal share a subsector (len 0) - drawing it leaves an orphaned dot
            // with no line, and it's the bulk of completed paths (log noise too).
            if (missionNamespace getVariable ["ALiVE_pathfinding_drawPaths", false] && {_result isEqualType []} && {count _result > 1}) then {
                private _pathMarkers = [_logic, "pathDrawMarkers", []] call ALiVE_fnc_hashGet;
                // Colour the route by the requesting profile's side (threaded as
                // the 3rd callbackArgs element from fnc_profileEntity's findPath
                // call). Standard A3 side marker colours; unknown -> ColorUNKNOWN.
                private _drawColor = switch (toUpper (_callbackArgs param [2, "UNKNOWN"])) do {
                    case "WEST": { "ColorWEST" };   // BLUFOR
                    case "EAST": { "ColorEAST" };   // OPFOR
                    case "GUER": { "ColorGUER" };   // Independent
                    case "CIV":  { "ColorCIV"  };   // Civilian
                    default      { "ColorUNKNOWN" };
                };
                private _tag = format ["ALiVE_pf_path_%1_%2", diag_frameNo, count _pathMarkers];
                // Drop a dot at each node and collect a flat [x1,y1,x2,y2,...]
                // coordinate list for the connecting polyline.
                private _line = [];
                {
                    private _mName = format ["%1_%2", _tag, _forEachIndex];
                    private _m = createMarker [_mName, _x];
                    _m setMarkerShape "ICON";
                    _m setMarkerType "hd_dot";
                    _m setMarkerSize [0.5, 0.5];
                    _m setMarkerColor _drawColor;
                    _m setMarkerAlpha 0.7;
                    _pathMarkers pushBack _mName;
                    _line pushBack (_x select 0);
                    _line pushBack (_x select 1);
                } forEach _result;
                // Link the nodes with a single polyline marker so the route reads
                // as a line rather than a scatter of dots. setMarkerPolyline needs
                // a flat, even-length array of >= 2 points (>= 4 numbers).
                if (count _line >= 4) then {
                    private _plName = format ["%1_line", _tag];
                    createMarker [_plName, _result select 0];
                    _plName setMarkerShape "POLYLINE";
                    _plName setMarkerPolyline _line;
                    _plName setMarkerColor _drawColor;
                    _plName setMarkerAlpha 0.8;
                    _pathMarkers pushBack _plName;
                };
                // Diag (gated by the same draw-paths flag): characterise the route
                // so a water-crossing path is identifiable in the RPT - requesting
                // side, node count, total + longest segment length, and how many
                // segment midpoints sit over water. A long route with water
                // segments = the path crosses water; a large maxSeg = a jump
                // between non-adjacent nodes. (#pathfinding-draw diag)
                private _side = _callbackArgs param [2, "UNKNOWN"];
                private _len = 0; private _maxSeg = 0; private _waterSegs = 0;
                private _deep = ALiVE_pathfinding_seaLevel - ALiVE_pathfinding_waterMargin;   // below = real sea (beach/shallows excluded)
                for "_i" from 1 to (count _result - 1) do {
                    private _pA = _result select (_i-1);
                    private _pB = _result select _i;
                    private _seg = _pB distance2D _pA;
                    _len = _len + _seg;
                    if (_seg > _maxSeg) then { _maxSeg = _seg; };
                    if ((getTerrainHeightASL [((_pA select 0)+(_pB select 0))/2, ((_pA select 1)+(_pB select 1))/2]) < _deep) then { _waterSegs = _waterSegs + 1; };
                };
                ["Pathfinding route: side=%1 nodes=%2 len=%3m maxSeg=%4m waterSegs=%5", _side, count _result, round _len, round _maxSeg, _waterSegs] call Alive_fnc_Dump;
                // DIAG-STRIP (candidate D profile): A* search effort for this path -
                // expansions (came-from map size = nodes reached, ~= nodes expanded) and
                // the final open-set size, per layer. Picks the optimisation target: a
                // large frontier means the O(n^2) linear open-set (candidate B) is the
                // cost; high expansions with a small frontier means the per-node
                // call-MAINCLASS dispatch tax (candidate A), which pays ~40-50 dispatches
                // PER expansion. Grep "Pathfinding perf:".
                ["Pathfinding perf: nodes=%1 expL1=%2 expL2=%3 frontierL1=%4 frontierL2=%5",
                    count _result, count (_layer1 select 0), count (_layer2 select 0),
                    count (_layer1 select 2), count (_layer2 select 2)] call Alive_fnc_Dump;
                // DIAG-STRIP: for water-touching routes, log the endpoints + which end
                // is over water + every over-water node. Distinguishes the START being
                // in water (a profile sitting in the sea) from the GOAL being in water
                // (an objective resolved offshore) from a mid-route crossing - which
                // decides the fix. Grep "route WATER:".
                if (_waterSegs > 0) then {
                    private _s = _result select 0;
                    private _g = _result select (count _result - 1);
                    private _wNodes = _result select { (getTerrainHeightASL [_x select 0, _x select 1]) < _deep };
                    ["Pathfinding route WATER: side=%1 startW=%2 goalW=%3 waterNodes=%4 of %5 | start=%6 goal=%7 | waterPos=%8 | profileID=%9",
                        _side, (getTerrainHeightASL [_s select 0, _s select 1]) < _deep, (getTerrainHeightASL [_g select 0, _g select 1]) < _deep,
                        count _wNodes, count _result, _s, _g, _wNodes, _callbackArgs param [0, "?"]] call Alive_fnc_Dump;
                    // DIAG-STRIP: per-node [cell type, terrain depth] so we can see how
                    // the crossed bay cells are actually classified (LAND/COAST/WATER)
                    // and how deep - tells us why the A* steps through them.
                    private _nodeCells = _result apply {
                        private _ss = [_terrainGrid, "positionToSubSector", _x] call ALiVE_fnc_pathfindingGrid;
                        [_ss select 3, round (getTerrainHeightASL [_x select 0, _x select 1])]
                    };
                    ["Pathfinding route WATER cells (type/depth): side=%1 %2", _side, _nodeCells] call Alive_fnc_Dump;
                };
                [_logic, "pathDrawMarkers", _pathMarkers] call ALiVE_fnc_hashSet;
            };

            [_callbackArgs,_result] spawn _callback;

            // remove job from queue and clean up the mess we made. The cost /
            // came-from HashMaps are released by garbage collection once the job
            // data holding them is cleared below - no explicit delete needed
            // (unlike the CBA namespaces these replaced). (#pathfinding-opt)
            _pathJobs deleteat 0;
            _currentJobData resize 0;
            _currentJob resize 0;
            // {deleteMarker _x} foreach _debugMarkers;
            // _debugMarkers resize 0;
            // load next job data
            [_logic,"loadCurrentJobData"] call MAINCLASS;
        };

        _currentJobData set [0,false];
    };

};

if (isnil "_result") then {nil} else {_result};