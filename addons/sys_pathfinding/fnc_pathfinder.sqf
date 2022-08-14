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
        private _sectorSize = 125; //ceil (_worldSize / 110);
        private _terrainGrid = [nil,"create", [_sectorSize]] call ALiVE_fnc_pathfindingGrid;

        _logic = [[
            ["terrainGrid", _terrainGrid],
            ["pathfindingProcedures", [] call ALiVE_fnc_hashCreate],
            ["currentJobData", []],
            ["pathJobs", []],
            ["pathDebugMarkers", []]
        ]] call ALiVE_fnc_hashCreate;

        [_logic,"addPathfindingProcedure", ["infantry", true, false, -0.1, 0.75, -3]] call MAINCLASS;
        [_logic,"addPathfindingProcedure", ["vehicleLand", true, false, -0.65, 0, 0]] call MAINCLASS;
        [_logic,"addPathfindingProcedure", ["vehicleWater", false, true, 0, 0, 0]] call MAINCLASS;
        [_logic,"addPathfindingProcedure", ["vehicleAir", true, true, 0, 0, 0]] call MAINCLASS;

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
            ["_roadWeight", 0],
            ["_waterWeight", 0],
            ["_heightWeight", 0]
        ];

        _procedures = [_logic,"pathfindingProcedures"] call ALiVE_fnc_hashGet;

        [_procedures,_name, _args] call ALiVE_fnc_hashSet;

    };

    case "heuristic": {

        _args params ["_currentSector","_goalSector","_procedure","_originSector","_isWaterTravel"];
        _procedure params ["_procName","_canUseLand","_canUseWater","_roadWeight","_waterWeight","_heightWeight"];

        ////////// OLD ///////////////
        //private _dx = abs(((_currentSector select 0) select 0) - ((_goalSector select 0) select 0));
        //private _dy = abs(((_currentSector select 0) select 1) - ((_goalSector select 0) select 1));
        //_result = _dx + _dy;
        //////////////////////////////
        //if (_currentSector isEqualTo _goalSector) exitwith {_result = 0;};

        private _hasBridge = (_currentSector select 5) || (_originSector select 5);
        private _roads = _currentSector select 3;

        // Distance weighting 
        private _distanceToGoal = (_currentSector select 1) distance (_goalSector select 1);
        private _sectorDistance = (_currentSector select 1) distance (_originSector select 1);

        _result = _distanceToGoal;
        // road / bridge weighting
        if (_canUseLand && !(_isWaterTravel)) then {
            if (_hasBridge) then {_result = 0;} else {
                _heightAdjust = ((_originSector select 7)-(_currentSector select 7));
                _result = _result + ( _heightAdjust / _sectorDistance ) * _distanceToGoal * _heightWeight;
                _result = _result + (_distanceToGoal * _roads * _roadWeight); // Adjust for roads and/or bridge
            };
        };

        // water weighting
        if (_canUseWater && _isWaterTravel) then {
            _result = _result + (_distanceToGoal * _waterWeight);
        };

        if (_result < 0) then {player sidechat format["A priority is less then zero %1", _result];};
        // Threat / Danger weight
        // ?? future ??
    };

    case "getMovementCost": {

        _args params ["_currentSector","_goalSector","_procedure"];

        if (
            ((_currentSector select 0) select 0) != ((_goalSector select 0) select 0) &&
            { ((_currentSector select 0) select 1) != ((_goalSector select 0) select 1) }
        ) then {
            _result = 1.414;
            //_result = 1.3;
        } else {
            _result = 1;
        };

    };

    case "reconstructPath": {

        _args params ["_startSector","_goalSector","_cameFromMap","_searchRoads","_onlyWater"];

        private _pathfindingTerrainGrid = [ALiVE_pathfinder,"terrainGrid"] call ALiVE_fnc_hashGet;
        private _pathfindingSectorSize = [_pathfindingTerrainGrid,"sectorSize"] call ALiVE_fnc_hashGet;

        private _path = [];
        private _currentSector = _goalSector;

        while { !((_currentSector select 0) isequalto (_startSector select 0)) || !((_currentSector select 0) isequalto (_goalSector select 0))} do {

            _pos = _currentSector select 2; //use center of sector
            
            private _varianceMin = _pathfindingSectorSize * 0.3;
            private _varianceMax = _varianceMin * 2;

            if (_onlyWater) then {  //Find a point that ensures it's on water deep enough - just use center and hope for the best if none found within 200 tries
                for "_iterations" from 1 to 200 do {
                    _pos = [
                                ((_pos select 0) - _varianceMin) + (random _varianceMax),
                                ((_pos select 1) - _varianceMin) + (random _varianceMax)
                            ]; 
                    if ((getTerrainHeightASL _pos) > -0.5) then { break; };  
                };
            } else {
                //Search for nearest road to center
                if ((_currentSector select 3) > 0) then {
                    _roads = nearestTerrainObjects [_pos, ["MAIN ROAD", "ROAD", "TRAIL"], _pathfindingSectorSize/2, true, true]; //We can find roads now in Arma 3 v2.00
                    if (count _roads > 0) then {_pos = getPos (_roads select 0) select [0,2];};
                } else {  //Get a random land position
                    _pos = [
                                ((_pos select 0) - _varianceMin) + (random _varianceMax),
                                ((_pos select 1) - _varianceMin) + (random _varianceMax)
                            ]; 
                };
            };

            _path pushback _pos; 
            _currentSector = _cameFromMap getvariable (str(_currentSector select 0));
        };

        _path pushback (_startSector select 2); //use center of sector

        reverse _path;

        _result = _path;

    };

    // case "randomizePathPositions": {

    //     private _positions = _args;

    //     private _pathfindingTerrainGrid = [ALiVE_pathfinder,"terrainGrid"] call ALiVE_fnc_hashGet;
    //     private _pathfindingSectorSize = [_pathfindingTerrainGrid,"sectorSize"] call ALiVE_fnc_hashGet;

    //     private _varianceMin = _pathfindingSectorSize * 0.3;
    //     private _varianceMax = _varianceMin * 2;

    //     // dont modify ending position
    //     private _lastPosition = _positions deleteat (count _positions - 1);
    //     _result = _positions apply {
    //         [
    //             ((_x select 0) - _varianceMin) + (random _varianceMax),
    //             ((_x select 1) - _varianceMin) + (random _varianceMax)
    //         ]
    //     };
    //     _result pushback _lastPosition;

    // };

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
        player sidechat format["New Job: %1",_startSector select 0];

                private _sM = [(_startSector select 2) select 0,((_startSector select 2) select 1) - 1];
                _m = createMarker [str str str str _sM, _sM];
                _m setMarkerShape "ICON";
                _m setMarkerType "hd_dot";
                _m setMarkerSize [0.7,0.7];
                _m setMarkerColor "ColorYellow";
                private _gM = [(_goalSector select 2) select 0,((_goalSector select 2) select 1) - 1];
                _m = createMarker [str str str str _gM, _gM];
                _m setMarkerShape "ICON";
                _m setMarkerType "hd_dot";
                _m setMarkerSize [0.7,0.7];
                _m setMarkerColor "ColorPink";

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

            private _cameFromMap = call CBA_fnc_createNamespace;
            private _costSoFarMap = call CBA_fnc_createNamespace;

            private _frontier = [[0,_startSector]];
            _costSoFarMap setvariable [str(_startSector select 0),0];
            Private _debugMarkers = [];//////////////////////
            _currentJobData = [false, _procedure, _cameFromMap, _costSoFarMap, _frontier, _debugMarkers];///////////////
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
        private _debugMarkers = _currentJobData select 5;////////////////////
        _procedure params ["_procName","_canUseLand","_canUseWater","_roadWeight","_waterWeight","_heightWeight"];

        private _terrainGrid = [_logic,"terrainGrid"] call ALiVE_fnc_hashGet;
        _result = [];
        private _jobComplete = false;

        scopename "main";

        call {

            if (!_initComplete) then {
                // check for impossible paths
                private _goalSectorIsLand = _goalSector select 4;
                private _pathIsPossible = if (_goalSectorIsLand) then { _canUseLand } else { _canUseWater };
                if (!_pathIsPossible) then {
                    _jobComplete = true;
                    breakto "main";
                };

                // check for non-bias procedure
                private _nonBiasProcedure = _canUseWater && { _canUseLand } && { _roadWeight == 0 } && { _waterWeight == 0 } && { _heightWeight ==0 };
                if (_nonBiasProcedure) then {
                    _result = [_goalPosition];
                    _jobComplete = true;
                    breakto "main";
                };
                // check for same Sector
                private _sameSector = (_startSector isEqualTo _goalSector);
                if (_sameSector) then {
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

                ////////////////////////////////////////////////////
                private _sectorCenter = [(_currentSector select 2) select 0,((_currentSector select 2) select 1) - 2];
                _m = createMarker [str str str str _sectorCenter, _sectorCenter];
                _debugMarkers pushback str str str str _sectorCenter;
                _m setMarkerShape "ICON";
                _m setMarkerType "hd_dot";
                _m setMarkerSize [0.5,0.5];
                _m setMarkerColor "ColorGreen";
                ////////////////////////////////////////////////////

                if (_currentSector isequalto _goalSector) exitwith {
                    _result = [nil,"reconstructPath", [_startSector,_goalSector,_cameFromMap,((_procedure select 3) > 0),(_procedure select 2) && !(_procedure select 1)]] call MAINCLASS;

                    //////// Obsolete - randomization embedded in reconstruct
                    // if (_randomizeWaypointRadius) then {
                    //     _result = [nil,"randomizePathPositions", _result] call MAINCLASS;
                    // };

                    if (count _result > 1) then {
                        // no need to move to center of sector we're already in
                        _result deleteat 0;
                    };

                    // last path position should be ending pos instead of sector center
                    _result set [count _result - 1, _goalPosition];

                    if (_shortenPath) then {
                        _result = [nil,"consolidatePath", _result] call MAINCLASS;
                    };

                    player sidechat format["End Job: %1",_startSector select 0]; /////////////
                    _jobComplete = true;
                    breakto "main";
                };

                // determine which neighbor is the best path
                private _neighbors = [_terrainGrid, "getNeighbors", [_currentSector select 0]] call alive_fnc_pathfindingGrid;
                {
                    private _currNeighbor = _x;
                    private _neighborIsLand = _currNeighbor select 4;
                    private _bridging = (_currNeighbor select 5 || _currentSector select 5);

                    //Lets check if there is water encountered when crossing sectors
                    private _wIxo = (_currentSector select 0) select 0;
                    private _wIyo = (_currentSector select 0) select 1;
                    _wIxo = (_wIxo + 1) - ((_currNeighbor select 0) select 0); //add one to get range of 0,1,2 instead of -1,0,1
                    _wIyo = (_wIyo + 1) - ((_currNeighbor select 0) select 1); //add one to get range of 0,1,2 instead of -1,0,1
                    private _wIx = (_currNeighbor select 0) select 0;
                    private _wIy = (_currNeighbor select 0) select 1;
                    _wIx = (_wIx + 1) - ((_currentSector select 0) select 0); //add one to get range of 0,1,2 instead of -1,0,1
                    _wIy = (_wIy + 1) - ((_currentSector select 0) select 1); //add one to get range of 0,1,2 instead of -1,0,1
                    private _isWaterTravel = ((((_currNeighbor select 6) select _wIxo) select _wIyo) || (((_currentSector select 6) select _wIx) select _wIy) || !(_neighborIsLand));
                    
                    private _canTraverse = if (_isWaterTravel) then { _canUseWater } else { _canUseLand };
                    if (_bridging && _canUseLand) then {_isWaterTravel = false;_canTraverse = true;};
                    if (_canTraverse) then {
                        private _newCost = (_costSoFarMap getvariable (str(_currentSector select 0))) + ([nil,"getMovementCost", [_currentSector,_currNeighbor,_procedure]] call MAINCLASS);
                        
                        private _currNeighborCostSoFar = _costSoFarMap getvariable (str(_currNeighbor select 0));
                        if (isnil "_currNeighborCostSoFar" || { _newCost < _currNeighborCostSoFar }) then {
                        //if (isnil "_currNeighborCostSoFar") then {
                            _costSoFarMap setvariable [str(_currNeighbor select 0), _newCost]; 
                            private _priority = _newCost + ([nil,"heuristic", [_currNeighbor,_goalSector,_procedure,_currentSector,_isWaterTravel]] call MAINCLASS);
                            [nil,"priorityAdd", [_frontier,_priority,_currNeighbor]] call MAINCLASS;
                            _cameFromMap setvariable [str(_currNeighbor select 0),_currentSector];
                            
                            private _sC = [(_currNeighbor select 2) select 0,((_currNeighbor select 2) select 1) - 10];
                            _debugMarkers pushback  str str str str  _sC;
                            private _m = createMarker [str str str str  _sC, _sC];
                            _m setMarkerShape "ICON";
                            _m setMarkerType "hd_dot";
                            _m setMarkerSize [0.3,0.3];
                            _m setMarkerColor "ColorRed";
                            _m setMarkerText format ["%1  (%2)",_newCost,_priority];
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
            _cameFromMap call CBA_fnc_deleteNamespace;
            _costSoFarMap call CBA_fnc_deleteNamespace;
            {deleteMarker _x} foreach _debugMarkers;
            // load next job data
            [_logic,"loadCurrentJobData"] call MAINCLASS;
        };

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