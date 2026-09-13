#include "\x\alive\addons\mil_ato\script_component.hpp"

SCRIPT(test_ato_machine);

/* ----------------------------------------------------------------------------
Machine test. NO MISSION NEEDED and no aircraft: the machine is pure, so this
runs anywhere, including an empty world with nothing placed. Time is a number
passed in, so deadlines are driven rather than waited for.

Two halves. First an enumeration: every state, against every command, against a
spread of observations, with and without an expired deadline, a player riding
along, and a remote hull. The promises have to hold for all of it, including
inputs the table has never heard of.

Then the incidents that were actually measured in missions, replayed as
observation sequences, because those are what the table exists to prevent.
---------------------------------------------------------------------------- */

// RUNS IN A SPAWNED THREAD. The debug console executes with `call`, which
// is UNSCHEDULED: the whole thing would run inside one frame and the game
// would stop dead until it finished. Fifteen hundred combinations, each
// building three hashes, is far too much to ask of a single frame.
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
        if !(_ok) then {
            _fails pushBack _name;
            diag_log format ["  FAIL  %1", _name];
        };
    };

    diag_log "=== ATO Machine test (pure, no mission) ===";

    private _m = [nil, "create"] call ALIVE_fnc_ATOMachine;
    private _states = [_m, "states"] call ALIVE_fnc_ATOMachine;
    private _rest = [_m, "restStates"] call ALIVE_fnc_ATOMachine;

    ["ten states in the table", count _states == 10] call _fnc_check;
    ["three of them rest", count _rest == 3] call _fnc_check;
    ["every attach starts by looking",
        ([_m, "entryState"] call ALIVE_fnc_ATOMachine) isEqualTo "RECOVERING"] call _fnc_check;

    // An observation set, built from named flags so a case reads as a scenario.
    private _fnc_obs = {
        params ["_flags"];
        private _o = [[
            ["objectLost", false], ["playerControl", false], ["anyPlayerAboard", false],
            ["playerPassenger", false], ["remote", false], ["airborne", false],
            ["atHome", true], ["crewLoss", false], ["crewSeated", false],
            ["lockHeld", false], ["onStation", false], ["landed", false],
            ["targetsGone", false], ["nearHome", false],
            // What kind of aircraft and what kind of home. All false is a
            // helicopter on land, which is what every case here used to be.
            ["deckHome", false], ["fixedWing", false], ["needsRunway", false],
            ["launchInProgress", false], ["onRunway", false],
            ["fuel", 1], ["armed", true], ["ordnance", 8], ["damage", 0],
            ["playersWithin1000Home", 0], ["playersWithin1000Hull", 0]
        ]] call ALIVE_fnc_hashCreate;
        { [_o, _x select 0, _x select 1] call ALIVE_fnc_hashSet } forEach _flags;
        _o
    };

    // ---- the enumeration -----------------------------------------------------
    private _commands = ["", "ASSIGN", "REROUTE", "CANCEL", "RELEASE", "RETIRE", "NONSENSE"];
    private _profiles = [
        ["parked and quiet",      []],
        ["airborne, crew fine",   [["airborne",true],["atHome",false]]],
        ["airborne, crew gone",   [["airborne",true],["atHome",false],["crewLoss",true]]],
        ["hull destroyed",        [["objectLost",true]]],
        ["player flying it",      [["playerControl",true],["anyPlayerAboard",true]]],
        ["player riding along",   [["playerPassenger",true],["anyPlayerAboard",true],["airborne",true],["atHome",false]]],
        ["hull not ours",         [["remote",true]]],
        ["low on fuel airborne",  [["airborne",true],["atHome",false],["fuel",0.05]]],
        ["over the target",       [["airborne",true],["atHome",false],["onStation",true]]],
        ["wheels down",           [["landed",true]]],
        ["people watching",       [["airborne",true],["atHome",false],["playersWithin1000Hull",3],["playersWithin1000Home",3]]],
        // The three kinds of aircraft the table now branches on, so that every
        // state is stepped for each of them rather than only for a helicopter
        // on land. These need no mission, which is why they belong here and not
        // in the carrier scene.
        ["a plane on land",       [["needsRunway",true]]],
        ["a plane on land, up",   [["needsRunway",true],["airborne",true],["atHome",false]]],
        ["a plane on a deck",     [["deckHome",true],["fixedWing",true],["needsRunway",true]]],
        ["a plane on a deck, up", [["deckHome",true],["fixedWing",true],["needsRunway",true],["airborne",true],["atHome",false]]],
        ["a plane mid launch",    [["deckHome",true],["fixedWing",true],["needsRunway",true],["launchInProgress",true],["crewSeated",true],["lockHeld",true]]],
        ["a helicopter on a deck",[["deckHome",true]]],
        ["a VTOL on land",        [["needsRunway",true],["airborne",true],["atHome",false]]],
        ["stopped on the runway",  [["needsRunway",true],["landed",true],["nearHome",true],["atHome",false],["onRunway",true],["playersWithin300",4]]]
    ];

    private _badState = 0;
    private _badDeadline = 0;
    private _badOrders = 0;
    // A count alone says only that something is wrong. This records WHICH
    // combination broke the promise, which is the difference between a red
    // light and a diagnosis.
    private _whyOrders = [];
    private _badLock = 0;
    private _mutated = 0;
    private _combos = 0;

    {
        private _state = _x;
        {
            private _cmd = _x;
            {
                private _profileName = _x select 0;
                private _obs = [_x select 1] call _fnc_obs;
                {
                    private _expired = _x;
                    private _row = [_m, "newRow", ["BLU_F_0", [[100,100,0],0,"terrain"]]] call ALIVE_fnc_ATOMachine;
                    [_row,"state",_state] call ALIVE_fnc_hashSet;
                    [_row,"sortie",["CAS",[0,0,0],600]] call ALIVE_fnc_hashSet;
                    [_row,"deadlineAt", if (_expired) then {50} else {9999}] call ALIVE_fnc_hashSet;

                    private _before = [_row] call ALIVE_fnc_hashCopy;
                    private _out = [_m, "step", [_row, _obs, _cmd, 100]] call ALIVE_fnc_ATOMachine;
                    _combos = _combos + 1;

                    _out params ["_row2", "_orders", "_effects"];
                    private _next = [_row2,"state",""] call ALIVE_fnc_hashGet;

                    // Promise: whatever went in, what comes out is a real state.
                    if !(_next in _states) then { _badState = _badState + 1 };

                    // Promise: nothing that is not resting may sit without a deadline.
                    private _dl = [_row2,"deadlineAt",0] call ALIVE_fnc_hashGet;
                    if (!(_next in _rest) && {_dl <= 0}) then { _badDeadline = _badDeadline + 1 };
                    if ((_next in _rest) && {_dl != 0}) then { _badDeadline = _badDeadline + 1 };

                    // Promise: an aircraft that is not resting always has
                    // orders, EXCEPT while it is landing.
                    //
                    // Landing cannot be expressed as an order, because the
                    // engine has no landing waypoint type: setWaypointType
                    // "LAND" is accepted and silently does nothing, leaving a
                    // waypoint with no type, which is no order at all. So
                    // LANDING issues none and carries the landing out as an
                    // effect. The promise below holds it to that, and this one
                    // stops asking it for the impossible.
                    if (!(_next in ["LOST","PLAYER_FLOWN","PARKED","LANDING"]) && {count _orders == 0}) then {
                        _badOrders = _badOrders + 1;
                        if (count _whyOrders < 6) then {
                            _whyOrders pushBack format ["%1 +%2 (%3%4) -> %5, no orders, effects %6",
                                _state, _cmd, _profileName,
                                if (_expired) then {", expired"} else {""},
                                _next, _effects];
                        };
                    };
                    // Promise: landing issues no orders, and while the aircraft
                    // is still up it always asks for the approach. A run was
                    // lost to an aircraft sitting in this state with neither,
                    // hovering for five minutes until a deadline put it down.
                    //
                    // Only when it was ALREADY landing: the step that merely
                    // arrives in the state emits nothing on entry, by design.
                    if ((_state isEqualTo "LANDING") && {_next isEqualTo "LANDING"}) then {
                        if (count _orders > 0) then {
                            _badOrders = _badOrders + 1;
                            if (count _whyOrders < 6) then {
                                _whyOrders pushBack format ["LANDING +%1 (%2) issued orders %3",
                                    _cmd, _profileName, _orders];
                            };
                        };
                        // Not for a hull this machine does not own: every
                        // effect but taking ownership is stripped for those,
                        // deliberately, because nothing local may be done to
                        // one. Asking for the approach there would be asking
                        // the table to break its own rule.
                        if (!([_obs,"landed",false] call ALIVE_fnc_hashGet)
                            && {!([_obs,"remote",false] call ALIVE_fnc_hashGet)}
                            && {!("landAtPad" in _effects)}
                            && {!("landOnRunway" in _effects)}
                            && {!("deckRecover" in _effects)}) then {
                            _badOrders = _badOrders + 1;
                            if (count _whyOrders < 6) then {
                                _whyOrders pushBack format ["LANDING +%1 (%2%3) up and never asked for ANY of the three approaches, effects %4",
                                    _cmd, _profileName,
                                    if (_expired) then {", expired"} else {""},
                                    _effects];
                            };
                        };
                    };
                    // Promise: a player flying it is given nothing.
                    if ((_next isEqualTo "PLAYER_FLOWN") && {count _orders > 0}) then {
                        _badOrders = _badOrders + 1;
                    };

                    // Promise: the runway is asked for only when leaving and when
                    // coming back to land. Anywhere else means something is
                    // holding a runway it has no use for.
                    if (("lock" in _effects) && {!(_next in ["ASSIGNED","RTB"])}) then {
                        _badLock = _badLock + 1;
                    };

                    // Promise: a player in the aircraft is never teleported.
                    if (("playerPassenger" call {[_obs,_this,false] call ALIVE_fnc_hashGet})
                        && {({_x in ["airborneStart","forceLaunch","placeOnSlot","forceLanded","quickPark"]} count _effects) > 0}) then {
                        _badLock = _badLock + 1;
                    };

                    // Promise: the row handed in is not the row handed back.
                    if !(([_before,"state",""] call ALIVE_fnc_hashGet) isEqualTo ([_row,"state",""] call ALIVE_fnc_hashGet)) then {
                        _mutated = _mutated + 1;
                    };
                    // Yield often enough that the frame never stalls.
                if (_combos mod 100 == 0) then { sleep 0.01 };
            } forEach [true, false];
            } forEach _profiles;
        } forEach _commands;
    } forEach _states;

    diag_log format ["  info  enumerated %1 combinations", _combos];
    ["every input lands on a state in the table", _badState == 0] call _fnc_check;
    ["only resting states have no deadline", _badDeadline == 0] call _fnc_check;
    { diag_log format ["  info  orders promise broken by: %1", _x] } forEach _whyOrders;
    ["every flying state carries orders", _badOrders == 0] call _fnc_check;
    ["the runway is only taken leaving or landing, and a player is never teleported", _badLock == 0] call _fnc_check;
    ["step never edits the row it was given", _mutated == 0] call _fnc_check;

    // ---- the measured incidents, replayed ------------------------------------

    private _fnc_step = {
        params ["_row", "_flags", "_cmd", "_now"];
        [_m, "step", [_row, [_flags] call _fnc_obs, _cmd, _now]] call ALIVE_fnc_ATOMachine
    };

    // Airframe alive, crew group null, flying at 158 km/h. The old machine had no
    // case for it and the aircraft hit the ground four seconds later.
    private _r = [_m, "newRow", ["BLU_F_1", [[100,100,0],0,"terrain"]]] call ALIVE_fnc_ATOMachine;
    [_r,"state","ENROUTE"] call ALIVE_fnc_hashSet;
    [_r,"deadlineAt",9999] call ALIVE_fnc_hashSet;
    ([_r, [["airborne",true],["atHome",false],["crewLoss",true]], "", 100] call _fnc_step) params ["_r1","_o1","_e1"];
    ["a crewless airframe in the air recovers",
        ([_r1,"state",""] call ALIVE_fnc_hashGet) isEqualTo "RECOVERING"] call _fnc_check;

    ([_r1, [["airborne",true],["atHome",false],["crewLoss",true]], "", 110] call _fnc_step) params ["_r2","_o2","_e2"];
    ["and it is re-crewed rather than left", "recrewInPlace" in _e2] call _fnc_check;

    // The hull is deleted underneath the module mid-sortie.
    private _r3 = [_m, "newRow", ["BLU_F_2", [[100,100,0],0,"terrain"]]] call ALIVE_fnc_ATOMachine;
    [_r3,"state","ON_STATION"] call ALIVE_fnc_hashSet;
    ([_r3, [["objectLost",true]], "", 100] call _fnc_step) params ["_r4","_o4","_e4"];
    ["a deleted hull is lost within one tick",
        ([_r4,"state",""] call ALIVE_fnc_hashGet) isEqualTo "LOST"] call _fnc_check;
    ["and it is written off exactly once", ({_x isEqualTo "markLost"} count _e4) == 1] call _fnc_check;
    ["and it stops holding the runway", "unlock" in _e4] call _fnc_check;

    // A player bails out of an aircraft in flight.
    private _r5 = [_m, "newRow", ["BLU_F_3", [[100,100,0],0,"terrain"]]] call ALIVE_fnc_ATOMachine;
    [_r5,"state","PLAYER_FLOWN"] call ALIVE_fnc_hashSet;
    ([_r5, [["airborne",true],["atHome",false]], "", 100] call _fnc_step) params ["_r6","_o6","_e6"];
    ["a player leaving an airborne hull recovers it the same tick",
        ([_r6,"state",""] call ALIVE_fnc_hashGet) isEqualTo "RECOVERING"] call _fnc_check;

    // A player who climbs out on the ground is given time to come back.
    private _r7 = [_m, "newRow", ["BLU_F_4", [[100,100,0],0,"terrain"]]] call ALIVE_fnc_ATOMachine;
    [_r7,"state","PLAYER_FLOWN"] call ALIVE_fnc_hashSet;
    ([_r7, [["atHome",true]], "", 100] call _fnc_step) params ["_r8","_o8","_e8"];
    ["a player stepping out on the ground does not lose the aircraft",
        ([_r8,"state",""] call ALIVE_fnc_hashGet) isEqualTo "PLAYER_FLOWN"] call _fnc_check;
    ([_r8, [["atHome",true]], "", 100 + 400] call _fnc_step) params ["_r9","_o9","_e9"];
    ["but it is taken back once they have plainly gone",
        ([_r9,"state",""] call ALIVE_fnc_hashGet) isEqualTo "PARKED"] call _fnc_check;

    // A player boards during launch: the machine lets go of everything.
    private _r10 = [_m, "newRow", ["BLU_F_5", [[100,100,0],0,"terrain"]]] call ALIVE_fnc_ATOMachine;
    [_r10,"state","LAUNCHING"] call ALIVE_fnc_hashSet;
    ([_r10, [["playerControl",true],["anyPlayerAboard",true]], "", 100] call _fnc_step) params ["_r11","_o11","_e11"];
    ["a player taking an aircraft mid-launch is handed it",
        ([_r11,"state",""] call ALIVE_fnc_hashGet) isEqualTo "PLAYER_FLOWN"] call _fnc_check;
    ["and the runway is given back", "unlock" in _e11] call _fnc_check;
    ["and it is told to do nothing at all", count _o11 == 0] call _fnc_check;

    // Coming home with nobody watching: park it, do not fly an approach.
    private _r12 = [_m, "newRow", ["BLU_F_6", [[100,100,0],0,"terrain"]]] call ALIVE_fnc_ATOMachine;
    [_r12,"state","RTB"] call ALIVE_fnc_hashSet;
    [_r12,"deadlineAt",9999] call ALIVE_fnc_hashSet;
    ([_r12, [["airborne",true],["atHome",false]], "", 100] call _fnc_step) params ["_r13","_o13","_e13"];
    ["with nobody near home it is simply put on its slot",
        ([_r13,"state",""] call ALIVE_fnc_hashGet) isEqualTo "PARKED" && {"placeOnSlot" in _e13}] call _fnc_check;
    ["and no runway is taken to do it", !("lock" in _e13)] call _fnc_check;

    // The same, but with a player riding along: it must not be teleported.
    private _r14 = [_m, "newRow", ["BLU_F_7", [[100,100,0],0,"terrain"]]] call ALIVE_fnc_ATOMachine;
    [_r14,"state","RTB"] call ALIVE_fnc_hashSet;
    [_r14,"deadlineAt",9999] call ALIVE_fnc_hashSet;
    ([_r14, [["airborne",true],["atHome",false],["playerPassenger",true],["anyPlayerAboard",true]], "", 100] call _fnc_step) params ["_r15","_o15","_e15"];
    ["a passenger stops the aircraft being put on its slot", !("placeOnSlot" in _e15)] call _fnc_check;
    ["and it keeps flying with orders", count _o15 > 0] call _fnc_check;

    // A hull this machine does not own: nothing local may be done to it.
    private _r16 = [_m, "newRow", ["BLU_F_8", [[100,100,0],0,"terrain"]]] call ALIVE_fnc_ATOMachine;
    [_r16,"state","RECOVERING"] call ALIVE_fnc_hashSet;
    ([_r16, [["remote",true]], "", 100] call _fnc_step) params ["_r17","_o17","_e17"];
    ["a hull owned elsewhere is claimed first", "takeOwnership" in _e17] call _fnc_check;
    ["and nothing else is done to it", ({!(_x in ["takeOwnership","unlock"])} count _e17) == 0] call _fnc_check;

    // An aircraft with an unknown state is recovered, not abandoned.
    private _r18 = [_m, "newRow", ["BLU_F_9", [[100,100,0],0,"terrain"]]] call ALIVE_fnc_ATOMachine;
    [_r18,"state","SOMETHING_NOBODY_WROTE"] call ALIVE_fnc_hashSet;
    ([_r18, [["airborne",true],["atHome",false]], "", 100] call _fnc_step) params ["_r19","_o19","_e19"];
    ["an unknown state is recovered from, not ignored",
        ([_r19,"state",""] call ALIVE_fnc_hashGet) in _states] call _fnc_check;
    // It may legitimately be put straight back on its slot, and a parked aircraft
    // has nothing to fly. What matters is that it is never left flying with no
    // orders: either it is resting, or it has something to do.
    ["and it is never left flying with nothing to do",
        (([_r19,"state",""] call ALIVE_fnc_hashGet) in _rest) || {count _o19 > 0}] call _fnc_check;

    // ---- result --------------------------------------------------------------
    diag_log format ["  info  %1 assertions", _checked];
    // ---- an aircraft stopped where others need to be ----------------------
    // Moved off, whoever is watching. An aircraft that has stopped on a runway
    // or a taxiway blocks every aircraft behind it, and waiting for nobody to
    // be within three hundred metres of a working airfield is waiting for
    // something that does not happen.
    private _fnc_landedAt = {
        params ["_flags"];
        private _row = [_m, "newRow", ["BLU_F_0", [[100,100,0], 0, "terrain"]]] call ALIVE_fnc_ATOMachine;
        [_row, "state", "LANDING"] call ALIVE_fnc_hashSet;
        [_row, "enteredAt", 900] call ALIVE_fnc_hashSet;
        [_row, "deadlineAt", 9999] call ALIVE_fnc_hashSet;
        private _base = [["landed", true], ["nearHome", true], ["atHome", false]];
        ([_m, "step", [_row, [_base + _flags] call _fnc_obs, "", 1000]] call ALIVE_fnc_ATOMachine)
    };

    (([[["onRunway", true], ["playersWithin300", 4]]] call _fnc_landedAt)) params ["_rwRow", "_rwOrd", "_rwEff"];
    diag_log format ["  info  stopped on the runway with people watching went to %1, effects %2",
        [_rwRow, "state", ""] call ALIVE_fnc_hashGet, _rwEff];
    ["an aircraft stopped on the runway is moved off it even with people watching",
        "placeOnSlot" in _rwEff] call _fnc_check;

    (([[["onRunway", false], ["playersWithin300", 4]]] call _fnc_landedAt)) params ["_offRow", "_offOrd", "_offEff"];
    ["but one stopped clear of it with people watching is left alone",
        !("placeOnSlot" in _offEff)] call _fnc_check;

    (([[["onRunway", false], ["playersWithin300", 0]]] call _fnc_landedAt)) params ["_qRow", "_qOrd", "_qEff"];
    ["and one stopped clear of it with nobody about is tidied as before",
        "placeOnSlot" in _qEff] call _fnc_check;

    // ---- a sortie that reaches its station and never prosecutes ------------
    // Brought home early, so the aircraft is available again instead of
    // holding over a target it is not attacking until its clock runs out.
    private _fnc_onStation = {
        params ["_type", "_ammoNow", "_since"];
        private _row = [_m, "newRow", ["BLU_F_0", [[100,100,0], 0, "terrain"]]] call ALIVE_fnc_ATOMachine;
        [_row, "state", "ON_STATION"] call ALIVE_fnc_hashSet;
        [_row, "enteredAt", 1000 - _since] call ALIVE_fnc_hashSet;
        [_row, "deadlineAt", 9999] call ALIVE_fnc_hashSet;
        // A sortie of this type, six hundred seconds long.
        [_row, "sortie", [_type, [100,100,0], 600, 2000, "s1", [], ""]] call ALIVE_fnc_hashSet;
        [_row, "ordnanceAt", 8] call ALIVE_fnc_hashSet;
        private _obs = [[["airborne", true], ["atHome", false], ["onStation", true],
            ["ordnance", _ammoNow]]] call _fnc_obs;
        ([_m, "step", [_row, _obs, "", 1000]] call ALIVE_fnc_ATOMachine) select 0
    };

    private _stalledRow = ["Strike", 8, 500] call _fnc_onStation;
    diag_log format ["  info  a strike that fired nothing for 500 s of 600 went to %1",
        [_stalledRow, "state", ""] call ALIVE_fnc_hashGet];
    ["a strike sortie that never fires is brought home",
        ([_stalledRow, "state", ""] call ALIVE_fnc_hashGet) isEqualTo "RTB"] call _fnc_check;

    private _firedRow = ["Strike", 3, 500] call _fnc_onStation;
    ["but one that has been firing is left to it",
        ([_firedRow, "state", ""] call ALIVE_fnc_hashGet) isEqualTo "ON_STATION"] call _fnc_check;

    private _earlyRow = ["Strike", 8, 60] call _fnc_onStation;
    ["and one that has only just arrived is given time",
        ([_earlyRow, "state", ""] call ALIVE_fnc_hashGet) isEqualTo "ON_STATION"] call _fnc_check;

    // The one that matters. A patrol does its job by being there, so firing
    // nothing is the expected outcome and bringing it home would be the fault
    // rather than the fix.
    private _capRow = ["CAP", 8, 500] call _fnc_onStation;
    diag_log format ["  info  a patrol that fired nothing for 500 s of 600 stayed %1",
        [_capRow, "state", ""] call ALIVE_fnc_hashGet];
    ["a patrol that fires nothing is NOT brought home",
        ([_capRow, "state", ""] call ALIVE_fnc_hashGet) isEqualTo "ON_STATION"] call _fnc_check;
    private _recceRow = ["Recce", 8, 500] call _fnc_onStation;
    ["and neither is a reconnaissance sortie",
        ([_recceRow, "state", ""] call ALIVE_fnc_hashGet) isEqualTo "ON_STATION"] call _fnc_check;

    // ---- out of ordnance, and never had any -------------------------------
    // These two look identical in the reading and must not be treated alike.
    // An armed aircraft with nothing left comes home; a transport or a scout
    // carries nothing on a full load and has to be allowed to stay.
    private _fnc_dry = {
        params ["_armed", "_rounds"];
        private _row = [_m, "newRow", ["BLU_F_0", [[100,100,0], 0, "terrain"]]] call ALIVE_fnc_ATOMachine;
        [_row, "state", "ON_STATION"] call ALIVE_fnc_hashSet;
        [_row, "enteredAt", 990] call ALIVE_fnc_hashSet;
        [_row, "deadlineAt", 9999] call ALIVE_fnc_hashSet;
        [_row, "sortie", ["CAS", [100,100,0], 600, 2000, "s1", [], ""]] call ALIVE_fnc_hashSet;
        // Arrived with nothing recorded, so the stall test cannot fire and
        // only the ordnance test can be what moves it.
        [_row, "ordnanceAt", -1] call ALIVE_fnc_hashSet;
        private _obs = [[["airborne", true], ["atHome", false], ["onStation", true],
            ["armed", _armed], ["ordnance", _rounds]]] call _fnc_obs;
        private _out = [_m, "step", [_row, _obs, "", 1000]] call ALIVE_fnc_ATOMachine;
        [([(_out select 0), "state", ""] call ALIVE_fnc_hashGet),
         ([(_out select 0), "reason", ""] call ALIVE_fnc_hashGet)]
    };

    ([true, 0] call _fnc_dry) params ["_dryState", "_dryReason"];
    ["an armed aircraft out of ordnance comes home",
        _dryState isEqualTo "RTB" && {_dryReason isEqualTo "RETURN_AMMO"}] call _fnc_check;
    ["an unarmed aircraft carrying none is left on station",
        (([false, 0] call _fnc_dry) select 0) isEqualTo "ON_STATION"] call _fnc_check;
    ["and an armed one with rounds left is left on station",
        (([true, 6] call _fnc_dry) select 0) isEqualTo "ON_STATION"] call _fnc_check;

    if (count _fails == 0) then {
        diag_log "=== ATO Machine test: ALL PASS ===";
    } else {
        diag_log format ["=== ATO Machine test: %1 FAILURE(S): %2 ===", count _fails, _fails];
    };
};

"ATO Machine test started, results follow in the log"
