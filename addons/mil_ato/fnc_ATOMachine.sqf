#include "\x\alive\addons\mil_ato\script_component.hpp"
SCRIPT(machine);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ATOMachine
Description:
The airframe state table. One aircraft, one row, one step at a time.

PURE. It reads a row, what the world currently looks like, and any command, and
returns a new row plus the orders that row should be flying and the effects
somebody else should apply. It touches no object, reads no profile, and has no
side effects, so it can be exercised completely without a mission running.

Two properties are the point of it.

An aircraft can never end up with no orders. Every state that is not resting
carries a deadline and issues orders, and every input, including one this table
has never heard of, lands on a state that is in the table. Four seconds from
"has no more waypoints" to destroyed is what the old machine did, because an
unhandled transition left an airframe flying with nothing to do.

A player flying an aircraft is not a state the machine can order around. While a
player is aboard and in control the table issues nothing at all: no orders, no
repositions, no crew changes. A player merely riding along is a MODIFIER rather
than a state, so the sortie keeps its deadlines, but every effect that would
teleport the aircraft is refused while they are in it.

step(row, obs, cmd, now) -> [row, orders, effects]

Parameters:
Nil or Array - If Nil, return a new instance. If a hash, reference an existing one.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function

Examples:
(begin example)
_m = [nil, "create"] call ALIVE_fnc_ATOMachine;
_out = [_m, "step", [_row, _obs, "", 120]] call ALIVE_fnc_ATOMachine;
_out params ["_row2", "_orders", "_effects"];

(end)

See Also:
<ALIVE_fnc_ATOLedger>, <ALIVE_fnc_ATOSurface>

Author:
Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_ATOMachine

// The three states with no deadline. Everything else must carry one, or an
// aircraft can sit in it for the rest of the mission.
#define REST_STATES ["PARKED","PLAYER_FLOWN","LOST"]

#define ALL_STATES ["PARKED","PLAYER_FLOWN","ASSIGNED","LAUNCHING","ENROUTE","ON_STATION","RTB","LANDING","RECOVERING","LOST"]

// Effects that move an aircraft. None of them may be applied with a player in
// it, whether they are flying it or just aboard. A catapult tows the aircraft
// onto the wire before it fires, so it moves the aircraft as surely as any of
// the others.
// The kinds of sortie that are supposed to shoot. A patrol and an
// interception do their job by being present and reconnaissance by looking, so
// none of those three firing anything is the expected outcome rather than a
// stalled sortie.
#define PROSECUTING_TYPES ["SEAD","CAS","Strike","OCA"]

#define TELEPORTS ["airborneStart","forceLaunch","virtualLaunch","placeOnSlot","forceLanded","quickPark","catapult"]

private ["_result"];

TRACE_1("ATO Machine - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

_result = true;

switch(_operation) do {

    case "create": {
        _result = [[["class", MAINCLASS]]] call ALIVE_fnc_hashCreate;
    };

    // Every attach and every restore starts here. The machine does not assume
    // it knows what an aircraft was doing before it was handed one: it looks.
    case "entryState": { _result = "RECOVERING"; };

    case "states": { _result = + ALL_STATES; };
    case "restStates": { _result = + REST_STATES; };

    // A blank row, so a caller never has to know the field list.
    case "newRow": {
        _args params [["_tail","",[""]], ["_home",[],[[]]]];
        _result = [[
            ["tail", _tail],
            ["state", "RECOVERING"],
            ["home", + _home],
            ["enteredAt", 0],
            ["deadlineAt", 0],
            ["readyAt", 0],
            ["playerFreeSince", -1],
            ["attempts", 0],
            ["sortie", []],
            // How much ordnance the aircraft had when it reached its station,
            // so that whether it has used any can be answered. Minus one means
            // it has not reached one.
            ["ordnanceAt", -1],
            ["reason", ""]
        ]] call ALIVE_fnc_hashCreate;
    };

    case "step": {
        _args params [
            ["_row",[],[[]]],
            ["_obs",[],[[]]],
            ["_cmd","",[""]],
            ["_now",0,[0]]
        ];

        // Work on a COPY. The caller's row is an input, and a step that edits
        // its input is not something you can replay, reason about, or test by
        // feeding it the same row twice.
        _row = [_row] call ALIVE_fnc_hashCopy;

        private _fnc_o = { [_obs, _this, false] call ALIVE_fnc_hashGet };
        private _fnc_n = { [_obs, _this, 0] call ALIVE_fnc_hashGet };

        private _state = [_row,"state","RECOVERING"] call ALIVE_fnc_hashGet;
        // An unknown state is not a reason to do nothing. Recover from it.
        if !(_state in ALL_STATES) then { _state = "RECOVERING" };

        private _orders = [];
        private _effects = [];
        private _next = _state;
        private _reason = "";

        private _playerPassenger = "playerPassenger" call _fnc_o;
        private _remote = "remote" call _fnc_o;
        private _airborne = "airborne" call _fnc_o;
        private _atHome = "atHome" call _fnc_o;
        // A fixed wing aircraft whose home is a ship. It cannot take off down
        // a runway and cannot come down on a pad, so it launches off a
        // catapult and recovers onto the wire. A helicopter on the same ship
        // is lifted and landed the way it is anywhere else, and a VTOL is a
        // helicopter here. Both facts come from the observation, because
        // this table reads no config and never looks at a home's shape.
        private _deckPlane = ("deckHome" call _fnc_o) && {"fixedWing" call _fnc_o};
        // A commander with no airfield. Its aircraft are held at a point in the
        // air, so there is no runway to take, no pad to come down on and no
        // deck to be shot off: they are let go, and they are put back.
        private _virtualHome = "virtualHome" call _fnc_o;

        // Whether this aircraft needs a RUNWAY to come back to, which is not
        // the same question as whether it can be catapulted off one. A VTOL is
        // never shot off a wire and still cannot land on a parking stand:
        // measured, it was doing 139 km/h at three metres when it was
        // destroyed. So the landing branch asks this and the launch branch asks
        // about fixed wing.
        private _needsRunway = "needsRunway" call _fnc_o;

        // And whether a launch this module started is still running on the
        // hull. The table cannot read a variable off an object, so the observer
        // reads the stamp and reports it.
        private _launching = "launchInProgress" call _fnc_o;
        private _expired = ([_row,"deadlineAt",0] call ALIVE_fnc_hashGet) > 0
                        && {_now >= ([_row,"deadlineAt",0] call ALIVE_fnc_hashGet)};

        // ---- the priority ladder ------------------------------------------
        // Order matters and is the same for every state. A lost hull is lost
        // whatever else is true of it; a player in control outranks any command
        // the commander wanted to give.

        if ("objectLost" call _fnc_o) then {
            _next = "LOST";
        } else {
            if ("playerControl" call _fnc_o) then {
                _next = "PLAYER_FLOWN";
            } else {
                switch (true) do {

                    // ---- commands ------------------------------------------
                    case (_cmd isEqualTo "RETIRE"): { _next = "LOST"; _reason = "retired"; };
                    case (_cmd isEqualTo "CANCEL" && {!(_state in ["PARKED","LOST"])}): {
                        _next = "RTB"; _reason = "CANCELLED";
                    };
                    case (_cmd isEqualTo "ASSIGN" && {_state isEqualTo "PARKED"}
                          && {_now >= ([_row,"readyAt",0] call ALIVE_fnc_hashGet)}): {
                        _next = "ASSIGNED";
                    };
                    case (_cmd isEqualTo "REROUTE" && {_state isEqualTo "ON_STATION"}): {
                        _next = "ENROUTE";
                    };
                    case (_cmd isEqualTo "RELEASE" && {_state isEqualTo "PLAYER_FLOWN"}): {
                        _next = if (_atHome) then {"PARKED"} else {"RECOVERING"};
                    };

                    // ---- crew lost in the air ------------------------------
                    // The airframe is flying with nobody in it. Recover before
                    // anything else is considered.
                    //
                    // Not while ALREADY recovering: that state is the one that
                    // knows what to do about a crewless hull, and matching here
                    // would send it back to itself every tick and never let its
                    // own rules run, so the aircraft would fly on empty forever.
                    case ("crewLoss" call _fnc_o && {_airborne} && {!(_state isEqualTo "RECOVERING")}): {
                        _next = "RECOVERING";
                    };

                    // ---- the state's own rules -----------------------------
                    default {
                        switch (_state) do {

                            case "PARKED": {
                                if (!_atHome) then { _next = "RECOVERING" };
                            };

                            case "PLAYER_FLOWN": {
                                // Nobody controlling and nobody aboard. In the
                                // air that is immediate: the aircraft is empty
                                // and falling. On the ground a player who got
                                // out is probably coming back, so it waits.
                                if !("anyPlayerAboard" call _fnc_o) then {
                                    if (_airborne) then {
                                        _next = "RECOVERING";
                                    } else {
                                        private _since = [_row,"playerFreeSince",-1] call ALIVE_fnc_hashGet;
                                        private _grace = if (isNil "ALIVE_playerOccupantGrace") then {300} else {ALIVE_playerOccupantGrace};
                                        if (_since < 0) then {
                                            [_row,"playerFreeSince",_now] call ALIVE_fnc_hashSet;
                                        } else {
                                            if (_now - _since >= _grace) then {
                                                _next = if (_atHome) then {"PARKED"} else {"RECOVERING"};
                                            };
                                        };
                                    };
                                } else {
                                    [_row,"playerFreeSince",-1] call ALIVE_fnc_hashSet;
                                };
                            };

                            case "ASSIGNED": {
                                if ("crewSeated" call _fnc_o && {"lockHeld" call _fnc_o}) then {
                                    _next = "LAUNCHING";
                                } else {
                                    if (_expired) then {
                                        // The hull never moved, so it simply
                                        // goes back to being parked and the
                                        // request is handed back to be re-let.
                                        _effects append ["standDownCrew","unlock","assignFailed"];
                                        _next = "PARKED";
                                    };
                                };
                            };

                            case "LAUNCHING": {
                                if (_airborne) then {
                                    _effects pushBack "unlock";
                                    _next = "ENROUTE";
                                } else {
                                    // A deadline that falls due inside a running
                                    // launch waits for it.
                                    //
                                    // The launch owns the aircraft for a minute
                                    // and the deadline is three minutes, so they
                                    // can overlap. When they did, the table
                                    // teleported the aircraft six hundred metres
                                    // up while the sequence was still pinning it
                                    // to the deck: the two fought frame by frame,
                                    // the sequence won, and the table had already
                                    // given up on a launch that then completed
                                    // underneath it.
                                    if (_expired && {!_launching}) then {
                                        if (([_row,"attempts",0] call ALIVE_fnc_hashGet) < 1 && {!_playerPassenger}) then {
                                            _effects pushBack "forceLaunch";
                                            [_row,"attempts",1] call ALIVE_fnc_hashSet;
                                        } else {
                                            _next = "RECOVERING";
                                        };
                                    } else {
                                        // Asked for EVERY tick it is still on the
                                        // deck, the way the approach is re-aimed
                                        // every tick. A refusal (no free catapult,
                                        // the ship's parts not found) is retried
                                        // next tick rather than lost, and while a
                                        // launch is under way the effect answers
                                        // "matched" and does not start a second
                                        // one underneath it. The deadline above
                                        // is the backstop, and forceLaunch keeps
                                        // its job as the last resort.
                                        // Not with somebody aboard. The filter
                                        // below strips a teleport in that case
                                        // and notes a refusal, so asking anyway
                                        // put one refusal in the log every two
                                        // seconds until the deadline.
                                        if (_deckPlane && {!_playerPassenger}) then {
                                            _effects pushBack "catapult";
                                        };
                                        // Asked again every tick, for the same
                                        // reason: a refusal is retried rather
                                        // than lost, and once it is up the
                                        // effect answers matched and does
                                        // nothing. Not with somebody aboard, or
                                        // the filter below notes a refused
                                        // teleport every two seconds.
                                        if (_virtualHome && {!_playerPassenger}) then {
                                            _effects pushBack "virtualLaunch";
                                        };
                                    };
                                };
                            };

                            case "ENROUTE": {
                                if ("onStation" call _fnc_o) then {
                                    _next = "ON_STATION";
                                } else {
                                    if (("fuel" call _fnc_n) < 0.2) then {
                                        _next = "RTB"; _reason = "RETURN_FUEL";
                                    } else {
                                        if (_expired) then { _next = "RTB"; _reason = "RETURN" };
                                    };
                                };
                            };

                            case "ON_STATION": {
                                // Has it actually done anything.
                                //
                                // An aircraft that reaches its station and then
                                // never prosecutes used to sit there until its
                                // ordinary sortie clock ran out, which was
                                // recorded against a drone that held over its
                                // target and did nothing for the whole
                                // operation. Nothing noticed, because being on
                                // station is what it was asked to do.
                                //
                                // Only for the kinds of sortie that are
                                // supposed to shoot. A patrol and an
                                // interception are doing their job by being
                                // there, and reconnaissance by looking, so
                                // firing nothing is the expected outcome for
                                // all three and bringing them home early would
                                // be the fault rather than the fix.
                                //
                                // Judged on the round count, and on ORDNANCE
                                // rounds only. Counting everything aboard
                                // counted the countermeasures, so an aircraft
                                // that had dropped flares and fired nothing
                                // read as having been in the fight.
                                private _sortieNow = [_row,"sortie",[]] call ALIVE_fnc_hashGet;
                                private _kindNow = if (count _sortieNow > 0 && {(_sortieNow select 0) isEqualType ""}) then { _sortieNow select 0 } else { "" };
                                private _lenNow = if (count _sortieNow > 2 && {(_sortieNow select 2) isEqualType 0}) then { _sortieNow select 2 } else { 600 };
                                private _hadOrdnance = [_row,"ordnanceAt",-1] call ALIVE_fnc_hashGet;
                                private _onStationFor = _now - ([_row,"enteredAt",_now] call ALIVE_fnc_hashGet);
                                private _stalled = (_kindNow in PROSECUTING_TYPES)
                                    && {_hadOrdnance > 0}
                                    && {("ordnance" call _fnc_n) >= _hadOrdnance}
                                    && {!("targetsGone" call _fnc_o)}
                                    && {_onStationFor > ((_lenNow * 0.6) max 120)};

                                switch (true) do {
                                    case (_stalled): { _next = "RTB"; _reason = "RETURN"; };
                                    case (("fuel" call _fnc_n) < 0.2):   { _next = "RTB"; _reason = "RETURN_FUEL"; };
                                    // Out of ordnance, and it had some to
                                    // be out of. Both halves are needed: a
                                    // transport and a scout carry none on a
                                    // full load, so the second half is what
                                    // keeps them on station.
                                    case (("armed" call _fnc_o) && {("ordnance" call _fnc_n) <= 0}): { _next = "RTB"; _reason = "RETURN_AMMO"; };
                                    case (("damage" call _fnc_n) > 0.5): { _next = "RTB"; _reason = "RETURN_DAMAGE"; };
                                    case ("targetsGone" call _fnc_o):    { _next = "RTB"; _reason = "RETURN"; };
                                    case (_expired):                     { _next = "RTB"; _reason = "RETURN"; };
                                };
                            };

                            case "RTB": {
                                // Nobody near home and nobody riding along, so
                                // there is nothing to see: put it on its slot
                                // and skip the approach entirely. No lock is
                                // taken, because no runway is used.
                                // Nobody to see it go. For a virtual home that
                                // is asked of the AIRCRAFT rather than of home:
                                // there is no approach and no landing to watch,
                                // so the only way back is to be put there, and
                                // the standing orders have already turned it
                                // away from the target. Waiting until nobody is
                                // near an empty point in the sea would be
                                // waiting on a question nothing ever answers
                                // differently.
                                private _unseen = ("playersWithin1000Home" call _fnc_n) == 0;
                                if (_virtualHome) then {
                                    _unseen = ("playersWithin1000Hull" call _fnc_n) == 0;
                                };
                                if (_unseen && {!_playerPassenger}) then {
                                    _effects pushBack "placeOnSlot";
                                    _next = "PARKED";
                                } else {
                                    private _near = "nearHome" call _fnc_o;
                                    switch (true) do {
                                        // Runway in hand: go and land on it.
                                        case (_near && {"lockHeld" call _fnc_o}): { _next = "LANDING" };

                                        // Almost dry. Land regardless, and say so.
                                        case (_near && {("fuel" call _fnc_n) < 0.1}): {
                                            _effects pushBack "emergencyLanding";
                                            _next = "LANDING";
                                        };

                                        // Close to home with no runway yet: ASK for
                                        // one and hold off a tick. Only checking
                                        // whether it already had one meant it never
                                        // got one, and it circled until its time
                                        // ran out.
                                        case (_near): { _effects pushBack "lock" };

                                        case (_expired): {
                                            [_row,"attempts",([_row,"attempts",0] call ALIVE_fnc_hashGet) + 1] call ALIVE_fnc_hashSet;
                                            _next = "RECOVERING";
                                        };
                                    };
                                };
                            };

                            case "LANDING": {
                                if ("landed" call _fnc_o) then {
                                    // Wheels down is not the same as home. An
                                    // aircraft that put itself on the grass short
                                    // of the field is not parked, and calling it
                                    // parked leaves the stand empty and the
                                    // airframe in that field for the rest of the
                                    // campaign. Recovery already owns the problem
                                    // of a landed aircraft in the wrong place, so
                                    // it is handed there rather than solved twice.
                                    // Both destinations release the runway on
                                    // entry, so this does not release it itself.
                                    // Whether it CAN be tidied is asked before whether it is close
                                    // enough to leave alone. Asked the other way round, a touchdown
                                    // 26 m out satisfied atHome, took the branch that only turns the
                                    // aircraft round, and was never put on its stand, so the fleet
                                    // drifted a little further off its pads with every sortie.
                                    // placeOnSlot itself now decides what counts as already on the
                                    // slot, so all this has to settle is whether tidying is allowed.
                                    //
                                    // The tidying is deliberate and it replaces a long argument with
                                    // the engine. The aim of this state is that the aircraft ends up
                                    // on its stand, not that a particular engine command does the
                                    // placing, and landAt has been measured issuing no command at
                                    // all: every descent so far was the height floor letting it sink
                                    // wherever its last order left it, 26 to 38 m out. Moving a
                                    // stopped aircraft thirty metres across an apron is also a far
                                    // smaller thing to see than the mid-air repositioning this
                                    // module used to do.
                                    //
                                    // Landing somewhere else entirely is still recovery's problem.
                                    // On a DECK the player count is the wrong
                                    // question, and leaving it in place meant a
                                    // jet that had just landed correctly was
                                    // never moved.
                                    //
                                    // On a carrier the players are ON the ship,
                                    // so "nobody within three hundred metres" is
                                    // false essentially always, and an arrested
                                    // jet stops on the landing area tens of
                                    // metres from its stand, so being at home is
                                    // false too. The row fell through to recovery
                                    // and stood on the wire for the whole ten
                                    // minute deadline, and deck parking is kept
                                    // clear of that strip precisely because an
                                    // airframe on it blocks a hook and wire
                                    // recovery. So the next jet back had the wire
                                    // blocked by the last one.
                                    //
                                    // The trade is deliberate and it is the
                                    // opposite of the one made for wrecks: a
                                    // wreck that vanishes in front of somebody
                                    // costs more than a wreck that stays, but an
                                    // aircraft that stays on the wire costs every
                                    // later recovery. So it is moved, and being
                                    // seen to move is the cheaper price.
                                    // Standing on the runway counts the same
                                    // way a deck does, and for the same reason.
                                    //
                                    // An aircraft that has stopped on it blocks
                                    // every aircraft behind it, and
                                    // waiting for nobody to be within three
                                    // hundred metres of a working airfield is
                                    // waiting for something that does not
                                    // happen. So it is moved, and being seen to
                                    // move is the cheaper price.
                                    //
                                    // This is what is left of the stuck-taxi
                                    // problem. The rest of it was about
                                    // recovering an aircraft stuck taxiing OUT,
                                    // and aircraft are no longer taxied out at
                                    // all.
                                    private _canTidy = ("nearHome" call _fnc_o)
                                        && {(("playersWithin300" call _fnc_n) == 0)
                                            || {"deckHome" call _fnc_o}
                                            || {"onRunway" call _fnc_o}}
                                        && {!_playerPassenger};
                                    if (_canTidy) then {
                                        _effects pushBack "placeOnSlot";
                                        _effects pushBack "turnaround";
                                        _next = "PARKED";
                                    } else {
                                        if (_atHome) then {
                                            // Down at its own field with somebody watching or
                                            // riding. A crooked park is a smaller thing to see
                                            // than an aircraft sliding sideways across the apron,
                                            // so it keeps the spot it chose.
                                            _effects pushBack "turnaround";
                                            _next = "PARKED";
                                        } else {
                                            _next = "RECOVERING";
                                        };
                                    };
                                } else {
                                    // Re-aimed EVERY tick while it is still up.
                                    // A landing order is advisory: the engine
                                    // drifts an aircraft back to its cruise
                                    // height and evasive AI can discard the
                                    // order outright minutes after it was
                                    // given, so issuing it once on entry is not
                                    // enough. This is what logistics does at
                                    // each of its own landings and why.
                                    //
                                    // A plane coming back to a ship is asked for
                                    // the deck recovery instead: a pad approach
                                    // is a helicopter's, with an arrival gate a
                                    // jet cannot satisfy. A helicopter on the same
                                    // ship keeps the pad path.
                                    //
                                    // And a plane coming back to LAND is asked
                                    // for the runway, which is the fault this
                                    // branch exists to fix. Every aircraft used
                                    // to be aimed at its own parking stand, and
                                    // a stand is twelve metres across. Measured
                                    // on Stratis from 900 m out: the helicopter
                                    // came down two metres from its stand and
                                    // lived; the jet overflew at twenty four
                                    // metres, climbed away and was destroyed
                                    // 1649 m out; the VTOL was doing 139 km/h
                                    // at three metres when it was destroyed.
                                    // Every fixed-wing aircraft this module
                                    // owned was being destroyed on its way home,
                                    // and nothing caught it because the landing
                                    // checks only ever flew a helicopter.
                                    switch (true) do {
                                        case (_deckPlane): { _effects pushBack "deckRecover" };
                                        case (_needsRunway): { _effects pushBack "landOnRunway" };
                                        default { _effects pushBack "landAtPad" };
                                    };
                                    if (_expired) then {
                                        private _a = [_row,"attempts",0] call ALIVE_fnc_hashGet;
                                        if (_a < 1) then {
                                            // The aim is already re-issued
                                            // every tick above, so a deadline
                                            // here means the approach is not
                                            // working rather than that it was
                                            // forgotten. Count it and let the
                                            // next expiry put it down.
                                            [_row,"attempts",_a + 1] call ALIVE_fnc_hashSet;
                                        } else {
                                            if (_playerPassenger) then {
                                                // Never put a hull on the ground
                                                // with somebody in it. Ask again.
                                                _effects pushBack "retryLanding";
                                            } else {
                                                _effects pushBack "forceLanded";
                                                _next = "PARKED";
                                            };
                                        };
                                    };
                                };
                            };

                            case "RECOVERING": {
                                switch (true) do {
                                    case (_remote): { _effects pushBack "takeOwnership"; };
                                    case (_airborne && {"crewLoss" call _fnc_o}): {
                                        _effects pushBack "recrewInPlace";
                                    };
                                    case (_airborne): {
                                        if (("playersWithin1000Hull" call _fnc_n) == 0 && {!_playerPassenger}) then {
                                            _effects pushBack "placeOnSlot";
                                            _next = "PARKED";
                                        } else {
                                            if (([_row,"attempts",0] call ALIVE_fnc_hashGet) < 2) then {
                                                [_row,"attempts",([_row,"attempts",0] call ALIVE_fnc_hashGet) + 1] call ALIVE_fnc_hashSet;
                                                _next = "RTB"; _reason = "RETURN";
                                            } else {
                                                // A held aircraft is put back
                                                // where it lives. forceLanded
                                                // sets it down on the terrain,
                                                // and over water the terrain is
                                                // the sea bed.
                                                if (_virtualHome) then {
                                                    _effects pushBack "placeOnSlot";
                                                } else {
                                                    _effects pushBack "forceLanded";
                                                };
                                                _next = "PARKED";
                                            };
                                        };
                                    };
                                    case (_atHome): { _next = "PARKED"; };
                                    case (("playersWithin1000Hull" call _fnc_n) == 0): {
                                        _effects pushBack "placeOnSlot";
                                        _next = "PARKED";
                                    };
                                    default {
                                        // On the ground, away from home, with
                                        // people watching. It has to fly back.
                                        if (_expired) then {
                                            _effects pushBack "placeOnSlot";
                                            _next = "PARKED";
                                        };
                                    };
                                };
                            };

                            case "LOST": { };
                        };
                    };
                };
            };
        };

        // ---- entry effects and the new row --------------------------------
        private _changed = !(_next isEqualTo _state);

        if (_changed) then {
            // Exit effects: what the state being LEFT has to give back. The
            // only one so far is the approach, which may have had a landing pad
            // minted for it, and that object must not outlive the state that
            // needed it. Fires on EVERY way out of LANDING, including the ones
            // that are not a landing at all, because an aircraft that is lost
            // or taken over by a player on final is still an approach that
            // ended.
            if (_state isEqualTo "LANDING") then { _effects pushBack "releaseApproach" };

            [_row,"state",_next] call ALIVE_fnc_hashSet;
            [_row,"enteredAt",_now] call ALIVE_fnc_hashSet;
            if (!(_reason isEqualTo "")) then { [_row,"reason",_reason] call ALIVE_fnc_hashSet };

            // Attempts belong to the run at a state, not to the aircraft.
            if (_next in ["PARKED","PLAYER_FLOWN","LOST","ENROUTE","ON_STATION"]) then {
                [_row,"attempts",0] call ALIVE_fnc_hashSet;
            };
            if !(_next isEqualTo "PLAYER_FLOWN") then {
                [_row,"playerFreeSince",-1] call ALIVE_fnc_hashSet;
            };

            switch (_next) do {
                case "PARKED": {
                    _effects append ["unlock","engineOff","clearOrders"];
                    if (!_playerPassenger) then { _effects pushBack "standDownCrew" };
                };
                case "PLAYER_FLOWN": { _effects append ["unlock","releaseTargets","sortiePlayerControl"]; };
                case "LOST":         { _effects append ["unlock","releaseTargets","broadcastLost","markLost","onLost"]; };
                case "RECOVERING":   {
                    _effects append ["unlock","clearOrders"];
                    // An aircraft recovering ON THE GROUND is one that came down
                    // somewhere it does not belong, and it will not stay down on
                    // its own: a crewed helicopter with a running engine and an
                    // empty waypoint list lifts off again, which is how one flew
                    // three circuits of the airfield after landing correctly.
                    // PARKED has always stopped the engine; this state never did.
                    // Not applied in the air, where recovering means still flying.
                    if (!_airborne) then { _effects pushBack "engineOff" };
                };
                case "ASSIGNED":     { _effects append ["mintCrew","seatCrew","lock"]; };
                // Start the engine as well as saying it is going. Announcing a
                // departure does not make one happen.
                //
                // A plane on a ship is shot off a catapult, and the engine is
                // started FIRST so the launch sequence finds one running.
                case "LAUNCHING":    {
                    switch (true) do {
                        case (_deckPlane): { _effects append ["engineOn","catapult","broadcastStart"]; };
                        case (_virtualHome): { _effects append ["engineOn","virtualLaunch","broadcastStart"]; };
                        default { _effects append ["engineOn","broadcastStart"]; };
                    };
                };
                case "ON_STATION":   {
                    _effects append ["broadcastOnStation","revealTargets","sortieArrived"];
                    [_row,"ordnanceAt", "ordnance" call _fnc_n] call ALIVE_fnc_hashSet;
                };
                case "RTB":          { _effects append ["broadcastReturn","releaseTargets","sortieReturning"]; };
                // Nothing on entry. The standing order for this state is a
                // landing waypoint at the home pad, and that is the engine
                // feature for "fly there and come down".
                //
                // This used to also emit landingPlan, which issues land "LAND".
                // That is an IMMEDIATE order meaning descend where you are, and
                // it overrides the waypoint that was taking the aircraft to the
                // pad. Measured: issued at 117 m and a kilometre short, over the
                // sea, the helicopter stopped dead and hovered over water for
                // the rest of the run, because it cannot land there and it was
                // no longer navigating to anywhere it could.
                //
                // The effect is kept for retryLanding and emergencyLanding,
                // which fire when the aircraft is already low and near, and
                // where landing on the spot is the whole intention.
                // Nothing on entry: the state re-aims every tick instead.
                case "LANDING":      { };
                case "ENROUTE":      { };
            };
        };

        // A player in the aircraft refuses every effect that would move it. This
        // is the one rule that outranks the table, and it is applied here rather
        // than in each state so no state can forget it.
        if (_playerPassenger || {_next isEqualTo "PLAYER_FLOWN"}) then {
            private _kept = _effects select { !(_x in TELEPORTS) };
            if (!(_kept isEqualTo _effects)) then {
                _effects = _kept;
                _effects pushBack "refusedTeleportPlayerAboard";
            };
        };
        // Nothing local may be done to a hull this machine does not own.
        if (_remote) then {
            _effects = _effects select { _x in ["takeOwnership","unlock"] };
        };

        // ---- deadline and orders ------------------------------------------
        // Every state that is not resting gets a finite deadline. Without one
        // an aircraft can sit in a state forever, which is how a sortie ends
        // with an airframe flying nowhere.
        if (_next in REST_STATES) then {
            [_row,"deadlineAt",0] call ALIVE_fnc_hashSet;
        } else {
            if (_changed || {([_row,"deadlineAt",0] call ALIVE_fnc_hashGet) <= 0}) then {
                private _sortie = [_row,"sortie",[]] call ALIVE_fnc_hashGet;
                private _duration = if (count _sortie > 2) then {_sortie select 2} else {600};
                private _span = switch (_next) do {
                    case "ASSIGNED":   { 120 };
                    case "LAUNCHING":  { (_duration / 3) max 180 };
                    case "ENROUTE":    { (2 * _duration) max 120 };
                    case "ON_STATION": { _duration max 120 };
                    case "RTB":        { (2 * _duration) max 120 };
                    case "LANDING":    { 300 };
                    case "RECOVERING": { 600 };
                    default            { 300 };
                };
                [_row,"deadlineAt", _now + _span] call ALIVE_fnc_hashSet;
            };
        };

        // Standing orders. Every state that is flying has something to fly, and
        // every airborne chain ends holding rather than running out.
        _orders = switch (_next) do {
            case "ENROUTE":    { ["MOVE_STATION","LOITER"] };
            case "ON_STATION": { ["EXECUTE","LOITER"] };
            case "RTB":        { ["MOVE_APPROACH","LOITER"] };
            // Nothing. There is no landing waypoint type in this engine, so a
            // chain cannot express "come down here" and the attempt produced a
            // typeless waypoint, which is no order at all. The landAtPad effect
            // on entry owns this state, and a competing chain would only fight
            // it the way a pending move already did.
            case "LANDING":    { [] };
            // Ending in a hold, for the reason the tasker's own list gives:
            // a launch that is a teleport rather than a roll is already in the
            // air by the time orders are issued, and an airborne chain that
            // does not end in a hold is refused.
            case "LAUNCHING":  { ["TAKEOFF","LOITER"] };
            case "ASSIGNED":   { ["HOLD"] };
            case "RECOVERING": { ["HOLD"] };
            case "PARKED":     { [] };
            case "PLAYER_FLOWN": { [] };
            case "LOST":       { [] };
            default            { ["HOLD"] };
        };
        // A player flying it is given nothing at all.
        if (_next isEqualTo "PLAYER_FLOWN") then { _orders = [] };

        _result = [_row, _orders, _effects];
    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};

TRACE_1("ATO Machine - output",_result);

_result;
