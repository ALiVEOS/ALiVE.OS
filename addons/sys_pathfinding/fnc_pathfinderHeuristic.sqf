params ["_currentSector", "_fromSector", "_procedure", "_basePriority", "_sectorDistance", ["_isWaterTravel", false]];

private _weights = _procedure select 3;

// With no weights every terrain branch returns the unmodified base priority.
// This covers Naval and Plane as well as any custom unbiased procedure.
if (_weights isEqualTo [0,0,0,0]) exitWith {_basePriority};

private _type = _currentSector select 3;
if !(_type in ["WATER", "BRIDGE", "COAST", "LAND"]) exitWith {_basePriority};

private _modifiers = _currentSector select 4;
private _roadWeight = _weights select 0;
private _waterWeight = _weights select 1;
private _heightWeight = _weights select 2;
private _densityWeight = _weights select 3;
private _modPriority = _basePriority;

// Water sectors use water and height weighting only.
if (_type == "WATER") exitWith {
    if (_waterWeight != 0) then {
        private _waterModifier = (_modifiers select 1) select 1;
        _modPriority = _modPriority + (_modPriority * _waterModifier * _waterWeight);
    };
    if (_heightWeight != 0) then {
        private _height = _modifiers select 2;
        private _prevHeight = (_fromSector select 4) select 2;
        _modPriority = _modPriority
            + (_modPriority * ((_height - _prevHeight) / _sectorDistance) * _heightWeight);
    };
    _modPriority
};

// A water crossing through a bridge or coast cell uses only water weighting.
if (_isWaterTravel && {_type == "BRIDGE" || {_type == "COAST"}}) exitWith {
    if (_waterWeight != 0) then {
        private _waterModifier = (_modifiers select 1) select 1;
        _modPriority = _modPriority + (_modPriority * _waterModifier * _waterWeight);
    };
    _modPriority
};

private _capabilities = _procedure select 1;
private _canTraverseTrails = _capabilities select 1;
private _canTraverseRoads = _capabilities select 2;
private _road = _modifiers select 0;

private _useRoadModifier = if (_type == "BRIDGE") then {
    _canTraverseRoads
} else {
    (_canTraverseRoads && {_road select 0})
        || {_canTraverseTrails && {_road select 1}}
};

if (_useRoadModifier) then {
    if (_roadWeight != 0) then {
        private _roadModifier = _road select 3;
        _modPriority = _modPriority + (_modPriority * _roadModifier * _roadWeight);
    };
} else {
    if (_heightWeight != 0) then {
        private _height = _modifiers select 2;
        private _prevHeight = (_fromSector select 4) select 2;
        _modPriority = _modPriority
            + (_modPriority * ((_height - _prevHeight) / _sectorDistance) * _heightWeight);
    };
    if (_densityWeight != 0) then {
        private _maxDensity = (_procedure select 2) select 1;
        if (_maxDensity != 0) then {
            private _densityModifier = _modifiers select 3;
            _modPriority = _modPriority
                + (_modPriority * (_densityModifier / _maxDensity) * _densityWeight);
        };
    };
};

_modPriority
