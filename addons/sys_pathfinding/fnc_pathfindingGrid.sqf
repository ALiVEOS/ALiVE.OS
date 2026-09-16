#define MAINCLASS alive_fnc_pathfindingGrid

params [
    ["_logic", nil],
    ["_operation", ""],
    ["_args", objNull]
];

private "_result";

private _fnc_mapBoundsOuterLimit = {
    params ["_value"];
    
    if (_value <= 0) then {_value = 1;};
    if (_value >= worldSize) then {_value = worldSize - 1;};

    _value
};

switch (_operation) do {

    case "create": {
        ALiVE_pathfinding_neighborOffsets = [[-1,-1],[0,-1],[1,-1],[-1,0],[1,0],[-1,1],[0,1],[1,1]];

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

        _logic = createHashMapFromArray [
            ["sectors", createHashMapFromArray _sectors],
            ["subSectors", createHashMapFromArray _subSectors],
            // Neighbor lists are built only for expanded cells, separately per layer.
            ["sectorNeighborCache", createHashMap],
            ["subSectorNeighborCache", createHashMap],
            ["sectorSize", _sectorSize],
            ["sectorRadius", _sectorSize/2],
            ["subSectorSize", _subSectorSize],
            ["subSectorRadius", _subSectorSize/2],
            ["gridWidth", _gridWidth],
            // Lazy, mission-lifetime terrain water caches. The outer map selects
            // a cache by [sea level, water margin, layer size]
            ["waterEdgeCaches", createHashMap],
            ["debugMarkers", []]
        ];
        _result = _logic;

    };

    case "getSector": {

        _args params ["_x","_y"];

        private _sectors = _logic get "sectors";

        _result = _sectors get [_x,_y];

        if (isnil "_result") exitwith {};

        if (_result select 0 isEqualTo [-1,-1]) then { //Compressed water sector - build position info on the fly without deep-copying the template
            private _sectorSize = _logic get "sectorSize";
            private _sectorRadius = _sectorSize / 2;
            _result = [
                [_x,_y],
                [_sectorSize*_x,_sectorSize*_y],
                [_sectorSize*_x + _sectorRadius,_sectorSize*_y + _sectorRadius],
                _result select 3,
                _result select 4
            ];
        };

        _result;
    };

    case "getSubSector": {

        _args params ["_x","_y"];

        private _subSectors = _logic get "subSectors";

        _result = _subSectors get [_x,_y];

        if (isnil "_result") exitwith {};

        if (_result select 0 isEqualTo [-1,-1]) then { //Compressed water sector - build position info on the fly without deep-copying the template
            private _subSectorSize = _logic get "subSectorSize";
            private _subSectorRadius = _subSectorSize / 2;
            _result = [
                [_x,_y],
                [_subSectorSize*_x,_subSectorSize*_y],
                [_subSectorSize*_x + _subSectorRadius,_subSectorSize*_y + _subSectorRadius],
                _result select 3,
                _result select 4
            ];
        };

        _result;
    };

    case "positionToIndex": {

        private _pos = _args;

        private _sectorSize = _logic get "sectorSize";

        private _x = floor ((_pos select 0) / _sectorSize);
        private _y = floor ((_pos select 1) / _sectorSize);

        _result = [_x,_y];

    };

    case "positionToSubIndex": {

        private _pos = _args;

        private _subSectorSize = _logic get "subSectorSize";

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
        private _sectorIndex = _args;
        if (isNil "_sectorIndex") exitWith { _result = []; };
        // The grid topology is immutable after creation. Return the cached list
        // directly: callers iterate it without changing membership or order.
        // Recreating the grid creates fresh caches. Clear this layer cache if
        // future code replaces cells, changes layer size, or changes offsets.
        private _neighborCache = _logic get "sectorNeighborCache";
        // Also support a grid created before this function was recompiled.
        if (isNil "_neighborCache") then {
            _neighborCache = createHashMap;
            _logic set ["sectorNeighborCache", _neighborCache];
        };
        private _cachedNeighbors = _neighborCache get _sectorIndex;
        if (!isNil "_cachedNeighbors") exitWith { _result = _cachedNeighbors; };
        private _sectors = _logic get "sectors";
        private "_sectorSize";
        private "_sectorRadius";
        private _ix = _sectorIndex select 0;
        private _iy = _sectorIndex select 1;
        private _neighbors = [];
        {
            private _ni = [_ix + (_x select 0), _iy + (_x select 1)];
            private _sector = _sectors get _ni;
            if (!isNil "_sector") then {
                if ((_sector select 0) isEqualTo [-1,-1]) then {
                    // Most expansions are over land
                    // Fetch water-only metadata lazily when a compressed sector is present.
                    if (isNil "_sectorSize") then {
                        _sectorSize = _logic get "sectorSize";
                        _sectorRadius = _sectorSize / 2;
                    };
                    _sector = [
                        _ni,
                        [_sectorSize*(_ni select 0),_sectorSize*(_ni select 1)],
                        [_sectorSize*(_ni select 0) + _sectorRadius,_sectorSize*(_ni select 1) + _sectorRadius],
                        _sector select 3,
                        _sector select 4
                    ];
                };
                _neighbors pushBack _sector;
            };
        } forEach ALiVE_pathfinding_neighborOffsets;
        _neighborCache set [_sectorIndex, _neighbors];
        _result = _neighbors;
    };

    case "getNeighborSubSectors": {
        private _sectorIndex = _args;
        if (isNil "_sectorIndex") exitWith { _result = []; };
        // The grid topology is immutable after creation. Return the cached list
        // directly: callers iterate it without changing membership or order.
        // Recreating the grid creates fresh caches. Clear this layer cache if
        // future code replaces cells, changes layer size, or changes offsets.
        private _neighborCache = _logic get "subSectorNeighborCache";
        // Also support a grid created before this function was recompiled.
        if (isNil "_neighborCache") then {
            _neighborCache = createHashMap;
            _logic set ["subSectorNeighborCache", _neighborCache];
        };
        private _cachedNeighbors = _neighborCache get _sectorIndex;
        if (!isNil "_cachedNeighbors") exitWith { _result = _cachedNeighbors; };
        private _subSectors = _logic get "subSectors";
        private "_subSectorSize";
        private "_subSectorRadius";
        private _ix = _sectorIndex select 0;
        private _iy = _sectorIndex select 1;
        private _neighbors = [];
        {
            private _ni = [_ix + (_x select 0), _iy + (_x select 1)];
            private _subSector = _subSectors get _ni;
            if (!isNil "_subSector") then {
                if ((_subSector select 0) isEqualTo [-1,-1]) then {
                    if (isNil "_subSectorSize") then {
                        _subSectorSize = _logic get "subSectorSize";
                        _subSectorRadius = _subSectorSize / 2;
                    };
                    _subSector = [
                        _ni,
                        [_subSectorSize*(_ni select 0),_subSectorSize*(_ni select 1)],
                        [_subSectorSize*(_ni select 0) + _subSectorRadius,_subSectorSize*(_ni select 1) + _subSectorRadius],
                        _subSector select 3,
                        _subSector select 4
                    ];
                };
                _neighbors pushBack _subSector;
            };
        } forEach ALiVE_pathfinding_neighborOffsets;
        _neighborCache set [_sectorIndex, _neighbors];
        _result = _neighbors;
    };

    case "enableDebugMarkers": {
        _args params ["_enable"];
        private _debugMarkers = _logic get "debugMarkers";

        // Draw each sector once and retain its marker names for removal.
        if (_enable) exitwith {
            if (count _debugMarkers > 0) exitWith { _result = true; };   // already drawn
            private _sectors = _logic get "sectors";
            private _size = _logic get "sectorSize";
            { _debugMarkers append ([nil, "createSectorDebugMarker", [_y,_size]] call Alive_fnc_pathfindingSector); } foreach _sectors;
            _logic set ["debugMarkers", _debugMarkers];
            _result = true;
        };

        // Clear marker names so the overlay can be enabled again.
        { deleteMarker _x } forEach _debugMarkers;
        _logic set ["debugMarkers", []];
        _result = false;
    };

};

if (isnil "_result") then {nil} else {_result};
