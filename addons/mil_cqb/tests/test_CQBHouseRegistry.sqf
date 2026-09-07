#include "\x\alive\addons\mil_cqb\script_component.hpp"
SCRIPT(test_CQBHouseRegistry);

// Run on the server in an ALiVE test mission:
// execVM "\x\alive\addons\mil_cqb\tests\test_CQBHouseRegistry.sqf";
// Local fixtures and a temporary module reference keep real CQB state untouched.
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
private _base = [worldSize / 2, worldSize / 2, 100];
private _logic = [[0,0,0]] call _makeObject;
private _near = [_base vectorAdd [50,0,0]] call _makeObject;
private _boundary = [_base vectorAdd [100,0,0]] call _makeObject;
private _far = [_base vectorAdd [150,0,0]] call _makeObject;
private _registry = createHashMap;
{
    _registry set [hashValue _x, [_x, true, "idle"]];
} forEach [_near, _boundary, _far];
_logic setVariable ["houses", _registry];
_logic setVariable ["claims", createHashMap];
_logic setVariable ["spawnQueue", []];
_logic setVariable ["debug", false];
_logic setVariable ["instancetype", "regular"];
_logic setVariable ["id", "registry-test"];
_logic setVariable ["cleared", []];

private _failures = [];
private _check = {
    params ["_condition", "_message"];
    if (!_condition) then {_failures pushBack _message; diag_log format ["CQB registry FAIL: %1", _message]};
};

private _hadModule = !isNil QMOD(CQB);
private _savedModule = missionNamespace getVariable [QMOD(CQB), objNull];
{
MOD(CQB) = _logic;

private _grid = [_logic, "positionGrid"] call ALiVE_fnc_CQB;
private _sectors = _grid get "sectors";
[typeName ([_logic, "houses"] call ALiVE_fnc_CQB) == "HASHMAP", "houses getter returns registry map"] call _check;
[count (_grid call ["findInRange", [_base, 200]]) == 3, "all registered houses enter the grid"] call _check;

[_base, 100, [_logic]] call ALiVE_fnc_removeCQBpositions;
private _afterDisable = [_logic, "houses"] call ALiVE_fnc_CQB;
[!((_afterDisable get (hashValue _near)) select 1), "helper disables house inside radius"] call _check;
[!((_afterDisable get (hashValue _boundary)) select 1), "helper includes precise radius boundary"] call _check;
[(_afterDisable get (hashValue _far)) select 1, "helper leaves distant house enabled"] call _check;
[_sectors isEqualRef (_grid get "sectors"), "disable preserves grid identity"] call _check;
[count (_grid call ["findInRange", [_base, 200]]) == 3, "disable retains every grid entry"] call _check;

private _batch = [[_near, true], [_far, false], [_boundary, false]];
[_logic, "setHousesEnabled", _batch] call ALiVE_fnc_CQB;
[(_afterDisable get (hashValue _near)) select 1, "mixed batch enables house"] call _check;
[!((_afterDisable get (hashValue _far)) select 1), "mixed batch disables house"] call _check;
[_logic, "setHousesEnabled", _batch] call ALiVE_fnc_CQB;
[(_afterDisable get (hashValue _near)) select 1 && {!((_afterDisable get (hashValue _far)) select 1)}, "reapplying batch preserves flags"] call _check;
[_logic, "setHousesEnabled", []] call ALiVE_fnc_CQB;
[_logic, "setHousesEnabled", [[_far, true]]] call ALiVE_fnc_CQB;

[_base, 100, [_logic]] call ALiVE_fnc_addCQBpositions;
[(([_logic, "houses"] call ALiVE_fnc_CQB) get (hashValue _near)) select 1, "helper re-enables nearby house"] call _check;

// Saved state keeps disabled records and gives distinct stable IDs to houses.
[_logic, "setHousesEnabled", [[_near, false]]] call ALiVE_fnc_CQB;
private _state = [_logic, "state"] call ALiVE_fnc_CQB;
private _savedHouses = [_state, "houses"] call ALiVE_fnc_HashGet;
private _savedKeys = _savedHouses select 1;
private _savedValues = _savedHouses select 2;
[count _savedValues == 3 && {count _savedKeys == 3}, "state saves every registered house"] call _check;
[count (_savedKeys arrayIntersect _savedKeys) == 3, "state house record IDs are unique"] call _check;
[count (_savedValues select {!([_x, "enabled", true] call ALiVE_fnc_HashGet)}) == 1, "state saves enabled flags"] call _check;

[_logic, "setHousesEnabled", [[_near, true]]] call ALiVE_fnc_CQB;
private _nearID = hashValue _near;
private _claims = createHashMapFromArray [[_nearID, [_near, 7]]];
_logic setVariable ["claims", _claims];
_logic setVariable ["spawnQueue", [_near]];
((_logic getVariable "houses") get _nearID) set [2, "queued"];
[_logic, "setHousesEnabled", [[_near, false]]] call ALiVE_fnc_CQB;
[!(((_logic getVariable "houses") get _nearID) select 1), "disable updates queued house flag"] call _check;
[_logic, "processSpawnQueue"] call ALiVE_fnc_CQB;
[_nearID in _claims, "disable leaves claim for normal cycle expiry"] call _check;
[count (_logic getVariable "spawnQueue") == 0, "disable cancels queued spawn"] call _check;
[(((_logic getVariable "houses") get _nearID) select 2) == "idle", "disable releases queued lifecycle"] call _check;
[isNil {_near getVariable "group"}, "queued house does not use group sentinel"] call _check;

[_logic, "removeHouse", _boundary] call ALiVE_fnc_CQB;
[!((hashValue _boundary) in ([_logic, "houses"] call ALiVE_fnc_CQB)), "permanent removal deletes registry record"] call _check;
[_logic, "setHousesEnabled", [[_boundary, true]]] call ALiVE_fnc_CQB;
[!((hashValue _boundary) in ([_logic, "houses"] call ALiVE_fnc_CQB)), "removed house cannot be re-enabled"] call _check;
[count (_grid call ["findInRange", [getPosATL _boundary, 1]]) == 0, "permanent removal deletes grid entry"] call _check;

[[_logic]] call ALiVE_fnc_resetCQB;
private _afterReset = [_logic, "houses"] call ALiVE_fnc_CQB;
[count ((values _afterReset) select {_x select 1}) == 0, "reset disables every remaining house"] call _check;
[_sectors isEqualRef (_grid get "sectors"), "reset preserves grid identity"] call _check;
[count (_grid call ["findInRange", [_base, 200]]) == 2, "reset retains remaining grid entries"] call _check;

if (_hadModule) then {MOD(CQB) = _savedModule} else {missionNamespace setVariable [QMOD(CQB), nil]};
} call CBA_fnc_DirectCall;
{deleteVehicle _x} forEach _fixtures;
diag_log format ["CQB registry tests complete: %1 failures", count _failures];
_failures
