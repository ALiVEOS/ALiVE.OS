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
        && {([_dead,"playerControl"] call _fnc_get) isEqualType false}] call _fnc_check;
    ["and reports nobody aboard it", [_dead,"crewLoss"] call _fnc_get] call _fnc_check;

    // --- a real hull ---------------------------------------------------------
    private _spot = (getPosATL player) getPos [40, getDir player];
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

    // --- the player flies it -------------------------------------------------
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

    // --- the hull is destroyed ------------------------------------------------
    deleteVehicle _veh;
    sleep 1;
    _obs = [_veh, _home] call _fnc_obs;
    ["a deleted hull reports itself gone", [_obs,"objectLost"] call _fnc_get] call _fnc_check;
    ["without throwing", !isNil "_obs"] call _fnc_check;

    diag_log format ["  info  %1 assertions", _checked];
    if (count _fails == 0) then {
        diag_log "=== ATO Observer test: ALL PASS ===";
    } else {
        diag_log format ["=== ATO Observer test: %1 FAILURE(S): %2 ===", count _fails, _fails];
    };
};

"ATO Observer test started, results follow in the log"
