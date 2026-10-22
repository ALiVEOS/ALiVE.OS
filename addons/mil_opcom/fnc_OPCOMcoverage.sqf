#include "\x\alive\addons\mil_OPCOM\script_component.hpp"
SCRIPT(OPCOMcoverage);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_OPCOMcoverage

Description:
Coverage for Security Patrols (#1092). The commander's territory is every
coarse route memory sector within the patrol reach of an objective it holds,
owned by the nearest one. A presence value per sector is written by its own
patrols as they pass and halves on a half-life, so ground nobody has walked
lately reads cold. Each group still at home watches a radius round its
objective that never reads cold. A Coverage patrol's route goes through the
coldest sectors within reach of home and back.

Territory and the watch are static fields on the commander's handler, rebuilt
only when the held objectives or the groups at home change. Presence is kept
per side in ALiVE_coveragePresence, written on the profile simulator's own
tick for profiles flagged securityPatrol, as [value, stamp] pairs decayed on
read, so idle sectors cost nothing. None of it is saved; the securityPatrol flag
goes out with a saved profile but the import path drops it, so a reload starts clean.

Parameters:
Any - nil, or the commander's handler for the per-commander operations
String - operation: "sectorSize", "territory", "watch", "mark", "presence", "coldest", "surplus"
Any - arguments, see each operation

Returns:
Any - see each operation

Author:
Goldwep
Jman
---------------------------------------------------------------------------- */

#define COVERAGE_WATCH_PER_GROUP 400
#define COVERAGE_WATCH_MAX 1000
#define COVERAGE_STOPS 4
// in metres, not sectors: the route memory grid's sectors are 250 m on small maps but 480 m to 1 km on large ones
#define COVERAGE_NEAR_HOME 500
#define COVERAGE_STOP_GAP 750

params ["_handler", ["_operation", ""], ["_args", []]];

private _result = nil;

// the half-life of presence in seconds of simulation time; isNil-guarded so a console override survives
if (isNil "ALiVE_coverageHalfLife") then { ALiVE_coverageHalfLife = 3600 };

private _fnc_now = { missionNamespace getVariable ["ALiVE_simulationTime", time] };

switch (_operation) do {

    // the coarse sector size the route memory grid uses, or 250 m when there is no pathfinder
    case "sectorSize": {
        _result = 250;
        if (!isNil "ALiVE_pathfinder") then {
            private _grid = ALiVE_pathfinder get "terrainGrid";
            if (!isNil "_grid") then { _result = _grid getOrDefault ["sectorSize", 250] };
        };
    };

    // [held objectives, reach]: sector index -> owning objective ID, for every land sector within reach of a
    // held objective, owned by the nearest. Cached on the handler; rebuilt when the held set or the reach changes.
    case "territory": {
        _args params [["_held", []], ["_reach", 3000]];
        private _size = [nil, "sectorSize"] call ALIVE_fnc_OPCOMcoverage;
        private _key = format ["%1|%2|%3", _held apply { [_x, "objectiveID", ""] call ALiVE_fnc_HashGet }, _reach, _size];
        private _territory = [_handler, "coverageTerritory", createHashMap] call ALiVE_fnc_HashGet;
        if (([_handler, "coverageTerritoryKey", ""] call ALiVE_fnc_HashGet) == _key) exitWith { _result = _territory };
        _territory = createHashMap;
        private _r = _reach / _size;
        private _r2 = _r * _r;
        private _ring = ceil _r;
        // nearest objective wins: keep the distance each sector was claimed at
        private _claimed = createHashMap;
        {
            private _oid = [_x, "objectiveID", ""] call ALiVE_fnc_HashGet;
            private _c = [_x, "center", [0,0,0]] call ALiVE_fnc_HashGet;
            private _ix = floor ((_c select 0) / _size);
            private _iy = floor ((_c select 1) / _size);
            for "_dx" from -_ring to _ring do {
                for "_dy" from -_ring to _ring do {
                    private _d2 = _dx * _dx + _dy * _dy;
                    if (_d2 <= _r2) then {
                        private _sector = [_ix + _dx, _iy + _dy];
                        private _best = _claimed getOrDefault [_sector, 1e9];
                        if (_d2 < _best) then {
                            private _p = [(_ix + _dx + 0.5) * _size, (_iy + _dy + 0.5) * _size, 0];
                            // on the map only: past its edge the engine carries the edge's land on, and a stop there
                            // would send a patrol off the map
                            if ((_p select 0) >= 0 && {(_p select 1) >= 0} && {(_p select 0) <= worldSize} && {(_p select 1) <= worldSize} && {!surfaceIsWater _p}) then {
                                _claimed set [_sector, _d2];
                                _territory set [_sector, _oid];
                            };
                        };
                    };
                };
            };
        } forEach _held;
        [_handler, "coverageTerritory", _territory] call ALiVE_fnc_HashSet;
        [_handler, "coverageTerritoryKey", _key] call ALiVE_fnc_HashSet;
        _result = _territory;
    };

    // [[objective, groups at home] ...]: sector index -> objective ID for the ground each garrison watches,
    // 400 m a group up to 1 km. Static; rebuilt only when the counts change.
    case "watch": {
        _args params [["_homes", []]];
        private _size = [nil, "sectorSize"] call ALIVE_fnc_OPCOMcoverage;
        private _key = format ["%1|%2", _homes apply { [[_x select 0, "objectiveID", ""] call ALiVE_fnc_HashGet, _x select 1] }, _size];
        private _watch = [_handler, "coverageWatch", createHashMap] call ALiVE_fnc_HashGet;
        if (([_handler, "coverageWatchKey", ""] call ALiVE_fnc_HashGet) == _key) exitWith { _result = _watch };
        _watch = createHashMap;
        {
            _x params ["_obj", "_home"];
            if (_home > 0) then {
                private _oid = [_obj, "objectiveID", ""] call ALiVE_fnc_HashGet;
                private _c = [_obj, "center", [0,0,0]] call ALiVE_fnc_HashGet;
                private _r = ((COVERAGE_WATCH_PER_GROUP * _home) min COVERAGE_WATCH_MAX) / _size;
                private _r2 = _r * _r;
                private _ring = ceil _r;
                private _ix = floor ((_c select 0) / _size);
                private _iy = floor ((_c select 1) / _size);
                for "_dx" from -_ring to _ring do {
                    for "_dy" from -_ring to _ring do {
                        if (_dx * _dx + _dy * _dy <= _r2) then { _watch set [[_ix + _dx, _iy + _dy], _oid] };
                    };
                };
            };
        } forEach _homes;
        [_handler, "coverageWatch", _watch] call ALiVE_fnc_HashSet;
        [_handler, "coverageWatchKey", _key] call ALiVE_fnc_HashSet;
        _result = _watch;
    };

    // [side text, position, profile ID]: a patrol of that side is in this sector. One get, one set; the old value
    // decays first. A patrol that is still in the sector it last marked doesn't mark it again.
    case "mark": {
        _args params [["_side", ""], ["_pos", []], ["_id", ""]];
        if (_side isEqualType west) then { _side = str _side };
        if !(_side isEqualType "" && {_side != ""} && {_pos isEqualType []} && {count _pos > 1}) exitWith {};
        if (isNil "ALiVE_coveragePresence") then { ALiVE_coveragePresence = createHashMap };
        if (isNil "ALiVE_coverageLastSector") then { ALiVE_coverageLastSector = createHashMap };
        private _size = [nil, "sectorSize"] call ALIVE_fnc_OPCOMcoverage;
        private _sector = [floor ((_pos select 0) / _size), floor ((_pos select 1) / _size)];
        if ((ALiVE_coverageLastSector getOrDefault [_id, []]) isEqualTo _sector) exitWith {};
        ALiVE_coverageLastSector set [_id, _sector];
        private _table = ALiVE_coveragePresence getOrDefault [_side, createHashMap, true];
        private _now = call _fnc_now;
        (_table getOrDefault [_sector, [0, _now]]) params ["_v", "_stamp"];
        _table set [_sector, [_v * (0.5 ^ ((_now - _stamp) / ALiVE_coverageHalfLife)) + 1, _now]];
        _result = true;
    };

    // [side text, sector index]: the decayed presence there, 0 when none
    case "presence": {
        _args params [["_side", ""], ["_sector", []]];
        _result = 0;
        if (isNil "ALiVE_coveragePresence") exitWith {};
        private _table = ALiVE_coveragePresence getOrDefault [_side, createHashMap];
        private _cell = _table get _sector;
        if (isNil "_cell") exitWith {};
        _cell params ["_v", "_stamp"];
        _result = _v * (0.5 ^ (((call _fnc_now) - _stamp) / ALiVE_coverageHalfLife));
    };

    // [side text, home position, reach, is-rear code]: the stops for a Coverage patrol, nearest first, as
    // [position, size] pairs: the coldest sectors of the territory within reach of home that nobody watches and
    // that are not near a fight, at least three sectors apart, scored by presence and distance
    case "coldest": {
        _args params [["_side", ""], ["_homePos", [0,0,0]], ["_reach", 3000], ["_fnc_rear", { true }]];
        private _size = [nil, "sectorSize"] call ALIVE_fnc_OPCOMcoverage;
        private _territory = [_handler, "coverageTerritory", createHashMap] call ALiVE_fnc_HashGet;
        private _watch = [_handler, "coverageWatch", createHashMap] call ALiVE_fnc_HashGet;
        private _r = _reach / _size;
        private _r2 = _r * _r;
        private _near2 = (COVERAGE_NEAR_HOME / _size) ^ 2;
        private _gap = COVERAGE_STOP_GAP max _size;
        private _hx = (_homePos select 0) / _size;
        private _hy = (_homePos select 1) / _size;
        private _candidates = [];
        {
            private _sector = _x;
            private _dx = (_sector select 0) + 0.5 - _hx;
            private _dy = (_sector select 1) + 0.5 - _hy;
            private _d2 = _dx * _dx + _dy * _dy;
            if (_d2 <= _r2 && {_d2 > _near2} && {isNil { _watch get _sector }}) then {
                private _p = [((_sector select 0) + 0.5) * _size, ((_sector select 1) + 0.5) * _size, 0];
                if ([_p] call _fnc_rear) then {
                    private _presence = [nil, "presence", [_side, _sector]] call ALIVE_fnc_OPCOMcoverage;
                    _candidates pushBack [_presence * (1 + (sqrt _d2) / _r) + random 0.05, _sector, _p];
                };
            };
        } forEach (keys _territory);
        _candidates sort true;
        private _picked = [];
        {
            _x params ["", "_sector", "_p"];
            if ((_picked findIf { ((_x select 0) distance2D _p) < _gap }) < 0) then { _picked pushBack [_p, _sector] };
            if (count _picked >= COVERAGE_STOPS) exitWith {};
        } forEach _candidates;
        // nearest first from home, then from each stop, so the walk is a loop and not a star
        private _tour = [];
        private _from = _homePos;
        while { _picked isNotEqualTo [] } do {
            private _i = 0;
            private _best = 1e9;
            {
                private _d = (_x select 0) distance2D _from;
                if (_d < _best) then { _best = _d; _i = _forEachIndex };
            } forEach _picked;
            _from = (_picked select _i) select 0;
            _tour pushBack [_from, 100];
            _picked deleteAt _i;
        };
        _result = _tour;
    };

    // [groups at the objective, objective size, share, patrols already out]: how many more a Coverage patrol can
    // take, the surplus above the objective's minimum (2 at a large one, 1 at a small one) times the share as a bias:
    // Few a third, Some two thirds, Many all. One place, so the patrol code and the test use the same rule
    case "surplus": {
        _args params [["_groups", 0], ["_objSize", 100], ["_share", 0], ["_out", 0]];
        private _minimum = [1, 2] select (_objSize >= 150);
        _result = floor (((_groups - _minimum) max 0) * (_share / 0.75)) - _out;
    };
};

if (isNil "_result") then { nil } else { _result };
