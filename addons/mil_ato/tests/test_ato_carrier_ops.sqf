#include "\x\alive\addons\mil_ato\script_component.hpp"

SCRIPT(test_ato_carrier_ops);

/* ----------------------------------------------------------------------------
Carrier operations: launching off a catapult and recovering onto the wire.

Smallest mission: place a USS Freedom (Land_Carrier_01_base_F) in deep water,
put a player anywhere, and run this from the debug console, or hand it to the
headless rig as its probe with the carrier mission:

    run.ps1 -Probe D:\ArmaDev\x\alive\addons\mil_ato\tests\test_ato_carrier_ops.sqf -Mission carrier

The carrier has to be placed by the EDITOR: the twenty parts a carrier is made
of are spawned by the hull's own init handler, and a hull created from a script
and then moved leaves them behind.

What this holds, in order:

  The height frame. Over water the terrain is the sea bed, forty metres down,
  so a jet standing on the deck used to read as sixty-odd metres airborne to
  the observer and to the effector. The first thing asserted is that a parked
  deck aircraft reads as parked. Everything else here depends on it.

  The catapults are read off the PART objects, not the hull, two of the four
  are never offered, the nearer free one is chosen, and one with a jet on it
  is not offered twice.

  The launch itself, from the stand to the air: towed onto the wire, held
  there, shot, and clear of the ship a quarter of a minute later, with the
  deflector back down and damage re-armed behind it.

  The table sends a plane to the catapult and a helicopter to its lift, and
  sends a plane back to the wire and a helicopter back to its pad.

  A jet on land, a home whose ship is gone, and a missing hull are all
  refused, and the jet on land does not move.

  The hook goes down when asked, stays down when asked again, is refused on a
  helicopter, and comes back up when the approach is given back.

Every aircraft created here is deleted with its crew at the end, and the
deflectors are put back down.

Author:
Jman
---------------------------------------------------------------------------- */

[] spawn {

    private _fails = [];
    private _skips = [];
    private _fnc_check = {
        // _ok taken as Any deliberately: an assertion whose expression threw
        // arrives as nil, and `if (nil)` would throw again and print nothing,
        // so the failure would disappear instead of being reported.
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
    private _fnc_skip = {
        _skips pushBack _this;
        diag_log format ["  skip  %1", _this];
    };

    diag_log "=== ATO Carrier ops test ===";

    private _surface = [nil, "create"] call ALIVE_fnc_ATOSurface;
    private _effect = [nil, "create"] call ALIVE_fnc_ATOEffect;
    private _observe = [nil, "create"] call ALIVE_fnc_ATOObserve;
    private _machine = [nil, "create"] call ALIVE_fnc_ATOMachine;
    private _land = if (isNull player) then {[1839.76, 5750.47, 0]} else {getPosATL player};

    // The carrier, by name when the scene gives it one and by search when it
    // does not, so this runs in a hand-built mission as well as on the rig.
    private _ship = objNull;
    if (!isNil "ATO_TEST_CARRIER") then { _ship = ATO_TEST_CARRIER };
    if (isNull _ship) then {
        _ship = (nearestObjects [_land, ["StaticShip"], 6000]) param [0, objNull];
    };

    if (isNull _ship) exitWith {
        diag_log "  FAIL  no carrier in this mission, so nothing here can run";
        diag_log "=== ATO Carrier ops test: NO CARRIER ===";
    };

    private _centre = _ship modelToWorld [0, 0, 0];
    private _flatCentre = [_centre select 0, _centre select 1, 0];
    diag_log format ["  info  %1 at %2, heading %3", typeOf _ship, getPosASL _ship, round (getDir _ship)];

    private _geom = [_surface, "deckGeometry", _ship] call ALIVE_fnc_ATOSurface;
    _geom params [["_deckZ", -9999], ["_landA", []], ["_landB", []], ["_taxi", []], ["_spots", []], ["_parts", []]];
    diag_log format ["  info  deck at %1 m, %2 parking offsets, %3 part classes", _deckZ, count _spots, count _parts];

    private _spawned = [];
    private _cats = [];
    // The hardest case: a hook, folding wings, and a catapult launch bar.
    private _jet = "B_Plane_Fighter_01_F";
    private _heliClass = "B_Heli_Transport_01_F";

    // Smallest angle between two headings, so a heading of 359 and one of 1
    // are two degrees apart rather than 358.
    private _fnc_headingGap = {
        params ["_a", "_b"];
        private _d = (_a - _b) % 360;
        if (_d < -180) then { _d = _d + 360 };
        if (_d > 180) then { _d = _d - 360 };
        abs _d
    };
    private _fnc_apply = {
        params ["_name", "_obj", "_home", ["_extra", []]];
        private _r = [_effect, "apply", [_name, _obj, _home, _extra]] call ALIVE_fnc_ATOEffect;
        if !(_r isEqualType []) then { _r = ["refused", false, "no answer"] };
        _r
    };

    // --- A1: the height frame on a deck ---------------------------------------
    private _homeA = [_surface, "cascade", ["deck", _jet, _flatCentre, []]] call ALIVE_fnc_ATOSurface;
    diag_log format ["  info  the jet's deck home: %1", _homeA];
    ["a deck home is found for a jet", count _homeA >= 6] call _fnc_check;

    private _a = objNull;
    if (count _homeA >= 6) then {
        _a = createVehicle [_jet, [0,0,0], [], 0, "CAN_COLLIDE"];
        _a setVariable ["ALIVE_profileIgnore", true, true];
        _spawned pushBack _a;
        [_surface, "place", [_a, _homeA]] call ALIVE_fnc_ATOSurface;
        sleep 3;

        private _obs = [_observe, "observe", [_a, _homeA, false, [], time]] call ALIVE_fnc_ATOObserve;
        diag_log format ["  info  parked on the deck: getPosATL z %1, getPos z %2, getPosASL z %3, isTouchingGround %4, altAGL reported %5",
            round ((getPosATL _a) select 2), (getPos _a) select 2, round ((getPosASL _a) select 2),
            isTouchingGround _a, [_obs, "altAGL", -1] call ALIVE_fnc_hashGet];
        ["a jet parked on the deck does not read as airborne",
            !([_obs, "airborne", true] call ALIVE_fnc_hashGet)] call _fnc_check;
        ["and it reads as landed",
            [_obs, "landed", false] call ALIVE_fnc_hashGet] call _fnc_check;
        ["the observer calls it fixed wing",
            [_obs, "fixedWing", false] call ALIVE_fnc_hashGet] call _fnc_check;
        ["and calls its home a deck",
            [_obs, "deckHome", false] call ALIVE_fnc_hashGet] call _fnc_check;

        // The effector's own frame. A ground chain on a parked deck jet is
        // accepted; read from the sea bed it was refused as an airborne chain
        // with no hold at the end. forceLaunch is NOT applied here, it would
        // fly the aircraft.
        [_effect, "apply", ["mintCrew", _a, _homeA, []]] call ALIVE_fnc_ATOEffect;
        sleep 1;
        ["the jet has a pilot", !isNull (driver _a)] call _fnc_check;
        private _hold = [["HOLD", [round ((getPosATL _a) select 0), round ((getPosATL _a) select 1), 0]]];
        (["issueOrders", _a, _homeA, [_hold]] call _fnc_apply) params ["_stO", "_mO", "_dO"];
        ["a ground chain is accepted for a jet parked on the deck",
            _stO isEqualTo "ok" && {!(_dO isEqualTo "no terminal hold")}] call _fnc_check;
        ["clearOrders", _a, _homeA, []] call _fnc_apply;

        // Let the placement's own settle thread finish before anything else
        // moves the jet by hand, so its re-arm cannot land in the middle of
        // a move below.
        sleep 6;
    } else {
        {
            _x call _fnc_skip;
        } forEach ["a jet parked on the deck does not read as airborne", "and it reads as landed",
                   "the observer calls it fixed wing", "and calls its home a deck", "the jet has a pilot",
                   "a ground chain is accepted for a jet parked on the deck"];
    };

    // --- A2: the catapults are read off the parts -----------------------------
    _cats = [_surface, "catapults", _ship] call ALIVE_fnc_ATOSurface;
    diag_log format ["  info  %1 catapult(s) read: %2", count _cats,
        _cats apply { [typeOf (_x select 0), _x select 1, _x select 2, count (_x select 3)] }];
    ["two catapults are read off the parts", count _cats == 2] call _fnc_check;
    ["each is on a live part of this ship",
        count _cats > 0 && {(_cats findIf { isNull (_x select 0) || {!((typeOf (_x select 0)) in _parts)} }) == -1}] call _fnc_check;
    ["each has four deflector animations",
        count _cats > 0 && {(_cats findIf { !((_x select 3) isEqualType []) || {count (_x select 3) != 4} }) == -1}] call _fnc_check;

    private _badPos = [];
    {
        private _p = [_surface, "catapultPos", _x] call ALIVE_fnc_ATOSurface;
        private _cls = [_surface, "classify", [_p select 0, _p select 1, 0]] call ALIVE_fnc_ATOSurface;
        if (!(_cls isEqualTo "deck") || {(abs ((_p select 2) - _deckZ)) > 3}) then {
            _badPos pushBack [_x select 1, _cls, round (_p select 2)];
        };
    } forEach _cats;
    ["each catapult point is on the deck at deck level",
        count _cats > 0 && {count _badPos == 0}] call _fnc_check;
    if (count _badPos > 0) then { diag_log format ["  info  the points that are not: %1", _badPos] };

    // --- A3: the outer pair is never offered ----------------------------------
    ["neither outer catapult is offered",
        (_cats findIf { (_x select 1) in ["pos_catapult_01", "pos_catapult_04"] }) == -1] call _fnc_check;

    // Asked from right beside the outer one, found directly on its part.
    private _hull042 = (nearestObjects [getPosASL _ship, ["Land_Carrier_01_hull_04_2_F"], 400]) param [0, objNull];
    if (isNull _hull042 || {count _cats == 0}) then {
        "asked from beside an outer catapult, an inner one is still the answer" call _fnc_skip;
    } else {
        private _p01 = _hull042 modelToWorldWorld (_hull042 selectionPosition "pos_catapult_01");
        private _beside = [(_p01 select 0) + 2, _p01 select 1, _p01 select 2];
        private _f3 = [_surface, "freeCatapult", [_ship, _beside, [_a]]] call ALIVE_fnc_ATOSurface;
        diag_log format ["  info  from 2 m beside pos_catapult_01 the answer is %1", _f3 param [1, "nothing"]];
        ["asked from beside an outer catapult, an inner one is still the answer",
            count _f3 > 4 && {(_f3 select 1) in ["pos_catapult_02", "pos_catapult_03"]}] call _fnc_check;
    };

    // --- A4: found from a deck position, nearest first ------------------------
    private _f4 = [_surface, "freeCatapult", [_ship, _flatCentre, [_a]]] call ALIVE_fnc_ATOSurface;
    ["a free catapult is found from the deck centre", count _f4 > 4] call _fnc_check;
    private _chosenIdx = -1;
    private _otherIdx = -1;
    if (count _f4 > 4 && {count _cats == 2}) then {
        _chosenIdx = _cats findIf { (_x select 1) isEqualTo (_f4 select 1) };
        _otherIdx = if (_chosenIdx == 0) then { 1 } else { 0 };
        private _dChosen = _flatCentre distance2D (_f4 select 4);
        private _dOther = _flatCentre distance2D ([_surface, "catapultPos", _cats select _otherIdx] call ALIVE_fnc_ATOSurface);
        diag_log format ["  info  %1 is %2 m from the centre, %3 is %4 m",
            _f4 select 1, round _dChosen, (_cats select _otherIdx) select 1, round _dOther];
        ["and it is the nearer of the two", _dChosen <= _dOther] call _fnc_check;
    } else {
        "and it is the nearer of the two" call _fnc_skip;
    };

    // --- A5: a catapult with a jet on it is not offered twice ------------------
    private _standPos = [0,0,0];
    private _standDir = 0;
    if (!isNull _a && {_chosenIdx > -1}) then {
        _standPos = getPosASL _a;
        _standDir = getDir _a;
        private _xEntry = _cats select _chosenIdx;
        private _xMem = _xEntry select 1;
        private _xPos = [_surface, "catapultPos", _xEntry] call ALIVE_fnc_ATOSurface;
        // Damage off for the hand moves in this section; the launch below
        // takes it off itself and re-arms it when the shot is done.
        _a allowDamage false;
        _a setPosASL [_xPos select 0, _xPos select 1, (_xPos select 2) + 0.4];
        _a setVectorUp [0,0,1];
        _a setVelocity [0,0,0];
        sleep 1;

        private _f5 = [_surface, "freeCatapult", [_ship, getPosASL _a, []]] call ALIVE_fnc_ATOSurface;
        ["a catapult with a jet standing on it is not offered",
            count _f5 > 4 && {!((_f5 select 1) isEqualTo _xMem)}] call _fnc_check;
        private _f5i = [_surface, "freeCatapult", [_ship, getPosASL _a, [_a]]] call ALIVE_fnc_ATOSurface;
        ["unless the jet asking is the one standing on it",
            count _f5i > 4 && {(_f5i select 1) isEqualTo _xMem}] call _fnc_check;

        private _oPos = [_surface, "catapultPos", _cats select _otherIdx] call ALIVE_fnc_ATOSurface;
        private _b = createVehicle [_jet, [0,0,0], [], 0, "CAN_COLLIDE"];
        _b setVariable ["ALIVE_profileIgnore", true, true];
        _b allowDamage false;
        _b setPosASL [_oPos select 0, _oPos select 1, (_oPos select 2) + 0.4];
        _b setVectorUp [0,0,1];
        _b setVelocity [0,0,0];
        sleep 1;
        private _f5b = [_surface, "freeCatapult", [_ship, getPosASL _a, []]] call ALIVE_fnc_ATOSurface;
        ["with a jet on each there is no free catapult", _f5b isEqualTo []] call _fnc_check;
        deleteVehicle _b;
        sleep 1;

        // Back on its stand for the launch, by hand rather than through
        // place, whose settle thread would re-arm damage in the middle of
        // the tow.
        _a setDir _standDir;
        _a setPosASL _standPos;
        _a setVectorUp [0,0,1];
        _a setVelocity [0,0,0];
        sleep 2;
    } else {
        {
            _x call _fnc_skip;
        } forEach ["a catapult with a jet standing on it is not offered", "unless the jet asking is the one standing on it",
                   "with a jet on each there is no free catapult"];
    };

    // --- A6, A8: onto the catapult, and asking twice ---------------------------
    private _launchEntry = [];
    if (!isNull _a && {count _cats > 0} && {!isNull (driver _a)}) then {
        [_effect, "apply", ["mintCrew", _a, _homeA, []]] call ALIVE_fnc_ATOEffect;
        private _r6 = ["catapult", _a, _homeA, [_surface, "BLU_F_0"]] call _fnc_apply;
        _r6 params [["_st6", "refused"], ["_m6", false], ["_d6", ""]];
        diag_log format ["  info  the catapult effect answered %1", _r6];
        ["the catapult effect is accepted", _st6 isEqualTo "ok" && {!_m6}] call _fnc_check;
        ["and names the catapult it chose", _d6 in ["pos_catapult_02", "pos_catapult_03"]] call _fnc_check;

        // A8, asked again straight away: the launch owns the aircraft.
        private _r8 = ["catapult", _a, _homeA, [_surface, "BLU_F_0"]] call _fnc_apply;
        ["asking again during the launch changes nothing and says so",
            (_r8 param [1, false]) && {(_r8 param [2, ""]) isEqualTo "launch in progress"}] call _fnc_check;

        private _li = _cats findIf { (_x select 1) isEqualTo _d6 };
        if (_st6 isEqualTo "ok" && {_li > -1}) then {
            _launchEntry = _cats select _li;
            _launchEntry params ["_cPart", "_cMem", "_cOff", "_cAnims"];
            private _cPos = [_surface, "catapultPos", _launchEntry] call ALIVE_fnc_ATOSurface;
            // The part's heading less the catapult's offset, and NOT less a
            // further 180. Measured: with the extra 180 the jet is thrown down
            // the deck towards the stern and ends up in the sea; without it, it
            // leaves at 409 km/h and climbs away.
            private _want = ((((getDir _cPart) - _cOff) % 360) + 360) % 360;

            // Wait for the tow to finish rather than sleeping a fixed time:
            // how long it takes depends on where the stand is and how far
            // round the jet has to turn, and the turn can outlast the move.
            // Both have to be done, because the pin and the deflector start
            // only when both are.
            private _waited = 0;
            private _arrived = false;
            while { !_arrived && {_waited < 20} } do {
                sleep 0.25;
                _waited = _waited + 0.25;
                _arrived = ((_a distance2D _cPos) < 0.5) && {([getDir _a, _want] call _fnc_headingGap) < 3};
            };
            private _gap = [getDir _a, _want] call _fnc_headingGap;
            diag_log format ["  info  %1 after %2 s: %3 m from %4, heading %5 against %6 wanted",
                if (_arrived) then {"on the catapult"} else {"NOT on the catapult"}, _waited,
                round (_a distance2D _cPos), _cMem, round (getDir _a), round _want];
            ["the jet is towed onto the catapult", (_a distance2D _cPos) < 3] call _fnc_check;
            ["and points down it", _gap < 3] call _fnc_check;

            // Pinned: two samples a second apart do not move. checkAIFeature
            // is global per feature, so the pilot's MOVE being off is shown by
            // the aircraft staying put with its engine running.
            sleep 1;
            private _p1 = getPosWorld _a;
            sleep 1;
            private _p2 = getPosWorld _a;
            diag_log format ["  info  pinned: moved %1 m in a second, engine on %2",
                (_p1 distance _p2) toFixed 2, isEngineOn _a];
            ["and is held there", (_p1 distance _p2) < 0.5] call _fnc_check;

            // Five seconds after the tow it is still pinned and the deflector,
            // one second to raise, has long been up.
            sleep 3;
            private _phaseUp = _cPart animationPhase (_cAnims select 0);
            diag_log format ["  info  deflector %1 at phase %2", _cAnims select 0, _phaseUp toFixed 2];
            // MOVED, not moved to a particular number. The engine's own
            // animation was measured at 4.92 three seconds in, and what the
            // scale tops out at is its business rather than something this
            // check should legislate. Zero is down, which is what matters.
            ["and the deflector behind it has come up", _phaseUp > 1] call _fnc_check;

            // --- A7: airborne and moving ---------------------------------------
            sleep 15;
            private _alt = (getPosASL _a) select 2;
            private _spd = speed _a;
            private _dShip = _a distance2D _ship;
            diag_log format ["  info  twenty seconds on: alive %1, %2 m ASL, %3 km/h, %4 m from the ship",
                alive _a, round _alt, round _spd, round _dShip];
            ["the jet is still in one piece", !isNull _a && {alive _a}] call _fnc_check;
            ["and it is in the air", _alt > 20] call _fnc_check;
            ["and flying, not falling", _spd > 150] call _fnc_check;
            ["and clear of the ship", _dShip > 150] call _fnc_check;

            sleep 5;
            private _phaseDown = _cPart animationPhase (_cAnims select 0);
            diag_log format ["  info  deflector back at phase %1, damage allowed %2", _phaseDown toFixed 2, isDamageAllowed _a];
            ["the deflector is down again behind it", _phaseDown < 0.1] call _fnc_check;
            ["and damage is re-armed", isDamageAllowed _a] call _fnc_check;
        } else {
            {
                _x call _fnc_skip;
            } forEach ["the jet is towed onto the catapult", "and is held there", "and points down it",
                       "and the deflector behind it has come up", "the jet is still in one piece", "and it is in the air",
                       "and flying, not falling", "and clear of the ship", "the deflector is down again behind it",
                       "and damage is re-armed"];
        };
    } else {
        {
            _x call _fnc_skip;
        } forEach ["the catapult effect is accepted", "and names the catapult it chose",
                   "asking again during the launch changes nothing and says so"];
    };

    // --- A9, A10: what the table asks for, pure --------------------------------
    // The observation a parked, crewed, cleared aircraft on a ship gives.
    private _fnc_obs = {
        params ["_flags"];
        private _o = [] call ALIVE_fnc_hashCreate;
        {
            [_o, _x select 0, _x select 1] call ALIVE_fnc_hashSet;
        } forEach [
            ["objectLive", true], ["objectLost", false], ["local", true], ["remote", false],
            ["airborne", false], ["atHome", true], ["nearHome", true], ["landed", false],
            ["crewGroupLive", true], ["driverPresent", true], ["crewSeated", true], ["crewLoss", false],
            ["playerControl", false], ["playerPassenger", false], ["anyPlayerAboard", false],
            ["onStation", false], ["targetsGone", false], ["lockHeld", true],
            ["deckHome", true], ["fixedWing", true],
            ["fuel", 1], ["ammo", 1], ["damage", 0],
            ["playersWithin300", 0], ["playersWithin1000Home", 0], ["playersWithin1000Hull", 0]
        ];
        { [_o, _x select 0, _x select 1] call ALIVE_fnc_hashSet } forEach _flags;
        _o
    };
    private _fnc_step = {
        params ["_state", "_flags"];
        private _row = [_machine, "newRow", ["BLU_F_0", _homeA]] call ALIVE_fnc_ATOMachine;
        [_row, "state", _state] call ALIVE_fnc_hashSet;
        [_row, "sortie", ["CAS", [1000, 1000, 0], 600]] call ALIVE_fnc_hashSet;
        [_row, "deadlineAt", 9999] call ALIVE_fnc_hashSet;
        [_machine, "step", [_row, [_flags] call _fnc_obs, "", 100]] call ALIVE_fnc_ATOMachine
    };

    (["ASSIGNED", [["fixedWing", false]]] call _fnc_step) params ["_rowH", "_ordH", "_effH"];
    ["a helicopter on a deck goes to LAUNCHING when crewed and cleared",
        ([_rowH, "state", ""] call ALIVE_fnc_hashGet) isEqualTo "LAUNCHING"] call _fnc_check;
    ["and is given its engine, not a catapult",
        ("engineOn" in _effH) && {!("catapult" in _effH)}] call _fnc_check;
    (["ASSIGNED", [["fixedWing", true]]] call _fnc_step) params ["_rowP", "_ordP", "_effP"];
    ["a plane on a deck is sent to the catapult on launch",
        (([_rowP, "state", ""] call ALIVE_fnc_hashGet) isEqualTo "LAUNCHING") && {"catapult" in _effP} && {"engineOn" in _effP}] call _fnc_check;
    ["and the engine is started before the catapult is asked for",
        (_effP find "engineOn") > -1 && {(_effP find "engineOn") < (_effP find "catapult")}] call _fnc_check;
    // Still on the deck a tick later: asked again.
    (["LAUNCHING", [["fixedWing", true]]] call _fnc_step) params ["_rowP2", "_ordP2", "_effP2"];
    ["and asked for again every tick it is still on the deck", "catapult" in _effP2] call _fnc_check;
    // Off the wire: the runway goes back and it is on its way.
    (["LAUNCHING", [["fixedWing", true], ["airborne", true], ["atHome", false]]] call _fnc_step) params ["_rowP3", "_ordP3", "_effP3"];
    ["and once airborne it is en route with the runway released",
        (([_rowP3, "state", ""] call ALIVE_fnc_hashGet) isEqualTo "ENROUTE") && {"unlock" in _effP3} && {!("catapult" in _effP3)}] call _fnc_check;
    // A player riding along: the tow is a teleport and is stripped.
    (["LAUNCHING", [["fixedWing", true], ["playerPassenger", true], ["anyPlayerAboard", true]]] call _fnc_step) params ["_rowP4", "_ordP4", "_effP4"];
    // Not asked for, and no refusal recorded either, because it is never
    // asked for. This check used to require the refusal marker as well, which
    // was asserting the churn rather than the behaviour: the table pushed the
    // launch anyway and the teleport filter stripped it and noted a refusal,
    // once every two seconds until the deadline. It is now simply not asked
    // for, so there is nothing to strip and nothing to note.
    ["and never asked for with a player riding along",
        !("catapult" in _effP4)] call _fnc_check;

    (["LANDING", [["fixedWing", true], ["airborne", true], ["atHome", false]]] call _fnc_step) params ["_rowL", "_ordL", "_effL"];
    ["a plane coming back to a deck is asked for the deck recovery",
        ("deckRecover" in _effL) && {!("landAtPad" in _effL)}] call _fnc_check;
    (["LANDING", [["fixedWing", false], ["airborne", true], ["atHome", false]]] call _fnc_step) params ["_rowLH", "_ordLH", "_effLH"];
    ["and a helicopter coming back to a deck keeps its pad",
        ("landAtPad" in _effLH) && {!("deckRecover" in _effLH)}] call _fnc_check;
    (["LANDING", [["fixedWing", true], ["deckHome", false], ["airborne", true], ["atHome", false]]] call _fnc_step) params ["_rowLT", "_ordLT", "_effLT"];
    ["and a plane coming back to land is not sent to a wire",
        ("landAtPad" in _effLT) && {!("deckRecover" in _effLT)}] call _fnc_check;

    // The observer on a real helicopter parked on the same deck.
    private _heli = objNull;
    private _homeH = [];
    if (count _homeA >= 6) then {
        private _bb = [_jet] call ALiVE_fnc_getVehicleBoundingBox;
        private _span = ((((_bb select 0) max (_bb select 1)) / 2) + 4) max 12;
        _homeH = [_surface, "cascade", ["deck", _heliClass, _flatCentre, [[_homeA select 0, _span]]]] call ALIVE_fnc_ATOSurface;
    } else {
        _homeH = [_surface, "cascade", ["deck", _heliClass, _flatCentre, []]] call ALIVE_fnc_ATOSurface;
    };
    if (count _homeH >= 6) then {
        _heli = createVehicle [_heliClass, [0,0,0], [], 0, "CAN_COLLIDE"];
        _heli setVariable ["ALIVE_profileIgnore", true, true];
        _spawned pushBack _heli;
        [_surface, "place", [_heli, _homeH]] call ALIVE_fnc_ATOSurface;
        sleep 2;
        private _obsH = [_observe, "observe", [_heli, _homeH, false, [], time]] call ALIVE_fnc_ATOObserve;
        ["a helicopter on the deck is not called fixed wing",
            !([_obsH, "fixedWing", true] call ALIVE_fnc_hashGet)] call _fnc_check;
        ["but its home is still a deck",
            [_obsH, "deckHome", false] call ALIVE_fnc_hashGet] call _fnc_check;
    } else {
        "a helicopter on the deck is not called fixed wing" call _fnc_skip;
        "but its home is still a deck" call _fnc_skip;
    };

    // --- A11: refusals ---------------------------------------------------------
    private _c = objNull;
    private _homeC = [_surface, "cascade", ["terrain", _jet, _land, []]] call ALIVE_fnc_ATOSurface;
    if (count _homeC == 3) then {
        _c = createVehicle [_jet, [0,0,0], [], 0, "CAN_COLLIDE"];
        _c setVariable ["ALIVE_profileIgnore", true, true];
        _spawned pushBack _c;
        [_surface, "place", [_c, _homeC]] call ALIVE_fnc_ATOSurface;
        sleep 3;
        [_effect, "apply", ["mintCrew", _c, _homeC, []]] call ALIVE_fnc_ATOEffect;
        sleep 1;
        // Brought to a stop first, and the reason is this test's own doing.
        // This jet was launched earlier in the run, which leaves it with a move
        // order two kilometres ahead and its pilot's movement enabled, so it
        // taxis. Measuring whether a REFUSAL moved it while it is already under
        // orders to go somewhere measures the orders, not the refusal.
        if (!isNull (driver _c)) then {
            (driver _c) disableAI "MOVE";
            doStop _c;
        };
        _c engineOn false;
        _c setVelocity [0,0,0];
        sleep 2;
        private _before = getPosASL _c;
        private _rC = ["catapult", _c, _homeC, [_surface, "BLU_F_1"]] call _fnc_apply;
        diag_log format ["  info  a jet on land asked for a catapult: %1", _rC];
        ["a jet on land is refused a catapult",
            ((_rC param [0, ""]) isEqualTo "refused") && {(_rC param [2, ""]) isEqualTo "no carrier"}] call _fnc_check;
        sleep 1;
        // Five metres, and the figure is chosen for what it has to catch. The
        // property is that a REFUSED launch does not move the aircraft, and the
        // thing that would move it is the tow, which is twenty to a hundred and
        // fifty metres. A metre was too tight for a crewed plane idling on the
        // ground: shutting the engine down and stopping the pilot does not stop
        // a plane that is already rolling from finishing its roll.
        private _drift = _c distance2D _before;
        diag_log format ["  info  the refused jet drifted %1 m", _drift toFixed 2];
        ["and it was not towed anywhere", _drift < 5] call _fnc_check;

        // A deck home whose ship is not here.
        if (count _homeA >= 6) then {
            private _orphan = +_homeA;
            _orphan set [3, [typeOf _ship, [10, 10, 0], "0:0"]];
            private _rO = ["catapult", _c, _orphan, [_surface, "BLU_F_1"]] call _fnc_apply;
            ["a deck home whose carrier is gone is refused",
                ((_rO param [0, ""]) isEqualTo "refused") && {(_rO param [2, ""]) isEqualTo "no carrier"}] call _fnc_check;
        } else {
            "a deck home whose carrier is gone is refused" call _fnc_skip;
        };
    } else {
        {
            _x call _fnc_skip;
        } forEach ["a jet on land is refused a catapult", "and it was not towed anywhere", "a deck home whose carrier is gone is refused"];
    };

    private _rN = ["catapult", objNull, _homeA, [_surface, "BLU_F_0"]] call _fnc_apply;
    ["a missing hull is refused",
        ((_rN param [0, ""]) isEqualTo "refused") && {(_rN param [2, ""]) isEqualTo "no object"}] call _fnc_check;
    "a hull owned elsewhere is refused (single machine, nothing here is remote)" call _fnc_skip;

    // --- A12: the hook ----------------------------------------------------------
    if (!isNull _c && {!isNull _heli}) then {
        private _hookBefore = _c animationPhase "tailhook";
        private _rH = ["tailhook", _c, _homeC, []] call _fnc_apply;
        ["the hook is put out", ((_rH param [0, ""]) isEqualTo "ok") && {!(_rH param [1, false])}] call _fnc_check;

        // Waited for, not sampled. The animation takes about a second and a
        // half, and reading it half way through was what let the old pair of
        // checks assert the very behaviour that was broken.
        private _down = false;
        private _w = 0;
        while { !_down && {_w < 4} } do {
            sleep 0.25;
            _w = _w + 0.25;
            _down = (_c animationPhase "tailhook") < 0.1;
        };
        diag_log format ["  info  tailhook phase %1 before, %2 after %3 s",
            _hookBefore toFixed 2, (_c animationPhase "tailhook") toFixed 2, _w];
        ["and it reaches the down position", _down] call _fnc_check;

        // Asked again with the hook actually down: nothing to do, and it says
        // so. This is only meaningful now that it is the HOOK being read and
        // not a flag.
        private _rH2 = ["tailhook", _c, _homeC, []] call _fnc_apply;
        diag_log format ["  info  asking again with the hook down answered %1", _rH2];
        ["asking again with the hook down changes nothing and says so",
            _rH2 param [1, false]] call _fnc_check;

        private _rHH = ["tailhook", _heli, _homeH, []] call _fnc_apply;
        ["a helicopter has no hook to put out",
            ((_rHH param [0, ""]) isEqualTo "refused") && {(_rHH param [2, ""]) isEqualTo "no hook on this aircraft"}] call _fnc_check;

        private _rR = ["releaseApproach", _c, _homeC, [_surface, "BLU_F_1"]] call _fnc_apply;
        ["giving the approach back is accepted", (_rR param [0, ""]) isEqualTo "ok"] call _fnc_check;
        private _raised = false;
        _w = 0;
        while { !_raised && {_w < 5} } do {
            sleep 0.25;
            _w = _w + 0.25;
            _raised = (_c animationPhase "tailhook") > 0.95;
        };
        diag_log format ["  info  tailhook phase %1 after the release", (_c animationPhase "tailhook") toFixed 2];
        ["and the hook comes back up", _raised] call _fnc_check;
        ["and the aircraft no longer says its hook is out",
            !(_c getVariable ["ALiVE_mil_ato_hookOut", false])] call _fnc_check;

        // THE ONE THAT MATTERS. With the hook up again, asking is not
        // "nothing to do": it has to put the hook back out.
        //
        // This is the regression guard for the fault the review found. The
        // old test read a flag this module set, and the engine raises the hook
        // by itself after a bolter, at the end of an arrest, and through the
        // aircraft's own landing handler. With the flag still saying out, every
        // later ask answered "nothing to do" and moved nothing, so a go-around
        // was flown hook up and the wire never caught.
        if (_raised) then {
            private _rH3 = ["tailhook", _c, _homeC, []] call _fnc_apply;
            diag_log format ["  info  with the hook up, asking again answered %1", _rH3];
            ["with the hook UP, asking again puts it out rather than saying nothing to do",
                !(_rH3 param [1, false])] call _fnc_check;
        } else {
            "with the hook UP, asking again puts it out rather than saying nothing to do" call _fnc_skip;
        };
    } else {
        {
            _x call _fnc_skip;
        } forEach ["the hook is put out", "and it reaches the down position",
                   "asking again with the hook down changes nothing and says so",
                   "a helicopter has no hook to put out", "giving the approach back is accepted",
                   "and the hook comes back up", "and the aircraft no longer says its hook is out",
                   "with the hook UP, asking again puts it out rather than saying nothing to do"];
    };

    // --- tidy up ---------------------------------------------------------------
    {
        if (!isNull _x) then {
            { deleteVehicle _x } forEach (crew _x);
            deleteVehicle _x;
        };
    } forEach _spawned;
    {
        if (!isNull (_x select 0)) then {
            [_x select 0, _x select 3, 0] call BIS_fnc_Carrier01AnimateDeflectors;
        };
    } forEach _cats;

    if (count _fails == 0) then {
        diag_log format ["=== ATO Carrier ops test: ALL PASS (%1 skipped) ===", count _skips];
    } else {
        diag_log format ["=== ATO Carrier ops test: %1 FAILED ===", count _fails];
        { diag_log format ["   failed: %1", _x] } forEach _fails;
    };
};

"ATO Carrier ops test started, results follow in the log"
