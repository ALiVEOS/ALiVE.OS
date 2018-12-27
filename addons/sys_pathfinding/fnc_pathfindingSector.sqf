#define MAINCLASS alive_fnc_pathfindingSector

params [
    ["_logic", nil],
    ["_operation", ""],
    ["_args", objNull]
];

private "_result";

switch (_operation) do {

    case "create": {

        _args params ["_index","_origin","_size"];

        private _center = _origin apply {_x + (_size * 0.50)};

        private _terrainType = "LAND";
        private _hasRoads = count (_center nearRoads (_size * 0.6)) > 0;
        if (_hasRoads) then {
            _terrainType = "ROAD";
        } else {
            private _isLand = !(surfaceIsWater _center);

            if (!_isLand) then {
                _terrainType = "WATER";
            };
        };

        private _region = -1;

        _logic = [_index, _origin, _terrainType, _region];

        _result = _logic;

        ///*
        // debug

        _m = createMarker [str _center, _center];
        _m setMarkerShape "RECTANGLE";
        _m setMarkerSize [_size * 0.50,_size * 0.5];

        private _markerColor = switch (_terrainType) do {
            case "LAND": { "ColorGreen" };
            case "ROAD": { "ColorYellow" };
            case "WATER": { "ColorBlue" };
        };
        _m setMarkerColor _markerColor;
        //*/

        //_m = createMarker [str str _markerCenter, _markerCenter];
        //_m setMarkerShape "ICON";
        //_m setMarkerType "hd_dot";
        //_m setMarkerSize [0.05,0.05];
        //_m setMarkerColor "ColorBlack";
        //_m setMarkerText (format ["(%1,%2)", _index select 0, _index select 1]);

    };

};

if (isnil "_result") then {nil} else {_result};