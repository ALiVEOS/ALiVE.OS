#include "\x\alive\addons\mil_ato\script_component.hpp"

SCRIPT(test_ato_observe);

/* ----------------------------------------------------------------------------
Observer test.

Smallest mission: a player standing anywhere, no ALiVE modules, no aircraft.
The test creates the one hull it needs and deletes it afterwards.

It moves the player in and out of the seats, because who is aboard and whether
they are flying is the thing this piece has to get right every tick. A handler
set when the aircraft was adopted does not fire when a player dies in the seat,
and a corpse is not a pilot.

Runs spawned: seating and ownership changes need a tick to take effect, and a
console `call` would run the whole thing inside one frame.
---------------------------------------------------------------------------- */

[] spawn {

    private _fails = [];
    private _skips = [];
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
    // What a dedicated server cannot answer. There is no player on one at all,
    // so every assertion about somebody being at the controls is unanswerable
    // rather than false, and calling it a failure hides the real ones.
    private _fnc_skip = {
        _skips pushBack _this;
        diag_log format ["  skip  %1  (no player on this machine)", _this];
    };

    diag_log "=== ATO Observer test ===";

    private _o = [nil, "create"] call ALIVE_fnc_ATOObserve;
    private _fnc_obs = {
        params ["_obj", ["_home", []], ["_sortie", []]];
        [_o, "observe", [_obj, _home, false, _sortie, time]] call ALIVE_fnc_ATOObserve
    };
    private _fnc_get = { [_this select 0, _this select 1, "MISSING"] call ALIVE_fnc_hashGet };

    // --- a hull that is not there -------------------------------------------
    // Asked first, because everything downstream depends on this not throwing.
    private _dead = [_o, "observe", [objNull, [], false, [], time]] call ALIVE_fnc_ATOObserve;
    ["a null hull answers without throwing", !isNil "_dead"] call _fnc_check;
    ["and says it is gone", [_dead,"objectLost"] call _fnc_get] call _fnc_check;
    ["and answers every question the table asks",
        ([_dead,"airborne"] call _fnc_get) isEqualType false
        && {([_dead,"fuel"] call _fnc_get) isEqualType 0}
        && {([_dead,"playerControl"] call _fnc_get) isEqualType false}
        && {([_dead,"heldOnStand"] call _fnc_get) isEqualType false}
        && {([_dead,"distHome"] call _fnc_get) isEqualType 0}
        && {([_dead,"taxiOutAt"] call _fnc_get) isEqualType 0}
        && {([_dead,"playerGrace"] call _fnc_get) isEqualType 0}] call _fnc_check;
    ["and reports nobody aboard it", [_dead,"crewLoss"] call _fnc_get] call _fnc_check;

    // --- a real hull ---------------------------------------------------------
    // Nobody at a keyboard means no player to stand beside, and a position
    // derived from a null player is the map corner: aircraft created there
    // sink, and a hull that has drowned answers every question with the
    // defaults for a hull that is gone. Measured: a jet read its full load on
    // the first look and nothing at all two seconds later. The airfield
    // fallback is the one the other checks in this suite already use.
    private _spot = if (isNull player) then {
        [1839.76, 5750.47, 0]
    } else {
        (getPosATL player) getPos [40, getDir player]
    };
    private _veh = createVehicle ["B_Heli_Transport_01_F", _spot, [], 0, "CAN_COLLIDE"];
    _veh setPosATL [_spot select 0, _spot select 1, 0];
    private _home = [[_spot select 0, _spot select 1, 0], 0, "terrain"];
    sleep 2;

    private _obs = [_veh, _home] call _fnc_obs;
    ["a parked hull is alive", [_obs,"objectLive"] call _fnc_get] call _fnc_check;
    ["is not airborne", !([_obs,"airborne"] call _fnc_get)] call _fnc_check;
    ["is at its home", [_obs,"atHome"] call _fnc_get] call _fnc_check;
    ["is ours", [_obs,"local"] call _fnc_get] call _fnc_check;
    ["reports no crew", [_obs,"crewLoss"] call _fnc_get] call _fnc_check;
    ["and nobody flying it", !([_obs,"playerControl"] call _fnc_get)] call _fnc_check;
    ["reports full fuel", ([_obs,"fuel"] call _fnc_get) > 0.9] call _fnc_check;
    ["counts its rounds rather than only saying it has some",
        ([_obs,"ordnance"] call _fnc_get) isEqualType 0] call _fnc_check;
    ["and reports a climb rate, which is nothing while it is parked",
        (abs ([_obs,"climbRate"] call _fnc_get)) < 2] call _fnc_check;

    // Every key a live hull answers, a dead one answers too, or the table
    // throws on the tick an aircraft is lost. "pos" is live only by design: the
    // Kernel reads it only behind objectLive.
    private _missing = ((_obs select 1) - (_dead select 1)) - ["pos"];
    if (count _missing > 0) then { diag_log format ["  info  keys a dead hull does not answer: %1", _missing] };
    ["a dead hull answers every key a live one does", count _missing == 0] call _fnc_check;
    ["and reports the runway as not held by another aircraft",
        !([_dead,"lockBusy"] call _fnc_get) && {!([_obs,"lockBusy"] call _fnc_get)}] call _fnc_check;
    private _busy = [_o, "observe", [_veh, _home, false, [], time, true]] call ALIVE_fnc_ATOObserve;
    ["or as held by another, when the kernel says so", [_busy,"lockBusy"] call _fnc_get] call _fnc_check;

    // --- the player flies it -------------------------------------------------
    if (isNull player) then {
        {
            _x call _fnc_skip;
        } forEach [
            "a player at the controls is flying it",
            "and is not merely a passenger",
            "and somebody is aboard",
            "and the crew is not reported lost",
            "with an AI at the controls the player is a passenger",
            "and is still counted as aboard"
        ];
    } else {
    player moveInDriver _veh;
    sleep 2;
    _obs = [_veh, _home] call _fnc_obs;
    ["a player at the controls is flying it", [_obs,"playerControl"] call _fnc_get] call _fnc_check;
    ["and is not merely a passenger", !([_obs,"playerPassenger"] call _fnc_get)] call _fnc_check;
    ["and somebody is aboard", [_obs,"anyPlayerAboard"] call _fnc_get] call _fnc_check;
    ["and the crew is not reported lost", !([_obs,"crewLoss"] call _fnc_get)] call _fnc_check;

    // --- the player rides along ----------------------------------------------
    // An AI takes the controls; the player moves back. That is a different
    // situation with different consequences, so it must read differently.
    // The player has to LEAVE the driver seat first. moveInDriver does nothing
    // when the seat is taken, so putting the AI in while the player sat there
    // left the player still flying it and the observation was right to say so.
    private _grp = createGroup (side player);
    private _ai = _grp createUnit ["B_Helipilot_F", _spot, [], 0, "NONE"];
    moveOut player;
    sleep 1;
    _ai moveInDriver _veh;
    sleep 1;
    player moveInCargo _veh;
    sleep 2;
    diag_log format ["  info  driver is %1, player in cargo: %2",
        typeOf (driver _veh), (player in (crew _veh)) && {(driver _veh) != player}];
    _obs = [_veh, _home] call _fnc_obs;
    ["with an AI at the controls the player is a passenger",
        [_obs,"playerPassenger"] call _fnc_get] call _fnc_check;
    ["and is not counted as flying it", !([_obs,"playerControl"] call _fnc_get)] call _fnc_check;
    ["and is still counted as aboard", [_obs,"anyPlayerAboard"] call _fnc_get] call _fnc_check;

    // --- everyone gets out ---------------------------------------------------
    moveOut player;
    deleteVehicle _ai;
    deleteGroup _grp;
    };
    sleep 2;
    _obs = [_veh, _home] call _fnc_obs;
    ["an empty hull reports its crew lost", [_obs,"crewLoss"] call _fnc_get] call _fnc_check;
    ["with nobody flying it", !([_obs,"playerControl"] call _fnc_get)] call _fnc_check;
    ["and nobody riding along", !([_obs,"playerPassenger"] call _fnc_get)] call _fnc_check;

    // --- condition -----------------------------------------------------------
    _veh setFuel 0;
    sleep 1;
    _obs = [_veh, _home] call _fnc_obs;
    ["an empty tank is reported", ([_obs,"fuel"] call _fnc_get) < 0.01] call _fnc_check;
    _veh setFuel 1;

    // --- protection ----------------------------------------------------------
    // Under the current design an airframe the module owns carries no profile,
    // so nothing that removes profiles can reach it.
    ([_o, "isProtected", _veh] call ALIVE_fnc_ATOObserve) params ["_p1", "_r1"];
    ["a hull with no profile cannot be taken away", _p1] call _fnc_check;
    ["and there is nothing to report about it", count _r1 == 0] call _fnc_check;

    // A stamp with nothing behind it is a leftover, not an owner: it must be
    // said out loud but must not read as a risk.
    _veh setVariable ["profileID", "NOT_A_REAL_PROFILE", true];
    ([_o, "isProtected", _veh] call ALIVE_fnc_ATOObserve) params ["_p2", "_r2"];
    ["a stale profile stamp is not treated as an owner", _p2] call _fnc_check;
    _veh setVariable ["profileID", nil, true];

    ([_o, "isProtected", objNull] call ALIVE_fnc_ATOObserve) params ["_p3", "_r3"];
    ["a null hull is not protected, and says why", !_p3 && {count _r3 > 0}] call _fnc_check;

    // --- scans ---------------------------------------------------------------
    // No enemy aircraft anywhere, so the honest answer is none.
    private _zones = [[getPosATL player, 2000]];
    private _air = [_o, "scanAir", [_zones, side player]] call ALIVE_fnc_ATOObserve;
    ["the air scan answers with a list", _air isEqualType []] call _fnc_check;
    ["and finds no enemy aircraft in an empty sky", count _air == 0] call _fnc_check;

    private _aa = [_o, "scanAirDefences", [_zones, side player]] call ALIVE_fnc_ATOObserve;
    ["the air defence scan answers with a list", _aa isEqualType []] call _fnc_check;

    // --- what counts as ammunition -------------------------------------------
    // The reading counts ordnance and nothing else, which is the whole of the
    // fault it replaced: every magazine was counted, and a CAS jet carries a
    // hundred and twenty flares and a designator round beside its bombs, so an
    // aircraft with everything spent still read as armed and never came home.
    //
    // Three airframes, because the cases have to be told apart: one that
    // carries ordnance, the same one with its ordnance gone and its flares
    // still aboard, and one that carries no ordnance at all on a full load.
    private _fnc_ord = {
        params ["_class"];
        private _v = createVehicle [_class, [(_spot select 0) + 60, _spot select 1, 0], [], 0, "CAN_COLLIDE"];
        _v setVariable ["ALIVE_profileIgnore", true, true];
        _v setPosATL [(_spot select 0) + 60, _spot select 1, 0];
        sleep 1;
        private _obs2 = [_v, _home] call _fnc_obs;
        private _out = [([_obs2,"ordnance"] call _fnc_get), ([_obs2,"armed"] call _fnc_get), _v];
        _out
    };

    (["B_Plane_CAS_01_F"] call _fnc_ord) params ["_jetRounds", "_jetArmed", "_jet"];
    diag_log format ["  info  a full CAS jet reads %1 rounds of ordnance, armed %2", _jetRounds, _jetArmed];
    ["a jet with a full load reports ordnance", _jetRounds > 0] call _fnc_check;
    ["and reports itself armed", _jetArmed isEqualTo true] call _fnc_check;

    // Everything that can hurt something, emptied, and the flares left alone.
    {
        private _w = _x;
        private _mags = getArray (configFile >> "CfgWeapons" >> _w >> "magazines");
        private _keep = (_mags findIf {"CMFlare" in _x || {"Chaff" in _x}}) > -1;
        if (!_keep) then { _jet setAmmo [_w, 0] };
    } forEach (_jet weaponsTurret [-1]);
    sleep 1;
    private _spent = [_jet, _home] call _fnc_obs;
    diag_log format ["  info  with its ordnance emptied it reads %1 rounds, armed %2, and %3 magazines are still aboard",
        [_spent,"ordnance"] call _fnc_get, [_spent,"armed"] call _fnc_get, count (magazinesAmmo _jet)];
    ["with its ordnance gone it reports none, though its flares are still aboard",
        ([_spent,"ordnance"] call _fnc_get) == 0] call _fnc_check;
    ["and is still an armed aircraft, so it is sent home rather than left there",
        ([_spent,"armed"] call _fnc_get) isEqualTo true] call _fnc_check;
    deleteVehicle _jet;
    sleep 1;

    (["B_T_VTOL_01_infantry_F"] call _fnc_ord) params ["_vtolRounds", "_vtolArmed", "_vtol"];
    diag_log format ["  info  a full VTOL transport reads %1 rounds of ordnance, armed %2", _vtolRounds, _vtolArmed];
    ["a transport that carries only flares and a designator reports no ordnance",
        _vtolRounds == 0] call _fnc_check;
    ["and is not an armed aircraft, so having none is not grounds for anything",
        _vtolArmed isEqualTo false] call _fnc_check;
    deleteVehicle _vtol;
    sleep 1;

    // --- are the targets still there -----------------------------------------
    // This reading was declared false and never worked out, so the exit from
    // being on station when the targets are gone could never fire and an
    // aircraft held over a target somebody else had destroyed stayed for its
    // whole clock. The dangerous direction is the other one: answering TRUE
    // wrongly brings every sortie home, so the cases that must stay false are
    // checked as carefully as the one that must go true.
    private _hi = [(_spot select 0) + 120, _spot select 1, 300];
    private _jet = createVehicle ["B_Plane_CAS_01_F", _hi, [], 0, "FLY"];
    _jet setVariable ["ALIVE_profileIgnore", true, true];
    _jet setPosATL _hi;
    sleep 2;
    private _station = [_hi select 0, _hi select 1, 0];

    // A sortie on station over its target, with one live thing to attack.
    private _victim = createVehicle ["Land_BagFence_Long_F", [(_hi select 0) + 30, _hi select 1, 0], [], 0, "CAN_COLLIDE"];
    private _fnc_tg = {
        params ["_targets"];
        private _sortie = ["CAS", _station, 600, 2000, "s_test", _targets, ""];
        private _o2 = [nil, "create"] call ALIVE_fnc_ATOObserve;
        private _obs2 = [_o2, "observe", [_jet, _home, false, _sortie, time]] call ALIVE_fnc_ATOObserve;
        [([_obs2, "onStation", false] call ALIVE_fnc_hashGet),
         ([_obs2, "targetsGone", "MISSING"] call ALIVE_fnc_hashGet)]
    };

    ([[_victim]] call _fnc_tg) params ["_onSt", "_goneLive"];
    diag_log format ["  info  on station %1, and with a live target it reads gone %2", _onSt, _goneLive];
    ["an aircraft over its target reads as on station", _onSt] call _fnc_check;
    ["and with its target still standing, the targets are NOT gone",
        _goneLive isEqualTo false] call _fnc_check;

    // The case that matters most: no targets at all. Every patrol is raised
    // this way, and answering true here would send them all home on arrival.
    ["a sortie with no targets never reports them gone",
        (([[]] call _fnc_tg) select 1) isEqualTo false] call _fnc_check;

    // A profile id nothing knows about. A killed profile is unregistered from
    // the handler, so this is what a destroyed target looks like.
    ["a target the profile system has never heard of counts as gone",
        (([["NOT_A_REAL_PROFILE_ID"]] call _fnc_tg) select 1) isEqualTo true] call _fnc_check;

    // And the real case: the thing it was sent to attack is destroyed.
    deleteVehicle _victim;
    sleep 1;
    ["a target that has been destroyed counts as gone",
        (([[_victim]] call _fnc_tg) select 1) isEqualTo true] call _fnc_check;

    // Away from its station it is asked as well now, so a sortie whose target
    // has died is called off on its way out rather than on arrival.
    _jet setPosATL [(_spot select 0) + 4000, _spot select 1, 300];
    sleep 2;
    ["and away from its station a target that is gone reads gone as well",
        (([["NOT_A_REAL_PROFILE_ID"]] call _fnc_tg) select 1) isEqualTo true] call _fnc_check;
    ["while a sortie with no targets still never does",
        (([[]] call _fnc_tg) select 1) isEqualTo false] call _fnc_check;

    { deleteVehicle _x } forEach (crew _jet);
    deleteVehicle _jet;
    sleep 1;

    // --- the hull is destroyed ------------------------------------------------
    deleteVehicle _veh;
    sleep 1;
    _obs = [_veh, _home] call _fnc_obs;
    ["a deleted hull reports itself gone", [_obs,"objectLost"] call _fnc_get] call _fnc_check;
    ["without throwing", !isNil "_obs"] call _fnc_check;

    diag_log format ["  info  %1 assertions", _checked];
    diag_log format ["  info  %1 check(s) skipped for want of a player", count _skips];
    if (count _fails == 0) then {
        diag_log "=== ATO Observer test: ALL PASS ===";
    } else {
        diag_log format ["=== ATO Observer test: %1 FAILURE(S): %2 ===", count _fails, _fails];
    };
};

"ATO Observer test started, results follow in the log"
