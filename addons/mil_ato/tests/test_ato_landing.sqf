#include "\x\alive\addons\mil_ato\script_component.hpp"

SCRIPT(test_ato_landing);

/* ----------------------------------------------------------------------------
The approach, on its own, timed.

Smallest mission: nothing at all. Anchored on the player when there is one and
on the Agia Marina strip when there is not, so it runs on a dedicated server as
well as in front of somebody. The test creates the aircraft it needs and removes
it afterwards.

Why this exists separately from the flight run. The flight run takes seven
minutes and spends six of them proving things that already work, and it cannot
test the approach at all when nobody is watching: with no player within a
kilometre of home, the table deliberately places a returning aircraft on its
slot rather than flying it in, so the whole approach is skipped and the run
passes without touching it. This starts where a returning aircraft actually is,
nine hundred metres out and flying, and drives the effector directly.

What it is really guarding is a pair of engine facts that took a long time to
establish and are easy to undo by tidying the code:

  landAt does not land. It holds an aircraft dead centre over the pad, at
  whatever height it already has, for as long as you leave it there.

  land "LAND" is the landing, and the two have to be issued seconds apart or
  they fight each other and the aircraft ends up further away than if only one
  had been given.

So a regression here does not look like an error in the log. It looks like an
aircraft hovering quietly above its stand, or parked next to it, which is
exactly what shipped for weeks. Hence the assertion on the DISTANCE, not just on
whether it came down.
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

    diag_log "=== ATO landing test ===";

    private _s = [nil, "create"] call ALIVE_fnc_ATOSurface;
    private _e = [nil, "create"] call ALIVE_fnc_ATOEffect;

    private _anchor = if (isNull player) then {[1839.76, 5750.47, 0]} else {getPosATL player};
    private _class = "B_Heli_Attack_01_F";
    private _tail = "BLU_F_0";

    private _home = [_s, "cascade", ["terrain", _class, _anchor, []]] call ALIVE_fnc_ATOSurface;
    ["a home was found for the aircraft", count _home == 3] call _fnc_check;
    if (count _home != 3) exitWith { diag_log "=== ATO landing test: ABANDONED, no home ===" };
    private _stand = _home select 0;

    // Airborne, nine hundred metres out, at the height a returning aircraft is
    // actually at, and pointed at the field rather than away from it.
    private _start = _stand getPos [900, 200];
    private _veh = createVehicle [_class, [_start select 0, _start select 1, 120], [], 0, "FLY"];
    [_e, "apply", ["shield",   _veh, _home, [_tail]]] call ALIVE_fnc_ATOEffect;
    [_e, "apply", ["mintCrew", _veh, _home, [_tail]]] call ALIVE_fnc_ATOEffect;
    sleep 3;
    ["it has a crew to fly it", !isNull (driver _veh)] call _fnc_check;
    if (isNull (driver _veh)) exitWith {
        deleteVehicle _veh;
        diag_log "=== ATO landing test: ABANDONED, no crew ===";
    };
    _veh setPosATL [_start select 0, _start select 1, 120];
    _veh setVelocity [(sin 20) * 60, (cos 20) * 60, 0];
    // Home the way the table sends it: the return chain first, a move to an
    // approach fix and a loiter, so the approach starts from the legs a real
    // return leaves behind rather than from a clean run-in. On LAN three Apaches
    // with that chain behind them circled their pads for five minutes.
    [_e, "apply", ["issueOrders", _veh, _home, [[["MOVE", _stand getPos [800, 200]], ["LOITER", _stand getPos [600, 90]]]]]] call ALIVE_fnc_ATOEffect;
    sleep 4;

    // --- the approach ---------------------------------------------------------
    private _down = false;
    private _elapsed = 0;
    private _closest = 9999;
    private _everSteered = false;
    private _quietSeen = "";
    for "_i" from 1 to 75 do {
        private _r = [_e, "apply", ["landAtPad", _veh, _home, [_s, _tail]]] call ALIVE_fnc_ATOEffect;
        private _p = getPosATL _veh;
        private _d = _veh distance2D _stand;
        if (_d < _closest) then { _closest = _d };
        if (((_r select 2) select [0, 7]) isEqualTo "inbound") then {
            _everSteered = true;
            if (_quietSeen isEqualTo "") then { _quietSeen = behaviour (driver _veh) };
        };

        // Every fourth tick. Enough to see the shape of the descent without
        // burying the log in a run that is mostly uneventful.
        if (_i mod 4 == 0) then {
            diag_log format ["  info  t%1 %2 m out, %3 m up, %4 km/h | %5",
                _elapsed, round _d, round (_p select 2), round (speed _veh), _r select 2];
        };

        // Wheels down, and stopped. Being low is not being down.
        if ((isTouchingGround _veh) && {(speed _veh) < 5} && {(_p select 2) < 2}) then {
            _down = true;
        };
        if (_down) exitWith {};
        sleep 2;
        _elapsed = _elapsed + 2;
    };

    private _finalDist = _veh distance2D _stand;
    diag_log format ["  info  %1 after %2 s, %3 m from the stand",
        if (_down) then {"down"} else {"STILL UP"}, _elapsed, round _finalDist];

    ["it was steered in rather than starting on finals", _everSteered] call _fnc_check;
    ["and its crew was quiesced from the first approach tick", _quietSeen isEqualTo "CARELESS"] call _fnc_check;
    ["it reached its stand on the way in", _closest < 60] call _fnc_check;
    ["it came down", _down] call _fnc_check;
    // The number that matters. Measured at 2 m twice; ten gives room for the
    // engine without letting a regression to parking-beside-the-pad through.
    ["and it came down ON its stand", _down && {_finalDist < 10}] call _fnc_check;

    // --- and then the tidy ----------------------------------------------------
    // On the slot is within 5 m, and there this must say so and move nothing.
    // The approach commits within 150 m now, and its landings end 1 to 6 m off,
    // so one a little further out is slid the last few metres instead.
    private _offBy = _veh distance2D _stand;
    (([_e, "apply", ["placeOnSlot", _veh, _home, [_s]]] call ALIVE_fnc_ATOEffect)) params ["_stT", "_mT"];
    sleep 2;
    if (_offBy < 5) then {
        ["the tidy finds it already on its stand and leaves it alone",
            _stT isEqualTo "ok" && {_mT}] call _fnc_check;
    } else {
        ["the tidy slides it the last few metres onto its stand",
            _stT isEqualTo "ok" && {!_mT} && {(_veh distance2D _stand) < 5}] call _fnc_check;
    };
    ["and it ends on its stand", (_veh distance2D _stand) < 10] call _fnc_check;

    // --- giving the approach back ---------------------------------------------
    private _grp = group (driver _veh);
    (([_e, "apply", ["releaseApproach", _veh, _home, [_s, _tail]]] call ALIVE_fnc_ATOEffect)) params ["_stR"];
    ["the approach is given back", _stR isEqualTo "ok"] call _fnc_check;
    ["and the aircraft is no longer held on finals",
        isNil {_grp getVariable "ALiVE_mil_ato_landing"}] call _fnc_check;

    { deleteVehicle _x } forEach (crew _veh);
    deleteVehicle _veh;

    diag_log format ["  info  %1 assertions", _checked];
    if (count _fails == 0) then {
        diag_log "=== ATO landing test: ALL PASS ===";
    } else {
        diag_log format ["=== ATO landing test: %1 FAILURE(S): %2 ===", count _fails, _fails];
    };
};

"ATO landing test started, results follow in the log"
