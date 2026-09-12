#include "\x\alive\addons\mil_ato\script_component.hpp"

SCRIPT(test_ato_effect);

/* ----------------------------------------------------------------------------
Effector test.

Smallest mission: a player standing anywhere with clear ground in front, no
ALiVE modules, no aircraft. The test creates the hulls it needs and removes
them afterwards.

The point of this piece is that it can be told to do the same thing twice and
the world does not move the second time, and that it refuses out loud when it
must not act at all. So most of what follows is: apply, apply again, and check
nothing changed and it said so.
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

    // Some checks here need a real player to sit in the aircraft, and a
    // dedicated server has none. Those are skipped rather than failed, and the
    // skip is printed and counted so the run says what it did not cover.
    private _skipped = [];
    private _fnc_skip = {
        _skipped pushBack _this;
        diag_log format ["  skip  %1  (needs a player at a keyboard)", _this];
    };

    diag_log "=== ATO Effector test ===";

    private _e = [nil, "create"] call ALIVE_fnc_ATOEffect;
    private _s = [nil, "create"] call ALIVE_fnc_ATOSurface;

    // Anchored on the player when there is one and on the Agia Marina strip
    // when there is not, so this runs on the headless rig as well as in front
    // of somebody. A dedicated server has no player at all.
    private _from = if (isNull player) then {[1839.76, 5750.47, 0]} else {getPosATL player};
    private _bearing = if (isNull player) then {0} else {getDir player};
    private _spot = _from getPos [45, _bearing];
    private _home = [[_spot select 0, _spot select 1, 0], 0, "terrain"];
    private _veh = createVehicle ["B_Heli_Transport_01_F", _spot, [], 0, "CAN_COLLIDE"];
    _veh setPosATL [_spot select 0, _spot select 1, 0];
    sleep 2;

    private _fnc_apply = {
        params ["_effect", ["_extra", []]];
        [_e, "apply", [_effect, _veh, _home, _extra]] call ALIVE_fnc_ATOEffect
    };

    // --- the engine, twice ---------------------------------------------------
    (["engineOn"] call _fnc_apply) params ["_st1", "_m1", "_d1"];
    ["the engine starts", _st1 isEqualTo "ok" && {!_m1}] call _fnc_check;
    (["engineOn"] call _fnc_apply) params ["_st2", "_m2", "_d2"];
    ["starting it again changes nothing and says so", _st2 isEqualTo "ok" && {_m2}] call _fnc_check;

    (["engineOff"] call _fnc_apply) params ["_st3", "_m3"];
    ["the engine stops", _st3 isEqualTo "ok" && {!_m3}] call _fnc_check;
    (["engineOff"] call _fnc_apply) params ["_st4", "_m4"];
    ["stopping it again changes nothing and says so", _st4 isEqualTo "ok" && {_m4}] call _fnc_check;

    // --- crew ----------------------------------------------------------------
    (["mintCrew"] call _fnc_apply) params ["_st5", "_m5", "_d5"];
    sleep 1;
    ["a crew is created", _st5 isEqualTo "ok" && {!_m5} && {count (crew _veh) > 0}] call _fnc_check;
    private _crewCount = count (crew _veh);
    (["mintCrew"] call _fnc_apply) params ["_st6", "_m6"];
    ["asking again does not create a second crew",
        _m6 && {count (crew _veh) == _crewCount}] call _fnc_check;

    // --- orders --------------------------------------------------------------
    // On the ground, so a chain without a hold is allowed.
    private _chain = [["MOVE", _spot getPos [300, 0]], ["LOITER", _spot getPos [400, 0]]];
    (["issueOrders", [_chain]] call _fnc_apply) params ["_st7", "_m7", "_d7"];
    ["orders are issued", _st7 isEqualTo "ok" && {!_m7}] call _fnc_check;
    (["issueOrders", [_chain]] call _fnc_apply) params ["_st8", "_m8"];
    ["issuing the same orders again leaves them alone", _st8 isEqualTo "ok" && {_m8}] call _fnc_check;

    (["issueOrders", [[]]] call _fnc_apply) params ["_st9", "_m9", "_d9"];
    ["an empty order list is refused", _st9 isEqualTo "refused"] call _fnc_check;

    (["clearOrders"] call _fnc_apply) params ["_st10", "_m10"];
    ["orders are cleared", _st10 isEqualTo "ok"] call _fnc_check;
    (["clearOrders"] call _fnc_apply) params ["_st11", "_m11"];
    ["clearing again changes nothing and says so", _m11] call _fnc_check;

    // --- an order chain that runs out, in the air ----------------------------
    // This is the one that killed an aircraft: orders that simply end.
    private _flyer = createVehicle ["B_Heli_Transport_01_F", _spot getPos [200, 90], [], 0, "FLY"];
    _flyer setPosATL [(getPosATL _flyer) select 0, (getPosATL _flyer) select 1, 200];
    createVehicleCrew _flyer;
    sleep 2;
    private _bad = [["MOVE", _spot getPos [500, 0]]];
    private _r = [_e, "apply", ["issueOrders", _flyer, _home, [_bad]]] call ALIVE_fnc_ATOEffect;
    _r params ["_st12", "_m12", "_d12"];
    ["orders that run out are refused for an aircraft in the air",
        _st12 isEqualTo "refused" && {_d12 isEqualTo "no terminal hold"}] call _fnc_check;

    private _good = [["MOVE", _spot getPos [500, 0]], ["LOITER", _spot getPos [600, 0]]];
    (([_e, "apply", ["issueOrders", _flyer, _home, [_good]]] call ALIVE_fnc_ATOEffect)) params ["_st13"];
    ["the same orders ending in a hold are accepted", _st13 isEqualTo "ok"] call _fnc_check;
    { deleteVehicle _x } forEach (crew _flyer);
    deleteVehicle _flyer;

    // --- refusals with a player aboard ---------------------------------------
    // Nothing may move the aircraft, and nothing may take its crew, while
    // somebody is sitting in it.
    if (isNull player) then {
        {
            format ["%1 is refused with a player aboard", _x] call _fnc_skip;
        } forEach ["placeOnSlot", "forceLanded", "airborneStart", "forceLaunch", "standDownCrew"];
    } else {
        player moveInCargo _veh;
        sleep 2;
        {
            private _eff = _x;
            (([_e, "apply", [_eff, _veh, _home, [_s]]] call ALIVE_fnc_ATOEffect)) params ["_stx", "_mx", "_dx"];
            [format ["%1 is refused with a player aboard", _eff],
                _stx isEqualTo "refused" && {_dx isEqualTo "player aboard"}] call _fnc_check;
        } forEach ["placeOnSlot", "forceLanded", "airborneStart", "forceLaunch", "standDownCrew"];
        moveOut player;
        sleep 1;
    };

    // --- putting it on its slot ----------------------------------------------
    _veh setPosATL [(_spot select 0) + 60, (_spot select 1) + 60, 0];
    sleep 1;
    (["placeOnSlot", [_s]] call _fnc_apply) params ["_st14", "_m14", "_d14"];
    sleep 1;
    ["an aircraft away from its stand is put back", _st14 isEqualTo "ok" && {!_m14}] call _fnc_check;
    (["placeOnSlot", [_s]] call _fnc_apply) params ["_st15", "_m15"];
    ["asking again while it is already there changes nothing", _m15] call _fnc_check;

    // --- protection -----------------------------------------------------------
    _veh setVariable ["profileID", "LEFTOVER_STAMP", true];
    (["shield", ["BLU_F_0"]] call _fnc_apply) params ["_st16", "_m16"];
    ["shielding clears a leftover stamp",
        _st16 isEqualTo "ok" && {(_veh getVariable ["profileID", ""]) isEqualTo ""}] call _fnc_check;
    ["and marks the aircraft as ours",
        (_veh getVariable ["ALiVE_mil_ato_tail", ""]) isEqualTo "BLU_F_0"] call _fnc_check;
    (["shield", ["BLU_F_0"]] call _fnc_apply) params ["_st17", "_m17"];
    ["shielding again changes nothing and says so", _m17] call _fnc_check;

    // --- standing the crew down ------------------------------------------------
    // A player is within 300 m (the tester), so they should be dismissed rather
    // than deleted in front of them.
    if (isNull player) then {
        "the crew is dismissed rather than vanished while watched" call _fnc_skip;
    } else {
        (["standDownCrew"] call _fnc_apply) params ["_st18", "_m18", "_d18"];
        ["the crew is dismissed rather than vanished while watched",
            _st18 isEqualTo "ok" && {_d18 isEqualTo "dismissed"}] call _fnc_check;
    };

    // --- re-crewing an aircraft whose crew was killed ---------------------------
    // Bodies stay in their seats, and crew creation only fills empty ones, so
    // this only works if the dead are taken out first.
    private _dead = createVehicle ["B_Heli_Transport_01_F", _spot getPos [120, 180], [], 0, "CAN_COLLIDE"];
    _dead setPosATL [(getPosATL _dead) select 0, (getPosATL _dead) select 1, 0];
    createVehicleCrew _dead;
    sleep 2;
    { _x setDamage 1 } forEach (crew _dead);
    sleep 2;
    ["the crew really are dead", ({alive _x} count (crew _dead)) == 0] call _fnc_check;
    (([_e, "apply", ["recrewInPlace", _dead, _home, []]] call ALIVE_fnc_ATOEffect)) params ["_stR", "_mR", "_dR"];
    sleep 2;
    ["an aircraft with a dead crew is crewed again",
        _stR isEqualTo "ok" && {({alive _x} count (crew _dead)) > 0}] call _fnc_check;
    { deleteVehicle _x } forEach (crew _dead);
    deleteVehicle _dead;

    // --- things this pass does not do ------------------------------------------
    {
        (([_e, "apply", [_x, _veh, _home, []]] call ALIVE_fnc_ATOEffect)) params ["_sty", "_my", "_dy"];
        [format ["%1 refuses rather than doing nothing quietly", _x],
            _sty isEqualTo "refused" && {_dy isEqualTo "not built"}] call _fnc_check;
    } forEach ["catapult", "tailhook", "holdTargets"];

    (([_e, "apply", ["somethingNobodyWrote", _veh, _home, []]] call ALIVE_fnc_ATOEffect)) params ["_st19", "_m19", "_d19"];
    ["an effect it has never heard of is refused",
        _st19 isEqualTo "refused" && {_d19 isEqualTo "unknown effect"}] call _fnc_check;

    (([_e, "apply", ["engineOn", objNull, _home, []]] call ALIVE_fnc_ATOEffect)) params ["_st20", "_m20", "_d20"];
    ["an effect on a missing aircraft is refused", _st20 isEqualTo "refused"] call _fnc_check;

    // --- tidy -------------------------------------------------------------------
    { deleteVehicle _x } forEach (crew _veh);
    deleteVehicle _veh;

    diag_log format ["  info  %1 assertions", _checked];
    // The skips are named in the verdict, not just counted. A run that says
    // ALL PASS while quietly leaving five checks out is worse than one that
    // fails, because nobody goes looking.
    if (count _skipped > 0) then {
        diag_log format ["  info  %1 check(s) skipped for want of a player: %2",
            count _skipped, _skipped];
    };
    if (count _fails == 0) then {
        if (count _skipped == 0) then {
            diag_log "=== ATO Effector test: ALL PASS ===";
        } else {
            diag_log format ["=== ATO Effector test: ALL PASS, %1 SKIPPED ===", count _skipped];
        };
    } else {
        diag_log format ["=== ATO Effector test: %1 FAILURE(S): %2 ===", count _fails, _fails];
    };
};

"ATO Effector test started, results follow in the log"
