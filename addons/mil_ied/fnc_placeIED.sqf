#include "\x\alive\addons\mil_ied\script_component.hpp"
SCRIPT(placeIED);

// Find suitable spot for IED
// Pass location and booleans to look for roads, objects, entrances
// Returns an array of validated positions

/* IMPROVED VERSION v2.0:
   - Validates terrain slope (flat terrain only)
   - Checks proximity between positions
   - Filters out water positions
   - Prioritizes tactical placement locations
   - NEW: Building interior detection (prevents indoor spawns)
   - NEW: Chokepoint detection (bridges, narrow roads get priority)
   - NEW: Concealment scoring (prefers hidden positions)
*/

private ["_addroads","_addobjects","_addentrances","_goodspots","_location","_size"];

_location = _this select 0;
_addroads = _this select 1;
_addobjects = _this select 2;
_addentrances = _this select 3;
_size = _this select 4;

_goodspots = [];
_candidateSpots = []; // Initial candidates before validation

// ============================================================================
// PHASE 1: IDENTIFY CHOKEPOINTS (HIGH-VALUE TARGETS)
// ============================================================================
private ["_chokepoints","_chokepointPositions"];
_chokepoints = [];
_chokepointPositions = [];

// Shared offset helper: returns [X,Y,Z] offset from _base by _dist metres
// along compass bearing _bearing (degrees). Z is preserved from _base.
private _fnOffset = {
    params ["_base", "_bearing", "_dist"];
    private _rad = _bearing * (pi / 180);
    [
        (_base select 0) + (_dist * sin _rad),
        (_base select 1) + (_dist * cos _rad),
        _base select 2
    ]
};

// Shared width helper: derives road half-width from getRoadInfo, falling back
// by road type when the width index is missing or implausible. getRoadInfo
// returns [type, width, isPaved, isLimited, texture] but width is unreliable
// on modded maps - defaulting purely to 6m is too tight for MAIN ROAD.
private _fnHalfWidth = {
    params ["_road"];
    private _info  = getRoadInfo _road;
    private _type  = if (count _info > 0) then { toUpper (_info select 0) } else { "" };
    private _width = if (count _info > 1 && { (_info select 1) > 1 }) then {
        _info select 1
    } else {
        switch (_type) do {
            case "MAIN ROAD": { 10 };
            case "ROAD":      { 7 };
            case "TRACK":     { 4 };
            default           { 6 };
        };
    };
    (_width / 2) max 3
};

if (_addroads) then {
    // Find tactical chokepoints (bridges, narrow roads, etc.)
    _chokepoints = ["findChokepoints", [_location, _size]] call ALIVE_fnc_IEDPlacementHelpers;

    // Extract top chokepoint positions and add with VERY high weight
    private ["_maxChokepoints","_count"];
    _maxChokepoints = 10; // Limit to top 10 chokepoints
    _count = (count _chokepoints) min _maxChokepoints;

    for "_i" from 0 to (_count - 1) do {
        private ["_chokepointData","_chokepointPos","_score","_chokepointRoad"];
        _chokepointData = _chokepoints select _i;
        _chokepointPos  = _chokepointData select 0;  // raw road centre
        _score          = _chokepointData select 1;
        _chokepointRoad = if (count _chokepointData > 2) then { _chokepointData select 2 } else { objNull };

        // Store road centre for chokepoint overlap-checks
        _chokepointPositions pushBack _chokepointPos;

        // Resolve the road object so we can offset truly perpendicular to the
        // carriageway. Absolute-bearing offsets (N/E/S/W) can land ON the road
        // when it runs diagonally - we need the road's own direction vector.
        if (isNull _chokepointRoad) then {
            private _nearby = _chokepointPos nearRoads 5;
            if (count _nearby > 0) then { _chokepointRoad = _nearby select 0; };
        };

        private _heading = if (!isNull _chokepointRoad) then { direction _chokepointRoad } else { 0 };
        private _halfWidth = if (!isNull _chokepointRoad) then {
            [_chokepointRoad] call _fnHalfWidth
        } else {
            3  // conservative fallback when no road object resolvable
        };

        // Verge band identical to regular roads - halfWidth + 1m clear, +0..3m scatter
        private _vergeMin = _halfWidth + 1.0;
        private _vergeMax = _halfWidth + 4.0;

        private _offsetsCP = [
            [_chokepointPos, _heading + 90, _vergeMin + random (_vergeMax - _vergeMin)] call _fnOffset,
            [_chokepointPos, _heading - 90, _vergeMin + random (_vergeMax - _vergeMin)] call _fnOffset
        ];

        // Add offsets with weight based on score (same weighting as before)
        private _weight = 2;
        if (_score >= 80) then { _weight = 6; } else {
            if (_score >= 50) then { _weight = 4; };
        };

        for "_w" from 1 to _weight do {
            { _candidateSpots pushBack _x; } forEach _offsetsCP;
        };
    };

    if (ADDON getVariable ["debug", false]) then {
        ["ALIVE-IED placeIED: Found %1 chokepoints, using top %2", count _chokepoints, _count] call ALiVE_fnc_dump;
    };
};

// ============================================================================
// PHASE 2: GATHER OTHER CANDIDATES
// ============================================================================

// Look for objects
If (_addobjects) then {
    private ["_spottype"];
    // broken fences, low walls, garbage, garbage containers, gates, rubble
    _spottype = ["Land_JunkPile_F","Land_GarbageContainer_closed_F","Land_GarbageBags_F","Land_Tyres_F","Land_GarbagePallet_F","Land_Pallets_F","Land_Ancient_Wall_8m_F","Land_City_8mD_F","Land_City2_8mD_F","Land_Wreck_HMMWV_F","Land_Wreck_Hunter_F","Land_Mil_WallBig_Gate_F","Land_Stone_Gate_F","Land_Mil_WiredFenceD_F","Land_Net_Fence_Gate_F","Land_Stone_8mD_F","Land_Wired_Fence_8mD_F","Land_Wall_IndCnc_4_D_F","Land_Wall_IndCnc_End_2_F","Land_Net_FenceD_8m_F","Land_New_WiredFence_10m_Dam_F"];
    {
        _candidateSpots pushback (getposATL  _x);
    } foreach nearestobjects [_location,_spottype,_size];
};

// Look for building entrances
If (_addentrances) then {
    // Get first building position (entrance) for each building within range
    {
        _candidateSpots pushback (getposATL  _x);
    } foreach (nearestobjects [_location ,["House"],_size]);
};

// Look for roads - Add regular roads (not chokepoints) with standard weight
If (_addroads) then {
    private _allRoads = _location nearRoads _size;

    {
        private _road    = _x;
        private _roadPos = getposATL _road;

        // Check if this road is already a chokepoint
        private _isChokepoint = false;
        {
            if (_roadPos distance _x < 15) exitWith { _isChokepoint = true; };
        } forEach _chokepointPositions;

        if (!_isChokepoint) then {
            // Compute perpendicular offsets that clear the carriageway.
            // Road centres are mid-carriageway; offsets must exceed the road
            // half-width to land on the verge. Half-width is derived with
            // type-aware fallbacks so a missing getRoadInfo width doesn't
            // leave MAIN ROAD offsets in the tarmac.
            private _halfWidth = [_road] call _fnHalfWidth;

            // Verge band: halfWidth + 1m minimum clear, +0-3m random scatter
            private _vergeMin  = _halfWidth + 1.0;
            private _vergeMax  = _halfWidth + 4.0;

            private _heading = direction _road;
            private _perpL   = _heading + 90;
            private _perpR   = _heading - 90;

            // Primary verge - fully clear of road, both sides (3x weight each)
            private _offsetL1 = [_roadPos, _perpL, _vergeMin + random (_vergeMax - _vergeMin)] call _fnOffset;
            private _offsetR1 = [_roadPos, _perpR, _vergeMin + random (_vergeMax - _vergeMin)] call _fnOffset;
            for "_w" from 1 to 3 do {
                _candidateSpots pushBack _offsetL1;
                _candidateSpots pushBack _offsetR1;
            };

            // Outer verge - slightly further out for better concealment (2x weight each)
            private _outerDist = _vergeMax + random 2.0;
            private _offsetL2 = [_roadPos, _perpL, _outerDist] call _fnOffset;
            private _offsetR2 = [_roadPos, _perpR, _outerDist] call _fnOffset;
            _candidateSpots pushBack _offsetL2;
            _candidateSpots pushBack _offsetL2;
            _candidateSpots pushBack _offsetR2;
            _candidateSpots pushBack _offsetR2;

            // NOTE: road centre is deliberately NOT added as a fallback candidate.
            // A bare IED on the tarmac is trivially spotted; better to place no
            // IED here than an obvious one. If every verge offset fails validation
            // this road segment is simply skipped.
        };

    } forEach _allRoads;
};

// ============================================================================
// PHASE 3: VALIDATION & SCORING
// ============================================================================
private ["_maxSlope","_minProximity","_minConcealmentScore"];

_maxSlope = 15; // Maximum terrain slope in degrees
_minProximity = 40; // Minimum distance between IEDs in metres — spreads them across the town

// DYNAMIC CONCEALMENT SCORING - Adapts to terrain type
// Check ALiVE map composition type and set appropriate minimum concealment
private ["_terrainType","_minConcealmentScore"];
_terrainType = missionNamespace getVariable ["ALiVE_mapCompositionType", "Unknown"];

switch (_terrainType) do {
    case "Desert": {
        _minConcealmentScore = 0; // Desert: Very permissive (little natural cover)
    };
    case "Pacific": {
        _minConcealmentScore = 0; // Pacific/Tropical: Permissive (mixed terrain)
    };
    case "Urban": {
        _minConcealmentScore = 5; // Urban: Slightly strict (expect some building/object cover)
    };
    case "Woodland": {
        _minConcealmentScore = 15; // Woodland: Strict (expect vegetation/natural cover)
    };
    default {
        _minConcealmentScore = 0; // Unknown terrain: Permissive (safe default)
        if (ADDON getVariable ["debug", false]) then {
            ["ALIVE-IED: Unknown terrain type '%1', using permissive concealment (0)", _terrainType] call ALiVE_fnc_dump;
        };
    };
};

if (ADDON getVariable ["debug", false]) then {
    ["ALIVE-IED: Terrain type '%1', minimum concealment score set to %2", _terrainType, _minConcealmentScore] call ALiVE_fnc_dump;
};

{
    private ["_pos","_isValid","_terrainNormal","_slopeAngle","_concealmentScore","_isOutside"];
    _pos = _x;
    _isValid = true;
    
    // Check 1: Not in water
    if (surfaceIsWater _pos) then {
        _isValid = false;
        if (ADDON getVariable ["debug", false]) then {
            ["ALIVE-IED: Position rejected (water) at %1", _pos] call ALiVE_fnc_dump;
        };
    };

    // Check 1b: Not on road surface (safety net)
    // Even with correct perpendicular offsets, intersections/overpasses/roundabouts
    // can place the offset on a neighbouring road. Reject those outright so the
    // IED never ends up on visible tarmac.
    if (_isValid && isOnRoad _pos) then {
        _isValid = false;
        if (ADDON getVariable ["debug", false]) then {
            ["ALIVE-IED: Position rejected (still on road after offset) at %1", _pos] call ALiVE_fnc_dump;
        };
    };

    // Check 2: Terrain slope validation (flat terrain only)
    if (_isValid) then {
        _terrainNormal = surfaceNormal _pos;
        _slopeAngle = acos (_terrainNormal select 2);
        
        if (_slopeAngle > _maxSlope) then {
            _isValid = false;
            if (ADDON getVariable ["debug", false]) then {
                ["ALIVE-IED: Position rejected (slope %.1f°) at %2", _slopeAngle, _pos] call ALiVE_fnc_dump;
            };
        };
    };
    
    // Check 3: Building interior check (NEW FEATURE)
    if (_isValid) then {
        _isOutside = ["isPositionOutside", [_pos]] call ALIVE_fnc_IEDPlacementHelpers;
        
        if (!_isOutside) then {
            _isValid = false;
            if (ADDON getVariable ["debug", false]) then {
                ["ALIVE-IED: Position rejected (inside building) at %1", _pos] call ALiVE_fnc_dump;
            };
        };
    };
    
    // Check 4: Concealment score (NEW FEATURE)
    if (_isValid) then {
        _concealmentScore = ["getConcealmentScore", [_pos]] call ALIVE_fnc_IEDPlacementHelpers;
        
        // Reject positions that are too exposed
        if (_concealmentScore < _minConcealmentScore) then {
            _isValid = false;
            if (ADDON getVariable ["debug", false]) then {
                ["ALIVE-IED: Position rejected (too exposed, score %1) at %2", _concealmentScore, _pos] call ALiVE_fnc_dump;
            };
        } else {
            // Log good concealment
            if (ADDON getVariable ["debug", false]) then {
                if (_concealmentScore > 50) then {
                    ["ALIVE-IED: Good concealment (score %1) at %2", _concealmentScore, _pos] call ALiVE_fnc_dump;
                };
            };
        };
    };
    
    // Check 5: Proximity to already validated positions
    if (_isValid && count _goodspots > 0) then {
        {
            if (_pos distance _x < _minProximity) exitWith {
                _isValid = false;
                if (ADDON getVariable ["debug", false]) then {
                    ["ALIVE-IED: Position rejected (too close to existing IED) at %1", _pos] call ALiVE_fnc_dump;
                };
            };
        } forEach _goodspots;
    };
    
    // If position passed all checks, add to good spots
    if (_isValid) then {
        _goodspots pushback _pos;
    };
    
} forEach _candidateSpots;

// ============================================================================
// PHASE 4: FINAL SORTING (Optional - prioritize by concealment)
// ============================================================================
// Sort validated positions by concealment score (best first)
private ["_scoredPositions"];
_scoredPositions = [];

{
    private ["_pos","_score"];
    _pos = _x;
    _score = ["getConcealmentScore", [_pos]] call ALIVE_fnc_IEDPlacementHelpers;
    _scoredPositions pushBack [_score, _pos]; // score first so array sort uses score, not position X
} forEach _goodspots;

// Sort by score descending (highest concealment first)
_scoredPositions sort false;

// Extract just the positions (index 1 now, since score is index 0)
_goodspots = [];
{
    _goodspots pushBack (_x select 1);
} forEach _scoredPositions;

// Debug output
if (ADDON getVariable ["debug", false]) then {
    private ["_chokepointCount","_regularCount"];
    _chokepointCount = count _chokepointPositions;
    _regularCount = (count _candidateSpots) - (_chokepointCount * 4); // Approximate
    
    ["ALIVE-IED placeIED: Found %1 chokepoints, %2 regular candidates, validated %3 positions", 
        _chokepointCount, 
        _regularCount, 
        count _goodspots
    ] call ALiVE_fnc_dump;
    
    // Warn clearly if no candidates were found at all
    if (count _candidateSpots == 0) then {
        ["ALIVE-IED placeIED: WARNING - zero candidate spots found at %1 (no roads/objects/entrances in range?)", _location] call ALiVE_fnc_dump;
    };
    
    // Log top 3 positions with concealment scores
    private ["_topCount"];
    _topCount = (count _scoredPositions) min 3;
    for "_i" from 0 to (_topCount - 1) do {
        private ["_data","_pos","_score"];
        _data = _scoredPositions select _i;
        _score = _data select 0;
        _pos = _data select 1;
        ["ALIVE-IED: Top position #%1: Concealment score %2 at %3", _i + 1, _score, _pos] call ALiVE_fnc_dump;
    };
};

_goodspots
