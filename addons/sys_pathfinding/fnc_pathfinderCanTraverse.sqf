#include "\x\alive\addons\sys_pathfinding\script_component.hpp"

params ["_procedure", "_sectorTo", "_sectorFrom", "_size", "_waterEdgeCache"];

PROFILE_SCOPE(PFTRSETUP, "ALiVE pathfinder traversal: setup and early rejection")

PROFILE_SCOPE(PFTRCAPS, "ALiVE pathfinder traversal: capabilities and air-naval exits")

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
    private _answer = if (_typeTo == "LAND") then {0} else {2};
    _answer
};

PROFILE_SCOPE_END(PFTRCAPS)
PROFILE_SCOPE(PFTRDEST, "ALiVE pathfinder traversal: destination water rejection")

// Preserve the air/naval early-outs above. Land-capable procedures cannot
// end in deep water, regardless of roads, bridges, or the crossing result.
// Reject before unpacking the source or looking up/sampling the water edge.
private _modifiersTo = _sectorTo select 4;
private _water = _modifiersTo select 1;
private _centreHeightTo = _water select 2;
if (
    _canTraverseLand
    && {_centreHeightTo < (ALiVE_pathfinding_seaLevel - ALiVE_pathfinding_waterMargin)}
) exitWith {0};

PROFILE_SCOPE_END(PFTRDEST)
PROFILE_SCOPE(PFTRUNPACK, "ALiVE pathfinder traversal: edge context setup")

private _typeFrom = _sectorFrom select 3;

private _canTraverse = false;
private _isWaterCrossing = false;
private _waterDistance = 0;
private _isMovingToFromBridge = (_typeTo == "BRIDGE" || _typeFrom == "BRIDGE") && {((_procedure select 3) select 0) < 0};

PROFILE_SCOPE_END(PFTRUNPACK)
PROFILE_SCOPE_END(PFTRSETUP)

// Cell modifiers cache endpoint water, but a dry LAND -> LAND edge can still
// cross a narrow inlet between the sampled cell interiors. The cache is scoped
// by sea level, water margin, and layer size by its caller.
if (!_isMovingToFromBridge && {_canTraverseLand}) then {
    PROFILE_SCOPE(PFTRLOOKUP, "ALiVE pathfinder traversal: water-edge lookup")
    private _indxFrom = _sectorFrom select 0;
    private _indxTo = _sectorTo select 0;
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
    PROFILE_SCOPE(PFTRGET, "ALiVE pathfinder traversal: water-cache get")
    private _waterData = _waterEdgeCache get _edgeKey;
    PROFILE_SCOPE_END(PFTRGET)
    PROFILE_SCOPE_END(PFTRLOOKUP)

    if (isNil "_waterData") then {
        PROFILE_SCOPE(PFTRMISS, "ALiVE pathfinder traversal: water-edge cache miss")
        // Cached edges already contain the crossing result. Only a cache miss
        // needs endpoint positions and the conditions for terrain sampling.
        PROFILE_SCOPE(PFTRMISSPREP, "ALiVE pathfinder traversal: cache-miss preparation")
        private _centerPosTo = _sectorTo select 2;
        private _centerPosFrom = _sectorFrom select 2;
        private _needsSpanCheck = (_typeTo == "COAST" || {_typeFrom == "COAST"})
            && {((_water select 1) > 0.4) || {(((_sectorFrom select 4) select 1) select 1) > 0.4}};
        PROFILE_SCOPE_END(PFTRMISSPREP)
        if (!_needsSpanCheck) then {
            PROFILE_SCOPE(PFTRMIDPOINT, "ALiVE pathfinder traversal: midpoint sampling")
            private _midpoint = [
                ((_centerPosFrom select 0) + (_centerPosTo select 0)) / 2,
                ((_centerPosFrom select 1) + (_centerPosTo select 1)) / 2
            ];
            _needsSpanCheck = (getTerrainHeightASL _midpoint)
                < (ALiVE_pathfinding_seaLevel - ALiVE_pathfinding_waterMargin);
        };

        _waterData = if (_needsSpanCheck) then {
            PROFILE_SCOPE(PFTRSPAN, "ALiVE pathfinder traversal: full water-span sampling")
            [_centerPosFrom, _centerPosTo] call ALiVE_fnc_pathfinderCheckCoastTravelForWater
        } else {
            PROFILE_SCOPE(PFTRDRY, "ALiVE pathfinder traversal: dry-edge result allocation")
            [false, 0]
        };
        PROFILE_SCOPE(PFTRINSERT, "ALiVE pathfinder traversal: water-cache insertion")
        _waterEdgeCache set [_edgeKey, _waterData];
        PROFILE_SCOPE_END(PFTRINSERT)
    };

    _isWaterCrossing = _waterData select 0;
    _waterDistance = _waterData select 1;
};

PROFILE_SCOPE(PFTRTERRAIN, "ALiVE pathfinder traversal: terrain and capability checks")

// Non-land water-capable procedures treat every non-land destination as water.
if (_canTraverseWater && {!_canTraverseLand} && {_typeTo != "LAND"}) then {
    _isWaterCrossing = true;
};

if (!_isWaterCrossing) then {
    switch (_typeTo) do {
        case "LAND": {
            private _road = _modifiersTo select 0;
            if (_canTraverseRoads && {_road select 0}) then {_canTraverse = true;};
            if (_canTraverseTrails && {_road select 1}) then {_canTraverse = true;};
            // Only the terrain fallback needs density/slope limits and heights.
            if (!_canTraverse && {_canTraverseLand}) then {
                PROFILE_SCOPE(PFTRFALLBACKLAND, "ALiVE pathfinder traversal: LAND terrain fallback")
                private _limits = _procedure select 2;
                private _maxDensity = _limits select 1;
                _canTraverse = _maxDensity != 0
                    && {(_modifiersTo select 3) < _maxDensity}
                    && {(abs ((_modifiersTo select 2) - ((_sectorFrom select 4) select 2)) / _size) < (_limits select 0)};
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
            private _road = _modifiersTo select 0;
            if (_canTraverseRoads && {_road select 0}) then {_canTraverse = true;};
            if (_canTraverseTrails && {_road select 1}) then {_canTraverse = true;};
            // Only the terrain fallback needs density/slope limits and heights.
            if (!_canTraverse && {_canTraverseLand} && {(_water select 1) < 0.4}) then {
                PROFILE_SCOPE(PFTRFALLBACKCOAST, "ALiVE pathfinder traversal: COAST terrain fallback")
                private _limits = _procedure select 2;
                private _maxDensity = _limits select 1;
                _canTraverse = _maxDensity != 0
                    && {(_modifiersTo select 3) < _maxDensity}
                    && {(abs ((_modifiersTo select 2) - ((_sectorFrom select 4) select 2)) / _size) < (_limits select 0)};
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

PROFILE_SCOPE_END(PFTRTERRAIN)

if (!_canTraverse) exitWith {0};
if (_isWaterCrossing) then {2} else {1}
