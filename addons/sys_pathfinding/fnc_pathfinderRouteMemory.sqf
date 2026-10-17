#include "\x\alive\addons\sys_pathfinding\script_component.hpp"
SCRIPT(pathfinderRouteMemory);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_pathfinderRouteMemory

Description:
Route memory (#1086, proposed by Goldwep). Ground routes remember where a side
has been hurt and, on top of that, vary a little from one request to the next,
so two groups sent the same way don't walk the identical line and a road that
keeps costing a side lives is avoided for a while.

Danger: a group wiped out (PROFILE_KILLED) or a land vehicle destroyed adds 1
to the coarse sector it happened in and 0.5 to the eight round it; each man
lost adds 0.25, and each attack on one of a side's groups 0.1 where the group
stands. Losses in aircraft and boats add nothing. Danger halves every two hours
of simulation time and is not saved, so a reload starts with none. A sector's cost for that side is multiplied by
1 + (ceiling - 1) * (1 - e^-danger), so it rises quickly at first and never
passes the ceiling.

Variation: each request draws its own random field over a 2 km lattice,
smoothly interpolated, and multiplies sector costs by 1 +/- the amplitude.

Both are computed once per coarse sector per request and shared by the coarse
and fine searches, so the fine search refines a route built with the same
costs. Off (the default) builds nothing and routes exactly as before.

Parameters:
Any - logic (unused) or the event listener
String - operation: "init", "handleEvent", "deposit", "jobContext", "factor"
Any - arguments

Returns:
Any - see each operation

Author:
Jman
---------------------------------------------------------------------------- */

#define RM_LATTICE 2000
#define RM_KILL_WEIGHT 1
#define RM_ATTACK_WEIGHT 0.1
// stall check (#1086 step 2)
#define RM_STALL_PASS 30
#define RM_STALL_MOVE 15
#define RM_STALL_TIME_VEHICLE 90
#define RM_STALL_TIME_MAN 150
#define RM_BLOCKED_CEILING 8
#define RM_BLOCKED_HALFLIFE 21600
#define RM_BLOCKED_CELLS 4
#define RM_REPATH_GAP 300
#define RM_REPATH_WINDOW 1800
#define RM_REPATH_MAX 3
#define RM_REPATH_PER_PASS 2
#define RM_QUEUE_BUSY 20

params ["_logic", ["_operation", ""], ["_args", []]];

private _result = nil;

switch (_operation) do {

    // Read the setting, start the danger table and listen for deaths and attacks. Server only.
    case "init": {
        private _mode = toLower (if (_args isEqualType "") then { _args } else { "off" });
        if !(_mode in ["off", "low", "high"]) then { _mode = "off" };
        ALiVE_pathfinding_routeMemory = _mode;
        // amplitude of the variation and danger ceiling per level; isNil-guarded so a console override survives
        if (isNil "ALiVE_pathfinding_routeMemoryLevels") then {
            ALiVE_pathfinding_routeMemoryLevels = createHashMapFromArray [["low", [0.14, 3]], ["high", [0.28, 5]]];
        };
        if (isNil "ALiVE_pathfinding_routeMemoryHalfLife") then { ALiVE_pathfinding_routeMemoryHalfLife = 7200 };
        // Step 2: spawned groups that stop moving mark the ground ahead blocked for their size and take a detour.
        // The loop runs whatever the setting, so switching it on later works; each pass returns at once while Off.
        if (isNil "ALiVE_routeMemory_blocked") then { ALiVE_routeMemory_blocked = createHashMap };
        if (isNil "ALiVE_routeMemory_stall") then {
            ALiVE_routeMemory_stall = createHashMap;
            [] spawn {
                while { true } do {
                    sleep RM_STALL_PASS;
                    [nil, "stallPass"] call ALiVE_fnc_pathfinderRouteMemory;
                };
            };
        };
        if (_mode == "off") exitWith {};
        if (isNil "ALiVE_routeMemory_danger") then { ALiVE_routeMemory_danger = createHashMap };
        if (isNil "ALiVE_routeMemory_listenerID" && {!isNil "ALiVE_eventLog"}) then {
            private _listener = [] call ALiVE_fnc_hashCreate;
            [_listener, "class", "ALiVE_fnc_pathfinderRouteMemory"] call ALiVE_fnc_hashSet;
            ALiVE_routeMemory_listenerID = [ALiVE_eventLog, "addListener", [_listener, ["PROFILE_KILLED", "PROFILE_ATTACK_START"]]] call ALiVE_fnc_eventLog;
        };
    };

    // [profile, group or classname]: "man", "car", "truck" or "tracked", the size the blocked table is kept by
    case "sizeClass": {
        private _class = "";
        if (_args isEqualType "") then { _class = _args };
        if (_args isEqualType grpNull && {!isNull _args}) then {
            private _vehicle = vehicle leader _args;
            if (_vehicle != leader _args) then { _class = typeOf _vehicle };
        };
        if (_args isEqualType [] && {count _args > 2}) then {
            private _inCommand = (_args select 2) param [8, []];
            if (_inCommand isNotEqualTo []) then {
                private _vehicleProfile = [ALiVE_profileHandler, "getProfile", _inCommand select 0] call ALiVE_fnc_profileHandler;
                if (!isNil "_vehicleProfile") then { _class = _vehicleProfile select 2 select 11 };
            };
        };
        _result = "man";
        if (_class isEqualType "" && {_class != ""}) then {
            _result = switch (_class call ALIVE_fnc_vehicleGetKindOf) do {
                case "Car": { "car" };
                case "Truck": { "truck" };
                case "Tank";
                case "Armored": { "tracked" };
                default { "truck" };
            };
        };
    };

    // [positions, size class, weight]: mark sub-sectors blocked for that size; a fresh pair per write, as deposit
    case "block": {
        _args params [["_positions", []], ["_class", "man"], ["_weight", 1]];
        if (isNil "ALiVE_routeMemory_blocked" || {isNil "ALiVE_pathfinder"}) exitWith {};
        private _size = (ALiVE_pathfinder get "terrainGrid") get "subSectorSize";
        private _now = missionNamespace getVariable ["ALiVE_simulationTime", time];
        private _table = ALiVE_routeMemory_blocked getOrDefault [_class, createHashMap, true];
        {
            private _key = [floor ((_x select 0) / _size), floor ((_x select 1) / _size)];
            (_table getOrDefault [_key, [0, _now]]) params ["_v", "_stamp"];
            _table set [_key, [_v * (0.5 ^ ((_now - _stamp) / RM_BLOCKED_HALFLIFE)) + _weight, _now]];
        } forEach _positions;
    };

    // One pass over the spawned ground groups: a group that hasn't moved RM_STALL_MOVE metres for its stall
    // time, with somewhere to go and no reason to wait, marks the ground towards its next waypoint blocked for
    // its size and is given a detour to that waypoint, laid in front of it. Its own orders are never touched.
    case "stallPass": {
        if ((missionNamespace getVariable ["ALiVE_pathfinding_routeMemory", "off"]) == "off") exitWith {};
        if (isNil "ALiVE_profileHandler" || {isNil "ALiVE_pathfinder"}) exitWith {};
        private _now = missionNamespace getVariable ["ALiVE_simulationTime", time];
        private _stall = ALiVE_routeMemory_stall;
        private _active = [ALiVE_profileHandler, "getActiveEntities"] call ALiVE_fnc_profileHandler;
        _active = if (_active isEqualType []) then { +_active } else { [] };
        { if !(_x in _active) then { _stall deleteAt _x } } forEach (keys _stall);
        private _subSize = (ALiVE_pathfinder get "terrainGrid") get "subSectorSize";
        private _queueBusy = count (ALiVE_pathfinder get "pathJobs") > RM_QUEUE_BUSY;
        private _debug = missionNamespace getVariable ["ALiVE_pathfinding_routeMemoryDebug", false];
        private _repaths = 0;
        {
            private _id = _x;
            call {
                private _profile = [ALiVE_profileHandler, "getProfile", _id] call ALiVE_fnc_profileHandler;
                if (isNil "_profile") exitWith {};
                private _data = _profile select 2;
                if ((_data param [30, false]) isEqualTo true) exitWith { _stall deleteAt _id };              // players
                if ((_data param [25, false]) isEqualTo true) exitWith { _stall deleteAt _id };              // cycling patrols
                if ((_data param [9, []]) isNotEqualTo []) exitWith { _stall deleteAt _id };               // riding as cargo
                if (([_profile, "isSPE", false] call ALiVE_fnc_hashGet) isEqualTo true) exitWith { _stall deleteAt _id };
                private _group = _data param [13, grpNull];
                if !(_group isEqualType grpNull) exitWith {};
                if (isNull _group) exitWith { _stall deleteAt _id };
                private _leader = leader _group;
                if (!alive _leader) exitWith { _stall deleteAt _id };
                private _wps = waypoints _group;
                private _current = currentWaypoint _group;
                if (_current < 0 || {_current >= count _wps}) exitWith { _stall deleteAt _id };
                private _wp = [_group, _current];
                private _vehicle = vehicle _leader;
                private _inVehicle = _vehicle != _leader;
                if (_inVehicle && {_vehicle isKindOf "StaticWeapon" || {getNumber (configOf _vehicle >> "artilleryScanner") > 0}}) exitWith { _stall deleteAt _id };
                private _here = getPosATL _vehicle;
                private _dir = _here getDir (waypointPosition _wp);
                private _entry = _stall getOrDefault [_id, []];
                // a new route or order starts the clock again; so does moving, or a reason to stand still. Standing
                // by an order's waypoint is waiting at it; a route point a group can't reach is not.
                private _signature = [count _wps, _current, waypointPosition _wp];
                // orders are renamed "pathfound" like the points of their route, so tell them apart by what they carry
                private _isOrder = _current == count _wps - 1
                    || {((waypointStatements _wp) param [1, ""]) != ""}
                    || {waypointType _wp != "MOVE"}
                    || {(waypointTimeout _wp) isNotEqualTo [0, 0, 0]};
                // the first reason it has to stand still, or "" for none
                private _why = call {
                    if (([_profile, "combat", false] call ALiVE_fnc_hashGet) isEqualTo true) exitWith { "combat" };
                    // on guard with an enemy it knows of close by: resting after a fight or waiting for one. On guard with
                    // nobody near, it's as stuck as anyone (a group boxed in can stay in combat mode for good).
                    if (behaviour _leader in ["COMBAT", "STEALTH"] && {
                        private _enemy = _leader findNearestEnemy _leader;
                        !isNull _enemy && {(_enemy distance2D _leader) < 400}
                    }) exitWith { "enemy near" };
                    if ((units _group) findIf { _x getVariable ["ALiVE_garrisonHeld", false] } > -1) exitWith { "garrison" };
                    if (!_inVehicle && {!isNull assignedVehicle _leader}) exitWith { "mounting" };
                    if (_inVehicle && {!canMove _vehicle || {_vehicle isKindOf "Air"} || {_vehicle isKindOf "Ship"}}) exitWith { "vehicle" };
                    if (((waypointStatements _wp) param [1, ""]) find "_disableSimulation = true;" > -1) exitWith { "ambient" };
                    if (([_profile, "locked", false] call ALiVE_fnc_hashGet) isEqualTo true) exitWith { "locked" };
                    if ((_data param [33, false]) isEqualTo true) exitWith { "busy" };
                    if (!(_leader checkAIFeature "PATH") || {!(_leader checkAIFeature "MOVE")}) exitWith { "ai off" };
                    if (((expectedDestination _leader) param [1, ""]) == "DoNotPlan") exitWith { "stopped" };
                    if (_inVehicle && {((_here getPos [20, _dir]) nearEntities [["LandVehicle"], 15]) findIf { _x != _vehicle && {side _x == side _group} } > -1}) exitWith { "queue" };
                    if (_isOrder && {(_here distance2D waypointPosition _wp) < (waypointCompletionRadius _wp max 10) + 50}) exitWith { "at order" };
                    ""
                };
                // progress is getting closer to the waypoint: milling about where it stands is not
                private _distance = _here distance2D waypointPosition _wp;
                if (_entry isEqualTo [] || {_why != ""} || {(_entry select 2) isNotEqualTo _signature} || {_distance < (_entry select 0) - RM_STALL_MOVE}) exitWith {
                    _stall set [_id, [_distance, _now, _signature, _entry param [3, []], _why]];
                };
                private _limit = [RM_STALL_TIME_MAN, RM_STALL_TIME_VEHICLE] select _inVehicle;
                if (_now - (_entry select 1) < _limit) exitWith {};
                private _history = (_entry param [3, []]) select { _now - _x < RM_REPATH_WINDOW };
                if (count _history >= RM_REPATH_MAX || {_history isNotEqualTo [] && {_now - (selectMax _history) < RM_REPATH_GAP}}) exitWith {};
                if (_queueBusy || {_repaths >= RM_REPATH_PER_PASS}) exitWith {};

                // aim far enough ahead to go round something: the first waypoint four sub-sectors off, passing over
                // plain route points but never an order, which the group has to reach itself
                private _fnc_isOrder = {
                    private _w = [_group, _this];
                    _this == count _wps - 1
                        || {((waypointStatements _w) param [1, ""]) != ""}
                        || {waypointType _w != "MOVE"}
                        || {(waypointTimeout _w) isNotEqualTo [0, 0, 0]}
                };
                private _target = _current;
                while {
                    (_here distance2D waypointPosition [_group, _target]) < 4 * _subSize
                    && {!(_target call _fnc_isOrder)}
                    && {_target + 1 < count _wps}
                } do { _target = _target + 1 };
                private _targetPos = waypointPosition [_group, _target];
                private _class = [nil, "sizeClass", _profile] call ALiVE_fnc_pathfinderRouteMemory;

                // the band ahead: up to four sub-sectors on the line it was trying to take (towards its current
                // waypoint), half as much either side
                private _bandDir = _dir;
                private _steps = (floor ((_here distance2D _targetPos) / _subSize)) min RM_BLOCKED_CELLS max 1;
                private _line = [];
                private _sides = [];
                for "_i" from 1 to _steps do {
                    private _p = _here getPos [_i * _subSize, _bandDir];
                    _line pushBack _p;
                    _sides pushBack (_p getPos [_subSize, _bandDir + 90]);
                    _sides pushBack (_p getPos [_subSize, _bandDir - 90]);
                };
                private _weight = [1, 2] select (_history isNotEqualTo []);
                [nil, "block", [_line, _class, _weight]] call ALiVE_fnc_pathfinderRouteMemory;
                [nil, "block", [_sides, _class, _weight / 2]] call ALiVE_fnc_pathfinderRouteMemory;

                _history pushBack _now;
                _stall set [_id, [_distance, _now, _signature, _history, "detour"]];
                _repaths = _repaths + 1;

                // the detour: a route from here to the target, its points laid in front of the target as plain
                // moves named like any other route point, so a despawn carries them over as already routed.
                // The pathfinder is only ever asked from unscheduled code, as everywhere else.
                private _procedure = [_profile] call ALiVE_fnc_profileGetPathfindingProcedure;
                private _goal = [_targetPos, 0, "MOVE", "NORMAL", waypointCompletionRadius [_group, _target]] call ALIVE_fnc_createProfileWaypoint;
                private _request = [_here, _procedure, _goal, nil, [_id, [false], _data select 3, _group, _target, _targetPos, _debug, _here, _current], {
                    params ["_callbackArgs", "_path"];
                    [{
                        params ["_callbackArgs", "_path"];
                        _callbackArgs params ["_id", "", "", "_group", "_target", "_targetPos", "_debug", "_from", "_current"];
                        if (
                            isNull _group
                            || {currentWaypoint _group != _current}
                            || {count waypoints _group <= _target}
                            || {(waypointPosition [_group, _target]) distance2D _targetPos > 5}
                            || {((getPosATL vehicle leader _group) distance2D _targetPos) < (_from distance2D _targetPos) - RM_STALL_MOVE}
                        ) exitWith {
                            if (_debug) then { ["ALiVE route memory: %1 moved on or was given new orders before its detour came back", _id] call ALiVE_fnc_dump };
                        };
                        if !(_path isEqualType []) exitWith {};
                        // the last point is the target itself; points within reach of where it stands are dropped, or
                        // the first would count as a waypoint it's waiting at and hide a second stall
                        private _reach = (waypointCompletionRadius [_group, _target] max 10) + 50;
                        private _points = (_path select [0, (count _path - 1) max 0]) select { (_x distance2D _from) >= _reach };
                        if (_points isEqualTo []) exitWith {};
                        // read before inserting: each insert moves the target one place on
                        private _template = [_group, _target];
                        private _settings = [waypointCompletionRadius _template, waypointSpeed _template, waypointBehaviour _template, waypointCombatMode _template, waypointFormation _template];
                        {
                            private _new = _group addWaypoint [_x, 0, _target + _forEachIndex];
                            _new setWaypointType "MOVE";
                            _new setWaypointName "pathfound";
                            _new setWaypointCompletionRadius (_settings select 0);
                            _new setWaypointSpeed (_settings select 1);
                            _new setWaypointBehaviour (_settings select 2);
                            _new setWaypointCombatMode (_settings select 3);
                            _new setWaypointFormation (_settings select 4);
                        } forEach _points;
                        _group setCurrentWaypoint [_group, _target];
                        if (_debug) then { ["ALiVE route memory: %1 stuck, detour of %2 points to %3", _id, count _points, mapGridPosition _targetPos] call ALiVE_fnc_dump };
                    }, [_callbackArgs, _path]] call CBA_fnc_directCall;
                }];
                [{ [ALiVE_pathfinder, "findPath", _this] call ALiVE_fnc_pathfinder }, _request] call CBA_fnc_directCall;
            };
        } forEach _active;
    };

    case "handleEvent": {
        private _type = [_args, "type"] call ALiVE_fnc_hashGet;
        private _data = [_args, "data"] call ALiVE_fnc_hashGet;
        switch (_type) do {
            case "PROFILE_KILLED": {
                _data params ["_position", "_faction", "_side", "_killerSide", ["_victim", []]];
                // a group lost with its aircraft or boat says nothing about the ground below
                private _byAirOrSea = false;
                if (_victim isEqualType [] && {count _victim > 2}) then {
                    private _victimData = _victim select 2;
                    {
                        private _vehicle = [ALiVE_profileHandler, "getProfile", _x] call ALiVE_fnc_profileHandler;
                        if (!isNil "_vehicle") then {
                            private _type = _vehicle select 2 select 6;
                            if (_type isEqualType "" && {_type isKindOf "Air" || {_type isKindOf "Ship"}}) then { _byAirOrSea = true };
                        };
                    } forEach ((_victimData param [8, []]) + (_victimData param [9, []]));
                };
                if (!_byAirOrSea) then {
                    [nil, "deposit", [_position, _side, RM_KILL_WEIGHT]] call ALiVE_fnc_pathfinderRouteMemory;
                };
            };
            case "PROFILE_ATTACK_START": {
                // where the targets stand: the attack's own position is the attacker's
                _data params ["_attackID", "_attackerID", "_targets"];
                {
                    private _profile = [ALiVE_profileHandler, "getProfile", _x] call ALiVE_fnc_profileHandler;
                    if (!isNil "_profile") then {
                        [nil, "deposit", [_profile select 2 select 2, _profile select 2 select 3, RM_ATTACK_WEIGHT]] call ALiVE_fnc_pathfinderRouteMemory;
                    };
                } forEach (if (_targets isEqualType []) then { _targets } else { [] });
            };
        };
    };

    // [position, side, weight]: add danger for that side at the position's sector, half as much around it
    case "deposit": {
        _args params [["_pos", []], ["_side", ""], ["_weight", 0]];
        if (isNil "ALiVE_routeMemory_danger" || {isNil "ALiVE_pathfinder"}) exitWith {};
        if (_side isEqualType west) then { _side = str _side };
        if !(_side isEqualType "" && {_pos isEqualType []} && {count _pos > 1}) exitWith {};
        private _size = (ALiVE_pathfinder get "terrainGrid") get "sectorSize";
        private _now = missionNamespace getVariable ["ALiVE_simulationTime", time];
        private _halfLife = ALiVE_pathfinding_routeMemoryHalfLife;
        private _table = ALiVE_routeMemory_danger getOrDefault [_side, createHashMap, true];
        private _ix = floor ((_pos select 0) / _size);
        private _iy = floor ((_pos select 1) / _size);
        for "_dx" from -1 to 1 do {
            for "_dy" from -1 to 1 do {
                private _key = [_ix + _dx, _iy + _dy];
                private _add = if (_dx == 0 && {_dy == 0}) then { _weight } else { _weight / 2 };
                (_table getOrDefault [_key, [0, _now]]) params ["_v", "_stamp"];
                // a fresh pair each time: the pathfinder reads the table unscheduled while this runs scheduled
                _table set [_key, [_v * (0.5 ^ ((_now - _stamp) / _halfLife)) + _add, _now]];
            };
        };
    };

    // [procedure capabilities, side]: the per-request state, or [] when route memory doesn't apply to this
    // request. Ground routes only: men on foot and land vehicles, never anything that flies.
    case "jobContext": {
        _args params [["_capabilities", []], ["_side", ""], ["_callbackArgs", []]];
        private _mode = missionNamespace getVariable ["ALiVE_pathfinding_routeMemory", "off"];
        _result = [];
        if (_mode == "off" || {!(_capabilities param [0, false])} || {_capabilities param [4, true]}) exitWith {};
        (ALiVE_pathfinding_routeMemoryLevels getOrDefault [_mode, [0, 1]]) params ["_amp", "_ceiling"];
        private _danger = if (_side isEqualType "" && {!isNil "ALiVE_routeMemory_danger"}) then {
            ALiVE_routeMemory_danger getOrDefault [_side, createHashMap]
        } else { createHashMap };
        private _grid = ALiVE_pathfinder get "terrainGrid";
        // the blocked table for the size of whoever asked: a profile's ID, or a group (logistics trucks)
        private _blocked = createHashMap;
        if (!isNil "ALiVE_routeMemory_blocked" && {count ALiVE_routeMemory_blocked > 0}) then {
            private _who = if (_callbackArgs isEqualType []) then { _callbackArgs param [0, ""] } else { "" };
            if (_who isEqualType "" && {_who != ""}) then {
                private _profile = [ALiVE_profileHandler, "getProfile", _who] call ALiVE_fnc_profileHandler;
                _who = if (isNil "_profile") then { "" } else { _profile };
            };
            private _class = [nil, "sizeClass", _who] call ALiVE_fnc_pathfinderRouteMemory;
            _blocked = ALiVE_routeMemory_blocked getOrDefault [_class, createHashMap];
        };
        // [amplitude, ceiling, danger table, time now, lattice corners, factor per sector, sector size,
        //  blocked table, factor per sub-sector, sub-sector size]
        _result = [_amp, _ceiling, _danger, missionNamespace getVariable ["ALiVE_simulationTime", time], createHashMap, createHashMap,
            _grid get "sectorSize", _blocked, createHashMap, _grid get "subSectorSize"];
    };

    // [context, sub-sector index]: the fine search's factor, its coarse sector's times any blockage there
    case "fineFactor": {
        _args params ["_ctx", "_key"];
        private _ratio = round ((_ctx select 6) / (_ctx select 9));
        private _coarse = [nil, "factor", [_ctx, [floor ((_key select 0) / _ratio), floor ((_key select 1) / _ratio)]]] call ALiVE_fnc_pathfinderRouteMemory;
        private _blocked = _ctx select 7;
        if (count _blocked == 0) exitWith { _result = _coarse };
        private _cache = _ctx select 8;
        _result = _cache get _key;
        if (isNil "_result") then {
            _result = _coarse;
            private _cell = _blocked get _key;
            if (!isNil "_cell") then {
                _cell params ["_v", "_stamp"];
                private _b = _v * (0.5 ^ (((_ctx select 3) - _stamp) / RM_BLOCKED_HALFLIFE));
                _result = _result * (1 + (RM_BLOCKED_CEILING - 1) * (1 - exp (-_b)));
            };
            _cache set [_key, _result];
        };
    };

    // [context, sector index]: the cost factor for that coarse sector, computed once per request
    case "factor": {
        _args params ["_ctx", "_key"];
        _ctx params ["_amp", "_ceiling", "_danger", "_now", "_lattice", "_cache", "_size"];
        _result = _cache get _key;
        if (isNil "_result") then {
            private _u = ((_key select 0) + 0.5) * _size / RM_LATTICE;
            private _w = ((_key select 1) + 0.5) * _size / RM_LATTICE;
            private _i = floor _u;
            private _j = floor _w;
            private _fu = _u - _i;
            private _fw = _w - _j;
            _fu = _fu * _fu * (3 - 2 * _fu);
            _fw = _fw * _fw * (3 - 2 * _fw);
            private _c = [[_i, _j], [_i + 1, _j], [_i, _j + 1], [_i + 1, _j + 1]] apply {
                private _n = _lattice get _x;
                if (isNil "_n") then { _n = random 2 - 1; _lattice set [_x, _n] };
                _n
            };
            private _noise = ((_c select 0) * (1 - _fu) + (_c select 1) * _fu) * (1 - _fw)
                + ((_c select 2) * (1 - _fu) + (_c select 3) * _fu) * _fw;
            _result = 1 + _amp * _noise;
            private _cell = _danger get _key;
            if (!isNil "_cell") then {
                _cell params ["_v", "_stamp"];
                private _d = _v * (0.5 ^ ((_now - _stamp) / ALiVE_pathfinding_routeMemoryHalfLife));
                _result = _result * (1 + (_ceiling - 1) * (1 - exp (-_d)));
            };
            _cache set [_key, _result];
        };
    };
};

if (isNil "_result") then { nil } else { _result };
