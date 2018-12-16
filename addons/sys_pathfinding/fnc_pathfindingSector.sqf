#define MAINCLASS alive_fnc_pathfindingSector

params [
    ["_logic", nil],
    ["_operation", ""],
    ["_args", objNull]
];

private "_result";

switch (_operation) do {

    case "create": {

        _args params ["_index","_pos","_size"];

        private _roads = count (_pos nearRoads (_size * 0.6)) > 0;
        private _isLand = !(surfaceIsWater _pos);

        _logic = [_index, _pos, _roads, _isLand];

        _result = _logic;

        // debug

        _m = createMarker [str _pos, _pos];
        _m setMarkerShape "RECTANGLE";
        _m setMarkerSize [_size * 0.50,_size * 0.5];

        if (_roads) then {
            _m setMarkerColor "ColorYellow";
        } else {
            if (_isLand) then {
                _m setMarkerColor "ColorGreen";
            } else {
                _m setMarkerColor "ColorBlue";
            };
        };

        //_m = createMarker [str str _pos, _pos];
        //_m setMarkerShape "ICON";
        //_m setMarkerType "hd_dot";
        //_m setMarkerSize [0.05,0.05];
        //_m setMarkerColor "ColorBlack";
        //_m setMarkerText (format ["(%1,%2)", _index select 0, _index select 1]);

    };
};

if (isnil "_result") then {nil} else {_result};