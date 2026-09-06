#include "\x\alive\addons\mil_cqb\script_component.hpp"
SCRIPT(test_CQBPositionGrid);

// Run in an Arma test mission with ALiVE loaded:
// execVM "\x\alive\addons\mil_cqb\tests\test_CQBPositionGrid.sqf";
// Local fixtures only; no live CQB modules are changed.
private _fixtures = [];
private _makeObject = {
    params ["_class", "_position"];
    private _object = createVehicleLocal [_class, _position, [], 0, "CAN_COLLIDE"];
    _object enableSimulation false;
    _object setPosATL _position;
    _fixtures pushBack _object;
    _object
};
private _ground = ["Land_HelipadEmpty_F", [worldSize / 2, worldSize / 2, 100]] call _makeObject;
private _heli = ["B_Heli_Light_01_F", (getPosATL _ground) vectorAdd [100, 0, 200]] call _makeObject;
private _jet = ["B_Plane_CAS_01_F", (getPosATL _ground) vectorAdd [0, 100, 400]] call _makeObject;
private _sources = [_ground, _heli, _jet];
private _points = [];
{
    private _position = (getPosATL _ground) vectorAdd _x;
    private _house = ["Land_HelipadEmpty_F", _position] call _makeObject;
    _points pushBack [getPosATL _house, _house];
} forEach [[0,0,0], [699,0,0], [700,0,0], [701,0,0], [1100,0,0], [1200,0,0], [0,0,1500], [-1001,-1001,0]];
((_points select 4) select 1) setVariable ["staticWeapons", []];
((_points select 5) select 1) setVariable ["staticWeapons", []];
// Verify that construction covers positions outside the usual map bounds too.
private _offMapA = ["Land_HelipadEmpty_F", [-5000,-5000,0]] call _makeObject;
private _offMapB = ["Land_HelipadEmpty_F", [worldSize + 5000,worldSize + 5000,0]] call _makeObject;
_points pushBack [getPosATL _offMapA, _offMapA];
_points pushBack [getPosATL _offMapB, _offMapB];
private _logic = ["Land_HelipadEmpty_F", [0,0,0]] call _makeObject;
private _registry = createHashMap;
{
    private _house = _x select 1;
    _registry set [hashValue _house, [_house, true]];
} forEach _points;
_logic setVariable ["houses", _registry];
private _grid = [_logic, "positionGrid"] call ALiVE_fnc_CQB;
private _failures = [];
private _check = {
    params ["_condition", "_message"];
    if (!_condition) then {_failures pushBack _message; diag_log format ["CQB grid FAIL: %1", _message]};
};

// Compare against a brute-force scan with inclusive grid boundaries,
// altitude, static ranges, disabled aircraft, and overlapping source radii.
{
    _x params ["_groundRange", "_staticRange", "_jetRange", "_heliRange"];
    private _actual = [_logic, "positionsInRange", [_grid, _groundRange, _staticRange, _jetRange, _heliRange, _sources]] call ALiVE_fnc_CQB;
    {
        _x params ["_position", "_house"];
        private _range = _groundRange;
        if (!isNil {_house getVariable "staticWeapons"}) then {_range = _range max _staticRange};
        private _expected = _sources select {
            (!(vehicle _x isKindOf "Plane") && {!(vehicle _x isKindOf "Helicopter")} && {_range > 0 && {(getPosATL _x) distance _position <= _range}}) ||
            {vehicle _x isKindOf "Plane" && {_jetRange > 0 && {(getPosATL _x) distance _position <= _jetRange}}} ||
            {vehicle _x isKindOf "Helicopter" && {_heliRange > 0 && {(getPosATL _x) distance _position <= _heliRange}}}
        };
        private _found = _actual getOrDefault [hashValue _house, []];
        [count (_expected - _found) == 0 && {count (_found - _expected) == 0}, format ["range comparison %1 at %2", [_groundRange,_staticRange,_jetRange,_heliRange], _position]] call _check;
    } forEach _points;
} forEach [[700,1200,0,0], [700,1200,1800,1000], [700,300,1800,0], [0,0,0,0], [2100,3600,5400,3000]];

[count ([_logic, "positionsInRange", [_grid,700,1200,1800,1000,[]]] call ALiVE_fnc_CQB) == 0, "no sources"] call _check;
[count (_grid call ["findInRange", [[-5000,-5000,0], 1]]) == 1, "negative off-map point"] call _check;
[count (_grid call ["findInRange", [[worldSize+5000,worldSize+5000,0], 1]]) == 1, "positive off-map point"] call _check;
private _sectors = _grid get "sectors";
_grid = [_logic, "positionGrid"] call ALiVE_fnc_CQB;
[_sectors isEqualRef (_grid get "sectors"), "getter retains grid"] call _check;
private _removed = _points select 0;
private _removedEntry = [_removed select 0, hashValue (_removed select 1)];
_grid call ["remove", _removedEntry];
[!((hashValue (_removed select 1)) in ([_logic, "positionsInRange", [_grid,700,1200,0,0,[_ground]]] call ALiVE_fnc_CQB)), "grid entry removed"] call _check;
_grid call ["insert", [_removedEntry]];
[(hashValue (_removed select 1)) in ([_logic, "positionsInRange", [_grid,700,1200,0,0,[_ground]]] call ALiVE_fnc_CQB), "grid entry reinserted"] call _check;
[_sectors isEqualRef (_grid get "sectors"), "insert/remove retain grid"] call _check;

private _disabledHouse = (_points select 1) select 1;
[_logic, "setHousesEnabled", [[_disabledHouse, false]]] call ALiVE_fnc_CQB;
private _disabledResult = [_logic, "positionsInRange", [_grid,700,1200,0,0,[_ground]]] call ALiVE_fnc_CQB;
[!((hashValue _disabledHouse) in _disabledResult), "disabled house filtered"] call _check;
[(hashValue _disabledHouse) in ((_grid call ["findInRange", [getPosATL _disabledHouse, 1]]) apply {_x select 1}), "disabled house remains in grid"] call _check;
[_logic, "setHousesEnabled", [[_disabledHouse, true]]] call ALiVE_fnc_CQB;
[(hashValue _disabledHouse) in ([_logic, "positionsInRange", [_grid,700,1200,0,0,[_ground]]] call ALiVE_fnc_CQB), "re-enabled house returned"] call _check;
_grid call ["clear"];
[count ([_logic, "positionsInRange", [_grid,700,1200,0,0,_sources]] call ALiVE_fnc_CQB) == 0, "empty grid"] call _check;

// A patrol's retention range follows its house, even when its leader moves away.
private _house = (_points select 4) select 1;
private _lead = ["Land_HelipadEmpty_F", (getPosATL _ground) vectorAdd [3000,0,0]] call _makeObject;
_lead setVariable ["house", _house];
private _houseEntry = _points select 4;
private _houseGridEntry = [_houseEntry select 0, hashValue _house];
_grid call ["insert", [_houseGridEntry]];
private _nearHouse = [_logic, "positionsInRange", [_grid,2100,3600,0,0,[_ground]]] call ALiVE_fnc_CQB;
[(hashValue _house) in _nearHouse, "house retained for patrol"] call _check;
_lead setPosATL ((getPosATL _ground) vectorAdd [100,0,0]);
private _nearHouseAfterMove = [_logic, "positionsInRange", [_grid,2100,3600,0,0,[_ground]]] call ALiVE_fnc_CQB;
[(hashValue _house) in _nearHouseAfterMove, "moved patrol still follows house"] call _check;
[(_nearHouse get (hashValue _house)) isEqualTo (_nearHouseAfterMove get (hashValue _house)), "leader movement does not change house query"] call _check;
_grid call ["remove", _houseGridEntry];
[count ([_logic, "positionsInRange", [_grid,2100,3600,0,0,[_ground]]] call ALiVE_fnc_CQB) == 0, "cleared patrol house removed"] call _check;

{deleteVehicle _x} forEach _fixtures;
diag_log format ["CQB grid tests complete: %1 failures", count _failures];
_failures
