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
        
        private _centerPos = [(_pos select 0) + _size/2,(_pos select 1) + _size/2];
        private _roads = 0;
        private _heightASL = round((getTerrainHeightASL _centerPos)); //approx height based on center
        private _isLand = !(_heightASL < -0.5);
        private _hasBridge = false;
        private _roadWeights = [false,false,false]; // basically [has main road, has road, has trail]
        {
            private _info = getRoadInfo _x;
            if (_info select 8) exitWith {
                _hasBridge = true;  //Large Bridge only
                _roadWeights set [0,true]; //We know it has highest possible, lets exit
                break;
            };

            switch (_info select 0) do
            {
                case "MAIN ROAD": {                    
                    _roadWeights set [0,true];
                };
                case "ROAD": {                    
                    _roadWeights set [1,true];
                };
                case "TRAIL": {                    
                    _roadWeights set [2,true];
                };
            };
        } foreach (_centerPos nearRoads (_size * 0.6)); 

        // Not sure if this is needed but, will focus on MAIN ROADS if two comparison sectors have different types of roads.
        private _maxRoadWeight = 1;
        {
            if (_x) exitWith {_roads = _roads + _maxRoadWeight;};
            _maxRoadWeight = _maxRoadWeight - 0.1;
        } foreach _roadWeights;  
        

        ///// Create a 4 x 3 grid within the sector for determining water crossing and average flyInHeight /////
        private _waterCrossing = [[false,false,false],[false,false,false],[false,false,false]];
        private _wI = [false,false,false,false,false,false,false,false,false]; // coverage of any water near vertices of sector
        private _wOffset = _size / 3;
        private _wPositions = [[(_centerPos select 0) - _wOffset,(_centerPos select 1) - _wOffset],[(_centerPos select 0),(_centerPos select 1)  - _wOffset],[(_centerPos select 0) + _wOffset,(_centerPos select 1) - _wOffset],[(_centerPos select 0) - _wOffset,(_centerPos select 1)],_centerPos,[(_centerPos select 0) + _wOffset,(_centerPos select 1)],[(_centerPos select 0) - _wOffset,(_centerPos select 1) + _wOffset],[(_centerPos select 0),(_centerPos select 1) + _wOffset],[(_centerPos select 0) + _wOffset,(_centerPos select 1) + _wOffset]];
        private _avgHeightASL = 0;      
        
        _tempIndex = 0;
        {
            _tempASL = getTerrainHeightASL _x;
            _avgHeightASL = _avgHeightASL + _tempASL;
            _wI set [_tempIndex, _tempASL < -0.5];
            _tempIndex = _tempIndex + 1;

            // //////Debugging  Markers
            // if (getTerrainHeightASL _x < -0.5) then {
            //     _m2 = createMarker [str str _x, _x];
            //     _m2 setMarkerShape "ICON";
            //     _m2 setMarkerType "hd_dot";
            //     _m2 setMarkerSize [0.5,0.5];
            //     _m2 setMarkerColor "ColorBlue";
            //     _m2 setMarkerAlpha 0.5;
            // };
        } foreach _wPositions;

        _waterCrossing set [0, [_wI select 0 || (_wI select 1 && _wI select 3),_wI select 3 || (_wI select 0 && _wI select 6),_wI select 6 || (_wI select 3 && _wI select 7)]];
        _waterCrossing set [1, [_wI select 1 || (_wI select 0 && _wI select 2),_wI select 4,_wI select 7 || (_wI select 6 && _wI select 8)]];
        _waterCrossing set [2, [_wI select 2 || (_wI select 1 && _wI select 5),_wI select 5 || (_wI select 2 && _wI select 8),_wI select 8 || (_wI select 5 && _wI select 7)]];

        _heightASL = _avgHeightASL / 9; // 


        _logic = [_index, _pos, _centerPos, _roads, _isLand, _hasBridge, _waterCrossing, _heightASL];

        _result = _logic;

        // debug
        
        // _m = createMarker [str _Pos, _Pos];
        // _m setMarkerShape "RECTANGLE";
        // _m setMarkerSize [_size,_size];
        // _m setMarkerAlpha 0.2;
        // if (_roads > 0) then {
        //     _m setMarkerColor "ColorYellow";
        // } else {
        //     if (_isLand) then {
        //         _m setMarkerColor "ColorGreen";
        //     } else {
        //         _m setMarkerColor "ColorBlue";
        //         if (_hasBridge) then {_m setMarkerBrush "Grid";};
        //     };
        // };
        

        // _m = createMarker [str [_centerPos select 0,(_centerPos select 1) + 20],[_centerPos select 0,(_centerPos select 1) + 20]];
        // _m setMarkerShape "ICON";
        // _m setMarkerType "hd_dot";
        // _m setMarkerSize [0.05,0.05];
        // _m setMarkerColor "ColorBlack";
        // _m setMarkerAlpha 0.5;
        // _mtext = format ["H%1-R%2", _heightASL, _roads];
        // if (_hasBridge) then {_mtext = _mtext + "*"};
        // _m setMarkerText _mtext;

    };
};

if (isnil "_result") then {nil} else {_result};