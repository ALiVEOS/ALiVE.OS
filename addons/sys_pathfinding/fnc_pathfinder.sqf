#define MAINCLASS alive_fnc_pathfinder

params [
    ["_logic", nil],
    ["_operation", ""],
    ["_args", objNull]
];

private "_result";

switch (_operation) do {

    case "create": {

        private _worldSize = [ALiVE_mapBounds,worldname, worldsize] call ALiVE_fnc_hashGet;
        private _sectorSize = 100 max (ceil (_worldSize / 110));
        private _terrainGrid = [nil,"create", [_sectorSize]] call ALiVE_fnc_pathfindingGrid;

        _logic = [[
            ["terrainGrid", _terrainGrid],
            ["procedures", [] call ALiVE_fnc_hashCreate],
            ["currentJobData", []],
            ["pathJobs", []],
            ["pathDebugMarkers", []]
        ]] call ALiVE_fnc_hashCreate;

        // terrain types [land,road,water]

        [_logic,"addProcedure", ["infantry", ["land","road"], [1,1,1]]] call MAINCLASS;
        [_logic,"addProcedure", ["vehicleLand", ["land","road"], [15,1,1]]] call MAINCLASS;
        [_logic,"addProcedure", ["vehicleWater", ["water"], [1,1,1]]] call MAINCLASS;
        [_logic,"addProcedure", ["vehicleAir", ["land","road","water"], [0,0,0]]] call MAINCLASS;

        addMissionEventHandler ["EachFrame", {
            [ALiVE_pathfinder,"onFrame"] call ALiVE_fnc_pathfinder;
        }];

        _result = _logic;

    };

    case "addProcedure": {

        _args params ["_name","_passableTerrains","_weightings"];

        private _procedures = [_logic,"procedures"] call ALiVE_fnc_hashGet;

        [_procedures,_name, [_passableTerrains,_weightings]] call ALiVE_fnc_hashSet;

    };

    case "heuristic": {

        _args params ["_currentSector","_goalSector","_procedure"];

        private _currentSectorCoords = _currentSector select 0;
        private _goalSectorCoords = _goalSector select 0;

        private _dx = abs ((_currentSectorCoords select 0) - (_goalSectorCoords select 0));
        private _dy = abs ((_currentSectorCoords select 1) - (_goalSectorCoords select 1));

        // non diagonal path distance + distance saved if using diagonals
        //_result = 1 * (_dx + _dy) + (1.414 - 2 * 1) * (_dx min _dy);
        _result = (_dx + _dy) + ((-0.586) * (_dx min _dy));

        // tie breaker
        // the higher we go the more we search nodes closer to the end position
        _result = _result * 5;

    };

    case "getMovementCost": {

        _args params ["_currentSector","_goalSector","_procedure"];

        _result = 1;

        //if (
        //    ((_currentSector select 0) select 0) != ((_goalSector select 0) select 0) &&
        //    { ((_currentSector select 0) select 1) != ((_goalSector select 0) select 1) }
        //) then {
        //    _result = 1.414;
        //    //_result = 1.3;
        //} else {
        //    _result = 1;
        //};

        if ((_procedure select 0) == "vehicleLand") then {
            private _sectorHasRoads = _currentSector select 2;
            if (_sectorHasRoads) then {
                _result = _result + 1;
            } else {
                _result = _result + 15;
            };
        };

    };

    case "reconstructPath": {

        _args params ["_startSector","_goalSector","_cameFromMap"];

        private _path = [];
        private _currentSector = _goalSector;

        while { !((_currentSector select 0) isequalto (_startSector select 0)) } do {
            _path pushback (_currentSector select 1);
            _currentSector = _cameFromMap getvariable (str(_currentSector select 0));
        };

        _path pushback (_startSector select 1);

        reverse _path;

        _result = _path;

    };

    case "randomizePathPositions": {

        private _positions = _args;

        private _pathfindingTerrainGrid = [ALiVE_pathfinder,"terrainGrid"] call ALiVE_fnc_hashGet;
        private _pathfindingSectorSize = [_pathfindingTerrainGrid,"sectorSize"] call ALiVE_fnc_hashGet;

        private _varianceMin = _pathfindingSectorSize * 0.3;
        private _varianceMax = _varianceMin * 2;

        // dont modify ending position
        private _lastPosition = _positions deleteat (count _positions - 1);
        _result = _positions apply {
            [
                ((_x select 0) - _varianceMin) + (random _varianceMax),
                ((_x select 1) - _varianceMin) + (random _varianceMax)
            ]
        };
        _result pushback _lastPosition;

    };

    // string pull
    case "straightenPath": {

        _args params ["_path","_procedure"];

        private _terrainGrid = [_logic,"terrainGrid"] call ALiVE_fnc_hashGet;

        private _i = 0;
        while { count _path > _i + 2 } do {
            private _pos1 = _path select _i;
            private _pos2 = _path select (_i + 2);

            private _sectorsBetween = [_logic,"raycast", [_pos1,_pos2]] call MAINCLASS;
            private _directPath = [_logic,"pathIsPassible", [_sectorsBetween,_procedure]] call MAINCLASS;

            if (count _path < 10) then { copyToClipboard str (_sectorsBetween) };

            if (_directPath) then {
                _path deleteat (_i + 1);
            } else {
                _i = _i + 1;
            };
        };

        _result = _path;

    };

    // remove sectors directly next to eachother
    // ignore diagonals
    case "consolidatePath": {

        _path = _args;

        if (count _path <= 3) exitwith { _result = _path };

        private _terrainGrid = [ALiVE_pathfinder,"terrainGrid"] call ALiVE_fnc_hashGet;
        private _sectorSize = [_terrainGrid,"sectorSize"] call ALiVE_fnc_hashGet;

        private _i = 0;
        while {_i < count _path - 2} do {
            private _currSectorPos = _path select _i;
            private _nextSectorPos = _path select (_i + 1);

            private _dist = _currSectorPos distance2D _nextSectorPos;

            if ((_dist / _sectorSize) == 1) then {
                _path deleteat (_i + 1);
            } else {
                _i = _i + 1;
            };
        };

        _result = _path;

    };

    case "priorityAdd": {
        _args params ["_queue","_priority","_item"];

        private _queueSize = count _queue;
        private _i = 0;
        while {_i < _queueSize - 1 && { _priority <= ((_queue select _i) select 0) }} do {
            _i = _i + 1;
        };

        // move all elements after new item position to temp arrayIntersect
        // insert new item
        // append temp array to queue

        private _tempArr = _queue select [_i, _queueSize - _i];
        _queue deleterange [_i, _queueSize - _i];
        _queue pushback [_priority,_item];
        _queue append _tempArr;
    };

    case "priorityGet": {
        private _queue = _args;

        private _queueSize = count _queue;
        if (_queueSize > 0) then {
            _result = (_queue deleteat _queueSize - 1) select 1;
        };
    };

    case "findPath": {

        _args params ["_startPos","_endPos","_procedureName","_shortenPath","_randomizeWaypointRadius","_callbackArgs","_callback"];

        private _terrainGrid = [_logic,"terrainGrid"] call ALiVE_fnc_hashGet;
        private _pathJobs = [_logic,"pathJobs"] call ALiVE_fnc_hashGet;

        private _startSector = [_terrainGrid,"positionToSector", _startPos] call ALiVE_fnc_pathfindingGrid;
        private _goalSector = [_terrainGrid,"positionToSector", _endPos] call ALiVE_fnc_pathfindingGrid;

        private _newJob = [_startSector,_goalSector,_endPos,_procedureName,_shortenPath,_randomizeWaypointRadius,_callbackArgs,_callback];
        _pathJobs pushback _newJob;

        if (count _pathJobs == 1) then {
            [_logic,"loadCurrentJobData"] call MAINCLASS;
        };

    };

    case "loadCurrentJobData": {

        private _pathJobs = [_logic,"pathJobs"] call ALiVE_fnc_hashGet;

        // load next job data
        if (count _pathJobs > 0) then {
            private _nextJob = _pathJobs select 0;
            _nextJob params ["_startSector","_goalSector","_goalPosition","_procedureName","_shortenPath","_randomizeWaypointRadius","_callbackArgs","_callback"];

            private _procedures = [_logic,"pathfindingProcedures"] call ALiVE_fnc_hashGet;
            private _procedure = [_procedures,_procedureName] call ALiVE_fnc_hashGet;

            private _cameFromMap = call CBA_fnc_createNamespace;
            private _costSoFarMap = call CBA_fnc_createNamespace;

            private _frontier = [[0,_startSector]];
            _costSoFarMap setvariable [str(_startSector select 0),0];

            _currentJobData = [false, _procedure, _cameFromMap, _costSoFarMap, _frontier];
            [_logic,"currentJobData", _currentJobData] call ALiVE_fnc_hashSet;
        } else {
            [_logic,"currentJobData", []] call ALiVE_fnc_hashSet;
        };

    };

    case "onFrame": {
        private _pathJobs = [_logic,"pathJobs"] call ALiVE_fnc_hashGet;

        if (count _pathJobs == 0) exitwith {};

        private _currentJob = _pathJobs select 0;
        private _currentJobData = [_logic,"currentJobData"] call ALiVE_fnc_hashGet;

        _currentJob params ["_startSector","_goalSector","_goalPosition","_procedureName","_shortenPath","_randomizeWaypointRadius","_callbackArgs","_callback"];
        _currentJobData params ["_initComplete","_procedure", "_cameFromMap","_costSoFarMap","_frontier"];

        _procedure params ["_procName","_canUseLand","_canUseWater","_roadWeight","_waterWeight"];

        private _terrainGrid = [_logic,"terrainGrid"] call ALiVE_fnc_hashGet;
        _result = [];
        private _jobComplete = false;

        scopename "main";

        call {

            if (!_initComplete) then {
                // check for impossible paths
                private _goalSectorIsLand = _goalSector select 3;
                private _pathIsPossible = if (_goalSectorIsLand) then { _canUseLand } else { _canUseWater };
                if (!_pathIsPossible) then {
                    _jobComplete = true;
                    breakto "main";
                };

                // check for non-bias procedure
                private _nonBiasProcedure = _canUseWater && { _canUseLand } && { _roadWeight == 0 } && { _waterWeight == 0 };
                if (_nonBiasProcedure) then {
                    _result = [_goalPosition];
                    _jobComplete = true;
                    breakto "main";
                };

                _currentJobData set [0,true];
            };

            // only check 2 sectors per frame
            private _sectorIterations = 0;

            while {!(_frontier isequalto []) && _sectorIterations < 2} do {
                _sectorIterations = _sectorIterations + 1;
                private _currentSector = [nil,"priorityGet", _frontier] call MAINCLASS;

                //////////////////////////////////////////////////
                private _sectorCenter = _currentSector select 1;
                _m = createMarker [str str str str _sectorCenter, _sectorCenter];
                _m setMarkerShape "ICON";
                _m setMarkerType "hd_dot";
                _m setMarkerSize [0.3,0.3];
                _m setMarkerColor "ColorBlue";
                //////////////////////////////////////////////////

                if (_currentSector isequalto _goalSector) exitwith {
                    _result = [nil,"reconstructPath", [_startSector,_goalSector,_cameFromMap]] call MAINCLASS;

                    if (_randomizeWaypointRadius) then {
                        _result = [nil,"randomizePathPositions", _result] call MAINCLASS;
                    };

                    if (count _result > 1) then {
                        // no need to move to center of sector we're already in
                        _result deleteat 0;
                    };

                    // last path position should be ending pos instead of sector center
                    _result set [count _result - 1, _goalPosition];

                    if (_shortenPath) then {
                        _result = [_logic,"straightenPath", [_result,_procedure]] call MAINCLASS;

                        if ((_procedure select 1)) then {
                            systemchat "consolidating";
                            _result = [_logic,"consolidatePath", _result] call MAINCLASS;
                        };
                    };

                    _jobComplete = true;
                    breakto "main";
                };

                // determine which neighbor is the best path
                private _neighbors = [_terrainGrid, "getNeighbors", [_currentSector select 0]] call alive_fnc_pathfindingGrid;
                private _currentSectorMovementCost = _costSoFarMap getvariable (str(_currentSector select 0));
                {
                    private _currNeighbor = _x;
                    private _neighborIsLand = _currNeighbor select 3;
                    private _canTraverse = if (_neighborIsLand) then { _canUseLand } else { _canUseWater };

                    if (_canTraverse) then {
                        private _neighborCost = [nil,"getMovementCost", [_currentSector,_currNeighbor,_procedure]] call MAINCLASS;
                        private _newCost = _currentSectorMovementCost + _neighborCost;

                        private _currNeighborCostSoFar = _costSoFarMap getvariable (str(_currNeighbor select 0));
                        if (isnil "_currNeighborCostSoFar" || { _newCost < _currNeighborCostSoFar }) then {
                        //if (isnil "_currNeighborCostSoFar") then {
                            _costSoFarMap setvariable [str(_currNeighbor select 0), _newCost];

                            private _neighborHeuristic = [nil,"heuristic", [_currNeighbor,_goalSector,_procedure]] call MAINCLASS;
                            private _priority = _newCost + _neighborHeuristic;
                            [nil,"priorityAdd", [_frontier,_priority,_currNeighbor]] call MAINCLASS;

                            _cameFromMap setvariable [str(_currNeighbor select 0),_currentSector];
                        };
                    };
                } foreach _neighbors;
            };

        };

        // all nodes have been evaluated
        // no path exists
        if (_frontier isequalto []) then {
            _jobComplete = true;
        };

        if (_jobComplete) then {
            [_callbackArgs,_result] spawn _callback;

            systemchat (format ["Nodes Evaluated: %1", count (allvariables _cameFromMap)]);

            // remove job from queue
            _pathJobs deleteat 0;

            // load next job data
            [_logic,"loadCurrentJobData"] call MAINCLASS;
        };

    };

    case "plotLineLow": {

        _args params ["_x1","_y1","_x2","_y2"];

        private _dx = _x2 - _x1;
        private _dy = _y2 - _y1;

        private _yi = 1;
        if (_dy < 0) then {
            _yi = -1;
            _dy = -_dy;
        };

        private _intersected = [];

        private _d = (2 * _dy) - _dx;
        private _y = _y1;
        for "_x" from _x1 to _x2 do {
            _intersected pushback [_x,_y];

            if (_d > 0) then {
                _y = _y + _yi;
                _d = _d - (2 * _dx);
            };

            _d = _d + (2 * _dy);
        };

        _result = _intersected;

    };

    case "plotLineHigh": {

        _args params ["_x1","_y1","_x2","_y2"];

        private _dx = _x2 - _x1;
        private _dy = _y2 - _y1;

        private _xi = 1;
        if (_dx < 0) then {
            _xi = -1;
            _dx = -_dx;
        };

        private _intersected = [];

        private _d = (2 * _dx) - _dy;
        private _x = _x1;
        for "_y" from _y1 to _y2 do {
            _intersected pushback [_x,_y];

            if (_d > 0) then {
                _x = _x + _xi;
                _d = _d - (2 * _dy);
            };

            _d = _d + (2 * _dx);
        };

        _result = _intersected;

    };

    // https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
    case "raycast": {

        _args params ["_startPos","_endPos"];

        private _terrainGrid = [_logic,"terrainGrid"] call ALiVE_fnc_hashGet;
        private _startCoord = [_terrainGrid,"positionToIndex", _startPos] call ALiVE_fnc_pathfindingGrid;
        private _endCoord = [_terrainGrid,"positionToIndex", _endPos] call ALiVE_fnc_pathfindingGrid;

        _startCoord params ["_x1","_y1"];
        _endCoord params ["_x2","_y2"];

        if (abs (_y2 - _y1) < abs (_x2 - _x1)) then {
            if (_x1 > _x2) then {
                _result = [nil,"plotLineLow", [_x2,_y2,_x1,_y1]] call MAINCLASS;
            } else {
                _result = [nil,"plotLineLow", [_x1,_y1,_x2,_y2]] call MAINCLASS;
            };
        } else {
            if (_y1 > _y2) then {
                _result = [nil,"plotLineHigh", [_x2,_y2,_x1,_y1]] call MAINCLASS;
            } else {
                _result = [nil,"plotLineHigh", [_x1,_y1,_x2,_y2]] call MAINCLASS;
            };
        };

        _result = _result apply { [_terrainGrid,"getSector", _x] call ALiVE_fnc_pathfindingGrid };

    };

    case "pathIsPassible": {

        _args params ["_sectors","_procedure"];

        private _canUseLand = _procedure select 1;
        private _canUseWater = _procedure select 2;

        _result = true;

        private _lastSectorTerrain = [(_sectors select 0) select 2, (_sectors select 0) select 3];
        {
            private _isLand = _x select 3;
            private _terrain = [_x select 2, _x select 3];
            private _canTraverse = if (_isLand) then { _canUseLand && { _terrain isequalto _lastSectorTerrain }} else { _canUseWater };

            if (!_canTraverse) exitwith { _result = false };
        } foreach _sectors;

    };

    case "debugPath": {

        _path = _args;

        private _pathDebugMarkers = [_logic,"pathDebugMarkers"] call ALiVE_fnc_hashGet;

        { deletemarker _x } foreach _pathDebugMarkers;

        {
            _sectorCenter = _x;

            _m = createMarker [str str str _sectorCenter, _sectorCenter];
            _m setMarkerShape "ICON";
            _m setMarkerType "hd_dot";
            _m setMarkerSize [0.7,0.7];
            _m setMarkerColor "ColorRed";

            _pathDebugMarkers pushback _m;
        } foreach _path;

    };

};

if (isnil "_result") then {nil} else {_result};