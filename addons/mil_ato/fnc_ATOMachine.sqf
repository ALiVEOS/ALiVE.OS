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

// The one extension a landing gets at its deadline when it is still flying and
// plainly coming down: how long, and what counts as coming down (below the low
// height, or a plane below the circuit height and descending).
#define LANDING_EXTENSION 180
#define LANDING_LOW_AGL 300
#define LANDING_CIRCUIT_AGL 1500
// And only within this distance of home. On LAN a Blackfish that had touched
// down and flown off again was given the three minutes while 231 m up and 48 km
// away, level, and was put down from there anyway. A jet flying its circuit is
// several kilometres out and still coming down.
#define LANDING_EXTENSION_REACH 5000

// A plane on land leaves along its airport's taxi route. Once it is stood on it,
// it has at least this long to get into the air: the wait for the route to clear
// no longer eats the time it needs to taxi and take off.
#define LAUNCH_TAXI_WINDOW 180
// While the route is blocked it waits on its stand, tank empty, this long at a
// time and this many times, and then it leaves from its stand as it did before
// there was a taxi out, with the launch deadline behind it.
#define LAUNCH_TAXI_WAIT 60
#define LAUNCH_TAXI_WAITS 3
// A plane still rolling down the runway when its time runs out is given this
// much more, once, rather than being thrown into the air mid take-off run. Above
// this speed on the runway it is rolling, below it stopped there.
#define LAUNCH_ROLL_EXTENSION 90
#define LAUNCH_ROLL_SPEED 10

// How long a launch waits each time its runway is held by another of our
// aircraft, and how many times it may wait before it gives up. Six covers the
// LAN queue: a landing that held the runway 4 min 16 s and three launches ahead
// of this one, each holding it until it is up, 100 to 180 s apiece.
#define ASSIGN_LOCK_WAIT 120
#define ASSIGN_LOCK_WAITS 6

#define TELEPORTS ["airborneStart","forceLaunch","virtualLaunch","taxiOut","placeOnSlot","forceLanded","quickPark","catapult"]

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
            // When it came to rest after landing, on the runway or anywhere a
            // plane may only be pausing on its way off, so that it can be seen
            // to land before anything is done with it. Minus one while it is
            // not at rest.
            ["stoppedSince", -1],
            // Whether this landing has had its one extension. Its own field
            // rather than attempts: an aircraft that came round through
            // recovery reaches LANDING with attempts already counted, and would
            // never have been given the time. Cleared on entry to LANDING.
            ["landingExtended", false],
            // How many times this launch has waited for a runway another of
            // our aircraft holds. Its own field rather than attempts, because
            // LAUNCHING's one forced launch is counted on attempts and a wait
            // would have spent it. Cleared on entry to ASSIGNED.
            ["runwayWaits", 0],
            // When this launch was stood on its taxi route, minus one before
            // then; how many times it has waited on its stand for the route to
            // clear; and whether it has had its one extension for a take-off
            // run. All three cleared on entry to LAUNCHING.
            ["taxiedOutAt", -1],
            ["taxiWaits", 0],
            ["launchExtended", false],
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
        // And whether it needs one to take OFF, which only a fixed-wing plane
        // does. A VTOL lifts where it stands, as the launch below already says,
        // so it neither takes the runway lock nor waits for it: on LAN a
        // Blackfish held the runway for eight minutes while three jets waited
        // behind it for a runway it never used. A plane on a ship still takes
        // it.
        private _takesRunway = _needsRunway && {"fixedWing" call _fnc_o};
        // A plane that leaves along a taxi route: fixed wing, on land, not held
        // at a point in the air.
        private _landPlane = ("fixedWing" call _fnc_o) && {!("deckHome" call _fnc_o)} && {!_virtualHome};

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
                                        // The module's own figure when it has one (0 is at
                                        // once), else the profile system's, as before.
                                        private _graceSet = [_obs, "playerGrace", -1] call ALIVE_fnc_hashGet;
                                        private _grace = if (_graceSet isEqualType 0 && {_graceSet >= 0}) then { _graceSet } else {
                                            if (isNil "ALIVE_playerOccupantGrace") then {300} else {ALIVE_playerOccupantGrace}
                                        };
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
                                // Its targets are already gone, so there is nothing to
                                // launch for. On LAN one close support sortie waited
                                // eight minutes for the runway and flew four more to
                                // find its contact dead. Stood down where it is; one
                                // that has lifted off by itself is recovered instead,
                                // as below.
                                if ("targetsGone" call _fnc_o) exitWith {
                                    if (_airborne) then {
                                        _effects pushBack "unlock";
                                        _next = "RECOVERING";
                                    } else {
                                        _next = "PARKED";
                                    };
                                    _reason = "TARGETS_GONE";
                                };
                                // Only an aircraft that uses the runway waits for it.
                                // A helicopter lifts off from its own pad and lands
                                // on it again, and queueing it behind the jets cost
                                // both ways: an Apache that could not get down held
                                // the runway through five minutes of hovering while a
                                // jet behind it ran out of time on NO_LOCK.
                                private _lockOk = !_takesRunway || {"lockHeld" call _fnc_o};
                                if ("crewSeated" call _fnc_o && {_lockOk}) then {
                                    _next = "LAUNCHING";
                                } else {
                                    // Only the runway is missing and another of our
                                    // aircraft has it: wait instead of giving up. On
                                    // LAN an F-22 landing from 6953 m held it for
                                    // 4 min 16 s, and four launches behind it ran out
                                    // of time, went back to planning and each cost its
                                    // sortie an attempt. Waiting costs nothing where
                                    // the plane waits with its tank held empty, so it
                                    // cannot roll: on land, not on a deck (nothing
                                    // holds a plane there), not once it has lifted
                                    // off, and not with a passenger sitting in it.
                                    private _waitForRunway = _expired && {"crewSeated" call _fnc_o} && {!_lockOk}
                                        && {"lockBusy" call _fnc_o}
                                        && {_takesRunway && {!("deckHome" call _fnc_o)} && {!_virtualHome}}
                                        && {!_airborne} && {!_playerPassenger}
                                        && {([_row,"runwayWaits",0] call ALIVE_fnc_hashGet) < ASSIGN_LOCK_WAITS};
                                    if (_waitForRunway) then {
                                        [_row,"runwayWaits",([_row,"runwayWaits",0] call ALIVE_fnc_hashGet) + 1] call ALIVE_fnc_hashSet;
                                        [_row,"deadlineAt",_now + ASSIGN_LOCK_WAIT] call ALIVE_fnc_hashSet;
                                        _effects pushBack "waitingForRunway";
                                    };
                                    if (_expired && {!_waitForRunway}) then {
                                        // Normally the hull never moved, so it
                                        // simply goes back to being parked and
                                        // the request is handed back to be re-let.
                                        //
                                        // Not when it is in the air. A gunship
                                        // lifted off by itself while it waited
                                        // for the runway, ran out of time 199 m
                                        // up, and was parked there: its crew was
                                        // taken off and its engine stopped at
                                        // height. It is recovered instead, which
                                        // brings it home with its crew aboard.
                                        if (_airborne) then {
                                            _effects append ["unlock","assignFailed"];
                                            _next = "RECOVERING";
                                        } else {
                                            _effects append ["standDownCrew","unlock","assignFailed"];
                                            _next = "PARKED";
                                        };
                                        // Which half of the gate it never passed. Half of
                                        // all assignments were expiring here and the log
                                        // could not say whether for want of a pilot or of
                                        // the runway lock, which need different fixes.
                                        _reason = switch (true) do {
                                            case (!("crewSeated" call _fnc_o) && {!_lockOk}): { "NO_PILOT_NO_LOCK" };
                                            case (!("crewSeated" call _fnc_o)): { "NO_PILOT" };
                                            default { "NO_LOCK" };
                                        };
                                    } else {
                                        // No runway yet: ask again. The lock is requested
                                        // once on the way into this state, so an aircraft
                                        // assigned a second after another one lost that race
                                        // and never asked again. It sat out its two minutes
                                        // with the runway free for most of them and went
                                        // back to being parked. The landing approach learnt
                                        // the same lesson. Asked only while it is not held,
                                        // so a lock already won is never extended.
                                        if (!_lockOk) then { _effects pushBack "lock" };
                                    };
                                };
                            };

                            case "LAUNCHING": {
                                // An aircraft that cannot fly is not launched.
                                //
                                // An Apache parked against a hangar lost its
                                // rotors to the hangar as it started up, sat out
                                // its launch, and was then thrown six hundred
                                // metres up by the deadline below with no rotors
                                // and fell. Damage did not warn anybody: measured,
                                // a helicopter with its main rotor, tail rotor or
                                // engine destroyed reads damage 0 and canMove
                                // false.
                                //
                                // canMove is false with an empty tank as well, and
                                // a plane on land keeps its tank empty here until
                                // it has been stood on its taxi route (below). So
                                // a plane this module is holding is never taken for
                                // a broken one, and otherwise a launch is called off
                                // at once only with fuel aboard, which is a broken
                                // aircraft, and at the deadline, where the only
                                // alternative was throwing it into the air. Never
                                // under a catapult shot that is still running.
                                //
                                // Called off, it is put back on its stand and
                                // serviced, which repairs it, and kept off the rota
                                // while that happens. The job goes back to be given
                                // to another aircraft.
                                private _held = "heldOnStand" call _fnc_o;
                                private _cannotFly = !([_obs, "canMove", true] call ALIVE_fnc_hashGet)
                                    && {!_launching} && {!_held}
                                    && {(("fuel" call _fnc_n) > 0) || {_expired}};
                                // On its way for THIS launch: stood on its taxi route
                                // (the stamp from an earlier launch is older than this
                                // state's entry, so it never counts), or not held on
                                // its stand at all, which is a plane that goes from
                                // where it is. Only a held plane is ever asked to be
                                // stood on its route, so one already rolling is never
                                // pulled back to it.
                                private _taxiedOut = _landPlane
                                    && {(([_obs, "taxiOutAt", -1] call ALIVE_fnc_hashGet) >= ([_row,"enteredAt",0] call ALIVE_fnc_hashGet))
                                        || {!_held}};
                                private _onRunwayNow = "onRunway" call _fnc_o;
                                switch (true) do {
                                    case (_airborne): {
                                        _effects pushBack "unlock";
                                        _next = "ENROUTE";
                                    };
                                    case (_cannotFly): {
                                        // Off the rota either way. With somebody
                                        // aboard it is not repaired, and without
                                        // this it was offered the next job at once,
                                        // failed it at once, and did that again
                                        // every few seconds with a radio call each
                                        // time.
                                        [_row,"readyAt",_now + 300] call ALIVE_fnc_hashSet;
                                        if (_playerPassenger) then {
                                            _effects append ["unlock","assignFailed"];
                                            _next = "RECOVERING";
                                        } else {
                                            _effects append ["placeOnSlot","turnaround","unlock","assignFailed"];
                                            _next = "PARKED";
                                        };
                                        _reason = "CANNOT_FLY";
                                    };
                                    default {
                                        private _deadline = [_row,"deadlineAt",0] call ALIVE_fnc_hashGet;

                                        // ---- a plane leaving along its taxi route ----
                                        // It is held on its stand with its tank empty
                                        // until it has been stood on the route, and
                                        // asked for that every tick rather than once.
                                        // On LAN the one ask was refused while a supply
                                        // truck drove along the route; nothing asked
                                        // again, the A-10 was given its fuel anyway,
                                        // drove itself into its tent hangar's doorway
                                        // and sat there with its engine running until
                                        // the deadline threw it 588 m into the air.
                                        // Only an empty tank holds a crewed plane.
                                        //
                                        // With somebody aboard it is not held (see the
                                        // way out of ASSIGNED) and nothing here moves it.
                                        if (_landPlane && {_playerPassenger}) then { _effects pushBack "releaseHold" };
                                        if (_landPlane && {!_playerPassenger}) then {
                                            if (_taxiedOut || {_onRunwayNow}) then {
                                                // On its route: its tank back, its
                                                // engine, the path ahead kept clear, and
                                                // the runway kept while it goes. Each
                                                // answers "done" once done.
                                                _effects append ["releaseHold","engineOn","sweepTaxiPath","lock"];
                                                if (([_row,"taxiedOutAt",-1] call ALIVE_fnc_hashGet) < 0) then {
                                                    [_row,"taxiedOutAt",_now] call ALIVE_fnc_hashSet;
                                                    _deadline = _deadline max (_now + LAUNCH_TAXI_WINDOW);
                                                    [_row,"deadlineAt",_deadline] call ALIVE_fnc_hashSet;
                                                };
                                                // Rolling down the runway when its time
                                                // is up: more time, once. On LAN an A-10
                                                // was thrown 597 m up at its deadline
                                                // just as it began its take-off run.
                                                if (_now >= _deadline && {!_launching} && {_onRunwayNow}
                                                    && {("speed" call _fnc_n) > LAUNCH_ROLL_SPEED}
                                                    && {!([_row,"launchExtended",false] call ALIVE_fnc_hashGet)}) then {
                                                    [_row,"launchExtended",true] call ALIVE_fnc_hashSet;
                                                    _deadline = _now + LAUNCH_ROLL_EXTENSION;
                                                    [_row,"deadlineAt",_deadline] call ALIVE_fnc_hashSet;
                                                    _effects pushBack "launchExtended";
                                                };
                                            } else {
                                                // Not on its route yet: asked again every
                                                // tick, and at its deadline it waits a
                                                // little longer while it has waits left.
                                                //
                                                // The runway is not kept for it from its
                                                // stand. It is taken when the plane is
                                                // stood on its route, by the kernel along
                                                // with the taxi out, so one whose route
                                                // stays blocked lets it lapse and an
                                                // aircraft of ours coming home can land.
                                                // Kept here every tick, a jet shut in its
                                                // hangar kept a returning one circling for
                                                // the whole of its wait.
                                                //
                                                // Nor is it stood on its route, or let go,
                                                // while another of ours has the runway: it
                                                // would be heading for a runway somebody is
                                                // landing on. That wait is not counted
                                                // against it.
                                                //
                                                // Blocked through every wait, it leaves
                                                // from its stand as it did before there was
                                                // a taxi out, taking the runway as it goes:
                                                // its hold is let go here, so next tick it
                                                // counts as on its way. Handing the job back
                                                // instead left an apron whose route stayed
                                                // blocked, by a wreck or a parked vehicle,
                                                // unable ever to launch.
                                                private _busy = "lockBusy" call _fnc_o;
                                                private _leaves = false;
                                                if (_now >= _deadline) then {
                                                    private _waits = [_row,"taxiWaits",0] call ALIVE_fnc_hashGet;
                                                    if (_busy || {_waits < LAUNCH_TAXI_WAITS}) then {
                                                        if (!_busy) then { [_row,"taxiWaits",_waits + 1] call ALIVE_fnc_hashSet };
                                                        _effects pushBack "waitingForTaxiRoute";
                                                    } else {
                                                        _leaves = true;
                                                        _effects append ["lock","releaseHold","leavesFromStand"];
                                                    };
                                                    _deadline = _now + (if (_leaves) then { LAUNCH_TAXI_WINDOW } else { LAUNCH_TAXI_WAIT });
                                                    [_row,"deadlineAt",_deadline] call ALIVE_fnc_hashSet;
                                                };
                                                if (!_leaves && {!_busy}) then { _effects pushBack "taxiOut" };
                                            };
                                        };

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
                                        private _expiredNow = (_deadline > 0) && {_now >= _deadline};
                                        if (_expiredNow && {!_launching}) then {
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
                            };

                            case "ENROUTE": {
                                if ("onStation" call _fnc_o) then {
                                    _next = "ON_STATION";
                                } else {
                                    // Its targets died while it was on its way:
                                    // home now, not after flying out to find that
                                    // out. The same answer ON_STATION gives.
                                    if ("targetsGone" call _fnc_o) exitWith { _next = "RTB"; _reason = "RETURN" };
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
                                        // Runway in hand: go and land on it. A
                                        // helicopter comes down on its own pad and
                                        // never needs the runway to do it.
                                        case (_near && {!_needsRunway || {"lockHeld" call _fnc_o}}): { _next = "LANDING" };

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
                                // A plane down on land is still landing while it
                                // rolls out and taxis off, however slowly it goes,
                                // and it has come home when it reaches the end of
                                // its airport's taxi-off route. Landed alone cannot
                                // say so: for a plane it means under forty km/h on
                                // the ground, which is true for the whole taxi.
                                private _planeDown = _needsRunway && {!("deckHome" call _fnc_o)} && {!_virtualHome}
                                    && {"touchingGround" call _fnc_o} && {("altAGL" call _fnc_n) < 2};
                                private _rolling = _planeDown && {!("landed" call _fnc_o)
                                    || {(abs ("speed" call _fnc_n)) >= 5}
                                    || {"atTaxiOffEnd" call _fnc_o}};
                                if (("landed" call _fnc_o) && {!_rolling}) then {
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
                                    // waiting for nobody to be within a
                                    // kilometre of a working airfield is
                                    // waiting for something that does not
                                    // happen. So it is moved, and being seen to
                                    // move is the cheaper price. A taxiway is
                                    // counted the same way: it blocks the same
                                    // aircraft.
                                    //
                                    // This is what is left of the stuck-taxi
                                    // problem. The rest of it was about
                                    // recovering an aircraft stuck taxiing OUT,
                                    // and a plane now starts its taxi on the
                                    // airport's own route rather than from its
                                    // stand, with the launch deadline behind it
                                    // if it stalls there.
                                    //
                                    // Not the moment it comes to rest on the
                                    // runway, though: that put a Blackfish back on
                                    // its stand the instant it touched down, in
                                    // front of the player watching it land. It is
                                    // given thirty seconds. It will not clear the
                                    // runway by itself in that time or any other:
                                    // measured, a VTOL landed on the centreline and
                                    // sat there with its engine running for five
                                    // minutes without moving. So thirty seconds is
                                    // for being seen to land, and then it is moved.
                                    //
                                    // A plane stopped anywhere else on its way off
                                    // is given the same thirty seconds before it is
                                    // handed to recovery, because it may only be
                                    // pausing. Recovery stops the engine and holds
                                    // it for ten minutes while anyone is about,
                                    // which on a taxiway would shut the airfield,
                                    // so a taxiway is treated as the runway is.
                                    //
                                    // Who counts as watching depends on how far
                                    // the aircraft would be moved. Off its stand
                                    // it is a kilometre, as recovery and the
                                    // return home already use: this was three
                                    // hundred metres, and on Stratis the control
                                    // tower is 188 m off the runway's line with
                                    // only nine of twenty two points along the
                                    // runway within 300 m of it, every one of
                                    // them within 1000 m. On the test server,
                                    // Blackfish landings there came to rest about
                                    // 750 m from the tower, and on LAN one was put
                                    // on its stand the moment it slowed in front
                                    // of a player watching from it. Near its own stand already (within
                                    // sixty metres) it stays at three hundred:
                                    // that slide is short, and one not made now
                                    // is not made soon, because at home it is
                                    // parked where it stopped and short of home
                                    // it waits out recovery's ten minutes, so at
                                    // a kilometre every helicopter that set down
                                    // a little off its pad would stay crooked,
                                    // or stand idle and then jump anyway.
                                    private _onTheRunway = "onRunway" call _fnc_o;
                                    private _inTheWay = _onTheRunway || {"onTaxiway" call _fnc_o};
                                    private _mayWait = _inTheWay || {_planeDown};
                                    private _waited = false;
                                    if (_mayWait) then {
                                        private _since = [_row,"stoppedSince",-1] call ALIVE_fnc_hashGet;
                                        if (_since < 0) then {
                                            [_row,"stoppedSince",_now] call ALIVE_fnc_hashSet;
                                        } else {
                                            _waited = (_now - _since) >= 30;
                                        };
                                    } else {
                                        [_row,"stoppedSince",-1] call ALIVE_fnc_hashSet;
                                    };
                                    private _unwatched = if (_atHome || {"nearStand" call _fnc_o}) then {
                                        ("playersWithin300" call _fnc_n) == 0
                                    } else {
                                        ("playersWithin1000Hull" call _fnc_n) == 0
                                    };
                                    private _canTidy = ("nearHome" call _fnc_o)
                                        && {_unwatched
                                            || {"deckHome" call _fnc_o}
                                            || {_inTheWay && {_waited}}}
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
                                            // Still inside its thirty seconds: it
                                            // stays landing, rather than being
                                            // handed to recovery, which would leave
                                            // it there for ten minutes.
                                            if (!_mayWait || {_waited} || {_playerPassenger}) then { _next = "RECOVERING" };
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
                                    //
                                    // Except for a plane that is already down on
                                    // land and rolling. It has landed and is
                                    // taxiing off, and it has come home when it
                                    // reaches the end of the taxi-off route, which
                                    // is where it is put on its stand, whoever is
                                    // watching. Stopping is the wrong sign for a
                                    // jet: measured, one touched down, taxied off
                                    // to the end of the route in 81 seconds, never
                                    // stopped, and went straight round onto the
                                    // take-off route and flew again. The landing
                                    // order is not given again once it is down,
                                    // either, or it would be sent round a circuit
                                    // from the taxiway.
                                    if (_rolling) then {
                                        // Moving again, so any wait for it to
                                        // come to rest starts over.
                                        [_row,"stoppedSince",-1] call ALIVE_fnc_hashSet;
                                        switch (true) do {
                                            // At the end of the route, or out of
                                            // time, which is how one that never
                                            // finds the end is still put away.
                                            case (("atTaxiOffEnd" call _fnc_o) || {_expired}): {
                                                if (_playerPassenger) then {
                                                    // Never moved with somebody in it:
                                                    // held where it is instead, before
                                                    // it can take off again.
                                                    _next = "RECOVERING";
                                                } else {
                                                    _effects pushBack "placeOnSlot";
                                                    _effects pushBack "turnaround";
                                                    _next = "PARKED";
                                                };
                                            };
                                            // Nobody about to see it: put away as
                                            // soon as it is down to taxiing speed,
                                            // as a landing always was. Nobody
                                            // within a kilometre, as for one that
                                            // has stopped: a plane rolling out is
                                            // never on its own stand, so this is
                                            // always the long jump.
                                            case (("landed" call _fnc_o) && {"nearHome" call _fnc_o}
                                                && {("playersWithin1000Hull" call _fnc_n) == 0} && {!_playerPassenger}): {
                                                _effects pushBack "placeOnSlot";
                                                _effects pushBack "turnaround";
                                                _next = "PARKED";
                                            };
                                            default { };
                                        };
                                    } else {
                                        switch (true) do {
                                            case (_deckPlane): { _effects pushBack "deckRecover" };
                                            case (_needsRunway): { _effects pushBack "landOnRunway" };
                                            default { _effects pushBack "landAtPad" };
                                        };
                                    };
                                    if (_expired && {_next isEqualTo "LANDING"}) then {
                                        // Three more minutes, once, when it is still
                                        // flying and plainly coming down: below 300 m,
                                        // or a plane below 1500 m and descending (a
                                        // circuit has level legs, and a jet level at
                                        // seven kilometres is not coming down). Below
                                        // 300 m includes a go-around, which is still
                                        // in the circuit that ends on the runway. On LAN
                                        // a Blackfish hit this deadline 94 m up, 1750 m
                                        // out and descending at 2.9 m/s, twenty or
                                        // thirty seconds from touchdown, and was put
                                        // down from there. Not on the ground: a plane
                                        // stopped on the runway is holding it, and the
                                        // landed branch above has its own waits.
                                        //
                                        // This replaces a count on attempts that gave
                                        // one more tick and nothing else. The runway
                                        // order above can share this tick with the
                                        // put-down below; the Kernel applies effects in
                                        // order and the put-down moves the hull last.
                                        private _comingDown = _airborne
                                            && {("distHome" call _fnc_n) < LANDING_EXTENSION_REACH}
                                            && {
                                                (("altAGL" call _fnc_n) < LANDING_LOW_AGL)
                                                || {_needsRunway && {("altAGL" call _fnc_n) < LANDING_CIRCUIT_AGL} && {("climbRate" call _fnc_n) < 0}}
                                            };
                                        if (_comingDown && {!([_row,"landingExtended",false] call ALIVE_fnc_hashGet)}) then {
                                            [_row,"landingExtended",true] call ALIVE_fnc_hashSet;
                                            [_row,"deadlineAt",_now + LANDING_EXTENSION] call ALIVE_fnc_hashSet;
                                            _effects pushBack "landingExtended";
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
            // And the wait for the runway gives back the fuel it held, on every
            // way out of it: launched, timed out, taken by a player, or lost. It
            // is harmless on anything that was never held.
            //
            // Except a plane on land going on to launch, which is kept held
            // until it has been stood on its taxi route, and so is given its
            // fuel back on every way out of LAUNCHING instead.
            if (_state isEqualTo "ASSIGNED"
                && {!(_next isEqualTo "LAUNCHING" && {_landPlane} && {!_playerPassenger})}) then {
                _effects pushBack "releaseHold";
            };
            if (_state isEqualTo "LAUNCHING") then { _effects pushBack "releaseHold" };

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
            if !(_next isEqualTo "LANDING") then {
                [_row,"stoppedSince",-1] call ALIVE_fnc_hashSet;
            };
            // Each landing gets its own one extension, and each launch its own
            // waits for the runway.
            if (_next isEqualTo "LANDING") then {
                [_row,"landingExtended",false] call ALIVE_fnc_hashSet;
            };
            if (_next isEqualTo "ASSIGNED") then {
                [_row,"runwayWaits",0] call ALIVE_fnc_hashSet;
            };
            if (_next isEqualTo "LAUNCHING") then {
                [_row,"taxiedOutAt",-1] call ALIVE_fnc_hashSet;
                [_row,"taxiWaits",0] call ALIVE_fnc_hashSet;
                [_row,"launchExtended",false] call ALIVE_fnc_hashSet;
            };

            switch (_next) do {
                case "PARKED": {
                    _effects append ["unlock","engineOff","clearOrders"];
                    if (!_playerPassenger) then { _effects pushBack "standDownCrew" };
                    // Locked to players again, or left open, as the module says. The
                    // lock is asked at every parking so one refused while somebody
                    // sat in the aircraft is put on once they have gone.
                    _effects pushBack "playerLock";
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
                // A plane on land is held on its stand with an empty tank while
                // it waits, BEFORE its crew is made: a crewed plane starts its
                // engine and rolls, and one rolled half out of its hangar door
                // while it waited. The tank is given back on the way out.
                case "ASSIGNED":     {
                    // Fixed wing only: a VTOL lifts where it stands, so it is
                    // neither held nor given the runway.
                    if (_landPlane) then {
                        _effects pushBack "holdOnStand";
                    };
                    _effects append ["mintCrew","seatCrew"];
                    // The runway only for something that uses it.
                    if (_takesRunway) then { _effects pushBack "lock" };
                };
                // Start the engine as well as saying it is going. Announcing a
                // departure does not make one happen.
                //
                // A plane on a ship is shot off a catapult, and the engine is
                // started FIRST so the launch sequence finds one running.
                //
                // A plane on land is stood on its airport's taxi route first,
                // pointing along it, and the engine taxis it out from there.
                // Left on its stand it had to drive itself out, and a jet in a
                // tent hangar never got past the doorway. Asked here, on the
                // way in, and never again for the same launch: asked on a later
                // tick it would pull an aircraft already taxiing back to the
                // start of its taxi. The runway is held by now, so no other
                // aircraft of this commander is taking off; anything else on
                // the route is the effect's to look for.
                case "LAUNCHING":    {
                    switch (true) do {
                        case (_deckPlane): { _effects append ["engineOn","catapult","broadcastStart"]; };
                        case (_virtualHome): { _effects append ["engineOn","virtualLaunch","broadcastStart"]; };
                        // Held, tank empty, until it stands on its route: the
                        // engine, the sweep of its path and its fuel follow in
                        // the state's own rules once it does. With somebody
                        // aboard it is not held and goes as before.
                        case ("fixedWing" call _fnc_o): {
                            if (_playerPassenger) then {
                                _effects append ["taxiOut","sweepTaxiPath","engineOn","broadcastStart"];
                            } else {
                                _effects append ["taxiOut","broadcastStart"];
                            };
                        };
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
        // Nothing local may be done to a hull this machine does not own. Giving a
        // held tank back is the exception: it is set wherever the hull lives, and
        // a player who took an aircraft mid-wait must not be left with it empty.
        if (_remote) then {
            _effects = _effects select { _x in ["takeOwnership","unlock","releaseHold"] };
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
