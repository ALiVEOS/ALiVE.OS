#include "\x\alive\addons\civ_placement\script_component.hpp"
SCRIPT(createRoadBlock);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_createRoadBlock

Description:
    Generates a RoadBlock at one or more road points within radius.

    Per roadpoint the function:
        1. Skips dead-ends and points within 100 m of an existing roadblock
        2. Resolves a composition from the multi-class picker pool, the
           legacy ALiVE_compositions_roadblocks global override, or the
           category-based fallback (CheckpointsBarricades + Medium/Small)
        3. Runs the chosen composition (or each in shuffled order when the
           picker has multiple ticks) through ALiVE_fnc_findCompositionSpawnPosition
           in mode="roadblock". The validator snaps to the road centreline,
           reports the road tangent as the spawn direction, and rejects the
           candidate if the composition's bbox-sized footprint clips into a
           building / static / sloped surface / sand or mud surface
        4. Spawns the first composition that fits; skips the roadpoint
           entirely when nothing fits

    Validator wiring replaces the old inline checks (fixed 10 m isFlatEmpty
    + 20 m nearestBuilding test) which underestimated the footprint of
    larger checkpoint compositions and could spawn them clipping into
    buildings or onto verges.

    Spawn direction = road tangent (parallel-to-road). Compositions
    designed to sit perpendicular across a road are not auto-detected
    yet - see strategy_roadblock_orientation_autodetect.md.

Parameters:
    Array  - centre position
    Scalar - search radius
    Scalar - roadblock count (capped at 5)
    Bool   - debug
    String - optional. Picker pool: comma-separated class CSV, with optional
             [F:s,z,c,m] filter prefix from the Eden picker. Empty string =
             fall through to the legacy global / category fallback

Returns:
    Array of road positions where roadblocks have been created

Examples:
    (begin example)
    [getPos player, 100, 2] call ALiVE_fnc_createRoadblock;
    [getPos player, 200, 1, true, "RoadBlock_BLU_F,Mil_Concrete_Walls"] call ALiVE_fnc_createRoadblock;
    (end)

See Also:
    ALiVE_fnc_findCompositionSpawnPosition
    ALiVE_fnc_getCompositionRadius

Author:
    Tupolov
    shukari
    Jman
---------------------------------------------------------------------------- */

private [
    "_grp","_roadpos","_vehicle","_vehtype","_blockers","_roads",
    "_roadConnectedTo", "_connectedRoad","_direction","_checkpoint",
    "_checkpointComp","_roadpoints"
];

params [
    ["_pos", [0,0,0], [[]]],
    ["_radius", 500, [-1]],
    ["_num", 1, [-1]],
    ["_debug", false, [true]],
    ["_compClasses", "", [""]]
];

private _result = [];
_vehicle = objNull;

if (isnil QGVAR(ROADBLOCKS)) then {GVAR(ROADBLOCKS) = []};

private _fac = [_pos, _radius] call ALiVE_fnc_getDominantFaction;

if (isNil "_fac") exitWith {
    ["Unable to find a dominant faction within %1 radius", _radius] call ALiVE_fnc_Dump;

    _result;
};

// Limit Roadblock number
if (_num > 5) then {_num = 5};

// Find all the roads
_roads = _pos nearRoads (_radius + 20);

// scan road positions, filter trails, filter runways and find those roads on outskirts
_roads = _roads select {_x distance _pos >= (_radius - 10) || {isOnRoad _x} || {(str _x) find "invisible" == -1}};

if (_roads isEqualTo []) exitWith {
    ["No roads found for roadblock! Cannot create..."] call ALiVE_fnc_dump;

    _result;
};

if (_num > count _roads) then {_num = count _roads};

private _roadpoints = [];
for "_i" from 1 to _num do {
    private "_roadsel";
    while {
        _roadsel = selectRandom _roads;
        (count _roads > 1 && ({_roadsel distance _x < 60} count _roadpoints) != 0)
    } do {
        _roads = _roads - [_roadsel];
    };

    _roadpoints pushback _roadsel;
};

// Composition type for the dominant faction. Determined once outside the
// per-roadpoint loop because it doesn't vary by position.
private _compType = "Military";
if (_fac call ALiVE_fnc_factionSide == RESISTANCE) then {
    _compType = "Guerrilla";
};

// Resolve the picker pool. Cascade:
//   1. Picker (Eden multi-select)        - _compClasses param, after stripping [F:..] prefix
//   2. Legacy global override            - ALiVE_compositions_roadblocks
//   3. Category fallback                 - CheckpointsBarricades / Medium-or-Small
// Picker classes are validated against the composition registry; misspelt
// or absent classes are silently dropped (the user's Override Edit is the
// place to add mod compositions the listbox doesn't surface).
private _pickerPool = [];
private _pickerForParse = _compClasses;
if (count _pickerForParse > 3 && {(_pickerForParse select [0, 3]) == "[F:"}) then {
    private _closeIdx = _pickerForParse find "]";
    if (_closeIdx > 3) then { _pickerForParse = _pickerForParse select [_closeIdx + 1] };
};
if (typeName _pickerForParse == "STRING" && {_pickerForParse != ""} && {_pickerForParse != "false"}) then {
    {
        private _t = _x;
        while {count _t > 0 && {(_t select [0, 1]) == " "}} do { _t = _t select [1] };
        while {count _t > 0 && {(_t select [count _t - 1, 1]) == " "}} do { _t = _t select [0, count _t - 1] };
        if (_t != "") then { _pickerPool pushBackUnique _t };
    } forEach ([_pickerForParse, ","] call CBA_fnc_split);
};

for "_j" from 1 to (count _roadpoints) do {

    _roadpos = _roadpoints select (_j - 1);
    _vehicle = objNull;

    if ({_roadpos distance _x < 100} count GVAR(ROADBLOCKS) > 0) exitWith {["Roadblock %1 too close to another! Not created...",_roadpos] call ALiVE_fnc_dump};

    _roadConnectedTo = roadsConnectedTo _roadpos;

    if (count _roadConnectedTo == 0) exitWith {["Selected road %1 for roadblock is a dead end! Not created...",_roadpos] call ALiVE_fnc_dump};

    // Build the candidate-composition pool for THIS roadpoint. Picker
    // wins; legacy global next; category fallback last. Picker entries are
    // resolved against the live composition registry so an entry the user
    // saved against one mission's mod loadout silently no-ops if that mod
    // isn't loaded this session.
    //
    // Picker entries can be qualified `class|category|size` (new format,
    // disambiguates size variants of the same class) or legacy `class`
    // (old saves + Override Edit free-text). Qualified entries use the
    // size hint to pull the exact variant via getCompositions; legacy
    // entries fall back to findComposition's first-match.
    private _candidates = [];   // array of [_class, _compConfig]
    if (count _pickerPool > 0) then {
        {
            private _entry = _x;
            private _class = _entry;
            private _entrySize = "";
            private _entryCat = "";
            private _pipeIdx = _entry find "|";
            if (_pipeIdx > 0) then {
                _class = _entry select [0, _pipeIdx];
                private _rest = _entry select [_pipeIdx + 1];
                private _pipe2 = _rest find "|";
                if (_pipe2 > 0) then {
                    _entryCat  = _rest select [0, _pipe2];
                    _entrySize = _rest select [_pipe2 + 1];
                } else {
                    _entryCat = _rest;
                };
            };
            private _comp = [];
            if (_entrySize != "" && {_entrySize != "Unspecified"}) then {
                // Qualified path: pull only compositions matching class +
                // size. Lets BIS Checkpoint_BLU_F (Large) and (Medium) be
                // chosen independently rather than collapsing to a random
                // size.
                private _compDef = ([_compType, [_class], [_entrySize], _fac] call ALiVE_fnc_getCompositions);
                if (count _compDef > 0) then { _comp = selectRandom _compDef };
            };
            if (count _comp == 0) then {
                _comp = [_class, _compType] call ALIVE_fnc_findComposition;
            };
            if (count _comp == 0) then {
                private _compDef = ([_compType, [_class], [], _fac] call ALiVE_fnc_getCompositions);
                if (count _compDef > 0) then { _comp = selectRandom _compDef };
            };
            if (count _comp > 0) then { _candidates pushBack [_class, _comp] };
        } forEach _pickerPool;
    };
    if (count _candidates == 0 && {!isNil "ALiVE_compositions_roadblocks"}) then {
        // Legacy mission-init override - one random pick from the global,
        // resolved via findComposition (matches original behaviour).
        private _class = selectRandom ALiVE_compositions_roadblocks;
        private _comp = [_class, _compType] call ALiVE_fnc_findComposition;
        if (count _comp > 0) then { _candidates pushBack [_class, _comp] };
    };
    if (count _candidates == 0) then {
        // Category fallback. Pull up to 3 random Medium/Small CheckpointsBarricades
        // entries so the validator has alternates to try if the closest
        // road point doesn't suit the first pick.
        private _pool = [_compType, ["CheckpointsBarricades"], ["Medium","Small"], _fac] call ALiVE_fnc_getCompositions;
        if (count _pool > 0) then {
            private _shuffled = +_pool;
            private _take = (count _shuffled) min 3;
            for "_k" from 1 to _take do {
                private _c = _shuffled deleteAt (floor random count _shuffled);
                _candidates pushBack [configName _c, _c];
            };
        };
    };

    if (count _candidates == 0) exitWith {
        ["CMP createRoadblock - no candidate compositions for faction %1 (%2) at %3", _fac, _compType, _roadpos] call ALiVE_fnc_dump;
    };

    // Multi-class fitment search. Shuffle once and iterate; first that
    // passes the validator wins. Validator handles snap-to-road, slope,
    // surface, static-obstacle, building-footprint and clearance using
    // the composition's own envelope (from getCompositionRadius). Search
    // radius 60 m matches the existing roadpoint spacing - we want the
    // validator to tolerate a small offset along the road but not jump
    // to a totally different stretch.
    private _shuffled = +_candidates;
    private _spawnedComp = configNull;
    private _spawnedClass = "";
    private _spawnedSafePos = position _roadpos;
    private _spawnedSafeDir = 0;
    while {count _shuffled > 0 && {isNull _spawnedComp}} do {
        private _pick = _shuffled deleteAt (floor random count _shuffled);
        _pick params ["_class", "_comp"];
        private _envelope = ([_comp] call ALiVE_fnc_getCompositionRadius) max 15;
        private _validatorResult = [position _roadpos, 60, _envelope, "roadblock", -1, _debug] call ALiVE_fnc_findCompositionSpawnPosition;
        if (count _validatorResult > 0) then {
            _validatorResult params ["_sp", "_sd"];
            _spawnedComp     = _comp;
            _spawnedClass    = _class;
            _spawnedSafePos  = _sp;
            _spawnedSafeDir  = _sd;
        };
    };

    if (isNull _spawnedComp) exitWith {
        ["CMP createRoadblock [%1] - no candidate fit at roadpoint %2 (%3 candidates tried, validator rejected all - slope / clearance / building footprint)", _fac, _roadpos, count _candidates] call ALiVE_fnc_dump;
    };

    GVAR(ROADBLOCKS) pushBack _spawnedSafePos;

    if (_debug) then {
        ["CMP createRoadblock [%1] - %2 spawned at %3 dir %4 (envelope=%5)", _fac, _spawnedClass, _spawnedSafePos, _spawnedSafeDir, ([_spawnedComp] call ALiVE_fnc_getCompositionRadius)] call ALiVE_fnc_dump;
        // Delete the cluster's queue marker (and its anchor) now that the
        // actual roadblock has spawned. CP / CPC name the queue marker
        // deterministically against the cluster centre so we can target
        // it from here without threading the name through the call args.
        // _pos is the cluster centre (param #1); matching format keeps
        // the two sites in lock-step.
        private _qName = format ["ALiVE_RB_Q_%1_%2", floor (_pos select 0), floor (_pos select 1)];
        deleteMarker _qName;
        deleteMarker (_qName + "_anchor");
        // ColorBrown to distinguish from the civilian cluster palette
        // (HQ=Black, Power=Yellow, Comms=White, Marine=Blue, Rail=Khaki,
        // Fuel=Orange, Construction=Pink, Settlement=Green) and from
        // the per-module placement markers (mil_placement = blue,
        // mil_placement_custom = orange). No emitter id - roadblocks
        // land at unique road points so the compass-slot offset doesn't
        // apply.
        [_spawnedSafePos, 1, format ["RoadBlock - %1 (%2)", _fac, _spawnedClass], "ColorBrown"] call ALiVE_fnc_placeDebugMarker;
    };

    // Walk the composition class list - used downstream by getParkingPosition
    // to avoid parking the road-side vehicle on top of one of its own statics.
    _checkpoint     = _spawnedComp;
    _checkpointComp = _spawnedComp;
    private _config = _checkpoint;
    if (typeName _checkpoint == "ARRAY") then {
        _config = [_checkpoint, configFile] call BIS_fnc_configPath;
    };
    private _compClassnames = [];
    private _objects = [];
    for "_i" from 0 to ((count _config) - 1) do {
        private _item = _config select _i;
        if (isClass _item) then {
            _objects pushback (getText(_item >> "vehicle"));
        };
    };
    {
        if !(_x in _compClassnames) then { _compClassnames pushback _x };
    } forEach _objects;

    _direction = _spawnedSafeDir;

    // Spawn composition
    [_checkpoint,_spawnedSafePos,_direction,_fac] spawn {[_this select 0, _this select 1, _this select 2, _this select 3] call ALiVE_fnc_spawnComposition};

    _result pushback _roadpos;

    // Place a vehicle at side of road
    private _vehicleTypes = [1, _fac, "Car"] call ALiVE_fnc_findVehicleType;
    _vehicleTypes = _vehicleTypes - ALiVE_PLACEMENT_VEHICLEBLACKLIST;

    if (count _vehicleTypes > 0) then {
        _vehtype = selectRandom _vehicleTypes;

        // randomise 50/50 spawn...
        private _randomVehicleDice = round(random 99);
        if (_randomVehicleDice % 2 == 0) then {
            if (!isNil "_vehtype") then {
                private _parkingPosition = [_vehtype, _roadpos, _compClassnames, false] call ALIVE_fnc_getParkingPosition;
                if (count _parkingPosition > 0) then {
                    private _parkPosition = _parkingPosition select 0;
                    private _parkDirection = _parkingPosition select 1;
                    if !(isnil "ALiVE_ProfileHandler") then {
                        _vehicle = [_vehtype, [_fac call ALiVE_fnc_factionSide] call ALiVE_fnc_sideToSideText, _fac, _parkPosition, _parkDirection, true, _fac, [], true] call ALiVE_fnc_createProfileVehicle;
                    } else {
                        // No-profile-handler fallback path: route through the
                        // unified vehicle spawn validator (#850 Phase 2) so
                        // the roadblock vehicle gets the same bbox-aware
                        // footprint clearance + geometry sweep that profile
                        // activations get. Without this the vehicle just
                        // takes _parkPosition unvalidated and can spawn
                        // through walls / fences. Falls back to _parkPosition
                        // if the validator can't find a clear spot - the
                        // allowDamage window below catches the residual case.
                        private _spawnResult = [_vehtype, _parkPosition, 50, "auto", _parkDirection] call ALiVE_fnc_findVehicleSpawnPosition;
                        if (count _spawnResult >= 2) then {
                            _parkPosition = _spawnResult select 0;
                            _parkDirection = _spawnResult select 1;
                        };
                        _vehicle = createVehicle [_vehtype, _parkPosition, [], 0, "NONE"];
                        _vehicle setDir _parkDirection;
                        _vehicle setposATL (getposATL _vehicle);
                        // Same allowDamage settle pattern as the profile path -
                        // if the vehicle did spawn slightly clipped, the engine
                        // gets time to resolve before damage re-engages.
                        _vehicle allowDamage false;
                        [{_this allowDamage true;}, _vehicle, 15] call CBA_fnc_waitAndExecute;
                    };
                    if(_debug) then {
                        ["ALIVE_fnc_createRoadBlock _vehicleClass: %1, _parkPosition: %2, _parkDirection: %3", _vehtype, _parkPosition, _parkDirection] call ALiVE_fnc_dump;
                    };
                };
            };
        };
    };

    // Spawn static virtual group if Profile System is loaded and get them to defend
    if !(isnil "ALiVE_ProfileHandler") then {
        private _group = ["Infantry",_fac] call ALIVE_fnc_configGetRandomGroup;
        private _guards = [_group, _spawnedSafePos, random(360), true, _fac, true] call ALIVE_fnc_createProfilesFromGroupConfig;

        ["ALIVE_fnc_createRoadBlock [%1] - Calling ALIVE_fnc_configGetRandomGroup", _fac] call ALiVE_fnc_dump;

        {
            if (([_x,"type"] call ALiVE_fnc_HashGet) == "entity") then {
                [_x, "setActiveCommand", ["ALIVE_fnc_garrison","spawn",[30,"false",[0,0,0],"",1, 1]]] call ALIVE_fnc_profileEntity;
                [_x,"busy",true] call ALIVE_fnc_hashSet;
            };
        } foreach _guards;

    // else spawn real AI and get them to defend
    } else {
        [_vehicle, _spawnedSafePos, _fac] spawn {
            private["_roadpos","_fac","_vehicle","_side","_blockers"];

            _vehicle = _this select 0;
            _roadpos = _this select 1;
            _fac = _this select 2;
            _side = _fac call ALiVE_fnc_factionSide;

            // Spawn group and get them to defend
            _blockers = [_roadpos, _side, "Infantry", _fac] call ALiVE_fnc_randomGroupByType;
            if !(isNull _vehicle) then {
                _blockers addVehicle _vehicle;
            };

            sleep 1;

            ["ALIVE_fnc_createRoadBlock [%1] - Calling ALIVE_fnc_groupGarrison", _fac] call ALiVE_fnc_dump;

            [_blockers, _roadpos, 100, true, false, 1, nil, 50] call ALIVE_fnc_groupGarrison;
        };
    };

};

_result;
