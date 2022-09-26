#define MAINCLASS alive_fnc_pathfindingSector

params [
    ["_logic", nil],
    ["_operation", ""],
    ["_args", objNull]
];

private "_result";

private _fnc_getRoadModifier = {

    params ["_subSector", "_radius"];

    private _sPos = _subSector select 2; // Center
    private _subRoads = [];
    private _subHasBridge = false;
    
    // Not sure if there is a better way but, will set focus on MAIN ROADS if two comparison sectors have different types of roads.
    private _subRoadModifierList = [false,false,false,false]; // basically [has main road, has road, has track, has Trail]
    {
        private _info = getRoadInfo _x;
        if (_info select 8) exitwith {  //Non-Pedestrian Bridges only trigger this
            _subRoadModifierList set [0,true];
            _subHasBridge = true;  
        };

        switch (_info select 0) do
        {
            case "MAIN ROAD": {                    
                _subRoadModifierList set [0,true];
            };
            case "ROAD": {                    
                _subRoadModifierList set [1,true];
            };
            case "TRACK": {                    
                _subRoadModifierList set [2,true];
            };
            case "TRAIL": {                    
                _subRoadModifierList set [3,true];
            };
        };
    } foreach nearestTerrainObjects [_sPos, ["MAIN ROAD","ROAD","TRACK","TRAIL"], _radius * 1.2, false, true]; // Might ignore corners but thats ok

    // Create an overall modifier for comparing sectors
    private _maxRoadWeight = 1;
    private _subRoadModifier = 0;
    {
        if (_x) exitWith {_subRoadModifier = _maxRoadWeight;};
        _maxRoadWeight = _maxRoadWeight - 0.1;
    } foreach _subRoadModifierList; 
    
    private _subHasRoads = (_subRoadModifierList select 0)||(_subRoadModifierList select 1)||(_subRoadModifierList select 2);
    private _subHasTrails = _subRoadModifierList select 3;
    _subRoads pushback _subHasRoads;
    _subRoads pushback _subHasTrails;
    _subRoads pushback _subHasBridge;
    _subRoads pushback _subRoadModifier;
    (_subSector select 4) pushback _subRoads;

    //// DEBUG MARKING
    // if (_subHasBridge) then {
    //     _m = createMarker [str str _sPos, _sPos];
    //     _m setMarkerShape "ICON";
    //     _m setMarkerType "hd_dot";
    //     _m setMarkerSize [0.5,0.5];
    //     _m setMarkerColor "ColorYellow";
    //     _m setMarkerAlpha 0.6;
    // };

    [_subRoadModifier,_subHasRoads,_subHasTrails,_subHasBridge];
};

private _fnc_getHeightWaterModifier = {

    params ["_subSector", "_radius"];
    private _subWater = [];
    private _subHasWater = false;
    private _subIsEntirelyWater = true;
    private _subWaterModifier = 0;

    private _sPos = (_subSector select 2); // Center
    private _subHeightASL = getTerrainHeightASL _sPos;

    //Check for Water in multiple positions from center
    private _sOffset = _radius * 0.7;
    private _sPositions = [[-1,-1],[0,-1],[1,-1],[-1,0],[1,0],[-1,1],[0,1],[1,1]];
    {
        private _testPos = [
            (_sPos select 0) + ((_x select 0 ) * _sOffset),
            (_sPos select 1) + ((_x select 1 ) * _sOffset)
            ];
        if (getTerrainHeightASL _testPos < -0.3) then {_subHasWater = true;_subWaterModifier = _subWaterModifier + 1;} else {_subIsEntirelyWater = false;};

    } foreach _sPositions;
    
    _subWaterModifier = _subWaterModifier / 8;
    _subWater pushback _subHasWater;
    _subWater pushback _subWaterModifier;
    (_subSector select 4) pushback _subWater;
    (_subSector select 4) pushback _subHeightASL;
    private _hasBridge = (((_subSector select 4) select 0) select 2);
    if (_subIsEntirelyWater && !_hasBridge) then {
        _subSector set [3,"WATER"];
    } else {
        if (_hasBridge) then {
            _subSector set [3, "BRIDGE"];
            _subIsEntirelyWater = false;
        } else {
            if (_subHasWater) then {
                _subSector set [3, "COAST"];
            };
        };
    };
    

    //// DEBUG MARKING
    // if (_subHasWater) then {
    //     _m = createMarker [str _sPos, _sPos];
    //     _m setMarkerShape "ICON";
    //     _m setMarkerType "hd_dot";
    //     _m setMarkerSize [0.3,0.3];
    //     _m setMarkerColor "ColorBlue";
    //     _m setMarkerAlpha 0.6;
    // };

    [_subIsEntirelyWater, _subWaterModifier, _subHeightASL];

};

switch (_operation) do {

    case "create": {

        _args params ["_index","_posRef","_size","_subSize","_gridWidth"];


        private _subSectors = [];
        private _sCenterOffset = _subSize/2;
        private _subSectorRadius = _subSize/2;
        private _inc = _size/_subSize;

        /////// Create subSector Grid ///////
        for [{private _i = 0},{_i < _inc},{_i = _i + 1}] do {
            for [{private _j = 0},{_j < _inc},{_j = _j + 1}] do {
                private _sIndex = [(_index select 0)*_inc+_j,(_index select 1)*_inc+_i];
                private _sPosRef = [(_posRef select 0)+(_j*_size/_inc),(_posRef select 1)+(_i*_size/_inc)];
                private _sPosCenter = [(_sPosRef select 0)+_sCenterOffset,(_sPosRef select 1)+_sCenterOffset];
                private _subModifiers = [];
                private _newSubSector = [_sIndex,[_sIndex,_sPosRef,_sPosCenter,"LAND",_subModifiers]];
                _subSectors pushback _newSubSector;
            };
        };
        
        private _posCenter = [(_posRef select 0) + _size/2,(_posRef select 1) + _size/2];
        private _type = "LAND";  // Can be "LAND" , "WATER", "COAST" (for coastline or rivers - basically a mix), or "BRIDGE"
        private _modifiers = [];

        ///////////////// THIS SECTION REMOVED - Caused too much bloat and general performance suffered - have to do it 'on the fly'
        /////// GET NEIGHBORS LAYER 1 ///////
        // private _neighRelArray = [[-1,-1],[0,-1],[1,-1],[-1,0],[0,0],[1,0],[-1,1],[0,1],[1,1]];   
        // {
        //     // Create Neighbor Index 
        //     private _a = (_index select 0) + (_x select 0);
        //     private _b = (_index select 1) + (_x select 1);
        //     private _neighIndex = [_a,_b];
        //     private _outOfBoundsX = (_a < 0) || (_a >= _gridWidth);
        //     private _outOfBoundsY = (_b < 0) || (_b >= _gridWidth);
        //     if (!(_x isEqualTo [0,0]) && !_outOfBoundsX && !_outOfBoundsY) then { // skipCenter and outer boundries
        //         _neighbors pushback _neighIndex;  
        //     };
        // } foreach _neighRelArray;
        
        /////// GET NEIGHBORS LAYER 2 ///////
        // {
        //     private _subSector = _x select 1;
        //     {
        //         // Create Neighbor Index 
        //         private _a = ((_subSector select 0) select 0) + (_x select 0);
        //         private _b = ((_subSector select 0) select 1) + (_x select 1);
        //         private _subNeighIndex = [_a,_b];
        //         private _outOfBoundsX = (_a < 0) || (_a == (_gridWidth*_inc)+1);
        //         private _outOfBoundsY = (_b < 0) || (_b == (_gridWidth*_inc)+1);
        //         if (!(_x isEqualTo [0,0]) && !_outOfBoundsX && !_outOfBoundsY) then { // skipCenter and outer boundries
        //             (_subSector select 4) pushback _subNeighIndex;  
        //         };
        //     } foreach _neighRelArray;
        // } foreach _subSectors;
        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        ////// ROAD ANALYSIS //////
        private _roadModifier = 0;
        private _hasRoads = false;
        private _hasTrails = false;
        private _hasBridge = false;
        {
            private _roadData = [_x select 1,_subSectorRadius] call _fnc_getRoadModifier;
            if (_roadModifier < _roadData select 0) then {_roadModifier = _roadData select 0};
            if (_roadData select 1) then {_hasRoads = true;};
            if (_roadData select 2) then {_hasTrails = true;};
            if (_roadData select 3) then {_hasBridge = true;};
        } foreach _subSectors;

        private _roadModData = [_hasRoads,_hasTrails,_hasBridge,_roadModifier];
        _modifiers pushback _roadModData;

        private _numLandAreas = 0.01;
        private _numWaterAreas = 0.01;
        ////// WATER / HEIGHT ANALYSIS //////
        private _sumHeightASL = 0;
        private _sumWaterModifier = 0;
        private _hasWater = false;
        private _isEntirelyWater = true;

        //// WATER - Grid Compression - use single array ref for 'Water' sectors to compress memory
        _waterSectorArray = [[-1,-1], [-1,-1], [-1,-1], "WATER",[[false,false,false,0],[true,1],-99,0]];
        ////

        {
            private _heightData = [_x select 1,_subSectorRadius] call _fnc_getHeightWaterModifier;
            if (_heightData select 0) then {
                _numWaterAreas = _numWaterAreas + 1;
                _sumWaterModifier = _sumWaterModifier + 1;
                _hasWater = true;
                _x set [1,_waterSectorArray]; // For compression
            } else {
                if ((_heightData select 1) > 0) then {
                    _sumWaterModifier = _sumWaterModifier + (_heightData select 1);
                    _numWaterAreas = _numWaterAreas + 1;
                    _hasWater = true;
                };
                if ((_heightData select 2) > 0) then {_numLandAreas = _numLandAreas + 1;};
                _isEntirelyWater = false;
            };
            _sumHeightASL = _sumHeightASL + (_heightData select 2);
        } foreach _subSectors;

        // for compression
        if (_isEntirelyWater) exitwith { _sector = [_index,_waterSectorArray]; _result = [_sector, _subSectors]; };
 
        private _waterModData = [_hasWater, _sumWaterModifier/_numWaterAreas];
        _modifiers pushback _waterModData;
        _modifiers pushback (_sumHeightASL/(count _subsectors)); //Height Data

        /////// ROUGHNESS ANALYSIS ///////
        private _sumDensityModifier = 0;
        private _densitySizeAdjust = (_subSectorSize * _subSectorSize) / 2500; // default procedure values are based on 50 x 50 sub grid - this adjusts for different subSector area size
        private _searchArray = ["tree","rock","house","building","fence","wall"];
        {
            private _subSector = _x select 1;
            private _sPos = _subSector select 2; // Center
            if (_subSector select 3 != "WATER") then {
                private _subDensityModifier = count nearestTerrainObjects [_sPos, _searchArray, _subSectorRadius, false];
                (_subSector select 4) pushback _subDensityModifier * _densitySizeAdjust;
                _sumDensityModifier = _sumDensityModifier + _subDensityModifier * _densitySizeAdjust;
            };
        } foreach _subSectors;
        _modifiers pushback (_sumDensityModifier/_numLandAreas);


        /////// SET TYPE IF NOT LAND ///////
        if (_isEntirelyWater) then {_type = "WATER";};
        if (_hasWater && !_isEntirelyWater) then {_type = "COAST";};
        if (_hasBridge) then {_type = "BRIDGE";};

        _sector = [_index,[_index, _posRef, _posCenter, _type, _modifiers]];

        _result = [_sector, _subSectors];
        
    };

    case "createSectorDebugMarker" : {

        _args params ["_sector","_size"];
        _sector params ["_index", "_posRef", "_posCenter", "_type", "_modifiers"];
        _modifiers params ["_road","_water","_height","_density"];
        _road params ["_hasRoads","_hasTrails","_hasBridge","_roadModifier"];
        _water params ["_hasWater","_waterModifier"];
        
        _m = createMarker [str _posCenter, _posCenter];
        _m setMarkerShape "RECTANGLE";
        _m setMarkerSize [_size/2,_size/2];
        _m setMarkerAlpha 0.6;
        _m setMarkerColor "ColorYellow";
        switch (_type) do {
            case "LAND": {
                if (_roadModifier > 0) then {
                    if (_hasRoads) then {
                        //_m setMarkerAlpha 0.6; 
                    } else { _m setMarkerAlpha 0.3;};
                } else {_m setMarkerColor "ColorGreen";};
            };
            case "WATER": {
                _m setMarkerColor "ColorBlue";
            };
            case "COAST": {
                _m setMarkerColor "ColorWEST";
            };
            case "BRIDGE": {
                _m setMarkerColor "ColorOrange";
            };
        };

        _m = createMarker [str str _posCenter, [(_posCenter select 0)-40,(_posCenter select 1)+150]];
        _m setMarkerShape "ICON";
        _m setMarkerType "hd_dot";
        _m setMarkerSize [0.05,0.05];
        _m setMarkerColor "ColorWhite";
        _m setMarkerAlpha 0.6;
        _mtext = format ["%1", _index];
        _m setMarkerText _mtext;

        _m = createMarker [str str str _posCenter, [(_posCenter select 0)-200,(_posCenter select 1)+50]];
        _m setMarkerShape "ICON";
        _m setMarkerType "hd_dot";
        _m setMarkerSize [0.05,0.05];
        _m setMarkerColor "ColorBrown";
        _m setMarkerAlpha 0.6;
        _mtext = format ["[H:%1|R:%2|D:%3|W:%4]", _height toFixed 2, _roadModifier toFixed 2, _density toFixed 2, _waterModifier toFixed 2];
        _m setMarkerText _mtext;

        _result = [str _posCenter, str str _posCenter, str str str _posCenter];
    };
};

if (isnil "_result") then {nil} else {_result};