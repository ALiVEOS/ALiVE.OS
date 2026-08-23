
    params ["_sectorAPos","_sectorBPos"];
    private _waterTravel = false;
    private _dist = _sectorAPos distance _sectorBPos;
    private _inc = ceil(_dist / 15);
    private _stepDistance = _dist / _inc;
    private _waterDistance = 0;
    private _seaLevel = missionNamespace getVariable ["ALiVE_pathfinding_seaLevel", 0];
    private _a = ((_sectorBPos select 0) - (_sectorAPos select 0)) / _inc;
    private _b = ((_sectorBPos select 1) - (_sectorAPos select 1)) / _inc;

    for "_i" from 0 to _inc do {
        if (getTerrainHeightASL [(_sectorAPos select 0) + (_a*_i),(_sectorAPos select 1) + (_b*_i)] < _seaLevel) then {
            _waterTravel = true;
            // Accumulate the WATER SPAN in metres - each underwater sample covers
            // one step of ~_dist/_inc m (~15 m). (Was "+ _inc", the step COUNT not
            // a length, which made _waterDistance far too small at subsector scale
            // and defeated the "_waterDistance < 100" ford limit - letting land
            // units cross wide open water.)
            _waterDistance = _waterDistance + _stepDistance;
        };

        // // _debugMarkers = _logic get "pathDebugMarkers";
        // _m = createMarker [str str str str str str str  [(_sectorAPos select 0) + (_a*_i),(_sectorAPos select 1) + (_b*_i)], [(_sectorAPos select 0) + (_a*_i),(_sectorAPos select 1) + (_b*_i)]];
        // // _debugMarkers pushback  str str str str str str str [(_sectorAPos select 0) + (_a*_i),(_sectorAPos select 1) + (_b*_i)];
        // _m setMarkerShape "ICON";
        // _m setMarkerType "hd_dot";
        // _m setMarkerSize [0.3,0.3];
        // _m setMarkerAlpha 0.5;
        // _m setMarkerColor "ColorBlue";
    };
    
    [_waterTravel,_waterDistance];
