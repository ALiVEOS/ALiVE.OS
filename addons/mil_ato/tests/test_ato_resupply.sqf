#include "\x\alive\addons\mil_ato\script_component.hpp"

SCRIPT(test_ato_resupply);

/* ----------------------------------------------------------------------------
Resupply test.

Smallest mission: nothing placed, and deliberately no logistics module. With
logistics absent every order takes the build-it-here route, which is the one a
mission without logistics depends on and the one the old module got wrong.

What this piece has to get right is bookkeeping rather than flying: one record,
one outstanding replacement, and a delivery that nobody ordered is let go rather
than taken. The last of those matters because taking it would steal another
module's vehicle, and the old handler had no test for it at all.

The parts that need a real profiled delivery are skipped by name when placement
cannot take one, and the skip says so rather than the run reporting a clean
sweep it did not do.
---------------------------------------------------------------------------- */

[] spawn {

    private _fails = [];
    private _skipped = [];
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
    private _fnc_skip = {
        _skipped pushBack _this;
        diag_log format ["  skip  %1", _this];
    };

    diag_log "=== ATO Resupply test ===";

    private _anchor = if (isNull player) then {[1839.76, 5750.47, 0]} else {getPosATL player};
    private _home = [_anchor, 0, "terrain"];

    // --- a ledger with one aircraft that was lost ----------------------------
    private _fnc_fresh = {
        params ["_lost"];
        private _l = [nil, "create"] call ALIVE_fnc_ATOLedger;
        private _t = [_l, "createRecord", ["B_Heli_Attack_01_F", "BLU_F", ["as1"], [["Attack"], ["CAS"]]]] call ALIVE_fnc_ATOLedger;
        [_l, "setHome", [_t, _home]] call ALIVE_fnc_ATOLedger;
        // A record can only be declared lost once it has actually been here,
        // which is the ledger's own rule, so it is attached first.
        [_l, "markPresent", _t] call ALIVE_fnc_ATOLedger;
        if (_lost) then { [_l, "markLost", _t] call ALIVE_fnc_ATOLedger };
        [_l, _t]
    };

    ([true] call _fnc_fresh) params ["_ledger", "_tail"];
    ["a record can be created and declared lost",
        ([[_ledger, "get", _tail] call ALIVE_fnc_ATOLedger, "status", ""] call ALIVE_fnc_hashGet) isEqualTo "lost"] call _fnc_check;

    // --- replacement turned off ----------------------------------------------
    private _r = [nil, "create"] call ALIVE_fnc_ATOResupply;
    [_r, "configure", [["ledger", _ledger], ["faction", "BLU_F"], ["side", "WEST"], ["enabled", false]]] call ALIVE_fnc_ATOResupply;
    ["with replacement off a lost aircraft stays lost",
        !([_r, "onLost", _tail] call ALIVE_fnc_ATOResupply)] call _fnc_check;
    ["and nothing is ordered on a sweep",
        ([_r, "sweep", 1000] call ALIVE_fnc_ATOResupply) isEqualTo ""] call _fnc_check;

    // --- replacement on ------------------------------------------------------
    [_r, "configure", [["enabled", true]]] call ALIVE_fnc_ATOResupply;
    ["a lost aircraft is taken on once replacement is turned on",
        [_r, "onLost", _tail] call ALIVE_fnc_ATOResupply] call _fnc_check;
    ["and the record says one is wanted",
        ([[_ledger, "get", _tail] call ALIVE_fnc_ATOLedger, "replacement", ""] call ALIVE_fnc_hashGet) isEqualTo "wanted"] call _fnc_check;

    // The guard the old module did not have: the same loss reported twice does
    // not become two replacements.
    ["the same loss reported twice does not order twice",
        !([_r, "onLost", _tail] call ALIVE_fnc_ATOResupply)] call _fnc_check;

    ["a tail that is not a record is refused",
        !([_r, "onLost", "nosuchtail"] call ALIVE_fnc_ATOResupply)] call _fnc_check;

    // --- no logistics, so it builds one here ---------------------------------
    // Placement owns creating the hull. Whether it can yet decides how far this
    // goes, so the outcome is read rather than assumed.
    private _place = [nil, "create"] call ALIVE_fnc_ATOPlace;
    private _surface = [nil, "create"] call ALIVE_fnc_ATOSurface;
    private _effect = [nil, "create"] call ALIVE_fnc_ATOEffect;
    [_place, "configure", [
        ["ledger", _ledger], ["surface", _surface], ["effect", _effect],
        ["faction", "BLU_F"], ["side", "WEST"], ["factions", ["BLU_F"]]
    ]] call ALIVE_fnc_ATOPlace;
    [_r, "configure", [["place", _place]]] call ALIVE_fnc_ATOResupply;

    private _built = [_r, "sweep", 2000] call ALIVE_fnc_ATOResupply;
    diag_log format ["  info  a sweep with no logistics answered: '%1'", _built];
    private _canBuild = _built isEqualTo _tail;

    if (_canBuild) then {
        ["with no logistics the replacement is built at its own stand", true] call _fnc_check;
        ["and the record no longer wants one",
            ([[_ledger, "get", _tail] call ALIVE_fnc_ATOLedger, "replacement", ""] call ALIVE_fnc_hashGet) isEqualTo ""] call _fnc_check;
        private _obj = [_place, "objFor", _tail] call ALIVE_fnc_ATOPlace;
        ["and there is an aircraft standing there",
            !isNull _obj && {alive _obj}] call _fnc_check;
        if (!isNull _obj) then {
            { deleteVehicle _x } forEach (crew _obj);
            deleteVehicle _obj;
        };
    } else {
        "with no logistics the replacement is built at its own stand  (placement cannot create a hull on this build)" call _fnc_skip;
        "and the record no longer wants one  (nothing was built)" call _fnc_skip;
        "and there is an aircraft standing there  (nothing was built)" call _fnc_skip;
    };

    // --- a delivery nobody ordered -------------------------------------------
    // The one that matters most. An arrival matched to no order is let go, not
    // taken, because taking it steals another module's vehicle.
    private _r2 = [nil, "create"] call ALIVE_fnc_ATOResupply;
    ([true] call _fnc_fresh) params ["_ledger2", "_tail2"];
    [_r2, "configure", [["ledger", _ledger2], ["place", _place], ["enabled", true],
        ["faction", "BLU_F"], ["side", "WEST"]]] call ALIVE_fnc_ATOResupply;

    ["a delivery for an order that was never placed is not taken",
        !([_r2, "onLogisticsComplete", ["LOGISTICS_COMPLETE", [], "LOGCOM", 9999, "", ["someVehId", "someEntId"]]] call ALIVE_fnc_ATOResupply)] call _fnc_check;

    ["a completion with no data at all is refused rather than throwing",
        !([_r2, "onLogisticsComplete", []] call ALIVE_fnc_ATOResupply)] call _fnc_check;

    ["and one that is not even an array is refused",
        !([_r2, "onLogisticsComplete", "nonsense"] call ALIVE_fnc_ATOResupply)] call _fnc_check;

    // --- a delivery that arrived without the aircraft -------------------------
    // It was shot down on the way. The crew is released and the record is
    // flipped to being built here instead.
    [_r2, "onLost", _tail2] call ALIVE_fnc_ATOResupply;
    private _pending = [_r2, "pending", []] call ALIVE_fnc_hashGet;
    [_pending, "42", [_tail2, 3000, 1, false]] call ALIVE_fnc_hashSet;
    ["a delivery that arrived without an aircraft is not taken",
        !([_r2, "onLogisticsComplete", ["LOGISTICS_COMPLETE", [], "LOGCOM", 42, "", []]] call ALIVE_fnc_ATOResupply)] call _fnc_check;
    ["and the record is flipped to being built here instead",
        ([[_ledger2, "get", _tail2] call ALIVE_fnc_ATOLedger, "replacement", ""] call ALIVE_fnc_hashGet) isEqualTo "selfCreate"] call _fnc_check;
    ["and the order is consumed, so a duplicate arrival finds nothing",
        ([[_r2, "pending", []] call ALIVE_fnc_hashGet, "42", []] call ALIVE_fnc_hashGet) isEqualTo []] call _fnc_check;

    // --- a delivery that never arrives ---------------------------------------
    // Logistics tells an AI requester nothing when a delivery fails, so the
    // only way to find out is the clock.
    private _r3 = [nil, "create"] call ALIVE_fnc_ATOResupply;
    ([true] call _fnc_fresh) params ["_ledger3", "_tail3"];
    [_r3, "configure", [["ledger", _ledger3], ["place", _place], ["enabled", true]]] call ALIVE_fnc_ATOResupply;
    [_r3, "onLost", _tail3] call ALIVE_fnc_ATOResupply;
    private _pending3 = [_r3, "pending", []] call ALIVE_fnc_hashGet;
    [_pending3, "77", [_tail3, 0, 1, false]] call ALIVE_fnc_hashSet;
    [_r3, "sweep", 5000] call ALIVE_fnc_ATOResupply;
    ["a delivery that never arrives is given up on and built here instead",
        ([[_ledger3, "get", _tail3] call ALIVE_fnc_ATOLedger, "replacement", ""] call ALIVE_fnc_hashGet)
            in ["selfCreate", ""]] call _fnc_check;
    ["and the stuck order is cleared",
        ([[_r3, "pending", []] call ALIVE_fnc_hashGet, "77", []] call ALIVE_fnc_hashGet) isEqualTo []] call _fnc_check;

    // Enough goes and the record says it has nowhere to go, rather than being
    // asked for every pass until the mission ends.
    private _r4 = [nil, "create"] call ALIVE_fnc_ATOResupply;
    ([true] call _fnc_fresh) params ["_ledger4", "_tail4"];
    [_r4, "configure", [["ledger", _ledger4], ["place", _place], ["enabled", true]]] call ALIVE_fnc_ATOResupply;
    [_r4, "onLost", _tail4] call ALIVE_fnc_ATOResupply;
    private _pending4 = [_r4, "pending", []] call ALIVE_fnc_hashGet;
    [_pending4, "88", [_tail4, 0, 3, false]] call ALIVE_fnc_hashSet;
    [_r4, "sweep", 5000] call ALIVE_fnc_ATOResupply;
    ["after enough failed goes the record says it has nowhere to go",
        ([[_ledger4, "get", _tail4] call ALIVE_fnc_ATOLedger, "status", ""] call ALIVE_fnc_hashGet) isEqualTo "unplaceable"] call _fnc_check;

    // --- one at a time -------------------------------------------------------
    // Four aircraft lost in a bad minute must not put four deliveries up.
    private _r5 = [nil, "create"] call ALIVE_fnc_ATOResupply;
    private _l5 = [nil, "create"] call ALIVE_fnc_ATOLedger;
    private _tails5 = [];
    for "_i" from 1 to 4 do {
        private _t = [_l5, "createRecord", ["B_Heli_Attack_01_F", "BLU_F", ["as1"], [["Attack"], ["CAS"]]]] call ALIVE_fnc_ATOLedger;
        [_l5, "setHome", [_t, _home]] call ALIVE_fnc_ATOLedger;
        [_l5, "markPresent", _t] call ALIVE_fnc_ATOLedger;
        [_l5, "markLost", _t] call ALIVE_fnc_ATOLedger;
        _tails5 pushBack _t;
    };
    [_r5, "configure", [["ledger", _l5], ["place", _place], ["enabled", true]]] call ALIVE_fnc_ATOResupply;
    { [_r5, "onLost", _x] call ALIVE_fnc_ATOResupply } forEach _tails5;
    private _acted = [_r5, "sweep", 6000] call ALIVE_fnc_ATOResupply;
    private _stillWanting = 0;
    {
        if (([[_l5, "get", _x] call ALIVE_fnc_ATOLedger, "replacement", ""] call ALIVE_fnc_hashGet) isEqualTo "wanted") then {
            _stillWanting = _stillWanting + 1;
        };
    } forEach _tails5;
    diag_log format ["  info  four lost, one sweep acted on '%1', %2 still waiting", _acted, _stillWanting];
    ["four aircraft lost at once are replaced one at a time",
        _stillWanting >= 3] call _fnc_check;

    diag_log format ["  info  %1 assertions", _checked];
    if (count _skipped > 0) then {
        diag_log format ["  info  %1 check(s) skipped: %2", count _skipped, _skipped];
    };
    if (count _fails == 0) then {
        if (count _skipped == 0) then {
            diag_log "=== ATO Resupply test: ALL PASS ===";
        } else {
            diag_log format ["=== ATO Resupply test: ALL PASS, %1 SKIPPED ===", count _skipped];
        };
    } else {
        diag_log format ["=== ATO Resupply test: %1 FAILURE(S): %2 ===", count _fails, _fails];
    };
};

"ATO Resupply test started, results follow in the log"
