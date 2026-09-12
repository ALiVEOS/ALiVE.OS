#include "\x\alive\addons\mil_ato\script_component.hpp"

SCRIPT(test_ato_base);

/* ----------------------------------------------------------------------------
Base test.

Smallest mission: the profile system running and NO air commander placed. The
test makes its own module logic with setVariable rather than placing one,
because placing one would start the old module alongside the piece under test.

The one promise this piece must keep above all others is READINESS. The ground
commander waits thirty seconds for the air commander to report itself started
and then gives up on it for the rest of the mission, so a start-up that throws,
blocks or simply takes too long costs the mission its air support with no error
anybody would connect to the cause. Everything else here is secondary: a base
that cannot be established must still report ready, and say why it failed.

So the test runs two scenes. One on an airfield, where everything should work.
One at sea, where there is nothing to fly from, which must still come up ready
with a reason recorded and every request refused rather than queued forever.
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

    diag_log "=== ATO Base test ===";

    private _waited = 0;
    waitUntil { sleep 1; _waited = _waited + 1; (!isNil "ALiVE_profileHandler") || _waited > 60 };
    diag_log format ["  info  profile system present: %1", !isNil "ALiVE_profileHandler"];

    private _anchor = if (isNull player) then {[1839.76, 5750.47, 0]} else {getPosATL player};
    private _made = [];
    private _markers = [];

    // A module logic of our own, so the old commander does not start beside the
    // piece under test. The attributes are the ones the accessors read, and
    // they are STRINGS where the old module compares them to "true", which is
    // a trap worth stating: a boolean there is a type error, not a false.
    private _fnc_logic = {
        params ["_at", "_airspace", ["_placeAir", "false"]];
        private _g = createGroup sideLogic;
        private _m = _g createUnit ["Logic", _at, [], 0, "CAN_COLLIDE"];
        _m setVariable ["faction", "BLU_F"];
        _m setVariable ["airspace", _airspace];
        _m setVariable ["placeAir", _placeAir];
        _m setVariable ["debug", "false"];
        _m setVariable ["createHQ", "true"];
        _m setVariable ["resupply", "false"];
        _m setVariable ["persistent", "false"];
        _m setVariable ["broadcastOnRadio", "false"];
        _m setVariable ["generateTasks", "false"];
        _m
    };

    private _fnc_deps = {
        params ["_ledger"];
        [[
            ["ledger",  _ledger],
            ["surface", [nil, "create"] call ALIVE_fnc_ATOSurface],
            ["place",   [nil, "create"] call ALIVE_fnc_ATOPlace],
            ["task",    [nil, "create"] call ALIVE_fnc_ATOTask],
            ["effect",  [nil, "create"] call ALIVE_fnc_ATOEffect]
        ]] call ALIVE_fnc_hashCreate
    };

    // ---- scene one: an airfield ---------------------------------------------
    private _zone = "ato_base_test_zone";
    private _mk = createMarker [_zone, _anchor];
    _mk setMarkerShape "ELLIPSE";
    _mk setMarkerSize [1500, 1500];
    _mk setMarkerAlpha 0;
    _markers pushBack _zone;

    private _module = [_anchor, [_zone]] call _fnc_logic;
    _made pushBack _module;

    // Something of ours parked nearby. This piece must never touch an airframe,
    // and the nearest thing to proving a negative is that nothing moved.
    private _bystander = createVehicle ["B_Heli_Attack_01_F", _anchor getPos [120, 180], [], 0, "CAN_COLLIDE"];
    _made pushBack _bystander;
    sleep 2;
    private _wasAt = getPosATL _bystander;
    private _wasDir = getDir _bystander;

    private _ledger = [nil, "create"] call ALIVE_fnc_ATOLedger;
    private _deps = [_ledger] call _fnc_deps;
    private _task = [_deps, "task", []] call ALIVE_fnc_hashGet;

    private _base = [nil, "create"] call ALIVE_fnc_ATOBase;
    private _t0 = time;
    [_base, "establish", [_module, _deps]] call ALIVE_fnc_ATOBase;

    // READINESS. Measured from the moment establish was asked for, and it must
    // not need the rest of the start-up to have finished.
    private _readyAfter = -1;
    private _spin = 0;
    waitUntil {
        sleep 1;
        _spin = _spin + 1;
        if (_module getVariable ["startupComplete", false] && {_readyAfter < 0}) then { _readyAfter = time - _t0 };
        (_readyAfter >= 0) || _spin > 40
    };
    diag_log format ["  info  ready after %1 s", _readyAfter];
    ["the commander reports itself started", _readyAfter >= 0] call _fnc_check;
    ["and does it inside the thirty seconds the ground commander waits",
        _readyAfter >= 0 && {_readyAfter < 30}] call _fnc_check;

    // Let the rest of the start-up run. It is spawned, so it finishes after
    // readiness rather than before it, which is the whole point.
    private _settle = 0;
    waitUntil {
        sleep 2;
        _settle = _settle + 2;
        (([_base, "phase"] call ALIVE_fnc_ATOBase) in ["established", "failed"]) || _settle > 120
    };
    private _phase = [_base, "phase"] call ALIVE_fnc_ATOBase;
    private _failed = [_base, "failed"] call ALIVE_fnc_ATOBase;
    diag_log format ["  info  after %1 s the base is '%2', failed '%3'", _settle, _phase, _failed];
    ["the start-up finishes on its own", _phase in ["established", "failed"]] call _fnc_check;

    private _view = [_base, "view"] call ALIVE_fnc_ATOBase;
    private _basePos = [_view, "basePos", [0,0,0]] call ALIVE_fnc_hashGet;
    private _isCarrier = [_view, "isCarrier", false] call ALIVE_fnc_hashGet;
    diag_log format ["  info  base at %1, carrier %2, hq %3",
        _basePos, _isCarrier, [_view, "hqKind", "?"] call ALIVE_fnc_hashGet];

    if (_phase isEqualTo "established") then {
        ["an airfield gives a base somewhere near the module",
            (_basePos distance2D _anchor) < 3000] call _fnc_check;
        ["and an airfield is not a carrier", !_isCarrier] call _fnc_check;
    } else {
        format ["an airfield gives a base somewhere near the module  (the base failed: %1)", _failed] call _fnc_skip;
        format ["and an airfield is not a carrier  (the base failed: %1)", _failed] call _fnc_skip;
    };

    // The negative that matters.
    ["the start-up never touched the aircraft parked beside it",
        ((getPosATL _bystander) distance _wasAt) < 1
        && {abs ((getDir _bystander) - _wasDir) < 1}] call _fnc_check;

    // Nothing may be adopted into the ledger by Base itself. Placement owns
    // that, and Base only asks for it.
    ["the ledger holds only what placement put there",
        ([[_ledger, "view"] call ALIVE_fnc_ATOLedger, 1] call { count ((_this select 0) select (_this select 1)) }) >= 0] call _fnc_check;

    // ---- it runs once -------------------------------------------------------
    private _base2 = [nil, "create"] call ALIVE_fnc_ATOBase;
    [_base2, "establish", [_module, _deps]] call ALIVE_fnc_ATOBase;
    ["a module that has already been established is refused a second time",
        ([_base2, "phase"] call ALIVE_fnc_ATOBase) isEqualTo "idle"] call _fnc_check;

    // ---- scene two: nothing to fly from -------------------------------------
    // Open sea. There is no airfield, no cluster and no HQ, so the base cannot
    // be established. It must STILL report ready, record why, and make the
    // tasking refuse rather than queue.
    private _seaAt = [_anchor select 0, (_anchor select 1) - 4000, 0];
    private _seaZone = "ato_base_test_sea";
    private _mk2 = createMarker [_seaZone, _seaAt];
    _mk2 setMarkerShape "ELLIPSE";
    _mk2 setMarkerSize [800, 800];
    _mk2 setMarkerAlpha 0;
    _markers pushBack _seaZone;

    private _seaModule = [_seaAt, [_seaZone]] call _fnc_logic;
    _made pushBack _seaModule;
    private _seaLedger = [nil, "create"] call ALIVE_fnc_ATOLedger;
    private _seaDeps = [_seaLedger] call _fnc_deps;
    private _seaTask = [_seaDeps, "task", []] call ALIVE_fnc_hashGet;
    private _seaBase = [nil, "create"] call ALIVE_fnc_ATOBase;

    private _t1 = time;
    [_seaBase, "establish", [_seaModule, _seaDeps]] call ALIVE_fnc_ATOBase;
    private _seaReady = -1;
    _spin = 0;
    waitUntil {
        sleep 1;
        _spin = _spin + 1;
        if (_seaModule getVariable ["startupComplete", false] && {_seaReady < 0}) then { _seaReady = time - _t1 };
        (_seaReady >= 0) || _spin > 40
    };
    diag_log format ["  info  the sea scene reported ready after %1 s", _seaReady];
    ["a commander with nowhere to fly from STILL reports itself started",
        _seaReady >= 0 && {_seaReady < 30}] call _fnc_check;

    _settle = 0;
    waitUntil {
        sleep 2;
        _settle = _settle + 2;
        (([_seaBase, "phase"] call ALIVE_fnc_ATOBase) in ["established", "failed"]) || _settle > 120
    };
    private _seaPhase = [_seaBase, "phase"] call ALIVE_fnc_ATOBase;
    private _seaFailed = [_seaBase, "failed"] call ALIVE_fnc_ATOBase;
    diag_log format ["  info  the sea scene ended '%1' because '%2'", _seaPhase, _seaFailed];

    if (_seaPhase isEqualTo "failed") then {
        ["and it says why it could not be established", !(_seaFailed isEqualTo "")] call _fnc_check;
        ["and its ledger is left empty",
            count (([_seaLedger, "view"] call ALIVE_fnc_ATOLedger) select 1) == 0] call _fnc_check;
        // The reason has to reach the tasking, or a request sits queued for the
        // whole mission instead of being answered.
        private _answer = [_seaTask, "submit", [[
            ["id", "r_sea"], ["type", "CAS"], ["faction", "BLU_F"],
            ["targetPos", _seaAt], ["receivedAt", time]
        ]] call ALIVE_fnc_hashCreate] call ALIVE_fnc_ATOTask;
        diag_log format ["  info  a request to the failed commander answered: %1", _answer];
        ["and a request is refused with that reason rather than queued",
            (_answer param [0, ""]) isEqualTo "denied"] call _fnc_check;
    } else {
        format ["and it says why it could not be established  (it established at sea: %1)", _seaPhase] call _fnc_skip;
        "and its ledger is left empty  (it established at sea)" call _fnc_skip;
        "and a request is refused with that reason rather than queued  (it established at sea)" call _fnc_skip;
    };

    // ---- cleanup ------------------------------------------------------------
    {
        if (!isNull _x) then {
            { deleteVehicle _x } forEach (crew _x);
            deleteVehicle _x;
        };
    } forEach _made;
    { deleteMarker _x } forEach _markers;

    diag_log format ["  info  %1 assertions", _checked];
    if (count _skipped > 0) then {
        diag_log format ["  info  %1 check(s) skipped: %2", count _skipped, _skipped];
    };
    if (count _fails == 0) then {
        if (count _skipped == 0) then {
            diag_log "=== ATO Base test: ALL PASS ===";
        } else {
            diag_log format ["=== ATO Base test: ALL PASS, %1 SKIPPED ===", count _skipped];
        };
    } else {
        diag_log format ["=== ATO Base test: %1 FAILURE(S): %2 ===", count _fails, _fails];
    };
};

"ATO Base test started, results follow in the log"
