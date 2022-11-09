#define MAINCLASS alive_fnc_pathfindingGrid

params [
    ["_logic", nil],
    ["_operation", ""],
    ["_args", objNull]
];

private "_result";

private _fns_decompressWaterSector = {
    params ["_sectorCopy","_sectorIndex","_size","_radius"];
    private _x = _sectorIndex select 0;
    private _y = _sectorIndex select 1;
    _sectorCopy set [0, _sectorIndex];
    _sectorCopy set [1, [_size*_x,_size*_y]];
    _sectorCopy set [2, [_size*_x + _radius , _size*_y + _radius]];
    _sectorCopy;
};

switch (_operation) do {

    case "create": {
        _start = diag_tickTime;
        _args params ["_sectorSize","_subSectorSize"];

        // create sector grid - layer 1

        private _sectors = [];
        private _subSectors = [];
        private _gridWidth = ceil(worldsize / _sectorSize) + 1;

        for "_i" from 0 to _gridWidth - 1 do {
            for "_j" from 0 to _gridWidth - 1 do {
                private _newSectorData = [nil,"create", [[_j,_i],[_sectorSize * _j, _sectorSize * _i], _sectorSize, _subSectorSize, _gridWidth]] call alive_fnc_pathfindingSector;
                _sectors pushback (_newSectorData select 0);
                _subSectors append (_newSectorData select 1);
            };
        };

        _logic = [[
            ["sectors", createHashMapFromArray _sectors],
            ["subSectors", createHashMapFromArray _subSectors],
            ["sectorSize", _sectorSize],
            ["sectorRadius", _sectorSize/2],
            ["subSectorSize", _subSectorSize],
            ["subSectorRadius", _subSectorSize/2],
            ["gridWidth", _gridWidth],
            ["debugMarkers", []]
        ]] call ALiVE_fnc_hashCreate;
        _stop = diag_tickTime;
        ["Exp Pathfinding Grid Creation Time:%1",_stop-_start] call Alive_fnc_Dump;
        _result = _logic;

    };

    case "getSector": {

        _args params ["_x","_y"];

        private _sectors = [_logic,"sectors"] call ALiVE_fnc_hashGet;

        _result = _sectors get [_x,_y];

        if (_result select 0 isEqualTo [-1,-1]) then { //Compressed water sector - must build position info on the fly
            private _sectorSize = [_logic,"sectorSize"] call ALiVE_fnc_hashGet;
            private _sectorRadius = [_logic,"sectorRadius"] call ALiVE_fnc_hashGet;

            _result = +_result;
            [_result, [_x,_y] ,_sectorSize, _sectorRadius ] call _fns_decompressWaterSector;
        };

        _result;
    };

    case "getSubSector": {

        _args params ["_x","_y"];

        private _subSectors = [_logic,"subSectors"] call ALiVE_fnc_hashGet;

        _result = _subSectors get [_x,_y];

        if (_result select 0 isEqualTo [-1,-1]) then { //Compressed water sector - must build position info on the fly
            private _subSectorSize = [_logic,"subSectorSize"] call ALiVE_fnc_hashGet;
            private _subSectorRadius = [_logic,"subSectorRadius"] call ALiVE_fnc_hashGet;

            _result = +_result;
            [_result, [_x,_y] ,_subSectorSize, _subSectorRadius ] call _fns_decompressWaterSector;
        };

        _result;
    };

    case "positionToIndex": {

        private _pos = _args;

        private _sectorSize = [_logic,"sectorSize"] call ALiVE_fnc_hashGet;

        private _x = floor ((_pos select 0) / _sectorSize);
        private _y = floor ((_pos select 1) / _sectorSize);

        _result = [_x,_y];

    };

    case "positionToSubIndex": {

        private _pos = _args;

        private _subSectorSize = [_logic,"subSectorSize"] call ALiVE_fnc_hashGet;

        private _x = (floor ((_pos select 0) / _subSectorSize));
        private _y = (floor ((_pos select 1) / _subSectorSize));

        _result = [_x,_y];

    };

    case "positionToSector": {

        private _pos = _args;

        private _sectorIndex = [_logic,"positionToIndex", _pos] call ALiVE_fnc_pathfindingGrid;
        _result = [_logic,"getSector", _sectorIndex] call ALiVE_fnc_pathfindingGrid;

    };

    case "positionToSubSector": {

        private _pos = _args;

        private _subSectorIndex = [_logic,"positionToSubIndex", _pos] call ALiVE_fnc_pathfindingGrid;
        _result = [_logic,"getSubSector", _subSectorIndex] call ALiVE_fnc_pathfindingGrid;

    };

    case "getNeighborIndices": {   

        private _sectorIndex = _args; 
        if (isNil "_sectorIndex") exitwith {[];};
         
        private _neighbors = [];

        { 
            private _a = (_sectorIndex select 0) + (_x select 0);
            private _b = (_sectorIndex select 1) + (_x select 1);
            private _neighIndex = [_a,_b];
            _neighbors pushback _neighIndex;
        } foreach [[-1,-1],[0,-1],[1,-1],[-1,0],[1,0],[-1,1],[0,1],[1,1]];

        _result = _neighbors;
    };

    case "getNeighborSectors": {
        private _sectorIndex = _args;
        private _indices = [_logic, "getNeighborIndices", _sectorIndex] call Alive_fnc_pathfindingGrid;
        private _neighbors = [];
        {
            _sector = [_logic,"getSector", _x] call ALiVE_fnc_pathfindingGrid; 
            if !(isnil "_sector") then {_neighbors pushback _sector;};
        } foreach _indices;
        _result = _neighbors;
    };

    case "getNeighborSubSectors": {
        private _sectorIndex = _args;
        private _indices = [_logic, "getNeighborIndices", _sectorIndex] call Alive_fnc_pathfindingGrid;
        private _neighbors = [];
        {
            _subSector = [_logic,"getSubSector", _x] call ALiVE_fnc_pathfindingGrid; 
            if !(isnil "_subSector") then { _neighbors pushback _subSector;};
        } foreach _indices;
        _result = _neighbors;
    };

    case "enableDebugMarkers": {
        _args params ["_enable"];
        _debugMarkers = [_logic,"debugMarkers"] call ALiVE_fnc_hashGet;

        if ((count _debugMarkers > 0) && _enable) exitwith {_result = _enable;};
        if ((count _debugMarkers > 0) && !_enable) exitwith {
            {deleteMarker _x} foreach _debugMarkers;
            _result = _enable;
        };
        if (_enable) exitwith {
            private _sectors = [_logic, "sectors"] call Alive_fnc_hashGet;
            //_sectors = [_sectors] call CBA_fnc_hashValues;
            private _size = [_logic,"sectorSize"] call Alive_fnc_hashGet;
            {_debugMarkers append ([nil, "createSectorDebugMarker", [_y,_size]] call Alive_fnc_pathfindingSector);} foreach _sectors;
            _result = _enable;
        };

        _result = _enable;
    };

};

if (isnil "_result") then {nil} else {_result};