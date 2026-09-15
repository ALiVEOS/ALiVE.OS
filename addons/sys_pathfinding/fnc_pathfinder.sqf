#include "\x\alive\addons\sys_pathfinding\script_component.hpp"

#define MAINCLASS alive_fnc_pathfinder

params [
    ["_logic", nil],
    ["_operation", ""],
    ["_args", objNull]
];

private "_result";

PROFILE_SCOPE(PFOPERATION, ("ALiVE pathfinder: " + _operation))

switch (_operation) do {

    case "create": {
        private _pathfindingSizeRaw = [ALIVE_profileSystem,"pathfindingSize"] call ALIVE_fnc_profileSystem;

        // Grid size accepts a positive [sector, subsector] pair, a stringified pair,
        // or an auto/high/med/low token. Auto uses medium resolution.
        // Select the first world-size tier covering the map, capped at the largest tier.
        private _resolvePathfindingSize = {
            params ["_raw"];
            // Invalid explicit arrays fall back to automatic sizing.
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
        // sea for the goal-snap + the A* deep-water traverse checks - anything shallower is walkable
        // beach/surf and must NOT be treated as water. isNil-guarded so a console
        // override (e.g. ALiVE_pathfinding_waterMargin = 0.5) survives a mission restart.
        if (isNil "ALiVE_pathfinding_waterMargin") then { ALiVE_pathfinding_waterMargin = 1.0 };
        // How much dearer an airfield-surface cell is to cross, for ground procedures.
        // A soft cost, not a hard block: grid cells are tens of metres, and a hard
        // wall could sever a field that sits across a narrow neck (Stratis Air Station
        // does exactly that) and starve the frontier into a dead route. Six is enough
        // to bend a route around a runway when any way around exists, and to fall back
        // to crossing when none does. isNil-guarded so a console override survives a
        // mission restart. Set to 1 to disable the penalty entirely.
        if (isNil "ALiVE_pathfinding_airsideWeight") then { ALiVE_pathfinding_airsideWeight = 6 };
        private _terrainGrid = [nil,"create", _pathfindingSize] call ALiVE_fnc_pathfindingGrid;

        // Pathfinder state is an opaque HashMap handle passed to this dispatcher.
        _logic = createHashMapFromArray [
            ["terrainGrid", _terrainGrid],
            ["pathfindingProcedures", createHashMap],
            ["currentJobData", []],
            ["pathJobs", []],
            ["pathDebugMarkers", []],
            ["pathDrawMarkers", []]
        ];

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
    //
    case "setDrawGrid": {
        private _enable = if (_args isEqualType true) then { _args } else { false };
        missionNamespace setVariable ["ALiVE_pathfinding_drawGrid", _enable];
        private _terrainGrid = _logic get "terrainGrid";
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
            private _pathMarkers = _logic get "pathDrawMarkers";
            { deleteMarker _x } forEach _pathMarkers;
            _logic set ["pathDrawMarkers", []];
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

        private _allProcedures = _logic get "pathfindingProcedures";
        private _factionProcedures = _allProcedures get _faction;
        if (isNil "_factionProcedures") then { _factionProcedures = createHashMap; };

        _factionProcedures set [_name, _procedure];
        _allProcedures set [_faction, _factionProcedures];

    };

    case "getPathfindingProcedure": {

        _args params [["_procedureName","LandRoad"],["_faction","default"]];

        private _allProcedures = _logic get "pathfindingProcedures";
        private _factionProcedures = _allProcedures get _faction;
        if (isNil "_factionProcedures") then { _factionProcedures = _allProcedures get "default"; };

        _result = _factionProcedures get _procedureName;
    };

    ////////// SECTOR ANALYSIS //////////
    case "layer1SeaTravelCheck": {
        _args params [
            ["_startPos",[0,0,0],[[]],[2,3]],
            ["_endPos",[0,0,0],[[]],[2,3]],
            ["_maxIterations", 250, [0]],
            ["_procedure",["genericCanSwimButNoWater", [true, true, true, false, false], [0.7, 0], [-0.5, 0, 0, 0]],[[]],[4]]
        ];


        private _terrainGrid = _logic get "terrainGrid";
        private _sectorSize = _terrainGrid get "sectorSize";
        private _waterEdgeCache = [_terrainGrid, _sectorSize] call ALiVE_fnc_pathfinderGetWaterEdgeCache;
        private _airsideActive =
            ALiVE_pathfinding_airsideWeight != 1
            && {!(((_procedure select 1) select 4))}
            && {!(ALiVE_airsideFields isEqualTo [])};
        private _airsideCanDiscount = _airsideActive && {ALiVE_pathfinding_airsideWeight < 1};
        private _startSector = [_terrainGrid,"positionToSector", _startPos] call ALiVE_fnc_pathfindingGrid;
        private _goalSector = [_terrainGrid,"positionToSector", _endPos] call ALiVE_fnc_pathfindingGrid;

        // Cost and predecessor maps use cell indices [x,y] as keys.
        private _cameFromMapLayer1 = createHashMap;
        private _costSoFarMapLayer1 = createHashMap;
        _costSoFarMapLayer1 set [_startSector select 0, 0];
        private _frontierLayer1 = [[0,_startSector,0]];
        private _layer1Complete = false;
        // An exhausted frontier indicates no land route. An iteration timeout is inconclusive.
        private _genuinelyBlocked = false;
        private _sectorIterations = 0;

        scopeName "Main";

        call {
            while {!_layer1Complete && _sectorIterations < _maxIterations} do {
                PROFILE_SCOPE(PFSEACHECK, "ALiVE pathfinder: sea-check expansion")
                _sectorIterations = _sectorIterations + 1;

                private _currentSector = [_frontierLayer1, _costSoFarMapLayer1] call ALiVE_fnc_pathfinderPriorityPullFresh;
                if (isNil "_currentSector") exitWith {
                    _genuinelyBlocked = true;
                    breakTo "Main";
                };
                _currentSector params ["_indxCS", "_posCS", "_centerPosCS", "_typeCS", "_modifiersCS"];
                private _currentCost = _costSoFarMapLayer1 get _indxCS;

                if ((_currentSector select 0) isequalto (_goalSector select 0)) exitwith {
                    _layer1Complete = true;
                    breakto "main";
                };
                {
                    private _neighSector = _x;

                    private _centerPos = _neighSector select 2;
                    private _moveCost = [_currentSector, _neighSector, _sectorSize] call ALiVE_fnc_pathfinderGetMovementCost;
                    private _knownCost = _costSoFarMapLayer1 get (_neighSector select 0);
                    private _baseCostCanImprove = isNil "_knownCost" || {_currentCost + _moveCost < _knownCost};
                    private _mustCheckTraversal = _neighSector isEqualTo _goalSector;
                    if (
                        _mustCheckTraversal
                        || {_airsideCanDiscount}
                        || {_baseCostCanImprove}
                    ) then {
                        // Only finalize candidates that survived the cheap base-cost filter.
                        // Mandatory goal/failure traversal checks still run without improvement.
                        if (_airsideActive && {_baseCostCanImprove || {_airsideCanDiscount}}) then {
                            // Classified cells need only the cached flag and current weight.
                            // Keep first-time classification in the helper.
                            if (count _neighSector > 5) then {
                                if (_neighSector select 5) then {
                                    _moveCost = _moveCost * ALiVE_pathfinding_airsideWeight;
                                };
                            } else {
                                _moveCost = [_neighSector, _sectorSize, _moveCost] call ALiVE_fnc_pathfinderGetFinalMovementCost;
                            };
                        };
                        private _newCostSoFar = _moveCost + _currentCost;
                        private _finalCostCanImprove = isNil "_knownCost" || {_newCostSoFar < _knownCost};
                        private _traversal = 0;
                        if (_mustCheckTraversal || {_finalCostCanImprove}) then {
                            _traversal = [_procedure, _neighSector, _currentSector, _sectorSize, _waterEdgeCache] call ALiVE_fnc_pathfinderCanTraverse;
                        };
                        if (_traversal > 0) then {
                            if (_finalCostCanImprove) then {
                                private _distanceToGoal = _centerPos distance (_goalSector select 2);
                                private _heuristicParams = [_neighSector,_currentSector,_procedure, _distanceToGoal,_sectorSize,_traversal == 2];
                                [_cameFromMapLayer1, _costSoFarMapLayer1, _frontierLayer1, _neighSector, _currentSector, _distanceToGoal, _heuristicParams, _moveCost, false, _newCostSoFar] call ALiVE_fnc_pathfinderSetNode;
                            };
                        };
                        // A rejected edge into the goal does not rule out other approaches.
                    };
                } foreach ([_terrainGrid, "getNeighborSectors", _indxCS] call Alive_fnc_pathfindingGrid);

                if (count _frontierLayer1 == 0) exitwith {_genuinelyBlocked = true; breakTo "Main";};
            };
        };

        // Budget exhaustion leaves reachability unknown and returns false.
        _result = _genuinelyBlocked;
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
            // Boats: pick the probe that keeps the route straightest (min
            // prev->node->next detour) while staying in water, so adjacent naval
            // waypoints track a centreline instead of each lurching to the deepest
            // nearby pocket. Depth only breaks near-straight ties.
            if !((isNil "_prevPos") || (isNil "_nextPos")) then {
                private _seaLvl = missionNamespace getVariable ["ALiVE_pathfinding_seaLevel", 0];
                private _bestDetour = (_nextPos distance _result) + (_prevPos distance _result);
                private _bestDepth = getTerrainHeightASL _result;
                {
                    private _detour = (_nextPos distance _x) + (_prevPos distance _x);
                    private _depth = getTerrainHeightASL _x;
                    if ((_depth < _seaLvl) && {(_detour < _bestDetour) || ((_detour < _bestDetour + 30) && (_depth < _bestDepth))}) then {
                        _result = _x;
                        _bestDetour = _detour;
                        _bestDepth = _depth;
                    };
                } foreach _subPositions;
                // Never leave a naval waypoint on dry land: if nothing straighter and
                // wet was found, fall back to the deepest-water probe.
                if ((getTerrainHeightASL _result) >= _seaLvl) then {
                    {
                        if ((getTerrainHeightASL _x) < (getTerrainheightASL _result)) then {_result = _x;};
                    } foreach _subPositions;
                };
            } else {
                {
                    if ((getTerrainHeightASL _x) < (getTerrainheightASL _result)) then {_result = _x;};
                } foreach _subPositions;
            };
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

    // A search terminal queues reconstruction; the next frame owns the work.
    // Keep layer flags false until refinement and consolidation have finished.
    case "beginLayerPath": {
        _args params ["_layerIndex", "_start", "_goal", "_cameFrom", "_path", "_size", ["_retarget", false]];
        private _jobData = _logic get "currentJobData";
        // Coarse reconstruction changes the guidance route; discard its cached length.
        if (_layerIndex == 1) then {(_jobData select 2) set [5, -1]};
        _jobData set [8, [_layerIndex, _start, _goal, _cameFrom, _path, _size, _retarget, 0, 1]];
    };

    case "stepLayerPath": {
        _args params ["_procedure", "_state"];
        _state params ["_layerIndex", "_start", "_current", "_cameFrom", "_path", "_size", "_retarget", "_phase", "_index"];
        // Yield between complete steps. Cheap reversal/consolidation work can
        // share an update instead of holding the queue for four steps at a time.
        // Compare elapsed time, rather than a rounded absolute deadline, and
        // guarantee progress even when diag_tickTime precision is coarse.
        // A single refinement query may overshoot; the work cap also bounds
        // updates where the timer does not advance. Zero disables time limiting.
        private _reconstructionBudgetMs = missionNamespace getVariable ["ALiVE_pathfinding_reconstructionBudgetMs", 1];
        if !(_reconstructionBudgetMs isEqualType 0) then {_reconstructionBudgetMs = 1};
        private _reconstructionStarted = diag_tickTime;
        private _steps = 0;
        while {
            _phase < 3 && {_steps < 32}
            && {
                _steps == 0
                || {_reconstructionBudgetMs <= 0}
                || {1000 * (diag_tickTime - _reconstructionStarted) < _reconstructionBudgetMs}
            }
        } do {
            _steps = _steps + 1;
            switch (_phase) do {
                case 0: {
                    PROFILE_SCOPE(PFRECONSTRUCT, "ALiVE pathfinder: reconstruct step")
                    if ((_current select 0) isEqualTo (_start select 0)) then {
                        if (_path isEqualTo []) then {_path pushBack (_start select 2)};
                        _phase = 1;
                    } else {
                        private _next = _cameFrom get (_current select 0);
                        if (_path isEqualTo []) then {
                            _path pushBack (_current select 2);
                        } else {
                            private _previousPos = _path select (count _path - 1);
                            _path pushBack ([nil, "findOptimalPos", [_current, _size, _procedure, _next select 2, _previousPos]] call MAINCLASS);
                        };
                        _current = _next;
                    };
                };
                case 1: {
                    PROFILE_SCOPE(PFREVERSE, "ALiVE pathfinder: reverse route")
                    reverse _path;
                    _phase = if (_size < 200 && {count _path > 3}) then {2} else {3};
                };
                case 2: {
                    PROFILE_SCOPE(PFCONSOLIDATE, "ALiVE pathfinder: consolidate step")
                    if (_index < (count _path - 2)) then {
                        private _currentDir = (_path select (_index - 1)) getDir (_path select _index);
                        private _nextDir = (_path select _index) getDir (_path select (_index + 1));
                        if (abs (_nextDir - _currentDir) < 15) then {
                            _path deleteAt _index;
                        } else {
                            _index = _index + 1;
                        };
                    } else {
                        _phase = 3;
                    };
                };
            };
        };
        _state set [2, _current];
        _state set [7, _phase];
        _state set [8, _index];
        _result = _phase == 3;
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

    ////////// JOB FUNCTIONS //////////
    case "findPath": {

        _args params ["_startPos","_procedure","_waypoint","_previousWaypoint","_callbackArgs","_callback"];
        
        private _pathJobs = _logic get "pathJobs";
        // Copy only the outer array. Waypoints and callback
        // arguments must keep their shared references: the callback marks the
        // profile's original pending-path record ready. Unary + deep-copies it.
        private _newJob = _args + [];
        _pathJobs pushback _newJob;
        
        if (count _pathJobs == 1) then {
            [_logic,"loadCurrentJobData"] call MAINCLASS;
        };
    };

    case "loadCurrentJobData": {

        private _pathJobs = _logic get "pathJobs";

        // load next job data
        if (count _pathJobs > 0) then {
            private _nextJob = _pathJobs select 0;
            _nextJob params ["_startPos","_procedure","_waypoint","_previousWaypoint","_callbackArgs","_callback"];

            if !(isNil "_previousWaypoint") then { 
                //update _startPos in the event the waypoint position changed e.g. during prev pathfinding job
                _startPos = [_previousWaypoint, "position"] call Alive_fnc_hashGet;
            };

            private _endPos = [_waypoint,"position"] call ALive_fnc_hashGet;
            
            private _terrainGrid = _logic get "terrainGrid";

            // Goal-snap: a land-capable group must never be routed
            // into open sea. When the goal resolves over water - an objective/waypoint
            // placed offshore - retarget to the nearest land
            // so the route ends at the shore, not in the sea. Fires only for land
            // procedures with a water goal; a land goal is untouched, and a goal on an
            // island stays as-is (the A* still returns the closest reachable node).
            // getTerrainHeightASL < seaLevel matches the grid's own water classification
            // and is reliable at any range (unlike surfaceIsWater). Ring-search outward
            // in subsector steps for the nearest land point.
            private _canLand = (_procedure select 1) select 0;   // capabilities select 0 = canTraverseLand
            if (_canLand && {(getTerrainHeightASL [_endPos select 0, _endPos select 1]) < (ALiVE_pathfinding_seaLevel - ALiVE_pathfinding_waterMargin)}) then {
                private _step = (_terrainGrid get "subSectorSize") max 25;
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
            };

            private _startSector = [_terrainGrid,"positionToSector", _startPos] call ALiVE_fnc_pathfindingGrid;
            private _goalSector = [_terrainGrid,"positionToSector", _endPos] call ALiVE_fnc_pathfindingGrid;
            private _startSubSector = [_terrainGrid,"positionToSubSector", _startPos] call ALiVE_fnc_pathfindingGrid;
            private _goalSubSector = [_terrainGrid,"positionToSubSector", _endPos] call ALiVE_fnc_pathfindingGrid;

            // Resolve same-cell requests after refreshing the previous waypoint position,
            // before allocating search state. Keep callback arguments shared.
            if (_startSubSector isEqualTo _goalSubSector) exitWith {
                [_callbackArgs, [_goalSubSector select 2]] spawn _callback;
                _pathJobs deleteAt 0;
                [_logic,"loadCurrentJobData"] call MAINCLASS;
            };

            // Coarse search state.
            private _cameFromMapLayer1 = createHashMap;
            private _costSoFarMapLayer1 = createHashMap;
            private _frontierLayer1 = [[0,_startSector,0]];
            private _pathLayer1 = [];
            private _closestSector = [(_startSector select 2) distance (_goalSector select 2),_startSector];

            // Setup Layer 2
            private _cameFromMapLayer2 = createHashMap;
            private _costSoFarMapLayer2 = createHashMap;
            private _frontierLayer2 = [[0,_startSubSector,0]];
            private _pathLayer2 = [];
            private _closestSubSector = [(_startSubSector select 2) distance (_goalSubSector select 2),_startSubSector];
            private _itersSinceClosest = 0;

            // Init Layers
            _costSoFarMapLayer1 set [_startSector select 0, 0];
            _costSoFarMapLayer2 set [_startSubSector select 0, 0];

            // Slot 5 caches the coarse-route tail distance; -1 means not calculated.
            private _layer1Data = [_cameFromMapLayer1, _costSoFarMapLayer1, _frontierLayer1, _pathLayer1, _closestSector, -1];
            private _layer2Data = [_cameFromMapLayer2, _costSoFarMapLayer2, _frontierLayer2, _pathLayer2, _closestSubSector, _itersSinceClosest];

            _currentJobData = [false, [false,false,false], _layer1Data, _layer2Data, _startSector, _goalSector, _startSubSector, _goalSubSector, []];

            _logic set ["currentJobData", _currentJobData];
        } else {
            _logic set ["currentJobData", []];
        };

    };

    case "onFrame": {

        private _pathJobs = _logic get "pathJobs";
        private _queuedPathCount = count _pathJobs;
        if (missionNamespace getVariable ["ALiVE_pathfinding_queueChat", true]) then {
        };
        if (_queuedPathCount == 0) exitwith {};

        _debugMarkers = _logic get "pathDebugMarkers";

        private _currentJob = _pathJobs select 0;
        private _currentJobData = _logic get "currentJobData";

        _currentJob params ["_startPos","_procedure","_waypoint","_previousWaypoint","_callbackArgs","_callback"];
        _currentJobData params ["_isActive","_jobDataFlags","_layer1", "_layer2","_startSector", "_goalSector", "_startSubSector", "_goalSubSector"];
        _jobDataFlags params ["_initComplete", "_layer1Complete", "_layer2Complete"];
        _procedure params ["_name","_capabilities","_limits","_weights"];

        // Prevent this from executing the same job twice in the event of a race condition
        if (_isActive) exitwith {};
        _currentJobData set [0,true];

        private _jobComplete = false;

        scopename "main";

        call {

            private _completion = _currentJobData param [8, []];
            if !(_completion isEqualTo []) then {
                if ([_logic, "stepLayerPath", [_procedure, _completion]] call MAINCLASS) then {
                    _completion params ["_completedLayer", "_start", "_end", "_cameFrom", "_path", "_size", "_retarget"];
                    if (_retarget && {count _path > 0}) then {
                        [_waypoint, "position", _path select (count _path - 1)] call ALiVE_fnc_hashSet;
                    };
                    _jobDataFlags set [_completedLayer, true];
                    _layer1Complete = _jobDataFlags select 1;
                    _layer2Complete = _jobDataFlags select 2;
                    _currentJobData set [8, []];
                };
                // Never combine reconstruction with another search slice.
                breakTo "main";
            };

            private _terrainGrid = _logic get "terrainGrid";
            private _sectorSize = _terrainGrid get "sectorSize";
            private _subSectorSize = _terrainGrid get "subSectorSize";
            private _sectorWaterEdgeCache = [_terrainGrid, _sectorSize] call ALiVE_fnc_pathfinderGetWaterEdgeCache;
            private _subSectorWaterEdgeCache = [_terrainGrid, _subSectorSize] call ALiVE_fnc_pathfinderGetWaterEdgeCache;
            private _airsideActive =
                ALiVE_pathfinding_airsideWeight != 1
                && {!((_capabilities select 4))}
                && {!(ALiVE_airsideFields isEqualTo [])};
            private _airsideCanDiscount = _airsideActive && {ALiVE_pathfinding_airsideWeight < 1};

            if (!_initComplete) then {

                private _nonBiasProcedure =
                    _capabilities isEqualTo [true,true,true,true,true]
                    && {_limits isEqualTo [0,0]}
                    && {_weights isEqualTo [0,0,0,0]};
                if (_nonBiasProcedure) then {
                    _result = [_goalSubSector select 2];
                    _jobComplete = true;
                    breakto "main";
                };

                private _sameSubSector = (_startSubSector isEqualTo _goalSubSector);
                if (_sameSubSector) then {
                    _result = [_goalSubSector select 2];
                    _jobComplete = true;
                    breakto "main";
                };
                _initComplete = true;
                _jobDataFlags set [0,_initComplete];

            };

            // Destination-only failures cannot be repaired by another approach.
            // Preserve unrestricted air and same-cell behavior. Do not infer a
            // destination failure from slope or water-span checks on one edge.
            private _goalCaps = _procedure select 1;
            private _invalidGoal = false;
            if (!(_goalCaps select 4) && {!((_startSubSector select 0) isEqualTo (_goalSubSector select 0))}) then {
                _invalidGoal = if (_goalCaps select 0) then {
                    (((_goalSubSector select 4) select 1) select 2)
                        < (ALiVE_pathfinding_seaLevel - ALiVE_pathfinding_waterMargin)
                } else {
                    (_goalCaps select 3) && {!(_goalCaps select 1)} && {!(_goalCaps select 2)}
                        && {(_goalSubSector select 3) == "LAND"}
                };
            };
            if (_invalidGoal) exitWith {
                if (!_layer1Complete) then {
                    _layer1Complete = true;
                    _jobDataFlags set [1, true];
                };
                [_logic,"beginLayerPath", [2, _startSubSector, ((_layer2 select 4) select 1), _layer2 select 0, _layer2 select 3, _subSectorSize, true]] call MAINCLASS;
                breakTo "main";
            };

            ////// LAYER 1 PATHFINDING
            // Coarse search resumes from its saved frontier after three expansions.
            private _sectorIterations = 0;

            while {!(_layer1Complete) && _sectorIterations < 3} do {
                PROFILE_SCOPE(PFCOARSE, "ALiVE pathfinder: coarse expansion")
                _sectorIterations = _sectorIterations + 1;
                _layer1 params ["_cameFromMapLayer1", "_costSoFarMapLayer1", "_frontierLayer1", "_pathLayer1", "_closestSector"];

                private _currentSector = [_frontierLayer1, _costSoFarMapLayer1] call ALiVE_fnc_pathfinderPriorityPullFresh;
                if (isNil "_currentSector") exitWith {
                    // Filtering consumed the last queued entries because every one
                    // had already been superseded by a cheaper route.
                    [_logic,"beginLayerPath", [1, _startSector, (_closestSector select 1), _cameFromMapLayer1, _pathLayer1, _sectorSize, false]] call MAINCLASS;
                    breakTo "main";
                };
                _currentSector params ["_indxCS", "_posCS", "_centerPosCS", "_typeCS", "_modifiersCS"];
                private _currentCost = _costSoFarMapLayer1 get _indxCS;


                if ((_currentSector select 0) isequalto (_goalSector select 0)) exitwith {
                    [_logic,"beginLayerPath", [1, _startSector, _goalSector ,_cameFromMapLayer1, _pathLayer1, _sectorSize, false]] call MAINCLASS;
                    breakto "main";
                };

                private _currentDistanceToGoal = _centerPosCS distance (_goalSector select 2);
                if (_currentDistanceToGoal < (_closestSector select 0)) then {
                    _closestSector set [0, _currentDistanceToGoal];
                    _closestSector set [1, _currentSector];
                };
                {
                    private _neighSector = _x;

                    private _centerPos = _neighSector select 2;
                    private _distanceToGoal = _centerPos distance (_goalSector select 2);
                    private _moveCost = [_currentSector, _neighSector, _sectorSize] call ALiVE_fnc_pathfinderGetMovementCost;
                    private _knownCost = _costSoFarMapLayer1 get (_neighSector select 0);
                    private _baseCostCanImprove = isNil "_knownCost" || {_currentCost + _moveCost < _knownCost};
                    private _mustCheckTraversal =
                        _neighSector isEqualTo _goalSector
                        || {_distanceToGoal > (_closestSector select 0) * 5};
                    if (
                        _mustCheckTraversal
                        || {_airsideCanDiscount}
                        || {_baseCostCanImprove}
                    ) then {
                        // Only finalize candidates that survived the cheap base-cost filter.
                        // Mandatory goal/failure traversal checks still run without improvement.
                        if (_airsideActive && {_baseCostCanImprove || {_airsideCanDiscount}}) then {
                            // Classified cells need only the cached flag and current weight.
                            // Keep first-time classification in the helper.
                            if (count _neighSector > 5) then {
                                if (_neighSector select 5) then {
                                    _moveCost = _moveCost * ALiVE_pathfinding_airsideWeight;
                                };
                            } else {
                                _moveCost = [_neighSector, _sectorSize, _moveCost] call ALiVE_fnc_pathfinderGetFinalMovementCost;
                            };
                        };
                        private _newCostSoFar = _moveCost + _currentCost;
                        private _finalCostCanImprove = isNil "_knownCost" || {_newCostSoFar < _knownCost};
                        private _traversal = 0;
                        if (_mustCheckTraversal || {_finalCostCanImprove}) then {
                            _traversal = [_procedure, _neighSector, _currentSector, _sectorSize, _sectorWaterEdgeCache] call ALiVE_fnc_pathfinderCanTraverse;
                        };
                        if (_traversal > 0) then {
                            if (_finalCostCanImprove) then {
                                private _heuristicParams = [_neighSector,_currentSector,_procedure, _distanceToGoal,_sectorSize,_traversal == 2];
                                [_cameFromMapLayer1, _costSoFarMapLayer1, _frontierLayer1, _neighSector, _currentSector, _distanceToGoal, _heuristicParams, _moveCost, false, _newCostSoFar] call ALiVE_fnc_pathfinderSetNode;
                            };
                            if (_distanceToGoal > (_closestSector select 0)*5) exitwith {
                                // Unable to complete path to goal
                                [_logic,"beginLayerPath", [1, _startSector, (_closestSector select 1),_cameFromMapLayer1, _pathLayer1, _sectorSize, false]] call MAINCLASS;
                                breakto "main";
                            };
                        };
                        // A rejected edge into the goal does not rule out other approaches.
                    };
                } foreach ([_terrainGrid, "getNeighborSectors", _indxCS] call Alive_fnc_pathfindingGrid);

                if (count _frontierLayer1 == 0) exitwith {
                    // Unable to complete path to goal
                    [_logic,"beginLayerPath", [1, _startSector, (_closestSector select 1) ,_cameFromMapLayer1, _pathLayer1, _sectorSize, false]] call MAINCLASS;
                    breakto "main";
                };
            };

            // Yield between complete expansions; never interrupt an edge update.
            // At least one expansion avoids starvation when diag_tickTime has
            // coarse precision at long uptime. The existing work cap also bounds
            // frames where the timer does not advance. Zero disables the budget.
            private _fineBudgetMs = missionNamespace getVariable ["ALiVE_pathfinding_fineBudgetMs", 3];
            if !(_fineBudgetMs isEqualType 0) then {_fineBudgetMs = 3};
            // Request-local evidence. Refresh if procedure/water settings change.
            // Collect failed incoming edges during traversal.
            private _goalEvidenceKey = [_procedure, ALiVE_pathfinding_seaLevel, ALiVE_pathfinding_waterMargin];
            private _goalEvidence = _layer2 param [6, []];
            if (_goalEvidence isEqualTo [] || {!((_goalEvidence select 0) isEqualTo _goalEvidenceKey)}) then {
                _goalEvidence = [+_goalEvidenceKey, [], []];
                _layer2 set [6, _goalEvidence];
            };
            private _fineBudgetStarted = diag_tickTime;
            private _fineExpansionsThisFrame = 0;
            while {
                (_layer1Complete) && {!(_layer2Complete)} && {_sectorIterations < 6}
                && {
                    _fineExpansionsThisFrame == 0
                    || {_fineBudgetMs <= 0}
                    || {1000 * (diag_tickTime - _fineBudgetStarted) < _fineBudgetMs}
                }
            } do {
                _fineExpansionsThisFrame = _fineExpansionsThisFrame + 1;
                PROFILE_SCOPE(PFFINE, "ALiVE pathfinder: fine expansion")
                _sectorIterations = _sectorIterations + 1;
                _layer2 params ["_cameFromMapLayer2", "_costSoFarMapLayer2", "_frontierLayer2", "_pathLayer2", "_closestSubSector", "_itersSinceClosest"];
                _layer2 set [5, _itersSinceClosest + 1];
                private _pathLayer1 = _layer1 select 3;
                private _currentSubSector = [_frontierLayer2, _costSoFarMapLayer2] call ALiVE_fnc_pathfinderPriorityPullFresh;
                if (isNil "_currentSubSector") exitWith {
                    [_logic,"beginLayerPath", [2, _startSubSector, (_closestSubSector select 1), _cameFromMapLayer2, _pathLayer2, _subSectorSize, true]] call MAINCLASS;
                    breakTo "main";
                };
                _currentSubSector params ["_indxCS", "_posCS", "_centerPosCS", "_typeCS", "_modifiersCS"];
                private _currentCost = _costSoFarMapLayer2 get _indxCS;


                if ((_currentSubSector select 0) isequalto (_goalSubSector select 0)) exitwith {
                    [_logic,"beginLayerPath", [2, _startSubSector, _goalSubSector ,_cameFromMapLayer2, _pathLayer2, _subSectorSize, false]] call MAINCLASS;
                    breakto "main";
                };

                private _currentDistanceToGoal = _centerPosCS distance (_goalSubSector select 2);
                if (_currentDistanceToGoal < (_closestSubSector select 0)) then {
                    _closestSubSector set [0, _currentDistanceToGoal];
                    _closestSubSector set [1, _currentSubSector];
                    _itersSinceClosest = 0;
                    _layer2 set [5,0];
                };
                
                if ((count _pathLayer1 > 0) && ((_centerPosCS distance (_pathLayer1 select 0)) < _sectorSize)) then {
                    _pathLayer1 deleteat 0;
                    _layer1 set [5, -1];
                };

                // Cache the route tail across expansions and frames in this job.
                // Recompute lazily after coarse reconstruction or waypoint removal,
                // using forward summation order. Any edit
                // to coarse waypoint positions must also invalidate layer1 slot 5.
                private _pathLayer1Count = count _pathLayer1;
                private _pathLayer1First = if (_pathLayer1Count > 0) then { _pathLayer1 select 0 } else { [] };
                private _pathLayer1TailDistance = _layer1 param [5, -1];
                private _pathLayer1TailReady = _pathLayer1TailDistance >= 0;

                // Base distances depend only on immutable grid topology and size.
                // Clear this cache with subSectorNeighborCache if either changes.
                private _neighborCostCache = _terrainGrid get "subSectorNeighborCostCache";
                if (isNil "_neighborCostCache") then {
                    _neighborCostCache = createHashMap;
                    _terrainGrid set ["subSectorNeighborCostCache", _neighborCostCache];
                };
                private _fineNeighborData = _neighborCostCache get _indxCS;
                if (isNil "_fineNeighborData") then {
                    private _neighbors = [_terrainGrid, "getNeighborSubSectors", _indxCS] call Alive_fnc_pathfindingGrid;
                    private _ix = _indxCS select 0;
                    private _iy = _indxCS select 1;
                    private _costs = _neighbors apply {
                        private _index = _x select 0;
                        if (_ix != (_index select 0) && {_iy != (_index select 1)}) then {
                            1.414 * _subSectorSize
                        } else {
                            1.0 * _subSectorSize
                        }
                    };
                    _fineNeighborData = [_neighbors, _costs];
                    _neighborCostCache set [_indxCS, _fineNeighborData];
                };
                _fineNeighborData params ["_fineNeighbors", "_fineNeighborCosts"];
                {
                    private _neighSubSector = _x;
                    if (isNil "_neighSubSector") exitwith {};

                    private _centerPos = _neighSubSector select 2;
                    private _isGoalNeighbor = (_neighSubSector select 0) isEqualTo (_goalSubSector select 0);
                    private _moveCost = _fineNeighborCosts select _forEachIndex;
                    private _knownCost = _costSoFarMapLayer2 get (_neighSubSector select 0);
                    private _baseCostCanImprove = isNil "_knownCost" || {_currentCost + _moveCost < _knownCost};
                    private _mustCheckTraversal =
                        _isGoalNeighbor
                        || {_itersSinceClosest > 500};
                    if (
                        _mustCheckTraversal
                        || {_airsideCanDiscount}
                        || {_baseCostCanImprove}
                    ) then {
                        // Only finalize candidates that survived the cheap base-cost filter.
                        // Mandatory goal/failure traversal checks still run without improvement.
                        if (_airsideActive && {_baseCostCanImprove || {_airsideCanDiscount}}) then {
                            // Classified cells need only the cached flag and current weight.
                            // Keep first-time classification in the helper.
                            if (count _neighSubSector > 5) then {
                                if (_neighSubSector select 5) then {
                                    _moveCost = _moveCost * ALiVE_pathfinding_airsideWeight;
                                };
                            } else {
                                _moveCost = [_neighSubSector, _subSectorSize, _moveCost] call ALiVE_fnc_pathfinderGetFinalMovementCost;
                            };
                        };
                        private _newCostSoFar = _moveCost + _currentCost;
                        private _finalCostCanImprove = isNil "_knownCost" || {_newCostSoFar < _knownCost};
                        private _traversal = 0;
                        if (_mustCheckTraversal || {_finalCostCanImprove}) then {
                            _traversal = [_procedure, _neighSubSector, _currentSubSector, _subSectorSize, _subSectorWaterEdgeCache] call ALiVE_fnc_pathfinderCanTraverse;
                        };

                        if (_traversal > 0) then {
                            if (_isGoalNeighbor) then {
                                private _failedApproaches = _goalEvidence select 2;
                                private _failedIndex = _failedApproaches find _indxCS;
                                if (_failedIndex >= 0) then {_failedApproaches deleteAt _failedIndex};
                            };
                            if (_finalCostCanImprove) then {
                                private "_distanceToGoal";
                                // The destination has no remaining journey, even while coarse
                                // guidance still contains waypoints beyond this valid approach.
                                if (_isGoalNeighbor) then {
                                    _distanceToGoal = 0;
                                } else {
                                    if (_pathLayer1Count > 0) then {
                                        if (!_pathLayer1TailReady) then {
                                            PROFILE_SCOPE(PFTAIL, "ALiVE pathfinder: recompute route tail")
                                            _pathLayer1TailDistance = 0;
                                            private _i = 1;
                                            while {_i < _pathLayer1Count} do {
                                                _pathLayer1TailDistance = _pathLayer1TailDistance
                                                    + ((_pathLayer1 select (_i - 1)) distance (_pathLayer1 select _i));
                                                _i = _i + 1;
                                            };
                                            _layer1 set [5, _pathLayer1TailDistance];
                                            _pathLayer1TailReady = true;
                                        };
                                        _distanceToGoal = (_centerPos distance _pathLayer1First) + _pathLayer1TailDistance;
                                    } else {
                                        _distanceToGoal = _centerPos distance (_goalSubSector select 2);
                                    };
                                };
                                // Internal insertion: traversal and strict cost improvement have
                                // already passed. Insertion uses the same priority and write order as SetNode.
                                private _priority = [_neighSubSector,_currentSubSector,_procedure,_distanceToGoal,_subSectorSize,_traversal == 2] call ALiVE_fnc_pathfinderHeuristic;
                                private _neighborIndex = _neighSubSector select 0;
                                _costSoFarMapLayer2 set [_neighborIndex, _newCostSoFar];
                                [_frontierLayer2, _distanceToGoal + _priority + _moveCost, _neighSubSector, _newCostSoFar] call ALiVE_fnc_pathfinderPriorityAdd;
                                _cameFromMapLayer2 set [_neighborIndex, _currentSubSector];
                            };
                            if (/*(_distanceToGoal > (_closestSubSector select 0)*4) ||*/ (_itersSinceClosest > 500)) exitwith {
                                // Unable to complete path to goal - spent too much time looking
                                [_logic,"beginLayerPath", [2, _startSubSector, (_closestSubSector select 1),_cameFromMapLayer2, _pathLayer2, _subSectorSize, true]] call MAINCLASS;
                                breakto "main";
                            };
                        };
                        // Only an actual traversal rejection counts as evidence.
                        if (_isGoalNeighbor && {_traversal == 0}) then {
                            private _goalIncoming = _goalEvidence select 1;
                            if (_goalIncoming isEqualTo []) then {
                                _goalIncoming = ([_terrainGrid, "getNeighborSubSectors", _goalSubSector select 0] call ALiVE_fnc_pathfindingGrid) apply {+(_x select 0)};
                                _goalEvidence set [1, _goalIncoming];
                            };
                            private _failedApproaches = _goalEvidence select 2;
                            if (_indxCS in _goalIncoming) then {_failedApproaches pushBackUnique (+_indxCS)};
                            if (count _goalIncoming > 0 && {count _failedApproaches == count _goalIncoming}) exitWith {
                                [_logic,"beginLayerPath", [2, _startSubSector, (_closestSubSector select 1), _cameFromMapLayer2, _pathLayer2, _subSectorSize, true]] call MAINCLASS;
                                breakTo "main";
                            };
                        };
                    };
                } foreach _fineNeighbors;

                if (count _frontierLayer2 == 0) exitwith {
                    // Unable to complete path to goal - ran out of sectors to check
                    [_logic,"beginLayerPath", [2, _startSubSector, (_closestSubSector select 1), _cameFromMapLayer2, _pathLayer2, _subSectorSize, true]] call MAINCLASS;
                    breakto "main";
                };
            };
        };


        if (_layer1Complete && _layer2Complete) then {
            _jobComplete = true;
            _result = _layer2 select 3;
        };

        if (_jobComplete) then {
            PROFILE_SCOPE(PFFINISH, "ALiVE pathfinder: finish job")
            if (isNil {_result select 0;}) then {["Error - Undefined value in path: %1 \n%2", _layer2, _result] call Alive_fnc_Dump;};

            // Optional debug draw of the final computed route (gated by the
            // "Draw Paths" toggle - Eden param ALiVE_sys_profile_pathfindingDrawPaths
            // or the live admin-menu toggle, both set the global below). Off by
            // default = zero cost (the flag short-circuits before any marker is
            // made). Each path's markers are tagged with a per-call id so the next
            // draw doesn't collide.
            // Only draw/log actual routes (>= 2 nodes). A 1-node "path" means start
            // and goal share a subsector (len 0) - drawing it leaves an orphaned dot
            // with no line, and it's the bulk of completed paths (log noise too).
            if (missionNamespace getVariable ["ALiVE_pathfinding_drawPaths", false] && {_result isEqualType []} && {count _result > 1}) then {
                PROFILE_SCOPE(PFDRAW, "ALiVE pathfinder: draw route")
                private _pathMarkers = _logic get "pathDrawMarkers";
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
                _logic set ["pathDrawMarkers", _pathMarkers];
            };

            PROFILE_SCOPE(PFCALLBACK, "ALiVE pathfinder: callback dispatch")
            [_callbackArgs,_result] spawn _callback;
            PROFILE_SCOPE_END(PFCALLBACK)

            // remove job from queue and clean up the mess we made. The cost /
            // came-from HashMaps are released by garbage collection once the job
            // data holding them is cleared below - no explicit delete needed
            // (unlike the CBA namespaces these replaced).
            PROFILE_SCOPE(PFCLEANUP, "ALiVE pathfinder: release completed job")
            _pathJobs deleteat 0;
            _currentJobData resize 0;
            _currentJob resize 0;
            PROFILE_SCOPE_END(PFCLEANUP)
            // {deleteMarker _x} foreach _debugMarkers;
            // _debugMarkers resize 0;
            // load next job data
            [_logic,"loadCurrentJobData"] call MAINCLASS;
        };

        _currentJobData set [0,false];
    };

};

PROFILE_SCOPE_END(PFOPERATION)

if (isnil "_result") then {nil} else {_result};
