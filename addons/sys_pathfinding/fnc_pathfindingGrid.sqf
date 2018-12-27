#define MAINCLASS alive_fnc_pathfindingGrid

params [
    ["_logic", nil],
    ["_operation", ""],
    ["_args", objNull]
];

private "_result";

switch (_operation) do {

    case "create": {

        _args params ["_sectorSize"];

        // create sector grid

        private _sectors = call CBA_fnc_createNamespace;
        private _gridWidth = ceil(worldsize / _sectorSize) + 1;

        private _sectorArr = [];

        for "_i" from 0 to _gridWidth - 1 do {
            for "_j" from 0 to _gridWidth - 1 do {
                private _index = [_j,_i];
                private _newSector = [nil,"create", [[_j,_i],[_sectorSize * _j, _sectorSize * _i], _sectorSize]] call alive_fnc_pathfindingSector;

                _sectors setvariable [str _index,_newSector];
                _sectorArr pushback _newSector;
            };
        };

        // create sector grid

        _logic = [[
            ["sectors", _sectors],
            ["sectorSize", _sectorSize],
            ["gridWidth", _gridWidth],
            ["initialized", false],
            ["initData", [-1,[],[],_sectorArr]]
        ]] call ALiVE_fnc_hashCreate;

        private _timer = diag_tickTime;
        //[_logic,"determineRegions"] call MAINCLASS;
        private _timeTaken = diag_tickTime - _timer;
        copyToClipboard format ["Time Taken: %1", _timeTaken];

        _result = _logic;

    };

    case "getSector": {

        private _sectors = _logic select 2 select 0;

        _result = _sectors getvariable (str _args);

    };

    case "positionToIndex": {

        private _pos = _args;

        private _sectorSize = _logic select 2 select 1;

        private _x = floor ((_pos select 0) / _sectorSize);
        private _y = floor ((_pos select 1) / _sectorSize);

        _result = [_x,_y];

    };

    case "positionToSector": {

        private _pos = _args;

        private _sectorIndex = [_logic,"positionToIndex", _pos] call ALiVE_fnc_pathfindingGrid;
        _result = [_logic,"getSector", _sectorIndex] call ALiVE_fnc_pathfindingGrid;

    };

    case "getNeighbors": {

        _args params [
            "_sector",
            ["_returnIndices", false, [false]]
        ];

        if (count _sector != 2) then {
            _sector = _sector select 0;
        };

        _sector params ["_sectorX","_sectorY"];

        _result = [
            [_sectorX - 1, _sectorY + 1],   [_sectorX, _sectorY + 1],   [_sectorX + 1, _sectorY + 1],
            [_sectorX - 1, _sectorY],                                   [_sectorX + 1, _sectorY],
            [_sectorX - 1, _sectorY - 1],   [_sectorX, _sectorY - 1],   [_sectorX + 1, _sectorY - 1]
        ];

        if (!_returnIndices) then {
            private _sectors = _logic select 2 select 0;
            _result = _result apply {
                _sectors getvariable (str _x)
            };

            _result = _result select {!isnil "_x"};
        };

    };

    case "onFrameDetermineRegions": {

        private _sectors = _logic select 2 select 0;
        private _initData = _logic select 2 select 4;

        _initData params ["_regionNum","_sectorsToCheck","_validTerrainTypes","_open"];

        for "_i" from 0 to 3 do {
            if (_sectorsToCheck isequalto []) then {
                _regionNum = _regionNum + 1;

                private _sectorIndex = _open findif { (_x select 3) == -1 };
                if (_sectorIndex == -1) exitwith {
                    [_logic,"initialized", true] call ALiVE_fnc_hashSet;
                    [_logic,"initData", nil] call ALiVE_fnc_hashSet;
                };

                private _sector = _open select _sectorIndex;
                private _sectorTerrainType = _sector select 2;
                private _validTerrainTypes = switch (_sectorTerrainType) do {
                    case "ROAD": { ["LAND","ROAD"] };
                    case "LAND": { ["LAND","ROAD"] };
                    case "WATER": { ["WATER"] };
                };

                _sector set [3,_regionNum];

                _initData set [0, _regionNum];
                _initData set [1, [_sector]];
                _initData set [2, _validTerrainTypes];
            } else {
                private _sector = _sectorsToCheck deleteat 0;

                //
                private _pos = _sector select 1;
                private _size = _logic select 2 select 1;
                private _markerCenter = _pos apply {_x + _size * 0.5};
                private _m = createMarker [str str str _markerCenter, _markerCenter];
                _m setMarkerShape "ICON";
                _m setMarkerType "hd_dot";
                _m setMarkerSize [0.1,0.1];
                _m setMarkerColor "ColorBlack";
                _m setMarkerText (format ["(%1)", _regionNum]);
                //

                private _sectorCoords = _sector select 0; systemchat format ["Checking %1", _sectorCoords];
                private _neighbors = [_logic,"getNeighbors", [_sectorCoords]] call MAINCLASS;
                {
                    private _neighborIslandNum = _x select 3;

                    if (_neighborIslandNum == -1) then {
                        private _neighborTerrainType = _x select 2;

                        if (_neighborTerrainType in _validTerrainTypes) then {
                            _sectorsToCheck pushback _x;
                            _x set [3, _regionNum];
                        };
                    };
                } foreach _neighbors;
            };
        };

    };

};

if (isnil "_result") then {nil} else {_result};