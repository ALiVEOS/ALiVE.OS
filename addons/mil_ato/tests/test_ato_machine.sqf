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
            ["playersWithin1000Home", 0], ["playersWithin1000Hull", 0], ["onTaxiway", false], ["nearStand", false],
            ["lockBusy", false],
            // Near home unless a case says otherwise, so a landing's extension
            // turns on how it is flying, as it did before distance counted.
            ["distHome", 1000]
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
        ["a plane on land",       [["needsRunway",true],["fixedWing",true]]],
        ["a plane on land, up",   [["needsRunway",true],["fixedWing",true],["airborne",true],["atHome",false]]],
        ["a plane on a deck",     [["deckHome",true],["fixedWing",true],["needsRunway",true]]],
        ["a plane on a deck, up", [["deckHome",true],["fixedWing",true],["needsRunway",true],["airborne",true],["atHome",false]]],
        ["a plane mid launch",    [["deckHome",true],["fixedWing",true],["needsRunway",true],["launchInProgress",true],["crewSeated",true],["lockHeld",true]]],
        ["a helicopter on a deck",[["deckHome",true]]],
        ["a VTOL on land",        [["airborne",true],["atHome",false]]],
        ["stopped on the runway",  [["needsRunway",true],["fixedWing",true],["landed",true],["nearHome",true],["atHome",false],["onRunway",true],["playersWithin1000Hull",4]]],
        ["a plane taxiing off",    [["needsRunway",true],["fixedWing",true],["landed",true],["touchingGround",true],["speed",20],["nearHome",true],["atHome",false],["playersWithin1000Hull",4]]],
        ["stopped on a taxiway",   [["needsRunway",true],["fixedWing",true],["landed",true],["nearHome",true],["atHome",false],["onTaxiway",true],["playersWithin1000Hull",4]]],
        ["broken on the ground",   [["canMove",false]]],
        ["a plane waiting on a busy runway", [["needsRunway",true],["fixedWing",true],["crewSeated",true],["lockBusy",true]]],
        ["an empty tank",          [["canMove",false],["fuel",0]]],
        // A plane on land through its launch: cleared to go, held on its stand
        // with its tank empty, stood on its route, rolling down the runway, and
        // with somebody riding in it.
        ["a plane on land, cleared",   [["needsRunway",true],["fixedWing",true],["crewSeated",true],["lockHeld",true]]],
        ["a plane held on its stand",  [["needsRunway",true],["fixedWing",true],["crewSeated",true],["lockHeld",true],["heldOnStand",true],["canMove",false],["fuel",0]]],
        ["a plane on its taxi route",  [["needsRunway",true],["fixedWing",true],["crewSeated",true],["taxiOutAt",1e6]]],
        ["a plane rolling for take-off", [["needsRunway",true],["fixedWing",true],["crewSeated",true],["taxiOutAt",1e6],["onRunway",true],["speed",60]]],
        ["a plane on land, player riding", [["needsRunway",true],["fixedWing",true],["crewSeated",true],["lockHeld",true],["playerPassenger",true],["anyPlayerAboard",true]]]
    ];

    private _badState = 0;
    private _badDeadline = 0;
    private _badOrders = 0;
    // A count alone says only that something is wrong. This records WHICH
    // combination broke the promise, which is the difference between a red
    // light and a diagnosis.
    private _whyOrders = [];
    private _badLock = 0;
    private _badAir = 0;
    private _whyAir = [];
    private _badHold = 0;
    private _whyHold = [];
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
                        // Nor for a plane already down and rolling, which is
                        // taxiing off and must not be sent round again.
                        if (!([_obs,"landed",false] call ALIVE_fnc_hashGet)
                            && {!([_obs,"remote",false] call ALIVE_fnc_hashGet)}
                            && {!([_obs,"touchingGround",false] call ALIVE_fnc_hashGet)}
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
                    // holding a runway it has no use for. A plane launching from
                    // land keeps it while it goes, so a landing cannot be let in
                    // on top of a take-off run.
                    if (("lock" in _effects) && {!(_next in ["ASSIGNED","LAUNCHING","RTB"])}) then {
                        _badLock = _badLock + 1;
                    };

                    // Promise: a player in the aircraft is never teleported.
                    if (("playerPassenger" call {[_obs,_this,false] call ALIVE_fnc_hashGet})
                        && {({_x in ["airborneStart","forceLaunch","taxiOut","placeOnSlot","forceLanded","quickPark"]} count _effects) > 0}) then {
                        _badLock = _badLock + 1;
                    };

                    // Promise: an aircraft in the air is never stood down and
                    // never has its engine switched off, unless the same step
                    // first puts it on the ground. A gunship that lifted off
                    // while it waited for the runway was parked at 199 m, and
                    // parking took its crew and stopped its engine up there.
                    if ([_obs,"airborne",false] call ALIVE_fnc_hashGet) then {
                        private _grounded = 1e9;
                        {
                            private _at = _effects find _x;
                            if (_at > -1 && {_at < _grounded}) then { _grounded = _at };
                        } forEach ["placeOnSlot","forceLanded"];
                        {
                            private _at = _effects find _x;
                            if (_at > -1 && {_at < _grounded}) then {
                                _badAir = _badAir + 1;
                                if (count _whyAir < 6) then {
                                    _whyAir pushBack format ["%1 +%2 (%3%4) -> %5, effects %6",
                                        _state, _cmd, _profileName,
                                        if (_expired) then {", expired"} else {""}, _next, _effects];
                                };
                            };
                        } forEach ["standDownCrew","engineOff"];
                    };

                    // Promise: nothing leaves the wait for the runway without
                    // giving back the fuel the wait held, whichever way it
                    // leaves, the hull's owner included. A plane on land going on
                    // to launch keeps its hold until it stands on its taxi route,
                    // so for it the same promise is made of every way out of
                    // LAUNCHING instead.
                    private _landPlaneP = ([_obs,"fixedWing",false] call ALIVE_fnc_hashGet)
                        && {!([_obs,"deckHome",false] call ALIVE_fnc_hashGet)}
                        && {!([_obs,"virtualHome",false] call ALIVE_fnc_hashGet)}
                        && {!([_obs,"playerPassenger",false] call ALIVE_fnc_hashGet)};
                    private _keptHeld = (_state isEqualTo "ASSIGNED") && {_next isEqualTo "LAUNCHING"} && {_landPlaneP};
                    if ((_state in ["ASSIGNED","LAUNCHING"]) && {!(_next isEqualTo _state)} && {!_keptHeld} && {!("releaseHold" in _effects)}) then {
                        _badHold = _badHold + 1;
                        if (count _whyHold < 6) then {
                            _whyHold pushBack format ["%1 +%2 (%3%4) -> %5, effects %6",
                                _state, _cmd, _profileName, if (_expired) then {", expired"} else {""}, _next, _effects];
                        };
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
    { diag_log format ["  info  in-the-air promise broken by: %1", _x] } forEach _whyAir;
    ["an aircraft in the air keeps its crew and its engine", _badAir == 0] call _fnc_check;
    { diag_log format ["  info  fuel-back promise broken by: %1", _x] } forEach _whyHold;
    ["every way out of the wait for the runway, or of a launch held for its taxi route, gives the fuel back", _badHold == 0] call _fnc_check;
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

    (([[["onRunway", true], ["playersWithin1000Hull", 4]]] call _fnc_landedAt)) params ["_rwRow", "_rwOrd", "_rwEff"];
    diag_log format ["  info  just stopped on the runway with people watching went to %1, effects %2",
        [_rwRow, "state", ""] call ALIVE_fnc_hashGet, _rwEff];
    ["an aircraft that has just stopped on the runway is given time to be seen to land",
        (([_rwRow, "state", ""] call ALIVE_fnc_hashGet) isEqualTo "LANDING") && {!("placeOnSlot" in _rwEff)}] call _fnc_check;
    private _rwOut2 = [_m, "step", [_rwRow, [[["landed", true], ["nearHome", true], ["atHome", false],
        ["onRunway", true], ["playersWithin1000Hull", 4]]] call _fnc_obs, "", 1031]] call ALIVE_fnc_ATOMachine;
    ["and is moved off it after thirty seconds, even with people watching",
        "placeOnSlot" in (_rwOut2 select 2)] call _fnc_check;

    // ---- a plane that has landed taxis off first ----------------------------
    // It has come home when it reaches the end of the taxi-off route. Measured,
    // a jet never stops on the way: it taxied to the end and flew again.
    private _fnc_rolling = {
        params ["_flags"];
        private _row = [_m, "newRow", ["BLU_F_0", [[100,100,0], 0, "terrain"]]] call ALIVE_fnc_ATOMachine;
        [_row, "state", "LANDING"] call ALIVE_fnc_hashSet;
        [_row, "enteredAt", 900] call ALIVE_fnc_hashSet;
        [_row, "deadlineAt", 9999] call ALIVE_fnc_hashSet;
        private _obs = [[["touchingGround", true], ["altAGL", 0], ["landed", false], ["nearHome", true],
            ["atHome", false], ["fixedWing", true], ["needsRunway", true], ["playersWithin1000Hull", 4]] + _flags] call _fnc_obs;
        private _out = [_m, "step", [_row, _obs, "", 1000]] call ALIVE_fnc_ATOMachine;
        [([(_out select 0), "state", ""] call ALIVE_fnc_hashGet), _out select 2]
    };
    ([[]] call _fnc_rolling) params ["_rlState", "_rlEff"];
    ["a jet rolling out after it lands is left to taxi off, and not sent round again",
        _rlState isEqualTo "LANDING" && {!("landOnRunway" in _rlEff)} && {!("placeOnSlot" in _rlEff)}] call _fnc_check;
    ([[["atTaxiOffEnd", true]]] call _fnc_rolling) params ["_teState", "_teEff"];
    ["at the end of the taxi-off route it is put on its stand, whoever is watching",
        _teState isEqualTo "PARKED" && {"placeOnSlot" in _teEff} && {"turnaround" in _teEff}] call _fnc_check;
    ([[["atTaxiOffEnd", true], ["playerPassenger", true], ["anyPlayerAboard", true]]] call _fnc_rolling) params ["_tpState", "_tpEff"];
    ["but never with a player aboard: held where it is instead",
        _tpState isEqualTo "RECOVERING" && {!("placeOnSlot" in _tpEff)}] call _fnc_check;
    ([[["touchingGround", false], ["altAGL", 150], ["airborne", true]]] call _fnc_rolling) params ["_raState", "_raEff"];
    ["one still in the air is aimed at the runway as before",
        _raState isEqualTo "LANDING" && {"landOnRunway" in _raEff}] call _fnc_check;

    (([[["onRunway", false], ["playersWithin1000Hull", 4]]] call _fnc_landedAt)) params ["_offRow", "_offOrd", "_offEff"];
    ["but one stopped clear of it with people watching is left alone",
        !("placeOnSlot" in _offEff)] call _fnc_check;

    (([[["onRunway", false], ["playersWithin1000Hull", 0]]] call _fnc_landedAt)) params ["_qRow", "_qOrd", "_qEff"];
    ["and one stopped clear of it with nobody about is tidied as before",
        "placeOnSlot" in _qEff] call _fnc_check;

    // ---- a plane taxiing off, as the observer really reports it -------------
    // For a plane, landed means under forty km/h on the ground, which is true
    // for the whole taxi. So a jet taxiing off at twenty reads landed, and the
    // cases above that only set rolling out fast would never have caught one.
    private _fnc_landingRow = {
        private _row = [_m, "newRow", ["BLU_F_0", [[100,100,0], 0, "terrain"]]] call ALIVE_fnc_ATOMachine;
        [_row, "state", "LANDING"] call ALIVE_fnc_hashSet;
        [_row, "enteredAt", 900] call ALIVE_fnc_hashSet;
        [_row, "deadlineAt", 9999] call ALIVE_fnc_hashSet;
        _row
    };
    private _fnc_taxi = {
        params ["_row", "_flags", "_now"];
        private _obs = [[["touchingGround", true], ["altAGL", 0], ["landed", true], ["speed", 20],
            ["nearHome", true], ["atHome", false], ["fixedWing", true], ["needsRunway", true],
            ["playersWithin1000Hull", 4]] + _flags] call _fnc_obs;
        private _out = [_m, "step", [_row, _obs, "", _now]] call ALIVE_fnc_ATOMachine;
        [_out select 0, [(_out select 0), "state", ""] call ALIVE_fnc_hashGet, _out select 2]
    };
    ([call _fnc_landingRow, [], 1000] call _fnc_taxi) params ["_txRow", "_txState", "_txEff"];
    ["a jet taxiing off at twenty km/h is left to taxi while people watch",
        _txState isEqualTo "LANDING" && {!("placeOnSlot" in _txEff)} && {!("landOnRunway" in _txEff)}] call _fnc_check;
    ([call _fnc_landingRow, [["playersWithin1000Hull", 0]], 1000] call _fnc_taxi) params ["_tqRow", "_tqState", "_tqEff"];
    ["with nobody about it is put away at once, as a landing always was",
        _tqState isEqualTo "PARKED" && {"placeOnSlot" in _tqEff}] call _fnc_check;
    ([call _fnc_landingRow, [["atTaxiOffEnd", true]], 1000] call _fnc_taxi) params ["_tzRow", "_tzState", "_tzEff"];
    ["at the end of the taxi-off route it is put on its stand while still moving",
        _tzState isEqualTo "PARKED" && {"placeOnSlot" in _tzEff} && {"turnaround" in _tzEff}] call _fnc_check;
    private _lateRow = call _fnc_landingRow;
    [_lateRow, "deadlineAt", 950] call ALIVE_fnc_hashSet;
    ([_lateRow, [], 1000] call _fnc_taxi) params ["_tlRow", "_tlState", "_tlEff"];
    ["one still taxiing when its time runs out is put away rather than left to fly again",
        _tlState isEqualTo "PARKED" && {"placeOnSlot" in _tlEff}] call _fnc_check;

    // Stopped on its way off: it may only be pausing.
    ([call _fnc_landingRow, [["speed", 0]], 1000] call _fnc_taxi) params ["_ps1", "_psState1", "_psEff1"];
    ["a jet that stops on its way off with people watching is waited for",
        _psState1 isEqualTo "LANDING" && {!("placeOnSlot" in _psEff1)}] call _fnc_check;
    ([_ps1, [], 1015] call _fnc_taxi) params ["_ps2", "_psState2", "_psEff2"];
    ([_ps2, [["speed", 0]], 1035] call _fnc_taxi) params ["_ps3", "_psState3", "_psEff3"];
    ["and the wait starts over when it moves on",
        _psState2 isEqualTo "LANDING" && {_psState3 isEqualTo "LANDING"}] call _fnc_check;
    ([_ps3, [["speed", 0]], 1066] call _fnc_taxi) params ["_ps4", "_psState4", "_psEff4"];
    ["but after thirty seconds at rest clear of the runway and the taxiways it goes to recovery",
        _psState4 isEqualTo "RECOVERING" && {!("placeOnSlot" in _psEff4)}] call _fnc_check;
    ([call _fnc_landingRow, [["speed", 0], ["onRunway", true]], 1000] call _fnc_taxi) params ["_pr1", "_prState1", "_prEff1"];
    ([_pr1, [["speed", 0], ["onRunway", true]], 1031] call _fnc_taxi) params ["_pr2", "_prState2", "_prEff2"];
    ["and one at rest on the runway for thirty seconds is moved off it",
        _prState1 isEqualTo "LANDING" && {_prState2 isEqualTo "PARKED"} && {"placeOnSlot" in _prEff2}] call _fnc_check;
    // A taxiway blocks the aircraft behind it just as the runway does, so it is
    // counted the same way: seen to stop, then moved. Recovery would stop the
    // engine and hold it there for ten minutes while anyone is about.
    ([call _fnc_landingRow, [["speed", 0], ["onTaxiway", true]], 1000] call _fnc_taxi) params ["_pt1", "_ptState1", "_ptEff1"];
    ([_pt1, [["speed", 0], ["onTaxiway", true]], 1031] call _fnc_taxi) params ["_pt2", "_ptState2", "_ptEff2"];
    ["one at rest on a taxiway for thirty seconds is moved off it too",
        _ptState1 isEqualTo "LANDING" && {!("placeOnSlot" in _ptEff1)} && {_ptState2 isEqualTo "PARKED"} && {"placeOnSlot" in _ptEff2}] call _fnc_check;

    // ---- who counts as watching a landing -----------------------------------
    // Nobody within 300 m is not nobody watching. On Stratis the control tower
    // is 188 m off the runway's line and only nine of its twenty two points are
    // within 300 m of it; every one is within 1000 m. A Blackfish was put on its
    // stand the moment it slowed, in front of a player in the tower.
    private _towerOnly = [["playersWithin300", 0], ["playersWithin1000Hull", 1]];
    ([call _fnc_landingRow, [["speed", 0]] + _towerOnly, 1000] call _fnc_taxi) params ["_tw1", "_twState1", "_twEff1"];
    ([_tw1, [["speed", 0]] + _towerOnly, 1031] call _fnc_taxi) params ["_tw2", "_twState2", "_twEff2"];
    diag_log format ["  info  stopped clear of the runway, somebody 300 to 1000 m away: %1 then %2, effects %3",
        _twState1, _twState2, _twEff2];
    ["a plane stopped clear of the runway with somebody a few hundred metres off is left alone",
        _twState1 isEqualTo "LANDING" && {!("placeOnSlot" in _twEff1)}
        && {_twState2 isEqualTo "RECOVERING"} && {!("placeOnSlot" in _twEff2)}] call _fnc_check;
    ([call _fnc_landingRow, _towerOnly, 1000] call _fnc_taxi) params ["_tr1", "_trState1", "_trEff1"];
    ["and one still rolling out is not put away mid-roll either",
        _trState1 isEqualTo "LANDING" && {!("placeOnSlot" in _trEff1)}] call _fnc_check;
    // On its own stand the slide is a few metres, and one not made now is never
    // made: home is home to every later state. So that one keeps 300 m.
    (([_towerOnly + [["atHome", true]]] call _fnc_landedAt)) params ["_ahRow", "_ahOrd", "_ahEff"];
    ["a helicopter a little off its own pad is still slid onto it with nobody within 300 m",
        ([_ahRow, "state", ""] call ALIVE_fnc_hashGet) isEqualTo "PARKED" && {"placeOnSlot" in _ahEff} && {"turnaround" in _ahEff}] call _fnc_check;
    (([[["playersWithin300", 2], ["playersWithin1000Hull", 2], ["atHome", true]]] call _fnc_landedAt)) params ["_awRow", "_awOrd", "_awEff"];
    ["but left where it set down with somebody closer than that",
        ([_awRow, "state", ""] call ALIVE_fnc_hashGet) isEqualTo "PARKED" && {!("placeOnSlot" in _awEff)} && {"turnaround" in _awEff}] call _fnc_check;
    // Thirty to sixty metres off its pad is still a short slide, so it keeps
    // the 300 m rule too, instead of waiting out recovery and jumping later.
    (([_towerOnly + [["nearStand", true]]] call _fnc_landedAt)) params ["_nsRow", "_nsOrd", "_nsEff"];
    ["one that set down forty metres off its pad is slid onto it with nobody within 300 m",
        ([_nsRow, "state", ""] call ALIVE_fnc_hashGet) isEqualTo "PARKED" && {"placeOnSlot" in _nsEff}] call _fnc_check;
    (([_towerOnly] call _fnc_landedAt)) params ["_farRow", "_farOrd", "_farEff"];
    ["but one further off than that, with somebody within a kilometre, is not",
        !("placeOnSlot" in _farEff)] call _fnc_check;

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

    // ---- the launch from land ----------------------------------------------
    // A plane on land is stood on its airport's taxi route as it launches,
    // because left on its stand a jet in a tent hangar never got out of the
    // door. Only a plane, only on land, only on the way in, and never with
    // somebody aboard.
    private _fnc_launchFrom = {
        params ["_flags", ["_state", "ASSIGNED"]];
        private _row = [_m, "newRow", ["BLU_F_0", [[100,100,0], 0, "terrain"]]] call ALIVE_fnc_ATOMachine;
        [_row, "state", _state] call ALIVE_fnc_hashSet;
        [_row, "enteredAt", 990] call ALIVE_fnc_hashSet;
        [_row, "deadlineAt", 9999] call ALIVE_fnc_hashSet;
        [_row, "sortie", ["CAS", [100,100,0], 600, 2000, "s1", [], ""]] call ALIVE_fnc_hashSet;
        private _obs = [[["crewSeated", true], ["lockHeld", true]] + _flags] call _fnc_obs;
        private _out = [_m, "step", [_row, _obs, "", 1000]] call ALIVE_fnc_ATOMachine;
        [([(_out select 0), "state", ""] call ALIVE_fnc_hashGet), _out select 2]
    };

    ([[["fixedWing", true], ["needsRunway", true]]] call _fnc_launchFrom) params ["_lpState", "_lpEff"];
    diag_log format ["  info  a plane on land launching went to %1, effects %2", _lpState, _lpEff];
    ["a plane on land launches from its taxi route",
        _lpState isEqualTo "LAUNCHING" && {"taxiOut" in _lpEff}] call _fnc_check;
    // Held until it stands there: on LAN a refused taxi out was never asked
    // again, the A-10 was given its fuel and engine anyway and drove itself
    // into its hangar's doorway.
    ["and it stays held until it stands there: no fuel back, no engine, no sweep yet",
        !("releaseHold" in _lpEff) && {!("engineOn" in _lpEff)} && {!("sweepTaxiPath" in _lpEff)}] call _fnc_check;

    // Held on the stand with an empty tank while it waits, before its crew is
    // made. A plane on land only.
    private _fnc_assign = {
        params ["_flags"];
        private _row = [_m, "newRow", ["BLU_F_0", [[100,100,0], 0, "terrain"]]] call ALIVE_fnc_ATOMachine;
        [_row, "state", "PARKED"] call ALIVE_fnc_hashSet;
        [_row, "readyAt", 0] call ALIVE_fnc_hashSet;
        [_row, "sortie", ["CAS", [100,100,0], 600, 2000, "s1", [], ""]] call ALIVE_fnc_hashSet;
        private _out = [_m, "step", [_row, [_flags] call _fnc_obs, "ASSIGN", 1000]] call ALIVE_fnc_ATOMachine;
        [([(_out select 0), "state", ""] call ALIVE_fnc_hashGet), _out select 2]
    };
    ([[["fixedWing", true], ["needsRunway", true]]] call _fnc_assign) params ["_asState", "_asEff"];
    diag_log format ["  info  a plane on land assigned went to %1, effects %2", _asState, _asEff];
    ["a plane on land is held on its stand before its crew is made",
        _asState isEqualTo "ASSIGNED" && {(_asEff find "holdOnStand") > -1}
        && {(_asEff find "holdOnStand") < (_asEff find "mintCrew")}] call _fnc_check;
    ["a VTOL on land is not held, nor given the runway: it lifts where it stands",
        !("holdOnStand" in (([[]] call _fnc_assign) select 1)) && {!("lock" in (([[]] call _fnc_assign) select 1))}] call _fnc_check;
    ["a helicopter is not held",
        !("holdOnStand" in (([[]] call _fnc_assign) select 1))] call _fnc_check;
    ["nor is a plane on a deck",
        !("holdOnStand" in (([[["deckHome", true], ["fixedWing", true], ["needsRunway", true]]] call _fnc_assign) select 1))] call _fnc_check;
    ["a helicopter lifts from where it stands",
        !("taxiOut" in (([[]] call _fnc_launchFrom) select 1))] call _fnc_check;
    ["and so does a VTOL",
        !("taxiOut" in (([[["needsRunway", true]]] call _fnc_launchFrom) select 1))] call _fnc_check;
    private _deckEff = ([[["deckHome", true], ["fixedWing", true], ["needsRunway", true]]] call _fnc_launchFrom) select 1;
    ["a plane on a deck is catapulted instead",
        ("catapult" in _deckEff) && {!("taxiOut" in _deckEff)}] call _fnc_check;
    private _riddenEff = ([[["fixedWing", true], ["needsRunway", true], ["playerPassenger", true], ["anyPlayerAboard", true]]] call _fnc_launchFrom) select 1;
    ["a plane with a player aboard is not moved to the taxi route",
        !("taxiOut" in _riddenEff) && {"refusedTeleportPlayerAboard" in _riddenEff}] call _fnc_check;
    private _heldNow = [["fixedWing", true], ["needsRunway", true], ["heldOnStand", true], ["canMove", false], ["fuel", 0]];
    ([_heldNow, "LAUNCHING"] call _fnc_launchFrom) params ["_lpState2", "_lpEff2"];
    // The runway is not kept for it from its stand: the kernel takes it when the
    // plane is stood on its route, so a plane whose route stays blocked lets it
    // lapse and one of ours coming home can land.
    ["a plane held on its stand and not yet on its route is asked again every tick, and the runway is not kept for it",
        _lpState2 isEqualTo "LAUNCHING" && {"taxiOut" in _lpEff2} && {!("lock" in _lpEff2)} && {!("engineOn" in _lpEff2)}] call _fnc_check;
    ([_heldNow + [["lockHeld", false], ["lockBusy", true]], "LAUNCHING"] call _fnc_launchFrom) params ["_lpStateB", "_lpEffB"];
    ["and while another of ours has the runway it is not stood on its route at all",
        _lpStateB isEqualTo "LAUNCHING" && {!("taxiOut" in _lpEffB)} && {!("lock" in _lpEffB)}
        && {!("releaseHold" in _lpEffB)} && {!("engineOn" in _lpEffB)}] call _fnc_check;
    // Not held, it is on its way from wherever it is, and is never stood back on
    // the start of its route: a plane whose hold was let go for a passenger who
    // has since got out may be rolling.
    ([[["fixedWing", true], ["needsRunway", true]], "LAUNCHING"] call _fnc_launchFrom) params ["_lpStateN", "_lpEffN"];
    ["a plane that is not held is never asked to be stood on its route",
        _lpStateN isEqualTo "LAUNCHING" && {!("taxiOut" in _lpEffN)} && {"engineOn" in _lpEffN}] call _fnc_check;
    ([[["fixedWing", true], ["needsRunway", true], ["taxiOutAt", 995]], "LAUNCHING"] call _fnc_launchFrom) params ["_lpState3", "_lpEff3"];
    diag_log format ["  info  a plane stood on its route went to %1, effects %2", _lpState3, _lpEff3];
    ["and one already stood on its route is never pulled back: its fuel, engine and sweep follow",
        _lpState3 isEqualTo "LAUNCHING" && {!("taxiOut" in _lpEff3)} && {"releaseHold" in _lpEff3}
        && {"engineOn" in _lpEff3} && {"sweepTaxiPath" in _lpEff3}
        && {(_lpEff3 find "releaseHold") < (_lpEff3 find "engineOn")}] call _fnc_check;
    ([_heldNow + [["taxiOutAt", 500]], "LAUNCHING"] call _fnc_launchFrom) params ["", "_lpEff4"];
    ["and a stamp from an earlier launch does not count",
        "taxiOut" in _lpEff4] call _fnc_check;

    // ---- an assignment that runs out with the aircraft already up ------------
    // It lifted off by itself while it waited for the runway. Recovered, with
    // its crew and its engine; never parked in the air.
    private _upRow = [_m, "newRow", ["BLU_F_0", [[100,100,0], 0, "terrain"]]] call ALIVE_fnc_ATOMachine;
    [_upRow, "state", "ASSIGNED"] call ALIVE_fnc_hashSet;
    [_upRow, "enteredAt", 800] call ALIVE_fnc_hashSet;
    [_upRow, "deadlineAt", 920] call ALIVE_fnc_hashSet;
    [_upRow, "sortie", ["CAS", [100,100,0], 600, 2000, "s1", [], ""]] call ALIVE_fnc_hashSet;
    private _upOut = [_m, "step", [_upRow,
        [[["crewSeated", true], ["lockHeld", false], ["airborne", true], ["atHome", false], ["needsRunway", true], ["fixedWing", true]]] call _fnc_obs,
        "", 1000]] call ALIVE_fnc_ATOMachine;
    private _upState = [(_upOut select 0), "state", ""] call ALIVE_fnc_hashGet;
    private _upEff = _upOut select 2;
    diag_log format ["  info  an assignment run out in the air went to %1, effects %2", _upState, _upEff];
    ["an assignment that runs out in the air is recovered, not parked",
        _upState isEqualTo "RECOVERING" && {!("standDownCrew" in _upEff)} && {!("engineOff" in _upEff)}] call _fnc_check;
    ["and the tasker is still told it failed", "assignFailed" in _upEff] call _fnc_check;
    // A plane, because only a plane waits for the runway: a helicopter with its
    // pilot seated would simply launch.
    private _gndOut = [_m, "step", [_upRow, [[["crewSeated", true], ["lockHeld", false],
        ["fixedWing", true], ["needsRunway", true]]] call _fnc_obs, "", 1000]] call ALIVE_fnc_ATOMachine;
    ["one that runs out on the ground is still parked and stood down, as before",
        (([(_gndOut select 0), "state", ""] call ALIVE_fnc_hashGet) isEqualTo "PARKED")
        && {"standDownCrew" in (_gndOut select 2)}] call _fnc_check;

    // ---- the runway is for what uses it ------------------------------------
    // A helicopter lifts from its own pad and lands on it again. An Apache that
    // could not get down held the runway through five minutes of hovering while
    // a jet behind it ran out of time, so a helicopter neither waits for the
    // runway nor holds it.
    ([[["lockHeld", false]]] call _fnc_launchFrom) params ["_hState", "_hEff"];
    ["a helicopter with its pilot seated launches without the runway",
        _hState isEqualTo "LAUNCHING" && {!("lock" in _hEff)}] call _fnc_check;
    ([[["lockHeld", false], ["fixedWing", true], ["needsRunway", true]]] call _fnc_launchFrom) params ["_pState", "_pEff"];
    ["a plane still waits for the runway and asks for it",
        _pState isEqualTo "ASSIGNED" && {"lock" in _pEff}] call _fnc_check;
    ["a helicopter's assignment does not ask for the runway",
        !("lock" in (([[]] call _fnc_assign) select 1))] call _fnc_check;
    ["a plane's does",
        "lock" in (([[["fixedWing", true], ["needsRunway", true]]] call _fnc_assign) select 1)] call _fnc_check;

    private _fnc_rtbNear = {
        params ["_flags"];
        private _row = [_m, "newRow", ["BLU_F_0", [[100,100,0], 0, "terrain"]]] call ALIVE_fnc_ATOMachine;
        [_row, "state", "RTB"] call ALIVE_fnc_hashSet;
        [_row, "deadlineAt", 9999] call ALIVE_fnc_hashSet;
        [_row, "sortie", ["CAS", [100,100,0], 600, 2000, "s1", [], ""]] call ALIVE_fnc_hashSet;
        private _obs = [[["airborne", true], ["atHome", false], ["nearHome", true],
            ["playersWithin1000Home", 2], ["lockHeld", false]] + _flags] call _fnc_obs;
        private _out = [_m, "step", [_row, _obs, "", 1000]] call ALIVE_fnc_ATOMachine;
        [([(_out select 0), "state", ""] call ALIVE_fnc_hashGet), _out select 2]
    };
    ([[]] call _fnc_rtbNear) params ["_hrState", "_hrEff"];
    ["a helicopter near home goes in to land without the runway",
        _hrState isEqualTo "LANDING" && {!("lock" in _hrEff)}] call _fnc_check;
    ([[["fixedWing", true], ["needsRunway", true]]] call _fnc_rtbNear) params ["_prState", "_prEff"];
    ["a plane near home asks for the runway first, as before",
        _prState isEqualTo "RTB" && {"lock" in _prEff}] call _fnc_check;

    // ---- a launch that cannot happen ----------------------------------------
    // An Apache's rotors broke off against a hangar as it started up, and the
    // launch deadline then threw it six hundred metres up and it fell. A broken
    // aircraft reads canMove false with damage 0; so does an empty tank.
    private _fnc_launching = {
        params ["_flags", ["_deadline", 9999]];
        private _row = [_m, "newRow", ["BLU_F_0", [[100,100,0], 0, "terrain"]]] call ALIVE_fnc_ATOMachine;
        [_row, "state", "LAUNCHING"] call ALIVE_fnc_hashSet;
        [_row, "enteredAt", 800] call ALIVE_fnc_hashSet;
        [_row, "deadlineAt", _deadline] call ALIVE_fnc_hashSet;
        [_row, "sortie", ["CAS", [100,100,0], 600, 2000, "s1", [], ""]] call ALIVE_fnc_hashSet;
        private _out = [_m, "step", [_row, [[["crewSeated", true]] + _flags] call _fnc_obs, "", 1000]] call ALIVE_fnc_ATOMachine;
        [([(_out select 0), "state", ""] call ALIVE_fnc_hashGet), _out select 2, ([(_out select 0), "readyAt", 0] call ALIVE_fnc_hashGet)]
    };
    ([[["canMove", false]]] call _fnc_launching) params ["_bkState", "_bkEff", "_bkReady"];
    diag_log format ["  info  a broken helicopter launching went to %1, effects %2", _bkState, _bkEff];
    ["a broken aircraft's launch is called off at once, not forced",
        _bkState isEqualTo "PARKED" && {!("forceLaunch" in _bkEff)}] call _fnc_check;
    ["and it is put back on its stand and serviced",
        "placeOnSlot" in _bkEff && {"turnaround" in _bkEff}] call _fnc_check;
    ["and the job goes to another aircraft while it is off the rota",
        "assignFailed" in _bkEff && {_bkReady >= 1300}] call _fnc_check;
    ([[["canMove", false], ["fuel", 0]]] call _fnc_launching) params ["_etState", "_etEff"];
    ["one that only has an empty tank is left to its launch, since a held plane gets its fuel back on the way in",
        _etState isEqualTo "LAUNCHING" && {!("placeOnSlot" in _etEff)}] call _fnc_check;
    ([[["canMove", false], ["fuel", 0]], 900] call _fnc_launching) params ["_edState", "_edEff"];
    ["but at the deadline it is called off rather than thrown into the air",
        _edState isEqualTo "PARKED" && {!("forceLaunch" in _edEff)}] call _fnc_check;
    ([[], 900] call _fnc_launching) params ["_okState", "_okEff"];
    ["a sound aircraft still stuck at the deadline is forced up, as before",
        "forceLaunch" in _okEff] call _fnc_check;
    ([[["canMove", false], ["playerPassenger", true], ["anyPlayerAboard", true]]] call _fnc_launching) params ["_bpState", "_bpEff", "_bpReady"];
    ["with a player aboard it is recovered where it is, never moved",
        _bpState isEqualTo "RECOVERING" && {!("placeOnSlot" in _bpEff)}] call _fnc_check;
    ["and it is kept off the rota all the same, or it is offered every job and fails each one",
        _bpReady >= 1300] call _fnc_check;
    ([[["canMove", false], ["launchInProgress", true], ["deckHome", true], ["fixedWing", true], ["needsRunway", true]]] call _fnc_launching) params ["_bcState", "_bcEff"];
    ["and a catapult shot already running is left to finish",
        _bcState isEqualTo "LAUNCHING" && {!("placeOnSlot" in _bcEff)}] call _fnc_check;

    // ---- a plane waiting on its stand for its taxi route ---------------------
    // Its tank is held empty, so it reads as unable to move. That is the hold,
    // not a fault: it is asked again, waits at its deadline, and only after its
    // waits is the job given back. Never thrown into the air from its stand.
    private _heldFlags = [["fixedWing", true], ["needsRunway", true], ["heldOnStand", true], ["canMove", false], ["fuel", 0]];
    ([_heldFlags] call _fnc_launching) params ["_hdState", "_hdEff"];
    ["a plane held for its taxi route is asked again, not called off as broken",
        _hdState isEqualTo "LAUNCHING" && {"taxiOut" in _hdEff} && {!("placeOnSlot" in _hdEff)} && {!("assignFailed" in _hdEff)}] call _fnc_check;
    private _fnc_heldAt = {
        params ["_waits", "_flags"];
        private _row = [_m, "newRow", ["BLU_F_0", [[100,100,0], 0, "terrain"]]] call ALIVE_fnc_ATOMachine;
        [_row, "state", "LAUNCHING"] call ALIVE_fnc_hashSet;
        [_row, "enteredAt", 800] call ALIVE_fnc_hashSet;
        [_row, "deadlineAt", 900] call ALIVE_fnc_hashSet;
        [_row, "taxiWaits", _waits] call ALIVE_fnc_hashSet;
        [_row, "sortie", ["CAS", [100,100,0], 600, 2000, "s1", [], ""]] call ALIVE_fnc_hashSet;
        private _out = [_m, "step", [_row, [[["crewSeated", true]] + _flags] call _fnc_obs, "", 1000]] call ALIVE_fnc_ATOMachine;
        [_out select 0, [(_out select 0), "state", ""] call ALIVE_fnc_hashGet, _out select 2, [(_out select 0), "reason", ""] call ALIVE_fnc_hashGet]
    };
    ([0, _heldFlags] call _fnc_heldAt) params ["_hw1", "_hwState1", "_hwEff1"];
    diag_log format ["  info  a held plane at its deadline went to %1, effects %2, deadline %3", _hwState1, _hwEff1, [_hw1, "deadlineAt", 0] call ALIVE_fnc_hashGet];
    ["at its deadline it waits a minute more on its stand, still asking",
        _hwState1 isEqualTo "LAUNCHING" && {"waitingForTaxiRoute" in _hwEff1} && {"taxiOut" in _hwEff1}
        && {!("forceLaunch" in _hwEff1)} && {([_hw1, "taxiWaits", 0] call ALIVE_fnc_hashGet) == 1}
        && {([_hw1, "deadlineAt", 0] call ALIVE_fnc_hashGet) == 1060}] call _fnc_check;
    ([3, _heldFlags] call _fnc_heldAt) params ["_hw2", "_hwState2", "_hwEff2", "_hwWhy2"];
    diag_log format ["  info  a held plane out of waits went to %1, effects %2, deadline %3", _hwState2, _hwEff2, [_hw2, "deadlineAt", 0] call ALIVE_fnc_hashGet];
    // Not handed back: an apron whose route stayed blocked, by a wreck or a parked
    // vehicle, would then never launch at all.
    ["after its waits it leaves from its stand as before: its hold let go, not thrown into the air and not handed back",
        _hwState2 isEqualTo "LAUNCHING" && {"releaseHold" in _hwEff2} && {"leavesFromStand" in _hwEff2}
        && {!("taxiOut" in _hwEff2)} && {!("forceLaunch" in _hwEff2)} && {!("assignFailed" in _hwEff2)}
        && {([_hw2, "deadlineAt", 0] call ALIVE_fnc_hashGet) == 1180}] call _fnc_check;
    ["and it takes the runway as it goes, before its hold is let go",
        ("lock" in _hwEff2) && {(_hwEff2 find "lock") < (_hwEff2 find "releaseHold")}] call _fnc_check;
    // Another of ours on the runway: it waits that out, whatever its count, and
    // the wait is not counted against it.
    ([3, _heldFlags + [["lockBusy", true]]] call _fnc_heldAt) params ["_hwB", "_hwStateB", "_hwEffB"];
    diag_log format ["  info  a held plane out of waits with the runway busy went to %1, effects %2, deadline %3", _hwStateB, _hwEffB, [_hwB, "deadlineAt", 0] call ALIVE_fnc_hashGet];
    ["out of waits while another of ours has the runway, it waits a minute more rather than leaving",
        _hwStateB isEqualTo "LAUNCHING" && {"waitingForTaxiRoute" in _hwEffB} && {!("leavesFromStand" in _hwEffB)}
        && {!("releaseHold" in _hwEffB)} && {!("taxiOut" in _hwEffB)} && {!("lock" in _hwEffB)}
        && {([_hwB, "deadlineAt", 0] call ALIVE_fnc_hashGet) == 1060}] call _fnc_check;
    ([0, _heldFlags + [["lockBusy", true]]] call _fnc_heldAt) params ["_hwB0"];
    ["and a wait spent on the runway does not use up one of its three",
        ([_hwB0, "taxiWaits", -1] call ALIVE_fnc_hashGet) == 0] call _fnc_check;
    // Stood on its route, it is given its time from then: the wait does not eat it.
    ([0, [["fixedWing", true], ["needsRunway", true], ["taxiOutAt", 990]]] call _fnc_heldAt) params ["_fw", "_fwState", "_fwEff"];
    ["stood on its route late, it has three minutes from then, not what was left",
        _fwState isEqualTo "LAUNCHING" && {!("forceLaunch" in _fwEff)} && {"engineOn" in _fwEff}
        && {([_fw, "deadlineAt", 0] call ALIVE_fnc_hashGet) == 1180}
        && {([_fw, "taxiedOutAt", -1] call ALIVE_fnc_hashGet) == 1000}] call _fnc_check;
    // Rolling down the runway at its deadline: once, more time.
    private _fnc_rollAt = {
        params ["_speed", "_extended", ["_now", 1000], ["_onRunway", true]];
        private _row = [_m, "newRow", ["BLU_F_0", [[100,100,0], 0, "terrain"]]] call ALIVE_fnc_ATOMachine;
        [_row, "state", "LAUNCHING"] call ALIVE_fnc_hashSet;
        [_row, "enteredAt", 800] call ALIVE_fnc_hashSet;
        [_row, "deadlineAt", 900] call ALIVE_fnc_hashSet;
        [_row, "taxiedOutAt", 850] call ALIVE_fnc_hashSet;
        [_row, "launchExtended", _extended] call ALIVE_fnc_hashSet;
        [_row, "sortie", ["CAS", [100,100,0], 600, 2000, "s1", [], ""]] call ALIVE_fnc_hashSet;
        private _out = [_m, "step", [_row, [[["crewSeated", true], ["fixedWing", true], ["needsRunway", true], ["taxiOutAt", 850],
            ["onRunway", _onRunway], ["speed", _speed]]] call _fnc_obs, "", _now]] call ALIVE_fnc_ATOMachine;
        [_out select 0, [(_out select 0), "state", ""] call ALIVE_fnc_hashGet, _out select 2]
    };
    ([60, false] call _fnc_rollAt) params ["_rl1", "_rlState1", "_rlEff1"];
    ["a plane rolling down the runway at its deadline is given more time, not thrown up",
        _rlState1 isEqualTo "LAUNCHING" && {"launchExtended" in _rlEff1} && {!("forceLaunch" in _rlEff1)}
        && {([_rl1, "deadlineAt", 0] call ALIVE_fnc_hashGet) == 1090}] call _fnc_check;
    ([60, true] call _fnc_rollAt) params ["", "", "_rlEff2"];
    ["but only once", "forceLaunch" in _rlEff2 && {!("launchExtended" in _rlEff2)}] call _fnc_check;
    ([0, false] call _fnc_rollAt) params ["", "", "_rlEff3"];
    ["and one stopped on the runway is still forced up", "forceLaunch" in _rlEff3] call _fnc_check;
    ([60, false, 1000, false] call _fnc_rollAt) params ["", "", "_rlEff4"];
    ["as is one taxiing off the runway", "forceLaunch" in _rlEff4] call _fnc_check;
    ([[["fixedWing", true], ["needsRunway", true], ["heldOnStand", true], ["canMove", false], ["fuel", 0],
        ["playerPassenger", true], ["anyPlayerAboard", true]]] call _fnc_launching) params ["", "_ppEff"];
    ["a player riding a held plane gets its fuel back at once and is never moved",
        "releaseHold" in _ppEff && {!("taxiOut" in _ppEff)}] call _fnc_check;

    // ---- a landing on final is not cut off -----------------------------------
    // On LAN a Blackfish hit its five minute landing deadline 94 m up, 1750 m
    // out and descending, twenty or thirty seconds from touchdown, and was put
    // down from there. One still flying and plainly coming down gets three more
    // minutes, once; anything else is put down as before.
    private _fnc_landingExpiry = {
        params ["_flags", ["_attempts", 0], ["_extended", false], ["_now", 1000], ["_row", []]];
        if (_row isEqualTo []) then {
            _row = [_m, "newRow", ["BLU_F_0", [[100,100,0], 0, "terrain"]]] call ALIVE_fnc_ATOMachine;
            [_row, "state", "LANDING"] call ALIVE_fnc_hashSet;
            [_row, "enteredAt", 650] call ALIVE_fnc_hashSet;
            [_row, "deadlineAt", 950] call ALIVE_fnc_hashSet;
            [_row, "attempts", _attempts] call ALIVE_fnc_hashSet;
            [_row, "landingExtended", _extended] call ALIVE_fnc_hashSet;
            [_row, "sortie", ["CAS", [100,100,0], 600, 2000, "s1", [], ""]] call ALIVE_fnc_hashSet;
        };
        private _obs = [[["airborne", true], ["atHome", false], ["nearHome", true], ["needsRunway", true],
            ["fixedWing", true], ["playersWithin1000Hull", 4], ["playersWithin1000Home", 4]] + _flags] call _fnc_obs;
        private _out = [_m, "step", [_row, _obs, "", _now]] call ALIVE_fnc_ATOMachine;
        [_out select 0, [(_out select 0), "state", ""] call ALIVE_fnc_hashGet, _out select 2]
    };
    private _finalFlags = [["altAGL", 94], ["climbRate", -2.9]];
    ([_finalFlags] call _fnc_landingExpiry) params ["_lx1", "_lxState1", "_lxEff1"];
    diag_log format ["  info  a plane on final at its deadline went to %1, effects %2, deadline %3",
        _lxState1, _lxEff1, [_lx1, "deadlineAt", 0] call ALIVE_fnc_hashGet];
    ["a plane on final at its deadline is given more time, not put down",
        _lxState1 isEqualTo "LANDING" && {"landingExtended" in _lxEff1} && {!("forceLanded" in _lxEff1)}
        && {([_lx1, "landingExtended", false] call ALIVE_fnc_hashGet)}
        && {([_lx1, "deadlineAt", 0] call ALIVE_fnc_hashGet) == 1180}] call _fnc_check;
    ["and it goes on flying its approach", "landOnRunway" in _lxEff1] call _fnc_check;
    ([_finalFlags, 0, false, 1181, _lx1] call _fnc_landingExpiry) params ["_lx2", "_lxState2", "_lxEff2"];
    ["but only once: at the end of the extra time it is put down",
        _lxState2 isEqualTo "PARKED" && {"forceLanded" in _lxEff2} && {!("landingExtended" in _lxEff2)}] call _fnc_check;
    ([[["altAGL", 800], ["climbRate", 6]]] call _fnc_landingExpiry) params ["", "_lxState3", "_lxEff3"];
    ["one climbing away is put down at once, as before",
        _lxState3 isEqualTo "PARKED" && {"forceLanded" in _lxEff3}] call _fnc_check;
    ([[["altAGL", 7000], ["climbRate", 0]]] call _fnc_landingExpiry) params ["", "_lxState4", "_lxEff4"];
    ["and so is a jet level at seven kilometres, which is not coming down",
        _lxState4 isEqualTo "PARKED" && {!("landingExtended" in _lxEff4)}] call _fnc_check;
    ([[["needsRunway", false], ["fixedWing", false], ["altAGL", 57]]] call _fnc_landingExpiry) params ["", "_lxState5", "_lxEff5"];
    ["a helicopter low over its pad gets the extra time too",
        _lxState5 isEqualTo "LANDING" && {"landingExtended" in _lxEff5} && {"landAtPad" in _lxEff5}] call _fnc_check;
    ([_finalFlags, 2] call _fnc_landingExpiry) params ["", "_lxState6", "_lxEff6"];
    ["one that came round through recovery gets it as well",
        _lxState6 isEqualTo "LANDING" && {"landingExtended" in _lxEff6}] call _fnc_check;
    ([[["airborne", false], ["landed", true], ["touchingGround", true], ["onRunway", true], ["altAGL", 0]]] call _fnc_landingExpiry) params ["", "_lxState7", "_lxEff7"];
    ["one on the ground is not extended: it is holding the runway",
        !("landingExtended" in _lxEff7)] call _fnc_check;
    // A helicopter holding 30 m over a pad it cannot get onto reads as not in
    // the air (the observer's airborne height is higher), and it is put down.
    ([[["needsRunway", false], ["fixedWing", false], ["airborne", false], ["altAGL", 30]]] call _fnc_landingExpiry) params ["", "_lxState9", "_lxEff9"];
    ["a helicopter hovering low over a blocked pad is put down, not given more time",
        _lxState9 isEqualTo "PARKED" && {"forceLanded" in _lxEff9} && {!("landingExtended" in _lxEff9)}] call _fnc_check;
    // Not far from home. On LAN a Blackfish that had touched down and flown off
    // again was given the three minutes 231 m up and 48 km out.
    ([[["needsRunway", false], ["fixedWing", false], ["altAGL", 231], ["climbRate", 0], ["distHome", 48103]]] call _fnc_landingExpiry) params ["", "_lxStateF", "_lxEffF"];
    ["one low but 48 km from home is put down, not given more time",
        _lxStateF isEqualTo "PARKED" && {"forceLanded" in _lxEffF} && {!("landingExtended" in _lxEffF)}] call _fnc_check;
    ([[["altAGL", 1200], ["climbRate", -4], ["distHome", 4500]]] call _fnc_landingExpiry) params ["", "_lxStateC", "_lxEffC"];
    ["a jet coming down on its circuit 4.5 km out still gets it",
        _lxStateC isEqualTo "LANDING" && {"landingExtended" in _lxEffC}] call _fnc_check;
    ([[["altAGL", 1200], ["climbRate", -4], ["distHome", 5500]]] call _fnc_landingExpiry) params ["", "_lxStateC2", "_lxEffC2"];
    ["but not 5.5 km out", _lxStateC2 isEqualTo "PARKED" && {!("landingExtended" in _lxEffC2)}] call _fnc_check;
    ([_finalFlags + [["playerPassenger", true], ["anyPlayerAboard", true]], 0, true] call _fnc_landingExpiry) params ["", "_lxState8", "_lxEff8"];
    ["with a player aboard, after its extra time it is sent round again rather than put down",
        _lxState8 isEqualTo "LANDING" && {"retryLanding" in _lxEff8} && {!("forceLanded" in _lxEff8)}] call _fnc_check;
    private _rtbX = [_m, "newRow", ["BLU_F_0", [[100,100,0], 0, "terrain"]]] call ALIVE_fnc_ATOMachine;
    [_rtbX, "state", "RTB"] call ALIVE_fnc_hashSet;
    [_rtbX, "deadlineAt", 9999] call ALIVE_fnc_hashSet;
    [_rtbX, "landingExtended", true] call ALIVE_fnc_hashSet;
    private _rtbXOut = [_m, "step", [_rtbX, [[["airborne", true], ["atHome", false], ["nearHome", true],
        ["playersWithin1000Home", 2]]] call _fnc_obs, "", 1000]] call ALIVE_fnc_ATOMachine;
    ["each landing gets its own extension: the mark is cleared on the way in",
        (([(_rtbXOut select 0), "state", ""] call ALIVE_fnc_hashGet) isEqualTo "LANDING")
        && {!([(_rtbXOut select 0), "landingExtended", true] call ALIVE_fnc_hashGet)}] call _fnc_check;

    // ---- a launch waits for a runway another of ours is landing on -----------
    // On LAN an F-22 landing from 6953 m held the runway for 4 min 16 s, and four
    // launches behind it ran out of time and went back to planning. A plane on
    // land waits instead, up to six times, then gives up as before.
    private _fnc_assignWait = {
        params ["_flags", ["_now", 1000], ["_row", []]];
        if (_row isEqualTo []) then {
            _row = [_m, "newRow", ["BLU_F_0", [[100,100,0], 0, "terrain"]]] call ALIVE_fnc_ATOMachine;
            [_row, "state", "ASSIGNED"] call ALIVE_fnc_hashSet;
            [_row, "enteredAt", 800] call ALIVE_fnc_hashSet;
            [_row, "deadlineAt", 950] call ALIVE_fnc_hashSet;
            [_row, "sortie", ["CAS", [100,100,0], 600, 2000, "s1", [], ""]] call ALIVE_fnc_hashSet;
        };
        private _obs = [[["crewSeated", true], ["lockHeld", false], ["needsRunway", true], ["fixedWing", true]] + _flags] call _fnc_obs;
        private _out = [_m, "step", [_row, _obs, "", _now]] call ALIVE_fnc_ATOMachine;
        [_out select 0, [(_out select 0), "state", ""] call ALIVE_fnc_hashGet, _out select 2,
            [(_out select 0), "reason", ""] call ALIVE_fnc_hashGet]
    };
    ([[["lockBusy", true]]] call _fnc_assignWait) params ["_aw1", "_awState1", "_awEff1"];
    diag_log format ["  info  a launch whose runway another aircraft holds went to %1, effects %2", _awState1, _awEff1];
    ["a launch whose runway another of ours is using waits rather than giving up",
        _awState1 isEqualTo "ASSIGNED" && {"waitingForRunway" in _awEff1} && {"lock" in _awEff1}
        && {!("assignFailed" in _awEff1)} && {!("releaseHold" in _awEff1)}
        && {([_aw1, "runwayWaits", 0] call ALIVE_fnc_hashGet) == 1}
        && {([_aw1, "deadlineAt", 0] call ALIVE_fnc_hashGet) == 1120}] call _fnc_check;
    private _awRow = _aw1;
    private _awLast = [];
    { ([[["lockBusy", true]], _x, _awRow] call _fnc_assignWait) params ["_r", "_s", "_e", "_why"]; _awRow = _r; _awLast = [_s, _e, _why] } forEach [1121, 1242, 1363, 1484, 1605];
    ["and keeps waiting while the runway stays busy",
        (_awLast select 0) isEqualTo "ASSIGNED" && {([_awRow, "runwayWaits", 0] call ALIVE_fnc_hashGet) == 6}] call _fnc_check;
    ([[["lockBusy", true]], 1726, _awRow] call _fnc_assignWait) params ["", "_awState5", "_awEff5", "_awWhy5"];
    ["but not for ever: after six waits it gives up as before",
        _awState5 isEqualTo "PARKED" && {"assignFailed" in _awEff5} && {"standDownCrew" in _awEff5}
        && {_awWhy5 isEqualTo "NO_LOCK"}] call _fnc_check;
    ([[["lockBusy", false]]] call _fnc_assignWait) params ["", "_awStateF", "", "_awWhyF"];
    ["a runway that nobody holds is not waited for: that is a lock problem",
        _awStateF isEqualTo "PARKED" && {_awWhyF isEqualTo "NO_LOCK"}] call _fnc_check;
    ([[["lockBusy", true], ["crewSeated", false]]] call _fnc_assignWait) params ["", "_awStateP", "", "_awWhyP"];
    ["and a launch with no pilot seated is not waited for either",
        _awStateP isEqualTo "PARKED" && {_awWhyP isEqualTo "NO_PILOT_NO_LOCK"}] call _fnc_check;
    ([[["lockBusy", true], ["airborne", true], ["atHome", false]]] call _fnc_assignWait) params ["", "_awStateA", "_awEffA"];
    ["one that has lifted off while it waited is recovered, not kept waiting",
        _awStateA isEqualTo "RECOVERING" && {"assignFailed" in _awEffA}] call _fnc_check;
    ([[["lockBusy", true], ["deckHome", true]]] call _fnc_assignWait) params ["", "_awStateD", "_awEffD"];
    ["a plane on a deck, which nothing holds still, does not wait",
        _awStateD isEqualTo "PARKED" && {!("waitingForRunway" in _awEffD)}] call _fnc_check;
    ([[["lockBusy", true], ["playerPassenger", true], ["anyPlayerAboard", true]]] call _fnc_assignWait) params ["", "", "_awEffPP"];
    ["nor does one with a player sitting in it on an empty tank",
        !("waitingForRunway" in _awEffPP)] call _fnc_check;
    // The waits are counted apart from the attempts LAUNCHING's one forced
    // launch is counted on, so a launch that waited still gets it.
    ([[["lockBusy", true]]] call _fnc_assignWait) params ["_lw1"];
    ([[["lockBusy", true]], 1121, _lw1] call _fnc_assignWait) params ["_lw2"];
    ([[["lockHeld", true]], 1150, _lw2] call _fnc_assignWait) params ["_lw3", "_lwState3"];
    ["a launch that waited for the runway still launches when it gets it",
        _lwState3 isEqualTo "LAUNCHING" && {([_lw3, "attempts", 0] call ALIVE_fnc_hashGet) == 0}] call _fnc_check;
    private _lwDeadline = [_lw3, "deadlineAt", 0] call ALIVE_fnc_hashGet;
    // On its route since before its deadline, so it has had its fresh window.
    [_lw3, "taxiedOutAt", 1160] call ALIVE_fnc_hashSet;
    private _lwOut = [_m, "step", [_lw3, [[["crewSeated", true], ["lockHeld", true], ["needsRunway", true],
        ["fixedWing", true], ["launchInProgress", false], ["taxiOutAt", 1160]]] call _fnc_obs, "", _lwDeadline + 1]] call ALIVE_fnc_ATOMachine;
    ["and is still forced up if its take-off stalls, the waits having cost it nothing",
        "forceLaunch" in (_lwOut select 2)] call _fnc_check;
    private _pk = [_m, "newRow", ["BLU_F_0", [[100,100,0], 0, "terrain"]]] call ALIVE_fnc_ATOMachine;
    [_pk, "state", "PARKED"] call ALIVE_fnc_hashSet;
    [_pk, "readyAt", 0] call ALIVE_fnc_hashSet;
    [_pk, "runwayWaits", 3] call ALIVE_fnc_hashSet;
    [_pk, "sortie", ["CAS", [100,100,0], 600, 2000, "s1", [], ""]] call ALIVE_fnc_hashSet;
    private _pkOut = [_m, "step", [_pk, [[["fixedWing", true], ["needsRunway", true]]] call _fnc_obs, "ASSIGN", 1000]] call ALIVE_fnc_ATOMachine;
    ["each launch gets its own waits: the count is cleared on the way in",
        (([(_pkOut select 0), "state", ""] call ALIVE_fnc_hashGet) isEqualTo "ASSIGNED")
        && {([(_pkOut select 0), "runwayWaits", 3] call ALIVE_fnc_hashGet) == 0}] call _fnc_check;

    if (count _fails == 0) then {
        diag_log "=== ATO Machine test: ALL PASS ===";
    } else {
        diag_log format ["=== ATO Machine test: %1 FAILURE(S): %2 ===", count _fails, _fails];
    };
};

"ATO Machine test started, results follow in the log"
