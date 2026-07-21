// NEO_fnc_radioGridToPos
// #630 Convert an 8-digit numeric grid string ("eeeennnn", 4 easting + 4 northing) into a world [x,y,0] that
// matches what mapGridPosition shows on the CURRENTLY loaded map. Returns [] on failure so callers
// can distinguish a bad/unresolvable grid from a legitimate 00000000.
//
// Reads CfgWorlds >> Grid at runtime rather than assuming easting*10/northing*10 - on every stock map
// (Altis/Stratis/Tanoa/Malden) the grid has offsetY = mapSize and a NEGATIVE stepY, so grid northing is
// inverted vs raw world Y; a naive multiply would mirror the point north-south.
// Params: 0: _grid <STRING> exactly 8 digits
// Author: Jman
params [["_grid", "", [""]]];

// --- validate the raw string BEFORE parseNumber (parseNumber never errors - returns 0 for garbage,
//     truncates at the first bad char - so length + char-class must be checked here) ---------------
if (count _grid != 8) exitWith { [] }; // 8-digit grids only (4 easting + 4 northing, 10m precision)
private _numeric = true;
{ if (_x < 48 || _x > 57) exitWith { _numeric = false } } forEach (toArray _grid);
if (!_numeric) exitWith { [] };

private _isDigitsOnly = {
    private _ok = (count _this) > 0;
    { if (_x < 48 || _x > 57) exitWith { _ok = false } } forEach (toArray _this);
    _ok
};

// --- pick the finest purely-numeric grid definition on this world -------------------------------
private _gridCfg = configFile >> "CfgWorlds" >> worldName >> "Grid";
private _best = configNull;
private _bestStep = 1e9;
{
    if ((getText (_x >> "formatX")) call _isDigitsOnly && {(getText (_x >> "formatY")) call _isDigitsOnly}) then {
        private _step = abs (getNumber (_x >> "stepX"));
        if (_step > 0 && {_step < _bestStep}) then { _bestStep = _step; _best = _x };
    };
} forEach ("true" configClasses _gridCfg);

// fallback: some minimal configs define step/format directly on the Grid class (no zoom sub-classes)
if (isNull _best && {(getText (_gridCfg >> "formatX")) call _isDigitsOnly} && {abs (getNumber (_gridCfg >> "stepX")) > 0}) then {
    _best = _gridCfg;
};
if (isNull _best) exitWith { [] }; // no numeric grid on this terrain (letter-based / missing)

private _refDigits = count (getText (_best >> "formatX"));   // e.g. 3 -> "000" (standard 6-digit map)
private _stepX     = getNumber (_best >> "stepX");            // e.g. 100
private _stepY     = getNumber (_best >> "stepY");            // e.g. -100 (KEEP the sign)
private _offsetX   = getNumber (_gridCfg >> "offsetX");       // e.g. 0
private _offsetY   = getNumber (_gridCfg >> "offsetY");       // e.g. mapSize, NOT 0

// --- split 4+4, scale from the map's own reference precision, centre in the cell -----------------
private _halfLen   = (count _grid) / 2;              // 4
private _fineStepX = _stepX / (10 ^ (_halfLen - _refDigits));
private _fineStepY = _stepY / (10 ^ (_halfLen - _refDigits));

private _easting  = parseNumber (_grid select [0, _halfLen]);
private _northing = parseNumber (_grid select [_halfLen, _halfLen]);

// + half a fine cell to land in the MIDDLE of the typed square (mirrors x_lib ALIVE_fnc_gridPos)
private _worldX = _offsetX + (_easting  * _fineStepX) + (_fineStepX / 2);
private _worldY = _offsetY + (_northing * _fineStepY) + (_fineStepY / 2);
private _pos = [_worldX, _worldY, 0];

// Northing direction differs per map (Altis inverts it via offsetY=mapSize + negative stepY, Stratis
// and others do not). Verify against the engine's OWN grid - exactly what the map lines show - and
// mirror worldY around the map if the northing came out flipped. Self-correcting, no per-map guessing.
private _worldSize = worldSize; // the SQF command (terrain size in m) - NOT a config entry
if (_worldSize > 0) then {
    private _got = mapGridPosition _pos;
    private _gh  = (count _got) / 2;
    if (_gh > 0) then {
        private _cmp = _gh min _halfLen;
        if ((_grid select [_halfLen, _cmp]) != (_got select [_gh, _cmp])) then {
            _pos set [1, _worldSize - _worldY];
        };
    };
};

_pos
