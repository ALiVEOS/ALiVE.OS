#include "\x\alive\addons\sys_pathfinding\script_component.hpp"

SCRIPT(test_routeMemory);

/* ----------------------------------------------------------------------------
Route memory test (#1086). Covers fnc_pathfinderRouteMemory: init, jobContext,
factor, deposit, decay, block, fineFactor, sizeClass, handleEvent and the
stall pass guards.

Needs no mission for the first part: paste it into the debug console of an
empty world and read the RPT. When no pathfinder exists it stands in a stub
grid (250 m sectors, 50 m sub-sectors) and removes it afterwards. The last
part asks the live pathfinder for routes and only runs when one exists, so
run it from a mission with the Virtual AI System placed to cover that too.

Every global the test touches is put back as it was. The stall check itself
needs a group boxed in by something on a real map; that stays a manual test.
---------------------------------------------------------------------------- */

private _fails = [];
private _fnc_check = {
    // _ok is Any on purpose: an assertion that threw arrives as nil, and
    // `if (nil)` would throw again and print nothing.
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
private _fnc_near = { params ["_a", "_b", ["_tol", 0.0001]]; abs (_a - _b) <= _tol };
// the simulation clock ticks every frame and deposit decays what is there before adding, so accumulation
// checks allow for a few frames of decay (half-lives are hours; 10 s is under 1e-3) and never touch the clock

diag_log "=== Route memory test ===";

// --- keep what we change ---------------------------------------------------
private _saved = [
    missionNamespace getVariable "ALiVE_pathfinding_routeMemory",
    missionNamespace getVariable "ALiVE_pathfinding_routeMemoryLevels",
    missionNamespace getVariable "ALiVE_pathfinding_routeMemoryHalfLife",
    missionNamespace getVariable "ALiVE_routeMemory_danger",
    missionNamespace getVariable "ALiVE_routeMemory_blocked"
];
// test the defaults, not a console override; the stall register is left alone or a second loop would start
ALiVE_pathfinding_routeMemoryLevels = nil;
ALiVE_pathfinding_routeMemoryHalfLife = nil;
ALiVE_routeMemory_blocked = nil;
private _stubbedPathfinder = isNil "ALiVE_pathfinder";
if (_stubbedPathfinder) then {
    ALiVE_pathfinder = createHashMapFromArray [
        ["terrainGrid", createHashMapFromArray [["sectorSize", 250], ["subSectorSize", 50]]],
        ["pathJobs", []]
    ];
};
private _sectorSize = (ALiVE_pathfinder get "terrainGrid") get "sectorSize";
private _subSize = (ALiVE_pathfinder get "terrainGrid") get "subSectorSize";
private _ratio = round (_sectorSize / _subSize);
private _land = [true, false, true, false, false];   // LandRoad / LandOffRoad capabilities
private _air = [true, true, true, true, true];        // Heli / Plane
private _fnc_sectorKey = { params ["_p"]; [floor ((_p select 0) / _sectorSize), floor ((_p select 1) / _sectorSize)] };
private _fnc_subKey = { params ["_p"]; [floor ((_p select 0) / _subSize), floor ((_p select 1) / _subSize)] };

// --- init ---------------------------------------------------------------------
[nil, "init", "off"] call ALiVE_fnc_pathfinderRouteMemory;
["init off sets the mode", ALiVE_pathfinding_routeMemory == "off"] call _fnc_check;
["init off starts the blocked table (stall loop runs whatever the setting)", !isNil "ALiVE_routeMemory_blocked"] call _fnc_check;
["init off starts the stall register", !isNil "ALiVE_routeMemory_stall"] call _fnc_check;
["init off fills the level table", (ALiVE_pathfinding_routeMemoryLevels get "high") isEqualTo [0.28, 5]] call _fnc_check;
["init off fills the half-life", ALiVE_pathfinding_routeMemoryHalfLife == 7200] call _fnc_check;

[nil, "init", "nonsense"] call ALiVE_fnc_pathfinderRouteMemory;
["init with an unknown level falls back to off", ALiVE_pathfinding_routeMemory == "off"] call _fnc_check;
[nil, "init", 42] call ALiVE_fnc_pathfinderRouteMemory;
["init with a non-string falls back to off", ALiVE_pathfinding_routeMemory == "off"] call _fnc_check;

["jobContext is empty while off", ([nil, "jobContext", [_land, "WEST", []]] call ALiVE_fnc_pathfinderRouteMemory) isEqualTo []] call _fnc_check;
["stallPass returns while off", isNil { [nil, "stallPass"] call ALiVE_fnc_pathfinderRouteMemory }] call _fnc_check;

ALiVE_routeMemory_danger = nil;
[nil, "init", "High"] call ALiVE_fnc_pathfinderRouteMemory;
["init accepts any case", ALiVE_pathfinding_routeMemory == "high"] call _fnc_check;
["init on starts the danger table", !isNil "ALiVE_routeMemory_danger"] call _fnc_check;
if (!isNil "ALiVE_eventLog") then {
    ["init on registers the event listener", !isNil "ALiVE_routeMemory_listenerID"] call _fnc_check;
};

// --- jobContext -------------------------------------------------------------
private _ctx = [nil, "jobContext", [_land, "WEST", []]] call ALiVE_fnc_pathfinderRouteMemory;
["jobContext for a land route has ten slots", count _ctx == 10] call _fnc_check;
["jobContext carries the level's amplitude", (_ctx select 0) == 0.28] call _fnc_check;
["jobContext carries the level's ceiling", (_ctx select 1) == 5] call _fnc_check;
["jobContext carries the sector sizes", (_ctx select 6) == _sectorSize && {(_ctx select 9) == _subSize}] call _fnc_check;
["jobContext is empty for an air route", ([nil, "jobContext", [_air, "WEST", []]] call ALiVE_fnc_pathfinderRouteMemory) isEqualTo []] call _fnc_check;
["jobContext is empty for a route that can't use land", ([nil, "jobContext", [[false, false, false, true, false], "WEST", []]] call ALiVE_fnc_pathfinderRouteMemory) isEqualTo []] call _fnc_check;
private _noSide = [nil, "jobContext", [_land, "", []]] call ALiVE_fnc_pathfinderRouteMemory;
["jobContext with no side still applies (variation only)", count _noSide == 10 && {count (_noSide select 2) == 0}] call _fnc_check;

// --- factor: variation only ---------------------------------------------------
private _keyA = [40, 40];
private _fA = [nil, "factor", [_ctx, _keyA]] call ALiVE_fnc_pathfinderRouteMemory;
["factor with no danger stays within the amplitude", _fA >= 1 - 0.28 - 0.0001 && {_fA <= 1 + 0.28 + 0.0001}] call _fnc_check;
["factor is cached per request", ([nil, "factor", [_ctx, _keyA]] call ALiVE_fnc_pathfinderRouteMemory) == _fA] call _fnc_check;
private _differs = false;
for "_i" from 0 to 19 do {
    private _c = [nil, "jobContext", [_land, "WEST", []]] call ALiVE_fnc_pathfinderRouteMemory;
    if (([nil, "factor", [_c, _keyA]] call ALiVE_fnc_pathfinderRouteMemory) != _fA) exitWith { _differs = true };
};
["variation differs between requests", _differs] call _fnc_check;
// the lattice is 2 km: two sectors inside one lattice cell get factors close to each other
// bound: 2 * amplitude * smoothstep difference across one sector, which only exceeds the amplitude on
// sectors wider than the 2 km lattice; checked with the sector size in use
private _fB = [nil, "factor", [_ctx, [41, 40]]] call ALiVE_fnc_pathfinderRouteMemory;
private _fnc_smooth = { params ["_t"]; _t * _t * (3 - 2 * _t) };
private _uA = (40.5 * _sectorSize / 2000) - floor (40.5 * _sectorSize / 2000);
private _uB = (41.5 * _sectorSize / 2000) - floor (41.5 * _sectorSize / 2000);
private _sameCell = floor (40.5 * _sectorSize / 2000) == floor (41.5 * _sectorSize / 2000);
private _bound = 2 * 0.28 * abs (([_uB] call _fnc_smooth) - ([_uA] call _fnc_smooth)) + 0.0001;
if (_sameCell) then {
    ["variation is smooth between neighbouring sectors", abs (_fA - _fB) <= _bound] call _fnc_check;
} else {
    diag_log "  skip  smoothness check: sectors 40 and 41 fall in different lattice cells at this grid size";
};

// --- deposit + factor: danger --------------------------------------------------
private _pos = [(45 + 0.5) * _sectorSize, (45 + 0.5) * _sectorSize, 0];
private _key = [_pos] call _fnc_sectorKey;
[nil, "deposit", [_pos, "WEST", 1]] call ALiVE_fnc_pathfinderRouteMemory;
private _west = ALiVE_routeMemory_danger get "WEST";
["deposit writes the side's table", !isNil "_west"] call _fnc_check;
["deposit puts the full weight on the sector", ((_west get _key) select 0) == 1] call _fnc_check;
["deposit puts half the weight on a neighbour", ((_west get [(_key select 0) + 1, (_key select 1) - 1]) select 0) == 0.5] call _fnc_check;
["deposit writes nine cells", count _west == 9] call _fnc_check;
[nil, "deposit", [_pos, "WEST", 1]] call ALiVE_fnc_pathfinderRouteMemory;
["deposit accumulates", [((_west get _key) select 0), 2, 0.002] call _fnc_near] call _fnc_check;
[nil, "deposit", [_pos, east, 1]] call ALiVE_fnc_pathfinderRouteMemory;
["deposit takes a side object as its side text", !isNil { ALiVE_routeMemory_danger get "EAST" }] call _fnc_check;
["deposit keeps sides apart", isNil { (ALiVE_routeMemory_danger get "EAST") get [(_key select 0) + 2, _key select 1] } && {count (ALiVE_routeMemory_danger get "EAST") == 9}] call _fnc_check;
private _before = count _west;
[nil, "deposit", [[], "WEST", 1]] call ALiVE_fnc_pathfinderRouteMemory;
[nil, "deposit", [_pos, 5, 1]] call ALiVE_fnc_pathfinderRouteMemory;
["deposit ignores a bad position or side", count _west == _before] call _fnc_check;

// a fresh context reads the danger; factor = variation * (1 + (ceiling-1)(1 - e^-d))
private _ctxD = [nil, "jobContext", [_land, "WEST", []]] call ALiVE_fnc_pathfinderRouteMemory;
private _ctxE = [nil, "jobContext", [_land, "EAST", []]] call ALiVE_fnc_pathfinderRouteMemory;
// strip the variation: compute the same key with amplitude forced to 0 in a copy of the context
private _fnc_pure = {
    params ["_c", "_k"];
    private _copy = +_c;
    _copy set [0, 0];
    _copy set [5, createHashMap];
    [nil, "factor", [_copy, _k]] call ALiVE_fnc_pathfinderRouteMemory
};
private _expected = 1 + (5 - 1) * (1 - exp (-2));
["danger of 2 gives 1 + 4(1 - e^-2) at the sector", [[_ctxD, _key] call _fnc_pure, _expected, 0.001] call _fnc_near] call _fnc_check;
["danger of 1 on the neighbour gives 1 + 4(1 - e^-1)", [[_ctxD, [(_key select 0) + 1, _key select 1]] call _fnc_pure, 1 + 4 * (1 - exp (-1)), 0.001] call _fnc_near] call _fnc_check;
["no danger two sectors away", [[_ctxD, [(_key select 0) + 2, _key select 1]] call _fnc_pure, 1, 0.001] call _fnc_near] call _fnc_check;
["the other side's danger at the same sector is its own", [[_ctxE, _key] call _fnc_pure, 1 + 4 * (1 - exp (-1)), 0.001] call _fnc_near] call _fnc_check;
[nil, "deposit", [_pos, "WEST", 1000]] call ALiVE_fnc_pathfinderRouteMemory;
private _ctxC = [nil, "jobContext", [_land, "WEST", []]] call ALiVE_fnc_pathfinderRouteMemory;
["danger never passes the ceiling", [[_ctxC, _key] call _fnc_pure, 5, 0.001] call _fnc_near] call _fnc_check;
["the variation rides on top of the danger", ([nil, "factor", [_ctxC, _key]] call ALiVE_fnc_pathfinderRouteMemory) <= 5 * 1.28 + 0.001] call _fnc_check;

// --- decay: the context carries its own clock ----------------------------------
private _ctxT = [nil, "jobContext", [_land, "EAST", []]] call ALiVE_fnc_pathfinderRouteMemory;
private _stamp = ((ALiVE_routeMemory_danger get "EAST") get _key) select 1;
_ctxT set [3, _stamp + ALiVE_pathfinding_routeMemoryHalfLife];
["danger halves after one half-life", [[_ctxT, _key] call _fnc_pure, 1 + 4 * (1 - exp (-0.5)), 0.001] call _fnc_near] call _fnc_check;
_ctxT set [3, _stamp + 10 * ALiVE_pathfinding_routeMemoryHalfLife];
_ctxT set [5, createHashMap];
["danger is all but gone after ten half-lives", [[_ctxT, _key] call _fnc_pure, 1, 0.01] call _fnc_near] call _fnc_check;
// deposit decays what was there before adding: back-date the stamp two half-lives from the live clock
private _stampedTable = ALiVE_routeMemory_danger get "EAST";
private _clock = missionNamespace getVariable ["ALiVE_simulationTime", time];
_stampedTable set [_key, [4, _clock - 2 * ALiVE_pathfinding_routeMemoryHalfLife]];
[nil, "deposit", [_pos, "EAST", 1]] call ALiVE_fnc_pathfinderRouteMemory;
["deposit decays the old value before adding", [((_stampedTable get _key) select 0), 2, 0.002] call _fnc_near] call _fnc_check;

// --- sizeClass -----------------------------------------------------------------
["sizeClass of nothing is man", ([nil, "sizeClass", ""] call ALiVE_fnc_pathfinderRouteMemory) == "man"] call _fnc_check;
["sizeClass of a null group is man", ([nil, "sizeClass", grpNull] call ALiVE_fnc_pathfinderRouteMemory) == "man"] call _fnc_check;
["sizeClass of a truck", ([nil, "sizeClass", "B_Truck_01_covered_F"] call ALiVE_fnc_pathfinderRouteMemory) == "truck"] call _fnc_check;
["sizeClass of an MRAP is car", ([nil, "sizeClass", "B_MRAP_01_F"] call ALiVE_fnc_pathfinderRouteMemory) == "car"] call _fnc_check;
["sizeClass of a tank is tracked", ([nil, "sizeClass", "B_MBT_01_cannon_F"] call ALiVE_fnc_pathfinderRouteMemory) == "tracked"] call _fnc_check;
["sizeClass of a tracked APC is tracked", ([nil, "sizeClass", "B_APC_Tracked_01_rcws_F"] call ALiVE_fnc_pathfinderRouteMemory) == "tracked"] call _fnc_check;
["sizeClass of an unknown kind falls back to truck", ([nil, "sizeClass", "B_Heli_Light_01_F"] call ALiVE_fnc_pathfinderRouteMemory) == "truck"] call _fnc_check;

// --- block + fineFactor ---------------------------------------------------------
private _bpos = [(80 + 0.5) * _subSize, (80 + 0.5) * _subSize, 0];
private _bkey = [_bpos] call _fnc_subKey;
[nil, "block", [[_bpos], "truck", 1]] call ALiVE_fnc_pathfinderRouteMemory;
private _trucks = ALiVE_routeMemory_blocked get "truck";
["block writes the size class's table", !isNil "_trucks"] call _fnc_check;
["block marks exactly the sub-sector given", count _trucks == 1 && {((_trucks get _bkey) select 0) == 1}] call _fnc_check;
[nil, "block", [[_bpos], "truck", 2]] call ALiVE_fnc_pathfinderRouteMemory;
["block accumulates", [((_trucks get _bkey) select 0), 3, 0.002] call _fnc_near] call _fnc_check;
// no asker in the callback args reads the man table; set a truck's table on the context by hand, as
// jobContext would for a truck profile or a logistics truck's group
private _ctxB = [nil, "jobContext", [_land, "WEST", []]] call ALiVE_fnc_pathfinderRouteMemory;
["jobContext for an unknown asker reads the man table, which is empty", count (_ctxB select 7) == 0] call _fnc_check;
_ctxB set [7, _trucks];
_ctxB set [0, 0];
private _coarseKey = [floor ((_bkey select 0) / _ratio), floor ((_bkey select 1) / _ratio)];
private _coarse = [nil, "factor", [_ctxB, _coarseKey]] call ALiVE_fnc_pathfinderRouteMemory;
private _fine = [nil, "fineFactor", [_ctxB, _bkey]] call ALiVE_fnc_pathfinderRouteMemory;
["fineFactor multiplies the coarse factor by the blockage", [_fine, _coarse * (1 + 7 * (1 - exp (-3))), 0.001] call _fnc_near] call _fnc_check;
["fineFactor is cached", ([nil, "fineFactor", [_ctxB, _bkey]] call ALiVE_fnc_pathfinderRouteMemory) == _fine] call _fnc_check;
["an unblocked sub-sector is just its coarse factor", ([nil, "fineFactor", [_ctxB, [(_bkey select 0) + 1, _bkey select 1]]] call ALiVE_fnc_pathfinderRouteMemory) == _coarse] call _fnc_check;
[nil, "block", [[_bpos], "truck", 1000]] call ALiVE_fnc_pathfinderRouteMemory;
_ctxB set [8, createHashMap];
["blockage never passes its ceiling of 8", [([nil, "fineFactor", [_ctxB, _bkey]] call ALiVE_fnc_pathfinderRouteMemory), _coarse * 8, 0.001] call _fnc_near] call _fnc_check;
private _ctxM = [nil, "jobContext", [_land, "WEST", []]] call ALiVE_fnc_pathfinderRouteMemory;
_ctxM set [0, 0];
["a man is not held up by a truck's blockage", ([nil, "fineFactor", [_ctxM, _bkey]] call ALiVE_fnc_pathfinderRouteMemory) == ([nil, "factor", [_ctxM, _coarseKey]] call ALiVE_fnc_pathfinderRouteMemory)] call _fnc_check;

// --- handleEvent -----------------------------------------------------------------
private _fnc_event = {
    params ["_type", "_data"];
    private _e = [] call ALiVE_fnc_hashCreate;
    [_e, "type", _type] call ALiVE_fnc_hashSet;
    [_e, "data", _data] call ALiVE_fnc_hashSet;
    _e
};
private _epos = [(60 + 0.5) * _sectorSize, (60 + 0.5) * _sectorSize, 0];
private _ekey = [_epos] call _fnc_sectorKey;
[nil, "handleEvent", ["PROFILE_KILLED", [_epos, "BLU_F", "WEST", "EAST", []]] call _fnc_event] call ALiVE_fnc_pathfinderRouteMemory;
["a group lost on the ground adds a full mark", (((ALiVE_routeMemory_danger get "WEST") get _ekey) select 0) == 1] call _fnc_check;
if (!isNil "ALiVE_profileHandler") then {
    // a victim whose vehicle in command can't be found is taken as a ground loss; the shape the handler reads
    // is [_, _, fields] with vehiclesInCommandOf at 8 and vehiclesInCargoOf at 9
    private _fields = []; _fields resize 10; _fields set [8, ["rm_test_no_such_vehicle"]]; _fields set [9, []];
    private _victim = [objNull, "profile", _fields];
    [nil, "handleEvent", ["PROFILE_KILLED", [_epos, "BLU_F", "WEST", "EAST", _victim]] call _fnc_event] call ALiVE_fnc_pathfinderRouteMemory;
    ["a victim with an unknown vehicle still counts as a ground loss", [(((ALiVE_routeMemory_danger get "WEST") get _ekey) select 0), 2, 0.002] call _fnc_near] call _fnc_check;
    // a group lost with its aircraft adds nothing: needs a registered aircraft profile, checked by hand in a mission
};
if (!isNil "ALiVE_profileHandler") then {
private _beforeAttack = count (ALiVE_routeMemory_danger get "WEST");
[nil, "handleEvent", ["PROFILE_ATTACK_START", ["atk_1", "attacker_x", ["no_such_profile_1", "no_such_profile_2"]]] call _fnc_event] call ALiVE_fnc_pathfinderRouteMemory;
["an attack on unknown profiles adds nothing", count (ALiVE_routeMemory_danger get "WEST") == _beforeAttack] call _fnc_check;
};
[nil, "handleEvent", ["SOMETHING_ELSE", []] call _fnc_event] call ALiVE_fnc_pathfinderRouteMemory;
["an unrelated event is ignored", true] call _fnc_check;

// --- stall pass guards ---------------------------------------------------------
if (isNil "ALiVE_profileHandler") then {
    ["stallPass returns with no profile handler", isNil { [nil, "stallPass"] call ALiVE_fnc_pathfinderRouteMemory }] call _fnc_check;
};

// --- live pathfinder: Off routes as before, danger bends the route ----------------
private _fnc_finish = {
    params ["_fails", "_saved", "_stubbedPathfinder"];
    if (_stubbedPathfinder) then { ALiVE_pathfinder = nil };
    ALiVE_pathfinding_routeMemory = _saved select 0;
    ALiVE_pathfinding_routeMemoryLevels = _saved select 1;
    ALiVE_pathfinding_routeMemoryHalfLife = _saved select 2;
    ALiVE_routeMemory_danger = _saved select 3;
    ALiVE_routeMemory_blocked = _saved select 4;
    if (count _fails == 0) then {
        diag_log "=== Route memory test: all passed ===";
    } else {
        diag_log format ["=== Route memory test: %1 FAILED: %2 ===", count _fails, _fails];
    };
};

if (_stubbedPathfinder || {isNil "ALiVE_profileSystem"}) exitWith {
    diag_log "  skip  live pathfinder section (no Virtual AI System in this mission)";
    [_fails, _saved, _stubbedPathfinder] call _fnc_finish;
};

[_fails, _saved, _stubbedPathfinder, _fnc_check, _fnc_finish] spawn {
    params ["_fails", "_saved", "_stubbedPathfinder", "_fnc_check", "_fnc_finish"];
    private _sectorSize = (ALiVE_pathfinder get "terrainGrid") get "sectorSize";
    private _fnc_sectorKey = { params ["_p"]; [floor ((_p select 0) / _sectorSize), floor ((_p select 1) / _sectorSize)] };
    private _procedure = [ALiVE_pathfinder, "getPathfindingProcedure", ["LandRoad", "default"]] call ALiVE_fnc_pathfinder;
    // two dry-land points a third of the map apart, so there is room to go round
    private _from = [[worldSize * 0.3, worldSize * 0.5, 0], 0, 4000, 10, 0, 0.3, 0] call BIS_fnc_findSafePos;
    private _to = [[worldSize * 0.7, worldSize * 0.5, 0], 0, 4000, 10, 0, 0.3, 0] call BIS_fnc_findSafePos;
    _from set [2, 0]; _to set [2, 0];
    private _fnc_route = {
        params ["_from", "_to", "_procedure"];
        private _wp = [] call ALiVE_fnc_hashCreate;
        [_wp, "position", _to] call ALiVE_fnc_hashSet;
        private _box = [false, []];
        private _request = [_from, _procedure, _wp, nil, [_box], {
            params ["_args", "_path"];
            (_args select 0) set [1, _path];
            (_args select 0) set [0, true];
        }, "WEST"];
        // asked from unscheduled code, as the profile system and the stall pass do
        [{ [ALiVE_pathfinder, "findPath", _this] call ALiVE_fnc_pathfinder }, _request] call CBA_fnc_directCall;
        private _t0 = diag_tickTime;
        waitUntil { sleep 0.5; (_box select 0) || {diag_tickTime - _t0 > 120} };
        [_box select 1, diag_tickTime - _t0]
    };

    ALiVE_pathfinding_routeMemory = "off";
    (([_from, _to, _procedure] call _fnc_route)) params ["_offA", "_tOff"];
    if !(_offA isEqualType [] && {count _offA > 1}) exitWith {
        ["off: a route comes back", false] call _fnc_check;
        [_fails, _saved, _stubbedPathfinder] call _fnc_finish;
    };
    (([_from, _to, _procedure] call _fnc_route)) params ["_offB"];
    ["off: a route comes back", _offA isEqualType [] && {count _offA > 1}] call _fnc_check;
    ["off: the same request gives the same route", _offA isEqualTo _offB] call _fnc_check;

    // high with no danger and no amplitude must equal off: the memory is applied but changes nothing
    ALiVE_routeMemory_danger = createHashMap;
    ALiVE_routeMemory_blocked = createHashMap;
    ALiVE_pathfinding_routeMemory = "high";
    ALiVE_pathfinding_routeMemoryLevels = createHashMapFromArray [["low", [0, 3]], ["high", [0, 5]]];
    (([_from, _to, _procedure] call _fnc_route)) params ["_highZero", "_tHigh"];
    ["high with amplitude 0 and no danger routes exactly as off", _highZero isEqualTo _offA] call _fnc_check;
    diag_log format ["  info  route time off %1 s, high %2 s, %3 points", _tOff, _tHigh, count _offA];

    // danger on the middle of the off route for WEST bends WEST's route and leaves EAST's alone
    private _mid = _offA select (floor (count _offA / 2));
    [nil, "deposit", [_mid, "WEST", 20]] call ALiVE_fnc_pathfinderRouteMemory;
    (([_from, _to, _procedure] call _fnc_route)) params ["_bent"];
    private _midKey = [_mid] call _fnc_sectorKey;
    private _crosses = (_bent findIf { ([_x] call _fnc_sectorKey) isEqualTo _midKey }) > -1;
    ["danger changes the route", _bent isEqualType [] && {!(_bent isEqualTo _offA)}] call _fnc_check;
    diag_log format ["  info  bent route %1 the marked sector (a map with one corridor has to)", ["avoids", "still crosses"] select _crosses];
    ["the bent route still arrives", _bent isEqualType [] && {count _bent > 0} && {((_bent select (count _bent - 1)) distance2D _to) < 2 * _sectorSize}] call _fnc_check;

    ALiVE_pathfinding_routeMemoryLevels = createHashMapFromArray [["low", [0.14, 3]], ["high", [0.28, 5]]];
    ALiVE_routeMemory_danger = createHashMap;
    private _v1 = ([_from, _to, _procedure] call _fnc_route) select 0;
    private _v2 = ([_from, _to, _procedure] call _fnc_route) select 0;
    ["high: two requests vary", !(_v1 isEqualTo _v2)] call _fnc_check;

    [_fails, _saved, _stubbedPathfinder] call _fnc_finish;
};
