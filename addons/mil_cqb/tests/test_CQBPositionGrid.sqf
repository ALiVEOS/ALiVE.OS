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
private _nearHouse = [_logic, "positionsInRange", [_grid,840,1440,0,0,[_ground]]] call ALiVE_fnc_CQB;
[(hashValue _house) in _nearHouse, "house retained for patrol"] call _check;
_lead setPosATL ((getPosATL _ground) vectorAdd [100,0,0]);
private _nearHouseAfterMove = [_logic, "positionsInRange", [_grid,840,1440,0,0,[_ground]]] call ALiVE_fnc_CQB;
[(hashValue _house) in _nearHouseAfterMove, "moved patrol still follows house"] call _check;
[(_nearHouse get (hashValue _house)) isEqualTo (_nearHouseAfterMove get (hashValue _house)), "leader movement does not change house query"] call _check;
_grid call ["remove", _houseGridEntry];
[count ([_logic, "positionsInRange", [_grid,840,1440,0,0,[_ground]]] call ALiVE_fnc_CQB) == 0, "cleared patrol house removed"] call _check;

// Differential claim oracle: use the unchanged range query twice, then apply
// the former per-house lifecycle rules to its activation and retention sets.
private _claimBase = (getPosATL _ground) vectorAdd [5000,5000,0];
private _claimSource = ["Land_HelipadEmpty_F", _claimBase] call _makeObject;
private _claimPlane = ["B_Plane_CAS_01_F", _claimBase] call _makeObject;
private _claimHeli = ["B_Heli_Light_01_F", _claimBase] call _makeObject;
private _claimHouses = [];
{
    _x params ["_offset", ["_class", "Land_HelipadEmpty_F"]];
    _claimHouses pushBack ([_class, _claimBase vectorAdd _offset] call _makeObject);
} forEach [
    [[60,80,0]],             // exact 3D activation boundary at 100 m
    [[0,0,120]],             // exact retention boundary at 1.2x100 m
    [[200,0,0]],             // static activation boundary
    [[121,0,0]],             // outside ground retention
    [[40,0,0]],              // disabled
    [[30,0,0], "Land_CargoBox_V1_F"], // dead
    [[105,0,0]],             // queued
    [[107,0,0]],             // spawning
    [[109,0,0]],             // active lifecycle
    [[111,0,0]],             // despawnQueued
    [[113,0,0]],             // idle retention only
    [[115,0,0]],             // real group
    [[20,0,0]],              // cooldown
    [[80,0,0]]               // moved after grid insertion
];
private _claimStatic = _claimHouses select 2;
_claimStatic setVariable ["staticWeapons", []];
private _claimDead = _claimHouses select 5;
_claimDead setDamage 1;
private _claimLogic = ["Land_HelipadEmpty_F", [0,0,0]] call _makeObject;
private _claimRegistry = createHashMap;
{
    _claimRegistry set [hashValue _x, [_x, true, "idle"]];
} forEach _claimHouses;
(_claimRegistry get (hashValue (_claimHouses select 4))) set [1, false];
(_claimRegistry get (hashValue (_claimHouses select 6))) set [2, "queued"];
(_claimRegistry get (hashValue (_claimHouses select 7))) set [2, "spawning"];
(_claimRegistry get (hashValue (_claimHouses select 8))) set [2, "active"];
(_claimRegistry get (hashValue (_claimHouses select 9))) set [2, "despawnQueued"];
private _claimGroup = createGroup west;
private _claimUnit = _claimGroup createUnit ["B_Soldier_F", getPosATL (_claimHouses select 11), [], 0, "NONE"];
_claimGroup setVariable ["house", _claimHouses select 11];
(_claimHouses select 11) setVariable ["group", _claimGroup];
(_claimHouses select 12) setVariable ["ALIVE_CQB_nextDetect", time + 60];
_claimLogic setVariable ["houses", _claimRegistry];
_claimLogic setVariable ["claims", createHashMap];
_claimLogic setVariable ["claimCycle", 9];
_claimLogic setVariable ["spawnQueue", []];
_claimLogic setVariable ["debug", false];
private _claimGrid = [_claimLogic, "positionGrid"] call ALiVE_fnc_CQB;
private _cachedHouse = _claimHouses select 13;
_cachedHouse setPosATL (_claimBase vectorAdd [2000,0,0]);

private _resetClaimState = {
    _claimLogic setVariable ["claims", createHashMap];
    _claimLogic setVariable ["spawnQueue", []];
    {
        private _record = _y;
        private _index = _claimHouses find (_record select 0);
        private _lifecycle = switch _index do {
            case 1: {"active"};
            case 3: {"active"};
            case 6: {"queued"};
            case 7: {"spawning"};
            case 8: {"active"};
            case 9: {"despawnQueued"};
            default {"idle"};
        };
        _record set [2, _lifecycle];
    } forEach _claimRegistry;
};
private _checkClaimCase = {
    params ["_name", "_source", "_ranges"];
    call _resetClaimState;
    _ranges params ["_groundRange", "_staticRange", "_jetRange", "_heliRange"];
    _claimLogic setVariable ["spawnDistance", _groundRange];
    _claimLogic setVariable ["spawnDistanceStatic", _staticRange];
    _claimLogic setVariable ["spawnDistanceJet", _jetRange];
    _claimLogic setVariable ["spawnDistanceHeli", _heliRange];
    private _activation = [_claimLogic, "positionsInRange", [_claimGrid,_groundRange,_staticRange,_jetRange,_heliRange,[_source]]] call ALiVE_fnc_CQB;
    private _retention = [_claimLogic, "positionsInRange", [_claimGrid,_groundRange*1.2,_staticRange*1.2,_jetRange*1.2,_heliRange*1.2,[_source]]] call ALiVE_fnc_CQB;
    private _expectedClaims = [];
    private _expectedQueue = [];
    {
        private _record = _claimRegistry get _x;
        _record params ["_candidate"];
        if (alive _candidate) then {
            private _lifecycle = _record param [2, "idle"];
            private _group = _candidate getVariable ["group", grpNull];
            private _hasGroup = _group isEqualType grpNull && {!isNull _group};
            private _activated = _x in _activation;
            if (_activated || {_hasGroup} || {_lifecycle in ["queued","spawning","active","despawnQueued"]}) then {
                _expectedClaims pushBack _x;
                if (_activated && {!_hasGroup} && {_lifecycle == "idle"} && {time >= (_candidate getVariable ["ALIVE_CQB_nextDetect", 0])}) then {
                    _expectedQueue pushBack _candidate;
                };
            };
        };
    } forEach keys _retention;
    [_claimLogic, "claimHouses", _source] call ALiVE_fnc_CQB;
    private _actualClaims = keys (_claimLogic getVariable "claims");
    private _actualQueue = _claimLogic getVariable "spawnQueue";
    [(_actualClaims - _expectedClaims) isEqualTo [] && {(_expectedClaims - _actualClaims) isEqualTo []}, format ["claim oracle %1", _name]] call _check;
    [(_actualQueue - _expectedQueue) isEqualTo [] && {(_expectedQueue - _actualQueue) isEqualTo []}, format ["queue oracle %1", _name]] call _check;
    [{(((_claimLogic getVariable "claims") get _x) select 1) == (_claimLogic getVariable "claimCycle")} count _actualClaims == count _actualClaims, format ["claim cycle %1", _name]] call _check;
    [{((_claimRegistry get (hashValue _x)) param [2, "idle"]) == "queued"} count _expectedQueue == count _expectedQueue, format ["queued lifecycle %1", _name]] call _check;
    if (_name == "ground/static boundaries") then {
        [(hashValue (_claimHouses select 1)) in _actualClaims, "active house retained at exactly 1.2x range"] call _check;
        [!((hashValue (_claimHouses select 3)) in _actualClaims), "active house outside 1.2x range is not retained"] call _check;
        [(hashValue _cachedHouse) in _actualClaims, "claim uses cached grid position after house moves"] call _check;
    };
};
{
    _x call _checkClaimCase;
} forEach [
    ["ground/static boundaries", _claimSource, [100,200,0,0]],
    ["ground dominates smaller static", _claimSource, [200,50,0,0]],
    ["static only with zero ground", _claimSource, [0,200,0,0]],
    ["static only with negative ground", _claimSource, [-10,200,0,0]],
    ["zero ranges", _claimSource, [0,0,0,0]],
    ["negative ranges", _claimSource, [-10,-20,0,0]],
    ["plane enabled", _claimPlane, [0,0,100,0]],
    ["plane disabled", _claimPlane, [500,800,0,500]],
    ["helicopter enabled", _claimHeli, [0,0,0,100]],
    ["helicopter disabled", _claimHeli, [500,800,500,0]]
];
[!alive _claimDead && {!((hashValue _claimDead) in (_claimLogic getVariable "claims"))}, "dead house never claimed"] call _check;
[!((hashValue (_claimHouses select 4)) in (_claimLogic getVariable "claims")), "disabled house never claimed"] call _check;

// Repeating a source and adding an overlapping source refreshes claims without
// duplicating queued houses during the same cycle.
call _resetClaimState;
_claimLogic setVariable ["spawnDistance", 200];
_claimLogic setVariable ["spawnDistanceStatic", 200];
[_claimLogic, "claimHouses", _claimSource] call ALiVE_fnc_CQB;
private _firstQueue = +(_claimLogic getVariable "spawnQueue");
private _firstClaimID = hashValue (_claimHouses select 0);
private _firstClaim = (_claimLogic getVariable "claims") get _firstClaimID;
[_claimLogic, "claimHouses", _claimSource] call ALiVE_fnc_CQB;
[(_claimLogic getVariable "spawnQueue") isEqualTo _firstQueue, "repeated source does not duplicate queue"] call _check;
[(_firstClaim isEqualRef ((_claimLogic getVariable "claims") get _firstClaimID)), "repeated source reuses claim record"] call _check;
private _overlapSource = ["Land_HelipadEmpty_F", _claimBase vectorAdd [50,0,0]] call _makeObject;
[_claimLogic, "claimHouses", _overlapSource] call ALiVE_fnc_CQB;
private _overlapQueue = +(_claimLogic getVariable ["spawnQueue", []]);
[count _overlapQueue == count (_overlapQueue arrayIntersect _overlapQueue), "overlapping sources keep queue unique"] call _check;
[(((_claimLogic getVariable "claims") getOrDefault [hashValue (_claimHouses select 0), [objNull,-1]]) select 1) == 9, "multi-source claim stores current cycle"] call _check;
_claimLogic setVariable ["claimCycle", 10];
[_claimLogic, "claimHouses", _claimSource] call ALiVE_fnc_CQB;
[(_claimLogic getVariable "spawnQueue") isEqualTo _overlapQueue, "next cycle refresh preserves queue uniqueness"] call _check;
[(((_claimLogic getVariable "claims") getOrDefault [hashValue (_claimHouses select 0), [objNull,-1]]) select 1) == 10, "next cycle refreshes claim record"] call _check;
[(_firstClaim isEqualRef ((_claimLogic getVariable "claims") get _firstClaimID)) && {(_firstClaim select 1) == 10}, "next cycle updates original claim record in place"] call _check;

{deleteVehicle _x} forEach units _claimGroup;
deleteGroup _claimGroup;

{deleteVehicle _x} forEach _fixtures;
diag_log format ["CQB grid tests complete: %1 failures", count _failures];
_failures
