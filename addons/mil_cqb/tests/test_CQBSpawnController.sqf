#include "\x\alive\addons\mil_cqb\script_component.hpp"
SCRIPT(test_CQBSpawnController);

// Run on the server in an ALiVE test mission:
// execVM "\x\alive\addons\mil_cqb\tests\test_CQBSpawnController.sqf";
if (!isServer) exitWith {};
private _fixtures = [];
private _makeObject = {
    params ["_class", "_position"];
    private _object = createVehicleLocal [_class, _position, [], 0, "CAN_COLLIDE"];
    _object enableSimulation false;
    _object setPosATL _position;
    _fixtures pushBack _object;
    _object
};
private _base = [worldSize / 2, worldSize / 2, 0];
private _sourceA = ["Land_HelipadEmpty_F", _base] call _makeObject;
private _sourceB = ["Land_HelipadEmpty_F", _base vectorAdd [500,0,0]] call _makeObject;
private _heli = ["B_Heli_Light_01_F", _base] call _makeObject;
private _jet = ["B_Plane_CAS_01_F", _base] call _makeObject;
private _houseA = ["Land_HelipadEmpty_F", _base vectorAdd [50,0,0]] call _makeObject;
private _houseB = ["Land_HelipadEmpty_F", _base vectorAdd [550,0,0]] call _makeObject;
private _outer = ["Land_HelipadEmpty_F", _base vectorAdd [250,0,0]] call _makeObject;
private _static = ["Land_HelipadEmpty_F", _base vectorAdd [150,0,0]] call _makeObject;
_static setVariable ["staticWeapons", []];
private _logic = ["Land_HelipadEmpty_F", [0,0,0]] call _makeObject;
private _registry = createHashMap;
{
    _registry set [hashValue _x, [_x, true]];
} forEach [_houseA,_houseB,_outer,_static];
_logic setVariable ["houses", _registry];
_logic setVariable ["spawnDistance", 100];
_logic setVariable ["spawnDistanceStatic", 200];
_logic setVariable ["spawnDistanceHeli", 0];
_logic setVariable ["spawnDistanceJet", 0];
[_logic, "positionGrid"] call ALiVE_fnc_CQB;
private _grp = createGroup west;
private _unit = _grp createUnit ["B_Soldier_F", getPosATL _houseB, [], 0, "NONE"];
_unit enableSimulation false;
_unit allowDamage false;
_unit setVariable ["house", _houseB];
_grp setVariable ["house", _houseB];
_houseB setVariable ["group", _grp];
_logic setVariable ["groups", [_grp]];
private _failures = [];
private _check = {
    params ["_condition", "_message"];
    if (!_condition) then {_failures pushBack _message; diag_log format ["CQB controller FAIL: %1", _message]};
};

// Run transitions without yielding or starting real faction/spawn workers. The
// temporary module reference is restored before any live PFH can execute.
{
    private _hadModule = !isNil QMOD(CQB);
    private _savedModule = missionNamespace getVariable [QMOD(CQB), objNull];
    MOD(CQB) = _logic;
    _logic setVariable ["active", true];
    _logic setVariable ["claims", createHashMap];
    _logic setVariable ["spawnQueue", []];
    _logic setVariable ["spawnStage", "snapshot"];
    _logic setVariable ["despawnQueue", []];
    private _blockedWorker = [] spawn {sleep 60};
    _logic setVariable ["process", _blockedWorker];
    [_logic, "onFrame"] call ALiVE_fnc_CQB;
    private _expectedSources = allPlayers - entities "HeadlessClient_F";
    if (!isNil "ALIVE_profileSystem" && {[ALIVE_profileSystem,"zeusSpawn"] call ALiVE_fnc_hashGet}) then {
        {_expectedSources pushBackUnique _x} forEach allCurators;
    };
    [(_logic getVariable "spawnSources") isEqualTo _expectedSources, "spawn source compatibility"] call _check;

    _logic setVariable ["spawnSources", [_sourceA,_sourceB]];
    [_logic, "onFrame"] call ALiVE_fnc_CQB;
    private _claims = _logic getVariable "claims";
    [(_logic getVariable "spawnSourceIndex") == 1, "one source per frame"] call _check;
    [(hashValue _houseA) in _claims && {!((hashValue _houseB) in _claims)}, "first source only"] call _check;
    [(hashValue _static) in _claims, "static activation range"] call _check;
    [!((hashValue _outer) in _claims), "empty outer house does not spawn"] call _check;
    [alive _unit, "no despawn before remaining source"] call _check;
    private _queueCount = count (_logic getVariable "spawnQueue");
    [_logic, "claimHouses", _sourceA] call ALiVE_fnc_CQB;
    [count (_logic getVariable "spawnQueue") == _queueCount, "overlap does not duplicate jobs"] call _check;

    [_logic, "onFrame"] call ALiVE_fnc_CQB;
    [(hashValue _houseA) in _claims && {(hashValue _houseB) in _claims}, "claims union across sources"] call _check;
    [_logic, "onFrame"] call ALiVE_fnc_CQB;
    [(_logic getVariable "spawnStage") == "groups", "sweep starts after all sources"] call _check;
    _unit setPosATL (_base vectorAdd [5000,0,0]);
    [_logic, "onFrame"] call ALiVE_fnc_CQB;
    [alive _unit, "last source retains the house despite leader movement"] call _check;

    // Pending/active houses retain the larger radius, including aircraft.
    _outer setVariable ["group", "preinit"];
    [_logic, "claimHouses", _sourceA] call ALiVE_fnc_CQB;
    [(hashValue _outer) in _claims, "pending house uses retention range"] call _check;
    _logic setVariable ["claims", createHashMap];
    [_logic, "claimHouses", _heli] call ALiVE_fnc_CQB;
    [_logic, "claimHouses", _jet] call ALiVE_fnc_CQB;
    [count (_logic getVariable "claims") == 0, "disabled aircraft create no claims"] call _check;
    _logic setVariable ["spawnDistanceHeli", 100];
    [_logic, "claimHouses", _heli] call ALiVE_fnc_CQB;
    [(hashValue _outer) in (_logic getVariable "claims"), "aircraft retention range"] call _check;

    // Pause must neither consume sources nor expire claims.
    _logic setVariable ["pause", true];
    private _count = count (_logic getVariable "claims");
    [_logic, "onFrame"] call ALiVE_fnc_CQB;
    [count (_logic getVariable "claims") == _count, "pause preserves claims"] call _check;
    [(_logic getVariable "spawnStage") == "snapshot", "resume restarts source snapshot"] call _check;
    _logic setVariable ["pause", false];

    // The queue head starts once, stays queued while running, and is removed on completion.
    terminate _blockedWorker;
    _logic setVariable ["process", nil];
    private _houseAID = hashValue _houseA;
    private _houseBID = hashValue _houseB;
    _logic setVariable ["claims", createHashMapFromArray [[_houseAID, [_houseA, 1]], [_houseBID, [_houseB, 1]]]];
    _logic setVariable ["spawnQueue", [_houseA, _static]];
    _houseA setVariable ["group", "preinit"];
    [_logic, "processSpawnQueue"] call ALiVE_fnc_CQB;
    private _startedWorker = _logic getVariable "process";
    [!isNil "_startedWorker", "idle head starts a worker"] call _check;
    [(_logic getVariable "spawnQueue") isEqualTo [_houseA, _static], "starting leaves head queued"] call _check;
    [_logic, "processSpawnQueue"] call ALiVE_fnc_CQB;
    [(_logic getVariable "process") isEqualTo _startedWorker, "running head does not start another worker"] call _check;
    [count (_logic getVariable "spawnQueue") == 2, "running head remains queued"] call _check;
    terminate _startedWorker;
    [_logic, "finishSpawn", true] call ALiVE_fnc_CQB;
    [(_logic getVariable "spawnQueue") isEqualTo [_static], "cancellation removes only the worker head"] call _check;

    // Model a successfully completed worker using the existing live group.
    _logic setVariable ["spawnQueue", [_houseB, _houseA]];
    _logic setVariable ["spawningHouse", _houseB];
    _logic setVariable ["spawningGroup", _grp];
    _logic setVariable ["process", scriptNull];
    [_logic, "processSpawnQueue"] call ALiVE_fnc_CQB;
    [(_logic getVariable "spawnQueue") isEqualTo [_houseA], "completed head is removed"] call _check;
    [isNil {_logic getVariable "process"}, "completion does not start the next job in the same frame"] call _check;
    [alive _unit, "successful completion keeps its group"] call _check;

    // A failed worker releases its reservation and applies retry backoff.
    _houseA setVariable ["group", "preinit"];
    _logic setVariable ["spawningHouse", _houseA];
    _logic setVariable ["process", scriptNull];
    [_logic, "processSpawnQueue"] call ALiVE_fnc_CQB;
    [count (_logic getVariable "spawnQueue") == 0, "failed head is removed"] call _check;
    [isNil {_houseA getVariable "group"}, "failed head releases reservation"] call _check;
    [(_houseA getVariable ["ALIVE_CQB_nextDetect", 0]) > time, "failed head backs off"] call _check;

    // Reclaimed houses survive stale despawn requests; only one entry is consumed.
    _logic setVariable ["despawnQueue", [_houseB, _houseA]];
    [_logic, "processDespawnQueue"] call ALiVE_fnc_CQB;
    [alive _unit, "reclaimed house survives queued despawn"] call _check;
    [(_logic getVariable "despawnQueue") isEqualTo [_houseA], "despawn dequeues only its first house"] call _check;
    _logic setVariable ["despawnQueue", [objNull]];
    // An empty subsequent cycle expires all claims and removes the live fixture.
    _logic setVariable ["spawnStage", "sources"];
    _logic setVariable ["spawnSources", []];
    _logic setVariable ["spawnSourceIndex", 0];
    _logic setVariable ["claimCycle", (_logic getVariable "claimCycle") + 1];
    [_logic, "onFrame"] call ALiVE_fnc_CQB;
    [count (_logic getVariable "claims") == 0, "empty cycle expires claims"] call _check;
    [(_logic getVariable "despawnQueue") isEqualTo [_houseB], "claim loss queues the active house"] call _check;
    [alive _unit, "despawn leaves later entries for the next frame"] call _check;
    [_logic, "onFrame"] call ALiVE_fnc_CQB;
    [isNull _unit, "unclaimed house despawns"] call _check;

    // Queue validation rejects disabled houses without removing their grid registration.
    _logic setVariable ["claims", createHashMapFromArray [[_houseAID, [_houseA, 1]]]];
    _logic setVariable ["spawnQueue", [_houseA, _static]];
    _houseA setVariable ["group", "preinit"];
    [_logic, "setHousesEnabled", [[_houseA, false]]] call ALiVE_fnc_CQB;
    [_logic, "processSpawnQueue"] call ALiVE_fnc_CQB;
    [(_logic getVariable "spawnQueue") isEqualTo [_static], "disabled head is discarded alone"] call _check;
    [isNil {_houseA getVariable "group"}, "disabled head releases reservation"] call _check;
    [isNil {_logic getVariable "process"}, "disabled head never starts a worker"] call _check;
    private _disabledNear = [_logic, "positionsInRange", [[_logic, "positionGrid"] call ALiVE_fnc_CQB,100,200,0,0,[_sourceA]]] call ALiVE_fnc_CQB;
    [!(_houseAID in _disabledNear), "disabled queued house is not claimable"] call _check;
    [_logic, "setHousesEnabled", [[_houseA, true]]] call ALiVE_fnc_CQB;

    // Every scan stage services both queues, consuming at most one entry from each.
    {
        _logic setVariable ["spawnStage", _x];
        _logic setVariable ["spawnSources", []];
        _logic setVariable ["spawnSourceIndex", 0];
        _logic setVariable ["checkedGroups", []];
        _logic setVariable ["checkedGroupIndex", 0];
        _logic setVariable ["spawnQueue", [objNull, objNull]];
        _logic setVariable ["despawnQueue", [objNull, objNull]];
        [_logic, "onFrame"] call ALiVE_fnc_CQB;
        [count (_logic getVariable "spawnQueue") == 1, format ["spawn queue serviced during %1", _x]] call _check;
        [count (_logic getVariable "despawnQueue") == 1, format ["despawn queue serviced during %1", _x]] call _check;
    } forEach ["snapshot", "sources", "groups"];
    // Cancellation must clean even a group that has not created its first unit.
    private _partial = createGroup west;
    _partial setVariable ["house", _houseA];
    _logic setVariable ["spawningGroup", _partial];
    _logic setVariable ["spawningHouse", _houseA];
    _houseA setVariable ["group", "preinit"];
    _logic setVariable ["spawnQueue", [_houseA, _static]];
    _logic setVariable ["despawnQueue", [_houseB]];
    private _worker = [] spawn {sleep 60};
    _logic setVariable ["process", _worker];
    [_logic, "active", false] call ALiVE_fnc_CQB;
    [scriptDone _worker && {isNull _partial}, "shutdown cancels partial spawn"] call _check;
    [isNil {_logic getVariable "process"}, "shutdown clears worker handle"] call _check;
    [count (_logic getVariable ["spawnQueue", []]) == 0, "shutdown clears queued jobs"] call _check;
    [count (_logic getVariable ["despawnQueue", []]) == 0, "shutdown clears despawn jobs"] call _check;
    [isNil {_houseA getVariable "group"}, "shutdown releases reservations"] call _check;
    [_logic, "active", true] call ALiVE_fnc_CQB;
    private _handle = _logic getVariable "spawnPFH";
    [_logic, "active", true] call ALiVE_fnc_CQB;
    [(_logic getVariable "spawnPFH") == _handle, "activation is idempotent"] call _check;
    [_logic, "active", false] call ALiVE_fnc_CQB;
    [isNil {_logic getVariable "spawnPFH"}, "shutdown removes PFH"] call _check;
    if (_hadModule) then {MOD(CQB) = _savedModule} else {missionNamespace setVariable [QMOD(CQB), nil]};
} call CBA_fnc_DirectCall;

if (!isNull _unit) then {deleteVehicle _unit};
if (!isNull _grp) then {deleteGroup _grp};
{deleteVehicle _x} forEach _fixtures;
diag_log format ["CQB controller tests complete: %1 failures", count _failures];
_failures
