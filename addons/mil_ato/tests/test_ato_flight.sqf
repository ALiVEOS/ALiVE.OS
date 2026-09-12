#include "\x\alive\addons\mil_ato\script_component.hpp"

SCRIPT(test_ato_flight);

/* ----------------------------------------------------------------------------
The first flight. Machine, Observer, Effector and Surface driven together by a
loop, with NO ALiVE module, no commander, no logistics and no profiles.

Smallest mission: a player on the Stratis airfield. The test creates one
aircraft and one truck 8 km away to fly at, and removes both afterwards.

This is where the seams show. The four pieces have only ever been exercised on
their own, and the loop below is the first thing that asks them to agree: the
state table says what should happen, the observer says what is true, the
effector carries it out, and the surface says where the ground is.

One job here belongs to nobody yet. The table answers in names, "go to the
station and hold", while the effector needs places. Turning one into the other
is the kernel's work and the kernel is not written, so the loop does it in the
open, which is also a fair statement of what the kernel will have to own.
---------------------------------------------------------------------------- */

[] spawn {

    private _fails = [];
    private _checked = 0;
    private _fnc_check = {
        params ["_name", ["_ok", nil, [true]]];
        _checked = _checked + 1;
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

    diag_log "=== ATO flight run (four pieces, no module) ===";

    private _m = [nil, "create"] call ALIVE_fnc_ATOMachine;
    private _o = [nil, "create"] call ALIVE_fnc_ATOObserve;
    private _e = [nil, "create"] call ALIVE_fnc_ATOEffect;
    private _s = [nil, "create"] call ALIVE_fnc_ATOSurface;

    // --- the aircraft and its home -------------------------------------------
    // Anchored on the player when there is one, and on the Agia Marina strip
    // when there is not. A dedicated server has no player, and this test is
    // now run headless on one: the server recompiles every function as the
    // mission loads, so a function edit is picked up by relaunching the
    // server rather than by asking somebody to restart a mission. The fixed
    // position is where the test mission puts the player, so a headless run
    // and a run in front of somebody are measuring the same airfield.
    private _anchor = if (isNull player) then {[1839.76, 5750.47, 0]} else {getPosATL player};
    private _class = "B_Heli_Attack_01_F";
    private _home = [_s, "cascade", ["terrain", _class, _anchor, []]] call ALIVE_fnc_ATOSurface;
    ["a home was found for the aircraft", count _home == 3] call _fnc_check;
    if (count _home != 3) exitWith { diag_log "=== ATO flight run: ABANDONED, no home ===" };

    private _veh = createVehicle [_class, [0,0,300], [], 0, "CAN_COLLIDE"];
    [_s, "place", [_veh, _home]] call ALIVE_fnc_ATOSurface;
    [_e, "apply", ["shield", _veh, _home, ["BLU_F_0"]]] call ALIVE_fnc_ATOEffect;
    sleep 10;

    // Something to fly at, far enough that the trip is a real one.
    private _targetPos = _anchor getPos [8000, 45];
    _targetPos set [2, 0];
    private _truck = createVehicle ["B_Truck_01_transport_F", _targetPos, [], 0, "CAN_COLLIDE"];

    // --- the row --------------------------------------------------------------
    private _row = [_m, "newRow", ["BLU_F_0", _home]] call ALIVE_fnc_ATOMachine;
    // type, target, how long it may take, how close counts as being there.
    //
    // Ninety seconds on station, not the fifteen minutes a real sortie runs.
    // Nothing here destroys the target, so the only thing that ends a station is
    // that clock, and a real duration would have the aircraft circling correctly
    // for a quarter of an hour while this gave up at ten minutes and called it a
    // failure. The point of the run is the whole circuit, not the dwell.
    [_row, "sortie", ["CAS", _targetPos, 90, 400]] call ALIVE_fnc_hashSet;

    // --- turning order names into places --------------------------------------
    // The kernel's job, done here so it is visible.
    private _fnc_resolve = {
        params ["_orders"];
        private _out = [];
        {
            switch (_x) do {
                // Being told to go somewhere is what makes a helicopter lift.
                // "Take off" on its own is not an order the engine understands.
                case "TAKEOFF":       { _out pushBack ["MOVE", (_home select 0) getPos [1200, 45]] };
                case "MOVE_STATION":  { _out pushBack ["MOVE", _targetPos] };
                case "EXECUTE":       { _out pushBack ["SAD", _targetPos] };
                case "MOVE_APPROACH": { _out pushBack ["MOVE", (_home select 0) getPos [800, 0]] };
                case "LOITER":        { _out pushBack ["LOITER", (_home select 0) getPos [600, 90]] };
                // Stay where you are. The table asks for this in ASSIGNED and in
                // RECOVERING, and it went unresolved, so those two states cleared
                // the waypoint list and put nothing back. An aircraft on the ground
                // with a running engine and no waypoints does not sit still, which
                // is why one lifted off a minute after it had landed.
                case "HOLD":          { _out pushBack ["HOLD", getPosATL _veh] };
                default               { };
            };
        } forEach _orders;
        _out
    };

    // --- one tick --------------------------------------------------------------
    private _seen = [];
    private _refusals = [];
    private _applied = [];
    private _ticks = 0;
    private _fnc_tick = {
        params [["_cmd", ""]];

        private _lockHeld = ([_s, "holder", "rwy"] call ALIVE_fnc_ATOSurface) isEqualTo "BLU_F_0";
        private _sortie = [_row, "sortie", []] call ALIVE_fnc_hashGet;
        private _obs = [_o, "observe", [_veh, _home, _lockHeld, _sortie, time]] call ALIVE_fnc_ATOObserve;

        private _out = [_m, "step", [_row, _obs, _cmd, time]] call ALIVE_fnc_ATOMachine;
        _out params ["_newRow", "_orders", "_effects"];
        _row = _newRow;

        private _state = [_row, "state", ""] call ALIVE_fnc_hashGet;
        private _changedState = count _seen == 0 || {!((_seen select (count _seen - 1)) isEqualTo _state)};
        if (_changedState) then {
            _seen pushBack _state;
            diag_log format ["  info  %1  (alt %2 m, fuel %3)", _state,
                round ([_obs,"altAGL",0] call ALIVE_fnc_hashGet),
                ([_obs,"fuel",0] call ALIVE_fnc_hashGet) toFixed 2];
        };

        // Every effect the table asked for, kept for the assertions. A run has
        // already passed every check while the aircraft was put down by the
        // deadline safety net rather than landing, and nothing in the results
        // could tell the difference.
        { _applied pushBack _x } forEach _effects;
        _ticks = _ticks + 1;

        // Effects the table asked for. The extras each one needs are supplied
        // here; the table names the effect and never the arguments.
        {
            private _extra = switch (_x) do {
                case "placeOnSlot":  { [_s] };
                case "forceLanded":  { [_s] };
                // The only thing out there to shoot at.
                case "revealTargets":{ [[_truck]] };
                // Landing needs somewhere to land ON, and giving the pad back
                // needs to know whose it was.
                case "landAtPad":       { [_s, "BLU_F_0"] };
                case "releaseApproach": { [_s, "BLU_F_0"] };
                case "lock":         { [] };
                case "unlock":       { [] };
                default              { [] };
            };
            // The table answers with two kinds of thing in one list: things to
            // do to the aircraft, and things to write down or tell somebody.
            // Only the first kind goes to the effector. Sorting them is the
            // kernel's job, done here in the open because there is no kernel.
            private _bookkeeping = ["assignFailed","markLost","onLost","sortieArrived",
                                    "sortieReturning","sortiePlayerControl",
                                    "refusedTeleportPlayerAboard"];
            switch (true) do {
                case (_x isEqualTo "lock"):   { [_s, "lock",   ["rwy", "BLU_F_0", time + 150]] call ALIVE_fnc_ATOSurface };
                case (_x isEqualTo "unlock"): { [_s, "unlock", "BLU_F_0"] call ALIVE_fnc_ATOSurface };
                case (_x in _bookkeeping):    { };
                default {
                    private _r = [_e, "apply", [_x, _veh, _home, _extra]] call ALIVE_fnc_ATOEffect;
                    if ((_r select 0) isEqualTo "refused") then {
                        _refusals pushBack [_x, _r select 2];
                    };
                    // The approach is the only thing here that takes minutes and
                    // reports its progress in its own answer, and reading that
                    // answer has needed a probe pasted into a live window three
                    // times tonight. Every tenth second is enough to watch it
                    // without burying the log.
                    if (_x isEqualTo "landAtPad" && {_ticks mod 5 == 0}) then {
                        diag_log format ["  info  approach: %1 | alt %2 spd %3 | cmd %4",
                            _r, round ((getPosATL _veh) select 2), round (speed _veh),
                            currentCommand (driver _veh)];
                    };
                };
            };
        } forEach _effects;

        // Orders, resolved and issued.
        //
        // The result is logged on a state change, not just when refused. A run
        // was lost to an aircraft that hovered for five minutes with no orders
        // while the only evidence sat in a variable printed after it was over,
        // and the waypoint list is the thing that says whether an order chain
        // actually reached the group or only appeared to.
        if (count _orders > 0) then {
            private _chain = [_orders] call _fnc_resolve;
            if (count _chain > 0) then {
                private _r = [_e, "apply", ["issueOrders", _veh, _home, [_chain]]] call ALIVE_fnc_ATOEffect;
                if (_changedState) then {
                    private _grp = group (driver _veh);
                    diag_log format ["  info  orders for %1: %2 -> %3 | group now has %4 waypoint(s) %5, on %6",
                        _state, _orders, _r,
                        count (waypoints _grp),
                        (waypoints _grp) apply {waypointType _x},
                        currentWaypoint _grp];
                };
            } else {
                if (_changedState) then {
                    diag_log format ["  info  %1 asked for %2 and the resolver produced nothing", _state, _orders];
                };
            };
        };
        _state
    };

    // --- settle it, then send it -----------------------------------------------
    for "_i" from 1 to 6 do { [] call _fnc_tick; sleep 1 };
    ["the aircraft settles at its stand", ((_seen select (count _seen - 1)) isEqualTo "PARKED")] call _fnc_check;

    ["ASSIGN"] call _fnc_tick;
    sleep 1;
    ["an order to fly is taken up",
        ([_row,"state",""] call ALIVE_fnc_hashGet) isEqualTo "ASSIGNED"] call _fnc_check;

    // --- fly it -----------------------------------------------------------------
    private _t0 = time;
    private _reachedStation = false;
    private _reachedRTB = false;
    // A plain loop rather than waitUntil: sleeping inside a waitUntil condition
    // is not something to rely on, and this has to tick on a steady beat.
    private _done = false;
    while {!_done} do {
        sleep 2;
        private _st = [] call _fnc_tick;
        if (_st isEqualTo "ON_STATION") then { _reachedStation = true };
        if (_reachedStation && {_st isEqualTo "RTB"}) then { _reachedRTB = true };
        if ((_st isEqualTo "PARKED" && {_reachedStation})
            || {_st isEqualTo "LOST"}
            || {time - _t0 > 600}) then { _done = true };
    };

    private _final = [_row,"state",""] call ALIVE_fnc_hashGet;
    diag_log format ["  info  states seen: %1", _seen];
    diag_log format ["  info  finished in %1 s as %2", round (time - _t0), _final];

    ["it left the ground", "LAUNCHING" in _seen] call _fnc_check;
    ["it flew out", "ENROUTE" in _seen] call _fnc_check;
    ["it reached the target", _reachedStation] call _fnc_check;
    ["it came home", _reachedRTB] call _fnc_check;
    ["it ended parked rather than lost or stuck", _final isEqualTo "PARKED"] call _fnc_check;
    ["it was never lost", !("LOST" in _seen)] call _fnc_check;
    ["it is alive at the end", alive _veh] call _fnc_check;
    ["it is back at its stand", [_s, "atHome", [_veh, _home]] call ALIVE_fnc_ATOSurface] call _fnc_check;
    // The one that caught a false pass. Every other check here is satisfied by
    // an aircraft the deadline put on the ground: it ends parked, at its home,
    // alive, with the runway released. Only this says it FLEW the approach.
    ["it landed rather than being put down by the deadline",
        !("forceLanded" in _applied)] call _fnc_check;
    // No assertion on HOW MANY times it was aimed. A landing order is advisory
    // and has to be re-issued while the aircraft is still up, so counting the
    // aims measures the length of the approach rather than its success. That was
    // my mistake, not the module's: the first version of this check failed a run
    // for re-aiming, which is the correct behaviour.
    diag_log format ["  info  aimed at its pad %1 time(s) over the approach",
        {_x isEqualTo "landAtPad"} count _applied];
    ["and the approach was given back afterwards",
        "releaseApproach" in _applied] call _fnc_check;

    ["nothing was refused unexpectedly", count _refusals == 0] call _fnc_check;
    if (count _refusals > 0) then {
        diag_log format ["  info  refusals: %1", _refusals];
    };
    ["the runway was given back",
        ([_s, "holder", "rwy"] call ALIVE_fnc_ATOSurface) isEqualTo ""] call _fnc_check;

    // --- tidy ---------------------------------------------------------------------
    { deleteVehicle _x } forEach (crew _veh);
    deleteVehicle _veh;
    deleteVehicle _truck;

    diag_log format ["  info  %1 assertions", _checked];
    if (count _fails == 0) then {
        diag_log "=== ATO flight run: ALL PASS ===";
    } else {
        diag_log format ["=== ATO flight run: %1 FAILURE(S): %2 ===", count _fails, _fails];
    };
};

"ATO flight run started, results follow in the log (may take several minutes)"
