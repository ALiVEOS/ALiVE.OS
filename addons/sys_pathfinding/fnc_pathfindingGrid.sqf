#define MAINCLASS alive_fnc_pathfindingGrid

params [
    ["_logic", nil],
    ["_operation", ""],
    ["_args", objNull]
];

private "_result";

switch (_operation) do {

    case "create": {
["PATHFINDING GRID START - %1 || %2", diag_ticktime, cansuspend] call ALiVE_fnc_Dump;
        _args params ["_sectorSize"];

        // create sector grid

        private _sectors = [];
        private _gridWidth = ceil(worldsize / _sectorSize) + 1;

        for "_i" from 0 to _gridWidth - 1 do {
            for "_j" from 0 to _gridWidth - 1 do {
                private _newSector = [nil,"create", [[_j,_i],[_sectorSize * _j, _sectorSize * _i], _sectorSize]] call alive_fnc_pathfindingSector;
                _sectors pushback _newSector;
            };
        };

        // create sector grid

        _logic = [[
            ["sectors", _sectors],
            ["sectorSize", _sectorSize],
            ["gridWidth", _gridWidth]
        ]] call ALiVE_fnc_hashCreate;
		
		[_logic,"determineRegions"] call MAINCLASS;
		[_logic,"colormegrid"] call MAINCLASS;

        _result = _logic;
["PATHFINDING GRID END - %1 || %2", diag_ticktime, cansuspend] call ALiVE_fnc_Dump;
    };

    case "getSector": {

        _args params ["_x","_y"];

        private _sectors = [_logic,"sectors"] call ALiVE_fnc_hashGet;
        private _gridWidth = [_logic,"gridWidth"] call ALiVE_fnc_hashGet;

        private _index = (_y * _gridWidth) + _x;

        _result = _sectors select _index;

    };

    case "positionToIndex": {

        private _pos = _args;

        private _sectorSize = [_logic,"sectorSize"] call ALiVE_fnc_hashGet;

        private _x = floor ((_pos select 0) / _sectorSize);
        private _y = floor ((_pos select 1) / _sectorSize);

        _result = [_x,_y];

    };

    case "positionToSector": {

        private _pos = _args;

        private _sectorIndex = [_logic,"positionToIndex", _pos] call ALiVE_fnc_pathfindingGrid;
        _result = [_logic,"getSector", _sectorIndex] call ALiVE_fnc_pathfindingGrid;

    };

	// determine and store at mission start?
    case "getNeighbors": {

        _args params [
            "_sector",
            ["_returnIndices", false, [false]]
        ];

        if (count _sector != 2) then {
            _sector = _sector select 0;
        };

        private _gridWidth = [_logic,"gridWidth"] call ALiVE_fnc_hashGet;
        private _gridHeight = _gridWidth;

        _sector params ["_sectorX","_sectorY"];

        private _indices = [];

        if (_sectorX > 0) then {
            _indices pushback [_sectorX - 1, _sectorY]; // left

            if (_sectorY > 0) then {
                _indices pushback [_sectorX - 1, _sectorY - 1]; // bot left corner
            };

            if (_sectorY < _gridHeight - 1) then {
                _indices pushback [_sectorX - 1, _sectorY + 1]; // top left corner
            };
        };

        if (_sectorX < _gridWidth - 1) then {
            _indices pushback [_sectorX + 1, _sector select 1]; // right

            if (_sectorY > 0) then {
                _indices pushback [_sectorX + 1, _sectorY - 1]; // bot right corner
            };

            if (_sectorY < _gridHeight - 1) then {
                _indices pushback [_sectorX + 1, _sectorY + 1]; // top right corner
            };
        };

        if (_sectorY > 0) then {
            _indices pushback [_sectorX, _sectorY - 1]; // bot
        };

        if (_sectorY < _gridHeight - 1) then {
            _indices pushback [_sectorX, _sectorY + 1]; // top
        };

        if (!_returnIndices) then {
            _indices = _indices apply {
                [_logic,"getSector", _x] call MAINCLASS;
            };
        };

        _result = _indices;

    };
	
	case "determineRegions": {

		private _sectors = [_logic,"sectors"] call ALiVE_fnc_hashGet;
		private _nextRegionID = 0;

        {
            if ((_x select 4) == -1) then {
                private _sourceSector = _x;
                private _regionTerrainType = _sourceSector select 3;

                private _regionID = _nextRegionID;
                _nextRegionID = _nextRegionID + 1;

                private _connected = [_sourceSector];
                while { _connected isnotequalto [] } do {
                    private _connectedSector = _connected deleteat 0;
                    _connectedSector set [4, _regionID];

                    // private _connectedSectorNeighbors = [_logic,"getNeighbors", [_connectedSector]] call MAINCLASS;
                    // private _validNeighbors = _connectedSectorNeighbors select { ((_x select 4) == -1) && ((_x select 3) == _regionTerrainType)};

                    // _connected append _validNeighbors;
                };
            };
        } foreach _sectors;
		
	};
	
	case "colormegrid": {
		private _colors = ["COLORRED","COLORBLUE","COLORGREEN","COLORYELLOW","COLORBROWN","COLORORANGE","COLORWHITE","COLORBLACK","COLORGREY"];
        private _colorCount = count _colors;
	
		private _sectorSize = [_logic,"sectorSize"] call ALiVE_fnc_hashGet;
		private _halfSectorSize = _sectorSize * 0.5;
		private _sectors = [_logic,"sectors"] call ALiVE_fnc_hashGet;
		{
			private _region = _x select 4;
			if (_region >= 0) then {
				private _color = _colors select (_region mod _colorCount);
				
				private _pos = _x select 1;
				private _center = _pos vectoradd [_halfSectorSize, _halfSectorSize];
				
				private _marker = createMarker [str random 10000, _pos];
				_marker setMarkerShape "RECTANGLE";
				_marker setMarkerSize [_halfSectorSize,_halfSectorSize];
				_marker setMarkerColor _color;
				_marker setMarkerAlpha 0.3;
			};
		} foreach _sectors;
	};

};

if (isnil "_result") then {nil} else {_result};