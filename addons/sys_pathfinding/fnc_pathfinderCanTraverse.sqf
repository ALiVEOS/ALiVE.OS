params ["_procedure", "_sectorTo", "_sectorFrom", "_size", "_waterEdgeCache"];

private _capabilities = _procedure select 1;
private _canTraverseLand = _capabilities select 0;
private _canTraverseTrails = _capabilities select 1;
private _canTraverseRoads = _capabilities select 2;
private _canTraverseWater = _capabilities select 3;
private _canTraverseAir = _capabilities select 4;

// Air procedures are unrestricted. Exit before unpacking either sector.
if (_canTraverseAir) exitWith {1};

private _typeTo = _sectorTo select 3;

// The default naval procedure has no land, trail, or road capability. Its full
// traversal decision depends only on the destination type.
if (
    !_canTraverseLand
    && {_canTraverseWater}
    && {!_canTraverseTrails}
    && {!_canTraverseRoads}
) exitWith {
    if (_typeTo == "LAND") then {0} else {2}
};

private _limits = _procedure select 2;
private _maxSlope = _limits select 0;
private _maxDensity = _limits select 1;
private _roadWeight = (_procedure select 3) select 0;

private _indxTo = _sectorTo select 0;
private _centerPosTo = _sectorTo select 2;
private _modifiersTo = _sectorTo select 4;

private _road = _modifiersTo select 0;
private _water = _modifiersTo select 1;
private _height = _modifiersTo select 2;
private _density = _modifiersTo select 3;

private _hasRoads = _road select 0;
private _hasTrails = _road select 1;

private _waterModifier = _water select 1;
private _centreHeightTo = _water select 2;

private _indxFrom = _sectorFrom select 0;
private _centerPosFrom = _sectorFrom select 2;
private _typeFrom = _sectorFrom select 3;
private _modifiersFrom = _sectorFrom select 4;

private _prevWaterModifier = ((_modifiersFrom select 1) select 1);
private _prevHeight = _modifiersFrom select 2;

private _canTraverse = false;
private _isWaterCrossing = false;
private _waterDistance = 0;
private _isCoastTravel = (_typeTo == "COAST" || _typeFrom == "COAST");
private _isMovingToFromBridge = (_typeTo == "BRIDGE" || _typeFrom == "BRIDGE") && {_roadWeight < 0};
private _hasDeepWater = (_waterModifier > 0.4) || {_prevWaterModifier > 0.4};

// Cell modifiers cache endpoint water, but a dry LAND -> LAND edge can still
// cross a narrow inlet between the sampled cell interiors. The cache is scoped
// by sea level, water margin, and layer size by its caller.
if (!_isMovingToFromBridge && {_canTraverseLand}) then {
    private _fromX = _indxFrom select 0;
    private _fromY = _indxFrom select 1;
    private _toX = _indxTo select 0;
    private _toY = _indxTo select 1;
    private _fromFirst = _fromX < _toX || {_fromX == _toX && {_fromY <= _toY}};
    private _edgeKey = if (_fromFirst) then {
        [_fromX, _fromY, _toX, _toY]
    } else {
        [_toX, _toY, _fromX, _fromY]
    };
    private _waterData = _waterEdgeCache get _edgeKey;

    if (isNil "_waterData") then {
        private _needsSpanCheck = _isCoastTravel && {_hasDeepWater};
        if (!_needsSpanCheck) then {
            private _midpoint = [
                ((_centerPosFrom select 0) + (_centerPosTo select 0)) / 2,
                ((_centerPosFrom select 1) + (_centerPosTo select 1)) / 2
            ];
            _needsSpanCheck = (getTerrainHeightASL _midpoint)
                < (ALiVE_pathfinding_seaLevel - ALiVE_pathfinding_waterMargin);
        };

        _waterData = if (_needsSpanCheck) then {
            [_centerPosFrom, _centerPosTo] call ALiVE_fnc_pathfinderCheckCoastTravelForWater
        } else {
            [false, 0]
        };
        _waterEdgeCache set [_edgeKey, _waterData];
    };

    _isWaterCrossing = _waterData select 0;
    _waterDistance = _waterData select 1;
};

// Non-land water-capable procedures treat every non-land destination as water.
if (_canTraverseWater && {!_canTraverseLand} && {_typeTo != "LAND"}) then {
    _isWaterCrossing = true;
};

if (!_isWaterCrossing) then {
    switch (_typeTo) do {
        case "LAND": {
            if (_canTraverseRoads && {_hasRoads}) then {_canTraverse = true;};
            if (_canTraverseTrails && {_hasTrails}) then {_canTraverse = true;};
            if (
                _canTraverseLand
                && {_maxDensity != 0}
                && {_density < _maxDensity}
                && {(abs (_height - _prevHeight) / _size) < _maxSlope}
            ) then {
                _canTraverse = true;
            };
        };
        case "WATER": {
            _canTraverse = _canTraverseWater && {!_canTraverseLand};
        };
        case "BRIDGE": {
            _canTraverse = true;
        };
        case "COAST": {
            _canTraverse = _canTraverseWater && {!_canTraverseLand};
            if (_canTraverseRoads && {_hasRoads}) then {_canTraverse = true;};
            if (_canTraverseTrails && {_hasTrails}) then {_canTraverse = true;};
            if (
                _canTraverseLand
                && {_waterModifier < 0.4}
                && {_maxDensity != 0}
                && {_density < _maxDensity}
                && {(abs (_height - _prevHeight) / _size) < _maxSlope}
            ) then {
                _canTraverse = true;
            };
        };
    };
} else {
    _canTraverse = if (_canTraverseLand) then {
        _canTraverseWater && {_waterDistance < 100}
    } else {
        _canTraverseWater
    };
};

// A land unit may never end a step in a genuinely deep-water cell.
if (
    _canTraverseLand
    && {_centreHeightTo < (ALiVE_pathfinding_seaLevel - ALiVE_pathfinding_waterMargin)}
) then {
    _canTraverse = false;
};

if (!_canTraverse) exitWith {0};
if (_isWaterCrossing) then {2} else {1}
