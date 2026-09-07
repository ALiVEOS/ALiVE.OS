#include "\x\alive\addons\mil_cqb\script_component.hpp"
SCRIPT(test_CQBSpawnStep);

// Run on the server in an ALiVE test mission:
// execVM "\x\alive\addons\mil_cqb\tests\test_CQBSpawnStep.sqf";
if (!isServer) exitWith {};

private _fixtures = [];
private _makeObject = {
    params ["_position"];
    private _object = createVehicleLocal ["Land_HelipadEmpty_F", _position, [], 0, "CAN_COLLIDE"];
    _object enableSimulation false;
    _object setPosATL _position;
    _fixtures pushBack _object;
    _object
};
private _base = [worldSize / 2, worldSize / 2, 0];
private _logic = [[0,0,0]] call _makeObject;
private _house = [_base] call _makeObject;
_logic setVariable ["debug", false];
_logic setVariable ["amount", 2];
_logic setVariable ["UnitsBlackList", []];

private _failures = [];
private _check = {
    params ["_condition", "_message"];
    if (!_condition) then {_failures pushBack _message; diag_log format ["CQB spawn step FAIL: %1", _message]};
};

{
    private _hadSmoothSpawn = !isNil QMOD(smoothSpawn);
    private _savedSmoothSpawn = missionNamespace getVariable [QMOD(smoothSpawn), 0.3];
    private _hadStrategic = !isNil QGVAR(STRATEGICPLATFORMS);
    private _savedStrategic = missionNamespace getVariable [QGVAR(STRATEGICPLATFORMS), []];
    private _hadBlacklist = !isNil QGVAR(UNITBLACKLIST);
    private _savedBlacklist = missionNamespace getVariable [QGVAR(UNITBLACKLIST), []];
    MOD(smoothSpawn) = 0;
    GVAR(STRATEGICPLATFORMS) = [];
    GVAR(UNITBLACKLIST) = [];

    [!canSuspend, "test invokes spawn steps from unscheduled context"] call _check;

    // Stored classes for the same faction bypass candidate discovery.
    _house setVariable ["unittypes", ["B_Soldier_F", "B_Soldier_F"]];
    _house setVariable ["faction", "BLU_F"];
    private _savedContext = createHashMapFromArray [["phase", "classes"], ["faction", "BLU_F"]];
    private _savedResult = [_logic, _house, _savedContext] call ALiVE_fnc_CQBSpawnStep;
    [_savedResult == "running", "saved class selection remains incremental"] call _check;
    [(_savedContext get "phase") == "positions", "matching saved faction advances directly to positions"] call _check;
    [(_savedContext get "unitClasses") isEqualTo ["B_Soldier_F", "B_Soldier_F"], "matching saved classes are reused"] call _check;
    [isNil {_savedContext get "classCandidates"}, "saved classes avoid global candidate scan state"] call _check;

    // Dominant faction selection uses the near set when populated, then falls
    // back to the wider set without rescanning the same profiles.
    private _makeProfile = {
        params ["_position", "_faction"];
        private _data = [];
        _data resize 31;
        _data set [1, false];
        _data set [2, _position];
        _data set [5, "entity"];
        _data set [29, _faction];
        _data set [30, false];
        [[], [], _data]
    };
    private _runDominant = {
        params ["_profiles"];
        private _context = createHashMapFromArray [
            ["phase", "factionProfiles"],
            ["dominantFallbackRadius", 700],
            ["dominantProfiles", _profiles],
            ["dominantGroups", []],
            ["dominantCursor", 0],
            ["dominantNearCounts", createHashMap],
            ["dominantFarCounts", createHashMap],
            ["dominantNearOrder", []],
            ["dominantFarOrder", []]
        ];
        private _result = "running";
        private _steps = 0;
        while {_result == "running" && {(_context get "phase") != "classes"} && {_steps < 20}} do {
            _result = [_logic, _house, _context] call ALiVE_fnc_CQBSpawnStep;
            _steps = _steps + 1;
        };
        [_result, _context]
    };
    private _nearProfile = [_base vectorAdd [100,0,0], "BLU_F"] call _makeProfile;
    private _farProfileA = [_base vectorAdd [400,0,0], "OPF_F"] call _makeProfile;
    private _farProfileB = [_base vectorAdd [500,0,0], "OPF_F"] call _makeProfile;
    ([[_nearProfile, _farProfileA, _farProfileB]] call _runDominant) params ["_nearResult", "_nearContext"];
    [_nearResult == "running" && {(_nearContext get "faction") == "BLU_F"}, "near dominant faction wins over larger fallback count"] call _check;
    ([[_farProfileA, _farProfileB]] call _runDominant) params ["_farResult", "_farContext"];
    [_farResult == "running" && {(_farContext get "faction") == "OPF_F"}, "fallback dominant faction wins when near set is empty"] call _check;

    // An entirely excluded candidate batch fails once and caches that result.
    private _filterContext = createHashMapFromArray [
        ["phase", "classFilter"],
        ["faction", "BLU_F"],
        ["classCandidates", ["B_Helipilot_F"]],
        ["classCursor", 0],
        ["eligibleClasses", []],
        ["baseEligibleCount", 0],
        ["compiledSource", false],
        ["classCacheKey", "test-empty-filter"]
    ];
    private _filterResult = [_logic, _house, _filterContext] call ALiVE_fnc_CQBSpawnStep;
    [_filterResult == "failed", "fully excluded class pool terminates as failure"] call _check;
    private _cache = _logic getVariable ["ALIVE_CQB_eligibleUnitCache", createHashMap];
    ["test-empty-filter" in _cache && {(_cache get "test-empty-filter") isEqualTo []}, "empty eligible pool is cached"] call _check;

    // The units phase creates and positions at most one unit per invocation.
    private _group = createGroup west;
    _group setVariable ["house", _house];
    _house setVariable ["group", _group];
    private _positionA = _base vectorAdd [1,0,0];
    private _positionB = _base vectorAdd [2,0,0];
    private _unitContext = createHashMapFromArray [
        ["phase", "units"],
        ["group", _group],
        ["unitClasses", ["B_Soldier_F", "B_Soldier_F"]],
        ["unitCursor", 0],
        ["nextUnitAt", time],
        ["usablePositions", [_positionA, _positionB]]
    ];
    private _unitResultA = [_logic, _house, _unitContext] call ALiVE_fnc_CQBSpawnStep;
    [_unitResultA == "running" && {count units _group == 1} && {(_unitContext get "unitCursor") == 1}, "first units step creates exactly one unit"] call _check;
    private _unitA = units _group select 0;
    [(_unitA getVariable ["house", objNull]) isEqualTo _house, "created unit records its house"] call _check;
    [(_unitA getVariable ["ALIVE_cqb_instance", objNull]) isEqualTo _logic, "created unit records its CQB instance"] call _check;
    [(_unitA getVariable ["ALIVE_profileIgnore", false]), "created unit is excluded from profiling"] call _check;
    [(getPosATL _unitA) distance (_positionA vectorAdd [0,0,0.4]) < 0.25, "first unit uses first prepared position"] call _check;

    private _unitResultB = [_logic, _house, _unitContext] call ALiVE_fnc_CQBSpawnStep;
    [_unitResultB == "running" && {count units _group == 2} && {(_unitContext get "unitCursor") == 2}, "second units step creates exactly one additional unit"] call _check;
    private _unitB = units _group select 1;
    [(getPosATL _unitB) distance (_positionB vectorAdd [0,0,0.4]) < 0.25, "second unit uses second prepared position"] call _check;
    [_logic, _house, _unitContext] call ALiVE_fnc_CQBSpawnStep;
    [count units _group == 2 && {(_unitContext get "phase") == "staticInit"}, "completion check creates no extra unit"] call _check;

    private _emptyFaction = createHashMapFromArray [["phase", "faction"]];
    _logic setVariable ["CQB_UseDominantFaction", false];
    _logic setVariable ["factions", []];
    [([_logic, _house, _emptyFaction] call ALiVE_fnc_CQBSpawnStep) == "failed", "empty configured faction list fails cleanly"] call _check;
    private _invalidContext = createHashMapFromArray [["phase", "not-a-phase"]];
    [([_logic, _house, _invalidContext] call ALiVE_fnc_CQBSpawnStep) == "failed", "unknown phase fails cleanly"] call _check;

    {deleteVehicle _x} forEach units _group;
    deleteGroup _group;
    _house setVariable ["group", nil];
    if (_hadSmoothSpawn) then {MOD(smoothSpawn) = _savedSmoothSpawn} else {missionNamespace setVariable [QMOD(smoothSpawn), nil]};
    if (_hadStrategic) then {GVAR(STRATEGICPLATFORMS) = _savedStrategic} else {missionNamespace setVariable [QGVAR(STRATEGICPLATFORMS), nil]};
    if (_hadBlacklist) then {GVAR(UNITBLACKLIST) = _savedBlacklist} else {missionNamespace setVariable [QGVAR(UNITBLACKLIST), nil]};
} call CBA_fnc_DirectCall;

{deleteVehicle _x} forEach _fixtures;
diag_log format ["CQB spawn step tests complete: %1 failures", count _failures];
_failures
