#define MAINCLASS alive_fnc_pathfinder

params [
    ["_logic", nil],
    ["_operation", ""],
    ["_args", objNull]
];

private "_result";

switch (_operation) do {

    case "create": {

        private _terrainGrid = [nil,"create", [300]] call ALiVE_fnc_pathfindingGrid;

        _logic = [[
            ["terrainGrid", _terrainGrid],
            ["pathfindingProcedures", [] call ALiVE_fnc_hashCreate],
            ["pathDebugMarkers", []],
            ["pathJobs", []],
            ["currentJobData", []]
        ]] call ALiVE_fnc_hashCreate;

        [_logic,"addPathfindingProcedure", ["infantry", true, false, -1.25, 0]] call MAINCLASS;
        [_logic,"addPathfindingProcedure", ["vehicleLand", true, false, -6, 0]] call MAINCLASS;
        [_logic,"addPathfindingProcedure", ["vehicleWater", false, true, 0, 0]] call MAINCLASS;
        [_logic,"addPathfindingProcedure", ["vehicleAir", true, true, 0, 0]] call MAINCLASS;

        addMissionEventHandler ["EachFrame", {
            [ALiVE_pathfinder,"onFrame"] call ALiVE_fnc_pathfinder;
        }];

        _result = _logic;

    };

    case "addPathfindingProcedure": {

        _args params [
            "_name",
            ["_canUseLand", true],
            ["_canUseWater", true],
            ["_roadWeight", 1],
            ["_waterWeight", 0]
        ];

        _procedures = [_logic,"pathfindingProcedures"] call ALiVE_fnc_hashGet;

        [_procedures,_name, _args] call ALiVE_fnc_hashSet;

    };

    case "heuristic": {

        _args params ["_currentSector","_goalSector","_procedure"];

        private _dx = abs(((_currentSector select 0) select 0) - ((_goalSector select 0) select 0));
        private _dy = abs(((_currentSector select 0) select 1) - ((_goalSector select 0) select 1));

        _result = _dx + _dy;

        // road weighting

        private _sectorHasRoads = _currentSector select 2;
        if (_sectorHasRoads) then {
            _result = _result + (_procedure select 3);
        };

        // water weighting

        private _sectorIsLand = _currentSector select 3;
        if !(_sectorIsLand) then {
            _result = _result + (_procedure select 4);
        };

    };

    case "getMovementCost": {

        _args params ["_currentSector","_goalSector","_procedure"];

        if (
            ((_currentSector select 0) select 0) != ((_goalSector select 0) select 0) &&
            { ((_currentSector select 0) select 1) != ((_goalSector select 0) select 1) }
        ) then {
            //_result = 1.414;
            _result = 1.3;
        } else {
            _result = 1;
        };

    };

    case "reconstructPath": {

        _args params ["_startSector","_goalSector","_cameFromMap"];

        private _path = [];
        private _currentSector = _goalSector;

        while { !((_currentSector select 0) isequalto (_startSector select 0)) } do {
            _path pushback (_currentSector select 1);
            _currentSector = [_cameFromMap,_currentSector select 0] call ALiVE_fnc_hashGet;
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

    case "consolidatePath": {

        _path = _args;

        if (count _path <= 3) exitwith { _result = _path };

        private _shortPath = [_path select 0];
        private _currDir = (_path select 0) getDir (_path select 1);

        for "_i" from 1 to (count _path - 1) do {
            private _currSector = _path select _i;
            private _tempDir = (_path select (_i - 1)) getdir _currSector;

            if ((abs (_tempDir - _currDir)) > 15 && _i > 1) then {
                _shortPath pushback (_path select (_i - 1));
                _currDir = _tempDir;
            };
        };

        private _lastPositionIndex = count _path - 1;
        _shortPath pushbackunique (_path select _lastPositionIndex);

        _result = _shortPath;

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
            private _procedure = [_procedures,_procedureName, "landVehicle"] call ALiVE_fnc_hashGet;

            private _cameFromMap = [] call ALiVE_fnc_hashCreate;
            private _costSoFarMap = [] call ALiVE_fnc_hashCreate;

            private _frontier = [[0,_startSector]];
            [_costSoFarMap,_startSector select 0, 0] call ALiVE_fnc_hashSet;

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

            // only check 5 sectors per frame
            private _sectorIterations = 0;

            while {!(_frontier isequalto []) && _sectorIterations < 2} do {
                _sectorIterations = _sectorIterations + 1;
                private _currentSector = [nil,"priorityGet", _frontier] call MAINCLASS;

                //////////////////////////////////////////////////
                //private _sectorCenter = _currentSector select 1;
                //_m = createMarker [str str str str _sectorCenter, _sectorCenter];
                //_m setMarkerShape "ICON";
                //_m setMarkerType "hd_dot";
                //_m setMarkerSize [0.3,0.3];
                //_m setMarkerColor "ColorBlue";
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
                        _result = [nil,"consolidatePath", _result] call MAINCLASS;
                    };

                    _jobComplete = true;
                    breakto "main";
                };

                // determine which neighbor is the best path
                private _neighbors = [_terrainGrid, "getNeighbors", [_currentSector select 0]] call alive_fnc_pathfindingGrid;
                {
                    private _currNeighbor = _x;
                    private _neighborIsLand = _currNeighbor select 3;
                    private _canTraverse = if (_neighborIsLand) then { _canUseLand } else { _canUseWater };

                    if (_canTraverse) then {
                        private _newCost = ([_costSoFarMap,_currentSector select 0] call ALiVE_fnc_hashGet) + ([nil,"getMovementCost", [_currentSector,_currNeighbor,_procedure]] call MAINCLASS);

                        private _currNeighborCostSoFar = [_costSoFarMap,_currNeighbor select 0] call ALiVE_fnc_hashGet;
                        //if (isnil "_currNeighborCostSoFar" || { _newCost < _currNeighborCostSoFar }) then {
                        if (isnil "_currNeighborCostSoFar") then {
                            [_costSoFarMap,_currNeighbor select 0, _newCost] call ALiVE_fnc_hashSet;
                            private _priority = _newCost + ([nil,"heuristic", [_currNeighbor,_goalSector,_procedure]] call MAINCLASS);
                            [nil,"priorityAdd", [_frontier,_priority,_currNeighbor]] call MAINCLASS;
                            [_cameFromMap,_currNeighbor select 0,_currentSector] call ALiVE_fnc_hashSet;
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

            // remove job from queue
            _pathJobs deleteat 0;

            // load next job data
            [_logic,"loadCurrentJobData"] call MAINCLASS;
        };

    };

    //case "findPath": {
    //
    //    _args params ["_startSector","_goalSector", ["_procedureName", "infantry"], ["_shortenPath", true]];
    //
    //    _result = [];
    //
    //    // detect impossible paths
    //
    //    private _goalSectorIsLand = _goalSector select 3;
    //    private _pathIsPossible = if (_goalSectorIsLand) then { _canUseLand } else { _canUseWater };
    //
    //    if (!_pathIsPossible) exitwith { _result };
    //
    //    private _cameFromMap = [] call ALiVE_fnc_hashCreate;
    //    private _costSoFar = [] call ALiVE_fnc_hashCreate;
    //
    //    private _frontier = [[0,_startSector]];
    //    [_costSoFar,_startSector select 0, 0] call ALiVE_fnc_hashSet;
    //
    //    while {!(_frontier isequalto [])} do {
    //        private _currentSector = [nil,"priorityGet", _frontier] call MAINCLASS;
    //
    //        //////////////////////////////////////////////////
    //        private _sectorCenter = _currentSector select 1;
    //        _m = createMarker [str str str str _sectorCenter, _sectorCenter];
    //        _m setMarkerShape "ICON";
    //        _m setMarkerType "hd_dot";
    //        _m setMarkerSize [0.3,0.3];
    //        _m setMarkerColor "ColorBlue";
    //        //////////////////////////////////////////////////
    //
    //        if (_currentSector isequalto _goalSector) exitwith { _result = [nil,"reconstructPath", [_startSector,_goalSector,_cameFromMap]] call MAINCLASS };
    //
    //        // determine which neighbor is the best path
    //        private _neighbors = [_terrainGrid, "getNeighbors", [_currentSector select 0]] call alive_fnc_pathfindingGrid;
    //        {
    //            private _currNeighbor = _x;
    //            private _neighborIsLand = _currNeighbor select 3;
    //            private _canTraverse = if (_neighborIsLand) then { _canUseLand } else { _canUseWater };
    //
    //            if (_canTraverse) then {
    //                private _newCost = ([_costSoFar,_currentSector select 0] call ALiVE_fnc_hashGet) + ([nil,"getMovementCost", [_currentSector,_currNeighbor,_procedure]] call MAINCLASS);
    //
    //                private _currNeighborCostSoFar = [_costSoFar,_currNeighbor select 0] call ALiVE_fnc_hashGet;
    //                //if (isnil "_currNeighborCostSoFar" || { _newCost < _currNeighborCostSoFar }) then {
    //                if (isnil "_currNeighborCostSoFar") then {
    //                    [_costSoFar,_currNeighbor select 0, _newCost] call ALiVE_fnc_hashSet;
    //                    //private _priority = _newCost + ([nil,"heuristic", [_currNeighbor,_goalSector,_procedure]] call s_fnc_pathfinder);
    //                    private _priority = _newCost + ([nil,"heuristic", [_currNeighbor,_goalSector,_procedure]] call MAINCLASS);
    //                    [nil,"priorityAdd", [_frontier,_priority,_currNeighbor]] call MAINCLASS;
    //                    [_cameFromMap,_currNeighbor select 0,_currentSector] call ALiVE_fnc_hashSet;
    //                };
    //            };
    //        } foreach _neighbors;
    //    };
    //
    //    if (_shortenPath) then {
    //        _result = [nil,"consolidatePath", _result] call MAINCLASS;
    //    };
    //
    //};

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