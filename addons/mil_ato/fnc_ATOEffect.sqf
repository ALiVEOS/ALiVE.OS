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
// while a player is in it, from any state, by any path. A catapult tows the
// aircraft onto the wire before it fires, so it belongs here with the rest.
#define PLAYER_UNSAFE ["airborneStart","forceLaunch","virtualLaunch","taxiOut","placeOnSlot","forceLanded","spawnAtHome","standDownCrew","takeOwnership","catapult","holdOnStand"]

// Effects that only work where the object lives. On a hull owned elsewhere these
// do nothing at all, so they are refused and reported instead. releaseHold is not
// here on purpose: it sets the tank wherever the hull lives, so a player who took
// the aircraft is never left with it empty.
#define LOCAL_ONLY ["engineOn","engineOff","airborneStart","forceLaunch","virtualLaunch","taxiOut","placeOnSlot","forceLanded","spawnAtHome","seatCrew","recrewInPlace","standDownCrew","issueOrders","clearOrders","land","taxiTo","revealTargets","releaseTargets","catapult","tailhook","deckRecover","landOnRunway","holdOnStand"]

// Not built in this pass. Named so a caller reaching one is told, rather than
// finding that nothing happened. deckLaunch stays here on purpose: it would be
// a second name for catapult, and two names for one thing is how two callers
// come to disagree.
#define NOT_BUILT ["deckLaunch","decoyLasers","addThreatHandlers","holdTargets","unquiesce","siren","deleteWreckNear","rehome","unshield"]

// The catapult, in numbers.
//
// How long one launch is allowed to own the aircraft. A second ask inside
// this window is answered "matched" rather than started on top of the first:
// the tow takes up to eight seconds, the pin six, the launch itself a couple,
// and the deflectors come down four seconds after that.
// One launch owns its aircraft for this long. The arithmetic has to hold or
// the state table's own deadline lands inside a running sequence: up to 30 s of
// tow, 6 s pinned, and about 7 s for the shot and the kick is 43, so 60 leaves
// room without letting a wedged attempt hold an aircraft for long.
#define CATAPULT_WINDOW 60

// How far an aircraft may be towed to reach a catapult, and how long that may
// take. The distance is a REFUSAL, not a cap on the time: capping the time
// while letting the distance grow is what dragged a jet three kilometres
// across the sea in eight seconds. A hundred and fifty metres reaches any
// stand on this deck, and at the engine's own five metres a second that is
// thirty seconds of visible movement.
#define CATAPULT_TOW_REACH 150
// The tow onto the wire, in metres a second and degrees a second, and the
// longest it may take. These are the engine's own figures for a player's
// aircraft (fn_carrier01catapultlockto.sqf), so an AI jet crosses the deck
// at the same pace a player's does.
#define CATAPULT_TOW_SPEED 5
#define CATAPULT_TOW_TURN 15
#define CATAPULT_TOW_MAX 30
// Held on the wire this long before the shot, engine running, so the
// engine's own launch finds a settled aircraft. The old module waited three
// seconds for the deflectors and six pinned; the deflectors take one, so the
// pin covers both.
#define CATAPULT_PIN 6

// How long to leave a plane alone once it has been sent to the airport.
//
// Measured from three kilometres out at three hundred metres: a jet took 106
// seconds to fly the circuit and touch down, and a VTOL 126. Re-issuing the
// order restarts the circuit, so re-aiming on the thirty-five second interval
// the pad approach uses would restart it three times and it would never land.
// Three minutes is longer than any circuit measured and still short enough to
// rescue an approach the engine has quietly dropped.
#define RUNWAY_REAIM 180

// How long a returned aircraft waits for a supply truck before it is serviced
// where it stands. The old module made every aircraft wait between three and
// thirteen minutes after landing before it could be tasked again, for no
// reason anybody wrote down, so three minutes of waiting for a real truck
// costs nothing against what it used to do and buys a truck that is actually
// driving there.
#define SERVICE_WAIT 180

// How high a held aircraft is lifted to when it is let go. Measured: both a jet
// and a gunship released from here flew on under their own power and levelled
// off around a hundred and twenty metres.
#define VIRTUAL_LAUNCH_ALT 300

// How far from its stand a plane may be moved to start its taxi. The furthest
// stand on Stratis is 792 m from the head of the taxi route. A route starting
// further off than this belongs to some other field, and following it would be
// moving the aircraft across the map rather than out of its hangar.
#define TAXI_REACH 3000

// How long the path ahead of a launching plane is kept clear, at most. Launches
// measured from the taxi route took 67 to 302 seconds to reach fifty metres; the
// sweep stops as soon as the aircraft does.
#define SWEEP_SPAN 300

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

    // The name the HQ speaks under, for a caller assembling radio arguments.
    //
    // Here rather than in every caller because the keys want it in different
    // places and each caller would otherwise have to know how to look it up,
    // which is how two of them end up disagreeing. An HQ with no identity still
    // has a voice, it just has no name.
    case "hqName": {
        private _hqClass = _args;
        if !(_hqClass isEqualType "") then { _hqClass = "" };
        _result = "HQ";
        if !(_hqClass isEqualTo "") then {
            private _fromConfig = getText (configFile >> "CfgHQIdentities" >> _hqClass >> "name");
            if !(_fromConfig isEqualTo "") then { _result = _fromConfig };
        };
    };

    case "vocabulary": {
        _result = ["spawnAtHome","airborneStart","mintCrew","mintDroneCrew","seatCrew","recrewInPlace",
                   "standDownCrew","takeOwnership","engineOn","engineOff","issueOrders","clearOrders",
                   "revealTargets","releaseTargets","landAtPad","releaseApproach",
                   "taxiTo","taxiOut","land","forceLaunch","forceLanded","placeOnSlot","shield",
                   "broadcast","broadcastStart","broadcastOnStation","broadcastReturn",
                   "broadcastLost","retryLanding","emergencyLanding","turnaround",
                   "mintDroneCrew","recrewInPlace","takeOwnership","engineOn","engineOff",
                   "seatCrew","standDownCrew","clearOrders","airborneStart",
                   "catapult","tailhook","deckRecover","landOnRunway","holdOnStand","releaseHold",
                   "sweepTaxiPath"];
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

        // How far up the aircraft is, measured against what is UNDER it. On a
        // deck that is getPos: getPosATL measures from the terrain, and over
        // water the terrain is the sea bed forty metres down, so an aircraft
        // standing on a carrier read as sixty-odd metres airborne. That made
        // orders for a parked jet refuse as "an airborne chain must end in a
        // hold", and forceLaunch answer "matched" and do nothing. The
        // observer makes the same choice for the same reason; terrain homes
        // keep getPosATL so nothing on land changes.
        private _fnc_up = {
            params ["_o", "_h"];
            // A deck and a hold point are both measured from what is
            // underneath rather than from terrain level, because over water
            // terrain level is the SEA BED and everything above it reads as
            // tens of metres up.
            if (count _h > 2 && {(_h select 2) in ["deck","virtual"]}) then {
                (getPos _o) select 2
            } else {
                (getPosATL _o) select 2
            }
        };

        // How far a point is from a runway's centre line, and which side of it
        // it is on: [distance, side]. Two points with the same side can be
        // joined without crossing the runway. [1e9, 0] with no runway known.
        // Shared by the taxi sweep, which moves things off an aircraft's path to
        // the side away from the runway, and the crew walk-off, which must not
        // send men across it.
        private _fnc_offRunway = {
            params ["_p", "_cl"];
            if !(_cl isEqualType [] && {count _cl > 1}) exitWith { [1e9, 0] };
            private _ra = _cl select 0;
            private _rb = _cl select 1;
            private _dx = (_rb select 0) - (_ra select 0);
            private _dy = (_rb select 1) - (_ra select 1);
            private _l2 = (_dx * _dx) + (_dy * _dy);
            if (_l2 <= 0) exitWith { [1e9, 0] };
            private _px = (_p select 0) - (_ra select 0);
            private _py = (_p select 1) - (_ra select 1);
            private _t = ((_px * _dx) + (_py * _dy)) / _l2;
            _t = (_t max 0) min 1;
            // SQF has no sign command; this is the sign of the cross product.
            private _cross = (_dx * _py) - (_dy * _px);
            private _side = if (_cross > 0) then { 1 } else { if (_cross < 0) then { -1 } else { 0 } };
            [_p distance2D [(_ra select 0) + (_t * _dx), (_ra select 1) + (_t * _dy), 0], _side]
        };
        // Kept off Drongo's Air Operations when that mod is loaded, so there is
        // one air commander per aircraft. That mod takes over every crewed
        // vehicle it sees, two seconds after the crew appears. Measured with it
        // loaded: a plane the ATO crewed on its stand went from AWARE and YELLOW
        // to CARELESS and BLUE, weapons held, within six seconds, and it takes
        // an aircraft only the first time it is crewed, so that is the crew the
        // first sortie flies with. The mod's own way to be left alone is its
        // daoIgnore list, read before anything else it does to an aircraft, and
        // a daoExclude mark it also reads: the hull goes on the list before its
        // crew exists, so there is no window, and the group as soon as there is
        // one. Put on the list that way, the same plane stayed AWARE and YELLOW.
        // Nothing happens without the mod.
        private _fnc_keepOffAirOps = {
            params ["_o", ["_g", grpNull, [grpNull]]];
            if (isNil "daoIgnore" || {!(daoIgnore isEqualType [])}) exitWith { false };
            daoIgnore pushBackUnique _o;
            _o setVariable ["daoExclude", true, true];
            if (!isNull _g) then {
                daoIgnore pushBackUnique _g;
                _g setVariable ["daoExclude", true, true];
            };
            true
        };

        // What an aircraft that has been told to land is actually doing, for the
        // log. An RHS Apache on LAN hovered over its stand until the five minute
        // landing deadline put it down, in two runs (36 m up the time the height
        // was recorded), and the log could not say why: nothing on the landing
        // path wrote anything down. On the test server the same airframe lands in
        // about a minute with RHS alone and with every other mod that LAN run had,
        // and a vanilla attack helicopter does with soldiers or a truck beside the
        // pad, so what stops it is something only a real mission has. This names
        // the command in force, the crew's mood, what is broken, and what the
        // crew knows about. A hit point the airframe does not have reads -1.
        private _fnc_landingState = {
            params ["_o", "_padPos"];
            private _d = driver _o;
            private _g = group _d;
            private _fnc_hit = {
                private _v = _o getHitPointDamage _this;
                if (isNil "_v") then { -1 } else { _v }
            };
            format ["%1 m up, %2 m from the pad, %3 km/h, climbing %4 m/s, command '%5', %6 %7, %8 waypoints, engine %9, fuel %10, damage %11 (main rotor %12, tail rotor %13, engine %14, can move %15), local %16, %17 enemies known, Drongo '%18', spin %19 rad/s",
                round ((getPosATL _o) select 2), round (_o distance2D _padPos), round (speed _o), ((velocity _o) select 2) toFixed 1,
                if (isNull _d) then {"no pilot"} else {currentCommand _d},
                if (isNull _d) then {"-"} else {behaviour _d},
                if (isNull _g) then {"-"} else {combatMode _g},
                if (isNull _g) then {0} else {count (waypoints _g)},
                isEngineOn _o, (fuel _o) toFixed 2, (damage _o) toFixed 2,
                ("HitHRotor" call _fnc_hit) toFixed 2, ("HitVRotor" call _fnc_hit) toFixed 2, ("HitEngine" call _fnc_hit) toFixed 2,
                canMove _o, local _o,
                if (isNull _d) then {0} else {count (_d targets [true, 2000])},
                _o getVariable ["daoAction", "-"],
                // How fast it is turning over. A Blackfish put down from banked
                // flight on LAN was destroyed ten seconds later with nothing in
                // the log to say it had been thrown; spin is the first sign.
                (vectorMagnitude (angularVelocity _o)) toFixed 2]
        };

        // Seventy metres off to one side of a heading, the side further from the
        // runway, never into the sea, and for anything bigger than a man on the
        // nearest spot it fits.
        private _fnc_aside = {
            params ["_u", "_heading", "_cl"];
            private _a = _u getPos [70, _heading + 90];
            private _b = _u getPos [70, _heading - 90];
            private _to = if ((([_a, _cl] call _fnc_offRunway) select 0) >= (([_b, _cl] call _fnc_offRunway) select 0)) then { _a } else { _b };
            if (surfaceIsWater _to) then { _to = if (_to isEqualTo _a) then { _b } else { _a } };
            if !(_u isKindOf "CAManBase") then {
                private _clear = _to findEmptyPosition [0, 30, typeOf _u];
                if (count _clear > 1) then { _to = _clear };
            };
            _to set [2, 0];
            _to
        };

        switch (_effect) do {

            // ---- engine ---------------------------------------------------
            case "engineOn": {
                if (isEngineOn _obj) then { _matched = true } else { _obj engineOn true };
            };
            case "engineOff": {
                // Never in the air, whoever asks. A gunship that lifted off on its
                // own while it waited for the runway was parked at 199 m, and
                // parking switches the engine off. A stopped engine at height is
                // a crash.
                if (([_obj, _home] call _fnc_up) > 5) exitWith { _status = "refused"; _detail = "in the air" };
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
                    [_obj] call _fnc_keepOffAirOps;
                    private _grp = createVehicleCrew _obj;
                    if (isNull _grp) then {
                        _status = "refused"; _detail = "crew could not be created";
                    } else {
                        [_obj, _grp] call _fnc_keepOffAirOps;
                        // Marked so nothing else adopts them, and so they are
                        // recognisable as ours when they are stood down.
                        { _x setVariable ["ALiVE_mil_ato_crew", true, true] } forEach (units _grp);
                        _detail = str (count (units _grp));
                        // Aircraft have been turning up with an empty cockpit,
                        // which stops any order reaching them: issueOrders and
                        // landAtPad both refuse with "no group", and one
                        // helicopter finished a patrol and then hung over the
                        // airfield because it could not be told to land. Nothing
                        // in here recorded a crew being built or taken away, so
                        // the sequence could never be read off a log. Both ends
                        // say so now.
                        ["ALIVE_fnc_ATOEffect - crew of %1 built for %2 (%3)",
                            count (units _grp), typeOf _obj,
                            _obj getVariable ["ALiVE_mil_ato_tail", "no tail"]] call ALiVE_fnc_dump;
                    };
                };
            };

            case "mintDroneCrew": {
                if (count (crew _obj) > 0) then {
                    _matched = true;
                } else {
                    [_obj] call _fnc_keepOffAirOps;
                    [_obj, createVehicleCrew _obj] call _fnc_keepOffAirOps;
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
                    [_obj] call _fnc_keepOffAirOps;
                    [_obj, createVehicleCrew _obj] call _fnc_keepOffAirOps;
                    { _x setVariable ["ALiVE_mil_ato_crew", true, true] } forEach (crew _obj);
                    _detail = "recrewed";
                };
            };

            case "seatCrew": {
                _matched = ({alive _x} count (crew _obj)) > 0;
            };

            case "standDownCrew": {
                // Never in the air, whoever asks: the crew is the pilot.
                if (([_obj, _home] call _fnc_up) > 5) exitWith { _status = "refused"; _detail = "in the air" };
                private _ours = (crew _obj) select { _x getVariable ["ALiVE_mil_ato_crew", false] };
                private _tailNow = _obj getVariable ["ALiVE_mil_ato_tail", "no tail"];
                if (count _ours == 0) then {
                    _matched = true;
                } else {
                    // Deleted outright only when nobody is close enough to see
                    // it happen. Otherwise they get out and are removed once
                    // they have walked off, because people vanishing in front of
                    // you is worse than a few extra men standing about. Watching
                    // through a Zeus camera counts, the same as the observer's.
                    private _watched = [nil, "playersNear", [getPosATL _obj, 300]] call ALIVE_fnc_ATOObserve;
                    if (_watched == 0) then {
                        { deleteVehicle _x } forEach _ours;
                        ["ALIVE_fnc_ATOEffect - crew of %1 deleted from %2 (%3)",
                            count _ours, typeOf _obj, _tailNow] call ALiVE_fnc_dump;
                        _detail = "deleted";
                    } else {
                        // Let go of properly, so nothing can order them back in.
                        //
                        // Getting out and being told not to get in left the group
                        // still owning the aircraft. A gunship parked this way
                        // was 62 m up again 55 seconds later, and when the timer
                        // below fired its pilot was one of the men it had
                        // dismissed. A vanilla crew with no enemy about stayed out
                        // either way, so what sent them back is not known; this
                        // closes every way back in rather than guessing which.
                        { moveOut _x; unassignVehicle _x } forEach _ours;
                        _ours allowGetIn false;
                        _ours orderGetIn false;
                        private _groupsOut = [];
                        { _groupsOut pushBackUnique (group _x) } forEach _ours;
                        { if (!isNull _x) then { _x leaveVehicle _obj } } forEach _groupsOut;

                        // And somewhere to go. Measured on LAN: four men let out
                        // of a parked Blackfish stood beside it for the whole two
                        // minutes, because nothing gave them anywhere to be.
                        //
                        // The nearest building within 250 m that can be walked
                        // into, is not a hangar, is off the stand, and stands on
                        // the SAME side of the runway as the aircraft and at least
                        // 60 m from its line. Otherwise seventy metres off to the
                        // side further from the runway, never into the sea, which
                        // is the taxi sweep's own rule. The runway matters because
                        // these men carry the crew mark, so the sweep leaves them
                        // alone, and a landing jet does not stop for them: on
                        // Stratis the control tower is 188 m off the runway's line,
                        // within reach of stands on both sides of it.
                        //
                        // Nowhere on a deck or at a hold point. There is no runway
                        // line and no building, and seventy metres off a carrier
                        // is the sea, so there they stand where they got out.
                        private _dest = [];
                        if !(count _home > 2 && {(_home select 2) in ["deck","virtual"]}) then {
                            private _at = getPosATL _obj;
                            private _cl = [];
                            if (!isNil "ALiVE_fnc_getRunwayCentreline") then { _cl = [_at, 1500] call ALiVE_fnc_getRunwayCentreline };
                            private _mine = [_at, _cl] call _fnc_offRunway;
                            private _hangars = (if (isNil "ALIVE_airBuildingTypes") then {[]} else {ALIVE_airBuildingTypes})
                                + (if (isNil "ALIVE_militaryAirBuildingTypes") then {[]} else {ALIVE_militaryAirBuildingTypes});
                            private _near = (nearestObjects [_at, ["House"], 250]) select {
                                private _b = _x;
                                private _t = toLower (typeOf _b);
                                private _off = [getPosATL _b, _cl] call _fnc_offRunway;
                                (count (_b buildingPos -1) > 0)
                                    && {(_hangars findIf { [_t, _x] call CBA_fnc_find != -1 }) == -1}
                                    && {(_b distance2D _at) > 25}
                                    && {(_off select 0) >= 60}
                                    && {((_off select 1) == (_mine select 1)) || {(_mine select 1) == 0}}
                            };
                            _dest = if (count _near > 0) then {
                                getPosATL (_near select 0)
                            } else {
                                [_ours select 0, getDir _obj, _cl] call _fnc_aside
                            };
                        };
                        if (count _dest > 1) then {
                            {
                                private _g = _x;
                                if (!isNull _g) then {
                                    // The sortie's orders go first. A crew let out
                                    // with a search and destroy still set walks off
                                    // after it, as a landing aircraft would.
                                    for "_i" from ((count (waypoints _g)) - 1) to 0 step -1 do { deleteWaypoint [_g, _i] };
                                    _g setVariable ["ALiVE_mil_ato_orders", nil, false];
                                    _g setBehaviour "SAFE";
                                    _g setCombatMode "BLUE";
                                    _g setSpeedMode "LIMITED";
                                    _g move _dest;
                                };
                            } forEach _groupsOut;
                        };
                        ["ALIVE_fnc_ATOEffect - crew of %1 dismissed from %2 (%3), %4, deleted once nobody is near them",
                            count _ours, typeOf _obj, _tailNow,
                            if (count _dest > 1) then { format ["walking to %1", _dest apply { round _x }] } else { "let out where they stand" }] call ALiVE_fnc_dump;
                        [_ours, _obj, _tailNow] spawn {
                            params ["_units", "_hull", "_tailNow"];
                            // Two minutes to walk off, then each man goes as soon as
                            // nobody is near enough to see it happen, bodies and Zeus
                            // cameras both, and everyone left goes at ten minutes.
                            // It used to be all of them at two minutes wherever
                            // they were, in front of whoever was there.
                            //
                            // Anybody sitting in an aircraft that is off the ground
                            // is left alone at every step, whoever put him there.
                            // This timer deleted the four men of a gunship while it
                            // was flying, its pilot among them, and it crashed seven
                            // seconds later. Deleting a man who is flying something
                            // is never what this timer is for.
                            sleep 120;
                            private _elapsed = 120;
                            private _left = _units;
                            private _gone = 0;
                            private _flying = 0;
                            while { true } do {
                                _left = _left select { !isNull _x && {alive _x} };
                                private _keep = [];
                                _flying = 0;
                                {
                                    private _v = objectParent _x;
                                    if (!isNull _v && {((getPos _v) select 2) > 5}) then {
                                        _flying = _flying + 1;
                                        _keep pushBack _x;
                                    } else {
                                        if (_elapsed >= 600 || {([nil, "playersNear", [getPosATL _x, 300]] call ALIVE_fnc_ATOObserve) == 0}) then {
                                            deleteVehicle _x;
                                            _gone = _gone + 1;
                                        } else {
                                            _keep pushBack _x;
                                        };
                                    };
                                } forEach _left;
                                _left = _keep;
                                if ((count _left) == _flying || {_elapsed >= 600}) exitWith {};
                                sleep 15;
                                _elapsed = _elapsed + 15;
                            };
                            // Said once, at the end, because the thing worth knowing
                            // is whether anyone was deleted while the hull they came
                            // from was flying.
                            // The hull's own state last. It used to read "hull now has
                            // a dead hull aboard" when the aircraft had been destroyed
                            // and cleared away before its crew went.
                            ["ALIVE_fnc_ATOEffect - %1 dismissed crew of %2 deleted by %3 s, %4 left alone in an aircraft in the air, %5",
                                _gone, _tailNow, _elapsed, _flying,
                                switch (true) do {
                                    case (isNull _hull): { "the aircraft is gone" };
                                    case (!alive _hull): { "the aircraft was destroyed" };
                                    default { format ["hull now has %1 aboard", count (crew _hull)] };
                                }] call ALiVE_fnc_dump;
                        };
                        _detail = "dismissed";
                    };
                };
            };

            // ---- holding a crewed aircraft on its stand ------------------------
            // A plane given its crew starts its engine within a second and rolls
            // on idle thrust, about fourteen metres at up to nine kilometres an
            // hour, orders or none. In a tent hangar that puts its nose through
            // the door while it waits for the runway, and a gunship waiting the
            // same way lifted off altogether. Measured in one hangar bay, a minute
            // each: switching the pilot's movement off still rolled it 13.7 m;
            // switching the engine off as well still rolled it 13.8 m, because
            // the pilot starts it again; an empty tank held it at 0 m with the
            // engine never starting. So the tank is emptied before the crew is
            // made, and what was in it is kept on the hull and given back when
            // the wait ends, whichever way it ends. Given back and launched, the
            // same jet was fifty metres up 101 seconds later.
            //
            // Nothing here is saved: a restored aircraft is a fresh hull with a
            // full tank, so a hold cannot outlive a save.
            case "holdOnStand": {
                if (([_obj, _home] call _fnc_up) > 5) exitWith { _status = "refused"; _detail = "in the air" };
                private _kept = _obj getVariable ["ALiVE_mil_ato_heldFuel", -1];
                if (_kept isEqualType 0 && {_kept >= 0}) exitWith { _matched = true; _detail = "already held" };
                _obj setVariable ["ALiVE_mil_ato_heldFuel", fuel _obj, true];
                _obj engineOn false;
                _obj setFuel 0;
                _detail = "held";
            };

            // Given back on every way out of the wait. The hull may be on another
            // machine by then, a player's for one, and a tank set from here would
            // simply not change, so it is set where the hull lives.
            case "releaseHold": {
                private _kept = _obj getVariable ["ALiVE_mil_ato_heldFuel", -1];
                if (!(_kept isEqualType 0) || {_kept < 0}) exitWith { _matched = true; _detail = "not held" };
                if (local _obj) then {
                    _obj setFuel _kept;
                } else {
                    [_obj, _kept] remoteExec ["setFuel", _obj];
                };
                _obj setVariable ["ALiVE_mil_ato_heldFuel", nil, true];
                _detail = format ["fuel back to %1", _kept toFixed 2];
            };

            // ---- orders ------------------------------------------------------
            // Orders arrive already resolved to places: [[type, position], ...].
            // Turning a name like "go to the target" into a position needs to
            // know what the sortie is, and that is not this piece's business.
            case "issueOrders": {
                private _chain = _extra param [0, []];
                private _airborne = ([_obj, _home] call _fnc_up) > 50;

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
                    // And what it was doing up there, the moment before, for a
                    // landing that ran out of time rather than failing outright.
                    if (count _home > 0 && {([_obj, _home] call _fnc_up) > 5}) then {
                        ["ALIVE_fnc_ATOEffect - %1 (%2) when it was put down: %3", typeOf _obj,
                            _obj getVariable ["ALiVE_mil_ato_tail", "no tail"], [_obj, _home select 0] call _fnc_landingState] call ALiVE_fnc_dump;
                    };
                    // Said when it did not happen. The surface now also refuses a
                    // stand with a vehicle on it, and the aircraft is then still
                    // flying; recovery brings it round again.
                    if !([_surface, "place", [_obj, _home]] call ALIVE_fnc_ATOSurface) then {
                        _status = "refused"; _detail = "surface refused the placement";
                    };
                };
            };

            case "airborneStart": {
                if (([_obj, _home] call _fnc_up) > 50) then {
                    _matched = true;
                } else {
                    private _alt = _extra param [0, 300];
                    private _p = getPosATL _obj;
                    _obj setPosATL [_p select 0, _p select 1, _alt];
                    _obj engineOn true;
                    _obj setVelocity [(sin (getDir _obj)) * 90, (cos (getDir _obj)) * 90, 0];
                };
            };

            // Let a held aircraft go and put it into the air. The whole of a
            // launch from a base with no airfield.
            //
            // The order is measured and it matters. It is let go first, then
            // lifted, then given its engine, and only a PLANE is pushed: a
            // hundred and twenty metres a second is past a helicopter's top
            // speed. Both airframes flew two sorties each this way and were
            // holding their point in between.
            //
            // What makes this possible at all is not here: an aircraft that
            // lives at a virtual base is CREATED in flight (see placement), and
            // one created the ordinary way can never afterwards be put into the
            // air. Measured on a gunship, every way round: teleported up with
            // its engine running it was dead in fifteen seconds, frozen first
            // or not, pushed or not, with somewhere to go or nowhere.
            case "virtualLaunch": {
                if (([_obj, _home] call _fnc_up) > 50) then {
                    _matched = true;
                } else {
                    private _surfaceV = _extra param [0, []];
                    if ([_surfaceV] call ALIVE_fnc_isHash) then {
                        [_surfaceV, "release", _obj] call ALIVE_fnc_ATOSurface;
                    };
                    private _pV = getPosASL _obj;
                    _obj setPosASL [_pV select 0, _pV select 1, VIRTUAL_LAUNCH_ALT];
                    _obj setVectorUp [0,0,1];
                    _obj engineOn true;
                    if (_obj isKindOf "Plane") then {
                        _obj setVelocity [(sin (getDir _obj)) * 120, (cos (getDir _obj)) * 120, 0];
                    };
                };
            };

            // Never an aircraft that cannot move. An Apache with its rotors
            // broken off against a hangar was thrown six hundred metres up by
            // this and fell. The table no longer asks for it then; this holds
            // whoever asks.
            case "forceLaunch": {
                if (([_obj, _home] call _fnc_up) > 50) then {
                    _matched = true;
                } else {
                    if !(canMove _obj) then {
                        _status = "refused"; _detail = "it cannot fly";
                    } else {
                        private _p = getPosATL _obj;
                        _obj setPosATL [_p select 0, _p select 1, 600];
                        _obj engineOn true;
                        _obj setVelocity [(sin (getDir _obj)) * 120, (cos (getDir _obj)) * 120, 0];
                    };
                };
            };

            // ---- the taxi out ---------------------------------------------
            // Stands a plane on its airport's taxi route, pointing along it,
            // and leaves the engine to taxi it to the runway and take off.
            //
            // Nothing moved a land plane at launch before this. The launch was
            // the engine and a radio call, so the engine had to drive the
            // aircraft out from wherever it was parked, and a jet in a Stratis
            // tent hangar cannot: they stalled in the doorway or never moved,
            // and reached the air only when the launch deadline threw them six
            // hundred metres up.
            //
            // The route is the airport's ilsTaxiIn, which runs from the apron to
            // the runway threshold and is the path the engine's own taxi
            // follows. The module this one replaced started every departure on
            // its first point, facing the second. Measured on Stratis with
            // nothing else running: an A-164 stood there taxied the 908 m to the
            // threshold by itself and was fifty metres up 101 seconds later,
            // well inside the three minutes a launch is given.
            //
            // Not always on the first point, though. The engine joins the route
            // wherever the aircraft stands on it and carries on towards the
            // runway: an F/A-181 stood 45 m down the first leg, with a jet
            // parked on the head behind it, drove on to the threshold, took off
            // in 99 seconds and never came back towards the head. So the
            // aircraft goes to the point on the first leg nearest its own
            // stand. A jet in a hangar beside the far end of the taxiway is
            // moved a hundred metres onto it, rather than eight hundred back up
            // to the head, and has less of the taxiway to drive.
            //
            // Nothing is put on top of anything. Another aircraft, a vehicle,
            // somebody on foot or a wreck on the spot moves it further down the
            // leg, which keeps it AHEAD of whatever is in the way, as measured
            // with a parked one. Something MOVING on the leg behind the spot is
            // different: that is traffic coming this way, a player taxiing out
            // or another commander's launch on a shared field, and a jet stood
            // in front of it gets run into. Either that, or nothing clear
            // before the end of the leg within a hundred metres or so, is a
            // refusal, and the aircraft keeps the old launch from its stand.
            //
            // Fixed wing planes on land. A helicopter or a VTOL lifts where it
            // stands, and a deck plane or a held one has its own launch. The
            // table asks for this once, on the way into the launch: asked again
            // after the aircraft has rolled, it would pull it back to where it
            // started.
            case "taxiOut": {
                if !(_obj isKindOf "Plane") exitWith { _matched = true; _detail = "not a plane" };
                if (getNumber (configFile >> "CfgVehicles" >> typeOf _obj >> "vtol") != 0) exitWith {
                    _matched = true; _detail = "a VTOL lifts where it stands";
                };
                if (count _home > 2 && {(_home select 2) in ["deck","virtual"]}) exitWith {
                    _matched = true; _detail = "not a land home";
                };
                if (([_obj, _home] call _fnc_up) > 5) exitWith { _matched = true; _detail = "not on the ground" };
                if ((speed _obj) > 40) exitWith { _matched = true; _detail = "already rolling" };
                private _surfaceT = _extra param [0, []];
                if (_surfaceT isEqualTo []) exitWith { _status = "refused"; _detail = "no surface" };

                // The airport nearest the home, as for a landing: a plane that
                // has drifted from its stand still leaves from its own field.
                // Only the terrain's own airports. The shared lookup counts
                // carriers as well, and a land plane is not taxiing out along
                // a ship.
                private _from = _home param [0, []];
                if (!(_from isEqualType []) || {count _from < 2}) then { _from = getPosATL _obj };
                private _w = configFile >> "CfgWorlds" >> worldName;
                private _secondary = _w >> "SecondaryAirports";
                private _airportID = -1;
                private _nearest = 1e10;
                private _ilsMain = getArray (_w >> "ilsPosition");
                if (count _ilsMain >= 2) then { _airportID = 0; _nearest = _from distance2D _ilsMain };
                for "_i" from 0 to ((count _secondary) - 1) do {
                    private _ils = getArray ((_secondary select _i) >> "ilsPosition");
                    if (count _ils >= 2 && {(_from distance2D _ils) < _nearest}) then {
                        _nearest = _from distance2D _ils;
                        _airportID = _i + 1;
                    };
                };

                // The route, read from the terrain's config here rather than
                // through the shared taxi helper, which is only defined once
                // the module has been initialised and which also knows carriers.
                private _in = [];
                if (_airportID == 0) then { _in = getArray (_w >> "ilsTaxiIn") };
                if (_airportID > 0) then { _in = getArray ((_secondary select (_airportID - 1)) >> "ilsTaxiIn") };
                private _route = [];
                for "_i" from 0 to ((count _in) - 2) step 2 do {
                    _route pushBack [_in select _i, _in select (_i + 1), 0];
                };
                if (count _route > 1 && {(_from distance2D (_route select 0)) > TAXI_REACH}) then { _route = [] };

                // A terrain with no route in its config: the runway on the
                // ground by the stand instead, from the nearer end and pointing
                // down it, which is what the old module fell back on. That leg
                // IS the runway, so the aircraft goes to its end and is never
                // stood part way along it.
                private _alongLeg = true;
                if (count _route < 2) then {
                    _route = [];
                    _alongLeg = false;
                    private _cl = [];
                    if (!isNil "ALiVE_fnc_getRunwayCentreline") then { _cl = [_from, 1500] call ALiVE_fnc_getRunwayCentreline };
                    if (_cl isEqualType [] && {count _cl > 1}) then {
                        private _ca = _cl select 0;
                        private _cb = _cl select 1;
                        if ((_from distance2D _cb) < (_from distance2D _ca)) then {
                            private _swap = _ca; _ca = _cb; _cb = _swap;
                        };
                        _route = [[_ca select 0, _ca select 1, 0], [_cb select 0, _cb select 1, 0]];
                    };
                };
                if (count _route < 2) exitWith { _status = "refused"; _detail = "no taxi route or runway near its stand" };

                private _a = _route select 0;
                private _b = _route select 1;
                private _dir = _a getDir _b;
                private _dx = (_b select 0) - (_a select 0);
                private _dy = (_b select 1) - (_a select 1);
                private _leg = _a distance2D _b;
                if (_leg < 1) exitWith { _status = "refused"; _detail = "the taxi route has no first leg" };

                // How far a thing reaches from its centre, the larger of its
                // length and width halved. Two things are in each other's way
                // when their centres are closer than their two reaches together.
                // Asking only whether something's CENTRE is within this
                // aircraft's own reach, the way a stand is checked, would let two
                // jets be stood thirteen metres apart with their wings through
                // each other.
                private _fnc_halfSpan = {
                    (boundingBoxReal _this) params ["_lo", "_hi"];
                    ((abs ((_hi select 0) - (_lo select 0))) max (abs ((_hi select 1) - (_lo select 1)))) / 2
                };
                private _half = _obj call _fnc_halfSpan;

                // Whatever is standing on a spot. A wreck counts, as it does for
                // parking: driving into one is no better than driving into a
                // live one. A body on the ground does not, and nor does anyone
                // sitting in a vehicle, who is found as the vehicle, and nor does
                // a helicopter passing overhead. This aircraft is not in its own
                // way. Never closer than the stand's own check allows either, so
                // the placing below does not then refuse a spot passed here.
                private _fnc_standing = {
                    params ["_at"];
                    ((nearestObjects [_at, ["Air","LandVehicle","CAManBase"], _half + 60]) select {
                        !(_x isEqualTo _obj) && {isNull (objectParent _x)}
                        && {alive _x || {!(_x isKindOf "CAManBase")}}
                        && {((getPosATL _x) select 2) < 5}
                        && {(_x distance2D _at) < ((_half + (_x call _fnc_halfSpan) + 3) max ((_half + 4) max 12))}
                    }) param [0, objNull]
                };

                // Where on the first leg, as a distance from its start. The
                // nearest point to the stand, and never within an aircraft's
                // length of the turn at the far end, which is left for the engine
                // to take. On the runway itself only its end will do: anywhere
                // further along is a shorter run to take off in.
                private _last = if (_alongLeg) then { (_leg - (2 * _half) - 10) max 0 } else { 0 };
                private _along = 0;
                if (_alongLeg && {_leg > 0}) then {
                    _along = ((((_from select 0) - (_a select 0)) * _dx) + (((_from select 1) - (_a select 1)) * _dy)) / _leg;
                    _along = (_along max 0) min _last;
                };

                // Down the leg from there, a few metres at a time, for about a
                // hundred metres at most. Further than that and whatever is in
                // the way is more than a parked aircraft.
                private _spot = [];
                private _first = objNull;
                private _d = _along;
                private _tries = 0;
                while { count _spot == 0 && {_d <= _last} && {_tries < 12} } do {
                    private _p = _a getPos [_d, _dir];
                    _p set [2, 0];
                    private _there = [_p] call _fnc_standing;
                    if (isNull _there) then { _spot = _p } else { if (isNull _first) then { _first = _there } };
                    _d = _d + (_half max 5);
                    _tries = _tries + 1;
                };
                if (count _spot == 0) exitWith {
                    _status = "refused";
                    _detail = format ["the taxi route is blocked by %1", if (isNull _first) then {"nothing it could name"} else {typeOf _first}];
                };

                // Traffic coming this way. Anything on the ground and moving,
                // between a little before the start of the leg and the spot,
                // within forty metres of the line of it.
                private _upTo = _a distance2D _spot;
                private _coming = objNull;
                {
                    private _c = _x;
                    if (isNull _coming && {!(_c isEqualTo _obj)} && {alive _c} && {(speed _c) > 5}
                        && {((getPosATL _c) select 2) < 5}) then {
                        private _rx = ((getPosATL _c) select 0) - (_a select 0);
                        private _ry = ((getPosATL _c) select 1) - (_a select 1);
                        private _t = ((_rx * _dx) + (_ry * _dy)) / _leg;
                        private _off = abs (((_rx * _dy) - (_ry * _dx)) / _leg);
                        if (_t > -50 && {_t < _upTo} && {_off < 40}) then { _coming = _c };
                    };
                } forEach (nearestObjects [_a getPos [_upTo / 2, _dir], ["Air","LandVehicle"], (_upTo / 2) + 70]);
                if (!isNull _coming) exitWith {
                    _status = "refused";
                    _detail = format ["%1 is moving on the taxi route behind that spot", typeOf _coming];
                };

                // Already there. A second ask while it still stands where it was
                // put changes nothing; one after it has rolled would move it
                // back, which is why the table only asks once.
                if ((_obj distance2D _spot) < 5) exitWith { _matched = true; _detail = "already on the taxi route" };

                private _moved = round (_obj distance2D _spot);
                if !([_surfaceT, "place", [_obj, [_spot, _dir, "taxi"]]] call ALIVE_fnc_ATOSurface) exitWith {
                    _status = "refused"; _detail = "the surface refused the placement";
                };
                _detail = format ["moved %1 m to the taxi route", _moved];
                // Said out loud, because a detail is only ever written down when
                // an effect is refused, and moving an aircraft hundreds of
                // metres is worth a line whether or not anything went wrong.
                ["ALIVE_fnc_ATOEffect - %1 (%2) moved %3 m onto the taxi route of airport %4, %5 m down its first leg, heading %6%7",
                    typeOf _obj, _obj getVariable ["ALiVE_mil_ato_tail", "no tail"], _moved,
                    if (_alongLeg) then {str _airportID} else {"none, the runway itself"},
                    round (_a distance2D _spot), round _dir,
                    if (isNull _first) then {""} else {format [", further down because %1 was in the way", typeOf _first]}
                ] call ALiVE_fnc_dump;
            };

            // ---- keeping the taxi path clear ----------------------------------
            // Anything in a plane's path as it taxis out, up to 120 m ahead and
            // within thirty metres of its line, is moved aside, from the moment it
            // is stood on its route until it is fifty metres up.
            //
            // The module this one replaced did this, and the rewrite had it only
            // as a name nobody had built. An empty civilian van left where the
            // taxiway joins the runway held a jet on the ground until a player
            // moved it by hand.
            //
            // Soldiers and crewed vehicles are told to move first and put there
            // if they have not gone five seconds later, as the old watch did. An
            // EMPTY vehicle cannot move itself, so a civilian one is put aside at
            // once. An empty military vehicle is left where it is: somebody put
            // it there. Nothing a player is in or leads, a player on foot, or
            // this aircraft's own crew is touched. Aside is seventy metres off
            // the aircraft's line, on the side further from the runway, never
            // into the sea, on the nearest clear spot for a vehicle.
            //
            // Civilian is asked of the vehicle's FACTION, not its side: an empty
            // vehicle reads as civilian side whatever it belongs to.
            case "sweepTaxiPath": {
                if !(_obj isKindOf "Plane") exitWith { _matched = true; _detail = "not a plane" };
                if (([_obj, _home] call _fnc_up) > 5) exitWith { _matched = true; _detail = "not on the ground" };
                private _sweeping = _obj getVariable ["ALiVE_mil_ato_sweepUntil", -1];
                if (_sweeping isEqualType 0 && {time < _sweeping}) exitWith { _matched = true; _detail = "already sweeping" };
                _obj setVariable ["ALiVE_mil_ato_sweepUntil", time + SWEEP_SPAN, false];

                // The side helpers go in with it: a spawned thread does not see
                // the privates of the scope that started it.
                [_obj, _obj getVariable ["ALiVE_mil_ato_tail", "no tail"], _fnc_offRunway, _fnc_aside] spawn {
                    params ["_jet", "_tail", "_fnc_offRunway", "_fnc_aside"];
                    private _stop = time + SWEEP_SPAN;

                    // The runway's line, to pick the side away from it.
                    private _cl = [];
                    if (!isNil "ALiVE_fnc_getRunwayCentreline") then { _cl = [getPosATL _jet, 1500] call ALiVE_fnc_getRunwayCentreline };
                    private _fnc_putAside = {
                        params ["_u", "_to", "_how"];
                        private _was = getPosATL _u;
                        _u setVelocity [0,0,0];
                        _u setPosATL _to;
                        ["ALIVE_fnc_ATOEffect - %1 %2 put %3 m aside from the taxi path of %4 (%5)",
                            _how, typeOf _u, round (_was distance2D _to), _tail, typeOf _jet] call ALiVE_fnc_dump;
                    };

                    while { !isNull _jet && {alive _jet} && {((getPosATL _jet) select 2) < 50} && {time < _stop} } do {
                        private _pos = getPosATL _jet;
                        private _heading = getDir _jet;
                        private _hx = sin _heading;
                        private _hy = cos _heading;
                        {
                            private _u = _x;
                            // In the aircraft's PATH: ahead of it and within thirty
                            // metres of its line, not merely in front of it. The old
                            // watch swept a sixty degree cone, which at a hundred
                            // metres is a hundred metres either side, so a pickup
                            // moved seventy metres aside was still inside it and was
                            // moved again the next second.
                            private _rx = ((getPosATL _u) select 0) - (_pos select 0);
                            private _ry = ((getPosATL _u) select 1) - (_pos select 1);
                            private _ahead = (_rx * _hx) + (_ry * _hy);
                            private _lateral = abs ((_rx * _hy) - (_ry * _hx));
                            private _isMan = _u isKindOf "CAManBase";
                            private _aboard = if (_isMan) then { [] } else { (crew _u) select { alive _x } };
                            private _players = if (_isMan) then {
                                isPlayer _u || {isPlayer (leader (group _u))}
                            } else {
                                (_aboard findIf { isPlayer _x || {isPlayer (leader (group _x))} }) > -1
                            };
                            private _civilianEmpty = !_isMan && {count _aboard == 0}
                                && {getNumber (configFile >> "CfgFactionClasses" >> (faction _u) >> "side") == 3};
                            if (alive _u && {!(_u isEqualTo _jet)} && {isNull (objectParent _u)} && {!_players}
                                && {!(_u getVariable ["ALiVE_mil_ato_crew", false])}
                                && {_isMan || {count _aboard > 0} || {_civilianEmpty}}
                                && {_ahead > 0} && {_lateral < 30}) then {
                                if (_civilianEmpty) then {
                                    [_u, [_u, _heading, _cl] call _fnc_aside, "an empty"] call _fnc_putAside;
                                } else {
                                    private _warned = _u getVariable ["ALiVE_mil_ato_sweepAt", -1];
                                    if (_warned < 0) then {
                                        private _to = [_u, _heading, _cl] call _fnc_aside;
                                        _u setVariable ["ALiVE_mil_ato_sweepAt", time, false];
                                        _u setVariable ["ALiVE_mil_ato_sweepFrom", getPosATL _u, false];
                                        _u setVariable ["ALiVE_mil_ato_sweepTo", _to, false];
                                        private _mover = if (_isMan) then { _u } else {
                                            if (!isNull (driver _u)) then { driver _u } else { effectiveCommander _u }
                                        };
                                        if (!isNull _mover) then { _mover doMove _to };
                                    } else {
                                        private _from = _u getVariable ["ALiVE_mil_ato_sweepFrom", getPosATL _u];
                                        if ((_u distance2D _from) > 10) then {
                                            // Gone of its own accord. Warned afresh if it wanders back.
                                            _u setVariable ["ALiVE_mil_ato_sweepAt", -1, false];
                                        } else {
                                            if ((time - _warned) > 5) then {
                                                [_u, _u getVariable ["ALiVE_mil_ato_sweepTo", [_u, _heading, _cl] call _fnc_aside], "a"] call _fnc_putAside;
                                                _u setVariable ["ALiVE_mil_ato_sweepAt", -1, false];
                                            };
                                        };
                                    };
                                };
                            };
                        } forEach (nearestObjects [_pos, ["CAManBase","LandVehicle"], 120]);
                        sleep 1;
                    };
                    if (!isNull _jet) then { _jet setVariable ["ALiVE_mil_ato_sweepUntil", nil, false] };
                };
                _detail = "sweeping";
            };

            // ---- the catapult -----------------------------------------------
            // Finds a free catapult on the aircraft's own ship, tows the
            // aircraft onto it and shoots it off. One effect rather than three
            // because the three are one sequence with one window in which a
            // second ask must do nothing, and split up the table would have
            // three things that can each be half done.
            //
            // What happens synchronously, before this answers: the pilot's
            // MOVE AI is switched off so the pending takeoff order cannot
            // taxi the aircraft out from under the tow, damage is switched
            // off, and the launch is stamped on the hull. Everything that
            // takes time is spawned. The stamp is a local variable and is
            // never saved, so a reload cannot resurrect a launch.
            case "catapult": {
                private _surface = _extra param [0, []];
                private _tail = _extra param [1, ""];
                if (_surface isEqualTo []) exitWith { _status = "refused"; _detail = "no surface" };

                // A launch already under way owns the aircraft until its stamp
                // runs out. The stamp carries its own expiry rather than a
                // start time, so the length of the window lives here, beside
                // the sequence that owns it, and the observer can read the same
                // variable without agreeing a number with this file.
                private _until = _obj getVariable ["ALiVE_mil_ato_catapultUntil", -99999];
                if !(_until isEqualType 0) then { _until = -99999 };
                if (time < _until) exitWith { _matched = true; _detail = "launch in progress" };

                // The MOVE AI toggle needs somebody at the controls. The table
                // only asks this with the crew seated, so a refusal here is
                // something worth reading.
                private _pilot = driver _obj;
                if (isNull _pilot || {!alive _pilot}) exitWith { _status = "refused"; _detail = "no pilot" };

                private _ship = [_surface, "carrierFor", _home param [3, []]] call ALIVE_fnc_ATOSurface;
                if (isNull _ship) exitWith { _status = "refused"; _detail = "no carrier" };

                // IS IT ON THE DECK. Asked before anything else is touched,
                // and the reason it has to be asked is worth writing down.
                //
                // The table asks for a launch on every tick while the aircraft
                // is not airborne, and airborne means fifty metres up. The
                // engine's own shot leaves a jet at about twenty four, which is
                // airborne and under the gate, so the state stays in LAUNCHING
                // and this is asked again. With no test for where the aircraft
                // actually is, the next attempt found its catapult empty, said
                // free, and towed a jet that was by then kilometres away and
                // flying back across the sea, pinned it above the plating where
                // the engine's launch cannot fire, and released it to fall. A
                // jet that had rolled off the bow into the water was pinned
                // inside the hull instead.
                //
                // Both go away if the question is asked. Near the ship, and at
                // the height of its deck.
                private _deckZ = ([_surface, "deckGeometry", _ship] call ALIVE_fnc_ATOSurface) param [0, -9999];
                if (_deckZ < -9000) exitWith { _status = "refused"; _detail = "the deck level is not known" };
                private _dShip = _obj distance2D _ship;
                private _dDeck = abs (((getPosASL _obj) select 2) - _deckZ);
                if (_dShip > CATAPULT_TOW_REACH + 100 || {_dDeck > 6}) exitWith {
                    _status = "refused";
                    _detail = format ["not on the deck (%1 m from the ship, %2 m off deck level)",
                        round _dShip, round _dDeck];
                };

                private _free = [_surface, "freeCatapult", [_ship, getPosASL _obj, [_obj]]] call ALIVE_fnc_ATOSurface;
                if !(_free isEqualType [] && {count _free > 4}) exitWith { _status = "refused"; _detail = "no free catapult" };
                _free params ["_part", "_mem", "_dirOffset", "_anims", "_catPos"];

                // Too far to tow is a refusal, not a faster tow. Capping the
                // TIME while letting the distance grow is what turned a long
                // tow into a three kilometre drag at three hundred and
                // seventy five metres a second.
                // The height the aircraft is held at is TRACED, not taken
                // from the catapult's own memory point.
                //
                // The memory point sits at 23.70 on this ship and the plating
                // traces at 23.48, and setPosWorld at the memory point slid the
                // aircraft seven metres off the wire where setPosASL at the
                // traced height put it on it to the metre. Measured, five
                // placements side by side.
                private _catTop = ([_surface, "deckTop", [[_catPos select 0, _catPos select 1, 0], []]] call ALIVE_fnc_ATOSurface) select 0;
                if (_catTop < -9000) then { _catTop = _catPos select 2 };

                private _towDist = _obj distance2D _catPos;
                if (_towDist > CATAPULT_TOW_REACH) exitWith {
                    _status = "refused";
                    _detail = format ["%1 m is too far to tow to %2", round _towDist, _mem];
                };

                // The launch heading. The part's own heading less the
                // catapult's offset, brought back into 0 to 360 because SQF's
                // remainder keeps the sign.
                //
                // NOT less a further 180, which the engine's own carrier
                // functions do and which is where that came from. Those orient
                // an aircraft to LOCK ON to the shuttle, and it faces the other
                // way to do that; it is not the direction it leaves in.
                //
                // Measured, both ways, on the test carrier with its bow at
                // model y plus 190 and the catapult at y minus 63:
                //
                //   with the extra 180, heading 178   thrown down the deck
                //                                     towards the STERN, ends at
                //                                     model y minus 199, twelve
                //                                     metres above the sea doing
                //                                     nothing
                //   without it, heading 358           409 km/h at 104 m four
                //                                     seconds out, climbing
                //                                     away, 1980 m from the
                //                                     ship at 434 km/h, alive
                private _launchDir = ((((getDir _part) - _dirOffset) % 360) + 360) % 360;

                _pilot disableAI "MOVE";
                _obj allowDamage false;
                // Stamped NOW, so the catapult is claimed from this moment
                // rather than from whenever the tow happens to arrive. Without
                // that there was a window of up to thirty seconds in which the
                // aircraft was still on its stand, nothing was near the
                // catapult, and a second aircraft was told the same catapult
                // was free.
                _obj setVariable ["ALiVE_mil_ato_catapultUntil", time + CATAPULT_WINDOW, false];
                _obj setVariable ["ALiVE_mil_ato_catapult", _mem, false];

                ["ALIVE_fnc_ATOEffect - %1 (%2) towed to %3 on %4, launch heading %5",
                    typeOf _obj, _tail, _mem, typeOf _part, round _launchDir] call ALiVE_fnc_dump;

                // The sequence. It is the old module's launch, which worked,
                // with two things in front of it: the wings are unfolded,
                // because the engine's own catapult refuses a folded aircraft
                // and it costs nothing on one without folding wings, and the
                // aircraft is TOWED to the wire rather than set on it. A jet
                // on its stand is twenty to sixty metres from a catapult, so
                // at the engine's five metres a second that is four to twelve
                // seconds of visible movement rather than a jump, and it is
                // the same loop the pin needs anyway.
                [_obj, _pilot, _part, _anims, _catPos, _launchDir, _deckZ, _catTop] spawn {
                    params ["_obj", "_pilot", "_part", "_anims", "_catPos", "_launchDir", "_deckZ", "_catTop"];

                    // Why the sequence may no longer proceed, asked at every
                    // step rather than once at the start.
                    //
                    // This used to ask only whether the hull was dead, and the
                    // three absolute refusals in front of the effect are
                    // evaluated ONCE. Everything that matters here happens over
                    // the next half minute. So a player who took a seat two
                    // seconds in was towed across the deck, pinned for six
                    // seconds where he could neither fly nor get out, and shot
                    // off the bow with his damage turned off. The table had
                    // already stopped asking; the running thread did not care.
                    // Teleporting an aircraft out from under somebody is the
                    // thing this module exists to stop.
                    private _fnc_stop = {
                        if (isNull _obj) exitWith { "the hull is gone" };
                        if (!alive _obj) exitWith { "the hull is dead" };
                        if (!local _obj) exitWith { "the hull moved to another machine" };
                        if (({alive _x && {isPlayer _x}} count (crew _obj)) > 0) exitWith { "somebody got in" };
                        if (isNull _pilot || {!alive _pilot}) exitWith { "the pilot is gone" };
                        ""
                    };

                    // And one way out, reached from every check, which puts
                    // back everything the sequence changed. The deflectors
                    // especially: they used to come down on the success path
                    // only, so a hull that died while pinned left that
                    // catapult's blast deflector standing up for the rest of
                    // the mission, and the next aircraft towed onto it was
                    // pinned inside raised geometry.
                    private _fnc_standDown = {
                        params ["_why"];
                        [_part, _anims, 0] call BIS_fnc_Carrier01AnimateDeflectors;
                        if (!isNull _obj) then {
                            _obj allowDamage true;
                            _obj setVariable ["ALiVE_mil_ato_catapultUntil", nil, false];
                            _obj setVariable ["ALiVE_mil_ato_catapult", nil, false];
                        };
                        if (!isNull _pilot && {alive _pilot}) then { _pilot enableAI "MOVE" };
                        ["ALIVE_fnc_ATOEffect - the launch stood down: %1", _why] call ALiVE_fnc_dump;
                    };
                    private _fnc_gone = { !(([] call _fnc_stop) isEqualTo "") };

                    private _aas = configFile >> "CfgVehicles" >> typeOf _obj >> "AircraftAutomatedSystems";
                    private _unfolded = getNumber (_aas >> "wingStateUnFolded");
                    { _obj animate [_x, _unfolded] } forEach (getArray (_aas >> "wingFoldAnimations"));

                    // The tow. Straight line at the aircraft's OWN height, so
                    // the frame the aircraft is standing in is the frame it
                    // arrives in: the deck is level and the catapult is on
                    // it. Position and heading each take as long as they
                    // need at the engine's pace, capped, and the aircraft is
                    // held level throughout because the surface normal over
                    // water answers about the sea.
                    // Above sea level, at the height the plating traces at,
                    // and set with setPosASL rather than setPosWorld.
                    //
                    // Taking the height from the AIRCRAFT was tried, and it
                    // meant an attempt on an aircraft that was not on the deck
                    // pinned it at its own altitude over the catapult, where
                    // the engine's launch, which fires only under a metre up,
                    // did nothing and the aircraft was released in mid-air.
                    private _startW = getPosASL _obj;
                    private _target = [_catPos select 0, _catPos select 1, _catTop];
                    private _height = _catTop;
                    private _dist = (_startW distance2D _target) max 0.1;
                    private _dirStart = (getDir _obj) % 360;
                    private _dirDelta = (_launchDir - _dirStart) % 360;
                    if (_dirDelta < -180) then { _dirDelta = _dirDelta + 360 };
                    if (_dirDelta > 180) then { _dirDelta = _dirDelta - 360 };
                    private _tMove = (_dist / CATAPULT_TOW_SPEED) min CATAPULT_TOW_MAX;
                    private _tTurn = ((abs _dirDelta) / CATAPULT_TOW_TURN) min CATAPULT_TOW_MAX;
                    private _t0 = time;
                    private _towing = true;
                    while { _towing && {!(call _fnc_gone)} } do {
                        private _dt = time - _t0;
                        _obj setVectorUp [0,0,1];
                        if (_dt >= _tMove) then {
                            _obj setPosASL _target;
                        } else {
                            private _f = _dt / _tMove;
                            _obj setPosASL [
                                (_startW select 0) + (((_target select 0) - (_startW select 0)) * _f),
                                (_startW select 1) + (((_target select 1) - (_startW select 1)) * _f),
                                _height
                            ];
                        };
                        if (_dt >= _tTurn) then {
                            _obj setDir _launchDir;
                        } else {
                            _obj setDir (_dirStart + (_dirDelta * (_dt / _tTurn)));
                        };
                        _towing = (_dt < _tMove) || {_dt < _tTurn};
                        sleep 0.01;
                    };
                    private _why = [] call _fnc_stop;
                    if !(_why isEqualTo "") exitWith { [_why] call _fnc_standDown };
                    _obj setVelocity [0,0,0];

                    // From here on it is the old module's sequence, which is
                    // the one measured to work: deflectors up, then the
                    // aircraft pinned to the wire with its engine running,
                    // then the engine's own launch, then a kick if the
                    // engine's launch left it low, then the deflectors down
                    // and damage back on.
                    [_part, _anims, 10] call BIS_fnc_Carrier01AnimateDeflectors;

                    _obj setFuel 1;
                    _obj engineOn true;
                    private _until = time + CATAPULT_PIN;
                    waitUntil {
                        if (!(call _fnc_gone)) then {
                            _obj setPosASL _target;
                            _obj setDir _launchDir;
                        };
                        (time >= _until) || {call _fnc_gone}
                    };
                    _why = [] call _fnc_stop;
                    if !(_why isEqualTo "") exitWith { [_why] call _fnc_standDown };

                    // The pilot is given the controls back and pointed
                    // straight ahead AND UP.
                    //
                    // The height is the whole of it. This was first written
                    // aiming two thousand metres out at the height the aircraft
                    // was standing at, which on a deck is about zero, so the
                    // point was on the water: the jet flew level off the bow at
                    // the sea, stayed under the fifty metres that counts as
                    // airborne, and so never left LAUNCHING, which let the
                    // whole launch be asked for again from scratch.
                    //
                    // Issuing NOTHING was then tried, on the grounds that the
                    // old module issued nothing and relied on the take-off
                    // order already sitting on the group. Measured: with no
                    // sortie behind it there is no such order, and the jet left
                    // the wire with nowhere to go, coasted off the bow and was
                    // in the sea twenty seconds later, 243 m out at eleven
                    // metres above sea level doing nothing. Relying on an order
                    // that may or may not be there is the fault in both
                    // directions.
                    //
                    // So the point is built here, explicitly: two thousand
                    // metres down the launch heading at three hundred metres
                    // above the surface. That is an above-surface height
                    // because doMove takes one, and over water above-surface
                    // and above-sea-level are the same number. ENROUTE
                    // replaces it a tick or two later on a real sortie.
                    if (!isNull _pilot && {alive _pilot}) then {
                        _pilot enableAI "MOVE";
                        private _ahead = _obj getPos [2000, _launchDir];
                        _ahead set [2, 300];
                        _obj doMove _ahead;
                        _pilot doMove _ahead;
                    };

                    // Spawned, because it sleeps. It refuses a hull that is not
                    // local, which the LOCAL_ONLY refusal above already ruled out.
                    [_obj, _launchDir] spawn BIS_fnc_AircraftCatapultLaunch;

                    // Eight tenths of a second, not two and two tenths.
                    //
                    // The catapults sit at model y minus sixty three and the
                    // bow is at plus a hundred and ninety, so an aircraft shot
                    // from one travels about two hundred and fifty metres ALONG
                    // the deck before it clears the ship. Measured at the old
                    // two and two tenths: twenty four metres above sea level
                    // against a deck at twenty three and a half, so it had
                    // spent that whole time flying half a metre above the
                    // plating at nearly five hundred kilometres an hour. The
                    // climb was arriving after the part of the launch that
                    // needed it, which is why the same code put a jet 1595 m
                    // clear on one run and in the sea on the next.
                    sleep 0.8;
                    _why = [] call _fnc_stop;
                    if !(_why isEqualTo "") exitWith { [_why] call _fnc_standDown };
                    // Not going fast enough to fly after the shot: the
                    // measured kick, seventy forward and fifty up, exactly as
                    // the old module gave it.
                    //
                    // The gate is height, and the height is well clear of the
                    // deck. The vertical half of the kick is what makes the
                    // difference: the engine's shot gives real forward speed
                    // and almost no climb, so a jet that is not helped upward
                    // leaves the bow level at deck height and is in the water
                    // seconds later.
                    //
                    // Measured three ways. With the kick: 409 km/h at 104
                    // metres four seconds out, 1980 m from the ship at 434
                    // km/h, alive. Gated on airspeed instead, so that a jet
                    // already doing over two hundred was NOT helped: in the sea
                    // 349 m out, destroyed. Gated on the old module's twenty
                    // four metres above sea level: a coin toss, because this
                    // deck is at twenty three and a half and the aircraft
                    // starts on it.
                    //
                    // Sixty is the figure because it is far enough above any
                    // deck that the deck cannot sit on the line, and low enough
                    // that an aircraft which is genuinely climbing away is left
                    // alone. The second clause catches one that is high but
                    // sinking.
                    private _aslNow = (getPosASL _obj) select 2;
                    private _velNow = velocity _obj;
                    if (_aslNow < 60 || {(_velNow select 2) < 2}) then {
                        // ADDED to what the aircraft already has, which is the
                        // old module's measured kick and is kept for a reason.
                        //
                        // Setting the velocity outright was tried instead, on
                        // the grounds that it removes the run to run variance
                        // in what the engine's launch gives. It made things
                        // worse, nought out of three, and the diagnostic said
                        // why: the aircraft was already doing 294 km/h at
                        // twenty four metres with a rate of plus one, which is
                        // a sound launch, and an absolute set to a twelve metre
                        // climb replaced a fifty metre one. Fifty metres a
                        // second of climb, even for a second, is what buys the
                        // altitude to clear the water while the pilot takes
                        // over. That is the whole point of it.
                        private _dir = direction _obj;
                        private _vel = velocity _obj;
                        _obj setVelocity [
                            (_vel select 0) + (sin _dir * 70),
                            (_vel select 1) + (cos _dir * 70),
                            (_vel select 2) + 50
                        ];
                        ["ALIVE_fnc_ATOEffect - %1 off the wire was %2 m up at %3 km/h, rate %4; set to a climb",
                            typeOf _obj, round _aslNow, round (speed _obj), round (_velNow select 2)] call ALiVE_fnc_dump;
                    } else {
                        ["ALIVE_fnc_ATOEffect - %1 off the wire was %2 m up at %3 km/h, rate %4; left alone",
                            typeOf _obj, round _aslNow, round (speed _obj), round (_velNow select 2)] call ALiVE_fnc_dump;
                    };

                    // Damage stays off until the aircraft is actually flying,
                    // not for a fixed four seconds.
                    //
                    // A jet dips towards the water after the shot before it
                    // starts climbing, and with damage back on a graze kills
                    // it. On a fixed timer that made the whole launch a coin
                    // toss: the same code flew to 1401 m at 467 km/h on one run
                    // and was in the sea 476 m out on the next. The module
                    // already does it this way when it sets an aircraft down on
                    // a stand, and for the same reason.
                    //
                    // Clear means a hundred metres up and moving like an
                    // aircraft. If it never gets there, the deflectors still
                    // come down and the catapult is still released, but damage
                    // is left off and that is said out loud, exactly as the
                    // placing does.
                    private _clearBy = time + 25;
                    private _flying = false;
                    while { !_flying && {time < _clearBy} && {!(call _fnc_gone)} } do {
                        sleep 1;
                        _flying = ((getPosASL _obj) select 2) > 100 && {(speed _obj) > 250};
                    };
                    _why = [] call _fnc_stop;
                    if !(_why isEqualTo "") exitWith { [_why] call _fnc_standDown };

                    if (_flying) then {
                        // The same stand-down as every failure path, because a
                        // finished launch and an abandoned one have to leave
                        // the catapult in the same state.
                        ["the launch finished"] call _fnc_standDown;
                    } else {
                        [_part, _anims, 0] call BIS_fnc_Carrier01AnimateDeflectors;
                        _obj setVariable ["ALiVE_mil_ato_catapultUntil", nil, false];
                        _obj setVariable ["ALiVE_mil_ato_catapult", nil, false];
                        ["ALIVE_fnc_ATOEffect - %1 never got established after its launch (%2 m up, %3 km/h); damage left off",
                            typeOf _obj, round ((getPosASL _obj) select 2), round (speed _obj)] call ALiVE_fnc_dump;
                    };
                };

                _detail = _mem;
            };

            // ---- the hook ---------------------------------------------------
            // Drops the arrestor hook and hands the arrest to the engine, which
            // waits until the aircraft is on the deck and within reach of the
            // wire and then slows it. Idempotent against itself through the
            // flag, and against the aircraft's own config landing handler
            // (vanilla jets drop the hook themselves on an airport approach)
            // because animating a hook that is already down moves nothing.
            //
            // The engine's wait has no timeout: it ends when the hook is
            // raised, the hull dies, or the aircraft touches down. So
            // releaseApproach raises a hook this put out, which is what ends
            // that thread on an approach that never landed.
            case "tailhook": {
                private _cfg = configFile >> "CfgVehicles" >> typeOf _obj;
                if (getNumber (_cfg >> "tailHook") == 0) exitWith {
                    _status = "refused"; _detail = "no hook on this aircraft";
                };
                private _list = getArray (_cfg >> "CarrierOpsCompatability" >> "ArrestHookAnimationList");
                private _states = getArray (_cfg >> "CarrierOpsCompatability" >> "ArrestHookAnimationStates");
                if (count _list == 0) exitWith {
                    _status = "refused"; _detail = "this aircraft has no hook to animate";
                };
                // States are [down, caught, up], the engine's own order.
                private _down = _states param [0, 0];
                private _first = _list param [0, ""];

                // Is the hook DOWN, asked of the hook.
                //
                // This used to read a flag this module had set, and the engine
                // raises the hook on its own in three places: when an aircraft
                // touches down with no wire in reach, which is a bolter; at the
                // end of every arrest; and through the aircraft's own
                // landing-cancelled handler. After a bolter the flag still said
                // out, so every following tick answered "nothing to do" and the
                // go-around was flown hook up with the wire never catching. The
                // observer's own rule applies here: nothing downstream should
                // have to trust a flag somebody set earlier and forgot to clear.
                //
                // The phase is the engine's own test for this.
                if ((_obj animationPhase _first) < ((_down + 0.1) max 0.1)) exitWith {
                    _matched = true; _detail = "hook already down";
                };

                { _obj animate [_x, _down] } forEach _list;

                // The arrest thread is only started when the aircraft does not
                // already start one for itself. A vanilla jet carries a landing
                // event handler that spawns the engine's arrest on any
                // engine-driven approach, which is exactly what this module's
                // own landing order produces. Two threads then run the same
                // deceleration loop on one hull, and the first arrest slows it
                // at twice the rate the config asks for.
                private _ownHandler = getText (_cfg >> "EventHandlers" >> "landing");
                if (_ownHandler isEqualTo "") then {
                    [_obj] spawn BIS_fnc_aircraftTailhook;
                };

                // The flag is kept, but only to record that THIS module put the
                // hook out, so the approach being given back knows to raise it.
                // It is never read as "is the hook down" again.
                _obj setVariable ["ALiVE_mil_ato_hookOut", true, false];
                _detail = if (_ownHandler isEqualTo "") then { "hook out" } else { "hook out, the aircraft arrests itself" };
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
            // Brings a PLANE down, which the pad approach cannot do.
            //
            // Every aircraft used to be aimed at its own parking stand, and a
            // stand is twelve metres across. Measured on Stratis, all three
            // given the same approach from 900 m out at 120 m, the order
            // re-issued every two seconds exactly as the table does it:
            //
            //   helicopter   came down 2 m from its stand, alive
            //   jet          overflew at 24 m, climbed away, DESTROYED 1649 m out
            //   VTOL         139 km/h at three metres, DESTROYED
            //
            // So every fixed-wing aircraft this module owned was destroyed on
            // its way home, and nothing caught it because the landing checks
            // only ever flew a helicopter.
            //
            // The engine has a primitive for this and it works. The same two
            // airframes given the airport flew the circuit and came down on the
            // runway alive, in 106 and 126 seconds. It is exactly wrong for a
            // helicopter, which under the same order hovered at 116 m, two
            // kilometres out, indefinitely: the two kinds need opposite orders
            // and each one's correct order is the other's failure.
            case "landOnRunway": {
                private _surface = _extra param [0, []];
                private _tail = _extra param [1, ""];

                private _grp = group (driver _obj);
                if (isNull _grp) exitWith { _status = "refused"; _detail = "no group" };

                // The airport is taken from the HOME, not from where the
                // aircraft happens to be: a jet that wandered on its way back
                // should come home, not to whatever field it drifted over.
                private _from = _home param [0, []];
                if (!(_from isEqualType []) || {count _from < 2}) then { _from = getPosATL _obj };
                private _airportID = -1;
                if (!isNil "ALiVE_fnc_getNearestAirportID") then {
                    private _got = [_from] call ALiVE_fnc_getNearestAirportID;
                    if (_got isEqualType 0) then { _airportID = _got };
                };
                if (_airportID < 0) exitWith { _status = "refused"; _detail = "no airport to land at" };

                private _aimedAt = _grp getVariable ["ALiVE_mil_ato_runwayAimedAt", -1];
                if !(_aimedAt isEqualType 0) then { _aimedAt = -1 };

                if (_aimedAt < 0) then {
                    // The chain goes first. A pending waypoint outranks a
                    // landing order, which is how an approach was lost before.
                    private _wps = waypoints _grp;
                    for "_i" from (count _wps - 1) to 0 step -1 do { deleteWaypoint [_grp, _i] };
                    _grp setVariable ["ALiVE_mil_ato_orders", nil, false];
                    _grp setVariable ["ALiVE_mil_ato_landing", true, false];
                };

                if (_aimedAt < 0 || {(time - _aimedAt) > RUNWAY_REAIM}) then {
                    // Quiesced for the same reason the pad approach is: a pilot
                    // with evasion and targeting live ignores a landing order
                    // outright, and this aircraft has just spent its sortie on a
                    // search and destroy waypoint, so it is in combat behaviour
                    // by definition.
                    _grp setBehaviour "CARELESS";
                    _grp allowFleeing 0;
                    _grp setCombatMode "BLUE";
                    {
                        _x disableAI "AUTOTARGET";
                        _x disableAI "TARGET";
                        _x setSkill ["courage", 1];
                    } forEach (units _grp);

                    // "NONE" first, to clear any standing landing order, then
                    // the airport. This is the pair that was measured working;
                    // land "LAND" is the helicopter's order and it is what
                    // destroyed these aircraft.
                    _obj land "NONE";
                    _obj landAt _airportID;
                    _grp setVariable ["ALiVE_mil_ato_runwayAimedAt", time, false];
                    _detail = format ["sent to airport %1", _airportID];
                } else {
                    _detail = format ["on the circuit for airport %1, %2 s",
                        _airportID, round (time - _aimedAt)];
                };
            };

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
                    _grp setVariable ["ALiVE_mil_ato_landingSince", time, false];
                    _grp setVariable ["ALiVE_mil_ato_landingStallSaid", nil, false];
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

                // Still up a minute after it was over its stand and told to come
                // down: said once, with everything that could be holding it. On
                // the test server these landings were down 12 to 22 seconds after
                // that point, so this only speaks for a stuck one.
                private _since = _grp getVariable ["ALiVE_mil_ato_landingSince", -1];
                if (_since >= 0 && {(time - _since) >= 60} && {_agl > 5}
                    && {!(_grp getVariable ["ALiVE_mil_ato_landingStallSaid", false])}) then {
                    _grp setVariable ["ALiVE_mil_ato_landingStallSaid", true, false];
                    ["ALIVE_fnc_ATOEffect - %1 (%2) told to land %3 s ago and not down: %4; last step '%5'",
                        typeOf _obj, _tail, round (time - _since), [_obj, _stand] call _fnc_landingState, _detail] call ALiVE_fnc_dump;
                };
            };

            // ---- a plane coming back to a ship --------------------------------
            // The plane's equivalent of landAtPad, re-issued every tick by the
            // table. A jet cannot be brought down on a pad: landAtPad's arrival
            // gate wants it under forty km/h, which a jet cannot do in the air.
            // Its approach is the engine's own, aimed at the airport object the
            // carrier carries, and its arrival is the wire.
            //
            // Nothing here slows it or sets a height. A jet held to a landing
            // pace stalls, and the engine flies a carrier approach on its own
            // once it has been told where the airport is. Both landing orders
            // are given, in this order, because that is what the old module
            // did for carriers: land "LAND" is the intent to come down, landAt
            // names where, in the object form so no airport id arithmetic is
            // needed. Re-issued every thirty-five seconds rather than every
            // tick, for landAtPad's reason: re-issuing restarts the approach.
            case "deckRecover": {
                private _surface = _extra param [0, []];
                private _tail = _extra param [1, ""];
                if (_surface isEqualTo []) exitWith { _status = "refused"; _detail = "no surface" };

                private _grp = group (driver _obj);
                if (isNull _grp) exitWith { _status = "refused"; _detail = "no group" };

                private _ship = [_surface, "carrierFor", _home param [3, []]] call ALIVE_fnc_ATOSurface;
                if (isNull _ship) exitWith { _status = "refused"; _detail = "no carrier" };

                // The DynamicAirport_01_F the carrier carries. The hull's own
                // config has no landing data at all; deckGeometry finds the
                // lines to keep clear the same way.
                private _airObj = (nearestObjects [getPosASL _ship, ["AirportBase"], 400]) param [0, objNull];
                if (isNull _airObj) exitWith { _status = "refused"; _detail = "carrier has no airport" };

                private _committed = _grp getVariable ["ALiVE_mil_ato_landing", false];
                if (!_committed) then {
                    // Clear the chain first, as landAtPad does: a pending
                    // waypoint or move competes with the landing and wins.
                    private _wps = waypoints _grp;
                    for "_i" from (count _wps - 1) to 0 step -1 do { deleteWaypoint [_grp, _i] };
                    _grp setVariable ["ALiVE_mil_ato_orders", nil, false];
                    // Any standing landing order is cleared by the aim below
                    // rather than here. Clearing it here as well meant it was
                    // issued and then contradicted twenty lines later in the
                    // same call, so the "start clean" step did nothing.
                    _grp setVariable ["ALiVE_mil_ato_landing", true, false];
                    _grp setVariable ["ALiVE_mil_ato_landingAimedAt", -1, false];
                };

                private _dShip = _obj distance2D _ship;
                private _up = [_obj, _home] call _fnc_up;
                private _aimedAt = _grp getVariable ["ALiVE_mil_ato_landingAimedAt", -1];
                if !(_aimedAt isEqualType 0) then { _aimedAt = -1 };

                // Once, and then left alone for three minutes.
                //
                // Two things were wrong here and both are measured. The
                // interval was thirty five seconds, which is right for a
                // helicopter being re-centred over a pad and wrong for an
                // aircraft flying a circuit: a jet takes 106 seconds to fly one
                // and a VTOL 126, and re-issuing the order starts the circuit
                // again, so at thirty five seconds it was restarted three times
                // over and never completed.
                //
                // And it issued land "LAND" together with landAt. This file
                // already records, eighty lines above, that the two issued in
                // the same breath fight and come out worse than either alone.
                // Worse than that, land "LAND" means come down HERE and it is
                // the helicopter's order: given to a plane it destroyed every
                // one it was given, at the airfield and presumably at sea. The
                // pair that was measured landing a plane is land "NONE" to
                // clear any standing order, then the airport.
                if (_aimedAt < 0 || {(time - _aimedAt) > RUNWAY_REAIM}) then {
                    // The same quiesce as landAtPad, for the same reason: a
                    // pilot with evasion and targeting live ignores a landing
                    // order outright, and the engine turns evasion back on by
                    // itself, so it is re-done with every re-aim.
                    _grp setBehaviour "CARELESS";
                    _grp allowFleeing 0;
                    _grp setCombatMode "BLUE";
                    {
                        _x disableAI "AUTOTARGET";
                        _x disableAI "TARGET";
                        _x setSkill ["courage", 1];
                    } forEach (units _grp);
                    _obj land "NONE";
                    _obj landAt _airObj;
                    _grp setVariable ["ALiVE_mil_ato_landingAimedAt", time, false];
                    ["ALIVE_fnc_ATOEffect - %1 (%2) sent to %3's deck, %4 m out",
                        typeOf _obj, _tail, typeOf _ship, round _dShip] call ALiVE_fnc_dump;
                };

                // The hook, every tick. Its answer is taken apart rather than
                // passed through: _result is assembled AFTER the switch, so
                // assigning it here would be thrown away, the trap that once
                // made three refusals report success.
                private _h = [_logic, "apply", ["tailhook", _obj, _home, []]] call MAINCLASS;
                private _hook = _h param [2, ""];
                _detail = format ["approach %1 m out, %2 m up, %3", round _dShip, round _up, _hook];
            };

            // The approach is over, however it ended. Gives back a pad this
            // surface minted and leaves a real one alone, so the object cannot
            // outlive the state that needed it.
            case "releaseApproach": {
                // The runway approach is let go here as well, so an aircraft
                // that leaves LANDING and comes back is sent round again rather
                // than being told it is already on a circuit it has abandoned.
                private _grpR = group (driver _obj);
                if (!isNull _grpR) then {
                    _grpR setVariable ["ALiVE_mil_ato_runwayAimedAt", nil, false];
                };
                // And the landing order itself is cancelled, not just the note
                // that one was given. Giving the approach back and leaving the
                // aircraft under orders to land means it goes on trying to
                // land while whatever asked for it to stop has moved on.
                _obj land "NONE";
                private _surface = _extra param [0, []];
                private _tail = _extra param [1, ""];
                if (_surface isEqualTo []) exitWith { _status = "refused"; _detail = "no surface" };
                [_surface, "unstampPad", _tail] call ALIVE_fnc_ATOSurface;
                // A hook this module put out is raised again. That is what
                // ends the engine's arrest thread on an approach that never
                // touched the deck, and a jet flying its next sortie with the
                // hook down is a jet that snags the first wire it crosses.
                if (_obj getVariable ["ALiVE_mil_ato_hookOut", false]) then {
                    private _cfg = configFile >> "CfgVehicles" >> typeOf _obj;
                    private _list = getArray (_cfg >> "CarrierOpsCompatability" >> "ArrestHookAnimationList");
                    private _up = (getArray (_cfg >> "CarrierOpsCompatability" >> "ArrestHookAnimationStates")) param [2, 1];
                    { _obj animate [_x, _up] } forEach _list;
                    _obj setVariable ["ALiVE_mil_ato_hookOut", nil, false];
                };
                // And forget that a landing was committed to, or the next
                // approach starts already believing it is on finals.
                private _grp = group (driver _obj);
                if (!isNull _grp) then {
                    _grp setVariable ["ALiVE_mil_ato_landing", nil, false];
                    // The re-aim timer goes with it, or the next approach sits
                    // overhead for thirty-five seconds before aiming at all.
                    _grp setVariable ["ALiVE_mil_ato_landingAimedAt", nil, false];
                    _grp setVariable ["ALiVE_mil_ato_landingHeld", nil, false];
                    _grp setVariable ["ALiVE_mil_ato_landingSince", nil, false];
                    _grp setVariable ["ALiVE_mil_ato_landingStallSaid", nil, false];
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
                    _grp setVariable ["ALiVE_mil_ato_landingSince", nil, false];
                    _grp setVariable ["ALiVE_mil_ato_landingStallSaid", nil, false];
                    _detail = "approach restarted";
                };
            };
            case "emergencyLanding": {
                _obj land "LAND";
                _detail = "emergency";
            };

            // Back on the ground and ready to go again.
            // Refuelled, REARMED and repaired, by a truck that drives to it
            // where there is a logistics commander to send one.
            //
            // This used to do it instantly and in place, and despite its own
            // comment saying rearm it never did: there is no ammo restore
            // anywhere in the module this replaced either. So an aircraft came
            // back repaired and refuelled and still carrying whatever ordnance
            // was left, and its next sortie went out half armed or dry.
            //
            // The truck is the logistics commander's own resupply dispatch,
            // raised as the event it already listens for, rather than a second
            // copy of that machinery living here. It already knows how to
            // handle an aircraft: its own handler defers a ground truck while
            // the target is airborne or moving and sends it once the aircraft
            // is parked and still.
            //
            // With no logistics commander placed, the aircraft is serviced
            // where it stands exactly as before, so a mission without one is
            // unchanged.
            case "turnaround": {
                private _tail = _extra param [0, ""];

                // Already done. The stamp is what distinguishes "serviced" from
                // "happens to be undamaged and full", because an aircraft that
                // flew a sortie without being shot at reads the same as a
                // serviced one on damage and fuel alone and would never be
                // rearmed.
                //
                // Done for THIS landing, that is. It was a flag that was set
                // after the first service and never cleared, so every later
                // landing answered "already serviced" and nothing was refuelled
                // or rearmed again for the rest of the mission: an A-10 back
                // with 0.44 of a tank asked for no truck at all. A time answers
                // the one question the guard is for, a second ask for the same
                // arrival, and lets the next landing be serviced.
                private _servicedAt = _obj getVariable ["ALiVE_mil_ato_servicedAt", -1e9];
                if (!(_servicedAt isEqualType 0)) then { _servicedAt = -1e9 };
                // Not for an aircraft that cannot move. A launch called off for a
                // break on start-up asks for this too, and a helicopter that lost
                // its rotors inside a minute of its last service would have been
                // answered "already serviced", sat out its five minutes off the
                // rota, been offered the next job and been called off again. A
                // hull that cannot move has nothing to be "already" about.
                // canMove also reads false on an empty tank, which is serviced
                // either way.
                if ((time - _servicedAt) < 60 && {canMove _obj}) exitWith {
                    _matched = true; _detail = "already serviced";
                };

                _obj engineOn false;

                // Asked for once. The state table asks for this on arrival and
                // not again, so the waiting and the falling back belong to a
                // thread of its own rather than to a later tick that never
                // comes.
                if (_obj getVariable ["ALiVE_mil_ato_serviceAsked", false]) exitWith {
                    _matched = true; _detail = "service already asked for";
                };
                _obj setVariable ["ALiVE_mil_ato_serviceAsked", true, false];

                // The last visit's answer is cleared before this one is asked for.
                // The logistics commander writes "complete" on the hull when its
                // truck is done and nothing ever clears it, and the wait below
                // reads that word as "a truck did it" and skips the repair. So a
                // second service of the same aircraft could read the previous
                // truck's "complete" at its first look and stamp the hull serviced
                // with its rotors still off. Public, as the logistics side writes it.
                _obj setVariable ["ALIVE_resupply_state", "", true];

                private _hasLogcom = (count (allMissionObjects "ALiVE_mil_logistics")) > 0;
                private _side = "";
                private _grpT = group (driver _obj);
                if (!isNull _grpT) then { _side = str (side _grpT) };

                if (_hasLogcom && {!isNil "ALIVE_fnc_event"} && {!isNil "ALIVE_eventLog"}) then {
                    // All three are asked for. An aircraft back from a sortie
                    // wants fuel, ordnance and whatever it collected on the
                    // way, and they are one visit rather than three.
                    private _data = [
                        getPos _obj, _side, typeOf _obj,
                        if (_tail isEqualTo "") then { typeOf _obj } else { _tail },
                        0, [true, true, true], _obj
                    ];
                    private _ev = ["LOGCOM_RESUPPLY", _data, "ATO"] call ALIVE_fnc_event;
                    [ALIVE_eventLog, "addEvent", _ev] call ALIVE_fnc_eventLog;
                    _detail = "a truck has been asked for";
                    ["ALIVE_fnc_ATOEffect - a supply truck asked for %1 (%2) at %3",
                        _tail, typeOf _obj, getPos _obj] call ALiVE_fnc_dump;
                } else {
                    _detail = "no logistics commander, servicing it here";
                };

                [_obj, _tail, _hasLogcom] spawn {
                    params ["_v", "_tail", "_waited"];
                    // Given time to be serviced properly, then done here.
                    private _until = time + (if (_waited) then { SERVICE_WAIT } else { 0 });
                    // Waiting ends on the truck finishing, on it giving up, or
                    // on running out of patience. Giving up is worth its own
                    // exit: a dispatch that failed or was cancelled is never
                    // going to arrive, so making the aircraft stand there for
                    // the rest of the three minutes would be waiting for
                    // nothing.
                    waitUntil {
                        sleep 5;
                        private _state = _v getVariable ["ALIVE_resupply_state", ""];
                        if !(_state isEqualType "") then { _state = "" };
                        isNull _v
                        || {!alive _v}
                        || {time >= _until}
                        || {_state isEqualTo "complete"}
                        || {_state in ["failed", "cancelled"]}
                    };
                    if (isNull _v || {!alive _v}) exitWith {};

                    private _endState = _v getVariable ["ALIVE_resupply_state", ""];
                    if !(_endState isEqualType "") then { _endState = "" };
                    private _byTruck = _endState isEqualTo "complete";
                    if (!_byTruck) then {
                        // Where it stands. This is the old behaviour, plus the
                        // rearm it always said it did.
                        _v setDamage 0;
                        _v setFuel 1;
                        _v setVehicleAmmo 1;
                    };
                    _v setVariable ["ALiVE_mil_ato_servicedAt", time, false];
                    _v setVariable ["ALiVE_mil_ato_serviceAsked", nil, false];
                    ["ALIVE_fnc_ATOEffect - %1 is serviced%2", _tail,
                        if (_byTruck) then { " by a truck" } else {
                            format [" where it stands (the truck said '%1')", _endState]
                        }] call ALiVE_fnc_dump;
                };
            };

            // One broadcast effect, named by what it is announcing.

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

            // ---- the commander's voice (N1) -----------------------------------
            // Says something to everybody on the side, as their HQ.
            //
            // This used to validate the key and then say nothing at all, so
            // every announcement the module makes was silently dropped: the
            // establishment notice, the acknowledgements, the returns, the
            // losses. Fifteen runtime keys, none of them ever heard, and the
            // state table has been asking for four of them since it was
            // written.
            //
            // The extras are [key, args, sideText, hqClass, onRadio]:
            //
            //   key       a stringtable key, spoken through localize
            //   args      whatever that key's %1..%n need, IN ORDER and
            //             COMPLETE, including the HQ name where the key wants
            //             it (see below)
            //   sideText  "WEST" / "EAST" / "GUER" / "CIV", whose players hear
            //   hqClass   a CfgHQIdentities class, so the voice has a name
            //   onRadio   false keeps it silent, which is a mission maker's
            //             setting and not a failure
            //
            // The caller supplies every argument rather than having the HQ name
            // prepended here, because the keys do not agree about where it
            // goes: most open with it, and STR_ALIVE_ATO_RETURN is "on %1. Air
            // tasking complete" where %1 is the sortie. Prepending it would
            // have put the HQ's name in place of the mission on that one. Ask
            // "hqName" for the name and put it where the key wants it.
            case "broadcast": {
                private _key = _extra param [0, ""];
                private _say = _extra param [1, []];
                private _sideText = _extra param [2, ""];
                private _hqClass = _extra param [3, ""];
                private _onRadio = _extra param [4, true];
                if !(_say isEqualType []) then { _say = [_say] };

                if (_key isEqualTo "") exitWith { _status = "refused"; _detail = "no key" };

                // Silence is a setting, so it reports what it would have said
                // and sends nothing.
                if !(_onRadio) exitWith { _matched = true; _detail = format ["%1 (radio off)", _key] };

                if (isNil "ALIVE_fnc_radioBroadcastToSide") exitWith {
                    _status = "refused"; _detail = "no radio";
                };

                // A key with no text behind it answers EMPTY, measured, not
                // with the key as the documentation suggests. Both are checked,
                // because the empty answer is the dangerous one: it passes a
                // key-name test, needs no arguments, and sends a blank
                // transmission that looks like a working radio saying nothing.
                private _template = localize _key;
                if (_template isEqualTo "" || {_template isEqualTo _key}) exitWith {
                    ["ALIVE_fnc_ATOEffect - no text for radio key %1, saying nothing", _key] call ALiVE_fnc_dump;
                    _status = "refused"; _detail = "no text for that key";
                };

                // How many arguments the text actually wants, read from the
                // text rather than written down here, so adding a %5 to a
                // translation cannot leave this out of step.
                //
                // Worth checking rather than trusting: format leaves a literal
                // %2 in the message when an argument is missing, and players
                // would read it out loud on the radio.
                private _needed = 0;
                {
                    if ((_template find format ["%1%2", "%", _x]) > -1) then { _needed = _x };
                } forEach [1,2,3,4,5,6,7,8,9];
                if (count _say < _needed) exitWith {
                    ["ALIVE_fnc_ATOEffect - radio key %1 wants %2 argument(s) and was given %3, saying nothing",
                        _key, _needed, count _say] call ALiVE_fnc_dump;
                    _status = "refused"; _detail = "not enough to say it with";
                };

                // format takes the template and its arguments as ONE array, and
                // the count varies by key, so the array is built.
                private _message = format ([_template] + _say);

                private _sideObject = objNull;
                if (!isNil "ALIVE_fnc_sideTextToObject" && {!(_sideText isEqualTo "")}) then {
                    _sideObject = [_sideText] call ALIVE_fnc_sideTextToObject;
                };

                [_sideText, [objNull, _message, "side", _sideObject, false, false, false, true, _hqClass]] call ALIVE_fnc_radioBroadcastToSide;
                _detail = _message;
            };

            // The four the state table names, each one of the keys above with
            // its key already chosen. The table says what to announce and never
            // how to say it, which is why these exist at all; the words still
            // come from the caller, because only the caller knows the callsign,
            // the grid and the mission.
            case "broadcastStart";
            case "broadcastOnStation";
            case "broadcastReturn";
            case "broadcastLost": {
                private _key = switch (_effect) do {
                    case "broadcastStart":     { "STR_ALIVE_ATO_START" };
                    case "broadcastOnStation": { "STR_ALIVE_ATO_ON_STATION" };
                    case "broadcastReturn":    { "STR_ALIVE_ATO_RETURN" };
                    default                    { "STR_ALIVE_ATO_AIRCRAFT_LOST" };
                };
                // Its answer is taken apart rather than passed through.
                // _result is assembled from these three AFTER the switch, so
                // assigning _result here would be thrown away, which is the
                // same trap that once made three refusals report success.
                private _r = [_logic, "apply", ["broadcast", _obj, _home,
                    [_key] + (_extra select [0, 4])]] call MAINCLASS;
                _status = _r param [0, "ok"];
                _matched = _r param [1, false];
                _detail = _r param [2, ""];
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
