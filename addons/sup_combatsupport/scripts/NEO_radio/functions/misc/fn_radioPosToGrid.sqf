// NEO_fnc_radioPosToGrid
// #630 Format a world position as an 8-digit grid string (4 easting + 4 northing) matching the map's
// own grid, so a map-click can be reflected back into the grid input field. Inverse of
// NEO_fnc_radioGridToPos - reads CfgWorlds >> Grid at runtime (handles offsetY / negative stepY).
// Returns "" if the map has no numeric grid.
// Params: 0: _pos <ARRAY> world position [x,y(,z)]
// Author: Jman
params ["_pos"];

private _isDigitsOnly = {
    private _ok = (count _this) > 0;
    { if (_x < 48 || _x > 57) exitWith { _ok = false } } forEach (toArray _this);
    _ok
};

private _gridCfg = configFile >> "CfgWorlds" >> worldName >> "Grid";
private _best = configNull;
private _bestStep = 1e9;
{
    if ((getText (_x >> "formatX")) call _isDigitsOnly && {(getText (_x >> "formatY")) call _isDigitsOnly}) then {
        private _step = abs (getNumber (_x >> "stepX"));
        if (_step > 0 && {_step < _bestStep}) then { _bestStep = _step; _best = _x };
    };
} forEach ("true" configClasses _gridCfg);
if (isNull _best && {(getText (_gridCfg >> "formatX")) call _isDigitsOnly} && {abs (getNumber (_gridCfg >> "stepX")) > 0}) then {
    _best = _gridCfg;
};
if (isNull _best) exitWith { "" };

private _refDigits = count (getText (_best >> "formatX"));
private _stepX     = getNumber (_best >> "stepX");
private _stepY     = getNumber (_best >> "stepY");
private _offsetX   = getNumber (_gridCfg >> "offsetX");
private _offsetY   = getNumber (_gridCfg >> "offsetY");

private _halfLen   = 4; // 8-digit output
private _span      = 10 ^ _halfLen; // 10000
private _fineStepX = _stepX / (10 ^ (_halfLen - _refDigits));
private _fineStepY = _stepY / (10 ^ (_halfLen - _refDigits));

private _easting  = floor (((_pos select 0) - _offsetX) / _fineStepX);
private _northing = floor (((_pos select 1) - _offsetY) / _fineStepY);

// northing direction differs per map (see fn_radioGridToPos); verify the coarse northing against the
// engine's own grid and recompute from the mirrored Y if this map's config inverts it.
private _worldSize = worldSize; // the SQF command (terrain size in m) - NOT a config entry
if (_worldSize > 0) then {
    private _got = mapGridPosition _pos;
    private _gh  = (count _got) / 2;
    if (_gh > 0) then {
        private _myN = _northing mod _span; if (_myN < 0) then { _myN = _myN + _span };
        private _myNs = str _myN;
        while { count _myNs < _halfLen } do { _myNs = "0" + _myNs };
        private _cmp = _gh min _halfLen;
        if ((_myNs select [0, _cmp]) != (_got select [_gh, _cmp])) then {
            _northing = floor ((_worldSize - (_pos select 1) - _offsetY) / _fineStepY);
        };
    };
};

// wrap into 0..9999 (grid labels repeat every 100km zone; positive after the modulo)
_easting  = _easting  mod _span; if (_easting  < 0) then { _easting  = _easting  + _span };
_northing = _northing mod _span; if (_northing < 0) then { _northing = _northing + _span };

private _es = str _easting;
private _ns = str _northing;
while { count _es < _halfLen } do { _es = "0" + _es };
while { count _ns < _halfLen } do { _ns = "0" + _ns };

_es + _ns
