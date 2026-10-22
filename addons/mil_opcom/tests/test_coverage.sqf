#include "\x\alive\addons\mil_OPCOM\script_component.hpp"

SCRIPT(test_coverage);

/* ----------------------------------------------------------------------------
Security Coverage test (#1092). Covers fnc_OPCOMcoverage: sectorSize,
territory, watch, mark, presence, coldest, and the surplus rule the patrol
code applies in Coverage mode.

Needs no mission: paste it into the debug console of an empty world and read
the RPT. It builds a commander handler and objectives of its own as plain
hashes, so nothing in a running commander is touched. With no pathfinder in
the world the sector size is 250 m; with one, the test reads the grid's size
and the numbers scale. Every global it touches is put back.
---------------------------------------------------------------------------- */

private _fails = [];
private _fnc_check = {
    params ["_name", ["_ok", nil, [true]]];
    if (isNil "_ok") exitWith {
        _fails pushBack _name;
        diag_log format ["  FAIL  %1  (assertion threw or returned nothing)", _name];
    };
    if (_ok) then {
        diag_log format ["  pass  %1", _name];
    } else {
        _fails pushBack _name;
        diag_log format ["  FAIL  %1", _name];
    };
};
private _fnc_near = { params ["_a", "_b", ["_tol", 0.001]]; abs (_a - _b) <= _tol };

diag_log "=== Security Coverage test ===";

private _saved = [
    missionNamespace getVariable "ALiVE_coveragePresence",
    missionNamespace getVariable "ALiVE_coverageLastSector",
    missionNamespace getVariable "ALiVE_coverageHalfLife"
];
ALiVE_coveragePresence = nil;
ALiVE_coverageLastSector = nil;
ALiVE_coverageHalfLife = nil;

private _size = [nil, "sectorSize"] call ALIVE_fnc_OPCOMcoverage;
["sectorSize is a positive number", _size isEqualType 0 && {_size > 0}] call _fnc_check;
["half-life defaults to an hour", ALiVE_coverageHalfLife == 3600] call _fnc_check;
private _fnc_centre = { params ["_ix", "_iy"]; [(_ix + 0.5) * _size, (_iy + 0.5) * _size, 0] };

// --- a commander and its objectives, as plain hashes -----------------------------
private _fnc_objective = {
    params ["_id", "_ix", "_iy", "_objSize", "_state"];
    private _o = [] call ALiVE_fnc_hashCreate;
    [_o, "objectiveID", _id] call ALiVE_fnc_hashSet;
    [_o, "center", [_ix, _iy] call _fnc_centre] call ALiVE_fnc_hashSet;
    [_o, "size", _objSize] call ALiVE_fnc_hashSet;
    [_o, "opcom_state", _state] call ALiVE_fnc_hashSet;
    _o
};
private _handler = [] call ALiVE_fnc_hashCreate;
[_handler, "side", "WEST"] call ALiVE_fnc_hashSet;
// two held objectives twelve sectors apart on dry land, found from the map centre so water doesn't skew it
private _base = [[worldSize / 2, worldSize / 2, 0], 0, 6000, 10, 0, 0.2, 0] call BIS_fnc_findSafePos;
_base resize 3;
_base set [2, 0];
private _bx = floor ((_base select 0) / _size);
private _by = floor ((_base select 1) / _size);
private _a = ["obj_a", _bx - 6, _by, 200, "idle"] call _fnc_objective;
private _b = ["obj_b", _bx + 6, _by, 100, "reserve"] call _fnc_objective;
private _reach = 4 * _size;

// --- territory --------------------------------------------------------------------
private _territory = [_handler, "territory", [[_a, _b], _reach]] call ALIVE_fnc_OPCOMcoverage;
["territory is a hashmap", _territory isEqualType createHashMap] call _fnc_check;
["territory has sectors", count _territory > 0] call _fnc_check;
["a sector at an objective belongs to it", (_territory get [_bx - 6, _by]) isEqualTo "obj_a"] call _fnc_check;
["a sector nearer the other objective belongs to that one", (_territory get [_bx + 4, _by]) isEqualTo "obj_b"] call _fnc_check;
["a sector beyond reach is nobody's", isNil { _territory get [_bx - 11, _by] }] call _fnc_check;
["the territory is cached under its key", ([_handler, "territory", [[_a, _b], _reach]] call ALIVE_fnc_OPCOMcoverage) isEqualRef _territory] call _fnc_check;
private _smaller = [_handler, "territory", [[_a, _b], 2 * _size]] call ALIVE_fnc_OPCOMcoverage;
["a shorter reach rebuilds a smaller territory", count _smaller < count _territory && {isNil { _smaller get [_bx - 9, _by] }}] call _fnc_check;
private _oneOnly = [_handler, "territory", [[_a], _reach]] call ALIVE_fnc_OPCOMcoverage;
["losing an objective drops its ground", isNil { _oneOnly get [_bx + 6, _by] }] call _fnc_check;
_territory = [_handler, "territory", [[_a, _b], _reach]] call ALIVE_fnc_OPCOMcoverage;

// --- watch ---------------------------------------------------------------------------
private _watch = [_handler, "watch", [[[_a, 2], [_b, 0]]]] call ALIVE_fnc_OPCOMcoverage;
["two groups at home watch 800 m", !isNil { _watch get [_bx - 6 + (floor (700 / _size)), _by] } || {_size > 700}] call _fnc_check;
["a sector past the watch is unwatched", isNil { _watch get [_bx - 6 + (ceil (1100 / _size)), _by] }] call _fnc_check;
["an objective with nobody home watches nothing", isNil { _watch get [_bx + 6, _by] }] call _fnc_check;
["the watch is cached under its key", ([_handler, "watch", [[[_a, 2], [_b, 0]]]] call ALIVE_fnc_OPCOMcoverage) isEqualRef _watch] call _fnc_check;
private _watchMore = [_handler, "watch", [[[_a, 5], [_b, 0]]]] call ALIVE_fnc_OPCOMcoverage;
["the watch is capped at 1 km", isNil { _watchMore get [_bx - 6 + (ceil (1100 / _size)), _by] }] call _fnc_check;
["all groups out watches nothing", count ([_handler, "watch", [[[_a, 0], [_b, 0]]]] call ALIVE_fnc_OPCOMcoverage) == 0] call _fnc_check;
[_handler, "watch", [[[_a, 2], [_b, 0]]]] call ALIVE_fnc_OPCOMcoverage;

// --- mark + presence ----------------------------------------------------------------
private _p1 = [_bx, _by] call _fnc_centre;
private _s1 = [_bx, _by];
["nothing marked reads 0", ([nil, "presence", ["WEST", _s1]] call ALIVE_fnc_OPCOMcoverage) == 0] call _fnc_check;
[nil, "mark", ["WEST", _p1, "patrol_1"]] call ALIVE_fnc_OPCOMcoverage;
["one pass marks 1", [[nil, "presence", ["WEST", _s1]] call ALIVE_fnc_OPCOMcoverage, 1, 0.002] call _fnc_near] call _fnc_check;
[nil, "mark", ["WEST", _p1 vectorAdd [1, 1, 0], "patrol_1"]] call ALIVE_fnc_OPCOMcoverage;
["the same patrol still in the sector doesn't mark it again", [[nil, "presence", ["WEST", _s1]] call ALIVE_fnc_OPCOMcoverage, 1, 0.002] call _fnc_near] call _fnc_check;
[nil, "mark", ["WEST", _p1, "patrol_2"]] call ALIVE_fnc_OPCOMcoverage;
["a second patrol does", [[nil, "presence", ["WEST", _s1]] call ALIVE_fnc_OPCOMcoverage, 2, 0.002] call _fnc_near] call _fnc_check;
[nil, "mark", ["WEST", [_bx + 1, _by] call _fnc_centre, "patrol_1"]] call ALIVE_fnc_OPCOMcoverage;
[nil, "mark", ["WEST", _p1, "patrol_1"]] call ALIVE_fnc_OPCOMcoverage;
["a patrol that left and came back marks again", [[nil, "presence", ["WEST", _s1]] call ALIVE_fnc_OPCOMcoverage, 3, 0.002] call _fnc_near] call _fnc_check;
[nil, "mark", [west, _p1, "patrol_3"]] call ALIVE_fnc_OPCOMcoverage;
["a side object is taken as its text", [[nil, "presence", ["WEST", _s1]] call ALIVE_fnc_OPCOMcoverage, 4, 0.002] call _fnc_near] call _fnc_check;
["the other side reads nothing there", ([nil, "presence", ["EAST", _s1]] call ALIVE_fnc_OPCOMcoverage) == 0] call _fnc_check;
[nil, "mark", ["", _p1, "patrol_x"]] call ALIVE_fnc_OPCOMcoverage;
[nil, "mark", ["WEST", [], "patrol_x"]] call ALIVE_fnc_OPCOMcoverage;
["bad input marks nothing", [[nil, "presence", ["WEST", _s1]] call ALIVE_fnc_OPCOMcoverage, 4, 0.002] call _fnc_near] call _fnc_check;
// decay: back-date the stamp two half-lives
private _table = ALiVE_coveragePresence get "WEST";
private _clock = missionNamespace getVariable ["ALiVE_simulationTime", time];
_table set [_s1, [4, _clock - 2 * ALiVE_coverageHalfLife]];
["presence halves each half-life", [[nil, "presence", ["WEST", _s1]] call ALIVE_fnc_OPCOMcoverage, 1, 0.002] call _fnc_near] call _fnc_check;
[nil, "mark", ["WEST", _p1, "patrol_4"]] call ALIVE_fnc_OPCOMcoverage;
["mark decays the old value before adding", [((_table get _s1) select 0), 2, 0.002] call _fnc_near] call _fnc_check;

// --- coldest --------------------------------------------------------------------------
private _homePos = [_a, "center", [0,0,0]] call ALiVE_fnc_hashGet;
private _fnc_rearAll = { true };
private _stops = [_handler, "coldest", ["WEST", _homePos, _reach, _fnc_rearAll]] call ALIVE_fnc_OPCOMcoverage;
["coldest returns up to four stops", _stops isEqualType [] && {count _stops > 0} && {count _stops <= 4}] call _fnc_check;
["each stop is a [position, size] pair", (_stops findIf { !(_x isEqualType []) || {count _x != 2} || {!((_x select 0) isEqualType [])} }) < 0] call _fnc_check;
["stops are within reach of home", (_stops findIf { ((_x select 0) distance2D _homePos) > _reach + _size }) < 0] call _fnc_check;
private _apart = true;
for "_i" from 0 to (count _stops - 1) do {
    for "_j" from (_i + 1) to (count _stops - 1) do {
        if (((_stops select _i select 0) distance2D (_stops select _j select 0)) < (750 max _size) - 1) then { _apart = false };
    };
};
["stops are at least 750 m apart (a sector on a coarse grid)", _apart] call _fnc_check;
["no stop within 500 m of home", (_stops findIf { ((_x select 0) distance2D _homePos) <= 500 - _size }) < 0] call _fnc_check;
["stops avoid watched ground", (_stops findIf { ((_x select 0) distance2D _homePos) < 800 }) < 0 || {_size > 800}] call _fnc_check;
private _ordered = true;
private _from = _homePos;
{ if (((_x select 0) distance2D _from) > _reach * 2) then { _ordered = false }; _from = _x select 0 } forEach _stops;
["each stop is within two reaches of the last", _ordered] call _fnc_check;
// warm up every sector but one and the picker must include the cold one
private _cold = _stops select 0 select 0;
private _coldSector = [floor ((_cold select 0) / _size), floor ((_cold select 1) / _size)];
{
    private _sector = _x;
    if !(_sector isEqualTo _coldSector) then {
        private _t = ALiVE_coveragePresence get "WEST";
        _t set [_sector, [50, missionNamespace getVariable ["ALiVE_simulationTime", time]]];
    };
} forEach (keys _territory);
private _again = [_handler, "coldest", ["WEST", _homePos, _reach, _fnc_rearAll]] call ALIVE_fnc_OPCOMcoverage;
["the one cold sector is picked", (_again findIf { ((_x select 0) distance2D _cold) < 1 }) > -1] call _fnc_check;
private _none = [_handler, "coldest", ["WEST", _homePos, _reach, { false }]] call ALIVE_fnc_OPCOMcoverage;
["nothing near a fight is a stop", _none isEqualTo []] call _fnc_check;

// --- the map edge: no territory past it ------------------------------------------------
private _edge = ["obj_edge", 0, _by, 100, "idle"] call _fnc_objective;
private _edgeLand = [_handler, "territory", [[_edge], _reach]] call ALIVE_fnc_OPCOMcoverage;
private _maxIx = floor (worldSize / _size);
["no sector off the map", ((keys _edgeLand) findIf { (_x select 0) < 0 || {(_x select 1) < 0} || {(_x select 0) > _maxIx} || {(_x select 1) > _maxIx} }) < 0] call _fnc_check;
[_handler, "territory", [[_a, _b], _reach]] call ALIVE_fnc_OPCOMcoverage;

// --- the surplus rule: the same "surplus" operation fnc_OPCOMsecurityPatrols calls -------
private _fnc_want = { params ["_groups", "_objSize", "_share", ["_out", 0]]; [nil, "surplus", [_groups, _objSize, _share, _out]] call ALIVE_fnc_OPCOMcoverage };
["a large objective keeps two", ([2, 200, 0.75] call _fnc_want) == 0] call _fnc_check;
["a small objective keeps one", ([2, 100, 0.75] call _fnc_want) == 1] call _fnc_check;
["Many sends all the surplus", ([5, 200, 0.75] call _fnc_want) == 3] call _fnc_check;
["Some sends two thirds of it", ([5, 200, 0.5] call _fnc_want) == 2] call _fnc_check;
["Few sends a third", ([5, 200, 0.25] call _fnc_want) == 1] call _fnc_check;
["Few with one spare sends none", ([3, 200, 0.25] call _fnc_want) == 0] call _fnc_check;
["patrols already out count against it", ([5, 200, 0.75, 2] call _fnc_want) == 1] call _fnc_check;

// --- put everything back ---------------------------------------------------------------
ALiVE_coveragePresence = _saved select 0;
ALiVE_coverageLastSector = _saved select 1;
ALiVE_coverageHalfLife = _saved select 2;
if (count _fails == 0) then {
    diag_log "=== Security Coverage test: all passed ===";
} else {
    diag_log format ["=== Security Coverage test: %1 FAILED: %2 ===", count _fails, _fails];
};
