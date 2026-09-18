#include "\x\alive\addons\mil_ato\script_component.hpp"
SCRIPT(observe);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ATOObserve
Description:
What an airframe actually is, right now. The only piece that looks at the world.

It reads and never writes. Everything it reports is measured this tick from the
object itself, so nothing downstream has to trust a flag somebody set earlier
and forgot to clear. That mattered: despawn protection was sampled false at
every point of a whole mission while three separate places believed they had
turned it on.

It answers for a hull that has been deleted without throwing, because "the
aircraft is gone" is the single most important thing it has to be able to say,
and an observer that errors on a null object cannot say it.

It reports in the vocabulary the state table reads. Raw facts are reported too,
for anything that wants them, but the flags the table consumes are derived here
rather than at each reader, so two readers cannot disagree about what "the crew
is gone" means.

Parameters:
Nil or Array - If Nil, return a new instance. If a hash, reference an existing one.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function

Examples:
(begin example)
_obs = [_o, "observe", [_obj, _home, _lockHeld, _sortie, _now]] call ALIVE_fnc_ATOObserve;

(end)

See Also:
<ALIVE_fnc_ATOMachine>, <ALIVE_fnc_ATOSurface>

Author:
Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_ATOObserve

// Above this off the ground the aircraft is flying, not parked or rolling.
#define AIRBORNE_AGL 50

private ["_result"];

TRACE_1("ATO Observe - input",_this);

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

    case "observe": {
        _args params [
            ["_obj", objNull, [objNull]],
            ["_home", [], [[]]],
            ["_lockHeld", false, [false]],
            ["_sortie", [], [[]]],
            ["_now", 0, [0]]
        ];

        private _o = [] call ALIVE_fnc_hashCreate;
        private _fnc_set = { [_o, _this select 0, _this select 1] call ALIVE_fnc_hashSet };

        // ---- is it there at all -------------------------------------------
        // Asked first and answered for a null object, because everything below
        // this line would throw on one.
        private _live = !isNull _obj && {alive _obj};
        ["objectLive", _live] call _fnc_set;
        ["objectLost", !_live] call _fnc_set;

        if (!_live) exitWith {
            // A dead hull still has to answer every question the table asks, or
            // the table cannot decide anything about it.
            {
                [_o, _x, false] call ALIVE_fnc_hashSet;
            } forEach ["local","remote","airborne","atHome","nearHome","landed","touchingGround",
                       "crewGroupLive","driverPresent","crewSeated","playerControl","playerPassenger",
                       "anyPlayerAboard","uavControlled","onStation","targetsGone","lockHeld",
                       "deckHome","fixedWing","needsRunway","launchInProgress","onRunway","armed","virtualHome",
                       "atTaxiOffEnd"];
            {
                [_o, _x, 0] call ALIVE_fnc_hashSet;
            } forEach ["altAGL","altASL","speed","fuel","damage","wpRemaining","aliveCrew",
                       "ordnance","climbRate",
                       "playersWithin300","playersWithin1000Hull","playersWithin1000Home",
                       "playersWithin1500Home"];
            // Nobody is aboard a hull that is gone, so nothing is holding it.
            ["crewLoss", true] call _fnc_set;
            _result = _o;
        };

        // ---- what kind of aircraft, and what kind of home --------------------
        // The table needs both to choose between a runway launch, a catapult
        // launch and a helicopter lift, and it may not read config or a home's
        // shape itself. A VTOL is a helicopter for every purpose here: it is
        // lifted, not shot off a wire.
        private _deckHome = count _home > 2 && {(_home select 2) isEqualTo "deck"};
        // A commander with no airfield holds its aircraft at a point in the
        // air. Kept apart from a deck home deliberately: the two share how
        // their height is measured and nothing else, and reporting one as the
        // other would have a virtual aircraft shot off a catapult.
        private _virtualHome = count _home > 2 && {(_home select 2) isEqualTo "virtual"};
        private _fixedWing = (_obj isKindOf "Plane")
            && {getNumber (configFile >> "CfgVehicles" >> typeOf _obj >> "vtol") == 0};
        ["deckHome", _deckHome] call _fnc_set;
        ["virtualHome", _virtualHome] call _fnc_set;
        ["fixedWing", _fixedWing] call _fnc_set;

        // And separately, whether it needs a RUNWAY to come back to. This is
        // NOT the same question as fixedWing, and the difference is measured.
        //
        // A VTOL is a Plane whose vtol rating is not zero, so fixedWing is
        // false for it and it is never shot off a catapult, which is right: it
        // does not need one. But it dies exactly like a jet when it is aimed
        // at a parking stand. Measured on Stratis, all three given the same
        // approach from 900 m out at 120 m: the helicopter came down 2 m from
        // its stand and lived, the jet overflew at 24 m, climbed away and was
        // destroyed 1649 m out, and the VTOL was doing 139 km/h at three
        // metres when it was destroyed. The same two airframes given the
        // airport instead came down on the runway and lived.
        //
        // So anything that is a Plane at all comes back to a runway, and only
        // a non-VTOL plane is catapulted off one.
        ["needsRunway", _obj isKindOf "Plane"] call _fnc_set;

        // Whether a launch this module started is still running on this hull.
        //
        // The table cannot read a variable off an object, and it needs to know
        // this one: its own launch deadline can fall due while the catapult
        // sequence is still towing, and it would then teleport the aircraft
        // into the air from under a thread that is pinning it to the deck. The
        // two fight, the teleport wins for a frame, the tow drags it back, and
        // the state gives up on a launch that then completes underneath it.
        //
        // The stamp carries its own expiry rather than a time to compare
        // against a window, so the length of the window lives in one place,
        // beside the sequence that owns it, instead of being a number two
        // files have to agree about.
        private _catUntil = _obj getVariable ["ALiVE_mil_ato_catapultUntil", -99999];
        if !(_catUntil isEqualType 0) then { _catUntil = -99999 };
        ["launchInProgress", time < _catUntil] call _fnc_set;

        // ---- where and how fast -------------------------------------------
        private _pos = getPosATL _obj;
        // Height above whatever is UNDER the aircraft, which on a ship is the
        // deck. getPosATL measures from the terrain, and over water the
        // terrain is the sea bed: the flight deck of a USS Freedom is 23.6 m
        // above the waterline and the sea bed about 40 m below it, so an
        // aircraft standing on the deck read as roughly 64 m up. That made
        // it airborne the moment it was told to launch, so it went to
        // ENROUTE without launching, and it could never read as landed, so an
        // approach ran to its deadline with the aircraft already stopped on
        // the deck. getPos is the engine's own measure for this: its catapult
        // and tailhook functions both gate on getPos being under a metre.
        // Terrain homes keep getPosATL, so nothing on land changes.
        // A held aircraft is measured the same way, and for the same reason.
        // Over water terrain level is the sea bed, so one held half a metre
        // above the waves reads fifty five metres up over deep water and is
        // judged to be flying with nobody aboard. Measured at 54 m of water:
        // 54.9 the terrain way, 0.7 this way.
        private _agl = if (_deckHome || _virtualHome) then { (getPos _obj) select 2 } else { _pos select 2 };
        ["pos", + _pos] call _fnc_set;
        ["altAGL", _agl] call _fnc_set;
        ["altASL", (getPosASL _obj) select 2] call _fnc_set;
        ["speed", speed _obj] call _fnc_set;
        // How fast it is going UP or down, which speed does not say.
        //
        // Asked for so that an aircraft climbing away endlessly can be told
        // from one flying level, which is what the original request for this
        // was chasing: a reconnaissance flight that kept climbing and nothing
        // could say so, because every reading available described where it was
        // rather than where it was going. Every deadline in the table would
        // eventually catch it; this makes it visible while it is happening.
        ["climbRate", (velocity _obj) select 2] call _fnc_set;
        ["airborne", _agl > AIRBORNE_AGL] call _fnc_set;
        ["touchingGround", isTouchingGround _obj] call _fnc_set;

        // Is it standing on the runway.
        //
        // The table cannot ask the world, and it needs to know, because an
        // aircraft stopped on the runway blocks every aircraft behind it.
        //
        // Measured against the terrain's own centreline rather than the shared
        // airside test. That test answers false everywhere on this map even
        // with its cache built, so an aircraft stopped in the middle of the
        // runway read as standing nowhere in particular: false on its stand,
        // false on the runway, false in the air over the runway. The
        // centreline reads nothing at the middle of the runway and at both
        // thresholds, and thirty nine metres or more at every stand the search
        // chooses.
        //
        // The RUNWAY only, and not taxiways, which the other test also covered
        // in name. A taxiway is narrower and the stands sit close enough to
        // the taxi lines that including them would flag legitimate parking,
        // and blocking the runway is the harm worth acting on.
        //
        // Only asked of something on the ground.
        //
        // Asked of the derivation each time rather than remembered here. The
        // answer depends on where it is asked from, so keeping one for the
        // whole terrain let the first aircraft seen decide it for every
        // aircraft after: one seen far from the field answered "no runway on
        // this terrain" and nothing was ever recognised as standing on it
        // again. The derivation keeps its own answer per area.
        private _onRunway = false;
        if (_agl < 5) then {
            private _line = [];
            if (!isNil "ALiVE_fnc_getRunwayCentreline") then {
                _line = [_pos] call ALiVE_fnc_getRunwayCentreline;
            };
            private _ra = if (_line isEqualType [] && {count _line > 1}) then { _line select 0 } else { [] };
            private _rb = if (_line isEqualType [] && {count _line > 1}) then { _line select 1 } else { [] };
            if (_ra isEqualType [] && {_rb isEqualType []}
                && {count _ra > 1} && {count _rb > 1}) then {
                private _ax = _ra select 0;
                private _ay = _ra select 1;
                private _dx = (_rb select 0) - _ax;
                private _dy = (_rb select 1) - _ay;
                private _len2 = (_dx * _dx) + (_dy * _dy);
                if (_len2 > 0) then {
                    private _t = ((((_pos select 0) - _ax) * _dx) + (((_pos select 1) - _ay) * _dy)) / _len2;
                    _t = (_t max 0) min 1;
                    private _d = _pos distance2D [_ax + (_t * _dx), _ay + (_t * _dy), 0];
                    _onRunway = _d < 25;
                };
            };
        };
        ["onRunway", _onRunway] call _fnc_set;

        // Has a plane that landed finished taxiing off: is it within eighty
        // metres of the END of its airport's taxi-off route.
        //
        // The table needs this because stopping is the wrong sign for a jet.
        // Measured on Stratis with the ATO's own landing order: an A-164 touched
        // down, rolled out, taxied the taxi-off route to its end in 81 seconds,
        // and never stopped at all. It went straight round onto the take-off
        // route and flew again. So the moment it reaches the end of the taxi-off
        // is the moment it has come home.
        //
        // The airport is the one nearest the home, read from the terrain's own
        // config the same way the taxi out reads it. Only a plane on land, and
        // only near the ground.
        private _atTaxiOffEnd = false;
        if ((_obj isKindOf "Plane") && {!_deckHome} && {!_virtualHome} && {_agl < 5}) then {
            private _w = configFile >> "CfgWorlds" >> worldName;
            private _secondary = _w >> "SecondaryAirports";
            private _from = if (count _home > 0 && {(_home select 0) isEqualType []}) then { _home select 0 } else { _pos };
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
            private _off = [];
            if (_airportID == 0) then { _off = getArray (_w >> "ilsTaxiOff") };
            if (_airportID > 0) then { _off = getArray ((_secondary select (_airportID - 1)) >> "ilsTaxiOff") };
            if (count _off >= 2) then {
                private _end = [_off select ((count _off) - 2), _off select ((count _off) - 1), 0];
                _atTaxiOffEnd = (_obj distance2D _end) < 80;
            };
        };
        ["atTaxiOffEnd", _atTaxiOffEnd] call _fnc_set;

        // Landed is not simply "on the ground": an aircraft rolling out at
        // 140 km/h is touching the ground and is not down yet.
        // Two metres, not five, and all three tests. The old module recorded why:
        // being low is not being down, and counting a helicopter as landed while
        // the engine was still flying it through the last of its descent meant
        // everything that follows a landing ran early, and the airframe was put
        // back where it launched from. Anyone watching the pad saw it jump
        // sideways out of its own approach.
        //
        // The ground test is isTouchingGround and nothing else, on a deck as
        // much as on land.
        //
        // A deck clause was tried here, "or the home is a deck and it is under
        // a metre up", because whether isTouchingGround answers for a hull
        // resting on a ship had not been measured. It has been now, and it
        // does: a jet parked on the test carrier's plating reads touching, at
        // minus a tenth of a metre above the deck. So the clause was not
        // needed, and it was actively wrong.
        //
        // What was wrong with it: over water, height is measured from the sea
        // SURFACE, so a jet that missed its approach and ditched astern reads
        // about zero and slows below five, and the clause called that landed.
        // The landed branch then tidies an aircraft, which teleports it onto
        // its deck stand and sets its damage to zero and its fuel to full. A
        // jet that went in the sea would have reappeared on the deck good as
        // new. Guarding the clause with surfaceIsWater does not help either:
        // the sea is still underneath a carrier, so that reads true on the
        // deck as well and would have disabled the clause everywhere.
        // And how slow counts as stopped depends on what it is.
        //
        // Five is right for a helicopter: it comes to a stop on its pad. A
        // plane does not. Measured: the engine lands a jet on the runway and
        // then TAXIS it, and it was still doing eighteen to twenty kilometres
        // an hour a minute later, a hundred metres or so from the field. At a
        // five kilometre threshold it would never once have read as landed, so
        // the approach would have run to its deadline with the aircraft
        // already down and rolling.
        //
        // Forty is the figure because a plane cannot fly at forty. Anything
        // touching the ground below it is on the ground for good, which is the
        // question being asked; where it then ends up is the placing's job.
        private _onGround = isTouchingGround _obj;
        private _stopped = (speed _obj) < (if (_obj isKindOf "Plane") then { 40 } else { 5 });
        ["landed", _onGround && {_stopped} && {_agl < 2}] call _fnc_set;

        // ---- whose is it --------------------------------------------------
        // A hull this machine does not own cannot be told anything local, so
        // the table has to know before it tries.
        private _isLocal = local _obj;
        ["local", _isLocal] call _fnc_set;
        ["remote", !_isLocal] call _fnc_set;

        // ---- who is in it -------------------------------------------------
        // Measured from the crew every tick. A handler added when the aircraft
        // was adopted is a shortcut, not the truth: it does not fire when a
        // player dies in the seat, and a corpse is not a pilot.
        private _crew = crew _obj;
        private _aliveCrew = _crew select { alive _x };
        private _players  = _aliveCrew select { isPlayer _x };
        private _driver   = driver _obj;

        ["aliveCrew", count _aliveCrew] call _fnc_set;
        ["crewGroupLive", count _aliveCrew > 0] call _fnc_set;
        ["driverPresent", !isNull _driver && {alive _driver}] call _fnc_set;
        // Ready to fly: somebody alive is actually at the controls. The state
        // table waits on this before it will launch, so an aircraft with a crew
        // standing beside it rather than sitting in it is not ready.
        ["crewSeated", !isNull _driver && {alive _driver}] call _fnc_set;
        ["crewLoss", count _aliveCrew == 0] call _fnc_set;
        ["anyPlayerAboard", count _players > 0] call _fnc_set;

        // A drone is flown from somewhere else entirely, so being empty is not
        // the same as being unattended.
        // param rather than select, matching how the rest of the mod reads this:
        // the array is not always the length you expect.
        private _controller = (UAVControl _obj) param [0, objNull];
        private _uav = !isNull _controller && {alive _controller} && {isPlayer _controller};
        ["uavControlled", _uav] call _fnc_set;

        // In control means flying it: at the stick, or operating it remotely.
        // Merely being aboard is a different thing with different consequences.
        private _control = (!isNull _driver && {alive _driver} && {isPlayer _driver}) || _uav;
        ["playerControl", _control] call _fnc_set;
        ["playerPassenger", (count _players > 0) && {!_control}] call _fnc_set;

        // ---- condition -----------------------------------------------------
        ["fuel", fuel _obj] call _fnc_set;
        ["damage", damage _obj] call _fnc_set;

        // How many rounds it has left to fight with.
        //
        // ORDNANCE only. This counted every magazine aboard, and a CAS jet
        // carries a hundred and twenty flares and a designator round beside its
        // four bombs, so one with every bomb, rocket and missile spent still
        // reported a thousand and twenty one rounds and read as fully armed.
        // The table's return test compared a one-or-nothing flag against a
        // tenth, so it could only ever fire once the FLARES were gone as well,
        // which does not happen on a sortie. An aircraft out of ordnance stayed
        // on station indefinitely.
        //
        // The separation cannot come from the damage figures. Measured: a flare
        // reports hit 1, and the laser designator reports hit 500, which is
        // more than a rocket. Nor from the ammunition's class tree, because the
        // flare round descends from BulletBase exactly as a cannon shell does.
        // The simulation is the field that tells them apart. Anything with an
        // unrecognised simulation that does damage is counted as ordnance, so
        // modded stores err towards staying on station rather than coming home
        // early.
        //
        // Cached, because it is pure config and a jet is asked eight times a
        // tick. Cached per MAGAZINE rather than per aircraft type, so a
        // refitted pylon is judged on what is actually hanging off it.
        if (isNil "ALiVE_ATO_magIsOrdnance") then {
            ALiVE_ATO_magIsOrdnance = [] call ALIVE_fnc_hashCreate;
        };
        private _rounds = 0;
        {
            private _mag = _x select 0;
            private _isOrd = [ALiVE_ATO_magIsOrdnance, _mag, -1] call ALIVE_fnc_hashGet;
            if (_isOrd isEqualTo -1) then {
                private _ammoCls = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
                private _aCfg = configFile >> "CfgAmmo" >> _ammoCls;
                private _sim = toLower getText (_aCfg >> "simulation");
                // A dispenser does its harm through its submunitions and can
                // carry no damage figures of its own, so it counts on the
                // simulation alone.
                private _harms = (getNumber (_aCfg >> "hit") > 0)
                    || {getNumber (_aCfg >> "indirectHit") > 0}
                    || {_sim isEqualTo "shotsubmunitions"};
                _isOrd = _harms && {!(_sim in ["shotcm","laserdesignate","shotilluminating","shotsmoke"])};
                [ALiVE_ATO_magIsOrdnance, _mag, _isOrd] call ALIVE_fnc_hashSet;
            };
            if (_isOrd isEqualTo true) then { _rounds = _rounds + (_x select 1) };
        } forEach (magazinesAmmo _obj);
        ["ordnance", _rounds] call _fnc_set;

        // Whether it carries offensive stores AT ALL, which is a different
        // question from whether it has any left, and the reason the reading
        // above could not simply be believed.
        //
        // Measured: the VTOL transport carries two hundred and forty flares, a
        // designator and no ordnance whatsoever, and the reconnaissance drone
        // carries only a designator. Both read zero rounds on a full load, so
        // sending an aircraft home for having none would have grounded every
        // transport and every scout the moment it arrived.
        //
        // Asked of the config through the shared capability derivation, which
        // already summarises this, because an expended magazine is REMOVED: a
        // jet that has spent everything looks identical to one that was never
        // armed. Cached per type, since it is a config walk. Anything with
        // ordnance actually aboard counts as armed whatever the config says,
        // which covers a pylon refitted to carry more than its default.
        if (isNil "ALiVE_ATO_typeArmed") then {
            ALiVE_ATO_typeArmed = [] call ALIVE_fnc_hashCreate;
        };
        private _hullType = typeOf _obj;
        private _cfgArmed = [ALiVE_ATO_typeArmed, _hullType, -1] call ALIVE_fnc_hashGet;
        if (_cfgArmed isEqualTo -1) then {
            _cfgArmed = false;
            if (!isNil "ALiVE_fnc_getAircraftCapabilities") then {
                _cfgArmed = "armed" in ([_hullType] call ALiVE_fnc_getAircraftCapabilities);
            };
            [ALiVE_ATO_typeArmed, _hullType, _cfgArmed] call ALIVE_fnc_hashSet;
        };
        ["armed", (_cfgArmed isEqualTo true) || {_rounds > 0}] call _fnc_set;

        private _grp = group _driver;
        private _wp = 0;
        if (!isNull _grp) then { _wp = (count (waypoints _grp)) - (currentWaypoint _grp) };
        ["wpRemaining", _wp max 0] call _fnc_set;

        // ---- where it is relative to home ----------------------------------
        private _homePos = if (count _home > 0) then { _home select 0 } else { [0,0,0] };
        private _dHome = _obj distance2D _homePos;
        ["atHome", _dHome < (if (_obj isKindOf "Plane") then {15} else {30})] call _fnc_set;
        ["nearHome", _dHome < 2000] call _fnc_set;

        // ---- who is watching ------------------------------------------------
        // Counted separately around the aircraft and around its home, because
        // one decides whether it may be moved and the other whether it may skip
        // an approach.
        private _fnc_players = {
            params ["_p", "_r"];
            count (allPlayers select { alive _x && {(_x distance2D _p) < _r} })
        };
        ["playersWithin300",      [_pos, 300] call _fnc_players] call _fnc_set;
        ["playersWithin1000Hull", [_pos, 1000] call _fnc_players] call _fnc_set;
        ["playersWithin1000Home", [_homePos, 1000] call _fnc_players] call _fnc_set;
        ["playersWithin1500Home", [_homePos, 1500] call _fnc_players] call _fnc_set;

        // ---- the sortie ------------------------------------------------------
        private _onStation = false;
        private _targetsGone = false;
        if (count _sortie > 1) then {
            private _target = _sortie select 1;
            private _range = if (count _sortie > 3) then { _sortie select 3 } else { 500 };
            private _d = _obj distance2D _target;
            _onStation = _d < (_range * 1.2) && {_agl > AIRBORNE_AGL};
        };

        // Are the things this sortie was sent for still there.
        //
        // This was declared false and never worked out, and two decisions
        // rested on it: the exit from ON_STATION when the targets are gone,
        // which therefore could never fire, and the stalled-sortie test, whose
        // guard against it was permanently satisfied. So an aircraft holding
        // over a target somebody else had already destroyed held on until its
        // clock ran out, which for a patrol is a full hour.
        //
        // Asked of the sortie's OWN targets, which it carries, rather than by
        // sweeping the area. A target is either a live object or a profile the
        // profile system still knows about, and the profile half is the
        // important one: a virtualised enemy is NOT an object, so asking the
        // world for objects would report every target far from a player as
        // gone and bring every sortie home. A killed profile is unregistered
        // from the handler, so asking it tells "dead" from "far away", which
        // nothing else here can do.
        //
        // An empty target list answers FALSE, never true. A sortie raised
        // without targets, which is every patrol, cannot have lost them, and
        // answering true there would send every patrol home on arrival.
        //
        // Only asked of an aircraft actually on station, because that is the
        // only state that reads it, and it costs a lookup per target.
        //
        // And a list of nothing but POSITIONS answers false as well. A patrol is
        // raised with the centre of its zone as its one "target", and a
        // suppression sortie with the positions of the defences it was sent
        // at, because that is somewhere to aim. Neither is a thing that can be
        // destroyed, so counting them as targets that are no longer standing
        // sent every patrol home within three seconds of reaching its station.
        // Only objects and profile ids are targets; everything else is where to
        // go.
        if (_onStation && {count _sortie > 5} && {(_sortie select 5) isEqualType []}) then {
            private _targets = _sortie select 5;
            if (count _targets > 0) then {
                private _named = 0;
                private _standing = 0;
                {
                    if (_x isEqualType objNull) then {
                        _named = _named + 1;
                        if (!isNull _x && {alive _x}) then { _standing = _standing + 1 };
                    };
                    if (_x isEqualType "" && {!(_x isEqualTo "")}) then {
                        _named = _named + 1;
                        if (!isNil "ALIVE_profileHandler") then {
                            private _p = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                            if (!isNil "_p" && {[_p] call ALIVE_fnc_isHash}) then { _standing = _standing + 1 };
                        };
                    };
                } forEach _targets;
                _targetsGone = _named > 0 && {_standing == 0};
            };
        };

        ["onStation", _onStation] call _fnc_set;
        ["targetsGone", _targetsGone] call _fnc_set;

        ["lockHeld", _lockHeld] call _fnc_set;

        _result = _o;
    };

    // Can this hull be taken away from us? Under the current design an airframe
    // the module owns has no profile at all, so nothing that removes profiles
    // can reach it. A leftover profile id is the thing to look for.
    case "isProtected": {
        private _obj = _args;
        private _reasons = [];

        if (isNull _obj) exitWith { _result = [false, ["object is null"]] };
        if (!alive _obj) exitWith { _result = [false, ["object is not alive"]] };

        if !(local _obj) then { _reasons pushBack "not local" };

        private _pid = _obj getVariable ["profileID", ""];
        if !(_pid isEqualTo "") then {
            // A stamp with nothing behind it is a leftover, not an owner. Worth
            // saying out loud, because it means something stamped this hull and
            // did not clean up, but it does not put the aircraft at risk.
            // Held as an ARRAY, not an object. getProfile answers with the
            // profile hash, which is an array, and isNull has no array form:
            // asking it threw on exactly the case this is here to report, a
            // hull carrying a profile id that still resolves to a profile.
            private _profile = [];
            if (!isNil "ALiVE_ProfileHandler") then {
                private _got = [ALiVE_ProfileHandler, "getProfile", _pid] call ALiVE_fnc_profileHandler;
                if (!isNil "_got" && {_got isEqualType []}) then { _profile = _got };
            };
            if (_profile isEqualTo []) then {
                ["ALIVE_fnc_ATOObserve - %1 carries a stale profile id %2 with no profile behind it", typeOf _obj, _pid] call ALiVE_fnc_dump;
            } else {
                _reasons pushBack "profileID";
            };
        };

        _result = [count _reasons == 0, _reasons];
    };

    // Enemy aircraft worth intercepting: high enough to be flying somewhere
    // rather than sitting on a pad.
    case "scanAir": {
        _args params [["_zones",[],[[]]], ["_side",sideUnknown,[sideUnknown]]];
        private _found = [];
        {
            private _zone = _x;
            private _centre = _zone select 0;
            private _radius = _zone select 1;
            {
                if (alive _x
                    && {(getPosATL _x) select 2 > 105}
                    && {(side _x) getFriend _side < 0.6}
                    && {(_x distance2D _centre) < _radius}) then {
                    _found pushBackUnique _x;
                };
            // Parenthesised on purpose rather than leaning on precedence, and
            // aircraft are vehicles, so there is nothing for allUnits to add.
            } forEach (vehicles select { _x isKindOf "Air" });
        } forEach _zones;
        _result = _found;
    };

    case "scanAirDefences": {
        _args params [["_zones",[],[[]]], ["_side",sideUnknown,[sideUnknown]]];
        private _found = [];
        {
            private _centre = _x select 0;
            private _radius = _x select 1;
            {
                private _v = _x;
                if (alive _v && {(side _v) getFriend _side < 0.6} && {(_v distance2D _centre) < _radius}) then {
                    private _isAA = false;
                    if (!isNil "ALiVE_fnc_isAntiAir") then { _isAA = [typeOf _v] call ALiVE_fnc_isAntiAir };
                    if (_isAA) then { _found pushBackUnique _v };
                };
            } forEach (vehicles select { (_x isKindOf "StaticWeapon") || {_x isKindOf "LandVehicle"} });
        } forEach _zones;
        _result = _found;
    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};

TRACE_1("ATO Observe - output",_result);

_result;
