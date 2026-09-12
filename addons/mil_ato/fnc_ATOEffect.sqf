#include "\x\alive\addons\mil_ato\script_component.hpp"
SCRIPT(effect);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ATOEffect
Description:
Does things to an aircraft. The only piece that changes the world.

Every effect has a name from a closed list, and applying one twice leaves the
world exactly as it was and says so. Nothing here decides anything: the state
table decides, this carries it out, and if it cannot it refuses out loud rather
than half-doing it quietly. Guards that refused correctly and silently for four
days are why the refusal is spoken.

Three refusals are absolute and are checked here rather than trusted to callers,
so no caller can forget one:

  A player in the aircraft. Nothing that moves it, and nothing that removes its
  crew. A player being carried somewhere is the whole reason the aircraft is
  worth having, and teleporting it out from under them is the complaint this
  module exists to stop.

  A hull owned by another machine. Anything that only works locally is refused
  and reported, never applied and silently lost, which is what made the same
  fault look intermittent.

  Orders for an aircraft in the air that do not end in a hold. An order chain
  that simply runs out is an aircraft with nothing to do, and that is four
  seconds from the ground.

apply(effect, obj, home, extra) -> [status, alreadyMatched, detail]

Parameters:
Nil or Array - If Nil, return a new instance. If a hash, reference an existing one.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function

Examples:
(begin example)
_r = [_e, "apply", ["engineOn", _veh, _home, []]] call ALIVE_fnc_ATOEffect;
_r params ["_status", "_alreadyMatched", "_detail"];

(end)

See Also:
<ALIVE_fnc_ATOMachine>, <ALIVE_fnc_ATOSurface>, <ALIVE_fnc_ATOObserve>

Author:
Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_ATOEffect

// Anything that moves the aircraft, plus taking its crew away. Refused outright
// while a player is in it, from any state, by any path.
#define PLAYER_UNSAFE ["airborneStart","forceLaunch","placeOnSlot","forceLanded","spawnAtHome","standDownCrew","takeOwnership"]

// Effects that only work where the object lives. On a hull owned elsewhere these
// do nothing at all, so they are refused and reported instead.
#define LOCAL_ONLY ["engineOn","engineOff","airborneStart","forceLaunch","placeOnSlot","forceLanded","spawnAtHome","seatCrew","recrewInPlace","standDownCrew","issueOrders","clearOrders","land","taxiTo","revealTargets","releaseTargets"]

// Not built in this pass. Named so a caller reaching one is told, rather than
// finding that nothing happened.
#define NOT_BUILT ["catapult","tailhook","deckLaunch","deckRecover","decoyLasers","addThreatHandlers","holdTargets","unquiesce","sweepTaxiPath","siren","deleteWreckNear","rehome","unshield"]

private ["_result"];

TRACE_1("ATO Effect - input",_this);

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

    case "vocabulary": {
        _result = ["spawnAtHome","airborneStart","mintCrew","mintDroneCrew","seatCrew","recrewInPlace",
                   "standDownCrew","takeOwnership","engineOn","engineOff","issueOrders","clearOrders",
                   "revealTargets","releaseTargets","landAtPad","releaseApproach",
                   "taxiTo","land","forceLaunch","forceLanded","placeOnSlot","shield","broadcast"];
    };

    case "apply": {
        _args params [
            ["_effect", "", [""]],
            ["_obj", objNull, [objNull]],
            ["_home", [], [[]]],
            ["_extra", [], [[],"",0,true]]
        ];

        private _status = "ok";
        private _matched = false;
        private _detail = "";

        // ---- the three absolute refusals ----------------------------------
        // Checked before anything looks at what the effect is, so a new effect
        // added later inherits them rather than having to remember them.

        if (isNull _obj && {!(_effect isEqualTo "broadcast")}) exitWith {
            _result = ["refused", false, "no object"];
        };

        if (!isNull _obj && {(_effect in PLAYER_UNSAFE)} && {({alive _x && {isPlayer _x}} count (crew _obj)) > 0}) exitWith {
            ["ALIVE_fnc_ATOEffect - %1 refused on %2: a player is aboard", _effect, typeOf _obj] call ALiVE_fnc_dump;
            _result = ["refused", false, "player aboard"];
        };

        if (!isNull _obj && {(_effect in LOCAL_ONLY)} && {!local _obj}) exitWith {
            ["ALIVE_fnc_ATOEffect - %1 refused on %2: the hull is owned elsewhere", _effect, typeOf _obj] call ALiVE_fnc_dump;
            _result = ["refused", false, "remote"];
        };

        if (_effect in NOT_BUILT) exitWith {
            ["ALIVE_fnc_ATOEffect - %1 is not built yet, refusing rather than doing nothing quietly", _effect] call ALiVE_fnc_dump;
            _result = ["refused", false, "not built"];
        };

        switch (_effect) do {

            // ---- engine ---------------------------------------------------
            case "engineOn": {
                if (isEngineOn _obj) then { _matched = true } else { _obj engineOn true };
            };
            case "engineOff": {
                if (!isEngineOn _obj) then { _matched = true } else { _obj engineOn false };
            };

            // ---- ownership ------------------------------------------------
            // Only ever moved to the server, and only when empty: taking a hull
            // with somebody in it away from the machine they are on is not a
            // thing to do to a person.
            case "takeOwnership": {
                if (local _obj) then {
                    _matched = true;
                } else {
                    if (count (crew _obj) > 0) then {
                        _status = "refused"; _detail = "crew aboard";
                    } else {
                        _obj setOwner 2;
                    };
                };
            };

            // ---- crew ------------------------------------------------------
            case "mintCrew": {
                if (count (crew _obj) > 0) then {
                    _matched = true;
                } else {
                    private _grp = createVehicleCrew _obj;
                    if (isNull _grp) then {
                        _status = "refused"; _detail = "crew could not be created";
                    } else {
                        // Marked so nothing else adopts them, and so they are
                        // recognisable as ours when they are stood down.
                        { _x setVariable ["ALiVE_mil_ato_crew", true, true] } forEach (units _grp);
                        _detail = str (count (units _grp));
                    };
                };
            };

            case "mintDroneCrew": {
                if (count (crew _obj) > 0) then {
                    _matched = true;
                } else {
                    createVehicleCrew _obj;
                    // A drone flown by nobody is still meant to be operable from
                    // a terminal, so the crew must not be treated as pilots.
                    { _x setVariable ["ALiVE_mil_ato_crew", true, true] } forEach (crew _obj);
                };
            };

            case "recrewInPlace": {
                if (({alive _x} count (crew _obj)) > 0) then {
                    _matched = true;
                } else {
                    // The dead have to be taken out of the seats first. Crew
                    // creation only fills seats it finds EMPTY, and a body still
                    // occupies one, so an aircraft whose pilot was killed would
                    // be handed no replacement at all and fly on with nobody in
                    // it. That is the exact failure this effect exists to undo.
                    { deleteVehicle _x } forEach (crew _obj);
                    createVehicleCrew _obj;
                    { _x setVariable ["ALiVE_mil_ato_crew", true, true] } forEach (crew _obj);
                    _detail = "recrewed";
                };
            };

            case "seatCrew": {
                _matched = ({alive _x} count (crew _obj)) > 0;
            };

            case "standDownCrew": {
                private _ours = (crew _obj) select { _x getVariable ["ALiVE_mil_ato_crew", false] };
                if (count _ours == 0) then {
                    _matched = true;
                } else {
                    // Deleted outright only when nobody is close enough to see
                    // it happen. Otherwise they get out and are removed once
                    // they have walked off, because people vanishing in front of
                    // you is worse than a few extra men standing about.
                    private _watched = (allPlayers select { alive _x && {(_x distance2D _obj) < 300} });
                    if (count _watched == 0) then {
                        { deleteVehicle _x } forEach _ours;
                        _detail = "deleted";
                    } else {
                        { moveOut _x; [_x] orderGetIn false } forEach _ours;
                        [_ours] spawn {
                            params ["_units"];
                            sleep 120;
                            { if (!isNull _x && {alive _x}) then { deleteVehicle _x } } forEach _units;
                        };
                        _detail = "dismissed";
                    };
                };
            };

            // ---- orders ------------------------------------------------------
            // Orders arrive already resolved to places: [[type, position], ...].
            // Turning a name like "go to the target" into a position needs to
            // know what the sortie is, and that is not this piece's business.
            case "issueOrders": {
                private _chain = _extra param [0, []];
                private _airborne = ((getPosATL _obj) select 2) > 50;

                if (count _chain == 0) exitWith { _status = "refused"; _detail = "empty chain" };

                // An order list for an aircraft in the air that does not end in
                // a hold is an aircraft that runs out of things to do, and that
                // was four seconds from the ground.
                //
                // Landing is the exception, and the only one: an approach is
                // MEANT to end, because the aircraft finishes it on the ground.
                // Requiring a hold there refused every approach the moment one
                // was ordered, and the aircraft circled with nothing accepted.
                private _lastType = (_chain select (count _chain - 1)) param [0, ""];
                if (_airborne && {!(_lastType in ["LOITER","GETOUT"])}) exitWith {
                    ["ALIVE_fnc_ATOEffect - orders refused for %1: an airborne chain must end in a hold", typeOf _obj] call ALiVE_fnc_dump;
                    _status = "refused"; _detail = "no terminal hold";
                };

                private _grp = group (driver _obj);
                if (isNull _grp) exitWith { _status = "refused"; _detail = "no group" };

                // Already flying exactly this? Leave it alone. Re-issuing the
                // same chain every tick restarts the aircraft's plan each time.
                private _signature = str _chain;
                if ((_grp getVariable ["ALiVE_mil_ato_orders", ""]) isEqualTo _signature) exitWith {
                    _matched = true; _detail = "unchanged";
                };

                private _wps = waypoints _grp;
                for "_i" from (count _wps - 1) to 0 step -1 do { deleteWaypoint [_grp, _i] };
                {
                    _x params [["_type","MOVE",[""]], ["_pos",[0,0,0],[[]]]];
                    private _wp = _grp addWaypoint [_pos, 0];
                    _wp setWaypointType _type;
                } forEach _chain;

                // Point the group back at the FIRST of the new orders. Emptying
                // the list and refilling it does not move the group's place in
                // it: a group that had finished order one carries on from order
                // two, so a fresh set of orders was joined halfway through. That
                // is how an aircraft told to fly eight kilometres to a target
                // instead flew to the end of its takeoff and circled there.
                //
                // Index ZERO is the first of the new orders, and asking for
                // one skipped it.
                //
                // A fresh group does carry an automatic waypoint at index 0 for
                // its own starting position, which is where the belief that one
                // is the first real order came from. But deleteWaypoint removes
                // that one too, so after the list is emptied the first ADDED
                // waypoint IS index 0. Measured: after clearing and adding two,
                // addWaypoint returned [grp,0] and [grp,1], and a group set to
                // one walked to the SECOND order's position while the first went
                // unvisited. Every two-item chain this module issues was losing
                // its first order that way.
                _grp setCurrentWaypoint [_grp, 0];
                // Only worth saying when the group is reading past the orders
                // it was just given, which now means something has gone wrong
                // rather than being the expected answer.
                private _landed = currentWaypoint _grp;
                if (_landed >= count (waypoints _grp)) then {
                    ["ALIVE_fnc_ATOEffect - new orders given but the group reads %1 of %2, past the end",
                        _landed, count (waypoints _grp)] call ALiVE_fnc_dump;
                };
                // Told directly where to go as well as by the plan.
                //
                // This was added to paper over the index fault above: the group
                // was reading the wrong entry, so the plan alone sent it to the
                // wrong place and a direct order was the only thing that worked.
                // The index is right now, so this is no longer load-bearing.
                //
                // It stays because it aims at the SAME place as the first order,
                // so the two agree rather than compete, and because a direct
                // command is what actually gets a parked aircraft moving. It
                // would be wrong to point it anywhere else: a pending doMove
                // outranks the plan, and that is exactly how an approach was
                // lost earlier, with the aircraft orbiting a stale move
                // destination while its landing order was discarded.
                (_chain select 0) params ["", ["_firstPos",[0,0,0],[[]]]];
                _obj doMove _firstPos;
                (driver _obj) doMove _firstPos;

                _grp setVariable ["ALiVE_mil_ato_orders", _signature, false];
                _detail = str (count _chain);
            };

            case "clearOrders": {
                private _grp = group (driver _obj);
                if (isNull _grp) then {
                    _matched = true;
                } else {
                    private _wps = waypoints _grp;
                    // Forget what was last issued, as well as deleting it.
                    // issueOrders refuses a chain whose signature matches the
                    // one on the group, so a signature left behind here meant
                    // the next identical chain was reported "unchanged" against
                    // an EMPTY waypoint list, and the aircraft sat doing nothing
                    // until a deadline forced it. Reachable in one step: two
                    // launch timeouts, recovery, parked, assigned, and the same
                    // takeoff chain comes round again.
                    private _sig = _grp getVariable ["ALiVE_mil_ato_orders", ""];
                    if (count _wps == 0 && {_sig isEqualTo ""}) then {
                        _matched = true;
                    } else {
                        for "_i" from (count _wps - 1) to 0 step -1 do { deleteWaypoint [_grp, _i] };
                        _grp setVariable ["ALiVE_mil_ato_orders", nil, false];
                    };
                };
            };

            // ---- what the aircraft is allowed to know ------------------------
            // A gunship that has not been told where the enemy is orbits its
            // station and never fires. Knowledge is handed over deliberately on
            // arrival and taken back on the way out, so an aircraft does not
            // carry a target list home and shoot at it in passing.
            case "revealTargets": {
                private _targets = (_extra param [0, [], [[]]]) select { !isNull _x && {alive _x} };
                private _grp = group (driver _obj);
                if (isNull _grp) exitWith { _status = "refused"; _detail = "no group" };
                if (count _targets == 0) exitWith { _matched = true; _detail = "nothing to reveal" };

                private _held = _grp getVariable ["ALiVE_mil_ato_revealed", []];
                if (_held isEqualTo _targets) exitWith { _matched = true; _detail = "unchanged" };

                {
                    // Four is certainty. Anything less and the crew goes hunting
                    // for a contact it has already been handed.
                    _grp reveal [_x, 4];
                    (units _grp) doTarget _x;
                } forEach _targets;
                _grp setVariable ["ALiVE_mil_ato_revealed", _targets, false];
                _detail = str (count _targets);
            };

            case "releaseTargets": {
                private _grp = group (driver _obj);
                if (isNull _grp) exitWith { _status = "refused"; _detail = "no group" };
                private _held = _grp getVariable ["ALiVE_mil_ato_revealed", []];
                if (count _held == 0) exitWith { _matched = true; _detail = "nothing held" };

                {
                    private _t = _x;
                    if (!isNull _t) then { { _x forgetTarget _t } forEach (units _grp) };
                } forEach _held;
                (units _grp) doTarget objNull;
                _grp setVariable ["ALiVE_mil_ato_revealed", nil, false];
                _detail = str (count _held);
            };

            // ---- putting it places -------------------------------------------
            case "placeOnSlot": {
                private _surface = _extra param [0, []];
                if (_surface isEqualTo []) exitWith { _status = "refused"; _detail = "no surface" };
                // "Already there" means ON the slot, not merely inside the
                // thirty metres that counts as home.
                //
                // This asked atHome, which is that 30 m tolerance, so an
                // aircraft that set itself down 26 m from its pad was already
                // home by definition and was never tidied onto it. That skip is
                // the old module's deliberate choice and its reason is on record:
                // a reposition from a few metres is a visible shuffle sideways
                // and a spin onto a heading it was not flying. But the result is
                // a fleet parked beside its pads rather than on them, which is
                // worse to look at than the shuffle and drifts further every
                // turnaround.
                //
                // atHome KEEPS its 30 m, because main's 60 m pad threshold is
                // calibrated against that figure (IN-14). Only the decision to
                // tidy is tightened, not the definition of home. forceLanded
                // below still uses atHome, deliberately: that path is an
                // emergency and near enough is the point of it.
                if ((_obj distance2D (_home select 0)) < 5) then {
                    _matched = true;
                } else {
                    if !([_surface, "place", [_obj, _home]] call ALIVE_fnc_ATOSurface) then {
                        _status = "refused"; _detail = "surface refused the placement";
                    };
                };
            };

            case "forceLanded": {
                private _surface = _extra param [0, []];
                if (_surface isEqualTo []) exitWith { _status = "refused"; _detail = "no surface" };
                if ([_surface, "atHome", [_obj, _home]] call ALIVE_fnc_ATOSurface) then {
                    _matched = true;
                } else {
                    ["ALIVE_fnc_ATOEffect - %1 put down at its home rather than left flying", typeOf _obj] call ALiVE_fnc_dump;
                    [_surface, "place", [_obj, _home]] call ALIVE_fnc_ATOSurface;
                };
            };

            case "airborneStart": {
                if (((getPosATL _obj) select 2) > 50) then {
                    _matched = true;
                } else {
                    private _alt = _extra param [0, 300];
                    private _p = getPosATL _obj;
                    _obj setPosATL [_p select 0, _p select 1, _alt];
                    _obj engineOn true;
                    _obj setVelocity [(sin (getDir _obj)) * 90, (cos (getDir _obj)) * 90, 0];
                };
            };

            case "forceLaunch": {
                if (((getPosATL _obj) select 2) > 50) then {
                    _matched = true;
                } else {
                    private _p = getPosATL _obj;
                    _obj setPosATL [_p select 0, _p select 1, 600];
                    _obj engineOn true;
                    _obj setVelocity [(sin (getDir _obj)) * 120, (cos (getDir _obj)) * 120, 0];
                };
            };

            case "land": {
                private _mode = _extra param [0, "LAND"];
                private _grp = group (driver _obj);
                if (isNull _grp) then { _status = "refused"; _detail = "no group" }
                else { _obj land _mode };
            };

            case "taxiTo": { _detail = "taxi not modelled in this pass"; };

            // Everything a landing needs, kept simple for a helicopter: tell it
            // to come down. Planes and decks get their own handling later.
            // The one that puts a helicopter on a chosen spot. land "LAND" sets
            // the intent to come down, landAt names WHERE, and it needs an
            // object because this engine has no landing waypoint type. Both
            // together are what the old module used and what logistics still
            // uses at every one of its landing sites.
            case "landAtPad": {
                private _surface = _extra param [0, []];
                private _tail = _extra param [1, ""];
                if (_surface isEqualTo []) exitWith { _status = "refused"; _detail = "no surface" };

                private _grp = group (driver _obj);
                if (isNull _grp) exitWith { _status = "refused"; _detail = "no group" };

                // Clear the approach chain first. A pending waypoint or move
                // competes with the landing and wins, which is how one aircraft
                // stopped dead and hovered rather than coming down.
                private _wps = waypoints _grp;
                for "_i" from (count _wps - 1) to 0 step -1 do { deleteWaypoint [_grp, _i] };
                _grp setVariable ["ALiVE_mil_ato_orders", nil, false];

                // Arrive over the stand FIRST, then come down. That order is the
                // whole of this and it is taken from the one landing sequence in
                // this codebase that demonstrably works.
                //
                // Neither landing command will travel. landAt holds an
                // aircraft over a pad and never descends; land "LAND" brings
                // one down where it already is. So whichever is used, the
                // aircraft has to be over its stand BEFORE either is issued,
                // and getting it there is this module's own work.
                //
                // Logistics reaches the same arrangement from the other end: it
                // waits until the aircraft has arrived and then creates a pad
                // directly beneath it, so the landing never has anywhere to go.
                //
                // This module has to put the aircraft on an ASSIGNED stand
                // rather than wherever it happens to be, so the arriving is ours
                // to do. Everything after the arrival is logistics' sequence.
                //
                // What that replaces, and why each piece went:
                //
                //   Committing at five hundred metres. It released the height
                //   floor while the aircraft was still half a kilometre out, so
                //   every descent was the floor letting it sink rather than the
                //   landing placing it. Measured settling 26 to 38 m from the
                //   pad with both painted pads clearly visible alongside.
                //
                //   flyInHeight 0. It does land promptly, and wherever it
                //   happens to be: one came down on a hillside two kilometres
                //   out. Logistics never uses it to land and neither does this.
                //
                //   Steering with doMove while landing. A pending doMove is a
                //   direct command and outranks landAt, so every aim was
                //   discarded while the aircraft orbited its own move
                //   destination. Measured 259 m out, command still MOVE, no
                //   waypoints, 197 km/h in a circle. Here the steering STOPS at
                //   the moment of commitment, and by then the move has completed
                //   by arriving rather than by being cancelled, so nothing is
                //   left pending to outrank the landing.
                //
                // Thirty-five metres counts as overhead: loose enough that a
                // hovering aircraft reaches it, tight enough that landAt has
                // almost nothing left to do. Whatever it does leave is what
                // placeOnSlot tidies once the wheels are down.
                private _stand = _home select 0;
                private _dPad = _obj distance2D _stand;
                private _agl = (getPosATL _obj) select 2;
                private _spd = abs (speed _obj);
                private _committed = _grp getVariable ["ALiVE_mil_ato_landing", false];

                // Arriving is being low, slow and over the stand, not merely
                // being near it on the map.
                //
                // Measured with a horizontal test alone: the aircraft closed
                // from 900 m to 26 m, committed there while still 150 m up and
                // doing 199 km/h, and flew straight over the top. Committing
                // also stops the steering, so from that moment it had no order
                // at all and drifted back out to 257 m, climbing to 203 m as the
                // engine returned it to its cruise height. landAt issued no
                // command throughout, which is what landAt does when the pad is
                // not underneath the aircraft.
                //
                // Sixty metres and forty km/h are loose on purpose. A helicopter
                // holding a height of thirty sits a little above it and never
                // stops moving entirely, and a gate it cannot satisfy is worse
                // than one that lets it commit slightly early.
                private _overhead = _dPad < 60 && {_agl < 60} && {_spd < 40};

                // ---- transit ---------------------------------------------
                // Still on the way in, so fly to the stand and say nothing about
                // landing. Slowed for the last stretch: it arrives at 280 km/h,
                // which is 155 metres a second, so between two ticks it crossed
                // from 768 m out to 107 m and the arrival gate never saw
                // anything in between. Arriving fast is also what made it
                // overshoot the stand.
                if (!_committed && {!_overhead}) exitWith {
                    // Come down ON THE WAY IN rather than arriving at cruise
                    // height and then diving. Tapered early because it closes
                    // the last three hundred metres in four seconds: setting a
                    // lower height only inside that radius left no time to use
                    // it, and the aircraft arrived a hundred and fifty metres up.
                    _obj flyInHeight (switch (true) do {
                        case (_dPad > 1000): {100};
                        case (_dPad > 400):  {60};
                        default              {30};
                    });
                    // Slowed from well out, for the same reason. At 277 km/h it
                    // covers 77 metres a second, so it overshoots the stand
                    // before any arrival test can see it there.
                    if (_dPad < 800) then { _grp setSpeedMode "LIMITED" };
                    (driver _obj) doMove _stand;
                    _detail = format ["inbound %1 m, %2 m up, %3 km/h",
                        round _dPad, round _agl, round _spd];
                };

                // ---- overhead --------------------------------------------
                // Latched, so an aircraft that drifts back outside the radius
                // while it is coming down is not sent round again.
                // Arrived. The pad goes ON THE STAND, which is where the
                // aircraft is meant to end up.
                //
                // Putting it beneath the aircraft instead was tried, on the
                // grounds that logistics does that and logistics works. It does
                // work, at 2 m, but not for the reason it appeared to: the
                // aircraft moved forty metres AWAY from that pad while coming
                // down, pulled onto the stand by the transit order it had not
                // finished. The pad beneath was doing nothing. Logistics puts
                // its pad underneath because it is content to land wherever it
                // arrived; this module is not.
                //
                // On the stand, the two orders pull the same way: landAt has
                // very strong horizontal authority, measured holding an
                // aircraft at 0 m over its pad for a full minute, so aiming it
                // at the stand closes the last forty metres that steering will
                // not.
                private _pad = [_surface, "padFor", [_home, _tail]] call ALIVE_fnc_ATOSurface;
                if (isNull _pad) exitWith { _status = "refused"; _detail = "no pad" };

                if (!_committed) then {
                    _grp setVariable ["ALiVE_mil_ato_landing", true, false];
                    _grp setVariable ["ALiVE_mil_ato_landingAimedAt", -1, false];
                };

                // Quiesce and aim, on a timer rather than every tick.
                //
                // The quiesce is not optional and logistics wrote down why: a
                // pilot with evasion and targeting live ignores landAt outright,
                // banking away and climbing instead of coming down. It matters
                // more here, because this aircraft has just spent its whole
                // sortie on a search-and-destroy waypoint and so is in combat
                // behaviour by definition. It is re-done with every re-aim,
                // because the engine turns evasion back on by itself.
                //
                // Every tick was wrong. Re-issuing landAt restarts the approach,
                // so at one call every two seconds the aircraft never got far
                // enough into one to finish it. Logistics re-issues every
                // thirty-five seconds, so that is the interval used here.
                private _aimedAt = _grp getVariable ["ALiVE_mil_ato_landingAimedAt", -1];
                private _held = _grp getVariable ["ALiVE_mil_ato_landingHeld", false];
                if (_aimedAt < 0 || {(time - _aimedAt) > 35}) then {
                    _grp setBehaviour "CARELESS";
                    _grp allowFleeing 0;
                    _grp setCombatMode "BLUE";
                    {
                        _x disableAI "AUTOTARGET";
                        _x disableAI "TARGET";
                        _x setSkill ["courage", 1];
                    } forEach (units _grp);
                    // Both orders, in this order, and the order matters.
                    //
                    // land "LAND" is the one that actually brings a helicopter
                    // down. landAt does not: it holds one dead centre over the
                    // pad at whatever height it already has, indefinitely.
                    // Measured, four aircraft side by side, each hovering 45 m
                    // over its own pad, quiesced, held for a minute:
                    //
                    //   landAt alone            never came down. 53 m up,
                    //                           0 m from the pad, stable.
                    //   landAt + flyInHeight 0  down, 17 m out.
                    //   flyInHeight 0 alone     down, 12 m out.
                    //   land "LAND"             down, 5 m out.
                    //
                    // So they do different jobs, and neither name says which:
                    // landAt is a station-keeper with perfect horizontal
                    // accuracy and no vertical effect, and land "LAND" is the
                    // landing. Used together, land "LAND" first to start the
                    // descent and landAt second to hold the centre while it
                    // happens, the aircraft comes down 1 m from the pad against
                    // 2 m for land "LAND" on its own and 7 m for both issued in
                    // the same breath.
                    //
                    // land "LAND" was ruled out here once, on the grounds that
                    // it means come down HERE and immediately and so freezes an
                    // aircraft wherever it happens to be. That is true, and it
                    // is why it is wrong as an APPROACH order and right as an
                    // ARRIVAL one. By this point the aircraft is already
                    // hovering over its stand, so here is where it should come
                    // down.
                    // The descent first, ALONE, and the centring a few
                    // seconds later. Issued in the same breath the two fight:
                    // the aircraft came down and then wandered 26 m off the
                    // pad, worse than either order on its own. Six seconds
                    // apart, in this order, is the 1 m result.
                    _obj land "LAND";
                    _grp setVariable ["ALiVE_mil_ato_landingAimedAt", time, false];
                    _grp setVariable ["ALiVE_mil_ato_landingHeld", false, false];
                    _detail = format ["coming down from %1 m, %2 m up", round _dPad, round _agl];
                } else {
                    if (!_held && {(time - _aimedAt) >= 5}) then {
                        // Already on the way down. Hold the centre while it is.
                        _obj landAt _pad;
                        _grp setVariable ["ALiVE_mil_ato_landingHeld", true, false];
                        _detail = format ["centring at %1 m, %2 m up", round _dPad, round _agl];
                    } else {
                        _detail = format ["landing from %1 m, %2 m up", round _dPad, round _agl];
                    };
                };
            };

            // The approach is over, however it ended. Gives back a pad this
            // surface minted and leaves a real one alone, so the object cannot
            // outlive the state that needed it.
            case "releaseApproach": {
                private _surface = _extra param [0, []];
                private _tail = _extra param [1, ""];
                if (_surface isEqualTo []) exitWith { _status = "refused"; _detail = "no surface" };
                [_surface, "unstampPad", _tail] call ALIVE_fnc_ATOSurface;
                // And forget that a landing was committed to, or the next
                // approach starts already believing it is on finals.
                private _grp = group (driver _obj);
                if (!isNull _grp) then {
                    _grp setVariable ["ALiVE_mil_ato_landing", nil, false];
                    // The re-aim timer goes with it, or the next approach sits
                    // overhead for thirty-five seconds before aiming at all.
                    _grp setVariable ["ALiVE_mil_ato_landingAimedAt", nil, false];
                    _grp setVariable ["ALiVE_mil_ato_landingHeld", nil, false];
                    // Give the throttle back, or the next sortie flies at a
                    // landing pace all the way to its target.
                    _grp setSpeedMode "NORMAL";
                };
                _detail = "released";
            };

            // Start the approach again from the beginning.
            //
            // The table asks for this when the landing deadline has run out
            // with somebody aboard, where putting the hull down is not allowed
            // and giving up is not either. So it is a real retry: forget that
            // the aircraft was ever on finals, and the next tick transits back
            // to the stand and aims afresh.
            //
            // It used to issue land "LAND", which means come down HERE and
            // immediately. On an approach that freezes the aircraft wherever it
            // happens to be, with nothing left navigating to the stand, and it
            // is measured doing exactly that. Coming down on the spot is right
            // for emergencyLanding below, which is why that one keeps it.
            case "retryLanding": {
                private _grp = group (driver _obj);
                if (isNull _grp) then { _status = "refused"; _detail = "no group" }
                else {
                    _obj land "NONE";
                    _grp setVariable ["ALiVE_mil_ato_landing", nil, false];
                    _grp setVariable ["ALiVE_mil_ato_landingAimedAt", nil, false];
                    _grp setVariable ["ALiVE_mil_ato_landingHeld", nil, false];
                    _detail = "approach restarted";
                };
            };
            case "emergencyLanding": {
                _obj land "LAND";
                _detail = "emergency";
            };

            // Back on the ground and ready to go again.
            case "turnaround": {
                if (!isEngineOn _obj && {(damage _obj) < 0.01} && {(fuel _obj) > 0.99}) then {
                    _matched = true;
                } else {
                    _obj engineOn false;
                    _obj setDamage 0;
                    _obj setFuel 1;
                };
            };

            // One broadcast effect, named by what it is announcing.
            case "broadcastStart";
            case "broadcastOnStation";
            case "broadcastReturn";
            case "broadcastLost": { _detail = _effect; };

            // ---- protecting it -----------------------------------------------
            // An aircraft this module owns carries no profile, so nothing that
            // removes profiles can reach it. Clearing a leftover stamp is the
            // whole of the protection.
            case "shield": {
                private _tail = _extra param [0, ""];
                if ((_obj getVariable ["ALiVE_mil_ato_tail", ""]) isEqualTo _tail && {_tail != ""}) then {
                    _matched = true;
                } else {
                    _obj setVariable ["ALiVE_mil_ato_tail", _tail, true];
                    _obj setVariable ["ALIVE_profileIgnore", true, true];
                    _obj setVariable ["profileID", nil, true];
                    _obj setVariable ["profileIndex", nil, true];
                    _obj setVariable ["runtimeProfiled", nil, true];
                };
            };

            case "spawnAtHome": {
                _status = "refused"; _detail = "creation belongs to placement";
            };

            case "broadcast": {
                private _key = _extra param [0, ""];
                if (_key isEqualTo "") then { _status = "refused"; _detail = "no key" }
                else { _detail = _key };
            };

            default {
                ["ALIVE_fnc_ATOEffect - %1 is not an effect this knows", _effect] call ALiVE_fnc_dump;
                _status = "refused"; _detail = "unknown effect";
            };
        };

        _result = [_status, _matched, _detail];
    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};

TRACE_1("ATO Effect - output",_result);

_result;
