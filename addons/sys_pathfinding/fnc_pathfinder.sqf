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
    _a = ((_sectorBPos select 0) - (_sectorAPos select 0))/_inc;
    _b = ((_sectorBPos select 1) - (_sectorAPos select 1))/_inc;

    for "_i" from 0 to _inc do {
        _heightASL = getTerrainHeightASL [(_sectorAPos select 0) + (_a*_i),(_sectorAPos select 1) + (_b*_i)];
        if (_heightASL < -0.3) then {
            _waterTravel = true;
            _waterDistance = _waterDistance + _inc;
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
////////////////////////////////

switch (_operation) do {

    case "create": {
        PRIVATE _pathfindingSize = [ALIVE_profileSystem,"pathfindingSize"] call ALIVE_fnc_profileSystem;
        private _sectorSize = _pathfindingSize select 0;
        private _subSectorSize = _pathfindingSize select 1;
        private _terrainGrid = [nil,"create", _pathfindingSize] call ALiVE_fnc_pathfindingGrid;

        _logic = [[
            ["terrainGrid", _terrainGrid],
            ["pathfindingProcedures", [] call ALiVE_fnc_hashCreate],
            ["currentJobData", []],
            ["pathJobs", []],
            ["pathDebugMarkers", []]
        ]] call ALiVE_fnc_hashCreate;

        [_logic,"addPathfindingProcedure", ["default",["Man", [true, true, true, true, false], [0.7, 30], [-0.2, 0.6, -0.1, -0.1]]]] call MAINCLASS;
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
    case "heuristic": {
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
        // Threat / Danger weight
        // ?? future ??
    };

    case "canTraverseSector": {
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
            // Land Unit Check
            if (_isCoastTravel && !(_isMovingToFromBridge) && _canTraverseLand && _hasDeepWater) then {
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
                        _canTraverse = _canTraverseWater;
                        if (_canTraverseRoads && _hasRoads) then {_canTraverse = true;};
                        if (_canTraverseTrails && _hasTrails) then {_canTraverse = true;};
                        if (_canTraverseLand && _maxDensity !=0 && (_density < _maxDensity) && ((abs(_height - _prevHeight)/_size) < _maxSlope)) then {
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

        _result = _canTraverse;
    };

    case "getMovementCost": {
        _args params ["_currentSector","_goalSector","_size"];

        if (
            ((_currentSector select 0) select 0) != ((_goalSector select 0) select 0) &&
            { ((_currentSector select 0) select 1) != ((_goalSector select 0) select 1) }
        ) then {
            _result = 1.414 * _size;
            //_result = 1.3;
        } else {
            _result = 1.0 * _size;
        };
    };

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

        private _cameFromMapLayer1 = call CBA_fnc_createNamespace;
        private _costSoFarMapLayer1 = call CBA_fnc_createNamespace;
        _costSoFarMapLayer1 setvariable [str(_startSector select 0),0];
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
                    if (((_distS1+_distS2) < (_distR1+_distR2)) && (getTerrainHeightASL _x > -0.3)) then {_result = _x;};
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
                _currentSector = _cameFromMap getVariable str(_currentSector select 0);
            } else {
                private _nextSector = _cameFromMap getvariable str(_currentSector select 0);
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

    case "priorityAdd": {
        _args params ["_queue","_priority","_item"];

        private _queueSize = count _queue;
        private _i = 0;
        while {_i <= _queueSize - 1 && { _priority > ((_queue select _i) select 0) }} do {
            _i = _i + 1;
        };

        _queue insert [_i, [[_priority, _item]] ];
    };

    case "priorityPullLowest": {  // Renamed for better description
        private _queue = _args;

        if (count _queue > 0) then {
            _result = (_queue deleteat 0) select 1;
        };
    };

    case "setNodeToFrontier": {
        _args params ["_cameFromMap", "_costSoFarMap", "_frontier", "_sector", "_cameFromSector", "_distanceToGoal", "_heuristicParams"];
    
        private _size = _heuristicParams select 4;
        private _moveCost = ([nil,"getMovementCost", [_cameFromSector,_sector,_size]] call MAINCLASS); 
        private _priority = ([nil,"heuristic", _heuristicParams] call MAINCLASS);
        private _newCostSoFar = _moveCost + (_costSoFarMap getvariable str(_cameFromSector select 0));
        private _sectorCostSoFar = _costSoFarMap getvariable str(_sector select 0);

        if (isnil "_sectorCostSoFar" || { _newCostSoFar < _sectorCostSoFar }) then {
            _costSoFarMap setvariable [str (_sector select 0), _newCostSoFar]; 
            [nil,"priorityAdd", [_frontier, _distanceToGoal + _priority + _moveCost/*_newCostSoFar*/, _sector]] call MAINCLASS;
            //["[d:%1] [p:%2] [nc:%3] -- total[%4] ",_distanceToGoal , _priority , _newCostSoFar,_distanceToGoal + _priority + _newCostSoFar] call Alive_fnc_Dump;
            _cameFromMap setVariable [str(_sector select 0),_cameFromSector];            
        };       
    };

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

            private _startSector = [_terrainGrid,"positionToSector", _startPos] call ALiVE_fnc_pathfindingGrid;
            private _goalSector = [_terrainGrid,"positionToSector", _endPos] call ALiVE_fnc_pathfindingGrid;
            private _startSubSector = [_terrainGrid,"positionToSubSector", _startPos] call ALiVE_fnc_pathfindingGrid;
            private _goalSubSector = [_terrainGrid,"positionToSubSector", _endPos] call ALiVE_fnc_pathfindingGrid;

            // Setup Layer 1
            private _cameFromMapLayer1 = call CBA_fnc_createNamespace;
            private _costSoFarMapLayer1 = call CBA_fnc_createNamespace;
            private _frontierLayer1 = [[0,_startSector]];
            private _pathLayer1 = [];
            private _closestSector = [(_startSector select 2) distance (_goalSector select 2),_startSector];

            // Setup Layer 2
            private _cameFromMapLayer2 = call CBA_fnc_createNamespace;
            private _costSoFarMapLayer2 = call CBA_fnc_createNamespace;
            private _frontierLayer2 = [[0,_startSubSector]];
            private _pathLayer2 = [];
            private _closestSubSector = [(_startSubSector select 2) distance (_goalSubSector select 2),_startSubSector];
            private _itersSinceClosest = 0;

            // Init Layers
            _costSoFarMapLayer1 setvariable [str(_startSector select 0),0];
            _costSoFarMapLayer2 setvariable [str(_startSubSector select 0),0];

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

                private _currentSector = [nil,"priorityPullLowest", _frontierLayer1] call MAINCLASS;
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
                    private _canTraverse = [_logic, "canTraverseSector", [_procedure, _neighSector, _currentSector, _sectorSize]] call MAINCLASS;
                    if (typeName _canTraverse == "ARRAY") then {_isWaterTravel = _canTraverse select 1; _canTraverse = _canTraverse select 0;};
                    if (_canTraverse) then {
                        private _distanceToGoal = _centerPos distance (_goalSector select 2);
                        private _heuristicParams = [_neighSector,_currentSector,_procedure, _distanceToGoal,_sectorSize,_isWaterTravel];
                        [_logic,"setNodeToFrontier",[_cameFromMapLayer1, _costSoFarMapLayer1, _frontierLayer1, _neighSector, _currentSector, _distanceToGoal, _heuristicParams]] call MAINCLASS;
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
                private _currentSubSector = [nil,"priorityPullLowest", _frontierLayer2] call MAINCLASS;
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
                    private _canTraverse = [_logic, "canTraverseSector", [_procedure, _neighSubSector, _currentSubSector, _subSectorSize]] call MAINCLASS;
                    if (typeName _canTraverse == "ARRAY") then {_isWaterTravel = _canTraverse select 1; _canTraverse = _canTraverse select 0;};

                    if (_canTraverse) then { 
                        if (count _pathLayer1 > 0) then {_distanceToGoal = [_pathLayer1,_centerPos] call _fnc_getDistanceFromLayer;};
                        private _heuristicParams = [_neighSubSector,_currentSubSector,_procedure,_distanceToGoal,_subSectorSize,_isWaterTravel];
                        [nil,"setNodeToFrontier",[_cameFromMapLayer2, _costSoFarMapLayer2, _frontierLayer2, _neighSubSector, _currentSubSector, _distanceToGoal, _heuristicParams]] call MAINCLASS;
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

            [_callbackArgs,_result] spawn _callback;

            // remove job from queue and clean up the mess we made
            _pathJobs deleteat 0;
            _cameFromMapLayer1 call CBA_fnc_deleteNamespace;
            _costSoFarMapLayer1 call CBA_fnc_deleteNamespace;
            _cameFromMapLayer2 call CBA_fnc_deleteNamespace;
            _costSoFarMapLayer2 call CBA_fnc_deleteNamespace;
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