#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(spawnObjectiveObjects);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_spawnObjectiveObjects

Description:
    Reads the consolidated structured-string `objectiveObjects` setVariable
    off the passed module logic, parses it into a flat list of class
    names, and spawns N random selections at validator-checked positions
    within the module's area of influence.

    Storage format (set by ALiVE_ObjectiveObjectChoice's SAVE handler):
        "radar:Class1,Class2;antenna:Class3;dataTerminal:;jammer:;comms:Class4;staticData:Class5"

    Empty string OR _count <= 0 = skip (no objects spawned). Mirrors the
    AA-style triplet pattern where:
      - aaCount     -> objectiveObjectsCount     ("Spawn Objective Units")
      - aaBehaviour -> objectiveObjectsBehaviour ("Objective Behaviour")
      - aaClasses   -> objectiveObjects (picker)

    Distribution shapes (passed via _behaviour):
      - "clustered" - tight cluster near the center (5-30% of radius)
      - "dispersed" - spread evenly across the area (25-95% of radius)
                      Default when _behaviour is empty / unrecognised.
      - "perimeter" - ring at the edge of the search radius (80-100%)

    Spawn policy:
      - findCompositionSpawnPosition mode="field" validates each
        candidate (rejects roads, runways/taxiways, helipads, buildings,
        water, steep slopes, soft surfaces)
      - Neighbour-aware search radius cap: half-distance to nearest
        other ALiVE placement-class module so adjacent modules don't
        spawn into each other's territory
      - 25m minimum separation between placed objects
      - Selection from picker pool with replacement (selectRandom per
        spawn) - count > pool size means duplicates appear

    Backs GitHub issue #875 ("Add objects to objectives"). Shared by all
    consuming modules (mil_placement / mil_placement_custom / civ_placement /
    civ_placement_custom / mil_ato).

Parameters:
    [_logic, _centerPos, _baseRadius, _count, _behaviour, _debug]

    _logic       : OBJECT - module logic that owns the objectiveObjects
                            setVariable
    _centerPos   : ARRAY  - [x, y, z] center to spawn around
    _baseRadius  : SCALAR - module's preferred spawn radius (from its
                            size attribute or a per-module default).
                            Capped by neighbour-aware logic, floored
                            at 50m, ceilinged at 400m.
    _count       : SCALAR - how many objects to spawn. <=0 = skip.
    _behaviour   : STRING - "clustered" / "dispersed" / "perimeter".
                            Empty / unrecognised falls back to "dispersed".
    _debug       : BOOL   - whether to log spawn results via ALiVE_fnc_dump

Returns:
    NUMBER - count of objects successfully spawned

Author:
    Jman
---------------------------------------------------------------------------- */

params [
    ["_logic", objNull, [objNull]],
    ["_centerPos", [0,0,0], [[]], [3]],
    ["_baseRadius", 150, [0]],
    ["_count", 0, [0]],
    ["_behaviour", "dispersed", [""]],
    ["_debug", false, [false]]
];

if (isNull _logic) exitWith { 0 };
if (_count <= 0) exitWith { 0 };

private _raw = _logic getVariable ["objectiveObjects", ""];
if (typeName _raw != "STRING" || {_raw == ""}) exitWith { 0 };

// Parse "cat1:c1,c2;cat2:c3" into a flat class-name list.
private _picked = [];
{
    private _seg = _x;
    private _colon = _seg find ":";
    if (_colon > 0) then {
        private _classesStr = _seg select [_colon + 1];
        {
            private _cls = _x;
            while {count _cls > 0 && {(_cls select [0,1]) == " "}} do { _cls = _cls select [1] };
            while {count _cls > 0 && {(_cls select [count _cls - 1, 1]) == " "}} do {
                _cls = _cls select [0, count _cls - 1];
            };
            if (_cls != "") then { _picked pushBackUnique _cls };
        } forEach ([_classesStr, ","] call CBA_fnc_split);
    };
} forEach ([_raw, ";"] call CBA_fnc_split);

if (count _picked == 0) exitWith {
    if (_debug) then {
        ["ALiVE_fnc_spawnObjectiveObjects: count=%1 but picker pool empty - nothing to spawn", _count] call ALiVE_fnc_dump;
    };
    0
};

// ---- Neighbour-aware search radius cap ------------------------------------
if (_baseRadius <= 0) then { _baseRadius = 150 };
private _searchRadius = [_logic, _centerPos, _baseRadius, 50, 400] call ALIVE_fnc_neighbourAwareSearchCap;

// ---- Distribution shape -> ring distances ---------------------------------
// "clustered" -> tight near center
// "dispersed" -> default; spread evenly
// "perimeter" -> edge of the area
private _ringDistances = switch (toLower _behaviour) do {
    case "clustered": {
        [_searchRadius * 0.05, _searchRadius * 0.12, _searchRadius * 0.18,
         _searchRadius * 0.24, _searchRadius * 0.30]
    };
    case "perimeter": {
        [_searchRadius * 0.80, _searchRadius * 0.85, _searchRadius * 0.90,
         _searchRadius * 0.95, _searchRadius]
    };
    default {  // dispersed (also catches "" / unrecognised)
        [_searchRadius * 0.25, _searchRadius * 0.45, _searchRadius * 0.60,
         _searchRadius * 0.78, _searchRadius * 0.95]
    };
};

// ---- Spawn loop ------------------------------------------------------------
// Selection from picker pool with replacement (selectRandom per spawn).
// _count drives the loop, NOT count of _picked - so a single-class pool
// + _count=10 spawns 10 of that class.
private _placed = 0;
private _usedPositions = [];
private _minSeparation = 25;

for "_i" from 1 to _count do {
    private _cls = selectRandom _picked;

    // Ring-grid candidates - 12 angles x 5 distance rings = 60.
    private _candidates = [];
    {
        private _ring = _x;
        for "_a" from 0 to 11 do {
            private _angle = _a * 30 + (random 25);
            _candidates pushBack [
                (_centerPos select 0) + _ring * (sin _angle),
                (_centerPos select 1) + _ring * (cos _angle),
                _centerPos param [2, 0]
            ];
        };
    } forEach _ringDistances;
    _candidates = _candidates call BIS_fnc_arrayShuffle;

    private _accepted = false;
    private _safePos = [];
    private _safeDir = 0;
    {
        if (_accepted) exitWith {};
        private _cand = _x;
        if ((_cand distance2D _centerPos) <= _searchRadius) then {
            // Envelope bumped 10 -> 20m so the validator checks a wider
            // clear area. POOK SAM radars and similar tower-class
            // objective scenery have wide footprints (base plus tower
            // plus dish/launcher) - a 10m envelope can approve a pos
            // whose center is just off-road while the actual model
            // overlaps the road.
            private _result = [_cand, 20, 20, "field", random 360, false, 0.6] call ALiVE_fnc_findCompositionSpawnPosition;
            if (count _result >= 2) then {
                private _testPos = _result select 0;
                // Post-validator road backstop - layered check. The
                // validator's field mode rejects classified roads but
                // unclassified dirt paths / trails / drivable surfaces
                // outside CfgRoads slip through. Two-pass detection:
                //   1. nearRoads 20 catches any CfgRoads object within
                //      20m of the candidate (classified roads).
                //   2. isOnRoad sampled at 8 ring positions (8m radius)
                //      catches drivable surfaces the engine considers
                //      road but aren't in CfgRoads. Some dirt paths /
                //      trails register as drivable without a Road
                //      object. Catches the case the screenshot showed
                //      (radar on dirt path).
                private _onRoad = false;
                private _nearbyRoads = _testPos nearRoads 20;
                if (count _nearbyRoads > 0) then { _onRoad = true; };
                if (!_onRoad) then {
                    for "_a" from 0 to 7 do {
                        private _samplePt = _testPos getPos [8, _a * 45];
                        if (isOnRoad _samplePt) exitWith { _onRoad = true; };
                    };
                };
                if (_onRoad) then {
                    if (_debug) then {
                        ["ALiVE_fnc_spawnObjectiveObjects: candidate %1 rejected by road backstop (nearRoads20=%2 isOnRoad-ring=%3)",
                            _testPos, count _nearbyRoads, _onRoad] call ALiVE_fnc_dump;
                    };
                } else {
                    private _tooClose = false;
                    {
                        if (_testPos distance2D _x < _minSeparation) exitWith { _tooClose = true };
                    } forEach _usedPositions;
                    if (!_tooClose) then {
                        _safePos = _testPos;
                        _safeDir = _result select 1;
                        _accepted = true;
                    };
                };
            };
        };
    } forEach _candidates;

    if (_accepted) then {
        _usedPositions pushBack _safePos;
        // Spawn via ALIVE_fnc_createProfileVehicle so the object enters
        // ALiVE's profile system (virtualises when no players nearby,
        // persists across save/load, tracked for damage / lifecycle).
        // Mirrors AA placement pattern. createCrew=false because
        // scenery doesn't need crew. Falls back to direct createVehicle
        // if the profile call returns nil (some pure-scenery classes
        // like Land_Antenna may not be profileable).
        private _faction = _logic getVariable ["faction", ""];
        if (_faction == "") then { _faction = "CIV" };
        private _factionConfig = _faction call ALiVE_fnc_configGetFactionClass;
        private _factionSideNumber = if (!isNil "_factionConfig") then { getNumber (_factionConfig >> "side") } else { 3 };
        private _side = _factionSideNumber call ALIVE_fnc_sideNumberToText;
        // Anything with a crew unit configured in CfgVehicles needs crew
        // to actually scan / track / engage / drive (POOK SAM radar masts,
        // ZSU AA gun trucks, EAA launcher vehicles, AA tanks). Pure scenery
        // (signal panels, satellite dish props, antennas, transmitter
        // boxes) has no crew config. Detect via getText >> crew and route
        // accordingly:
        //   has crew -> createProfilesCrewedVehicle (registers crew profile
        //               alongside the vehicle so the spawn handler
        //               instantiates gunner / driver / commander on
        //               profile activation)
        //   no crew  -> createProfileVehicle (scenery)
        // Detection covers ALL vehicle kinds (Tank, Wheeled_APC, Plane,
        // Helicopter, StaticWeapon) without enumerating each.
        private _crewClass = getText (configFile >> "CfgVehicles" >> _cls >> "crew");
        if (_crewClass != "") then {
            [_cls, _side, _faction, "PRIVATE", _safePos, _safeDir, false, _faction] call ALIVE_fnc_createProfilesCrewedVehicle;
        } else {
            [_cls, _side, _faction, _safePos, _safeDir, false, _faction] call ALIVE_fnc_createProfileVehicle;
        };
        // Force upright via the profile-spawn path. Slot 10 is objNull
        // until ALiVE later activates the profile (player proximity);
        // pass classname + position so the helper wires the class init
        // EH that fires when the engine eventually creates the entity.
        // Persistent across virtualisation cycles - the EH re-fires on
        // every respawn since the profile schema only stores pos+dir,
        // not vectorUp.
        [objNull, _safeDir, _cls, _safePos] call ALIVE_fnc_registerForceUpright;
        _placed = _placed + 1;

            // Debug markers - mirrors AA placement pattern.
            //   - small anchor dot at the actual spawn position
            //   - labeled marker at 60m radial offset away from the
            //     center, with per-index angular jitter so multi-pick
            //     sets don't stack their labels on a single compass slot.
            // ColorPink keeps objective-object markers visually distinct
            // from AA (orange) and other placement emitters' colours.
            if (_debug) then {
                private _label = format ["Obj Obj #%1 [%2]", _placed, _cls];
                private _dx = (_safePos select 0) - (_centerPos select 0);
                private _dy = (_safePos select 1) - (_centerPos select 1);
                private _norm = sqrt (_dx * _dx + _dy * _dy);
                if (_norm < 1) then { _dx = 1; _dy = 0; _norm = 1 };
                _dx = _dx / _norm; _dy = _dy / _norm;
                private _jitterAngles = [0, 30, -30, 60, -60, 90, -90];
                private _jit = _jitterAngles select ((_placed - 1) mod (count _jitterAngles));
                private _cosJ = cos _jit; private _sinJ = sin _jit;
                private _rdx = _cosJ * _dx - _sinJ * _dy;
                private _rdy = _sinJ * _dx + _cosJ * _dy;
                private _labelPos = [
                    (_safePos select 0) + _rdx * 60,
                    (_safePos select 1) + _rdy * 60,
                    _safePos param [2, 0]
                ];
                [_safePos, 1, "", "ColorPink"] call ALIVE_fnc_placeDebugMarker;
                [_labelPos, 3, _label, "ColorPink"] call ALIVE_fnc_placeDebugMarker;
            };
    } else {
        if (_debug) then {
            ["ALiVE_fnc_spawnObjectiveObjects: no clear position found for %1 within %2m of %3 (already-placed=%4 behaviour=%5)",
                _cls, _searchRadius, _centerPos, count _usedPositions, _behaviour] call ALiVE_fnc_dump;
        };
    };
};

if (_debug) then {
    ["ALiVE_fnc_spawnObjectiveObjects: logic=%1 center=%2 searchRadius=%3 count=%4 behaviour=%5 poolSize=%6 placed=%7 raw=%8",
        _logic, _centerPos, _searchRadius, _count, _behaviour, count _picked, _placed, _raw] call ALiVE_fnc_dump;
};

_placed
