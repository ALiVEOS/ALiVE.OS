#define MAINCLASS alive_fnc_pathfindingGrid

params [
    ["_logic", nil],
    ["_operation", ""],
    ["_args", objNull]
];

private "_result";

// CANDIDATE C: build + return a fresh decompressed water sector from the cached
// template instead of deep-copying it. The decompress only sets fields 0-2, so the
// new array shares the template's type (3) + modifiers (4) by reference - read-only
// in the search, so safe - dropping the per-access deep-copy churn on coastal maps.
private _fns_decompressWaterSector = {
    params ["_template","_sectorIndex","_size","_radius"];
    private _x = _sectorIndex select 0;
    private _y = _sectorIndex select 1;
    [_sectorIndex, [_size*_x,_size*_y], [_size*_x + _radius, _size*_y + _radius], _template select 3, _template select 4]
};

private _fnc_mapBoundsOuterLimit = {
    params ["_value"];
    
    if (_value <= 0) then {_value = 1;};
    if (_value >= worldSize) then {_value = worldSize - 1;};

    _value
};

// CANDIDATE C: the 8 neighbour offsets, built once and reused, instead of rebuilt on
// every getNeighbor* call.
if (isNil "ALiVE_pathfinding_neighborOffsets") then {
    ALiVE_pathfinding_neighborOffsets = [[-1,-1],[0,-1],[1,-1],[-1,0],[1,0],[-1,1],[0,1],[1,1]];
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
        ["Pathfinding Grid Creation Time:%1",_stop-_start] call Alive_fnc_Dump;
        _result = _logic;

    };

    case "getSector": {

        _args params ["_x","_y"];

        private _sectors = [_logic,"sectors"] call ALiVE_fnc_hashGet;

        _result = _sectors get [_x,_y];

        if (isnil "_result") exitwith {};

        if (_result select 0 isEqualTo [-1,-1]) then { //Compressed water sector - build position info on the fly (shallow, via the helper)
            private _sectorSize = [_logic,"sectorSize"] call ALiVE_fnc_hashGet;
            private _sectorRadius = [_logic,"sectorRadius"] call ALiVE_fnc_hashGet;
            _result = [_result, [_x,_y], _sectorSize, _sectorRadius] call _fns_decompressWaterSector;
        };

        _result;
    };

    case "getSubSector": {

        _args params ["_x","_y"];

        private _subSectors = [_logic,"subSectors"] call ALiVE_fnc_hashGet;

        _result = _subSectors get [_x,_y];

        if (isnil "_result") exitwith {};

        if (_result select 0 isEqualTo [-1,-1]) then { //Compressed water sector - build position info on the fly (shallow, via the helper)
            private _subSectorSize = [_logic,"subSectorSize"] call ALiVE_fnc_hashGet;
            private _subSectorRadius = [_logic,"subSectorRadius"] call ALiVE_fnc_hashGet;
            _result = [_result, [_x,_y], _subSectorSize, _subSectorRadius] call _fns_decompressWaterSector;
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

        if (isnil "_pos") exitwith {};

        _pos set [0, [_pos select 0] call _fnc_mapBoundsOuterLimit];
        _pos set [1, [_pos select 1] call _fnc_mapBoundsOuterLimit];

        private _sectorIndex = [_logic,"positionToIndex", _pos] call ALiVE_fnc_pathfindingGrid;
        _result = [_logic,"getSector", _sectorIndex] call ALiVE_fnc_pathfindingGrid;

    };

    case "positionToSubSector": {

        private _pos = _args;

        if (isnil "_pos") exitwith {};

        _pos set [0, [_pos select 0] call _fnc_mapBoundsOuterLimit];
        _pos set [1, [_pos select 1] call _fnc_mapBoundsOuterLimit];

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
        } foreach ALiVE_pathfinding_neighborOffsets;

        _result = _neighbors;
    };

    case "getNeighborSectors": {
        // CANDIDATE A/C: fold getNeighborIndices + getSector in here - one dispatch
        // + direct hash-gets per fetch instead of ~10 dispatches.
        private _sectorIndex = _args;
        if (isNil "_sectorIndex") exitWith { _result = []; };
        private _sectors = [_logic,"sectors"] call ALiVE_fnc_hashGet;
        private _sectorSize = [_logic,"sectorSize"] call ALiVE_fnc_hashGet;
        private _sectorRadius = [_logic,"sectorRadius"] call ALiVE_fnc_hashGet;
        private _ix = _sectorIndex select 0;
        private _iy = _sectorIndex select 1;
        private _neighbors = [];
        {
            private _ni = [_ix + (_x select 0), _iy + (_x select 1)];
            private _sector = _sectors get _ni;
            if (!isNil "_sector") then {
                if ((_sector select 0) isEqualTo [-1,-1]) then {
                    _sector = [_sector, _ni, _sectorSize, _sectorRadius] call _fns_decompressWaterSector;
                };
                _neighbors pushBack _sector;
            };
        } forEach ALiVE_pathfinding_neighborOffsets;
        _result = _neighbors;
    };

    case "getNeighborSubSectors": {
        // CANDIDATE A/C: fold getNeighborIndices + getSubSector in here.
        private _sectorIndex = _args;
        if (isNil "_sectorIndex") exitWith { _result = []; };
        private _subSectors = [_logic,"subSectors"] call ALiVE_fnc_hashGet;
        private _subSectorSize = [_logic,"subSectorSize"] call ALiVE_fnc_hashGet;
        private _subSectorRadius = [_logic,"subSectorRadius"] call ALiVE_fnc_hashGet;
        private _ix = _sectorIndex select 0;
        private _iy = _sectorIndex select 1;
        private _neighbors = [];
        {
            private _ni = [_ix + (_x select 0), _iy + (_x select 1)];
            private _subSector = _subSectors get _ni;
            if (!isNil "_subSector") then {
                if ((_subSector select 0) isEqualTo [-1,-1]) then {
                    _subSector = [_subSector, _ni, _subSectorSize, _subSectorRadius] call _fns_decompressWaterSector;
                };
                _neighbors pushBack _subSector;
            };
        } forEach ALiVE_pathfinding_neighborOffsets;
        _result = _neighbors;
    };

    case "enableDebugMarkers": {
        _args params ["_enable"];
        private _debugMarkers = [_logic,"debugMarkers"] call ALiVE_fnc_hashGet;

        // Enable: if not already drawn, build the coloured sector overlay and
        // store the created marker names. (sectors is a HashMap, so forEach gives
        // key=_x, value=_y - pass the sector value _y to the marker builder.)
        if (_enable) exitwith {
            if (count _debugMarkers > 0) exitWith { _result = true; };   // already drawn
            private _sectors = [_logic, "sectors"] call Alive_fnc_hashGet;
            private _size = [_logic,"sectorSize"] call Alive_fnc_hashGet;
            { _debugMarkers append ([nil, "createSectorDebugMarker", [_y,_size]] call Alive_fnc_pathfindingSector); } foreach _sectors;
            [_logic,"debugMarkers",_debugMarkers] call ALiVE_fnc_hashSet;
            _result = true;
        };

        // Disable: delete every drawn marker and clear the store so a later
        // enable will redraw (the previous version left stale names in the store,
        // which blocked re-enabling).
        { deleteMarker _x } forEach _debugMarkers;
        [_logic,"debugMarkers",[]] call ALiVE_fnc_hashSet;
        _result = false;
    };

};

if (isnil "_result") then {nil} else {_result};