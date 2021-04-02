params ["_index","_pos","_size","_halfSize"];

private _center = _pos vectorAdd _halfSize;
private _roads = count (_center nearRoads ((_size select 0) * 0.6)) > 0;

private _isLand = !(surfaceIsWater _center) || {!(surfaceIsWater _pos)} || {!(surfaceIsWater (_pos vectoradd _size))};

_sector = [_index, _pos, _roads, _isLand, -1, []];

// debug

/*
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
*/

//_m = createMarker [str str _pos, _pos];
//_m setMarkerShape "ICON";
//_m setMarkerType "hd_dot";
//_m setMarkerSize [0.05,0.05];
//_m setMarkerColor "ColorBlack";
//_m setMarkerText (format ["(%1,%2)", _index select 0, _index select 1]);

_sector