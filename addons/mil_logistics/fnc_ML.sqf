//#define DEBUG_MPDE_FULL
#include "\x\alive\addons\mil_logistics\script_component.hpp"
SCRIPT(ML);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ML
Description:
Military objectives

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Nil - init - Initiate instance
Nil - destroy - Destroy instance
Boolean - debug - Debug enabled
Array - state - Save and restore module state
Array - faction - Faction associated with module

Examples:
[_logic, "debug", true] call ALiVE_fnc_ML;

See Also:
- <ALIVE_fnc_MLInit>

Author:
ARJay & Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_ML
#define MTEMPLATE "ALiVE_ML_%1"
#define DEFAULT_FACTIONS []
#define DEFAULT_OBJECTIVES []
#define DEFAULT_EVENT_QUEUE []
#define DEFAULT_REINFORCEMENT_ANALYSIS []
#define DEFAULT_SIDE "EAST"
#define DEFAULT_FORCE_POOL_TYPE "FIXED"
#define DEFAULT_FORCE_POOL "1000"
#define DEFAULT_ALLOW true
#define DEFAULT_TYPE "DYNAMIC"
#define DEFAULT_REGISTRY_ID ""
#define PARADROP_HEIGHT 350
#define PARADROP_MIN_DROP_HEIGHT 200
#define DESTINATION_VARIANCE 150
#define DESTINATION_RADIUS 300
#define WAIT_TIME_AIR 10
#define WAIT_TIME_HELI 20
#define WAIT_TIME_MARINE 30
#define WAIT_TIME_DROP 40
#define START_FORCE_STRENGTH_INC false
#define START_FORCE_STRENGTH_INC_FACTOR "1"
#define START_FORCE_STRENGTH_DEC false
#define START_FORCE_STRENGTH_DEC_FACTOR "1"
// LZ search constants
#define LZ_MIN_CLEAR_RADIUS 5
#define LZ_OBJECT_CLEAR_RADIUS 30
#define LZ_VEHICLE_CLEAR_RADIUS 15
#define LZ_VERTICAL_CHECK_HEIGHT 35
#define LZ_MAX_GRADIENT 15
#define LZ_MAX_SEARCH_ATTEMPTS 8
#define LZ_SEARCH_RADIUS_INCREMENT 25
#define FUEL_WATCHDOG_STARTUP_DELAY 300
#define FUEL_WATCHDOG_CHECK_INTERVAL 10
#define FUEL_WATCHDOG_LOW_FUEL_THRESHOLD 0.15
#define FUEL_WATCHDOG_RECOVER_FUEL 0.5
#define FUEL_WATCHDOG_HOVER_SPEED_THRESHOLD 5
#define FUEL_WATCHDOG_MIN_HOVER_HEIGHT 5
#define MAX_GROUPS_PER_REQUEST 5
#define MAX_SLINGLOAD_CONCURRENT 3
#define DISMOUNT_RADIUS 500
#define VEHICLE_LEAD_DIST 50
// Slingload safe-drop constants
#define SLINGLOAD_DROP_HEIGHT  3    // metres AGL at which slung load is released (safe fall distance)
#define SLINGLOAD_DROP_TIMEOUT 180  // seconds to wait for heli to descend before forcing release

private ["_result"];

TRACE_1("ML - input",_this);

params [
    ["_logic", objNull, [objNull]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
_result = true;

switch(_operation) do {
    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
    case "destroy": {
        [_logic, "debug", false] call MAINCLASS;
        if (isServer) then {
            // if server
            _logic setVariable ["super", nil];
            _logic setVariable ["class", nil];
            _logic setVariable ["markers", []];

            [_logic, "destroy"] call SUPERCLASS;
        };
    };
    case "debug": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["debug", _args];
        } else {
            _args = _logic getVariable ["debug", false];
        };
        if (typeName _args == "STRING") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["debug", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "persistent": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["persistent", _args];
        } else {
            _args = _logic getVariable ["persistent", false];
        };
        if (typeName _args == "STRING") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["persistent", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "pause": {
        if(typeName _args != "BOOL") then {
            // if no new value was provided return current setting
            _args = [_logic,"pause",objNull,false] call ALIVE_fnc_OOsimpleOperation;
        } else {
                // if a new value was provided set groups list
                ASSERT_TRUE(typeName _args == "BOOL",str typeName _args);

                private ["_state"];
                _state = [_logic,"pause",objNull,false] call ALIVE_fnc_OOsimpleOperation;
                if (_state && _args) exitwith {};

                //Set value
                _args = [_logic,"pause",_args,false] call ALIVE_fnc_OOsimpleOperation;
                ["Pausing state of %1 instance set to %2!",QMOD(ADDON),_args] call ALiVE_fnc_dumpR;
        };
        _result = _args;
    };
    case "createMarker": {
        private["_position","_faction","_text","_markers","_debugColor","_markerID","_m"];

        _position = _args select 0;
        _faction = _args select 1;
        _text = _args select 2;

        _markers = _logic getVariable ["markers", []];

        if(count _markers > 10) then {
            {
                deleteMarker _x;
            } forEach _markers;
            _markers = [];
        };

        _debugColor = "ColorPink";

        switch(_faction) do {
            case "OPF_F":{
                _debugColor = "ColorRed";
            };
            case "BLU_F":{
                _debugColor = "ColorBlue";
            };
            case "IND_F":{
                _debugColor = "ColorGreen";
            };
            case "BLU_G_F":{
                _debugColor = "ColorBrown";
            };
            default {
                _debugColor = "ColorGreen";
            };
        };

        _markerID = time;

        if(count _position > 0) then {
            _m = createMarker [format["%1_%2",MTEMPLATE,_markerID], _position];
            _m setMarkerShape "ICON";
            _m setMarkerSize [0.5, 0.5];
            _m setMarkerType "mil_join";
            _m setMarkerColor _debugColor;
            _m setMarkerText _text;

            _markers pushback _m;
        };

        _logic setVariable ["markers", _markers];
    };
    case "side": {
        _result = [_logic,_operation,_args,DEFAULT_SIDE] call ALIVE_fnc_OOsimpleOperation;
    };
    case "factions": {
        _result = [_logic,_operation,_args,DEFAULT_FACTIONS] call ALIVE_fnc_OOsimpleOperation;
    };
    case "objectives": {
        _result = [_logic,_operation,_args,DEFAULT_OBJECTIVES] call ALIVE_fnc_OOsimpleOperation;
    };
    case "eventQueue": {
        _result = [_logic,_operation,_args,DEFAULT_EVENT_QUEUE] call ALIVE_fnc_OOsimpleOperation;
    };
    case "reinforcementAnalysis": {
        _result = [_logic,_operation,_args,DEFAULT_REINFORCEMENT_ANALYSIS] call ALIVE_fnc_OOsimpleOperation;
    };
    case "forcePoolType": {
        _result = [_logic,_operation,_args,DEFAULT_FORCE_POOL_TYPE] call ALIVE_fnc_OOsimpleOperation;
    };
    case "registryID": {
        _result = [_logic,_operation,_args,DEFAULT_REGISTRY_ID] call ALIVE_fnc_OOsimpleOperation;
    };
    case "allowInfantryReinforcement": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["allowInfantryReinforcement", _args];
        } else {
            _args = _logic getVariable ["allowInfantryReinforcement", false];
        };
        if (typeName _args == "STRING") then {
            if(_args == "true") then {_args = true;} else {_args = false;};
            _logic setVariable ["allowInfantryReinforcement", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "allowMechanisedReinforcement": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["allowMechanisedReinforcement", _args];
        } else {
            _args = _logic getVariable ["allowMechanisedReinforcement", false];
        };
        if (typeName _args == "STRING") then {
            if(_args == "true") then {_args = true;} else {_args = false;};
            _logic setVariable ["allowMechanisedReinforcement", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "allowMotorisedReinforcement": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["allowMotorisedReinforcement", _args];
        } else {
            _args = _logic getVariable ["allowMotorisedReinforcement", false];
        };
        if (typeName _args == "STRING") then {
            if(_args == "true") then {_args = true;} else {_args = false;};
            _logic setVariable ["allowMotorisedReinforcement", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "allowArmourReinforcement": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["allowArmourReinforcement", _args];
        } else {
            _args = _logic getVariable ["allowArmourReinforcement", false];
        };
        if (typeName _args == "STRING") then {
            if(_args == "true") then {_args = true;} else {_args = false;};
            _logic setVariable ["allowArmourReinforcement", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "allowHeliReinforcement": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["allowHeliReinforcement", _args];
        } else {
            _args = _logic getVariable ["allowHeliReinforcement", false];
        };
        if (typeName _args == "STRING") then {
            if(_args == "true") then {_args = true;} else {_args = false;};
            _logic setVariable ["allowHeliReinforcement", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "allowPlaneReinforcement": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["allowPlaneReinforcement", _args];
        } else {
            _args = _logic getVariable ["allowPlaneReinforcement", false];
        };
        if (typeName _args == "STRING") then {
            if(_args == "true") then {_args = true;} else {_args = false;};
            _logic setVariable ["allowPlaneReinforcement", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "enableAirTransport": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["enableAirTransport", _args];
        } else {
            _args = _logic getVariable ["enableAirTransport", false];
        };
        if (typeName _args == "STRING") then {
            if(_args == "true") then {_args = true;} else {_args = false;};
            _logic setVariable ["enableAirTransport", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "limitTransportToFaction": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["limitTransportToFaction", _args];
        } else {
            _args = _logic getVariable ["limitTransportToFaction", false];
        };
        if (typeName _args == "STRING") then {
            if(_args == "true") then {_args = true;} else {_args = false;};
            _logic setVariable ["limitTransportToFaction", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "type": {
        if(typeName _args == "STRING") then {
            _logic setVariable [_operation, parseNumber _args];
        };

        _result = _logic getVariable [_operation, DEFAULT_TYPE];
    };
    case "forcePool": {
        if(typeName _args == "STRING") then {
            _logic setVariable [_operation, parseNumber _args];
        };

        if(typeName _args == "SCALAR") then {
            _logic setVariable [_operation, _args];
        };

        _result = _logic getVariable [_operation, DEFAULT_FORCE_POOL];
    };
    case "startForceStrengthInc": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["startForceStrengthInc", _args];
        } else {
            _args = _logic getVariable ["startForceStrengthInc", START_FORCE_STRENGTH_INC];
        };
        if (typeName _args == "STRING") then {
            if(_args == "true") then {_args = true;} else {_args = START_FORCE_STRENGTH_INC;};
            _logic setVariable ["startForceStrengthInc", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "startForceStrengthIncFactor": {
        _result = [_logic,_operation,_args,START_FORCE_STRENGTH_INC_FACTOR] call ALIVE_fnc_OOsimpleOperation;
    };
    case "startForceStrengthDec": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["startForceStrengthDec", _args];
        } else {
            _args = _logic getVariable ["startForceStrengthDec", START_FORCE_STRENGTH_DEC];
        };
        if (typeName _args == "STRING") then {
            if(_args == "true") then {_args = true;} else {_args = START_FORCE_STRENGTH_DEC;};
            _logic setVariable ["startForceStrengthDec", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "startForceStrengthDecFactor": {
        _result = [_logic,_operation,_args,START_FORCE_STRENGTH_DEC_FACTOR] call ALIVE_fnc_OOsimpleOperation;
    };    
    
    // ============================================================
    // NEW OPERATION: prepareHelicopterLZ
    // Finds a clear landing zone near a position, moves any
    // blocking infantry out of the way, and returns the cleared pos.
    // Args: [_centerPosition, _searchRadius (optional, default 80)]
    // Returns: position array
    // ============================================================
    case "prepareHelicopterLZ": {

        private _centerPos    = _args select 0;
        private _searchRadius = if (count _args > 1) then {_args select 1} else {80};
        private _debug        = [_logic, "debug"] call MAINCLASS;

        ["ML - prepareHelicopterLZ: Searching for clear LZ near %1 radius %2",
            _centerPos, _searchRadius] call ALiVE_fnc_dump;

        private _clearPos  = [];
        private _attempts  = 0;
        private _curRadius = _searchRadius;

        // --- Pass 1: Roads first ---
        // nearRoads finds flat surfaced positions clear of buildings by definition.
        // BIS_fnc_findSafePos repeatedly returns a sentinel value [8000,1900,300]
        // on dense airfields, consuming all attempts without finding anything.
        // Checking nearby roads first avoids this entirely.
        private _roadSearchRadius = _searchRadius + 200;
        private _candidateRoads = _centerPos nearRoads _roadSearchRadius;
        _candidateRoads = _candidateRoads apply { [_x distance2D _centerPos, _x] };
        _candidateRoads sort true;
        {
            if (count _clearPos > 0) exitWith {};
            private _candidate = getPos (_x select 1);
            if (count _candidate < 2) then { continue };
            if (surfaceIsWater _candidate) then { continue };
            if (count _candidate > 2 && (_candidate select 2) > 10) then { continue };

            private _nearTerrain = nearestTerrainObjects [
                _candidate,
                ["ROCK","TREE","BUSH","WALL","FENCE","HOUSE"],
                LZ_OBJECT_CLEAR_RADIUS
            ];
            private _nearVehicles = _candidate nearEntities [["Car","Tank","Air","Ship"], LZ_VEHICLE_CLEAR_RADIUS];
            private _checkHigh = _candidate vectorAdd [0, 0, LZ_VERTICAL_CHECK_HEIGHT];
            private _checkLow  = _candidate vectorAdd [0, 0, 1];
            private _obstructed = count (lineIntersectsSurfaces [
                AGLtoASL _checkHigh, AGLtoASL _checkLow,
                objNull, objNull, true, 1, "GEOM"
            ]) > 0;

            if (count _nearTerrain == 0 && count _nearVehicles == 0 && !_obstructed) then {
                _clearPos = _candidate;
                if (_debug) then {
                    ["ML - prepareHelicopterLZ: Road LZ found at %1", _clearPos] call ALiVE_fnc_dump;
                };
            };
        } forEach _candidateRoads;

        // --- Pass 2: BIS_fnc_findSafePos, strict 30m secondary check ---
        while {count _clearPos == 0 && _attempts < LZ_MAX_SEARCH_ATTEMPTS} do {
            private _candidate = [
                _centerPos,
                LZ_MIN_CLEAR_RADIUS,
                _curRadius,
                20,
                0,
                LZ_MAX_GRADIENT,
                0
            ] call BIS_fnc_findSafePos;

            if (_debug) then {
                ["ML - prepareHelicopterLZ: Attempt %1 candidate %2",
                    _attempts + 1, _candidate] call ALiVE_fnc_dump;
            };

            if (!(surfaceIsWater _candidate) && !(_candidate isEqualTo []) && (count _candidate < 3 || (_candidate select 2) < 10)) then {
                private _nearTerrain  = nearestTerrainObjects [
                    _candidate,
                    ["ROCK","TREE","BUSH","WALL","FENCE","HOUSE"],
                    LZ_OBJECT_CLEAR_RADIUS
                ];
                private _nearVehicles = _candidate nearEntities [["Car","Tank","Air","Ship"], LZ_VEHICLE_CLEAR_RADIUS];
                private _checkHigh  = _candidate vectorAdd [0, 0, LZ_VERTICAL_CHECK_HEIGHT];
                private _checkLow   = _candidate vectorAdd [0, 0, 1];
                private _obstructed = count (lineIntersectsSurfaces [
                    AGLtoASL _checkHigh, AGLtoASL _checkLow,
                    objNull, objNull, true, 1, "GEOM"
                ]) > 0;

                if (_debug) then {
                    ["ML - prepareHelicopterLZ: terrain=%1 vehicles=%2 obstructed=%3",
                        count _nearTerrain, count _nearVehicles, _obstructed] call ALiVE_fnc_dump;
                };

                if (count _nearTerrain == 0 && count _nearVehicles == 0 && !_obstructed) then {
                    _clearPos = _candidate;
                    if (_debug) then {
                        ["ML - prepareHelicopterLZ: Clear LZ found at %1 on attempt %2",
                            _clearPos, _attempts + 1] call ALiVE_fnc_dump;
                    };
                };
            };

            _curRadius = _curRadius + LZ_SEARCH_RADIUS_INCREMENT;
            _attempts  = _attempts + 1;
        };

        // --- Pass 3: Relaxed 20m secondary check ---
        // Last resort before accepting the raw fallback position.
        if (count _clearPos == 0) then {
            ["ML - prepareHelicopterLZ: Strict check failed, relaxed retry near %1", _centerPos] call ALiVE_fnc_dump;
            private _attempts3 = 0;
            private _curRadius3 = _searchRadius;
            while {count _clearPos == 0 && _attempts3 < LZ_MAX_SEARCH_ATTEMPTS} do {
                private _candidate3 = [
                    _centerPos, LZ_MIN_CLEAR_RADIUS, _curRadius3, 10, 0, LZ_MAX_GRADIENT, 0
                ] call BIS_fnc_findSafePos;
                if (!(surfaceIsWater _candidate3) && !(_candidate3 isEqualTo []) && (count _candidate3 < 3 || (_candidate3 select 2) < 10)) then {
                    private _nearTerrain3 = nearestTerrainObjects [_candidate3, ["ROCK","TREE","BUSH","WALL","FENCE","HOUSE"], 20];
                    private _nearVehicles3 = _candidate3 nearEntities [["Car","Tank","Air","Ship"], LZ_VEHICLE_CLEAR_RADIUS];
                    private _checkHigh3 = _candidate3 vectorAdd [0, 0, LZ_VERTICAL_CHECK_HEIGHT];
                    private _checkLow3  = _candidate3 vectorAdd [0, 0, 1];
                    private _obstructed3 = count (lineIntersectsSurfaces [AGLtoASL _checkHigh3, AGLtoASL _checkLow3, objNull, objNull, true, 1, "GEOM"]) > 0;
                    if (count _nearTerrain3 == 0 && count _nearVehicles3 == 0 && !_obstructed3) then {
                        _clearPos = _candidate3;
                        ["ML - prepareHelicopterLZ: Relaxed clearance LZ found at %1", _clearPos] call ALiVE_fnc_dump;
                    };
                };
                _curRadius3 = _curRadius3 + LZ_SEARCH_RADIUS_INCREMENT;
                _attempts3  = _attempts3 + 1;
            };
        };

        if (count _clearPos == 0) then {
            _clearPos = _centerPos;
            ["ML - prepareHelicopterLZ: WARNING - No clear LZ found after %1 attempts, using original pos %2",
                LZ_MAX_SEARCH_ATTEMPTS, _centerPos] call ALiVE_fnc_dump;
        };

        // Move blocking infantry clear of the chosen LZ
        private _blockingInfantry = _clearPos nearEntities [["Man"], LZ_OBJECT_CLEAR_RADIUS];
        if (count _blockingInfantry > 0) then {
            ["ML - prepareHelicopterLZ: Moving %1 blocking infantry from LZ %2",
                count _blockingInfantry, _clearPos] call ALiVE_fnc_dump;
            {
                private _movePos = [getPos _x, 8, 30, 1, 0, LZ_MAX_GRADIENT, 0] call BIS_fnc_findSafePos;
                if (count _movePos > 0 && !(surfaceIsWater _movePos)) then {
                    _x setPos _movePos;
                    if (_debug) then {
                        ["ML - prepareHelicopterLZ: Moved unit %1 to %2", _x, _movePos] call ALiVE_fnc_dump;
                    };
                };
            } forEach _blockingInfantry;
        };

        if (_debug) then {
            [_logic, "createMarker", [_clearPos, "BLU_F", "ML LZ"]] call MAINCLASS;
            ["ML - prepareHelicopterLZ: Final LZ: %1", _clearPos] call ALiVE_fnc_dump;
        };

        // Ensure returned position has Z coordinate
        if (count _clearPos == 2) then { _clearPos pushback 0; };

        _result = _clearPos;
    };

    // ============================================================
    // NEW OPERATION: findHelicopterLandingPos
    // Terrain and obstacle aware destination position search.
    // Checks terrain objects, vehicles, and vertical clearance.
    // Args: [_centerPosition, _minRadius, _maxRadius]
    // Returns: position array
    // ============================================================
    case "findHelicopterLandingPos": {

        private _centerPos     = _args select 0;
        private _minRadius     = _args select 1;
        private _maxRadius     = _args select 2;
        private _usedPositions = if (count _args > 3) then { _args select 3 } else { [] };
        private _debug         = [_logic, "debug"] call MAINCLASS;

        ["ML - findHelicopterLandingPos: Searching near %1 min %2 max %3",
            _centerPos, _minRadius, _maxRadius] call ALiVE_fnc_dump;

        private _foundPos = [];

        // --- Pass 1: Try roads first - they are clear of buildings by definition ---
        private _searchRadius = _maxRadius;
        for "_r" from 0 to 3 do {
            if (count _foundPos > 0) exitWith {};
            private _roads = _centerPos nearRoads _searchRadius;
            // Sort by distance
            _roads = _roads apply { [_x distance2D _centerPos, _x] };
            _roads sort true;

            // Merge caller's usedPositions with global tracker
            private _allUsedPos = _usedPositions + (missionNamespace getVariable ["ALIVE_ML_usedLZPositions", []]);

            // Two sub-passes: first respecting _minRadius exclusion zone,
            // then ignoring it if nothing was found outside the zone.
            // This handles objectives in small settlements where all nearby
            // roads fall inside the 200m exclusion radius.
            private _roadPasses = [true, false]; // true = enforce minRadius, false = relax it
            {
                private _enforceMin = _x;
                if (count _foundPos > 0) exitWith {};
                {
                    private _road = _x select 1;
                    private _candidate = getPos _road;
                    if (count _candidate < 2) then { continue };

                    // Skip if too close to any used position (global or local)
                    private _tooClose = false;
                    {
                        private _usedPos = _x;
                        if (count _usedPos > 3) then { _usedPos = [_usedPos select 0, _usedPos select 1, _usedPos select 2]; };
                        if (_candidate distance _usedPos < 150) then { _tooClose = true; };
                    } forEach _allUsedPos;
                    if (_tooClose) then { continue };

                    // Distance bounds - relax minimum on second sub-pass
                    private _dist = _candidate distance2D _centerPos;
                    private _minCheck = if (_enforceMin) then { _minRadius } else { 0 };
                    if (_dist < _minCheck || _dist > _searchRadius + 100) then { continue };

                    // Road surface check - no terrain objects
                    private _nearTerrain = nearestTerrainObjects [
                        _candidate,
                        ["ROCK","TREE","HOUSE","WALL","FENCE","BUILDING"],
                        LZ_OBJECT_CLEAR_RADIUS
                    ];
                    private _nearVehicles = _candidate nearEntities [["Car","Tank","Air","Ship"], LZ_VEHICLE_CLEAR_RADIUS];

                    // Vertical obstruction check via ray cast - catches bridges, canopies,
                    // overhead structures. Replaces the old nearObjects overhead check which
                    // was rejecting roads near lamp posts, poles and road signs.
                    private _checkHigh = _candidate vectorAdd [0, 0, LZ_VERTICAL_CHECK_HEIGHT];
                    private _checkLow  = _candidate vectorAdd [0, 0, 1];
                    private _obstructed = count (lineIntersectsSurfaces [
                        AGLtoASL _checkHigh, AGLtoASL _checkLow,
                        objNull, objNull, true, 1, "GEOM"
                    ]) > 0;

                    // Gradient check
                    private _h0 = getTerrainHeightASL _candidate;
                    private _gradientTooSteep = false;
                    {
                        private _samplePos = _candidate getPos [15, _x];
                        private _h1 = getTerrainHeightASL _samplePos;
                        if (abs(_h1 - _h0) > 2.5) then { _gradientTooSteep = true; };
                    } forEach [0, 90, 180, 270];
                    if (_gradientTooSteep) then { continue };

                    if (count _nearTerrain == 0 && count _nearVehicles == 0 && !_obstructed) then {
                        _foundPos = _candidate;
                        if (count _foundPos == 2) then { _foundPos pushback 0; };
                        // Register in global tracker so other events avoid this spot
                        private _globalUsed = missionNamespace getVariable ["ALIVE_ML_usedLZPositions", []];
                        _globalUsed = _globalUsed select { (time - (_x select 3)) < 600 };
                        _globalUsed pushback (_foundPos + [time]);
                        missionNamespace setVariable ["ALIVE_ML_usedLZPositions", _globalUsed];
                        if (_debug) then {
                            ["ML - findHelicopterLandingPos: Road LZ found at %1", _foundPos] call ALiVE_fnc_dump;
                        };
                    };
                    if (count _foundPos > 0) exitWith {};
                } forEach _roads;
            } forEach _roadPasses;
            _searchRadius = _searchRadius + 100;
        };

        // --- Pass 2: BIS_fnc_findSafePos fallback if no road found ---
        private _attempts    = 0;
        private _maxAttempts = 16;
        private _curMax      = _maxRadius;

        while {count _foundPos == 0 && _attempts < _maxAttempts} do {

            private _candidate = [
                _centerPos,
                _minRadius,
                _curMax,
                LZ_OBJECT_CLEAR_RADIUS,
                0,
                LZ_MAX_GRADIENT,
                0
            ] call BIS_fnc_findSafePos;

            if (!(surfaceIsWater _candidate) && !(_candidate isEqualTo []) && (count _candidate < 3 || (_candidate select 2) < 10)) then {

                private _nearTerrain  = nearestTerrainObjects [
                    _candidate,
                    ["ROCK","TREE","HOUSE","BUSH","WALL","FENCE"],
                    LZ_OBJECT_CLEAR_RADIUS
                ];
                private _nearVehicles = _candidate nearEntities [
                    ["Car","Tank","Air","Ship"],
                    LZ_VEHICLE_CLEAR_RADIUS
                ];

                private _checkHigh  = _candidate vectorAdd [0, 0, LZ_VERTICAL_CHECK_HEIGHT];
                private _checkLow   = _candidate vectorAdd [0, 0, 1];
                private _obstructed = count (lineIntersectsSurfaces [
                    AGLtoASL _checkHigh,
                    AGLtoASL _checkLow,
                    objNull, objNull, true, 1, "GEOM"
                ]) > 0;

                // Check spacing from already-assigned heli positions (local and global)
                private _tooClose = false;
                private _allUsed2 = _usedPositions + (missionNamespace getVariable ["ALIVE_ML_usedLZPositions", []]);
                {
                    private _usedPos2 = _x;
                    if (count _usedPos2 > 3) then { _usedPos2 = [_usedPos2 select 0, _usedPos2 select 1, _usedPos2 select 2]; };
                    if (_candidate distance _usedPos2 < 150) then { _tooClose = true; };
                } forEach _allUsed2;

                if (_debug) then {
                    ["ML - findHelicopterLandingPos: Attempt %1 terrain=%2 vehicles=%3 obstructed=%4 tooClose=%5",
                        _attempts + 1, count _nearTerrain, count _nearVehicles, _obstructed, _tooClose] call ALiVE_fnc_dump;
                };

                if (count _nearTerrain == 0 && count _nearVehicles == 0 && !_obstructed && !_tooClose) then {
                    _foundPos = _candidate;
                    // Register in global tracker
                    private _globalUsed2 = missionNamespace getVariable ["ALIVE_ML_usedLZPositions", []];
                    _globalUsed2 = _globalUsed2 select { (time - (_x select 3)) < 600 };
                    _globalUsed2 pushback (_foundPos + [time]);
                    missionNamespace setVariable ["ALIVE_ML_usedLZPositions", _globalUsed2];
                    if (_debug) then {
                        ["ML - findHelicopterLandingPos: Valid pos found %1 on attempt %2",
                            _foundPos, _attempts + 1] call ALiVE_fnc_dump;
                    };
                };
            };

            _curMax   = _curMax + LZ_SEARCH_RADIUS_INCREMENT;
            _attempts = _attempts + 1;
        };

        if (count _foundPos == 0) then {
            _foundPos = _centerPos getPos [_minRadius + 20 + (count _usedPositions * 30), random 360];
            ["ML - findHelicopterLandingPos: WARNING - No clear pos after %1 attempts, fallback %2",
                _maxAttempts, _foundPos] call ALiVE_fnc_dump;
        };

        if (_debug) then {
            ["ML - findHelicopterLandingPos: Final pos: %1", _foundPos] call ALiVE_fnc_dump;
        };

        // Ensure returned position has Z coordinate
        if (count _foundPos == 2) then { _foundPos pushback 0; };

        _result = _foundPos;
    };
    
    
    // ============================================================
    // NEW OPERATION: findBestDeliveryObjective
    // Scores OPCOM objectives by tactical need and friendly unit
    // presence to find the most useful helicopter delivery destination.
    // Prefers objectives that are actively contested (attack/defend)
    // with few friendly units already present.
    // Args: [_objectives, _insertionPos, _eventFaction, _side]
    // Returns: position array, or [] if no suitable objective found
    // ============================================================
    case "findBestDeliveryObjective": {

        private _objectives   = _args select 0;
        private _insertionPos = _args select 1;
        private _faction      = _args select 2;
        private _side         = _args select 3;
        private _departurePos = if (count _args > 4) then { _args select 4 } else { [] };
        private _heldCount    = if (count _args > 5) then { _args select 5 } else { 99 };
        private _debug        = [_logic, "debug"] call MAINCLASS;

        // When only 2 held objectives exist, relax proximity filters --
        // we must use whatever destination is available regardless of distance.
        private _proximityFilter = if (_heldCount <= 2) then { 0 } else { 500 };

        if (_debug) then {
            ["ML - findBestDeliveryObjective: Scoring %1 objectives for faction %2",
                count _objectives, _faction] call ALiVE_fnc_dump;
        };

        // Tactical state score - higher means more urgently needs reinforcement
        // attack/capture: OPCOM is actively taking this with units present - best target
        // defend: under pressure, reinforcements critical
        // reserve: already held, safe fallback if no active objectives exist
        // recon: skipped entirely (enemy/unknown territory)
        // none: skipped entirely - OPCOM hasn't assessed it, could be enemy territory
        private _stateScores = [
            ["attack",  100],
            ["capture", 100],
            ["defend",   80],
            ["reserve",  10]
        ];

        // Cap applied to raw OPCOM priority before scoring.
        // Prevents a single very high priority objective (e.g. priority=1000)
        // from dominating all tactical state considerations.
        // Effective range after normalisation becomes 0-50 points.
        private _priorityCap = 100;

        // Radius within which to count friendly and enemy units near an objective
        private _presenceCheckRadius = 500;

        // Maximum friendly unit count at which an objective is considered
        // well-staffed and deprioritised.
        private _wellStaffedThreshold = 8;

        // Valid active states for delivery destinations.
        // attack/capture/defend = OPCOM has units actively engaged there - best target.
        // reserve = OPCOM holds it - safe fallback when no active objectives exist.
        // recon and none are excluded - unknown/unassessed territory.
        private _activeStates = ["attack", "capture", "defend"];

        private _bestObjective   = nil;
        private _bestScore       = -1;
        private _bestPos         = [];
        private _bestIsActive    = false;
        private _bestObjState    = "none";
        private _bestEnemyCount  = 0;

        {
            private _obj         = _x;
            private _objPos      = [_obj, "center"] call ALIVE_fnc_hashGet;
            private _objPriority = [_obj, "priority"] call ALIVE_fnc_hashGet;
            private _objState    = "none";

            if ("tacom_state" in (_obj select 1)) then {
                _objState = [_obj, "tacom_state", "none"] call ALIVE_fnc_hashGet;
            };

            // Skip recon and none objectives entirely.
            // recon = OPCOM scouting enemy territory - unsafe.
            // none = OPCOM hasn't assessed it yet - could be anything.
            // Only attack/capture/defend/reserve are safe delivery targets.
            if (_objState == "recon" || _objState == "none") then {
                if (_debug) then {
                    ["ML - findBestDeliveryObjective: Skipping objective %1 - state=%2 (unassessed/enemy territory)",
                        _objPos, _objState] call ALiVE_fnc_dump;
                };
            } else {

            // Skip objectives that are the same as or too close to the insertion point,
            // or too close to the departure base - destination must be distinct from both
            private _distFromInsertion = _insertionPos distance _objPos;
            private _distFromDeparture = if (count _departurePos > 0) then { _departurePos distance _objPos } else { 9999 };
            if (_distFromInsertion < _proximityFilter) then {
                if (_debug) then {
                    ["ML - findBestDeliveryObjective: Skipping objective %1 - too close to insertion point (%2m)",
                        _objPos, _distFromInsertion] call ALiVE_fnc_dump;
                };
            } else {
            if (_distFromDeparture < _proximityFilter) then {
                if (_debug) then {
                    ["ML - findBestDeliveryObjective: Skipping objective %1 - too close to departure base (%2m)",
                        _objPos, _distFromDeparture] call ALiVE_fnc_dump;
                };
            } else {

                private _isActive = _objState in _activeStates;

                // If we already have an active-state candidate, skip inactive ones
                if (_bestIsActive && !_isActive) then {
                    if (_debug) then {
                        ["ML - findBestDeliveryObjective: Skipping inactive objective %1 (state=%2) - active candidate already found",
                            _objPos, _objState] call ALiVE_fnc_dump;
                    };
                } else {

                    // State score
                    private _stateScore = 40; // default for unknown states
                    {
                        if (_x select 0 == _objState) exitWith {
                            _stateScore = _x select 1;
                        };
                    } forEach _stateScores;

                    // Priority score - cap then normalise to 0-50 range.
                    // Capping prevents outlier priorities from overwhelming
                    // tactical state scores.
                    private _cappedPriority = _objPriority min _priorityCap;
                    private _priorityScore = (_cappedPriority / _priorityCap) * 50;

                    // Count friendly and enemy units near the objective
                    private _sideObj = [_side] call ALIVE_fnc_sideTextToObject;
                    private _friendlyCount = 0;
                    private _enemyCount = 0;
                    private _nearUnits = _objPos nearEntities [["Man","Car","Tank"], _presenceCheckRadius];
                    {
                        if (side _x == _sideObj) then {
                            _friendlyCount = _friendlyCount + 1;
                        } else {
                            if (side _x != civilian) then {
                                _enemyCount = _enemyCount + 1;
                            };
                        };
                    } forEach _nearUnits;

                    // Skip objectives with significant enemy presence -
                    // delivering reinforcements into an occupied enemy position
                    // is counterproductive regardless of tactical state score.
                    // Threshold of 3 allows for small patrols but blocks clearly
                    // enemy-held locations.
                    if (_enemyCount >= 3) then {
                        if (_debug) then {
                            ["ML - findBestDeliveryObjective: Skipping objective %1 (state=%2) - %3 enemy units within %4m",
                                _objPos, _objState, _enemyCount, _presenceCheckRadius] call ALiVE_fnc_dump;
                        };
                    } else {

                    // Presence score: 50 points when empty, scaling down to 0 at threshold
                    private _presenceScore = 0;
                    if (_friendlyCount < _wellStaffedThreshold) then {
                        _presenceScore = ((_wellStaffedThreshold - _friendlyCount) / _wellStaffedThreshold) * 50;
                    };

                    // Combined score
                    private _totalScore = _stateScore + _priorityScore + _presenceScore;

                    if (_debug) then {
                        ["ML - findBestDeliveryObjective: Objective at %1 state=%2 priority=%3 friendly=%4 enemy=%5 scores: state=%6 priority=%7 presence=%8 total=%9",
                            _objPos, _objState, _objPriority, _friendlyCount, _enemyCount,
                            _stateScore, _priorityScore, _presenceScore, _totalScore] call ALiVE_fnc_dump;
                    };

                    if (_totalScore > _bestScore || (_isActive && !_bestIsActive)) then {
                        _bestScore      = _totalScore;
                        _bestObjective  = _obj;
                        _bestPos        = _objPos;
                        _bestIsActive   = _isActive;
                        _bestObjState   = _objState;
                        _bestEnemyCount = _enemyCount;
                    };

                    }; // end enemy presence check

                };
            };
            }; // end departure proximity check

            }; // end recon skip

        } forEach _objectives;

        if (!isNil "_bestObjective" && count _bestPos > 0) then {
            if (_debug) then {
                private _bestLocName = [_bestPos] call ALIVE_fnc_taskGetNearestLocationName;
                ["ML - findBestDeliveryObjective: Best objective selected near %1 at %2 with score %3 state=%4 enemyCount=%5",
                    _bestLocName, _bestPos, _bestScore, _bestObjState, _bestEnemyCount] call ALiVE_fnc_dump;
            };
        } else {
            if (_debug) then {
                ["ML - findBestDeliveryObjective: No suitable objective found"] call ALiVE_fnc_dump;
            };
            _bestPos = [];
        };

        _result = [_bestPos, _bestEnemyCount, _bestObjState];
    };

    // ============================================================
    // NEW OPERATION: spawnHelicopterFuelWatchdog
    // Monitors a helicopter for hover-lock / fuel starvation.
    // Forces emergency landing and restores fuel for RTB.
    // Args: [_transportProfileID, _fallbackPosition, _eventFaction]
    // Returns: nil
    // ============================================================
    case "spawnHelicopterFuelWatchdog": {

        private _profileID   = _args select 0;
        private _fallbackPos = _args select 1;
        private _faction     = _args select 2;
        private _debug       = [_logic, "debug"] call MAINCLASS;

        ["ML - spawnHelicopterFuelWatchdog: Starting watchdog for profile %1",
            _profileID] call ALiVE_fnc_dump;

        [_profileID, _fallbackPos, _faction, _debug] spawn {

            private _profileID   = _this select 0;
            private _fallbackPos = _this select 1;
            private _faction     = _this select 2;
            private _debug       = _this select 3;

            sleep FUEL_WATCHDOG_STARTUP_DELAY;

            private _active        = true;
            private _hoverTicks    = 0; // consecutive ticks at hover with non-zero AGL

            while {_active} do {
                sleep FUEL_WATCHDOG_CHECK_INTERVAL;

                private _profile = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;

                if (isNil "_profile") exitWith {
                    if (_debug) then {
                        ["ML - spawnHelicopterFuelWatchdog: Profile %1 gone, exiting",
                            _profileID] call ALiVE_fnc_dump;
                    };
                    _active = false;
                };

                private _isActive = _profile select 2 select 1;

                if (_isActive) then {
                    private _heli = _profile select 2 select 10;

                    if (!isNull _heli && alive _heli) then {

                        private _fuel      = fuel _heli;
                        private _posASL    = getPosASL _heli;
                        private _groundASL = getTerrainHeightASL _posASL;
                        private _heightAGL = (_posASL select 2) - _groundASL;
                        private _spd       = speed _heli;

                        if (_debug) then {
                            ["ML - spawnHelicopterFuelWatchdog: %1 fuel=%2 heightAGL=%3 speed=%4",
                                _profileID, _fuel, _heightAGL, _spd] call ALiVE_fnc_dump;
                        };

                        if (
                            _fuel      < FUEL_WATCHDOG_LOW_FUEL_THRESHOLD &&
                            _heightAGL > FUEL_WATCHDOG_MIN_HOVER_HEIGHT   &&
                            _spd       < FUEL_WATCHDOG_HOVER_SPEED_THRESHOLD
                        ) then {
                            ["ML - spawnHelicopterFuelWatchdog: ALERT profile %1 hover-locked, fuel=%2. Forcing landing.",
                                _profileID, _fuel] call ALiVE_fnc_dump;

                            // Reset AI behaviour before landAt -- if heli is under fire the
                            // engine will have re-enabled evasion and targeting, which overrides
                            // landAt immediately without this reset.
                            private _grpFuel = group (driver _heli);
                            _grpFuel setBehaviour "CARELESS";
                            _grpFuel allowFleeing 0;
                            _grpFuel setCombatMode "BLUE";
                            _grpFuel setSpeedMode "FULL";
                            { _x disableAI "AUTOTARGET"; _x disableAI "TARGET"; _x setSkill ["courage", 1]; } forEach (units _grpFuel);

                            private _emergencyPos = [
                                _fallbackPos, 0, 150,
                                LZ_OBJECT_CLEAR_RADIUS,
                                0, LZ_MAX_GRADIENT, 0
                            ] call BIS_fnc_findSafePos;

                            if (surfaceIsWater _emergencyPos || _emergencyPos isEqualTo []) then {
                                _emergencyPos = _fallbackPos;
                            };

                            private _emergencyPad = createVehicle ["Land_HelipadEmpty_F", _emergencyPos, [], 0, "CAN_COLLIDE"];
                            _heli landAt _emergencyPad;
                            _heli setFuel FUEL_WATCHDOG_RECOVER_FUEL;

                            // Clean up pad once landed or after timeout
                            [_heli, _emergencyPad] spawn {
                                private _h = _this select 0;
                                private _p = _this select 1;
                                private _t = 0;
                                waitUntil { sleep 2; _t = _t + 2; (isTouchingGround _h || !alive _h || _t > 60) };
                                deleteVehicle _p;
                            };

                            ["ML - spawnHelicopterFuelWatchdog: Emergency landing at %1, fuel restored for profile %2",
                                _emergencyPos, _profileID] call ALiVE_fnc_dump;

                            _active = false;
                        };

                        // Sustained hover detection -- fires regardless of fuel.
                        // If the heli has been hovering (speed < threshold, AGL > minimum)
                        // for 60+ seconds with no passengers and no slung load, it is
                        // zombie-hovering with no more waypoints.
                        // Guards:
                        //   - isTouchingGround: heli is landing normally, don't interfere
                        //   - cargoCount > 0: units aboard, delivery watchdog is handling it
                        //   - hasSlung: slingload in progress, don't drop cargo at altitude
                        if (!_active) exitWith {};
                        if (
                            _heightAGL > FUEL_WATCHDOG_MIN_HOVER_HEIGHT &&
                            abs _spd    < FUEL_WATCHDOG_HOVER_SPEED_THRESHOLD &&
                            !isTouchingGround _heli
                        ) then {
                            private _cargoCount = { alive _x && _x != driver _heli && _x != gunner _heli } count crew _heli;
                            private _hasSlung = !isNull (vehicle _heli) && { count (attachedObjects _heli) > 0 };
                            if (_cargoCount == 0 && !_hasSlung) then {
                                _hoverTicks = _hoverTicks + 1;
                            } else {
                                _hoverTicks = 0; // units aboard or slung load -- reset counter
                            };
                        } else {
                            _hoverTicks = 0;
                        };
                        // 6 ticks x 10s interval = 60s sustained hover
                        if (_hoverTicks >= 6) then {
                            // Check for passengers -- never destroy a heli with units aboard.
                            // Eject any non-crew passengers first so they don't die with the heli.
                            // Eject any non-pilot passengers before forcing a landing.
                            // Passengers = crew members that are not the driver or gunner.
                            private _passengers = crew _heli select { alive _x && _x != driver _heli && _x != gunner _heli };
                            if (count _passengers > 0) then {
                                { unassignVehicle _x; _x moveOut _heli; } forEach _passengers;
                                ["ML - spawnHelicopterFuelWatchdog: ALERT profile %1 sustained hover with %2 passengers -- ejecting before forced landing.",
                                    _profileID, count _passengers] call ALiVE_fnc_dump;
                            };

                            ["ML - spawnHelicopterFuelWatchdog: ALERT profile %1 sustained hover %2 ticks at %3m AGL. Forcing landing.",
                                _profileID, _hoverTicks, _heightAGL] call ALiVE_fnc_dump;

                            // Reset AI behaviour before landAt for same reason as fuel-starvation branch.
                            private _grpHover = group (driver _heli);
                            _grpHover setBehaviour "CARELESS";
                            _grpHover allowFleeing 0;
                            _grpHover setCombatMode "BLUE";
                            _grpHover setSpeedMode "FULL";
                            { _x disableAI "AUTOTARGET"; _x disableAI "TARGET"; _x setSkill ["courage", 1]; } forEach (units _grpHover);

                            private _landPad = createVehicle ["Land_HelipadEmpty_F", getPosATL _heli, [], 0, "CAN_COLLIDE"];
                            _heli landAt _landPad;
                            [_heli, _landPad] spawn {
                                private _h = _this select 0; private _p = _this select 1; private _t = 0;
                                waitUntil { sleep 2; _t = _t + 2; isTouchingGround _h || !alive _h || _t > 30 };
                                deleteVehicle _p;
                                if (alive _h) then { _h setDamage 1; };
                            };
                            _hoverTicks = 0;
                            _active = false;
                        };

                    } else {
                        if (_debug) then {
                            ["ML - spawnHelicopterFuelWatchdog: Heli null/dead for %1, exiting",
                                _profileID] call ALiVE_fnc_dump;
                        };
                        _active = false;
                    };
                };
            };
        };
    };



    // ============================================================
    // getSupplyNetworkDeparturePos
    // Returns the best supply network departure position for a
    // logistics event. Searches ALIVE_ML_supplyNetwork for the
    // nearest valid node for the given faction relative to the
    // delivery destination. A node is valid if it is flagged as
    // HQ OR at least one of its registered profile IDs is still
    // alive in the profile handler.
    // Falls back to _fallbackPos if no valid node is found.
    //
    // Args: [_faction, _destinationPos, _fallbackPos, _eventID, _debug]
    // Returns: position array
    // ============================================================
    case "getSupplyNetworkDeparturePos": {

        private _faction        = _args select 0;
        private _destinationPos = _args select 1;
        private _fallbackPos    = _args select 2;
        private _eventID        = _args select 3;
        private _dbg            = _args select 4;

        private _nodeResult = _fallbackPos;

        if (isNil "ALIVE_ML_supplyNetwork") then {
            ["ML - getSupplyNetworkDeparturePos: ALIVE_ML_supplyNetwork is nil for event %1 faction %2 - check Military Logistics module is placed. Using fallback %3",
                _eventID, _faction, _fallbackPos] call ALiVE_fnc_dump;
        } else {
            private _nodes = [ALIVE_ML_supplyNetwork, _faction, []] call ALIVE_fnc_hashGet;
            private _bestNodePos  = [];
            private _bestNodeDist = 1e10;

            {
                private _node     = _x;
                private _nodePos  = _node select 0;
                private _nodeIDs  = _node select 1;
                private _nodeIsHQ = if (count _node > 2) then { _node select 2 } else { false };

                private _nodeValid = _nodeIsHQ || {
                    private _alive = false;
                    {
                        if (!isNil { [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler })
                        exitWith { _alive = true; };
                    } forEach _nodeIDs;
                    _alive
                };

                if (_nodeValid) then {
                    private _d = _nodePos distance _destinationPos;
                    if (_d < _bestNodeDist) then {
                        _bestNodeDist = _d;
                        _bestNodePos  = _nodePos;
                    };
                };
            } forEach _nodes;

            if (count _bestNodePos > 0) then {
                _nodeResult = _bestNodePos;
                if (_dbg) then {
                    private _nodePos3 = _nodeResult;
                    if (count _nodePos3 < 3) then { _nodePos3 = _nodePos3 + [0]; };
                    private _nodeName = [_nodePos3] call ALIVE_fnc_taskGetNearestLocationName;
                    ["ML - Departure anchored to supply network node near %1 at %2 for event %3",
                        _nodeName, _nodeResult, _eventID] call ALiVE_fnc_dump;
                };
            } else {
                if (_dbg) then {
                    ["ML - getSupplyNetworkDeparturePos: no valid node found for faction %1, using fallback %2",
                        _faction, _fallbackPos] call ALiVE_fnc_dump;
                };
            };
        }; // end if/else ALIVE_ML_supplyNetwork

        // Safety guard: always return a valid position array.
        // If _fallbackPos itself is invalid, use origin to prevent
        // downstream 'count Bool' errors in the caller.
        if (isNil "_nodeResult" || {!(_nodeResult isEqualType [])} || {count _nodeResult < 2}) then {
            ["ML - getSupplyNetworkDeparturePos: result invalid for event %1 faction %2, using [0,0,0]",
                _eventID, _faction] call ALiVE_fnc_dump;
            _nodeResult = [0,0,0];
        };

        // Assign to file-level _result so the MAINCLASS caller receives it.
        _result = _nodeResult;
    };



    // ============================================================
    // spawnHeliDeliveryWatchdog
    // Monitors a transport heli through its delivery cycle.
    // Only acts when the heli is ACTIVE (spawned near players).
    // Never fights ALiVE's virtualisation system.
    // Phases: TRANSIT(0) -> LANDING(1) -> UNLOAD(2) -> RTB(3)
    // Args: [_transportProfileID, _vehicleProfileID, _eventPosition, _returnPosition, _debug]
    // ============================================================
    case "spawnHeliDeliveryWatchdog": {

        private _transportProfileID = _args select 0;
        private _vehicleProfileID   = _args select 1;
        private _eventPosition      = _args select 2;
        private _returnPosition     = _args select 3;
        private _debug              = _args select 4;

        [_transportProfileID, _vehicleProfileID, _eventPosition, _returnPosition, _debug] spawn {

            private _tProfID   = _this select 0;
            private _vProfID   = _this select 1;
            private _destPos   = _this select 2;
            private _returnPos = _this select 3;
            private _dbg       = _this select 4;

            private _phase        = 0; // 0=transit 1=landing 2=unload 3=rtb
            private _phaseTimer   = 0;
            private _running      = true;
            private _landAtIssued = false;

            // Hit event handler: when the heli takes fire the Arma AI immediately
            // overrides landAt with evasive behaviour -- banking away, climbing,
            // abandoning the landing. The monitor loop (10s) and landAt retry (35s)
            // are far too slow to correct this. A HitPart EH fires immediately and
            // resets the pilot AI and reissues landAt so the heli stays on mission.
            // The EH stores phase in a vehicle variable so the closure can read it.
            // EH is removed on RTB to avoid interfering with egress AI.
            private _hitEH = -1;
            private _hitEHAdded = false;

            // Wait until the heli is active (spawned) before attaching the EH
            private _heliForEH = objNull;
            waitUntil {
                sleep 2;
                private _vp = [ALIVE_profileHandler, "getProfile", _vProfID] call ALIVE_fnc_profileHandler;
                if (!isNil "_vp" && { _vp select 2 select 1 } && { !isNull (_vp select 2 select 10) }) then {
                    _heliForEH = _vp select 2 select 10;
                };
                (!isNull _heliForEH || !_running)
            };

            if (!isNull _heliForEH && alive _heliForEH && !_hitEHAdded) then {
                _heliForEH setVariable ["alive_ml_watchdog_phase", _phase];
                _hitEH = _heliForEH addEventHandler ["HitPart", {
                    // HitPart _this = [[vehicle, shooter, bullet, ...], ...] -- array of per-part arrays.
                    // params ["_vehicle",...] would unpack the OUTER array making _vehicle the per-part
                    // array instead of the vehicle object, causing getVariable: Type Array errors.
                    private _partData = _this select 0;
                    private _vehicle  = _partData select 0;
                    // Only act during LANDING (1) and UNLOAD (2) phases
                    private _currentPhase = _vehicle getVariable ["alive_ml_watchdog_phase", 0];
                    if (_currentPhase in [1, 2]) then {
                        private _grp = group (driver _vehicle);
                        _grp setBehaviour "CARELESS";
                        _grp allowFleeing 0;
                        _grp setCombatMode "BLUE";
                        _grp setSpeedMode "FULL";
                        { _x disableAI "AUTOTARGET"; _x disableAI "TARGET"; _x setSkill ["courage", 1]; } forEach (units _grp);
                        // Reissue landAt to the heli's current position -- overrides evasive AI
                        private _landPos = getPosATL _vehicle;
                        _landPos set [2, 0];
                        private _pad = createVehicle ["Land_HelipadEmpty_F", _landPos, [], 0, "CAN_COLLIDE"];
                        _vehicle landAt _pad;
                        [_vehicle, _pad] spawn {
                            private _h = _this select 0; private _p = _this select 1; private _t = 0;
                            waitUntil { sleep 2; _t = _t + 2; isTouchingGround _h || !alive _h || _t > 60 };
                            deleteVehicle _p;
                        };
                    };
                }];
                _hitEHAdded = true;
                if (_dbg) then { ["ML - heliDeliveryWatchdog: %1 hit EH attached.", _tProfID] call ALiVE_fnc_dump; };
            };

            while {_running} do {
                sleep 5;
                _phaseTimer = _phaseTimer + 5;

                private _tProf = [ALIVE_profileHandler, "getProfile", _tProfID] call ALIVE_fnc_profileHandler;
                private _vProf = [ALIVE_profileHandler, "getProfile", _vProfID] call ALIVE_fnc_profileHandler;

                // Profile gone - heli destroyed or cleaned up
                if (isNil "_tProf" || isNil "_vProf") exitWith {
                    if (_dbg) then { ["ML - heliDeliveryWatchdog: Profile gone (%1), exiting.", _tProfID] call ALiVE_fnc_dump; };
                    _running = false;
                };

                private _isActive = _vProf select 2 select 1;
                private _heli     = _vProf select 2 select 10;

                // Only act when physically spawned - never force virtualisation state
                if (_isActive && !isNull _heli && alive _heli) then {

                    private _posASL    = getPosASL _heli;
                    private _groundASL = getTerrainHeightASL _posASL;
                    private _heightAGL = (_posASL select 2) - _groundASL;
                    private _spd       = speed _heli;

                    switch (_phase) do {

                        // TRANSIT - wait until heli reaches destination area
                        case 0: {
                            private _distToDest = _heli distance _destPos;
                            private _heliAGLt  = (getPosATL _heli) select 2;
                            private _heliSpdT  = round (speed _heli);
                            if (_dbg) then {
                                ["ML - heliDeliveryWatchdog: %1 TRANSIT dist=%2m AGL=%3m spd=%4km/h slungAttached=%5 t=%6s",
                                    _tProfID, round _distToDest, round _heliAGLt, _heliSpdT,
                                    !isNull (getSlingLoad _heli), _phaseTimer] call ALiVE_fnc_dump;
                            };
                            if (_distToDest < 350) then {
                                // For slingload helis, skip LANDING entirely -- landAt is ignored
                                // by the Arma AI when carrying a slung vehicle, so the heli never
                                // descends. Go straight to UNLOAD and signal unloadTransportHelicopter
                                // to force-release the slung load via the RTB path.
                                _phase = 2; _phaseTimer = 0;
                                _heli setVariable ["alive_ml_watchdog_phase", _phase];
                                // Signal heliTransport to call unloadTransportHelicopter.
                                // Do NOT set alive_ml_rtb_issued yet -- the sling may not be
                                // physically attached at this point. RTB is issued from case 2
                                // once alive_ml_sling_unload_active confirms monitoring started.
                                private _tProfSig = [ALIVE_profileHandler, "getProfile", _tProfID] call ALIVE_fnc_profileHandler;
                                if (!isNil "_tProfSig") then {
                                    [_tProfSig, "alive_ml_sling_ready", true] call ALIVE_fnc_hashSet;
                                };
                                ["ML - heliDeliveryWatchdog: %1 at dest, sling_ready set. class=%2 side=%3 near=%4 AGL=%5m spd=%6km/h slungAttached=%7",
                                    _tProfID, typeOf _heli, str side (driver _heli),
                                    ([getPos _heli] call ALIVE_fnc_taskGetNearestLocationName),
                                    round _heliAGLt, _heliSpdT, !isNull (getSlingLoad _heli)] call ALiVE_fnc_dump;
                            };
                            // Hard timeout - something went wrong in transit
                            if (_phaseTimer > 900) then {
                                ["ML - heliDeliveryWatchdog: %1 TRANSIT timeout at AGL=%2m spd=%3km/h dist=%4m, watchdog exiting.",
                                    _tProfID, round _heliAGLt, _heliSpdT, round _distToDest] call ALiVE_fnc_dump;
                                _running = false;
                            };
                        };

                        // LANDING - kept for non-slingload helis; slingload skips directly to case 2
                        case 1: {
                            _heli setVariable ["alive_ml_sling_landing", true];
                            if (isTouchingGround _heli) then {
                                _phase = 2; _phaseTimer = 0;
                                _heli setVariable ["alive_ml_watchdog_phase", _phase];
                                _heli setVariable ["alive_ml_sling_landing", false];
                                if (_dbg) then { ["ML - heliDeliveryWatchdog: %1 UNLOAD phase.", _tProfID] call ALiVE_fnc_dump; };
                            } else {
                                if (!_landAtIssued) then {
                                    private _grpNow = group (driver _heli);
                                    _grpNow setBehaviour "CARELESS";
                                    _grpNow allowFleeing 0;
                                    _grpNow setCombatMode "BLUE";
                                    _grpNow setSpeedMode "FULL";
                                    { _x disableAI "AUTOTARGET"; _x disableAI "TARGET"; _x setSkill ["courage", 1]; } forEach (units _grpNow);
                                    private _landPos = getPosATL _heli;
                                    _landPos set [2, 0];
                                    private _nearRoad = [getPos _heli] call ALIVE_fnc_getClosestRoad;
                                    if (count _nearRoad > 0 && !surfaceIsWater _nearRoad && (_nearRoad distance2D _heli < 150)) then {
                                        _landPos = _nearRoad;
                                        _landPos set [2, 0];
                                    };
                                    private _landPad = createVehicle ["Land_HelipadEmpty_F", _landPos, [], 0, "CAN_COLLIDE"];
                                    _heli landAt _landPad;
                                    _landAtIssued = true;
                                    [_heli, _landPad] spawn {
                                        private _h = _this select 0; private _p = _this select 1; private _t = 0;
                                        waitUntil { sleep 2; _t = _t + 2; isTouchingGround _h || !alive _h || _t > 120 };
                                        deleteVehicle _p;
                                    };
                                    if (_dbg) then { ["ML - heliDeliveryWatchdog: %1 landAt issued.", _tProfID] call ALiVE_fnc_dump; };
                                };
                                if (_landAtIssued && (_phaseTimer mod 35) < 5) then {
                                    _landAtIssued = false;
                                };
                                if (_phaseTimer > 60) then {
                                    _phase = 2; _phaseTimer = 0;
                                    _heli setVariable ["alive_ml_sling_landing", false];
                                    ["ML - heliDeliveryWatchdog: %1 LANDING timeout (%2m AGL), forcing UNLOAD.", _tProfID, _heightAGL] call ALiVE_fnc_dump;
                                };
                            };
                        };

                        // UNLOAD - wait for cargo to exit, then scatter troops before RTB
                        // UNLOAD (slingload path):
                        // Wait until unloadTransportHelicopter has started monitoring
                        // (alive_ml_sling_unload_active=true), then signal RTB.
                        // This ensures the sling is physically attached before we ask
                        // for force-release, preventing the premature parachute-at-cruise-altitude drop.
                        case 2: {
                            private _slungAttached = !isNull (getSlingLoad _heli);
                            private _unloadActive  = _heli getVariable ["alive_ml_sling_unload_active", false];
                            private _heliAGLu = (getPosATL _heli) select 2;
                            private _heliSpdU = round (speed _heli);

                            if (_slungAttached && _unloadActive) then {
                                // unloadTransportHelicopter is monitoring -- signal it to release
                                _heli setVariable ["alive_ml_rtb_issued", true];

                                // Issue RTB waypoints via profile
                                private _tProfNow = [ALIVE_profileHandler, "getProfile", _tProfID] call ALIVE_fnc_profileHandler;
                                if !(isNil "_tProfNow") then {
                                    private _wpReturn = [_returnPos, 400, "MOVE", "FULL", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                    [_tProfNow, "clearWaypoints"] call ALIVE_fnc_profileEntity;
                                    [_tProfNow, "addWaypoint", _wpReturn] call ALIVE_fnc_profileEntity;
                                };
                                // Issue direct flight commands so the heli physically departs
                                // after sling release rather than hovering at the delivery point.
                                _heli flyInHeight 150;
                                (group (driver _heli)) setSpeedMode "FULL";
                                _heli move _returnPos;

                                _phase = 3; _phaseTimer = 0;
                                _heli setVariable ["alive_ml_watchdog_phase", _phase];
                                if (_hitEHAdded && _hitEH >= 0) then {
                                    _heli removeEventHandler ["HitPart", _hitEH];
                                    _hitEH = -1;
                                    if (_dbg) then { ["ML - heliDeliveryWatchdog: %1 hit EH removed for RTB.", _tProfID] call ALiVE_fnc_dump; };
                                };
                                if (_dbg) then { ["ML - heliDeliveryWatchdog: %1 RTB phase, waypoints issued.", _tProfID] call ALiVE_fnc_dump; };

                            } else {
                                if (_phaseTimer > 60) then {
                                    // Timeout: sling never attached or unload thread never started.
                                    // Force RTB regardless so the heli doesn't hover indefinitely.
                                    ["ML - heliDeliveryWatchdog: %1 UNLOAD timeout (slungAttached=%2 unloadActive=%3) class=%4 side=%5 near=%6 AGL=%7m spd=%8km/h pos=%9, forcing RTB.",
                                        _tProfID, _slungAttached, _unloadActive,
                                        typeOf _heli, str side (driver _heli),
                                        ([getPos _heli] call ALIVE_fnc_taskGetNearestLocationName),
                                        round _heliAGLu, _heliSpdU, getPosATL _heli] call ALiVE_fnc_dump;

                                    // If the sling is still attached, release it directly here.
                                    // unloadTransportHelicopter cannot reach the vehicle object
                                    // via the profile when _active=false (slot 10 is null).
                                    // The watchdog has the live heli reference so it is the
                                    // correct authority to physically release the load.
                                    if (_slungAttached) then {
                                        private _slungVeh = getSlingLoad _heli;
                                        if (!isNull _slungVeh) then {
                                            private _slungAGL = (getPosATL _slungVeh) select 2;
                                            if (_slungAGL > 5) then {
                                                private _para = createVehicle ["B_Parachute_02_F", getPosATL _slungVeh, [], 0, "FLY"];
                                                _para setPosASL (getPosASL _slungVeh);
                                                _para setVelocity (velocity _heli);
                                                _slungVeh attachTo [_para, [0,0,0]];
                                                [_para, _slungVeh] spawn {
                                                    private _p = _this select 0; private _v = _this select 1;
                                                    waitUntil { sleep 1; (getPosATL _v select 2) < 3 || !alive _p };
                                                    detach _v; deleteVehicle _p;
                                                };
                                            };
                                            _heli setSlingLoad objNull;
                                            ["ML - heliDeliveryWatchdog: %1 force-released sling at timeout.", _tProfID] call ALiVE_fnc_dump;
                                        };
                                    };

                                    _heli setVariable ["alive_ml_rtb_issued", true];
                                    private _tProfNow = [ALIVE_profileHandler, "getProfile", _tProfID] call ALIVE_fnc_profileHandler;
                                    if !(isNil "_tProfNow") then {
                                        private _wpReturn = [_returnPos, 400, "MOVE", "FULL", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                        [_tProfNow, "clearWaypoints"] call ALIVE_fnc_profileEntity;
                                        [_tProfNow, "addWaypoint", _wpReturn] call ALIVE_fnc_profileEntity;
                                    };
                                    // Issue direct flight commands so the physically spawned
                                    // heli actually departs rather than hovering after the
                                    // profile waypoint is set.
                                    _heli flyInHeight 150;
                                    (group (driver _heli)) setSpeedMode "FULL";
                                    _heli move _returnPos;
                                    _phase = 3; _phaseTimer = 0;
                                    _heli setVariable ["alive_ml_watchdog_phase", _phase];
                                } else {
                                    if (_dbg) then {
                                        ["ML - heliDeliveryWatchdog: %1 waiting for unload thread (slungAttached=%2 unloadActive=%3 AGL=%4m spd=%5km/h t=%6s).",
                                            _tProfID, _slungAttached, _unloadActive,
                                            round _heliAGLu, _heliSpdU, _phaseTimer] call ALiVE_fnc_dump;
                                    };
                                };
                            };
                        };

                        // RTB - once far enough away, done
                        case 3: {
                            // Enforce full speed egress every iteration while active.
                            // Without this the heli defaults to whatever speed the AI chooses
                            // after the hit EH is removed, often slowing when obstacles are near.
                            private _grpRTB = group (driver _heli);
                            _grpRTB setSpeedMode "FULL";
                            (units _grpRTB) apply { _x forceSpeed 70; };

                            private _distFromDest = _heli distance _destPos;
                            private _heliAGLr = (getPosATL _heli) select 2;
                            private _heliSpdR = round (speed _heli);
                            if (_dbg) then {
                                ["ML - heliDeliveryWatchdog: %1 RTB dist=%2m AGL=%3m spd=%4km/h t=%5s",
                                    _tProfID, round _distFromDest, round _heliAGLr, _heliSpdR, _phaseTimer] call ALiVE_fnc_dump;
                            };
                            if (_distFromDest > 1200 || _phaseTimer > 600) then {
                                ["ML - heliDeliveryWatchdog: %1 RTB complete. class=%2 near=%3 dist=%4m AGL=%5m spd=%6km/h t=%7s",
                                    _tProfID, typeOf _heli,
                                    ([getPos _heli] call ALIVE_fnc_taskGetNearestLocationName),
                                    round _distFromDest, round _heliAGLr, _heliSpdR, _phaseTimer] call ALiVE_fnc_dump;
                                // Clear preventDespawn on heli vehicle and pilot entity profiles.
                                // Safe to do here at dist>1200m -- ALiVE will virtualise the heli
                                // shortly after, and fnc_profileEntity now moveOut's crew before
                                // deleteVehicle so there is no longer any ejection risk.
                                private _vProfRTB = [ALIVE_profileHandler, "getProfile", _vProfID] call ALIVE_fnc_profileHandler;
                                if (!isNil "_vProfRTB") then {
                                    [_vProfRTB, "spawnType", []] call ALIVE_fnc_profileVehicle;
                                    private _pilotIDRTB = [_vProfRTB, "alive_ml_pilot_entity_id", ""] call ALIVE_fnc_hashGet;
                                    if (_pilotIDRTB != "") then {
                                        private _pilotProfRTB = [ALIVE_profileHandler, "getProfile", _pilotIDRTB] call ALIVE_fnc_profileHandler;
                                        if (!isNil "_pilotProfRTB") then {
                                            [_pilotProfRTB, "spawnType", []] call ALIVE_fnc_hashSet;
                                        };
                                    };
                                    ["ML - heliDeliveryWatchdog: %1 preventDespawn cleared at RTB (dist=%2m).",
                                        _tProfID, round _distFromDest] call ALiVE_fnc_dump;
                                };
                                _running = false;
                            };
                        };

                    }; // end switch

                } else {
                    // Heli is virtual (not near players) - just track time and exit if too long
                    // Don't try to force it active - trust ALiVE's virtualisation
                    if (_phase == 3 && _phaseTimer > 120) then {
                        // RTB and virtual = successfully departed, done
                        _running = false;
                        if (_dbg) then { ["ML - heliDeliveryWatchdog: %1 virtualised in RTB, done.", _tProfID] call ALiVE_fnc_dump; };
                    };
                    if (_phaseTimer > 1200) then {
                        // Something went wrong - exit to avoid zombie watchdog
                        _running = false;
                        ["ML - heliDeliveryWatchdog: %1 global timeout, exiting.", _tProfID] call ALiVE_fnc_dump;
                    };
                };

            }; // end while

        }; // end spawn

    }; // end case spawnHeliDeliveryWatchdog



    // ============================================================
    // OPERATION: spawnHeliParadropWatchdog
    // ============================================================
    case "spawnHeliParadropWatchdog": {
        private _tProfID = _args select 0;
        private _vProfID = _args select 1;
        private _destPos = _args select 2;
        private _returnPos = _args select 3;
        private _infantryIDs = _args select 4;
        private _dropHeight = _args select 5;
        private _dbg = _args select 6;

        [_tProfID, _vProfID, _destPos, _returnPos, _infantryIDs, _dropHeight, _dbg] spawn {
            private _tProfID = _this select 0;
            private _vProfID = _this select 1;
            private _destPos = _this select 2;
            private _returnPos = _this select 3;
            private _infantryIDs = _this select 4;
            private _dropHeight = _this select 5;
            private _dbg = _this select 6;

            private _dropRadius = 350;
            private _transitTimeout = 900;
            private _phaseTimer = 0;
            private _phase = 0;
            private _dropped = false;
            // Loop runs every 2s instead of 5s so altitude enforcement fires more
            // frequently and keeps pace with the AI's continuous descent on approach.
            private _loopInterval = 2;
            // Set true on the first loop tick where the heli is active (spawned).
            // Used to detect the virtual->active transition and apply one-time fixes.
            private _wasActive = false;
            // Accumulates seconds the heli has spent within _dropRadius but below
            // PARADROP_MIN_DROP_HEIGHT. After 30s a forced drop fires regardless of
            // altitude to prevent the heli hovering indefinitely at the DZ.
            private _stuckLowTimer = 0;
            // Stores the AGL overshoot position set by the first-activation block.
            // Re-issued via doMove every loop tick so the AI never runs out of movement
            // orders. addWaypoint is unreliable on vehicles not created by the ALiVE
            // placement system; doMove is the safe alternative.
            private _overshootPosAGL = [];
            ["ML - heliParadropWatchdog: %1 STARTED. dest=%2 groups=%3 dropHeight=%4m dropRadius=%5m loopInterval=%6s",
                _tProfID, _destPos, count _infantryIDs, _dropHeight, _dropRadius, _loopInterval] call ALiVE_fnc_dump;

            // Hit EH: paradrop helis fly at 500m AGL and must not be diverted by ground fire.
            // Attach on first activation, remove once drops are complete.
            private _paradropHitEH = -1;
            private _paradropHitEHObj = objNull;

            while { _phase == 0 } do {
                sleep _loopInterval;
                _phaseTimer = _phaseTimer + _loopInterval;

                private _tp = [ALIVE_profileHandler, "getProfile", _tProfID] call ALIVE_fnc_profileHandler;

                if (isNil "_tp") then {
                    ["ML - heliParadropWatchdog: %1 profile gone at %2s. Aborting.", _tProfID, _phaseTimer] call ALiVE_fnc_dump;
                    _phase = 2;
                } else {
                    if (_phaseTimer > _transitTimeout) then {
                        ["ML - heliParadropWatchdog: %1 TRANSIT timeout at %2s. Forcing drop.", _tProfID, _phaseTimer] call ALiVE_fnc_dump;
                        _phase = 1;
                    } else {
                        // _tp is the entity (crew) profile. The vehicle object lives in
                        // the vehicle profile at _vProfID. Read it from there.
                        // _tp select 2 select 10 = "leader" on an entity profile -- wrong.
                        private _vp = if (_vProfID != "") then {
                            [ALIVE_profileHandler, "getProfile", _vProfID] call ALIVE_fnc_profileHandler
                        } else { nil };

                        private _heli = if (!isNil "_vp") then { _vp select 2 select 10 } else { objNull };

                        // Diagnostic: log vehicle profile / heli object status every 10s
                        if (_phaseTimer % 10 == 0) then {
                            ["ML - heliParadropWatchdog: %1 vProfID=%2 vpNil=%3 heliNull=%4 heliAlive=%5 t=%6s",
                                _tProfID, _vProfID, isNil "_vp", isNull _heli,
                                (!isNull _heli && alive _heli), _phaseTimer] call ALiVE_fnc_dump;
                        };

                        // _heliCanFly guards against helis that have lost rotors/engines
                        // but are still alive. alive returns true for a rotor-less heli,
                        // so without this check flyInHeight/setVelocity keep it airborne
                        // as a flying wreck indefinitely.
                        private _heliCanFly = false;
                        if (!isNull _heli && {alive _heli}) then {
                            // Check main rotor and tail rotor damage + engine status
                            private _mainRotorDamage = _heli getHitPointDamage "HitHRotor"; // main rotor (most important)
                            private _tailRotorDamage = _heli getHitPointDamage "HitVRotor"; // tail rotor
                            private _engineDamage    = _heli getHitPointDamage "HitEngine";

                            _heliCanFly = (_mainRotorDamage < 0.9) &&
                                          (_tailRotorDamage < 0.9) &&
                                          (_engineDamage < 0.9) &&
                                          (isEngineOn _heli || canMove _heli);
                        };

                        if (!isNull _heli && {alive _heli && !_heliCanFly}) then {
                            // Heli is alive but can no longer fly (rotors/engines destroyed).
                            // Stop issuing flight commands -- let it fall and treat as lost.
                            ["ML - heliParadropWatchdog: %1 alive but _heliCanFly=false (rotor/engine loss). Treating as destroyed. Aborting.",
                                _tProfID] call ALiVE_fnc_dump;
                            _phase = 2;
                        };

                        if (_heliCanFly) then {
                            // -------------------------------------------------------
                            // FIRST-ACTIVATION CORRECTION
                            // When a profile transitions virtual->active, the vehicle
                            // spawns at its stored profile position which has z=0
                            // (ground level). We detect the first tick where the heli
                            // is active and immediately:
                            // (a) Teleport the heli to PARADROP_HEIGHT AGL so the AI
                            // starts at the correct altitude.
                            // (b) Clear the native Arma waypoints (which were
                            // converted from the profile waypoint at z=0 or
                            // z=PARADROP_HEIGHT but the AI descends into anyway)
                            // and replace with a single overshoot waypoint 600m
                            // PAST the DZ at PARADROP_HEIGHT. The AI then flies
                            // THROUGH the drop zone at altitude rather than
                            // decelerating and descending into it.
                            // -------------------------------------------------------

                            if (!_wasActive) then {
                                _wasActive = true;
                                private _posASL = getPosASL _heli;
                                private _terrainH = getTerrainHeightASL [_posASL select 0, _posASL select 1];
                                private _curAGL = (_heli modelToWorldVisual [0,0,0]) select 2;
                                ["ML - heliParadropWatchdog: %1 FIRST ACTIVATION. spawnAGL=%2m terrainASL=%3m. Applying altitude correction to %4m AGL.",
                                    _tProfID, round _curAGL, round _terrainH, PARADROP_HEIGHT] call ALiVE_fnc_dump;

                                // (a) Command the heli to climb to PARADROP_HEIGHT using flyInHeight.
                                // This lets the AI climb smoothly rather than teleporting,
                                // which prevents cargo detachment and looks correct visually.
                                // A strong upward velocity kick starts the climb immediately.
                                private _curVel = velocity _heli;
                                _heli setVelocity [_curVel select 0, _curVel select 1, 15];
                                _heli flyInHeight PARADROP_HEIGHT;

                                // Extended climb window: suppress drop trigger for 30s so the
                                // heli has time to reach altitude before we start checking dist.
                                _phaseTimer = 0;

                                // (b) Issue overshoot native waypoint: 600m past DZ at PARADROP_HEIGHT.
                                // The AI overflies the DZ on the way to the overshoot point,
                                // maintaining altitude across the entire drop zone.
                                private _heliPos2D = [_posASL select 0, _posASL select 1, 0];
                                private _dzDir = _heliPos2D getDir _destPos;
                                private _overshoot = _destPos getPos [600, _dzDir];
                                private _overshootASL = AGLToASL _overshoot;
                                _overshootASL set [2, (_terrainH + PARADROP_HEIGHT)];

                                private _grpNow = group (driver _heli);
                                // Clear any native waypoints inherited from profile system
                                private _wpCount = count (waypoints _grpNow);
                                while { count (waypoints _grpNow) > 0 } do {
                                    deleteWaypoint [_grpNow, 0];
                                };

                                // Use doMove instead of addWaypoint. addWaypoint silently fails
                                // on vehicles not created by the ALiVE placement system
                                // (e.g. createVehicle vehicles, test harness, etc.) because their
                                // AI pilot groups are not initialised the same way. doMove is a
                                // direct AI order that works regardless of vehicle origin. It is
                                // re-issued every loop tick below to prevent the AI from ignoring
                                // it on approach or after completing previous movement orders.
                                _overshootPosAGL = ASLToAGL _overshootASL;

                                // Use vehicle-level move command, not (driver) doMove.
                                // doMove on a unit issues a walking order -- a seated pilot
                                // cannot act on it and the heli gets no flight instruction.
                                // _heli move issues the order directly to the vehicle AI.
                                _heli move _overshootPosAGL;
                                _heli flyInHeight PARADROP_HEIGHT;

                                // Also set velocity toward target so AI has initial momentum
                                private _toOvDir = _heliPos2D getDir _overshootPosAGL;
                                _heli setVelocity [
                                    50 * sin _toOvDir,
                                    50 * cos _toOvDir,
                                    2
                                ];

                                ["ML - heliParadropWatchdog: %1 Overshoot move issued. DZ=%2 overshoot=%3 (DZ+600m at %4m AGL). Cleared %5 old WPs.",
                                    _tProfID, _destPos, _overshootPosAGL, PARADROP_HEIGHT, _wpCount] call ALiVE_fnc_dump;
                            };

                            // Enforce mission AI behaviour every iteration while in transit.
                            // Without this, taking fire re-enables targeting and evasion between
                            // monitor loop calls, causing the heli to break off course.
                            private _grp = group (driver _heli);
                            _grp setBehaviour "CARELESS";
                            _grp allowFleeing 0;
                            _grp setCombatMode "BLUE";
                            _grp setSpeedMode "FULL";
                            { _x disableAI "AUTOTARGET"; _x disableAI "TARGET"; _x setSkill ["courage", 1]; } forEach (units _grp);

                            // Attach hit EH once the heli is active -- resets course immediately on hit
                            if (_paradropHitEH < 0 && isNull _paradropHitEHObj) then {
                                _paradropHitEHObj = _heli;
                                _paradropHitEH = _heli addEventHandler ["HitPart", {
                                    params ["_event"];
                                    private _vehicle = _event select 0;

                                    // Guard: _heliCanFly=false means rotors/engines are gone.
                                    // Do not issue flight commands to a rotor-less heli --
                                    // it would be held airborne as a flying wreck.
                                    if (!isNull _vehicle) then {
                                        // Check main rotor and tail rotor damage + engine status
                                        private _mainRotorDamage = _vehicle getHitPointDamage "HitHRotor"; // main rotor (most important)
                                        private _tailRotorDamage = _vehicle getHitPointDamage "HitVRotor"; // tail rotor
                                        private _engineDamage    = _vehicle getHitPointDamage "HitEngine";

                                        private _canStillFly = (_mainRotorDamage < 0.9) &&
                                                               (_tailRotorDamage < 0.9) &&
                                                               (_engineDamage < 0.9) &&
                                                               (isEngineOn _vehicle || canMove _vehicle);

                                        if (alive _vehicle && _canStillFly) then {
                                            private _g = group (driver _vehicle);
                                            _g setBehaviour "CARELESS";
                                            _g allowFleeing 0;
                                            _g setCombatMode "BLUE";
                                            _g setSpeedMode "FULL";
                                            { _x disableAI "AUTOTARGET"; _x disableAI "TARGET"; _x setSkill ["courage", 1]; } forEach (units _g);

                                            // Re-enforce altitude immediately on hit so AI doesn't dive
                                            _vehicle flyInHeight PARADROP_HEIGHT;
                                        };
                                    };
                                }];
                                ["ML - heliParadropWatchdog: %1 transit hit EH attached.", _tProfID] call ALiVE_fnc_dump;
                            };

                            private _dist = _heli distance2D _destPos;
                            private _heliAGL = (_heli modelToWorldVisual [0,0,0]) select 2;
                            private _heliSpd = round (speed _heli);
                            private _heliPos = getPosASL _heli;
                            private _wpCountNow = count (waypoints (group (driver _heli)));

                            // Always log every tick so future logs have full resolution
                            ["ML - heliParadropWatchdog: %1 TRANSIT active. dist=%2m AGL=%3m spd=%4km/h pos=[%5,%6] nativeWPs=%7 t=%8s",
                                _tProfID, round _dist, round _heliAGL, _heliSpd,
                                round (_heliPos select 0), round (_heliPos select 1),
                                _wpCountNow, _phaseTimer] call ALiVE_fnc_dump;

                            // Enforce minimum paradrop altitude every tick.
                            // flyInHeight is advisory but loses to the AI's natural descent
                            // on approach. Re-issue every tick to keep the order active.
                            // NOTE: no setVelocity kick here -- applying a vertical kick every
                            // 2s causes the AI to pitch nose-up, bleed all forward airspeed,
                            // and oscillate between climbing and descending without making
                            // progress toward the DZ. The kick belongs only in first-activation.
                            if (_heliAGL < PARADROP_MIN_DROP_HEIGHT) then {
                                _heli flyInHeight PARADROP_HEIGHT;
                                if (count _overshootPosAGL > 0) then { _heli move _overshootPosAGL; };
                                ["ML - heliParadropWatchdog: %1 below min AGL (%2m < %3m). Re-issuing climb command.",
                                    _tProfID, round _heliAGL, PARADROP_MIN_DROP_HEIGHT] call ALiVE_fnc_dump;
                            };

                            // Re-issue vehicle move every tick toward the stored overshoot position.
                            // ALSO clear native waypoints every tick: the ALiVE profile system
                            // re-adds the original profile waypoint (z=ground) each simulation
                            // cycle. The AI prioritises its native WP queue over _heli move, so
                            // if that ground-level WP is present the heli decelerates, descends,
                            // and hovers stationary rather than flying to the overshoot point.
                            // Deleting it every 2s ensures _heli move always has clear authority.
                            if (count _overshootPosAGL > 0) then {
                                private _grpTick = group (driver _heli);
                                while { count (waypoints _grpTick) > 0 } do {
                                    deleteWaypoint [_grpTick, 0];
                                };
                                _heli move _overshootPosAGL;
                            };

                            // Drop trigger logic with stuck-low fallback.
                            if (_dist < _dropRadius) then {
                                if (_heliAGL >= PARADROP_MIN_DROP_HEIGHT) then {
                                    // Nominal drop: within radius AND at correct altitude
                                    ["ML - heliParadropWatchdog: %1 NOMINAL DROP TRIGGER. dist=%2m AGL=%3m >= MIN=%4m. Beginning drop.",
                                        _tProfID, round _dist, round _heliAGL, PARADROP_MIN_DROP_HEIGHT] call ALiVE_fnc_dump;
                                    _stuckLowTimer = 0;
                                    _phase = 1;
                                } else {
                                    // Within radius but below minimum height. Accumulate stuck-low timer.
                                    // After 30s force a drop anyway -- hovering forever is worse than
                                    // a low-altitude drop.
                                    _stuckLowTimer = _stuckLowTimer + _loopInterval;
                                    ["ML - heliParadropWatchdog: %1 STUCK-LOW: dist=%2m AGL=%3m < MIN=%4m. stuckLowTimer=%5s/30s.",
                                        _tProfID, round _dist, round _heliAGL, PARADROP_MIN_DROP_HEIGHT, _stuckLowTimer] call ALiVE_fnc_dump;

                                    if (_stuckLowTimer >= 30) then {
                                        ["ML - heliParadropWatchdog: %1 STUCK-LOW FORCED DROP after %2s. dist=%3m AGL=%4m. Dropping at sub-optimal altitude.",
                                            _tProfID, _stuckLowTimer, round _dist, round _heliAGL] call ALiVE_fnc_dump;
                                        _phase = 1;
                                    };
                                };
                            } else {
                                // Outside drop radius -- reset stuck-low timer
                                if (_stuckLowTimer > 0) then {
                                    ["ML - heliParadropWatchdog: %1 moved outside drop radius (dist=%2m). stuckLowTimer reset.",
                                        _tProfID, round _dist] call ALiVE_fnc_dump;
                                    _stuckLowTimer = 0;
                                };
                            };
                        } else {
                            // Virtual transit: profile system is moving the position.
                            // Log every tick unconditionally so the RPT shows full position
                            // history and the virtual->active transition is precisely locatable.
                            private _profPos = _tp select 2 select 2;
                            private _dist2D = if (count _profPos > 1) then { _profPos distance2D _destPos } else { -1 };
                            private _profPosStr = if (count _profPos > 1) then {
                                format ["[%1,%2]", round (_profPos select 0), round (_profPos select 1)]
                            } else { "unknown" };

                            ["ML - heliParadropWatchdog: %1 TRANSIT virtual. profPos=%2 dist=%3m t=%4s",
                                _tProfID, _profPosStr, round _dist2D, _phaseTimer] call ALiVE_fnc_dump;

                            if (_dist2D >= 0 && _dist2D < _dropRadius) then {
                                ["ML - heliParadropWatchdog: %1 over DZ (virtual) dist=%2m. Beginning drop.",
                                    _tProfID, round _dist2D] call ALiVE_fnc_dump;
                                _phase = 1;
                            } else {
                                if (_phaseTimer > 180) then {
                                    ["ML - heliParadropWatchdog: %1 virtual timeout at %2s dist=%3m. Forcing drop.",
                                        _tProfID, _phaseTimer, round _dist2D] call ALiVE_fnc_dump;
                                    _phase = 1;
                                };
                            };
                        };
                    };
                };
            };

            // Remove transit hit EH -- drop phase doesn't need course correction
            if (_paradropHitEH >= 0 && !isNull _paradropHitEHObj) then {
                _paradropHitEHObj removeEventHandler ["HitPart", _paradropHitEH];
                _paradropHitEH = -1;
                ["ML - heliParadropWatchdog: %1 transit hit EH removed.", _tProfID] call ALiVE_fnc_dump;
            };

            if (_phase == 1) then {
                private _tp2   = [ALIVE_profileHandler, "getProfile", _tProfID] call ALIVE_fnc_profileHandler;
                // Heli object lives in the vehicle profile, not the entity (crew) profile.
                private _vp2   = if (_vProfID != "") then {
                    [ALIVE_profileHandler, "getProfile", _vProfID] call ALIVE_fnc_profileHandler
                } else { nil };
                private _heli2 = if (!isNil "_vp2") then { _vp2 select 2 select 10 } else { objNull };
                private _heliActive = (!isNull _heli2 && alive _heli2);

                // Log full drop-entry state: position, altitude, velocity, active/virtual
                private _dropAGL  = if (_heliActive) then { round ((_heli2 modelToWorldVisual [0,0,0]) select 2) } else { -1 };
                private _dropPos  = if (_heliActive) then { getPosASL _heli2 } else { [0,0,0] };
                private _dropVel  = if (_heliActive) then { velocity _heli2 } else { [0,0,0] };
                private _dropSpd  = if (_heliActive) then { round (speed _heli2) } else { -1 };
                ["ML - heliParadropWatchdog: %1 DROP phase. heliActive=%2 groups=%3 AGL=%4m spd=%5km/h pos=[%6,%7] vel=[%8,%9,%10]",
                    _tProfID, _heliActive, count _infantryIDs,
                    _dropAGL, _dropSpd,
                    round (_dropPos select 0), round (_dropPos select 1),
                    round (_dropVel select 0), round (_dropVel select 1), round (_dropVel select 2)] call ALiVE_fnc_dump;

                {
                    private _infProfID  = _x;
                    private _infProfile = [ALIVE_profileHandler, "getProfile", _infProfID] call ALIVE_fnc_profileHandler;
                    if (!isNil "_infProfile") then {

                        if (_heliActive) then {
                            // -------------------------------------------------------
                            // ACTIVE drop: heli is within activation range.
                            // Teleport infantry profile position to ground below the heli
                            // so ALiVE will spawn them (out-of-range spawn silently fails),
                            // then physically place them in parachutes.
                            // -------------------------------------------------------
                            private _heliPos = getPos _heli2;  // ground-level x,y beneath heli
                            [_infProfile, "position", _heliPos] call ALIVE_fnc_profileEntity;

                            // Remove vehicle assignment before spawning. Infantry profiles
                            // were assigned to the transport heli at creation so the profile
                            // system tracks their position from the vehicle during transit.
                            // With the assignment still in place ALiVE may spawn the units
                            // already seated in the heli, after which moveInDriver into a
                            // parachute silently fails or conflicts with the seated state.
                            // Clearing the assignment here forces ALiVE to spawn them as a
                            // free infantry group at _heliPos, ready to be placed in chutes.
                            private _vAssignClear = [] call ALIVE_fnc_hashCreate;
                            [_infProfile, "vehicleAssignments",  _vAssignClear] call ALIVE_fnc_hashSet;
                            [_infProfile, "vehiclesInCargoOf",   []]            call ALIVE_fnc_hashSet;
                            [_infProfile, "vehiclesInCommandOf", []]            call ALIVE_fnc_hashSet;
                            [_infProfile, "speedPerSecond", "Man" call ALIVE_fnc_vehicleGetSpeedPerSecond] call ALIVE_fnc_hashSet;

                            private _infUnits = _infProfile select 2 select 21;
                            ["ML - heliParadropWatchdog: %1 inf profile %2 units before spawn: %3 active=%4 heliPos=[%5,%6] heliAGL=%7m",
                                _tProfID, _infProfID, count _infUnits, _infProfile select 2 select 1,
                                round (_dropPos select 0), round (_dropPos select 1),
                                _dropAGL] call ALiVE_fnc_dump;
                            if (count _infUnits == 0) then {
                                [_infProfile, "spawn"] call ALIVE_fnc_profileEntity;
                                // Wait for ALiVE to materialise units -- max 5 seconds
                                private _spawnTimer = 0;
                                waitUntil {
                                    sleep 0.1;
                                    _spawnTimer = _spawnTimer + 0.1;
                                    _infUnits = _infProfile select 2 select 21;
                                    (count _infUnits > 0) || (_spawnTimer > 5)
                                };
                                ["ML - heliParadropWatchdog: %1 inf profile %2 units after spawn: %3 (waited %4s)",
                                    _tProfID, _infProfID, count _infUnits, round _spawnTimer] call ALiVE_fnc_dump;
                            };

                            // Eject any units that spawned inside the heli due to a
                            // residual vehicle assignment, then place all in parachutes.
                            {
                                private _unit = _x;
                                if (alive _unit) then {
                                    // Eject from heli if seated -- moveInDriver into a
                                    // parachute fails silently when the unit is in a vehicle.
                                    if (vehicle _unit != _unit) then {
                                        unassignVehicle _unit;
                                        _unit moveOut (vehicle _unit);
                                    };
                                    private _dropPosASL = getPosASL _heli2;
                                    _dropPosASL set [2, (_dropPosASL select 2) - 8];
                                    private _para = createVehicle ["Steerable_Parachute_F", ASLToAGL _dropPosASL, [], 0, "CAN_COLLIDE"];
                                    _para allowDamage false;
                                    _para setPosASL _dropPosASL;
                                    _para setVelocity (velocity _heli2);
                                    _unit moveInDriver _para;
                                    [_unit, _para] spawn {
                                        params ["_u", "_p"];
                                        _u allowDamage false;
                                        // Wait until touching ground, para deleted, or 60s timeout
                                        private _t = 0;
                                        waitUntil {
                                            sleep 0.5; _t = _t + 0.5;
                                            isTouchingGround _u || isNull _p || _t > 60
                                        };
                                        sleep 2; // brief grace period after landing
                                        if (alive _u) then { _u allowDamage true; };
                                    };
                                    ["ML - heliParadropWatchdog: %1 unit %2 dropped in parachute. paraPos=[%3,%4] paraAGL=%5m heliVel=[%6,%7,%8]",
                                        _tProfID, _unit,
                                        round ((ASLToAGL _dropPosASL) select 0), round ((ASLToAGL _dropPosASL) select 1),
                                        round ((ASLToAGL _dropPosASL) select 2),
                                        round ((velocity _heli2) select 0), round ((velocity _heli2) select 1), round ((velocity _heli2) select 2)] call ALiVE_fnc_dump;
                                    sleep 0.4;
                                };
                            } forEach _infUnits;

                        } else {
                            // -------------------------------------------------------
                            // VIRTUAL drop: heli is not within activation range.
                            // If players are near the DZ, attempt to force-spawn the
                            // heli profile so the active parachute path can run instead.
                            // This prevents units materialising on the ground when
                            // players are watching the drop zone.
                            // -------------------------------------------------------
                            private _tp3 = [ALIVE_profileHandler, "getProfile", _tProfID] call ALIVE_fnc_profileHandler;
                            private _playersNearDZ = ([_destPos, 1500] call ALiVE_fnc_anyPlayersInRange) > 0;
                            if (!isNil "_tp3" && _playersNearDZ) then {
                                // Set heli profile position to directly above the DZ at PARADROP_HEIGHT
                                // before spawning. Without this the heli materialises at its current
                                // virtual profile position which is Z=0 ground level -- infantry
                                // parachutes are then created at ground level and units die on impact.
                                private _spawnPos = +_destPos;
                                _spawnPos set [2, PARADROP_HEIGHT];
                                [_tp3, "position", _spawnPos] call ALIVE_fnc_profileEntity;
                                [_tp3, "spawn"] call ALIVE_fnc_profileEntity;
                                // Wait up to 3s for the heli vehicle object to materialise
                                private _spawnWait = 0;
                                private _heli3 = objNull;
                                waitUntil {
                                    sleep 0.2;
                                    _spawnWait = _spawnWait + 0.2;
                                    _tp3 = [ALIVE_profileHandler, "getProfile", _tProfID] call ALIVE_fnc_profileHandler;
                                    private _vp3w = if (_vProfID != "") then {
                                        [ALIVE_profileHandler, "getProfile", _vProfID] call ALIVE_fnc_profileHandler
                                    } else { nil };
                                    if (!isNil "_vp3w") then { _heli3 = _vp3w select 2 select 10; };
                                    (!isNull _heli3 && alive _heli3) || _spawnWait > 3
                                };
                                if (!isNull _heli3 && alive _heli3) then {
                                    // Heli activated -- clear vehicle assignment and run active parachute drop.
                                    // Mirror the active drop path: remove assignment before spawning infantry
                                    // so units don't materialise inside the heli, and eject any that do.
                                    if (_dbg) then {
                                        ["ML - heliParadropWatchdog: %1 force-spawned heli near DZ. Running active drop.", _tProfID] call ALiVE_fnc_dump;
                                    };
                                    private _vAssignClear2 = [] call ALIVE_fnc_hashCreate;
                                    [_infProfile, "vehicleAssignments",  _vAssignClear2] call ALIVE_fnc_hashSet;
                                    [_infProfile, "vehiclesInCargoOf",   []]             call ALIVE_fnc_hashSet;
                                    [_infProfile, "vehiclesInCommandOf", []]             call ALIVE_fnc_hashSet;
                                    [_infProfile, "speedPerSecond", "Man" call ALIVE_fnc_vehicleGetSpeedPerSecond] call ALIVE_fnc_hashSet;
                                    {
                                        private _unit = _x;
                                        if (alive _unit) then {
                                            if (vehicle _unit != _unit) then {
                                                unassignVehicle _unit;
                                                _unit moveOut (vehicle _unit);
                                            };
                                            private _dropPosASL = getPosASL _heli3;
                                            _dropPosASL set [2, (_dropPosASL select 2) - 8];
                                            private _para = createVehicle ["Steerable_Parachute_F", ASLToAGL _dropPosASL, [], 0, "CAN_COLLIDE"];
                                            _para allowDamage false;
                                            _para setPosASL _dropPosASL;
                                            _para setVelocity (velocity _heli3);
                                            _unit moveInDriver _para;
                                            [_unit, _para] spawn {
                                                params ["_u", "_p"];
                                                _u allowDamage false;
                                                private _t = 0;
                                                waitUntil {
                                                    sleep 0.5; _t = _t + 0.5;
                                                    isTouchingGround _u || isNull _p || _t > 60
                                                };
                                                sleep 2;
                                                if (alive _u) then { _u allowDamage true; };
                                            };
                                            if (_dbg) then {
                                                ["ML - heliParadropWatchdog: %1 unit %2 dropped (force-spawn path)", _tProfID, _unit] call ALiVE_fnc_dump;
                                            };
                                            sleep 0.4;
                                        };
                                    } forEach (_infProfile select 2 select 21);
                                } else {
                                    // Force-spawn failed -- fall back to profile teleport
                                    if (_dbg) then {
                                        ["ML - heliParadropWatchdog: %1 force-spawn failed, falling back to virtual drop.", _tProfID] call ALiVE_fnc_dump;
                                    };
                                    [_infProfile, "position", _destPos] call ALIVE_fnc_profileEntity;
                                    private _wpDest = [_destPos, 100, "MOVE", "NORMAL", 60, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                    [_infProfile, "clearWaypoints"] call ALIVE_fnc_profileEntity;
                                    [_infProfile, "addWaypoint", _wpDest] call ALIVE_fnc_profileEntity;
                                };
                            } else {
                                // No players near DZ -- safe to teleport profile silently
                                [_infProfile, "position", _destPos] call ALIVE_fnc_profileEntity;
                                private _wpDest = [_destPos, 100, "MOVE", "NORMAL", 60, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                [_infProfile, "clearWaypoints"] call ALIVE_fnc_profileEntity;
                                [_infProfile, "addWaypoint", _wpDest] call ALIVE_fnc_profileEntity;
                                if (_dbg) then {
                                    ["ML - heliParadropWatchdog: %1 virtual drop -- inf profile %2 teleported to %3", _tProfID, _infProfID, _destPos] call ALiVE_fnc_dump;
                                };
                            };
                        };

                    } else {
                        if (_dbg) then {
                            ["ML - heliParadropWatchdog: %1 inf profile %2 is nil, skipping.", _tProfID, _infProfID] call ALiVE_fnc_dump;
                        };
                    };
                } forEach _infantryIDs;
                _dropped = true;
                ["ML - heliParadropWatchdog: %1 drop phase complete. dropped=%2 groups=%3",
                    _tProfID, _dropped, count _infantryIDs] call ALiVE_fnc_dump;
            };

            // Signal completion only after a successful drop
            if (_dropped) then {
                if (isNil "ALIVE_ML_paradropComplete") then { ALIVE_ML_paradropComplete = []; };
                ALIVE_ML_paradropComplete pushBackUnique _tProfID;
                ["ML - heliParadropWatchdog: %1 paradropComplete signalled. Watchdog exiting.", _tProfID] call ALiVE_fnc_dump;
            } else {
                ["ML - heliParadropWatchdog: %1 exiting WITHOUT drop (phase=%2). paradropComplete NOT signalled.", _tProfID, _phase] call ALiVE_fnc_dump;
            };

        };

    }; // end case spawnHeliParadropWatchdog

    // Main process
    case "init": {
        if (isServer) then {

            private ["_debug","_forcePool","_type","_allowInfantry","_allowMechanised","_allowMotorised","_allowArmour","_allowHeli","_allowPlane"];

            // if server, initialise module game logic
            _logic setVariable ["super", SUPERCLASS];
            _logic setVariable ["class", MAINCLASS];
            _logic setVariable ["moduleType", "ALIVE_ML"];
            _logic setVariable ["startupComplete", false];
            _logic setVariable ["listenerID", ""];
            _logic setVariable ["registryID", ""];
            _logic setVariable ["initialAnalysisComplete", false];
            _logic setVariable ["analysisInProgress", false];
            _logic setVariable ["eventQueue", [] call ALIVE_fnc_hashCreate];

            _debug = [_logic, "debug"] call MAINCLASS;
            _forcePool = [_logic, "forcePool"] call MAINCLASS;
            _type = [_logic, "type"] call MAINCLASS;

            if(typeName _forcePool == "STRING") then {
                _forcePool = parseNumber _forcePool;
            };

            if(_forcePool == 10) then {
                [_logic, "forcePool", 1000] call MAINCLASS;
                [_logic, "forcePoolType", "DYNAMIC"] call MAINCLASS;
            };

            _allowInfantry = [_logic, "allowInfantryReinforcement"] call MAINCLASS;
            _allowMechanised = [_logic, "allowMechanisedReinforcement"] call MAINCLASS;
            _allowMotorised = [_logic, "allowMotorisedReinforcement"] call MAINCLASS;
            _allowArmour = [_logic, "allowArmourReinforcement"] call MAINCLASS;
            _allowHeli = [_logic, "allowHeliReinforcement"] call MAINCLASS;
            _allowPlane = [_logic, "allowPlaneReinforcement"] call MAINCLASS;

            _enableAirTransport = [_logic, "enableAirTransport"] call MAINCLASS;
            _limitTransportToFaction = [_logic, "limitTransportToFaction"] call MAINCLASS;

            _startForceStrengthIncrement = [_logic, "startForceStrengthInc"] call MAINCLASS;
            _startForceStrengthIncrementFactor = parseNumber([_logic, "startForceStrengthIncFactor"] call MAINCLASS);
            _startForceStrengthDecrement = [_logic, "startForceStrengthDec"] call MAINCLASS;
            _startForceStrengthDecrementFactor = parseNumber([_logic, "startForceStrengthDecFactor"] call MAINCLASS);

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                ["ML - Init"] call ALiVE_fnc_dump;
                ["ML - Type: %1",_type] call ALiVE_fnc_dump;
                ["ML - Force pool type: %1 limit: %2",[_logic, "forcePool"] call MAINCLASS,[_logic, "forcePoolType"] call MAINCLASS] call ALiVE_fnc_dump;
                ["ML - Allow infantry requests: %1",_allowInfantry] call ALiVE_fnc_dump;
                ["ML - Allow mechanised requests: %1",_allowMechanised] call ALiVE_fnc_dump;
                ["ML - Allow motorised requests: %1",_allowMotorised] call ALiVE_fnc_dump;
                ["ML - Allow armour requests: %1",_allowArmour] call ALiVE_fnc_dump;
                ["ML - Allow heli requests: %1",_allowHeli] call ALiVE_fnc_dump;
                ["ML - Allow plane requests: %1",_allowPlane] call ALiVE_fnc_dump;
                ["ML - Enable air transport: %1",_enableAirTransport] call ALiVE_fnc_dump;
                ["ML - Limit air assets to faction only: %1",_limitTransportToFaction] call ALiVE_fnc_dump;
                ["ML - Enable incremental force strength on objective capture: %1",_startForceStrengthIncrement] call ALiVE_fnc_dump;
                ["ML - Incremental force strength factor: %1",_startForceStrengthIncrementFactor] call ALiVE_fnc_dump;
                ["ML - Enable decremental force strength on objective loss: %1",_startForceStrengthDecrement] call ALiVE_fnc_dump;
                ["ML - Decremental force strength factor: %1",_startForceStrengthDecrementFactor] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            // create the global registry
            if(isNil "ALIVE_MLGlobalRegistry") then {
                ALIVE_MLGlobalRegistry = [nil, "create"] call ALIVE_fnc_MLGlobalRegistry;
                [ALIVE_MLGlobalRegistry, "init"] call ALIVE_fnc_MLGlobalRegistry;
                [ALIVE_MLGlobalRegistry, "debug", _debug] call ALIVE_fnc_MLGlobalRegistry;
            };

            // Initialise the global supply network registry.
            // Seed the HQ origin node using the world position of the synced
            // OPCOM module -- this is where the mission designer placed OPCOM,
            // which is the true HQ location. All logistics flows outward from here.
            if (isNil "ALIVE_ML_supplyNetwork") then {
                ALIVE_ML_supplyNetwork = [] call ALIVE_fnc_hashCreate;
            };
            {
                private _syncedObj = _x;
                private _syncedType = _syncedObj getVariable ["moduleType", ""];
                if (_syncedType == "ALIVE_OPCOM") then {
                    private _opcomHandler  = _syncedObj getVariable ["handler", nil];
                    private _opcomFactions = if (!isNil "_opcomHandler") then {
                        [_opcomHandler, "factions"] call ALIVE_fnc_hashGet
                    } else { [] };
                    private _opcomHQPos    = position _syncedObj;
                    // Register HQ node for every faction this OPCOM controls
                    {
                        private _fac = _x;
                        private _nodes = [ALIVE_ML_supplyNetwork, _fac, []] call ALIVE_fnc_hashGet;
                        if (count _nodes == 0) then {
                            _nodes pushBack [_opcomHQPos, [], true];
                            [ALIVE_ML_supplyNetwork, _fac, _nodes] call ALIVE_fnc_hashSet;
                            if (_debug) then {
                                ["ML - Supply network init: OPCOM HQ node registered for faction %1 at %2",
                                    _fac, _opcomHQPos] call ALiVE_fnc_dump;
                            };
                        };
                    } forEach _opcomFactions;
                };
            } forEach (synchronizedObjects _logic);

            TRACE_1("After module init",_logic);

            [_logic,"start"] call MAINCLASS;
        };
    };

    case "start": {
        if (isServer) then {

            private ["_debug","_modules","_module","_worldName","_file","_moduleObject"];

            _debug = [_logic, "debug"] call MAINCLASS;


            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                ["ML - Startup"] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            // check modules are available
            if !(["ALiVE_sys_profile","ALiVE_mil_opcom"] call ALiVE_fnc_isModuleAvailable) exitwith {
                ["Military Logistics reports that Virtual AI module or OPCOM module not placed! Exiting..."] call ALiVE_fnc_DumpR;
            };
            waituntil {!(isnil "ALiVE_ProfileHandler") && {[ALiVE_ProfileSystem,"startupComplete",false] call ALIVE_fnc_hashGet}};

            // if civ cluster data not loaded, load it
            if(isNil "ALIVE_clustersCiv" && isNil "ALIVE_loadedCivClusters") then {
                _worldName = toLower(worldName);
                _file = format["x\alive\addons\civ_placement\clusters\clusters.%1_civ.sqf", _worldName];
                call compile preprocessFileLineNumbers _file;
                ALIVE_loadedCIVClusters = true;
            };
            waituntil {!(isnil "ALIVE_loadedCIVClusters") && {ALIVE_loadedCIVClusters}};

            // if mil cluster data not loaded, load it
            if(isNil "ALIVE_clustersMil" && isNil "ALIVE_loadedMilClusters") then {
                _worldName = toLower(worldName);
                _file = format["x\alive\addons\mil_placement\clusters\clusters.%1_mil.sqf", _worldName];
                call compile preprocessFileLineNumbers _file;
                ALIVE_loadedMilClusters = true;
            };
            waituntil {!(isnil "ALIVE_loadedMilClusters") && {ALIVE_loadedMilClusters}};

            // get all synced modules
            _modules = [];

            for "_i" from 0 to ((count synchronizedObjects _logic)-1) do {
                _moduleObject = (synchronizedObjects _logic) select _i;

                waituntil {_module = _moduleObject getVariable "handler"; !(isnil "_module")};
                _module = _moduleObject getVariable "handler";
                _modules pushback _module;
            };

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["ML - Startup completed"] call ALiVE_fnc_dump;
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            _logic setVariable ["startupComplete", true];

            if(count _modules > 0) then {

                // start listening for logcom events
                [_logic,"listen"] call MAINCLASS;

                // start initial analysis
                [_logic, "initialAnalysis", _modules] call MAINCLASS;
            }else{
                ["ML - Warning no OPCOM modules synced to Military Logistics module, nothing to do.."] call ALiVE_fnc_dumpR;

            };
        };
    };

    case "initialAnalysis": {
        if (isServer) then {

            private ["_debug","_modules","_module","_modulesFactions","_moduleSide","_moduleFactions","_modulesObjectives","_moduleFactionBreakdowns",
            "_faction","_factionBreakdown","_objectives"];

            _modules = _args;

            _debug = [_logic, "debug"] call MAINCLASS;
            _modulesFactions = [];
            _modulesObjectives = [];

            // get objectives and modules settings from syncronised OPCOM instances
            // should only be 1...
            {
                _module = _x;
                _moduleSide = [_module,"side"] call ALiVE_fnc_HashGet;

                // Register side with clients
                MOD(Require) setVariable [format["ALIVE_MIL_LOG_AVAIL_%1", _moduleSide], true, true];

                _moduleFactions = [_module,"factions"] call ALiVE_fnc_HashGet;

                // store side
                [_logic, "side", _moduleSide] call MAINCLASS;

                // get the objectives from the module
                _objectives = [];

                waituntil {
                    sleep 10;
                    _objectives = nil;
                    _objectives = [_module,"objectives"] call ALIVE_fnc_hashGet;
                    (!(isnil "_objectives") && {count _objectives > 0})
                };

                _modulesFactions pushback [_moduleSide,_moduleFactions];
                _modulesObjectives pushback _objectives;

                // set the faction force pools
                {
                    [ALIVE_globalForcePool,_x,0] call ALIVE_fnc_hashSet;
                } forEach _moduleFactions;

            } forEach _modules;

            [_logic, "factions", _modulesFactions] call MAINCLASS;
            [_logic, "objectives", _modulesObjectives] call MAINCLASS;

            // register the module
            [ALIVE_MLGlobalRegistry,"register",_logic] call ALIVE_fnc_MLGlobalRegistry;

            // set as initial analysis complete
            _logic setVariable ["initialAnalysisComplete", true];

            // trigger main processing loop
            [_logic, "monitor"] call MAINCLASS;
        };
    };

    case "listen": {
        private["_listenerID"];

        _listenerID = [ALIVE_eventLog, "addListener",[_logic, ["LOGCOM_REQUEST","LOGCOM_RESUPPLY","LOGCOM_STATUS_REQUEST","LOGCOM_CANCEL_REQUEST","OPCOM_CAPTURE"]]] call ALIVE_fnc_eventLog;
        _logic setVariable ["listenerID", _listenerID];
    };

    case "handleEvent": {
        private["_event","_type","_eventData"];

        if(typeName _args == "ARRAY") then {

            _event = _args;
            _type = [_event, "type"] call ALIVE_fnc_hashGet;

            [_logic, _type, _event] call MAINCLASS;

        };
    };
    
    case "OPCOM_CAPTURE": {

        private["_debug","_event","_eventData","_eventQueue","_side","_factions","_eventFaction","_eventSide","_factionFound","_data","_id","_startForceStrengthIncrement","_startForceStrengthDecrement","_startForceStrengthIncrementFactor","_startForceStrengthDecrementFactor",
        "_moduleFactions","_eventPlayerID","_eventRequestID","_countToAdd","_countToRemove", "_instanceProfilesCount","_thisInstanceSFS","_thissideTarget","_objectiveID","_objectivePos","_randomWeightedElement"];
        
        if(typeName _args == "ARRAY") then {

		        _event = _args;
		        _debug = [_logic, "debug"] call MAINCLASS;
		        _id = [_event, "id"] call ALIVE_fnc_hashGet;
		        _data = [_event, "data"] call ALIVE_fnc_hashGet;
		        _factions = [_logic, "factions"] call MAINCLASS;
		        _eventFaction = _data select 0;
		        _eventSide = _data select 1;
		        _startForceStrengthIncrement = [_logic, "startForceStrengthInc"] call MAINCLASS;
		        _startForceStrengthDecrement = [_logic, "startForceStrengthDec"] call MAINCLASS;
		        _startForceStrengthIncrementFactor = parseNumber([_logic, "startForceStrengthIncFactor"] call MAINCLASS);
		        _startForceStrengthDecrementFactor = parseNumber([_logic, "startForceStrengthDecFactor"] call MAINCLASS);
		           
		        _data params ["_side","_objective"]; 
		         // DEBUG -------------------------------------------------------------------------------------
             if (_debug) then {
              ["ML - Force Strength 'OPCOM_CAPTURE' -> _side (event): %1, _eventFaction: %2, _faction: %3, _factions: %4", _side, _eventFaction, (_factions select 0 select 0), _factions] call ALiVE_fnc_dump;
		         };
		        // DEBUG -------------------------------------------------------------------------------------
		        // the side that captured && startForceStrengthInc is true...
		        if (_eventFaction == _side && _startForceStrengthIncrement) then {
		        	if (_side == (_factions select 0 select 0)) then {
		        		// DEBUG -------------------------------------------------------------------------------------
                if (_debug) then {
		        	   ["ML - Force Strength 'OPCOM_CAPTURE' (Increment) -> _faction: %1, _side (event): %2, _eventFaction: %3, _objective: %4, _startForceStrengthIncrementFactor: %5", (_factions select 0 select 0), _side, _eventFaction, _objective, _startForceStrengthIncrementFactor] call ALiVE_fnc_dump;
		        	  };
		        	  // DEBUG -------------------------------------------------------------------------------------
		             _objectiveID = [_objective,"id"] call ALiVE_fnc_hashGet;
		             _objectivePos = [_objective,"center"] call ALiVE_fnc_hashGet;
		            {
		            	 _thissideTarget = [_x, "side", ""] call ALIVE_fnc_hashGet;  
		            	if (_thissideTarget == _side) then {   
		            	 _thisInstanceSFS =  [_x,"startForceStrength"] call ALiVE_fnc_HashGet;
		        		// DEBUG -------------------------------------------------------------------------------------
                if (_debug) then {
                 ["ML - Force Strength 'OPCOM_CAPTURE' -> _thisInstanceSFS: %1", _thisInstanceSFS] call ALiVE_fnc_dump;
		        	  };
		        	  // DEBUG -------------------------------------------------------------------------------------
		              };
		            } forEach OPCOM_INSTANCES; 
		            _instanceProfilesCount = 0; 
		            { 
		            	_instanceProfilesCount = _instanceProfilesCount + _x;
		            } forEach _thisInstanceSFS;
		             _countToAdd = ceil((_instanceProfilesCount * _startForceStrengthIncrementFactor)/100);
		            for "_i" from 0 to (_countToAdd -1) do {
		            	_randomWeightedElement = [["Infantry","Motorized","Mechanized","Armored","Artillery","AAA","Air","Sea"], _thisInstanceSFS] call BIS_fnc_selectRandomWeighted;
                  [_side, _randomWeightedElement, 1] call ALIVE_fnc_OPCOMIncrementStartForceStrength;    
		            };
		          };
		        }; 
		        // the side that lost && startForceStrengthDec is true...
		        if (_eventFaction == _side && _startForceStrengthDecrement) then {
		        	if (_side != (_factions select 0 select 0)) then {
		        		// DEBUG -------------------------------------------------------------------------------------
                if (_debug) then {
		        	   ["ML - Force Strength 'OPCOM_CAPTURE' (Decrement) -> _faction: %1, _side (event): %2, _eventFaction: %3, _objective: %4, _startForceStrengthDecrementFactor: %5", (_factions select 0 select 0), _side, _eventFaction, _objective, _startForceStrengthDecrementFactor] call ALiVE_fnc_dump;
		        	  };
		        	  // DEBUG -------------------------------------------------------------------------------------
		             _objectiveID = [_objective,"id"] call ALiVE_fnc_hashGet;
		             _objectivePos = [_objective,"center"] call ALiVE_fnc_hashGet;
		            {
		            	 _thissideTarget = [_x, "side", ""] call ALIVE_fnc_hashGet;  
		            	if (_thissideTarget == (_factions select 0 select 0)) then {   
		            	 _thisInstanceSFS =  [_x,"startForceStrength"] call ALiVE_fnc_HashGet;
		        		// DEBUG -------------------------------------------------------------------------------------
                if (_debug) then {
                 ["ML - Force Strength 'OPCOM_CAPTURE' -> _thisInstanceSFS: %1", _thisInstanceSFS] call ALiVE_fnc_dump;
		        	  };
		        	  // DEBUG -------------------------------------------------------------------------------------
		              };
		            } forEach OPCOM_INSTANCES; 
		            _instanceProfilesCount = 0; 
		            { 
		            	_instanceProfilesCount = _instanceProfilesCount + _x;
		            } forEach _thisInstanceSFS;
		             _countToRemove = ceil((_instanceProfilesCount * _startForceStrengthDecrementFactor)/100);
		            for "_i" from 0 to (_countToRemove -1) do {
		            	_randomWeightedElement = [["Infantry","Motorized","Mechanized","Armored","Artillery","AAA","Air","Sea"], _thisInstanceSFS] call BIS_fnc_selectRandomWeighted;
                  [(_factions select 0 select 0), _randomWeightedElement, 1] call ALIVE_fnc_OPCOMdecrementStartForceStrength;    
		            };
		        	};
		        };
        };
    };

    // =========================================================================
    // LOGCOM_RESUPPLY — Support Asset Resupply Dispatch
    // Dispatches a resupply truck (or heli fallback) to a combat support asset
    // that has triggered ammo/fuel/damage thresholds via the resupply watchdog.
    // =========================================================================
    #define RESUPPLY_MAX_RETRIES 3
    #define RESUPPLY_SERVICE_DELAY 30
    #define RESUPPLY_RTB_ARRIVE_RADIUS 75
    #define RESUPPLY_RTB_SPEED_KPH 45
    #define RESUPPLY_RTB_TIMEOUT_MULTIPLIER 2
    case "LOGCOM_RESUPPLY": {

        if (typeName _args == "ARRAY") then {

            private _event = _args;
            private _eventData = [_event, "data"] call ALIVE_fnc_hashGet;

            // Event data: [position, sideText, type, callsign, source, needs, vehicleRef]
            private _targetPos = _eventData select 0;
            private _eventSide = _eventData select 1;
            private _assetType = _eventData select 2;
            private _callsign = _eventData select 3;
            private _sourceMode = _eventData select 4;  // 0 = Static, 1 = Dynamic
            private _needs = _eventData select 5;       // [needsAmmo, needsFuel, needsRepair]
            private _targetVeh = _eventData select 6;

            // Validate target is still alive.
            if (isNull _targetVeh || {!alive _targetVeh}) exitWith {
                ["LOGCOM_RESUPPLY: Target asset %1 no longer exists, aborting", _callsign] call ALiVE_fnc_dump;
                private _count = missionNamespace getVariable ["ALIVE_resupply_activeCount", 1];
                missionNamespace setVariable ["ALIVE_resupply_activeCount", (_count - 1) max 0, true];
            };

            // Multi-ML routing: every ML module receives every LOGCOM_RESUPPLY event.
            // Only the module matching this event's side should handle it. Silent exit for others
            // (matches upstream LOGCOM_REQUEST routing; no activeCount touch - the owning module
            // will handle the accounting).
            private _moduleSide = [_logic, "side"] call MAINCLASS;
            if (_moduleSide != _eventSide) exitWith {};

            // Determine source position.
            private _sourcePos = getPos _logic;  // Default: Static = LOGCOM module position.

            if (_sourceMode == 1) then {
                // Dynamic: collect every friendly-held defend/reserve objective, sort by distance
                // to the target, roll for a set size of 2 or 3, then pick at random from that set.
                // Two layers of variance (depth of the supply route + pick within it) so the source
                // isn't trivially predictable and it simulates drawing from a route rather than
                // always the single nearest stash.
                private _candidates = [];  // [[dist, pos], ...]
                {
                    private _handler = _x getVariable ["handler", objNull];
                    if (!isNull _handler) then {
                        private _opcomSide = [_handler, "side"] call ALiVE_fnc_HashGet;
                        if (_opcomSide == _eventSide) then {
                            private _objectives = [_handler, "objectives", []] call ALiVE_fnc_HashGet;
                            {
                                private _objState = [_x, "opcom_state", "none"] call ALiVE_fnc_HashGet;
                                if (_objState in ["defend", "reserve"]) then {
                                    private _objPos = [_x, "center"] call ALiVE_fnc_HashGet;
                                    _candidates pushBack [_objPos distance2D _targetPos, _objPos];
                                };
                            } forEach _objectives;
                        };
                    };
                } forEach (missionNamespace getVariable ["OPCOM_instances", []]);

                if (count _candidates > 0) then {
                    _candidates sort true;  // ascending by distance (first element)
                    private _setSize = 2 + floor random 2;  // 2 or 3
                    _setSize = _setSize min (count _candidates);
                    private _topN = _candidates select [0, _setSize];
                    _sourcePos = (selectRandom _topN) select 1;
                };
                // Otherwise _sourcePos stays at the LOGCOM base - no friendly objectives to draw from.
            };

            // --- Force pool check & deduct ---
            // Resupply dispatch consumes from the same ALIVE_globalForcePool used by OPCOM
            // reinforcements. Cost scales with pool size (2%) with a floor of 1 and a cap
            // of 10 so low pools don't get hollowed out by a single resupply and huge pools
            // still feel a meaningful drain. Deducted ONCE here before branching into any
            // dispatch path (truck / heli / timer) so the cost is for the supplies
            // themselves, not tied to the delivery vehicle type.
            private _factions = [_logic, "factions"] call MAINCLASS;
            private _eventFaction = "";
            {
                if ((_x select 0) == _eventSide) exitWith { _eventFaction = (_x select 1) select 0; };
            } forEach _factions;
            if (_eventFaction == "" && {count _factions > 0}) then {
                _eventFaction = (_factions select 0 select 1) select 0;
            };

            private _registryID = [_logic, "registryID"] call MAINCLASS;
            private _forcePool = [ALIVE_globalForcePool, _eventFaction] call ALIVE_fnc_hashGet;
            if (typeName _forcePool == "STRING") then { _forcePool = parseNumber _forcePool; };
            if (typeName _forcePool != "SCALAR") then { _forcePool = 0; };

            private _resupplyCost = 1 max (10 min (floor (_forcePool * 0.02)));

            if (_forcePool < _resupplyCost) exitWith {
                ["LOGCOM_RESUPPLY: Force pool exhausted for %1 (faction=%2 pool=%3 need=%4), deferring",
                    _callsign, _eventFaction, _forcePool, _resupplyCost] call ALiVE_fnc_dump;
                _targetVeh setVariable ["ALIVE_resupply_state", "failed", true];
                _targetVeh setVariable ["ALIVE_resupply_inProgress", false, true];
                _targetVeh setVariable ["ALIVE_resupply_vehicle", objNull, true];
                private _count = missionNamespace getVariable ["ALIVE_resupply_activeCount", 1];
                missionNamespace setVariable ["ALIVE_resupply_activeCount", (_count - 1) max 0, true];
            };

            // Deduct now. If the convoy is destroyed en route the units aren't credited back -
            // supplies are lost, defend your supply lines.
            _forcePool = _forcePool - _resupplyCost;
            [ALIVE_MLGlobalRegistry, "updateGlobalForcePool", [_registryID, _forcePool]] call ALIVE_fnc_MLGlobalRegistry;
            ["LOGCOM_RESUPPLY: Deducted %1 from %2 force pool for %3 (pool now %4)",
                _resupplyCost, _eventFaction, _callsign, _forcePool] call ALiVE_fnc_dump;

            private _distance = _sourcePos distance2D _targetPos;
            private _resupplySpeedMPS = 45 / 3.6;  // 45 km/h in m/s.
            private _timeout = (_distance / _resupplySpeedMPS) * 1.5;

            // Check route for water obstacles (existing ML pattern).
            private _waterBlocked = false;
            private _routeDir = _sourcePos getDir _targetPos;
            private _checkPos = +_sourcePos;
            for "_step" from 0 to _distance step 50 do {
                _checkPos = _checkPos getPos [50, _routeDir];
                if (surfaceIsWater _checkPos) exitWith { _waterBlocked = true };
            };

            // Set ETA variables on target for sitrep display.
            _targetVeh setVariable ["ALIVE_resupply_state", "enroute", true];
            _targetVeh setVariable ["ALIVE_resupply_eta", _timeout, true];
            _targetVeh setVariable ["ALIVE_resupply_startTime", serverTime, true];

            if (!_waterBlocked) then {
                // --- TRUCK DISPATCH ---
                private _truckClass = switch (_eventSide) do {
                    case "EAST": { "O_Truck_03_ammo_F" };
                    case "WEST": { "B_Truck_01_ammo_F" };
                    case "GUER": { "I_Truck_02_ammo_F" };
                    default { "B_Truck_01_ammo_F" };
                };

                // Route through the unified vehicle spawn validator
                // (#850). _sourcePos is an installation marker that's
                // usually clear, but if the source is in a built-up
                // base the truck can spawn clipped into a wall and
                // detonate before driving off. Falls back to the
                // original _sourcePos when the validator finds nothing.
                private _truckSpawnPos = _sourcePos;
                private _spawnResult = [_truckClass, _sourcePos, 50, "auto"] call ALiVE_fnc_findVehicleSpawnPosition;
                if (count _spawnResult >= 2) then {
                    _truckSpawnPos = _spawnResult select 0;
                    // Direction is overwritten below to face _targetPos
                    // - we only need the validated position here.
                };

                private _truck = createVehicle [_truckClass, _truckSpawnPos, [], 10, "NONE"];
                _truck setDir (_truckSpawnPos getDir _targetPos);
                createVehicleCrew _truck;

                // Settle window mirroring the profile / roadblock
                // / civilian-vehicle paths. 15 s of damage immunity
                // covers any residual clipping while the engine
                // resolves the placement.
                _truck allowDamage false;
                [{_this allowDamage true;}, _truck, 15] call CBA_fnc_waitAndExecute;
                private _truckGrp = group (driver _truck);

                // Assign waypoint to target position.
                private _wp = _truckGrp addWaypoint [_targetPos, 50];
                _wp setWaypointType "MOVE";
                _wp setWaypointSpeed "FULL";
                _wp setWaypointBehaviour "SAFE";

                // Store reference on target vehicle for marker display.
                _targetVeh setVariable ["ALIVE_resupply_vehicle", _truck, true];

                ["LOGCOM_RESUPPLY: Truck %1 dispatched from %2 to %3 (%4), ETA %5s",
                    _truckClass, _sourcePos, _callsign, _assetType, round _timeout] call ALiVE_fnc_dump;

                // Spawn delivery monitor. Pass sourcePos so the truck can RTB after servicing.
                [_truck, _targetVeh, _timeout, _callsign, _sourcePos] spawn {
                    params ["_truck", "_targetVeh", "_timeout", "_callsign", "_sourcePos"];

                    private _startTime = serverTime;

                    while {true} do {
                        // Protection: truck destroyed.
                        if (!alive _truck) exitWith {
                            ["LOGCOM_RESUPPLY: Truck destroyed en route to %1", _callsign] call ALiVE_fnc_dump;
                            _targetVeh setVariable ["ALIVE_resupply_state", "failed", true];
                            _targetVeh setVariable ["ALIVE_resupply_inProgress", false, true];
                            _targetVeh setVariable ["ALIVE_resupply_vehicle", objNull, true];
                            _targetVeh setVariable ["ALIVE_resupply_retries",
                                (_targetVeh getVariable ["ALIVE_resupply_retries", 0]) + 1, true];
                            private _count = missionNamespace getVariable ["ALIVE_resupply_activeCount", 1];
                            missionNamespace setVariable ["ALIVE_resupply_activeCount", (_count - 1) max 0, true];
                        };

                        // Protection: target asset destroyed.
                        if (isNull _targetVeh || {!alive _targetVeh}) exitWith {
                            ["LOGCOM_RESUPPLY: Target %1 destroyed, aborting truck", _callsign] call ALiVE_fnc_dump;
                            {deleteVehicle _x} forEach (crew _truck);
                            deleteVehicle _truck;
                            private _count = missionNamespace getVariable ["ALIVE_resupply_activeCount", 1];
                            missionNamespace setVariable ["ALIVE_resupply_activeCount", (_count - 1) max 0, true];
                        };

                        // Protection: timeout expired.
                        if (serverTime - _startTime > _timeout) exitWith {
                            private _retries = _targetVeh getVariable ["ALIVE_resupply_retries", 0];
                            if (_retries < RESUPPLY_MAX_RETRIES) then {
                                ["LOGCOM_RESUPPLY: Truck timed out for %1 (attempt %2/%3), retrying",
                                    _callsign, _retries + 1, RESUPPLY_MAX_RETRIES] call ALiVE_fnc_dump;
                                {deleteVehicle _x} forEach (crew _truck);
                                deleteVehicle _truck;
                                _targetVeh setVariable ["ALIVE_resupply_state", "failed", true];
                                _targetVeh setVariable ["ALIVE_resupply_inProgress", false, true];
                                _targetVeh setVariable ["ALIVE_resupply_vehicle", objNull, true];
                                _targetVeh setVariable ["ALIVE_resupply_retries", _retries + 1, true];
                            } else {
                                ["LOGCOM_RESUPPLY: Max retries reached for %1, force-servicing", _callsign] call ALiVE_fnc_dump;
                                {deleteVehicle _x} forEach (crew _truck);
                                deleteVehicle _truck;
                                [_targetVeh] call ALIVE_fnc_resupplyService;
                                _targetVeh setVariable ["ALIVE_resupply_state", "complete", true];
                                _targetVeh setVariable ["ALIVE_resupply_inProgress", false, true];
                                _targetVeh setVariable ["ALIVE_resupply_vehicle", objNull, true];
                                _targetVeh setVariable ["ALIVE_resupply_retries", 0, true];
                                _targetVeh setVariable ["ALIVE_resupply_lastDispatch", serverTime, true];
                            };
                            private _count = missionNamespace getVariable ["ALIVE_resupply_activeCount", 1];
                            missionNamespace setVariable ["ALIVE_resupply_activeCount", (_count - 1) max 0, true];
                        };

                        // Success: truck within 100m of target.
                        if (_truck distance _targetVeh < 100) exitWith {
                            ["LOGCOM_RESUPPLY: Truck arrived at %1, servicing...", _callsign] call ALiVE_fnc_dump;
                            _targetVeh setVariable ["ALIVE_resupply_state", "servicing", true];

                            // Simulate service time.
                            sleep RESUPPLY_SERVICE_DELAY;

                            [_targetVeh] call ALIVE_fnc_resupplyService;

                            _targetVeh setVariable ["ALIVE_resupply_state", "complete", true];
                            _targetVeh setVariable ["ALIVE_resupply_inProgress", false, true];
                            _targetVeh setVariable ["ALIVE_resupply_vehicle", objNull, true];
                            _targetVeh setVariable ["ALIVE_resupply_lastDispatch", serverTime, true];
                            _targetVeh setVariable ["ALIVE_resupply_retries", 0, true];

                            ["LOGCOM_RESUPPLY: Service complete for %1, truck RTB to %2", _callsign, _sourcePos] call ALiVE_fnc_dump;

                            // Decrement concurrent-dispatch counter now - the delivery leg is done.
                            // RTB is fire-and-forget and shouldn't keep the asset marked busy.
                            private _count = missionNamespace getVariable ["ALIVE_resupply_activeCount", 1];
                            missionNamespace setVariable ["ALIVE_resupply_activeCount", (_count - 1) max 0, true];

                            // --- RTB ---
                            // Clear any existing waypoints and route the truck back to its source.
                            private _truckGrp = group (driver _truck);
                            while {count waypoints _truckGrp > 0} do { deleteWaypoint [_truckGrp, 0] };
                            private _rtbWp = _truckGrp addWaypoint [_sourcePos, 50];
                            _rtbWp setWaypointType "MOVE";
                            _rtbWp setWaypointSpeed "FULL";
                            _rtbWp setWaypointBehaviour "SAFE";
                            _truckGrp setCurrentWaypoint _rtbWp;

                            // Monitor RTB - delete on arrival, or after a distance-scaled timeout
                            // so a stuck / destroyed truck still gets cleaned up.
                            private _rtbDistance = _truck distance _sourcePos;
                            private _rtbTimeout = ((_rtbDistance / (RESUPPLY_RTB_SPEED_KPH / 3.6)) * RESUPPLY_RTB_TIMEOUT_MULTIPLIER) max 60;

                            [_truck, _sourcePos, _callsign, _rtbTimeout] spawn {
                                params ["_truck", "_sourcePos", "_callsign", "_rtbTimeout"];
                                private _rtbStart = serverTime;
                                while {
                                    !isNull _truck
                                    && {alive _truck}
                                    && {_truck distance _sourcePos > RESUPPLY_RTB_ARRIVE_RADIUS}
                                    && {serverTime - _rtbStart < _rtbTimeout}
                                } do {
                                    sleep 5;
                                };
                                if (!isNull _truck) then {
                                    if (alive _truck && {_truck distance _sourcePos <= RESUPPLY_RTB_ARRIVE_RADIUS}) then {
                                        ["LOGCOM_RESUPPLY: Truck RTB complete for %1, deleting", _callsign] call ALiVE_fnc_dump;
                                    } else {
                                        ["LOGCOM_RESUPPLY: Truck RTB timed out or destroyed for %1, cleaning up", _callsign] call ALiVE_fnc_dump;
                                    };
                                    {deleteVehicle _x} forEach (crew _truck);
                                    deleteVehicle _truck;
                                };
                            };
                        };

                        // Update truck waypoint if target has moved (aircraft on ground).
                        private _wp = waypoints (group (driver _truck));
                        if (count _wp > 0) then {
                            [(group (driver _truck)), 1] setWaypointPosition [getPos _targetVeh, 50];
                        };

                        sleep 10;
                    };
                };

            } else {
                // --- WATER BLOCKED: HELI SLINGLOAD DISPATCH ---
                // Spawn a heli with a slingloaded supply crate, fly to the asset,
                // descend and release crate, service on arrival, cleanup.
                // Falls back to timer if no suitable heli class exists.

                // Select heli and crate classes by side.
                private _heliClass = "";
                private _crateClass = "";
                switch (_eventSide) do {
                    case "WEST": {
                        _heliClass = "B_Heli_Transport_03_F";
                        _crateClass = "B_Slingload_01_Ammo_F";
                    };
                    case "EAST": {
                        _heliClass = "O_Heli_Transport_04_F";
                        _crateClass = "O_Slingload_01_Ammo_F";
                    };
                    case "GUER": {
                        _heliClass = "I_Heli_Transport_02_F";
                        _crateClass = "I_Slingload_01_Ammo_F";
                    };
                    default {
                        _heliClass = "B_Heli_Transport_03_F";
                        _crateClass = "B_Slingload_01_Ammo_F";
                    };
                };

                // Validate heli class exists in config.
                if (!isClass (configFile >> "CfgVehicles" >> _heliClass)) then {
                    _heliClass = "";
                };

                if (_heliClass == "") then {
                    // --- TIMER FALLBACK: no suitable heli available ---
                    ["LOGCOM_RESUPPLY: No heli class available for %1, using timer fallback (ETA %2s)",
                        _callsign, round _timeout] call ALiVE_fnc_dump;

                    _targetVeh setVariable ["ALIVE_resupply_vehicle", objNull, true];

                    [_targetVeh, _timeout, _callsign] spawn {
                        params ["_targetVeh", "_timeout", "_callsign"];

                        sleep _timeout;

                        if (!isNull _targetVeh && {alive _targetVeh}) then {
                            [_targetVeh] call ALIVE_fnc_resupplyService;
                            _targetVeh setVariable ["ALIVE_resupply_state", "complete", true];
                            ["LOGCOM_RESUPPLY: Timer fallback service complete for %1", _callsign] call ALiVE_fnc_dump;
                        };

                        _targetVeh setVariable ["ALIVE_resupply_inProgress", false, true];
                        _targetVeh setVariable ["ALIVE_resupply_lastDispatch", serverTime, true];
                        _targetVeh setVariable ["ALIVE_resupply_retries", 0, true];
                        private _count = missionNamespace getVariable ["ALIVE_resupply_activeCount", 1];
                        missionNamespace setVariable ["ALIVE_resupply_activeCount", (_count - 1) max 0, true];
                    };
                } else {
                    // --- HELI SLINGLOAD DISPATCH ---

                    // Spawn heli at altitude above source position.
                    private _spawnPos = +_sourcePos;
                    _spawnPos set [2, PARADROP_HEIGHT];
                    private _heli = createVehicle [_heliClass, _spawnPos, [], 0, "FLY"];
                    _heli setDir (_sourcePos getDir _targetPos);
                    _heli setPosASL [_spawnPos select 0, _spawnPos select 1, PARADROP_HEIGHT];
                    _heli setVelocity [0, 0, 0];
                    _heli flyInHeight PARADROP_HEIGHT;
                    createVehicleCrew _heli;
                    private _heliGrp = group (driver _heli);

                    // Spawn supply crate and force-attach as slingload.
                    private _crate = createVehicle [_crateClass, _sourcePos, [], 0, "CAN_COLLIDE"];
                    _heli setSlingLoad _crate;

                    // Store reference on target for marker display.
                    _targetVeh setVariable ["ALIVE_resupply_vehicle", _heli, true];

                    // Recalculate timeout for air travel (faster than truck).
                    private _airSpeedMPS = 65 / 3.6;  // ~65 km/h slingloaded.
                    private _heliTimeout = ((_distance / _airSpeedMPS) * 1.5) max SLINGLOAD_DROP_TIMEOUT;

                    _targetVeh setVariable ["ALIVE_resupply_eta", _heliTimeout, true];
                    _targetVeh setVariable ["ALIVE_resupply_startTime", serverTime, true];

                    ["LOGCOM_RESUPPLY: Heli %1 dispatched with crate %2 to %3 (%4), ETA %5s",
                        _heliClass, _crateClass, _callsign, _assetType, round _heliTimeout] call ALiVE_fnc_dump;

                    // Spawn the slingload delivery monitor.
                    [_heli, _crate, _targetVeh, _heliTimeout, _callsign, _targetPos, _sourcePos, _logic] spawn {
                        params ["_heli", "_crate", "_targetVeh", "_timeout", "_callsign",
                                "_targetPos", "_sourcePos", "_logic"];

                        private _startTime = serverTime;
                        private _phase = 0;  // 0=TRANSIT, 1=DESCENT, 2=RELEASE, 3=SERVICE
                        private _dropPad = objNull;
                        private _lastLandAtTime = 0;
                        private _dropped = false;

                        // --- Helper: cleanup and exit ---
                        private _fnc_cleanup = {
                            params ["_heli", "_crate", "_dropPad", "_targetVeh", "_failed"];

                            if (!isNull _dropPad) then { deleteVehicle _dropPad };
                            if (!isNull _crate && {alive _crate}) then { deleteVehicle _crate };

                            if (_failed) then {
                                _targetVeh setVariable ["ALIVE_resupply_state", "failed", true];
                                _targetVeh setVariable ["ALIVE_resupply_inProgress", false, true];
                                _targetVeh setVariable ["ALIVE_resupply_vehicle", objNull, true];
                                _targetVeh setVariable ["ALIVE_resupply_retries",
                                    (_targetVeh getVariable ["ALIVE_resupply_retries", 0]) + 1, true];
                            };

                            // Delete heli + crew.
                            if (!isNull _heli) then {
                                [{
                                    params ["_h"];
                                    if (!isNull _h && {alive _h}) then {
                                        {deleteVehicle _x} forEach (crew _h);
                                        deleteVehicle _h;
                                    };
                                }, [_heli], 10] call CBA_fnc_waitAndExecute;
                            };

                            private _count = missionNamespace getVariable ["ALIVE_resupply_activeCount", 1];
                            missionNamespace setVariable ["ALIVE_resupply_activeCount", (_count - 1) max 0, true];
                        };

                        // --- Main monitor loop ---
                        while {!_dropped} do {

                            // Global guards (all phases).
                            if (!alive _heli || {!canFire _heli}) exitWith {
                                ["LOGCOM_RESUPPLY HELI: Heli destroyed/disabled en route to %1", _callsign] call ALiVE_fnc_dump;
                                [_heli, _crate, _dropPad, _targetVeh, true] call _fnc_cleanup;
                            };

                            if (isNull _targetVeh || {!alive _targetVeh}) exitWith {
                                ["LOGCOM_RESUPPLY HELI: Target %1 destroyed, aborting", _callsign] call ALiVE_fnc_dump;
                                [_heli, _crate, _dropPad, _targetVeh, false] call _fnc_cleanup;
                            };

                            if (serverTime - _startTime > _timeout) exitWith {
                                ["LOGCOM_RESUPPLY HELI: Timeout for %1, force-releasing", _callsign] call ALiVE_fnc_dump;

                                // Force release with parachute if at altitude.
                                private _slungObj = getSlingLoad _heli;
                                if (!isNull _slungObj) then {
                                    private _slungAGL = (getPosATL _slungObj) select 2;
                                    if (_slungAGL > 5) then {
                                        private _para = createVehicle ["B_Parachute_02_F", getPosATL _slungObj, [], 0, "FLY"];
                                        _para setPosASL (getPosASL _slungObj);
                                        _para setVelocity (velocity _heli);
                                        _slungObj attachTo [_para, [0,0,0]];
                                        [_para, _slungObj] spawn {
                                            private _p = _this select 0; private _v = _this select 1;
                                            waitUntil { sleep 1; (getPosATL _v select 2) < 3 || !alive _p };
                                            detach _v; deleteVehicle _p;
                                        };
                                    };
                                    _heli setSlingLoad objNull;
                                };

                                // Force service regardless.
                                private _retries = _targetVeh getVariable ["ALIVE_resupply_retries", 0];
                                if (_retries < 3) then {
                                    [_heli, _crate, _dropPad, _targetVeh, true] call _fnc_cleanup;
                                } else {
                                    [_targetVeh] call ALIVE_fnc_resupplyService;
                                    _targetVeh setVariable ["ALIVE_resupply_state", "complete", true];
                                    _targetVeh setVariable ["ALIVE_resupply_inProgress", false, true];
                                    _targetVeh setVariable ["ALIVE_resupply_vehicle", objNull, true];
                                    _targetVeh setVariable ["ALIVE_resupply_retries", 0, true];
                                    _targetVeh setVariable ["ALIVE_resupply_lastDispatch", serverTime, true];
                                    [_heli, _crate, _dropPad, _targetVeh, false] call _fnc_cleanup;
                                };
                            };

                            // Crate lost mid-flight.
                            if (isNull (getSlingLoad _heli) && {_phase < 2}) exitWith {
                                ["LOGCOM_RESUPPLY HELI: Crate detached mid-flight for %1", _callsign] call ALiVE_fnc_dump;
                                [_heli, _crate, _dropPad, _targetVeh, true] call _fnc_cleanup;
                            };

                            // --- Phase 0: TRANSIT ---
                            if (_phase == 0) then {
                                // Clear native waypoints every tick to prevent profile simulator override.
                                while {count waypoints _heliGrp > 1} do {
                                    deleteWaypoint [_heliGrp, 1];
                                };

                                _heli flyInHeight PARADROP_HEIGHT;
                                _heli move _targetPos;

                                // Transition to DESCENT when within 800m.
                                if (_heli distance2D _targetVeh < 800) then {
                                    _phase = 1;

                                    // Find LZ near target using battle-tested search.
                                    private _dropPos = [_logic, "findHelicopterLandingPos", [
                                        getPos _targetVeh, 50, 300
                                    ]] call ALIVE_fnc_ML;

                                    _dropPad = createVehicle ["Land_HelipadEmpty_F", _dropPos, [], 0, "CAN_COLLIDE"];
                                    _heli landAt _dropPad;
                                    _heli flyInHeight 30;
                                    _lastLandAtTime = serverTime;

                                    ["LOGCOM_RESUPPLY HELI: Phase DESCENT for %1, LZ at %2", _callsign, _dropPos] call ALiVE_fnc_dump;
                                };
                            };

                            // --- Phase 1: DESCENT ---
                            if (_phase == 1) then {
                                // Clear waypoints every tick.
                                while {count waypoints _heliGrp > 1} do {
                                    deleteWaypoint [_heliGrp, 1];
                                };

                                // Re-issue landAt every 30s if heli stalls (single authority).
                                if (serverTime - _lastLandAtTime > 30 && {!isNull _dropPad}) then {
                                    _heli landAt _dropPad;
                                    _lastLandAtTime = serverTime;
                                };

                                // Monitor slung vehicle AGL.
                                private _slungObj = getSlingLoad _heli;
                                if (!isNull _slungObj) then {
                                    private _slungAGL = (getPosATL _slungObj) select 2;

                                    if (_slungAGL <= SLINGLOAD_DROP_HEIGHT) then {
                                        _phase = 2;
                                        ["LOGCOM_RESUPPLY HELI: Phase RELEASE for %1, AGL=%2m", _callsign, _slungAGL] call ALiVE_fnc_dump;
                                    };
                                };
                            };

                            // --- Phase 2: RELEASE ---
                            if (_phase == 2) then {
                                private _slungObj = getSlingLoad _heli;
                                if (!isNull _slungObj) then {
                                    private _relAGL = (getPosATL _slungObj) select 2;

                                    // Parachute if still above safe height.
                                    if (_relAGL > 5) then {
                                        private _para = createVehicle ["B_Parachute_02_F", getPosATL _slungObj, [], 0, "FLY"];
                                        _para setPosASL (getPosASL _slungObj);
                                        _para setVelocity (velocity _heli);
                                        _slungObj attachTo [_para, [0,0,0]];
                                        [_para, _slungObj] spawn {
                                            private _p = _this select 0; private _v = _this select 1;
                                            waitUntil { sleep 1; (getPosATL _v select 2) < 3 || !alive _p };
                                            detach _v; deleteVehicle _p;
                                        };
                                        ["LOGCOM_RESUPPLY HELI: Parachute attached at AGL %1m for %2", _relAGL, _callsign] call ALiVE_fnc_dump;
                                    };

                                    _heli setSlingLoad objNull;
                                };

                                if (!isNull _dropPad) then { deleteVehicle _dropPad; _dropPad = objNull; };

                                // Wait for crate to settle.
                                sleep 3;

                                _phase = 3;
                                _dropped = true;
                                ["LOGCOM_RESUPPLY HELI: Sling released for %1", _callsign] call ALiVE_fnc_dump;
                            };

                            sleep 2;
                        };

                        // --- Phase 3: SERVICE ---
                        if (_phase == 3 && {alive _targetVeh}) then {
                            _targetVeh setVariable ["ALIVE_resupply_state", "servicing", true];
                            sleep 30;  // Simulate strikedown period.

                            [_targetVeh] call ALIVE_fnc_resupplyService;

                            _targetVeh setVariable ["ALIVE_resupply_state", "complete", true];
                            _targetVeh setVariable ["ALIVE_resupply_inProgress", false, true];
                            _targetVeh setVariable ["ALIVE_resupply_vehicle", objNull, true];
                            _targetVeh setVariable ["ALIVE_resupply_lastDispatch", serverTime, true];
                            _targetVeh setVariable ["ALIVE_resupply_retries", 0, true];

                            // Delete crate.
                            if (!isNull _crate && {alive _crate}) then { deleteVehicle _crate };

                            ["LOGCOM_RESUPPLY HELI: Service complete for %1, heli RTB", _callsign] call ALiVE_fnc_dump;

                            // Heli RTB and cleanup.
                            _heli flyInHeight PARADROP_HEIGHT;
                            _heli move _sourcePos;
                            [{
                                params ["_h"];
                                if (!isNull _h && {alive _h}) then {
                                    {deleteVehicle _x} forEach (crew _h);
                                    deleteVehicle _h;
                                };
                            }, [_heli], 120] call CBA_fnc_waitAndExecute;

                            private _count = missionNamespace getVariable ["ALIVE_resupply_activeCount", 1];
                            missionNamespace setVariable ["ALIVE_resupply_activeCount", (_count - 1) max 0, true];
                        };
                    };
                };
            };
        };
    };

    case "LOGCOM_STATUS_REQUEST": {

        private["_debug","_event","_eventData","_eventQueue","_side","_factions","_eventFaction","_eventSide","_factionFound",
        "_moduleFactions","_eventPlayerID","_eventRequestID"];

        if(typeName _args == "ARRAY") then {

            _event = _args;
            _eventData = [_event, "data"] call ALIVE_fnc_hashGet;

            _side = [_logic, "side"] call MAINCLASS;
            _factions = [_logic, "factions"] call MAINCLASS;

            _eventFaction = _eventData select 0;
            _eventSide = _eventData select 1;
            _eventRequestID = _eventData select 2;
            _eventPlayerID = _eventData select 3;

            // check if the faction in the event is handled
            // by this module
            _factionFound = false;

            {
                _moduleFactions = _x select 1;
                if(_eventFaction in _moduleFactions) then {
                    _factionFound = true;
                };
            } forEach _factions;

            // faction not handled by this mil logistics module
            if!(_factionFound) then {

                private ["_sideOPCOMModules","_factionOPCOMModules","_checkModule","_moduleType","_handler","_OPCOMSide","_OPCOMFactions","_OPCOMHasLogistics","_mod"];

                _sideOPCOMModules = [];
                _factionOPCOMModules = [];

                // loop through OPCOM modules with mil logistics synced and find any matching the events side and faction
                {

                    _checkModule = _x;
                    _moduleType = _x getVariable "moduleType";

                    if!(isNil "_moduleType") then {

                        if(_moduleType == "ALIVE_OPCOM") then {

                            _handler = _checkModule getVariable "handler";
                            _OPCOMSide = [_handler,"side"] call ALIVE_fnc_hashGet;
                            _OPCOMFactions = [_handler,"factions"] call ALIVE_fnc_hashGet;
                            _OPCOMHasLogistics = false;

                            for "_i" from 0 to ((count synchronizedObjects _checkModule)-1) do {

                                _mod = (synchronizedObjects _checkModule) select _i;

                                if ((typeof _mod) == "ALiVE_mil_logistics") then {
                                    _OPCOMHasLogistics = true;
                                };
                            };

                            if(_OPCOMHasLogistics) then {

                                if(_OPCOMSide == _eventSide) then {
                                    _sideOPCOMModules pushback _checkModule;
                                };

                                {
                                    if(_x == _eventFaction) then {
                                        _factionOPCOMModules pushback _checkModule;
                                    };

                                } forEach _OPCOMFactions;

                            };
                        };
                    };
                } forEach (entities "Module_F");

                // if no mil logistics handles this faction, and there is more than one mil
                // logistics for this side return an error
                if(((count _factionOPCOMModules == 0) && (count _sideOPCOMModules > 1)) || ((count _factionOPCOMModules == 0) && (count _sideOPCOMModules == 0))) then {
                    _factionFound = false;
                };

                // if no mil logistics handles this faction, and there is one mil
                // logistics for this side and this module handles that side
                if((count _factionOPCOMModules == 0) && (count _sideOPCOMModules == 1) && (_side == _eventSide)) then {
                    _factionFound = true;
                };

            };

            if!(_factionFound) exitWith {};

            if(_factionFound) then {

                private ["_eventQueue","_response","_responseItem","_playerRequested","_eventData","_logEvent","_playerID",
                "_eventState","_eventType","_eventForceMakeup","_requestID","_transportProfiles","_position","_playerRequestProfileID","_profile"];

                // get the event data for this player

                _eventQueue = [_logic, "eventQueue"] call MAINCLASS;

                _response = [];

                if((count (_eventQueue select 2)) > 0) then {

                    {
                        _playerRequested = [_x, "playerRequested"] call ALIVE_fnc_hashGet;

                        if(_playerRequested) then {
                            _eventData = [_x, "data"] call ALIVE_fnc_hashGet;
                            _playerID = _eventData select 5;
                            _eventType = _eventData select 4;
                            _eventForceMakeup = _eventData select 3;

                            if(_eventPlayerID == _playerID) then {

                                _responseItem = [];

                                _requestID = _eventForceMakeup select 0;
                                _eventState = [_x, "state"] call ALIVE_fnc_hashGet;
                                _transportProfiles = [_x, "transportProfiles"] call ALIVE_fnc_hashGet;

                                _positions = [];

                                if(count _transportProfiles > 0) then {

                                    {
                                        _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;

                                        if!(isNil "_profile") then {
                                            _position = _profile select 2 select 2;
                                            _positions pushBack _position;
                                        };

                                    } forEach _transportProfiles;

                                };

                                _responseItem pushBack _eventType;
                                _responseItem pushBack _requestID;
                                _responseItem pushBack _eventState;
                                _responseItem pushBack _positions;

                                _response pushBack _responseItem;
                            };
                        };

                    } forEach (_eventQueue select 2);

                };

                // respond to player request
                _logEvent = ['LOGCOM_RESPONSE', [_eventRequestID,_eventPlayerID,_response],"Logistics","STATUS"] call ALIVE_fnc_event;
                [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

            };
        };
    };

    case "LOGCOM_CANCEL_REQUEST": {

        private["_debug","_event","_eventData","_eventQueue","_side","_factions","_eventFaction","_eventSide","_factionFound",
        "_moduleFactions","_eventPlayerID","_eventRequestID","_eventCancelRequestID"];

        if(typeName _args == "ARRAY") then {

            _event = _args;
            _eventData = [_event, "data"] call ALIVE_fnc_hashGet;

            _side = [_logic, "side"] call MAINCLASS;
            _factions = [_logic, "factions"] call MAINCLASS;

            _eventFaction = _eventData select 0;
            _eventSide = _eventData select 1;
            _eventRequestID = _eventData select 2;
            _eventPlayerID = _eventData select 3;
            _eventCancelRequestID = _eventData select 4;

            // check if the faction in the event is handled
            // by this module
            _factionFound = false;

            {
                _moduleFactions = _x select 1;
                if(_eventFaction in _moduleFactions) then {
                    _factionFound = true;
                };
            } forEach _factions;

            // faction not handled by this mil logistics module
            if!(_factionFound) then {

                private ["_sideOPCOMModules","_factionOPCOMModules","_checkModule","_moduleType","_handler","_OPCOMSide","_OPCOMFactions","_OPCOMHasLogistics","_mod"];

                _sideOPCOMModules = [];
                _factionOPCOMModules = [];

                // loop through OPCOM modules with mil logistics synced and find any matching the events side and faction
                {

                    _checkModule = _x;
                    _moduleType = _x getVariable "moduleType";

                    if!(isNil "_moduleType") then {

                        if(_moduleType == "ALIVE_OPCOM") then {

                            _handler = _checkModule getVariable "handler";
                            _OPCOMSide = [_handler,"side"] call ALIVE_fnc_hashGet;
                            _OPCOMFactions = [_handler,"factions"] call ALIVE_fnc_hashGet;
                            _OPCOMHasLogistics = false;

                            for "_i" from 0 to ((count synchronizedObjects _checkModule)-1) do {

                                _mod = (synchronizedObjects _checkModule) select _i;

                                if ((typeof _mod) == "ALiVE_mil_logistics") then {
                                    _OPCOMHasLogistics = true;
                                };
                            };

                            if(_OPCOMHasLogistics) then {

                                if(_OPCOMSide == _eventSide) then {
                                    _sideOPCOMModules pushback _checkModule;
                                };

                                {
                                    if(_x == _eventFaction) then {
                                        _factionOPCOMModules pushback _checkModule;
                                    };

                                } forEach _OPCOMFactions;

                            };
                        };
                    };
                } forEach (entities "Module_F");

                // if no mil logistics handles this faction, and there is more than one mil
                // logistics for this side return an error
                if(((count _factionOPCOMModules == 0) && (count _sideOPCOMModules > 1)) || ((count _factionOPCOMModules == 0) && (count _sideOPCOMModules == 0))) then {
                    _factionFound = false;
                };

                // if no mil logistics handles this faction, and there is one mil
                // logistics for this side and this module handles that side
                if((count _factionOPCOMModules == 0) && (count _sideOPCOMModules == 1) && (_side == _eventSide)) then {
                    _factionFound = true;
                };

            };

            if!(_factionFound) exitWith {};

            if(_factionFound) then {

                private ["_eventQueue","_response","_responseItem","_playerRequested","_eventID","_eventData","_logEvent","_playerID",
                "_eventState","_eventType","_eventForceMakeup","_responseItem","_eventCargoProfiles","_infantryProfiles","_armourProfiles",
                "_mechanisedProfiles","_motorisedProfiles","_planeProfiles","_heliProfiles","_eventAssets","_allRequestedProfiles","_anyActive",
                "_transportProfiles","_transportVehiclesProfiles","_requestID","_position","_playerRequestProfileID","_profile","_active","_profileType"];

                // get the event data for this player

                _eventQueue = [_logic, "eventQueue"] call MAINCLASS;

                _response = [];

                if((count (_eventQueue select 2)) > 0) then {

                    {
                        _playerRequested = [_x, "playerRequested"] call ALIVE_fnc_hashGet;

                        if(_playerRequested) then {
                            _eventID = [_x, "id"] call ALIVE_fnc_hashGet;
                            _eventData = [_x, "data"] call ALIVE_fnc_hashGet;
                            _playerID = _eventData select 5;
                            _eventType = _eventData select 4;
                            _eventForceMakeup = _eventData select 3;

                            if(_eventPlayerID == _playerID) then {

                                _responseItem = [];

                                _requestID = _eventForceMakeup select 0;

                                if(_requestID == _eventCancelRequestID) then {

                                    //_x call ALIVE_fnc_inspectHash;

                                    _eventCargoProfiles = [_x, "cargoProfiles"] call ALIVE_fnc_hashGet;

                                    _transportProfiles = [_x, "transportProfiles"] call ALIVE_fnc_hashGet;
                                    _transportVehiclesProfiles = [_x, "transportVehiclesProfiles"] call ALIVE_fnc_hashGet;

                                    _infantryProfiles = [_eventCargoProfiles, 'infantry'] call ALIVE_fnc_hashGet;
                                    _armourProfiles = [_eventCargoProfiles, 'armour'] call ALIVE_fnc_hashGet;
                                    _mechanisedProfiles = [_eventCargoProfiles, 'mechanised'] call ALIVE_fnc_hashGet;
                                    _motorisedProfiles = [_eventCargoProfiles, 'motorised'] call ALIVE_fnc_hashGet;
                                    _planeProfiles = [_eventCargoProfiles, 'plane'] call ALIVE_fnc_hashGet;
                                    _heliProfiles = [_eventCargoProfiles, 'heli'] call ALIVE_fnc_hashGet;

                                    _allRequestedProfiles = [];
                                    _anyActive = false;

                                    {
                                        _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                        if!(isNil "_profile") then {
                                            _active = _profile select 2 select 1;
                                            if(_active) then {
                                                _anyActive = true;
                                            };
                                            _allRequestedProfiles pushBack _profile;
                                        };

                                    } forEach _transportProfiles;

                                    {
                                        _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                        if!(isNil "_profile") then {
                                            _active = _profile select 2 select 1;
                                            if(_active) then {
                                                _anyActive = true;
                                            };
                                            _allRequestedProfiles pushBack _profile;
                                        };

                                    } forEach _transportVehiclesProfiles;

                                    {
                                        _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                                        if!(isNil "_profile") then {
                                            _active = _profile select 2 select 1;
                                            if(_active) then {
                                                _anyActive = true;
                                            };
                                            _allRequestedProfiles pushBack _profile;
                                        };

                                    } forEach _infantryProfiles;

                                    {
                                        {
                                            _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                            if!(isNil "_profile") then {
                                                _active = _profile select 2 select 1;
                                                if(_active) then {
                                                    _anyActive = true;
                                                };
                                                _allRequestedProfiles pushBack _profile;
                                            };
                                        } forEach _x;

                                    } forEach _armourProfiles;

                                    {
                                        {
                                            _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                            if!(isNil "_profile") then {
                                                _active = _profile select 2 select 1;
                                                if(_active) then {
                                                    _anyActive = true;
                                                };
                                                _allRequestedProfiles pushBack _profile;
                                            };
                                        } forEach _x;

                                    } forEach _mechanisedProfiles;

                                    {
                                        {
                                            _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                            if!(isNil "_profile") then {
                                                _active = _profile select 2 select 1;
                                                if(_active) then {
                                                    _anyActive = true;
                                                };
                                                _allRequestedProfiles pushBack _profile;
                                            };
                                        } forEach _x;

                                    } forEach _motorisedProfiles;

                                    {
                                        {
                                            _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                            if!(isNil "_profile") then {
                                                _active = _profile select 2 select 1;
                                                if(_active) then {
                                                    _anyActive = true;
                                                };
                                                _allRequestedProfiles pushBack _profile;
                                            };
                                        } forEach _x;

                                    } forEach _planeProfiles;

                                    {
                                        {
                                            _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                            if!(isNil "_profile") then {
                                                _active = _profile select 2 select 1;
                                                if(_active) then {
                                                    _anyActive = true;
                                                };
                                                _allRequestedProfiles pushBack _profile;
                                            };
                                        } forEach _x;

                                    } forEach _heliProfiles;

                                    if(_anyActive) then {

                                        // respond to player request
                                        _logEvent = ['LOGCOM_RESPONSE', [_eventRequestID,_eventPlayerID,_response],"Logistics","CANCEL_FAILED"] call ALIVE_fnc_event;
                                        [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                                    }else{

                                        // delete all profiles

                                        {
                                            _profileType = _x select 2 select 5;
                                            if(_profileType == 'entity') then {
                                                [_x, "destroy"] call ALIVE_fnc_profileEntity;
                                            }else{
                                                [_x, "destroy"] call ALIVE_fnc_profileVehicle;
                                            };

                                        } forEach _allRequestedProfiles;

                                        _eventAssets = [_x, "eventAssets"] call ALIVE_fnc_hashGet;

                                        {
                                            deleteVehicle _x;
                                        } forEach _eventAssets;

                                        // set state to event complete
                                        [_x, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                                        [_eventQueue, _eventID, _x] call ALIVE_fnc_hashSet;

                                        // respond to player request
                                        _logEvent = ['LOGCOM_RESPONSE', [_eventRequestID,_eventPlayerID,_response],"Logistics","CANCEL_OK"] call ALIVE_fnc_event;
                                        [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                                    };
                                };
                            };
                        };

                    } forEach (_eventQueue select 2);

                };
            };
        };
    };

    case "LOGCOM_REQUEST": {

        private["_debug","_event","_eventQueue","_side","_factions","_eventFaction","_eventSide","_factionFound","_moduleFactions","_forcePool","_type","_eventID",
        "_eventData","_eventType","_eventForceMakeup","_eventForceInfantry","_eventForceMotorised","_eventForceMechanised","_eventForceArmour",
        "_eventForcePlane","_eventForceHeli","_forceMakeupTotal","_allowInfantry","_allowMechanised","_allowMotorised",
        "_allowArmour","_allowHeli","_allowPlane","_playerID","_requestID","_logEvent","_initComplete"];

        if(typeName _args == "ARRAY") then {

            _debug = [_logic, "debug"] call MAINCLASS;
            _event = _args;
            _eventData = [_event, "data"] call ALIVE_fnc_hashGet;
            _eventType = _eventData select 4;

            _initComplete = true;

            if(_eventType == "PR_STANDARD" || _eventType == "PR_AIRDROP" || _eventType == "PR_HELI_INSERT") then {
                _initComplete = _logic getVariable "initialAnalysisComplete";
                if!(_initComplete) then {
                    _eventForceMakeup = _eventData select 3;
                    _playerID = _eventData select 5;
                    _requestID = _eventForceMakeup select 0;
                    // respond to player request
                    _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","DENIED_WAITING_INIT"] call ALIVE_fnc_event;
                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                };
            };

            if!(_initComplete) exitWith {};

            _side = [_logic, "side"] call MAINCLASS;
            _factions = [_logic, "factions"] call MAINCLASS;

            _eventFaction = _eventData select 1;
            _eventSide = _eventData select 2;

            // check if the faction in the event is handled
            // by this module
            _factionFound = false;

            {
                _moduleFactions = _x select 1;
                if(_eventFaction in _moduleFactions) then {
                    _factionFound = true;
                };
            } forEach _factions;

            // check if any other mil logistics modules can handle this event

            if(_eventType == "PR_STANDARD" || _eventType == "PR_AIRDROP" || _eventType == "PR_HELI_INSERT") then {

                // faction not handled by this mil logistics module
                if!(_factionFound) then {

                    private ["_sideOPCOMModules","_factionOPCOMModules","_checkModule","_moduleType","_handler","_OPCOMSide","_OPCOMFactions","_OPCOMHasLogistics","_mod"];

                    _sideOPCOMModules = [];
                    _factionOPCOMModules = [];

                    // loop through OPCOM modules with mil logistics synced and find any matching the events side and faction
                    {

                        _checkModule = _x;
                        _moduleType = _x getVariable "moduleType";

                        if!(isNil "_moduleType") then {

                            if(_moduleType == "ALIVE_OPCOM") then {

                                _handler = _checkModule getVariable "handler";
                                _OPCOMSide = [_handler,"side"] call ALIVE_fnc_hashGet;
                                _OPCOMFactions = [_handler,"factions"] call ALIVE_fnc_hashGet;
                                _OPCOMHasLogistics = false;

                                for "_i" from 0 to ((count synchronizedObjects _checkModule)-1) do {

                                    _mod = (synchronizedObjects _checkModule) select _i;

                                    if ((typeof _mod) == "ALiVE_mil_logistics") then {
                                        _OPCOMHasLogistics = true;
                                    };
                                };

                                if(_OPCOMHasLogistics) then {

                                    if(_OPCOMSide == _eventSide) then {
                                        _sideOPCOMModules pushback _checkModule;
                                    };

                                    {
                                        if(_x == _eventFaction) then {
                                            _factionOPCOMModules pushback _checkModule;
                                        };

                                    } forEach _OPCOMFactions;

                                };
                            };
                        };
                    } forEach (entities "Module_F");

                    // if no mil logistics handles this faction, and there is more than one mil
                    // logistics for this side return an error
                    if(((count _factionOPCOMModules == 0) && (count _sideOPCOMModules > 1)) || ((count _factionOPCOMModules == 0) && (count _sideOPCOMModules == 0))) then {
                        _eventForceMakeup = _eventData select 3;
                        _playerID = _eventData select 5;
                        _requestID = _eventForceMakeup select 0;
                        // respond to player request
                        _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","DENIED_FACTION_HANDLER_NOT_FOUND"] call ALIVE_fnc_event;
                        [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                    };

                    // if no mil logistics handles this faction, and there is one mil
                    // logistics for this side and this module handles that side
                    if((count _factionOPCOMModules == 0) && (count _sideOPCOMModules == 1) && (_side == _eventSide)) then {

                        _factionFound = true;

                        _eventData set [1,_factions select 0 select 1 select 0];
                        [_event, "data", _eventData] call ALIVE_fnc_hashSet;
                        _eventFaction = _factions select 0 select 1 select 0;
                    };

                };
            };

            if!(_factionFound) exitWith {};


            if(_factionFound) then {

                _type = [_logic, "type"] call MAINCLASS;

                _forcePool = [ALIVE_globalForcePool,_eventFaction] call ALIVE_fnc_hashGet;


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["ML - Global force pool:"] call ALiVE_fnc_dump;
                    ALIVE_globalForcePool call ALIVE_fnc_inspectHash;
                };
                // DEBUG -------------------------------------------------------------------------------------


                // TEST BYPASS: ALIVE_ML_TEST_REQUEST=true skips the force pool check
                // and injects a synthetic pool of 100 so the event always proceeds.
                // TEST BYPASS: flag holds the eventID of the test request so concurrent
                // events don't clobber each other. Check typeName to accept both legacy bool and ID string.
                private _isTestRequest = (!isNil "ALIVE_ML_TEST_REQUEST") &&
                    { typeName ALIVE_ML_TEST_REQUEST == "BOOL" && { ALIVE_ML_TEST_REQUEST } ||
                      typeName ALIVE_ML_TEST_REQUEST == "STRING" && { ALIVE_ML_TEST_REQUEST != "" } };
                if (_isTestRequest) then {
                    if (typeName _forcePool != "SCALAR") then { _forcePool = 0; };
                    _forcePool = _forcePool max 100;
                    ["ML - TEST BYPASS: Force pool overridden to %1 for test request.", _forcePool] call ALiVE_fnc_dump;
                };

                // if there are still forces available
                if(_forcePool > 0) then {

                    _eventID = [_event, "id"] call ALIVE_fnc_hashGet;
                    _eventData = [_event, "data"] call ALIVE_fnc_hashGet;
                    _eventType = _eventData select 4;

                    _forceMakeupTotal = 0;

                    if(_eventType == "STANDARD" || _eventType == "AIRDROP" || _eventType == "HELI_INSERT" || _eventType == "HELI_PARADROP") then {

                        //Sanitize _eventForceMakeup, 0 is the minimum for every reinforcement type, only for default logistics
                        //Restricted to opcom calls as the player logistic requests are made different
                        _eventForceMakeup = (_eventData select 3) apply { _x max 0 };

                        _allowInfantry = [_logic, "allowInfantryReinforcement"] call MAINCLASS;
                        _allowMechanised = [_logic, "allowMechanisedReinforcement"] call MAINCLASS;
                        _allowMotorised = [_logic, "allowMotorisedReinforcement"] call MAINCLASS;
                        _allowArmour = [_logic, "allowArmourReinforcement"] call MAINCLASS;
                        _allowHeli = [_logic, "allowHeliReinforcement"] call MAINCLASS;
                        _allowPlane = [_logic, "allowPlaneReinforcement"] call MAINCLASS;

                        _eventForceInfantry = _eventForceMakeup select 0;
                        _eventForceMotorised = _eventForceMakeup select 1;
                        _eventForceMechanised = _eventForceMakeup select 2;
                        _eventForceArmour = _eventForceMakeup select 3;
                        _eventForcePlane = _eventForceMakeup select 4;
                        _eventForceHeli = _eventForceMakeup select 5;

                        _forceMakeupTotal = _eventForceInfantry + _eventForceMotorised + _eventForceMechanised + _eventForceArmour + _eventForcePlane + _eventForceHeli;

                        //["CHECK AI: %1 AM: %2 AM: %3 AA: %4 AH: %5 AP: %6",_allowInfantry,_allowMechanised,_allowMotorised,_allowArmour,_allowHeli,_allowPlane] call ALIVE_fnc_dump;
                        //["FORCE MAKEUP BEFORE: %1", _eventForceMakeup] call ALIVE_fnc_dump;

                        if!(_allowInfantry) then {
                            _forceMakeupTotal = _forceMakeupTotal - _eventForceInfantry;
                            _eventForceMakeup set [0,0];
                        };

                        if!(_allowMotorised) then {
                            _forceMakeupTotal = _forceMakeupTotal - _eventForceMotorised;
                            _eventForceMakeup set [1,0];
                        };

                        if!(_allowMechanised) then {
                            _forceMakeupTotal = _forceMakeupTotal - _eventForceMechanised;
                            _eventForceMakeup set [2,0];
                        };

                        if!(_allowArmour) then {
                            _forceMakeupTotal = _forceMakeupTotal - _eventForceArmour;
                            _eventForceMakeup set [3,0];
                        };

                        if!(_allowPlane) then {
                            _forceMakeupTotal = _forceMakeupTotal - _eventForcePlane;
                            _eventForceMakeup set [4,0];
                        };

                        if!(_allowHeli) then {
                            _forceMakeupTotal = _forceMakeupTotal - _eventForceHeli;
                            _eventForceMakeup set [5,0];
                        };

                        // -----------------------------------------------------------------
                        // FIX: Cap each force type to MAX_GROUPS_PER_REQUEST to prevent
                        // OPCOM from requesting unreasonably large reinforcements.
                        // Also recompute _forceMakeupTotal after capping.
                        // -----------------------------------------------------------------
                        private _capApplied = false;
                        for "_capIdx" from 0 to ((count _eventForceMakeup) - 1) do {
                            private _capVal = _eventForceMakeup select _capIdx;
                            if (_capVal > MAX_GROUPS_PER_REQUEST) then {
                                _eventForceMakeup set [_capIdx, MAX_GROUPS_PER_REQUEST];
                                _capApplied = true;
                            };
                        };

                        if (_capApplied && _debug) then {
                            ["ML - LOGCOM_REQUEST: Force makeup capped to max %1 per type. Capped makeup: %2",
                                MAX_GROUPS_PER_REQUEST, _eventForceMakeup] call ALiVE_fnc_dump;
                        };

                        // Recompute total after capping
                        _eventForceInfantry   = _eventForceMakeup select 0;
                        _eventForceMotorised  = _eventForceMakeup select 1;
                        _eventForceMechanised = _eventForceMakeup select 2;
                        _eventForceArmour     = _eventForceMakeup select 3;
                        _eventForcePlane      = _eventForceMakeup select 4;
                        _eventForceHeli       = _eventForceMakeup select 5;

                        _forceMakeupTotal = _eventForceInfantry + _eventForceMotorised + _eventForceMechanised + _eventForceArmour + _eventForcePlane + _eventForceHeli;

                        if (_debug) then {
                            ["ML - LOGCOM_REQUEST: Final force makeup after cap: %1 total groups: %2",
                                _eventForceMakeup, _forceMakeupTotal] call ALiVE_fnc_dump;
                        };
                        // -----------------------------------------------------------------

                        _eventData set [3, _eventForceMakeup];
                        [_event, "data", _eventData] call ALIVE_fnc_hashSet;

                        // set the state of the event
                        [_event, "state", "requested"] call ALIVE_fnc_hashSet;

                        // set the player requested flag on the event
                        [_event, "playerRequested", false] call ALIVE_fnc_hashSet;

                    }else{

                        _eventForceMakeup = _eventData select 3; //The array of player logistics is different than opcom one
                        
                        _playerID = _eventData select 5;
                        _requestID = _eventForceMakeup select 0;

                        // if it's a player request
                        // accept automatically

                        _forceMakeupTotal = 1;

                        // set the state of the event
                        [_event, "state", "playerRequested"] call ALIVE_fnc_hashSet;

                        // set the player requested flag on the event
                        [_event, "playerRequested", true] call ALIVE_fnc_hashSet;

                        // respond to player request
                        _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","ACKNOWLEDGED"] call ALIVE_fnc_event;
                        [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                    };


                    //["FORCE MAKEUP AFTER: %1 FORCE MAKEUP TOTAL: %2", _eventForceMakeup, _forceMakeupTotal] call ALIVE_fnc_dump;
                    //_event call ALIVE_fnc_inspectHash;

                    if(_forceMakeupTotal > 0) then {

                        // set the time the event was received
                        [_event, "time", time] call ALIVE_fnc_hashSet;

                        // set the state data array of the event
                        [_event, "stateData", []] call ALIVE_fnc_hashSet;

                        // set the profiles array of the event
                        [_event, "cargoProfiles", [] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
                        [_event, "transportProfiles", []] call ALIVE_fnc_hashSet;
                        [_event, "transportVehiclesProfiles", []] call ALIVE_fnc_hashSet;
                        [_event, "playerRequestProfiles", [] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;

                        [_event, "finalDestination", []] call ALIVE_fnc_hashSet;

                        [_event, "eventAssets", []] call ALIVE_fnc_hashSet;

                        // -----------------------------------------------------------------
                        // FIX: Reserve force pool immediately at request receipt to prevent
                        // burst requests all passing the pool check before any deduction.
                        // We deduct _forceMakeupTotal as a reservation. The actual profile
                        // creation may produce a different count, which is reconciled in
                        // monitorEvent by deducting the true count and refunding the
                        // reservation difference.
                        // -----------------------------------------------------------------
                        private _reservationAmount = _forceMakeupTotal;
                        if(_eventType != "PR_STANDARD" && _eventType != "PR_AIRDROP" && _eventType != "PR_HELI_INSERT") then {
                            private _registryID = [_logic, "registryID"] call MAINCLASS;
                            _forcePool = _forcePool - _reservationAmount;
                            [ALIVE_MLGlobalRegistry,"updateGlobalForcePool",[_registryID,_forcePool]] call ALIVE_fnc_MLGlobalRegistry;
                            [_event, "poolReservation", _reservationAmount] call ALIVE_fnc_hashSet;

                            if(_debug) then {
                                ["ML - LOGCOM_REQUEST: Reserved %1 from force pool. Remaining pool: %2",
                                    _reservationAmount, _forcePool] call ALiVE_fnc_dump;
                            };
                        } else {
                            [_event, "poolReservation", 0] call ALIVE_fnc_hashSet;
                        };
                        // -----------------------------------------------------------------

                        // store the event on the event queue
                        _eventQueue = [_logic, "eventQueue"] call MAINCLASS;
                        [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                        // TEST BYPASS: promote flag from bool to event ID so concurrent events
                        // don't interfere. Each test run owns its own event ID.
                        if (_isTestRequest) then {
                            ALIVE_ML_TEST_REQUEST = _eventID;
                            ["ML - TEST BYPASS: Flag bound to event %1.", _eventID] call ALiVE_fnc_dump;
                        };


                        // DEBUG -------------------------------------------------------------------------------------
                        if(_debug) then {
                            ["ML - Reinforce event received"] call ALiVE_fnc_dump;
                            ["ML - Current force pool for side: %2 available: %3", _side, _forcePool] call ALiVE_fnc_dump;
                            _event call ALIVE_fnc_inspectHash;
                        };
                        // DEBUG -------------------------------------------------------------------------------------


                        // trigger analysis
                        [_logic,"onDemandAnalysis"] call MAINCLASS;


                    }else{

                        // nothing left after non allowed types ruled out

                    };

                }else{


                    // DEBUG -------------------------------------------------------------------------------------
                    if(_debug) then {
                        ["ML - Reinforce event denied, force pool for side: %1 exhausted : %2", _side, _forcePool] call ALiVE_fnc_dump;
                    };
                    // DEBUG -------------------------------------------------------------------------------------


                    _eventID = [_event, "id"] call ALIVE_fnc_hashGet;
                    _eventData = [_event, "data"] call ALIVE_fnc_hashGet;
                    _eventForceMakeup = _eventData select 3;
                    _eventType = _eventData select 4;

                    if(_eventType == "PR_STANDARD" || _eventType == "PR_AIRDROP" || _eventType == "PR_HELI_INSERT") then {

                        _playerID = _eventData select 5;
                        _requestID = _eventForceMakeup select 0;

                        // respond to player request
                        _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","DENIED_FORCEPOOL"] call ALIVE_fnc_event;
                        [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                    };


                };

            }else{

                // faction not handled by this module, ignored..

            };

        };
    };

    case "onDemandAnalysis": {
        private["_debug","_analysisInProgress","_type","_forcePoolType","_registryID","_forcePool","_objectives"];

        if (isServer) then {

            _debug = [_logic, "debug"] call MAINCLASS;
            _analysisInProgress = _logic getVariable ["analysisInProgress", false];

            // if analysis not already underway
            if!(_analysisInProgress) then {

                _logic setVariable ["analysisInProgress", true];

                _type = [_logic, "type"] call MAINCLASS;
                _forcePoolType = [_logic, "forcePoolType"] call MAINCLASS;
                _registryID = [_logic, "registryID"] call MAINCLASS;
                _forcePool = [ALIVE_globalForcePool,_eventFaction] call ALIVE_fnc_hashGet;
                if(typeName _forcePool == "STRING") then {
                    _forcePool = parseNumber _forcePool;
                };

                _objectives = [_logic, "objectives"] call MAINCLASS;
                _objectives = _objectives select 0;


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["ML - On demand dynamic analysis started"] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------


                private["_reserve","_tacom_state","_priorityTotal","_priority"];

                _reserve = [];
                _priorityTotal = 0;

                // sort OPCOM objective states to find
                // reserved objectives
                {
                    _tacom_state = '';
                    if("tacom_state" in (_x select 1)) then {
                        _tacom_state = [_x,"tacom_state","none"] call ALIVE_fnc_hashGet;
                    };

                    switch(_tacom_state) do {
                        case "reserve":{

                            // increase the priority count by adding
                            // all held objective priorities
                            _priority = [_x,"priority"] call ALIVE_fnc_hashGet;
                            _priorityTotal = _priorityTotal + _priority;

                            // store the objective
                            _reserve pushback _x;
                        };
                    };

                } forEach _objectives;

                private["_previousReinforcementAnalysis","_previousReinforcementAnalysisPriorityTotal"];

                _previousReinforcementAnalysis = [_logic, "reinforcementAnalysis"] call MAINCLASS;

                // if the force pool type is dynamic
                // calculate the new pool
                if(_forcePoolType == "DYNAMIC") then {

                    //["DYNAMIC FORCE POOL"] call ALIVE_fnc_dump;
                    //["CURRENT FORCE POOL: %1",_forcePool] call ALIVE_fnc_dump;

                    // if there is a previous analysis
                    if(count _previousReinforcementAnalysis > 0) then {

                        //["PREVIOUS ANALYSIS FOUND"] call ALIVE_fnc_dump;

                        _previousReinforcementAnalysisPriorityTotal = [_previousReinforcementAnalysis, "priorityTotal"] call ALIVE_fnc_hashGet;

                        // if the current priority total is greater
                        // than the previous priority total
                        // objectives have been captured
                        // increase the available pool
                        if(_priorityTotal > _previousReinforcementAnalysisPriorityTotal) then {

                            //["CURRENT PRIORITY TOTAL IS GREATER THAN PREVIOUS"] call ALIVE_fnc_dump;

                            _forcePool = _forcePool + (_priorityTotal - _previousReinforcementAnalysisPriorityTotal);

                        }else{

                            if(_priorityTotal < _previousReinforcementAnalysisPriorityTotal) then {

                                // objectives have been lost
                                // reduce the force pool

                                if(_forcePool > 0) then {

                                    //["CURRENT PRIORITY TOTAL IS LESS THAN PREVIOUS"] call ALIVE_fnc_dump;

                                    _forcePool = _forcePool - (_previousReinforcementAnalysisPriorityTotal - _priorityTotal);

                                };

                            };

                        };

                    }else{

                        //["NO PREVIOUS ANALYSIS"] call ALIVE_fnc_dump;

                        // set the force pool as the
                        // current total
                        _forcePool = _priorityTotal;

                    };

                    // update the global force pool
                    [ALIVE_MLGlobalRegistry,"updateGlobalForcePool",[_registryID,_forcePool]] call ALIVE_fnc_MLGlobalRegistry;

                };


                private["_primaryReinforcementObjective","_reinforcementType","_sortedClusters",
                "_sortedObjectives","_primaryReinforcementObjectivePriority","_reinforcementAnalysis",
                "_previousPrimaryObjective","_available"];

                _primaryReinforcementObjective = [] call ALIVE_fnc_hashCreate;
                _reinforcementType = "";
                _available = false;

                if(_type == "STATIC") then {

                    // Static analysis, only one insertion point
                    // may be held. This point is dictated
                    // by the placement location
                    // once lost the insertion point is
                    // deactivated until recaptured

                    // if there is no previous analysis
                    if(count _previousReinforcementAnalysis == 0) then {

                        if(count _objectives > 0) then {

                            // sort objectives by distance to module
                            _sortedObjectives = [_objectives,[],{(position _logic) distance (_x select 2 select 1)},"DESCEND"] call ALiVE_fnc_SortBy;

                            // get the highest priority objective
                            _primaryReinforcementObjective = _sortedObjectives select ((count _sortedObjectives)-1);

                            // Preliminary type - deferred to case "requested" where
                            // route, terrain and asset data are available
                            _reinforcementType = "HELI";

                            if (_debug) then {
                                ["ML - onDemandAnalysis (STATIC): Preliminary type HELI (deferred to requested for final decision)."] call ALiVE_fnc_dump;
                            };

                            // Check if objective is held (available for use)
                            _tacom_state = '';
                            if("tacom_state" in (_primaryReinforcementObjective select 1)) then {
                                _tacom_state = [_primaryReinforcementObjective,"tacom_state","none"] call ALIVE_fnc_hashGet;
                            };
                            if(_tacom_state == "reserve") then { _available = true; };
                            
                            
                        // -----------------------------------------------------------------
                        // NEW: Single objective guard - if there is only one reserved
                        // objective it is simultaneously the insertion point AND the
                        // destination, which means helicopters fly units nowhere.
                        // When this is detected, find the nearest enemy-contested or
                        // uncontrolled mil cluster to use as the actual delivery target
                        // instead, so units are sent somewhere useful.
                        // -----------------------------------------------------------------
                        if (count _reserve == 1) then {

                            private _insertionPos = [_primaryReinforcementObjective, "center"] call ALIVE_fnc_hashGet;

                            if (_debug) then {
                                ["ML - onDemandAnalysis: Single reserved objective detected at %1. Searching for frontline destination.",
                                    _insertionPos] call ALiVE_fnc_dump;
                            };

                            private _frontlineObjective = nil;
                            private _frontlineDist = 0;

                            // First preference: look for objectives OPCOM does not currently hold
                            // sorted by distance from the insertion point - closest contested
                            // objective is the most tactically relevant destination
                            if (count _objectives > 0) then {

                                private _nonReserveObjectives = _objectives select {
                                    private _objState = "";
                                    if ("tacom_state" in (_x select 1)) then {
                                        _objState = [_x, "tacom_state", "none"] call ALIVE_fnc_hashGet;
                                    };
                                    // Include objectives that are being attacked or are unassigned
                                    // but exclude our own reserve (held) objectives
                                    _objState != "reserve"
                                };

                                if (_debug) then {
                                    ["ML - onDemandAnalysis: Found %1 non-reserve objectives as potential destinations",
                                        count _nonReserveObjectives] call ALiVE_fnc_dump;
                                };

                                if (count _nonReserveObjectives > 0) then {

                                    // Sort by distance from insertion point ascending
                                    // so we pick the closest frontline objective
                                    private _sortedFrontline = [
                                        _nonReserveObjectives, [],
                                        {(_insertionPos distance ([_x, "center"] call ALIVE_fnc_hashGet))},
                                        "ASCEND"
                                    ] call ALiVE_fnc_SortBy;

                                    private _candidate = _sortedFrontline select 0;
                                    private _candidateDist = _insertionPos distance ([_candidate, "center"] call ALIVE_fnc_hashGet);

                                    // Only use if meaningfully far from insertion point
                                    // (avoids swapping to an objective that is essentially
                                    // co-located with the base)
                                    if (_candidateDist > 500) then {
                                        _frontlineObjective = _candidate;
                                        _frontlineDist = _candidateDist;

                                        if (_debug) then {
                                            ["ML - onDemandAnalysis: Using non-reserve objective as destination. Distance: %1m",
                                                _frontlineDist] call ALiVE_fnc_dump;
                                        };
                                    } else {
                                        if (_debug) then {
                                            ["ML - onDemandAnalysis: Closest non-reserve objective too close (%1m), falling back to mil clusters.",
                                                _candidateDist] call ALiVE_fnc_dump;
                                        };
                                    };
                                };
                            };

                            // Second preference: if no suitable OPCOM objective found,
                            // fall back to mil clusters sorted by distance from insertion
                            if (isNil "_frontlineObjective" || {_frontlineDist <= 500}) then {

                                if (count(ALIVE_clustersMil select 2) > 0) then {

                                    private _sortedMilClusters = [
                                        ALIVE_clustersMil select 2, [],
                                        {(_insertionPos distance ([_x, "center"] call ALIVE_fnc_hashGet))},
                                        "ASCEND"
                                    ] call ALiVE_fnc_SortBy;

                                    // Walk through sorted clusters to find one that is
                                    // far enough away to be a meaningful destination
                                    {
                                        private _clusterDist = _insertionPos distance ([_x, "center"] call ALIVE_fnc_hashGet);
                                        if (_clusterDist > 500) exitWith {
                                            _frontlineObjective = _x;
                                            _frontlineDist = _clusterDist;
                                        };
                                    } forEach _sortedMilClusters;

                                    if (_debug) then {
                                        if (!isNil "_frontlineObjective" && {_frontlineDist > 500}) then {
                                            ["ML - onDemandAnalysis: Using mil cluster as destination. Distance: %1m",
                                                _frontlineDist] call ALiVE_fnc_dump;
                                        } else {
                                            ["ML - onDemandAnalysis: WARNING - No suitable mil cluster found beyond 500m. Keeping original destination."] call ALiVE_fnc_dump;
                                        };
                                    };
                                };
                            };

                            // Apply the frontline objective as the primary reinforcement
                            // destination if we found a valid one
                            if (!isNil "_frontlineObjective" && {_frontlineDist > 500}) then {
                                _primaryReinforcementObjective = _frontlineObjective;

                                // Recalculate reinforcement type based on distance
                                // Long distances favour air delivery, short favour ground
                                _reinforcementType = switch (true) do {
                                    case (_frontlineDist > 3000): { "AIR" };
                                    case (_frontlineDist > 1500): { "HELI" };
                                    default { "DROP" };
                                };

                                ["ML - onDemandAnalysis: Single objective scenario resolved. Destination set to frontline at %1m. Type: %2",
                                    _frontlineDist, _reinforcementType] call ALiVE_fnc_dump;
                            } else {
                                ["ML - onDemandAnalysis: WARNING - Could not resolve single objective scenario. Units may be delivered to insertion point."] call ALiVE_fnc_dump;
                            };
                        };
                        // -----------------------------------------------------------------
                        // END single objective guard
                        // -----------------------------------------------------------------

                        }else{

                            // no objectives nothing available
                            _available = false;
                        };

                    }else{

                        // there is previous analysis

                        _primaryReinforcementObjective = [_previousReinforcementAnalysis, "primary"] call ALIVE_fnc_hashGet;
                        _reinforcementType = [_previousReinforcementAnalysis, "type"] call ALIVE_fnc_hashGet;

                        // if the state of the objective is reserved
                        // objective is available for use
                        _tacom_state = '';
                        if("tacom_state" in (_primaryReinforcementObjective select 1)) then {
                            _tacom_state = [_primaryReinforcementObjective,"tacom_state","none"] call ALIVE_fnc_hashGet;
                        };

                        if(_tacom_state == "reserve") then {
                            _available = true;
                        };

                    };

                }else{

                    _available = true;

                    // Dynamic analysis, primary insertion objective
                    // will fall back to held objectives, finally
                    // falling back to non held marine or bases

                    if(count _reserve > 0) then {

                        // OPCOM controls some objectives
                        // reinforcements can be delivered
                        // directly assuming heli pads or
                        // airstrips are available


                        // sort reserved objectives by priority
                        _sortedObjectives = [_reserve,[],{([_x, "priority"] call ALIVE_fnc_hashGet)},"ASCEND"] call ALiVE_fnc_SortBy;

                        // get the highest priority objective
                        _primaryReinforcementObjective = _sortedObjectives select ((count _sortedObjectives)-1);

                        // Preliminary type - final decision is made in case "requested"
                        // where route distance, water, force composition and air asset
                        // availability are all known. Set HELI as the default preferred
                        // type when OPCOM holds objectives; requested will override to
                        // STANDARD if conditions don't support helicopter delivery.
                        _reinforcementType = "HELI";

                        if (_debug) then {
                            ["ML - onDemandAnalysis: Preliminary type HELI (deferred to requested for final decision based on route/assets)."] call ALiVE_fnc_dump;
                        };


                    }else{

                        // OPCOM controls no objectives
                        // reinforcements must be delivered
                        // via paradrops and or marine landings
                        // near to location of any existing troops

                        // randomly pick between marine and mil location for start position
                        if(random 1 > 0.5) then {

                            if(count(ALIVE_clustersCivMarine select 2) > 0) then {

                                // there are marine objectives available

                                // pick a primary one
                                _primaryReinforcementObjective = selectRandom (ALIVE_clustersCivMarine select 2);

                                _reinforcementType = "MARINE";

                            }else{

                                // no marine objectives available
                                // pick a low priority location for airdrops

                                if(count(ALIVE_clustersMil select 2) > 0) then {

                                    _sortedClusters = [ALIVE_clustersMil select 2,[],{([_x, "priority"] call ALIVE_fnc_hashGet)},"DESCEND"] call ALiVE_fnc_SortBy;

                                    // get the highest priority objective
                                    _primaryReinforcementObjective = _sortedClusters select ((count _sortedClusters)-1);

                                    _reinforcementType = "AIR";

                                };

                            };

                        }else{

                            // pick a low priority location for airdrops

                            if(count(ALIVE_clustersMil select 2) > 0) then {

                                _sortedClusters = [ALIVE_clustersMil select 2,[],{([_x, "priority"] call ALIVE_fnc_hashGet)},"DESCEND"] call ALiVE_fnc_SortBy;

                                // get the highest priority objective
                                _primaryReinforcementObjective = _sortedClusters select ((count _sortedClusters)-1);

                                _reinforcementType = "AIR";

                            };

                        };

                    };
                };

                // store the analysis results
                _reinforcementAnalysis = [] call ALIVE_fnc_hashCreate;
                [_reinforcementAnalysis, "priorityTotal", _priorityTotal] call ALIVE_fnc_hashSet;
                [_reinforcementAnalysis, "type", _reinforcementType] call ALIVE_fnc_hashSet;
                [_reinforcementAnalysis, "available", _available] call ALIVE_fnc_hashSet;
                [_reinforcementAnalysis, "primary", _primaryReinforcementObjective] call ALIVE_fnc_hashSet;
                [_reinforcementAnalysis, "reserveCount", count _reserve] call ALIVE_fnc_hashSet;

                [_logic, "reinforcementAnalysis", _reinforcementAnalysis] call MAINCLASS;

                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["ML - On demand analysis complete"] call ALiVE_fnc_dump;
                    ["ML - Priority total: %1",_priorityTotal] call ALiVE_fnc_dump;
                    ["ML - Reinforcement type: %1",_reinforcementType] call ALiVE_fnc_dump;
                    ["ML - Primary reinforcement objective available: %1",_available] call ALiVE_fnc_dump;
                    ["ML - Primary reinforcement objective:"] call ALiVE_fnc_dump;
                    _primaryReinforcementObjective call ALIVE_fnc_inspectHash;
                };
                // DEBUG -------------------------------------------------------------------------------------


                _logic setVariable ["analysisInProgress", false];
            };
        };
    };

    case "monitor": {
        if (isServer) then {

            // spawn monitoring loop

            [_logic] spawn {

                private ["_logic","_debug"];

                _logic = _this select 0;
                _debug = [_logic, "debug"] call MAINCLASS;


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["ML - Monitoring loop started"] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------


                waituntil {

                    sleep (10);

                    if!([_logic, "pause"] call MAINCLASS) then {

                        private ["_reinforcementAnalysis","_analysisInProgress","_eventQueue"];

                        _reinforcementAnalysis = [_logic, "reinforcementAnalysis"] call MAINCLASS;

                        // analysis has run
                        if(count _reinforcementAnalysis > 0) then {

                            _analysisInProgress = _logic getVariable ["analysisInProgress", false];

                            // if analysis not processing
                            if!(_analysisInProgress) then {

                                // loop the event queue
                                // and manage each event
                                _eventQueue = [_logic, "eventQueue"] call MAINCLASS;

                                if((count (_eventQueue select 2)) > 0) then {

                                    {
                                        [_logic,"monitorEvent",[_x, _reinforcementAnalysis]] call MAINCLASS;
                                    } forEach (_eventQueue select 2);

                                };

                            };

                        };

                    };

                    false
                };

            };

        };
    };

    case "monitorEvent": {

        private _debug = [_logic, "debug"] call MAINCLASS;
        private _registryID = [_logic, "registryID"] call MAINCLASS;
        private _event = _args select 0;
        private _reinforcementAnalysis = _args select 1;

        private _side = [_logic, "side"] call MAINCLASS;
        private _eventQueue = [_logic, "eventQueue"] call MAINCLASS;

        private _enableAirTransport = [_logic, "enableAirTransport"] call MAINCLASS;
        private _limitTransportToFaction = [_logic, "limitTransportToFaction"] call MAINCLASS;

        private _eventID = [_event, "id"] call ALIVE_fnc_hashGet;
        private _eventData = [_event, "data"] call ALIVE_fnc_hashGet;
        private _eventTime = [_event, "time"] call ALIVE_fnc_hashGet;
        private _eventState = [_event, "state"] call ALIVE_fnc_hashGet;
        private _eventStateData = [_event, "stateData"] call ALIVE_fnc_hashGet;
        private _eventCargoProfiles = [_event, "cargoProfiles"] call ALIVE_fnc_hashGet;
        private _eventTransportProfiles = [_event, "transportProfiles"] call ALIVE_fnc_hashGet;
        private _eventTransportVehiclesProfiles = [_event, "transportVehiclesProfiles"] call ALIVE_fnc_hashGet;
        private _playerRequested = [_event, "playerRequested"] call ALIVE_fnc_hashGet;
        private _playerRequestProfiles = [_event, "playerRequestProfiles"] call ALIVE_fnc_hashGet;

        private _reinforcementPriorityTotal = [_reinforcementAnalysis, "priorityTotal"] call ALIVE_fnc_hashGet;
        private _reinforcementType = [_reinforcementAnalysis, "type"] call ALIVE_fnc_hashGet;
        private _reinforcementAvailable = [_reinforcementAnalysis, "available"] call ALIVE_fnc_hashGet;
        private _reinforcementPrimaryObjective = [_reinforcementAnalysis, "primary"] call ALIVE_fnc_hashGet;

        private _eventPosition = _eventData select 0;
        private _eventFaction = _eventData select 1;
        private _eventSide = _eventData select 2;
        private _eventForceMakeup = _eventData select 3;
        private _eventType = _eventData select 4;

        private _forcePool = [ALIVE_globalForcePool,_eventFaction] call ALIVE_fnc_hashGet;

        private [
            "_playerID","_requestID","_payload","_emptyVehicles","_staticIndividuals","_joinIndividuals","_reinforceIndividuals","_staticGroups","_joinGroups","_reinforceGroups",
            "_eventForceInfantry","_eventForceMotorised","_eventForceMechanised","_eventForceArmour","_eventForcePlane","_eventForceHeli"
        ];

        if(_playerRequested) then {

            _playerID = _eventData select 5;
            _requestID = _eventForceMakeup select 0;
            _payload = _eventForceMakeup select 1;
            _emptyVehicles = _eventForceMakeup select 2;
            _staticIndividuals = _eventForceMakeup select 3;
            _joinIndividuals = _eventForceMakeup select 4;
            _reinforceIndividuals = _eventForceMakeup select 5;
            _staticGroups = _eventForceMakeup select 6;
            _joinGroups = _eventForceMakeup select 7;
            _reinforceGroups = _eventForceMakeup select 8;

        }else{

            _eventForceInfantry = _eventForceMakeup select 0;
            _eventForceMotorised = _eventForceMakeup select 1;
            _eventForceMechanised = _eventForceMakeup select 2;
            _eventForceArmour = _eventForceMakeup select 3;
            _eventForcePlane = _eventForceMakeup select 4;
            _eventForceHeli = _eventForceMakeup select 5;

        };

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["ML - Monitoring Event"] call ALiVE_fnc_dump;
            _event call ALIVE_fnc_inspectHash;
            //_reinforcementAnalysis call ALIVE_fnc_inspectHash;
        };
        // DEBUG -------------------------------------------------------------------------------------

        private "_logEvent";

        // react according to current event state
        switch(_eventState) do {

            // AI REQUEST ---------------------------------------------------------------------------------------------------------------------------------

            // the units have been requested
            // spawn the units at the insertion point
            case "requested": {

                private ["_waitTime"];

                // Wait time before spawning profiles.
                // Use helicopter wait time as default since that is the preferred
                // delivery method; the decision logic below will select STANDARD
                // if conditions don't support helicopter insertion.
                private _waitTime = WAIT_TIME_HELI;


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["ML - Event state: %1 event timer: %2 wait time on event: %3 ",_eventState, (time - _eventTime), _waitTime] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------


                // if the reinforcement objective is
                // not available, cancel the event

                if(_reinforcementAvailable) then {

                    if((time - _eventTime) > _waitTime) then {

                        private ["_reinforcementPosition","_playersInRange","_paraDrop","_remotePosition","_airTrans","_noHeavy","_slingAvailable","_water","_AA","_newPos","_routeDistance","_routeDirection"];

                        // Override delivery mechanism if there is water or AA or armored vehicles required
                        _noHeavy = _eventForceMechanised == 0 && _eventForceArmour == 0;

                        _water = false; // water is in the way

                        // Check route
                        _routeDistance = _eventPosition distance ([_reinforcementPrimaryObjective,"center"] call ALIVE_fnc_hashGet);
                        _routeDirection = (_eventPosition getDir ([_reinforcementPrimaryObjective,"center"] call ALIVE_fnc_hashGet));
                        _newPos = _eventPosition;
                        for "_i" from 0 to _routeDistance step 20 do {
                            _newPos = _newPos getpos [20, _routeDirection];
                            if (surfaceIsWater _newPos) exitWith {_water = true;};
                        };

                        _slingAvailable = false; // slingloading is available as a service
                        _airTrans = [];

                        if (_enableAirTransport) then {
                            _airTrans = [ALIVE_factionDefaultAirTransport,_eventFaction,[]] call ALIVE_fnc_hashGet;
                            if(count _airTrans == 0 && !_limitTransportToFaction) then {
                                 _airTrans = [ALIVE_sideDefaultAirTransport,_side] call ALIVE_fnc_hashGet;
                            };
                            // Check helicopters can slingload
                            {
                                _slingAvailable = [(configFile >> "CfgVehicles" >> _x >> "slingLoadMaxCargoMass"), 0] call ALiVE_fnc_getConfigValue > 1000;
                                if (_slingAvailable) exitWith {};
                            } foreach  _airTrans;
                        };

                        // ---------------------------------------------------------------
                        // DELIVERY TYPE DECISION
                        //
                        // Armour is always delivered by ground convoy -- too heavy to slingload.
                        // Motorised and mechanised use slingload helicopter when a capable
                        // heli asset exists; otherwise fall back to ground convoy.
                        // Infantry uses HELI_INSERT/PARADROP based on distance and terrain.
                        //
                        // Decision order:
                        // 0. Only 2 held objectives AND distance < 500m AND no water
                        //                                          -> STANDARD (ground only)
                        // 1. Armour requested                      -> STANDARD
                        // 2. No air transport assets               -> STANDARD
                        // 3. Motorised or mechanised + slingload
                        //    available                             -> HELI_INSERT (slingload path)
                        // 4. Motorised or mechanised + no slingload-> STANDARD
                        // 5. Zero distance (single objective)      -> HELI_INSERT (score destination)
                        // 6. Water on route                        -> HELI_INSERT
                        // 7. Distance < 1500m                      -> STANDARD
                        // 8. Distance >= 1500m                     -> HELI_INSERT
                        // ---------------------------------------------------------------

                        if (!isNil "ALIVE_ML_TEST_REQUEST" && { ALIVE_ML_TEST_REQUEST == _eventID }) then {
                            ["ML - TEST BYPASS: Preserving requested eventType=%1, skipping delivery type decision.", _eventType] call ALiVE_fnc_dump;
                        } else {
                        private _reserveCount = [_reinforcementAnalysis, "reserveCount", 99] call ALIVE_fnc_hashGet;
                        private _hasVehicles  = (_eventForceMechanised > 0 || _eventForceMotorised > 0);
                        private _hasArmour    = (_eventForceArmour > 0);

                        // Rule 0: 2 held objectives, close distance, no water -- ground only.
                        // Helicopter insertion is pointless at this range and the supply chain
                        // is just starting -- drive to the destination.
                        if (_reserveCount <= 2 && _routeDistance < 500 && !_water) then {
                            _eventType = "STANDARD";
                            if (_debug) then {
                                ["ML - Delivery type: STANDARD (only %1 held objectives, distance %2m < 500m threshold, ground only)",
                                    _reserveCount, round _routeDistance] call ALiVE_fnc_dump;
                            };
                        } else {

                        // Rule 1: Armour always goes by ground
                        if (_hasArmour) then {
                            _eventType = "STANDARD";
                            if (_debug) then {
                                ["ML - Delivery type: STANDARD (armour requested, ground convoy only)"] call ALiVE_fnc_dump;
                            };
                        } else {
                            // Rule 2: No air assets available
                            if (count _airTrans == 0) then {
                                _eventType = "STANDARD";
                                if (_debug) then {
                                    ["ML - Delivery type: STANDARD (no air transport assets available)"] call ALiVE_fnc_dump;
                                };
                            } else {
                                // Rule 3-4: Motorised/mechanised vehicles -- slingload or ground
                                if (_hasVehicles) then {
                                    if (_slingAvailable) then {
                                        _eventType = "HELI_INSERT";
                                        if (_debug) then {
                                            ["ML - Delivery type: HELI_INSERT (motorised/mechanised via slingload)"] call ALiVE_fnc_dump;
                                        };
                                    } else {
                                        _eventType = "STANDARD";
                                        if (_debug) then {
                                            ["ML - Delivery type: STANDARD (motorised/mechanised, no slingload heli available -- verify slingLoadMaxCargoMass config and ALIVE_factionDefaultAirTransport / ALIVE_sideDefaultAirTransport registration for faction=%1 side=%2)",
                                                _eventFaction, _side] call ALiVE_fnc_dump;
                                        };
                                    };
                                } else {
                                    // Pure infantry -- distance and terrain based
                                    if (_routeDistance < 1) then {
                                        _eventType = "HELI_INSERT";
                                        if (_debug) then {
                                            ["ML - Delivery type: HELI_INSERT (single objective scenario, deferring destination to scoring)"] call ALiVE_fnc_dump;
                                        };
                                    } else {
                                        if (_water) then {
                                            _eventType = "HELI_INSERT";
                                            if (_debug) then {
                                                ["ML - Delivery type: HELI_INSERT (water obstacle on route, distance %1m)", _routeDistance] call ALiVE_fnc_dump;
                                            };
                                        } else {
                                            if (_routeDistance < 1500) then {
                                                _eventType = "STANDARD";
                                                if (_debug) then {
                                                    ["ML - Delivery type: STANDARD (short distance %1m, ground preferred)", _routeDistance] call ALiVE_fnc_dump;
                                                };
                                            } else {
                                                _eventType = "HELI_INSERT";
                                                if (_debug) then {
                                                    ["ML - Delivery type: HELI_INSERT (distance %1m, helicopter preferred)", _routeDistance] call ALiVE_fnc_dump;
                                                };
                                            };
                                        };
                                    };
                                };
                            };
                        }; // end Rules 1-8
                        }; // end Rule 0 else
                        }; // end if (!ALIVE_ML_TEST_REQUEST) delivery type decision

                        // TEST BYPASS: pin departure and destination to the positions stored
                        // on the event hash by the test script. Skip the supply network anchor
                        // and destination scoring entirely so helis always fly the fixed route.
                        private _testFromPos = [];
                        private _testDestPos = [];
                        if (!isNil "ALIVE_ML_TEST_REQUEST" && { ALIVE_ML_TEST_REQUEST == _eventID }) then {
                            _testFromPos = [_event, "testFromPos", []] call ALIVE_fnc_hashGet;
                            _testDestPos = [_event, "testDestPos", []] call ALIVE_fnc_hashGet;
                            if (count _testFromPos > 0 && count _testDestPos > 0) then {
                                _reinforcementPosition = _testFromPos;
                                _eventPosition         = _testDestPos;
                                _eventData set [0, _eventPosition];
                                [_event, "data", _eventData] call ALIVE_fnc_hashSet;
                                _remotePosition = _testFromPos; // heli spawn near departure
                                private _fromName = [_testFromPos] call ALIVE_fnc_taskGetNearestLocationName;
                                private _toName   = [_testDestPos] call ALIVE_fnc_taskGetNearestLocationName;
                                ["ML - TEST BYPASS: Positions pinned. From=%1 at %2  To=%3 at %4",
                                    _fromName, _testFromPos, _toName, _testDestPos] call ALiVE_fnc_dump;
                            };
                        };

                        // Both STANDARD and HELI_INSERT depart from a held objective.
                        // Anchor _reinforcementPosition to the nearest valid supply network
                        // node so that departure/destination distance calculations are always
                        // relative to the actual HQ, not whatever _reinforcementPrimaryObjective
                        // OPCOM dynamically assigned (which can be any held objective).
                        if (count _testFromPos == 0) then {
                        _reinforcementPosition = [_reinforcementPrimaryObjective,"center"] call ALIVE_fnc_hashGet;

                        // Anchor departure to the nearest valid supply network node.
                        _reinforcementPosition = [_logic, "getSupplyNetworkDeparturePos", [
                            _eventFaction,
                            _eventPosition,
                            _reinforcementPosition,
                            _eventID,
                            _debug
                        ]] call MAINCLASS;

                        }; // end if (count _testFromPos == 0) -- supply network anchor

                        ["AI LOGCOM Side: %1 Type: %2 From: %3 To: %4 Dist: %5m Water: %6 Heavy: %7",
                            _side, _eventType, _reinforcementPosition, _eventPosition,
                            round _routeDistance, _water, !_noHeavy] call ALiVE_fnc_dump;

                        // Armour is never sent via HELI_INSERT (ruled out in delivery decision above).
                        // Zero it out defensively in case of unexpected state.
                        if (_eventType == "HELI_INSERT" || _eventType == "HELI_PARADROP") then {
                            _eventForceArmour = 0;
                        };

                        // players near check

                        _playersInRange = [_reinforcementPosition, 500] call ALiVE_fnc_anyPlayersInRange;

                        // if players are in visible range
                        // para drop groups instead of
                        // spawning on the ground

                        _paraDrop = false;
                        if(_playersInRange > 0) then {
                            _paraDrop = true;
                            _remotePosition = [_reinforcementPosition, 2000] call ALIVE_fnc_getPositionDistancePlayers;
                        };

                        // -----------------------------------------------------------------
                        // -----------------------------------------------------------------
                        // HELI_INSERT departure base and destination selection.
                        //
                        // Rules:
                        // 1. Helicopters must depart from a friendly held objective
                        //    that is DIFFERENT from the delivery destination.
                        // 2. If only one friendly objective is held, helicopter
                        //    insertion is not tactically viable - cancel and do nothing.
                        //    Do NOT substitute another delivery type.
                        // 3. If multiple friendly objectives exist, pick the one
                        //    furthest from the destination as the departure base
                        //    so helicopters fly the longest meaningful route.
                        // 4. Override the delivery destination with the best scored
                        //    objective from findBestDeliveryObjective.
                        // -----------------------------------------------------------------
                        // TEST BYPASS: if positions are pinned skip the entire HELI_INSERT
                        // departure base selection and destination scoring block. Positions
                        // are already fixed; running this would override them.
                        if (_eventType == "HELI_INSERT" && { count _testFromPos == 0 }) then {

                            // Get all friendly held objectives
                            private _allObjectives = [_logic, "objectives"] call MAINCLASS;
                            if (count _allObjectives > 0) then {
                                _allObjectives = _allObjectives select 0;
                            };

                            // Validate held objectives using multiple criteria:
                            // 1. tacom_state must be "reserve" (OPCOM assignment)
                            // 2. At least one assigned section profile must still exist
                            //    (confirms OPCOM units haven't been wiped out)
                            // 3. No more than 3 enemy units within 300m
                            //    (confirms not currently enemy-occupied)
                            private _heldObjectives = [];
                            {
                                private _obj = _x;
                                private _objState = "";
                                if ("tacom_state" in (_obj select 1)) then {
                                    _objState = [_obj, "tacom_state", "none"] call ALIVE_fnc_hashGet;
                                };

                                if (_objState == "reserve") then {

                                    // Check section profiles - at least one must still be registered
                                    private _section = [_obj, "section", []] call ALIVE_fnc_hashGet;
                                    private _hasAliveProfiles = false;
                                    if (count _section > 0) then {
                                        {
                                            private _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                            if (!isNil "_profile") exitWith { _hasAliveProfiles = true; };
                                        } forEach _section;
                                    } else {
                                        // No section assigned yet - trust tacom_state alone
                                        _hasAliveProfiles = true;
                                    };

                                    if (_hasAliveProfiles) then {

                                        // Check for enemy presence near the objective
                                        private _objPos = [_obj, "center"] call ALIVE_fnc_hashGet;
                                        private _sideObj = [_side] call ALIVE_fnc_sideTextToObject;
                                        private _nearUnits = _objPos nearEntities [["Man","Car","Tank"], 300];
                                        private _enemyNear = _nearUnits select { side _x != _sideObj && side _x != civilian };

                                        if (count _enemyNear < 3) then {
                                            _heldObjectives pushback _obj;
                                        } else {
                                            if (_debug) then {
                                                ["ML - HELI_INSERT: Objective at %1 has tacom_state=reserve but %2 enemy units within 300m - treating as lost",
                                                    _objPos, count _enemyNear] call ALiVE_fnc_dump;
                                            };
                                        };

                                    } else {
                                        if (_debug) then {
                                            ["ML - HELI_INSERT: Objective at %1 has tacom_state=reserve but all section profiles gone - treating as lost",
                                                [_obj, "center"] call ALIVE_fnc_hashGet] call ALiVE_fnc_dump;
                                        };
                                    };
                                };
                            } forEach _allObjectives;

                            if (_debug) then {
                                ["ML - HELI_INSERT: Found %1 validated friendly held objectives (tacom_state=reserve, profiles alive, no enemy presence):",
                                    count _heldObjectives] call ALiVE_fnc_dump;
                                {
                                    private _objPos   = [_x, "center"] call ALIVE_fnc_hashGet;
                                    private _objID    = [_x, "objectiveID"] call ALIVE_fnc_hashGet;
                                    private _objState = [_x, "tacom_state", "none"] call ALIVE_fnc_hashGet;
                                    private _nearLocName = [_objPos] call ALIVE_fnc_taskGetNearestLocationName;
                                    ["ML - HELI_INSERT: Held objective %1 near %2 at %3 tacom_state=%4",
                                        _objID, _nearLocName, _objPos, _objState] call ALiVE_fnc_dump;

                                    // Temporary marker - auto-deletes after 3 minutes
                                    [_objPos, _objID] spawn {
                                        private _pos   = _this select 0;
                                        private _id    = _this select 1;
                                        private _mName = format ["ML_HELD_%1_%2", _id, time];
                                        private _m = createMarker [_mName, _pos];
                                        _m setMarkerShape "ICON";
                                        _m setMarkerType "mil_flag";
                                        _m setMarkerColor "ColorGreen";
                                        _m setMarkerSize [0.6, 0.6];
                                        _m setMarkerText format ["HELD: %1", _id];
                                        sleep 180;
                                        deleteMarker _mName;
                                    };
                                } forEach _heldObjectives;
                            };

                            // Rule 2: Fewer than 2 validated held objectives - heli insert
                            // not yet viable. Keep event in requested state and re-check
                            // next monitor cycle. Fall back to ground convoy after timeout.
                            if (count _heldObjectives <= 1) then {

                                private _heliWaitIterations = _eventStateData param [1, 0]; if (isNil "_heliWaitIterations" || typeName _heliWaitIterations != "SCALAR") then { _heliWaitIterations = 0; };
                                _heliWaitIterations = _heliWaitIterations + 1;
                                _eventStateData set [1, _heliWaitIterations];
                                [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;
                                [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                                // ~33 minutes at 10s monitor interval
                                private _heliWaitMax = 200;

                                if (_heliWaitIterations >= _heliWaitMax) then {
                                    ["ML - HELI_INSERT: Timeout waiting for valid held objectives (%1 cycles). Falling back to ground convoy for event %2.",
                                        _heliWaitIterations, _eventID] call ALiVE_fnc_dump;
                                    _eventType = "STANDARD";
                                    // Reset stateData so ground convoy path starts clean
                                    _eventStateData set [1, 0];
                                    [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;
                                    // Fall through - _eventType is now STANDARD and will
                                    // be handled by the profile creation below
                                } else {
                                    if (_debug) then {
                                        ["ML - HELI_INSERT: Only %1 validated held objective(s). Waiting for more to be captured. Cycle %2/%3.",
                                            count _heldObjectives, _heliWaitIterations, _heliWaitMax] call ALiVE_fnc_dump;
                                    };
                                    // Exit this monitor cycle - re-evaluate next time
                                };

                            };

                            if (_eventType == "HELI_INSERT") then { // still heli after held check

                                // Held objectives check passed - clear that wait counter
                                if (count _eventStateData > 1) then {
                                    _eventStateData set [1, 0];
                                    [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;
                                };

                                // Select departure base and destination from held objectives.
                                //
                                // Doctrine:
                                //   Departure = held objective CLOSEST to the OPCOM reinforcement
                                //               position (the HQ). This is where troops stage from.
                                //   Destination = held objective FURTHEST from the reinforcement
                                //                 position. This is the frontline to reinforce.
                                //
                                // This works with 2+ held objectives and requires no scoring wait.
                                // Scoring (findBestDeliveryObjective) is then used to refine the
                                // destination when more assessed objectives are available.

                                private _departureObjective = nil;
                                private _destObjective      = nil;
                                private _minDistToHQ        = 1e10;
                                private _maxDistToHQ        = 0;

                                // Supply chain: determine whether the chain has started.
                                // If no non-HQ delivery node exists yet, ML has never
                                // completed a delivery beyond HQ -- the departure base is
                                // always HQ (only network node), and ALL held objectives
                                // are valid destinations so the chain can start flowing.
                                // Once the chain has started, the scored destination
                                // override is constrained to supply network nodes.
                                private _chainStarted = false;
                                if (!isNil "ALIVE_ML_supplyNetwork") then {
                                    private _nodes = [ALIVE_ML_supplyNetwork, _eventFaction, []] call ALIVE_fnc_hashGet;
                                    {
                                        private _nodeIsHQ = if (count _x > 2) then { _x select 2 } else { false };
                                        if (!_nodeIsHQ) exitWith { _chainStarted = true; };
                                    } forEach _nodes;
                                };

                                {
                                    private _objPos     = [_x, "center"] call ALIVE_fnc_hashGet;
                                    private _distToHQ   = _objPos distance _reinforcementPosition;

                                    // Departure constraint: objective must be in the supply
                                    // network (HQ node, or prior delivery with surviving units).
                                    // This always correctly selects HQ as departure at mission
                                    // start since it is the only network node.
                                    private _inNetwork = false;
                                    if (!isNil "ALIVE_ML_supplyNetwork") then {
                                        private _nodes = [ALIVE_ML_supplyNetwork, _eventFaction, []] call ALIVE_fnc_hashGet;
                                        {
                                            private _node     = _x;
                                            private _nodePos  = _node select 0;
                                            private _nodeIDs  = _node select 1;
                                            private _nodeIsHQ = if (count _node > 2) then { _node select 2 } else { false };
                                            if (_objPos distance2D _nodePos < 500) exitWith {
                                                if (_nodeIsHQ) then {
                                                    _inNetwork = true;
                                                } else {
                                                    {
                                                        if (!isNil { [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler }) exitWith {
                                                            _inNetwork = true;
                                                        };
                                                    } forEach _nodeIDs;
                                                };
                                            };
                                        } forEach _nodes;
                                    };

                                    // Closest to HQ that is in the supply network = departure base
                                    if (_inNetwork) then {
                                        if (_distToHQ < _minDistToHQ) then {
                                            _minDistToHQ        = _distToHQ;
                                            _departureObjective = _x;
                                        };
                                    } else {
                                        if (_debug) then {
                                            ["ML - HELI_INSERT: Objective at %1 skipped as departure -- not in supply network or delivered units gone",
                                                _objPos] call ALiVE_fnc_dump;
                                        };
                                    };

                                    // Destination: all held objectives are always candidates --
                                    // no supply chain constraint on where we send units to.
                                    if (_distToHQ > _maxDistToHQ) then {
                                        _maxDistToHQ    = _distToHQ;
                                        _destObjective  = _x;
                                    };
                                } forEach _heldObjectives;

                                // Departure and destination must be different objectives.
                                // Compare by center position since objectives are ALiVE hash arrays
                                // and cannot be compared with != directly.
                                // When only 2 held objectives exist the distance filter is relaxed --
                                // we must use what we have regardless of separation.
                                private _departurePos2 = if (!isNil "_departureObjective") then { [_departureObjective, "center"] call ALIVE_fnc_hashGet } else { [] };
                                private _destPos2      = if (!isNil "_destObjective")      then { [_destObjective,      "center"] call ALIVE_fnc_hashGet } else { [] };
                                private _minSeparation = if (count _heldObjectives <= 2) then { 0 } else { 500 };
                                private _validPair = (count _departurePos2 > 0) && { count _destPos2 > 0 } && { _departurePos2 distance2D _destPos2 > _minSeparation };

                                if (_validPair) then {
                                    private _departurePos = _departurePos2;
                                    private _destPos      = _destPos2;

                                    // Try to find a better scored destination among all objectives
                                    // (assessed enemy/contested objectives preferred over held ones).
                                    // When only 2 held objectives exist the destination IS the only
                                    // other held objective -- do not override it with a scored result
                                    // since that could send units to a distant unassessed location
                                    // before the supply chain has even started.
                                    private _scoredEnemyCount = 0;
                                    private _scoredObjState   = "none";
                                    if (count _allObjectives > 0 && count _heldObjectives > 2) then {
                                        private _scoredResult = [_logic, "findBestDeliveryObjective", [
                                            _allObjectives,
                                            _reinforcementPosition,
                                            _eventFaction,
                                            _side,
                                            _departurePos,
                                            count _heldObjectives
                                        ]] call MAINCLASS;
                                        private _scoredPos = _scoredResult select 0;
                                        _scoredEnemyCount  = _scoredResult select 1;
                                        _scoredObjState    = _scoredResult select 2;
                                        // Only use scored result if it's far enough from departure
                                        if (count _scoredPos > 0 && _scoredPos distance _departurePos > 500) then {
                                            _destPos = _scoredPos;
                                            if (_debug) then {
                                                private _sName = [_destPos] call ALIVE_fnc_taskGetNearestLocationName;
                                                ["ML - HELI_INSERT: Scored objective near %1 at %2 selected as destination (enemy=%3 state=%4)",
                                                    _sName, _destPos, _scoredEnemyCount, _scoredObjState] call ALiVE_fnc_dump;
                                            };
                                        } else {
                                            if (_debug) then {
                                                private _dName = [_destPos] call ALIVE_fnc_taskGetNearestLocationName;
                                                ["ML - HELI_INSERT: No better scored objective. Using furthest held objective near %1 at %2 as destination.",
                                                    _dName, _destPos] call ALiVE_fnc_dump;
                                            };
                                        };
                                    } else {
                                        if (_debug) then {
                                            private _dName = [_destPos] call ALIVE_fnc_taskGetNearestLocationName;
                                            ["ML - HELI_INSERT: Only %1 held objective(s) -- destination locked to nearest held objective near %2 at %3. No scored override.",
                                                count _heldObjectives, _dName, _destPos] call ALiVE_fnc_dump;
                                        };
                                    };

                                    // Persist destination
                                    _eventPosition = _destPos;
                                    _eventData set [0, _eventPosition];
                                    [_event, "data", _eventData] call ALIVE_fnc_hashSet;
                                    _eventStateData set [1, 0];
                                    _eventStateData set [2, 0];
                                    _eventStateData set [3, 0];
                                    [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                                    // Apply PARADROP vs INSERT decision
                                    // TEST BYPASS: skip enemy scoring -- preserve requested type.
                                    if (!isNil "ALIVE_ML_TEST_REQUEST" && { ALIVE_ML_TEST_REQUEST == _eventID }) then {
                                        ["ML - TEST BYPASS: Preserving eventType=%1, skipping PARADROP/INSERT enemy score check.", _eventType] call ALiVE_fnc_dump;
                                    } else {
                                        if (_scoredEnemyCount > 0 || _scoredObjState in ["attack","capture"]) then {
                                            _eventType = "HELI_PARADROP";
                                            ["ML - HELI_PARADROP selected: enemy=%1 objState=%2 at destination.",
                                                _scoredEnemyCount, _scoredObjState] call ALiVE_fnc_dump;
                                        } else {
                                            if (_debug) then {
                                                ["ML - HELI_INSERT confirmed: enemy=%1 objState=%2 at destination. LZ clear.",
                                                    _scoredEnemyCount, _scoredObjState] call ALiVE_fnc_dump;
                                            };
                                        };
                                    };

                                    // Set departure base and find spawn LZ
                                    _reinforcementPosition = _departurePos;
                                    _remotePosition = [_logic, "prepareHelicopterLZ", [
                                        _reinforcementPosition getPos [random 200, random 360], 100
                                    ]] call MAINCLASS;

                                    // FIX: prepareHelicopterLZ picks a local LZ near the departure
                                    // base without checking player positions. If players are nearby
                                    // the base the heli would spawn in view. Push the spawn position
                                    // out to at least 1500m from any player.
                                    if ([_remotePosition, 1000] call ALiVE_fnc_anyPlayersInRange > 0) then {
                                        _remotePosition = [_remotePosition, 1500] call ALIVE_fnc_getPositionDistancePlayers;
                                        if (_debug) then {
                                            ["ML - HELI_INSERT: Spawn LZ too close to players, pushed to %1", _remotePosition] call ALiVE_fnc_dump;
                                        };
                                    };

                                    if (_debug) then {
                                        private _baseName = [_departurePos] call ALIVE_fnc_taskGetNearestLocationName;
                                        private _dstName  = [_destPos]      call ALIVE_fnc_taskGetNearestLocationName;
                                        ["ML - HELI_INSERT: Departure base near %1 at %2. Destination near %3 at %4. Flight dist: %5m",
                                            _baseName, _departurePos, _dstName, _destPos,
                                            _remotePosition distance _destPos] call ALiVE_fnc_dump;
                                        ["ML - HELI_INSERT: Heli spawn LZ: %1", _remotePosition] call ALiVE_fnc_dump;
                                    };

                                } else {
                                    // Only one held objective or departure == destination - wait
                                    private _heliBaseWaitIterations = _eventStateData param [3, 0]; if (isNil "_heliBaseWaitIterations" || typeName _heliBaseWaitIterations != "SCALAR") then { _heliBaseWaitIterations = 0; };
                                    _heliBaseWaitIterations = _heliBaseWaitIterations + 1;
                                    _eventStateData set [3, _heliBaseWaitIterations];
                                    [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;
                                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                                    private _heliBaseWaitMax = 100;

                                    if (_heliBaseWaitIterations >= _heliBaseWaitMax) then {
                                        ["ML - HELI_INSERT: Timeout waiting for 2 distinct held objectives (%1 cycles). Falling back to ground convoy for event %2.",
                                            _heliBaseWaitIterations, _eventID] call ALiVE_fnc_dump;
                                        _eventType = "STANDARD";
                                        _eventStateData set [3, 0];
                                        [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;
                                    } else {
                                        if (_debug) then {
                                            ["ML - HELI_INSERT: Need 2 distinct held objectives for departure/destination. Have %1. Waiting. Cycle %2/%3.",
                                                count _heldObjectives, _heliBaseWaitIterations, _heliBaseWaitMax] call ALiVE_fnc_dump;
                                        };
                                    };
                                };

                            }; // end if (_eventType == "HELI_INSERT") held check

                        } else {
                            if (!_paraDrop) then {
                                _remotePosition = _reinforcementPosition;
                            };
                        };
                        // -----------------------------------------------------------------


                        // Guard: if event is in a wait state (no destination or departure base
                        // found yet) or was cancelled, skip profile creation this cycle.
                        // The event remains in the queue with state="requested" and will be
                        // re-evaluated on the next monitor cycle.
                        private ["_activeCheck","_eventStillActive","_sd","_w1","_w2","_w3","_waitingForHeli"];
                        _activeCheck = [_eventQueue, _eventID] call ALIVE_fnc_hashGet;
                        _eventStillActive = !isNil "_activeCheck";
                        _sd = _eventStateData;
                        _w1 = _sd param [1, 0]; if (isNil "_w1" || typeName _w1 != "SCALAR") then { _w1 = 0; };
                        _w2 = _sd param [2, 0]; if (isNil "_w2" || typeName _w2 != "SCALAR") then { _w2 = 0; };
                        _w3 = _sd param [3, 0]; if (isNil "_w3" || typeName _w3 != "SCALAR") then { _w3 = 0; };
                        _waitingForHeli = _eventStillActive && ((_w1 > 0 && _w1 < 200) || (_w2 > 0 && _w2 < 200) || (_w3 > 0 && _w3 < 100));

                        if (_debug) then {
                            if (!_eventStillActive) then {
                                ["ML - requested: Event %1 was cancelled before profile creation, skipping.", _eventID] call ALiVE_fnc_dump;
                            } else {
                                if (_waitingForHeli) then {
                                    ["ML - requested: Event %1 waiting for valid heli conditions, skipping profile creation this cycle.", _eventID] call ALiVE_fnc_dump;
                                };
                            };
                        };

                        if (_eventStillActive && !_waitingForHeli) then {

                        // Throttle: limit concurrent HELI_INSERT missions to avoid
                        // flooding the AO with helicopters from the same destination
                        private _heliThrottleExceeded = false;
                        if (_eventType in ["HELI_INSERT","HELI_PARADROP"]) then {
                            private _activeHeliEvents = 0;
                            {
                                private _qEvent = _x;
                                private _qState = [_qEvent, "state"] call ALIVE_fnc_hashGet;
                                private _qID    = [_qEvent, "id"]    call ALIVE_fnc_hashGet;
                                private _qData  = [_qEvent, "data"]  call ALIVE_fnc_hashGet;
                                private _qType  = if (count _qData > 4) then { _qData select 4 } else { "" };
                                if (_qID != _eventID && _qType in ["HELI_INSERT","HELI_PARADROP"]) then {
                                    // Count both HELI_INSERT/HELI_PARADROP-specific states AND standard transport
                                    // states, since HELI_INSERT can fall back to the STANDARD path
                                    if (_qState in [
                                        "transportLoad","transportLoadWait","transportStart","transportTravel",
                                        "heliTransportStart","heliTransport","heliTransportUnloadWait",
                                        "heliTransportComplete","heliTransportReturn","heliTransportReturnWait",
                                        "heliParadropStart","heliParadropFly","heliParadropReturn","heliParadropReturnWait"
                                    ]) then {
                                        _activeHeliEvents = _activeHeliEvents + 1;
                                    };
                                };
                            } forEach (_eventQueue select 2);
                        if (!isNil "ALIVE_ML_TEST_REQUEST" && { ALIVE_ML_TEST_REQUEST == _eventID }) then {
                            ["ML - TEST BYPASS: Skipping heli throttle check for test request."] call ALiVE_fnc_dump;
                        } else {
                            if (_activeHeliEvents >= 2) then {
                                _heliThrottleExceeded = true;
                                if (_debug) then {
                                    ["ML - HELI_INSERT: Throttle active - %1 heli missions in cycle. Deferring event %2.",
                                        _activeHeliEvents, _eventID] call ALiVE_fnc_dump;
                                };
                            };
                        }; // end test bypass else
                        }; // end if (_eventType in ["HELI_INSERT","HELI_PARADROP"])

                        // Slingload concurrency throttle: if MAX_SLINGLOAD_CONCURRENT vehicle
                        // slingload operations are already in flight, downgrade vehicle transport
                        // to STANDARD ground convoy for this event. Infantry delivery is unaffected.
                        if (!_heliThrottleExceeded && _eventType == "HELI_INSERT" && (_eventForceMotorised > 0 || _eventForceMechanised > 0)) then {
                            private _activeSlingloads = 0;
                            {
                                private _qEvent = _x;
                                private _qState = [_qEvent, "state"] call ALIVE_fnc_hashGet;
                                private _qID    = [_qEvent, "id"]    call ALIVE_fnc_hashGet;
                                if (_qID != _eventID && _qState in [
                                    "transportLoad","transportLoadWait","transportStart","transportTravel",
                                    "unloadTransportHelicopter"
                                ]) then {
                                    private _qCargo = [_qEvent, "cargoProfiles"] call ALIVE_fnc_hashGet;
                                    if (!isNil "_qCargo") then {
                                        private _qMot  = [_qCargo, "motorised"]  call ALIVE_fnc_hashGet;
                                        private _qMech = [_qCargo, "mechanised"] call ALIVE_fnc_hashGet;
                                        if ((count _qMot > 0) || (count _qMech > 0)) then {
                                            _activeSlingloads = _activeSlingloads + 1;
                                        };
                                    };
                                };
                            } forEach (_eventQueue select 2);

                            if (_activeSlingloads >= MAX_SLINGLOAD_CONCURRENT) then {
                                // Too many slingloads in flight - send vehicles by ground this cycle
                                _eventForceMotorised  = 0;
                                _eventForceMechanised = 0;
                                // If no infantry either, fall back to pure STANDARD
                                if (_eventForceInfantry == 0) then { _eventType = "STANDARD"; };
                                if (_debug) then {
                                    ["ML - Slingload throttle: %1 active slingload ops (max %2). Vehicle groups deferred to ground convoy. Event: %3",
                                        _activeSlingloads, MAX_SLINGLOAD_CONCURRENT, _eventID] call ALiVE_fnc_dump;
                                };
                            };
                        };

                        if (!_heliThrottleExceeded) then {

                        // wait time complete create profiles
                        // get groups according to requested force makeup

                        private ["_infantryGroups","_infantryProfiles","_transportGroups","_transportProfiles",
                        "_transportVehicleProfiles","_group","_groupCount","_totalCount","_vehicleClass",
                        "_profiles","_profileIDs","_profileID","_position"];

                        _groupCount = 0;
                        _totalCount = 0;

                        // motorised

                        private ["_motorisedGroups","_motorisedProfiles"];

                        _motorisedGroups = [];
                        _motorisedProfiles = [];

                        for "_i" from 0 to _eventForceMotorised -1 do {
                            private ["_group","_tempGroups"];
                            _tempGroups = [];
                            _group = ["Motorized",_eventFaction] call ALIVE_fnc_configGetRandomGroup;
                            if!(_group == "FALSE") then {
                                _tempGroups pushback _group;
                            };
                            _group = ["Motorized_MTP",_eventFaction] call ALIVE_fnc_configGetRandomGroup;
                            if!(_group == "FALSE") then {
                                _tempGroups pushback _group;
                            };
                            if (count _tempGroups > 0) then {
                                _group = selectRandom _tempGroups;
                                _motorisedGroups pushback _group;
                            };
                        };

                        _motorisedGroups = _motorisedGroups - ALiVE_PLACEMENT_GROUPBLACKLIST;
                        _groupCount = count _motorisedGroups;
                        _totalCount = _totalCount + _groupCount;

                        // FIX: Track skipped motorised groups
                        private _motorisedSkipped = 0;

                        for "_i" from 0 to _groupCount -1 do {

                            _group = _motorisedGroups select _i;

                            if (_eventType == "HELI_INSERT") then {
                                _position = [_logic, "prepareHelicopterLZ", [
                                    _reinforcementPosition getPos [random(200), random(360)], 60
                                ]] call MAINCLASS;
                                if (_debug) then {
                                    ["ML - HELI_INSERT motorised pickup LZ prepared at %1", _position] call ALiVE_fnc_dump;
                                };
                            } else {
                                _position = _reinforcementPosition getPos [random(200), random(360)];
                                if (_paraDrop && _eventType != "HELI_INSERT") then {
                                    _position set [2,PARADROP_HEIGHT];
                                };
                            };

                            if!(surfaceIsWater _position) then {

                                _profiles = [_group, _position, random(360), false, _eventFaction, true] call ALIVE_fnc_createProfilesFromGroupConfig;

                                _profileIDs = [];
                                {
                                    _profileID = _x select 2 select 4;
                                    _profileIDs pushback _profileID;
                                } forEach _profiles;

                                _motorisedProfiles pushback _profileIDs;

                            } else {
                                _groupCount = _groupCount - 1;
                                _totalCount = _totalCount - 1;
                                _motorisedSkipped = _motorisedSkipped + 1;

                                if (_debug) then {
                                    ["ML - Motorised group %1 skipped (water at position). Running skipped count: %2",
                                        _group, _motorisedSkipped] call ALiVE_fnc_dump;
                                };
                            };
                        };

                        if (_debug) then {
                            ["ML - Motorised groups created: %1 skipped: %2 profiles: %3",
                                _groupCount, _motorisedSkipped, count _motorisedProfiles] call ALiVE_fnc_dump;
                        };

                        // create profiles
                        for "_i" from 0 to _groupCount -1 do {

                            _group = _motorisedGroups select _i;

                            if (_eventType == "HELI_INSERT") then {
                                _position = [_logic, "prepareHelicopterLZ", [
                                    _reinforcementPosition getPos [random(200), random(360)], 60
                                ]] call MAINCLASS;
                                if (_debug) then {
                                    ["ML - HELI_INSERT motorised pickup LZ prepared at %1", _position] call ALiVE_fnc_dump;
                                };
                            } else {
                                _position = _reinforcementPosition getPos [random(200), random(360)];
                                if (_paraDrop && _eventType != "HELI_INSERT") then {
                                    _position set [2,PARADROP_HEIGHT];
                                };
                            };

                            if!(surfaceIsWater _position) then {

                                _profiles = [_group, _position, random(360), false, _eventFaction, true] call ALIVE_fnc_createProfilesFromGroupConfig;

                                _profileIDs = [];
                                {
                                    _profileID = _x select 2 select 4;
                                    _profileIDs pushback _profileID;
                                } forEach _profiles;

                                _motorisedProfiles pushback _profileIDs;

                            } else {
                                _groupCount = _groupCount - 1;
                                _totalCount = _totalCount - 1;
                            };
                        };

                        [_eventCargoProfiles, "motorised", _motorisedProfiles] call ALIVE_fnc_hashSet;

                        if(_debug) then {
                            ["ML - Profiles: %1 %2 %3 ", _eventForceMotorised, _motorisedGroups, _motorisedProfiles] call ALiVE_fnc_dump;
                        };

                        TRACE_1("ML HELI INSERT", _motorisedProfiles);

                        if(_eventType == "HELI_INSERT" && (count _motorisedProfiles > 0)) then {

                            // create heli transport vehicles for groups with vehicles

                            _transportGroups = [ALIVE_factionDefaultAirTransport,_eventFaction,[]] call ALIVE_fnc_hashGet;
                            _transportProfiles = [];
                            _transportVehicleProfiles = [];

                            _payloadGroupProfiles = [];

                            // Append side defaults when faction list is empty OR when not faction-limited.
                            // Using && caused spuriously empty _transportGroups when the faction list was
                            // populated but limitTransportToFaction was false, incorrectly forcing all
                            // HELI_INSERT and HELI_PARADROP events to STANDARD delivery.
                            if(count _transportGroups == 0 || !_limitTransportToFaction) then {
                                _transportGroups append ([ALIVE_sideDefaultAirTransport,_side] call ALIVE_fnc_hashGet);
                            };

                            if(count _transportGroups > 0) then {

                                // If any of the vehicles cannot be airlifted, will need to switch to a standard delivery for vehicles

                                private _requiresStandardDelivery = false;

                                {
                                    _groupProfile = _x;

                                    {
                                        private ["_currentDiff","_vehicleClass","_position","_payloadWeight","_slingLoadProfile"];

                                        // Check to see if profile is a vehicle
                                        if ([_x,"vehicle"] call CBA_fnc_find != -1) then {

                                            // Get the profile
                                            _slingLoadProfile = [ALiVE_ProfileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;

                                            // _slingloadProfile call ALIVE_fnc_inspectHash;

                                            _payloadWeight = [(_slingLoadProfile select 2 select 11)] call ALIVE_fnc_getObjectWeight;

                                            // Select helicopter that can slingload the vehicle
                                            _vehicleClass = "";
                                            _currentDiff = 15000;
                                            {
                                                private ["_capacity","_slingloadmax","_maxLoad","_slingDiff","_loadDiff"];

                                                _slingloadmax = [(configFile >> "CfgVehicles" >> _x >> "slingLoadMaxCargoMass")] call ALiVE_fnc_getConfigValue;

                                                if (!isnil "_slingloadmax") then {
                                                	_slingDiff = _slingloadmax - _payloadWeight;

                                                	if ((_slingDiff < _currentDiff) && (_slingDiff > 0)) then {_currentDiff = _slingDiff; _vehicleClass = _x;};
                                                };
                                            } foreach _transportGroups;

                                            // Cannot find vehicle big enough to slingload...
                                            if (_vehicleClass == "") exitWith {_requiresStandardDelivery = true};

                                            //save vehicle class to group profile
                                            [_slingloadProfile, "vehicleClassSling", _vehicleClass] call ALiVE_fnc_hashSet;
                                        };

                                    } foreach _groupProfile;

                                } foreach _motorisedProfiles;

                                // If we can't helo a vehicle then just send it by land.
                                // In test mode, log the failure explicitly so it is visible in RPT
                                // rather than silently degrading to ground convoy.
                                if (_requiresStandardDelivery) exitWith {
                                    if (!isNil "ALIVE_ML_TEST_REQUEST" && { ALIVE_ML_TEST_REQUEST == _eventID }) then {
                                        ["ML - TEST BYPASS: Slingload weight check FAILED -- no heli class in _transportGroups can lift the vehicle. _transportGroups=%1 faction=%2. Verify slingLoadMaxCargoMass config and faction air transport registration. Falling back to STANDARD for event %3.",
                                            _transportGroups, _eventFaction, _eventID] call ALiVE_fnc_dump;
                                    } else {
                                        if (_debug) then {
                                            ["ML - HELI_INSERT slingload: Weight check failed for a vehicle group. No suitable lift heli in _transportGroups=%1. Falling back to STANDARD for event %2.",
                                                _transportGroups, _eventID] call ALiVE_fnc_dump;
                                        };
                                    };
                                    _eventType = "STANDARD";
                                };

                                // For each group - create helis to carry their vehicles.
                                // Use a per-heli spawn index so findHelicopterLandingPos searches
                                // progressively wider arcs and the tracker exclusion zone guarantees
                                // >150m separation between all spawn pads. Base minRadius = 200m so
                                // Chinooks never share the same airspace on climb-out.
                                private _slingHeliSpawnIdx = 0;
                                {
                                    _groupProfile = _x;

                                    // Note: we do NOT pre-assign infantry into the truck profile here.
                                    // createProfileVehicleAssignment writes to profile slot 9 (_inCargo),
                                    // but the slung vehicle spawn path in ALiVE core bypasses that slot --
                                    // the truck spawns via setSlingLoad, not the normal cargo spawn path.
                                    // Infantry are seated after the sling is released (in unloadTransportHelicopter).
                                    // Store entity ID on the slung vehicle profile so the drop thread can find it.
                                    private _motEntityID  = _groupProfile select 0;
                                    private _motVehicleID = "";
                                    {
                                        if ([_x,"vehicle"] call CBA_fnc_find != -1) then { _motVehicleID = _x; };
                                    } forEach _groupProfile;

                                    {

                                        private ["_vehicleClass","_position","_slingLoadProfile"];

                                        if ([_x,"vehicle"] call CBA_fnc_find != -1) then {

                                            // Get the profile
                                            _slingLoadProfile = [ALiVE_ProfileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                            _vehicleClass = [_slingloadProfile, "vehicleClassSling"] call ALiVE_fnc_hashGet;
                                            [_slingloadProfile, "vehicleClassSling"] call ALiVE_fnc_hashRem;

                                            // Stagger spawn positions with 400m steps so Chinooks have
                                            // enough separation to avoid rotor-disc collisions on climb-out.
                                            // Z is set terrain-relative (ASL) so helis always spawn at
                                            // PARADROP_HEIGHT above the actual ground, not above sea level.
                                            // On mountainous terrain a fixed Z=350 can put the heli inside a
                                            // hillside; getTerrainHeightASL corrects for this.
                                            private _spawnMin = 400 + (_slingHeliSpawnIdx * 400);
                                            private _spawnMax = _spawnMin + 300;
                                            _position = [_logic, "findHelicopterLandingPos", [
                                                _reinforcementPosition, _spawnMin, _spawnMax
                                            ]] call MAINCLASS;
                                            // Spawn at ground level (Z=0). Spawning at altitude with slung
                                            // truck already attached causes immediate in-air collision --
                                            // the Arma engine resolves the combined slung mass as a ground
                                            // collision and destroys the heli within seconds of spawn.
                                            // The heli takes off from the ground naturally; heliTransportStart
                                            // assigns the flight waypoint and the AI climbs to cruise altitude.
                                            _position set [2, 0];
                                            _slingHeliSpawnIdx = _slingHeliSpawnIdx + 1;
                                            if (_debug) then {
                                                ["ML - HELI_INSERT slingload heli spawn pos (ground): %1 class: %2 (idx=%3 minR=%4 maxR=%5)",
                                                _position, _vehicleClass, _slingHeliSpawnIdx - 1, _spawnMin, _spawnMax] call ALiVE_fnc_dump;
                                            };

                                            // Create slingloading heli (slingloading another profile!)
                                            _profiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,true,true,[], [[_x], []]] call ALIVE_fnc_createProfilesCrewedVehicle;

                                            // Set slingload state on profile
                                            [_slingloadProfile,"slung",[[_profiles select 1 select 2 select 4]]] call ALIVE_fnc_profileVehicle;

                                            // Store infantry entity ID on the slung truck profile so
                                            // unloadTransportHelicopter can seat crew after drop.
                                            if (_motEntityID != "") then {
                                                [_slingloadProfile, "alive_ml_sling_infantry_id", _motEntityID] call ALIVE_fnc_hashSet;
                                            };

                                            if(_debug) then {
                                                ["ML - Slingloading: %1 (infantry entity: %2)", _vehicleClass, _motEntityID] call ALiVE_fnc_dump;
                                                _slingloadProfile call ALIVE_fnc_inspectHash;
                                            };

                                            _transportProfiles pushback (_profiles select 0 select 2 select 4);
                                            _transportVehicleProfiles pushback (_profiles select 1 select 2 select 4);

                                            _profileIDs = [];
                                            {
                                                _profileID = _x select 2 select 4;
                                                _profileIDs pushback _profileID;
                                            } forEach _profiles;

                                            _payloadGroupProfiles pushback _profileIDs;

                                            // Prevent ALiVE virtualising the heli and slung truck before
                                            // heliTransportStart fires. Without preventDespawn on ALL three
                                            // profiles (entity/pilot, vehicle/heli, truck) the profile system
                                            // despawns the pilot entity when players move away, deletes the
                                            // pilot unit, and the unmanned heli is garbage-collected mid-air.
                                            // preventDespawn is cleared after the sling is released.
                                            private _heliEntityProf = _profiles select 0;
                                            private _heliVehicleProf = _profiles select 1;
                                            // Entity profile uses hashSet (not profileVehicle) since it is an entity
                                            [_heliEntityProf, "spawnType", ["preventDespawn"]] call ALIVE_fnc_hashSet;
                                            [_heliVehicleProf, "spawnType", ["preventDespawn"]] call ALIVE_fnc_profileVehicle;
                                            [_slingLoadProfile, "spawnType", ["preventDespawn"]] call ALIVE_fnc_profileVehicle;
                                            // Store pilot entity profile ID on the heli vehicle PROFILE hash
                                            // so unloadTransportHelicopter can clear preventDespawn post-drop.
                                            // Use profile hash (always available) not vehicle object setVariable
                                            // (vehicle object may be null before ALiVE activates the profile).
                                            [_heliVehicleProf, "alive_ml_pilot_entity_id",
                                                _heliEntityProf select 2 select 4] call ALIVE_fnc_hashSet;
                                            if (_debug) then {
                                                ["ML - HELI_INSERT slingload: preventDespawn set on pilot %1 heli %2 truck %3",
                                                    _profiles select 0 select 2 select 4,
                                                    _profiles select 1 select 2 select 4, _x] call ALiVE_fnc_dump;
                                            };

                                            // Initial waypoint points to event destination (not reinforcementPosition).
                                            // Helis spawn at 350m AGL near reinforcementPosition -- if the waypoint
                                            // pointed there with a 100m completion radius the profile system would
                                            // complete it immediately (2D proximity, altitude ignored), despawn the
                                            // heli, and it would fall from the sky. heliTransportStart will override
                                            // this with the correct per-heli LZ waypoint before the heli moves far.
                                            _profileWaypoint = [_eventPosition, 200, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                            _profile = _heliEntityProf;
                                            [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

                                            _totalCount = _totalCount + 1;
                                            
                                            // Fuel watchdog for slingload transport heli
                                            [_logic, "spawnHelicopterFuelWatchdog", [
                                                _profiles select 0 select 2 select 4,
                                                _reinforcementPosition,
                                                _eventFaction
                                            ]] call MAINCLASS;
                                            if (_debug) then {
                                                ["ML - HELI_INSERT slingload watchdog started for profile %1",
                                                    _profiles select 0 select 2 select 4] call ALiVE_fnc_dump;
                                            };
                                            
                                        };

                                    } foreach _groupProfile;

                                } foreach _motorisedProfiles;

                            } else {
                                // _transportGroups empty after all faction + side lookups.
                                // No heli assets available to slingload motorised vehicles.
                                // This else is correctly scoped to the inner if(count _transportGroups > 0)
                                // so it only fires for genuine HELI_INSERT+motorised config failures.
                                // HELI_PARADROP and pure-infantry HELI_INSERT never enter the outer
                                // if(_eventType == "HELI_INSERT" && motorisedProfiles > 0) block
                                // and are therefore completely unaffected.
                                ["ML - HELI_INSERT slingload: No air transport assets found for faction=%1 side=%2 (limitToFaction=%3). Check ALIVE_factionDefaultAirTransport / ALIVE_sideDefaultAirTransport registration. Falling back to STANDARD for event %4.", _eventFaction, _side, _limitTransportToFaction, _eventID] call ALiVE_fnc_dump;
                                _eventType = "STANDARD";
                            };
                            _eventTransportProfiles = _transportProfiles;
                            _eventTransportVehiclesProfiles = _transportVehicleProfiles;

                            [_eventCargoProfiles,"payloadGroups",_payloadGroupProfiles] call ALIVE_fnc_hashSet;

                        };

                        // infantry
                        _infantryGroups = [];
                        _infantryProfiles = [];

                        for "_i" from 0 to _eventForceInfantry -1 do {
                            _group = ["Infantry",_eventFaction] call ALIVE_fnc_configGetRandomGroup;
                            if!(_group == "FALSE") then {
                                _infantryGroups pushback _group;
                            }
                        };

                        _infantryGroups = _infantryGroups - ALiVE_PLACEMENT_GROUPBLACKLIST;
                        _groupCount = count _infantryGroups;
                        _totalCount = _totalCount + _groupCount;

                        // create profiles
                        // FIX: Track skipped groups separately so _infantryProfiles
                        // index stays in sync with the heli transport loop below.
                        private _infantrySkipped = 0;

                        for "_i" from 0 to _groupCount -1 do {

                            _group = _infantryGroups select _i;

                            if(_paraDrop) then {
                                if(_eventType == "HELI_INSERT" || _eventType == "HELI_PARADROP") then {
                                    _position = _remotePosition;
                                }else{
                                    _position = _reinforcementPosition getPos [random(200), random(360)];
                                    _position set [2,PARADROP_HEIGHT];
                                };
                            } else {
                                if (_eventType == "HELI_INSERT" || _eventType == "HELI_PARADROP") then {
                                    // Spawn at departure base - position will be overridden
                                    // to the specific pickup LZ during heli assignment below
                                    _position = _remotePosition;
                                } else {
                                    _position = _reinforcementPosition getPos [random(200), random(360)];
                                };
                            };

                            if!(surfaceIsWater _position) then {

                                _profiles = [_group, _position, random(360), false, _eventFaction, true] call ALIVE_fnc_createProfilesFromGroupConfig;

                                _profileIDs = [];
                                {
                                    _profileID = _x select 2 select 4;
                                    _profileIDs pushback _profileID;
                                } forEach _profiles;

                                _infantryProfiles pushback _profileIDs;

                            } else {
                                _groupCount = _groupCount - 1;
                                _totalCount = _totalCount - 1;
                                _infantrySkipped = _infantrySkipped + 1;

                                if (_debug) then {
                                    ["ML - Infantry group %1 skipped (water at position). Running skipped count: %2",
                                        _group, _infantrySkipped] call ALiVE_fnc_dump;
                                };
                            };
                        };

                        if (_debug) then {
                            ["ML - Infantry groups created: %1 skipped: %2 profiles: %3",
                                _groupCount, _infantrySkipped, count _infantryProfiles] call ALiVE_fnc_dump;
                        };
                        
                        [_eventCargoProfiles, "infantry", _infantryProfiles] call ALIVE_fnc_hashSet;

                        if(_eventType == "HELI_INSERT") then {

                            private ["_infantryProfileID","_infantryProfile","_profileWaypoint","_profile"];

                            // create air transport vehicles for the profiles

                            _transportGroups = [ALIVE_factionDefaultAirTransport,_eventFaction,[]] call ALIVE_fnc_hashGet;
                            _transportProfiles = [];
                            _transportVehicleProfiles = [];

                            if(count _transportGroups == 0) then {
                                _transportGroups = [ALIVE_sideDefaultAirTransport,_side] call ALIVE_fnc_hashGet;
                            };

                            if(count _transportGroups > 0) then {

                                for "_i" from 0 to _groupCount -1 do {

                                    private _pickupLZPos = [_logic, "prepareHelicopterLZ", [
                                        _remotePosition getPos [random(200), random(360)], 80
                                    ]] call MAINCLASS;

                                    if (_paraDrop) then {
                                        _position = +_pickupLZPos;
                                        _position set [2,PARADROP_HEIGHT];
                                    } else {
                                        _position = _pickupLZPos;
                                    };

                                    if (_debug) then {
                                        ["ML - HELI_INSERT infantry [%1/%2] pickup LZ: %3",
                                            _i + 1, _groupCount, _pickupLZPos] call ALiVE_fnc_dump;
                                    };

                                    if(count _transportGroups > 0) then {

                                        _vehicleClass = selectRandom _transportGroups;

                                        _profiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,true,true] call ALIVE_fnc_createProfilesCrewedVehicle;

                                        _transportProfiles pushback (_profiles select 0 select 2 select 4);
                                        _transportVehicleProfiles pushback (_profiles select 1 select 2 select 4);

                                        if(count _infantryProfiles > _i) then {
                                            if(count (_infantryProfiles select _i) > 0) then {
                                                // Assign ALL entities in this infantry group to the transport vehicle
                                                {
                                                    if!(isNil "_x") then {
                                                        _infantryProfile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                                        if!(isNil "_infantryProfile") then {
                                                            [_infantryProfile,_profiles select 1] call ALIVE_fnc_createProfileVehicleAssignment;
                                                            [_infantryProfile, "position", _pickupLZPos] call ALIVE_fnc_profileEntity;
                                                        };
                                                    };
                                                } forEach (_infantryProfiles select _i);
                                            };
                                        };

                                        // Give heli only a loiter waypoint at the pickup LZ so
                                        // infantry have time to board. The destination waypoint is
                                        // assigned later by heliTransportStart after throttle checks
                                        // and final LZ selection -- assigning it here caused a stale
                                        // duplicate WP that made helis RTB before troops were
                                        // unloaded at the drop-off.
                                        private _loiterWaypoint = [_pickupLZPos, 10, "MOVE", "LIMITED", 60, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                        _profile = _profiles select 0;
                                        [_profile, "addWaypoint", _loiterWaypoint] call ALIVE_fnc_profileEntity;

                                        // Fuel watchdog for infantry transport heli
                                        [_logic, "spawnHelicopterFuelWatchdog", [
                                            _profiles select 0 select 2 select 4,
                                            _reinforcementPosition,
                                            _eventFaction
                                        ]] call MAINCLASS;

                                    };

                                };

                            };

                            _eventTransportProfiles = _eventTransportProfiles + _transportProfiles;
                            _eventTransportVehiclesProfiles = _eventTransportVehiclesProfiles + _transportVehicleProfiles;
                        };

                        if(_eventType == "HELI_PARADROP") then {

                            private ["_infantryProfileID","_infantryProfile","_profileWaypoint","_profile"];

                            _transportGroups = [ALIVE_factionDefaultAirTransport,_eventFaction,[]] call ALIVE_fnc_hashGet;
                            _transportProfiles = [];
                            _transportVehicleProfiles = [];

                            if(count _transportGroups == 0) then {
                                _transportGroups = [ALIVE_sideDefaultAirTransport,_side] call ALIVE_fnc_hashGet;
                            };

                            if(count _transportGroups > 0) then {

                                // Track used pickup positions so multiple paradrop helis
                                // don't spawn on top of each other -- mirrors the
                                // _usedLandingPositions pattern in heliTransportStart.
                                private _usedPickupPositions = [];

                                for "_i" from 0 to _groupCount -1 do {

                                    private _pickupLZPos = [_logic, "prepareHelicopterLZ", [
                                        _remotePosition getPos [random(200), random(360)], 80
                                    ]] call MAINCLASS;

                                    // Push back from any already-claimed pickup position
                                    private _tooClose = false;
                                    { if (_pickupLZPos distance _x < 50) then { _tooClose = true; }; } forEach _usedPickupPositions;
                                    if (_tooClose) then {
                                        _pickupLZPos = [_logic, "prepareHelicopterLZ", [
                                            _remotePosition getPos [random(300), random(360)], 80
                                        ]] call MAINCLASS;
                                    };
                                    _usedPickupPositions pushback _pickupLZPos;

                                    if (_debug) then {
                                        ["ML - HELI_PARADROP: Heli [%1/%2] spawn LZ: %3",
                                            _i + 1, _groupCount, _pickupLZPos] call ALiVE_fnc_dump;
                                    };

                                    _vehicleClass = selectRandom _transportGroups;

                                    _profiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_pickupLZPos,random(360),false,_eventFaction,true,true] call ALIVE_fnc_createProfilesCrewedVehicle;

                                    _transportProfiles pushback (_profiles select 0 select 2 select 4);
                                    _transportVehicleProfiles pushback (_profiles select 1 select 2 select 4);

                                    if(count _infantryProfiles > _i) then {
                                        if(count (_infantryProfiles select _i) > 0) then {
                                            {
                                                if!(isNil "_x") then {
                                                    _infantryProfile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                                    if!(isNil "_infantryProfile") then {
                                                        // FIX: Assign infantry to the transport vehicle so they are
                                                        // physically inside the heli when it spawns in player range.
                                                        // Without this assignment the profile system spawns infantry
                                                        // at their stored ground position (_eventPosition) rather than
                                                        // aboard the heli at altitude, meaning players see units
                                                        // teleport to the ground instead of parachuting.
                                                        // Mirror the HELI_INSERT pattern exactly.
                                                        [_infantryProfile, _profiles select 1] call ALIVE_fnc_createProfileVehicleAssignment;
                                                        [_infantryProfile, "position", _pickupLZPos] call ALIVE_fnc_profileEntity;
                                                    };
                                                };
                                            } forEach (_infantryProfiles select _i);
                                        };
                                    };

                                    // Give heli a brief loiter at the pickup LZ before departure.
                                    // Mirrors HELI_INSERT -- gives the profile system time to
                                    // propagate the vehicle assignment before the heli moves.
                                    // heliParadropStart assigns the actual drop zone waypoint.
                                    private _paradropLoiter = [_pickupLZPos, 10, "MOVE", "LIMITED", 30, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                    private _pdProfile = _profiles select 0;
                                    [_pdProfile, "addWaypoint", _paradropLoiter] call ALIVE_fnc_profileEntity;

                                    // If players are nearby at spawn time, physically board
                                    // the infantry into the heli so the boarding is visible.
                                    // Safe to do: the paradrop watchdog already ejects any
                                    // physically-seated units via moveOut before placing them
                                    // in parachutes, so this does not affect the drop sequence.
                                    private _pdVehicleProfileID = _profiles select 1 select 2 select 4;
                                    private _pdInfantryIDs = if (count _infantryProfiles > _i) then {
                                        _infantryProfiles select _i
                                    } else { [] };

                                    if (count _pdInfantryIDs > 0) then {
                                        [_pickupLZPos, _pdVehicleProfileID, _pdInfantryIDs] spawn {
                                            private _lzPos      = _this select 0;
                                            private _vProfID    = _this select 1;
                                            private _infIDs     = _this select 2;

                                            // Wait up to 10s for the heli to activate near players
                                            private _waitT = 0;
                                            private _heliObj = objNull;
                                            waitUntil {
                                                sleep 1;
                                                _waitT = _waitT + 1;
                                                private _vp = [ALIVE_profileHandler, "getProfile", _vProfID] call ALIVE_fnc_profileHandler;
                                                if (!isNil "_vp" && { _vp select 2 select 1 }) then {
                                                    _heliObj = _vp select 2 select 10;
                                                };
                                                (!isNull _heliObj && alive _heliObj) || _waitT > 10
                                            };

                                            if (!isNull _heliObj && alive _heliObj) then {
                                                // Heli is physically spawned -- board any infantry
                                                // that are also active (spawned near players)
                                                {
                                                    private _infID = _x;
                                                    private _ip = [ALIVE_profileHandler, "getProfile", _infID] call ALIVE_fnc_profileHandler;
                                                    if (!isNil "_ip" && { _ip select 2 select 1 }) then {
                                                        private _infUnits = _ip select 2 select 21;
                                                        {
                                                            if (alive _x && vehicle _x == _x) then {
                                                                _x moveInCargo _heliObj;
                                                            };
                                                        } forEach _infUnits;
                                                    };
                                                } forEach _infIDs;
                                            };
                                        };
                                    };

                                    // NOTE: spawnHelicopterFuelWatchdog is intentionally NOT spawned
                                    // for HELI_PARADROP helis. Paradrop helis operate at PARADROP_HEIGHT
                                    // (500m) and are managed entirely by spawnHeliParadropWatchdog.
                                    // The fuel watchdog is designed for HELI_INSERT hover-lock scenarios
                                    // and incorrectly kills paradrop helis that slow momentarily during
                                    // banking or terrain-following at low AGL after their drop.

                                };

                            };

                            _eventTransportProfiles = _eventTransportProfiles + _transportProfiles;
                            _eventTransportVehiclesProfiles = _eventTransportVehiclesProfiles + _transportVehicleProfiles;
                        };

                        if(_eventType == "STANDARD") then {

                            // create ground transport vehicles for the profiles

                            _transportGroups = [ALIVE_factionDefaultTransport,_eventFaction,[]] call ALIVE_fnc_hashGet;
                            _transportProfiles = [];
                            _transportVehicleProfiles = [];

                            if(count _transportGroups == 0) then {
                                _transportGroups = [ALIVE_sideDefaultTransport,_side] call ALIVE_fnc_hashGet;
                            };

                            if(count _transportGroups > 0) then {
                                for "_i" from 0 to _groupCount -1 do {

                                    _position = _reinforcementPosition getPos [random(200), random(360)];

                                    if(_paraDrop) then {
                                        _position set [2,PARADROP_HEIGHT];
                                    };

                                    if(count _transportGroups > 0) then {

                                        _vehicleClass = selectRandom _transportGroups;

                                        _profiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,false,true] call ALIVE_fnc_createProfilesCrewedVehicle;

                                        _transportProfiles pushback (_profiles select 0 select 2 select 4);
                                        _transportVehicleProfiles pushback (_profiles select 1 select 2 select 4);

                                    };

                                };
                            };

                            _eventTransportProfiles = _eventTransportProfiles + _transportProfiles;
                            _eventTransportVehiclesProfiles = _eventTransportVehiclesProfiles + _transportVehicleProfiles;
                        };

                        // armour
                        private ["_armourGroups","_armourProfiles"];

                        _armourGroups = [];
                        _armourProfiles = [];

                        for "_i" from 0 to _eventForceArmour -1 do {
                            _group = ["Armored",_eventFaction] call ALIVE_fnc_configGetRandomGroup;
                            if!(_group == "FALSE") then {
                                _armourGroups pushback _group;
                            };
                        };

                        _armourGroups = _armourGroups - ALiVE_PLACEMENT_GROUPBLACKLIST;
                        _groupCount = count _armourGroups;
                        _totalCount = _totalCount + _groupCount;

                        // create profiles
                        for "_i" from 0 to _groupCount -1 do {

                            _group = _armourGroups select _i;

                            _position = _reinforcementPosition getPos [random(200), random(360)];

                            if(_paraDrop) then {
                                _position set [2,PARADROP_HEIGHT];
                            };

                            if!(surfaceIsWater _position) then {

                                _profiles = [_group, _position, random(360), false, _eventFaction, true] call ALIVE_fnc_createProfilesFromGroupConfig;

                                _profileIDs = [];
                                {
                                    _profileID = _x select 2 select 4;
                                    _profileIDs pushback _profileID;
                                } forEach _profiles;

                                _armourProfiles pushback _profileIDs;

                            } else {
                                _groupCount = _groupCount - 1;
                                _totalCount = _totalCount - 1;
                            };
                        };

                        [_eventCargoProfiles, "armour", _armourProfiles] call ALIVE_fnc_hashSet;


                        // mechanised

                        private ["_mechanisedGroups","_mechanisedProfiles"];

                        _mechanisedGroups = [];
                        _mechanisedProfiles = [];

                        for "_i" from 0 to _eventForceMechanised -1 do {
                            _group = ["Mechanized",_eventFaction] call ALIVE_fnc_configGetRandomGroup;
                            if!(_group == "FALSE") then {
                                _mechanisedGroups pushback _group;
                            }
                        };

                        _mechanisedGroups = _mechanisedGroups - ALiVE_PLACEMENT_GROUPBLACKLIST;
                        _groupCount = count _mechanisedGroups;
                        _totalCount = _totalCount + _groupCount;

                        // create profiles
                        for "_i" from 0 to _groupCount -1 do {

                            _group = _mechanisedGroups select _i;

                            _position = _reinforcementPosition getPos [random(200), random(360)];

                            if!(surfaceIsWater _position) then {

                                _profiles = [_group, _position, random(360), false, _eventFaction, true] call ALIVE_fnc_createProfilesFromGroupConfig;

                                _profileIDs = [];
                                {
                                    _profileID = _x select 2 select 4;
                                    _profileIDs pushback _profileID;
                                } forEach _profiles;

                                _mechanisedProfiles pushback _profileIDs;

                            } else {
                                _groupCount = _groupCount - 1;
                                _totalCount = _totalCount - 1;
                            };
                        };

                        [_eventCargoProfiles, "mechanised", _mechanisedProfiles] call ALIVE_fnc_hashSet;

                        // Slingload path for mechanised (mirrors motorised slingload path)
                        if (_eventType == "HELI_INSERT" && count _mechanisedProfiles > 0) then {

                            _transportGroups = [ALIVE_factionDefaultAirTransport,_eventFaction,[]] call ALIVE_fnc_hashGet;

                            // Match the same fallback logic used by the _slingAvailable check:
                            // only append side defaults when faction list is empty AND not faction-limited.
                            if (count _transportGroups == 0 && !_limitTransportToFaction) then {
                                _transportGroups append ([ALIVE_sideDefaultAirTransport,_side] call ALIVE_fnc_hashGet);
                            };

                            if (count _transportGroups > 0) then {

                                private _requiresStandardDelivery = false;

                                {
                                    _groupProfile = _x;
                                    {
                                        if ([_x,"vehicle"] call CBA_fnc_find != -1) then {
                                            _slingLoadProfile = [ALiVE_ProfileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                            _payloadWeight = [(_slingLoadProfile select 2 select 11)] call ALIVE_fnc_getObjectWeight;
                                            _vehicleClass = "";
                                            _currentDiff = 15000;
                                            {
                                                private _slingloadmax = [(configFile >> "CfgVehicles" >> _x >> "slingLoadMaxCargoMass")] call ALiVE_fnc_getConfigValue;
                                                if (!isNil "_slingloadmax") then {
                                                    _slingDiff = _slingloadmax - _payloadWeight;
                                                    if ((_slingDiff < _currentDiff) && (_slingDiff > 0)) then { _currentDiff = _slingDiff; _vehicleClass = _x; };
                                                };
                                            } forEach _transportGroups;
                                            if (_vehicleClass == "") exitWith { _requiresStandardDelivery = true; };
                                            [_slingLoadProfile, "vehicleClassSling", _vehicleClass] call ALiVE_fnc_hashSet;
                                        };
                                    } forEach _groupProfile;
                                } forEach _mechanisedProfiles;

                                // If a mechanised vehicle cannot be slingloaded, skip the
                                // mechanised slingload path only -- do NOT downgrade _eventType
                                // since motorised slingload helis may already have been created.
                                if (_requiresStandardDelivery) exitWith {
                                    if (!isNil "ALIVE_ML_TEST_REQUEST" && { ALIVE_ML_TEST_REQUEST == _eventID }) then {
                                        ["ML - TEST BYPASS: Mechanised slingload weight check FAILED -- no heli class can lift vehicle. _transportGroups=%1 faction=%2. Mechanised groups will travel by ground. Event: %3.",
                                            _transportGroups, _eventFaction, _eventID] call ALiVE_fnc_dump;
                                    } else {
                                        if (_debug) then {
                                            ["ML - Mechanised slingload: vehicle too heavy, mechanised groups will travel by ground. Event: %1", _eventID] call ALiVE_fnc_dump;
                                        };
                                    };
                                    // Do NOT set _eventType = "STANDARD" here
                                };

                                // Stagger mechanised slingload spawn positions exactly as motorised:
                                // each heli searches a progressively wider arc so the 150m tracker
                                // exclusion forces them into well-separated sectors.
                                private _mechSlingHeliSpawnIdx = 0;
                                {
                                    _groupProfile = _x;

                                    // Same as motorised: store entity ID for post-drop crew seating.
                                    private _mechEntityID  = _groupProfile select 0;
                                    {
                                        if ([_x,"vehicle"] call CBA_fnc_find != -1) then {
                                            // stored on profile below after slung hash set
                                        };
                                    } forEach _groupProfile;

                                    {
                                        if ([_x,"vehicle"] call CBA_fnc_find != -1) then {
                                            _slingLoadProfile = [ALiVE_ProfileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                            _vehicleClass = [_slingLoadProfile, "vehicleClassSling"] call ALiVE_fnc_hashGet;
                                            [_slingLoadProfile, "vehicleClassSling"] call ALiVE_fnc_hashRem;

                                            private _mechSpawnMin = 400 + (_mechSlingHeliSpawnIdx * 400);
                                            private _mechSpawnMax = _mechSpawnMin + 300;
                                            _position = [_logic, "findHelicopterLandingPos", [
                                                _reinforcementPosition, _mechSpawnMin, _mechSpawnMax
                                            ]] call MAINCLASS;
                                            // Spawn at ground level - same reason as motorised above.
                                            _position set [2, 0];
                                            _mechSlingHeliSpawnIdx = _mechSlingHeliSpawnIdx + 1;

                                            if (_debug) then {
                                                ["ML - HELI_INSERT mechanised slingload heli spawn pos (ground): %1 class: %2 (idx=%3 minR=%4 maxR=%5)", _position, _vehicleClass, _mechSlingHeliSpawnIdx - 1, _mechSpawnMin, _mechSpawnMax] call ALiVE_fnc_dump;
                                            };

                                            _profiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,true,true,[], [[_x], []]] call ALIVE_fnc_createProfilesCrewedVehicle;

                                            [_slingLoadProfile,"slung",[[_profiles select 1 select 2 select 4]]] call ALIVE_fnc_profileVehicle;

                                            _transportProfiles pushback (_profiles select 0 select 2 select 4);
                                            _transportVehicleProfiles pushback (_profiles select 1 select 2 select 4);

                                            _profileIDs = [];
                                            { _profileIDs pushback (_x select 2 select 4); } forEach _profiles;
                                            _payloadGroupProfiles pushback _profileIDs;

                                            // preventDespawn on pilot entity, heli vehicle, and slung vehicle.
                                            [_profiles select 0, "spawnType", ["preventDespawn"]] call ALIVE_fnc_hashSet;
                                            [_profiles select 1, "spawnType", ["preventDespawn"]] call ALIVE_fnc_profileVehicle;
                                            [_slingLoadProfile, "spawnType", ["preventDespawn"]] call ALIVE_fnc_profileVehicle;
                                            // Store pilot entity profile ID on the heli vehicle profile hash
                                            [_profiles select 1, "alive_ml_pilot_entity_id",
                                                (_profiles select 0) select 2 select 4] call ALIVE_fnc_hashSet;

                                            // Same fix as motorised: waypoint to _eventPosition not
                                            // _reinforcementPosition to prevent immediate profile despawn.
                                            _profileWaypoint = [_eventPosition, 200, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                            _profile = _profiles select 0;
                                            [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

                                            _totalCount = _totalCount + 1;

                                            [_logic, "spawnHelicopterFuelWatchdog", [
                                                _profiles select 0 select 2 select 4,
                                                _reinforcementPosition,
                                                _eventFaction
                                            ]] call MAINCLASS;
                                            if (_debug) then {
                                                ["ML - HELI_INSERT mechanised slingload watchdog started for %1", _profiles select 0 select 2 select 4] call ALiVE_fnc_dump;
                                            };
                                        };
                                    } forEach _groupProfile;
                                } forEach _mechanisedProfiles;

                            };
                        } else {
                            // _transportGroups empty after faction + side lookup.
                            // No air transport assets for mechanised slingload.
                            // Do NOT downgrade _eventType -- motorised slingload helis may already
                            // have been created. Only skip the mechanised slingload path.
                            ["ML - HELI_INSERT mechanised slingload: No air transport assets for faction=%1 side=%2 (limitToFaction=%3). Mechanised groups will not be slingloaded. Event: %4.",
                                _eventFaction, _side, _limitTransportToFaction, _eventID] call ALiVE_fnc_dump;
                        };

                        // plane

                        private ["_planeProfiles","_planeClasses","_motorisedProfiles","_vehicleClass"];

                        _planeProfiles = [];

                        if(_eventType == "STANDARD" || _eventType == "HELI_INSERT") then {

                            _planeClasses = [0,_eventFaction,"Plane"] call ALiVE_fnc_findVehicleType;
                            _planeClasses = _planeClasses - ALiVE_PLACEMENT_VEHICLEBLACKLIST;

                            for "_i" from 0 to _eventForcePlane -1 do {

                                _position = [_logic, "findHelicopterLandingPos", [
                                    _remotePosition, 50, 250
                                ]] call MAINCLASS;
                                _position set [2,1000];

                                if(count _planeClasses > 0) then {

                                    _vehicleClass = selectRandom _planeClasses;

                                    _profiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,true,true] call ALIVE_fnc_createProfilesCrewedVehicle;

                                    _profileIDs = [];
                                    {
                                        _profileID = _x select 2 select 4;
                                        _profileIDs pushback _profileID;
                                    } forEach _profiles;

                                    _planeProfiles pushback _profileIDs;

                                    private _heliDestPos = [_logic, "findHelicopterLandingPos", [
                                        _eventPosition, 200, 600
                                    ]] call MAINCLASS;
                                    _profileWaypoint = [_heliDestPos, 30, "MOVE", "LIMITED", 100, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                    _profile = _profiles select 0;
                                    [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

                                    if (_debug) then {
                                        ["ML - Dedicated heli [%1] class %2 dest: %3",
                                            _i + 1, _vehicleClass, _heliDestPos] call ALiVE_fnc_dump;
                                    };

                                    // Fuel watchdog for dedicated heli asset
                                    [_logic, "spawnHelicopterFuelWatchdog", [
                                        _profiles select 0 select 2 select 4,
                                        _reinforcementPosition,
                                        _eventFaction
                                    ]] call MAINCLASS;
                                }
                            };

                            _groupCount = count _planeProfiles;
                            _totalCount = _totalCount + _groupCount;

                        };

                        [_eventCargoProfiles, "plane", _planeProfiles] call ALIVE_fnc_hashSet;


                        // heli

                        private ["_heliProfiles","_heliClasses","_motorisedProfiles","_vehicleClass"];

                        _heliProfiles = [];

                        if(_eventType == "STANDARD" || _eventType == "HELI_INSERT") then {

                            _heliClasses = [0,_eventFaction,"Helicopter"] call ALiVE_fnc_findVehicleType;
                            _heliClasses = _heliClasses - ALiVE_PLACEMENT_VEHICLEBLACKLIST;

                            for "_i" from 0 to _eventForceHeli -1 do {

                                _position = _remotePosition getPos [random(200), random(360)];
                                _position set [2,1000];

                                if(count _heliClasses > 0) then {

                                    _vehicleClass = selectRandom _heliClasses;

                                    _profiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,true,true] call ALIVE_fnc_createProfilesCrewedVehicle;

                                    _profileIDs = [];
                                    {
                                        _profileID = _x select 2 select 4;
                                        _profileIDs pushback _profileID;
                                    } forEach _profiles;

                                    _heliProfiles pushback _profileIDs;

                                    _profileWaypoint = [_reinforcementPosition, 100, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                    _profile = _profiles select 0;
                                    [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                                }
                            };

                            _groupCount = count _heliProfiles;
                            _totalCount = _totalCount + _groupCount;

                        };

                        [_eventCargoProfiles, "heli", _heliProfiles] call ALIVE_fnc_hashSet;


                        // DEBUG -------------------------------------------------------------------------------------
                        if(_debug) then {
                            ["ML - Profiles created total: %1", _totalCount] call ALiVE_fnc_dump;
                            ["ML - Profile breakdown - Infantry groups: %1 Motorised groups: %2 Mechanised groups: %3 Armour groups: %4 Plane groups: %5 Heli groups: %6",
                                count _infantryProfiles,
                                count _motorisedProfiles,
                                count _mechanisedProfiles,
                                count _armourProfiles,
                                count _planeProfiles,
                                count _heliProfiles] call ALiVE_fnc_dump;
                            ["ML - Transport profiles: %1 Transport vehicle profiles: %2",
                                count _eventTransportProfiles,
                                count _eventTransportVehiclesProfiles] call ALiVE_fnc_dump;
                            ["ML - Force pool before deduction: %1 After deduction: %2",
                                _forcePool, (_forcePool - _totalCount)] call ALiVE_fnc_dump;
                            switch(_eventType) do {
                                case "STANDARD": {
                                    [_logic, "createMarker", [_reinforcementPosition,_eventFaction,"ML INSERTION"]] call MAINCLASS;
                                    [_logic, "createMarker", [_eventPosition,_eventFaction,"ML DESTINATION"]] call MAINCLASS;
                                };
                                case "HELI_INSERT": {
                                    [_logic, "createMarker", [_reinforcementPosition,_eventFaction,"ML BASE"]] call MAINCLASS;
                                    [_logic, "createMarker", [_remotePosition,_eventFaction,"ML HELI SPAWN"]] call MAINCLASS;
                                    [_logic, "createMarker", [_eventPosition,_eventFaction,"ML DESTINATION"]] call MAINCLASS;
                                };
                                case "HELI_PARADROP": {
                                    [_logic, "createMarker", [_reinforcementPosition,_eventFaction,"ML BASE"]] call MAINCLASS;
                                    [_logic, "createMarker", [_remotePosition,_eventFaction,"ML PARADROP SPAWN"]] call MAINCLASS;
                                    [_logic, "createMarker", [_eventPosition,_eventFaction,"ML DROP ZONE"]] call MAINCLASS;
                                };
                                case "AIRDROP": {
                                    [_logic, "createMarker", [_eventPosition,_eventFaction,"ML AIRDROP"]] call MAINCLASS;
                                };
                            };
                        };
                        // DEBUG -------------------------------------------------------------------------------------


                        if(_totalCount > 0) then {

                            // Mark cargo profiles as busy=true so ALiVE's profile
                            // activation system does not spawn them prematurely.
                            //
                            // EXCEPTION: infantry profiles that are assigned to a transport
                            // vehicle (HELI_INSERT cargo) must NOT be busy=true. ALiVE's
                            // virtual profile movement derives their position from the vehicle
                            // they are assigned to via vehiclesInCargoOf. With busy=true the
                            // profile system skips them entirely and they stay at their
                            // creation position while the heli flies to the destination.
                            //
                            // Infantry profiles:  [[profileID], [profileID], ...]
                            // Vehicle profiles:   [[entityID, vehicleID, ...], ...]
                            // Both structures iterated fully to mark every profile ID.
                            private _allCargoProfileIDsForBusy = [];
                            {
                                { _allCargoProfileIDsForBusy pushBackUnique _x; } forEach _x;
                            } forEach _infantryProfiles;
                            { { _allCargoProfileIDsForBusy pushBackUnique _x; } forEach _x; } forEach _motorisedProfiles;
                            { { _allCargoProfileIDsForBusy pushBackUnique _x; } forEach _x; } forEach _mechanisedProfiles;
                            { { _allCargoProfileIDsForBusy pushBackUnique _x; } forEach _x; } forEach _armourProfiles;
                            { { _allCargoProfileIDsForBusy pushBackUnique _x; } forEach _x; } forEach _planeProfiles;
                            { { _allCargoProfileIDsForBusy pushBackUnique _x; } forEach _x; } forEach _heliProfiles;
                            {
                                private _p = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                if (!isNil "_p") then {
                                    // Skip busy=true for profiles that are cargo of a transport
                                    // vehicle (infantry assigned to helis). These must remain
                                    // free so ALiVE updates their position from the vehicle.
                                    // Use vehiclesInCargoOf (profile index 9) -- this is only
                                    // populated for entities RIDING IN a vehicle, not for
                                    // vehicle profiles that have crew assigned to them.
                                    private _cargoOf = _p select 2 select 9;
                                    private _hasAssignment = (!isNil "_cargoOf") && { count _cargoOf > 0 };
                                    if (_hasAssignment) then {
                                        if (_debug) then {
                                            ["ML - PROFILE CREATED [riding - not busy] id=%1 event=%2", _x, _eventID] call ALiVE_fnc_dump;
                                        };
                                    } else {
                                        [_p, "busy", true] call ALIVE_fnc_hashSet;
                                        if (_debug) then {
                                            private _pPos  = _p select 2 select 2;
                                            private _pName = if (count _pPos > 0) then { [_pPos] call ALIVE_fnc_taskGetNearestLocationName } else { "unknown" };
                                            ["ML - PROFILE CREATED [busy] id=%1 near=%2 at=%3 event=%4",
                                                _x, _pName, _pPos, _eventID] call ALiVE_fnc_dump;
                                        };
                                    };
                                };
                            } forEach _allCargoProfileIDsForBusy;

                            // -----------------------------------------------------------------
                            // FIX: Reconcile pool reservation made at request receipt.
                            // Refund the reservation and deduct the true spawned count.
                            // This prevents double-deduction.
                            // -----------------------------------------------------------------
                            private _reservation = [_event, "poolReservation", 0] call ALIVE_fnc_hashGet;
                            _forcePool = _forcePool + _reservation;
                            _forcePool = _forcePool - _totalCount;

                            if(_debug) then {
                                ["ML - monitorEvent: Pool reconciliation. Reservation refunded: %1 True count deducted: %2 Remaining pool: %3",
                                    _reservation, _totalCount, _forcePool] call ALiVE_fnc_dump;
                            };

                            [ALIVE_MLGlobalRegistry,"updateGlobalForcePool",[_registryID,_forcePool]] call ALIVE_fnc_MLGlobalRegistry;

                            // Dispatch summary -- always logged (not gated on _debug) so
                            // it's visible in production logs for tracking the logistics chain.
                            {
                                private _evType   = _x select 0;
                                private _depPos   = _x select 1;
                                private _dstPos   = _x select 2;
                                private _depName  = [_depPos] call ALIVE_fnc_taskGetNearestLocationName;
                                private _dstName  = [_dstPos] call ALIVE_fnc_taskGetNearestLocationName;
                                ["ML - DISPATCH [%1] event=%2 faction=%3 from=%4 at %5 to=%6 at %7 units=%8",
                                    _evType, _eventID, _eventFaction,
                                    _depName, _depPos, _dstName, _dstPos,
                                    _totalCount] call ALiVE_fnc_dump;
                            } forEach [[_eventType, _reinforcementPosition, _eventPosition]];

                            // TEST BYPASS: clear only if this event owns the flag.
                            if (!isNil "ALIVE_ML_TEST_REQUEST" && { ALIVE_ML_TEST_REQUEST == _eventID }) then {
                                ALIVE_ML_TEST_REQUEST = "";
                                ["ML - TEST BYPASS: ALIVE_ML_TEST_REQUEST cleared after dispatch of event %1.", _eventID] call ALiVE_fnc_dump;
                            };

                            switch(_eventType) do {
                                case "STANDARD": {

                                    // update the state of the event
                                    // next state is transport load
                                    [_event, "state", "transportLoad"] call ALIVE_fnc_hashSet;

                                    // dispatch event
                                    _logEvent = ['LOGISTICS_INSERTION', [_reinforcementPosition,_eventFaction,_side,_eventID],"Logistics"] call ALIVE_fnc_event;
                                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                                };
                                case "HELI_INSERT": {

                                    // update the state of the event
                                    // next state is transport load
                                    [_event, "state", "heliTransportStart"] call ALIVE_fnc_hashSet;

                                    // dispatch event
                                    _logEvent = ['LOGISTICS_INSERTION', [_reinforcementPosition,_eventFaction,_side,_eventID],"Logistics"] call ALIVE_fnc_event;
                                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                                };
                                case "HELI_PARADROP": {

                                    [_event, "state", "heliParadropStart"] call ALIVE_fnc_hashSet;

                                    _logEvent = ['LOGISTICS_INSERTION', [_reinforcementPosition,_eventFaction,_side,_eventID],"Logistics"] call ALIVE_fnc_event;
                                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                                };
                                case "AIRDROP": {

                                    // update the state of the event
                                    // next state is aridrop wait
                                    [_event, "state", "airdropWait"] call ALIVE_fnc_hashSet;

                                    // dispatch event
                                    _logEvent = ['LOGISTICS_DESTINATION', [_eventPosition,_eventFaction,_side,_eventID],"Logistics"] call ALIVE_fnc_event;
                                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                                };
                            };

                            [_event, "cargoProfiles", _eventCargoProfiles] call ALIVE_fnc_hashSet;
                            [_event, "transportProfiles", _eventTransportProfiles] call ALIVE_fnc_hashSet;
                            [_event, "transportVehiclesProfiles", _eventTransportVehiclesProfiles] call ALIVE_fnc_hashSet;

                            [_logic, "prepareUnitCounts", _event] call MAINCLASS;

                            [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                        }else{

                            // no profiles were created
                            // nothing to do so cancel...

                            if(_debug) then {
                                ["ML - No reinforcements have been created! Cancelling event: %1", _eventID] call ALiVE_fnc_dump;
                            };

                            [_logic, "removeEvent", _eventID] call MAINCLASS;
                        };
                    };
                        }; // end if (!_heliThrottleExceeded)
                        }; // end if (_eventStillActive && !_waitingForHeli)
                }else{
                    // no insertion point available
                    // nothing to do so cancel...

                    if(_debug) then {
                        ["ML - No insertion point available! Cancelling event: %1", _eventID] call ALiVE_fnc_dump;
                    };

                    [_logic, "removeEvent", _eventID] call MAINCLASS;

                };
            };

            // HELI INSERT ------------------------------------------------------------------------------------------------------------------------------

            case "heliTransportStart": {

                // assign waypoints to all
                // vehicle commanders

                private ["_transportProfiles","_infantryProfiles","_planeProfiles","_heliProfiles","_position","_profileWaypoint","_profile","_count","_slingLoadProfiles"];

                _transportProfiles = _eventTransportProfiles;
                _infantryProfiles = [_eventCargoProfiles, 'infantry'] call ALIVE_fnc_hashGet;
                _planeProfiles = [_eventCargoProfiles, 'plane'] call ALIVE_fnc_hashGet;
                _heliProfiles = [_eventCargoProfiles, 'heli'] call ALIVE_fnc_hashGet;

                _count = [_logic, "checkEvent", _event] call MAINCLASS;
                if(_count == 0) exitWith {
                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                // Throttle: count all HELI_INSERT events in any active transport state
                private _activeHeliCount = 0;
                {
                    private _qState = [_x, "state"] call ALIVE_fnc_hashGet;
                    private _qID    = [_x, "id"]    call ALIVE_fnc_hashGet;
                    private _qData  = [_x, "data"]  call ALIVE_fnc_hashGet;
                    private _qType  = if (count _qData > 4) then { _qData select 4 } else { "" };
                    if (_qID != _eventID && _qType in ["HELI_INSERT","HELI_PARADROP"]) then {
                        if (_qState in [
                            "transportLoad","transportLoadWait","transportStart","transportTravel",
                            "heliTransport","heliTransportUnloadWait","heliTransportComplete",
                            "heliTransportReturn","heliTransportReturnWait",
                            "heliParadropStart","heliParadropFly","heliParadropReturn","heliParadropReturnWait"
                        ]) then {
                            _activeHeliCount = _activeHeliCount + 1;
                        };
                    };
                } forEach (_eventQueue select 2);

                if (_activeHeliCount >= 2 && { isNil "ALIVE_ML_TEST_REQUEST" || { ALIVE_ML_TEST_REQUEST != _eventID } }) exitWith {
                    // Stay in heliTransportStart - will retry next monitor cycle
                    if (_debug) then {
                        ["ML - heliTransportStart: Throttle - %1 events in flight, deferring event %2.",
                            _activeHeliCount, _eventID] call ALiVE_fnc_dump;
                    };
                };

                [_event, "finalDestination", _eventPosition getPos [random(DESTINATION_VARIANCE), random(360)]] call ALIVE_fnc_hashSet;

                // Track assigned landing positions to prevent helis landing on top of each other
                private _usedLandingPositions = [];

                {
                    private _destPos = [_logic, "findHelicopterLandingPos", [
                        _eventPosition, 200, 600, _usedLandingPositions
                    ]] call MAINCLASS;
                    _usedLandingPositions pushback _destPos;
                    _profileWaypoint = [_destPos, 200, "MOVE", "NORMAL", 100, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;

                    _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        // FIX: Clear any residual waypoints from profile-creation time (e.g. the
                        // loiter WP assigned when the transport was built). A stale pickup-LZ
                        // loiter WP would be completed immediately on spawn since the heli starts
                        // at that position, then the profile system would treat the event as done
                        // and trigger RTB before troops were unloaded at the drop-off.
                        // clearWaypoints ensures heliTransportStart is the sole authority on
                        // the heli's routing.
                        [_profile, "clearWaypoints"] call ALIVE_fnc_profileEntity;
                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                        if (_debug) then {
                            ["ML - heliTransportStart: Transport profile %1 waypoint -> %2", _x, _destPos] call ALiVE_fnc_dump;
                        };

                        // Spawn delivery watchdog for this transport heli
                        private _vProfID = "";
                        private _tIdx = _transportProfiles find _x;
                        if (_tIdx >= 0 && _tIdx < count _eventTransportVehiclesProfiles) then {
                            _vProfID = _eventTransportVehiclesProfiles select _tIdx;
                        };
                        if (_vProfID != "") then {
                            private _returnPos = [_reinforcementPrimaryObjective, "center"] call ALIVE_fnc_hashGet;
                            [_logic, "spawnHeliDeliveryWatchdog", [
                                _x, _vProfID, _destPos, _returnPos, _debug
                            ]] call MAINCLASS;
                            if (_debug) then {
                                ["ML - heliTransportStart: Delivery watchdog started for transport %1 vehicle %2", _x, _vProfID] call ALiVE_fnc_dump;
                            };
                        };
                    } else {
                        ["ML - heliTransportStart: WARNING transport profile %1 nil, removing from event.", _x] call ALiVE_fnc_dump;
                        // Remove dead profile ID from transport lists to prevent downstream issues
                        private _tIdx = _transportProfiles find _x;
                        if (_tIdx >= 0) then {
                            _transportProfiles deleteAt _tIdx;
                            if (_tIdx < count _eventTransportVehiclesProfiles) then {
                                _eventTransportVehiclesProfiles deleteAt _tIdx;
                            };
                        };
                        [_event, "transportProfiles", _transportProfiles] call ALIVE_fnc_hashSet;
                        [_event, "transportVehiclesProfiles", _eventTransportVehiclesProfiles] call ALIVE_fnc_hashSet;
                    };

                } forEach _transportProfiles;

                // FIX: Infantry profiles assigned to transport vehicles must NOT receive
                // independent move waypoints here. Their movement is governed by the vehicle
                // profile they are cargo of. An independent waypoint competes with the vehicle
                // assignment, can cause the profile system to treat infantry as "arrived" and
                // strip the vehicle assignment mid-flight, and may activate them at the wrong
                // position during transit. OPCOM/garrison handles infantry routing after delivery
                // via setEventProfilesAvailable.

                {
                    private _destPos = [_logic, "findHelicopterLandingPos", [
                        _eventPosition, 200, 600
                    ]] call MAINCLASS;
                    _profileWaypoint = [_destPos, 200, "MOVE", "NORMAL", 100, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;

                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                        if (_debug) then {
                            ["ML - heliTransportStart: Plane profile %1 waypoint -> %2",
                                _x select 0, _destPos] call ALiVE_fnc_dump;
                        };
                    } else {
                        ["ML - heliTransportStart: WARNING plane profile %1 nil, waypoint not assigned",
                            _x select 0] call ALiVE_fnc_dump;
                    };

                } forEach _planeProfiles;

                {
                    private _destPos = [_logic, "findHelicopterLandingPos", [
                        _eventPosition, 200, 600
                    ]] call MAINCLASS;
                    _profileWaypoint = [_destPos, 200, "MOVE", "NORMAL", 100, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;

                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                        if (_debug) then {
                            ["ML - heliTransportStart: Heli profile %1 waypoint -> %2",
                                _x select 0, _destPos] call ALiVE_fnc_dump;
                        };
                    } else {
                        ["ML - heliTransportStart: WARNING heli profile %1 nil, waypoint not assigned",
                            _x select 0] call ALiVE_fnc_dump;
                    };

                } forEach _heliProfiles;


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    [_logic, "createMarker", [_eventPosition,_eventFaction,"ML DESTINATION"]] call MAINCLASS;
                };
                // DEBUG -------------------------------------------------------------------------------------


                // dispatch event
                _logEvent = ['LOGISTICS_DESTINATION', [_eventPosition,_eventFaction,_side,_eventID],"Logistics"] call ALIVE_fnc_event;
                [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                // respond to player request
                if(_playerRequested) then {
                    _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","REQUEST_ENROUTE"] call ALIVE_fnc_event;
                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                };


                [_event, "state", "heliTransport"] call ALIVE_fnc_hashSet;
                [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

            };

            case "heliTransport": {

                // waypoint complete check stage

                private ["_waitTotalIterations","_waitIterations","_waitDifference","_transportProfiles","_infantryProfiles","_completed",
                "_planeProfiles","_heliProfiles","_waypointsCompleted","_waypointsNotCompleted","_profile","_position","_distance","_count"];

                _count = [_logic, "checkEvent", _event] call MAINCLASS;
                if(_count == 0) exitWith {
                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                // mechanism for aborting this state
                // once set time limit has passed
                // if all units haven't reached objective
                _waitTotalIterations = 200;
                _waitIterations = _eventStateData param [0, 0]; if (isNil "_waitIterations" || typeName _waitIterations != "SCALAR") then { _waitIterations = 0; };

                // check waypoints
                // if all waypoints are complete
                // trigger end of logistics control

                _transportProfiles = _eventTransportProfiles;
                _infantryProfiles = [_eventCargoProfiles, 'infantry'] call ALIVE_fnc_hashGet;
                _planeProfiles = [_eventCargoProfiles, 'plane'] call ALIVE_fnc_hashGet;
                _heliProfiles = [_eventCargoProfiles, 'heli'] call ALIVE_fnc_hashGet;

                _waypointsCompleted = 0;
                _waypointsNotCompleted = 0;

                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;

                    if!(isNil "_profile") then {

                        _completed = [_logic,"checkWaypointCompleted",_profile] call MAINCLASS;

                        if!(_completed) then {

                            [_logic,"setHelicopterTravel",_profile] call MAINCLASS;

                            // Position-based fallback: if active heli is within 500m of
                            // destination, treat waypoint as complete. Raised from 200m to
                            // account for LZs assigned by findHelicopterLandingPos that may
                            // be offset from the event centre.
                            private _heliActive = _profile select 2 select 1;
                            if (_heliActive) then {
                                private _heliObj = _profile select 2 select 10;
                                if (!isNull _heliObj && alive _heliObj) then {
                                    if (_heliObj distance _eventPosition < 500) then {
                                        _completed = true;
                                    };

                                    // Stuck-heli recovery: if the heli has not reached the
                                    // destination after many iterations, reassign its waypoint
                                    // directly to the event position every 30 iterations.
                                    // forceHelicopterLanding is ineffective when the AI cannot
                                    // path to its per-heli LZ -- a direct waypoint breaks deadlock.
                                    if (!_completed && _waitIterations > 20 && (_waitIterations - 20) % 30 == 0) then {
                                        private _newWP = [_eventPosition, 200, "MOVE", "NORMAL", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                        [_profile, "clearWaypoints"] call ALIVE_fnc_profileEntity;
                                        [_profile, "addWaypoint", _newWP] call ALIVE_fnc_profileEntity;
                                        ["ML - heliTransport: %1 stuck at iteration %2, reassigning waypoint to event position %3",
                                            _x, _waitIterations, _eventPosition] call ALiVE_fnc_dump;
                                    };
                                };
                            };

                            // Slingload watchdog signal: when the watchdog reaches the
                            // destination it sets alive_ml_sling_ready on the entity profile hash.
                            // Checked OUTSIDE the _heliActive guard so it fires even when no
                            // players are near enough to keep the heli spawned. The heli is
                            // physically present anyway (preventDespawn), so unloadTransportHelicopter
                            // must run regardless of player proximity.
                            private _slingReady = [_profile, "alive_ml_sling_ready", false] call ALIVE_fnc_hashGet;
                            if (!_completed && _slingReady) then {
                                private _heliObjSR = _profile select 2 select 10;
                                private _alreadyActive = if (!isNull _heliObjSR) then {
                                    _heliObjSR getVariable ["alive_ml_sling_unload_active", false]
                                } else { false };
                                if (!_alreadyActive) then {
                                    _completed = true;
                                    // Clear the flag immediately to prevent duplicate calls on
                                    // subsequent monitor loop cycles before the profile is destroyed.
                                    [_profile, "alive_ml_sling_ready", false] call ALIVE_fnc_hashSet;
                                    ["ML - heliTransport: %1 sling_ready signal received (no-player path), triggering unload. _heliActive=%2 heliObjNull=%3",
                                        _x, (_profile select 2 select 1), isNull _heliObjSR] call ALiVE_fnc_dump;
                                };
                            };

                        };

                        if (_completed) then {
                            _waypointsCompleted = _waypointsCompleted + 1;
                            [_logic,"unloadTransportHelicopter",[_event,_profile]] call MAINCLASS;
                        } else {
                            _waypointsNotCompleted = _waypointsNotCompleted + 1;
                        };

                    };

                } forEach _transportProfiles;

                // if some waypoints are completed
                // can assume most units are close to
                // destination, adjust timeout
                if(_waypointsCompleted > 0) then {
                    _waitDifference = _waitTotalIterations - _waitIterations;
                    if(_waitDifference > 30) then {
                        _waitIterations = _waitTotalIterations - 10;
                    };
                };

                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {

                        _completed = [_logic,"checkWaypointCompleted",_profile] call MAINCLASS;

                        if!(_completed) then {
                            _waypointsNotCompleted = _waypointsNotCompleted + 1;
                        }else{
                            _waypointsCompleted = _waypointsCompleted + 1;
                        };

                    };

                } forEach _planeProfiles;

                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {

                        _completed = [_logic,"checkWaypointCompleted",_profile] call MAINCLASS;

                        if!(_completed) then {

                            [_logic,"setHelicopterTravel",_profile] call MAINCLASS;

                            // If this transport has been hovering a long time without
                            // completing its waypoint, force it to land
                            if (_waitIterations > 20) then {
                                [_logic, "forceHelicopterLanding", [_profile, _eventPosition]] call MAINCLASS;

                                if (_debug) then {
                                    ["ML - heliTransport: Transport profile %1 hover intervention after %2 iterations",
                                        _x, _waitIterations] call ALiVE_fnc_dump;
                                };
                            };

                            // Position-based fallback: if heli is within 500m of destination,
                            // treat waypoint as complete. Checked outside _heliActive so a
                            // preventDespawn heli that has physically arrived but has no players
                            // nearby still triggers unload and clears the destination.
                            private _heliActive = _profile select 2 select 1;
                            private _heliObj = _profile select 2 select 10;
                            if (!isNull _heliObj && alive _heliObj) then {
                                if (_heliObj distance _eventPosition < 500) then {
                                    _completed = true;
                                };
                                if (_heliActive && !_completed && _waitIterations > 20 && (_waitIterations - 20) % 30 == 0) then {
                                    private _newWP = [_eventPosition, 200, "MOVE", "NORMAL", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                    [_profile, "clearWaypoints"] call ALIVE_fnc_profileEntity;
                                    [_profile, "addWaypoint", _newWP] call ALIVE_fnc_profileEntity;
                                    ["ML - heliTransport: %1 stuck at iteration %2, reassigning waypoint to event position %3",
                                        _x, _waitIterations, _eventPosition] call ALiVE_fnc_dump;
                                };
                            };

                        };

                        // Slingload watchdog signal for dedicated heli reinforcements.
                        // Same no-player path as _transportProfiles loop above.
                        private _slingReadyH = [_profile, "alive_ml_sling_ready", false] call ALIVE_fnc_hashGet;
                        if (!_completed && _slingReadyH) then {
                            private _heliObjSRH = _profile select 2 select 10;
                            private _alreadyActiveH = if (!isNull _heliObjSRH) then {
                                _heliObjSRH getVariable ["alive_ml_sling_unload_active", false]
                            } else { false };
                            if (!_alreadyActiveH) then {
                                _completed = true;
                                [_profile, "alive_ml_sling_ready", false] call ALIVE_fnc_hashSet;
                                ["ML - heliTransport: %1 sling_ready signal (heliProfiles no-player path), triggering unload. _heliActive=%2 heliObjNull=%3",
                                    _x, (_profile select 2 select 1), isNull _heliObjSRH] call ALiVE_fnc_dump;
                            };
                        };

                        if (_completed) then {
                            _waypointsCompleted = _waypointsCompleted + 1;
                            [_logic,"unloadTransportHelicopter",[_event,_profile]] call MAINCLASS;
                        } else {
                            _waypointsNotCompleted = _waypointsNotCompleted + 1;
                        };

                    };

                } forEach _heliProfiles;


                // all waypoints completed

                if(_waypointsNotCompleted == 0) then {

                    if(_waypointsCompleted > 0) then {
                        [_event, "state", "heliTransportUnloadWait"] call ALIVE_fnc_hashSet;
                        [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                    }else{
                        // set state to event complete
                        [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                        [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                    };

                    // respond to player request
                    if(_playerRequested) then {
                        if(_waypointsCompleted > 0) then {
                            _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","REQUEST_ARRIVED"] call ALIVE_fnc_event;
                            [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                        }else{
                            _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","REQUEST_LOST"] call ALIVE_fnc_event;
                            [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                        };
                    };

                }else{

                    // not all waypoints have been completed
                    // to ensure control passes to OPCOM eventually
                    // limited number of iterations in this
                    // state are used.

                    _waitIterations = _waitIterations + 1;
                    _eventStateData set [0, _waitIterations];
                    [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                    if(_waitIterations > _waitTotalIterations) then {

                        _eventStateData set [0, 0];
                        [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                        //["TRANSPORT TRAVEL WAIT - ITERATIONS COMPLETE"] call ALIVE_fnc_dump;
                        [_event, "state", "heliTransportUnloadWait"] call ALIVE_fnc_hashSet;
                        [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                    };
                };

            };

            case "heliTransportReturn": {

                private _count = [_logic, "checkEvent", _event] call MAINCLASS;
                if(_count == 0 && count _eventTransportProfiles == 0) exitWith {
                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                if(count _eventTransportProfiles > 0) then {

                    // send transport vehicles back to insertion point and beyond 1500m to ensure it
                    // egress in opposite direction of ingress to avoid AI fun time

                    private _eventDestination = [_event, "finalDestination"] call ALIVE_fnc_hashGet;
                    private _reinforcementPosition = [_reinforcementPrimaryObjective,"center"] call ALIVE_fnc_hashGet;
                    // Guard against empty finalDestination
                    private _returnDest = if (count _eventDestination > 1) then {
                        // Bearing FROM destination TOWARD reinforcement position = egress direction
                        private _egressDir = _eventDestination getDir _reinforcementPosition;
                        _reinforcementPosition getPos [1500, _egressDir]
                    } else {
                        _reinforcementPosition getPos [1500, random 360]
                    };

                    // #TODO: Change this so each helicopter peels off in the direction of it's offset from the eventDestination position
                    {
                        private _transportProfile = [ALIVE_profileHandler,"getProfile", _x] call ALiVE_fnc_profileHandler;
                        if!(isNil "_transportProfile") then {
                            // FIX 3: Use live vehicle position when active - the stored profile
                            // position (select 2 select 2) may be the spawn origin if the profile
                            // system hasn't updated it yet, making the egress bearing incorrect.
                            private _liveVehicle = _transportProfile select 2 select 10;
                            private _transportProfilePos = if (!isNull _liveVehicle && alive _liveVehicle) then {
                                getPos _liveVehicle
                            } else {
                                _transportProfile select 2 select 2
                            };

                            // FIX 6: Egress direction should be TOWARD the reinforcement base,
                            // not away from it. The previous - 180 sent helis on an initial leg
                            // deeper into contested territory before reversing toward base.
                            // Remove the - 180 so the straight leg heads directly homeward.
                            private _leaveDir = _transportProfilePos getDir _reinforcementPosition;
                            private _turnDirOffset = if (random 1 > 0.5) then { 50 } else { -50 };
                            private _leaveDist = 300 + (random 200);

                            private _leavePosStraight = _transportProfilePos getpos [_leaveDist, _leaveDir];
                            private _leavePosTurn = _transportProfilePos getpos [_leaveDist * 1.5, [_leaveDir + _turnDirOffset] call ALiVE_fnc_modDegrees];

                            private _leaveWPStraight = [_leavePosStraight, 100, "MOVE", "FULL", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                            private _leaveWPTurn = [_leavePosTurn, 100, "MOVE", "FULL", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                            private _leaveWPFinal = [_returnDest, 100, "MOVE", "FULL", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;

                            [_transportProfile, "clearWaypoints"] call ALIVE_fnc_profileEntity;
                            [_transportProfile, "addWaypoint", _leaveWPStraight] call ALIVE_fnc_profileEntity;
                            [_transportProfile, "addWaypoint", _leaveWPTurn] call ALIVE_fnc_profileEntity;
                            [_transportProfile, "addWaypoint", _leaveWPFinal] call ALIVE_fnc_profileEntity;

                            // Signal the slingload spawn thread (if still running) that RTB
                            // waypoints have been issued - it must not clear them.
                            private _rtbVehicleObj = _transportProfile select 2 select 10;
                            if (!isNull _rtbVehicleObj) then {
                                _rtbVehicleObj setVariable ["alive_ml_rtb_issued", true];
                            };
                        };
                    } forEach _eventTransportProfiles;

                    // set state to wait for return of transports
                    // Reset stateData counter so heliTransportReturnWait starts at 0
                    _eventStateData set [0, 0];
                    [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;
                    [_event, "state", "heliTransportReturnWait"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                }else{

                    // no transport vehicles
                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                };

            };

            // AIR DROP ------------------------------------------------------------------------------------------------------------------------------

            case "airdropWait": {

                private ["_waitIterations","_waitTotalIterations"];

                _waitTotalIterations = 15;
                _waitIterations = _eventStateData param [0, 0]; if (isNil "_waitIterations" || typeName _waitIterations != "SCALAR") then { _waitIterations = 0; };

                _waitIterations = _waitIterations + 1;
                _eventStateData set [0, _waitIterations];
                [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                if(_waitIterations > _waitTotalIterations) then {

                    _eventStateData set [0, 0];
                    [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                };

            };

            // PR_AIRDROP proper state machine -------------------------------------------------------
            // Full transport aircraft delivery pipeline that mirrors heliParadropStart -> Fly ->
            // Return -> ReturnWait. Replaces the airdropWait timeout stub for player-requested
            // airdrops. Legacy AI AIRDROP continues to use airdropWait above.

            case "airdropStart": {

                private _count = [_logic, "checkEvent", _event] call MAINCLASS;
                if (_count == 0) exitWith {
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                // Launch the paradrop watchdog for the infantry transport only.
                // Slingload helis don't need it -- they just fly the waypoint and release
                // automatically via ALiVE's profile system (attach state on slung profile).
                // Bug 4 fix: use stored airdropInfTransportProfID, not forEach loop.
                private _infProfID = [_event, "airdropInfTransportProfID"] call ALIVE_fnc_hashGet;
                if (!isNil "_infProfID" && { _infProfID isEqualType "" } && { _infProfID != "" }) then {
                    private _infProfile = [ALIVE_profileHandler, "getProfile", _infProfID] call ALIVE_fnc_profileHandler;
                    if (!isNil "_infProfile") then {
                        // Flatten infantry group IDs into a single list for the watchdog
                        private _infantryProfilesHash = [_eventCargoProfiles, 'infantry'] call ALIVE_fnc_hashGet;
                        private _infantryIDs = [];
                        { _infantryIDs append _x; } forEach _infantryProfilesHash;

                        // Find the vehicle profile ID paired with this pilot entity
                        private _vProfID = "";
                        private _idx = _eventTransportProfiles find _infProfID;
                        if (_idx >= 0 && _idx < count _eventTransportVehiclesProfiles) then {
                            _vProfID = _eventTransportVehiclesProfiles select _idx;
                        };

                        private _departurePos = [_event, "departurePosition"] call ALIVE_fnc_hashGet;
                        private _finalDest    = [_event, "finalDestination"] call ALIVE_fnc_hashGet;

                        [_logic, "spawnHeliParadropWatchdog", [
                            _infProfID, _vProfID, _finalDest, _departurePos, _infantryIDs, PARADROP_HEIGHT, _debug
                        ]] call MAINCLASS;

                        if (_debug) then {
                            ["ML - airdropStart: Watchdog launched for infantry transport %1 vehicle %2 dropping %3 units at %4",
                                _infProfID, _vProfID, count _infantryIDs, _finalDest] call ALiVE_fnc_dump;
                        };
                    };
                } else {
                    if (_debug) then {
                        ["ML - airdropStart: No infantry transport -- slingload-only delivery. Event: %1", _eventID] call ALiVE_fnc_dump;
                    };
                };

                [_event, "state", "airdropFly"] call ALIVE_fnc_hashSet;
                [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                if (_debug) then {
                    ["ML - airdropStart: %1 transports dispatched. Event: %2",
                        count _eventTransportProfiles, _eventID] call ALiVE_fnc_dump;
                };
            };

            case "airdropFly": {

                private _count = [_logic, "checkEvent", _event] call MAINCLASS;
                if (_count == 0) exitWith {
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                private _waitTotalIterations = 300;
                private _waitIterations = _eventStateData param [0, 0];
                if (isNil "_waitIterations" || typeName _waitIterations != "SCALAR") then { _waitIterations = 0; };

                // Bug 5 fix: only poll the infantry transport for paradropComplete.
                // Slingload helis never appear in that list -- they release their sling
                // load on arrival via ALiVE's profile system. For slingload-only events
                // advance immediately.
                private _infProfID = [_event, "airdropInfTransportProfID"] call ALIVE_fnc_hashGet;
                private _dropped = false;
                private _anyAlive = false;

                if (!isNil "_infProfID" && { _infProfID isEqualType "" } && { _infProfID != "" }) then {
                    private _tProfile = [ALIVE_profileHandler, "getProfile", _infProfID] call ALIVE_fnc_profileHandler;
                    if (!isNil "_tProfile") then {
                        _anyAlive = true;
                        _dropped = if (isNil "ALIVE_ML_paradropComplete") then { false } else {
                            _infProfID in ALIVE_ML_paradropComplete
                        };
                    };
                    if (_debug) then {
                        ["ML - airdropFly: infantry transport %1 profile=%2 dropped=%3", _infProfID, (!isNil "_tProfile"), _dropped] call ALiVE_fnc_dump;
                    };
                } else {
                    // No infantry transport -- slingload-only. Check if any slingload transports still active.
                    {
                        private _tp = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                        if (!isNil "_tp") then { _anyAlive = true; };
                    } forEach _eventTransportProfiles;
                    // Slingload-only: advance as soon as any were dispatched (release happens automatically on arrival)
                    _dropped = true;
                };

                if (_dropped || _waitIterations > _waitTotalIterations || (!_anyAlive && _waitIterations > 5)) then {
                    if (_debug) then {
                        ["ML - airdropFly: Drops complete. Moving to airdropReturn. Event: %1", _eventID] call ALiVE_fnc_dump;
                    };
                    _eventStateData set [0, 0];
                    [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;
                    [_event, "state", "airdropReturn"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                } else {
                    _waitIterations = _waitIterations + 1;
                    _eventStateData set [0, _waitIterations];
                    [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;
                    if (_debug) then {
                        ["ML - airdropFly: Waiting for drops. iter=%1/%2 Event: %3",
                            _waitIterations, _waitTotalIterations, _eventID] call ALiVE_fnc_dump;
                    };
                };
            };

            case "airdropReturn": {

                private _count = [_logic, "checkEvent", _event] call MAINCLASS;
                if (_count == 0 && count _eventTransportProfiles == 0) exitWith {
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                // 3-waypoint egress mirrors heliParadropReturn -- straight out, turn, RTB.
                // Profile waypoints use 2D positions -- explicit Z causes descent.
                private _departurePos = [_event, "departurePosition"] call ALIVE_fnc_hashGet;
                private _eventDestination = [_event, "finalDestination"] call ALIVE_fnc_hashGet;
                private _returnDest = if (count _eventDestination > 1 && count _departurePos > 1) then {
                    private _egressDir = _eventDestination getDir _departurePos;
                    _departurePos getPos [1500, _egressDir]
                } else {
                    _departurePos getPos [1500, random 360]
                };

                {
                    private _tProfile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                    if (!isNil "_tProfile") then {
                        private _liveVehicle2 = _tProfile select 2 select 10;
                        private _tPos = if (!isNull _liveVehicle2 && alive _liveVehicle2) then {
                            getPos _liveVehicle2
                        } else {
                            _tProfile select 2 select 2
                        };

                        private _leaveDir = _tPos getDir _departurePos;
                        private _turnDirOffset = if (random 1 > 0.5) then { 50 } else { -50 };
                        private _leaveDist = 300 + (random 200);

                        private _leavePosStraight = _tPos getPos [_leaveDist, _leaveDir];
                        private _leavePosTurn     = _tPos getPos [_leaveDist * 1.5, [_leaveDir + _turnDirOffset] call ALiVE_fnc_modDegrees];

                        private _wpStraight = [_leavePosStraight, 100, "MOVE", "FULL", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                        private _wpTurn     = [_leavePosTurn,     100, "MOVE", "FULL",  300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                        private _wpFinal    = [_returnDest,       100, "MOVE", "FULL",  300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;

                        [_tProfile, "clearWaypoints"] call ALIVE_fnc_profileEntity;
                        [_tProfile, "addWaypoint", _wpStraight] call ALIVE_fnc_profileEntity;
                        [_tProfile, "addWaypoint", _wpTurn]     call ALIVE_fnc_profileEntity;
                        [_tProfile, "addWaypoint", _wpFinal]    call ALIVE_fnc_profileEntity;

                        if (_debug) then {
                            ["ML - airdropReturn: RTB issued to %1. exit->%2 turn->%3 base->%4", _x, _leavePosStraight, _leavePosTurn, _returnDest] call ALiVE_fnc_dump;
                        };
                    };
                } forEach _eventTransportProfiles;

                _eventStateData set [0, 0];
                [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;
                [_event, "state", "airdropReturnWait"] call ALIVE_fnc_hashSet;
                [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
            };

            case "airdropReturnWait": {

                private _count = [_logic, "checkEvent", _event] call MAINCLASS;
                if (_count == 0 && count _eventTransportProfiles == 0) exitWith {
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                if (count _eventTransportVehiclesProfiles > 0) then {
                    private _waitTotalIterations = 60;
                    private _waitIterations = _eventStateData param [0, 0];
                    if (isNil "_waitIterations" || typeName _waitIterations != "SCALAR") then { _waitIterations = 0; };

                    private _anyActive = 0;
                    private _anyAlive  = 0;
                    private _departurePos = [_event, "departurePosition"] call ALIVE_fnc_hashGet;

                    {
                        private _tProfile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                        if (!isNil "_tProfile") then {
                            private _active  = _tProfile select 2 select 1;
                            private _vehicle = _tProfile select 2 select 10;

                            private _farEnough = false;
                            if (count _departurePos > 1) then {
                                private _checkPos = if (!isNull _vehicle && alive _vehicle) then {
                                    getPos _vehicle
                                } else {
                                    _tProfile select 2 select 2
                                };
                                _farEnough = _checkPos distance2D _departurePos < 500;
                            };

                            if (_waitIterations > _waitTotalIterations || _farEnough) then {
                                if (!isNull _vehicle && alive _vehicle && _active) then {
                                    private _landPad = createVehicle ["Land_HelipadEmpty_F", getPosATL _vehicle, [], 0, "CAN_COLLIDE"];
                                    _vehicle landAt _landPad;
                                    [_vehicle, _landPad] spawn {
                                        private _h = _this select 0; private _p = _this select 1; private _t = 0;
                                        waitUntil { sleep 2; _t = _t + 2; isTouchingGround _h || !alive _h || _t > 30 };
                                        deleteVehicle _p;
                                        if (alive _h) then { _h setDamage 1; };
                                    };
                                };
                                _active = false;
                            };

                            if (_active) then {
                                if (!isNull _vehicle && alive _vehicle && canMove _vehicle) then {
                                    _anyAlive = _anyAlive + 1;
                                } else {
                                    private _inCommand = _tProfile select 2 select 8;
                                    if (count _inCommand > 0) then {
                                        private _cmdProf = [ALIVE_profileHandler, "getProfile", _inCommand select 0] call ALIVE_fnc_profileHandler;
                                        if (!isNil "_cmdProf") then { [_cmdProf, "destroy"] call ALIVE_fnc_profileEntity; };
                                    };
                                    [_tProfile, "vehicleAssignments", [] call ALIVE_fnc_hashCreate] call ALIVE_fnc_profileVehicle;
                                    [_tProfile, "destroy"] call ALIVE_fnc_profileVehicle;
                                };
                                _anyActive = _anyActive + 1;
                            } else {
                                private _inCommand = _tProfile select 2 select 8;
                                if (count _inCommand > 0) then {
                                    private _cmdProf = [ALIVE_profileHandler, "getProfile", _inCommand select 0] call ALIVE_fnc_profileHandler;
                                    if (!isNil "_cmdProf") then { [_cmdProf, "destroy"] call ALIVE_fnc_profileEntity; };
                                };
                                [_tProfile, "vehicleAssignments", [] call ALIVE_fnc_hashCreate] call ALIVE_fnc_profileVehicle;
                                [_tProfile, "destroy"] call ALIVE_fnc_profileVehicle;
                            };
                        };
                    } forEach _eventTransportVehiclesProfiles;

                    _waitIterations = _waitIterations + 1;
                    _eventStateData set [0, _waitIterations];
                    [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                    if (_anyActive == 0 || _anyAlive == 0 || _waitIterations > _waitTotalIterations) then {
                        ["ML - airdropReturnWait: RTB complete. Event: %1", _eventID] call ALiVE_fnc_dump;

                        // Send REQUEST_DELIVERED to the requesting player
                        if (_playerRequested) then {
                            private _logEvent2 = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","REQUEST_DELIVERED"] call ALIVE_fnc_event;
                            [ALIVE_eventLog, "addEvent", _logEvent2] call ALIVE_fnc_eventLog;
                            if (_debug) then {
                                ["ML - airdropReturnWait: REQUEST_DELIVERED sent to player %1 for request %2",
                                    _playerID, _requestID] call ALiVE_fnc_dump;
                            };
                        };

                        _eventStateData set [0, 0];
                        [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;
                        [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                        [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                    } else {
                        if (_debug) then {
                            ["ML - airdropReturnWait: Waiting RTB. anyActive=%1 anyAlive=%2 iter=%3/%4. Event: %5",
                                _anyActive, _anyAlive, _waitIterations, _waitTotalIterations, _eventID] call ALiVE_fnc_dump;
                        };
                    };
                } else {
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };
            };

            // END PR_AIRDROP state machine ----------------------------------------------------------

            // CONVOY ---------------------------------------------------------------------------------------------------------------------------------

            case "transportLoad": {

                // for any infantry groups order
                // them to load onto the transport vehicles

                private ["_infantryProfiles","_processedProfiles","_infantryProfile","_transportProfileID","_transportProfile"];

                _infantryProfiles = [_eventCargoProfiles, 'infantry'] call ALIVE_fnc_hashGet;
                _processedProfiles = 0;

                if(count _eventTransportVehiclesProfiles > 0) then {

                    if (_debug) then {
                        ["ML - transportLoad: Assigning %1 infantry groups to %2 transport vehicles. Event: %3",
                            count _infantryProfiles, count _eventTransportVehiclesProfiles, _eventID] call ALiVE_fnc_dump;
                    };

                    {
                        // Guard: more infantry groups than transport vehicles —
                        // the remaining groups travel on foot (no vehicle assignment).
                        if (_processedProfiles >= count _eventTransportVehiclesProfiles) exitWith {
                            if (_debug) then {
                                ["ML - transportLoad: No more transport vehicles available (%1 assigned, %2 groups remaining). Event: %3",
                                    _processedProfiles, count _infantryProfiles - _processedProfiles, _eventID] call ALiVE_fnc_dump;
                            };
                        };

                        _infantryProfile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                        if!(isNil "_infantryProfile") then {

                            _transportProfileID = _eventTransportVehiclesProfiles select _processedProfiles;
                            _transportProfile = [ALIVE_profileHandler, "getProfile", _transportProfileID] call ALIVE_fnc_profileHandler;
                            if!(isNil "_transportProfile") then {

                                [_infantryProfile,_transportProfile] call ALIVE_fnc_createProfileVehicleAssignment;

                                if (_debug) then {
                                    ["ML - transportLoad: Assigned infantry %1 to transport %2 (%3/%4)",
                                        _x select 0, _transportProfileID, _processedProfiles + 1, count _eventTransportVehiclesProfiles] call ALiVE_fnc_dump;
                                };

                                _processedProfiles = _processedProfiles + 1;
                            } else {
                                if (_debug) then {
                                    ["ML - transportLoad: WARNING transport profile %1 is nil, skipping.", _transportProfileID] call ALiVE_fnc_dump;
                                };
                            };
                        } else {
                            if (_debug) then {
                                ["ML - transportLoad: WARNING infantry profile %1 is nil, skipping.", _x select 0] call ALiVE_fnc_dump;
                            };
                        };

                    } forEach _infantryProfiles;

                    if (_debug) then {
                        ["ML - transportLoad: Complete. %1 assignments made. Event: %2",
                            _processedProfiles, _eventID] call ALiVE_fnc_dump;
                    };

                } else {
                    if (_debug) then {
                        ["ML - transportLoad: No transport vehicles available, infantry will travel on foot. Event: %1",
                            _eventID] call ALiVE_fnc_dump;
                    };
                };

                [_event, "state", "transportLoadWait"] call ALIVE_fnc_hashSet;
                [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

            };

            case "transportLoadWait": {

                private ["_infantryProfiles","_waitIterations","_waitTotalIterations","_loadedUnits","_notLoadedUnits",
                "_infantryProfile","_active","_units","_vehicle","_vehicleClass"];

                _infantryProfiles = [_eventCargoProfiles, 'infantry'] call ALIVE_fnc_hashGet;

                // mechanism for aborting this state
                // once set time limit has passed
                // if all units havent loaded up
                _waitTotalIterations = 35;
                _waitIterations = _eventStateData param [0, 0]; if (isNil "_waitIterations" || typeName _waitIterations != "SCALAR") then { _waitIterations = 0; };

                // if there are transport vehicles available

                if(count _eventTransportVehiclesProfiles > 0) then {

                    _loadedUnits = [];
                    _notLoadedUnits = [];

                    {
                        _infantryProfile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                        if!(isNil "_infantryProfile") then {
                            _active = _infantryProfile select 2 select 1;

                            // only need to worry about this is there are
                            // players nearby

                            if(_active) then {

                                _units = _infantryProfile select 2 select 21;

                                // catagorise units into loaded and not
                                // loaded arrays
                                {
                                    _vehicle = vehicle _x;
                                    _vehicleClass = typeOf _vehicle;
                                    if(_vehicleClass != "Steerable_Parachute_F") then {
                                        if(vehicle _x == _x) then {
                                            _notLoadedUnits pushback _x;
                                        }else{
                                            _loadedUnits pushback _x;
                                        };
                                    }else{
                                        _notLoadedUnits pushback _x;
                                    };

                                } forEach _units;

                            }else{

                                // profiles are not active, can skip this wait
                                // continue on to travel

                                [_event, "state", "transportStart"] call ALIVE_fnc_hashSet;
                                [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                            };

                        };

                    } forEach _infantryProfiles;

                    // if there are units left to be loaded
                    // wait for x iterations for loading to occur
                    // once time is up delete all not loaded units

                    if(count _notLoadedUnits > 0) then {

                        _waitIterations = _waitIterations + 1;
                        _eventStateData set [0, _waitIterations];
                        [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                        if(_waitIterations > _waitTotalIterations) then {

                            {
                                deleteVehicle _x;
                            } forEach _notLoadedUnits;

                            _eventStateData set [0, 0];
                            [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                            [_event, "state", "transportStart"] call ALIVE_fnc_hashSet;
                            [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                        };

                    }else{

                        // all units have loaded
                        // continue on to travel

                        [_event, "state", "transportStart"] call ALIVE_fnc_hashSet;
                        [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                    };


                }else{

                    // no transport vehicles available
                    // continue on to travel

                    [_event, "state", "transportStart"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

            };

            case "transportStart": {

                // assign waypoints to all
                // vehicle commanders

                private ["_transportProfiles","_infantryProfiles","_armourProfiles","_mechanisedProfiles","_motorisedProfiles",
                "_planeProfiles","_heliProfiles","_profileWaypoint","_profile","_position","_countProfiles","_positionSeries","_seriesIndex","_count"];

                _count = [_logic, "checkEvent", _event] call MAINCLASS;
                if(_count == 0) exitWith {
                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                _transportProfiles = _eventTransportProfiles;
                _infantryProfiles = [_eventCargoProfiles, 'infantry'] call ALIVE_fnc_hashGet;
                _armourProfiles = [_eventCargoProfiles, 'armour'] call ALIVE_fnc_hashGet;
                _mechanisedProfiles = [_eventCargoProfiles, 'mechanised'] call ALIVE_fnc_hashGet;
                _motorisedProfiles = [_eventCargoProfiles, 'motorised'] call ALIVE_fnc_hashGet;
                _planeProfiles = [_eventCargoProfiles, 'plane'] call ALIVE_fnc_hashGet;
                _heliProfiles = [_eventCargoProfiles, 'heli'] call ALIVE_fnc_hashGet;

                _countProfiles = (count(_transportProfiles)) + (count(_armourProfiles)) + (count(_mechanisedProfiles)) + (count(_motorisedProfiles));

                _position = [_eventPosition] call ALIVE_fnc_getClosestRoad;

                _positionSeries = [_position,300,_countProfiles,false] call ALIVE_fnc_getSeriesRoadPositions;

                if((count _positionSeries) < _countProfiles) then {
                    for "_i" from 0 to _countProfiles -1 do {
                        _position = _eventPosition getPos [random(DESTINATION_VARIANCE), random(360)];
                        _positionSeries set [_i, _position];
                    };
                };

                _seriesIndex = 0;

                [_event, "finalDestination", _positionSeries select 0] call ALIVE_fnc_hashSet;

                {

                    _position = _positionSeries select _seriesIndex;
                    _profileWaypoint = [_position, 1, "MOVE", "LIMITED", 2, [], "COLUMN"] call ALIVE_fnc_createProfileWaypoint;

                    _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                    };

                    _seriesIndex = _seriesIndex + 1;

                } forEach _transportProfiles;

                {
                    _position = _eventPosition getPos [random(DESTINATION_VARIANCE), random(360)];
                    _profileWaypoint = [_position, 1, "MOVE", "LIMITED", 2, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;

                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                    };

                } forEach _infantryProfiles;

                {
                    _position = _positionSeries select _seriesIndex;
                    _profileWaypoint = [_position, 1, "MOVE", "NORMAL", 2, [], "COLUMN"] call ALIVE_fnc_createProfileWaypoint;

                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                    };

                    _seriesIndex = _seriesIndex + 1;

                } forEach _armourProfiles;

                {
                    _position = _positionSeries select _seriesIndex;
                    _profileWaypoint = [_position, 1, "MOVE", "LIMITED", 2, [], "COLUMN"] call ALIVE_fnc_createProfileWaypoint;

                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                    };

                    _seriesIndex = _seriesIndex + 1;

                } forEach _mechanisedProfiles;

                {
                    _position = _positionSeries select _seriesIndex;
                    _profileWaypoint = [_position, 1, "MOVE", "LIMITED", 2, [], "COLUMN"] call ALIVE_fnc_createProfileWaypoint;

                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                    };

                    _seriesIndex = _seriesIndex + 1;

                } forEach _motorisedProfiles;

                {
                    _position = _eventPosition getPos [random(DESTINATION_VARIANCE), random(360)];
                    _profileWaypoint = [_position, 100, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;

                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                    };

                } forEach _planeProfiles;

                {
                    _position = _eventPosition getPos [random(DESTINATION_VARIANCE), random(360)];
                    _profileWaypoint = [_position, 100, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;

                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                    };

                } forEach _heliProfiles;


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    [_logic, "createMarker", [_eventPosition,_eventFaction,"ML DESTINATION"]] call MAINCLASS;
                };
                // DEBUG -------------------------------------------------------------------------------------


                // dispatch event
                _logEvent = ['LOGISTICS_DESTINATION', [_eventPosition,_eventFaction,_side,_eventID],"Logistics"] call ALIVE_fnc_event;
                [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;


                if(_playerRequested) then {
                    _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","REQUEST_ENROUTE"] call ALIVE_fnc_event;
                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                };


                [_event, "state", "transportTravel"] call ALIVE_fnc_hashSet;
                [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
            };

            case "transportTravel": {

                // waypoint complete check stage

                private ["_waitTotalIterations","_waitIterations","_waitDifference","_transportProfiles","_infantryProfiles",
                "_armourProfiles","_mechanisedProfiles","_motorisedProfiles","_planeProfiles","_heliProfiles",
                "_waypointsCompleted","_waypointsNotCompleted","_profile","_position","_distance","_count","_completed"];

                _count = [_logic, "checkEvent", _event] call MAINCLASS;
                if(_count == 0) exitWith {
                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                // mechanism for aborting this state
                // once set time limit has passed
                // if all units haven't reached objective
                _waitTotalIterations = 400;
                _waitIterations = _eventStateData param [0, 0]; if (isNil "_waitIterations" || typeName _waitIterations != "SCALAR") then { _waitIterations = 0; };

                // ---------------------------------------------------------------
                // EARLY DISMOUNT - ground transport vehicles only
                // When an active ground transport vehicle (not helicopter) is
                // within DISMOUNT_RADIUS of the destination, unload infantry
                // early so they approach on foot. The vehicle then advances
                // VEHICLE_LEAD_DIST ahead toward the objective as overwatch.
                // Only triggers once per event (stateData slot 1 used as flag).
                // Transport vehicle profiles are in _eventTransportVehiclesProfiles.
                // ---------------------------------------------------------------
                private _DISMOUNT_RADIUS = DISMOUNT_RADIUS;
                private _VEHICLE_LEAD_DIST = VEHICLE_LEAD_DIST;
                private _dismountDone = _eventStateData param [1, false];
                if (isNil "_dismountDone" || typeName _dismountDone != "BOOL") then { _dismountDone = false; };

                if (!_dismountDone) then {

                    if (_debug && count _eventTransportVehiclesProfiles > 0) then {
                        ["ML - transportTravel: Checking early dismount. Transport vehicles: %1 Dismount radius: %2m Event: %3",
                            count _eventTransportVehiclesProfiles, _DISMOUNT_RADIUS, _eventID] call ALiVE_fnc_dump;
                    };

                    private _dismountTriggered = false;

                    {
                        private _vehProfID  = _x;
                        private _vehProfile = [ALIVE_profileHandler, "getProfile", _vehProfID] call ALIVE_fnc_profileHandler;
                        if (isNil "_vehProfile") then { continue };

                        // Skip helicopters - they have their own delivery watchdog
                        private _vehClass = _vehProfile select 2 select 11;
                        private _simType = getText (configFile >> "CfgVehicles" >> _vehClass >> "simulation");
                        private _isHeli = (_simType == "helicopter");
                        if (_isHeli) then { continue };

                        private _isActive = _vehProfile select 2 select 1;
                        if (_debug) then {
                            ["ML - transportTravel: Transport vehicle %1 class=%2 active=%3",
                                _vehProfID, _vehClass, _isActive] call ALiVE_fnc_dump;
                        };
                        if (!_isActive) then { continue };

                        private _vehPos     = _vehProfile select 2 select 2;
                        private _distToDest = _vehPos distance2D _eventPosition;

                        if (_debug) then {
                            ["ML - transportTravel: Transport vehicle %1 dist to dest=%2m (threshold=%3m)",
                                _vehProfID, round _distToDest, _DISMOUNT_RADIUS] call ALiVE_fnc_dump;
                        };

                        if (_distToDest > _DISMOUNT_RADIUS) then { continue };

                        // Within dismount radius - check for cargo
                        private _inCargo = _vehProfile select 2 select 9;
                        if (_debug) then {
                            ["ML - transportTravel: Transport vehicle %1 within dismount radius. Cargo profiles: %2",
                                _vehProfID, count _inCargo] call ALiVE_fnc_dump;
                        };
                        if (count _inCargo == 0) then { continue };

                        ["ML - transportTravel: Early dismount triggered for %1 (%2) at %3m from destination. Event: %4",
                            _vehProfID, _vehClass, round _distToDest, _eventID] call ALiVE_fnc_dump;

                        // Unload each cargo profile and give them a foot waypoint to the destination
                        {
                            private _cargoProfile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                            if (isNil "_cargoProfile") then { continue };

                            [_cargoProfile, _vehProfile] call ALIVE_fnc_removeProfileVehicleAssignment;

                            // If physically spawned, moveOut the units
                            private _cargoActive = _cargoProfile select 2 select 1;
                            if (_cargoActive) then {
                                private _cargoUnits = _cargoProfile select 2 select 21;
                                private _vehObj     = _vehProfile select 2 select 10;
                                if (!isNull _vehObj) then {
                                    { if (alive _x) then { unassignVehicle _x; _x moveOut _vehObj; }; } forEach _cargoUnits;
                                    if (_debug) then {
                                        ["ML - transportTravel: Physically dismounted %1 units from %2",
                                            count _cargoUnits, _vehProfID] call ALiVE_fnc_dump;
                                    };
                                };
                            };

                            // Give infantry a waypoint to continue to destination on foot
                            [_cargoProfile, "clearWaypoints"] call ALIVE_fnc_profileEntity;
                            private _infWP = [_eventPosition, 50, "MOVE", "LIMITED", 2, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                            [_cargoProfile, "addWaypoint", _infWP] call ALIVE_fnc_profileEntity;

                            if (_debug) then {
                                ["ML - transportTravel: Infantry profile %1 given foot waypoint to %2",
                                    _x, _eventPosition] call ALiVE_fnc_dump;
                            };

                        } forEach _inCargo;

                        // Give vehicle a waypoint VEHICLE_LEAD_DIST ahead toward objective,
                        // then continue to destination to act as overwatch
                        private _dirToDest  = _vehPos getDir _eventPosition;
                        private _leadPos    = _vehPos getPos [_VEHICLE_LEAD_DIST, _dirToDest];
                        _leadPos set [2, 0];
                        private _nearRoad   = _leadPos nearRoads 40;
                        private _roadSnapped = false;
                        if (count _nearRoad > 0) then {
                            _leadPos = getPos (_nearRoad select 0);
                            _roadSnapped = true;
                        };

                        if (_debug) then {
                            ["ML - transportTravel: Vehicle %1 overwatch position %2 (road snapped: %3)",
                                _vehProfID, _leadPos, _roadSnapped] call ALiVE_fnc_dump;
                        };

                        [_vehProfile, "clearWaypoints"] call ALIVE_fnc_profileEntity;
                        private _leadWP = [_leadPos,      10, "MOVE", "LIMITED", 2, [], "COLUMN"] call ALIVE_fnc_createProfileWaypoint;
                        private _destWP = [_eventPosition, 50, "MOVE", "LIMITED", 2, [], "COLUMN"] call ALIVE_fnc_createProfileWaypoint;
                        [_vehProfile, "addWaypoint", _leadWP] call ALIVE_fnc_profileEntity;
                        [_vehProfile, "addWaypoint", _destWP] call ALIVE_fnc_profileEntity;

                        _dismountTriggered = true;

                    } forEach _eventTransportVehiclesProfiles;

                    if (_dismountTriggered) then {
                        _eventStateData set [1, true];
                        [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;
                        ["ML - transportTravel: Early dismount complete. Infantry on foot, vehicles advancing as overwatch. Event: %1",
                            _eventID] call ALiVE_fnc_dump;
                    } else {
                        if (_debug) then {
                            ["ML - transportTravel: No active ground transports within dismount radius yet. Event: %1", _eventID] call ALiVE_fnc_dump;
                        };
                    };
                } else {
                    if (_debug) then {
                        ["ML - transportTravel: Early dismount already completed for event %1, skipping check.", _eventID] call ALiVE_fnc_dump;
                    };
                };
                // ---------------------------------------------------------------
                // END EARLY DISMOUNT
                // ---------------------------------------------------------------

                // check waypoints

                _transportProfiles = _eventTransportProfiles;
                _infantryProfiles = [_eventCargoProfiles, 'infantry'] call ALIVE_fnc_hashGet;
                _armourProfiles = [_eventCargoProfiles, 'armour'] call ALIVE_fnc_hashGet;
                _mechanisedProfiles = [_eventCargoProfiles, 'mechanised'] call ALIVE_fnc_hashGet;
                _motorisedProfiles = [_eventCargoProfiles, 'motorised'] call ALIVE_fnc_hashGet;
                _planeProfiles = [_eventCargoProfiles, 'plane'] call ALIVE_fnc_hashGet;
                _heliProfiles = [_eventCargoProfiles, 'heli'] call ALIVE_fnc_hashGet;

                _waypointsCompleted = 0;
                _waypointsNotCompleted = 0;

                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {

                        _completed = [_logic,"checkWaypointCompleted",_profile] call MAINCLASS;

                        if!(_completed) then {
                            _waypointsNotCompleted = _waypointsNotCompleted + 1;
                        }else{
                            _waypointsCompleted = _waypointsCompleted + 1;

                            [_logic,"unloadTransport",[_event,_profile]] call MAINCLASS;
                        };

                    };
                } forEach _transportProfiles;

                // if some waypoints are completed
                // can assume most units are close to
                // destination, adjust timeout
                if(_waypointsCompleted > 0) then {
                    _waitDifference = _waitTotalIterations - _waitIterations;
                    if(_waitDifference > 50) then {
                        _waitIterations = _waitTotalIterations - 15;
                    };
                };

                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {

                        _completed = [_logic,"checkWaypointCompleted",_profile] call MAINCLASS;

                        if!(_completed) then {
                            _waypointsNotCompleted = _waypointsNotCompleted + 1;
                        }else{
                            _waypointsCompleted = _waypointsCompleted + 1;

                            [_logic,"unloadTransport",[_event,_profile]] call MAINCLASS;
                        };

                    };

                } forEach _armourProfiles;

                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {

                        _completed = [_logic,"checkWaypointCompleted",_profile] call MAINCLASS;

                        if!(_completed) then {
                            _waypointsNotCompleted = _waypointsNotCompleted + 1;
                        }else{
                            _waypointsCompleted = _waypointsCompleted + 1;

                            [_logic,"unloadTransport",[_event,_profile]] call MAINCLASS;
                        };

                    };

                } forEach _mechanisedProfiles;

                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {

                        _completed = [_logic,"checkWaypointCompleted",_profile] call MAINCLASS;

                        if!(_completed) then {
                            _waypointsNotCompleted = _waypointsNotCompleted + 1;
                        }else{
                            _waypointsCompleted = _waypointsCompleted + 1;

                            [_logic,"unloadTransport",[_event,_profile]] call MAINCLASS;
                        };

                    };

                } forEach _motorisedProfiles;

                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {

                        _completed = [_logic,"checkWaypointCompleted",_profile] call MAINCLASS;

                        if!(_completed) then {
                            _waypointsNotCompleted = _waypointsNotCompleted + 1;
                        }else{
                            _waypointsCompleted = _waypointsCompleted + 1;

                        };

                    };

                } forEach _planeProfiles;

                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {

                        _completed = [_logic,"checkWaypointCompleted",_profile] call MAINCLASS;

                        if!(_completed) then {
                            _waypointsNotCompleted = _waypointsNotCompleted + 1;
                        }else{
                            _waypointsCompleted = _waypointsCompleted + 1;
                        };

                    };

                } forEach _heliProfiles;


                // all waypoints completed

                if(_waypointsNotCompleted == 0) then {

                    if(_waypointsCompleted > 0) then {
                        [_event, "state", "transportUnloadWait"] call ALIVE_fnc_hashSet;
                        [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                    }else{
                        // set state to event complete
                        [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                        [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                    };

                    // respond to player request
                    if(_playerRequested) then {
                        if(_waypointsCompleted > 0) then {
                            _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","REQUEST_ARRIVED"] call ALIVE_fnc_event;
                            [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                        }else{
                            _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","REQUEST_LOST"] call ALIVE_fnc_event;
                            [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                        };
                    };

                }else{

                    // not all waypoints have been completed
                    // to ensure control passes to OPCOM eventually
                    // limited number of iterations in this
                    // state are used.

                    _waitIterations = _waitIterations + 1;
                    _eventStateData set [0, _waitIterations];
                    [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                    if(_waitIterations > _waitTotalIterations) then {

                        _eventStateData set [0, 0];
                        [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                        [_event, "state", "transportUnloadWait"] call ALIVE_fnc_hashSet;
                        [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;


                    };
                };

            };

            case "transportUnloadWait";
            case "heliTransportUnloadWait": {
                // wait until all vehicles
                // have unloaded their cargo
                private _count = [_logic, "checkEvent", _event] call MAINCLASS;

                if (_count == 0) exitWith {
                    if (_debug) then {
                        ["ML - heliTransportUnloadWait: No profiles remain, moving to eventComplete. Event: %1", _eventID] call ALiVE_fnc_dump;
                    };
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                // mechanism for aborting this state
                // once set time limit has passed
                // if all units haven't reached objective
                private _waitTotalIterations = 40;
                private _waitIterations = _eventStateData param [0, 0]; if (isNil "_waitIterations" || typeName _waitIterations != "SCALAR") then { _waitIterations = 0; };

                private _infantryProfiles = [_eventCargoProfiles, "infantry"] call ALIVE_fnc_hashGet;
                private _loadedUnits = 0;

                {
                    private _infantryProfile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;

                    if !(isNil "_infantryProfile") then {
                        private _active = _infantryProfile select 2 select 1;

                        // only need to worry about this if there are players nearby
                        if (_active) then {
                            private _units = _infantryProfile select 2 select 21;

                            {
                                if (alive _x && vehicle _x != _x) then {
                                    _loadedUnits = _loadedUnits + 1;
                                };
                            } forEach _units;
                        } else {
                            // FIX: Virtual infantry profiles (no players nearby) must still be
                            // checked for vehicle assignment. Without this, _loadedUnits stays 0
                            // for all virtual profiles and the unload wait completes immediately,
                            // sending the heli RTB before it has landed and unloaded its cargo.
                            // If a profile still has vehiclesInCargoOf populated it has not yet
                            // been through unloadTransportHelicopter and should count as loaded.
                            private _cargoOf = _infantryProfile select 2 select 9;
                            if (!isNil "_cargoOf" && { count _cargoOf > 0 }) then {
                                _loadedUnits = _loadedUnits + 1;
                            };
                        };
                    };
                } forEach _infantryProfiles;

                // Check to see if payload profiles are ready to return
                // If vehicle no longer has cargo it can return
                private _payloadUnloaded = true;
                private _payloadProfiles = [];

                if (_playerRequested) then {
                    _payloadProfiles append ((_playerRequestProfiles select 2) select 7)
                };

                _payloadProfiles append ([_eventCargoProfiles, "payloadGroups"] call ALIVE_fnc_hashGet);

                if (!isNil "_payloadProfiles") then {
                    {
                        if (count _x > 1) then {
                            private _vehicleProfile = [ALIVE_profileHandler, "getProfile", _x select 1] call ALIVE_fnc_profileHandler;


                            if !(isNil "_vehicleProfile") then {
                                if (_debug) then { _vehicleProfile call ALIVE_fnc_inspectHash; };

                                private _active = (_vehicleProfile select 2) select 1;
                                private _vehicle = (_vehicleProfile select 2) select 10;
                                private _noCargo = count (_vehicle getvariable ["ALiVE_SYS_LOGISTICS_CARGO", []]) == 0;
                                private _slingLoading = [_vehicleProfile, "slingloading", false] call ALiVE_fnc_hashGet;

                                // FIX: ALiVE_SYS_LOGISTICS_CARGO is never populated for slingload
                                // operations so _noCargo is always true for slingload helis regardless
                                // of whether the slung vehicle has been dropped. Check getSlingLoad on
                                // the live vehicle object directly to determine actual sling state.
                                if (_active && !isNull _vehicle && alive _vehicle) then {
                                    if (!isNull (getSlingLoad _vehicle)) then {
                                        _noCargo      = false;
                                        _slingLoading = true;
                                    };
                                };

                                // If payload vehicle is not slingloading and its cargo is empty - its done.
                                TRACE_1("PR UNLOADED", !_slingLoading, _noCargo);

                                if (_active && _noCargo && !_slingLoading) then {
                                    _payloadUnloaded = true;
                                } else {
                                    _payloadUnloaded = false;
                                };

                                // If we've run out of time, dump cargo
                                if (_waitIterations == _waitTotalIterations) then {
                                    if (_active && !_noCargo) then {
                                        [MOD(SYS_LOGISTICS), "unloadObjects", [_vehicle, _vehicle]] call ALiVE_fnc_logistics;
                                    };
                                };
                            };
                        };
                    } foreach _payloadProfiles;
                };

                TRACE_2("PR UNLOADED", _loadedUnits, _payloadUnloaded);

                // If all inf units are unloaded and all payloads are unloaded, then complete
                if ((_loadedUnits == 0 && _payloadUnloaded) || _waitIterations > _waitTotalIterations) then {

                    if (_debug) then {
                        if (_waitIterations > _waitTotalIterations) then {
                            ["ML - heliTransportUnloadWait: Timeout after %1 iterations. loadedUnits=%2 payloadUnloaded=%3. Forcing transition.",
                                _waitIterations, _loadedUnits, _payloadUnloaded] call ALiVE_fnc_dump;
                        } else {
                            ["ML - heliTransportUnloadWait: All units unloaded after %1 iterations. Moving to heliTransportComplete.",
                                _waitIterations] call ALiVE_fnc_dump;
                        };
                    };

                    _eventStateData set [0, 0];
                    [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                    if (_eventState == "heliTransportUnloadWait") then {
                        [_event, "state", "heliTransportComplete"] call ALIVE_fnc_hashSet;
                    } else {
                        [_event, "state", "transportComplete"] call ALIVE_fnc_hashSet;
                    };

                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                } else {
                    if (_debug) then {
                        ["ML - heliTransportUnloadWait: Waiting for unload. iteration=%1/%2 loadedUnits=%3 payloadUnloaded=%4",
                            _waitIterations, _waitTotalIterations, _loadedUnits, _payloadUnloaded] call ALiVE_fnc_dump;
                    };
                };

                _waitIterations = _waitIterations + 1;
                _eventStateData set [0, _waitIterations];
                [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;
            };

            case "transportComplete";
            case "heliTransportComplete": {

                // unloading complete
                // if profiles are active move on
                // to return to insertion point
                // if not active destroy transport profiles
                private ["_transportProfile","_inCargo","_cargoProfileID","_cargoProfile","_active","_inCommand","_commandProfileID","_commandProfile","_anyActive","_count"];
                _count = [_logic, "checkEvent", _event] call MAINCLASS;

                if (_debug) then {
                    ["ML - heliTransportComplete: Event %1 transportVehicles=%2 count=%3",
                        _eventID, count _eventTransportVehiclesProfiles, _count] call ALiVE_fnc_dump;
                };

                if (_count == 0 && count _eventTransportVehiclesProfiles == 0) exitWith {
                    if (_debug) then {
                        ["ML - heliTransportComplete: No profiles remain, moving to eventComplete. Event: %1", _eventID] call ALiVE_fnc_dump;
                    };
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                if (count _eventTransportVehiclesProfiles > 0) then {
                    _anyActive = 0;

                    {
                        _transportProfile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                        if !(isNil "_transportProfile") then {
                            _active = _transportProfile select 2 select 1;
                            private _vehicleObj = _transportProfile select 2 select 10;
                            private _hasLiveVehicle = (!isNull _vehicleObj && alive _vehicleObj);

                            // Also check the entity (pilot) profile -- ALiVE may virtualise the
                            // vehicle profile mid-flight while the physical heli is still active.
                            // If the pilot is active, the heli is physically in the world.
                            private _pilotActive = false;
                            private _inCmd = _transportProfile select 2 select 8; // entitiesInCommandOf (vehicle profile)
                            if (count _inCmd > 0) then {
                                private _pilotProf = [ALIVE_profileHandler, "getProfile", _inCmd select 0] call ALIVE_fnc_profileHandler;
                                if !(isNil "_pilotProf") then {
                                    _pilotActive = _pilotProf select 2 select 1;
                                };
                            };

                            // Count as active if vehicle OR pilot says so, or live vehicle object exists
                            if (_active || _pilotActive || _hasLiveVehicle) then {
                                _anyActive = _anyActive + 1;
                            } else {
                                // Truly virtual - no live object, safe to destroy
                                if (_debug) then {
                                    ["ML - heliTransportComplete: Transport vehicle %1 virtual (no live object), destroying profile.", _x] call ALiVE_fnc_dump;
                                };

                                private _inCommand = _transportProfile select 2 select 8;

                                if (count _inCommand > 0) then {
                                    _commandProfileID = _inCommand select 0;
                                    _commandProfile = [ALIVE_profileHandler, "getProfile", _commandProfileID] call ALIVE_fnc_profileHandler;

                                    if !(isNil "_commandProfile") then {
                                        [_commandProfile, "destroy"] call ALIVE_fnc_profileEntity;
                                    };
                                };

                                [_transportProfile, "destroy"] call ALIVE_fnc_profileVehicle;
                            };
                        };
                    } forEach _eventTransportVehiclesProfiles;

                    // Now decide state based on whether any were active
                    if (_anyActive > 0) then {
                        if (_debug) then {
                            ["ML - heliTransportComplete: %1 transport vehicle(s) active, releasing cargo and sending helis RTB. Event: %2",
                                _anyActive, _eventID] call ALiVE_fnc_dump;
                        };
                        [_logic, "setEventProfilesAvailable", _event] call MAINCLASS;

                        if (_eventState == "transportComplete") then {
                            [_event, "state", "transportReturn"] call ALIVE_fnc_hashSet;
                        } else {
                            [_event, "state", "heliTransportReturn"] call ALIVE_fnc_hashSet;
                        };

                        [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                    } else {
                        // All vehicles were inactive/virtual - release cargo and complete
                        if (_debug) then {
                            ["ML - heliTransportComplete: All transport vehicles inactive, releasing cargo and completing. Event: %1", _eventID] call ALiVE_fnc_dump;
                        };
                        [_logic, "setEventProfilesAvailable", _event] call MAINCLASS;
                        [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                        [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                    };
                } else {
                    if (_debug) then {
                        ["ML - heliTransportComplete: No transport vehicles, moving to eventComplete. Event: %1", _eventID] call ALiVE_fnc_dump;
                    };
                    // no transport vehicles
                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };
            };

            case "transportReturn": {

                private ["_position","_profileWaypoint","_reinforcementPosition","_count"];

                _count = [_logic, "checkEvent", _event] call MAINCLASS;
                if(_count == 0) exitWith {
                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                if(count _eventTransportProfiles > 0) then {

                    // Anchor RTB destination to the supply network so convoys
                    // don't drive back through enemy territory. Mirrors the
                    // heli-path supply-network anchoring for departures.
                    private _rawReinforcePos = [_reinforcementPrimaryObjective,"center"] call ALIVE_fnc_hashGet;
                    private _rtbPosition = [_logic, "getSupplyNetworkDeparturePos", [
                        _eventFaction,
                        _eventPosition,
                        _rawReinforcePos,
                        _eventID,
                        _debug
                    ]] call MAINCLASS;

                    if (_debug) then {
                        ["ML - transportReturn: RTB via supply network node at %1 (raw objective was %2). Event: %3",
                            _rtbPosition, _rawReinforcePos, _eventID] call ALiVE_fnc_dump;
                    };

                    // send transport vehicles back to supply network node
                    {
                        _position = _rtbPosition getPos [random(300), random(360)];
                        _position = [_position] call ALIVE_fnc_getClosestRoad;
                        _profileWaypoint = [_position, 100, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;

                        _transportProfile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                        if!(isNil "_transportProfile") then {
                            [_transportProfile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                        };


                    } forEach _eventTransportProfiles;

                    // set state to wait for return of transports
                    [_event, "state", "transportReturnWait"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                }else{

                    // no transport vehicles
                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                };

            };

            case "transportReturnWait";
            case "heliTransportReturnWait": {
                private ["_anyActive","_anyAlive","_transportProfile","_active","_inCommand","_commandProfileID","_commandProfile","_count"];

                _count = [_logic, "checkEvent", _event] call MAINCLASS;

                if (_count == 0 && count _eventTransportProfiles == 0) exitWith {
                    if (_debug) then {
                        ["ML - heliTransportReturnWait: No profiles remain, moving to eventComplete. Event: %1", _eventID] call ALiVE_fnc_dump;
                    };
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                if (count _eventTransportProfiles > 0) then {
                    _anyActive = 0;
                    _anyAlive = 0;

                    // mechanism for aborting this state
                    // once set time limit has passed
                    // if all units haven't reached objective
                    _waitTotalIterations = 60;
                    _waitIterations = _eventStateData param [0, 0]; if (isNil "_waitIterations" || typeName _waitIterations != "SCALAR") then { _waitIterations = 0; };

                    // once transport vehicles are inactive
                    // dispose of the profiles
                    {
                        _transportProfile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                        if !(isNil "_transportProfile") then {
                            _active = _transportProfile select 2 select 1;
                            _vehicle = _transportProfile select 2 select 10;
                            private _hasLiveVehicle = (!isNull _vehicle && alive _vehicle);

                            // For heli RTB: force inactive on timeout OR if it has flown far enough from delivery destination
                            if (_eventState == "heliTransportReturnWait") then {
                                private _finalDest = [_event, "finalDestination"] call ALIVE_fnc_hashGet;
                                private _farEnough = false;
                                if (count _finalDest > 1) then {
                                    // Use live vehicle position if spawned, otherwise profile's recorded position
                                    private _checkPos = if (!isNull _vehicle && alive _vehicle) then {
                                        getPos _vehicle
                                    } else {
                                        _transportProfile select 2 select 2
                                    };
                                    private _distFromDest = _checkPos distance2D _finalDest;
                                    _farEnough = _distFromDest > 1500;

                                    // Treat as RTB done if heli is well clear of destination AND
                                    // has been moving slowly for several consecutive checks.
                                    // Guards:
                                    //   - Distance must be >2000m (well past delivery zone, not just drifting)
                                    //   - Speed must be low for 3+ consecutive ReturnWait iterations
                                    //   - Heli must have no crew cargo (no passengers still aboard)
                                    if (!_farEnough && _distFromDest > 2000 && !isNull _vehicle && alive _vehicle) then {
                                        private _heliSpd = speed _vehicle;
                                        private _crewCount = { alive _x && _x != driver _vehicle && _x != gunner _vehicle } count crew _vehicle;
                                        private _hoverIterKey = format ["hoverIter_%1", _x];
                                        private _hoverCount = _eventStateData param [4, 0];
                                        if (abs _heliSpd < FUEL_WATCHDOG_HOVER_SPEED_THRESHOLD && _crewCount == 0) then {
                                            _hoverCount = _hoverCount + 1;
                                            _eventStateData set [4, _hoverCount];
                                            [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;
                                        } else {
                                            if (_hoverCount > 0) then {
                                                _eventStateData set [4, 0];
                                                [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;
                                            };
                                        };
                                        if (_hoverCount >= 3) then {
                                            _farEnough = true;
                                            ["ML - heliTransportReturnWait: %1 hover-stuck >2000m from dest for %2 checks, treating as RTB done.",
                                                _x, _hoverCount] call ALiVE_fnc_dump;
                                        };
                                    };
                                };
                                if (_waitIterations > _waitTotalIterations || _farEnough) then {
                                    // Force heli to land and despawn if still active
                                    if (!isNull _vehicle && alive _vehicle && _active) then {
                                        private _landPad = createVehicle ["Land_HelipadEmpty_F", getPosATL _vehicle, [], 0, "CAN_COLLIDE"];
                                        _vehicle landAt _landPad;
                                        [_vehicle, _landPad] spawn {
                                            private _h = _this select 0; private _p = _this select 1; private _t = 0;
                                            waitUntil { sleep 2; _t = _t + 2; isTouchingGround _h || !alive _h || _t > 30 };
                                            deleteVehicle _p;
                                            if (alive _h) then { _h setDamage 1; }; // despawn by destroying if won't land
                                        };
                                    };
                                    _active = false;
                                };
                            };

                            // FIX 4: Gate on _hasLiveVehicle before canMove. _vehicle is
                            // select 2 select 10 which can be a dead/null object even when
                            // _active is true if the vehicle was destroyed mid-RTB. Calling
                            // canMove on a dead object returns false, causing _anyAlive to
                            // stay 0 and the event to complete while the pilot profile still
                            // exists, leaking resources.
                            if (_active && _hasLiveVehicle) then {
                                // canMove can return false briefly after spawn during physics
                                // initialisation, and also on airborne helis with AI fighting
                                // the controls. Only treat canMove=false as "damaged/stuck"
                                // when the vehicle is on or near the ground (AGL < 10m).
                                // Airborne helis are always counted as alive regardless of canMove.
                                private _heliAGL = (getPosATL _vehicle) select 2;
                                if (canMove _vehicle || _heliAGL > 10) then {
                                    _anyAlive = _anyAlive + 1;
                                } else {
                                    // Vehicle is on the ground and can't move - treat as done
                                    if (_debug) then {
                                        ["ML - heliTransportReturnWait: Transport vehicle can't move (damaged?), counting as RTB done.", _x] call ALiVE_fnc_dump;
                                    };
                                    // Destroy the profile to free resources
                                    private _inCommand2 = _transportProfile select 2 select 8;
                                    if (count _inCommand2 > 0) then {
                                        private _cmdProf = [ALIVE_profileHandler, "getProfile", _inCommand2 select 0] call ALIVE_fnc_profileHandler;
                                        if !(isNil "_cmdProf") then { [_cmdProf, "destroy"] call ALIVE_fnc_profileEntity; };
                                    };
                                    [_transportProfile, "destroy"] call ALIVE_fnc_profileVehicle;
                                };

                                _anyActive = _anyActive + 1;
                            } else {
                                // if not active dispose of transport profiles
                                _inCommand = _transportProfile select 2 select 8;

                                if (count _inCommand > 0) then {
                                    _commandProfileID = _inCommand select 0;
                                    _commandProfile = [ALIVE_profileHandler, "getProfile", _commandProfileID] call ALIVE_fnc_profileHandler;

                                    if !(isNil "_commandProfile") then {
                                        [_commandProfile, "destroy"] call ALIVE_fnc_profileEntity;
                                    };
                                };

                                [_transportProfile, "destroy"] call ALIVE_fnc_profileVehicle;
                            };
                        };
                    } forEach _eventTransportVehiclesProfiles;

                    _waitIterations = _waitIterations + 1;
                    _eventStateData set [0, _waitIterations];
                    [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                    if (_anyActive == 0 || _anyAlive == 0 || _waitIterations > _waitTotalIterations) then {
                        if (_debug) then {
                            ["ML - heliTransportReturnWait: RTB complete. anyActive=%1 anyAlive=%2 iterations=%3/%4. Moving to eventComplete. Event: %5",
                                _anyActive, _anyAlive, _waitIterations, _waitTotalIterations, _eventID] call ALiVE_fnc_dump;
                        };
                        _eventStateData set [0, 0];
                        [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;
                        [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                        [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                    } else {
                        if (_debug) then {
                            ["ML - heliTransportReturnWait: Waiting for RTB. anyActive=%1 anyAlive=%2 iteration=%3/%4. Event: %5",
                                _anyActive, _anyAlive, _waitIterations, _waitTotalIterations, _eventID] call ALiVE_fnc_dump;
                        };
                    };
                } else {
                    if (_debug) then {
                        ["ML - heliTransportReturnWait: No transport profiles, moving to eventComplete. Event: %1", _eventID] call ALiVE_fnc_dump;
                    };
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };
            };

            // HELI PARADROP ---------------------------------------------------------------

            case "heliParadropStart": {

                private ["_transportProfiles","_infantryProfiles","_profileWaypoint","_profile","_count"];
                _transportProfiles = _eventTransportProfiles;
                _infantryProfiles  = [_eventCargoProfiles, 'infantry'] call ALIVE_fnc_hashGet;

                _count = [_logic, "checkEvent", _event] call MAINCLASS;
                if(_count == 0) exitWith {
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                private _activeHeliCount = 0;
                {
                    private _qState = [_x, "state"] call ALIVE_fnc_hashGet;
                    private _qID    = [_x, "id"]    call ALIVE_fnc_hashGet;
                    private _qData  = [_x, "data"]  call ALIVE_fnc_hashGet;
                    private _qType  = if (count _qData > 4) then { _qData select 4 } else { "" };
                    if (_qID != _eventID && _qType in ["HELI_INSERT","HELI_PARADROP"]) then {
                        if (_qState in [
                            "heliTransport","heliTransportUnloadWait","heliTransportComplete",
                            "heliTransportReturn","heliTransportReturnWait",
                            "heliParadropFly","heliParadropReturn","heliParadropReturnWait"
                        ]) then {
                            _activeHeliCount = _activeHeliCount + 1;
                        };
                    };
                } forEach (_eventQueue select 2);

                if (_activeHeliCount >= 2 && { isNil "ALIVE_ML_TEST_REQUEST" || { ALIVE_ML_TEST_REQUEST != _eventID } }) exitWith {
                    if (_debug) then {
                        ["ML - heliParadropStart: Throttle - %1 heli events in flight, deferring %2.",
                            _activeHeliCount, _eventID] call ALiVE_fnc_dump;
                    };
                };

                [_event, "finalDestination", _eventPosition getPos [random(DESTINATION_VARIANCE), random(360)]] call ALIVE_fnc_hashSet;

                private _paradropHeight = PARADROP_HEIGHT;

                {
                    private _dropWPPos = +_eventPosition;
                    _dropWPPos set [2, _paradropHeight];
                    _profileWaypoint = [_dropWPPos, 400, "MOVE", "NORMAL", 100, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                    _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                    if (!isNil "_profile") then {
                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

                        private _tIdx = _transportProfiles find _x;
                        private _groupInfantryIDs = if (_tIdx >= 0 && _tIdx < count _infantryProfiles) then {
                            _infantryProfiles select _tIdx
                        } else { [] };

                        private _vProfID = "";
                        if (_tIdx >= 0 && _tIdx < count _eventTransportVehiclesProfiles) then {
                            _vProfID = _eventTransportVehiclesProfiles select _tIdx;
                        };

                        private _returnPos = [_reinforcementPrimaryObjective, "center"] call ALIVE_fnc_hashGet;

                        [_logic, "spawnHeliParadropWatchdog", [
                            _x, _vProfID, _eventPosition, _returnPos, _groupInfantryIDs, _paradropHeight, _debug
                        ]] call MAINCLASS;

                        if (_debug) then {
                            ["ML - heliParadropStart: Watchdog started for transport %1 dropping %2 groups.",
                                _x, count _groupInfantryIDs] call ALiVE_fnc_dump;
                        };

                    } else {
                        ["ML - heliParadropStart: WARNING transport profile %1 nil, skipping.", _x] call ALiVE_fnc_dump;
                    };
                } forEach _transportProfiles;

                [_event, "state", "heliParadropFly"] call ALIVE_fnc_hashSet;
                [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                if (_debug) then {
                    ["ML - heliParadropStart: %1 helis dispatched. Event: %2",
                        count _transportProfiles, _eventID] call ALiVE_fnc_dump;
                };
            };

            case "heliParadropFly": {

                private _count = [_logic, "checkEvent", _event] call MAINCLASS;
                if (_count == 0) exitWith {
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                private _waitTotalIterations = 300;
                private _waitIterations = _eventStateData param [0, 0];
                if (isNil "_waitIterations" || typeName _waitIterations != "SCALAR") then { _waitIterations = 0; };

                private _allDropped = true;
                private _anyAlive   = false;

                {
                    private _tProfID  = _x;
                    private _tProfile = [ALIVE_profileHandler, "getProfile", _tProfID] call ALIVE_fnc_profileHandler;
                    if (!isNil "_tProfile") then {
                        _anyAlive = true;
                        private _completed = if (isNil "ALIVE_ML_paradropComplete") then { false } else {
                            _tProfID in ALIVE_ML_paradropComplete
                        };
                        if (!_completed) then { _allDropped = false; };
                        if (_debug) then {
                            ["ML - heliParadropFly: transport %1 profile=%2 completed=%3", _tProfID, (!isNil "_tProfile"), _completed] call ALiVE_fnc_dump;
                        };
                    } else {
                        if (_debug) then {
                            ["ML - heliParadropFly: transport %1 profile=NIL (gone)", _tProfID] call ALiVE_fnc_dump;
                        };
                    };
                } forEach _eventTransportProfiles;

                if ((_allDropped || _waitIterations > _waitTotalIterations) || (!_anyAlive && _waitIterations > 5)) then {
                    if (_debug) then {
                        ["ML - heliParadropFly: Drops complete. Moving to heliParadropReturn. Event: %1", _eventID] call ALiVE_fnc_dump;
                    };
                    _eventStateData set [0, 0];
                    [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;
                    [_event, "state", "heliParadropReturn"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                } else {
                    _waitIterations = _waitIterations + 1;
                    _eventStateData set [0, _waitIterations];
                    [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;
                    if (_debug) then {
                        ["ML - heliParadropFly: Waiting for drops. iter=%1/%2 Event: %3",
                            _waitIterations, _waitTotalIterations, _eventID] call ALiVE_fnc_dump;
                    };
                };
            };

            case "heliParadropReturn": {

                private _count = [_logic, "checkEvent", _event] call MAINCLASS;
                if (_count == 0 && count _eventTransportProfiles == 0) exitWith {
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                // Mirror heliTransportReturn: 3-waypoint egress to avoid AI hover issues.
                // Profile waypoints must use 2D/terrain positions -- explicit Z causes descent.
                private _reinforcementPosition = [_reinforcementPrimaryObjective, "center"] call ALIVE_fnc_hashGet;
                private _eventDestination = [_event, "finalDestination"] call ALIVE_fnc_hashGet;
                private _returnDest = if (count _eventDestination > 1) then {
                    private _egressDir = _eventDestination getDir _reinforcementPosition;
                    _reinforcementPosition getPos [1500, _egressDir]
                } else {
                    _reinforcementPosition getPos [1500, random 360]
                };

                {
                    private _tProfile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                    if (!isNil "_tProfile") then {
                        // FIX 3/6: Use live vehicle position when available (mirrors heliTransportReturn fix).
                        // Also corrected egress direction to head TOWARD reinforcement base on the
                        // straight leg -- the previous - 180 flew paradrop helis deeper into
                        // contested territory before reversing.
                        private _liveVehicle2 = _tProfile select 2 select 10;
                        private _tPos = if (!isNull _liveVehicle2 && alive _liveVehicle2) then {
                            getPos _liveVehicle2
                        } else {
                            _tProfile select 2 select 2
                        };

                        private _leaveDir = _tPos getDir _reinforcementPosition;
                        private _turnDirOffset = if (random 1 > 0.5) then { 50 } else { -50 };
                        private _leaveDist = 300 + (random 200);

                        private _leavePosStraight = _tPos getPos [_leaveDist, _leaveDir];
                        private _leavePosTurn     = _tPos getPos [_leaveDist * 1.5, [_leaveDir + _turnDirOffset] call ALiVE_fnc_modDegrees];

                        private _wpStraight = [_leavePosStraight, 100, "MOVE", "FULL", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                        private _wpTurn     = [_leavePosTurn,     100, "MOVE", "FULL",  300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                        private _wpFinal    = [_returnDest,       100, "MOVE", "FULL",  300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;

                        [_tProfile, "clearWaypoints"] call ALIVE_fnc_profileEntity;
                        [_tProfile, "addWaypoint", _wpStraight] call ALIVE_fnc_profileEntity;
                        [_tProfile, "addWaypoint", _wpTurn]     call ALIVE_fnc_profileEntity;
                        [_tProfile, "addWaypoint", _wpFinal]    call ALIVE_fnc_profileEntity;

                        if (_debug) then {
                            ["ML - heliParadropReturn: RTB issued to %1. exit->%2 turn->%3 base->%4", _x, _leavePosStraight, _leavePosTurn, _returnDest] call ALiVE_fnc_dump;
                        };
                    };
                } forEach _eventTransportProfiles;

                _eventStateData set [0, 0];
                [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;
                [_event, "state", "heliParadropReturnWait"] call ALIVE_fnc_hashSet;
                [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
            };

            case "heliParadropReturnWait": {

                private _count = [_logic, "checkEvent", _event] call MAINCLASS;
                if (_count == 0 && count _eventTransportProfiles == 0) exitWith {
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                if (count _eventTransportVehiclesProfiles > 0) then {
                    private _waitTotalIterations = 60;
                    private _waitIterations = _eventStateData param [0, 0];
                    if (isNil "_waitIterations" || typeName _waitIterations != "SCALAR") then { _waitIterations = 0; };

                    private _anyActive = 0;
                    private _anyAlive  = 0;
                    private _finalDest = [_event, "finalDestination"] call ALIVE_fnc_hashGet;

                    {
                        private _tProfile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                        if (!isNil "_tProfile") then {
                            private _active  = _tProfile select 2 select 1;
                            private _vehicle = _tProfile select 2 select 10;

                            private _farEnough = false;
                            if (count _finalDest > 1) then {
                                private _checkPos = if (!isNull _vehicle && alive _vehicle) then {
                                    getPos _vehicle
                                } else {
                                    _tProfile select 2 select 2
                                };
                                _farEnough = _checkPos distance2D _finalDest > 1500;
                            };

                            if (_waitIterations > _waitTotalIterations || _farEnough) then {
                                if (!isNull _vehicle && alive _vehicle && _active) then {
                                    private _landPad = createVehicle ["Land_HelipadEmpty_F", getPosATL _vehicle, [], 0, "CAN_COLLIDE"];
                                    _vehicle landAt _landPad;
                                    [_vehicle, _landPad] spawn {
                                        private _h = _this select 0; private _p = _this select 1; private _t = 0;
                                        waitUntil { sleep 2; _t = _t + 2; isTouchingGround _h || !alive _h || _t > 30 };
                                        deleteVehicle _p;
                                        if (alive _h) then { _h setDamage 1; };
                                    };
                                };
                                _active = false;
                            };

                            if (_active) then {
                                if (!isNull _vehicle && alive _vehicle && canMove _vehicle) then {
                                    _anyAlive = _anyAlive + 1;
                                } else {
                                    // damaged or gone -- destroy profiles
                                    private _inCommand = _tProfile select 2 select 8;
                                    if (count _inCommand > 0) then {
                                        private _cmdProf = [ALIVE_profileHandler, "getProfile", _inCommand select 0] call ALIVE_fnc_profileHandler;
                                        if (!isNil "_cmdProf") then { [_cmdProf, "destroy"] call ALIVE_fnc_profileEntity; };
                                    };
                                    // Clear vehicleAssignments before destroy to prevent
                                    // fnc_removeProfileVehicleAssignment _indexes error in ALiVE core.
                                    [_tProfile, "vehicleAssignments", [] call ALIVE_fnc_hashCreate] call ALIVE_fnc_profileVehicle;
                                    [_tProfile, "destroy"] call ALIVE_fnc_profileVehicle;
                                };
                                _anyActive = _anyActive + 1;
                            } else {
                                private _inCommand = _tProfile select 2 select 8;
                                if (count _inCommand > 0) then {
                                    private _cmdProf = [ALIVE_profileHandler, "getProfile", _inCommand select 0] call ALIVE_fnc_profileHandler;
                                    if (!isNil "_cmdProf") then { [_cmdProf, "destroy"] call ALIVE_fnc_profileEntity; };
                                };
                                // Clear vehicleAssignments before destroy to prevent ALiVE core _indexes error.
                                [_tProfile, "vehicleAssignments", [] call ALIVE_fnc_hashCreate] call ALIVE_fnc_profileVehicle;
                                [_tProfile, "destroy"] call ALIVE_fnc_profileVehicle;
                            };
                        };
                    } forEach _eventTransportVehiclesProfiles;

                    _waitIterations = _waitIterations + 1;
                    _eventStateData set [0, _waitIterations];
                    [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                    if (_anyActive == 0 || _anyAlive == 0 || _waitIterations > _waitTotalIterations) then {
                        ["ML - heliParadropReturnWait: RTB complete. Event: %1", _eventID] call ALiVE_fnc_dump;
                        _eventStateData set [0, 0];
                        [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;
                        [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                        [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                    } else {
                        if (_debug) then {
                            ["ML - heliParadropReturnWait: Waiting RTB. anyActive=%1 anyAlive=%2 iter=%3/%4. Event: %5",
                                _anyActive, _anyAlive, _waitIterations, _waitTotalIterations, _eventID] call ALiVE_fnc_dump;
                        };
                    };
                } else {
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };
            };

            // END HELI PARADROP -----------------------------------------------------------

            case "eventComplete": {

                private["_sideObject","_factionName","_forcePool","_message","_radioBroadcast","_debug"];

                _debug = [_logic, "debug"] call MAINCLASS;

                [_logic, "setEventProfilesAvailable", _event] call MAINCLASS;

				// Moved behind debug per request #348
				if (_debug) then {

	                // send radio broadcast
	                _sideObject = [_eventSide] call ALIVE_fnc_sideTextToObject;
	                _factionName = getText((_eventFaction call ALiVE_fnc_configGetFactionClass) >> "displayName");
	                _forcePool = [ALIVE_globalForcePool,_eventFaction] call ALIVE_fnc_hashGet;

                    private _HQ = switch (_sideObject) do {
                        case WEST: {
                            "BLU"
                        };
                        case EAST: {
                            "OPF"
                        };
                        case RESISTANCE: {
                            "IND"
                        };
                        default {
                            "HQ"
                        };
                    };
	                // send a message to all side players from HQ
	                private _finalDest = [_event, "finalDestination"] call ALIVE_fnc_hashGet;
	                private _destLocName = "";
	                if (count _finalDest > 0) then {
	                    private _nearLocStr = [_finalDest] call ALIVE_fnc_taskGetNearestLocationName;
	                    if (_nearLocStr != "" && _nearLocStr != "unknown") then {
	                        _destLocName = format [" near %1", _nearLocStr];
	                    };
	                };
	                _message = format["%1 reinforcements have arrived%2. Available reinforcement level: %3", _factionName, _destLocName, _forcePool];
	                _radioBroadcast = [objNull,_message,"side",_sideObject,false,false,false,true,_HQ];
	                [_eventSide,_radioBroadcast] call ALIVE_fnc_radioBroadcastToSide;
                };

                // remove the event
                [_logic, "removeEvent", _eventID] call MAINCLASS;

            };

            // PLAYER REQUEST ---------------------------------------------------------------------------------------------------------------------------------

            // the units have been requested by a player
            // spawn the units at the insertion point
            case "playerRequested": {

                private ["_waitTime"];

                // according to the type of reinforcement
                // adjust wait time for creation of profiles

                switch(_reinforcementType) do {
                    case "AIR": {
                        _waitTime = WAIT_TIME_AIR;
                    };
                    case "HELI": {
                        _waitTime = WAIT_TIME_HELI;
                    };
                    case "MARINE": {
                        _waitTime = WAIT_TIME_MARINE;
                    };
                    case "DROP": {
                        _waitTime = WAIT_TIME_DROP;
                    };
                };


                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["ML - Event state: %1 event timer: %2 wait time on event: %3 ",_eventState, (time - _eventTime), _waitTime] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------


                // if the reinforcement objective is
                // not available, cancel the event
                if(_reinforcementAvailable) then {

                    if((time - _eventTime) > _waitTime) then {

                        private ["_reinforcementPosition","_playersInRange","_paraDrop","_remotePosition","_totalCount"];

                        if(_eventType == "PR_STANDARD" || _eventType == "PR_HELI_INSERT") then {

                            _reinforcementPosition = [_reinforcementPrimaryObjective,"center"] call ALIVE_fnc_hashGet;

                        }else{
                            // PR_AIRDROP: fall back to event position (player destination)
                            _reinforcementPosition = _eventPosition;
                        };

                        // Anchor all three PR_ delivery types to the nearest valid supply
                        // network node so departures never originate in enemy territory.
                        _reinforcementPosition = [_logic, "getSupplyNetworkDeparturePos", [
                            _eventFaction,
                            _eventPosition,
                            _reinforcementPosition,
                            _eventID,
                            _debug
                        ]] call MAINCLASS;

                        if (_debug) then {
                            private _depPos  = _reinforcementPosition;
                            private _destPos = _eventPosition;
                            // Ensure positions are valid 3-element arrays before passing to
                            // taskGetNearestLocationName (nearestLocations requires ASL position)
                            if (isNil "_depPos"  || {!(_depPos  isEqualType [])} || {count _depPos  < 3}) then { _depPos  = [0,0,0]; };
                            if (isNil "_destPos" || {!(_destPos isEqualType [])} || {count _destPos < 3}) then { _destPos = [0,0,0]; };
                            private _depName  = [_depPos]  call ALIVE_fnc_taskGetNearestLocationName;
                            private _destName = [_destPos] call ALIVE_fnc_taskGetNearestLocationName;
                            ["ML - PR_%1 Resupply departure: %2 at %3 -> destination: %4 at %5 dist: %6m",
                                _eventType, _depName, _reinforcementPosition,
                                _destName, _eventPosition,
                                round (_reinforcementPosition distance _eventPosition)] call ALiVE_fnc_dump;
                        };

                        // players near check

                        _playersInRange = [_reinforcementPosition, 350] call ALiVE_fnc_anyPlayersInRange;

                        // if players are in visible range
                        // para drop groups instead of
                        // spawning on the ground

                        _paraDrop = false;
                        if(_playersInRange > 0) then {
                            _paraDrop = true;
                            // remote position should probably be spawn range - risk of heli getting shot down though too...
                            _remotePosition = [_reinforcementPosition, 1600] call ALIVE_fnc_getPositionDistancePlayers;
                        }else{
                            _remotePosition = _reinforcementPosition;
                        };

                        if (_debug) then {
                            ["ML - PR_%1 Resupply spawn origin: paraDrop=%2 playersInRange=%3 remotePosition=%4",
                                _eventType, _paraDrop, _playersInRange, _remotePosition] call ALiVE_fnc_dump;
                        };

                        // wait time complete create profiles
                        // get groups according to requested force makeup

                        _totalCount = 0;


                        private ["_position","_profiles","_profileID","_profileIDs","_emptyVehicleProfiles","_itemCategory","_infantryProfiles","_armourProfiles",
                        "_mechanisedProfiles","_motorisedProfiles","_heliProfiles","_planeProfiles","_itemClass"];

                        _infantryProfiles = [];
                        _mechanisedProfiles = [];
                        _motorisedProfiles = [];
                        _armourProfiles = [];
                        _heliProfiles = [];
                        _planeProfiles = [];
                        _marineProfiles = [];
                        _specOpsProfiles = [];

                        _payloadGroupProfiles = [];

                        // empty vehicles

                        _emptyVehicleProfiles = [];

                        {
                            _itemClass = _x select 0;

                            _position = _reinforcementPosition getPos [random(200), random(360)];

                            if!(surfaceIsWater _position) then {

                                _itemCategory = _x select 1 select 1;

                                switch(_itemCategory) do {
                                    case "Car":{
                                        if(_paraDrop) then {
                                            _position set [2,PARADROP_HEIGHT];
                                        };
                                    };
                                    case "Armored":{
                                        if(_paraDrop) then {
                                            _position set [2,PARADROP_HEIGHT];
                                        };
                                    };
                                    case "Ship":{
                                        if(_paraDrop) then {
                                            _position set [2,PARADROP_HEIGHT];
                                        } else {
                                            // Find the nearest bit of water
                                            _position = [_position, true] call ALIVE_fnc_getClosestSea;
                                        };
                                    };
                                    case "Air":{
                                        _position = _remotePosition getPos [random(200), random(360)];
                                        _position set [2,1000];
                                    };
                                };

                                if(_eventType == "PR_AIRDROP" || (_eventType == "PR_HELI_INSERT" && _itemCategory != "Air")) then {

                                    if (_paraDrop && _eventType == "PR_HELI_INSERT") then {
                                        _position = _remotePosition getPos [random(200), random(360)];
                                        _position set [2,0]; // position might be in water :(
                                    } else {
                                        _position = _reinforcementPosition getPos [random(200), random(360)];
                                    };

                                    TRACE_2(">>>>>>>>>>>>>>>>>>>>>>>>",_itemClass, _position);

                                    _profiles = [_itemClass,_side,_eventFaction,_position] call ALIVE_fnc_createProfileVehicle;
                                    _profiles = [_profiles];
                                    // Once spawned, prevent despawn while being slung
                                    _profile = _profiles select 0;
                                    [_profile, "spawnType", ["preventDespawn"]] call ALIVE_fnc_profileVehicle;

                                }else{
                                    _profiles = [_itemClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,true,true] call ALIVE_fnc_createProfilesCrewedVehicle;
                                };

                                _profileIDs = [];
                                {
                                    _profileID = _x select 2 select 4;
                                    _profileIDs pushback _profileID;
                                } forEach _profiles;

                                _emptyVehicleProfiles pushback _profileIDs;

                                switch(_itemCategory) do {
                                    case "Car":{
                                        _motorisedProfiles pushback _profileIDs;
                                    };
                                    case "Armored":{
                                        _armourProfiles pushback _profileIDs;
                                    };
                                    case "Ship":{
                                        _marineProfiles pushback _profileIDs;
                                    };
                                    case "Air":{
                                        _heliProfiles pushback _profileIDs;

                                        _profileWaypoint = [_reinforcementPosition, 100, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                        _profile = _profiles select 0;
                                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                                    };
                                };

                                _totalCount = _totalCount + 1;

                            };

                        } forEach _emptyVehicles;

                        // set up slingload for empty vehicles
                        if(_eventType == "PR_HELI_INSERT" && {_x select 1 select 1 != "Air"} count _emptyVehicles > 0) then {

                            // create heli transport vehicles for the empty vehicles

                            _transportGroups = [ALIVE_factionDefaultAirTransport,_eventFaction,[]] call ALIVE_fnc_hashGet;
                            _transportProfiles = [];
                            _transportVehicleProfiles = [];

                            if(count _transportGroups == 0) then {
                                _transportGroups = [ALIVE_sideDefaultAirTransport,_side] call ALIVE_fnc_hashGet;
                            };

                            if(count _transportGroups > 0) then {

                                // For each empty vehicle - create a heli to carry it
                                {
                                    private ["_currentDiff","_vehicleClass","_position","_payloadWeight","_slingLoadProfile"];

                                    private _prPickupBase = if (_paraDrop) then {
                                        _remotePosition getPos [random(200), random(360)]
                                    } else {
                                        _reinforcementPosition getPos [random(200), random(360)]
                                    };

                                    _position = [_logic, "prepareHelicopterLZ", [_prPickupBase, 80]] call MAINCLASS;


                                    // Get the profile
                                    _slingLoadProfile = [ALiVE_ProfileHandler, "getProfile", (_x select 0)] call ALIVE_fnc_profileHandler;

                                    // _slingloadProfile call ALIVE_fnc_inspectHash;

                                    _payloadWeight = [(_slingLoadProfile select 2 select 11)] call ALIVE_fnc_getObjectWeight;

                                    // Select helicopter that can slingload the vehicle
                                    _vehicleClass = "";
                                    _currentDiff = 15000;
                                    {
                                        private ["_capacity","_slingloadmax","_maxLoad","_slingDiff","_loadDiff"];

                                        _slingloadmax = [(configFile >> "CfgVehicles" >> _x >> "slingLoadMaxCargoMass")] call ALiVE_fnc_getConfigValue;

                                        if!(isNil "_slingloadmax") then {
                                        	_slingDiff = _slingloadmax - _payloadWeight;

                                        	if ((_slingDiff < _currentDiff) && (_slingDiff > 0)) then {_currentDiff = _slingDiff; _vehicleClass = _x;};
                                        };
                                    } foreach _transportGroups;

                                    // Cannot find heli big enough to slingload this vehicle.
                                    // Fall back to PR_AIRDROP "Option A" teleport: the cargo
                                    // profile was already registered earlier in the dispatch
                                    // loop, so we simply reposition it at the destination
                                    // rather than decrementing _totalCount and bailing.
                                    // The old exitWith here also broke the _emptyVehicleProfiles
                                    // forEach entirely, silently abandoning any further cargo items.
                                    if (_vehicleClass == "") then {
                                        private _heavyID = _x select 0;
                                        private _heavyProfile = [ALiVE_ProfileHandler, "getProfile", _heavyID] call ALIVE_fnc_profileHandler;
                                        if (!isNil "_heavyProfile") then {
                                            [_heavyProfile, "position", _eventPosition] call ALIVE_fnc_profileVehicle;
                                            _payloadGroupProfiles pushback [_heavyID];
                                            ["ML - PR_HELI_INSERT empty-vehicle too heavy to sling (weight %1). Teleporting %2 to destination %3 (Option A fallback).",
                                                _payloadWeight, _heavyID, _eventPosition] call ALiVE_fnc_dump;
                                        } else {
                                            ["ML - PR_HELI_INSERT weight-fail fallback: profile %1 already un-registered, skipping.", _heavyID] call ALiVE_fnc_dump;
                                            _totalCount = _totalCount - 1;
                                        };
                                    } else {

                                    if (_paraDrop) then {
                                        _position set [2,PARADROP_HEIGHT];
                                    };

                                    if (_debug) then {
                                        ["ML - PR_HELI_INSERT infantry [%1] transport LZ: %2",
                                            _forEachIndex + 1, _position] call ALiVE_fnc_dump;
                                    };

                                    // Create slingloading heli (slingloading another profile!)
                                    _profiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,true,true,[], [[_x select 0], []]] call ALIVE_fnc_createProfilesCrewedVehicle;

                                    // Set slingloaded profile
                                    [_slingloadProfile,"slung",[[_profiles select 1 select 2 select 4]]] call ALIVE_fnc_profileVehicle;

                                    _transportProfiles pushback (_profiles select 0 select 2 select 4);
                                    _transportVehicleProfiles pushback (_profiles select 1 select 2 select 4);

                                    _profileIDs = [];
                                    {
                                        _profileID = _x select 2 select 4;
                                        _profileIDs pushback _profileID;
                                    } forEach _profiles;

                                    _payloadGroupProfiles pushback _profileIDs;

                                        private _prDestPos = [_logic, "findHelicopterLandingPos", [
                                            _reinforcementPosition, 0, DESTINATION_VARIANCE
                                        ]] call MAINCLASS;
                                        private _profileWaypoint = [_prDestPos, 30, "MOVE", "NORMAL", 100, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                        _profile = _profiles select 0;
                                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

                                        if (_debug) then {
                                            ["ML - PR_HELI_INSERT [%1] dest waypoint: %2", _forEachIndex + 1, _prDestPos] call ALiVE_fnc_dump;
                                        };

                                        // Fuel watchdog for PR infantry transport heli
                                        [_logic, "spawnHelicopterFuelWatchdog", [
                                            _profiles select 0 select 2 select 4,
                                            _reinforcementPosition,
                                            _eventFaction
                                        ]] call MAINCLASS;

                                    _totalCount = _totalCount + 1;
                                    }; // end else (_vehicleClass == "")

                                } foreach _emptyVehicleProfiles;

                            } else {
                                ["WARNING: No %1 transport vehicles found for Heli Insert.",_eventFaction] call ALIVE_fnc_dump;
                            };

                            _eventTransportProfiles = _eventTransportProfiles + _transportProfiles;
                            _eventTransportVehiclesProfiles = _eventTransportVehiclesProfiles + _transportVehicleProfiles;

                        };


                        // static individuals

                        private ["_staticIndividualProfiles","_unitClasses"];

                        _staticIndividualProfiles = [];

                        if(count _staticIndividuals > 0) then {

                            _staticIndividualProfiles = [];

                            _position = _reinforcementPosition getPos [random(200), random(360)];

                            if(_paraDrop) then {
                                if(_eventType == "PR_HELI_INSERT") then {
                                    _position = _remotePosition;
                                }else{
                                    _position set [2,PARADROP_HEIGHT];
                                };
                            };

                            _unitClasses = [];
                            {
                                _unitClasses pushback (_x select 0);
                            } forEach _staticIndividuals;

                            _profile = [_unitClasses,_side,_eventFaction,_position,0,_side,true] call ALIVE_fnc_createProfileEntity;
                            _profileID = _profile select 2 select 4;
                            _staticIndividualProfiles pushback [_profileID];
                            _infantryProfiles pushback [_profileID];

                            _totalCount = _totalCount + 1;

                        };


                        // join individuals

                        private ["_joinIndividualProfiles"];

                        _joinIndividualProfiles = [];

                        if(count _joinIndividuals > 0) then {

                            _joinIndividualProfiles = [];

                            _position = _reinforcementPosition getPos [random(200), random(360)];

                            if(_paraDrop) then {
                                if(_eventType == "PR_HELI_INSERT") then {
                                    _position = _remotePosition;
                                }else{
                                    _position set [2,PARADROP_HEIGHT];
                                };
                            };

                            _unitClasses = [];
                            {
                                _unitClasses pushback (_x select 0);
                            } forEach _joinIndividuals;

                            _profile = [_unitClasses,_side,_eventFaction,_position,0,_side,true] call ALIVE_fnc_createProfileEntity;
                            _profileID = _profile select 2 select 4;
                            _joinIndividualProfiles pushback [_profileID];
                            _infantryProfiles pushback [_profileID];

                            _totalCount = _totalCount + 1;

                        };

                        // reinforce individuals

                        private ["_reinforceIndividualProfiles"];

                        _reinforceIndividualProfiles = [];

                        if(count _reinforceIndividuals > 0) then {

                            _reinforceIndividualProfiles = [];

                            _position = _reinforcementPosition getPos [random(200), random(360)];

                            if(_paraDrop) then {
                                if(_eventType == "PR_HELI_INSERT") then {
                                    _position = _remotePosition;
                                }else{
                                    _position set [2,PARADROP_HEIGHT];
                                };
                            };

                            _unitClasses = [];
                            {
                                _unitClasses pushback (_x select 0);
                            } forEach _reinforceIndividuals;

                            _profile = [_unitClasses,_side,_eventFaction,_position,0,_side,true] call ALIVE_fnc_createProfileEntity;
                            _profileID = _profile select 2 select 4;
                            _reinforceIndividualProfiles pushback [_profileID];
                            _infantryProfiles pushback [_profileID];

                            _totalCount = _totalCount + 1;

                        };

                        // Handle Groups - spawn inf and vehicles, slingload/paradrop vehicles if necessary

                        private _staticGroupProfiles = [];
                        private _joinGroupProfiles = [];
                        private _reinforceGroupProfiles = [];

                        {

                            private _profileList = _x select 0;
                            private _groupList = _x select 1;

                            {
                                private _group = _x select 0;
                                private _position = _reinforcementPosition getPos [random(200), random(360)];

                                if !(surfaceIsWater _position) then {
                                    private _groupFaction = (_x select 1) select 1;
                                    private _itemCategory = (_x select 1) select 2;

                                    // Handle other infantry groups such as Infantry_WDL
                                    if ([_itemCategory, "Infantry"] call CBA_fnc_find != -1) then {
                                        _itemCategory = "Infantry";
                                    };

                                    // Handle other Motorized groups such as Motorized_WDL
                                    if ([_itemCategory, "Motorized"] call CBA_fnc_find != -1) then {
                                        _itemCategory = "Motorized";
                                    };

                                    // RHS hacky stuff :(
                                    if !(_itemCategory in ["Infantry", "Support", "SpecOps", "Naval", "Armored", "Mechanized", "Motorized", "Air"]) then {
                                        if(!isNil "ALIVE_factionCustomMappings") then {
                                            if(_groupfaction in (ALIVE_factionCustomMappings select 1)) then {
                                                private _customMappings = [ALIVE_factionCustomMappings, _groupfaction] call ALIVE_fnc_hashGet;
                                                _groupfaction = [_customMappings, "GroupFactionName"] call ALIVE_fnc_hashGet;
                                            };
                                        };
                                        private _key = format ["%1_%2", _groupFaction, _group];
                                        private _value = [ALIVE_groupConfig, _key] call ALIVE_fnc_hashGet;
                                        private _side = (_value select 1) select 0;
                                        private _faction = (_value select 1) select 1;
                                        private _category = (_value select 1) select 2;
                                        private _configPath = ((((configFile >> "CfgGroups") select _side) select _faction) select _category) >> "aliveCategory";

                                        if (isText _configPath) then {
                                            _itemCategory = getText _configPath;
                                        } else {
                                            // Try the icon...
                                            private _iconText = getText(((((configFile >> "CfgGroups") select _side) select _faction) select _category) >> _group >> "icon");
                                            switch (true) do {
                                                case ([_iconText,"_air"] call CBA_fnc_find != -1): {
                                                    _itemCategory = "Air";
                                                };
                                                case ([_iconText,"_motor_inf"] call CBA_fnc_find != -1): {
                                                    _itemCategory = "Motorized";
                                                };
                                                case ([_iconText,"_mech_inf"] call CBA_fnc_find != -1): {
                                                    _itemCategory = "Mechanized";
                                                };
                                                case ([_iconText,"_armor"] call CBA_fnc_find != -1): {
                                                    _itemCategory = "Armored";
                                                };
                                                case ([_iconText,"_naval"] call CBA_fnc_find != -1): {
                                                    _itemCategory = "Naval";
                                                };
                                                case ([_iconText,"_recon"] call CBA_fnc_find != -1): {
                                                    _itemCategory = "SpecOps";
                                                };
                                                case ([_iconText,"_art"] call CBA_fnc_find != -1 || [_iconText,"_mortar"] call CBA_fnc_find != -1 || [_iconText,"_antiair"] call CBA_fnc_find != -1): {
                                                    _itemCategory = "Support";
                                                };

                                                default {
                                                     _itemCategory = "Infantry";
                                                };
                                            };
                                            ["ML - WARNING: No item category defined for group %1, using %2 based on group icon.",_group, _itemCategory] call ALIVE_fnc_dump;
                                        };
                                    };

                                    switch (_itemCategory) do {
                                        case "Naval": {
                                            if (_paraDrop) then {
                                                _position set [2, PARADROP_HEIGHT];
                                            } else {
                                                // Find the nearest bit of water
                                                _position = [_position, true] call ALIVE_fnc_getClosestSea;
                                            };
                                        };
                                        case "Air": {
                                            _position = _remotePosition getPos [random(200), random(360)];
                                            _position set [2,1000];
                                        };
                                        default {
                                            if (_eventType == "PR_HELI_INSERT") then {
                                                _position = _remotePosition;
                                            } else {
                                                if (_paraDrop) then {
                                                    _position set [2, PARADROP_HEIGHT];
                                                };
                                            };
                                        };
                                    };

                                    private _profiles = [_group, _position, random(360), false, _groupFaction, true] call ALIVE_fnc_createProfilesFromGroupConfig;
                                    private _profileIDs = [];
                                    private _containsVehicles = 0;

                                    {
                                        private _profileID = _x select 2 select 4;
                                        private _inCargo = _x select 2 select 9;

                                        //Count vehicles in group
                                        if ([_profileID,"vehicle"] call CBA_fnc_find != -1) then {
                                            _containsVehicles = _containsVehicles + 1;
                                        };

                                        _profileIDs pushback _profileID;
                                    } forEach _profiles;

                                    _profileList pushBack _profileIDs;

                                    switch(_itemCategory) do {
                                        case "Infantry":{
                                            _infantryProfiles pushback _profileIDs;
                                        };
                                        case "Support":{
                                            _infantryProfiles pushback _profileIDs;
                                        };
                                        case "SpecOps":{
                                            //If the spec op team, does not have a vehicle (like submarines in A3 vanilla)
                                            //treat them as infantry to allow heli insertion and paradrop
                                            if (_containsVehicles == 0) then {
                                                _infantryProfiles pushback _profileIDs;
                                            } else {
                                                _specOpsProfiles pushback _profileIDs;
                                            };
                                        };
                                        case "Naval":{
                                            _marineProfiles pushback _profileIDs;
                                        };
                                        case "Armored":{
                                            _armourProfiles pushback _profileIDs;
                                        };
                                        case "Mechanized":{
                                             _mechanisedProfiles pushback _profileIDs;
                                        };
                                        case "Motorized":{
                                             _motorisedProfiles pushback _profileIDs;
                                        };
                                        case "Air":{
                                            _heliProfiles pushback _profileIDs;

                                            _profileWaypoint = [_reinforcementPosition, 100, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                            _profile = _profiles select 0;
                                            [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                                        };
                                        default {
                                            ["ML - WARNING: No item category defined for group %1, using infantry.",_group] call ALIVE_fnc_dump;
                                            _infantryProfiles pushback _profileIDs;
                                        };
                                    };

                                    _totalCount = _totalCount + 1;
                                };
                            } forEach _groupList;
                        } forEach [
                            [_staticGroupProfiles, _staticGroups],
                            [_joinGroupProfiles, _joinGroups],
                            [_reinforceGroupProfiles, _reinforceGroups]
                        ];

                        // Handle infantry

                        if(_eventType == "PR_STANDARD") then {

                            // create ground transport vehicles for the profiles

                            _transportGroups = [ALIVE_factionDefaultTransport,_eventFaction,[]] call ALIVE_fnc_hashGet;
                            _transportProfiles = [];
                            _transportVehicleProfiles = [];

                            if(count _transportGroups == 0) then {
                                _transportGroups = [ALIVE_sideDefaultTransport,_side] call ALIVE_fnc_hashGet;
                            };

                            if(count _transportGroups > 0) then {
                                for "_i" from 0 to (count _infantryProfiles) -1 do {

                                    _position = _reinforcementPosition getPos [random(200), random(360)];

                                    if(_paraDrop) then {
                                        _position set [2,PARADROP_HEIGHT];
                                    };

                                    if(count _transportGroups > 0) then {

                                        _vehicleClass = selectRandom _transportGroups;

                                        _profiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,false,true] call ALIVE_fnc_createProfilesCrewedVehicle;

                                        _transportProfiles pushback (_profiles select 0 select 2 select 4);
                                        _transportVehicleProfiles pushback (_profiles select 1 select 2 select 4);

                                    }

                                };
                            };

                            _eventTransportProfiles = _eventTransportProfiles + _transportProfiles;
                            _eventTransportVehiclesProfiles = _eventTransportVehiclesProfiles + _transportVehicleProfiles;

                        };

                        if(_eventType == "PR_HELI_INSERT") then {

                            private ["_infantryProfileID","_infantryProfile","_profileWaypoint","_profile"];

                            // create air transport vehicles for the profiles

                            _transportGroups = [ALIVE_factionDefaultAirTransport,_eventFaction,[]] call ALIVE_fnc_hashGet;
                            _transportProfiles = [];
                            _transportVehicleProfiles = [];

                            if(count _transportGroups == 0) then {
                                _transportGroups = [ALIVE_sideDefaultAirTransport,_side] call ALIVE_fnc_hashGet;
                            };

                            if(count _transportGroups > 0) then {

                                for "_i" from 0 to (count _infantryProfiles) -1 do {

                                    if (_paraDrop) then {
                                        _position = _remotePosition getPos [random(200), random(360)];
                                    } else {
                                        _position = _reinforcementPosition getPos [random(200), random(360)];
                                    };

                                    if(_paraDrop) then {
                                        _position set [2,PARADROP_HEIGHT];
                                    };

                                    if(count _transportGroups > 0) then {

                                        // Select helicopter that can carry most troops
                                        private "_heliTransport";
                                        _heliTransport = 2;
                                        _vehicleClass = _transportGroups select 0;
                                        {
                                            private ["_transport"];
                                            _transport = [(configFile >> "CfgVehicles" >> _x >> "transportSoldier")] call ALiVE_fnc_getConfigValue;
                                            if (_transport > _heliTransport) then {_vehicleClass = _x};
                                        } foreach _transportGroups;


                                        if (_debug) then {
                                            ["ML - Found %1 for heli insert of %2", _vehicleclass, _infantryProfiles] call ALIVE_fnc_dump;
                                        };

                                        // Create profiles
                                        _profiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,true,true] call ALIVE_fnc_createProfilesCrewedVehicle;

                                        _transportProfiles pushback (_profiles select 0 select 2 select 4);
                                        _transportVehicleProfiles pushback (_profiles select 1 select 2 select 4);

                                        _infantryProfileID = _infantryProfiles select _i select 0;
                                        if!(isNil "_infantryProfileID") then {
                                            _infantryProfile = [ALIVE_profileHandler, "getProfile", _infantryProfileID] call ALIVE_fnc_profileHandler;
                                            if!(isNil "_infantryProfile") then {
                                                [_infantryProfile,_profiles select 1] call ALIVE_fnc_createProfileVehicleAssignment;
                                            };
                                        };

                                        _profileWaypoint = [_reinforcementPosition, 100, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                        _profile = _profiles select 0;
                                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

                                    };

                                };

                            } else {
                                ["ML - WARNING: No %1 transport vehicles found for Heli Insert.",_eventFaction] call ALIVE_fnc_dump;
                            };

                            _eventTransportProfiles = _eventTransportProfiles + _transportProfiles;
                            _eventTransportVehiclesProfiles = _eventTransportVehiclesProfiles + _transportVehicleProfiles;

                        };

                        // Handle Groups
                        // set up slingload for groups with vehicles

                        _groupProfiles = _joinGroupProfiles + _reinforceGroupProfiles + _staticGroupProfiles;

                        if(_eventType == "PR_HELI_INSERT" && (count _groupProfiles > 0)) then {

                            // create heli transport vehicles for groups with vehicles

                            _transportGroups = [ALIVE_factionDefaultAirTransport,_eventFaction,[]] call ALIVE_fnc_hashGet;
                            _transportProfiles = [];
                            _transportVehicleProfiles = [];

                            if(count _transportGroups == 0) then {
                                _transportGroups = [ALIVE_sideDefaultAirTransport,_side] call ALIVE_fnc_hashGet;
                            };

                            if(count _transportGroups > 0) then {

                                // For each group - create helis to carry their vehicles

                                {
                                    _groupProfile = _x;

                                    {
                                        private ["_currentDiff","_vehicleClass","_position","_payloadWeight","_slingLoadProfile"];

                                        // Check to see if profile is a vehicle
                                        if ([_x,"vehicle"] call CBA_fnc_find != -1) then {

                                            if (_paraDrop) then {
                                                _position = _remotePosition getPos [random(200), random(360)];
                                            } else {
                                                _position = _reinforcementPosition getPos [random(200), random(360)];
                                            };

                                            // Get the profile
                                            _slingLoadProfile = [ALiVE_ProfileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;

                                            // _slingloadProfile call ALIVE_fnc_inspectHash;

                                            _payloadWeight = [(_slingLoadProfile select 2 select 11)] call ALIVE_fnc_getObjectWeight;

                                            // Select helicopter that can slingload the vehicle
                                            _vehicleClass = "";
                                            _currentDiff = 15000;
                                            {
                                                private ["_capacity","_slingloadmax","_maxLoad","_slingDiff","_loadDiff"];

                                                _slingloadmax = [(configFile >> "CfgVehicles" >> _x >> "slingLoadMaxCargoMass")] call ALiVE_fnc_getConfigValue;

                                                if (!isnil "_slingloadmax") then {
                                                	_slingDiff = _slingloadmax - _payloadWeight;

                                                	if ((_slingDiff < _currentDiff) && (_slingDiff > 0)) then {_currentDiff = _slingDiff; _vehicleClass = _x;};
                                                };
                                            } foreach _transportGroups;

                                            // Cannot find heli big enough to slingload this vehicle.
                                            // Fall back to PR_AIRDROP "Option A" teleport — same
                                            // rationale as the empty-vehicle loop above; keeps
                                            // _totalCount honest and continues the forEach.
                                            if (_vehicleClass == "") then {
                                                if (!isNil "_slingLoadProfile") then {
                                                    [_slingLoadProfile, "position", _eventPosition] call ALIVE_fnc_profileVehicle;
                                                    _payloadGroupProfiles pushback [_x];
                                                    ["ML - PR_HELI_INSERT grouped-vehicle too heavy to sling (weight %1). Teleporting %2 to destination %3 (Option A fallback).",
                                                        _payloadWeight, _x, _eventPosition] call ALiVE_fnc_dump;
                                                } else {
                                                    ["ML - PR_HELI_INSERT weight-fail fallback: profile %1 already un-registered, skipping.", _x] call ALiVE_fnc_dump;
                                                    _totalCount = _totalCount - 1;
                                                };
                                            } else {

                                            _position set [2,PARADROP_HEIGHT];

                                            // Create slingloading heli (slingloading another profile!)
                                            _profiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,true,true,[], [[_x], []]] call ALIVE_fnc_createProfilesCrewedVehicle;

                                            ["HELI PROFILE FOR SLINGLOADING: %1",_profiles select 1 select 2 select 4] call ALiVE_fnc_dump;
                                            // Set slingloaded profile
                                            [_slingloadProfile,"slung",[[_profiles select 1 select 2 select 4]]] call ALIVE_fnc_profileVehicle;

                                            _transportProfiles pushback (_profiles select 0 select 2 select 4);
                                            _transportVehicleProfiles pushback (_profiles select 1 select 2 select 4);

                                            _profileIDs = [];
                                            {
                                                _profileID = _x select 2 select 4;
                                                _profileIDs pushback _profileID;
                                            } forEach _profiles;

                                            _payloadGroupProfiles pushback _profileIDs;

                                            _profileWaypoint = [_reinforcementPosition, 100, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                            _profile = _profiles select 0;
                                            [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

                                            _totalCount = _totalCount + 1;
                                            }; // end else (_vehicleClass == "")
                                        };

                                    } foreach _groupProfile;

                                } foreach _groupProfiles;

                            } else {
                                ["WARNING: No %1 transport vehicles found for Heli Insert.",_eventFaction] call ALIVE_fnc_dump;
                            };

                            _eventTransportProfiles = _eventTransportProfiles + _transportProfiles;
                            _eventTransportVehiclesProfiles = _eventTransportVehiclesProfiles + _transportVehicleProfiles;

                        };

                        // Handle payload

                        // spawn vehicles to fit the requested
                        // payload items in

                        private ["_payloadGroupProfiles","_transportGroups","_transportProfiles","_transportVehicleProfiles","_vehicleClass","_vehicle","_itemClass",
                        "_itemWeight","_payloadWeight","_payloadcount","_payloadSize","_payloadMaxSize"];

                        if(count _payload > 0) then {

                            _payloadWeight = 0;
                            _payloadSize = 0;
                            _payloadMaxSize = 0;
                            {
                                _itemWeight = [_x] call ALIVE_fnc_getObjectWeight;
                                _payloadWeight = _payloadWeight + _itemWeight;
                                _itemSize = [_x] call ALIVE_fnc_getObjectSize;
                                _payloadSize = _payloadSize + _itemSize;
                                if (_itemSize > _payloadMaxSize) then {_payloadMaxSize = _itemSize;};
                            } forEach _payload;

                            _payloadcount = floor(_payloadWeight / 2000);
                            if(_payloadcount <= 0) then {
                                _payloadcount = 1;
                            };
                            _totalCount = _totalCount + _payloadcount;

                            if(_eventType == "PR_STANDARD") then {

                                // create ground transport vehicles for the payload

                                _transportGroups = [ALIVE_factionDefaultTransport,_eventFaction,[]] call ALIVE_fnc_hashGet;
                                _transportProfiles = [];
                                _transportVehicleProfiles = [];

                                if(count _transportGroups == 0) then {
                                    _transportGroups = [ALIVE_sideDefaultTransport,_side] call ALIVE_fnc_hashGet;
                                };

                                if(count _transportGroups > 0) then {

                                    _position = _reinforcementPosition getPos [random(200), random(360)];

                                    if(_paraDrop) then {
                                        _position set [2,PARADROP_HEIGHT];
                                    };

                                    _vehicleClass = selectRandom _transportGroups;

                                    _profiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,false,true,_payload] call ALIVE_fnc_createProfilesCrewedVehicle;

                                    _transportProfiles pushback (_profiles select 0 select 2 select 4);
                                    _transportVehicleProfiles pushback (_profiles select 1 select 2 select 4);

                                    _profileIDs = [];
                                    {
                                        _profileID = _x select 2 select 4;
                                        _profileIDs pushback _profileID;
                                    } forEach _profiles;

                                    _payloadGroupProfiles pushback _profileIDs;

                                };

                                _totalCount = _totalCount + 1;

                                _eventTransportProfiles = _eventTransportProfiles + _transportProfiles;
                                _eventTransportVehiclesProfiles = _eventTransportVehiclesProfiles + _transportVehicleProfiles;

                            };

                            if(_eventType == "PR_HELI_INSERT") then {

                                // If payload weight is greater than maximumLoad, then items are put in a container and slingloaded.

                                // create heli transport vehicles for the payload

                                _transportGroups = [ALIVE_factionDefaultAirTransport,_eventFaction,[]] call ALIVE_fnc_hashGet;
                                _transportProfiles = [];
                                _transportVehicleProfiles = [];

                                if(count _transportGroups == 0) then {
                                    _transportGroups = [ALIVE_sideDefaultAirTransport,_side] call ALIVE_fnc_hashGet;
                                };

                                if(count _transportGroups > 0) then {
                                    private ["_slingload","_currentDiff"];

                                    if (_paraDrop) then {
                                        _position = _remotePosition getPos [random(200), random(360)];
                                    } else {
                                        _position = _reinforcementPosition getPos [random(200), random(360)];
                                    };

                                    // Select helicopter that can carry enough for payload
                                    _vehicleClass = _transportGroups select 0;
                                    _slingload = false;
                                    _currentDiff = 15000;
                                    {
                                        private ["_capacity","_slingloadmax","_maxLoad","_slingDiff","_loadDiff"];

                                        _slingloadmax = [(configFile >> "CfgVehicles" >> _x >> "slingLoadMaxCargoMass")] call ALiVE_fnc_getConfigValue;
                                        _maxLoad = [(configFile >> "CfgVehicles" >> _x >> "maximumLoad")] call ALiVE_fnc_getConfigValue;

                                        if (!isNil "_slingloadmax" && {!isNil "_maxLoad"}) then {
	                                        _slingDiff = _slingloadmax - _payloadWeight;
	                                        _loadDiff = _maxLoad - _payloadWeight;

	                                        if ((_slingDiff < _currentDiff) && (_slingDiff > 0)) then {_currentDiff = _slingDiff; _vehicleClass = _x; _slingload = true;};
	                                        if ((_loadDiff <= _currentDiff) && (_loadDiff > 0)) then {_currentDiff = _loadDiff; _vehicleClass = _x; _slingload = false;};
                                        };
                                    } foreach _transportGroups;

                                    // If total size > vehicle size then force slingload if available
                                    if ( (_payloadSize > [(configFile >> "CfgVehicles" >> _vehicleClass >> "mapSize")] call ALiVE_fnc_getConfigValue) && ([(configFile >> "CfgVehicles" >> _vehicleClass >> "slingLoadMaxCargoMass")] call ALiVE_fnc_getConfigValue > 0)) then {
                                        _slingload = true;
                                    };


                                    _position set [2,PARADROP_HEIGHT];


                                    if (!_slingload) then {
                                        _profiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,true,true,_payload] call ALIVE_fnc_createProfilesCrewedVehicle;

                                    } else {

                                        // Do slingloading
                                        private ["_containers","_containerClass","_container"];

                                        LOG("RESUPPLY WILL BE SLINGLOADING");

                                        // Get a suitable container
                                        _containers = [ALIVE_factionDefaultContainers,_eventFaction,[]] call ALIVE_fnc_hashGet;

                                        if(count _containers == 0) then {
                                            _containers = [ALIVE_sideDefaultContainers,_side] call ALIVE_fnc_hashGet;
                                        };

                                        if(count _containers > 0) then {
                                            private ["_tempContainer","_tempContainerSize"];
                                            if (_paraDrop) then {
                                                _position = _remotePosition getPos [random(200), random(360)];
                                            } else {
                                                _position = _reinforcementPosition getPos [random(200), random(360)];
                                            };

                                            // Choose a good sized container
                                            _containerClass = _containers select 0;

                                            // Find a container big enough and the helicopter can slingload
                                            _tempContainer = _containerClass;
                                            _tempContainerSize = [(configFile >> "CfgVehicles" >> _containerClass >> "mapSize")] call ALiVE_fnc_getConfigValue;
                                            {
                                                private ["_containerSize","_heliCanSling"];
                                                _containerSize = [(configFile >> "CfgVehicles" >> _x >> "mapSize")] call ALiVE_fnc_getConfigValue;

                                                // Work around for cargo container that is 7500kg
                                                _heliCanSling = if ([(configFile >> "CfgVehicles" >> _vehicleClass >> "slingLoadMaxCargoMass")] call ALiVE_fnc_getConfigValue < 7500 && _x == "B_Slingload_01_Cargo_F") then {false;}else{true;};

                                                if (_containerSize > _tempContainerSize && _heliCanSling) then {_tempContainer = _x; _tempContainerSize = _containerSize;};

                                                TRACE_3("RESUPPLY", _payloadMaxSize, _containerSize, _x);

                                                if ((_containerSize * 2) > _payloadMaxSize && _heliCanSling) exitWith {_containerClass = _x;};
                                            } foreach _containers;

                                            // If no container is big enough, then just use biggest
                                            if (_tempContainerSize > [(configFile >> "CfgVehicles" >> _containerClass >> "mapSize")] call ALiVE_fnc_getConfigValue) then {
                                                _containerClass = _tempContainer;
                                            };

                                            // Create slingloading heli
                                            _profiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_position,random(360),false,_eventFaction,true,true,[], [_containerClass, _payload]] call ALIVE_fnc_createProfilesCrewedVehicle;

                                        };
                                    };

                                    _transportProfiles pushback (_profiles select 0 select 2 select 4);
                                    _transportVehicleProfiles pushback (_profiles select 1 select 2 select 4);

                                    _profileIDs = [];
                                    {
                                        _profileID = _x select 2 select 4;
                                        _profileIDs pushback _profileID;
                                    } forEach _profiles;

                                    _payloadGroupProfiles pushback _profileIDs;

                                    _profileWaypoint = [_reinforcementPosition, 100, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                    _profile = _profiles select 0;
                                    [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

                                };

                                _totalCount = _totalCount + 1;

                                _eventTransportProfiles = _eventTransportProfiles + _transportProfiles;
                                _eventTransportVehiclesProfiles = _eventTransportVehiclesProfiles + _transportVehicleProfiles;

                            };

                            private ["_containers","_vehicle","_parachute","_soundFlyover"];

                            if(_eventType == "PR_AIRDROP") then {

                                _containers = [ALIVE_factionDefaultContainers,_eventFaction,[]] call ALIVE_fnc_hashGet;

                                if(count _containers == 0) then {
                                    _containers = [ALIVE_sideDefaultContainers,_side] call ALIVE_fnc_hashGet;
                                };

                                if(count _containers > 0) then {

                                    _position = _reinforcementPosition getPos [random(200), random(360)];

                                    if(_paraDrop) then {
                                        _position set [2,PARADROP_HEIGHT];
                                    };

                                    _vehicleClass = selectRandom _containers;

                                    //_profile = [_vehicleClass,_side,_eventFaction,_position,random(360),false,_eventFaction,_payload] call ALIVE_fnc_createProfileVehicle;

                                    // Route ground-spawned reinforcement containers through
                                    // the unified vehicle spawn validator (#850). Random
                                    // 200 m scatter from the cluster lands on unvalidated
                                    // ground - bbox-aware footprint check rejects buildings
                                    // / walls / fences. Paradrop containers descend under
                                    // canopy and don't need ground-footprint validation -
                                    // the parachute touchdown handles placement.
                                    if (!_paraDrop) then {
                                        private _spawnResult = [_vehicleClass, _position, 50, "auto"] call ALiVE_fnc_findVehicleSpawnPosition;
                                        if (count _spawnResult >= 2) then {
                                            _position = _spawnResult select 0;
                                        };
                                    };

                                    _vehicle = createVehicle [_vehicleClass, _position, [], 0, "NONE"];

                                    clearItemCargoGlobal _vehicle;
                                    clearMagazineCargoGlobal _vehicle;
                                    clearWeaponCargoGlobal _vehicle;

                                    [ALiVE_SYS_LOGISTICS,"fillContainer",[_vehicle,_payload]] call ALiVE_fnc_Logistics;

                                    if(_paraDrop) then {
                                        _parachute = createvehicle ["B_Parachute_02_F",position _vehicle ,[],0,"none"];
                                        _vehicle attachto [_parachute,[0,0,(abs ((boundingbox _vehicle select 0) select 2))]];

                                        _parachute setpos position _vehicle;
                                        _parachute setdir direction _vehicle;
                                        _parachute setvelocity [0,0,-1];

                                        if (time - (missionnamespace getvariable ["bis_fnc_curatorobjectedited_paraSoundTime",0]) > 0) then {
                                            _soundFlyover = selectRandom ["BattlefieldJet1","BattlefieldJet2"];
                                            [_parachute,_soundFlyover,"say3d"] remoteExec ["bis_fnc_sayMessage"];
                                            missionnamespace setvariable ["bis_fnc_curatorobjectedited_paraSoundTime",time + 10]
                                        };

                                        [_vehicle,_parachute] spawn {
                                            _vehicle = _this select 0;
                                            _parachute = _this select 1;

                                            waituntil {isnull _parachute || isnull _vehicle};
                                            _vehicle setdir direction _vehicle;
                                            deletevehicle _parachute;

                                            [_vehicle] call ALIVE_fnc_MLAttachSmokeOrStrobe;
                                        };
                                    };

                                };

                                _totalCount = _totalCount + 1;
                            };

                        };


                        [_playerRequestProfiles,"empty",_emptyVehicleProfiles] call ALIVE_fnc_hashSet;
                        [_playerRequestProfiles,"joinIndividuals",_joinIndividualProfiles] call ALIVE_fnc_hashSet;
                        [_playerRequestProfiles,"staticIndividuals",_staticIndividualProfiles] call ALIVE_fnc_hashSet;
                        [_playerRequestProfiles,"reinforceIndividuals",_reinforceIndividualProfiles] call ALIVE_fnc_hashSet;
                        [_playerRequestProfiles,"joinGroups",_joinGroupProfiles] call ALIVE_fnc_hashSet;
                        [_playerRequestProfiles,"staticGroups",_staticGroupProfiles] call ALIVE_fnc_hashSet;
                        [_playerRequestProfiles,"reinforceGroups",_reinforceGroupProfiles] call ALIVE_fnc_hashSet;
                        [_playerRequestProfiles,"payloadGroups",_payloadGroupProfiles] call ALIVE_fnc_hashSet;
                        [_event, "playerRequestProfiles", _playerRequestProfiles] call ALIVE_fnc_hashSet;


                        [_eventCargoProfiles, "armour", _armourProfiles] call ALIVE_fnc_hashSet;
                        [_eventCargoProfiles, "infantry", _infantryProfiles] call ALIVE_fnc_hashSet;
                        [_eventCargoProfiles, "mechanised", _mechanisedProfiles] call ALIVE_fnc_hashSet;
                        [_eventCargoProfiles, "motorised", _motorisedProfiles] call ALIVE_fnc_hashSet;
                        [_eventCargoProfiles, "heli", _heliProfiles] call ALIVE_fnc_hashSet;
                        [_eventCargoProfiles, "plane", _planeProfiles] call ALIVE_fnc_hashSet;


                        // DEBUG -------------------------------------------------------------------------------------
                        if(_debug) then {
                            ["ML - Profiles created: %1 ",_totalCount] call ALiVE_fnc_dump;
                            switch(_eventType) do {
                                case "PR_STANDARD": {
                                    [_logic, "createMarker", [_reinforcementPosition,_eventFaction,"PR CONVOY START"]] call MAINCLASS;
                                };
                                case "PR_HELI_INSERT": {
                                    [_logic, "createMarker", [_reinforcementPosition,_eventFaction,"PR AIR INSERTION"]] call MAINCLASS;
                                };
                                case "PR_AIRDROP": {
                                    [_logic, "createMarker", [_eventPosition,_eventFaction,"PR AIRDROP"]] call MAINCLASS;
                                };
                            };
                        };
                        // DEBUG -------------------------------------------------------------------------------------


                        if(_totalCount > 0) then {

                            // remove the created group count
                            // from the force pool
                            _forcePool = _forcePool - _totalCount;
                            // update the global force pool
                            [ALIVE_MLGlobalRegistry,"updateGlobalForcePool",[_registryID,_forcePool]] call ALIVE_fnc_MLGlobalRegistry;

                            switch(_eventType) do {
                                case "PR_STANDARD": {

                                    // Store departure position on event hash for consistency
                                    // with HELI_INSERT / AIRDROP paths. Used by debug dumps and
                                    // could be referenced by future garrison position logic.
                                    [_event, "departurePosition", _reinforcementPosition] call ALIVE_fnc_hashSet;

                                    // update the state of the event
                                    // next state is transport load
                                    [_event, "state", "transportLoad"] call ALIVE_fnc_hashSet;

                                    // dispatch event
                                    _logEvent = ['LOGISTICS_INSERTION', [_reinforcementPosition,_eventFaction,_side,_eventID],"Logistics"] call ALIVE_fnc_event;
                                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                                };
                                case "PR_HELI_INSERT": {

                                    // update the state of the event
                                    // next state is transport load
                                    [_event, "state", "heliTransportStart"] call ALIVE_fnc_hashSet;

                                    // dispatch event
                                    _logEvent = ['LOGISTICS_INSERTION', [_reinforcementPosition,_eventFaction,_side,_eventID],"Logistics"] call ALIVE_fnc_event;
                                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                                };
                                case "PR_AIRDROP": {

                                    // ============================================================
                                    // PR_AIRDROP transport aircraft creation
                                    // ------------------------------------------------------------
                                    // Mirrors HELI_INSERT slingload + HELI_PARADROP infantry patterns.
                                    // - Slingload helis for any motorised/mechanised vehicles
                                    // - One infantry heli for all infantry profiles combined
                                    // - Too-heavy cargo teleported to _eventPosition (Option A fallback)
                                    // Root-cause fixes applied from 2026-04-16 log analysis:
                                    //   * Spawn Z=0 (ground) not PARADROP_HEIGHT -- slung cargo at altitude
                                    //     causes immediate in-air collision and destroys the heli
                                    //   * preventDespawn on entity/vehicle/slung profiles -- without it
                                    //     ALiVE virtualises the heli mid-flight when players move away
                                    //   * Infantry assigned to transport via createProfileVehicleAssignment
                                    //     -- without it the infantry never physically board the heli
                                    // ============================================================

                                    private _airdropTransportProfiles = [];
                                    private _airdropTransportVehicleProfiles = [];
                                    private _airdropInfTransportProfID = "";

                                    private _airdropTransportGroups = [ALIVE_factionDefaultAirTransport,_eventFaction,[]] call ALIVE_fnc_hashGet;
                                    if (count _airdropTransportGroups == 0 || !_limitTransportToFaction) then {
                                        _airdropTransportGroups append ([ALIVE_sideDefaultAirTransport,_side] call ALIVE_fnc_hashGet);
                                    };

                                    if (count _airdropTransportGroups > 0) then {

                                        // ---- Part A: slingload helis for vehicle cargo ----
                                        private _vehicleGroupProfilesForSling = _motorisedProfiles + _mechanisedProfiles;
                                        private _slingHeliSpawnIdx = 0;

                                        {
                                            private _groupProfile = _x;
                                            {
                                                if ([_x,"vehicle"] call CBA_fnc_find != -1) then {
                                                    private _slingLoadProfile = [ALiVE_ProfileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                                    if (!isNil "_slingLoadProfile") then {
                                                        private _payloadWeight = [(_slingLoadProfile select 2 select 11)] call ALIVE_fnc_getObjectWeight;

                                                        // Find heli that can slingload this weight
                                                        private _vehicleClass = "";
                                                        private _currentDiff = 15000;
                                                        {
                                                            private _slingloadmax = [(configFile >> "CfgVehicles" >> _x >> "slingLoadMaxCargoMass")] call ALiVE_fnc_getConfigValue;
                                                            if (!isNil "_slingloadmax") then {
                                                                private _slingDiff = _slingloadmax - _payloadWeight;
                                                                if ((_slingDiff < _currentDiff) && (_slingDiff > 0)) then {
                                                                    _currentDiff = _slingDiff;
                                                                    _vehicleClass = _x;
                                                                };
                                                            };
                                                        } forEach _airdropTransportGroups;

                                                        if (_vehicleClass == "") then {
                                                            // Too heavy to sling -- teleport profile to destination (Option A fallback)
                                                            ["ML - PR_AIRDROP: cargo %1 weight %2 too heavy to sling (no heli match). Teleporting to destination %3.",
                                                                _x, _payloadWeight, _eventPosition] call ALiVE_fnc_dump;
                                                            [_slingLoadProfile, "position", _eventPosition] call ALIVE_fnc_profileVehicle;
                                                        } else {
                                                            // Find ground spawn pos near supply node, Z=0
                                                            private _spawnMin = 400 + (_slingHeliSpawnIdx * 400);
                                                            private _spawnMax = _spawnMin + 300;
                                                            private _slingSpawnPos = [_logic, "findHelicopterLandingPos", [
                                                                _remotePosition, _spawnMin, _spawnMax
                                                            ]] call MAINCLASS;
                                                            _slingSpawnPos set [2, 0]; // ground spawn -- see fix 1
                                                            _slingHeliSpawnIdx = _slingHeliSpawnIdx + 1;

                                                            if (_debug) then {
                                                                ["ML - PR_AIRDROP slingload heli spawn pos (ground): %1 class: %2 (idx=%3)",
                                                                    _slingSpawnPos, _vehicleClass, _slingHeliSpawnIdx - 1] call ALiVE_fnc_dump;
                                                            };

                                                            // Create slingloading heli crew/vehicle pair
                                                            private _slingProfiles = [_vehicleClass,_side,_eventFaction,"CAPTAIN",_slingSpawnPos,random(360),false,_eventFaction,true,true,[], [[_x], []]] call ALIVE_fnc_createProfilesCrewedVehicle;

                                                            // Attach sling state
                                                            [_slingLoadProfile,"slung",[[_slingProfiles select 1 select 2 select 4]]] call ALIVE_fnc_profileVehicle;

                                                            _airdropTransportProfiles pushback (_slingProfiles select 0 select 2 select 4);
                                                            _airdropTransportVehicleProfiles pushback (_slingProfiles select 1 select 2 select 4);

                                                            // preventDespawn on all three profiles -- fix 2
                                                            private _heliEntityProf  = _slingProfiles select 0;
                                                            private _heliVehicleProf = _slingProfiles select 1;
                                                            [_heliEntityProf, "spawnType", ["preventDespawn"]] call ALIVE_fnc_hashSet;
                                                            [_heliVehicleProf, "spawnType", ["preventDespawn"]] call ALIVE_fnc_profileVehicle;
                                                            [_slingLoadProfile, "spawnType", ["preventDespawn"]] call ALIVE_fnc_profileVehicle;
                                                            [_heliVehicleProf, "alive_ml_pilot_entity_id",
                                                                _heliEntityProf select 2 select 4] call ALIVE_fnc_hashSet;

                                                            if (_debug) then {
                                                                ["ML - PR_AIRDROP slingload: preventDespawn set on pilot %1 heli %2 truck %3",
                                                                    _slingProfiles select 0 select 2 select 4,
                                                                    _slingProfiles select 1 select 2 select 4, _x] call ALiVE_fnc_dump;
                                                            };

                                                            // Fuel watchdog
                                                            [_logic, "spawnHelicopterFuelWatchdog", [
                                                                _slingProfiles select 0 select 2 select 4,
                                                                _remotePosition,
                                                                _eventFaction
                                                            ]] call MAINCLASS;
                                                        };
                                                    };
                                                };
                                            } forEach _groupProfile;
                                        } forEach _vehicleGroupProfilesForSling;

                                        // ---- Part B: infantry heli for all infantry profiles ----
                                        if (count _infantryProfiles > 0) then {
                                            private _infSpawnPos = [_logic, "findHelicopterLandingPos", [
                                                _remotePosition, 200, 500
                                            ]] call MAINCLASS;
                                            _infSpawnPos set [2, 0]; // ground spawn -- fix 1

                                            private _infHeliClass = selectRandom _airdropTransportGroups;
                                            private _infProfiles = [_infHeliClass,_side,_eventFaction,"CAPTAIN",_infSpawnPos,random(360),false,_eventFaction,true,true] call ALIVE_fnc_createProfilesCrewedVehicle;

                                            _airdropInfTransportProfID = _infProfiles select 0 select 2 select 4;
                                            _airdropTransportProfiles pushback _airdropInfTransportProfID;
                                            _airdropTransportVehicleProfiles pushback (_infProfiles select 1 select 2 select 4);

                                            // preventDespawn on pilot + heli -- fix 2
                                            private _infHeliEntityProf  = _infProfiles select 0;
                                            private _infHeliVehicleProf = _infProfiles select 1;
                                            [_infHeliEntityProf, "spawnType", ["preventDespawn"]] call ALIVE_fnc_hashSet;
                                            [_infHeliVehicleProf, "spawnType", ["preventDespawn"]] call ALIVE_fnc_profileVehicle;
                                            [_infHeliVehicleProf, "alive_ml_pilot_entity_id",
                                                _infHeliEntityProf select 2 select 4] call ALIVE_fnc_hashSet;

                                            // Assign all infantry to the heli -- fix 3
                                            {
                                                private _grpIDs = _x;
                                                {
                                                    if (!isNil "_x") then {
                                                        private _infantryProfile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                                        if (!isNil "_infantryProfile") then {
                                                            [_infantryProfile, _infProfiles select 1] call ALIVE_fnc_createProfileVehicleAssignment;
                                                            [_infantryProfile, "position", _infSpawnPos] call ALIVE_fnc_profileEntity;
                                                        };
                                                    };
                                                } forEach _grpIDs;
                                            } forEach _infantryProfiles;

                                            if (_debug) then {
                                                ["ML - PR_AIRDROP infantry heli: class=%1 spawn=%2 profID=%3 infantry groups=%4",
                                                    _infHeliClass, _infSpawnPos, _airdropInfTransportProfID, count _infantryProfiles] call ALiVE_fnc_dump;
                                            };

                                            // Fuel watchdog
                                            [_logic, "spawnHelicopterFuelWatchdog", [
                                                _airdropInfTransportProfID,
                                                _remotePosition,
                                                _eventFaction
                                            ]] call MAINCLASS;
                                        };

                                        // ---- Part C: assign destination waypoint to all transports ----
                                        // Unified single-WP-per-heli loop (bug 6 fix: no double waypoint)
                                        {
                                            private _tProfile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                            if (!isNil "_tProfile") then {
                                                private _destWP = [_eventPosition, 200, "MOVE", "LIMITED", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                                [_tProfile, "addWaypoint", _destWP] call ALIVE_fnc_profileEntity;
                                            };
                                        } forEach _airdropTransportProfiles;

                                        _eventTransportProfiles = _eventTransportProfiles + _airdropTransportProfiles;
                                        _eventTransportVehiclesProfiles = _eventTransportVehiclesProfiles + _airdropTransportVehicleProfiles;

                                    } else {
                                        ["ML - PR_AIRDROP: No air transport assets found for faction=%1 side=%2. Falling back to teleport -- profiles placed at destination.",
                                            _eventFaction, _side] call ALiVE_fnc_dump;
                                        // Fallback: teleport all cargo profiles to destination
                                        {
                                            {
                                                private _p = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                                if (!isNil "_p") then {
                                                    [_p, "position", _eventPosition] call ALIVE_fnc_profileEntity;
                                                };
                                            } forEach _x;
                                        } forEach (_infantryProfiles + _motorisedProfiles + _mechanisedProfiles);
                                    };

                                    // Store positions and infantry transport ID on event hash for state handlers
                                    [_event, "departurePosition", _remotePosition] call ALIVE_fnc_hashSet;
                                    [_event, "finalDestination", _eventPosition] call ALIVE_fnc_hashSet;
                                    [_event, "airdropInfTransportProfID", _airdropInfTransportProfID] call ALIVE_fnc_hashSet;

                                    // update the state of the event
                                    // next state is airdropStart (full implementation, not stub)
                                    [_event, "state", "airdropStart"] call ALIVE_fnc_hashSet;

                                    // dispatch event
                                    _logEvent = ['LOGISTICS_DESTINATION', [_eventPosition,_eventFaction,_side,_eventID],"Logistics"] call ALIVE_fnc_event;
                                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                                };
                            };

                            [_event, "cargoProfiles", _eventCargoProfiles] call ALIVE_fnc_hashSet;
                            [_event, "transportProfiles", _eventTransportProfiles] call ALIVE_fnc_hashSet;
                            [_event, "transportVehiclesProfiles", _eventTransportVehiclesProfiles] call ALIVE_fnc_hashSet;

                            [_logic, "prepareUnitCounts", _event] call MAINCLASS;

                            [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                            // respond to player request
                            _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","REQUEST_INSERTION"] call ALIVE_fnc_event;
                            [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                        }else{

                            // respond to player request
                            _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","DENIED_FORCE_CREATION"] call ALIVE_fnc_event;
                            [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                            // no profiles were created
                            // nothing to do so cancel..
                            [_logic, "removeEvent", _eventID] call MAINCLASS;
                        };

                    };
                }else{

                    // no insertion point available
                    // nothing to do so cancel..
                    [_logic, "removeEvent", _eventID] call MAINCLASS;

                    // respond to player request
                    _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID],"Logistics","DENIED_NOT_AVAILABLE"] call ALIVE_fnc_event;
                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                };
            };
        };
    };

    case "prepareUnitCounts": {
        private _event = _args;
        private _eventCargoProfiles = [_event, "cargoProfiles"] call ALIVE_fnc_hashGet;
        private _playerRequested = [_event, "playerRequested"] call ALIVE_fnc_hashGet;
        private _playerRequestProfiles = [_event, "playerRequestProfiles"] call ALIVE_fnc_hashGet;
        private _unitCounts = [] call ALIVE_fnc_hashCreate;

        private _eventTransportProfiles = [_event, "transportProfiles"] call ALIVE_fnc_hashGet;
        [_unitCounts,"transport",count _eventTransportProfiles] call ALIVE_fnc_hashSet;

        private _eventTransportVehiclesProfiles = [_event, "transportVehiclesProfiles"] call ALIVE_fnc_hashGet;
        [_unitCounts,"transportVehicle",count _eventTransportVehiclesProfiles] call ALIVE_fnc_hashSet;

        {
            private _list = _x select 0;
            private _condition = _x select 1;
            private _categories = _x select 2;

            if (_condition) then {
                {
                    private _category = _x;
                    private _profiles = [_list, _category] call ALIVE_fnc_hashGet;
                    [_unitCounts, _category, count _profiles] call ALIVE_fnc_hashSet;
                } forEach _categories;
            };
        } forEach [
            [_eventCargoProfiles, true, ["infantry", "armour", "mechanised", "motorised", "plane", "heli"]],
            [_playerRequestProfiles, _playerRequested, ["empty", "joinIndividuals", "staticIndividuals",
                                                        "reinforceIndividuals", "joinGroups", "staticGroups",
                                                        "reinforceGroups", "payloadGroups"]]
        ];

        [_event, "initialUnitCounts", _unitCounts] call ALIVE_fnc_hashSet;
    };

    // takes an event
    // and removes any dead profileIDs from event data

    case "checkEvent": {
        private _event = _args;
        private _eventCargoProfiles = [_event, "cargoProfiles"] call ALIVE_fnc_hashGet;
        private _playerRequested = [_event, "playerRequested"] call ALIVE_fnc_hashGet;
        private _playerRequestProfiles = [_event, "playerRequestProfiles"] call ALIVE_fnc_hashGet;
        private _totalCount = 0;
        private _unitCounts = [] call ALIVE_fnc_hashCreate;

        private _eventTransportProfiles = [_event, "transportProfiles"] call ALIVE_fnc_hashGet;
        _eventTransportProfiles = [_logic, "removeUnregisteredProfiles", _eventTransportProfiles] call MAINCLASS;

        [_unitCounts, "transport", count _eventTransportProfiles] call ALIVE_fnc_hashSet;
        [_event, "transportProfiles", _eventTransportProfiles] call ALIVE_fnc_hashSet;

        private _eventTransportVehiclesProfiles = [_event, "transportVehiclesProfiles"] call ALIVE_fnc_hashGet;
        _eventTransportVehiclesProfiles = [_logic, "removeUnregisteredProfiles", _eventTransportVehiclesProfiles] call MAINCLASS;

        [_unitCounts,"transportVehicle", count _eventTransportVehiclesProfiles] call ALIVE_fnc_hashSet;
        [_event, "transportVehiclesProfiles", _eventTransportVehiclesProfiles] call ALIVE_fnc_hashSet;

        {
            private _list = _x select 0;
            private _condition = _x select 1;
            private _categories = _x select 2;

            if (_condition) then {
                {
                    private _category = _x;
                    private _profiles = [_list, _category] call ALIVE_fnc_hashGet;

                    {
                        private _profile = _x;
                        _profile = [_logic, "removeUnregisteredProfiles", _profile] call MAINCLASS;
                        _profiles set [_forEachIndex, _profile];
                    } forEach _profiles;

                    _totalCount = _totalCount + (count _profiles);
                    [_unitCounts, _category, count _profiles] call ALIVE_fnc_hashSet;
                    [_list, _category, _profiles] call ALIVE_fnc_hashSet;
                } forEach _categories;
            };
        } forEach [
            [_eventCargoProfiles, true, ["infantry", "armour", "mechanised", "motorised", "plane", "heli"]],
            [_playerRequestProfiles, _playerRequested, ["empty", "joinIndividuals", "staticIndividuals",
                                                        "reinforceIndividuals", "joinGroups", "staticGroups",
                                                        "reinforceGroups", "payloadGroups"]]
        ];

        [_event, "currentUnitCounts", _unitCounts] call ALIVE_fnc_hashSet;

        _result = _totalCount;
    };

    // takes an array of profileIDs
    // and returns a new array with the inactive profileIDs removed

    case "removeUnregisteredProfiles": {

        private _profiles = _args;

        _result = _profiles select { !isNil { [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler } };

    };

    // takes an entity profile
    // and returns true if it has zero active waypoints

    case "checkWaypointCompleted": {

        private ["_entityProfile","_debug","_active","_profileID","_waypointCompleted"];

        _entityProfile = _args;

        _debug = [_logic, "debug"] call MAINCLASS;

        _active = _entityProfile select 2 select 1;
        _profileID = _entityProfile select 2 select 4;

        _waypointCompleted = false;

        if(_active) then {
            private ["_group","_leader","_currentPosition","_currentWaypoint","_waypoints","_waypointCount",
            "_destination","_completionRadius","_distance"];

            _group = _entityProfile select 2 select 13;

            if !(!isnil "_group" && {typeName _group == "GROUP"}) exitwith {_waypointCompleted = true};

            _leader = leader _group;
            _currentPosition = position _leader;
            _currentWaypoint = currentWaypoint _group;
            _waypoints = waypoints _group;

            if (count _waypoints == 0) exitWith {_waypointCompleted = true};

            _currentWaypoint = _waypoints select ((count _waypoints)-1);

            if!(isNil "_currentWaypoint") then {

                _destination = waypointPosition _currentWaypoint;
                _completionRadius = waypointCompletionRadius _currentWaypoint;

                _completionRadius = (_completionRadius * 2) + 20;

                _distance = _currentPosition distance _destination;

                if(_distance < _completionRadius) then {
                    _waypointCompleted = true;
                };

            }else{
                _waypointCompleted = true;
            }

        } else {
            private ["_waypoints"];

            _waypoints = [_entityProfile,"waypoints"] call ALIVE_fnc_hashGet;

            if!(isNil "_waypoints") then {
                if(count _waypoints == 0) then {
                    _waypointCompleted = true;
                };
            }else{
                _waypointCompleted = true;
            }
        };

        _result = _waypointCompleted;

    };

    case "setHelicopterTravel": {

        private _entityProfile = _args;

        private _active = _entityProfile select 2 select 1;

        if(_active) then {

            private _group = _entityProfile select 2 select 13;

            _group setBehaviour "CARELESS";
            _group allowFleeing 0;
            _group setCombatMode "BLUE";
            _group setSpeedMode "FULL";

            {
                private _unit = _x;
                _unit disableAI "AUTOTARGET";
                _unit disableAI "TARGET";
                _unit setSkill 1;
                // Set courage explicitly -- allowFleeing 0 can be overridden by the engine
                // under suppression fire. courage 1 provides a second layer of resistance.
                _unit setSkill ["courage", 1];

                // Fly faster when enemies are nearby
                private _nearEnemies = (position _unit) nearEntities [["Man","Car","Tank","Air"], 1500];
                private _enemyNear = _nearEnemies select { side _x != side _unit };
                if (count _enemyNear > 0) then {
                    _unit forceSpeed 70;
                } else {
                    _unit forceSpeed 50;
                };
            } forEach (units _group);

        }else{
            [_entityProfile,"spawn"] call ALIVE_fnc_profileEntity;
        }

    };
    
    case "forceHelicopterLanding": {

        // Called when a helicopter transport has been hovering too long
        // at its destination without landing. Forces a landAt command
        // to a validated nearby position.

        private _entityProfile = _args select 0;
        private _targetPos     = _args select 1;
        private _debug         = [_logic, "debug"] call MAINCLASS;

        private _active = _entityProfile select 2 select 1;

        if (_active) then {
            private _heli = _entityProfile select 2 select 10;

            if (!isNull _heli && alive _heli) then {

                private _posASL    = getPosASL _heli;
                private _groundASL = getTerrainHeightASL _posASL;
                private _heightAGL = (_posASL select 2) - _groundASL;
                private _spd       = speed _heli;

                // Only intervene if clearly hovering - airborne and slow
                if (_heightAGL > 5 && _spd < 8) then {

                // Validate target position before searching near it
                if (typeName _targetPos != "ARRAY" || count _targetPos < 2) then {
                    ["ML - forceHelicopterLanding: WARNING invalid _targetPos %1 for heli %2, using heli current position",
                        _targetPos, _heli] call ALiVE_fnc_dump;
                    _targetPos = getPosATL _heli;
                };

                // Use the helicopter's current position as the land target,
                // offset slightly to avoid obstructions directly below.
                // Use heli's current position projected to ground as land target
                // BIS_fnc_findSafePos is unreliable on Takistan and can return sky positions
                private _landPos = getPosATL _heli;
                _landPos set [2, 0];

                if (_debug) then {
                    ["ML - forceHelicopterLanding: Heli %1 hovering at %2m AGL speed %3. Forcing land at %4",
                        _heli, _heightAGL, _spd, _landPos] call ALiVE_fnc_dump;
                };

                // Clear existing waypoints and issue direct land command
                private _group = _entityProfile select 2 select 13;
                if (!isNull _group) then {
                    while {count (waypoints _group) > 0} do {
                        deleteWaypoint [_group, 0];
                    };
                };

                // landAt requires an object - create a temporary helipad at the target pos
                if (typeName _landPos == "ARRAY" && count _landPos >= 2) then {

                    if (count _landPos == 2) then { _landPos pushback 0; };

                    private _tempPad = createVehicle ["Land_HelipadEmpty_F", _landPos, [], 0, "CAN_COLLIDE"];

                    [_heli, _tempPad] spawn {
                        private _heli   = _this select 0;
                        private _tmpPad = _this select 1;
                        _heli landAt _tmpPad;
                        // Wait until heli has landed or 60s timeout, then delete pad
                        private _t = 0;
                        waitUntil { sleep 2; _t = _t + 2; (isTouchingGround _heli || !alive _heli || _t > 60) };
                        deleteVehicle _tmpPad;
                    };

                    ["ML - forceHelicopterLanding: landAt issued to %1 via temp helipad at %2", _heli, _landPos] call ALiVE_fnc_dump;
                } else {
                    ["ML - forceHelicopterLanding: WARNING could not determine safe land position for %1, skipping landAt",
                        _heli] call ALiVE_fnc_dump;
                };
                };
            };
        };
    };
    
    case "spawnStalledUnitWatchdog": {

        // Monitors a set of cargo profiles after delivery.
        // If units have not moved meaningfully within the check period
        // a new waypoint toward the event destination is issued to
        // kick them out of any idle state before OPCOM picks them up.
        // Args: [_cargoProfileIDs, _eventPosition, _eventFaction, _side]

        private _profileIDs  = _args select 0;
        private _destPos     = _args select 1;
        private _faction     = _args select 2;
        private _side        = _args select 3;
        private _debug       = [_logic, "debug"] call MAINCLASS;

        if (_debug) then {
            ["ML - spawnStalledUnitWatchdog: Starting for %1 profiles destination %2",
                count _profileIDs, _destPos] call ALiVE_fnc_dump;
        };

        [_profileIDs, _destPos, _faction, _side, _debug] spawn {

            private _profileIDs = _this select 0;
            private _destPos    = _this select 1;
            private _faction    = _this select 2;
            private _side       = _this select 3;
            private _debug      = _this select 4;

            // Allow time for units to dismount and OPCOM to pick them up normally
            sleep 120;

            private _checkInterval   = 60;
            private _maxChecks       = 5;
            private _movementThreshold = 50; // metres - less than this = stalled

            for "_check" from 1 to _maxChecks do {

                sleep _checkInterval;

                {
                    private _profileID = _x;
                    private _profile = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;

                    if (!isNil "_profile") then {

                        private _active   = _profile select 2 select 1;
                        private _busy     = [_profile, "busy", false] call ALIVE_fnc_hashGet;
                        private _pos      = _profile select 2 select 2;
                        private _profileType = _profile select 2 select 5;

                        // Only check entity profiles (infantry/crews) not vehicles
                        if (_profileType == "entity" && !_busy) then {

                            private _waypoints = [_profile, "waypoints"] call ALIVE_fnc_hashGet;
                            private _hasWaypoints = !isNil "_waypoints" && {count _waypoints > 0};

                            if (_active) then {
                                // Profile is spawned - check actual unit movement
                                private _group = _profile select 2 select 13;
                                if (!isNull _group) then {
                                    private _leader = leader _group;
                                    private _distToDest = position _leader distance _destPos;
                                    private _currentWPs = waypoints _group;

                                    // If close enough to destination consider done
                                    if (_distToDest < 200) exitWith {};

                                    // If no waypoints and not at destination - stalled
                                    if (count _currentWPs == 0) then {
                                        if (_debug) then {
                                            ["ML - spawnStalledUnitWatchdog: Profile %1 active, no waypoints, dist to dest %2m. Assigning move waypoint.",
                                                _profileID, _distToDest] call ALiVE_fnc_dump;
                                        };

                                        private _moveWP = _group addWaypoint [_destPos, 50];
                                        _moveWP setWaypointType "MOVE";
                                        _moveWP setWaypointBehaviour "AWARE";
                                        _moveWP setWaypointCombatMode "YELLOW";
                                        _moveWP setWaypointSpeed "NORMAL";
                                        _group setCurrentWaypoint _moveWP;
                                    };
                                };
                            } else {
                                // Profile not spawned - if no waypoints assign one
                                if (!_hasWaypoints) then {
                                    private _distToDest = _pos distance _destPos;

                                    if (_distToDest > 200) then {
                                        if (_debug) then {
                                            ["ML - spawnStalledUnitWatchdog: Profile %1 inactive, no waypoints, dist %2m. Assigning profile waypoint.",
                                                _profileID, _distToDest] call ALiVE_fnc_dump;
                                        };

                                        private _profileWaypoint = [_destPos, 50, "MOVE", "AWARE", 100, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                        [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                                    };
                                };
                            };
                        };
                    };
                } forEach _profileIDs;
            };

            if (_debug) then {
                ["ML - spawnStalledUnitWatchdog: Watchdog complete for destination %1", _destPos] call ALiVE_fnc_dump;
            };
        };
    };

    case "unloadTransport": {

        private ["_event","_entityProfile","_active","_profileID","_vehiclesInCommandOf","_debug","_eventID","_eventData","_eventCargoProfiles",
        "_eventTransportProfiles","_eventTransportVehiclesProfiles","_playerRequested","_playerRequestProfiles","_eventPosition",
        "_eventType","_playerID","_requestID","_type","_emptyProfiles","_payloadProfiles","_vehicleProfileID","_vehicleProfile","_eventForceMakeup"];

        _event = _args select 0;
        _entityProfile = _args select 1;

        _active = _entityProfile select 2 select 1;
        _profileID = _entityProfile select 2 select 4;
        _vehiclesInCommandOf = _entityProfile select 2 select 8;

        if(count _vehiclesInCommandOf == 0) exitWith { _result = false; };

        _vehicleProfileID = _vehiclesInCommandOf select 0;

        _vehicleProfile = [ALIVE_profileHandler, "getProfile", _vehicleProfileID] call ALIVE_fnc_profileHandler;

        if(isNil "_vehicleProfile") exitWith { _result = false; };

        _debug = [_logic, "debug"] call MAINCLASS;

        _eventID = [_event, "id"] call ALIVE_fnc_hashGet;
        _eventData = [_event, "data"] call ALIVE_fnc_hashGet;
        _eventCargoProfiles = [_event, "cargoProfiles"] call ALIVE_fnc_hashGet;
        _eventTransportProfiles = [_event, "transportProfiles"] call ALIVE_fnc_hashGet;
        _eventTransportVehiclesProfiles = [_event, "transportVehiclesProfiles"] call ALIVE_fnc_hashGet;
        _playerRequested = [_event, "playerRequested"] call ALIVE_fnc_hashGet;
        _playerRequestProfiles = [_event, "playerRequestProfiles"] call ALIVE_fnc_hashGet;

        _eventForceMakeup = _eventData select 3;
        _eventPosition = _eventData select 0;
        _eventType = _eventData select 4;
        _type = "STANDARD";

        if(_playerRequested) then {
            _playerID = _eventData select 5;
            _requestID = _eventForceMakeup select 0;
            _emptyProfiles = [_playerRequestProfiles,"empty"] call ALIVE_fnc_hashGet;
            _payloadProfiles = [_playerRequestProfiles,"payloadGroups"] call ALIVE_fnc_hashGet;

            {
                if(_profileID in _x) then {
                    _type = "EMPTY";
                };
            } forEach _emptyProfiles;

            {
                if(_profileID in _x) then {
                    _type = "PAYLOAD";
                };
            } forEach _payloadProfiles;

        };

        switch(_type) do {
            case "STANDARD":{

                if(_active) then {

                    private ["_group","_position","_heliPad","_inCargo","_cargoProfileID","_cargoProfile"];

                    _inCargo = _vehicleProfile select 2 select 9;

                    if(count _inCargo > 0) then {
                        {
                            _cargoProfileID = _x;
                            _cargoProfile = [ALIVE_profileHandler, "getProfile", _cargoProfileID] call ALIVE_fnc_profileHandler;

                            if!(isNil "_cargoProfile") then {
                                [_cargoProfile,_vehicleProfile] call ALIVE_fnc_removeProfileVehicleAssignment;

                                // If the cargo profile is active (spawned), physically
                                // unload the units and move them to their own group so
                                // they are not commanded by the heli crew
                                private _cargoActive = _cargoProfile select 2 select 1;
                                if (_cargoActive) then {
                                    private _cargoUnits = _cargoProfile select 2 select 21;
                                    private _heliVehicle = _vehicleProfile select 2 select 10;

                                    if (count _cargoUnits > 0) then {
                                        // Create a new group on the same side for the infantry
                                        private _newGroup = createGroup (side (_cargoUnits select 0));

                                        {
                                            if (alive _x) then {
                                                unassignVehicle _x;
                                                [_x] orderGetIn false;
                                                _x moveOut _heliVehicle;
                                                [_x] joinSilent _newGroup;
                                            };
                                        } forEach _cargoUnits;

                                        if (_debug) then {
                                            ["ML - unloadTransportHelicopter: Moved %1 units from heli crew group to new group %2",
                                                count _cargoUnits, _newGroup] call ALiVE_fnc_dump;
                                        };
                                    };
                                };
                            };

                        } forEach _inCargo;
                    };

                }else{

                    private ["_inCargo","_cargoProfileID","_cargoProfile","_position"];

                    _inCargo = _vehicleProfile select 2 select 9;

                    if(count _inCargo > 0) then {
                        {
                            _cargoProfileID = _x;
                            _cargoProfile = [ALIVE_profileHandler, "getProfile", _cargoProfileID] call ALIVE_fnc_profileHandler;

                            _position = _vehicleProfile select 2 select 2;
                            _position set [2,0];

                            if!(isNil "_cargoProfile") then {
                             [_cargoProfile,_vehicleProfile] call ALIVE_fnc_removeProfileVehicleAssignment;
                             [_cargoProfile,"position",_position] call ALIVE_fnc_profileEntity;
                            };

                        } forEach _inCargo;
                    };

                 };

            };
            case "EMPTY":{

                if!(_active) then {

                    private ["_group","_position","_heliPad"];

                    [_entityProfile,_vehicleProfile] call ALIVE_fnc_removeProfileVehicleAssignment;

                    _position = _vehicleProfile select 2 select 2;
                    _position set [2,0];
                    [_vehicleProfile,"position",_position] call ALIVE_fnc_profileVehicle;
                    [_vehicleProfile,"hasSimulated",false] call ALIVE_fnc_profileVehicle;
                    [_vehicleProfile,"engineOn",false] call ALIVE_fnc_profileVehicle;
                    [_vehicleProfile,"despawnPosition",_position] call ALIVE_fnc_profileVehicle;

                    [_entityProfile, "destroy"] call ALIVE_fnc_profileEntity;
                    //[ALIVE_profileHandler, "unregisterProfile", _entityProfile] call ALIVE_fnc_profileHandler;


                }else{

                    [_entityProfile,_vehicleProfile] call ALIVE_fnc_removeProfileVehicleAssignment;

                };

            };
            case "PAYLOAD":{

                private ["_index","_heliPad"];

              /*  _index = _eventTransportProfiles find _profileID;
                _eventTransportProfiles set [_index,objNull];
                _eventTransportProfiles = _eventTransportProfiles - [objNull];
                [_event, "transportProfiles",_eventTransportProfiles] call ALIVE_fnc_hashSet;


                _index = _eventTransportVehiclesProfiles find _vehicleProfileID;
                _eventTransportVehiclesProfiles set [_index,objNull];
                _eventTransportVehiclesProfiles = _eventTransportVehiclesProfiles - [objNull];
                [_event, "transportVehiclesProfiles",_eventTransportVehiclesProfiles] call ALIVE_fnc_hashSet; */

            };
        };

    };

    case "unloadTransportHelicopter": {

        private ["_event","_entityProfile","_active","_profileID","_vehiclesInCommandOf","_debug","_eventID","_eventData","_eventCargoProfiles",
        "_eventTransportProfiles","_eventTransportVehiclesProfiles","_playerRequested","_playerRequestProfiles","_eventPosition",
        "_eventType","_playerID","_requestID","_type","_emptyProfiles","_payloadProfiles","_vehicleProfileID","_vehicleProfile","_eventForceMakeup","_eventAssets","_slingloading"];

        _event = _args select 0;
        _entityProfile = _args select 1;

        _active = _entityProfile select 2 select 1;
        _profileID = _entityProfile select 2 select 4;
        _vehiclesInCommandOf = _entityProfile select 2 select 8;

        if(count _vehiclesInCommandOf == 0) exitWith { _result = false; };

        _vehicleProfileID = _vehiclesInCommandOf select 0;

        _vehicleProfile = [ALIVE_profileHandler, "getProfile", _vehicleProfileID] call ALIVE_fnc_profileHandler;

        if(isNil "_vehicleProfile") exitWith { _result = false; };

        _debug = [_logic, "debug"] call MAINCLASS;

        _eventID = [_event, "id"] call ALIVE_fnc_hashGet;
        _eventData = [_event, "data"] call ALIVE_fnc_hashGet;
        _eventCargoProfiles = [_event, "cargoProfiles"] call ALIVE_fnc_hashGet;
        _eventTransportProfiles = [_event, "transportProfiles"] call ALIVE_fnc_hashGet;
        _eventTransportVehiclesProfiles = [_event, "transportVehiclesProfiles"] call ALIVE_fnc_hashGet;
        _playerRequested = [_event, "playerRequested"] call ALIVE_fnc_hashGet;
        _playerRequestProfiles = [_event, "playerRequestProfiles"] call ALIVE_fnc_hashGet;

        _eventAssets = [_event, "eventAssets"] call ALIVE_fnc_hashGet;

        _eventForceMakeup = _eventData select 3;
        _eventPosition = _eventData select 0;
        _eventType = _eventData select 4;
        _type = "STANDARD";

        _slingloading = [_vehicleProfile, "slingloading", false] call ALiVE_fnc_hashGet;

        if(_playerRequested) then {
            _playerID = _eventData select 5;
            _requestID = _eventForceMakeup select 0;
            _emptyProfiles = [_playerRequestProfiles,"empty"] call ALIVE_fnc_hashGet;
            _payloadProfiles = [_playerRequestProfiles,"payloadGroups"] call ALIVE_fnc_hashGet;

            {
                if(_profileID in _x) then {
                    _type = "EMPTY";
                };
            } forEach _emptyProfiles;

            {
                if(_profileID in _x) then {
                    _type = "PAYLOAD";
                };
            } forEach _payloadProfiles;

        };

        if(!_playerRequested && _slingLoading) then {
            _payloadProfiles = [_eventCargoProfiles,"payloadGroups"] call ALIVE_fnc_hashGet;

            {
                if(_profileID in _x) then {
                    _type = "PAYLOAD";
                };
            } forEach _payloadProfiles;

        };

        switch(_type) do {
            case "STANDARD":{

                if(_active) then {

                    private ["_group","_position","_heliPad","_inCargo","_cargoProfileID","_cargoProfile"];

                    _group = _entityProfile select 2 select 13;
                    _group setBehaviour "CARELESS";

                    // Build a local exclusion list from helipads already placed for this event
                    // so concurrent troop-drop helis don't choose the same landing spot.
                    // These are passed as the optional 4th arg to findHelicopterLandingPos,
                    // which merges them with the global ALIVE_ML_usedLZPositions tracker.
                    private _blacklistPositions = [];
                    {
                        if (typeof _x == "Land_HelipadEmpty_F") then {
                            _blacklistPositions pushback getpos _x;
                        };
                    } foreach _eventAssets;

                    _position = [_logic, "findHelicopterLandingPos", [
                        _eventPosition, 200, 600, _blacklistPositions
                    ]] call MAINCLASS;

                    _heliPad = "Land_HelipadEmpty_F" createVehicle _position;

                    _eventAssets pushback _heliPad;
                    [_event, "eventAssets",_eventAssets] call ALIVE_fnc_hashSet;

                    _inCargo = _vehicleProfile select 2 select 9;

                    if(count _inCargo > 0) then {
                        {
                            _cargoProfileID = _x;
                            _cargoProfile = [ALIVE_profileHandler, "getProfile", _cargoProfileID] call ALIVE_fnc_profileHandler;

                            if!(isNil "_cargoProfile") then {
                                [_cargoProfile,_vehicleProfile] call ALIVE_fnc_removeProfileVehicleAssignment;
                            };

                        } forEach _inCargo;
                    };

                    private _vehiclesInCommandOf = _entityProfile select 2 select 8;
                    {
                        private _vehicleProfile = [ALIVE_profileHandler,"getProfile", _x] call ALiVE_fnc_profileHandler;
                        private _isActive = _vehicleProfile select 2 select 1;
                        if (_isActive) then {
                            private _vehicleObject = _vehicleProfile select 2 select 10;
                            if (_vehicleObject iskindof "Helicopter") then {
                                private _landPos = getpos _helipad;

                                // Issue landAt via temp helipad so heli physically lands
                                private _tmpPad = createVehicle ["Land_HelipadEmpty_F", _landPos, [], 0, "CAN_COLLIDE"];
                                _vehicleObject landAt _tmpPad;

                                // Spawn thread: wait for landing then physically unload troops
                                [_vehicleObject, _tmpPad, _inCargo, _vehicleProfile, _debug] spawn {
                                    private _heli    = _this select 0;
                                    private _pad     = _this select 1;
                                    private _cargo   = _this select 2;
                                    private _vProf   = _this select 3;
                                    private _dbg     = _this select 4;

                                    // Wait until landed or 90s timeout
                                    private _t = 0;
                                    waitUntil {
                                        sleep 2; _t = _t + 2;
                                        isTouchingGround _heli || !alive _heli || _t > 90
                                    };

                                    deleteVehicle _pad;

                                    if (alive _heli) then {
                                        // Physically move all cargo units out
                                        {
                                            private _profID = _x;
                                            private _prof = [ALIVE_profileHandler, "getProfile", _profID] call ALIVE_fnc_profileHandler;
                                            if !(isNil "_prof") then {
                                                private _units = _prof select 2 select 21;
                                                if !(isNil "_units") then {
                                                    private _newGroup = if (count _units > 0) then {
                                                        createGroup (side (_units select 0))
                                                    } else { grpNull };

                                                    {
                                                        if (alive _x) then {
                                                            unassignVehicle _x;
                                                            [_x] orderGetIn false;
                                                            _x moveOut _heli;
                                                            if !(isNull _newGroup) then {
                                                                [_x] joinSilent _newGroup;
                                                            };
                                                        };
                                                    } forEach _units;

                                                    if (_dbg) then {
                                                        ["ML - unloadTransportHelicopter: Physically unloaded %1 units from heli", count _units] call ALiVE_fnc_dump;
                                                    };
                                                };
                                            };
                                        } forEach _cargo;
                                    };
                                };

                                // Profile waypoint to the land position (fallback for virtual helis)
                                private _landWaypoint = [_landPos, 15, "MOVE"] call ALIVE_fnc_createProfileWaypoint;
                                [_entityProfile, "clearWaypoints"] call ALIVE_fnc_profileEntity;
                                [_entityProfile, "addWaypoint", _landWaypoint] call ALIVE_fnc_profileEntity;
                            };
                        };
                    } foreach _vehiclesInCommandOf;
                }else{

                    private ["_position","_inCargo","_cargoProfileID","_cargoProfile"];

                    _inCargo = _vehicleProfile select 2 select 9;
                    _position = _eventPosition getPos [random(DESTINATION_VARIANCE), random(360)];

                    if(count _inCargo > 0) then {
                        {
                            _cargoProfileID = _x;
                            _cargoProfile = [ALIVE_profileHandler, "getProfile", _cargoProfileID] call ALIVE_fnc_profileHandler;

                            if!(isNil "_cargoProfile") then {
                                [_cargoProfile,_vehicleProfile] call ALIVE_fnc_removeProfileVehicleAssignment;
                                [_cargoProfile,"position",_position] call ALIVE_fnc_profileEntity;
                            };

                        } forEach _inCargo;
                    };

                };

            };
            case "EMPTY":{

                if(_active) then {

                    private ["_group","_position","_heliPad"];

                    _group = _entityProfile select 2 select 13;
                    _group setBehaviour "CARELESS";

                    _position = _eventPosition getPos [random(DESTINATION_VARIANCE), random(360)];
                    _position = _position findEmptyPosition [10,200];

                    if(count _position == 0) then {
                        _position = _eventPosition getPos [random(DESTINATION_VARIANCE), random(360)];
                    };
                    _heliPad = "Land_HelipadEmpty_F" createVehicle _position;

                    _eventAssets pushback _heliPad;
                    [_event, "eventAssets",_eventAssets] call ALIVE_fnc_hashSet;

                    [_entityProfile,_vehicleProfile] call ALIVE_fnc_removeProfileVehicleAssignment;

                }else{

                    private ["_position"];

                    [_entityProfile,_vehicleProfile] call ALIVE_fnc_removeProfileVehicleAssignment;

                    _position = _vehicleProfile select 2 select 2;
                    _position set [2,0];
                    [_vehicleProfile,"position",_position] call ALIVE_fnc_profileVehicle;
                    [_vehicleProfile,"hasSimulated",false] call ALIVE_fnc_profileVehicle;
                    [_vehicleProfile,"engineOn",false] call ALIVE_fnc_profileVehicle;
                    [_vehicleProfile,"despawnPosition",_position] call ALIVE_fnc_profileVehicle;

                    [_entityProfile, "destroy"] call ALIVE_fnc_profileEntity;
                    //[ALIVE_profileHandler, "unregisterProfile", _entityProfile] call ALIVE_fnc_profileHandler;

                };

            };
            case "PAYLOAD":{

                private ["_index","_heliPad"];

               /* _index = _eventTransportProfiles find _profileID;
                _eventTransportProfiles set [_index,objNull];
                _eventTransportProfiles = _eventTransportProfiles - [objNull];
                [_event, "transportProfiles",_eventTransportProfiles] call ALIVE_fnc_hashSet;


                _index = _eventTransportVehiclesProfiles find _vehicleProfileID;
                _eventTransportVehiclesProfiles set [_index,objNull];
                _eventTransportVehiclesProfiles = _eventTransportVehiclesProfiles - [objNull];
                [_event, "transportVehiclesProfiles",_eventTransportVehiclesProfiles] call ALIVE_fnc_hashSet; */


                if(_active) then {

                    private ["_vehicle","_group","_position","_heliPad"];

                    _vehicle = _vehicleProfile select 2 select 10;
                    _group = _entityProfile select 2 select 13;
                    _group setBehaviour "CARELESS";

                    // For slingloading helis the spawn thread will call findHelicopterLandingPos
                    // internally to find the actual drop position, so the outer position only
                    // needs to be a rough starting point - no need to consume a tracker slot here.
                    // For non-slingloading PAYLOAD helis, use findHelicopterLandingPos with the
                    // event's existing helipad positions as a local exclusion list.
                    private _payloadBlacklist = [];
                    {
                        if (typeof _x == "Land_HelipadEmpty_F") then {
                            _payloadBlacklist pushback getpos _x;
                        };
                    } forEach _eventAssets;

                    private _position = if (_slingloading) then {
                        // Slingload: allocate a well-separated drop pad now so concurrent helis
                        // are routed to different landing zones from the start.
                        // findHelicopterLandingPos uses the ALIVE_ML_usedLZPositions tracker
                        // (150m exclusion, 10-min expiry) so each call returns a unique slot.
                        // minRadius=300 keeps helis far enough from the objective centre that
                        // they don't conflict with each other or with ground units already there.
                        // Road-preferred so trucks land on suitable surfaces.
                        [_logic, "findHelicopterLandingPos", [
                            _eventPosition, 300, 700, _payloadBlacklist
                        ]] call MAINCLASS
                    } else {
                        [_logic, "findHelicopterLandingPos", [
                            _eventPosition, 200, 600, _payloadBlacklist
                        ]] call MAINCLASS
                    };

                    _heliPad = "Land_HelipadEmpty_F" createVehicle _position;

                    _eventAssets pushback _heliPad;
                    [_event, "eventAssets",_eventAssets] call ALIVE_fnc_hashSet;

                    if!(isNil "_vehicle") then {

                        // Pass _logic into spawn so findHelicopterLandingPos can be called
                        // for drop position retries (_logic is out of scope inside spawn blocks)
                        [_vehicle, _slingloading, _position, _eventPosition, _logic] spawn {

                            private _vehicle      = _this select 0;
                            private _slingloading = _this select 1;
                            private _position     = _this select 2;
                            private _eventPosition = _this select 3;
                            private _logic        = _this select 4;

                            sleep 3;

                            // Wait for heli to finish its current action before issuing delivery
                            // commands. Timeout after 60s to avoid infinite block if state is corrupt.
                            private _readyTimer = 0;
                            while { alive _vehicle && !(unitReady _vehicle) && _readyTimer < 60 } do {
                                sleep 2;
                                _readyTimer = _readyTimer + 2;
                            };

                            if (alive _vehicle) then {
                                if (_slingLoading) then {

                                    private _slingloadVehicle = getSlingLoad _vehicle;

                                    // Guard: sling may already have been released externally
                                    // (enemy fire, collision, or duplicate event trigger)
                                    if (isNull _slingloadVehicle) exitWith {
                                        ["ML - unloadTransportHelicopter: Slingload already released for heli %1, skipping.", _vehicle] call ALiVE_fnc_dump;
                                    };

                                    // Ships need a water drop position - preserve original logic
                                    if (_slingloadVehicle isKindOf "Ship") then {
                                        _position = [
                                            _eventPosition,
                                            0,
                                            100,
                                            (sizeOf typeOf _slingloadVehicle) / 2,
                                            2,
                                            0,
                                            0,
                                            [],
                                            [_eventPosition, _eventPosition]
                                        ] call bis_fnc_findSafePos;
                                    } else {
                                        // Find a road-preferred drop position near the event position.
                                        // Try increasing radii; accept the first road position found.
                                        // ALIVE_ML_usedLZPositions tracker (150m, 10-min) prevents
                                        // concurrent helis from sharing the same drop zone.
                                        private _dropSearchRadii = [50, 150, 300, 500];
                                        private _dropFound = false;
                                        {
                                            if (_dropFound) exitWith {};
                                            private _dropPos = [_logic, "findHelicopterLandingPos", [
                                                _eventPosition, 0, _x
                                            ]] call MAINCLASS;
                                            if (count _dropPos > 0 && !(surfaceIsWater _dropPos)) then {
                                                private _nearBuildings = _dropPos nearObjects ["Building", 40];
                                                if (count _nearBuildings == 0) then {
                                                    _position = _dropPos;
                                                    _dropFound = true;
                                                    ["ML - unloadTransportHelicopter: Drop pos found at radius %1 -> %2", _x, _position] call ALiVE_fnc_dump;
                                                };
                                            };
                                        } forEach _dropSearchRadii;

                                        if (!_dropFound) then {
                                            ["ML - unloadTransportHelicopter: WARNING no clear drop pos found, using fallback %1", _position] call ALiVE_fnc_dump;
                                        };
                                    };

                                    _vehicle setVariable ["alive_ml_slingload_object", _slingloadVehicle];

                                    // Guard against multiple concurrent spawn threads.
                                    // heliTransport calls unloadTransportHelicopter every monitor
                                    // cycle for any transport at its waypoint -- without this guard
                                    // each cycle spawns a new descent thread.
                                    // alive_ml_sling_unload_active: set true on entry, cleared after release.
                                    // alive_ml_sling_released: permanent flag, never cleared -- prevents
                                    // duplicate threads after the first completes and clears _unload_active.
                                    if (_vehicle getVariable ["alive_ml_sling_unload_active", false]) exitWith {
                                        ["ML - unloadTransportHelicopter: Slingload unload already active for %1, skipping duplicate.", _vehicle] call ALiVE_fnc_dump;
                                    };
                                    if (_vehicle getVariable ["alive_ml_sling_released", false]) exitWith {
                                        ["ML - unloadTransportHelicopter: Slingload already released for %1, skipping.", _vehicle] call ALiVE_fnc_dump;
                                    };
                                    _vehicle setVariable ["alive_ml_sling_unload_active", true];
                                    // Clear sling_ready on the entity profile so heliTransport
                                    // stops re-triggering unloadTransportHelicopter each poll cycle.
                                    private _heliProfID = _vehicle getVariable ["profileID", ""];
                                    if (_heliProfID != "") then {
                                        private _heliEntProf = [ALIVE_profileHandler, "getProfile",
                                            _vehicle getVariable ["alive_ml_entity_prof_id", ""]] call ALIVE_fnc_profileHandler;
                                        // Clear via vehicle profile lookup of entity
                                        private _heliVehProf = [ALIVE_profileHandler, "getProfile", _heliProfID] call ALIVE_fnc_profileHandler;
                                        if (!isNil "_heliVehProf") then {
                                            private _entID = [_heliVehProf, "entitiesInCommandOf", []] call ALIVE_fnc_hashGet;
                                            if (count _entID > 0) then {
                                                private _eProf = [ALIVE_profileHandler, "getProfile", _entID select 0] call ALIVE_fnc_profileHandler;
                                                if (!isNil "_eProf") then {
                                                    [_eProf, "alive_ml_sling_ready", false] call ALIVE_fnc_hashSet;
                                                };
                                            };
                                        };
                                    };

                                    // Fetch heli vehicle profile for cleanup later
                                    private _heliProfileID = _vehicle getVariable ["profileID", ""];
                                    private _heliProfile   = [ALIVE_profileHandler, "getProfile", _heliProfileID] call ALIVE_fnc_profileHandler;

                                    // DO NOT issue landAt here. The heliDeliveryWatchdog is the sole
                                    // authority on landAt for slingload helis -- it drives descent from
                                    // LANDING phase using the heli's current position. Issuing a
                                    // competing landAt to a different pad every 30s from this thread
                                    // was causing the AI to oscillate between two targets and never
                                    // commit to either descent. This thread only monitors slung vehicle
                                    // AGL and releases the load when the watchdog has brought it down.
                                    // Native waypoints are NOT cleared here either -- the watchdog
                                    // handles that when it transitions to LANDING phase.
                                    ["ML - unloadTransportHelicopter: Slingload %1 monitoring AGL for release. Drop ref pos %2",
                                        _vehicle, _position] call ALiVE_fnc_dump;

                                    // Dummy pad object for sling drop position tracking/cleanup
                                    // (created at drop pos but NOT used for landAt - watchdog drives descent)
                                    private _slingDropPad = createVehicle ["Land_HelipadEmpty_F", _position, [], 0, "CAN_COLLIDE"];
                                    [_slingDropPad] spawn {
                                        sleep 300;
                                        if (!isNull (_this select 0)) then { deleteVehicle (_this select 0); };
                                    };

                                    // Wait for the SLUNG VEHICLE (not the heli) to reach safe drop height.
                                    // The watchdog drives the actual descent via landAt.
                                    private _dropTimer = 0;
                                    private _dropped   = false;

                                    waitUntil {
                                        sleep 2;
                                        _dropTimer = _dropTimer + 2;

                                        if (!alive _vehicle) exitWith { true };

                                        // Guard: slung vehicle may have been destroyed mid-delivery
                                        if (isNull _slingloadVehicle || !alive _slingloadVehicle) exitWith {
                                            ["ML - unloadTransportHelicopter: Slung vehicle destroyed mid-delivery for heli %1, aborting drop.", _vehicle] call ALiVE_fnc_dump;
                                            true
                                        };

                                        // If heliTransportReturn has already issued RTB waypoints,
                                        // release the load immediately so the heli can depart.
                                        // Attach a parachute if still at altitude so vehicle lands intact.
                                        private _rtbIssued = _vehicle getVariable ["alive_ml_rtb_issued", false];
                                        if (_rtbIssued) then {
                                            private _rtbAGL = (getPosATL _slingloadVehicle) select 2;
                                            if (_rtbAGL > 5) then {
                                                private _rtbPara = createVehicle ["B_Parachute_02_F", getPosATL _slingloadVehicle, [], 0, "FLY"];
                                                _rtbPara setPosASL (getPosASL _slingloadVehicle);
                                                _rtbPara setVelocity (velocity _vehicle);
                                                _slingloadVehicle attachTo [_rtbPara, [0,0,0]];
                                                [_rtbPara, _slingloadVehicle] spawn {
                                                    private _p = _this select 0; private _v = _this select 1;
                                                    waitUntil { sleep 1; (getPosATL _v select 2) < 3 || !alive _p };
                                                    detach _v; deleteVehicle _p;
                                                };
                                                ["ML - unloadTransportHelicopter: RTB force-release - parachute attached to %1 at AGL %2m",
                                                    _slingloadVehicle, _rtbAGL] call ALiVE_fnc_dump;
                                            };
                                            _vehicle setSlingLoad objNull;
                                            deleteVehicle _slingDropPad;
                                            _vehicle setVariable ["alive_ml_sling_unload_active", false];
                                            _vehicle setVariable ["alive_ml_sling_released", true];
                                            _dropped = true;
                                            ["ML - unloadTransportHelicopter: RTB already issued to %1, force-releasing slung load.",
                                                _vehicle] call ALiVE_fnc_dump;
                                            // Climb immediately after release so heli doesn't fly through
                                            // the descending parachute+vehicle directly below it.
                                            private _heliPosASL = getPosASL _vehicle;
                                            private _climbTarget = _heliPosASL;
                                            _climbTarget set [2, (_heliPosASL select 2) + 50];
                                            _vehicle flyInHeight (PARADROP_HEIGHT + 50);
                                            _vehicle setVelocity [
                                                velocity _vehicle select 0,
                                                velocity _vehicle select 1,
                                                15
                                            ];
                                            _vehicle doMove (ASLToAGL _climbTarget);
                                            true
                                        } else {

                                        private _slungAGL = (getPosATL _slingloadVehicle) select 2;

                                        // NOTE: No landAt retries issued here. The heliDeliveryWatchdog
                                        // is the sole authority on landAt -- it retries every 30-35s in
                                        // LANDING phase. Issuing competing landAt from this thread caused
                                        // the AI to oscillate between two different target pads and never
                                        // commit to a descent. This thread only monitors AGL and releases.

                                        if (_slungAGL <= SLINGLOAD_DROP_HEIGHT || _dropTimer >= SLINGLOAD_DROP_TIMEOUT) then {
                                            private _groundPos = getPosATL _slingloadVehicle;
                                            _groundPos set [2, 0];
                                            private _h0 = getTerrainHeightASL _groundPos;
                                            private _gradOK = true;
                                            {
                                                private _sp = _groundPos getPos [5, _x];
                                                if (abs ((getTerrainHeightASL _sp) - _h0) > 1.5) then {
                                                    _gradOK = false;
                                                };
                                            } forEach [0, 90, 180, 270];

                                            if (!_gradOK && _dropTimer < SLINGLOAD_DROP_TIMEOUT) then {
                                                // Steep terrain - log it; watchdog will retry landAt at heli current pos
                                                ["ML - unloadTransportHelicopter: Steep terrain under %1 at AGL %2m (timer=%3s), waiting for watchdog to reposition.",
                                                    _vehicle, _slungAGL, _dropTimer] call ALiVE_fnc_dump;
                                                false
                                            } else {
                                                // Flat enough or timed out - release the load.
                                                // Attach parachute if still at altitude so vehicle lands intact.
                                                private _relAGL = (getPosATL _slingloadVehicle) select 2;
                                                if (_relAGL > 5) then {
                                                    private _relPara = createVehicle ["B_Parachute_02_F", getPosATL _slingloadVehicle, [], 0, "FLY"];
                                                    _relPara setPosASL (getPosASL _slingloadVehicle);
                                                    _relPara setVelocity (velocity _vehicle);
                                                    _slingloadVehicle attachTo [_relPara, [0,0,0]];
                                                    [_relPara, _slingloadVehicle] spawn {
                                                        private _p = _this select 0; private _v = _this select 1;
                                                        waitUntil { sleep 1; (getPosATL _v select 2) < 3 || !alive _p };
                                                        detach _v; deleteVehicle _p;
                                                    };
                                                    ["ML - unloadTransportHelicopter: Parachute attached to slung vehicle %1 at AGL %2m",
                                                        _slingloadVehicle, _relAGL] call ALiVE_fnc_dump;
                                                };
                                                _vehicle setSlingLoad objNull;
                                                deleteVehicle _slingDropPad;
                                                _vehicle setVariable ["alive_ml_sling_unload_active", false];
                                                _vehicle setVariable ["alive_ml_sling_released", true];
                                                _dropped = true;
                                                ["ML - unloadTransportHelicopter: Slingload released from %1, slungAGL=%2m timer=%3s gradOK=%4",
                                                    _vehicle, _slungAGL, _dropTimer, _gradOK] call ALiVE_fnc_dump;
                                                true
                                            };
                                        } else {
                                            false
                                        };
                                        }; // end else (!_rtbIssued)
                                    };

                                    // Clean up profile slingload state hashes and seat crew
                                    if (_dropped) then {
                                        if !(isNil "_heliProfile") then {
                                            private _slungData = [_heliProfile, "slingload"] call ALIVE_fnc_profileVehicle;
                                            private _slungID   = if (count _slungData > 0) then { _slungData select 0 } else { "" };
                                            if (typeName _slungID == "ARRAY") then {
                                                private _slungProf = [ALIVE_profileHandler, "getProfile", _slungID select 0] call ALIVE_fnc_profileHandler;
                                                if !(isNil "_slungProf") then {
                                                    [_slungProf, "slung",     []] call ALIVE_fnc_hashSet;
                                                    // Update truck profile position to where it actually landed.
                                                    // The profile still has the original HQ spawn position --
                                                    // without this ALiVE cannot locate the vehicle to despawn it.
                                                    private _truckLandPos = getPos _slingloadVehicle;
                                                    _truckLandPos set [2, 0];
                                                    [_slungProf, "position",        _truckLandPos] call ALIVE_fnc_profileVehicle;
                                                    [_slungProf, "despawnPosition", _truckLandPos] call ALIVE_fnc_profileVehicle;
                                                    [_slungProf, "hasSimulated",    false]         call ALIVE_fnc_profileVehicle;
                                                    ["ML - unloadTransportHelicopter: Slung truck %1 profile updated. pos=%2 hasSimulated=false spawnType=[]",
                                                        _slingloadVehicle, _truckLandPos] call ALiVE_fnc_dump;
                                                    // Clear preventDespawn so the truck profile returns to normal lifecycle
                                                    [_slungProf, "spawnType", []] call ALIVE_fnc_profileVehicle;

                                                    // Seat infantry crew into the now-landed truck.
                                                    // The sling spawn path bypasses normal _inCargo loading
                                                    // so we do it here after the vehicle is on the ground.
                                                    // alive_ml_sling_infantry_id was stored at sling-creation time.
                                                    private _infEntityID = [_slungProf, "alive_ml_sling_infantry_id", ""] call ALIVE_fnc_hashGet;
                                                    if (_infEntityID != "") then {
                                                        [_slingloadVehicle, _infEntityID, _logic] spawn {
                                                            private _truck      = _this select 0;
                                                            private _entityID   = _this select 1;
                                                            private _logicRef   = _this select 2;

                                                            // Wait for truck to settle on ground
                                                            sleep 3;
                                                            if (!alive _truck) exitWith {};

                                                            private _infProf = [ALIVE_profileHandler, "getProfile", _entityID] call ALIVE_fnc_profileHandler;
                                                            if (isNil "_infProf") exitWith {};

                                                            private _infActive = _infProf select 2 select 1;
                                                            if (_infActive) then {
                                                                // Profile is spawned - physically move units into truck
                                                                private _units = _infProf select 2 select 21;
                                                                {
                                                                    if (alive _x) then {
                                                                        _x moveInCargo _truck;
                                                                    };
                                                                } forEach _units;
                                                                ["ML - unloadTransportHelicopter: Seated %1 infantry from %2 into truck %3",
                                                                    count _units, _entityID, _truck] call ALiVE_fnc_dump;
                                                            } else {
                                                                // Profile not yet spawned - assign via profile system
                                                                // so they board when they eventually spawn nearby
                                                                private _truckProfID = _truck getVariable ["profileID", ""];
                                                                if (_truckProfID != "") then {
                                                                    private _truckProf = [ALIVE_profileHandler, "getProfile", _truckProfID] call ALIVE_fnc_profileHandler;
                                                                    if (!isNil "_truckProf") then {
                                                                        [_infProf, _truckProf] call ALIVE_fnc_createProfileVehicleAssignment;
                                                                        ["ML - unloadTransportHelicopter: Profile-assigned infantry %1 to truck %2 (not yet spawned)",
                                                                            _entityID, _truckProfID] call ALiVE_fnc_dump;
                                                                    };
                                                                };
                                                            };
                                                        };
                                                    };
                                                };
                                            } else {
                                                // Non-profile slung object (supply crate etc) - attach smoke/strobe marker
                                                [_slingloadVehicle] spawn ALIVE_fnc_MLAttachSmokeOrStrobe;
                                            };
                                            [_heliProfile, "slingload",    []] call ALIVE_fnc_profileVehicle;
                                            [_heliProfile, "slingloading", false] call ALIVE_fnc_hashSet;
                                            // Clear preventDespawn on heli vehicle profile -- RTB can now virtualise normally
                                            [_heliProfile, "spawnType", []] call ALIVE_fnc_profileVehicle;
                                            // Clear preventDespawn on pilot entity profile so it can virtualise on RTB.
                                            // Read from heli vehicle profile hash (stored at creation time).
                                            if !(isNil "_heliProfile") then {
                                                private _pilotEntityID = [_heliProfile, "alive_ml_pilot_entity_id", ""] call ALIVE_fnc_hashGet;
                                                if (_pilotEntityID != "") then {
                                                    private _pilotProf = [ALIVE_profileHandler, "getProfile", _pilotEntityID] call ALIVE_fnc_profileHandler;
                                                    if (!isNil "_pilotProf") then {
                                                        [_pilotProf, "spawnType", []] call ALIVE_fnc_hashSet;
                                                    };
                                                };
                                            };
                                        };

                                        ["ML - unloadTransportHelicopter: Slingload complete, heli %1 RTB",
                                            _vehicle] call ALiVE_fnc_dump;
                                    };

                                } else {
                                   [_vehicle,"LAND"] call ALiVE_fnc_landRemote;
                                };
                            };

                        };

                    };

                }else{

                    private ["_position"];

                    _position = _vehicleProfile select 2 select 2;
                    _position set [2,0];
                    [_vehicleProfile,"position",_position] call ALIVE_fnc_profileVehicle;
                    [_vehicleProfile,"hasSimulated",false] call ALIVE_fnc_profileVehicle;
                    [_vehicleProfile,"engineOn",false] call ALIVE_fnc_profileVehicle;
                    [_vehicleProfile,"despawnPosition",_position] call ALIVE_fnc_profileVehicle;

                    // Update any slingload
                    _slungID = ([_vehicleProfile, "slingload"] call ALIVE_fnc_profileVehicle) select 0;
                    if (typeName _slungID == "ARRAY") then {
                        _slungprofile = [ALIVE_profileHandler,'getProfile',_slungID] call ALIVE_fnc_profileHandler;
                        [_slungprofile, "slung", []] call ALIVE_fnc_hashSet;
                        [_slungProfile,"position",_position] call ALIVE_fnc_profileVehicle;
                        [_slungProfile,"despawnPosition",_position] call ALIVE_fnc_profileVehicle;
                        [_slungProfile,"spawnType",[]] call ALIVE_fnc_profileVehicle;
                    };
                    [_vehicleProfile,"spawnType",[]] call ALIVE_fnc_profileVehicle;
                    [_vehicleProfile,"slingload",[]] call ALIVE_fnc_profileVehicle;
                    [_vehicleProfile, 'slingloading', false] call ALIVE_fnc_hashSet;
                    // Clear preventDespawn on pilot entity profile so ALiVE does not
                    // re-spawn the heli on the next simulation cycle.
                    private _pilotEntityID = [_vehicleProfile, "alive_ml_pilot_entity_id", ""] call ALIVE_fnc_hashGet;
                    if (_pilotEntityID != "") then {
                        private _pilotProf = [ALIVE_profileHandler, "getProfile", _pilotEntityID] call ALIVE_fnc_profileHandler;
                        if (!isNil "_pilotProf") then {
                            [_pilotProf, "spawnType", []] call ALIVE_fnc_hashSet;
                        };
                    };
                    // Physically release the sling on the live heli object.
                    // The profile is virtual (_active=false) but the heli is still
                    // physically spawned due to preventDespawn. Without this the truck
                    // remains attached and the delivery watchdog never sees slungAttached=false.
                    private _heliObjInactive = _vehicleProfile select 2 select 10;
                    ["ML - unloadTransportHelicopter: Inactive PAYLOAD branch. profileID=%1 heliObjNull=%2 pilotEntityID=%3",
                        _vehicleProfileID, isNull _heliObjInactive, _pilotEntityID] call ALiVE_fnc_dump;
                    if (!isNull _heliObjInactive && alive _heliObjInactive) then {
                        private _slungObjInactive = getSlingLoad _heliObjInactive;
                        if (!isNull _slungObjInactive) then {
                            // Attach parachute if truck is still at altitude
                            private _truckAGL = (getPosATL _slungObjInactive) select 2;
                            if (_truckAGL > 5) then {
                                private _para = createVehicle ["B_Parachute_02_F", getPosATL _slungObjInactive, [], 0, "FLY"];
                                _para setPosASL (getPosASL _slungObjInactive);
                                _para setVelocity (velocity _heliObjInactive);
                                _slungObjInactive attachTo [_para, [0,0,0]];
                                [_para, _slungObjInactive] spawn {
                                    private _p = _this select 0; private _v = _this select 1;
                                    waitUntil { sleep 1; (getPosATL _v select 2) < 3 || !alive _p };
                                    detach _v; deleteVehicle _p;
                                };
                            };
                            _heliObjInactive setSlingLoad objNull;
                        };
                        // Issue RTB via flyInHeight + move toward departure origin
                        // so the heli climbs and departs rather than hovering after release.
                        _heliObjInactive flyInHeight 150;
                        private _rtbWP = [_vehicleProfile, "despawnPosition", getPos _heliObjInactive] call ALIVE_fnc_hashGet;
                        _heliObjInactive move _rtbWP;
                        ["ML - unloadTransportHelicopter: Inactive PAYLOAD - released sling from %1, RTB to %2",
                            _heliObjInactive, _rtbWP] call ALiVE_fnc_dump;
                    };

                };

            };
        };

    };

    case "setEventProfilesAvailable": {

        // logistics event complete
        // release profiles to OPCOM
        // control if AI requested
        // if player requested, it's more
        // complicated

        private ["_debug","_event","_eventData","_eventID","_eventFaction","_side","_eventPosition","_eventCargoProfiles","_infantryProfiles","_armourProfiles",
        "_mechanisedProfiles","_motorisedProfiles","_planeProfiles","_heliProfiles","_profile","_eventAssets","_finalDestination","_logEvent"];

        _debug = [_logic, "debug"] call MAINCLASS;
        _event = _args;

        _eventData = [_event, "data"] call ALIVE_fnc_hashGet;

        _eventID = [_event, "id"] call ALIVE_fnc_hashGet;
        _eventFaction = _eventData select 1;
        _side = _eventData select 2;

        _eventPosition = _eventData select 0;
        _eventCargoProfiles = [_event, "cargoProfiles"] call ALIVE_fnc_hashGet;

        _infantryProfiles = [_eventCargoProfiles, 'infantry'] call ALIVE_fnc_hashGet;
        _armourProfiles = [_eventCargoProfiles, 'armour'] call ALIVE_fnc_hashGet;
        _mechanisedProfiles = [_eventCargoProfiles, 'mechanised'] call ALIVE_fnc_hashGet;
        _motorisedProfiles = [_eventCargoProfiles, 'motorised'] call ALIVE_fnc_hashGet;
        _planeProfiles = [_eventCargoProfiles, 'plane'] call ALIVE_fnc_hashGet;
        _heliProfiles = [_eventCargoProfiles, 'heli'] call ALIVE_fnc_hashGet;

        _eventAssets = [_event, "eventAssets"] call ALIVE_fnc_hashGet;

        {
            deleteVehicle _x;
        } forEach _eventAssets;

        if!(_playerRequested) then {

            // AI requested
            // set all cargo profiles as not busy

            // Resolve garrison position -- use the event's final delivery position.
            // All infantry (heli-inserted and paradropped) garrison at their drop-off point
            // so they hold the area rather than standing idle waiting for OPCOM orders.
            private _garrisonPos = [_event, "finalDestination"] call ALIVE_fnc_hashGet;
            if (isNil "_garrisonPos" || count _garrisonPos == 0) then {
                _garrisonPos = _eventPosition;
            };

            {
                _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                if!(isNil "_profile") then {
                    [_profile,"busy",false] call ALIVE_fnc_hashSet;

                    // Clear any vehicle assignment left over from heli transport.
                    // Infantry assigned to helis have vehicleAssignments set at creation
                    // time (HELI_INSERT). The transport heli is destroyed after RTB but
                    // the assignment lingers, which can corrupt speedPerSecond and prevent
                    // OPCOM from properly re-assigning these profiles.
                    private _vAssign = [_profile, "vehicleAssignments"] call ALIVE_fnc_hashGet;
                    if (!isNil "_vAssign" && { typeName _vAssign == "ARRAY" } && { count _vAssign >= 2 } && { count (_vAssign select 1) > 0 }) then {
                        private _emptyHash = [] call ALIVE_fnc_hashCreate;
                        [_profile, "vehicleAssignments", _emptyHash] call ALIVE_fnc_hashSet;
                        [_profile, "vehiclesInCargoOf", []] call ALIVE_fnc_hashSet;
                        [_profile, "vehiclesInCommandOf", []] call ALIVE_fnc_hashSet;
                        [_profile, "speedPerSecond", "Man" call ALIVE_fnc_vehicleGetSpeedPerSecond] call ALIVE_fnc_hashSet;
                    };

                    // Assign garrison duty at the delivery position so infantry hold
                    // the area immediately on arrival rather than standing idle.
                    // OPCOM can override this with its own orders when it picks them up.
                    [_profile, "setActiveCommand", [
                        "ALIVE_fnc_managedGarrison", "managed", [200, "false", _garrisonPos]
                    ]] call ALIVE_fnc_profileEntity;

                    if (_debug) then {
                        ["ML - setEventProfilesAvailable: Garrison assigned to %1 at %2",
                            _x select 0, _garrisonPos] call ALiVE_fnc_dump;
                    };
                };

            } forEach _infantryProfiles;

            {
                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile,"busy",false] call ALIVE_fnc_hashSet;
                    };
                } forEach _x;

            } forEach _armourProfiles;

            {
                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile,"busy",false] call ALIVE_fnc_hashSet;
                    };
                } forEach _x;

            } forEach _mechanisedProfiles;

            {
                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile,"busy",false] call ALIVE_fnc_hashSet;
                    };
                } forEach _x;

            } forEach _motorisedProfiles;

            {
                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile,"busy",false] call ALIVE_fnc_hashSet;
                    };
                } forEach _x;

            } forEach _planeProfiles;

            {
                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile,"busy",false] call ALIVE_fnc_hashSet;
                    };
                } forEach _x;

            } forEach _heliProfiles;


            // -----------------------------------------------------------------
            // FIX: Start stalled unit watchdog for all released cargo profiles
            // to ensure units move toward their destination if OPCOM does not
            // pick them up promptly after delivery.
            // -----------------------------------------------------------------
            private _allCargoProfileIDs = [];
            {
                if (count _x > 0) then {
                    _allCargoProfileIDs pushback (_x select 0);
                };
            } forEach _infantryProfiles;
            {
                if (count _x > 0) then {
                    _allCargoProfileIDs pushback (_x select 0);
                };
            } forEach _armourProfiles;
            {
                if (count _x > 0) then {
                    _allCargoProfileIDs pushback (_x select 0);
                };
            } forEach _motorisedProfiles;

            if (count _allCargoProfileIDs > 0) then {
                private _finalDest = [_event, "finalDestination"] call ALIVE_fnc_hashGet;
                if (count _finalDest > 0) then {
                    [_logic, "spawnStalledUnitWatchdog", [
                        _allCargoProfileIDs,
                        _finalDest,
                        _eventFaction,
                        _side
                    ]] call MAINCLASS;

                    if (_debug) then {
                        ["ML - setEventProfilesAvailable: Stalled unit watchdog started for %1 profiles at destination %2",
                            count _allCargoProfileIDs, _finalDest] call ALiVE_fnc_dump;
                    };
                };
            };
            // -----------------------------------------------------------------


            // dispatch event
            _finalDestination = [_event, "finalDestination"] call ALIVE_fnc_hashGet;
            _logEvent = ['LOGISTICS_COMPLETE', [_finalDestination,_eventFaction,_side,_eventID],"Logistics"] call ALIVE_fnc_event;
            [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

            // Arrival summary -- always logged
            {
                private _finalDest2 = [_event, "finalDestination"] call ALIVE_fnc_hashGet;
                private _arrName = if (count _finalDest2 > 0) then { [_finalDest2] call ALIVE_fnc_taskGetNearestLocationName } else { "unknown" };
                ["ML - ARRIVED [%1] event=%2 faction=%3 destination=%4 at %5",
                    ([_event, "data"] call ALIVE_fnc_hashGet) select 4,
                    _eventID, _eventFaction, _arrName, _finalDest2] call ALiVE_fnc_dump;
            } forEach [[]];

            // Register the delivery destination as a valid supply network node.
            // Store the delivered profile IDs alongside the position so future
            // checks can verify those units still exist before using this
            // location as a departure base.
            if (count _finalDestination > 0 && !isNil "ALIVE_ML_supplyNetwork") then {
                private _nodes = [ALIVE_ML_supplyNetwork, _eventFaction, []] call ALIVE_fnc_hashGet;

                // Collect all delivered cargo profile IDs
                private _deliveredIDs = [];
                { if (count _x > 0) then { _deliveredIDs pushBack (_x select 0); }; } forEach _infantryProfiles;
                { if (count _x > 0) then { _deliveredIDs pushBack (_x select 0); }; } forEach _motorisedProfiles;
                { if (count _x > 0) then { _deliveredIDs pushBack (_x select 0); }; } forEach _mechanisedProfiles;
                { if (count _x > 0) then { _deliveredIDs pushBack (_x select 0); }; } forEach _armourProfiles;

                if (count _deliveredIDs > 0) then {
                    // Check if a node for this position already exists and merge
                    private _existingIdx = -1;
                    {
                        if ((_x select 0) distance2D _finalDestination < 500) exitWith { _existingIdx = _forEachIndex; };
                    } forEach _nodes;

                    if (_existingIdx >= 0) then {
                        private _existingNode = _nodes select _existingIdx;
                        private _existingIDs  = _existingNode select 1;
                        { _existingIDs pushBackUnique _x; } forEach _deliveredIDs;
                    } else {
                        _nodes pushBack [_finalDestination, _deliveredIDs];
                    };

                    [ALIVE_ML_supplyNetwork, _eventFaction, _nodes] call ALIVE_fnc_hashSet;

                    if (_debug) then {
                        ["ML - Supply network: delivery registered for faction %1 at %2. %3 profiles. Total nodes: %4",
                            _eventFaction, _finalDestination, count _deliveredIDs, count _nodes] call ALiVE_fnc_dump;
                    };
                };
            };


        }else{

            // Player requested

            private ["_emptyProfiles","_joinIndividualProfiles","_staticIndividualProfiles","_reinforceIndividualProfiles",
            "_joinGroupProfiles","_staticGroupProfiles","_reinforceGroupProfiles","_payloadGroupProfiles","_player","_logEvent","_finalDestination"];

            _emptyProfiles = [_playerRequestProfiles,"empty"] call ALIVE_fnc_hashGet;
            _joinIndividualProfiles = [_playerRequestProfiles,"joinIndividuals"] call ALIVE_fnc_hashGet;
            _staticIndividualProfiles = [_playerRequestProfiles,"staticIndividuals"] call ALIVE_fnc_hashGet;
            _reinforceIndividualProfiles = [_playerRequestProfiles,"reinforceIndividuals"] call ALIVE_fnc_hashGet;
            _joinGroupProfiles = [_playerRequestProfiles,"joinGroups"] call ALIVE_fnc_hashGet;
            _staticGroupProfiles = [_playerRequestProfiles,"staticGroups"] call ALIVE_fnc_hashGet;
            _reinforceGroupProfiles = [_playerRequestProfiles,"reinforceGroups"] call ALIVE_fnc_hashGet;
            _payloadGroupProfiles = [_playerRequestProfiles,"payloadGroups"] call ALIVE_fnc_hashGet;

            // reinforce profiles get released
            // to OPCOM control

            // Resolve garrison position for player-requested reinforceIndividuals --
            // use the event's final delivery position so they hold ground at the LZ
            // rather than standing idle until OPCOM picks them up. Mirrors the AI-path
            // treatment for _infantryProfiles above.
            private _reinforceGarrisonPos = [_event, "finalDestination"] call ALIVE_fnc_hashGet;
            if (isNil "_reinforceGarrisonPos" || count _reinforceGarrisonPos == 0) then {
                _reinforceGarrisonPos = _eventPosition;
            };

            {
                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile,"busy",false] call ALIVE_fnc_hashSet;

                        // Clear any vehicle assignment left over from heli transport.
                        // Player-requested reinforcements inserted via PR_HELI_INSERT
                        // carry stale vehicleAssignments pointing at the (now destroyed)
                        // transport heli. Without this cleanup, OPCOM sees corrupt
                        // speedPerSecond and may fail to re-task them.
                        private _vAssign = [_profile, "vehicleAssignments"] call ALIVE_fnc_hashGet;
                        if (!isNil "_vAssign" && { typeName _vAssign == "ARRAY" } && { count _vAssign >= 2 } && { count (_vAssign select 1) > 0 }) then {
                            private _emptyHash = [] call ALIVE_fnc_hashCreate;
                            [_profile, "vehicleAssignments", _emptyHash] call ALIVE_fnc_hashSet;
                            [_profile, "vehiclesInCargoOf", []] call ALIVE_fnc_hashSet;
                            [_profile, "vehiclesInCommandOf", []] call ALIVE_fnc_hashSet;
                            [_profile, "speedPerSecond", "Man" call ALIVE_fnc_vehicleGetSpeedPerSecond] call ALIVE_fnc_hashSet;
                        };

                        // Assign garrison duty at the delivery position so reinforcements
                        // hold the area immediately on arrival. OPCOM can override this
                        // with its own orders once it picks them up.
                        [_profile, "setActiveCommand", [
                            "ALIVE_fnc_managedGarrison", "managed", [200, "false", _reinforceGarrisonPos]
                        ]] call ALIVE_fnc_profileEntity;

                        if (_debug) then {
                            ["ML - setEventProfilesAvailable: Garrison assigned to reinforceIndividual %1 at %2",
                                _x, _reinforceGarrisonPos] call ALiVE_fnc_dump;
                        };
                    };
                } forEach _x;

            } forEach _reinforceIndividualProfiles;

            {
                {
                    _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                    if!(isNil "_profile") then {
                        [_profile,"busy",false] call ALIVE_fnc_hashSet;
                    };
                } forEach _x;

            } forEach _reinforceGroupProfiles;


            // find the player object

            if((isServer && isMultiplayer) || isDedicated) then {

                _player = objNull;
                {
                    if (getPlayerUID _x == _playerID) exitWith {
                        _player = _x;
                    };
                } forEach playableUnits;
            }else{

                 _player = player;
            };

            // player found

            if (!(isNull _player)) then {

                private ["_active","_type","_units"];

                // join player profiles, if active
                // join the player group

                {
                    {
                        _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                        if!(isNil "_profile") then {

                            _active = _profile select 2 select 1;
                            _type = _profile select 2 select 5;

                            if(_type == "entity") then {

                                if(_active) then {

                                    _units = _profile select 2 select 21;

                                    _units joinSilent (group _player);

                                    [ALIVE_profileHandler, "unregisterProfile", _profile] call ALIVE_fnc_profileHandler;
                                }else{

                                    [_profile,"busy",false] call ALIVE_fnc_hashSet;

                                };

                            }else{

                                if!(_active) then {

                                    [_profile,"busy",false] call ALIVE_fnc_hashSet;

                                };

                            };

                        };
                    } forEach _x;

                } forEach _joinIndividualProfiles;

                {
                    {
                        _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                        if!(isNil "_profile") then {

                            _active = _profile select 2 select 1;
                            _type = _profile select 2 select 5;

                            if(_type == "entity") then {

                                if(_active) then {

                                    _units = _profile select 2 select 21;

                                    _units joinSilent (group _player);

                                    [ALIVE_profileHandler, "unregisterProfile", _profile] call ALIVE_fnc_profileHandler;
                                }else{

                                    [_profile,"busy",false] call ALIVE_fnc_hashSet;

                                };

                            }else{

                                if!(_active) then {

                                    [_profile,"busy",false] call ALIVE_fnc_hashSet;

                                };

                            };

                        };
                    } forEach _x;

                } forEach _joinGroupProfiles;

                // static defence profiles
                // if active set to garrison
                // nearby structures

                {
                    {
                        _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                        if!(isNil "_profile") then {

                            _active = _profile select 2 select 1;
                            _type = _profile select 2 select 5;

                            if(_type == "entity") then {

                                if(_active) then {
                                    // [_profile, "setActiveCommand", ["ALIVE_fnc_managedGarrison","managed",[200,"false",_eventPosition]]] call ALIVE_fnc_profileEntity;
                                    [_profile, "setActiveCommand", ["ALIVE_fnc_managedGarrison","managed",[200,"false",_eventPosition, (count _staticIndividualProfiles)]]] call ALIVE_fnc_profileEntity;

                                }else{

                                    [_profile,"busy",false] call ALIVE_fnc_hashSet;

                                };

                            }else{

                                if!(_active) then {

                                    [_profile,"busy",false] call ALIVE_fnc_hashSet;

                                };

                            };

                        };
                    } forEach _x;

                } forEach _staticIndividualProfiles;

                {
                    if(count _x < 2) then {

                        _profile = [ALIVE_profileHandler, "getProfile", (_x select 0)] call ALIVE_fnc_profileHandler;
                        if!(isNil "_profile") then {

                            _active = _profile select 2 select 1;
                            _type = _profile select 2 select 5;

                            if(_type == "entity") then {

                                if(_active) then {

                                    // [_profile, "setActiveCommand", ["ALIVE_fnc_managedGarrison","managed",[200,"false",_eventPosition]]] call ALIVE_fnc_profileEntity;
                                    [_profile, "setActiveCommand", ["ALIVE_fnc_managedGarrison","managed",[200,"false",_eventPosition, (count _staticGroupProfiles)]]] call ALIVE_fnc_profileEntity;

                                }else{

                                    [_profile,"busy",false] call ALIVE_fnc_hashSet;

                                };

                            }else{

                                if!(_active) then {

                                    [_profile,"busy",false] call ALIVE_fnc_hashSet;

                                };

                            };

                        };

                    };

                } forEach _staticGroupProfiles;

                // If payload profiles are still carrying their load, wait a while then dump them
                private ["_payloadProfiles","_payloadProfileID","_payloadVehicleID","_payloadProfile","_payloadVehicle","_payloadCount",
                "_reinforcementPosition","_position","_vehicle"];

                _payloadProfiles = [];

                {
                    if(count _x > 1) then {
                        _payloadProfileID = _x select 0;
                        _payloadVehicleID = _x select 1;

                        _payloadProfile = [ALIVE_profileHandler, "getProfile", _payloadProfileID] call ALIVE_fnc_profileHandler;
                        _payloadVehicle = [ALIVE_profileHandler, "getProfile", _payloadVehicleID] call ALIVE_fnc_profileHandler;

                        if(!(isNil "_payloadProfile") && !(isNil "_payloadVehicle")) then {
                            _payloadProfiles pushback [_payloadProfileID, _payloadVehicleID];

                            _vehicle = _payloadVehicle select 2 select 10;

                            [_event, "finalDestination", position _vehicle] call ALIVE_fnc_hashSet;
                        };
                    };

                } forEach _payloadGroupProfiles;

                if(count _payloadProfiles > 0) then {

                    _reinforcementPosition = [_reinforcementPrimaryObjective,"center"] call ALIVE_fnc_hashGet;
                    _position = _reinforcementPosition getPos [1500, (([_event, "finalDestination"] call ALIVE_fnc_hashGet) getDir _reinforcementPosition)];

                    [_payloadGroupProfiles,_position] spawn {

                        private ["_payloadProfiles","_returnPosition","_currentTime","_waitTime","_profileWaypoint","_anyActive","_active",
                        "_profileCount","_vehicle"];

                        _payloadProfiles = _this select 0;
                        _returnPosition = _this select 1;

                        // Check to see if payload profiles are ready to return
                        // Slingloaders can return once done.
                        // If vehicle no longer has cargo it can return

                        private ["_payloadUnloaded"];

                        _payloadUnloaded = true;

                        {
                            private ["_Profile","_vehicleProfile"];

                            _vehicleProfile = [ALIVE_profileHandler, "getProfile", _x select 1] call ALIVE_fnc_profileHandler;

                            if!(isNil "_vehicleProfile") then {

                                private ["_active","_slingLoading","_slingload","_noCargo","_vehicle"];

                                _active = _vehicleProfile select 2 select 1;

                                _slingLoading = [_vehicleProfile,"slingloading",false] call ALiVE_fnc_hashGet;

                                _vehicle = _vehicleProfile select 2 select 10;
                                _noCargo = count (_vehicle getvariable ["ALiVE_SYS_LOGISTICS_CARGO",[]]) == 0;

                                // If payload vehicle is not slingloading and its cargo is empty - its done.
                                TRACE_2("PR UNLOADED", !_slingLoading, _noCargo);

                                if( _active && _noCargo && !_slingloading ) then {
                                    _payloadUnloaded = true;

                                } else {

                                    _payloadUnloaded = false;

                                };

                                // If we've run out of time, dump cargo
                                if (_active && !_noCargo) then {
                                    [MOD(SYS_LOGISTICS),"unloadObjects",[_vehicle,_vehicle]] call ALiVE_fnc_logistics;
                                };

                                // Drop slingload
                                if (_active && _slingloading) then {
                                    private ["_slungID"];
                                    _slungID = ([_vehicleProfile, 'slingload'] call ALIVE_fnc_profileVehicle) select 0;
                                    if (typeName _slungID == 'ARRAY') then {
                                        private ["_slungprofile"];
                                        _slungprofile = [ALIVE_profileHandler,'getProfile',_slungID select 0] call ALIVE_fnc_profileHandler;
                                        [_slungprofile, 'slung', []] call ALIVE_fnc_hashSet;
                                        [_slungProfile,'spawnType',[]] call ALIVE_fnc_profileVehicle;
                                    };
                                    [_vehicleProfile, 'slingload', []] call ALIVE_fnc_profileVehicle;
                                    [_vehicleProfile, 'slingloading', false] call ALIVE_fnc_hashSet;
                                    _vehicle setSlingLoad objNull;
                                    // Delete current unhook waypoint
                                    deleteWaypoint [group _vehicle, (currentWaypoint (group _vehicle))];
                                };

                            };
                        } foreach _payloadProfiles;

                        _waitTime = 12; // 2 minutes = 12 x 10 secs
                        _currentTime = 0;

                        if (!_payloadUnloaded) then {
                            waituntil {
                                sleep 10;
                                _currentTime = _currentTime + 1;
                                (_currentTime > _waitTime)
                            };
                        };

                        _profileWaypoint = [_returnPosition, 100, "MOVE", "FULL", 300, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                        _profileCount = 0;

                        {
                            private ["_payloadProfile"];
                            _payloadProfile = _x;
                            {
                                private ["_payloadProfileID","_payloadProfile","_isEntity"];
                                _payloadProfileID = _x;

                                _payloadProfile = [ALIVE_profileHandler, "getProfile", _payloadProfileID] call ALIVE_fnc_profileHandler;

                                // Guard: getProfile returns nil when a payload profile has
                                // been un-registered before cleanup runs (e.g. transport heli
                                // destroyed during RTB). Calling hashGet on nil throws
                                // "[any,'type']" and leaves _isEntity undeclared, cascading a
                                // second "Undefined variable _isEntity" error on the if() below.
                                if (isNil "_payloadProfile") exitWith {
                                    ["ML - setEventProfilesAvailable: skipping un-registered payload profile %1", _payloadProfileID] call ALiVE_fnc_dump;
                                };

                                _isEntity = [_payloadProfile,"type"] call ALiVE_fnc_hashGet != "vehicle";

                                if (_isEntity) then {
                                    [_payloadProfile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                                    _profileCount = _profileCount + 1;
                                };
                            } foreach _payloadProfile;

                        } forEach _payloadProfiles;

                        if(_profileCount > 0) then {

                            waituntil {
                                sleep (10);

                                _anyActive = 0;

                                // once transport vehicles are inactive
                                // dispose of the profiles
                                {

                                    if (count _x > 0) then {
                                        private ["_ID","_profile","_pVehicle"];
                                        _ID = _x select 0;
                                        _profile = [ALIVE_profileHandler, "getProfile", _ID] call ALIVE_fnc_profileHandler;

                                        if (count _x > 1) then {
                                            _ID = _x select 1;
                                            _pVehicle = [ALIVE_profileHandler, "getProfile", _ID] call ALIVE_fnc_profileHandler;
                                        };

                                        if(!(isNil "_profile") && !(isNil "_pVehicle")) then {

                                            _vehicle = _pVehicle select 2 select 10;

                                            if([position _vehicle, 1500] call ALiVE_fnc_anyPlayersInRange == 0) then {

                                                [_profile, "destroy"] call ALIVE_fnc_profileEntity;
                                                [_pVehicle, "destroy"] call ALIVE_fnc_profileVehicle;

                                                //[ALIVE_profileHandler, "unregisterProfile", _payloadProfile] call ALIVE_fnc_profileHandler;
                                                //[ALIVE_profileHandler, "unregisterProfile", _payloadVehicle] call ALIVE_fnc_profileHandler;

                                            }else{

                                                _anyActive = _anyActive + 1;

                                            };

                                        };
                                    };

                                } forEach _payloadProfiles;

                                (_anyActive == 0)
                            };

                            //["PAYLOAD RTB COMPLETE!!!!"] call ALIVE_fnc_dump;

                        };

                    };

                    // dispatch event
                    _finalDestination = [_event, "finalDestination"] call ALIVE_fnc_hashGet;
                    _logEvent = ['LOGISTICS_COMPLETE', [_finalDestination,_eventFaction,_side,_eventID],"Logistics"] call ALIVE_fnc_event;
                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                    // respond to player request
                    if(_playerRequested) then {
                        _finalDestination = [_event, "finalDestination"] call ALIVE_fnc_hashGet;
                        _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID,_finalDestination,true],"Logistics","REQUEST_DELIVERED"] call ALIVE_fnc_event;
                        [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                    };



                }else{

                    // dispatch event
                    _finalDestination = [_event, "finalDestination"] call ALIVE_fnc_hashGet;
                    _logEvent = ['LOGISTICS_COMPLETE', [_finalDestination,_eventFaction,_side,_eventID],"Logistics"] call ALIVE_fnc_event;
                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                    // respond to player request
                    if(_playerRequested) then {
                        _finalDestination = [_event, "finalDestination"] call ALIVE_fnc_hashGet;
                        _logEvent = ['LOGCOM_RESPONSE', [_requestID,_playerID,_finalDestination,false],"Logistics","REQUEST_DELIVERED"] call ALIVE_fnc_event;
                        [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                    };

                };

            }else{

                // player not found just set
                // the requested groups as
                // reinforcements

                {
                    {
                        _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                        if!(isNil "_profile") then {
                            [_profile,"busy",false] call ALIVE_fnc_hashSet;
                        };
                    } forEach _x;

                } forEach _reinforceIndividualProfiles;

                {
                    {
                        _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                        if!(isNil "_profile") then {
                            [_profile,"busy",false] call ALIVE_fnc_hashSet;
                        };
                    } forEach _x;

                } forEach _reinforceGroupProfiles;

                {
                    {
                        _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                        if!(isNil "_profile") then {
                            [_profile,"busy",false] call ALIVE_fnc_hashSet;
                        };
                    } forEach _x;

                } forEach _staticIndividualProfiles;

                {
                    {
                        _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                        if!(isNil "_profile") then {
                            [_profile,"busy",false] call ALIVE_fnc_hashSet;
                        };
                    } forEach _x;

                } forEach _staticGroupProfiles;


                // dispatch event
                _finalDestination = [_event, "finalDestination"] call ALIVE_fnc_hashGet;
                _logEvent = ['LOGISTICS_COMPLETE', [_finalDestination,_eventFaction,_side,_eventID],"Logistics"] call ALIVE_fnc_event;
                [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

            };

        };
    };

    case "removeEvent": {
        private["_debug","_eventID","_eventQueue"];

        // remove the event from the queue

        _eventID = _args;
        _eventQueue = [_logic, "eventQueue"] call MAINCLASS;

        [_eventQueue,_eventID] call ALIVE_fnc_hashRem;

        [_logic, "eventQueue", _eventQueue] call MAINCLASS;

    };
};

TRACE_1("ML - output",_result);
_result ;
